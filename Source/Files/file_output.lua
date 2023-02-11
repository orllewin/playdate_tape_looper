import 'Coracle/string_utils'

class('FileOuput').extends()

function FileOuput:init()
	FileOuput.super.init(self)
end

function FileOuput:exportAudioBothFormats(buffer)
	local filename = self:generateFilenameNoSuffix()
	buffer:save(filename .. ".wav")
	buffer:save(filename .. ".pda")
	return filename
end

function FileOuput:exportAudioWav(buffer)
	local filename = self:generateFilename(".wav")
	buffer:save(filename)
	return filename
end

function FileOuput:exportAudioPda(buffer)
	local filename = self:generateFilename(".pda")
	buffer:save(filename)
	return filename
end

function FileOuput:generateFilename(suffix)
	return generateFilenameNoSuffix() .. suffix
end

function FileOuput:generateFilenameNoSuffix()
	local now = playdate.getTime()
	local filename = "" .. now["year"] .. "-" .. leftPad(now["month"]) .. "-" .. leftPad(now["day"]) .. "-" .. leftPad(now["hour"]) .. "" .. leftPad(now["minute"]) .. "" .. leftPad(now["second"])
	return filename
end

