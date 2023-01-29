-- Playdate Coracle: Circle
-- Copyright (C) 2022 Orllewin
import 'Coracle/point'

class('Circle').extends()

function Circle:init(x, y, r)
	 Circle.super.init(self)
	 self.x = x or 0
	 self.y = y or 0
	 self.r = r or 10
end

function Circle:draw()
	if(coracleDrawMode == DrawingMode.FillAndStroke)
  	then
		playdate.graphics.fillCircleAtPoint(self.x, self.y, self.r)
		playdate.graphics.drawCircleAtPoint(self.x, self.y, self.r)
  	elseif(coracleDrawMode == DrawingMode.Fill)
  	then
		playdate.graphics.fillCircleAtPoint(self.x, self.y, self.r)
  	else
		playdate.graphics.drawCircleAtPoint(self.x, self.y, self.r)
  	end
end

function Circle:originDistance(other)
	local dx = self.x - other.x
	local dy = self.y - other.y
	return math.sqrt(dx * dx + dy * dy)
end


function Circle:collides(other)
	if(self:originDistance(other) <= (self.r + other.r))then
		return true
	else
		return false	
	end
end

function Circle:origin()
	return Point(self.x, self.y)
end