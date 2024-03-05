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

local function format_cells(i, j, cell)
  if i % 2 == 0 then
    return cell:fg(160)
  end
  return cell
end

local function format_seps(sep)
  return sep:fg(160)
end

local tbl = tables.Table
  :new()
  :headers(unpack(headers))
  :rows(unpack(data))

print(tbl:render())
