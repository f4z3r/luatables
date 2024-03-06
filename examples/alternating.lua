local tables = require("luatables")

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

local function format_rows(i, _, row)
  if i == 0 then
    return row:bg(232)
  elseif i % 2 == 0 then
    return row:bg(235)
  else
    return row:bg(237)
  end
end

local function format_cells(i, j, cell)
  if i == 4 then
    return cell:fg(246)
  end
  return cell:fg(tables.Color.White)
end

local tbl = tables.Table
    :new()
    :headers(unpack(headers))
    :null("")
    :format_rows(format_rows)
    :format_cells(format_cells)
    :border_style(tables.BorderStyle.Double)
    :header_separator(false)
    :rows(unpack(data))

print(tbl:render())
