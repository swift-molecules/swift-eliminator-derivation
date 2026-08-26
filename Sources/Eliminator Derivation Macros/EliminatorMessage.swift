import SwiftDiagnostics

struct EliminatorMessage: DiagnosticMessage {
    let message: String
    let diagnosticID = MessageID(
        domain: "EliminatorDerivation",
        id: "unsupported-coproduct"
    )
    let severity = DiagnosticSeverity.error

    init(_ message: String) {
        self.message = message
    }
}
