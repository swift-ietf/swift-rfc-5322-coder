public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import Byte
public import Parseable_ASCII
public import RFC_5322
import Byte_Standard_Library_Integration
import Cursor_Standard_Library_Integration

extension RFC_5322.DateTime: @retroactive ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(RFC_5322.DateTime.Error)
    where Bytes.Element == Byte {
        var input = ArraySlice<Byte>(bytes)
        let value = try Self.Coder<ArraySlice<Byte>, [Byte]>().parse(&input)
        RFC_5322.Whitespace.Coder<ArraySlice<Byte>, [Byte]>().parse(&input)
        guard input.isEmpty else {
            throw RFC_5322.DateTime.Error.invalidFormat(String(decoding: input, as: UTF8.self))
        }
        self = value
    }
}

extension RFC_5322.DateTime: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {

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
