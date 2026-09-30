import Byte
import RFC_5322
import RFC_5322_Coder
import Testing

@Suite
struct `Date-time coder zone digits` {
    @Test(arguments: ["+-100", "+01-5", "+0+00", "-+100"])
    func `a sign inside the zone digits is refused`(_ zone: String) {
        var input = ArraySlice(("Tue, 15 Nov 1994 08:12:31 " + zone).utf8.map(Byte.init(bitPattern:)))
        #expect(throws: RFC_5322.DateTime.Error.self) {
            try RFC_5322.DateTime.coder.parse(&input)
        }
    }

    @Test
    func `a negative zone keeps its sign`() throws {
        var input: ArraySlice<Byte> = "Tue, 15 Nov 1994 08:12:31 -0130"
        #expect(try RFC_5322.DateTime.coder.parse(&input).timezoneOffsetSeconds == -5400)
    }
}
