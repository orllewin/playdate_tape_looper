class('RotaryEncoder').extends(playdate.graphics.sprite)

-- A knob. Parent must import Coracle/coracle and Coracle/math
function RotaryEncoder:init(x, y, listener, _font)
	RotaryEncoder.super.init(self)
	
	-- Listener, optional
	self.listener = listener
	self.font = _font
	
	local backplateImage = playdate.graphics.image.new('Views/Images/rotary_encoder_backplate')
	self.backplate = playdate.graphics.sprite.new(backplateImage)
	self.backplate:moveTo(x, y)
	self.backplate:add()
	
	self.labelImage = playdate.graphics.image.new(48, 12)
	self.labelSprite = playdate.graphics.sprite.new(self.labelImage)
	self.labelSprite:moveTo(x, y + 28)
	self.labelSprite:add()
	self.labelSprite:setVisible(true)
	self:updateLabel()
	
	local focusedImage = playdate.graphics.image.new(48, 58)
	playdate.graphics.pushContext(focusedImage)
	playdate.graphics.setLineWidth(2)
	playdate.graphics.drawRoundRect(1, 1, 46, 56, 5) 
	playdate.graphics.setLineWidth(1)
	playdate.graphics.popContext()
	self.focusedSprite = playdate.graphics.sprite.new(focusedImage)
	self.focusedSprite:moveTo(x, y + 6)
	self.focusedSprite:add()
	self.focusedSprite:setVisible(false)
	
	self:setImage(playdate.graphics.image.new('Views/Images/rotary_encoder_encoder'))
	self:moveTo(x, y)
	self:add()
end

function RotaryEncoder:removeChildren()
	self.backplate:remove()
	self.labelSprite:remove()
	self.focusedSprite:remove()
end

function RotaryEncoder:addChildren()
	self.backplate:add()
	self.labelSprite:add()
	self.focusedSprite:add()
end

-- 0.0 to 1.0
function RotaryEncoder:getValue()
	return map(self:getRotation(), 0, 300, 0.0, 1.0)
end

-- 0.0 to 1.0
function RotaryEncoder:setValue(value)
	local normalised = math.max(1.0, math.min(0.0, value))
	self:rotate(map(normalised, 0.0, 1.0, 0, 300))
	self:updateLabel()
	if(self.listener ~= nil)then self.listener(round(normalised, 2)) end
end

function RotaryEncoder:turn(degrees)
	if(degrees == 0.0)then return end --indicates no change from crank in this frame
	self:setRotation(math.max(0, (math.min(300, self:getRotation() + degrees))))
	self:updateLabel()
	if(self.listener ~= nil)then self.listener(round(self:getValue(), 2)) end
end

function RotaryEncoder:setFocus(focus)
	self.hasFocus = focus
	self.focusedSprite:setVisible(focus)
	self:update()
end

function RotaryEncoder:focused()
	return self.hasFocus
end


function RotaryEncoder:updateLabel()
	playdate.graphics.setFont(fff)
	playdate.graphics.pushContext(self.labelImage)
	playdate.graphics.clear(playdate.graphics.kColorBlack)
	playdate.graphics.drawTextInRect(self:getLabel(), 0, 0, 48, 20, nil, nil, kTextAlignment.center)
	playdate.graphics.popContext()
	self.labelSprite:update()
end

function RotaryEncoder:getLabel()
	return "" .. round(map(self:getRotation(), 0, 300, 0.0, 1.0), 2)
end