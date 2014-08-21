BrewMobile
==========

iOS client for the [Brewfactory][1] project

What is this?
-------------
App for supervising the brewing process from your iPhone.

 - continuous temperature updates
 - displays current phases with necessary info
 - gives visual feedback of the current state

**The UI**

![brew_demo_1][2]
 
Used technologies
-----------------
 - Swift
 - iOS >= 7.0, iOS 8 compatible
 - Socket.IO for WebSocket

### Setting up the project ###
```
$ pod install

$ open BrewApp.xcworkspace/
```
// TODO
-------

 - write tests (facing some diffculties in this subject with iOS 8 beta for now)
 - support push notifications (for phase changes)

  [1]: https://github.com/brewfactory/BrewCore
  [2]: http://vasarhelyia.github.io/BrewMobile/img/2.png
