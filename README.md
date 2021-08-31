## Why?
When working on large projects with opencomputers, the built-in editor starts to show some issues (auto-whitespace, completeion, etc). This allows all of your files to be on one hard disk for easier access with external editors.

## Usage
1. Download both `bios.lua` and `netboot.lua`
2. Create a `bin` folder and a `lib` folder
3. Create desired files in `bin` and all desired libraries in `lib`
4. Run `netboot flash FILENAME` to flash the currently inserted eeprom with netboot and configure it to boot FILENAME
5. When updating files there is no need to reflash the eeprom, all that is needed is to update the file on the source pc

## Warnings
1. The way require is implemented is currently quite hacky and it currently requires parenthesis rather than spaces
2. Make sure to set `bufferChanges` to false in settings.conf inside the opencomputers config folder in order to use external editors 
