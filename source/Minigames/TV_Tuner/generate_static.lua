function generate_static(noise_frequency)
	local gfx <const> = playdate.graphics
	local static_image = gfx.image.new(TV_WIDTH * 2, TV_HEIGHT * 2)

	gfx.lockFocus(static_image)
    for y = 0, TV_HEIGHT * 2, noise_frequency do 
        for x = 0, TV_WIDTH * 2, noise_frequency do    
            local random_x = x + math.random(-noise_frequency, noise_frequency) 
            local random_y = y + math.random(-noise_frequency, noise_frequency)
            if math.random() > 0.5 then gfx.drawPixel(random_x, random_y) end --50% chance this pixel will be black  
        end
    end
	gfx.unlockFocus()
	
	return static_image
end
