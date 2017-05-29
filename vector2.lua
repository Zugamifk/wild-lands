local ffi = require "ffi"

local cos = math.cos
local sin = math.sin
local sqrt = math.sqrt
local atan2 = math.atan2

ffi.cdef[[
  typedef struct vector2 { double x, y; } vector2_t;
]]

local vector2
local index = {}
local meta = {__index = index}

-- Comparison operators
function meta.__eq(a, b)
  return a.x == b.x and a.y == b.y
end
function meta.__lt(a, b)
	return (a.x*a.x + a.y*a.y) < (b.x*b.x + b.y*b.y)
end
function meta.__le(a,b)
  return (a.x*a.x + a.y*a.y) <= (b.x*b.x + b.y*b.y)
end

-- Common math operators
function meta.__unm(a) return vector2(-a.x, -a.y) end
function meta.__add(a, b) return vector2(a.x + b.x, a.y + b.y) end
function meta.__sub(a, b) return vector2(a.x - b.x, a.y - b.y) end
function meta.__mul(a, b) return vector2(a.x * b.x, a.y * b.y) end
function meta.__div(a, b) return vector2(a.x * b, a.y * b) end

-- Utility metamethods
function meta.__len(a) return sqrt(a.x * a.x + a.y * a.y) end
function meta.__tostring(a)
  return "(" .. a.x .. "," .. a.y .. ")"
end

--- vector:copy()
-- Create a identical copy of a vector
-- Note: Use this if you're going to be using _mut() ops on constant vectors
function index.copy(a)
  return vector2(a.x, a.y)
end
--- vector:unpack()
-- Return the value of individual components as multiple values
-- Useful for passing into functions that take separate arguments
-- Example:
--   love.graphics.draw(sprite, position:unpack())
function index.unpack(a)
  return a.x, a.y
end
--- vector:len()
-- Compute the length of a vector with the Euclidean norm
function index.len(a)
  return sqrt(a.x * a.x + a.y * a.y)
end
--- vector:len2()
-- Compute the square length of a vector for comparing
function index.len2(a)
  return a.x * a.x + a.y * a.y
end
--- vector:cross(vector)
-- Compute the cross product of a, b
function index.cross(a, b)
  return a.x * b.y - a.y * b.x
end
--- vector:dist(vector)
-- Compute the Euclidean distance between vectors
-- Equivalent to (vector - vector):len()
function index.dist(a, b)
  local x = a.x - b.x
  local y = a.y - b.y
  return sqrt(x*x + y*y)
end
--- vector:dist2(vector)
-- Compute the squared Euclidean distance between vectors for comparing
-- Equivalent to (vector - vector):len2()
function index.dist2(a, b)
  local x = a.x - b.x
  local y = a.y - b.y
  return x*x + y*y
end
--- vector:angle()
-- Compute the 2D phi of a vector
--- vector:angle(vector)
-- Compute the 2D phi delta of two vectors
function index.angle(a, b)
  if b then
    return atan2(a.y, a.x) - atan2(b.y, b.x)
  end
  return atan2(a.y, a.x)
end
--- vector:dot(vector)
-- Compute the dot product of two vectors
function index.dot(a, b)
  return vector2(a.x * b.x, a.y * b.y)
end
--- vector:dot_mut(vector)
-- Set first vector to dot product of self with second vector
function index.dot_mut(a, b)
  a.x, a.y = a.x * b.x, a.y * b.y
  return a
end
--- vector:unit()
-- Normalize a vector such that #vector:unit() == 1
function index.unit(a)
  local len = #a
  if len > 0 then
    return vector2(a.x / len, a.y / len)
  end
  return vector2(a.x, a.y)
end
--- vector:unit_mut()
-- Normalize a vector in-place such that vector:unit_mut(), #vector == 1
function index.unit_mut(a)
  local len = #a
  if len > 0 then
    a.x, a.y = a.x / len, a.y / len
  end
  return a
end
--- vector:perp()
-- Return the vector perpendicular to this vector
function index.perp(a)
  return vector2(-a.y, a.x)
end
--- vector:perp_mut()
-- Replace the vector in-place with its perpendicular vector
function index.perp_mut(a)
  a.x, a.y = -a.y, a.x
  return a
end
--- vector:rotate(phi)
-- Rotate the vector by *phi* radians in 2D space
function index.rotate(a, phi)
  local c, s = cos(phi), sin(phi)
  return vector2(c * a.x - s * a.y, s * a.x + c * a.y)
end
--- vector:rotate_mut(phi)
-- Rotate the vector in-place by *phi* radians in 2D space
function index.rotate_mut(a, phi)
  local c, s = cos(phi), sin(phi)
  a.x, a.y = c * a.x - s * a.y, s * a.x + c * a.y
  return a
end
--- vector:project(vector)
-- Compute the projection of a vector onto another
function index.project(a, b)
  local s = (a.x*b.x + a.y*b.y) / (b.x*b.x + b.y*b.y)
  return vector2(s * a.x, s * a.y)
end
--- vector:project_mut(vector)
-- In-place vector projection
function index.project_mut(a, b)
  local s = (a.x*b.x + a.y*b.y) / (b.x*b.x + b.y*b.y)
  a.x, a.y = s * a.x, s * a.y
  return a
end
--- vector:mirror(vector)
-- Compute a vector as mirrored onto another
function index.mirror(a, b)
  local s = 2 * (a.x*b.x + a.y*b.y) / (b.x*b.x + b.y*b.y)
  return vector2(s * b.x - a.x, s * b.y - a.y)
end
--- vector:mirror_mut(vector)
-- In-place vector mirroring
function index.mirror_mut(a, b)
  local s = 2 * (a.x*b.x + a.y*b.y) / (b.x*b.x + b.y*b.y)
  a.x, a.y = s * b.x - a.x, s * b.y - a.y
  return a
end
--- vector:trim(max)
-- Limit a vector to length *max*
function index.trim(a, max)
  local s = max*max / (a.x*a.x + a.y*a.y)
  if s > 1 then s = 1 else s = sqrt(s) end
  return vector2(a.x * s, a.y * s)
end
--- vector:trim_mut(max)
-- Limit a vector to length *max* in-place
function index.trim_mut(a, max)
  local s = max*max / (a.x*a.x + a.y*a.y)
  if s > 1 then s = 1 else s = sqrt(s) end
  a.x, a.y = a.x * s, a.y * s
  return a
end
-- In-place variants of metatable operators
function index.unm_mut(a)
  a.x, a.y = -a.x, -a.y
  return a
end
function index.add_mut(a, b)
  a.x, a.y = a.x + b.x, a.y + b.y
  return a
end
function index.sub_mut(a, b)
  a.x, a.y = a.x - b.x, a.y - b.y
  return a
end
function index.mul_mut(a, b)
  a.x, a.y = a.x * b, a.y * b
  return a
end
function index.div_mut(a, b)
  a.x, a.y = a.x / b, a.y / b
  return a
end

vector2 = ffi.metatype("vector2_t", meta)

-- Common constant vectors
-- Please do not use _mut() ops as there is no read-only mechanism :)
meta.zero = vector2(0, 0)
meta.one = vector2(1, 1)
meta.unit = meta.one:unit()

return vector2
