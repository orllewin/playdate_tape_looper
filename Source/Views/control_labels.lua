class('ControlLabels').extends(playdate.graphics.sprite)

local STATE_REC_READY, STATE_REC, STATE_PLAY_READY, STATE_PLAYING_LOOPER, STATE_PLAYING_EFFECTS = 0, 1, 2, 3, 4

local INACTIVE = playdate.graphics.image.kDitherTypeBayer2x2

local textY = 233

function ControlLabels:init(font)
	ControlLabels.super.init(self)
	self.font = font
	self.viewWidth = 170
	self.viewHeight = 10
	self.state = -1
	
	self:setRecordReady()
	self:add()
end

function ControlLabels:setRecordReady()
	if(self.state == STATE_REC_READY)then return end
	playdate.graphics.setFont(self.font)
	self.state = STATE_REC_READY
	local image = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
	playdate.graphics.pushContext(image)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		self.font:drawText("REC.", 7, 0)
		
		local playFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(playFaded)
			self.font:drawText("PLAY", 10, 0)
		playdate.graphics.popContext()
		playFaded:drawFaded(90, 0, 0.35, INACTIVE)
		
	playdate.graphics.popContext()
	self:setImage(image)
	self:moveTo(335, textY)
end

function ControlLabels:setRecording()
	if(self.state == STATE_REC)then return end
	playdate.graphics.setFont(self.font)
	self.state = STATE_REC
	local image = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
	playdate.graphics.pushContext(image)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		self.font:drawText("STOP", 6, 0)
		
		local playFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(playFaded)
			self.font:drawText("PLAY", 6, 0)
		playdate.graphics.popContext()
		playFaded:drawFaded(93, 0, 0.35, INACTIVE)
		
	playdate.graphics.popContext()
	self:setImage(image)
	self:moveTo(335, textY)
end

function ControlLabels:setPlayReady()
	if(self.state == STATE_PLAY_READY)then return end
	playdate.graphics.setFont(self.font)
	self.state = STATE_PLAY_READY
	local image = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
	playdate.graphics.pushContext(image)
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)
		self.font:drawText("REC.", 6, 0)
		
		local playFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(playFaded)
			self.font:drawText("PLAY", 6, 0)
		playdate.graphics.popContext()
		playFaded:draw(93, 0)
		
	playdate.graphics.popContext()
	self:setImage(image)
	self:moveTo(335, textY)
end

function ControlLabels:setPlayingLooper()
	if(self.state == STATE_PLAYING_LOOPER)then return end
	playdate.graphics.setFont(self.font)
	self.state = STATE_PLAYING_LOOPER
	local image = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
	playdate.graphics.pushContext(image)
	
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)		
		local recFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(recFaded)
			self.font:drawText("EFX", 6, 0)
		playdate.graphics.popContext()
		recFaded:draw(0, 0)
		
		local playFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(playFaded)
			self.font:drawText("STOP", 6, 0)
		playdate.graphics.popContext()
		playFaded:draw(93, 0)
		
	playdate.graphics.popContext()
	self:setImage(image)
	self:moveTo(335, textY)
end

function ControlLabels:setPlayingEffects()
	if(self.state == STATE_PLAYING_EFFECTS)then return end
	playdate.graphics.setFont(self.font)
	self.state = STATE_PLAYING_EFFECTS
	local image = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
	playdate.graphics.pushContext(image)
	
		playdate.graphics.setImageDrawMode(playdate.graphics.kDrawModeFillWhite)		
		local recFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(recFaded)
			self.font:drawText("LOOP", 6, 0)
		playdate.graphics.popContext()
		recFaded:draw(0, 0)
		
		local playFaded = playdate.graphics.image.new(self.viewWidth, self.viewHeight)
		playdate.graphics.pushContext(playFaded)
			self.font:drawText("STOP", 6, 0)
		playdate.graphics.popContext()
		playFaded:draw(93, 0)
		
	playdate.graphics.popContext()
	self:setImage(image)
	self:moveTo(335, textY)
end