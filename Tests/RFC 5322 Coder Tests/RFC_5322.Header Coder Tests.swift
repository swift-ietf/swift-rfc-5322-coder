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
struct `RFC_5322.Header Coder Tests` {

    @Test
    func `parses a header line and stops at the line break`() throws {
        var input: ArraySlice<Byte> = "Subject: Hello World\r\nX-Next: 1"
        let header = try RFC_5322.Header.coder.parse(&input)
        #expect(header.name == .subject)
        #expect(header.value == "Hello World")
        #expect(input == "\r\nX-Next: 1")
    }

    @Test
    func `unfolds a folded field body`() throws {
        var input: ArraySlice<Byte> = "Subject: Hello\r\n World\r\n"
        let header = try RFC_5322.Header.coder.parse(&input)
        #expect(header.value == "Hello World")
        #expect(input == "\r\n")
    }

    @Test
    func `rejects a line without a colon and restores the cursor`() {
        var input: ArraySlice<Byte> = "Subject Hello\r\n"
        #expect(throws: RFC_5322.Header.Error.self) {
            try RFC_5322.Header.coder.parse(&input)
        }
        #expect(input == "Subject Hello\r\n")
    }

    @Test
    func `a header name stops before the colon`() throws {
        var input: ArraySlice<Byte> = "Content-Type: text/plain"
        let name = try RFC_5322.Header.Name.coder.parse(&input)
        #expect(name.rawValue == "Content-Type")
        #expect(input == ": text/plain")
    }

    @Test
    func `round-trips through the canonical form`() throws {
        let header = try RFC_5322.Header(name: .init("X-Test"), value: .init("test value"))
        #expect(try header.encoded() == "X-Test: test value")
        #expect(try RFC_5322.Header.Name("X-Test").encoded() == "X-Test")
        #expect(try RFC_5322.Header.Value("test value").encoded() == "test value")
    }
}
