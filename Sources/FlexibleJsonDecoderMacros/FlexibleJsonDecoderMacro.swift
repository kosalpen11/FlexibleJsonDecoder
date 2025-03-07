import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

@main
struct FlexibleJsonDecoderPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [FlexibleJsonDecoderMacros.self]
}

/// Macro to automatically implement `init(from:)` with default values
public struct FlexibleJsonDecoderMacros: MemberMacro {
    
    /// ✅ Required method for Swift 6.0+ (new signature)
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return try expansion(of: node, providingMembersOf: declaration, in: context)
    }
    
    /// ✅ Required method for backwards compatibility
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        
        guard let structDecl = declaration.as(StructDeclSyntax.self) else {
            fatalError()
        }
        
        // Extract properties from struct
        let properties = structDecl.memberBlock.members.compactMap { member -> (String, String)? in
            guard let varDecl = member.decl.as(VariableDeclSyntax.self),
                  let binding = varDecl.bindings.first,
                  let identifier = binding.pattern.as(IdentifierPatternSyntax.self),
                  let type = binding.typeAnnotation?.type else {
                return nil
            }
            return (identifier.identifier.text, type.description)
        }
        
        // ✅ Generate `init(from decoder:)` method
        let decodingStatements = properties.map { (name, type) in
                    """
                    self.\(name) = try container.decodeIfPresent(\(type).self, forKey: .\(name)) ?? \(type).defaultValue()
                    """
        }.joined(separator: "\n")
        
        let generatedInit = """
                init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    \(decodingStatements)
                }
                """

        return [DeclSyntax(stringLiteral: generatedInit)]
    }
}

