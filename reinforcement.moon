class Vec
  new: (@x, @y) =>

  dist_from: (v) =>
    math.sqrt (@x - v.x)^2 + (@y - v.y)^2

  magnitude: =>
    math.sqrt @x^2 + @y^2

  add: (v) =>
    Vec @x + v.x, @y + v.y

  sub: (v) =>
    Vec @x - v.x, @y - v.y

  rotate: (a) =>
    Vec @x * math.cos(a) + @y * math.sin(a), -@x * math.sin(a) + @y * math.cos(a)

  scale: (s) =>
    @x *= s
    @y *= s

  normalize: =>
    @scale 1 / @\magnitude

line_intersect = (p1, p2, p3, p4) ->
  denom = (p4.y - p3.y) * (p2.x - p1.x) - (p4.x - p3.x) * (p2.y - p1.y)

  if denom == 0
    return false

  ua = ((p4.x - p3.x) * (p1.y - p3.y) - (p4.y - p3.y) * (p1.x - p3.x)) / denom
  ub = ((p2.x - p1.x) * (p1.y - p3.y) - (p2.y - p1.y) * (p1.x - p3.x)) / denom

  if ua > 0 and ua < 1 and ub > 0 and ub < 1
    up = Vec p1.x + ua * (p2.x - p1.x), p1.y + ua * (p2.y - p1.y)
    return {
      :ua,
      :ub,
      :up,
    }

  false

line_point_intersect = (p1, p2, p0, rad) ->
  v = Vec p2.y - p1.y, -(p2.x - p1.x)
  d = math.abs (p2.x - p1.x) * (p1.y - p0.y) - (p1.x - p0.x) * (p2.y - p1.y)

  d /= v\magnitude!

  v\normalize!
  v\scale d

  up = p0\add v

  if (math.abs p2.x - p1.x) > math.abs p2.y - p1.y
    ua = (up.x - p1.x) / (p2.x - p1.x)
  else
    ua = (up.y - p1.y) / (p2.y - p1.y)

  if ua > 0 and ua < 1
    return {
      :ua,
      :up,
    }

  false

class Wall
  new: (@p1, @p2) =>

util_add_box = (lst, x, y, w, h) ->
  lst[#lst + 1] = Wall (Vec x, y), Vec x + w, y
  lst[#lst + 1] = Wall (Vec x + w, y), Vec x + w, y + h
  lst[#lst + 1] = Wall (Vec x + w, y + h), Vec x, y + h
  lst[#lst + 1] = Wall (Vec x, y + h), Vec x, y

class Item
  new: (x, y, @type) =>
    @p = Vec x, y
    @rad = 10
    @age = 0
    @clean_up = false

class World
  new: =>
    @agents = {}

    @W = love.graphics.getWidth!
    @H = love.graphics.getHeight!

    @clock = 0

    @walls = {}

    pad = 10

    util_add_box @walls, pad, pad, @W - pad * 2, @H - pad * 2
    util_add_box @walls, 100, 100, 200, 300

    table.remove @walls, 1

    util_add_box @walls, 400, 100, 200, 300

    table.remove @walls, 1

    @items = {}

    for k = 1, 30
      x = util.randf 20, @W - pad * 2
      y = util.randf 20, @H - pad * 2

      t = util.randi 1, 3

      it = Item x, y, t

      @items[#@items + 1] = it


  stuff_collide: (p1, p2, check_walls, check_items) =>
    minres = false

    if check_walls
      for i = 1, #@walls
        wall = @walls[i]
        res  = line_intersect p1, p2, wall.p1, wall.p2

        if res
          res.type = 0

          if not minres
            minres = res
          elseif res.ua < minres.ua
              minres = res

    if check_items
      for i = 1, #@items
        it = @items[i]
        res = line_point_intersect p1, p2, it.p, it.rad

        if res
          res.type = it.type

          if not minres
            minres = res
          elseif res.ua < minres.ua
            minres = res

    minres

  tick: =>
    @clock += 1

    for i = 1, #@agents
      a = @agents[i]
      for ei = 1, #@a.eyes
        e = a.eyes[ei]

        eyep = Vec a.p.x + e.max_range * (math.sin a.angle + e.angle), a.p.y + e.max_range * math.cos a.angle + e.angle
        res  = @\stuff_collide a.p, eyep, true, true

        if res
          e.sensed_proximity = res.up.dist_from a.p
          e.sensed_type = res.type
        else
          e.sensed_proximity = e.max_range
          e.sensed_type = -1

    for i = 1, #@agents
      @agents[i]\forward!

    for i = 1, #@agents
      a = @agents[i]
      a.op = a.p
      a.oangle = a.angle

      v = Vec 0, a.rad / 2
      v = v\rotate a.angle + math.pi / 2

      w1p = a.p\add v
      w2p = a.p\sub v

      vv = a.p\sub(w2p)
      vv = vv\rotate -a.rot1

      vv2 = a.p\sub w1p
      vv2 = vv2\rotate a.rot2

      np = w2p\add vv
      np\scale 0.5

      np2 = w1p\add vv2
      np2\scale 0.5

      a.p = np\add np2

      a.angle -= a.rot1

      if a.angle < 0
        a.angle += 2 * math.pi

      a.angle += a.rot2

      if a.angle > 2 * math.pi
        a.angle -= 2 * math.pi

      res = @\stuff_collide a.op, a.p, true, false

      if res
        a.p = a.op

      if a.p.x < 0
        a.p.x = 0
      if a.p.x > @W
        a.p.x = @W
      if a.p.y < 0
        a.p.y = 0
      if a.p.y > @H
        a.p.y = @H

    update_items = false

    for i = 1, #@items
      it = @items[i]
      it.age += 1

      for j = 1, #@agents
        a = @agents[j]
        d = a.p\dist_from it.p

        if d < it.rad + a.rad

          res_check = @\stuff_collide a.p, it.p, true, false

          if not res_check

            if it.type == 1
              a.digestion_signal += 5 -- yummi! d:
            elseif it.type == 2
              a.digestion_signal -= 6 -- ewww! :d

            it.clean_up  = true
            update_items = true

            break

      if it.age > 5000 and @clock % 100 == 0 and 0.1 > util.randf 0, 1
        it.clean_up  = true
        update_items = true

    if update_items
      nt = {}
      for i = 1, #@items
        it = @items[i]
        if not it.clean_up
          nt[#nt + 1] = it

    if #@items < 30 and @clock % 10 == 0 and 0.25 > util.randf 0, 1
      newitx = util.randf 20, @W - 20
      newity = util.randf
