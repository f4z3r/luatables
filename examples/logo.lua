local tables = require("luatables")

local function format_seps(sep)
  return sep:fg(tables.Color.Red)
end

local function format_cells(_, j, cell)
  if j == 1 then
    return cell:fg(tables.Color.Green):dim()
  end
  return cell:fg(tables.Color.Yellow):bold()
end

local tbl = tables.Table
  :new()
  :headers("Lua", "Tables")
  :header_separator(false)
  :border()
  :border_style(tables.BorderStyle.Double)
  :format_separators(format_seps)
  :format_cells(format_cells)

print()
print()
print(tbl:render())
print()
print()
