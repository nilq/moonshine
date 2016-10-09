do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      self.out_act = V
      return self.out_act
    end,
    backward = function(self) end,
    get_params_and_grads = function(self)
      return { }
    end,
    to_JSON = function(self)
      return {
        ["out_depth"] = self.out_depth,
        ["out_sx"] = self.sx,
        ["out_sy"] = self.sy,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.out_depth = json["out_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.layer_type = json["layer_type"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_sx = opt["out_sx"]
      self.out_sy = opt["out_sy"]
      self.out_depth = opt["out_depth"]
      self.layer_type = "input"
    end,
    __base = _base_0,
    __name = "InputLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  InputLayer = _class_0
end
