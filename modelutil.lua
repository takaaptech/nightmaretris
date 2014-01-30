local inspect = require '3rdparty/inspect' -- Inspect library (for debug prints)
local _ = require '3rdparty/underscore' -- Underscore library
local const = require 'const' -- Global constants
local util = require 'util' -- General utilities

local modelutil = {}

function modelutil.isValidPosition(matrix, rotation, position)
    for i = 1, #rotation do
        for j = 1, #rotation[i] do
            if rotation[i][j] then
                local blockPos = {
                    i = position.i + (i - 1),
                    j = position.j + (j - 1)
                }
                if blockPos.i < 1 or blockPos.i > const.MATRIX_SIZE.rows or
                   blockPos.j < 1 or blockPos.j > const.MATRIX_SIZE.cols or
                   matrix[blockPos.i][blockPos.j] ~= nil then return false end
            end
        end
    end
    return true
end

-- This function "consolidates" the falling tetromino, i.e. places it in a given position on a matrix
function modelutil.consolidate(matrix, tetromino, rotation, position)
    
    assert(modelutil.isValidPosition(rotation, position))
    
    for i = 1, #rotation do
        for j = 1, #rotation[i] do
            if rotation[i][j] then
                local blockPos = {
                    i = position.i + (i - 1),
                    j = position.j + (j - 1)
                }
                matrix[blockPos.i][blockPos.j] = { color = tetromino.color }
            end
        end
    end
    
end

-- This function deletes the full rows in a matrix
function modelutil.deleteFullRows(matrix)
    
    local counter = 0
    
    matrix = _.select(
        matrix,
        function (row)
            return #_.select(row, function(b) return b ~= nil end) < const.MATRIX_SIZE.cols
        end
    )
    
    while (#matrix < const.MATRIX_SIZE.rows) do
        local row = {}
        _.unshift(matrix, row)
        counter = counter + 1
    end
    
    return matrix, counter
    
end


return modelutil