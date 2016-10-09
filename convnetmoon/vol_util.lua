local augment
augment = function(V, crop, grayscale)
  if crop == V.sx then
    return V
  end
  local dx = util.randi(0, V.sx - crop)
  local dy = util.randi(0, V.sy - crop)
  local W = Vol(crop, crop, V.depth)
  for x = 1, crop do
    for y = 1, crop do
      local _continue_0 = false
      repeat
        if x + dx < 1 or x + dx >= V.sx or y + dy < 1 or y + dy >= V.sy then
          _continue_0 = true
          break
        end
        for d = 1, V.depth do
          W:set(x, y, d, (V:get(x + dx, y + dy, d)))
        end
        _continue_0 = true
      until true
      if not _continue_0 then
        break
      end
    end
  end
  if grayscale then
    local G = Vol(crop, crop, 1, 0)
    for i = 1, crop do
      for j = 1, crop do
        G:set(i, j, 0, (W:get(i, j, 0)))
      end
    end
    W = G
  end
  return W
end
vol_util = {
  augment = augment
}
