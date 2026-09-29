import Pair
public import Byte
public import Coder
public import Cursor
public import RFC_5322
import ASCII
import Binary
import Parser
import Either
import Serializer

extension RFC_5322.DateTime {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_5322.DateTime

        public typealias Failure = RFC_5322.DateTime.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            let parts: Fields.Output
            do throws(Fields.Error) {
                parts = try Fields.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .invalidFormat("\(error)")
            }

            let monthName = String(decoding: parts.month, as: UTF8.self)
            guard let monthIndex = RFC_5322.DateTime.monthNames.firstIndex(of: monthName) else {
                input.seek(to: start)
                throw .invalidMonth(monthName)
            }

            let zone = String(decoding: parts.zone, as: UTF8.self)
            guard parts.zone.count == 5,
                let sign = Self.sign(parts.zone[0]),
                let hours = Int(String(decoding: parts.zone[1...2], as: UTF8.self)), hours <= 23,
                let minutes = Int(String(decoding: parts.zone[3...4], as: UTF8.self)), minutes <= 59
            else {
                input.seek(to: start)
                throw .invalidTimezone(zone)
            }
            let offset = sign * (hours * 3600 + minutes * 60)

            let dateTime: RFC_5322.DateTime
            do {
                dateTime = try RFC_5322.DateTime(
                    year: parts.year,
                    month: monthIndex + 1,
                    day: parts.day,
                    hour: parts.hour,
                    minute: parts.minute,
                    second: parts.second ?? 0,
                    timezoneOffsetSeconds: offset
                )
            } catch {
                input.seek(to: start)
                throw .invalidFormat("Date components invalid: \(error)")
            }

            if let dayOfWeek = parts.dayOfWeek {
                let dayName = String(decoding: dayOfWeek, as: UTF8.self)
                guard let expected = RFC_5322.DateTime.dayNames.firstIndex(of: dayName) else {
                    input.seek(to: start)
                    throw .invalidDayName(dayName)
                }
                let actual = dateTime.components.weekday
                guard actual == expected else {
                    input.seek(to: start)
                    throw .weekdayMismatch(
                        expected: RFC_5322.DateTime.dayNames[expected],
                        actual: RFC_5322.DateTime.dayNames[actual]
                    )
                }
            }

            return dateTime
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_5322.DateTime.serialize(output, into: &buffer)
        }

        private static func sign(_ byte: Byte) -> Int? {
            switch byte.bitPattern {
            case 0x2B: 1
            case 0x2D: -1
            default: nil
            }
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_5322.DateTime {

    public enum Fields {}
}

extension RFC_5322.DateTime.Fields {

    public typealias Output = (
        dayOfWeek: [Byte]?,
        day: Int,
        month: [Byte],
        year: Int,
        hour: Int,
        minute: Int,
        second: Int?,
        zone: [Byte]
    )

    public enum Error: Swift.Error, Equatable {
        case expectedDate
        case expectedTime
        case expectedZone
    }

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Failure = RFC_5322.DateTime.Fields.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            RFC_5322.Whitespace.Coder<Input, Buffer>().parse(&input)
            let probe = input.checkpoint
            let beginsWeekday = input.next().map(RFC_5322.DateTime.Fields.isLetter) ?? false
            input.seek(to: probe)
            let dayOfWeek: [Byte]?
            if beginsWeekday {
                do throws(DayOfWeek.Error) {
                    dayOfWeek = try DayOfWeek.Coder<Input, Buffer>().parse(&input)
                } catch { throw .expectedDate }
            } else { dayOfWeek = nil }
            let date: (Int, [Byte], Int)
            do throws(Date.Error) {
                date = try Date.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .expectedDate
            }
            let time: (Int, Int, Int?)
            do throws(Time.Error) {
                time = try Time.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .expectedTime
            }
            let zone: [Byte]
            do throws(Zone.Error) {
                zone = try Zone.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .expectedZone
            }
            return (dayOfWeek, date.0, date.1, date.2, time.0, time.1, time.2, zone)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            if let dayOfWeek = output.dayOfWeek {
                do throws(DayOfWeek.Error) {
                    try DayOfWeek.Coder<Input, Buffer>().serialize(dayOfWeek, into: &buffer)
                } catch {
                    throw .expectedDate
                }
            }
            do throws(Date.Error) {
                try Date.Coder<Input, Buffer>().serialize((output.day, output.month, output.year), into: &buffer)
            } catch {
                throw .expectedDate
            }
            do throws(Time.Error) {
                try Time.Coder<Input, Buffer>().serialize((output.hour, output.minute, output.second), into: &buffer)
            } catch {
                throw .expectedTime
            }
            do throws(Zone.Error) {
                try Zone.Coder<Input, Buffer>().serialize(output.zone, into: &buffer)
            } catch {
                throw .expectedZone
            }
        }
    }

    static func isLetter(_ byte: Byte) -> Bool {
        let code = byte.bitPattern
        return (code >= 0x41 && code <= 0x5A) || (code >= 0x61 && code <= 0x7A)
    }

    public enum DayOfWeek {}

    public enum Date {}

    public enum Time {}

    public enum Zone {}
}

