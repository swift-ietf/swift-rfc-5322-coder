public import Byte
public import Coder
public import Cursor
public import RFC_5322
import Parser
import Serializer

extension RFC_5322 {

    public enum Whitespace {}
}

extension RFC_5322.Whitespace {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = Void

        public typealias Failure = Never

        public let canonical: [Byte]

        public init(canonical: [Byte] = []) {
            self.canonical = canonical
        }

        public borrowing func parse(_ input: inout Input) {
            while true {
                let mark = input.checkpoint
                guard let byte = input.next(), Self.isWhitespace(byte) else {
                    input.seek(to: mark)
                    return
                }
            }
        }

        public borrowing func serialize(_ output: Void, into buffer: inout Buffer) {
            buffer.append(contentsOf: canonical)
        }

        public static func isWhitespace(_ byte: Byte) -> Bool {
            let code = byte.bitPattern
            return code == 0x20 || code == 0x09 || code == 0x0D || code == 0x0A
        }
    }
}
