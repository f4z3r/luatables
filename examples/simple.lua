local tables = require("luatables")

local tbl = tables.Table
  :new()
  :headers("player", "points")
  :rows(
    { "Michael Jordan", 100},
    { "Michael Jordan", 100},
    { "Michael Jordan", 100},
    { "Michael Jordan", 100}
  )

print(tbl:render())
