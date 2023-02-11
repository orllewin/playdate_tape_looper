class('VerticalSlider').extends(playdate.graphics.sprite)

VSLIDER_HEIGHT = 130
VSLIDER_WIDTH = 48

-- value in range 0.0 to 1.0
function VerticalSlider:init(x, y, value, listener)
	VerticalSlider.super.init(self)
	self.value = value
	self.listener = listener
	self.hasFocus = false
	
	local focusedImage = playdate.graphics.image.new(VSLIDER_WIDTH, VSLIDER_HEIGHT)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.setDitherPattern(0.5, playdate.graphics.image.kDitherTypeBayer8x8)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, VSLIDER_WIDTH - 2, VSLIDER_HEIGHT - 2, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(x, y)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
	local backplateImage = playdate.graphics.image.new(VSLIDER_WIDTH, VSLIDER_HEIGHT)
	playdate.graphics.pushContext(backplateImage)
		playdate.graphics.setLineWidth(1)

		for i=1,15 do
			local y = map(i + 1, 1, 15, 0, VSLIDER_HEIGHT)
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
	self.knobSprite:moveTo(x, y)
	self.knobSprite:add()
	
	self:setImage(backplateImage)
	
	self:moveTo(x, y)
	self:redraw()
	self:add()
end

function VerticalSlider:redraw()
	self.knobSprite:moveTo(self.x, self.y + VSLIDER_HEIGHT/2 - map(self.value, 0, 1, 10, VSLIDER_HEIGHT - 10))
end

function VerticalSlider:getViews()
	local views = {}
	table.insert(views, self)
	table.insert(views, self.focusedSprite)
	table.insert(views, self.knobSprite)
	return views
end

function VerticalSlider:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	if(degrees > 0)then
		self.value += 0.02
	else
		self.value -= 0.02
	end
	
	if(self.value < 0.0) then self.value = 0.0 end
	if(self.value > 1.0) then self.value = 1.0 end
	self:redraw()
	if(self.listener ~= nil)then self.listener(round(self.value, 2)) end
end

function VerticalSlider:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	self:update()
end