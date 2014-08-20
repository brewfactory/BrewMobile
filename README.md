BrewMobile
==========

[![Build Status](https://travis-ci.org/vasarhelyia/BrewMobile.svg?branch=master)](https://travis-ci.org/vasarhelyia/BrewMobile)

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

### iOS 8 compatible [swift branch][3] ###

### Setting up the project ###
```
$ pod install

$ open BrewApp.xcworkspace/
```
// TODO
-------

 - support push notifications (for phase changes)

  [1]: https://github.com/brewfactory/BrewCore
  [2]: http://vasarhelyia.github.io/BrewMobile/img/1.png
  [3]: https://github.com/vasarhelyia/BrewMobile/tree/swift