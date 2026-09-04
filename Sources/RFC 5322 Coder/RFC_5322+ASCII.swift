public import ASCII
public import ASCII_Serializer
public import Binary_Serializable
public import Parseable_ASCII
public import RFC_5322

extension RFC_5322.DateTime: @retroactive ASCII.Parseable {}

extension RFC_5322.DateTime: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}

extension RFC_5322.Header: @retroactive ASCII.Parseable {}

extension RFC_5322.Header: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}

extension RFC_5322.Header.Name: @retroactive ASCII.Parseable {}

extension RFC_5322.Header.Name: @retroactive ASCII.Serializable, @retroactive Binary.Serializable
{}

extension RFC_5322.Header.Value: @retroactive ASCII.Parseable {}

extension RFC_5322.Header.Value: @retroactive ASCII.Serializable, @retroactive Binary.Serializable
{}

extension RFC_5322.Mailbox: @retroactive ASCII.Parseable {}

extension RFC_5322.Mailbox: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}

extension RFC_5322.Mailbox.LocalPart: @retroactive ASCII.Parseable {}

extension RFC_5322.Mailbox.LocalPart: @retroactive ASCII.Serializable,
    @retroactive Binary.Serializable
{}

extension RFC_5322.Message: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}

extension RFC_5322.Message.ID: @retroactive ASCII.Parseable {}

extension RFC_5322.Message.ID: @retroactive ASCII.Serializable, @retroactive Binary.Serializable {}
