---@class Colour
---@overload fun(r: number, g: number, b: number, a: number): Colour
local Colour = setmetatable({}, {
    __call = function(class, r, g ,b, a)
        return class:new(r, g, b, a)
    end
})


Colour.__index = Colour

---Ternary: If `expr` then `t` else `f`
---@param expr boolean
---@param t any?
---@param f any?
---@return any?
local function T(expr, t, f)
    if expr then return t else return f end
end

---Clamp value to between `lower` and `upper` inclusive
---@param val number    --value to be clamped
---@param lower number  --lower bound (returns this value if `val` is lower)
---@param upper number  --upper bound (returns this value if `val` is higher)
---@return number
local function clamp(val, lower, upper)
    if val > upper then
        return upper
    elseif val < lower then
        return lower
    else
        return val
    end
end

---Round `val` to `places` decimal places
---@param val number     -- [required] value to round
---@param places number? -- [optional] number of decimal places, between 0 and 10 (default 2, clamped)
---@return number
local function round(val, places)
    if places ~= nil then
        places = clamp(places, 0, 10)
    else
        places = 2
    end

    local exp = math.pow(10, places)
    return math.floor((val * exp) + 0.5) / exp
end

---Create a new Colour
---@param r number   -- [required] must be between 0 and 1 inclusive (clamped)
---@param g number   -- [required] must be between 0 and 1 inclusive (clamped)
---@param b number   -- [required] must be between 0 and 1 inclusive (clamped)
---@param a number?  -- [optional] must be between 0 and 1 inclusive (default 1, clamped)
---@return Colour
function Colour:new(r, g, b, a)
    a = a or 1

    r = clamp(r, 0, 1)
    g = clamp(g, 0, 1)
    b = clamp(b, 0, 1)
    a = clamp(a, 0, 1)

    local o = {
        r = r,
        g = g,
        b = b,
        a = a
    }

    return setmetatable(o, self)
end

---Returns the Red value
---@return number
function Colour:Red()
    return self.r
end

---Sets the Red value
---@param v number -- [required] must be between 0 and 1 inclusive (clamped)
function Colour:SetRed(v)
    self.r = clamp(v, 0, 1)
end

---Returns the Green value
---@return number
function Colour:Green()
    return self.g
end

---Sets the Green value
---@param v number -- [required] must be between 0 and 1 inclusive (clamped)
function Colour:SetGreen(v)
    self.g = clamp(v, 0, 1)
end

---Returns the Blue value
---@return number
function Colour:Blue()
    return self.b
end

---Sets the Blue value
---@param v number -- [required] must be between 0 and 1 inclusive (clamped)
function Colour:SetBlue(v)
    self.b = clamp(v, 0, 1)
end

---Returns the Alpha value
---@return number
function Colour:Alpha()
    return self.a
end

---Sets the Alpha value
---@param v number -- [required] must be between 0 and 1 inclusive (clamped)
function Colour:SetAlpha(v)
    self.a = clamp(v, 0, 1)
end

---Returns all 4 values
---@return number r --Red
---@return number g --Green
---@return number b --Blue
---@return number a --Alpha
function Colour:Params()
    return self.r, self.g, self.b, self.a
end

---Returns the colour as an array of constituent values
---@return number[]
function Colour:ToArray()
    return { self:Params() }
end

---Convert to a 32-bit unsigned integer
---@return number
function Colour:ToUint32()
    local result = 0
    for k, v in pairs(self:ToArray()) do
        local shift = T(k == 1, 0, 8)
        result = bit32.bor(
            bit32.lshift(result, shift),
            round(v * 255, 0)
        )
    end
    return result
end

---Returns the colour as a 32-bit (4 byte) hex string
---@return string --Format: `#[R][G][B][A]` (1 byte each)
function Colour:HexString()
    return "#"..bit32.tohex(self:ToUint32()):upper()
end

function Colour:__tostring()
    return "Colour: {R: "..self.r..", G: "..self.g..", B: "..self.b..", A: "..self.a.."} ("..self:HexString()..")"
end

---Create a new Colour
---@param colour number --Bits 1-8 = Red, 9-16 = Green, 17-24 = Blue, 25-32 = Alpha (big-endian) 
---@return Colour
function Colour.FromUint32(colour)
    colour  = bit32.bswap(colour) --flip it so we can work with the lowest 8 bits

    --shift out each value in order (except red, as it starts in place)
    --taking the lowest 8 bits as the value, and divide by 255 to get a float
    local r = round(bit32.band(bit32.rshift(colour,  0), 0x000000FF) / 255, 3)
    local g = round(bit32.band(bit32.rshift(colour,  8), 0x000000FF) / 255, 3)
    local b = round(bit32.band(bit32.rshift(colour, 16), 0x000000FF) / 255, 3)
    local a = round(bit32.band(bit32.rshift(colour, 24), 0x000000FF) / 255, 3)

    return Colour(r, g, b, a)
end

Colour._White  = Colour(1.000, 1.000, 1.000, 1.000)
Colour._Grey   = Colour(0.500, 0.500, 0.500, 1.000)
Colour._Green  = Colour(0.000, 0.800, 0.000, 1.000)
Colour._Yellow = Colour(1.000, 0.800, 0.000, 1.000)
Colour._Red    = Colour(0.800, 0.000, 0.000, 1.000)
Colour._Blue   = Colour(0.000, 0.750, 1.000, 1.000)

Colour.Default  = Colour._White
Colour.Disabled = Colour._Grey
Colour.Positive = Colour._Green
Colour.Info     = Colour._Blue
Colour.Warning  = Colour._Yellow
Colour.Critical = Colour._Red

return Colour