public import Byte
public import Coder
public import Cursor
public import Cursor_Standard_Library_Integration
public import RFC_5322
import Parser
import Serializer

extension RFC_5322.Header {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_5322.Header

        public typealias Failure = RFC_5322.Header.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint

            let name: RFC_5322.Header.Name
            do throws(RFC_5322.Header.Name.Error) {
                name = try RFC_5322.Header.Name.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .invalidName(error)
            }

            guard let colon = input.next(), colon.bitPattern == 0x3A else {
                input.seek(to: start)
                throw .invalidFormat(name.rawValue, reason: "Missing colon separator")
            }

            let value: RFC_5322.Header.Value
            do throws(RFC_5322.Header.Value.Error) {
                value = try RFC_5322.Header.Value.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .invalidValue(error)
            }

            return RFC_5322.Header(name: name, value: value)
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            Scan.append(output.description, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_5322.Header: Coder.Codable {}
