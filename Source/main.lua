import 'Coracle/coracle'
import 'Coracle/math'
import 'Coracle/string_utils'
import 'Coracle/vector'
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
import 'Views/spindles'
import 'Views/record_levels'
import 'Views/control_labels'
import 'Views/focus_manager'
import 'Views/rotary_encoder'
import 'Views/label'
import 'Views/visibility_manager'
import 'Views/two_part_effect'
import 'Views/vertical_slider'
import 'Views/mini_modal'
import 'Views/divider'

fff = playdate.graphics.font.new("Fonts/font-rains-1x")--some bug or other, somewhere, fixed with a global font
font = playdate.graphics.font.new("Fonts/font-rains-1x")

local spindles = Spindles()
local levels = RecordLevels()
local controls = ControlLabels(font)
local fxY = 76
local fxX = 35
local fxSpace = 70

local sound = playdate.sound

local overdrive = sound.overdrive.new()
sound.addEffect(overdrive)
overdrive:setGain(0.0)
overdrive:setMix(0.0)

local delay = 3
local delayFx = sound.delayline.new(delay)
local delayTapA = delayFx:addTap(delay)
local delayTapB = delayFx:addTap(delay)
sound.addEffect(delayFx)
delayFx:setMix(0.0)

local delayAEffect = TwoPartEffect(font, Vector(fxX, fxY), "Delay", "Mix")
delayAEffect:setAmountListener(function(value)
	--todo debounce?
	sound.removeEffect(delayFx)
	delay = map(value, 0.0, 1.0, 0.01, 5.0)
	delayFx = sound.delayline.new(delay)
	sound.addEffect(delayFx)
	delayTapA = delayFx:addTap(delay)
	delayTapB = delayFx:addTap(delay)
end)
delayAEffect:setMixListener(function(value)
	delayFx:setMix(value)
end)

local delayBEffect = TwoPartEffect(font, Vector(fxX + (fxSpace), fxY), "F/back", "Tap Vol")
delayBEffect:setAmountListener(function(value)
	delayFx:setFeedback(value)
end)
delayBEffect:setMixListener(function(value)
	delayTapA:setVolume(value)
	delayTapB:setVolume(value)
end)
local delayTapEffect = TwoPartEffect(font, Vector(fxX + (fxSpace * 2), fxY), "Tap 1", "Tap 2")
delayTapEffect:setAmountListener(function(value)
	delayTapA:setDelay(map(value, 0.0, 1.0, 0.0, delay))
end)
delayTapEffect:setMixListener(function(value)
	delayTapA:setDelay(map(value, 0.0, 1.0, 0.0, delay))
end)

local overdriveEffect = TwoPartEffect(font, Vector(fxX + (fxSpace * 3), fxY), "Gain", "Mix")
overdriveEffect:setAmountListener(function(value)
	overdrive:setGain(map(value, 0.0, 1.0, 0.0, 3.0))
	
end)
overdriveEffect:setMixListener(function(value)
	overdrive:setMix(value)
end)


local focusManager = FocusManager()
local sampleBuffer = SampleBuffer(playdate.sound.kFormat16bitMono, nil)
local visibilityManager = VisibilityManager()

player = Player(function(playing)
	-- Play listener
	if playing then
		controls:setPlayingLooper()
	else
		controls:setPlayReady()
	end
end, function() 
	-- ui mode toggle
	if focusManager:isHandlingInput() then
		-- loop mode
		focusManager:unfocus()
		focusManager:pop()-- input return to player
		controls:setPlayingLooper()
	else
		-- efx mode
		focusManager:start()
		focusManager:push()-- focus manager is now handling all input
		controls:setPlayingEffects() 
	end
end, function()
		-- switch to record
		local miniModal = MiniModal(232, font)
		miniModal:show("Sure?", function(confirmed)
			print("moadl confirmed: " .. tostring(confirmed))
			if confirmed == true then
				visibilityManager:hide()
				controls:setRecordReady()
				focusManager:pop()
				player:pop()
				spindles:recordingMode()
				pushIdle()
			end
		end)
end, function() 
	-- Playback reset listener
	resetUIRate()
end)

volumeLabel = Label(367, 76, "Vol.", fff)
volumeLabel:setOpacity(0.4)
volumeSlider = VerticalSlider(365, 145, 100.0, 0.0, 100.0, function(volume)
	player:setVolume(volume)
end, false)

