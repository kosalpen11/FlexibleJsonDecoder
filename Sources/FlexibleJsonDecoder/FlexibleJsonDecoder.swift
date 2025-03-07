// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(member, names: named(init(from:)))
public macro FlexibleJsonDecoder() = #externalMacro(
    module: "FlexibleJsonDecoderMacros",
    type: "FlexibleJsonDecoderMacros"
)
