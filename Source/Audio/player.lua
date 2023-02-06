import 'Audio/sample_buffer'

class('Player').extends()

function Player:init(sampleBuffer)
	Player.super.init(self)
	
	self.sampleBuffer = sampleBuffer
	self.samplePlayer = playdate.sound.sampleplayer.new(self.sampleBuffer:getBuffer())
	self.playbackRate = 1.0
	self.loopStartSet = false
	self.loopStart = -1
	self.loopStartX = -1
	self.loopStartFrame = -1
	self.loopEndSet = false
	self.loopEnd = -1
	self.loopEndX = -1
	self.loopEndFrame = -1
end

function reset(sampleBuffer)
	self.sampleBuffer = sampleBuffer
	self.loopStartSet = false
	self.loopEndSet = false
end
