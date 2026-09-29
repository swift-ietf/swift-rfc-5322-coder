import Binary
import Byte
import RFC_5322
import RFC_5322_Coder
import Testing

@Suite
struct `RFC_5322.Message Rendering Tests` {

    @Test
    func `renders every required header`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200),
            subject: "Test Message",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Hello, World!")
        )

        #expect(
            message.description == """
                From: sender@example.com\r
                To: recipient@example.com\r
                Subject: Test Message\r
                Date: Fri, 01 Jan 2021 00:00:00 +0000\r
                Message-ID: <test@example.com>\r
                MIME-Version: 1.0\r
                \r
                Hello, World!
                """
        )
    }

    @Test
    func `renders display names`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox(
                displayName: "John Doe",
                localPart: .init("john"),
                domain: .init("example.com")
            ),
            to: [RFC_5322.Mailbox("Jane Smith <jane@example.com>")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Test")
        )

        let rendered = message.description

        #expect(rendered.contains("From: John Doe <john@example.com>\r\n"))
        #expect(rendered.contains("To: Jane Smith <jane@example.com>\r\n"))
    }

    @Test
    func `omits Bcc`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            bcc: [RFC_5322.Mailbox("bcc@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test BCC",
            messageId: RFC_5322.Message.ID("<bcc-test@example.com>"),
            body: [Byte](utf8: "Test")
        )

        let rendered = message.description

        #expect(!rendered.contains("Bcc:"))
        #expect(!rendered.contains("bcc@example.com"))
    }

    @Test
    func `renders Cc, Reply-To and additional headers`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("alice@example.com"), RFC_5322.Mailbox("bob@example.com")],
            cc: [RFC_5322.Mailbox("cc@example.com")],
            replyTo: RFC_5322.Mailbox("replyto@example.com"),
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Test"),
            additionalHeaders: [
                RFC_5322.Header(name: .xPriority, value: 1)
            ]
        )

        let rendered = message.description

        #expect(rendered.contains("To: alice@example.com, bob@example.com\r\n"))
        #expect(rendered.contains("Cc: cc@example.com\r\n"))
        #expect(rendered.contains("Reply-To: replyto@example.com\r\n"))
        #expect(rendered.contains("X-Priority: 1\r\n"))
    }

    @Test
    func `the description and the serialized bytes agree`() throws {
        let message = try RFC_5322.Message(
            from: RFC_5322.Mailbox("sender@example.com"),
            to: [RFC_5322.Mailbox("recipient@example.com")],
            date: .init(secondsSinceEpoch: 0),
            subject: "Test",
            messageId: RFC_5322.Message.ID("<test@example.com>"),
            body: [Byte](utf8: "Test")
        )

        #expect(String(message) == message.description)
        #expect([Byte](message) == [Byte](utf8: message.description))
    }

    @Test
    func `DateTime renders the RFC 5322 date form`() {
        let dateTime = RFC_5322.DateTime(secondsSinceEpoch: 1_609_459_200)

        #expect(dateTime.description == "Fri, 01 Jan 2021 00:00:00 +0000")
    }

    @Test
    func `Mailbox quotes a display name that contains specials`() throws {
        let mailbox = try RFC_5322.Mailbox(
            displayName: "Doe, John",
            localPart: .init("john"),
            domain: .init("example.com")
        )

        #expect(String(mailbox) == "\"Doe, John\" <john@example.com>")
    }
}
