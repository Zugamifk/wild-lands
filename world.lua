World = {
log = false
}

function World.Create(width, height)
	local w = {
		tiles = {},
		tileCount = 0,
		tasks = {}
	}
	setmetatable(w, {__index = World})
	return w
end

function World:QueueTask(f)
	self.tasks[#self.tasks+1]=f
end

function World:GetTile(x,y, generate)
	generate = generate == nil or generate
	x = math.floor(x)
	y = math.floor(y)
	if not self.tiles[x] then
		if generate then 
			self.tiles[x] = {}
			if self.log then console:Log("generating row at "..x) end
		else return nil end
	end
	if not self.tiles[x][y] then  
		if generate then 
			local tile = Tile.Create(x,y)
			tile.heat = love.math.random(100)
			self:AddTile(x,y,tile)
			self.tileCount = self.tileCount +1
			if self.log then console:Log("tile count: "..self.tileCount) end
		else return nil end
	end
	return self.tiles[x][y]
end

function World:GetTiles(x,y,w,h)
	local xi = math.floor(x)
	local yi = math.floor(y)
	xi = math.max(xi,1)
	yi = math.max(yi,1)
	w = math.ceil(x+w)-xi
	h = math.ceil(y+h)-yi
	local x0 = xi
	local X = xi+w
	local Y = yi+h
	--console:Log("GetTiles: x "..x..", y "..y..", w "..w..", h "..h)
	return function()
		if xi < X and yi < Y then
			local t = self:GetTile(xi,yi)
			xi = xi + 1
			if xi == X then 
				xi = x0
				yi = yi + 1
			end
			return t
		end
	end
end

function World:AddTile(x,y,tile)

	local oldTile = self:GetTile(x,y,false)
	if oldTile then
		self:RemoveTile(x,y)
	end
	
	if not self.tiles[x] then self.tiles[x] = {} end
	self.tiles[x][y] = tile	
	
	local left = self:GetTile(x-1,y, false)
	if left then tile:SetNeighbour(left, "left") end
	
	local right = self:GetTile(x+1,y, false)
	if right then tile:SetNeighbour(right, "right") end
	
	local top = self:GetTile(x,y-1, false)
	if top then tile:SetNeighbour(top, "top") end
	
	local bottom = self:GetTile(x,y+1, false)
	if bottom then tile:SetNeighbour(bottom, "bottom") end
	
	assert(self.tiles[x][y], "No tile!")
end

function World:RemoveTile(x,y)
	local tile = self:GetTile(x,y,false)
	if tile then
		tile.neighbours = nil
		self.tiles[x][y] = nil
		if table.getn(self.tiles[x]) == 0 then
			self.tiles[x] = nil
		end
	end
end

function World:Update(dt)
	local tilecount = 0
	for x=1,table.getn(self.tiles) do
		local r = self.tiles[x]
		if r then
			for y = 1,table.getn(r) do
				local c = r[y]
				if c then 
					c:Update(dt, function(f) self:QueueTask(f) end)
					tilecount = tilecount + 1
				end
			end
		end
	end
	for i,f in ipairs(self.tasks) do
		self:DoTask(f)
	end
	
	if self.log and #self.tasks > 0 then 
		console:Log("did tasks: "..#self.tasks)
	end
	self.tasks = {}
	--console:Log("updated "..tilecount.." tiles!")
end

function World:DoTask(f)
	local taskData = f()
	if taskData then
		if taskData.name == "spawnObject" then
			local o = taskData.task()
			local t = self:GetTile(o.position.x, o.position.y)
			if not t.objects[o.type] then
				t:AddObject(o)
			end
			if self.log then console:Log("spawned object: "..tostring(o)) end
		elseif taskData.name == "removeObject" then
			local o = taskData.task()
			local t = self:GetTile(o.position.x, o.position.y)
			if not t.objects[o.type] then
				t:RemoveObject(o)
			end
			if self.log then console:Log("removed object: "..tostring(o)) end
		end
	end
end