CameraControl = {
	
}

function CameraControl.Create(camera)
	return setmetatable({camera = camera}, {__index = CameraControl})
end

function CameraControl:Update(events)
	local c = self.camera
	if events.w then
		c.y = c.y-5
	end
	if events.a then
		c.x = c.x-5
	end
	if events.s then
		c.y = c.y+5
	end
	if events.d then
		c.x = c.x+5
	end
	if events.mousewheelX then
		self:SetSize (c.size+mathx.sign(events.mousewheelX.event))
	end
	if events.mousewheelY then
		self:SetSize(c.size+mathx.sign(events.mousewheelY.event))
	end
end

function CameraControl:SetSize(size)
	local c = self.camera
	c.size = size
	if c.size < 1 then c.size = 1 end
end