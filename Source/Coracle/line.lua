-- Playdate Coracle: Line
-- Copyright (C) 2022 Orllewin
import 'Coracle/point'
import 'Coracle/vector'

class('Line').extends()

function Line:init(x1, y1, x2, y2)
	 Line.super.init(self)
	 self.x1 = x1 or 0
	 self.y1 = y1 or 0
	 self.x2 = x2 or width
	 self.y2 = 22 or height
end

function Line:update(p1, p2)
	self.x1 = p1.x
	self.y1 = p1.y
	self.x2 = p2.x
	self.y2 = p2.y
end

function Line:intersects(other)
	local a1 = self.y2 - self.y1
	local b1 = self.x1 - self.x2
	local c1 = a1 * self.x1 + b1 * self.y1
	
	local a2 = other.y2 - other.y1
	local b2 = other.x1 - other.x2
	local c2 = a2 * other.x1 + b2 * other.y1
	
	local delta = a1 * b2 - a2 * b1
	
	local iX = (b2 * c1 - b1 * c2) / delta
	local iY = (a1 * c2 - a2 * c1) / delta
	
	if(math.min(self.x1, self.x2) < iX and math.max(self.x1, self.x2) > iX and math.min(other.x1, other.x2) < iX and math.max(other.x1, other.x2) > iX)then
		return Vector(iX, iY)
	else
		return Vector(-1, -1)
	end
	
end

function Line:draw()
	playdate.graphics.drawLine(self.x1, self.y1, self.x2, self.y2)
end