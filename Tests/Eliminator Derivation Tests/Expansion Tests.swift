import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

@testable import Eliminator_Derivation_Macros

private let eliminatorMacros: [String: MacroSpec] = [
    "Eliminator": MacroSpec(type: Eliminator_Derivation_Macros.Macro.self)
]

@Test
func `eliminator derivation diagnoses a non enum attachment`() {
    assertMacroExpansion(
        """
        @Eliminator
        struct Choice {}
        """,
        expandedSource: """
        struct Choice {}
        """,
        diagnostics: [
            DiagnosticSpec(
                message: "@Eliminator applies to an enum declaration only.",
                line: 1,
                column: 1
            )
        ],
        macroSpecs: eliminatorMacros,
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message))
        }
    )
}
