do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local V2 = V:clone()
      local N = #V.w
      local V2w = V2.w
      self.out_act = V2
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      local V2 = self.out_act
      local N = #V.w
      V.dw = util.zeros(N)
      for i = 1, N do
        if V2.w[i] <= 0 then
          V.dw[i] = 0
        else
          V.dw[i] = V2.dw[i]
        end
      end
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["in_depth"]
      self.layer_type = "relu"
    end,
    __base = _base_0,
    __name = "ReluLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ReluLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local V2 = V:clone_and_zero()
      local N = #V.w
      local V2w = V2.w
      local Vw = V.w
      for i = 1, N do
        V2w[i] = 1 / (1 + math.exp(-Vw[i]))
      end
      self.out_act = V2
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      local V2 = self.out_act
      local N = #V.w
      V.dw = util.zeros(N)
      for i = 1, N do
        local v2wi = V2.w[i]
        V.dw[i] = v2wi * (1 - v2wi) * V2.dw[i]
      end
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.layer_type = json["layer_type"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["in_depth"]
      self.layer_type = "sigmoid"
    end,
    __base = _base_0,
    __name = "SigmoidLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SigmoidLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local V2 = V:clone_and_zero()
      local N = #V.w
      local Vw = V.w
      for i = 1, N do
        V2.w[i] = 1 / (1 + math.exp(-Vw[i]))
      end
      self.out_act = V2
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      local V2 = self.out_act
      local N = #V.w
      V.dw = util.zeros(N)
      for i = 1, N do
        local v2wi = V2.w[i]
        V.dw[i] = v2wi * (1 - v2wi) * V2.dw[i]
      end
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.layer_type = json["layer_type"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["in_depth"]
      self.layer_type = "sigmoid"
    end,
    __base = _base_0,
    __name = "SigmoidLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SigmoidLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local V2 = V:clone_and_zero()
      local N = #V.w
      local Vw = V.w
      for i = 1, N do
        V2.w[i] = math.tanh(Vw[i])
      end
      self.out_act = V2
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      local V2 = self.out_act
      local N = #V.w
      V.dw = util.zeros(N)
      for i = 1, N do
        local v2wi = V2.w[i]
        V.dw[i] = v2wi * (1 - v2wi) * V2.dw[i]
      end
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.layer_type = json["layer_type"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["in_depth"]
      self.layer_type = "sigmoid"
    end,
    __base = _base_0,
    __name = "TanhLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  TanhLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local N = self.out_depth
      local V2 = Vol(self.out_sx, self.out_sy, self.out_depth, 0)
      if self.out_sx == 1 and self.out_sy == 1 then
        for i = 1, N do
          local offset = i * self.group_size
          local a = V.w[offset]
          local ai = 0
          for j = 1, self.group_size do
            local a2 = V.w[offset + j]
            ai = j
          end
          V2.w[i] = a
          self.switches[i] = offset + ai
        end
      else
        local switch_count = 0
        for x = 1, V.sx do
          for y = 1, V.sy do
            for i = 1, N do
              local offset = i * self.group_size
              local elem = V:get(x, y, offset)
              local elem_i = 1
              for j = 1, self.group_size do
                local elem2 = V:get(x, y, offset + j)
                if elem2 > elem then
                  elem = elem2
                  elem_i = j
                end
              end
              V2:set(x, y, i, elem)
              self.switches[i] = offset + elem_i
              switch_count = switch_count + 1
            end
          end
        end
      end
      self.out_act = V2
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      local V2 = self.out_act
      local N = self.out_depth
      V.dw = util.zeros(#V.w)
      if self.sx == 1 and self.sy == 1 then
        for i = 1, N do
          local chain_grad = V2.dw[i]
          V.dw[self.switches[i]] = chain_grad
        end
      else
        local switch_count = 0
        for x = 1, V2.sx do
          for y = 1, V2.sy do
            for i = 1, N do
              local chain_grad = V2:get_grad(x, y, i)
              V:set_grad(x, y, self.switches[i], chain_grad)
              switch_count = switch_count + 1
            end
          end
        end
      end
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type,
        ["group_size"] = self.group_size
      }
    end,
    from_JSON = function(self, json)
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.layer_type = json["layer_type"]
      self.group_size = json["group_size"]
      self.switches = util.zeros(self.group_size)
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.group_size = util.get_opt(opt, "group_size", 2)
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["in_depth"] / self.group_size
      self.layer_type = "maxout"
      self.switches = util.zeros(self.out_sx * self.out_sy * self.out_depth)
    end,
    __base = _base_0,
    __name = "MaxoutLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  MaxoutLayer = _class_0
  return _class_0
end
