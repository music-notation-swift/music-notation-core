//: Utilize this playground to test out MusicNotationKit

import MusicNotationKit

let standardTime = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
var measure = Measure(timeSignature: standardTime, key: Key(noteLetter: .c))
measure.addNote(Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave3)))
debugPrint(measure)
