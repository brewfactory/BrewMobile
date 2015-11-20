# BrewMobile

[![Bitrise](https://www.bitrise.io/app/276d8847158110d2.svg?token=aYjuPeusfMeRdDn_eDksIg&branch=master)](https://www.bitrise.io/) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

iOS client for the [Brewfactory](https://github.com/brewfactory/BrewCore) project. 

Read the [stories of upgrading BrewMobile to ReactiveCocoa & Swift on AllTheFlow](https://blog.alltheflow.com/reactive-swift-upgrading-to-reactivecocoa-3-0/).

What is this?
-------------
App for managing the brewing process from your iPhone.

 - continuous temperature updates
 - displays current phases with necessary info
 - gives visual feedback of the current state
 - brew designer - ability of composing new brew
 - stopping current process
 
## Used technologies

 - Swift 2.0
 - iOS >= 8.1
 - Socket.IO for WebSocket
 - [ReactiveCocoa 4.0](https://github.com/ReactiveCocoa/ReactiveCocoa)

## Setting up the project with [Carthage](https://github.com/Carthage/Carthage)
In case you don't have Carthage installed, run:

```
$ brew update && brew install carthage
```
then:
```
$ carthage bootstrap --platform iOS

$ open BrewMobile.xcworkspace/
```

## The UI

![Brewing a beer](http://brewfactory.org/BrewMobile/img/9_small.png)![Designing a brew](http://brewfactory.org/BrewMobile/img/8_small.png)
