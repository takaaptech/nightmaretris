local util = {} -- Table of utility functions

-- Taken from http://lua-users.org/wiki/StringRecipes
function util.stringStarts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- Taken from http://snippets.luacode.org/?p=snippets/trim_whitespace_from_string_76
function util.trim(s)
    return s:find'^%s*$' and '' or s:match'^%s*(.*%S)'
end

-- Taken from http://stackoverflow.com/a/8316375/671092
function util.buildArray(...)
    local arr = {}
    for v in ... do
        arr[#arr + 1] = v
    end
    return arr
end

function util.scanf(s, fmt)
    return util.buildArray(string.gmatch(s, fmt))
end

-- Taken from: http://lua-users.org/wiki/CopyTable
function util.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[util.deepcopy(orig_key)] = util.deepcopy(orig_value)
        end
        setmetatable(copy, util.deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Taken from: http://lua-users.org/wiki/CopyTable
function util.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function util.saturate(num, minVal, maxVal)
    if num < minVal then return minVal end
    if num > maxVal then return maxVal end
    return num
end

-- Converts HSL to RGB. (input and output range: 0 - 255)
-- Taken from https://love2d.org/wiki/HSL_color
function util.hsl(hslColor)
    h = hslColor[1]
    s = hslColor[2]
    l = hslColor[3]
    a = hslColor[4] or 255
    if s <= 0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return { (r+m)*255,(g+m)*255,(b+m)*255,a }
end

-- Taken from: http://rosettacode.org/wiki/Knuth_Shuffle#Lua
function util.shuffle(t)
    local n = #t
    while n > 1 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
    return t
end

function util.getvalues(t)
    local values = {}
    for k, v in pairs(t) do
        values[#values + 1] = v
    end
    return values
end

function util.contains(t, e)
  for _, v in pairs(t) do
    if v == e then
      return true
    end
  end
  return false
end

return util