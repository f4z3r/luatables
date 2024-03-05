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
    return cell:fg(160):blink()
  end
  return cell
end

local function format_seps(sep)
  return sep:fg(16)
end

local tbl = tables.Table
  :new()
  :border_type(tables.BorderType.Double)
  :border(true)
  :column_separator(function(idx)
    return idx==3
  end)
  :row_separator(function(idx)
    return idx==4
  end)
  :headers(unpack(headers))
  :format_cells(format_cells)
  :format_separators(format_seps)
  :null("n/a")
  :rows(unpack(data))

print(tbl:render())
