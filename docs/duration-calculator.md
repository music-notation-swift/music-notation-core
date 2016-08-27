# Duration Calculator

The number of beats in a measure depend on the time signature. The top number 
of the time signature determines the number of beats per measure, while the 
bottom one determines the length of one beat. 

For example:

4/4: 4 beats of 1/4 notes.
6/8: 6 beats of 1/8 notes.

## Note Measurement

### Convert Note Duration Into Ticks Per Quarter Note (TPQN)

Calculate measure budget based on time signature. Ideally, it is not ideal to
work with fractions, so it would be better to express lengths w.r.t the shorest
note.

https://en.wikipedia.org/wiki/Two_hundred_fifty-sixth_note

The shortest recorded note is 1/256, which means that we would have to
use at least 1/512 to account for a 1/256 dot length, or 1/1024 to account for a
double dot. 

Lets say we go with 1024: 


|Note Duration | Note Weight |
|--------------|-------------|
|1             |         1024|
|1/2           |          512|
|1/4           |          256|
|1/8           |          128|
|1/16          |           64|
|1/32          |           32|
|1/64          |           16|
|1/128         |            8|
|1/256         |            4|
|1/512         |            2|
|1/1024        |            1|

1/1024 = 1 for a note: (1/256)+dot+dot

Another solution is to make the calculations w.r.t to the quarter note (1/4).
This is nice because it would make us more compatible with MIDI (see 
https://en.wikipedia.org/wiki/Pulses_per_quarter_note). With this in mind, 
we can probably use Ticks Per Quarter Note (TPQN).

Music XML supports 1/1024 notes:
http://usermanuals.musicxml.com/MusicXML/Content/ST-MusicXML-note-type-value.htm

### Implementation

- Make TPQN configurable (e.g 1024, TODO: look into MIDI time duration). This
  parameter is not necessarily exposed in the public API.
- Calculate budget in terms of TPQN. For example: `4/4 = 4 * TPQN, 6/8 = 6 * (TPQN / 2)`.
  In the case of `6/8` TPQN id divided by 2 because an eighth note is half of a quarter.

## Measure Calculations

- Measure occupancy value (measure usage): used space / measure budget.
- Proposed API: Suggest available note durations given used space. 
- Proposed API: Validate measure.
- ~~Proposed setting to enable automatic validation. This implementation would
  leverage incremental changes in the measure occupancy values.~~
- Insert note (Methods implemented in Measure class).
- Delete note (Methods implemented in Measure class).
- Replace note. This can be a combination of delete followed by insert?

## New API

New enum: `MeasureDurationValidator` with all static methods.

### Latest Draft

```swift
public enum MeasureDurationValidator {
    public enum CompletionState {
        case notFull(availableNotes: [NoteDuration : Int])
        case full
        case overfilled(overflowingNotes: Range<Int>)
    }
    public static func completionState(of measure: ImmutableMeasure) -> CompletionState
    public static func number(of noteDuration: NoteDuration, fittingIn: ImmutableMeasure) -> Int
```

### First Draft

```swift
public enum MeasureDurationValidator {
    public enum CompletionState {
        case notFull
        case full
        case overfilled
    }
    public static func completionState(of measure: Measure) -> CompletionState
    public static func number(of noteDuration: NoteDuration, fittingIn: Measure) -> Int
    public static func overflowingNotes(for measure: Measure) -> Range<Int>?
    public static func availableNotes(for measure: Measure) -> [NoteDuration : Int]
}
```

Changes to `Staff`
- Create method to split a `Measure` that is overfilled into 2 measures. This utilizes the return value from `MeasureDurationValidator.overflowingNotes(for:)`.

Changes to `Measure`:
- Make a way to modify `Tuplet`s and replace `Tuplet`s.
- There may be a way to reuse functionality from `Staff.insertMeasure`, so think about it...

Opens:
- How to deal with irrational meter (i.e. 4/3 time signature)
- ~~Good to have the ability to tell what can be used to fill the measure.~~
- ~~Let the API caller know that the measure is incomplete.~~
- ~~Add the ability to split the measure.~~ See changes for `Staff`
- ~~What happens when the user changes the time signature. Do we allow this?~~ Yes. We just call the methods.

