import SwiftSyntax

struct EliminatorCase {
    let name: TokenSyntax
    let parameters: EnumCaseParameterListSyntax

    init(_ element: EnumCaseElementSyntax) {
        name = element.name
        parameters = element.parameterClause?.parameters ?? []
    }

    var handlerParameter: String {
        let inputs = parameters.map(\.type.trimmedDescription).joined(separator: ", ")
        return "\(name.trimmedDescription): (\(inputs)) -> Result"
    }

    var branch: String {
        guard !parameters.isEmpty else {
            return "case .\(name.trimmedDescription): return \(name.trimmedDescription)()"
        }
        let patterns = parameters.enumerated().map { index, parameter in
            guard let label = label(of: parameter) else {
                return "let value\(index)"
            }
            return "\(label.trimmedDescription): let value\(index)"
        }.joined(separator: ", ")
        let values = parameters.enumerated().map { "value\($0.offset)" }.joined(separator: ", ")
        return "case .\(name.trimmedDescription)(\(patterns)): return \(name.trimmedDescription)(\(values))"
    }

    private func label(
        of parameter: EnumCaseParameterSyntax
    ) -> TokenSyntax? {
        guard let name = parameter.firstName, name.text != "_" else {
            return nil
        }
        return name
    }
}
