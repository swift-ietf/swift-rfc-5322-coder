public import ASCII
public import Binary
public import Byte
public import RFC_5322
import Byte
import Cursor

extension RFC_5322.Message.ID: @retroactive ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(RFC_5322.Message.ID.Error)
    where Bytes.Element == Byte {
        var input = ArraySlice<Byte>(bytes)
        let value = try Self.coder.parse(&input)
        if let trailing = input.first {
            let text = String(decoding: bytes, as: UTF8.self)
            guard trailing.bitPattern < 0x80 else {
                throw RFC_5322.Message.ID.Error.nonASCII(text)
            }
            throw RFC_5322.Message.ID.Error.invalidCharacter(
                text,
                code: ASCII.Code(unchecked: trailing),
                reason: "Trailing bytes after the closing angle bracket"
            )
        }
        self = value
    }
}

extension RFC_5322.Message.ID: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        Scan.append(value.description, into: &buffer)
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Scan.append(value.description, into: &buffer)
    }
}
