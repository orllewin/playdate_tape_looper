import 'Coracle/coracle'
import("CoreLibs/graphics")
import("CoreLibs/easing")
import("CoreLibs/timer")

import "CoreLibs/sprites"


local INTRO, TAPE_LOADING, STOPPED, RECORDING, PLAYING, PAUSED = 0, 1, 2, 3, 4, 5, 6
local state = INTRO

function startTapeLoading()
	print("startTapeLoading()")
	state = TAPE_LOADING
	playdate.graphics.setDrawOffset(0, 0)
end

playdate.timer.performAfterDelay(1425, startTapeLoading)

function introFinished()
	print("introFinished()")
	state = STOPPED
end

local introFilePlayer = playdate.sound.fileplayer.new("intro_tape_action")
introFilePlayer:setFinishCallback(introFinished)
introFilePlayer:play()

local introDrawOffset = -30


local tapeImage = playdate.graphics.image.new("tape")
local spindleImage = playdate.graphics.image.new("spindle")
local spindleSpriteLeft = playdate.graphics.sprite.new(spindleImage)
local spindleSpriteRight = playdate.graphics.sprite.new(spindleImage)

spindleSpriteLeft:moveTo(116, 102)
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

local playbackRate = 1.0
local loopStartSet = false
local loopStart = -1
local loopStartX = -1
local loopStartFrame = -1
local loopEndSet = false
local loopEnd = -1
local loopEndX = -1
local loopEndFrame = -1


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
			
			loopStartSet = false
			loopEndtSet = false
			recordFrame = 0
			audMax = 0
			
			playdate.sound.micinput.startListening()
			playdate.sound.micinput.recordToSample(buffer, onComplete)
			
		end
	end
	
	local change = crankChange()
	if(change > 0) then
		playbackRate += 0.05
		samplePlayer:setRate(playbackRate)
	elseif (change < 0) then
		playbackRate -= 0.05
		samplePlayer:setRate(playbackRate)
	end

	if state == PLAYING then
		spindleAngle += (playbackRate * 2) 
		
		if(spindleAngle > 358) then spindleAngle = 0 end
		
		spindleSpriteLeft:setRotation(spindleAngle)
		spindleSpriteRight:setRotation(spindleAngle)
		
		if(leftJustPressed())then
			if(loopStartSet)then
				if(loopEndSet) then
					samplePlayer:setPlayRange(0, loopEndFrame)
				else 
					local sampleRate = playdate.sound.getSampleRate()
					local frames = samplePlayer:getLength() * sampleRate
					samplePlayer:setPlayRange(0, frames)
				end
				loopStartSet = false
			else
				loopStart = samplePlayer:getOffset()
				loopStartX = map(loopStart, 0, samplePlayer:getLength(), 60, 340)
				loopStartFrame = loopStart * playdate.sound.getSampleRate()
				if(loopEndSet) then
					samplePlayer:setPlayRange(loopStartFrame, loopEndFrame)
				else 
					local sampleRate = playdate.sound.getSampleRate()
					local frames = samplePlayer:getLength() * sampleRate
					samplePlayer:setPlayRange(loopStartFrame, frames)
				end
				loopStartSet = true
			end
		end
		
		if(rightJustPressed())then
			if(loopEndSet)then
				local sampleRate = playdate.sound.getSampleRate()
				local frames = samplePlayer:getLength() * sampleRate
				if(loopStartSet)then
					samplePlayer:setPlayRange(loopStartFrame, frames)
				else
					samplePlayer:setPlayRange(0, frames)
				end
				loopEndSet = false
			else
				loopEnd = samplePlayer:getOffset()
				loopEndX = map(loopEnd, 0, samplePlayer:getLength(), 60, 340)
				loopEndFrame = loopEnd * playdate.sound.getSampleRate()
				if(loopStartSet)then
					samplePlayer:setPlayRange(loopStartFrame, loopEndFrame)
				else
					samplePlayer:setPlayRange(0, loopEndFrame)
				end
				
				loopEndSet = true
			end

		end

	end
	
	if state == RECORDING then 		
		spindleAngle += 2
		
		if(spindleAngle > 358) then spindleAngle = 0 end
		
		spindleSpriteLeft:setRotation(spindleAngle)
		spindleSpriteRight:setRotation(spindleAngle)
	end
	

	if state == TAPE_LOADING then
		spindleAngle -= 12
		
		if(spindleAngle > 358) then spindleAngle = 0 end
		
		spindleSpriteLeft:setRotation(spindleAngle)
		spindleSpriteRight:setRotation(spindleAngle)
	end

	playdate.graphics.sprite.update()
	
	-- POST SPRITE DRAWING --------------------------------------------------------
	
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
		rect(60, 15, min(280, map(audAverage, 0.0, audMax, 1, 280)), 20)
		
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
		
		
		
		if(loopStartSet)then
			fill(0.25)
			rect(loopStartX, 15, (playbackHeadX - loopStartX), 40)
			
			fill(1)
			line(loopStartX, 15, loopStartX, 55)
			triangle(loopStartX, 29, loopStartX, 41, loopStartX + 7, 35)
		else
			fill(0.25)
			rect(60, 15, (playbackHeadX - 60), 40)
		end
		
		if(loopEndSet)then
			fill(1)
			line(loopEndX, 15, loopEndX, 55)
			triangle(loopEndX, 30, loopEndX, 40, loopEndX - 5, 35)
			
		end
	end
	
	if(state == INTRO) then
		playdate.graphics.setDrawOffset(0, introDrawOffset)
		fill(0.8)
		rect(0, 0, 400, 350)
		tapeImage:draw( 0, introDrawOffset )
		introDrawOffset += 0.7
	end
	
	playdate.timer.updateTimers()
end