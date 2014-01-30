local inspect = require '3rdparty/inspect' -- Inspect library (for debug prints)
local _ = require '3rdparty/underscore' -- Underscore library
local const = require 'const' -- Global constants
local util = require 'util' -- General utilities
local loveutil = require 'loveutil' -- Utilities for the love2d framework

require '3rdparty/rounded_rect' -- Utility to draw rounded rectangles

local matrix = {} -- Table of matrix draw functions

local function alterBrightness(hslColor, increment)
    newColor = {}
    newColor[1] = hslColor[1] -- Hue
    newColor[2] = hslColor[2] -- Saturation
    newColor[3] = util.saturate(hslColor[3] + increment, 0, 255) -- Lightness
    newColor[4] = hslColor[4] -- Alpha channel
    return newColor
end

local function drawBlock(block)

    -- Block padding
    love.graphics.push()
    love.graphics.translate(const.BLOCK_PADDING, const.BLOCK_PADDING)
    love.graphics.scale(1 - const.BLOCK_PADDING, 1 - const.BLOCK_PADDING)

    -- Main color
    love.graphics.setColor(util.hsl(block.color))
    love.graphics.rectangle('fill', 0, 0, 1, 1)
    
    local function drawCorner()
        local pad = const.BEVEL_CORNER_SIZE
        love.graphics.polygon('fill', {0, 1, pad, 1 - pad, pad, 0, 0, 0})
        love.graphics.polygon('fill', {0, pad, 1 - pad, pad, 1, 0, 0, 0})
    end
    
    -- Bright area
    local brightColor = alterBrightness(block.color, const.BEVEL_BRIGHTNESS_INCREMENT)
    love.graphics.setColor(util.hsl(brightColor))
    drawCorner()
    
    -- Dark area
    local darkColor = alterBrightness(block.color, -const.BEVEL_BRIGHTNESS_INCREMENT)
    love.graphics.setColor(util.hsl(darkColor))
    love.graphics.push()
    love.graphics.translate(1, 1)
    love.graphics.scale(-1, -1)
    drawCorner()
    love.graphics.pop()
    
    -- Pop block padding transformation
    love.graphics.pop()
    
end

function matrix.draw(model)
    
    -- Calculate matrix size and position
    local matrixSize = {}
    matrixSize.height = loveutil.height() * const.MATRIX_HEIGHT_RATIO
    matrixSize.width = (const.MATRIX_SIZE.cols / const.MATRIX_SIZE.rows) * matrixSize.height
    local matrixPos = {
        left = loveutil.width() / 2 - matrixSize.width / 2,
        top = loveutil.height() / 2 - matrixSize.height / 2
    }
    
    -- Draw matrix rectangle
    love.graphics.setColor(const.MATRIX_COLOR)
    love.graphics.roundrect(
        "fill",
        matrixPos.left - const.MATRIX_PADDING,
        matrixPos.top - const.MATRIX_PADDING,
        matrixSize.width + 2 * const.MATRIX_PADDING,
        matrixSize.height + 2 * const.MATRIX_PADDING,
        const.MATRIX_CORNER_RADIUS,
        const.MATRIX_CORNER_RADIUS
    )
    
    -- Hide the matrix if the game is paused
    if const.HIDE_WHEN_PAUSED and model.status == 'paused' then
        return
    end
    
    -- Draw matrix contents
    love.graphics.push()
    love.graphics.translate(matrixPos.left, matrixPos.top)
    love.graphics.scale(matrixSize.width, matrixSize.height)
    
    local blockSize = {
        width = 1 / const.MATRIX_SIZE.cols,
        height = 1 / const.MATRIX_SIZE.rows
    }
    
    for i = 1, const.MATRIX_SIZE.rows do
        for j = 1, const.MATRIX_SIZE.cols do
            if model.matrix[i][j] ~= nil then
                love.graphics.push()
                love.graphics.translate((j - 1) * blockSize.width, (i - 1) * blockSize.height)
                love.graphics.scale(blockSize.width, blockSize.height)
                drawBlock(model.matrix[i][j])
                love.graphics.pop()
            end
        end
    end
    
    if model.fallingTetromino ~= nil then
        local fallingTetromino = model.fallingTetromino
        local tetromino = fallingTetromino.tetromino
        local position = fallingTetromino.position
        local rotation = tetromino.rotations[fallingTetromino.rotation]
        local block = { color = tetromino.color }
        love.graphics.push()
        love.graphics.translate((position.j - 1) * blockSize.width, (position.i - 1) * blockSize.height)
        for i = 1, #rotation do
            for j = 1, #rotation[i] do
                if rotation[i][j] then
                    love.graphics.push()
                    love.graphics.translate((j - 1) * blockSize.width, (i - 1) * blockSize.height)
                    love.graphics.scale(blockSize.width, blockSize.height)
                    drawBlock(block)
                    love.graphics.pop()
                end
            end
        end
        love.graphics.pop()
    end
    
    love.graphics.pop()
    
end

return matrix