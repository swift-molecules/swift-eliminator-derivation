import SwiftSyntax
import SwiftSyntaxBuilder

struct EliminatorAnalysis {
    let access: DeclModifierListSyntax
    let cases: [EliminatorCase]

    init(
        declaration: EnumDeclSyntax
    ) throws(EliminatorDerivation.Diagnostic) {
        guard declaration.genericParameterClause == nil,
              declaration.genericWhereClause == nil
        else {
            throw .init(
                message: "Eliminator cannot derive a generic coproduct.",
                node: Syntax(declaration)
            )
        }
        if let modifier = declaration.modifiers.first(where: Self.isUnsupported) {
            throw .init(
                message: "Eliminator cannot preserve coproduct isolation or non-access modifiers.",
                node: Syntax(modifier)
            )
        }
        if let attribute = declaration.attributes.first(where: Self.isUnsupported) {
            throw .init(
                message: "Eliminator cannot preserve unrelated coproduct attributes or isolation.",
                node: Syntax(attribute)
            )
        }
        if let inheritedType = declaration.inheritanceClause?.inheritedTypes.first(
            where: { $0.type.as(SuppressedTypeSyntax.self) != nil }
        ) {
            throw .init(
                message: "Eliminator cannot claim suppressed copyability or escapability.",
                node: Syntax(inheritedType)
            )
        }
        access = Self.access(of: declaration)

        var cases: [EliminatorCase] = []
        for member in declaration.memberBlock.members {
            guard let caseDeclaration = member.decl.as(EnumCaseDeclSyntax.self) else {
                continue
            }
            guard caseDeclaration.attributes.isEmpty else {
                throw .init(
                    message: "Eliminator cannot preserve attributes on individual cases.",
                    node: Syntax(caseDeclaration.attributes)
                )
            }
            for element in caseDeclaration.elements {
                if let parameter = element.parameterClause?.parameters.first(where: {
                    !$0.modifiers.isEmpty
                }) {
                    throw .init(
                        message: "Eliminator cannot preserve ownership-qualified case values.",
                        node: Syntax(parameter)
                    )
                }
                cases.append(.init(element))
            }
        }
        let names = cases.map(\.name.text)
        guard Set(names).count == names.count else {
            throw .init(
                message: "Eliminator cannot derive overloaded cases because their handler names collide.",
                node: Syntax(declaration)
            )
        }
        self.cases = cases
    }

    private static func isUnsupported(
        _ element: AttributeListSyntax.Element
    ) -> Bool {
        guard case .attribute(let attribute) = element,
              let name = attribute.attributeName.as(IdentifierTypeSyntax.self)?.name.text
        else {
            return true
        }
        return name != "Eliminator" && name != "Prisms"
    }

    private static func isUnsupported(_ modifier: DeclModifierSyntax) -> Bool {
        modifier.name.tokenKind != .keyword(.public)
            && modifier.name.tokenKind != .keyword(.package)
            && modifier.name.tokenKind != .keyword(.internal)
            && modifier.name.tokenKind != .keyword(.private)
            && modifier.name.tokenKind != .keyword(.fileprivate)
            && modifier.name.tokenKind != .keyword(.indirect)
    }

    var expansion: [DeclSyntax] {
        let parameters = cases.map(\.handlerParameter).joined(separator: ", ")
        let branches = cases.map(\.branch).joined(separator: " ")
        return ["""
            \(access)func eliminate<Result>(\(raw: parameters)) -> Result {
                switch self { \(raw: branches) }
            }
            """]
    }

    private static func access(
        of declaration: EnumDeclSyntax
    ) -> DeclModifierListSyntax {
        if declaration.modifiers.contains(where: {
            $0.name.tokenKind == .keyword(.public)
        }) {
            return [.init(name: .keyword(.public, trailingTrivia: .space))]
        }
        if declaration.modifiers.contains(where: {
            $0.name.tokenKind == .keyword(.package)
        }) {
            return [.init(name: .keyword(.package, trailingTrivia: .space))]
        }
        if declaration.modifiers.contains(where: {
            $0.name.tokenKind == .keyword(.fileprivate)
        }) {
            return [.init(name: .keyword(.fileprivate, trailingTrivia: .space))]
        }
        if declaration.modifiers.contains(where: {
            $0.name.tokenKind == .keyword(.private)
        }) {
            return [.init(name: .keyword(.private, trailingTrivia: .space))]
        }
        return []
    }
}
