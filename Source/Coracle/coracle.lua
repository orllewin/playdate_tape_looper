import 'CoreLibs/graphics'
import 'CoreLibs/object'

local graphics <const> = playdate.graphics
local _cos, _sin, _sqrt, _min, _max = math.cos, math.sin, math.sqrt, math.min, math.max
local _random = math.random

width = 400
height = 240
alpha = 1.0
pi = 3.14159265
tau = 6.28318
e = 2.71828 --Euler's number

DrawingMode = {Stroke = "0", Fill = "1"}
coracleDrawMode = DrawingMode.Fill

function invertDisplay()
	playdate.display.setInverted(true)
end

function scaleDisplay(scale)
  if(scale == 1)then
    width = 400
    height = 240
    playdate.display.setScale(1)
  elseif(scale == 2)then
    width = 200
    height = 120
    playdate.display.setScale(2)
  elseif(scale == 4)then
    width = 100
    height = 60
    playdate.display.setScale(4)
  elseif(scale == 8)then
    width = 50
    height = 30
    playdate.display.setScale(8)
  else
    print("Invalid scale value, use 1, 2, 4, or 8")
  end
end

function crankChange()
	local change, acceleratedChange = playdate.getCrankChange()
	return change
end

function aPressed()
  return playdate.buttonJustPressed(playdate.kButtonA)
end

function bPressed()
  return playdate.buttonJustPressed(playdate.kButtonB)
end

function upPressed()
  return playdate.buttonIsPressed(playdate.kButtonUp)
end

function upJustPressed()
  return playdate.buttonJustPressed(playdate.kButtonUp)
end

function downPressed()
  return playdate.buttonIsPressed(playdate.kButtonDown)
end

function leftPressed()
  return playdate.buttonIsPressed(playdate.kButtonLeft)
end

function leftJustPressed()
  return playdate.buttonJustPressed(playdate.kButtonLeft)
end

function rightPressed()
  return playdate.buttonIsPressed(playdate.kButtonRight)
end

function rightJustPressed()
  return playdate.buttonJustPressed(playdate.kButtonRight)
end

function background()
  graphics.clear(graphics.kColorWhite)
end

function noStroke()
  coracleDrawMode = DrawingMode.Fill
end

function noFill()
  coracleDrawMode = DrawingMode.Stroke
  graphics.setDitherPattern(0.0, playdate.graphics.image.kDitherTypeScreen)
end

function stroke()
 coracleDrawMode = DrawingMode.Stroke
end

function fill()
  coracleDrawMode = DrawingMode.Fill
end

-- alpha: 0.0 to 1.0
function fill(_alpha)
  alpha = _alpha
  graphics.setDitherPattern(1.0 - alpha, playdate.graphics.image.kDitherTypeBayer8x8)
  coracleDrawMode = DrawingMode.Fill
end

-- Maths
function map(value, start1, stop1, start2, stop2)
  return start2 + (stop2 - start2) * ((value - start1) / (stop1 - start1))
end

function random(a, b)
	return math.random(a, b)
end

function min(a, b)
  return _min(a, b)
end

function max(a, b)
  return _max(a, b)
end

function cos(value)
	return _cos(value)
end

function sin(value)
	return _sin(value)
end

function sqrt(value)
  return _sqrt(value)
end

function fastSqrt(value, exponent)
    return value^exponent
end

function random(a, b)
  if(a == nil and b == nil)then
    return _random()
  elseif(b == nil)then
    return _random(a)
  else
    return _random(a, b)
  end
end

function perlinNoise(x, y)
	return playdate.graphics.perlin(x, y, 1)
end

-- Draw

function text(text, x, y)
  graphics.drawText(text, x, y)
end

function rect(x, y, width, height)
  if(coracleDrawMode == DrawingMode.Fill) then
    graphics.fillRect(x, y, width, height)
  else
    graphics.drawRect(x, y, width, height)
  end
end

function roundedRect(x, y, width, height, cornerRadius)
  if(coracleDrawMode == DrawingMode.Fill) then
    graphics.fillRoundRect(x, y, width, height, cornerRadius)
  else
    graphics.drawRoundRect(x, y, width, height, cornerRadius)
  end
end

function circle(x, y, r)
	if(coracleDrawMode == DrawingMode.Fill) then
		graphics.fillCircleAtPoint(x, y, r)
	else
		graphics.drawCircleAtPoint(x, y, r)
	end
end

function circleP(p, r)
	if(coracleDrawMode == DrawingMode.Fill)
	  then
		graphics.fillCircleAtPoint(p.x, p.y, r)
	  else
		graphics.drawCircleAtPoint(p.x, p.y, r)
	  end
end

function circleV(vector, r)
	if(coracleDrawMode == DrawingMode.Fill)
	  then
		graphics.fillCircleAtPoint(vector.x, vector.y, r)
	  else
		graphics.drawCircleAtPoint(vector.x, vector.y, r)
	  end
end

function triangle(x1, y1, x2, y2, x3, y3)
  if(coracleDrawMode == DrawingMode.Fill) then
    graphics.fillTriangle(x1, y1, x2, y2, x3, y3)
  else
    graphics.drawTriangle(x1, y1, x2, y2, x3, y3)
  end
end

function point(x, y)
	graphics.drawPixel(x, y)
end

function line(x1, y1, x2, y2)
	graphics.drawLine(x1, y1, x2, y2)
end