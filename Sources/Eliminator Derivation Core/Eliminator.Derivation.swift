public import SwiftSyntax
public import Coproduct_Derivation_Core
import SwiftSyntaxBuilder

extension Eliminator {
    public enum Derivation {
        public static func expansion(
            of declaration: EnumDeclSyntax
        ) -> [DeclSyntax] {
            expansion(Coproduct.Analysis(declaration))
        }

        public static func expansion(
            whole: TypeSyntax,
            access: DeclModifierSyntax?,
            cases: [EnumCaseElementSyntax]
        ) -> [DeclSyntax] {
            expansion(
                Coproduct.Analysis(
                    whole: whole,
                    access: access,
                    cases: cases,
                    genericParameter: nil
                )
            )
        }

        public static func expansion(_ analysis: Coproduct.Analysis) -> [DeclSyntax] {
            let access = analysis.access.map { "\($0.name.text) " } ?? ""
            let escaping = analysis.cases.map { coproductCase in
                handler(
                    name: coproductCase.name.text,
                    payload: coproductCase.payload.trimmedDescription,
                    isNullary: coproductCase.parameters.isEmpty,
                    escaping: true,
                    access: ""
                )
            }.joined(separator: ", ")
            let stored = analysis.cases.map { coproductCase in
                handler(
                    name: coproductCase.name.text,
                    payload: coproductCase.payload.trimmedDescription,
                    isNullary: coproductCase.parameters.isEmpty,
                    escaping: false,
                    access: access
                )
            }.joined(separator: "\n")
            let assignments = analysis.cases.map {
                "self.\($0.name.text) = \($0.name.text)"
            }.joined(separator: "\n")
            let branches = analysis.cases.map(branch).joined(separator: "\n")

            return ["""
                \(raw: access)struct Eliminator<Result: ~Copyable & ~Escapable> {
                    \(raw: stored)

                    \(raw: access)init(\(raw: escaping)) {
                        \(raw: assignments)
                    }

                    @_lifetime(borrow self, borrow value)
                    \(raw: access)func callAsFunction(_ value: borrowing \(analysis.whole)) -> Result {
                        switch value {
                        \(raw: branches)
                        }
                    }
                }
                """]
        }

        private static func handler(
            name: String,
            payload: String,
            isNullary: Bool,
            escaping: Bool,
            access: String
        ) -> String {
            let type = isNullary ? "() -> Result" : "(borrowing \(payload)) -> Result"
            if escaping {
                return "\(name): @escaping \(type)"
            }
            return "\(access)let \(name): \(type)"
        }

        private static func branch(_ coproductCase: Coproduct.Analysis.Case) -> String {
            let name = coproductCase.name.text
            switch coproductCase.parameters.count {
            case 0:
                return "case .\(name): return self.\(name)()"
            case 1:
                return "case let .\(name)(payload): return self.\(name)(payload)"
            default:
                let payloads = coproductCase.parameters.indices.map { "payload\($0)" }
                let tuple = payloads.enumerated().map { offset, value in
                    coproductCase.tupleLabel(at: offset).map {
                        "\($0.text): \(value)"
                    } ?? value
                }.joined(separator: ", ")
                return "case let .\(name)(\(payloads.joined(separator: ", "))): return self.\(name)((\(tuple)))"
            }
        }
    }
}
