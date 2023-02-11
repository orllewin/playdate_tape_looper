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

 fff = playdate.graphics.font.new("Fonts/font-rains-1x")
 font = playdate.graphics.font.new("Fonts/font-rains-1x")


local spindles = Spindles()
local levels = RecordLevels()
local controls = ControlLabels(font)
local fxY = 76
local fxX = 35
local fxSpace = 70

local sound = playdate.sound

local bitcrusherFx = sound.bitcrusher.new()
sound.addEffect(bitcrusherFx)

local overdriveFx = sound.overdrive.new()
lfo = playdate.sound.lfo.new(playdate.sound.kWaveTriangle)
overdriveFx:setOffsetMod(lfo)
sound.addEffect(overdriveFx)

local ringmodFx = sound.ringmod.new()
sound.addEffect(ringmodFx)

local delayFx = sound.delayline.new(2)
local delayTap = delayFx:addTap(1)
sound.addEffect(delayFx)

local bitcrusherEffect = TwoPartEffect(font, Vector(fxX, fxY), "Crush", "Mix")
bitcrusherEffect:setAmountListener(function(value)
	bitcrusherFx:setAmount(value)
end)
bitcrusherEffect:setMixListener(function(value)
	bitcrusherFx:setMix(value)
end)

local ringmodEffect = TwoPartEffect(font, Vector(fxX + (fxSpace), fxY), "Ringmod", "Mix")
ringmodEffect:setAmountListener(function(value)
	ringmodFx:setFrequency(map(value, 0.0, 1.0, 200, 1500))
end)
ringmodEffect:setMixListener(function(value)
	ringmodFx:setMix(value)
end)
local onePoleEffect = TwoPartEffect(font, Vector(fxX + (fxSpace * 2), fxY), "Delay", "Mix")
onePoleEffect:setAmountListener(function(value)
	delayFx:setFeedback(value)
	delayTap:setDelay(value + 1)
end)
onePoleEffect:setMixListener(function(value)
	delayFx:setMix(value)
end)
local overdriveEffect = TwoPartEffect(font, Vector(fxX + (fxSpace * 3), fxY), "Drive", "Mix")
overdriveEffect:setAmountListener(function(value)
	overdriveFx:setGain(map(value, 0.0, 1.0, 0.0, 3.0))
end)
overdriveEffect:setMixListener(function(value)
	overdriveFx:setMix(value)
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
		controls:setPlayingLooper() -- no playing callback anywhere?
	else
		-- efx mode
		focusManager:start()
		focusManager:push()-- focus manager is now handling all input
		controls:setPlayingEffects() -- no playing callback anywhere?
	end
end)

volumeSlider = VerticalSlider(365, 145, 0.75)

playdate.graphics.setFont(font)

focusManager:addView(bitcrusherEffect:getTopFocusView(), 1)
focusManager:addView(bitcrusherEffect:getBottomFocusView(), 2)
focusManager:addView(ringmodEffect:getTopFocusView(), 1)
focusManager:addView(ringmodEffect:getBottomFocusView(), 2)
focusManager:addView(onePoleEffect:getTopFocusView(), 1)
focusManager:addView(onePoleEffect:getBottomFocusView(), 2)
focusManager:addView(overdriveEffect:getTopFocusView(), 1)
focusManager:addView(overdriveEffect:getBottomFocusView(), 2)
focusManager:addView(volumeSlider, 1)
focusManager:addView(volumeSlider, 2)
visibilityManager:addViews(bitcrusherEffect:getViews())
visibilityManager:addViews(ringmodEffect:getViews())
visibilityManager:addViews(onePoleEffect:getViews())
visibilityManager:addViews(overdriveEffect:getViews())
visibilityManager:addViews(volumeSlider:getViews())

local recorder = Recorder(function(recording, elapsed)
		print("rec elapsed: " .. elapsed)
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
local toast = Toast(148, font)

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
			toast.setText("" .. selectedFile .. " inserted")
			print("File browser selected file: " .. selectedFile)
			state= SAMPLE_LOADED
		end)
		state = LOAD_SAMPLE
end)

function playdate.update()
	local change = crankChange()
	if focusManager:isHandlingInput() then
		focusManager:turnFocusedView(change)
	else
		if(change > 0) then
			player:incPlaybackRate(0.025)
			toast:setText("Speed: " .. round(player:getPlaybackRate(), 2))
		elseif (change < 0) then
			player:decPlaybackRate(0.025)
			toast:setText("Speed: " .. round(player:getPlaybackRate(), 2))
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
