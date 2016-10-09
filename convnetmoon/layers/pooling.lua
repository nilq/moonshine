do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local A = Vol(self.out_sx, self.out_sy, self.out_depth, 0)
      local switch_count = 0
      for d = 1, self.out_depth do
        local x = -self.pad
        local y = -self.pad
        for ax = 1, self.out_sx do
          y = -self.pad
          for ay = 1, self.out_sy do
            local max_a = -1e5
            local win_x = -1
            local win_y = -1
            for fx = 1, self.sx do
              for fy = 1, self.sy do
                local off_x = x + fy
                local off_y = y + fx
                if off_x >= 0 and off_x < V.sx and off_y >= 0 and off_y < V.sy then
                  local v = V:get(off_x, off_y, d)
                  if v > max_a then
                    max_a = v
                    win_x = off_x
                    win_y = off_y
                  end
                end
              end
            end
            self.switch_x[switch_count] = win_x
            self.switch_y[switch_count] = win_y
            switch_count = switch_count + 1
            A:set(ax, ay, d, max_a)
            y = y + self.stride
          end
          x = x + self.stride
        end
      end
      self.out_act = A
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      V.dw = util.zeros(#V.w)
      local A = self.out_act
      local n = 0
      for d = 1, self.out_depth do
        local x = -self.pad
        local y = -self.pad
        for ax = 1, self.out_sx do
          y = -self.pad
          for ay = 1, self.out_sy do
            local chain_grad = self.out_act:get_grad(ax, ay, d)
            V:add_grad(self.switch_x[n], self.switch_y[n], d, chain_grad)
            n = n + 1
            y = y + self.stride
          end
          x = x + self.stride
        end
      end
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["sx"] = self.sx,
        ["sy"] = self.sy,
        ["stride"] = self.stride,
        ["in_depth"] = self.in_depth,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["pad"] = self.pad,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.sx = json["sx"]
      self.sy = json["sy"]
      self.stride = json["stride"]
      self.in_depth = json["in_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.pad = json["pad"]
      self.layer_type = json["layer_type"]
      local switch_size = self.out_sx * self.out_sy * self.out_depth
      self.switch_x = util.zeros(switch_size)
      self.switch_y = util.zeros(switch_size)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.sx = opt["sx"]
      self.in_sx = opt["in_sx"]
      self.in_sy = opt["in_sy"]
      self.in_depth = opt["in_depth"]
      self.sy = util.get_opt(opt, "sy", self.sx)
      self.stride = util.get_opt(opt, "stride", 2)
      self.pad = util.get_opt(opt, "pad", 0)
      self.out_sx = math.floor((self.in_sx - self.sx + 2 * self.pad) / self.stride + 1)
      self.out_sy = math.floor((self.in_sy - self.sy + 2 * self.pad) / self.stride + 1)
      self.out_depth = self.in_depth
      self.layer_type = "pool"
      local switch_size = self.out_sx * self.out_sy * self.out_depth
      self.switch_x = util.zeros(switch_size)
      self.switch_y = util.zeros(switch_size)
    end,
    __base = _base_0,
    __name = "PoolingLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  PoolingLayer = _class_0
end
