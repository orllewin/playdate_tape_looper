class('RecordLevels').extends(playdate.graphics.sprite)

local barHeight = 220
local barWidth = 25
local barTopAnchor = 10
local barLeftAnchor = 10
local barRightAnchor = barLeftAnchor + barWidth
local maxInputLevel = -1
local maxAvgLevel = -1

function RecordLevels:init()
	RecordLevels.super.init(self)
	
	self:moveTo(barLeftAnchor + (barWidth), barTopAnchor + (barHeight/2))
	self:add()
	self:redraw(0, 0, 0)
end

function RecordLevels:redraw(audLevel, audMax, audAverage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	
	fill(0.5)
	local maxRel = map(audLevel, 0.0, audMax, 1, barHeight)
	rect(barLeftAnchor, barTopAnchor + barHeight - maxRel, barWidth, maxRel)
	
	if(maxRel > maxAvgLevel)then
		maxAvgLevel = maxRel
	end
	
	maxAvgLevel -= 1
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	-- local avgRel = map(audAverage, 0.0, audMax, 1, barHeight)
	-- rect(10, 10 + barHeight - avgRel, barWidth, avgRel)
	
	--Max level bar		
	fill(0.5)
	local actRel = map(audLevel, 0.0, 1.0, 1, barHeight)
	rect(barRightAnchor, barTopAnchor + barHeight - actRel, barWidth, actRel)
	
	if(actRel > maxInputLevel)then
		maxInputLevel = actRel
	end
	
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	fill(0.5)
	local avgMRel = map(audAverage, 0.0, 1.0, 1, barHeight)
	rect(barRightAnchor, barTopAnchor + barHeight - avgMRel, barWidth, avgMRel)
	
	line(barRightAnchor, barTopAnchor + barHeight - maxInputLevel, barRightAnchor + barWidth, barTopAnchor + barHeight - maxInputLevel)
	if(maxAvgLevel > 0)then
		line(barLeftAnchor, barTopAnchor + barHeight - maxAvgLevel, barLeftAnchor + barWidth, barTopAnchor + barHeight - maxAvgLevel)
	end
	
	playdate.graphics.drawRect(barLeftAnchor, barTopAnchor, barWidth * 2, barHeight)
end