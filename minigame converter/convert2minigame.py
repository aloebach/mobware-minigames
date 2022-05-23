# This python script will take a directory containing Playdate Lua code as input and convert it into a minigame
# Author: Andrew Loebach

# NOTE: THIS SCRIPT IS A WORK IN PROGRESS AND IS NOT YET FUNCTIONAL!

### IMPORTING PACKAGES AND SETTING CREDENTIALS ###
#import json
import sys
import os
import shutil

#import requests
import argparse


#Parse command-line arguments and set default values if no argument is specified
parser = argparse.ArgumentParser()
parser.add_argument("path", help="file path where the Playdate game is located")
parser.add_argument("--git", action="store_true", help="retrieve code from git repository")
parser.add_argument("--output", help="path where minigame code will be outputted", default="minigame")
parser.add_argument("--name", help="Specify the name of the minigame")


args = parser.parse_args()
# define minigame name

# if the --name option is set, use this as the minigame name
if args.name:
	minigame_name = args.name.replace(' ','_')
else:
	# if no name is provided, extracts the minigame name from the filename
	base_name = os.path.basename(args.path)
	minigame_name = base_name.replace(' ','_')

# for debugging:
print('minigame name:', minigame_name)
	
# create new directory where we output the minigame code to
if args.output:
	output_directory = args.output
else:
	output_directory = minigame_name
	
if not os.path.isdir(output_directory):
	os.mkdir(output_directory)


'''
with open(os.path.join(args.output, "main.lua"), "w") as f:
	f.write(code)
	
shutil.copy("pulp.lua", outpath)
shutil.copy("pulp-audio.lua", outpath)
'''

print(f"files written to {args.output}")

# load Lua code

# search and replace standard playdate SDK commands with minigame commands

# remove files not relevant for minigame format
# remove pxinfo


