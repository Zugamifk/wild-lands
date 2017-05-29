Input = {
	events = {}
}

function Input:GenerateEvent(scancode, event)
	self.events[scancode] = {event=event} 
end

function Input:DoEvents(context)
	context:Update(self.events)
end

function Input:Update()
	local count = 0
	for k,e in pairs(self.events) do
		count = count +1
		if k == "mousebutton" then
			if love.mouse.isDown(e.event.button) then
				e.event.buttonEvent = "held"
				e.event.x, e.event.y = love.mouse.getPosition()
			else
				self.events[k] = nil
			end
		elseif love.keyboard.isDown(k) then
			e.event = "held"
		else
			self.events[k] = nil
		end
	end
	--if count > 0 then 
	--	console:Log(Input)
	--end
end

function Input:ToString()
	local result = "Input: "
	for k,e in pairs(self.events) do
		result = result.."\n\t\""..k.."\""--.."\t"..e.event
	end
	return result
end

setmetatable(Input, {__tostring = Input.ToString})