extension RFC_5322.DateTime.Fields.DayOfWeek {

    public enum Error: Swift.Error, Equatable {
        case malformed
    }

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Failure = RFC_5322.DateTime.Fields.DayOfWeek.Error

        public init() {}

        @Coder::Builder<Input, Buffer>
        public var body: some Coding<Input, [Byte], Buffer, Failure> {
            Coder::Coder(Input.self, Buffer.self) {
                Parser::Many(3...3, Coder::First.Where(RFC_5322.DateTime.Fields.isLetter), rejected: { _ in true })
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: ","))
                RFC_5322.Whitespace.Coder(canonical: " ")
            }
            .mapFailure { (_) -> Failure in .malformed }
        }
    }
}

extension RFC_5322.DateTime.Fields.Date {

    public enum Error: Swift.Error, Equatable {
        case malformed
    }

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Failure = RFC_5322.DateTime.Fields.Date.Error

        public init() {}

        @Coder::Builder<Input, Buffer>
        public var body: some Coding<Input, (Int, [Byte], Int), Buffer, Failure> {
            Coder::Coder(Input.self, Buffer.self) {
                ASCII.Decimal.Coder<Input, Buffer, Int>()
                RFC_5322.Whitespace.Coder(canonical: " ")
                Parser::Many(3...3, Coder::First.Where(RFC_5322.DateTime.Fields.isLetter), rejected: { _ in true })
                RFC_5322.Whitespace.Coder(canonical: " ")
                ASCII.Decimal.Coder<Input, Buffer, Int>()
            }
            .map(to: { ($0.first.first, $0.first.second, $0.second) },
                 from: { .init(.init($0.0, $0.1), $0.2) })
            .mapFailure { (_) -> Failure in .malformed }
        }
    }
}

extension RFC_5322.DateTime.Fields.Time {

    public enum Error: Swift.Error, Equatable {
        case malformed
    }

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Failure = RFC_5322.DateTime.Fields.Time.Error

        public init() {}

        @Coder::Builder<Input, Buffer>
        public var body: some Coding<Input, (Int, Int, Int?), Buffer, Failure> {
            Coder::Coder(Input.self, Buffer.self) {
                RFC_5322.Whitespace.Coder(canonical: " ")
                ASCII.Decimal.Coder<Input, Buffer, Int>()
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: ":"))
                ASCII.Decimal.Coder<Input, Buffer, Int>()
                Parser::Optionally(
                    Coder::Coder(Input.self, Buffer.self) {
                        Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: ":"))
                        ASCII.Decimal.Coder<Input, Buffer, Int>()
                    }
                , rejected: { failure in if case .left = failure { return true }; return false })
            }
            .map(to: { ($0.first.first, $0.first.second, $0.second) },
                 from: { .init(.init($0.0, $0.1), $0.2) })
            .mapFailure { (_) -> Failure in .malformed }
        }
    }
}

extension RFC_5322.DateTime.Fields.Zone {

    public enum Error: Swift.Error, Equatable {
        case malformed
    }

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Failure = RFC_5322.DateTime.Fields.Zone.Error

        public init() {}

        @Coder::Builder<Input, Buffer>
        public var body: some Coding<Input, [Byte], Buffer, Failure> {
            Coder::Coder(Input.self, Buffer.self) {
                RFC_5322.Whitespace.Coder(canonical: " ")
                Parser::Many(1..., Coder::First.Where { !RFC_5322.Whitespace.Coder<Input, Buffer>.isWhitespace($0) }, rejected: { _ in true })
            }
            .mapFailure { (_) -> Failure in .malformed }
        }
    }
}
