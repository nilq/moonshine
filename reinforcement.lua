local Vec
do
  local _class_0
  local _base_0 = {
    dist_from = function(self, v)
      return math.sqrt((self.x - v.x) ^ 2 + (self.y - v.y) ^ 2)
    end,
    magnitude = function(self)
      return math.sqrt(self.x ^ 2 + self.y ^ 2)
    end,
    add = function(self, v)
      return Vec(self.x + v.x, self.y + v.y)
    end,
    sub = function(self, v)
      return Vec(self.x - v.x, self.y - v.y)
    end,
    rotate = function(self, a)
      return Vec(self.x * math.cos(a) + self.y * math.sin(a), -self.x * math.sin(a) + self.y * math.cos(a))
    end,
    scale = function(self, s)
      self.x = self.x * s
      self.y = self.y * s
    end,
    normalize = function(self)
      return self:scale(1 / (function()
        local _base_1 = self
        local _fn_0 = _base_1.magnitude
        return function(...)
          return _fn_0(_base_1, ...)
        end
      end)())
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y)
      self.x, self.y = x, y
    end,
    __base = _base_0,
    __name = "Vec"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Vec = _class_0
end
local line_intersect
line_intersect = function(p1, p2, p3, p4)
  local denom = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)
  if denom == 0 then
    return false
  end
  local ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denom
  local ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denom
  if ua > 0 and ua < 1 and ub > 0 and ub < 1 then
    local up = Vec(p1.x + ua * (p2.x - p1.x), p1.y + ua * (p2.y - p1.y))
    return {
      ua = ua,
      ub = ub,
      up = up
    }
  end
  return false
end
local line_point_intersect
line_point_intersect = function(p1, p2, p0, rad)
  local v = Vec(p2.y - p1.y, -(p2.x - p1.x))
  local d = math.abs((p2.x - p1.x) * (p1.y - p0.y) - (p1.x - p0.x) * (p2.y - p1.y))
  d = d / v:magnitude()
  v:normalize()
  v:scale(d)
  local up = p0:add(v)
  if (math.abs(p2.x - p1.x)) > math.abs(p2.y - p1.y) then
    local ua = (up.x - p1.x) / (p2.x - p1.x)
  else
    local ua = (up.y - p1.y) / (p2.y - p1.y)
  end
  if ua > 0 and ua < 1 then
    return {
      ua = ua,
      up = up
    }
  end
  return false
end
local Wall
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, p1, p2)
      self.p1, self.p2 = p1, p2
    end,
    __base = _base_0,
    __name = "Wall"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Wall = _class_0
end
local util_add_box
util_add_box = function(lst, x, y, w, h)
  lst[#lst + 1] = Wall((Vec(x, y)), Vec(x + w, y))
  lst[#lst + 1] = Wall((Vec(x + w, y)), Vec(x + w, y + h))
  lst[#lst + 1] = Wall((Vec(x + w, y + h)), Vec(x, y + h))
  lst[#lst + 1] = Wall((Vec(x, y + h)), Vec(x, y))
end
local Item
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, x, y, type)
      self.type = type
      self.p = Vec(x, y)
      self.rad = 10
      self.age = 0
      self.clean_up = false
    end,
    __base = _base_0,
    __name = "Item"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Item = _class_0
end
local World
do
  local _class_0
  local _base_0 = { }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self)
      self.agents = { }
      self.W = love.graphics.getWidth()
      self.H = love.graphics.getHeight()
      self.walls = { }
      local pas = 10
      util_add_box(self.walls, pad, pad, self.W - pad * 2, self.H - pad * 2)
      util_add_box(self.walls, 100, 100, 200, 300)
      table.remove(self.walls, 1)
      util_add_box(self.walls, 400, 100, 200, 300)
      table.remove(self.walls, 1)
      self.items = { }
      for k = 1, 30 do
        local x = util.randf(20, self.W - pad * 2)
        local y = util.randf(20, self.H - pad * 2)
        local t = util.randi(1, 3)
        local it = Item(x, y, t)
        self.items[#self.items + 1] = it
      end
    end,
    __base = _base_0,
    __name = "World"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  World = _class_0
  return _class_0
end
