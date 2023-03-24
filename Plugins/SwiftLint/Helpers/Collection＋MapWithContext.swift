// Copyright © 2023 Alex Kovács. All rights reserved.

/// A sequence mapping context.
public struct SequenceMappingContext<Element> {

    /// The element at the index before the current. `nil` when `current` is the first element of the sequence.
    public var previous: Element?

    /// The element at the current index.
    public var current: Element

    /// The element at the index after the current one. `nil` when `current` is the last element of the sequence.
    public var next: Element?

    /// Returns `true` when the current element is the first of the sequence, `false` otherwise.
    public var isFirst: Bool {
        previous == nil
    }

    /// Returns `true` when the current element is the last of the sequence, `false` otherwise.
    public var isLast: Bool {
        next == nil
    }

    /// Creates a sequence mapping context
    public init(previous: Element? = nil, current: Element, next: Element? = nil) {
        self.previous = previous
        self.current = current
        self.next = next
    }
}

extension SequenceMappingContext: Equatable where Element: Equatable {}
extension SequenceMappingContext: Hashable where Element: Hashable {}
extension SequenceMappingContext: Codable where Element: Codable {}

extension Collection {

    /// Map function that provides the transform with a mapping context to simplify operations that require look-back or look forward.
    public func mapWithContext<T>(_ transform: (SequenceMappingContext<Self.Element>) throws -> T) rethrows -> [T] {
        var previous: Index?
        return try indices.map { current in
            let next = index(after: current)
            defer { previous = current }
            return try transform(
                SequenceMappingContext(
                    previous: previous.map { self[$0] },
                    current: self[current],
                    next: next < endIndex ? self[next] : nil
                )
            )
        }
    }
}
