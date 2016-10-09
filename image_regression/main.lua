require("../convnetmoon/init")
local layer_defs = {
  {
    ["type"] = "input",
    ["out_sx"] = 1,
    ["out_sy"] = 1,
    ["out_depth"] = 2
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "fc",
    ["num_neurons"] = 20,
    ["activation"] = "relu"
  },
  {
    ["type"] = "regression",
    ["num_neurons"] = 3
  }
}
local net = Net(layer_defs)
local trainer = Trainer(net, {
  ["learning_rate"] = 0.001,
  ["momentum"] = 0.9,
  ["batch_size"] = 5,
  ["l2_decay"] = 0
})
local batches_interval = 100
local draw_interval = 100
local smooth_loss = -1
print("[initial] done playing around - created net:")
return print(util.save_json(net:to_JSON()))
