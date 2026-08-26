import Eliminator_Derivation

@Eliminator
enum Choice {
    case message(String)
    case count(limit: Int, value: Int)
    case empty
}
