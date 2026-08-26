public import SwiftSyntax

public enum EliminatorDerivation {
    public static func expansion(
        of declaration: EnumDeclSyntax
    ) throws(Diagnostic) -> [DeclSyntax] {
        try EliminatorAnalysis(declaration: declaration).expansion
    }
}
