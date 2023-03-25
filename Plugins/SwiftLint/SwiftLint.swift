// Copyright © 2023 Alex Kovács. All rights reserved.

import Foundation
import PackagePlugin

@main
struct SwiftLint: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) async throws {
        let (targetNames, remainingArguments) = getTargetsAndArgumentsNames(from: arguments)

        var arguments = [
            "lint",
            "--quiet",
            "--cache-path", "\(context.pluginWorkDirectory)",
        ]
        arguments += remainingArguments

        let swiftlint = try context.tool(named: "swiftlint").path.string

        for target in context.package.targets {
            guard let sourceTarget = target as? SourceModuleTarget, targetNames.contains(sourceTarget.name) else {
                continue
            }

            let paths = sourceTarget.sourceFiles(withSuffix: "swift").map(\.path).map(\.string)

            try Process.run(swiftlint, arguments: arguments + paths)

            // Run again if the last run included the `--fix` flag.
            if arguments.contains("--fix") {
                print("Completed correcting violations where possible, running again without `--fix` flag.")
                try Process.run(swiftlint, arguments: arguments.filter { $0 != "--fix" } + paths)
            }
        }
    }
}

extension SwiftLint {
    private func getTargetsAndArgumentsNames(from arguments: [String]) -> (targetNames: [String], remainingArguments: [String]) {
        let groups = arguments.groupedWithContext { ctx -> Either<String, String>? in
            if ctx.current == "--target" {
                return nil
            } else if ctx.previous == "--target" {
                return .left(ctx.current)
            } else {
                return .right(ctx.current)
            }
        }
        return (targetNames: groups.lefts, remainingArguments: groups.rights)
    }
}
