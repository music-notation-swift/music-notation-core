Music Notation Core (WIP)
==============

[![Build Status](https://travis-ci.org/drumnkyle/music-notation-swift.svg?branch=master)](https://travis-ci.org/drumnkyle/music-notation-swift)
[![codecov](https://codecov.io/gh/drumnkyle/music-notation-swift/branch/master/graph/badge.svg)](https://codecov.io/gh/drumnkyle/music-notation-swift/)
![Swift](https://img.shields.io/badge/%20in-swift%203.0-orange.svg)

This is a **work in progress**, Cross-Platform Music Notation API written in Swift. It is written so that it can be used in most any operating system, such as iOS, macOS, Android, Windows, and Linux assuming that Swift is ported to these platforms. This library is being created with the goal of having 0 dependencies; not even Foundation.

If you are looking for the ability to display the music an an application, please see [MusicNotationKit](https://github.com/drumnkyle/music-notation-kit), which depends on this core library.

Please consult this [Swift style guide](https://github.com/drumnkyle/swift-style-guide) for coding style guidelines used in this repo and be sure to adhere to them.

There is a Slack channel you can join if you want to see more into the development process at [Music Notation Swift Slack](https://musicnotationswift.slack.com).

===
This library is meant to provide an easy-to-use API for creating tablature or staff music to be displayed or played in an application. The library is not meant to deal with any UI or Audio, so that it may be used with any other UI or Audio frameworks.

There is also a plan to create an easy to use input file format to create the music instead of having to create the objects in code as it stands right now. Hopefully a file format can be developed that will be able to make it so simple that a musician who is not necessarily tech savy, would be able to create sheet music or tablature. There are also some open file formats that may be looked into, such as MusicXML (http://www.musicxml.com).

===
# License
This library is under the GPLv3 license. If you would like to use this library for commercial use, please contact [Kyle Sherman](mailto:kyledsherman@gmail.com) for commercial license information
