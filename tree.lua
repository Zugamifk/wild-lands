Tree = {
	log = false,
	type = "Tree",
	colors = {
		sprout = {Color.Create(238,234,32), Color.Create(192,216,120)},
		budding = {Color.Create(9,95,31), Color.Create(51,228,109)},
		seeding = {Color.Create(59,159,84), Color.Create(51,167,228)}
	}
}

function Tree:ToString()
	return "[TREE age: "..self.age.."]"
end

function Tree.GenerateGenome()
	local genes = {}
	for i=1,10 do
		genes[i] = Genome.alphabet()
	end
	local genome = Genome.Create(genes)
	return genome
end

function Tree:GenerateInitialStats(genome)
	local g1 = genome.parser(genome.genes[1])
	local branchBaseHeight = g1*3+1
	local g2 = genome.parser(genome.genes[2])
	local branchGrowHeight = g2*0.5+0.25
	local g3 = genome.parser(genome.genes[3])
	local colorbias = g3
	self.stats = {
		branchBaseHeight = branchBaseHeight,
		branchGrowHeight = branchGrowHeight,
		colorBias = colorbias
	}
end
-- constructor
function Tree.Create(x,y, genome)
	
	if not genome then genome = Tree.GenerateGenome() end
	genome.parser = function(b) return Genome.parser[b]/25 end
	
	local t = {
		age = 0,
		seeds = {
			state = "sprout",
			age = 0
		},
		position = {x=x,y=y},
		genome = genome
	}
	
	Tree.GenerateInitialStats(t, genome)
	
	local dye = {}
	t.color = function()
		local c = Tree.colors[t.seeds.state]
		Color.Blend(c[1], c[2], t.stats.colorBias, dye)
		return Color.Unpack(dye)
	end
	
	setmetatable(t, {__index = Tree, __tostring = Tree.ToString})
	
	if Tree.log then console:Log("generating tree") end
	
	return t
end

function Tree:Draw(context)
	local w = context.width
	local h = context.height
	local x = context.x
	local y = context.y
	
	local rx = x + w/2
	local ry = y + h/2
	local ge = function(x) return 1-math.exp(-x) end
	
	local st = self.stats
	
	local by = ry-ge(self.age)*h*st.branchGrowHeight-h/st.branchBaseHeight
	local s = self.seeds.state

	love.graphics.setColor(self.color())
	
	love.graphics.line(rx,ry,rx,by)
	local bl = ge(self.age/4)*w*0.75+w/3
	local th = by-ge(self.age)*h*4-h
	love.graphics.polygon("fill", rx-bl,by, rx+bl,by, rx,th)
end

function Tree:Update(dt, q)
dt = dt*5
	self.age = self.age + dt
	local s = self.seeds
	if s.state ~= "sprout" or self.age>20 then
		if self.age > 50 then
			q(self:Die())
		elseif s.state == "sprout" then
			s.state = "budding"
			s.age = 0
		elseif s.state == "budding" then
			if s.age > 10 then
				s.state = "seeding"
			end
		elseif s.state == "seeding" then
			if self.age > 12 then
				s.state = "budding"
				s.age = 0
				q(self:Seed())
			end
		end
		s.age = s.age + dt
	end
end

function Tree:Seed()
	return function() 
			return {
				name = "spawnObject",
				task = function()
					local x=self.position.x
					local y = self.position.y
					local genes = GenePool.Breed(self.genome, self.genome)
					local t = Tree.Create(x+love.math.random(10)-5,y+love.math.random(10)-5, genes)
					return t
				end
			} 
		end
end

function Tree:Die()
	return function() 
			return {
				name = "removeObject",
				task = function()
					return self
				end
			} 
	end
end