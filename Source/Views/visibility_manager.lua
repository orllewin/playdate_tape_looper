class('VisibilityManager').extends()

-- Handles view visibility, all views must be sprite subclasses 
function VisibilityManager:init()
	VisibilityManager.super.init(self)
	
	self.views = {}
	self.hidden = false
end

function VisibilityManager:addView(view)
	table.insert(self.views, view)
end

function VisibilityManager:addViews(views)
	for i=1,#views do
		table.insert(self.views, views[i])
	end
end

function VisibilityManager:isHidden()	return self.hidden end
function VisibilityManager:isShowing() return not self.hidden end

function VisibilityManager:show()
	for i=1,#self.views do
		local sprite = self.views[i]
		sprite:add()
		if sprite.addChildren then sprite:addChildren() end
	end
	self.hidden = false
end

function VisibilityManager:hide()
	for i=1,#self.views do
		local sprite = self.views[i]
		sprite:remove()
		if sprite.removeChildren then sprite:removeChildren() end
	end
	self.hidden = true
end