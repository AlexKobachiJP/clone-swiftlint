// Copyright © 2023 Alex Kovács. All rights reserved.

import Foundation
import PackagePlugin

extension Process {
    static func run(_ launchPath: String, arguments: [String]) throws {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: launchPath)
        process.arguments = arguments

        try process.run()
        process.waitUntilExit()

        let cleanExit = process.terminationReason == .exit && process.terminationStatus >= 0
        if !cleanExit {
            Diagnostics.error("\(process.terminationReason) (\(process.terminationStatus))")
        }
    }
}
