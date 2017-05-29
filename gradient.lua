Gradient = {}

function Gradient.Create(...)
	local gradient = {}
	gradient.colors = {...}
	gradient.sampleCount = table.getn(gradient.colors)
	gradient.sampler = Gradient.GetSampler(gradient, Blend)
	return setmetatable(gradient, {__index = Gradient})
end

local function Lerp(a,b,x)
	return a + (b-a)*x
end

local function Blend(colorA, colorB, blend)
	return {
		Lerp(colorA[1], colorB[1], blend),
		Lerp(colorA[2], colorB[2], blend),
		Lerp(colorA[3], colorB[3], blend),
		Lerp(colorA[4], colorB[4], blend)
	}
end

function Gradient:GetSampler(blend)
	return function(x)
		if self.sampleCount == 0 then
			return {0,0,0,0}
		elseif self.sampleCount == 1 then	
			return self.colors[1]
		else
			x = math.max(x,0)
			local _, x0 = math.modf(x)
			local x0, b = math.modf(x0*(self.sampleCount-1))
			x0 = x0 + 1
			if x0 >= self.sampleCount then
				x0 = x0-1
				b = 1
			end
			return Blend(self.colors[x0], self.colors[x0+1], b)
		end
	end
end