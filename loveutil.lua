local loveutil = {} -- Table of utility functions for the love2d framework

function loveutil.height()
	return love.window.getHeight()
end

function loveutil.width()
	return love.window.getWidth()
end

function loveutil.getMaxResolution()
	local modes = love.window.getFullscreenModes()
	table.sort(modes, function(a, b) return a.width*a.height > b.width*b.height end) -- sort from largest to smallest
	return modes[1]
end

function loveutil.goFullscreen(fsaaSamples)
	local maxRes = loveutil.getMaxResolution()
	love.window.setMode(
		maxRes.width,
		maxRes.height,
		{
			fullscreen = true,
			vsync = true,
			fsaa = fsaaSamples
		}
	)
    love.mouse.setVisible(false)
end

function loveutil.text(text, color, font, x, y, width, align)
    love.graphics.setColor(color)
    love.graphics.setFont(font)
    love.graphics.printf(text, x, y, width, align)
end

return loveutil