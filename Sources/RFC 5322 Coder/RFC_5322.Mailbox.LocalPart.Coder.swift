public import Byte
public import Coder
public import Cursor
public import Cursor_Standard_Library_Integration
public import RFC_5322
import ASCII
import Parser
import Serializer

extension RFC_5322.Mailbox.LocalPart {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_5322.Mailbox.LocalPart

        public typealias Failure = RFC_5322.Mailbox.LocalPart.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            var bytes: [Byte] = []

            let mark = input.checkpoint
            if let first = input.next(), first.bitPattern == 0x22 {
                bytes.append(first)
                var escaped = false
                var terminated = false
                while let byte = input.next() {
                    bytes.append(byte)
                    if escaped {
                        escaped = false
                    } else if byte.bitPattern == 0x5C {
                        escaped = true
                    } else if byte.bitPattern == 0x22 {
                        terminated = true
                        break
                    }
                }
                guard terminated else {
                    input.seek(to: start)
                    throw .invalidQuotedString
                }
            } else {
                input.seek(to: mark)
                bytes = Scan.run(&input) { byte in
                    byte.bitPattern == 0x2E
                        || (byte.bitPattern < 0x80 && RFC_5322.isAtext(ASCII.Code(unchecked: byte)))
                }
            }

            do throws(Failure) {
                return try RFC_5322.Mailbox.LocalPart(ascii: bytes)
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

extension RFC_5322.Mailbox.LocalPart: Coder.Codable {}