rateLabel = Label(306, 76, "Rate", fff)
rateLabel:setOpacity(0.4)
rateSlider = VerticalSlider(305, 145, 1.0, -2.0, 2.0, function(rate)
	player:setRate(rate)
end, true)

function resetUIRate()
	rateSlider:setValue(1.0)
end

playdate.graphics.setFont(font)

divider = Divider(222)

focusManager:addView(delayAEffect:getTopFocusView(), 1)
focusManager:addView(delayAEffect:getBottomFocusView(), 2)
focusManager:addView(delayBEffect:getTopFocusView(), 1)
focusManager:addView(delayBEffect:getBottomFocusView(), 2)
focusManager:addView(delayTapEffect:getTopFocusView(), 1)
focusManager:addView(delayTapEffect:getBottomFocusView(), 2)
focusManager:addView(overdriveEffect:getTopFocusView(), 1)
focusManager:addView(overdriveEffect:getBottomFocusView(), 2)
focusManager:addView(rateSlider, 1)
focusManager:addView(rateSlider, 2)
focusManager:addView(volumeSlider, 1)
focusManager:addView(volumeSlider, 2)


visibilityManager:addViews(delayAEffect:getViews())
visibilityManager:addViews(delayBEffect:getViews())
visibilityManager:addViews(delayTapEffect:getViews())
visibilityManager:addViews(overdriveEffect:getViews())
visibilityManager:addViews(volumeSlider:getViews())
visibilityManager:addViews(rateSlider:getViews())
visibilityManager:addView(rateLabel)
visibilityManager:addView(volumeLabel)
--visibilityManager:addView(divider)

local recorder = Recorder(function(recording, elapsed)
		if(not recording)then recordingCompleteCallback() end
end)

visibilityManager:hide()
	
function recordingCompleteCallback()
	print("recording finished...")
	playdate.inputHandlers.pop()--recording finished, so pop recording input handler
	spindles:playMode()
	player:reset(recorder:getBuffer())
	player:push()--player now handling input
	controls:setPlayReady()
	visibilityManager:show()
end

local idle = Idle(function()
	if(player:isPlaying())then return end --Can't switch to record while playing
	recorder:push()
	recorder:startListening(function(audLevel, audMax, audAverage)
		levels:redraw(audLevel, audMax, audAverage)
	end)
	--fill(0.2)
	recorder:startRecording(sampleBuffer:getBuffer())
	spindles:recordingMode()
	controls:setRecording()
end)
idle:push()


local fileBrowser = AudioFileBrowser(font)
local fileOutput = FileOuput()
local toast = Toast(232, font)

--todo - most of these are redundant:
local STOPPED, LOAD_SAMPLE, SAMPLE_LOADED = 0, 1, 2
local state = STOPPED

playdate.graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	playdate.graphics.setColor(playdate.graphics.kColorBlack)
	playdate.graphics.fillRect(0, 0, 400, 240)
end)

local menu = playdate.getSystemMenu()

-- Add save sample menu
local menuItem, error = menu:addMenuItem("Save Sample", function()
		if player:isEmpty() then
			toast:setText("Empty buffer")
		else
			local savedFilename = fileOutput:exportAudioBothFormats(player:getBuffer())
			toast:setText(savedFilename)
		end
end)

-- Add save loop sample
local menuItem, error = menu:addMenuItem("Save Loop", function()
		if(not player:isEmpty() and player:hasLoop()) then
			local savedFilename = fileOutput:exportAudioBothFormats(player:getLoopBuffer())
			toast:setText(savedFilename)
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
			spindles:playMode()
			controls:setPlayReady()
			visibilityManager:show()
			toast.setText("" .. selectedFile .. " loaded")
			print("File browser selected file: " .. selectedFile)
			state= SAMPLE_LOADED
		end)
		state = LOAD_SAMPLE
end)

function pushIdle()
	idle:push()
end

function playdate.update()
	local change = crankChange()
	if focusManager:isHandlingInput() then
		focusManager:turnFocusedView(change)
	else
		if change ~= 0.0 and player:isPlaying() then
			rateSlider:turn(change)
		end
	end

	if player:isPlaying() then
		spindles:inc(player:getPlaybackRate() * 2)

	end
	
	if recorder:isRecording() then 		
		spindles:inc(2)
	end
	
	playdate.graphics.sprite.update()

	-- POST SPRITE DRAWING --------------------------------------------------------

	playdate.timer.updateTimers()
		
	if(fileBrowser:isDisplaying())then fileBrowser:draw() end
	
	recorder:update()
	player:draw()
end
