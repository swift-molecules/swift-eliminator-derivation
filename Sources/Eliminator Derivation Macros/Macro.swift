import SwiftSyntax
import SwiftSyntaxMacros
import Eliminator_Derivation_Core

public struct Macro: MemberMacro {
    public static func expansion(
        of _: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let declaration = declaration.as(EnumDeclSyntax.self) else {
            throw MacroExpansionErrorMessage("@Eliminator applies to an enum declaration only.")
        }
        return Eliminator.Derivation.expansion(of: declaration)
    }
}
