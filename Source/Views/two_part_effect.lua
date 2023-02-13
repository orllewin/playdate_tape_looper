class('TwoPartEffect').extends(playdate.graphics.sprite)

function TwoPartEffect:init(font, location, topLabel, bottomLabel)
	TwoPartEffect.super.init(self)
	
	playdate.graphics.setFont(font)
	
	self.amountListener = nil
	self.mixListener = nil
	
	self.effectLabel = Label(location.x, location.y, topLabel, font)
	self.effectLabel:setOpacity(0.4)
	self.amountEncoder = RotaryEncoder(location.x, 	location.y + 30, function(value)
		print(value)
		if(self.amountListener ~= nil)then self.amountListener(value) end
	end, font)
	
	self.mixLabel = Label(location.x, location.y + 75, bottomLabel, font)
	self.mixLabel:setOpacity(0.4)
	self.mixEncoder = RotaryEncoder(location.x, 	location.y + 105, function(value)
		print(value)
		if(self.mixListener ~= nil)then self.mixListener(value) end
	end, font)
	
	self:add()
end

function TwoPartEffect:setAmountListener(amountListener)
	self.amountListener = amountListener
end

function TwoPartEffect:setMixListener(mixListener)
	self.mixListener = mixListener
end

function TwoPartEffect:addChildren()
	self.effectLabel:add()
	self.amountEncoder:add()
	self.mixLabel:add()
	self.mixEncoder:add()
end

function TwoPartEffect:getViews()
	local views = {}
	table.insert(views, self.effectLabel)
	table.insert(views, self.amountEncoder)
	table.insert(views, self.mixLabel)
	table.insert(views, self.mixEncoder)
	return views
end

function TwoPartEffect:getTopFocusView()
	return self.amountEncoder
end

function TwoPartEffect:getBottomFocusView()
	return self.mixEncoder
end

