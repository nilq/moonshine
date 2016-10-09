do
  local _class_0
  local _base_0 = {
    forward = function(self, V, is_training)
      self.in_act = V
      local A = Vol(self.out_sx, self.out_sy, self.out_depth, 0)
      local v_sx = V.sx
      local v_sy = V.sy
      local xy_stride = self.stride
      for d = 1, self.out_depth do
        local f = self.filters[d]
        local x = -self.pad
        local y = -self.pad
        for ay = 1, self.out_sy do
          x = -self.pad
          for ax = 1, self.out_sx do
            local sum_a = 0
            for fy = 1, f.sy do
              local off_y = y + fy
              for fx = 1, f.sx do
                if off_y >= 0 and off_y < V.sy and off_x >= 0 and off_x < V.sx then
                  for fd = 1, f.depth do
                    sum_a = sum_a + (f.w[((f.sx * fy) + fx) * f.depth + fd] * V.w[((v_sx * off_y) + off_x) * V.depth + fd])
                  end
                end
              end
            end
            sum_a = sum_a + self.biases.w[d]
            A:set(ax, ay, d, sum_a)
            x = x + xy_stride
          end
          y = y + xy_stride
        end
      end
      self.out_act = A
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      V.dw = util.zeros(#V.w)
      local v_sx = V.sx
      local v_sy = V.sy
      local xy_stride = self.stride
      for d = 1, self.out_depth do
        local f = self.filters[d]
        local x = -self.pad
        local y = -self.pad
        for ay = 1, self.out_sy do
          x = -self.pad
          for ax = 1, self.out_sx do
            local chain_grad = self.out_act:get_grad(ax, ay, d)
            for fy = 1, f.sy do
              local off_y = y + fy
              for fx = 1, f.sx do
                local off_x = x + fx
                if off_y >= 0 and off_y < V.sy and off_x >= 0 and off_x < V.sx then
                  local ix1 = ((v_sx * off_y) + off_y) * V.depth + fd
                  local ix2 = ((f.sx * fy) + fx) * f.depth + fd
                  f.dw[ix2] = f.dw[ix2] + (V.w[ix1] * chain_grad)
                  V.dw[ix1] = V.dw[ix1] + (f.w[ix2] * chain_grad)
                end
              end
            end
            self.biases.dw[d] = self.biases.dw[d] + chain_grad
            x = x + xy_stride
          end
          y = y + xy_stride
        end
      end
    end,
    get_params_and_grads = function(self)
      local response = { }
      for d = 1, self.out_depth do
        response[#response + 1] = {
          ["params"] = self.filters[d].w,
          ["grads"] = self.filters[d].dw,
          ["l2_decay_mul"] = self.l2_decay_mul,
          ["l1_decay_mul"] = self.l1_decay_mul
        }
      end
      response[#response + 1] = {
        ["params"] = self.biases.w,
        ["grads"] = self.biases.dw,
        ["l2_decay_mul"] = 0,
        ["l1_decay_mul"] = 0
      }
      return response
    end,
    to_JSON = function(self)
      return {
        ["sx"] = self.sx,
        ["sy"] = self.sy,
        ["stride"] = self.stride,
        ["in_depth"] = self.in_depth,
        ["out_depth"] = self.out_depth,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["layer_type"] = self.layer_type,
        ["l2_decay_mul"] = self.l2_decay_mul,
        ["l1_decay_mul"] = self.l1_decay_mul,
        ["pad"] = self.pad,
        ["filters"] = (function()
          local _tbl_0 = { }
          for _, f in pairs(self.filters) do
            local _key_0, _val_0 = f:to_JSON()
            _tbl_0[_key_0] = _val_0
          end
          return _tbl_0
        end)(),
        ["biases"] = self.biases:to_JSON()
      }
    end,
    from_JSON = function(self, json)
      self.sx = json["sx"]
      self.sy = json["sy"]
      self.stride = json["stride"](y)
      self.in_depth = json["in_depth"]
      self.out_depth = json["out_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.layer_type = json["layer_type"]
      self.l2_decay_mul = json["l2_decay_mul"]
      self.l1_decay_mul = json["l1_decay_mul"]
      self.pad = json["pad"]
      do
        local _tbl_0 = { }
        for _, f in pairs(json["filters"]) do
          local _key_0, _val_0 = (Vol(0, 0, 0, 0)):from_JSON(f)
          _tbl_0[_key_0] = _val_0
        end
        self.filters = _tbl_0
      end
      self.biases = (Vol(0, 0, 0, 0)):from_JSON(json["biases"])
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_depth = opt["filters"]
      self.sx = opt["sx"]
      self.in_depth = opt["in_depth"]
      self.in_sx = opt["in_sx"]
      self.in_sy = opt["in_sy"]
      self.sy = util.get_opt(opt, "sy", self.sx)
      self.stride = util.get_opt(opt, "stride", 1)
      self.pad = util.get_opt(opt, "stride", 0)
      self.s = opt["in_sx"] * opt["in_sy"] * opt["in_depth"]
      self.l2_decay_mul = util.get_opt(opt, "l2_decay_mul", 1)
      self.l1_decay_mul = util.get_opt(opt, "l1_decay_mul", 0)
      self.out_sx = (math.floor(self.in_sx - self.sx + 2 * self.pad)) / self.stride + 1
      self.out_sy = (math.floor(self.in_sy - self.sy + 2 * self.pad)) / self.stride + 1
      self.layer_type = "conv"
      local bias = util.get_opt(opt, "bias_pref", 0)
      for i = 1, self.out_depth do
        self.filters[#self.filters + 1] = Vol(1, 1, self.s)
      end
      self.biases = Vol(1, 1, self.out_depth, bias)
    end,
    __base = _base_0,
    __name = "ConvLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  ConvLayer = _class_0
end
do
  local _class_0
  local _base_0 = {
    forward = function(self, V)
      self.in_act = V
      local A = Vol(1, 1, self.out_depth, 0)
      local Vw = V.w
      for i = 1, self.out_depth do
        local sum_a = 0
        local fiw = self.filters[i].w
        for d = 1, self.s do
          sum_a = sum_a + (Vw[d] * fiw[d])
        end
        sum_a = sum_a + self.biases.w[i]
        A.w[i] = sum_a
      end
      self.out_act = A
      return self.out_act
    end,
    backward = function(self)
      local V = self.in_act
      V.dw = util.zeros(#V.w)
      for i = 1, self.out_depth do
        local fi = self.filters[i]
        local chain_grad = self.out_act.dw[i]
        for d = 1, self.s do
          V.dw[d] = V.dw[d] + (fi.w[d] * chain_grad)
          fi.dw[d] = fi.dw[d] + (V.w[d] * chain_grad)
        end
        self.biases.dw[i] = self.biases.dw[i] + chain_grad
      end
    end,
    get_params_and_grads = function(self)
      local response = { }
      for d = 1, self.out_depth do
        response[#response + 1] = {
          ["params"] = self.filters[d].w,
          ["grads"] = self.filters[d].dw,
          ["l2_decay_mul"] = self.l2_decay_mul,
          ["l1_decay_mul"] = self.l1_decay_mul
        }
      end
      response[#response + 1] = {
        ["params"] = self.biases.w,
        ["grads"] = self.biases.dw,
        ["l2_decay_mul"] = 0,
        ["l1_decay_mul"] = 0
      }
      return response
    end,
    to_JSON = function(self)
      return {
        ["out_depth"] = self.out_depth,
        ["out_sx"] = self.out_sx,
        ["out_sy"] = self.out_sy,
        ["layer_type"] = self.layer_type,
        ["s"] = self.s,
        ["l2_decay_mul"] = self.l2_decay_mul,
        ["l1_decay_mul"] = self.l1_decay_mul,
        ["filters"] = (function()
          local _tbl_0 = { }
          for _, v in pairs(self.filters) do
            local _key_0, _val_0 = v:to_JSON()
            _tbl_0[_key_0] = _val_0
          end
          return _tbl_0
        end)(),
        ["biases"] = self.biases:to_JSON()
      }
    end,
    from_JSON = function(self, json)
      self.out_depth = json["out_depth"]
      self.out_sx = json["out_sx"]
      self.out_sy = json["out_sy"]
      self.layer_type = json["layer_type"]
      self.s = json["s"]
      self.l2_decay_mul = json["l2_decay_mul"]
      self.l1_decay_mul = json["l1_decay_mul"]
      do
        local _accum_0 = { }
        local _len_0 = 1
        for f in json["filters"] do
          _accum_0[_len_0] = (Vol(0, 0, 0, 0):from_JSON(f))
          _len_0 = _len_0 + 1
        end
        self.filters = _accum_0
      end
      self.biases = Vol(0, 0, 0, 0):from_JSON(json["biases"])
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, opt)
      self.out_depth = opt["num_neurons"]
      self.l2_decay_mul = util.get_opt(opt, "l2_decay_mul", 1)
      self.l1_decay_mul = util.get_opt(opt, "l1_decay_mul", 0)
      self.s = opt["in_sx"] * opt["in_sy"] * opt["in_depth"]
      self.out_sx = 1
      self.out_sy = 1
      self.layer_type = "fc"
      local bias = util.get_opt(opt, "bias_pref", 0)
      self.filters = { }
      for i = 1, self.out_depth do
        self.filters[#self.filters + 1] = Vol(1, 1, self.s)
      end
      self.biases = Vol(1, 1, self.out_depth, bias)
    end,
    __base = _base_0,
    __name = "FullyConnectedLayer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  FullyConnectedLayer = _class_0
  return _class_0
end
