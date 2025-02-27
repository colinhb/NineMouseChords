# NineMouseChords

A [Hammerspoon](http://www.hammerspoon.org) ["Spoon"](https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md) that mimics Plan 9's [Acme editor](https://en.wikipedia.org/wiki/Acme_(text_editor)) [mouse chords](http://acme.cat-v.org/mouse) for cut, paste, and "snarf" operations.

## Motivation

Acme's mouse chords become second nature. Though I am also a vi person ([nvi](https://en.wikipedia.org/wiki/Nvi) in particlar), it's hard to beat the flow of working inside Acme, and a big part of that is its use of the mouse. 

This Spoon brings a few text manipulation mouse chords to macOS, eliminating a tiny bit of mental context switching when using Acme on macOS.

## Installation

After [installing and setting up](http://www.hammerspoon.org/go/) Hammerspoon:

1. Download and unzip [NineMouseChords.spoon.zip](NineMouseChords.spoon.zip).
2. Install using one of these methods:
    * Double-click `NineMouseChords.spoon` to let Hammerspoon handle installation, or 
    * Copy `NineMouseChords.spoon` to your Spoons directory
3. Add this line to your Hammerspoon config: `hs.loadSpoon("NineMouseChords"):start()`
4. Reload your Hammerspoon configuration

For more details about Spoons installation and configuration paths, see the [Hammerspoon Spoon Documentation](https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md).

## Use

Mouse chording in NineMouseChords works similarly to Plan 9's Acme editor:

1. **Select text by pressing the left mouse button down.** You may already have text highlighted, but you can also drag the mouse to create a highlight, or hold the end of a double-click to create a highlight.
2. While holding the left button down:
   - Click the **middle button to cut the selected text**
   - Click the **right button to paste previously cut text**
3. **Release the left button** to complete the operation

**Note**: To copy text ("snarf" in Plan 9 parlance), while the left mouse button is down, you cut (middle button) and paste (right button) the same text back. You can then release the left mouse button, and use the paste chord to paste the "snarfed" text elsewhere.

You can find a helpful diagram at [http://acme.cat-v.org/mouse](http://acme.cat-v.org/mouse).

### Blacklist

Since the Acme editor handles mouse chords itself (and richer set than are implmented in this Spoon), we don't handle chording when Acme is focused; the app is "blacklisted". You can blacklist other apps using the `:excludeApps()` method:

```lua
hs.loadSpoon("NineMouseChords")
  :excludeApps({"Finder", "Photoshop"})
  :start()
```

Beesides allowing specialized apps to handle mouse events themselves, please see the [note on implementation](#1-implementation) below for other reasons you may want to blacklist certain apps.

## Notes

### 1. Implementation

We generate macOS key strokes (CMD-C, DEL, CMD-V) under the hood to perform cut and paste operations. While this is simple and reliable, it means the DEL key stroke is generated during cut operations. Exercise caution in apps where an unexpected delete key stroke could be problematic.

### 2. Compatibility

This Spoon has been tested primarily with standard macOS desktop apps and [the Acme editor](https://en.wikipedia.org/wiki/Acme_(text_editor)). 

I have no idea whether this (or Hammerspoon in general) works with games and more specialized apps (e.g. CAD software).

### 3. Alternative Installation

You can create a symbolic link from your Spoons directory to the NineMouseChords.spoon package:

```
$ cd $HOME/.hammerspoon/Spoons && ln -s /path/to/NineMouseChords.spoon
```

Hammerspoon seems to handle this fine, but it is not one of the documented installation methods.

## License

Please see [LICENSE](LICENSE) file.
