import Foundation
import PackagePlugin

#if os(Linux)
import Glibc
#else
import Darwin
#endif

extension Path {
    /// Scans the receiver, then all of its parents looking for a configuration file with the name ".swiftlint.yml".
    ///
    /// - returns: Path to the configuration file, or nil if one cannot be found.
    func firstConfigurationFileInParentDirectories() -> Path? {
        let defaultConfigurationFileName = ".swiftlint.yml"
        let proposedDirectory = sequence(
            first: self,
            next: { path in
                guard path.stem.count > 1 else {
                    // Check we're not at the root of this filesystem, as `removingLastComponent()`
                    // will continually return the root from itself.
                    return nil
                }

                return path.removingLastComponent()
            }
        ).first { path in
            let potentialConfigurationFile = path.appending(subpath: defaultConfigurationFileName)
            return potentialConfigurationFile.isAccessible()
        }
        return proposedDirectory?.appending(subpath: defaultConfigurationFileName)
    }

    /// Safe way to check if the file is accessible from within the current process sandbox.
    private func isAccessible() -> Bool {
        let result = string.withCString { pointer in
            access(pointer, R_OK)
        }

        return result == 0
    }
}

extension Path {
    /// Opens the receiver's file and looks for the first line containing the label `"xcode-plugin-arguments:"`. If found, returns the rest of the line after the label
    /// as an array of strings by splitting on `" "`.
    ///
    /// For example, if the file at the receiver's path is the following, the function returns `["--strict", "--no-cache"]`:
    /// ```yaml
    /// # xcode-plugin-arguments: --strict --no-cache
    ///
    /// included:
    ///   - Sources
    ///   - Tests
    /// ```
    func xcodePluginArguments() -> [String] {
        guard let contents = try? String(contentsOfFile: string) else {
            return []
        }

        var arguments: [String]?
        contents.enumerateLines { line, stop in
            let line = line as NSString
            let labelRange = line.range(of: "xcode-plugin-arguments:")
            let foundLabel = labelRange.location != NSNotFound
            if foundLabel {
                stop = true
                let argumentsRange = NSRange(location: labelRange.upperBound, length: line.length - labelRange.upperBound)
                arguments = line.substring(with: argumentsRange)
                    .split(separator: " ")
                    .map(String.init)
            }
        }

        return arguments ?? []
    }
}
