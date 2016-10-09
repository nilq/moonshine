do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local V2 = V:clone()
      local N = #V.w
      if is_training then
        for i = 1, N do
          if math.random() < self.drop_prob then
            V2.w[i] = 0
            self.dropped[i] = true
          else
            self.dropped = false
          end
        end
      else
        for i = 1, N do
          V2.w[i] = V2.w[i] * self.drop_prob
        end
      end
      self.out_act = V2
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      local chain_grad = self.out_act
      local N = #V.w
      V.dw = util.zeros(N)
      for i = 1, N do
        if not self.dropped[i] then
          V.dw[i] = chain_grad.dw[i]
        end
      end
    end,
    to_JSON = function(self)
      return {
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type,
        ["drop_prob"] = self.drop_prob
      }
    end,
    from_JSON = function(self, json)
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.layer_type = json["layer_type"]
      self.drop_prob = json["drop_prob"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["in_depth"]
      self.layer_type = "dropout"
      self.drop_prob = util.get_opt(opt, "drop_prob", 0.5)
      self.dropped = util.zeros(self.out_sx * self.out_sy * self.out_depth)
    end,
    __base = _base_0,
    __name = "DropoutLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  DropoutLayer = _class_0
end
