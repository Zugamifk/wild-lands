Console = {}

function Console.Create()
	local console= {}
	console.log = {}
	console.size = 1000
	console.head = 1
	console.lineHeight = 15
	console.enabled = true
	console.control = {
		Update = function(self, events)
			if events["`"] and events["`"].event == "pressed" then
				console.enabled = not console.enabled
			end
		end
	}
	return setmetatable(console, {__index = Console})
end

function Console:Log(message)
	self.log[self.head] = message
	self.head = self.head + 1
	if self.head > self.size then
		self.head = 1
	end
end

function Console:GetMessage(index)
	index = self.head-1-index
	while index > self.size do
		index = index - self.size
	end
	return self.log[index]
end

function Console:DrawStats(x,y,w,h)
	love.graphics.setColor(123,194,200,255)
	love.graphics.print("FPS: "..love.timer.getFPS().."\tAverage Delta: "..love.timer.getAverageDelta(), x+5, y+15)
end

function Console:Draw(x,y,w,h)
	if self.enabled then
		love.graphics.setColor(17,21,32,180)
		love.graphics.rectangle("fill", x,y,w,h)
		love.graphics.setColor(154,85,70,255)
		love.graphics.rectangle("line", x,y,w,h)
		
		self:DrawStats(x,y,w,30)
		y = y + 30
		h = h - 30
		
		love.graphics.stencil(
			function()
				love.graphics.rectangle("fill", x+5,y+5,w-10,h-10)
			end,
			"replace",
			1)
		love.graphics.setStencilTest("greater", 0)
		love.graphics.setColor(139,138,118,255)
		local lineNum = h/self.lineHeight
		for i=0,lineNum-1 do
			local msg = self:GetMessage(i)
			if msg then
				love.graphics.print(msg,x + 15, y+h-25-i*self.lineHeight)
			end
		end
		love.graphics.setStencilTest()
	end
end