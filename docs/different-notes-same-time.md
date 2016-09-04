# Different Notes at Same Time
## Introduction
In music, you can have a note with 2 different tones played at the same time. You see this with one stem and 2 note heads coming off of it on different staff lines/spaces. This has already been accomplished by making every `Note` have an array of `Tone`s. However, at the same time, you may also have a note of a different duration be played at the same time. Throughout this document I will refer to this as a second *set* of notes in the measure.
### Terminology
- **Set** of notes is one set of notes that need to equal a full measure (like the bass drum part of a drumset score).
- **Time slice** is the vertical slice of a measure where a note would be laid out. If 2 notes occur at the same exact time, they would be rendered in the same *time slice*.

### Example
This happens quite often in drumset music. With a standard rock beat in 4/4, you have the hi-hat playing eighth notes throughout the whole measure. The snare drum plays eighth notes on beats 2 and 4, which can be represented as 2 tones on the notes that have the snare drum and hi-hat at once. Then, you have the bass drum on beats 1 and 3 as quarter notes with quarter note rests in between.
## All Cases
This second set of notes in the measure can occur:
- at the same time as another note in a different set
- in between two notes in a different set
## Requirements
- Each set of notes must constitute a full measure (i.e. 4 beats in 4/4; no more, no less)
- You cannot have the same tone represented by 2 sets at the same exact time. **Open**: Can you?
    - **Open**: How do we enforce this? Seems like it needs to be some type of measure validation.
- Need to support the ability for a rendering library to be able to draw the measure easily
    - time slice by time slice
- API should be as simple as possible to perform measure mutation functionality

## Proposed Solution
### Two Dimensional Array
We take the array of `[NoteCollection]` that we have now and make it two dimensional: `[[NoteCollection]]`. Each set of notes will be represented as an element in the outermost array.
#### Reasoning
- We can perform measure duration validation on each element of the outermost array completely separately.
- Rendering index into each sub-array at the same time so that it can easily know if the where the notes line up with each other in the time slices.
- API can change to simply have a set index that can default to 0.

## Alternatives Considered
### Graph
We did not explore too deply into this, because it seemed that this would add much complexity. This would especially make it difficult to index into the measure in order to perform any of the mutation functionality. Therefore, we tabled this.
### Single-Dimensional of structs Representing multiple sets
We thought we might be able to have a single-dimensional array of some protocol type that represented a vertical time slice. This way you would have an simple, single dimensional array. And you would have multiple notes represented in some sort of protocol that represented a single slice of time.
#### Problems
The main issue is that this would make measure duration validation very difficult. Insertion would also become very difficult as you would have to figure out if you needed a new time slice in between two existing ones or if this lines up with a time slice that is already there.
