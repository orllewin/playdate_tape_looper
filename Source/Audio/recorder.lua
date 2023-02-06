import 'Coracle/math'
import 'Coracle/string_utils'
import 'Audio/sample_buffer'

class('Recorder').extends()

function Recorder:init(recordingListener)
	Recorder.super.init(self)
	self.recordingListener = recordingListener
	self.levelsListener = nil
	self.listening = false
	self.recording = false
	self.isListening = false
	self.audLevel = 0.5
	self.audAverage = 0.0
	self.audFrame = 0
	self.audScale = 0
	self.audMax = 0
end

function Recorder:startListening(levelsListener)
	self.levelsListener = levelsListener
	playdate.sound.micinput.startListening()
	self.listening = true
end

function Recorder:stopListening()
	playdate.sound.micinput.stopListening()
	self.listening = false
end

function Recorder:startRecording(buffer)
	assert(self.listening, "You need to start listening before you can record")
	self.buffer = buffer
	
	self.recording = true
	
	playdate.sound.micinput.recordToSample(buffer, function(sample)
		print("Recording complete...")
		self.recording = false
		if self.recordingListener ~= nil then self.recordingListener(false, 0) end
	end)
end

function Recorder:getBuffer()
	return self.buffer
end

function Recorder:push() playdate.inputHandlers.push(self:getInputHandler()) end
function Recorder:pop() playdate.inputHandlers.pop() end

function Recorder:stopRecording()
	playdate.sound.micinput.stopRecording()
	self.recording = false
end

function Recorder:isRecording()
	return self.recording
end

function Recorder:isNotRecording()
	return self.recording ~= true
end

function Recorder:update()
	if(self:isNotRecording()) then return end
	self.audLevel = playdate.sound.micinput.getLevel()
	if(self.audLevel > self.audMax) then self.audMax = self.audLevel end
	self.audFrame += 1
	self.audMax = math.max(self.audMax-(self.audMax/250), 0.0)
	
	self.audAverage = self.audAverage * (self.audFrame -1)/self.audFrame + self.audLevel / self.audFrame
		
	if self.levelsListener ~= nil then 
		self.levelsListener(self.audLevel, self.audMax, self.audAverage)
	end
	
	if self.recordingListener ~= nil then
		if self.recording then
			local recorded, max = self.buffer:getLength()
			self.recordingListener(true, recorded)
		else
			self.recordingListener(false, 0)
		end
	end
end

function Recorder:getInputHandler()
	return {
		BButtonDown = function()
			if(self.recording)then
				self:stopRecording()
			else
				if(self.onStartRecording ~= nil)then self.onStartRecording() end
			end
			
		end
	}
end

