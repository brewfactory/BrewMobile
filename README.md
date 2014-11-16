# BrewMobile

iOS client for the [Brewfactory](https://github.com/brewfactory/BrewCore) project

What is this?
-------------
App for managing the brewing process from your iPhone.

 - continuous temperature updates
 - displays current phases with necessary info
 - gives visual feedback of the current state
 - brew designer - ability of composing new brew
 - stopping current process
 
## Used technologies

 - Swift
 - iOS >= 7.0, iOS 8 compatible
 - Socket.IO for WebSocket

## Setting up the project
```
$ pod install

$ open BrewMobile.xcworkspace/
```

## // TODO

 - improve test coverage
 - support push notifications (for phase changes)
 - ability to edit host
 - pause/resume
 - logs

## The UI

![Brewing a beer](http://brewfactory.org/BrewMobile/img/6.png)![Designing a brew](http://brewfactory.org/BrewMobile/img/7.png)
