
local snd = playdate.sound

SoundManager = {}

SoundManager.kSoundBreakBlock = 'breakblock'
SoundManager.kSoundBump= 'bump'
SoundManager.kSoundCoin = 'coin'
SoundManager.kSoundJump = 'jump'
SoundManager.kSoundStomp = 'stomp'
SoundManager.kSoundHurt = 'moai_hurt'
SoundManager.kSoundLevelClear = 'level_clear'

local sounds = {}

--local filePlayer = snd.fileplayer.new('Minigames/super_moairio/sfx/easter_island_boogie')
--local backgroundMusic = snd.fileplayer.new('Minigames/super_moairio/sfx/super_moairio_theme')
local backgroundMusic = snd.fileplayer.new('Minigames/super_moairio/sfx/giga_moyai_rave')

for _, v in pairs(SoundManager) do
	sounds[v] = snd.sampleplayer.new('Minigames/super_moairio/sfx/' .. v)
end

SoundManager.sounds = sounds

function SoundManager:playSound(name)
	self.sounds[name]:play(1)		
end


function SoundManager:stopSound(name)
	self.sounds[name]:stop()
end

function SoundManager:playBackgroundMusic()
	backgroundMusic:setRate(1)
	backgroundMusic:play(0) -- repeat forever
end

function SoundManager:speedUpBackgroundMusic()
	backgroundMusic:setRate(1.5) -- repeat forever
end

function SoundManager:stopMusic()
	-- kill any sounds still playing
	local sounds = playdate.sound.playingSources()
	for _i, sound in ipairs(sounds) do
		sound:stop() 
	end	
end