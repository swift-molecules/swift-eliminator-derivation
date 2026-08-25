@attached(member, names: named(eliminate))
public macro Eliminator() = #externalMacro(
    module: "Eliminator_Derivation_Macros",
    type: "EliminatorMacro"
)
