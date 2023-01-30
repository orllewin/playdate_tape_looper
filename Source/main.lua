import 'Coracle/coracle'
import 'Coracle/string_utils'
import 'CoreLibs/graphics'
import 'CoreLibs/easing'
import 'CoreLibs/timer'
import 'CoreLibs/keyboard'
import 'CoreLibs/sprites'
import 'CoreLibs/ui'
import 'CoreLibs/nineslice'

local font = playdate.graphics.font.new("font-rains-1x")
local biggerFont = playdate.graphics.font.new("Roobert-11-Medium")


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

local introFilePlayer = playdate.sound.fileplayer.new("intro_tape_action")
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

local loadTapeImage = playdate.graphics.image.new("load_tape")
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
		refreshLoadFiles()
		state = LOAD_SAMPLE
end)

-- Show saved samples, must be in pda format.
local loadWindowWidth = 392

local wavs = {}
local selectedFile = nil

local loadSampleGridview = playdate.ui.gridview.new(loadWindowWidth-16, 25)

loadSampleGridview.backgroundImage = playdate.graphics.nineSlice.new('shadowbox', 4, 4, 45, 45)
loadSampleGridview:setNumberOfColumns(1)
loadSampleGridview:setSectionHeaderHeight(28)
loadSampleGridview:setContentInset(4, 4, 4, 4)--left, right, top, bottom
loadSampleGridview:setCellPadding(4, 4, 2, 2)--left, right, top, bottom
loadSampleGridview.changeRowOnColumnWrap = false

function refreshLoadFiles()
	print("refreshLoadFiles()")
	local files = playdate.file.listFiles()
	for i, v in ipairs(wavs) do wavs[i] = nil end

	
	print("--------------------------------------")
	print("Filesystem file count: " .. #files)
	for f=1, #files do
		print("index: " .. f)
		local file = files[f]
		print("file: " .. file)
	
		if endswith(file, ".pda") then
			print("audio file: " .. file)
			table.insert(wavs, file)
		end 
	end
	
	for w=1, #wavs do
		local pdaFile = wavs[w]
		print("stored audio file: " .. pdaFile)
	end
	print("--------------------------------------")
	selectedFile = nil
	loadSampleGridview:setNumberOfRows(#wavs)
	
end

function loadSampleGridview:drawCell(section, row, column, selected, x, y, width, height)
		
		local file = wavs[row]
		if selected then
			selectedFile = file
			fill(1)
			roundedRect(x, y, width, height, 5)
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		else
			fill(0)
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
		end

		local filename = tostring(file)
		local cellText = replace(filename, "_", " ")--Playdate turns _text_ into italics... so strip any underscores out
		playdate.graphics.setFont(font)
		text("" .. row .. ". " .. cellText, x + 8, y + 9)
end


function loadSampleGridview:drawSectionHeader(section, x, y, width, height)
		playdate.graphics.setFont(biggerFont)
		playdate.graphics.drawText("Load sample", x + 6, y + 6)
end

-- End of Gridview ----------------------------------------------------------

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
				buffer:load(selectedFile)
				
				if(buffer == nil)then
					state = STOPPED
					toast("Error loading sample")
					buffer = playdate.sound.sample.new(120, playdate.sound.kFormat16bitMono)
					
				else
					--samplePlayer:setSample(buffer)
					toast("Sample loaded")
				end

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
		loadSampleGridview:drawInRect(4, 4, loadWindowWidth, 232)
	end
end

-- Methods -----------------------------------------------------------------------
function playFromCuePoint()
	if loopStartSet then
		samplePlayer:play(0)
		samplePlayer:setOffset(loopStart)
	else
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
	if state == LOAD_SAMPLE then
		loadSampleGridview:selectPreviousRow(true)
	end
end

function playdate.downButtonUp()

	if state == LOAD_SAMPLE then
		loadSampleGridview:selectNextRow(true)
	end
	
end

function playdate.leftButtonUp()
	if state == LOAD_SAMPLE then
		loadSampleGridview:selectPreviousColumn(true)
	end

end

function playdate.rightButtonUp()
	if state == LOAD_SAMPLE then
		loadSampleGridview:selectNextColumn(true)
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