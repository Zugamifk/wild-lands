Genome = {
	log = true,
	alphabet = function()
		return love.math.random(97,122)
	end,
	parser = setmetatable({}, {__index = function(t,k) return k-97 end})
}

function Genome:GeneString()
	return string.char(unpack(self.genes))
end

function Genome:ToString()
	return "[Genome genes: "..self:GeneString().."]"
end

-- constructor
function Genome.Create(genes)
	if type(genes) == "string" then
		genes = {string.byte(genes,1,genes:len())}
	else
		local ng = {}
		for _,v in ipairs(genes) do
			table.insert(ng, v)
		end
		genes = ng
	end
	local g = {
		genes = genes
	}
	setmetatable(g, {__index = Genome, __tostring = Genome.ToString})
	if Genome.log then console:Log(tostring(g)) end
	return g
end

function Genome:Copy()
	return Genome.Create(self.genes)
end

function Genome:Cross(other)
	local g = self.genes
	local h = other.genes
	local cross = function(a,b,x)
		local l = math.max(#a, #b)
		for i = x, l do
			if i > #a then
				table.insert(a, i, b[i])
				b[i] = nil
			elseif i > #b then
				table.insert(b, i, a[i])
				a[i] = nil
			else
				local c = a[i]
				a[i] = b[i]
				b[i] = c
			end			
		end
	end
	local c = love.math.random(0,2)
	for i=1,c do
		local x = love.math.random(#g)
		cross(g,h,x)
	end
	self.genes = g
	other.genes = h
end

function Genome:Mutate()
	local pos = love.math.random(#self.genes)
	self.genes[pos] = self.alphabet()
end