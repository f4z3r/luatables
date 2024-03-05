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
  :header_separator(false)
  :rows(unpack(data))

print(tbl:render())

local headers = { "Item", "Count", "Price", "Currency" }
local data = {
  { "apple", 15, 7.5, "CHF" },
  { "orange", 3, 5, "CHF" },
  { "computer", 1, 1200, "USD" },
  { "total", 19 },
}

print()

local tbl = tables.Table
  :new()
  :headers(unpack(headers))
  :header_separator(false)
  :rows(unpack(data))
print(tbl:render())
