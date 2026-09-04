import Byte
import ASCII
import ASCII_Serializer
import Binary_Serializable
import RFC_5322
import RFC_5322_Coder
import Testing

@Suite
struct `DateTime Serialization Equivalence` {

    @Test
    func `ASCII verb output equals Binary witness output for a non-UTC offset`() throws {

        let dateTime = try RFC_5322.DateTime(
            year: 2024,
            month: 1,
            day: 1,
            hour: 9,
            minute: 5,
            second: 7,
            timezoneOffsetSeconds: -18000
        )

        let viaASCII: [Byte] = dateTime.serialized

        var viaBinary: [Byte] = []
        RFC_5322.DateTime.serialize(dateTime, into: &viaBinary)

        #expect(viaASCII == viaBinary)
    }
}
