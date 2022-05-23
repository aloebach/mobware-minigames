# mobware-minigames
Repo for Mobware Minigames for the Playdate!


Designed for the Playdate, this framework will allow you to compile your own minigame and play it within the overarching minigame framework.

The Mobware Minigames minigame framework will load a minigame which is programmed similar to a normal playdate game. See the minigame template in the minigame folder for details!

To get started, clone the repository. 
In z-shell: `git clone https://github.com/aloebach/mobware-minigames.git`

Rename and edit the `minigame_template` folder 
To compile and run the minigame jam game file, use the following command in z-shell:
`pdc ./mobware-minigames  mobware-minigames.pdx && open mobware-minigames.pdx`

Once you've cloned the repository, open Minigames/minigame-template and follow the instructions from there! After you've set up your own minigame using the template, you can set the DEBUG_GAME variable in `main.lua` to the name of your minigame to test. 


## Minigame guidelines 
* Minigames should not last longer 10s or so.
* The minigame should be in its own folder under "Minigames", and the <minigame_name> folder should have the same name as <minigame_name>.lua. 
* All necessary files such a libraries, music and image files should be contained within the individual minigame's folders, and the games can reference them accordingly. 
* <minigame_name>.lua must contain <minigame_name>.update(), similar to playdate.update(), which is called once every frame.
* <minigame_name>.update() should return a 1 if the player won, or a 0 if the player lost.
* Playdate's additional callback functions are supported, but will be similarly named the <minigame_name> equivalent, such as <minigame_name>.cranked(change, acceleratedChange)
* credits.json should be in the minigame's root folder and contain the credits for your minigame to be included in the overall game's final credits sequence.
* credits.gif should be a Gif to be displayed for your minigame in the credits sequence. It should be in the minigame's root folder and be no larger than 180 x 180.
* the main game will start at 20 fps and slowly increase to 40 fps. Keep this in mind when programming your minigame so that it scales in difficulty accordingly and it's playable both at 20 and 40 fps.

## License information
Code for the Mobware Minigames is licensed under Creative Commons Attribution-NonCommercial 4.0 International license.
https://creativecommons.org/licenses/by-nc/4.0/

Attribution — You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.

NonCommercial — You may not use the material for commercial purposes. 
