do
  local _class_0
  local _base_0 = {
    train = function(self, x, y)
      self.k = self.k + 1
      local start = os.time()
      self.net:forward(x, true)
      local fwd_time = os.difftime(os.time(), start)
      start = os.time()
      local cost_loss = self.net:backward(y)
      local l2_decay_loss = 0
      local l1_decay_loss = 0
      local bwd_time = os.difftime(os.time(), start)
      if self.k % self.batch_size == 0 then
        local pglist = self.net:get_params_and_grads()
        if #self.gsum == 0 and (self.method ~= "sgd" or self.momentum > 0) then
          for _, e in pairs(pglist) do
            self.gsum[#self.gsum + 1] = util.zeros(#e["params"])
            if self.method == "adadelta" then
              self.xsum[#self.xsum + 1] = util.zeros(#e["params"])
            else
              self.xsum[#self.xsum + 1] = { }
            end
          end
        end
        for i = 1, #pglist do
          local pg = pglist[i]
          local p = pg["params"]
          local g = pg["grads"]
          local l2_decay_mul = util.get_opt(pg, "l2_decay_mul", 1)
          local l1_decay_mul = util.get_opt(pg, "l1_decay_mul", 1)
          local l2_decay = self.l2_decay * l2_decay_mul
          local l1_decay = self.l1_decay * l1_decay_mul
          for j = 1, #p do
            l2_decay_loss = l2_decay_loss + (l2_decay * p[j] ^ 2 / 2)
            l1_decay_loss = l1_decay_loss + (l1_decay * math.abs(p[j]))
            local l1_grad = -p[j]
            if p[j] > 0 then
              l1_grad = 0
            end
            local l2_grad = l2_decay * p[j]
            local gij = (l2_grad + l1_grad + g[j]) / self.batch_size
            local gsumi = self.gsum[i]
            local xsumi = self.xsum[i]
            if self.method == "adagrad" then
              gsumi[j] = gsumi[j] + (gij ^ 2)
              local dx = -self.learning_rate / gij * math.sqrt(gsumi[j] + self.eps)
              p[j] = p[j] + dx
            elseif self.method == "windowgrad" then
              gsumi[j] = self.ro * gsumi[j] + (1 - self.ro) * gij ^ 2
              local dx = -math.sqrt((xsumi[j] + self.eps) / (gsumi[j] + self.eps) * gij)
              p[j] = p[j] + dx
            else
              if self.momentum > 0 then
                local dx = self.momentum * gsumi[j] - self.learning_rate * gij
                gsumi[j] = dx
                p[j] = p[j] + dx
              else
                p[j] = p[j] + -self.learning_rate * gij
              end
            end
            g[j] = 0
          end
        end
      end
      return {
        ["k"] = self.k,
        ["fwd_time"] = fwd_time,
        ["bwd_time"] = bwd_time,
        ["time"] = fwd_time + bwd_time,
        ["l2_decay_loss"] = l2_decay_loss,
        ["l1_decay_loss"] = l1_decay_loss,
        ["cost_loss"] = cost_loss,
        ["loss"] = cost_loss + l1_decay_loss + l2_decay_loss
      }
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, net, opt)
      self.net, self.opt = net, opt
      self.learning_rate = util.get_opt(opt, "learning_rate", 0.01)
      self.l1_decay = util.get_opt(opt, "l1_decay", 0)
      self.l2_decay = util.get_opt(opt, "l2_decay", 0)
      self.batch_size = util.get_opt(opt, "batch_size", 1)
      self.method = util.get_opt(opt, "method", "sgd")
      self.momentum = util.get_opt(opt, "momentum", 0.9)
      self.ro = util.get_opt(opt, "ro", 0.95)
      self.eps = util.get_opt(opt, "eps", 1e-6)
      self.k = 0
      self.gsum = { }
      self.xsum = { }
    end,
    __base = _base_0,
    __name = "Trainer"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  Trainer = _class_0
end
