# This python script will take a directory containing Playdate Lua code as input and convert it into a minigame
# Author: Andrew Loebach

# importing packages
import sys
import os
import shutil
import argparse

#Parse command-line arguments and set default values if no argument is specified
parser = argparse.ArgumentParser()
parser.add_argument("path", help="directory where the Playdate game is located")
parser.add_argument("--output", help="path where minigame code will be outputted")
parser.add_argument("--name", help="Specify the name of the minigame")

args = parser.parse_args()

# define minigame name:
if args.name:
	# if the --name option is set, use this as the minigame name
	minigame_name = args.name.replace(' ','_')
else:
	# if no name is provided, derives the minigame name from the filename
	base_name = os.path.basename(args.path)
	minigame_name = base_name.replace(' ','_')

print('Creating minigame files for:', minigame_name)

	
# create new directory where we output the minigame code to
if args.output:
	output_directory = args.output
else:
	output_directory = "_" + minigame_name

print("outputting minigame files to:", output_directory, "..." )

if os.path.isdir(output_directory):
	user_response = input("Directory " + output_directory + " already exists. Overwrite (y/n)? ")
	if user_response.lower() != 'y':  
		print("<aborting script>\n")
		sys.exit()
else:
	# if directory doesn't exist we simply create it
	os.mkdir(output_directory)
	

# copy game files to output directory
shutil.copytree(args.path, output_directory, dirs_exist_ok=True)

# traverse directory and create a list all .lua files it contains
file_list = []
for root, _directories, files in os.walk(output_directory):
	for file in files:
		if(file.endswith(".lua")):
			file_list.append(os.path.join(root,file))
			
			
# create a dictionary i can iterate over and do a replace operation for each element
function_dictionary = {
	'playdate.update': minigame_name + '.update',
	'playdate.cranked': minigame_name + '.cranked',
	'playdate.crankDocked':minigame_name + '.crankDocked',
	'playdate.crankUndocked':minigame_name + '.crankUndocked',
	'playdate.AButtonDown':minigame_name + '.AButtonDown',
	'playdate.AButtonHeld':minigame_name + '.AButtonHeld',
	'playdate.AButtonUp':minigame_name + '.AButtonUp',
	'playdate.BButtonDown':minigame_name + '.BButtonDown',
	'playdate.BButtonHeld':minigame_name + '.BButtonHeld',
	'playdate.BButtonUp':minigame_name + '.BButtonUp',
	'playdate.downButtonDown':minigame_name + '.downButtonDown',
	'playdate.downButtonUp':minigame_name + '.downButtonUp',
	'playdate.leftButtonDown':minigame_name + '.leftButtonDown',
	'playdate.leftButtonUp':minigame_name + '.leftButtonUp',
	'playdate.rightButtonDown':minigame_name + '.rightButtonDown',
	'playdate.rightButtonUp':minigame_name + '.rightButtonUp',
	'playdate.upButtonDown':minigame_name + '.upButtonDown',
	'playdate.upButtonUp':minigame_name + '.upButtonUp'
	}

# iterate over all lua files
for filename in file_list:
	#print("checking file:", filename)

	with open(filename, "r") as file:
		data = file.read()
	
		# search for standard playdate SDK commands and replace with minigame commands
		for PD_function in function_dictionary:
			data = data.replace(PD_function, function_dictionary[PD_function])
	
	# Writing the replaced data to file
	with open(filename, "w") as file:
		# add minigame name to top of main.lua
		if os.path.basename(filename) == "main.lua":
			file.write("-- Define minigame package\n")
			file.write("local " + minigame_name + " = {}\n")
			
		file.write(data) # writing the updated data to file
		
		# return minigame package at bottom of main.lua
		if os.path.basename(filename) == "main.lua":
			file.write("\n-- Return minigame package\n")
			file.write("return " + minigame_name)


# rename main.lua to the name of the minigame
try:
	os.replace(output_directory + '/main.lua', output_directory + '/' + minigame_name + '.lua')
except:
	print("ERROR: could not find main.lua")


# remove pdxinfo since the minigame doesn't need it
os.remove(os.path.join(output_directory,"pdxinfo"))
# remove .pdx file(s)?

print('Minigames files written to', output_directory)
print('<script completed>\n')
