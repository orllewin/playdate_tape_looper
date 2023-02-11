class('Toast').extends(playdate.graphics.sprite)

TOAST_CENTRAL = 0
TOAST_LEFT = 1

function Toast:init(y, font)
	Toast.super.init(self)
	
	self.mode = TOAST_LEFT
	
	self.font = font
	self.fontFamily = {
		[playdate.graphics.font.kVariantNormal] = self.font,
		[playdate.graphics.font.kVariantBold] = self.font,
		[playdate.graphics.font.kVariantItalic] = self.font
	}
	self.origY = y
	self.timer = playdate.timer.new(2500, function()
		self:setVisible(false)
		self.timer:reset()
		self.timer:pause()
	end)
	self.timer.discardOnCompletion = false
	self.timer:pause()
	self:add()
end

function Toast:setText(text)
	if(self.text == text)then return end
	self.text = text
	self:redraw()
end

function Toast:redraw()
	local width, height = playdate.graphics.getTextSize(self.text, self.fontFamily)
	if mode == TOAST_CENTRAL then
		local image = playdate.graphics.image.new(400, height)
		playdate.graphics.pushContext(image)
			self.font:drawText(self.text, 200 - (width/2), 0)
		playdate.graphics.popContext()
		
		self:moveTo(200, self.origY)
		self:setImage(image)
	else
		local image = playdate.graphics.image.new(width, height)
		playdate.graphics.pushContext(image)
			self.font:drawText(self.text, 0, 0)
		playdate.graphics.popContext()
		
		self:moveTo(10+(width/2), self.origY)
		self:setImage(image)
	end
	
	self:setVisible(true)
	self.timer:start()
end