do
  local _class_0
  local _base_0 = {
    clone_and_zero = function(self)
      return Vol(self.sx, self.sy, self.depth, 0)
    end,
    clone = function(self)
      local V = Vol(self.sx, self.sy, self.depth, 0)
      for i = 1, #self.w do
        V.w[i] = self.w[i]
      end
      return V
    end,
    add_from = function(self, V)
      for i = 1, #self.w do
        self.w[i] = self.w[i] + V.w[i]
      end
    end,
    add_from_scaled = function(self, V, a)
      for i = 1, #self.w do
        self.w[i] = self.w[i] + (V.w[i] * a)
      end
    end,
    to_JSON = function(self)
      return {
        ["sx"] = self.sx,
        ["sy"] = self.sy,
        ["depth"] = self.depth,
        ["w"] = self.w
      }
    end,
    from_JSON = function(self, json)
      self.sx = json["sx"]
      self.sy = json["sy"]
      self.depth = json["depth"]
      local n = self.sx * self.sy * self.depth
      self.w = util.zeros(n)
      self.dw = util.zeros(n)
      self:add_from(json["w"])
      return self
    end,
    get = function(self, x, y, d)
      local ix = ((self.sx + y) + x) * self.depth + d
      return self.w[ix]
    end,
    set = function(self, x, y, d, v)
      local ix = ((self.sx + y) + x) * self.depth + d
      self.w[ix] = v
    end,
    add = function(self, x, y, d, v)
      local ix = ((self.sx + y) + x) * self.depth + d
      self.w[ix] = self.w[ix] + v
    end,
    get_grad = function(self, x, y, d)
      local ix = ((self.sx + y) + x) * self.depth + d
      return self.dw[ix]
    end,
    set_grad = function(self, x, y, d, v)
      local ix = ((self.sx + y) + x) * self.depth + d
      self.dw[ix] = v
    end,
    add_grad = function(self, x, y, d, v)
      local ix = ((self.sx + y) + x) * self.depth + d
      self.dw[ix] = self.dw[ix] + v
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, sx, sy, depth, c)
      if "table" == type(sx) then
        self.sx = 1
        self.sy = 1
        self.depth = #sx
        self.w = util.zeros(self.depth)
        self.dw = util.zeros(self.depth)
        for i = 1, #sx do
          self.w[i] = sx[i]
        end
      else
        self.sx = sx
        self.sy = sy
        self.depth = depth
        local n = sx * sy * depth
        self.w = util.zeros(n)
        self.dw = util.zeros(n)
        if c then
          for i = 1, #self.w do
            self.w[i] = c
          end
        else
          local scale = math.sqrt(1 / (sx * sy * depth))
          for i = 1, #self.w do
            self.w[i] = util.randn(0, scale)
          end
        end
      end
    end,
    __base = _base_0,
    __name = "Vol"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Vol = _class_0
end
