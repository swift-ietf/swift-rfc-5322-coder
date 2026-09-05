public import Byte
public import Coder
public import Cursor
public import Cursor_Standard_Library_Integration
public import RFC_5322
import Parser
import Serializer

extension RFC_5322.Mailbox {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_5322.Mailbox

        public typealias Failure = RFC_5322.Mailbox.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            var bytes: [Byte] = []
            var quoted = false
            var escaped = false
            var angled = false

            while true {
                let mark = input.checkpoint
                guard let byte = input.next() else { break }
                let code = byte.bitPattern

                if quoted {
                    if escaped {
                        escaped = false
                    } else if code == 0x5C {
                        escaped = true
                    } else if code == 0x22 {
                        quoted = false
                    }
                    bytes.append(byte)
                    continue
                }

                if code == 0x0D || code == 0x0A || (!angled && (code == 0x2C || code == 0x3B)) {
                    input.seek(to: mark)
                    break
                }

                if code == 0x22 {
                    quoted = true
                } else if code == 0x3C {
                    angled = true
                } else if code == 0x3E {
                    angled = false
                }

                bytes.append(byte)
            }

            var lower = bytes.startIndex
            var upper = bytes.endIndex
            while lower < upper, Scan.isWhitespace(bytes[lower]) { lower += 1 }
            while upper > lower, Scan.isWhitespace(bytes[upper - 1]) { upper -= 1 }

            do throws(Failure) {
                return try RFC_5322.Mailbox(ascii: bytes[lower..<upper])
            } catch {
                input.seek(to: start)
                throw error
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Scan.append(output.description, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_5322.Mailbox: Coder.Codable {}
