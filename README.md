Music Notation Core (WIP)
==============

# THIS REPO IS DEPRECATED IN FAVOR OF `music-notation`

[![CocoaPods Version](https://img.shields.io/cocoapods/v/MusicNotationCore.svg)](#)
[![CocoaPods Platforms](https://img.shields.io/cocoapods/p/MusicNotationCore.svg)](#)
[![Build Status](https://travis-ci.org/drumnkyle/music-notation-core.svg?branch=master)](https://travis-ci.org/drumnkyle/music-notation-core)
[![codecov](https://codecov.io/gh/drumnkyle/music-notation-core/branch/master/graph/badge.svg)](https://codecov.io/gh/drumnkyle/music-notation-core/)
![Swift](https://img.shields.io/badge/%20in-swift%205.3-orange.svg)

This is a **work in progress**, Cross-Platform Music Notation API written in Swift. It is written so that it can be used in most any operating system, such as iOS, macOS, Android, Windows, and Linux assuming that Swift is ported to these platforms. This library is being created with the goal of having 0 dependencies; not even Foundation.

If you are looking for the ability to display the music in an application, please see [MusicNotationKit](https://github.com/drumnkyle/music-notation-kit), which depends on this core library.

Please consult this [Swift style guide](https://github.com/music-notation-swift/swift-style-guide) for coding style guidelines used in this repo and be sure to adhere to them.

There is a Slack channel you can join if you want to see more into the development process at [Music Notation Swift Slack](https://join.slack.com/t/musicnotationswift/shared_invite/enQtOTE1NzQyMzI5MTA2LWZlN2MyNmI5MjA2Njc4MGQ5N2IxNzYzY2QxMmYwNmFlNDNmNjUwNjBlMGY1MWIzNDkxMzY2MzAwNjc4NTJkNjU).

---

This library is meant to provide an easy-to-use API for creating tablature or staff music to be displayed or played in an application. The library is not meant to deal with any UI or Audio, so that it may be used with any other UI or Audio frameworks.

There is also a plan to create an easy to use input file format to create the music instead of having to create the objects in code as it stands right now. Hopefully a file format can be developed that will be able to make it so simple that a musician who is not necessarily tech savy, would be able to create sheet music or tablature. There are also some open file formats that may be looked into, such as MusicXML (http://www.musicxml.com).

# Including the library in your project

## Swift Package Manager

Currently unimplemented, but coming soon.

## Manual dependencies

`git checkout` the repository somewhere that your project can find it. You can use git _subtree_ or git sub modules method to keep the projects in sync, or use [`modulo`](https://github.com/modulo-dm/modulo) as a source only dependency manager, or yet still, simply keep them co-located and manage things manually.

To add a sub project (such as this) as a build dependency for your project, follow these steps:

- (If not present) Add a `Frameworks` group to your project.
- Add the project file into that group.

![Step1 & 2](docs/AddingFrameworkGroup.gif)

- Make the project's targets into a build dependency
- Link against the framework
- Add a copy phase to the Build Phases and copy the framework into your application framework folder.

![Step3, 4 & 5](docs/AddingFrameworkDeps.gif)

# License
This library is under the MIT license. You can use it freely. We'd love to hear about if you use it, so let us know. Feel free to reach out to [Steven Woolgar](mailto:woolie@gmail.com).

# Contributing
If you are interested in contributing, feel free to pick an issue and start to look into it. However, we suggest contacting us to get more info until we have created a full contributing guide. Contact [Steven Woolgar](mailto:woolie@gmail.com) for more details.
