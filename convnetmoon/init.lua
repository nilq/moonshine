local root = "convnetmoon/"
local modules = {
  "util",
  "vol",
  "net",
  "trainer",
  "layers/input",
  "layers/dotproduct",
  "layers/nonlinear",
  "layers/loss",
  "layers/normalization",
  "layers/dropout",
  "layers/pooling"
}
json = require(root .. "extern/json")
for _, v in pairs(modules) do
  require(root .. v)
end
