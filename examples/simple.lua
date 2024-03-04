local tables = require("luatables")

local tbl = tables.Table
  :new()
  :border_type(tables.BorderType.Fat)
  :headers("player", "points")
  :rows(
    { "Michael Jordan", 100},
    { "Michael Jordan", 100},
    { nil, 100},
    { "Michael Jordan", 100}
  )

print(tbl:render())
