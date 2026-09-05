import ASCII
import ASCII_Serializer
import Binary_Serializable
import Byte
import Byte_Standard_Library_Integration
import RFC_5322
import RFC_5322_Coder
import Testing

@Suite
struct `Serialization Equivalence` {

    @Test
    func `DateTime serializes to the RFC 5322 date form through both verbs`() throws {
        let date = try RFC_5322.DateTime(
            year: 2024, month: 1, day: 1, hour: 9, minute: 5, second: 7, timezoneOffsetSeconds: -18000
        )
        var ascii: [ASCII.Code] = []
        RFC_5322.DateTime.serialize(date, into: &ascii)

        #expect(ascii.map(\.byte) == [Byte](utf8: "Mon, 01 Jan 2024 09:05:07 -0500"))
        #expect([Byte](date) == [Byte](utf8: "Mon, 01 Jan 2024 09:05:07 -0500"))
    }

    @Test
    func `Mailbox serializes to its angle-addr form through both verbs`() throws {
        let quoted = try RFC_5322.Mailbox("\"Doe, John\" <jd@example.com>")
        var ascii: [ASCII.Code] = []
        RFC_5322.Mailbox.serialize(quoted, into: &ascii)

        #expect(ascii.map(\.byte) == [Byte](utf8: "\"Doe, John\" <jd@example.com>"))
        #expect([Byte](quoted) == [Byte](utf8: "\"Doe, John\" <jd@example.com>"))

        let bare = try RFC_5322.Mailbox("jd@example.com")
        #expect([Byte](bare) == [Byte](utf8: "jd@example.com"))

        let localPart = try RFC_5322.Mailbox.LocalPart("jd")
        #expect([Byte](localPart) == [Byte](utf8: "jd"))
    }

    @Test
    func `Header serializes to name, colon, space, value through both verbs`() throws {
        let header = try RFC_5322.Header(name: .subject, value: .init("Hello"))
        var ascii: [ASCII.Code] = []
        RFC_5322.Header.serialize(header, into: &ascii)

        #expect(ascii.map(\.byte) == [Byte](utf8: "Subject: Hello"))
        #expect([Byte](header) == [Byte](utf8: "Subject: Hello"))
        #expect([Byte](try RFC_5322.Header.Name("X-Test")) == [Byte](utf8: "X-Test"))
        #expect([Byte](try RFC_5322.Header.Value("test value")) == [Byte](utf8: "test value"))
    }

    @Test
    func `Message ID serializes with its angle brackets through both verbs`() throws {
        let id = try RFC_5322.Message.ID("<abc@example.com>")
        var ascii: [ASCII.Code] = []
        RFC_5322.Message.ID.serialize(id, into: &ascii)

        #expect(ascii.map(\.byte) == [Byte](utf8: "<abc@example.com>"))
        #expect([Byte](id) == [Byte](utf8: "<abc@example.com>"))
    }

    @Test
    func `Message serializes its header block as ASCII and the whole document as bytes`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Test")
        )
        let headers = """
            From: sender@example.com\r
            To: recipient@example.com\r
            Subject: Test\r
            Date: Thu, 01 Jan 1970 00:00:00 +0000\r
            Message-ID: <test@example.com>\r
            MIME-Version: 1.0\r
            \r

            """
        var ascii: [ASCII.Code] = []
        RFC_5322.Message.serialize(message, into: &ascii)

        #expect(ascii.map(\.byte) == [Byte](utf8: headers))
        #expect([Byte](message) == [Byte](utf8: headers + "Test"))
    }
}
