import 'Audio/sample_buffer'

class('Player').extends()

function Player:init(playbackListener, uiToggleListener)
	Player.super.init(self)
	
	self.playbackListener = playbackListener
	self.uiToggleListener = uiToggleListener
	
	self.samplePlayer = nil
	
	self.loopStartSet = false
	self.loopStart = -1
	self.loopStartX = -1
	self.loopStartFrame = -1
	
	self.loopEndSet = false
	self.loopEnd = -1
	self.loopEndX = -1
	self.loopEndFrame = -1
end

function Player:push() playdate.inputHandlers.push(self:getInputHandler()) end
function Player:pop() playdate.inputHandlers.pop() end

function Player:hasLoopStart()
	return self.loopStartSet
end

function Player:hasLoopEnd()
	return self.loopEndSet
end

function Player:hasLoop()
	if self:hasLoopStart() or player:hasLoopEnd() then
		return true
	else
		return false
	end
end

function Player:getBuffer()
	return self.samplePlayer:getSample()
end

function Player:getLoopBuffer()
	if self:hasLoopStart() and self:hasLoopEnd() then
		-- Full loop
		return self.samplePlayer:getSample():getSubsample(self.loopStartFrame, self.loopEndFrame)
	elseif self:hasLoopStart() then
		-- Loop start only
		local sampleRate = playdate.sound.getSampleRate()
		local frames = samplePlayer:getLength() * sampleRate
		return self.samplePlayer:getSample():getSubsample(self.loopStartFrame, frames)
	else
		-- Loop end only
		return self.samplePlayer:getSample():getSubsample(0, self.loopEndFrame)
	end
end

function Player:reset(buffer)
	self.samplePlayer = playdate.sound.sampleplayer.new(buffer)
	self.loopStartSet = false
	self.loopEndSet = false
end

function Player:softReset()
	self.samplePlayer:setRate(1.0)
	self.loopStartSet = false
	self.loopEndSet = false
end

function Player:isEmpty()
	if self.samplePlayer:getLength() == 0 then
		return true
	else
		return false
	end
end

function Player:play()
	self.samplePlayer:play(0)
	self.samplePlayer:setVolume(1.0)
end

function Player:play2()
	self:playFromCuePoint()
	self:setLoopPoints()
	self.samplePlayer:setVolume(1.0)
end

function Player:stop()
	print("Stopping sample player")
	self.samplePlayer:stop()
end

function Player:setVolume(volume)
	self.samplePlayer:setVolume(volume)
end

function Player:getLength()
	return self.samplePlayer:getLength()
end

function Player:setRate(playbackRate)
	self.samplePlayer:setRate(playbackRate)
end

function Player:getPlaybackRate()
	return self.samplePlayer:getRate()
end

function Player:incPlaybackRate(amount)
	self.samplePlayer:setRate(self:getPlaybackRate() + amount)
end

function Player:decPlaybackRate(amount)
	self.samplePlayer:setRate(self:getPlaybackRate() - amount)
end

function Player:resetPlaybackRate()
	self.samplePlayer:setRate(1.0)
end

function Player:getOffset()
	return self.samplePlayer:getOffset()
end

function Player:isPlaying()
	if(self.samplePlayer)then
		return self.samplePlayer:isPlaying()
	else
		return false
	end
	
end

xAnchor = 10
yAnchor = 10
tapeHeight = 55
tapeWidth = 260

function Player:draw()

	
	if(not self:isPlaying())then return end
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	fill(0.5)
	playdate.graphics.drawRect(xAnchor, yAnchor, tapeWidth, tapeHeight)
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	
	local sampleLength = self:getLength()
	local playbackElapsed = self:getOffset()
	local playbackHeadX = map(playbackElapsed, 0, sampleLength, xAnchor, tapeWidth + xAnchor)
	local caretHeight = 7
	local caretWidth = 7
	
	--draw main progress
	if(self:hasLoopStart())then
		fill(0.25)
		rect(self.loopStartX, yAnchor, (playbackHeadX - self.loopStartX), tapeHeight)
	else
		fill(0.25)
		rect(xAnchor, yAnchor, (playbackHeadX - xAnchor), tapeHeight)
	end

	--draw loop indicators
	if(self:hasLoopStart())then		
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		line(self.loopStartX, yAnchor, self.loopStartX, yAnchor + tapeHeight)
		triangle(self.loopStartX, yAnchor + (tapeHeight/2 - caretHeight/2), self.loopStartX, yAnchor + (tapeHeight/2 + caretHeight/2), self.loopStartX + caretWidth, yAnchor + (tapeHeight/2))
	end
	
	if(self:hasLoopEnd())then
		playdate.graphics.setColor(playdate.graphics.kColorWhite)
		line(self.loopEndX, yAnchor, self.loopEndX, yAnchor + tapeHeight)
		triangle(self.loopEndX, yAnchor + (tapeHeight/2 - caretHeight/2), self.loopEndX, yAnchor + (tapeHeight/2 + caretHeight/2), self.loopEndX - caretWidth, yAnchor + (tapeHeight/2))
	end
