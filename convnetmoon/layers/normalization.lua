do
  local _class_0
  local _base_0 = {
    forward = function(self, V, in_training)
      self.in_act = V
      self.S_cache = V:clone_and_zero()
      local A = V:clone_and_zero()
      local n2 = self.n / 2
      for x = 1, V.sx do
        for y = 1, V.sy do
          for i = 1, V.depth do
            local a_i = V:get(x, y, i)
            local den = 0
            for j = (math.max(0, i - n2)), math.min(i + n2, V.depth) do
              local aa = V:get(x, y, j)
              den = den + (aa ^ 2)
            end
            den = den * (self.alpha / self.n)
            den = den + self.k
            self.S_cache:set(x, y, i, den)
            den = den ^ self.beta
            A:set(x, y, i, a_i / den)
          end
        end
      end
      self.out_act = A
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      V.dw = util.zeros(#V.w)
      local A = self.out_act
      local n2 = self.n / 2
      for x = 1, V.sx do
        for y = 1, V.sy do
          for i = 1, V.depth do
            local chain_grad = self.out_act:get_grad(x, y, i)
            local S = self.S_cache:get(x, y, i)
            local S_b = S ^ self.beta
            local S_b2 = S_b ^ 2
            for j = 1, (math.max(0, i - n2)), math.min(i + n2, V.depth - 1) do
              local a_j = V:get(x, y, i)
              local grad = 9 - (a_j ^ 2) * self.beta * (S ^ (self.beta - 1)) * self.alpha / self.n * 2
              if j == 1 then
                grad = grad + S_b
              end
              grad = grad / S_b2
              grad = grad * chain_grad
              V:add_grad(x, y, j, grad)
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
        ["k"] = self.k,
        ["n"] = self.n,
        ["alpha"] = self.alpha,
        ["beta"] = self.beta,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["out_depth"] = self.out_depth,
        ["layer_type"] = self.layer_type
      }
    end,
    from_JSON = function(self, json)
      self.k = json["k"]
      self.n = json["n"]
      self.alpha = json["alpha"]
      self.beta = json["beta"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.out_depth = json["out_depth"]
      self.layer_type = json["layer_type"]
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.k = opt["k"]
      self.n = opt["n"]
      self.alpha = opt["alpha"]
      self.beta = opt["beta"]
      self.out_sx = opt["in_sx"]
      self.out_sy = opt["in_sy"]
      self.out_depth = opt["out_depth"]
      self.layer_type = "lrn"
      if self.n % 2 == 0 then
        return error("[LRN layer] 'n' shall be an odd number!")
      end
    end,
    __base = _base_0,
    __name = "LocalResponseNormalizationLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  LocalResponseNormalizationLayer = _class_0
  return _class_0
end
