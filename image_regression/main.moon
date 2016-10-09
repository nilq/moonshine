require "../convnetmoon/init"

-- very deep ( ͡° ͜ʖ ͡°)
layer_defs = {
  {
    ["type"]: "input",
    ["out_sx"]: 1,
    ["out_sy"]: 1,
    ["out_depth"]: 2,
  },

  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},
  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},
  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},
  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},
  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},
  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},
  {["type"]: "fc", ["num_neurons"]: 20, ["activation"]: "relu",},

  {
    ["type"]: "regression",
    ["num_neurons"]: 3,
  },
}

net = Net layer_defs

trainer = Trainer net, {
  ["learning_rate"]: 0.001,
  ["momentum"]: 0.9,
  ["batch_size"]: 5,
  ["l2_decay"]: 0,
}

batches_interval = 100
draw_interval    = 100
smooth_loss      = -1

print "[initial] done playing around - created net:"
print util.save_json net\to_JSON!
