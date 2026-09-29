public import ASCII
public import Binary
public import Byte
public import RFC_5322

extension RFC_5322.Header.Name: @retroactive ASCII.Parseable {}

extension RFC_5322.Header.Name: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {

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
