local inspect = require '3rdparty/inspect' -- Inspect library (for debug prints)
local _ = require '3rdparty/underscore' -- Underscore library
local const = require 'const' -- Global constants
local util = require 'util' -- General utilities

local modelutil = require 'modelutil' -- Model utilities

-- Constants
local MAX_TETROMINO_REPETITIONS = 3
local FULL_ROW_SCORE = 100
local COVERED_EMPTY_BLOCK_SCORE = -4
local ALMOST_FULL_ROW_SCORE = 15
local FAVORABLE_SITUATION_SCORE = 85
local SIGNIFICANT_SCORE_THRESHOLD = 12 -- scores between -12 and 12 will be considered 0

local nightmare = {}

local function getEmptyBlocks(matrix)

    local emptyBlocks = {}
    
    for i = 1, const.MATRIX_SIZE.rows do
        emptyBlocks[i] = {}
        for j = 1, const.MATRIX_SIZE.cols do
            if matrix[i][j] == nil then
                table.insert(emptyBlocks[i], j)
            end
        end
    end
    
    return emptyBlocks
    
end

local function countCoveredEmptyBlocks(matrix)

    local numHoles = 0

    for j = 1, const.MATRIX_SIZE.cols do
        local foundFilledBlock = false
        for i = 1, const.MATRIX_SIZE.rows do
            if matrix[i][j] ~= nil then
                foundFilledBlock = true
            elseif foundFilledBlock then
                numHoles = numHoles + 1
            end
        end
    end
    
    return numHoles
    
end

-- This function calculates the score for a given matrix
-- TODO: this function relies on the shape of the standard tetrominos, so it should be transformed
-- into a function that reads a configuration file stored in the tetrominos/ directory
local function matrixScore(matrix)
    
    local score = 0
    
    -- Remove full rows and compute score accordingly
    local fullRowsNo
    matrix, fullRowsNo = modelutil.deleteFullRows(matrix)
    score = score + FULL_ROW_SCORE * fullRowsNo
    
    local emptyBlocks = getEmptyBlocks(matrix)
    
    for i = 1, #emptyBlocks do
    
        -- Detect almost-full row
        --  ??????.???
        --  xxxxxx.xxx
        if i ~= 1 and #emptyBlocks[i] == 1 then
            local blockOver = matrix[i - 1][emptyBlocks[i][1]]
            if blockOver == nil then
                --if const.DEBUG_MODE then
                --    print('Almost-full row: ' .. i)
                --end
                score = score + ALMOST_FULL_ROW_SCORE
            end
        -- Detect favorable situation
        --  ?????..???
        --  xxxxx..xxx
        --  xxxxx.xxxx
        elseif i ~= 1 and i ~= #emptyBlocks and #emptyBlocks[i] == 2 and emptyBlocks[i][2] - emptyBlocks[i][1] == 1 and
                #emptyBlocks[i + 1] == 1 and (emptyBlocks[i + 1][1] == emptyBlocks[i][1] or emptyBlocks[i + 1][1] == emptyBlocks[i][2]) then
            local blocksOver = { matrix[i - 1][emptyBlocks[i][1]], matrix[i - 1][emptyBlocks[i][2]] }
            if _.all(blocksOver, function (b) return b == nil end) then
                if const.DEBUG_MODE then
                    print('Favorable situation at row: ' .. i .. ', col: ' .. emptyBlocks[i][1])
                end
                score = score + FAVORABLE_SITUATION_SCORE
            end
        end
        
    end
    
    -- Consider penalties for covered holes
    score = score + COVERED_EMPTY_BLOCK_SCORE * countCoveredEmptyBlocks(matrix)
    
    -- If the score is not significant, set it to 0
    if math.abs(score) < SIGNIFICANT_SCORE_THRESHOLD then score = 0 end
    
    return score
    
end

