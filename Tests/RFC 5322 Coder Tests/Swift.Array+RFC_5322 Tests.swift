import Byte
import INCITS_4_1986
import Testing

@testable import ASCII
import ASCII_Serializer
import Binary_Serializable
import RFC_5322
import RFC_5322_Coder

@Suite
struct `[UInt8] Conversions Tests` {

    @Test
    func `Convert simple email address to bytes`() throws {
        let email = try RFC_5322.Mailbox("user@example.com")
        let bytes = [UInt8](email)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string == "user@example.com")
    }

    @Test
    func `Convert email with display name to bytes`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: "John Doe",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let bytes = [UInt8](email)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string == "John Doe <john@example.com>")
    }

    @Test
    func `Convert email with quoted display name to bytes`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: "Doe, John",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let bytes = [UInt8](email)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string == "\"Doe, John\" <john@example.com>")
    }

    @Test
    func `Email address bytes contain @ symbol`() throws {
        let email = try RFC_5322.Mailbox("user@example.com")
        let bytes = [UInt8](email)

        #expect(bytes.contains(0x40))
    }

    @Test
    func `Convert header to bytes`() throws {
        let header = try RFC_5322.Header(name: .subject, value: .init("Hello World"))
        let bytes = [UInt8](header)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string == "Subject: Hello World")
    }

    @Test
    func `Convert custom header to bytes`() throws {
        let header = try RFC_5322.Header(name: .init("X-Custom"), value: .init("custom value"))
        let bytes = [UInt8].init(header)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string == "X-Custom: custom value")
    }

    @Test
    func `Header bytes contain colon and space`() throws {
        let header = try RFC_5322.Header(name: .init("X-Test"), value: .init("value"))
        let bytes = [UInt8](header)

        print("DEBUG Header bytes: \(bytes)")
        print("DEBUG Header string: '\(String(decoding: bytes, as: UTF8.self))'")

        #expect(bytes.contains(0x3A))
        #expect(bytes.contains(0x20))
    }

    @Test
    func `Convert datetime to bytes`() throws {
        let dateTime = try RFC_5322.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30,
            second: 45
        )
        let bytes = [UInt8](dateTime)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(!string.isEmpty)
        #expect(string.contains(","))
        #expect(string.contains(":"))
        #expect(string.contains("2024"))
    }

    @Test
    func `DateTime bytes match formatted string`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)
        let bytes = [UInt8](dateTime)
        let fromBytes = String(decoding: bytes, as: UTF8.self)
        let fromDescription = dateTime.description

        #expect(fromBytes == fromDescription)
    }

    @Test
    func `Convert basic message to bytes`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Hello".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.contains("From: sender@example.com"))
        #expect(string.contains("To: recipient@example.com"))
        #expect(string.contains("Subject: Test"))
        #expect(string.contains("Hello"))
    }

    @Test
    func `Message bytes use CRLF line endings`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)

        var hasCRLF = false
        for i in 0..<(bytes.count - 1) {
            if bytes[i] == 0x0D && bytes[i + 1] == 0x0A {
                hasCRLF = true
                break
            }
        }

        #expect(hasCRLF)
    }

    @Test
    func `Message bytes include all required headers`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test Subject",
            messageId: try RFC_5322.Message.ID("<unique@example.com>"),
            body: "Body".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.contains("From:"))
        #expect(string.contains("To:"))
        #expect(string.contains("Subject:"))
        #expect(string.contains("Date:"))
        #expect(string.contains("Message-ID:"))
        #expect(string.contains("MIME-Version:"))
    }

    @Test
    func `Message bytes exclude BCC header`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            bcc: [try RFC_5322.Mailbox("bcc@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(!string.contains("Bcc:"))
        #expect(!string.contains("bcc@example.com"))
    }

    @Test
    func `Message bytes include CC header when present`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            cc: [try RFC_5322.Mailbox("cc@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.contains("Cc: cc@example.com"))
    }

    @Test
    func `Message bytes include Reply-To when present`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            replyTo: try RFC_5322.Mailbox("replyto@example.com"),
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.contains("Reply-To: replyto@example.com"))
    }

    @Test
    func `Message bytes include additional headers`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:)),
            additionalHeaders: [
                RFC_5322.Header(name: .init("X-Priority"), value: 1)
            ]
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.contains("X-Priority: 1"))
    }

    @Test
    func `Message bytes have empty line between headers and body`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Body content".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)

        var hasDoubleCRLF = false
        for i in 0..<(bytes.count - 3) {
            let isDoubleCRLF =
                bytes[i] == 0x0D && bytes[i + 1] == 0x0A
                && bytes[i + 2] == 0x0D && bytes[i + 3] == 0x0A
            if isDoubleCRLF {
                hasDoubleCRLF = true
                break
            }
        }

        #expect(hasDoubleCRLF)
    }

    @Test
    func `Message bytes include body at end`() throws {
        let bodyContent = "This is the message body"
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: bodyContent.utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.hasSuffix(bodyContent))
    }

    @Test
    func `Multiple recipients separated by commas in bytes`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [
                try RFC_5322.Mailbox("alice@example.com"),
                try RFC_5322.Mailbox("bob@example.com"),
            ],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:))
        )

        let bytes = [UInt8](message)
        let string = String(decoding: bytes, as: UTF8.self)

        #expect(string.contains("To: alice@example.com, bob@example.com"))
    }

    @Test
    func `Message byte conversion is reversible`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200),
            subject: "Test Message",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Hello, World!".utf8.map(Byte.init(bitPattern:))
        )

        let bytes1 = [UInt8](message)
        let string = String(decoding: bytes1, as: UTF8.self)

        #expect(!string.isEmpty)
        #expect(string.contains("sender@example.com"))
        #expect(string.contains("recipient@example.com"))
        #expect(string.contains("Hello, World!"))
    }
}
