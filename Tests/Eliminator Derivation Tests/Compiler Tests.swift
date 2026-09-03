import Foundation
import Testing

@Suite
private struct `Compiler Tests` {
    @Test
    func `eliminator construction requires every case`() throws {
        let diagnostic = try typecheckFailure(
            named: "Incomplete Eliminator.swift"
        )

        #expect(diagnostic.contains("missing argument for parameter 'second' in call"))
    }

    private func typecheckFailure(named name: String) throws -> String {
        var products = Bundle.module.bundleURL
        while !FileManager.default.fileExists(
            atPath: products.appendingPathComponent("Eliminator_Derivation.swiftmodule").path
        ) {
            let parent = products.deletingLastPathComponent()
            products = try #require(parent != products ? parent : nil)
        }
        let fixture = Bundle.module.resourceURL!
            .appendingPathComponent("Fixtures")
            .appendingPathComponent(name)
        let process = Process()
        let standardError = Pipe()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        process.arguments = [
            "swiftc",
            "-typecheck",
            "-swift-version", "6",
            "-enable-experimental-feature", "Lifetimes",
            "-module-name", "Proof",
            "-I", products.path,
            "-F", products.appendingPathComponent("PackageFrameworks").path,
            "-Xfrontend", "-load-plugin-executable",
            "-Xfrontend",
            products.appendingPathComponent(
                "Eliminator Derivation Macros#Eliminator_Derivation_Macros"
            ).path,
            fixture.path,
        ]
        process.standardError = standardError
        try process.run()
        process.waitUntilExit()
        let diagnostic = String(
            decoding: standardError.fileHandleForReading.readDataToEndOfFile(),
            as: UTF8.self
        )

        #expect(process.terminationStatus != 0, "Fixture unexpectedly typechecked")
        #expect(!diagnostic.contains("no such module"))
        return diagnostic
    }
}
