do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local A = Vol(1, 1, self.out_depth, 0)
      local as = V.w
      local max_act = V.w[1]
      for i = 1, self.out_depth do
        if as[i] > max_act then
          max_act = as[i]
        end
      end
      self.exps = util.zeros(self.out_depth)
      local esum = 0
      for i = 1, self.out_depth do
        local e = math.exp(as[i] - max_act)
        esum = esum + e
        self.exps[i] = e
      end
      for i = 1, self.out_depth do
        self.exps[i] = self.exps[i] / esum
        A.w[i] = self.exps[i]
      end
      self.es = es
      self.out_act = A
      return self.out_act
    end,
    backward = function(self, y)
      local x = self.in_act
      x.dw = util.zeros(#x.w)
      for i = 1, self.out_depth do
        local indicator = 0
        if i == y then
          indicator = 1
        end
        local mul = -(indicator - self.exps[i])
        x.dw[i] = mul
      end
      return -math.log(self.exps[y])
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_depth"] = self.out_depth,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["layer_type"] = self.layer_type,
        ["num_inputs"] = self.num_inputs
      }
    end,
    from_JSON = function(self, json)
      self.out_depth = json["out_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.layer_type = json["layer_type"]
      self.num_inputs = json["num_inputs"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.num_inputs = opt["in_sx"] * opt["in_sy"] * opt["in_depth"]
      self.out_depth = self.num_inputs
      self.out_sx = 1
      self.out_sy = 1
      self.layer_type = "softmax"
    end,
    __base = _base_0,
    __name = "SoftmaxLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SoftmaxLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      self.out_act = V
      return V
    end,
    backward = function(self, y)
      local x = self.in_act
      x.dw = util.zeros(#x.w)
      local loss = 0
      if y["dim"] == nil and y["val"] == nil then
        for i = 1, self.out_depth do
          local dy = x.w[i] - y[i]
          x.dw[i] = dy
          loss = loss + (2 * dy ^ 2)
        end
      else
        local i = y["dim"]
        local y_i = y["val"]
        local dy = x.w[i] - y_i
        x.dw[i] = dy
        loss = loss + (2 * dy ^ 2)
      end
      return loss
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_depth"] = self.out_depth,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["layer_type"] = self.layer_type,
        ["num_inputs"] = self.num_inputs
      }
    end,
    from_JSON = function(self, json)
      self.out_depth = json["out_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.layer_type = json["layer_type"]
      self.num_inputs = json["num_inputs"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.num_inputs = opt["in_sx"] * opt["in_sy"] * opt["in_depth"]
      self.out_sx = 1
      self.out_sy = 1
      self.out_depth = self.num_inputs
      self.layer_type = "regression"
    end,
    __base = _base_0,
    __name = "RegressionLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  RegressionLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      self.out_act = V
      return V
    end,
    backward = function(self, V)
      local x = self.in_act
      x.dw = util.zeros(#x.w)
      local y_score = x.w[y]
      local margin = 1
      local loss = 0
      for i = 1, self.out_depth do
        if -y_score + x.w[i] + margin > 0 then
          x.dw[i] = x.dw[i] + 1
          x.dw[y] = x.dw[y] - 1
          loss = loss + -y_score + x.w[i] + margin
        end
      end
      return loss
    end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_depth"] = self.out_depth,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["layer_type"] = self.layer_type,
        ["num_inputs"] = self.num_inputs
      }
    end,
    from_JSON = function(self, json)
      self.out_depth = json["out_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.layer_type = json["layer_type"]
      self.num_inputs = json["num_inputs"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.num_inputs = opt["in_sx"] * opt["in_sy"] * opt["in_depth"]
      self.out_depth = opt["out_depth"]
      self.out_sx = 1
      self.out_sy = 1
      self.layer_type = "svm"
    end,
    __base = _base_0,
    __name = "SVMLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  SVMLayer = _class_0
  return _class_0
end
