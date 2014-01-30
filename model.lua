local inspect = require '3rdparty/inspect' -- Inspect library (for debug prints)
local _ = require '3rdparty/underscore' -- Underscore library
local const = require 'const' -- Global constants
local util = require 'util' -- General utilities

local modelutil = require 'modelutil' -- Model utilities
local tetrominos = require 'tetrominos' -- Table containing all the tetrominos

local tickDuration = 1 / const.GAME_SPEED

local model = {}

function model.new()

    local self = {} -- Instance
    
    -- Public fields
    self.matrix = nil
    self.score = nil
    self.status = nil
    self.fallingTetromino = nil
    
    -- Private fields
    local timeCounter
    local nightmare = require 'nightmare'.new()
    
    local function reset()
    
        self.matrix = {}
        
        for i = 1, const.MATRIX_SIZE.rows do
            self.matrix[i] = {}
        end
        
        timeCounter = 0
        self.score = 0
        self.fallingTetromino = nil
        self.status = 'stopped'
        
    end
    
    local function nextTetromino()

        -- If not in nightmare mode, just pick a random tetromino
        if not const.NIGHTMARE_MODE then
            return tetrominos[math.random(#tetrominos)]
        end
        
        return nightmare.nextTetromino(self.matrix, tetrominos)
        
    end
    
    local function newFallingTetromino()

        local tetromino = nextTetromino()
        local rotation = tetromino.rotations[1]
        local cols = #rotation[1]
        local offset = math.random(0, 1)
        local position = {
            i = 1,
            j = 1 + offset + math.floor(const.MATRIX_SIZE.cols / 2 - cols / 2)
        }
        
        if modelutil.isValidPosition(self.matrix, rotation, position) then
            self.fallingTetromino = {}
            self.fallingTetromino.tetromino = tetromino
            self.fallingTetromino.position = position
            self.fallingTetromino.rotation = 1
            return true
        else
            return false
        end
        
    end
    
    function self.startGame()
        reset()
        self.status = 'playing'
    end
    
    function self.pauseResumeGame()
        if self.status == 'playing' then
            self.status = 'paused'
        elseif self.status == 'paused' then
            self.status = 'playing'
        end
    end
    
    function self.move(direction)
    
        if self.fallingTetromino == nil then return false end
        
        assert(direction == 'left' or direction == 'right')
        
        local tetromino = self.fallingTetromino.tetromino
        local rotation = tetromino.rotations[self.fallingTetromino.rotation]
        local position = self.fallingTetromino.position
        
        local newPosition = {}
        
        if direction == 'left' then
            newPosition.j = position.j - 1
        else
            newPosition.j = position.j + 1
        end
        newPosition.i = position.i

        if modelutil.isValidPosition(self.matrix, rotation, newPosition) then
            self.fallingTetromino.position = newPosition
            return true
        else
            return false
        end
        
    end
    
    function self.rotate()

        if self.fallingTetromino == nil then return false end
        
        local tetromino = self.fallingTetromino.tetromino
        local position = self.fallingTetromino.position
        
        local newRotationIndex = 0
        if self.fallingTetromino.rotation == #tetromino.rotations then
            newRotationIndex = 1
        else
            newRotationIndex = self.fallingTetromino.rotation + 1
        end
        local newRotation = tetromino.rotations[newRotationIndex]
        
        if modelutil.isValidPosition(self.matrix, newRotation, position) then
            self.fallingTetromino.rotation = newRotationIndex
            return true
        else
            return false
        end

    end

    function self.stepDown()

        local tetromino = self.fallingTetromino.tetromino
        local rotation = tetromino.rotations[self.fallingTetromino.rotation]
        local position = self.fallingTetromino.position
        
        local newPosition = {
            i = position.i + 1,
            j = position.j
        }
        
        if modelutil.isValidPosition(self.matrix, rotation, newPosition) then
            self.fallingTetromino.position = newPosition
            return true
        else
            return false
        end
        
    end

    function self.drop()

        if self.fallingTetromino == nil then return false end

        while self.stepDown() do end
        
        local tetromino = self.fallingTetromino.tetromino
        local rotation = tetromino.rotations[self.fallingTetromino.rotation]
        local position = self.fallingTetromino.position
        
        modelutil.consolidate(self.matrix, tetromino, rotation, position)
        self.fallingTetromino = nil
        timeCounter = 0
        
        local fullRowsNo = 0
        self.matrix, fullRowsNo = modelutil.deleteFullRows(self.matrix)
        self.score = self.score + fullRowsNo
        
    end

    function self.update(dt)
        if self.status == 'playing' then
            timeCounter = timeCounter + dt
            if timeCounter > tickDuration then -- Change state
                timeCounter = 0
                if self.fallingTetromino == nil then -- Create a new falling tetromino
                    if not newFallingTetromino() then
                        self.status = 'gameover'
                    end
                else -- Step down current tetromino
                    if not self.stepDown() then
                        self.drop()
                    end
                end
            end
        end
    end
    
    reset()
    math.randomseed(os.time())
    
    return self
        
end

return model