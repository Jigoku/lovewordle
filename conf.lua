name = "wordle"
author = "ricky thomson"
version = "0.1"
default_width = 1024
default_height = 768

function love.conf(t)
	t.identity = "wordle"
	t.version = "11.3"
	t.window.title = name
	t.window.width = default_width
	t.window.height = default_height
	t.window.minwidth = default_width
	t.window.minheight = default_height
	t.modules.joystick = false
	t.modules.physics = false
	t.modules.touch = false
	t.modules.video = false
	t.window.msaa = 0
	t.window.fsaa = 0
	t.window.display = 1
	t.window.resizable = false
	t.window.vsync = false
	t.window.fullscreen = false
end
