class('FocusManager').extends()

-- Handles navigation. 
-- Any view added to this class must have a setFocus(bool)
-- Views that work with the crank should have a turn(degrees) method
function FocusManager:init()
	FocusManager.super.init(self)
	
	self.viewMatrix = {}
	self.activeRow = 1
	self.activeIndex = 1
	self.handlingInput = false
end

function FocusManager:start()
	assert(#self.viewMatrix[1] > 0, "You havn't added any views")
	self.viewMatrix[1][1]:setFocus(true)
end

function FocusManager:unfocus()
	self:getFocusedView():setFocus(false)
end

function FocusManager:addView(view, row)
	assert(view.setFocus ~= nil, "Views added to FocusManager must have a setFocus(bool) method")
	view:setFocus(false)
	if(#self.viewMatrix < row) then self.viewMatrix[row] = {} end
	table.insert(self.viewMatrix[row], view)
end

function FocusManager:getView(row, index)
	return self.viewMatrix[row][index]
end

function FocusManager:getFocusedView()
	return self.viewMatrix[self.activeRow][self.activeIndex]
end

function FocusManager:getActiveRow()
	return self.viewMatrix[self.activeRow]
end

function FocusManager:getRowSize(row)
	return #self.viewMatrix[row]
end

function FocusManager:turnFocusedView(degrees)
	if(degrees == 0.0 or self:isHandlingInput() == false)then return end --indicates no change from crank in this frame
	local active = self:getFocusedView()
	if(active.turn ~= nill) then active:turn(degrees) end
end

function FocusManager:push() 
	playdate.inputHandlers.push(self:getInputHandler())
	self.handlingInput = true
end

function FocusManager:pop() 
	playdate.inputHandlers.pop() 
	self.handlingInput = false
end

function FocusManager:isHandlingInput()
	return self.handlingInput
end

-- See https://sdk.play.date/1.12.3/Inside%20Playdate.html#M-inputHandlers
function FocusManager:getInputHandler()
	return {
		leftButtonDown = function()
			if(self.activeIndex > 1) then
				self:getFocusedView():setFocus(false)
				self.activeIndex -= 1
				self:getFocusedView():setFocus(true)
			end
		end,
		rightButtonDown = function()
			if(self.activeIndex < #self:getActiveRow()) then
				self:getFocusedView():setFocus(false)
				self.activeIndex += 1
				self:getFocusedView():setFocus(true)
			end
		end,
		upButtonDown = function()
			if(self.activeRow > 1)then
				self:getFocusedView():setFocus(false)
				local prevRowCount = self:getRowSize(self.activeRow - 1)
				if(prevRowCount < self.activeIndex)then self.activeIndex = prevRowCount end
				self.activeRow -= 1
				self:getFocusedView():setFocus(true)
			end
		end,
		downButtonDown = function()
			if(self.activeRow < #self.viewMatrix)then
				self:getFocusedView():setFocus(false)
				local nextRowCount = self:getRowSize(self.activeRow + 1)
				if(nextRowCount < self.activeIndex)then self.activeIndex = nextRowCount end
				self.activeRow += 1
				self:getFocusedView():setFocus(true)
			end
		end
	}
end
