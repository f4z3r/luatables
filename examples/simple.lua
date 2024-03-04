local tables = require("luatables")

local tbl = tables.Table
  :new()
  :border_type(tables.BorderType.None)
  :border(false)
  :column_separator(false)
  :headers("player", "points")
  :rows(
    { "Michael Jordan", 100},
    { "Michael Jórdan", 100},
    { nil, 100},
    { "Michael Jordan", 100}
  )

print(tbl:render())
