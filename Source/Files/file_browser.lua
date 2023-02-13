class('AudioFileBrowser').extends()

local loadWindowWidth = 392
local audioFiles = {}
local selectedFile = nil
local font = nil

function AudioFileBrowser:init(_font)
	AudioFileBrowser.super.init(self)
	
	self.displaying = false
	
	font = _font
	self.loadSampleGridview = playdate.ui.gridview.new(loadWindowWidth-16, 25)
	self.loadSampleGridview.backgroundImage = playdate.graphics.image.new('Images/black')
	self.loadSampleGridview:setNumberOfColumns(1)
	self.loadSampleGridview:setSectionHeaderHeight(28)
	self.loadSampleGridview:setContentInset(4, 4, 4, 4)--left, right, top, bottom
	self.loadSampleGridview:setCellPadding(4, 4, 2, 2)--left, right, top, bottom
	self.loadSampleGridview.changeRowOnColumnWrap = false
	
	function self.loadSampleGridview:drawCell(section, row, column, selected, x, y, width, height)			
			local file = audioFiles[row]
			local filename = tostring(file)
			local cellText = replace(filename, "_", " ")--Playdate turns _text_ into italics... so strip any underscores out
			
			if selected then
				selectedFile = file
				playdate.graphics.setColor(playdate.graphics.kColorWhite)
				playdate.graphics.fillRoundRect(x, y, width, height, 5)
				
				playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillBlack)
				font:drawText("" .. row .. ". " .. cellText, x + 8, y + 9)
				
			else
				playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
				font:drawText("" .. row .. ". " .. cellText, x + 8, y + 9)
			end
	end
	
	function self.loadSampleGridview:drawSectionHeader(section, x, y, width, height)
			playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
			font:drawText("Select sample:", x + 6, y + 6)
	end

end

function AudioFileBrowser:isDisplaying()
	return self.displaying
end

function AudioFileBrowser:chooseFile(onFileListener)
	self.onFileListener = onFileListener
	
	self.displaying = true
	--clear previous results (user may have saved files since chooser was last shown)
	for i, v in ipairs(audioFiles) do audioFiles[i] = nil end
	
	local files = playdate.file.listFiles()
	for f=1, #files do
		local file = files[f]	
		if endswith(file, ".pda") then
				table.insert(audioFiles, file)
		end
	end
	
	for w=1, #audioFiles do
		local pdaFile = audioFiles[w]
	end
	
	selectedFile = nil
	self.loadSampleGridview:setNumberOfRows(#audioFiles)
	
	playdate.inputHandlers.push(self:getInputHandler())
end

function AudioFileBrowser:getInputHandler()
	return {
		leftButtonDown = function()
			--NOOP
		end,
		rightButtonDown = function()
			--NOOP
		end,
		upButtonDown = function()
			self.loadSampleGridview:selectPreviousRow(true)
		end,
		downButtonDown = function()
			self.loadSampleGridview:selectNextRow(true)
		end,
		AButtonDown = function()
				self.displaying = false
				if(self.onFileListener ~= nil)then self.onFileListener(selectedFile) end
		end,
		BButtonDown = function()
			--Cancel
			selectedFile = nil
			playdate.inputHandlers.pop()
			self.displaying = false
		end
	}
end

function AudioFileBrowser:draw()
	self.loadSampleGridview:drawInRect(4, 4, loadWindowWidth, 232)
end