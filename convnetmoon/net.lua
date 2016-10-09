do
  local _class_0
  local _base_0 = {
    make_layers = function(self, layers)
      if #layers < 2 then
        error("[net] layer definitions must contain atleast input and output layer!")
      end
      if layers[1]["type"] ~= "input" then
        error("[net] first layer must be 'input'!")
      end
      local add_hidden_layers
      add_hidden_layers = function(self)
        local new_layers = { }
        for _, l in pairs(layers) do
          local layer_type = l["type"]
          if layer_type == "softmax" or layer_type == "svm" then
            new_layers[#new_layers + 1] = {
              ["type"] = "fc",
              ["num_neurons"] = l["num_classes"]
            }
          elseif layer_type == "regression" then
            new_layers[#new_layers + 1] = {
              ["type"] = "fc",
              ["num_neurons"] = l["num_neurons"]
            }
          elseif ((layer_type == "fc" or layer_type == "conv") and l["bias_pref"] == nil) then
            l["bias_pref"] = 0
            if l["activation"] == "relu" then
              l["bias_pref"] = 0.1
            end
          elseif l["activation"] then
            local l_act = l["activation"]
            if l_act == "relu" or l_act == "sigmoid" or l_act == "tanh" or l_act == "mex" then
              new_layers[#new_layers + 1] = {
                ["type"] = l_act
              }
            elseif l_act == "maxout" then
              new_layers[#new_layers + 1] = {
                ["type"] = l_act,
                ["group_size"] = l["group_size"] or 2
              }
            end
          elseif layer_type == "dropout" then
            new_layers[#new_layers + 1] = {
              ["type"] = "dropout",
              ["drop_prob"] = l["drop_prob"]
            }
          end
          if layer_type ~= "capsule" then
            new_layers[#new_layers + 1] = l
          end
        end
        if layer_type == "capsule" then
          local fc_recog = {
            ["type"] = "fc",
            ["num_neurons"] = l["num_recog"]
          }
          local pose = {
            ["type"] = "add",
            ["delta"] = {
              l["dx"],
              l["dy"]
            },
            ["skip"] = 1,
            ["num_neurons"] = l["num_pose"]
          }
          local fc_gen = {
            ["type"] = "fc",
            ["num_neurons"] = l["num_gen"]
          }
          new_layers[#new_layers + 1] = fc_recog
          new_layers[#new_layers + 1] = pose
          new_layers[#new_layers + 1] = fc_gen
        end
        return new_layers
      end
      local all_layers = add_hidden_layers()
      for i = 1, #all_layers do
        local _continue_0 = false
        repeat
          local l = all_layers[i]
          if i > 1 then
            local prev = self.layers[i - 1]
            l["in_sx"] = prev.out_sx
            l["in_sy"] = prev.out_sy
            l["in_depth"] = prev.out_depth
          end
          local layer_type = l["type"]
          local layer = { }
          local _exp_0 = layer_type
          if "input" == _exp_0 then
            layer = InputLayer(l)
          elseif "lrn" == _exp_0 then
            layer = LocalResponseNormalizationLayer(l)
          elseif "relu" == _exp_0 then
            layer = ReluLayer(l)
          elseif "sigmoid" == _exp_0 then
            layer = SigmoidLayer(l)
          elseif "tanh" == _exp_0 then
            layer = TanhLayer(l)
          elseif "maxout" == _exp_0 then
            layer = MaxoutLayer(l)
          elseif "fc" == _exp_0 then
            layer = FullyConnectedLayer(l)
          elseif "softmax" == _exp_0 then
            layer = SoftmaxLayer(l)
          elseif "regression" == _exp_0 then
            layer = RegressionLayer(l)
          elseif "svm" == _exp_0 then
            layer = SVMLayer(l)
          elseif "dropout" == _exp_0 then
            layer = DropoutLayer(l)
          elseif "pooling" == _exp_0 then
            layer = PoolingLayer(l)
          elseif "capsule" == _exp_0 then
            _continue_0 = true
            break
          else
            error("[net] unrecognized layer '" .. layer_type .. "'!")
          end
          if layer then
            self.layers[#self.layers + 1] = layer
          end
          _continue_0 = true
        until true
        if not _continue_0 then
          break
        end
      end
    end,
    forward = function(self, V, is_training)
      local activation = self.layers[1]:forward(V, is_training)
      for i = 2, #self.layers do
        activation = self.layers[i]:forward(activation, is_training)
      end
      return activation
    end,
    get_cost_loss = function(self, V, y)
      return self:forward(V, false)
    end,
    backward = function(self, y)
      local loss = self.layers[#self.layers]:backward(y)
      for i = #self.layers - 1, 1, -1 do
        self.layers[i]:backward()
      end
      return loss
    end,
    get_params_and_grads = function(self)
      local response = { }
      for i = 1, #self.layers do
        local l_response = self.layers[i]:get_params_and_grads()
        for j = 1, #l_response do
          response[#response + 1] = l_response[j]
        end
      end
      return response
    end,
    get_prediction = function(self)
      local softmax = self.layers[#self.layers]
      local p = softmax.out_act.w
      local max_i = (util.maxmin(p)).max_i
      return max_i
    end,
    to_JSON = function(self)
      local json = { }
      json.layers = { }
      for _, v in pairs(self.layers) do
        table.insert(json.layers, v:to_JSON())
      end
      return json
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, layers)
      self.layers = { }
      return self:make_layers(layers)
    end,
    __base = _base_0,
    __name = "Net"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Net = _class_0
end
