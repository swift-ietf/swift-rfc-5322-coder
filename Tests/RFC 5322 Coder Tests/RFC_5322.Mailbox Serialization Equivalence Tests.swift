import Byte
import ASCII
import ASCII_Serializer
import Binary_Serializable
import RFC_5322
import RFC_5322_Coder
import Testing

@Suite
struct `Mailbox Serialization Equivalence` {

    @Test
    func `ASCII verb output equals Binary witness output for the display-name quoting path`() throws
    {

        let email = try RFC_5322.Mailbox("\"Doe, John\" <jd@example.com>")

        let viaASCII: [Byte] = email.serialized

        var viaBinary: [Byte] = []
        RFC_5322.Mailbox.serialize(email, into: &viaBinary)

        #expect(viaASCII == viaBinary)
    }
}
