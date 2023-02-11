class('Spindles').extends()

SPINDLE_REC = 0
SPINDLE_PLAY = 1

function Spindles:init()
	Spindles.super.init(self)
	
	self.spindleAngle = 0
	
	self.playX = 305
	self.playY = 38
	self.playScale = 0.4
	self.playGap = 60
	
	self.recX = 150
	self.recY = 120
	self.recScale = 1.15
	self.recGap = 160

	self.mode = SPINDLE_REC
	
	local spindleImage = playdate.graphics.image.new("Images/large_spindle")
	self.leftSpindle = playdate.graphics.sprite.new(spindleImage)
	self.rightSpindle = playdate.graphics.sprite.new(spindleImage)
		
	self:reposition()
	self.leftSpindle:add()
	self.rightSpindle:add()
end

function Spindles:recordingMode()
	self.mode = SPINDLE_REC
	self:reposition()
end

function Spindles:playMode()
	self.mode = SPINDLE_PLAY
	self:reposition()
end

function Spindles:reposition()
	if(self.mode == SPINDLE_REC)then
		print("Spindles:reposition() SPINDLE_REC")
		self.leftSpindle:setScale(self.recScale)
		self.rightSpindle:setScale(self.recScale)
		self.leftSpindle:moveTo(self.recX, self.recY)
		self.rightSpindle:moveTo(self.recX + self.recGap, self.recY)
	elseif(self.mode == SPINDLE_PLAY)then
		print("Spindles:reposition() SPINDLE_PLAY")
		self.leftSpindle:setScale(self.playScale)
		self.rightSpindle:setScale(self.playScale)
		self.leftSpindle:moveTo(self.playX, self.playY)
		self.rightSpindle:moveTo(self.playX + self.playGap, self.playY)
	end
end

function Spindles:inc(angle)
	local a = self:getAngle() += angle
	if(a > 358) then a = 0 end
	self:setRotation(a)
end

function Spindles:dec(angle)
	self:setRotation(self:getAngle() += angle)
end

function Spindles:getAngle()
	return self.leftSpindle:getRotation()
end
function Spindles:setRotation(angle)
		self.leftSpindle:setRotation(angle)
		self.rightSpindle:setRotation(angle)
end