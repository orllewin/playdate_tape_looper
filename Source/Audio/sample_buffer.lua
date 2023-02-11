class('SampleBuffer').extends()

local Seconds16bitStereo = 45
local Seconds16bitMono = 90
local Seconds8bitMono = 180
local Seconds8bitStereo = 90

function SampleBuffer:init(format, errorListener)
	Recorder.super.init(self)
	
	self.format = format
	self:initialiseBuffer(format)
	self.errorListener = errorListener
end

function SampleBuffer:load(file)
	local buffer, error = playdate.sound.sample.new(file)
	
	if(buffer ~= nil)then
		self.buffer = buffer
	elseif(error ~= nil)then
		print("Error loading buffer from file: " .. file .. ": " .. error)
		if(self.errorListener ~= nil)then self.errorListener(error) end
	end
end

function SampleBuffer:initialiseBuffer(format)
	self.format = format
	if format == playdate.sound.kFormat16bitStereo then
		self.buffer = playdate.sound.sample.new(Seconds16bitStereo, format)
	elseif format == playdate.sound.kFormat16bitMono then
		self.buffer = playdate.sound.sample.new(Seconds16bitMono, format)
	elseif format == playdate.sound.kFormat8bitMono then
		self.buffer = playdate.sound.sample.new(Seconds8bitMono, format)
	elseif format == playdate.sound.kFormat8bitStereo then
		self.buffer = playdate.sound.sample.new(Seconds8bitStereo, format)
	end
end

function SampleBuffer:changeFormatFromLabel(label)
	if label == "8bit mono" then
		self:changeFormat(playdate.sound.kFormat8bitMono)
	elseif label == "8bit stereo" then
		self:changeFormat(playdate.sound.kFormat8bitStereo)
	elseif label == "16bit mono" then
		self:changeFormat(playdate.sound.kFormat16bitMono)
	elseif label ==  "16bit stereo" then
		self:changeFormat(playdate.sound.kFormat16bitStereo)	
	end
end

function SampleBuffer:getFormatLabel()
	if self.format == playdate.sound.kFormat16bitMono then
		return "16bit mono" 
	elseif self.format == playdate.sound.kFormat16bitStereo then
		return "16bit stereo" 
	elseif self.format == playdate.sound.kFormat8bitMono then
		return "8bit mono" 
	elseif self.format == playdate.sound.kFormat8bitStereo then
		return "8bit stereo"
	else
		return "" .. self.format
	end
end

function SampleBuffer:generateTimestampFilename()
	local now = playdate.getTime()
	local filename = "" .. now["year"] .. "-" .. leftPad(now["month"]) .. "-" .. leftPad(now["day"]) .. "-" .. leftPad(now["hour"]) .. ":" .. leftPad(now["minute"]) .. ":" .. leftPad(now["second"])
	return filename
end

function SampleBuffer:getBuffer()
	return self.buffer
end

function SampleBuffer:saveWav(filname)
	self.buffer:save(filname .. ".wav")
end

function SampleBuffer:savePda(filname)
	self.buffer:save(filname .. ".pda")
end