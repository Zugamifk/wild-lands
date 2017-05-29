WorldControl = {}

function WorldControl.Create(world, camera)
	return setmetatable({world = world, camera = camera}, {__index = WorldControl})
end

function WorldControl:Update(events)
	local w = self.world
	local c = self.camera
	if events.mousebutton then
		local e = events.mousebutton.event
		if e.button == 1 then 
			local x,y = c:ScreenToWorldPosition(e.x, e.y)
			local tile = w:GetTile(x,y)
			local tree = Tree.Create()
			tile:AddObject(tree)
		--console:Log("pressed on "..tile.position.x..", "..tile.position.y)
		elseif e.button == 2 then 
			local x,y = c:ScreenToWorldPosition(e.x, e.y)
			local tile = w:GetTile(x,y)
			tile.heat = 100
		--console:Log("pressed on "..tile.position.x..", "..tile.position.y)
		end
	end
end