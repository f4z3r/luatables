local tables = require("luatables")

local headers = {
  "item",
  "count",
  "cost"
}

local data = {
  { "apples", 15, "CHF 30" },
  { "oranges", 2, "CHF 6" },
  { "bananas", 0, tables.Nil },
  { "total", 17, "CHF 36" },
}

local tbl = tables.Table
  :new()
  :border_type(tables.BorderType.Single)
  :border(true)
  :column_separator(function(idx)
    return idx==3
  end)
  :row_separator(function(idx)
    return idx==4
  end)
  :headers(unpack(headers))
  :null("n/a")
  :rows(unpack(data))

print(tbl:render())
