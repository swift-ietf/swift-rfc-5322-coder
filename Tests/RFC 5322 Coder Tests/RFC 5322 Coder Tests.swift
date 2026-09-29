import Byte
import Coder
import Cursor
import Parser
import RFC_5322
import RFC_5322_Coder
import Serializer
import Testing

@Suite
struct `RFC 5322 Coder Tests` {
    @Suite struct `DateTime Tests` {}
    @Suite struct `Message ID Tests` {}
}

extension `RFC 5322 Coder Tests`.`DateTime Tests` {

    @Test
    func `parses a full date-time and stops after the zone`() throws {
        var input: ArraySlice<Byte> = "Tue, 15 Nov 1994 08:12:31 +0000\r\nNext"
        let date = try RFC_5322.DateTime.coder.parse(&input)
        #expect(date.components.year == 1994)
        #expect(date.components.month == 11)
        #expect(date.components.day == 15)
        #expect(date.components.hour == 8)
        #expect(date.components.minute == 12)
        #expect(date.components.second == 31)
        #expect(date.timezoneOffsetSeconds == 0)
        #expect(input.first == Byte(bitPattern: 0x0D))
    }

    @Test
    func `accepts a missing day of week and seconds`() throws {
        var input: ArraySlice<Byte> = "15 Nov 1994 08:12 +0200"
        let date = try RFC_5322.DateTime.coder.parse(&input)
        #expect(date.components.second == 0)
        #expect(date.timezoneOffsetSeconds == 7200)
    }

    @Test
    func `rejects a mismatching day of week and restores the cursor`() {
        var input: ArraySlice<Byte> = "Mon, 15 Nov 1994 08:12:31 +0000"
        #expect(throws: RFC_5322.DateTime.Error.weekdayMismatch(expected: "Mon", actual: "Tue")) {
            try RFC_5322.DateTime.coder.parse(&input)
        }
        #expect(input.count == 31)
    }

    @Test
    func `rejects a malformed time`() {
        var input: ArraySlice<Byte> = "15 Nov 1994 08-12 +0000"
        #expect(throws: RFC_5322.DateTime.Error.self) {
            try RFC_5322.DateTime.coder.parse(&input)
        }
    }

    @Test
    func `round-trips through its canonical form`() throws {
        let text = "Tue, 15 Nov 1994 08:12:31 +0000"
        let date = try RFC_5322.DateTime(text)
        #expect(try type(of: date).coder.serialize(date) == [Byte](utf8: text))
    }
}

extension `RFC 5322 Coder Tests`.`Message ID Tests` {

    @Test
    func `parses an angle-addressed identifier`() throws {
        var input: ArraySlice<Byte> = "<abc.123@example.com> rest"
        let id = try RFC_5322.Message.ID.coder.parse(&input)
        #expect(id.description == "<abc.123@example.com>")
        #expect(input.first == Byte(bitPattern: 0x20))
    }

    @Test
    func `rejects a missing at sign`() {
        var input: ArraySlice<Byte> = "<abc>"
        #expect(throws: RFC_5322.Message.ID.Error.self) {
            try RFC_5322.Message.ID.coder.parse(&input)
        }
        #expect(input.count == 5)
    }

    @Test
    func `round-trips`() throws {
        let id = try RFC_5322.Message.ID("<abc@example.com>")
        #expect(try type(of: id).coder.serialize(id) == [Byte](utf8: "<abc@example.com>"))
    }
}
