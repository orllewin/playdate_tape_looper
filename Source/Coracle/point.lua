class('Point').extends()

function Point:init(x, y)
	 Point.super.init(self)
	 self.x = x or 0
	 self.y = y or 0
end