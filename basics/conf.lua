-- conf.lua
--
-- @about Describes the configuration of the game.

-- @brief Config function called before any other function.
-- @param t Table holding configuration settings.
function love.conf(t)
	-- misc
	t.version = "11.2"		-- LÖVE version this game was made for
	t.console = false
	t.gammacorrect = false

	-- audio
	t.audio.mixwithsysem = true

	-- window
	t.window.title = "Game Basics"
	t.window.icon = "assets/logo.png"
	t.window.width = 800
	t.window.height = 600
	t.window.borderless = false
	t.window.resizable = false
	t.window.fullscreen = false
	t.window.fullscreentype = "desktop"
	t.window.vsync = 1
	t.window.msaa = 0
	t.window.depth = 0
	t.window.display = 1
	t.window.x = nil
	t.window.y = nil

	-- modules
	t.modules.joystick = false
	t.modules.touch = false
	t.modules.video = false
end
