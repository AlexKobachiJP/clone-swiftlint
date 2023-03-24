// Copyright © 2023 Alex Kovács. All rights reserved.

/// A enum with two cases.
public enum Either<A, B> {

    /// The left case.
    case left(A)

    /// The right case.
    case right(B)
}

extension Sequence {

    /// Groups the sequence into two, based on the result returned by the `choose` closure.
    /// - Parameter choose: Closure to choose for each element of the sequence wether it should go in the left or the right bucket. If you return `nil` from
    /// the closure, the element is dropped.
    /// - Returns: A tuple with each element of the sequence appearing either in the left array, the right array, or not at all. The sort order of the result arrays is stable.
    public func grouped<T>(by choose: (Element) throws -> Either<T, T>?) rethrows -> (lefts: [T], rights: [T]) {
        var lefts: [T] = []
        var rights: [T] = []
        try forEach {
            switch try choose($0) {
            case let .left(element):
                lefts.append(element)

            case let .right(element):
                rights.append(element)

            case _:
                break // Drop the element.
            }
        }
        return (lefts: lefts, rights: rights)
    }
}

extension Sequence where Self: Collection {

    /// Groups the sequence into two, based on the result returned by the `choose` closure.
    /// - Parameter choose: Closure to choose for each element of the sequence wether it should go in the left or the right bucket. If you return `nil` from
    /// the closure, the element is dropped. The closure is passed a ``SequenceMappingContext``.
    /// - Returns: A tuple with each element of the sequence appearing either in the left array, the right array, or not at all. The sort order of the result arrays is stable.
    public func groupedWithContext<T>(by choose: (SequenceMappingContext<Element>) throws -> Either<T, T>?) rethrows -> (lefts: [T], rights: [T]) {
        try mapWithContext(choose).grouped { $0 }
    }
}
