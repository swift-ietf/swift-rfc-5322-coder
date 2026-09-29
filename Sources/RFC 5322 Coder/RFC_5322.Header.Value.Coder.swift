public import Byte
public import Coder
public import Cursor
public import RFC_5322
import Parser
import Serializer

extension RFC_5322.Header.Value {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_5322.Header.Value

        public typealias Failure = RFC_5322.Header.Value.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            var bytes: [Byte] = []

            while true {
                let mark = input.checkpoint
                guard let byte = input.next() else { break }

                if byte.bitPattern == 0x0A {
                    input.seek(to: mark)
                    break
                }

                if byte.bitPattern == 0x0D {
                    guard let lf = input.next(), lf.bitPattern == 0x0A,
                        let wsp = input.next(), Scan.isWhitespace(wsp)
                    else {
                        input.seek(to: mark)
                        break
                    }
                    bytes.append(byte)
                    bytes.append(lf)
                    bytes.append(wsp)
                    continue
                }

                bytes.append(byte)
            }

            do throws(Failure) {
                return try RFC_5322.Header.Value(ascii: bytes)
            } catch {
                input.seek(to: start)
                throw error
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Scan.append(output.rawValue, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}
