class('VerticalSlider').extends(playdate.graphics.sprite)

VSLIDER_HEIGHT = 100
VSLIDER_WIDTH = 48

-- value in range 0.0 to 1.0
function VerticalSlider:init(x, y, value, rangeStart, rangeEnd, listener, labelIsFloat)
	VerticalSlider.super.init(self)
	self.value = value
	self.rangeStart = rangeStart
	self.rangeEnd = rangeEnd
	self.listener = listener
	self.labelIsFloat = labelIsFloat
	self.hasFocus = false
	
	local focusedImage = playdate.graphics.image.new(VSLIDER_WIDTH, VSLIDER_HEIGHT + 35)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.setDitherPattern(0.5, playdate.graphics.image.kDitherTypeBayer8x8)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, VSLIDER_WIDTH - 2, VSLIDER_HEIGHT +33, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(x, y + 4)
	self.focusedSprite:setZIndex(32000)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
	self.labelImage = playdate.graphics.image.new(48, 12)
	self.labelSprite = playdate.graphics.sprite.new(self.labelImage)
	self.labelSprite:moveTo(x, y + 63)
	self.labelSprite:setZIndex(200)
	self.labelSprite:add()
	self.labelSprite:setVisible(true)
	self:updateLabel()
	
	local backplateImage = playdate.graphics.image.new(VSLIDER_WIDTH, VSLIDER_HEIGHT + 25)
	playdate.graphics.pushContext(backplateImage)
		playdate.graphics.setLineWidth(1)

		for i=1,13 do
			local y = map(i + 1, 1, 13, 0, VSLIDER_HEIGHT)
			playdate.graphics.drawLine(5, y, VSLIDER_WIDTH/2 - 2, y) 
			playdate.graphics.drawLine(VSLIDER_WIDTH/2 + 2, y, VSLIDER_WIDTH - 5, y) 
		end	
		playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	
	local knobImage = playdate.graphics.image.new(VSLIDER_WIDTH - 10, 10)
	playdate.graphics.pushContext(knobImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	fill(1)
	playdate.graphics.fillRoundRect(0, 0, VSLIDER_WIDTH - 10, 10, 5) 
	playdate.graphics.popContext()
	self.knobSprite = playdate.graphics.sprite.new(knobImage)
	self.knobSprite:moveTo(x, y - 25)
	self.knobSprite:add()
	
	self:setImage(backplateImage)
	
	self:moveTo(x, y)
	self:redraw()
	self:add()
end

function VerticalSlider:redraw()
	local normalisedValue = map(self.value, self.rangeStart, self.rangeEnd, 0.0, 1.0)
	self.knobSprite:moveTo(self.x, self.y + map(1.0 - normalisedValue, 0, 1, 0, VSLIDER_HEIGHT) - (VSLIDER_HEIGHT/2) - 5)
end

function VerticalSlider:getViews()
	local views = {}
	table.insert(views, self)
	table.insert(views, self.focusedSprite)
	table.insert(views, self.knobSprite)
	table.insert(views, self.labelSprite)
	return views
end

function VerticalSlider:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	
	local normalisedValue = map(self.value, self.rangeStart, self.rangeEnd, 0.0, 1.0)
	if(degrees > 0)then
		normalisedValue += 0.01
	else
		normalisedValue -= 0.01
	end
	
	if(normalisedValue < 0.0) then normalisedValue = 0.0 end
	if(normalisedValue > 1.0) then normalisedValue = 1.0 end
	
	self.value = map(normalisedValue, 0.0, 1.0, self.rangeStart, self.rangeEnd)
	self:redraw()
	self:updateLabel()
	if(self.listener ~= nil)then self.listener(self.value) end
end

function VerticalSlider:setValue(value)
	self.value = value
	self:redraw()
	self:updateLabel()
end

function VerticalSlider:updateLabel()
	playdate.graphics.setFont(fff)
	playdate.graphics.pushContext(self.labelImage)
	playdate.graphics.clear(playdate.graphics.kColorBlack)
	playdate.graphics.drawTextInRect(self:getLabel(), 0, 0, 48, 20, nil, nil, kTextAlignment.center)
	playdate.graphics.popContext()
	self.labelSprite:update()
end

function VerticalSlider:getLabel()
	if(self.labelIsFloat)then
		return "" .. string.format("%.2f", round(self.value, 2))
	else
		return "" .. math.floor(self.value)
	end
	
end

function VerticalSlider:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	self:update()
end