import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct EliminatorDerivationPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [EliminatorMacro.self]
}
