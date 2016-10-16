//
//  FunctionalTests.swift
//  MusicNotationKit
//
//  Created by Kyle Sherman on 10/15/16.
//  Copyright © 2016 Kyle Sherman. All rights reserved.
//

import XCTest
import MusicNotationKit

class FunctionalTests: XCTestCase {

    // https://www.8notes.com/scores/23608.asp
    func testGuitarSong() {
        var staff = Staff(clef: .treble, instrument: .guitar6)
        let timeSignature = TimeSignature(topNumber: 4, bottomNumber: 4, tempo: 120)
        let key = Key(noteLetter: .a)
        assertNoErrorThrown {
            let firstRepeat = try MeasureRepeat(measures: [
                Measure(timeSignature: timeSignature, key: key,
                        notes: [
                            [
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave4)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .e, octave: .octave5)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .f, accidental: .sharp, octave: .octave5)),
                                ],
                            [
                                Note(noteDuration: .half, tone: Tone(noteLetter: .a, octave: .octave3)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave3)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .d, octave: .octave4))
                            ]
                    ]),
                Measure(timeSignature: timeSignature, key: key,
                        notes: [
                            [
                                Note(noteDuration: .half, tone: Tone(noteLetter: .e, octave: .octave5)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, octave: .octave5)),
                                Note(noteDuration: .quarter)
                            ],
                            [
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave3)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave3)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .e, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave3))
                            ]
                    ]),
                Measure(timeSignature: timeSignature, key: key,
                        notes: [
                            [
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave5)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .b, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .a, octave: .octave4)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .e, octave: .octave5)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave5)),
                                ],
                            [
                                Note(noteDuration: .half, tone: Tone(noteLetter: .a, octave: .octave3)),
                                Note(noteDuration: .half, tone: Tone(noteLetter: .f, octave: .octave4)),
                                ]
                    ]),
                Measure(timeSignature: timeSignature, key: key,
                        notes: [
                            [
                                Note(noteDuration: .half, tone: Tone(noteLetter: .b, octave: .octave4)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .b, octave: .octave4)),
                                Note(noteDuration: .quarter, tone: Tone(noteLetter: .c, accidental: .sharp, octave: .octave5)),
                                ],
                            [
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .d, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .f, octave: .octave4)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .e, octave: .octave3)),
                                Note(noteDuration: .eighth, tone: Tone(noteLetter: .d, octave: .octave4)),
                                Note(noteDuration: .half, tones: [
                                    Tone(noteLetter: .e, octave: .octave4),
                                    Tone(noteLetter: .g, accidental: .sharp, octave: .octave4)
                                    ])
                            ]
                    ])
                ])
            staff.appendRepeat(firstRepeat)
            try staff.startTieFromNote(at: 0, inMeasureAt: 3, inSet: 0)

            XCTAssertTrue(staff.isValid())
        }
    }
}
