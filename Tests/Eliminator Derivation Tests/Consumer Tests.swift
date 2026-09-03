import Eliminator_Derivation
import Testing

@Eliminator
private enum Selection {
    case none
    case name(String)
    case pair(Int, String)
}

@Eliminator
private enum LabeledSelection {
    case labeled(code: Int, note: String)
}

private struct LinearToken: ~Copyable {
    let value: Int
}

@Eliminator
private enum LinearSelection: ~Copyable {
    case pair(LinearToken, LinearToken)
}

private struct LinearOutcome: ~Copyable {}
private struct ScopedOutcome: ~Escapable {}

private func consume(_: consuming LinearOutcome) {}
private func consume(_: consuming ScopedOutcome) {}

@Test
func `derived product exhaustively eliminates every case shape`() {
    let eliminator = Selection.Eliminator<String>(
        none: { "none" },
        name: { $0 },
        pair: { "\($0.0):\($0.1)" }
    )

    #expect(eliminator(.pair(42, "Blob")) == "42:Blob")
}

@Test
func `derived product may eliminate into a noncopyable carrier`() {
    let eliminator = Selection.Eliminator<LinearOutcome>(
        none: { LinearOutcome() },
        name: { _ in LinearOutcome() },
        pair: { _ in LinearOutcome() }
    )
    let selection = Selection.pair(42, "Blob")
    let outcome = eliminator(selection)

    consume(outcome)
}

@Test
func `derived product may eliminate into a nonescapable carrier`() {
    let eliminator = Selection.Eliminator<ScopedOutcome>(
        none: { ScopedOutcome() },
        name: { _ in ScopedOutcome() },
        pair: { _ in ScopedOutcome() }
    )
    let selection = Selection.pair(42, "Blob")
    let outcome = eliminator(selection)

    consume(outcome)
}

@Test
func `derived eliminator preserves labeled payload structure`() {
    let eliminator = LabeledSelection.Eliminator<String>(
        labeled: { "\($0.code):\($0.note)" }
    )

    #expect(eliminator(.labeled(code: 42, note: "Blob")) == "42:Blob")
}

@Test
func `derived eliminator borrows a noncopyable tuple payload`() {
    let eliminator = LinearSelection.Eliminator<Int>(
        pair: { _ in 42 }
    )
    let selection = LinearSelection.pair(
        LinearToken(value: 20),
        LinearToken(value: 22)
    )

    #expect(eliminator(selection) == 42)
}
