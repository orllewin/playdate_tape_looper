class('MiniModal').extends(playdate.graphics.sprite)

function MiniModal:init(y, font)
	MiniModal.super.init(self)
	
	self.font = font
	
	self.origY = y
	self:add()
end

function MiniModal:show(text, onConfirm)
	if(self.text == text)then return end
	self.text = text
	self.onConfirm = onConfirm
	playdate.inputHandlers.push(self:getInputHandler())
	self:redraw()
end

function MiniModal:redraw()
	local message = self.text .. " No (B), Yes (A)"
	local width, height = playdate.graphics.getTextSize(message, self.fontFamily)
	
		local image = playdate.graphics.image.new(width, height)
		playdate.graphics.pushContext(image)
			self.font:drawText(message, 0, 0)
		playdate.graphics.popContext()
		
		self:moveTo(10+(width/2), self.origY)
		self:setImage(image)
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function MiniModal:getInputHandler()
	return {
		leftButtonDown = function()
			--NOOP
		end,
		rightButtonDown = function()
			--NOOP
		end,
		upButtonDown = function()
			--NOOP
		end,
		downButtonDown = function()
			--NOOP
		end,
		BButtonDown = function()
			--cancel
			self:remove()
			playdate.inputHandlers.pop()
			if(self.onConfirm ~= nil) then self.onConfirm(false) end
		end,
		AButtonDown = function()
			--confirm
			self:remove()
			playdate.inputHandlers.pop()
			if(self.onConfirm ~= nil) then self.onConfirm(true) end
		end
		
	}
end