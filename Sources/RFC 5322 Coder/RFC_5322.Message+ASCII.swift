public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import Byte
public import RFC_5322
import Byte_Standard_Library_Integration

extension RFC_5322.Message: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        var bytes: [Byte] = []
        Self.headers(of: value, into: &bytes)
        buffer.append(contentsOf: bytes.lazy.map(ASCII.Code.init(unchecked:)))
    }

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.reserveCapacity(500 + value.body.count)
        Self.headers(of: value, into: &buffer)
        buffer.append(contentsOf: value.body)
    }

    private static func headers<Buffer: RangeReplaceableCollection>(
        of value: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Self.line(named: "From", value.from.description, into: &buffer)
        Self.line(named: "To", Self.list(value.to), into: &buffer)

        if let cc = value.cc, !cc.isEmpty {
            Self.line(named: "Cc", Self.list(cc), into: &buffer)
        }

        Self.line(named: "Subject", value.subject, into: &buffer)
        Self.line(named: "Date", value.date.description, into: &buffer)
        Self.line(named: "Message-ID", value.messageId.description, into: &buffer)

        if let replyTo = value.replyTo {
            Self.line(named: "Reply-To", replyTo.description, into: &buffer)
        }

        Self.line(named: "MIME-Version", value.mimeVersion, into: &buffer)

        for header in value.additionalHeaders {
            Scan.append(header.description, into: &buffer)
            Scan.append("\r\n", into: &buffer)
        }

        Scan.append("\r\n", into: &buffer)
    }

    private static func line<Buffer: RangeReplaceableCollection>(
        named name: String,
        _ body: String,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        Scan.append(name, into: &buffer)
        Scan.append(": ", into: &buffer)
        Scan.append(body, into: &buffer)
        Scan.append("\r\n", into: &buffer)
    }

    private static func list(_ mailboxes: [RFC_5322.Mailbox]) -> String {
        mailboxes.map(\.description).joined(separator: ", ")
    }
}

extension RFC_5322.Message: @retroactive CustomStringConvertible {

    public var description: String {
        var bytes: [Byte] = []
        Self.serialize(self, into: &bytes)
        return String(decoding: bytes, as: UTF8.self)
    }
}
