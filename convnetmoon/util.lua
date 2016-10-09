local return_v = false
local value_v = 0
local gauss_random
gauss_random = function()
  if return_v then
    return_v = false
    return value_v
  end
  local u = 2 * math.random() - 1
  local v = 2 * math.random() - 1
  local r = u ^ 2 + v ^ 2
  if r == 0 or r > 1 then
    return gauss_random()
  end
  local c = math.sqrt(-2 * (math.log(r)) / r)
  value_v = v * c
  return u * c
end
local randf
randf = function(a, b)
  return math.random() * (b - a) + a
end
local randi
randi = function(a, b)
  return math.floor(math.random() * (b - a) + a)
end
local randn
randn = function(m, s)
  return m + gauss_random() * s
end
local zeros
zeros = function(n)
  local l = { }
  for i = 1, n do
    l[i] = 0
  end
  return l
end
local contains
contains = function(l, e)
  for k, v in pairs(l) do
    if v == e then
      return true
    end
  end
  return false
end
local unique
unique = function(l)
  local b = { }
  for k, v in pairs(l) do
    if not contains(b, v) then
      table.insert(b, v)
    end
  end
  return b
end
local maxmin
maxmin = function(l)
  local max_v = l[1]
  local max_i = 1
  local min_v = l[1]
  local min_i = 1
  for i, v in ipairs(l) do
    if v > max_v then
      max_v = v
      max_i = i
    elseif v < min_v then
      min_v = v
      min_i = i
    end
  end
  return {
    max_v = max_v,
    max_i = max_i,
    min_v = min_v,
    min_i = min_i,
    dv = max_v - min_v
  }
end
local randperm
randperm = function(n)
  local i = n - 1
  local l = { }
  for j = 1, n do
    l[j] = j
  end
  while i > 0 do
    local j = math.floor(math.random() * (i + 1))
    local tmp = l[i]
    l[i] = l[j]
    l[j] = tmp
    i = i - 1
  end
  return l
end
local weighted_sample
weighted_sample = function(l, pr)
  local p = randf(0, 1)
  local p2 = 0
  for i = 1, #l do
    p2 = p2 + pr[i]
    if p < p2 then
      return l[i]
    end
  end
end
local get_opt
get_opt = function(o, k, d)
  if (type(k)) == "string" then
    return o[k] or d
  else
    local r = d
    for i = 1, #k do
      local f = k[i]
      if f == nil then
        r = o[f]
      end
    end
    return r
  end
end
local save_json
save_json = function(d)
  return json:encode_pretty(d)
end
local load_json
load_json = function(d)
  return json:decode(d)
end
local Window
do
  local _class_0
  local _base_0 = {
    add = function(self, v)
      if #self.v < self.size then
        self.v[#self.v + 1] = v
        self.sum = self.sum + v
      end
    end,
    get_average = function(self)
      if #self.v < self.min_size then
        return -1
      else
        return self.sum / #self.v
      end
    end,
    reset = function(self)
      self.v = { }
      self.sum = 0
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, size, min_size)
      self.size, self.min_size = size, min_size
      self.v = { }
      self.sum = 0
    end,
    __base = _base_0,
    __name = "Window"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Window = _class_0
end
local extend
extend = function(a, b)
  for k, v in pairs(b) do
    table.insert(a, v)
  end
  return a
end
util = {
  gauss_random = gauss_random,
  randf = randf,
  randi = randi,
  randn = randn,
  zeros = zeros,
  maxmin = maxmin,
  randperm = randperm,
  weighted_sample = weighted_sample,
  unique = unique,
  contains = contains,
  get_opt = get_opt,
  save_json = save_json,
  load_json = load_json,
  Window = Window,
  extend = extend
}
