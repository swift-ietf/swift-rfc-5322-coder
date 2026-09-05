import Byte
import Byte_Standard_Library_Integration
import Coder
import Coder_Standard_Library_Integration
import Cursor_Standard_Library_Integration
import Parser
import RFC_5322
import RFC_5322_Coder
import Testing

@Suite
struct `RFC_5322.Mailbox Coder Tests` {

    @Test
    func `parses a bare address and stops at the list separator`() throws {
        var input: ArraySlice<Byte> = "alice@example.com, bob@example.com"
        let mailbox = try RFC_5322.Mailbox.coder.parse(&input)
        #expect(mailbox.address == "alice@example.com")
        #expect(mailbox.displayName == nil)
        #expect(input == ", bob@example.com")
    }

    @Test
    func `parses a quoted display name containing a comma`() throws {
        var input: ArraySlice<Byte> = "\"Doe, John\" <john@example.com>\r\n"
        let mailbox = try RFC_5322.Mailbox.coder.parse(&input)
        #expect(mailbox.displayName == "Doe, John")
        #expect(mailbox.address == "john@example.com")
        #expect(input == "\r\n")
    }

    @Test
    func `rejects an address without an at sign and restores the cursor`() {
        var input: ArraySlice<Byte> = "john.example.com"
        #expect(throws: RFC_5322.Mailbox.Error.missingAtSign) {
            try RFC_5322.Mailbox.coder.parse(&input)
        }
        #expect(input == "john.example.com")
    }

    @Test
    func `a local part stops at the at sign`() throws {
        var input: ArraySlice<Byte> = "john.doe@example.com"
        let localPart = try RFC_5322.Mailbox.LocalPart.coder.parse(&input)
        #expect(localPart.description == "john.doe")
        #expect(input == "@example.com")
    }

    @Test
    func `a quoted local part keeps its quotes`() throws {
        var input: ArraySlice<Byte> = "\"john doe\"@example.com"
        let localPart = try RFC_5322.Mailbox.LocalPart.coder.parse(&input)
        #expect(localPart.description == "\"john doe\"")
        #expect(input == "@example.com")
    }

    @Test
    func `round-trips through the canonical form`() throws {
        let mailbox = try RFC_5322.Mailbox("Doe, John <john@example.com>")
        #expect(try mailbox.encoded() == "\"Doe, John\" <john@example.com>")
        #expect(try mailbox.localPart.encoded() == "john")
    }
}
