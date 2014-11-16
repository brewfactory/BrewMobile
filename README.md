BrewMobile
==========

iOS client for the [Brewfactory][1] project

What is this?
-------------
App for managing the brewing process from your iPhone.

 - continuous temperature updates
 - displays current phases with necessary info
 - gives visual feedback of the current state
 - brew designer - ability of composing new brew
 - stopping current process

**The UI**

![brew_demo_1][2][brew_demo_2][3]
 
Used technologies
-----------------
 - Swift
 - iOS >= 7.0, iOS 8 compatible
 - Socket.IO for WebSocket

### Setting up the project ###
```
$ pod install

$ open BrewMobile.xcworkspace/
```
// TODO
-------

 - improve test coverage
 - support push notifications (for phase changes)
 - ability to edit host
 - pause/resume
 - logs

  [1]: https://github.com/brewfactory/BrewCore
  [2]: http://brewfactory.org/BrewMobile/img/3.png
  [3]: http://brewfactory.org/BrewMobile/img/4.png
