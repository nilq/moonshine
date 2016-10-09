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
  ["learning_rate"]: 0.01,
  ["momentum"]: 0.9,
  ["batch_size"]: 5,
  ["l2_decay"]: 0,
}

batches_interval = 100
draw_interval    = 100
smooth_loss      = -1
counter          = 0

seed_image = love.image.newImageData "res/datboi.png"
prediction = love.image.newImageData seed_image\getWidth!, seed_image\getHeight!

love.update = (dt) ->
  W = prediction\getWidth!
  H = prediction\getHeight!

  v = Vol 1, 1, 2

  loss   = 0
  loss_i = 0

  N = batches_interval

  for itr = 1, trainer.batch_size
    for i = 1, N
      x = util.randi 1, W - 1
      y = util.randi 1, H - 1

      r, g, b = seed_image\getPixel x, y

      print r / 255, g / 255, b / 255

      color = {r / 255, g / 255, b / 255,}

      v.w[1] = (x - W / 2) / W
      v.w[2] = (y - H / 2) / H

      stats = trainer\train v, color

      loss += stats["loss"]
      loss_i += 1

  loss /= loss_i

  if counter == 0
    smooth_loss = loss
  else
    smooth_loss = 0.99 * smooth_loss + 0.01 * loss

  status = "loss: " .. smooth_loss .. "\n"
  status ..= "iteration: " .. counter

  counter += 1

  if counter % draw_interval != 0
    return

  W = prediction\getWidth!
  H = prediction\getHeight!

  v = Vol 1, 1, 2

  for x = 1, W - 1
    v.w[1] = (x - W / 2) / W
    for y = 1, H - 1
      v.w[2] = (y - H / 2) / H

      r = net\forward v

      prediction\setPixel x, y, 255 * r.w[1], 255 * r.w[2], 255 * r.w[3]

love.draw = ->
  love.graphics.draw (love.graphics.newImage prediction), 0, 0
  love.graphics.draw (love.graphics.newImage seed_image), 400, 0
