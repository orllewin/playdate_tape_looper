import 'Coracle/coracle'
import 'Coracle/string_utils'
import 'CoreLibs/graphics'
import 'CoreLibs/easing'
import 'CoreLibs/timer'
import 'CoreLibs/keyboard'
import 'CoreLibs/sprites'
import 'CoreLibs/ui'
import 'CoreLibs/nineslice'
import 'Audio/sample_buffer'
import 'Audio/recorder'
import 'Audio/player'
import 'Files/file_browser'

local sampleBuffer = SampleBuffer(playdate.sound.kFormat16bitMono, nil)
local recorder = Recorder(sampleBuffer)
local player = Player(sampleBuffer)
local fileBrowser = AudioFileBrowser()

local font = playdate.graphics.font.new("Fonts/font-rains-1x")
local biggerFont = playdate.graphics.font.new("Fonts/Roobert-11-Medium")

local INTRO, TAPE_LOADING, STOPPED, RECORDING, PLAYING, PAUSED, LOAD_SAMPLE = 0, 1, 2, 3, 4, 5, 6, 7
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
	toast("Ready")
end

local introFilePlayer = playdate.sound.fileplayer.new("Audio/intro_tape_action")
introFilePlayer:setFinishCallback(introFinished)
introFilePlayer:play()

local introDrawOffset = -30
local playbackRate = 1.0
local loopStartSet = false
local loopStart = -1
local loopStartX = -1
local loopStartFrame = -1
local loopEndSet = false
local loopEnd = -1
local loopEndX = -1
local loopEndFrame = -1
local toastMessage = ""
local showToast = false
local toastTimer = nil
local toastYAnchor = 138

local loadTapeImage = playdate.graphics.image.new("Images/load_tape")
local tapeImage = playdate.graphics.image.new("Images/tape")
local spindleImage = playdate.graphics.image.new("Images/spindle")
local spindleSpriteLeft = playdate.graphics.sprite.new(spindleImage)
local spindleSpriteRight = playdate.graphics.sprite.new(spindleImage)

spindleSpriteLeft:moveTo(116, 102)
spindleSpriteLeft:add()

spindleSpriteRight:moveTo(284, 102)
spindleSpriteRight:add()

playdate.graphics.sprite.setBackgroundDrawingCallback(
		function(x, y, width, height)
				playdate.graphics.setClipRect( x, y, width, height ) 
				tapeImage:draw( 0, 0 )
				playdate.graphics.clearClipRect()
		end
)

local buffer = playdate.sound.sample.new(120, playdate.sound.kFormat16bitMono)
local samplePlayer = playdate.sound.sampleplayer.new(buffer)

local menu = playdate.getSystemMenu()

-- Add save sample menu
local menuItem, error = menu:addMenuItem("Save Sample", function()
		if buffer:getLength() == 0 then
			toast("Empty buffer")
		else
			local pdaFilename = generateFilename("tr-", ".pda")
			local wavFilename = replace(pdaFilename, ".pda", ".wav")
			buffer:save(pdaFilename)
			buffer:save(wavFilename)
			toast(replace(pdaFilename, ".pda", ""))
		end
end)

-- Add save loop sample
local menuItem, error = menu:addMenuItem("Save Loop", function()
		if loopStartSet or loopEndSet then
			
			local pdaFilename = generateFilename("tl-", ".pda")
			local wavFilename = replace(pdaFilename, ".pda", ".wav")
			
			if loopStartSet and loopEndSet then
				-- Full loop
				local loop = buffer:getSubsample(loopStartFrame, loopEndFrame)
				loop:save(pdaFilename)	
				loop:save(wavFilename)	
			elseif loopStartSet then
				-- Loop start only
				local sampleRate = playdate.sound.getSampleRate()
				local frames = samplePlayer:getLength() * sampleRate
				local loop = buffer:getSubsample(loopStartFrame, frames)
				loop:save(pdaFilename)	
				loop:save(wavFilename)
			else
				-- Loop end only
				local loop = buffer:getSubsample(0, loopEndFrame)
				loop:save(pdaFilename)	
				loop:save(wavFilename)
			end
			
			toast(replace(pdaFilename, ".pda", ""))
		else
			toast("No loop set")
		end
end)

-- Add load sample
local menuItem, error = menu:addMenuItem("Load sample", function()
		state = STOPPED
		fileBrowser:chooseFile(function(_selectedFile)
			selectedFile = _selectedFile
			print("File browser selected file: " .. selectedFile)
		end)
		state = LOAD_SAMPLE
end)

local spindleAngle = 0

local audLevel = 0.5
local audAverage = 0.5
local audFrame = 0
local audScale = 0
local audMax = 0

function onComplete(sample)
	playdate.sound.micinput.stopListening()
	state = PAUSED
end

