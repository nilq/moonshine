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
  ["learning_rate"] = 0.01,
  ["momentum"] = 0.9,
  ["batch_size"] = 5,
  ["l2_decay"] = 0
})
local batches_interval = 100
local draw_interval = 100
local smooth_loss = -1
local counter = 0
local seed_image = love.image.newImageData("res/datboi.png")
local prediction = love.image.newImageData(seed_image:getWidth(), seed_image:getHeight())
love.update = function(dt)
  local W = prediction:getWidth()
  local H = prediction:getHeight()
  local v = Vol(1, 1, 2)
  local loss = 0
  local loss_i = 0
  local N = batches_interval
  for itr = 1, trainer.batch_size do
    for i = 1, N do
      local x = util.randi(1, W - 1)
      local y = util.randi(1, H - 1)
      local r, g, b = seed_image:getPixel(x, y)
      print(r / 255, g / 255, b / 255)
      local color = {
        r / 255,
        g / 255,
        b / 255
      }
      v.w[1] = (x - W / 2) / W
      v.w[2] = (y - H / 2) / H
      local stats = trainer:train(v, color)
      loss = loss + stats["loss"]
      loss_i = loss_i + 1
    end
  end
  loss = loss / loss_i
  if counter == 0 then
    smooth_loss = loss
  else
    smooth_loss = 0.99 * smooth_loss + 0.01 * loss
  end
  local status = "loss: " .. smooth_loss .. "\n"
  status = status .. ("iteration: " .. counter)
  counter = counter + 1
  if counter % draw_interval ~= 0 then
    return 
  end
  W = prediction:getWidth()
  H = prediction:getHeight()
  v = Vol(1, 1, 2)
  for x = 1, W - 1 do
    v.w[1] = (x - W / 2) / W
    for y = 1, H - 1 do
      v.w[2] = (y - H / 2) / H
      local r = net:forward(v)
      prediction:setPixel(x, y, 255 * r.w[1], 255 * r.w[2], 255 * r.w[3])
    end
  end
end
love.draw = function()
  love.graphics.draw((love.graphics.newImage(prediction)), 0, 0)
  return love.graphics.draw((love.graphics.newImage(seed_image)), 400, 0)
end
