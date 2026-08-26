import Testing

@Test
func eliminatorIsExhaustive() {
    func eliminate(_ choice: Choice) -> Int {
        choice.eliminate(
            message: { $0.count },
            count: { limit, value in limit + value },
            empty: { 0 }
        )
    }

    #expect(eliminate(.message("hello")) == 5)
    #expect(eliminate(.count(limit: 3, value: 2)) == 5)
    #expect(eliminate(.empty) == 0)
}
