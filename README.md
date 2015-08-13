# SafeFTL

SafeFTL is a relatively simple mod for the game Starbound. Its primary goal is to make the game's visual effects bearable for those who suffer from epilepsy or motion sickness.


---

### General Layout

SafeFTL is split up into three different mods:  
- SafeFTL - Tones down FTL jump and teleport effects.  
- SafeFTL-lights - Removes light flicker from just about every item in the game.  
- SafeFTL-lights_modded - An as-of-yet unused portion for removing light flicker from modded objects.  


---

### Utility Scripts  
These scripts are pretty ugly, but they function... for the most part.

#### lightNerf.sh  
Due to the sheer volume of objects to process, it would be impractical to remove light flicker by hand. As such, I wrote a quick BASH script to generate the patch files.  
The script is capable of generating patches for objects in the vanilla assets.pak, modpak files in giraffe_storage/mods, and conventional mods in giraffe_storage/mods.

#### package.sh  
This is a fairly simple script that makes the packaging process happen in a single place. The prompts should make it fairly intuitive.

#### clean.sh  
This script is really a single command to recursively remove all gedit temp files from the project directory.