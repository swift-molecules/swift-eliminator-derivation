import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros
import Eliminator_Derivation_Core

public struct EliminatorMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo _: [TypeSyntax],
        in _: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let enumDeclaration = declaration.as(EnumDeclSyntax.self) else {
            throw DiagnosticsError(
                diagnostics: [
                    .init(
                        node: node,
                        message: EliminatorMessage(
                            "Eliminator attaches to an enum declaration only."
                        )
                    )
                ]
            )
        }
        do throws(EliminatorDerivation.Diagnostic) {
            return try EliminatorDerivation.expansion(of: enumDeclaration)
        } catch {
            throw DiagnosticsError(
                diagnostics: [
                    .init(
                        node: error.node,
                        message: EliminatorMessage(error.message)
                    )
                ]
            )
        }
    }
}
