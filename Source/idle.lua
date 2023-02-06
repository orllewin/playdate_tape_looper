class('Idle').extends()

function Idle:init(onStartRecording)
	Idle.super.init(self)
	
	self.onStartRecording = onStartRecording
end

function Idle:push() playdate.inputHandlers.push(self:getInputHandler()) end

function Idle:pop() playdate.inputHandlers.pop() end

function Idle:getInputHandler()
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
		AButtonDown = function()
			--NOOP
		end,
		BButtonDown = function()
			if(self.onStartRecording ~= nil)then self.onStartRecording() end
		end
	}
end