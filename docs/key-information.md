# Indexing Methodology
Author: Rob Hudson
## Audience
This design document goes over an implementation detail that is only pertinent to maintainers and developers of this library and not to users of the API.
## Introduction
The `Interval` type can be used to define key signatures, and will provide the greatest flexibility and extensibility to handle any non-standard key signatures.
### Example
Any standard key or mode may be defined with a starting pitch and a series of intervals. For example, all major keys consistent of (abbreviated) 'M2 M2 m3 M2 M2 M2 m2'. The notes of any major key may be calculated with the starting pitch and this series of intervals.
## Implementation
### Overview
Though there is currently an `Interval` type in MusicNotationKit, more functionality needs to be added to it. It needs to be extended so that it may calculate the interval between a pair of notes, or calculate a note given another note and a particular interval.

A concept of direction will also be needed in some cases. For example, a C4 and A4 played simultaneously are a Major 6th without a direction, but a C4 followed by an A4 represents an _ascending_ Major 6th, while an A4 followed by a C4 is a _descending_ Major 6th.

I propose the addition of an `IntervalDirection` enum for this purpose:

```
public enum IntervalDirection {
	case .ascending
	case .descending
	case .unison
}
```

Once `Interval` has been extended, various scales and modes may be created from a starting pitch and an array of ascending intervals. Once the series of pitches calculated, the non-natural accidentals would be used for display.

**Open**: Should direction be an optional property of the existing `Interval` type, or should a new type (`DirectedInterval`?) be added?
