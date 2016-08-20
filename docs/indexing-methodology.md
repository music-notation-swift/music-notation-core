# Indexing Methodology
## Audience
This design document goes over an implementation detail that is only pertinent to maintainers and developers of this library and not to users of the API.
## Introduction
Throughout multiple implementations in this library, a technique is used to allow for indexing of elements within a container in two different ways at the same time. There is indexing that accesses the structs that are used to implement concepts and then there is indexing used to access the actual data as a user would see it.
### Example
`Staff` holds an array of `NotesHolder`s. `NotesHolder` is a protocol that both `Measure` and `MeasureRepeat` implement. Therefore, the staff holds an array where each element is either a `Measure` or a structure that stores the data for one or `Measure`s that are repeated.

For a method like `Staff.insertMeasure(at:beforeRepeat)`, the index given to the `at` parameter would take into account the expanded `MeasureRepeat`, including its repeated measures. Therefore, in order to do this indexing, we need to be able to translate between that index and indexing into the array of `NotesHolder`s that the `Staff` stores and into the `MeasureRepeat` if that is what exists at the specified index.

## Implementation
### Overview
We have a method called `recompute<Name>Indexes` that gets called in the `didSet` of the array that we need to compute this secondary set of indexes for. For `Staff` the method is called `recomputeMeasureIndexes`. In this method, we loop through the array and get the index of any nested structures and expand those indexes. The resulting data structure is an array of tuples. The tuple has 2 elements: primary index and secondary index. The secondary index is optional, because it is only used if there is a nested data structure at that index.
    
### Concrete Example
`Staff.recomputeMeasureIndexes()` will set the `measureIndexes` array. This array will store tuples of `(notesHolderIndex: Int, repeatMeasureIndex: Int?)`.

### Detail
`recompute<Name>Indexes` will loop through the array and add a tuple entry to the indexes array. If it encounters a nested structure, it will perform a nested loop and add a tuple entry for every element in that nested structure as well.

### Efficiency
Therefore, the worst case efficiency of this algorithm is O(n*m) where n is the number of elements in the main array and m is the number of elements in the nested structure. Of course, a piece of music is not going to have all nested structures.

To limit the hit to performance, this method is performed only when the array is modified. The idea is that the array will be modified less times than the methods will be called. However, this has not been explored or tested fully. The performance has also not been specifically measured.

**Open**: If anyone can think of a more efficient way, please let us know.

## Usages
- Used in `Staff` for the array of `NotesHolder`s.
- Used in `Measure` for the array of `NoteCollection`s.
- Used in `Tuplet` for the array of `NoteCollection`s.
