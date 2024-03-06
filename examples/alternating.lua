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
  if i == 0 then           -- set the header background
    return row:bg(232)
  elseif i % 2 == 0 then   -- alternate row backgrounds for data
    return row:bg(235)
  else
    return row:bg(237)
  end
end

local function format_cells(i, _, cell)
  if i == #data then      -- set foreground of final data row
    return cell:fg(246)
  end
  return cell:fg(255)     -- set other cells foreground
end

local tbl = tables.Table
    :new()
    :headers(unpack(headers))
    :rows(unpack(data))
    :null("n/a")                              -- replace nils
    :header_separator(false)                  -- do not print a separator between header and data
    :border_style(tables.BorderStyle.Double)  -- use double lines in borders and separators
    :format_rows(format_rows)                 -- format rows using the function above
    :format_cells(format_cells)               -- format cells using the function above

print(tbl:render())