end

function Player:playFromCuePoint()
	if self:hasLoopStart() then
		print("playFromCuePoint() with offset")
		self.samplePlayer:play(0)
		self.samplePlayer:setOffset(self.loopStart)
	else
		print("playFromCuePoint() play(0)")
		self.samplePlayer:play(0)
	end
end

function Player:setLoopPoints()
	if(not self:hasLoopStart() and not self:hasLoopEnd()) then
		--Neither
		local sampleRate = playdate.sound.getSampleRate()
		local frames = self.samplePlayer:getLength() * sampleRate
		self.samplePlayer:setPlayRange(0, frames)
	elseif (self:hasLoopStart() and self:hasLoopEnd()) then
		--Both
		self.samplePlayer:setPlayRange(self.loopStartFrame, self.loopEndFrame)
	elseif (self:hasLoopStart()) then
		--Start set only
		local sampleRate = playdate.sound.getSampleRate()
		local frames = self.samplePlayer:getLength() * sampleRate
		self.samplePlayer:setPlayRange(self.loopStartFrame, frames)
	elseif(self:hasLoopEnd()) then
		--End set only
		self.samplePlayer:setPlayRange(0, self.loopEndFrame)
	end
end

-- xAnchor = 10
-- yAnchor = 10
-- tapeHeight = 55
-- tapeWidth = 260

function Player:getInputHandler()
	return {
		leftButtonDown = function()
			print("Player set/unset loop start")
			if(self.loopStartSet)then
				if(self.loopEndSet) then
					self.samplePlayer:setPlayRange(0, self.loopEndFrame)
				else 
					local sampleRate = playdate.sound.getSampleRate()
					local frames = self.samplePlayer:getLength() * sampleRate
					self.samplePlayer:setPlayRange(0, frames)
				end
				self.loopStartSet = false
			else
				self.loopStart = self.samplePlayer:getOffset()
				self.loopStartX = map(self.loopStart, 0, self.samplePlayer:getLength(), xAnchor, xAnchor + tapeWidth)
				self.loopStartFrame = math.floor(self.loopStart * playdate.sound.getSampleRate())
				if(self.loopEndSet) then
					self.samplePlayer:setPlayRange(self.loopStartFrame, self.loopEndFrame)
				else 
					local sampleRate = playdate.sound.getSampleRate()
					local frames = self.samplePlayer:getLength() * sampleRate
					self.samplePlayer:setPlayRange(self.loopStartFrame, frames)
				end
				self.loopStartSet = true
			end
		end,
		rightButtonDown = function()
			print("Player set/unset loop start")
			if(self.loopEndSet)then
				local sampleRate = playdate.sound.getSampleRate()
				local frames = self.samplePlayer:getLength() * sampleRate
				if(self.loopStartSet)then
					self.samplePlayer:setPlayRange(self.loopStartFrame, frames)
				else
					self.samplePlayer:setPlayRange(0, frames)
				end
				self.loopEndSet = false
			else
				self.loopEnd = self.samplePlayer:getOffset()
				self.loopEndX = map(self.loopEnd, 0, self.samplePlayer:getLength(), xAnchor, xAnchor + tapeWidth)
				self.loopEndFrame = math.floor(self.loopEnd * playdate.sound.getSampleRate())
				if(self.loopStartSet)then
					self.samplePlayer:setPlayRange(self.loopStartFrame, self.loopEndFrame)
				else
					self.samplePlayer:setPlayRange(0, self.loopEndFrame)
				end
				
				self.loopEndSet = true
			end
		end,
		upButtonDown = function()
			self:stop()
			self:playFromCuePoint()
			self:setLoopPoints()
			self.playing = true
		end,
		downButtonDown = function()
			self:resetPlaybackRate()
		end,
		BButtonDown = function()
			if self.uiToggleListener then self.uiToggleListener() end
		end,
		AButtonUp = function()
			if(self:isPlaying())then
				self:stop()
				self.playbackListener(false)
			else
				self:play()
				self.playbackListener(true)
			end
		end,
		AButtonHeld = function()
			if(self:isPlaying())then
				self:windDownAndStop()
			end
		end
	}
end

function Player:windDownAndStop()
	local windDownTimer = playdate.timer.new(1000, self.samplePlayer:getRate(), 0, playdate.easingFunctions.easeInCirc)
	windDownTimer.timerEndedCallback = function()
		self:softReset()
		self:stop()
	end
	windDownTimer.updateCallback = function(timer)
		self:setRate(timer.value)
		self.samplePlayer:setVolume(timer.value)
	end

end


