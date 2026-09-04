import Byte
import Testing

@testable import ASCII
import ASCII_Serializer
import Binary_Serializable
import RFC_5322
import RFC_5322_Coder

@Suite
struct `String Tests` {

    @Test
    func `Convert simple email to string`() throws {
        let email = try RFC_5322.Mailbox("user@example.com")
        let string = String(email)

        #expect(string == "user@example.com")
    }

    @Test
    func `Convert email with display name to string`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: "John Doe",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let string = String(email)

        #expect(string == "John Doe <john@example.com>")
    }

    @Test
    func `Convert email with quoted display name to string`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: "Doe, John",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let string = String(email)

        #expect(string == "\"Doe, John\" <john@example.com>")
    }

    @Test
    func `Display name with special characters gets quoted`() throws {
        let email = try RFC_5322.Mailbox(
            displayName: "John@Doe",
            localPart: .init("john"),
            domain: .init("example.com")
        )
        let string = String(email)

        #expect(string.hasPrefix("\""))
        #expect(string.contains("John@Doe"))
    }

    @Test
    func `Convert message to string`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Hello".utf8.map(Byte.init(bitPattern:))
        )

        let string = message.description

        #expect(string.contains("From: sender@example.com"))
        #expect(string.contains("To: recipient@example.com"))
        #expect(string.contains("Subject: Test"))
        #expect(string.contains("Hello"))
    }

    @Test
    func `String conversion matches byte conversion`() throws {
        let message = try RFC_5322.Message(
            from: try RFC_5322.Mailbox("sender@example.com"),
            to: [try RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: try RFC_5322.Message.ID("<test@example.com>"),
            body: "Test".utf8.map(Byte.init(bitPattern:))
        )

        let fromString = message.description
        let fromBytes = String(decoding: [UInt8](message), as: UTF8.self)

        #expect(fromString == fromBytes)
    }

    @Test
    func `Convert datetime to string`() throws {
        let dateTime = try RFC_5322.DateTime(
            year: 2024,
            month: 1,
            day: 15,
            hour: 12,
            minute: 30
        )

        let string = dateTime.description

        #expect(!string.isEmpty)
        #expect(string.contains(","))
        #expect(string.contains(":"))
    }

    @Test
    func `DateTime renders the RFC 5322 date form`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)

        #expect(dateTime.description == "Fri, 01 Jan 2021 00:00:00 +0000")
    }

    @Test
    func `Convert header to string`() throws {
        let header = try RFC_5322.Header(name: .subject, value: .init("Hello World"))
        let string = String(decoding: [UInt8](header), as: UTF8.self)

        #expect(string == "Subject: Hello World")
    }

    @Test
    func `Header string format`() throws {
        let header = try RFC_5322.Header(name: .init("X-Test"), value: .init("test value"))
        let string = String(decoding: [UInt8](header), as: UTF8.self)

        #expect(string == "X-Test: test value")
        #expect(string.contains(": "))
    }
}
