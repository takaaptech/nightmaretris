local inspect = require '3rdparty/inspect' -- Inspect library (for debug prints)
local _ = require '3rdparty/underscore' -- Underscore library
local const = require 'const' -- Global constants
local util = require 'util' -- General utilities
local loveutil = require 'loveutil' -- Utilities for the love2d framework

local model = require 'model'.new() -- Game model
local matrix = require 'matrix' -- Matrix draw function

local images = {} -- Table of images
local fonts = {} -- Table of fonts

function love.load(args)

    -- Load resources
    images.bg = love.graphics.newImage(const.BG_IMAGE_PATH)
    fonts.title = love.graphics.newFont(const.FONT_PATH, const.TITLE_FONT_SIZE)
    fonts.stopped = love.graphics.newFont(const.FONT_PATH, const.STOPPED_FONT_SIZE)
    fonts.paused = love.graphics.newFont(const.FONT_PATH, const.PAUSED_FONT_SIZE)
    fonts.gameover = love.graphics.newFont(const.FONT_PATH, const.GAMEOVER_FONT_SIZE)
    fonts.score = love.graphics.newFont(const.FONT_PATH, const.SCORE_FONT_SIZE)
    
    -- Window title and background
    love.graphics.setBackgroundColor(const.BACKGROUND_COLOR)
    love.window.setTitle(const.WINDOW_TITLE)
    
    -- Enable fullscreen
    local fullscreen = not const.DEBUG_MODE and not util.contains(args, '--windowed')
    
    if fullscreen then
        local fsaaSamples
        if not util.contains(args, '--no-fsaa') then
            fsaaSamples = const.FSAA_SAMPLES
        else
            fsaaSamples = 0
        end
        loveutil.goFullscreen(fsaaSamples)
    end
    
end

function love.draw()
    
    -- Draw background image
    love.graphics.setColor(const.DEFAULT_COLOR)
    local bgPos = {
        left = loveutil.width() - images.bg:getWidth(),
        top = loveutil.height() - images.bg:getHeight()
    }
    love.graphics.draw(images.bg, bgPos.left, bgPos.top)
    
    -- Draw matrix
    matrix.draw(model)
    
    if model.status == 'stopped' then
        loveutil.text(
            const.STOPPED_MESSAGE,
            const.STOPPED_MESSAGE_COLOR,
            fonts.stopped,
            0, 
            loveutil.height() / 2 - fonts.stopped:getHeight() / 2,
            loveutil.width(),
            'center'
        )
    elseif model.status == 'paused' then
        loveutil.text(
            const.PAUSED_MESSAGE,
            const.PAUSED_MESSAGE_COLOR,
            fonts.paused,
            0, 
            loveutil.height() / 2 - fonts.stopped:getHeight() / 2,
            loveutil.width(),
            'center'
        )
    elseif model.status == 'gameover' then
        -- Shadow
        loveutil.text(
            const.GAMEOVER_MESSAGE,
            const.GAMEOVER_MESSAGE_SHADOW_COLOR,
            fonts.gameover,
            const.GAMEOVER_MESSAGE_SHADOW_OFFSET,
            const.GAMEOVER_MESSAGE_SHADOW_OFFSET + loveutil.height() / 2 - fonts.stopped:getHeight() / 2,
            loveutil.width() - const.GAMEOVER_MESSAGE_SHADOW_OFFSET,
            'center'
        )
        -- Gameover message
        loveutil.text(
            const.GAMEOVER_MESSAGE,
            const.GAMEOVER_MESSAGE_COLOR,
            fonts.gameover,
            0,
            loveutil.height() / 2 - fonts.stopped:getHeight() / 2,
            loveutil.width() - const.GAMEOVER_MESSAGE_SHADOW_OFFSET,
            'center'
        )
    end
    
    -- Draw game title
    loveutil.text(const.TITLE, const.TITLE_COLOR, fonts.title, const.TITLE_POS[1], const.TITLE_POS[2], loveutil.width())
    
    -- Draw score indicator
    local score = string.format(const.SCORE_MESSAGE, model.score)
    loveutil.text(score, const.SCORE_COLOR, fonts.score, const.SCORE_POS[1], const.SCORE_POS[2], loveutil.width())
    
end

function love.update(dt)
    model.update(dt)
end

function love.keypressed(key)
    
    local commands = {
        ['escape'] = function() love.event.quit() end,
        ['f2'] = function() model.startGame() end,
        ['f3'] = function() model.pauseResumeGame() end
    }
    
    local gameCommands = {
        ['down'] = function() model.drop() end,
        ['left'] = function() model.move('left') end,
        ['right'] = function() model.move('right') end,
        ['up'] = function() model.rotate() end
    }
    
    if commands[key] ~= nil then
        commands[key]()
    elseif gameCommands[key] ~= nil and model.status == 'playing'  then
        gameCommands[key]()
    end
    
end
