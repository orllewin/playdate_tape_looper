class('Label').extends(playdate.graphics.sprite)

function Label:init(x, y, text, font)
	Label.super.init(self)
	
	self.font = font
	self.fontFamily = {
		 [playdate.graphics.font.kVariantNormal] = self.font,
		[playdate.graphics.font.kVariantBold] = self.font,
		[playdate.graphics.font.kVariantItalic] = self.font
	}
	self.text = text
	self.origX = x
	self.origY = y
	self:redraw()
	self:add()
end

function Label:setText(text)
	if(self.text == text)then return end
	self.text = text
	self:redraw()
end

function Label:redraw()
	playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
	local width, height = playdate.graphics.getTextSize(self.text, self.fontFamily)
	local image = playdate.graphics.image.new(width, height)
	playdate.graphics.pushContext(image)
		self.font:drawText(self.text, 0, 0)
	playdate.graphics.popContext()
	self:moveTo(self.origX, self.origY)
	self:setImage(image)
end