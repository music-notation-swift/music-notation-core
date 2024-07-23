//
//  PauseMap.swift
//  MusicNotationCore
//
//  Created by Steven Woolgar on 07/18/2024.
//  Copyright © 2024 Steven Woolgar. All rights reserved.
//

/// Represents the collection tempos of a score.
public struct TempoMap: Equatable, RandomAccessCollection {
    // MARK: - Collection Conformance

    public typealias Index = Int
    public subscript(position: Index) -> Iterator.Element {
        TempoMap.tempoSlices(at: position, in: tempos)!
    }

    public typealias Iterator = TempoIterator
    public func makeIterator() -> Iterator {
        TempoIterator(self)
    }

    public func tempo(at index: Int) throws -> Tempo {
    }

    // MARK: - Main Properties

    public private(set) var tempos: [[TempoMap]] {
        tempoCollectionIndexes = [[TempoCollectionIndex]]()
        for tempoSet in tempos {
            var tempoSetIndexes: [TempoCollectionIndex] = []
            for (i, tempoCollection) in tempoSet.enumerated() {
                switch tempoCollection.tempoCount {
                case 1:
                    tempoSetIndexes.append(TempoCollectionIndex(tempoIndex: i))
                case let count:
                    for j in 0 ..< count {
                        tempoSetIndexes.append(TempoCollectionIndex(tempoIndex: i))
                    }
                }
            }
            tempoCollectionIndexes.append(tempoSetIndexes)
        }
    }

    private var tempoCollectionIndexes: [[TempoCollectionIndex]] = [[TempoCollectionIndex]]()
    public var tempoCount: [Int] { tempos.map { $0.reduce(0) { prev, tempoCollection in prev + tempoCollection.tempoCount } } }
    internal struct TempoCollectionIndex { let tempoIndex: Int }
}

extension TempoMap: Equatable {
	public static func == (lhs: TempoMap, rhs: TempoMap) -> Bool {
		guard lhs.value == rhs.value, lhs.text == rhs.text else { return false }
        return true
	}
}

extension TempoMap: CustomDebugStringConvertible {
	public var debugDescription: String {
		"\(value) \"(text)\")"
	}
}

// MARK: - Equality

public func == (lhs: TempoMap, rhs: TempoMap) -> Bool {
    if let left = lhs as? Note,
        let right = rhs as? Note,
        left == right {
        return true
    } else if let left = lhs as? Tuplet,
        let right = rhs as? Tuplet,
        left == right {
        return true
    } else {
        return false
    }
}

public func != (lhs: TempoMap, rhs: TempoMap) -> Bool {
    !(lhs == rhs)
}

// MARK: - Iterator

public struct TempoIterator: IteratorProtocol {
    var currentIndex: Int = 0
    let notes: [[TempoCollection]]
    let endIndex: Int

    init<T: ImmutableMeasure>(_ measure: T) {
        notes = measure.notes
        endIndex = measure.endIndex
    }

    public mutating func next() -> [MeasureSlice]? {
        defer { currentIndex += 1 }
        if currentIndex >= endIndex {
            return nil
        }
        return TempoMap.tempoSlices(at: currentIndex, in: notes)
    }
}

