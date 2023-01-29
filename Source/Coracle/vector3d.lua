class('Vector3D').extends()

local sqrt <const> = math.sqrt
local cos <const> = math.cos
local sin <const> = math.sin

function Vector3D:init(x, y, z)
	 Vector3D.super.init(self)
	 self.x = x or 0
	 self.y = y or 0
	 self.z = z or 0
end

function Vector3D:isoX(originX)
	local xCart = ( self.x - self.z ) * cos(0.46365)
	local xx = xCart + originX
	return xx
end

function Vector3D:isoY(originY) 
	local yCart = self.y + ( self.x + self.z) * sin(0.46365);
	local yy = 0 - yCart + originY 
	return yy
end

function distance(other)
	local d =((other.x - self.x)^2) + ((other.y - self.y)^2) + ((other.z - self.z)^ 2) ^ 0.5
	return d
end
