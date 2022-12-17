
-- helper class for loading game data from a Tiled JSON file


-- loads the json file and returns a lua table containing the data
local function getJSONTableFromTiledFile(path)
	
	local levelData = nil
	
	local f = playdate.file.open(path)
	if f then
		local s = playdate.file.getSize(path)
		levelData = f:read(s)
		f:close()
		
		if not levelData then
			print('ERROR LOADING DATA for ' .. path)
			return nil
		end
	end

	local jsonTable = json.decode(levelData)
	
	if not jsonTable then
		print('ERROR PARSING JSON DATA for ' .. levelPath)
		return nil
	end
	
	return jsonTable
	
end

-- returns an array containing the tilesets from the json file
local function getTilesetsFromJSON(jsonTable)
	
	local tilesets = {}
		
	for i=1, #jsonTable.tilesets do
		
		local tileset = jsonTable.tilesets[i]
		local newTileset = {}
		
		newTileset.firstgid = tileset.firstgid
		newTileset.lastgid = tileset.firstgid + tileset.tilecount - 1
		newTileset.name = tileset.name
		newTileset.tileHeight = tileset.tileheight
		newTileset.tileWidth = tileset.tilewidth
		local tilesetImageName = string.sub(tileset.image, 1, string.find(tileset.image, '-table-') - 1)
		newTileset.imageTable = playdate.graphics.imagetable.new(tilesetImageName)

		tilesets[i] = newTileset
		
	end
	
	return tilesets
end


-- utility function for importTilemapsFromTiledJSON()
local function tilesetWithName(tilesets, name)
	for _, tileset in pairs(tilesets) do
	
		if tileset.name == name then
			return tileset
		end
	end
	
	return nil
	
end


local function tilesetNameForProperies(properties)
	for key, property in ipairs(properties) do
		if property.name == 'tileset' then
			return property.value
		end
	end
	return nil
end


-- loads the data we are interested in from the Tiled json file
-- returns custom layer tables containing the data, which are basically a subset of the layer objects found in the Tiled file
function importTilemapsFromTiledJSON(path)
	
	local jsonTable = getJSONTableFromTiledFile(path)
	
	if jsonTable == nil then
		return
	end
	
	
	-- load tilesets
	local tilesets = getTilesetsFromJSON(jsonTable)	
	
	
	-- create tilemaps from the level data and already-loaded tilesets
	
	local layers = {}
	
	for i=1, #jsonTable.layers do

		local level = {}
		
		local layer = jsonTable.layers[i]
		
		level.name = layer.name
		level.x = layer.x
		level.y = layer.y
		level.tileHeight = layer.height
		level.tileWidth = layer.width
				
		local tileset = nil
		local tilesetName = tilesetNameForProperies(layer.properties)
		if tilesetName ~= nil then
			tileset = tilesetWithName(tilesets, tilesetName)
		end
		
		if tileset ~= nil then
		
			level.pixelHeight = level.tileHeight * tileset.tileHeight
			level.pixelWidth = level.tileWidth * tileset.tileWidth
		
			local tilemap = playdate.graphics.tilemap.new()
			tilemap:setImageTable(tileset.imageTable)
			tilemap:setSize(level.tileWidth, level.tileHeight)
						
			-- we want our indexes for each tileset to be 1-based, so remove the offset that Tiled adds.
			-- this is only makes sense because because we have exactly one tilemap image per layer
			local indexModifier = tileset.firstgid-1		
			
			local tileData = layer.data
			
			local x = 1
			local y = 1
			
			for j=1, #tileData do
				
				local tileIndex = tileData[j]
				
				if tileIndex > 0 then
					tileIndex = tileIndex - indexModifier
					tilemap:setTileAtPosition(x, y, tileIndex)	
				end
				
				x = x + 1
				if ( x > level.tileWidth-1 ) then
					x = 0
					y = y + 1
				end
			end
			
			level.tilemap = tilemap
			layers[layer.name] = level
			
		end
	end
		
	return layers
	
end