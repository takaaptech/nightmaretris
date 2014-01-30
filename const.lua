local const = {
    
    -- Resource paths
    BG_IMAGE_PATH = 'img/bgimage.png',
    FONT_PATH = 'fonts/mrsmonster.ttf',
    TETROMINOS_DIR = 'tetrominos',
    
    -- Sizes
    TITLE_FONT_SIZE = 36,
    STOPPED_FONT_SIZE = 45,
    PAUSED_FONT_SIZE = 60,
    GAMEOVER_FONT_SIZE = 64,
    GAMEOVER_MESSAGE_SHADOW_OFFSET = 5,
    SCORE_FONT_SIZE = 24,
    TITLE_POS = { 20, 20 },
    SCORE_POS = { 20, 90 },
    MATRIX_SIZE = {
        rows = 20,
        cols = 10
    },
    MATRIX_HEIGHT_RATIO = 0.88, -- the ratio between the height of the matrix (in pixels) and the height of the window (in pixels)
    MATRIX_PADDING = 8, -- the internal padding of the matrix
    MATRIX_CORNER_RADIUS = 8, -- the radius of the rounded corners of the matrix rectangle
    
    -- Colors
    BACKGROUND_COLOR = { 0, 85, 160 },
    MATRIX_COLOR = { 0, 0, 0, 170 },
    DEFAULT_COLOR = { 255, 255, 255 },
    TITLE_COLOR = { 255, 255, 255 },
    STOPPED_MESSAGE_COLOR = { 255, 255, 0 },
    GAMEOVER_MESSAGE_COLOR = { 255, 0, 0 },
    GAMEOVER_MESSAGE_SHADOW_COLOR = { 255, 255, 255 },
    PAUSED_MESSAGE_COLOR = { 255, 255, 0 },
    SCORE_COLOR = { 255, 255, 255 },
    BEVEL_BRIGHTNESS_INCREMENT = 50,
    BEVEL_CORNER_SIZE = 0.15,
    BLOCK_PADDING = 0,
    
    -- Rendering
    FSAA_SAMPLES = 4,

    -- Game
    GAME_SPEED = 2, -- Number of ticks per second (TODO: adapt for different difficulty levels)
    NIGHTMARE_MODE = true,
    HIDE_WHEN_PAUSED = true,
    
    -- Messages
    WINDOW_TITLE = 'NightmareTris',
    TITLE = 'NightmareTris',
    STOPPED_MESSAGE = 'Press F2 to start',
    GAMEOVER_MESSAGE = 'Game Over!',
    PAUSED_MESSAGE = 'Paused',
    SCORE_MESSAGE = 'Number of lines: %d',
    
    -- Enable debug (developer) mode
    DEBUG_MODE = false,
    
}

return const