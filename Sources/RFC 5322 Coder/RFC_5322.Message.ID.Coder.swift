import Pair
public import Byte
public import Coder
public import Cursor
public import RFC_5322
import Binary
import Parser
import Either
import Serializer

extension RFC_5322.Message.ID {

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Output = RFC_5322.Message.ID

        public typealias Failure = RFC_5322.Message.ID.Error

        public init() {}

        public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
            let start = input.checkpoint
            let parts: ([Byte], [Byte])
            do throws(Parts.Error) {
                parts = try Parts.Coder<Input, Buffer>().parse(&input)
            } catch {
                input.seek(to: start)
                throw .missingAtSign("\(error)")
            }
            do throws(Failure) {
                let bytes = [Byte](utf8: "<") + parts.0 + [Byte](utf8: "@") + parts.1 + [Byte](utf8: ">")
                return try RFC_5322.Message.ID(String(decoding: bytes, as: UTF8.self))
            } catch {
                input.seek(to: start)
                throw error
            }
        }

        public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
            RFC_5322.Message.ID.serialize(output, into: &buffer)
        }
    }

    public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
}

extension RFC_5322.Message.ID {

    public enum Parts {}
}

extension RFC_5322.Message.ID.Parts {

    public enum Error: Swift.Error, Equatable {
        case expectedOpenAngle
        case expectedAtSign
        case expectedCloseAngle
    }

    public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

        public typealias Failure = RFC_5322.Message.ID.Parts.Error

        public init() {}

        @Coder::Builder<Input, Buffer>
        public var body: some Coding<Input, ([Byte], [Byte]), Buffer, Failure> {
            Coder::Coder(Input.self, Buffer.self) {
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: "<"))
                Parser::Many(1..., Coder::First.Where { $0.bitPattern != 0x40 && $0.bitPattern != 0x3E }, rejected: { _ in true })
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: "@"))
                Parser::Many(1..., Coder::First.Where { $0.bitPattern != 0x3E }, rejected: { _ in true })
                Coder::ConsumingLiteral<Input, Buffer>([Byte](utf8: ">"))
            }
            .map(to: { ($0.first, $0.second) }, from: { .init($0.0, $0.1) })
            .mapFailure { (failure) -> Failure in
                switch failure {
                case .left(.left(.left(.left))): .expectedOpenAngle
                case .left(.left(.left(.right))): .expectedAtSign
                case .left(.left(.right)): .expectedAtSign
                case .left(.right): .expectedCloseAngle
                case .right: .expectedCloseAngle
                }
            }
        }
    }
}
