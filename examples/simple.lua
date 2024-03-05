local tables = require("luatables")
local string = require("string")

local headers = {
  "Item",
  "Count",
  "Cost",
}

local data = {
  { "apples",  15, "CHF 30" },
  { "oranges", 2,  "CHF 6" },
  { "bananas", 0 },
  { "total",   17, "CHF 36" },
}

local function format_cells(i, j, cell)
  if string.find(cell._data, "n/a") then
    return cell:dim()
  end
  if i == 4 then
    cell:bold():fg(58)
  end
  return cell
end

local function format_rows(i, _, row)
  if i == 0 then
    return row:fg(tables.Color.Red)
  end
  return row
end

local function format_seps(sep)
  return sep:fg(tables.Color.Cyan)
end

local tbl = tables.Table
    :new()
    :headers(unpack(headers))
    :border()
    :null("n/a")
    :format_rows(format_rows)
    :format_separators(format_seps)
    :format_cells(format_cells)
    :border_style(tables.BorderStyle.Double)
    :header_separator()
    :rows(unpack(data))

print(tbl:render())
