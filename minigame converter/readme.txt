This minigame converter will allow you to take a playdate game written in in Lua and convert it into a minigame format for use with Mobware Minigames. 

Usage: python3 convert2minigame.py <path> --name <minigame name> [--output <output directory>]

example: The following command will take the playdate code found in the directory "Asheteroids/Source/" and create a minigame named "asheteroids"

python3 convert2minigame.py Asheteroids/Source/ --name asheteroids
