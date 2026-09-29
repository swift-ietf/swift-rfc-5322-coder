import Serializer
import Byte
import Coder
import Cursor
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
        #expect(try type(of: header).coder.serialize(header) == [Byte](utf8: "X-Test: test value"))
        #expect(try type(of: RFC_5322.Header.Name("X-Test")).coder.serialize(RFC_5322.Header.Name("X-Test")) == [Byte](utf8: "X-Test"))
        #expect(try type(of: RFC_5322.Header.Value("test value")).coder.serialize(RFC_5322.Header.Value("test value")) == [Byte](utf8: "test value"))
    }
}
