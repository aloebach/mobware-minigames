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
#parser.add_argument("--keeppaths", help="keep original paths for import functions")
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
	output_directory = "_" + minigame_name + "_minigame"

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
	
# create a dictionary I can iterate over and do a replace operation to add the minigame path for importing files and functions
minigame_path = 'Minigames/' + minigame_name + '/'
path_dictionary = {
	'import \'': 'import \'' + minigame_path,
	'import \"': 'import \"' + minigame_path,
	'image.new(\'': 'image.new(\'' + minigame_path,
	'image.new(\"': 'image.new(\"' + minigame_path,
	'imagetable.new(\'': 'imagetable.new(\'' + minigame_path,
	'imagetable.new(\"': 'imagetable.new(\"' + minigame_path,
	'fileplayer.new(\'': 'fileplayer.new(\'' + minigame_path,
	'fileplayer.new(\"': 'fileplayer.new(\"' + minigame_path,
	'sampleplayer.new(\'': 'sampleplayer.new(\'' + minigame_path,
	'sampleplayer.new(\"': 'sampleplayer.new(\"' + minigame_path,
	
	'image:load(\'':'image:load(\'' + minigame_path,
	'image:load(\"':'image:load(\"' + minigame_path,
	'imagetable:load(\'':'imagetable:load(\'' + minigame_path,
	'imagetable:load(\"':'imagetable:load(\"' + minigame_path,	
	'font.new(\'': 'font.new(\'' + minigame_path,
	'font.new(\"': 'font.new(\"' + minigame_path,
	'newFamily(\'': 'newFamily(\'' + minigame_path,
	'newFamily(\"': 'newFamily(\"' + minigame_path,
	'video.new(\'': 'video.new(\'' + minigame_path,
	'video.new(\"': 'video.new(\"' + minigame_path,
	'decodeFile(\'': 'decodeFile(\'' + minigame_path,
	'decodeFile(\"': 'decodeFile(\"' + minigame_path,
	'json.encodeToFile(\'': 'json.encodeToFile(\'' + minigame_path,
	'json.encodeToFile(\"': 'json.encodeToFile(\"' + minigame_path,
	'fileplayer:load(\'':'fileplayer:load(\'' + minigame_path,
	'fileplayer:load(\"':'fileplayer:load(\"' + minigame_path,
	'sample.new(\'': 'sample.new(\'' + minigame_path,
	'sample.new(\"': 'sample.new(\"' + minigame_path,
	'sequence.new(\'': 'sequence.new(\'' + minigame_path,
	'sequence.new(\"': 'sequence.new(\"' + minigame_path,
	'loadImage(\'': 'loadImage(\'' + minigame_path,
	'loadImage(\"': 'loadImage(\"' + minigame_path,
	'readImage(\'': 'readImage(\'' + minigame_path,
	'readImage(\"': 'readImage(\"' + minigame_path,	
	'file.open(\'': 'file.open(\'' + minigame_path,
	'file.open(\"': 'file.open(\"' + minigame_path,
	'listFiles(\'': 'listFiles(\'' + minigame_path,
	'listFiles(\"': 'listFiles(\"' + minigame_path,	
	'exists(\'': 'exists(\'' + minigame_path,
	'exists(\"': 'exists(\"' + minigame_path,	
	'isdir(\'': 'isdir(\'' + minigame_path,
	'isdir(\"': 'isdir(\"' + minigame_path,			
	'mkdir(\'': 'mkdir(\'' + minigame_path,
	'mkdir(\"': 'mkdir(\"' + minigame_path,		
	'delete(\'': 'delete(\'' + minigame_path,
	'delete(\"': 'delete(\"' + minigame_path,		
	'getSize(\'': 'getSize(\'' + minigame_path,
	'getSize(\"': 'getSize(\"' + minigame_path,	
	'getType(\'': 'getType(\'' + minigame_path,
	'getType(\"': 'getType(\"' + minigame_path,	
	'modtime(\'': 'modtime(\'' + minigame_path,
	'modtime(\"': 'modtime(\"' + minigame_path,	
	'load(\'': 'load(\'' + minigame_path,
	'load(\"': 'load(\"' + minigame_path,	
	'run(\'': 'run(\'' + minigame_path,
	'run(\"': 'run(\"' + minigame_path,	
	'imageSizeAtPath(\'': 'imageSizeAtPath(\'' + minigame_path,
	'imageSizeAtPath(\"': 'imageSizeAtPath(\"' + minigame_path,	
	'nineSlice.new(\'': 'nineSlice.new(\'' + minigame_path,
	'nineSlice.new(\"': 'nineSlice.new(\"' + minigame_path
}	
	

# iterate over all lua files
CoreLibs_warning = False
for filename in file_list:
	#print("checking file:", filename)

	with open(filename, "r") as file:
		data = file.read()
		
		if "CoreLibs" in data:
			print("WARNING: CoreLibs import found in", filename)
			CoreLibs_warning = True
				
		# search for standard playdate SDK commands and replace with minigame commands
		for PD_function in function_dictionary:
			data = data.replace(PD_function, function_dictionary[PD_function])

		# search for functions that import sometihg from a path and replace with minigame path
		for PD_path in path_dictionary:
			data = data.replace(PD_path, path_dictionary[PD_path])
	
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

if CoreLibs_warning:
	print("  If these CoreLibs libraries are imported in Mobware Minigames main.lua then they can simply be removed here.")
	print("  Otherwise this will require special handling.")


# rename main.lua to the name of the minigame
try:
	os.replace(output_directory + '/main.lua', output_directory + '/' + minigame_name + '.lua')
except:
	print("ERROR: could not find main.lua")


print('Minigames files written to', output_directory)
print('<script completed>\n')
