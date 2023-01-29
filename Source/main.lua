import 'Coracle/coracle'
import("CoreLibs/graphics")
import("CoreLibs/easing")

import "CoreLibs/sprites"

local tapeImage = playdate.graphics.image.new("tape")
local spindleImage = playdate.graphics.image.new("spindle")
local spindleSpriteLeft = playdate.graphics.sprite.new(spindleImage)
local spindleSpriteRight = playdate.graphics.sprite.new(spindleImage)

spindleSpriteLeft:moveTo(115, 102)
spindleSpriteLeft:add()

spindleSpriteRight:moveTo(284, 102)
spindleSpriteRight:add()

playdate.graphics.sprite.setBackgroundDrawingCallback(
		function( x, y, width, height )
				playdate.graphics.setClipRect( x, y, width, height ) 
				tapeImage:draw( 0, 0 )
				playdate.graphics.clearClipRect()
		end
)


local buffer = playdate.sound.sample.new(120, playdate.sound.kFormat16bitMono)
local samplePlayer = playdate.sound.sampleplayer.new(buffer)

local STOPPED, RECORDING, PLAYING, PAUSED = 0, 1 , 2, 3
local state = STOPPED


local playbackRate = 1.0

local gain = 1.0
local effect = playdate.sound.overdrive.new()
effect:setMix(1)
effect:setGain(5)
playdate.sound.addEffect(effect)

playdate.sound.getHeadphoneState(function() 
	if playdate.isSimulator then
		playdate.sound.setOutputsActive(true, true)
	else
		playdate.sound.setOutputsActive(false, true)
	end
end)

local recordFrame = 0
local spindleAngle = 0

audLevel = 0.5
audAverage = 0.5
audFrame = 0
audScale = 0
audMax = 0

function onComplete(sample)
	playdate.sound.micinput.stopListening()
	state = PAUSED
end

function playdate.update()
	if aPressed() then
		if(state == RECORDING)then return end
		if samplePlayer:isPlaying() then
			samplePlayer:stop()
			state = PAUSED
		else
			samplePlayer:play(0)
			state = PLAYING
		end
		
	end

	if bPressed() then
		if state == RECORDING then
			playdate.sound.micinput.stopListening()
			playdate.sound.micinput.stopRecording()
			state = PAUSED
		else
			
			if samplePlayer:isPlaying() then
				playbackRate = 1
				samplePlayer:setRate(playbackRate)
				samplePlayer:stop()
			end
			
			state = RECORDING
			
			recordFrame = 0
			audMax = 0
			
			playdate.sound.micinput.startListening()
			playdate.sound.micinput.recordToSample(buffer, onComplete)
			
		end
	end
	
	local change = crankChange()
	if(change > 0) then
		playbackRate += 0.1
		samplePlayer:setRate(playbackRate)
	elseif (change < 0) then
		playbackRate -= 0.1
		samplePlayer:setRate(playbackRate)
	end

	if state == PLAYING then
		spindleAngle += (playbackRate * 2) 
		
		if(spindleAngle > 358) then spindleAngle = 0 end
		
		spindleSpriteLeft:setRotation(spindleAngle)
		spindleSpriteRight:setRotation(spindleAngle)

	end
	
	if state == RECORDING then 		
		spindleAngle += 2
		
		if(spindleAngle > 358) then spindleAngle = 0 end
		
		spindleSpriteLeft:setRotation(spindleAngle)
		spindleSpriteRight:setRotation(spindleAngle)
	end

	playdate.graphics.sprite.update()
	
	fill(1)
	stroke()
	playdate.graphics.drawRoundRect(60, 15, 280, 40, 5)
	
	if state == RECORDING then 
		audLevel = playdate.sound.micinput.getLevel()
		if(audLevel > audMax) then audMax = audLevel end
		audFrame = audFrame + 1
		
		audAverage = audAverage * (audFrame - 1)/audFrame + audLevel / audFrame
		
		--Session level bar
	
		fill(0.5)
		rect(60, 15, map(audLevel, 0.0, audMax, 1, 280), 20)
		
		fill(1)
		rect(60, 15, map(audAverage, 0.0, audMax, 1, 280), 20)
		
		--Max level bar		
		fill(0.5)
		rect(60, 35, map(audLevel, 0.0, 1.0, 1, 280), 20)
		
		fill(1)
		rect(60, 35, map(audAverage, 0.0, 1.0, 1, 280), 20)
		
	end
	
	if(state == PLAYING)then
		--playback head
		local sampleLength = samplePlayer:getLength()
		local playbackElapsed = samplePlayer:getOffset()
		local playbackHeadX = map(playbackElapsed, 0, sampleLength, 60, 340)
		
		fill(0.25)
		rect(60, 15, (playbackHeadX - 60), 40)
	end
end