-- This function does not produce exact results: it may return false when a position
-- is reachable, or true when it is unreachable.
-- The function only provides a convenient approximation for a complete "reachability" test.
local function isPossibleReachable(matrix, rotation, position)
    
    -- Check that the position is valid
    if not modelutil.isValidPosition(matrix, rotation, position) then
        return false
    end
    
    -- Check that is NOT possible to go down any further
    if modelutil.isValidPosition(matrix, rotation, { i = position.i + 1, j = position.j }) then
        return false
    end
    
    -- Start from the top
    local currPos = {
        i = 1,
        j = position.j
    }
    
    -- Check that is possible to go from the top to the position
    while currPos.i ~= position.i do
        currPos.i = currPos.i + 1
        if not modelutil.isValidPosition(matrix, rotation, currPos) then
            return false
        end
    end
    
    return true
    
end

function nightmare.new()

    local self = {} -- Instance
    self.lastTetromino = nil

    -- Function for the selection of the next tetromino, implementing the 'nightmare' algorithm
    function self.nextTetromino(matrix, tetrominos)
        
        -- This function assigns a score to a tetromino placed in a given position
        -- and with a given rotation
        local function positionScore(tetromino, rotation, position)
            
            local tempMatrix = util.deepcopy(matrix) -- Create a temporary matrix copy
            modelutil.consolidate(tempMatrix, tetromino, rotation, position) -- Put the tetromino in the matrix
            
            -- Calculate the score of the matrix
            return matrixScore(tempMatrix)
                    
        end
        
        -- This function assigns a score to a tetromino
        local function tetrominoScore(tetromino)
        
            local scores = {}
            
            scores[#scores + 1] = -math.huge -- Dummy -infinite score
            
            -- For each rotation
            _.each(tetromino.rotations, function(rotation)
                -- For each possible position
                for i = -#rotation, const.MATRIX_SIZE.rows do
                    for j = -#rotation, const.MATRIX_SIZE.cols do
                        local position = {
                            i = i,
                            j = j
                        }
                        if isPossibleReachable(matrix, rotation, position) then
                            -- The position is PROBABLY reachable: calculate the score
                            scores[#scores + 1] = positionScore(tetromino, rotation, position)
                        end
                    end
                end
            end)
            
            return _.max(scores)
            
        end
        
        local startTime = os.clock()
        
        -- Shuffle the list of tetrominos (this allows to select a random tetromino among the 'worst' ones)
        local shuffledTetrominos = util.shuffle(util.shallowcopy(tetrominos))
        
        -- Check if the last tetromino has been repeated too many times. If so, remove it from the shuffledTetrominos table.
        if self.lastTetromino ~= nil and self.lastTetromino.counter == MAX_TETROMINO_REPETITIONS then
            shuffledTetrominos = _.reject(shuffledTetrominos, function (tetromino) return tetromino.id == self.lastTetromino.id end)
        end
        
        -- Find the tetromino that can achieve minimum score
        local scores = {}
        _.each(shuffledTetrominos, function(tetromino) scores[tetromino] = tetrominoScore(tetromino) end)
        local worstTetromino = _.min(shuffledTetrominos, function(tetromino) return scores[tetromino] end)
        local worstScore = _.min(util.getvalues(scores))
        
        -- Update last tetromino record
        if self.lastTetromino == nil or self.lastTetromino.id ~= worstTetromino.id then
            self.lastTetromino = {
                id = worstTetromino.id,
                counter = 1
            }
        else
            self.lastTetromino.counter = self.lastTetromino.counter + 1
        end
        
        local endTime = os.clock()   
       
        -- Print debug information to console
        if const.DEBUG_MODE then
            local info = _.map(shuffledTetrominos, function(tetromino) return tetromino.id .. ':' .. scores[tetromino] end)
            print(inspect(info))
            print(inspect(self.lastTetromino))
            local elapsedTime = endTime - startTime
            print('Time: ' .. elapsedTime)
        end 
        
        return worstTetromino, worstScore
        
    end
    
    return self

end

return nightmare