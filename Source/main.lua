import 'Coracle/coracle'
import 'Coracle/string_utils'
import 'CoreLibs/graphics'
import 'CoreLibs/easing'
import 'CoreLibs/timer'
import 'CoreLibs/keyboard'
import 'CoreLibs/sprites'
import 'CoreLibs/ui'
import 'CoreLibs/nineslice'
import 'idle'
import 'Audio/sample_buffer'
import 'Audio/recorder'
import 'Audio/player'
import 'Files/file_browser'
import 'Files/file_output'
import 'Views/toast'

local font = playdate.graphics.font.new("Fonts/font-rains-1x")
local biggerFont = playdate.graphics.font.new("Fonts/Roobert-11-Medium")

local sampleBuffer = SampleBuffer(playdate.sound.kFormat16bitMono, nil)
player = Player(sampleBuffer:getBuffer())

local recorder = Recorder(function(recording, elapsed)
		if(not recording)then recordingCompleteCallback() end
end)
	
function recordingCompleteCallback()
	print("recording finished...")
	playdate.inputHandlers.pop()--recording finished, so pop recording input handler
	player = Player(recorder:getBuffer())
	player:push()--player now handling input
end

local idle = Idle(function()
	if(player:isPlaying())then return end --Can't switch to record while playing
	recorder:push()
	recorder:startListening(function(audLevel, audMax, audAverage)
		--Draw recording bars
		fill(0.5)
		rect(60, 15, map(audLevel, 0.0, audMax, 1, 280), 20)
		
		fill(1)
		rect(60, 15, min(280, map(audAverage, 0.0, audMax, 1, 280)), 20)
		
		--Max level bar		
		fill(0.5)
		rect(60, 35, map(audLevel, 0.0, 1.0, 1, 280), 20)
		
		fill(1)
		rect(60, 35, map(audAverage, 0.0, 1.0, 1, 280), 20)
	end)
	recorder:startRecording(sampleBuffer:getBuffer())
end)
idle:push()


local fileBrowser = AudioFileBrowser(font)
local toast = Toast(148, biggerFont)

--todo - most of these are redundant:
local INTRO, TAPE_LOADING, STOPPED, RECORDING, PLAYING, PAUSED, LOAD_SAMPLE, SAMPLE_LOADED = 0, 1, 2, 3, 4, 5, 6, 7, 8
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
	toast:setText("Ready")
end

local introFilePlayer = playdate.sound.fileplayer.new("Audio/intro_tape_action")
introFilePlayer:setFinishCallback(introFinished)
introFilePlayer:play()

local introDrawOffset = -30
local spindleAngle = 0

local loadTapeImage = playdate.graphics.image.new("Images/load_tape")
local tapeImage = playdate.graphics.image.new("Images/tape")
local spindleImage = playdate.graphics.image.new("Images/spindle")
local spindleSpriteLeft = playdate.graphics.sprite.new(spindleImage)
local spindleSpriteRight = playdate.graphics.sprite.new(spindleImage)

spindleSpriteLeft:moveTo(116, 102)
spindleSpriteLeft:add()

spindleSpriteRight:moveTo(284, 102)
spindleSpriteRight:add()

playdate.graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
		playdate.graphics.setClipRect( x, y, width, height ) 
		tapeImage:draw( 0, 0 )
		playdate.graphics.clearClipRect()
end)

local menu = playdate.getSystemMenu()

-- Add save sample menu
local menuItem, error = menu:addMenuItem("Save Sample", function()
		if player:isEmpty() then
			toast:setText("Empty buffer")
		else
			local savedFilename = FileOutput():exportAudioBothFormats(player:getBuffer())
			toast:setText(replace(savedFilename, ".pda", ""))
		end
end)

-- Add save loop sample
local menuItem, error = menu:addMenuItem("Save Loop", function()
		if(not player:isEmpty() and player:hasLoop()) then
			local savedFilename = FileOutput():exportAudioBothFormats(player:getLoopBuffer())
			toast:setText(replace(savedFilename, ".pda", ""))
		else
			toast:setText("No loop set")
		end
end)

-- Add load sample
local menuItem, error = menu:addMenuItem("Load sample", function()
		state = STOPPED
		fileBrowser:chooseFile(function(_selectedFile)
			selectedFile = _selectedFile
			sampleBuffer:load(selectedFile)
			player:reset(sampleBuffer:getBuffer())
			playdate.inputHandlers.pop()
			player:push()
			toast.setText("" .. selectedFile .. " inserted")
			print("File browser selected file: " .. selectedFile)
			state= SAMPLE_LOADED
		end)
		state = LOAD_SAMPLE
end)

function playdate.update()
	local change = crankChange()
	if(change > 0) then
		player:incPlaybackRate(0.025)
		toast:setText("Speed: " .. round(player:getPlaybackRate(), 2))
	elseif (change < 0) then
		player:decPlaybackRate(0.025)
		toast:setText("Speed: " .. round(player:getPlaybackRate(), 2))
	end

	if player:isPlaying() then
		spindleAngle += (player:getPlaybackRate() * 2) 
		
		if(spindleAngle > 358) then spindleAngle = 0 end
		
		spindleSpriteLeft:setRotation(spindleAngle)
		spindleSpriteRight:setRotation(spindleAngle)
	end
	
	if recorder:isRecording() then 		
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
		
	if(state == INTRO) then
		playdate.graphics.setDrawOffset(0, introDrawOffset)
		fill(0.8)
		rect(0, 0, 400, 350)
		tapeImage:draw( 0, introDrawOffset)
		introDrawOffset += 0.7
	end
	
	playdate.timer.updateTimers()
		
	if(fileBrowser:isDisplaying())then fileBrowser:draw() end
	
	recorder:update()
	player:draw()
end
