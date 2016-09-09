# Tuplet Design

## Groupings
Most of then you see a grouping of 3, 5, 6, 7, or 9. However, You may also see a grouping of 2, 4, or 8 if you are a time signature where the top number is an odd number. Also, most places that go over tuplets list the following groupings:
- Duplet (2)
- Triplet (3)
- Quadruplet (4)
- Quintuplet (5)
- Sextuplet (6)
- Septuplet (7)
- Octuplet (8)
- Nontuplet (9)

But they all end with etc. Therefore, I don't think we should validate the number. It seems that it can really be any arbitrary number.

## Definition
A complete tuplet definition requires knowing how many of what duration fits into the space of how many of a certain duration. This is how you define the ratio.
You can see a simple dialog box that shows this very clearly [here](https://usermanuals.finalemusic.com/Finale2014Mac/Content/Finale/TPDLG.htm).

Usually the two note durations would be the same, but you can do the calculation with any duration. For instance, you would normally define a standard eighth note triplet in 4/4 as "3 eighth notes in the space of 2 eighth notes". However, you could also define that as "3 eighth notes in the space of 1 quarter note". The ratio here would be 3:2.

## Standard Ratios
There are certain ratios that are standard, like a triplet would usually have a ratio of 3:2. However, there are also non-standard ratios where you can use whatever you'd like, such as 8:5. It would be good to have the standard ratios defined so that, for instance, a user can create a triplet and not have to define the full ratio.

There should only be a need to list the standard ratios for 2-9. In this case, we can just list them in `Tuplet` struct. This way, if the second number is not specific in the initializer and the first number is one of these, we can fill in the second number according to th static list of default ratios.

**Open**: Can we have one standard ratio per number? Seems like the standard may be based on the time signature. If not, we can use the following standard ratios.

Right now the assumption is that these are the standard ratios:

    2: 3
    3: 2
    4: 3
    5: 4
    6: 4
    7: 4
    8: 6
    9: 8

## Compound Tuplets
You can have a tuplet that is made up of another tuplet, which is made up of another tuplet, and so on. 

In order to support this behavior, the `Tuplet` will store an array of type `NoteCollection` so that it can have a `Note` or `Tuplet` as a value in the array. Also, the `NoteCollection` will have to have a property or set of properties to communicate the duration and number of that duration for each `NoteCollection`. 
    
i.e. A 3:2 Eighth note tuplet will have a number of 2 and duration of `.eighth`. A single eighth note, would have a number of 1 and duration of `.eighth`

## Validation
A tuplet needs to always be full. This means if it is a 3:2 ratio, it needs to have 3 notes in it. However, the notes can be rests. Because of this, the only mutating function should be to replace a note, not remove or add.
You may also have notes of different durations as part of the tuplet as seen [here](http://www2.siba.fi/muste1/index.php?id=100&la=en) where you have triplets with eighth notes and tied quarter notes.

Because of these rules, some type of validation must be done in the initializer to ensure the given notes equate to a full tuplet. This must be built into the `Tuplet` struct.

## API Design
### API Definition
**Open**: Naming is still up for debate. Having trouble with that. We did a first pass and it seems pretty good.
```swift
struct Tuplet: NoteCollection {
    /// The notes that make up the tuplet
    public private(set) var notes: [NoteCollection]
    /// The number of notes of the specified duration that this tuplet contains
    public let noteCount: Int
    /// The duration of the notes that define this tuplet
    public let noteDuration: NoteDuration
    /// The number of notes that this tuplet fits in the space of
    public let noteTimingCount: Int
    
    init(_ count: Int, _ baseNoteDuration: NoteDuration, inSpaceOf baseCount: Int? = nil, notes: [NoteCollection]) throws
    
    mutating func replaceNote(at index: Int, with note: Note) throws
    mutating func replaceNote(at index: Int, with notes: [Note]) throws
    mutating func replaceNote(at index: Int, with tuplet: Tuplet)
    mutating func replaceNotes(in range: Range<Int>, with notes: [Note])
    mutating func replaceNotes(in range: Range<Int>, with tuplet: Tuplet) throws
}
```
### Secondary duration
We can choose to allow a second duration to be specified like in [Finale](https://usermanuals.finalemusic.com/Finale2014Mac/Content/Finale/TPDLG.htm). However, in order to put the ratio on top, it seems like you need to convert to the same duration? Therefore, I have decided to take out the selection of a second duration.

-**Open**: Why have a second duration? Don't we need to convert to the same duration for the ratio?- I removed this capability as it doesn't seem useful.

If we do have a second duration, the initializer would function in the following way:
- The second duration is optional and will default to the same as the first duration.
- If the second duration is not the same as the first, we will need to internally convert it into the same as the first duration, so that we can use a standard ratio notation.

### Usage
If you would like to use a standard ratio, you can specify only the first number and duration. Then, `Tuplet` will validate whether the number specified is a standard (2-9) and if it is, it will automatically set the second number to the static ratio.

*Standard Ratio*
```swift
let standardTriplet = try! Tuplet(3, .eighth, notes: [eighthNote, eighthNote, eighthNote])
```
*Standard Ratio w/Odd definition*
```swift
let standardTriplet = try! Tuplet(3, .eighth, inSpaceOf: 1, .quarter, notes: [eighthNote, eighthNote, eighthNote])
```

*Custom Ratio*
```swift
let customOctuplet = try! Tuplet(
    8,
    .eighth,
    inSpaceOf: 5,
    .eighth, 
    notes: [eighthNote, eighthNote, eighthNote, eighthNote, eighthNote, eighthNote, eighthNote, eighthNote]
)
```

## Implementation Details
### Indexing for `replaceNote`
We will need to use a similar method used in other places to have an expanded set of indexes to get to each note. Please see [design doc](https://github.com/drumnkyle/music-notation-swift/blob/master/docs/indexing-methodolgy.md). This is needed because there can be compound tuplets and we want to be able to replace a single note with either a `Note` or `Tuplet`. Therefore, we need to be able to index into a single note even if it is within a compound `Tuplet`.

The `Tuplet` will have its own indexes and the `Measure` will get the indexes for a `Tuplet` for its purposes.

This one will differ a bit, because you can have a `Tuplet` that contains `Tuplet`s.

**Open**: Still figuring out how to represent this case.

## Other API Changes
### NoteCollection
#### API Before
```swift
protocol NoteCollection {
    var noteCount: Int
}
```

#### API After
**Open**: Naming is still up for debate. Needs to match `Tuplet` property naming above.
```swift
protocol NoteCollection {
    /**
     The duration of the note that in combination with `noteTimingCount` 
     will give you the amount of time this `NoteCollection` occupies.
     */
    var noteDuration: NoteDuration
    /**
     The number of notes to indicate the amount of time occupied by this
     `NoteCollection`. Combine this with `noteDuration`.
     */
    var noteTimingCount: Int
    /// The count of actual notes in this `NoteCollection`
    var noteCount: Int
}
```
### NoteDuration
It used to be an enum and the dot was a property on note. However, you can create a `Tuplet` with it's base note as a dotted note. Therefore, it makes sense to have a `NoteDuration` combine the value (eighth, quarter, etc.) with the number of dots. This also makes sense, because these two properties combined are what dictate the length of a note.

Now, `Tuplet` will be able to have a `NoteDuration` that will describe the base note type completely.
#### API Before
```swift
public enum NoteDuration: Int {
    case whole = 1
    case half = 2
    case quarter = 4
    // ...
}
```
#### API After
```swift
public struct NoteDuration {
    public enum Value {
        case long
        case large
        case doubleWhole
        case whole
        case half
        // ...
    }
    public let value: Value
    public let dotCount: Int
    public var timeSignatureValue: Int? {
        switch value {
        case whole: return 1
        case half: 2
        // ...
        case .long, .large, .doubleWhole: return nil
        }
    }
    
    private init(value: Value)
    public init(value: Value, dotCount: Int) throws
    
    public static let long = NoteDuration(value: .long)
    public static let large = NoteDuration(value: .large)
    // ...
}
```

## Sources
http://www2.siba.fi/muste1/index.php?id=100&la=en
https://usermanuals.finalemusic.com/Finale2014Mac/Content/Finale/TPDLG.htm
https://usermanuals.finalemusic.com/Finale2014Mac/Content/Finale/SIMPLETUPLETS.htm
https://musescore.org/en/handbook/tuplet
http://www.rpmseattle.com/of_note/create-a-tuplet-of-any-ratio-in-sibelius/
