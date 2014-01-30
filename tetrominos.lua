local inspect = require '3rdparty/inspect' -- Inspect library (for debug prints)
local _ = require '3rdparty/underscore' -- Underscore library
local const = require 'const' -- Global constants
local util = require 'util' -- General utilities

local function readTetrominoFromFile(filepath, id)
    
    local function readRotationLine(line)
        local values = { ['x'] = true, ['.'] = false }
        local chars = util.scanf(line, '.')
        local line = _.map(chars, function(c) return values[c] end);
        return line;
    end
    
    local function checkRotations(rotations)
        local function checkRotation(rotation)
            _.each(rotation, function(line) assert(#line == #rotation[1], 'Corrupted tetromino ' .. filepath .. ': invalid rotations') end)
        end
        _.each(rotations, function(rotation) checkRotation(rotation) end)
        _.each(rotations, function(rotation) assert(#rotation == #rotations[1], 'Corrupted tetromino ' .. filepath .. ': invalid rotations') end)
    end
    
    local status = 'READING_COLOR'
    local color = {}
    local rotations = {}
    local currentRotation = {}
    
    for line in love.filesystem.lines(filepath) do
        line = util.trim(line)
        if line ~= '' then
            if status == 'READING_COLOR' then
                color = util.scanf(line, '%d+')
                assert(#color == 3, 'Corrupted tetromino ' .. filepath .. ': invalid color')
                color = _.map(color, function(e) return tonumber(e) end)
                _.each(color, function(c) assert(c >= 0 and c <= 255, 'Corrupted tetromino ' .. filepath .. ': invalid color') end)
                status = 'READING_ROTATION'
            elseif status == 'READING_ROTATION' then
                if line == 'end' then
                    rotations[#rotations + 1] = util.deepcopy(currentRotation)
                    currentRotation = {}
                else
                    currentRotation[#currentRotation + 1] = readRotationLine(line)
                end
            end
        end
    end
    
    assert(#rotations > 0, 'Corrupted tetromino ' .. filepath .. ': no rotations found')
    checkRotations(rotations)
    
    local tetromino = {}
    tetromino.id = id
    tetromino.color = color
    tetromino.rotations = rotations
    
    return tetromino
    
end

local files = love.filesystem.getDirectoryItems(const.TETROMINOS_DIR)

local tetrominos = {}

for i, filename in ipairs(files) do
    local filepath = const.TETROMINOS_DIR .. '/' .. filename
    if not util.stringStarts(filename, '.') and love.filesystem.isFile(filepath) then
        tetrominos[#tetrominos + 1] = readTetrominoFromFile(filepath, filename)
    end
end

return tetrominos