function playdate.update()
	if aPressed() then
		if state == RECORDING then return end
		if state == LOAD_SAMPLE then
			loopStartSet = false
			loopEndSet = false
			if selectedFile == nil then
				state = STOPPED
				toast("File source error")
				return
			end
			print("loading sample: " .. selectedFile)

			if playdate.file.exists(selectedFile) then
				print("File exists: " .. selectedFile)
				--buffer:load(selectedFile)
				--local newBuffer, error = playdate.sound.sample.new(selectedFile)
				buffer, error = playdate.sound.sample.new(selectedFile)
				
			if(error ~= null) then 
				print("Error loading sample" .. error) 
				
			else
				--buffer = newBuffer
			end
				
				if(buffer == nil)then
					
					toast("Error loading sample")
					buffer = playdate.sound.sample.new(30, playdate.sound.kFormat16bitMono)--todo - was 120
					
				else
					samplePlayer:setSample(buffer)
					toast("Sample loaded")
				end
					state = STOPPED
			else
				print("File not available: " .. selectedFile)
			end
			
			
			state = PAUSED
			return
		end
		
		if buffer:getLength() == 0 then
			toast("Empty buffer")
			return
		end
		
		if samplePlayer:isPlaying() then
			samplePlayer:stop()
			state = PAUSED
			toast("Stopped")
		else
			print("playing...")
			playFromCuePoint()
			setLoopPoints()
			state = PLAYING
			toast("Playing")
		end
		
	end

	if bPressed() then
		if state == LOAD_SAMPLE then
			state = STOPPED
			return
		end
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
			loopEndSet = false
			audMax = 0
			
			playdate.sound.micinput.startListening()
			playdate.sound.micinput.recordToSample(buffer, onComplete)
			
			toast("Recording")
			
		end
	end
	
	local change = crankChange()
	if(change > 0) then
		playbackRate += 0.05
		samplePlayer:setRate(playbackRate)
		toast("Speed: " .. round(playbackRate, 2))
	elseif (change < 0) then
		playbackRate -= 0.05
		samplePlayer:setRate(playbackRate)
		toast("Speed: " .. round(playbackRate, 2))
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
				loopStartFrame = math.floor(loopStart * playdate.sound.getSampleRate())
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
				loopEndFrame = math.floor(loopEnd * playdate.sound.getSampleRate())
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
		else
			fill(0.25)
			rect(60, 15, (playbackHeadX - 60), 40)
		end
	end
	
	-- Draw cue points
	if(state == PLAYING or state == PAUSED)then
		if(loopStartSet)then			
			fill(1)
			line(loopStartX, 15, loopStartX, 55)
			triangle(loopStartX, 29, loopStartX, 41, loopStartX + 7, 35)
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
	
	if showToast then
			playdate.graphics.setFont(biggerFont)
			playdate.graphics.drawTextInRect(toastMessage, 0, toastYAnchor, 400, 30, nil, "...", kTextAlignment.center)
	end
	
	
	if(state == LOAD_SAMPLE)then
		fileBrowser:draw()
	end
end

-- Methods -----------------------------------------------------------------------
function playFromCuePoint()
	if loopStartSet then
		print("playFromCuePoint() with offset")
		samplePlayer:play(0)
		samplePlayer:setOffset(loopStart)
	else
		print("playFromCuePoint() play(0)")
		samplePlayer:play(0)
	end
end

function setLoopPoints()
	if(not loopStartSet and not loopEndSet) then
		--Neither
		local sampleRate = playdate.sound.getSampleRate()
		local frames = samplePlayer:getLength() * sampleRate
		samplePlayer:setPlayRange(0, frames)
	elseif (loopStartSet and loopEndSet) then
		--Both
		samplePlayer:setPlayRange(loopStartFrame, loopEndFrame)
	elseif (loopStartSet) then
		--Start set only
		local sampleRate = playdate.sound.getSampleRate()
		local frames = samplePlayer:getLength() * sampleRate
		samplePlayer:setPlayRange(loopStartFrame, frames)
	elseif(loopEndSet) then
		--End set only
		samplePlayer:setPlayRange(0, loopEndFrame)
	end
end

function playdate.upButtonUp()
	if state == LOAD_SAMPLE then return end
	
	if samplePlayer:isPlaying() then
		samplePlayer:stop()
		state = PAUSED
		playFromCuePoint()
		setLoopPoints()
		state = PLAYING
	end
end

function playdate.downButtonUp()

	if state == LOAD_SAMPLE then return end
	
	if samplePlayer:isPlaying() then
		--reset playback rate
		playbackRate = 1.0
		samplePlayer:setRate(playbackRate)
		toast("Speed reset")
	end
	
end

function toast(message)
	toastMessage = message
	print("TOAST: " .. message)
	local function toastCallback()
			showToast = false
	end
	showToast = true
	toastTimer = playdate.timer.new(2500, toastCallback)
end

function generateFilename(prefix, filetype)
	local now = playdate.getTime()
	local seconds, ms = playdate.getSecondsSinceEpoch()
	local filename = "" .. prefix .. getMonth(now["month"]) .. "-" .. seconds .. filetype
	print("generateFilename(): prefix: " .. prefix .. " filetype: " .. filetype .. " output: " .. filename)
	return filename
end

local months = {"jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"}
function getMonth(index)
	return months[index]
end

function round(number, decimalPlaces)
		local mult = 10^(decimalPlaces or 0)
		return math.floor(number * mult + 0.5)/mult
end
