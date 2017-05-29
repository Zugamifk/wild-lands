require "mathx"
require "gradient"
require "console"
require "color"
require "genome"
require "genepool"
require "tile"
require "tree"
require "world"
require "camera"
require "input"
require "cameracontrol"
require "worldcontrol"

function love.load()
	console = Console.Create()
	local dx, dy = love.graphics.getDimensions()
	camera = Camera.Create(5,5,dx,dy, 10)
	cameracontrol = CameraControl.Create(camera)
	world = World.Create(100,100)
	worldcontrol = WorldControl.Create(world, camera)
	heat = Gradient.Create({55,39,53,255}, {219,6,2,255},{219,89,2,255},{219,151,2,255},{217,179,108,255})
	longTime = 0
	GenePool.Init()
end

function love.draw()
	camera:Draw(world)
    love.graphics.print(camera:ToString(), 400, 300)
	love.graphics.print(Input:ToString(), 100, 300)
	console:Draw(0,0,300,500)
end

function love.update(dt)
	Input:DoEvents(cameracontrol)
	Input:DoEvents(worldcontrol)
	Input:DoEvents(console.control)
	Input:DoEvents(GenePool.control)
	Input:Update()
	
	longTime = longTime + dt
	local int = 0.1
	if longTime > int then 
		world:Update(longTime)
		longTime = longTime - int
	end
end

function love.keypressed( key, scancode, isrepeat )
	Input:GenerateEvent(scancode, "pressed")
	console:Log("pressed "..scancode.." key: "..key)
end

function love.wheelmoved( x, y )
	Input:GenerateEvent("mousewheelX", x)
	Input:GenerateEvent("mousewheelY", y)
	console:Log("mousewheel: "..x..", "..y)
end

function love.mousepressed( x, y, button, istouch )
	Input:GenerateEvent("mousebutton", {x=x,y=y,button=button,buttonEvent="pressed"})
	console:Log("mousebutton: "..button..", "..x..", "..y)
end