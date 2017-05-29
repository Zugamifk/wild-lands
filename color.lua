Color = {
}
function Color:ToString()
	return "[Color r: "..self.r.." g: "..self.g.." b: "..self.b.." a: "..self.a.."]"
end

-- constructor
function Color.Create(r,g,b,a)
	local c = {
		r = r,g=g,b=b,a=a or 255
	}
	setmetatable(c, {__index = Color, __tostring = Color.ToString})
	return c
end

function Color.Blend(a,b,x,c)
	c = c or {}
	c.r = a.r + (b.r-a.r)*x
	c.g = a.g + (b.g-a.g)*x
	c.b = a.b + (b.b-a.b)*x
	c.a = a.a + (b.a-a.a)*x
	return c
end

function Color:Unpack()
	return self.r, self.g, self.b, self.a
end