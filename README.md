Music Notation Kit (WIP)
==============

[![Build Status](https://travis-ci.org/drumnkyle/music-notation-swift.svg?branch=master)](https://travis-ci.org/drumnkyle/music-notation-swift)
[![codecov](https://codecov.io/gh/drumnkyle/music-notation-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/drumnkyle/music-notation-swift/)

This is a **work in progress**, Cross-Platform Music Notation API written in Swift. It is written so that it can be used in most any operating system, such as iOS, OS X, Android, Windows, and Linux assuming that Swift is ported to these platforms. This library is being created with the goal of having 0 dependencies; not even Foundation.

Please consult this [Swift style guide](https://github.com/drumnkyle/swift-style-guide) for coding style guidelines used in this repo and be sure to adhere to them.

===
This library is meant to provide an easy-to-use API for creating tablature or staff music to be displayed or played in an application. The library is not meant to deal with any UI or Audio, so that it may be used with any other UI or Audio frameworks.

There is also a plan to create an easy to use input file format to create the music instead of having to create the objects in code as it stands right now. Hopefully a file format can be developed that will be able to make it so simple that a musician who is not necessarily tech savy, would be able to create sheet music or tablature. There are also some open file formats that may be looked into from LilyPond (http://www.lilypond.org) and MusicXML (http://www.musicxml.com).
