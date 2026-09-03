import Eliminator_Derivation

@Eliminator
enum Choice {
    case first(Int)
    case second(String)
}

let eliminate = Choice.Eliminator<Int>(first: { $0 })
