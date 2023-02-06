import 'Coracle/string_utils'

class('FileOuput').extends()

function FileOuput:init()
	FileOuput.super.init(self)
end

function FileOuput:exportAudioBothFormats(buffer)
	local filename = self:generateFilenameNoSuffix()
	buffer:save(filename .. ".wav")
	buffer:save(filename .. ".pdi")
	return filename
end

function FileOuput:exportAudioWav(buffer)
	local filename = self:generateFilename(".wav")
	buffer:save(filename)
	return filename
end

function FileOuput:exportAudioPdi(buffer)
	local filename = self:generateFilename(".pdi")
	buffer:save(filename)
	return filename
end

function Recorder:generateFilename(suffix)
	return generateFilenameNoSuffix() .. suffix
end

function Recorder:generateFilenameNoSuffix()
	local now = playdate.getTime()
	local filename = "" .. now["year"] .. "-" .. leftPad(now["month"]) .. "-" .. leftPad(now["day"]) .. "-" .. leftPad(now["hour"]) .. ":" .. leftPad(now["minute"]) .. ":" .. leftPad(now["second"])
	return filename
end

