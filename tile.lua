Tile = {
	side = {
		"left",
		"top",
		"right",
		"bottom"
	},
	
	log = false
}

-- constructor
function Tile.Create(x, y)
	local t = {
		position = {
			x = x, y = y
		},
		neighbours = {},
		objects = {}
	}
	setmetatable(t, {__index = Tile})
	if Tile.log then console:Log("generating tile at ["..x..", "..y.."]") end
	return t
end

-- methods

-- Draw: draws a tile
-- context: contains information about where and how to draw the tile
-- drawer: object that draws the tile
function Tile:Draw(context)
	local w = context.width
	local h = context.height
	local x = context.x
	local y = context.y
	if context.layer == "terrain" then
		love.graphics.setColor(
			heat.sampler(self.heat/100))
		love.graphics.rectangle("fill", x, y, w, h)
		if w > 25 and h > 15 then
			love.graphics.setColor(0,0,0,255)
			love.graphics.print(math.floor(self.heat), x+5, y+3)
		end
	elseif context.layer == "objects" then
		for t,o in pairs(self.objects) do
			o:Draw(context)
		end
	end
end

function Tile:Update(dt, q)
	local speed = 0.5
	for s,t in pairs(self.neighbours) do
		local d = self.heat - t.heat
		self.heat = self.heat - speed * dt * d * speed
		t.heat = t.heat + speed * dt * d * speed
	end
		for t,o in pairs(self.objects) do
		o:Update(dt, q)
	end
	self.heat = self.heat - 5*speed*dt
	self.heat = math.max(self.heat,0)
end

function Tile.GetOppositeSide(side)
	if side == "left" then return "right" end
	if side == "right" then return "left" end
	if side == "top" then return "bottom" end
	if side == "bottom" then return "left" end
end

function Tile:SetNeighbour(tile, side)
	self.neighbours[side] = tile
	tile.neighbours[Tile.GetOppositeSide(side)] = self
end

function Tile:AddObject(object)
	self.objects[object.type] = object
	object.position = self.position
	console:Log("added object: "..tostring(object))
end

function Tile:RemoveObject(object)
	self.object[object.type] = nil
	console:Log("removed object: "..tostring(object))
end