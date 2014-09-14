BrewMobile
==========

[![Build Status](https://travis-ci.org/brewfactory/BrewMobile.svg?branch=objC)](https://travis-ci.org/brewfactory/BrewMobile)

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

 - iOS >= 7.0
 - Socket.IO for WebSocket

### iOS 8 compatible [swift project at master][3] ###

### Setting up the project ###
```
$ pod install

$ open BrewApp.xcworkspace/
```
// TODO
-------

 - support push notifications (for phase changes)

  [1]: https://github.com/brewfactory/BrewCore
  [2]: http://brewfactory.org/BrewMobile/img/2.png
  [3]: https://github.com/brewfactory/BrewMobile/
