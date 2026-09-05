public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import Byte
public import Parseable_ASCII
public import RFC_5322

extension RFC_5322.Header.Value: @retroactive ASCII.Parseable {}

extension RFC_5322.Header.Value: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        Scan.append(value.rawValue, into: &buffer)
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Scan.append(value.rawValue, into: &buffer)
    }
}
