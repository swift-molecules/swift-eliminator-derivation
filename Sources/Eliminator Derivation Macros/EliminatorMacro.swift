import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct EliminatorMacro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf _: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        []
    }
}

@main
struct EliminatorDerivationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [EliminatorMacro.self]
}
