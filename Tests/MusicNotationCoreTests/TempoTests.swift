//
//  TempoTests.swift
//  MusicNotationCore
//
//  Created by Steven Woolgar on 07/29/2024.
//  Copyright © 2024 Steven Woolgar. All rights reserved.
//

@testable import MusicNotationCore
import Testing

@Suite final class TempoTests {
    @Test func tempoDebug() async throws {
        let tempo = Tempo(type: .linear, position: 10.3, value: 120, unit: .quarter)
        #expect(tempo.debugDescription == "type: linear, position: 10.3, value: 120, unit: quarter")
    }

    @Test func tempoDebugWithLabel() async throws {
        let tempo = Tempo(type: .linear, position: 10.3, value: 120, unit: .quarter, text: "Intro")
        #expect(tempo.debugDescription == "type: linear, position: 10.3, value: 120, unit: quarter, text: Intro")
    }
}
