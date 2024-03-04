local table = require("table")
local text = require("luatext")

local luatables = {}

if not table.unpack and unpack then
  table.unpack = unpack
end

local BORDERS = {
  single = {
    top_left = "┌",
    top_right = "┐",
    bottom_left = "└",
    bottom_right = "┘",
    inner_intersection = "┼",
    outer_left_intersection = "├",
    outer_right_intersection = "┤",
    outer_top_intersection = "┬",
    outer_bottom_intersection = "┴",
    vertical = "│",
    horizontal = "─",
  },
  double = {
    top_left = "╔",
    top_right = "╗",
    bottom_left = "╚",
    bottom_right = "╝",
    inner_intersection = "╬",
    outer_left_intersection = "╠",
    outer_right_intersection = "╣",
    outer_top_intersection = "╦",
    outer_bottom_intersection = "╩",
    vertical = "║",
    horizontal = "═",
  },
  fat = {
    top_left = "┏",
    top_right = "┓",
    bottom_left = "┗",
    bottom_right = "┛",
    inner_intersection = "╋",
    outer_left_intersection = "┣",
    outer_right_intersection = "┫",
    outer_top_intersection = "┳",
    outer_bottom_intersection = "┻",
    vertical = "┃",
    horizontal = "━",
  },
}

---@enum BorderType
local BorderType = {
  None = "none",
  Single = "single",
  Double = "double",
  Fat = "fat",
}

luatables.BorderType = BorderType

---@class Table
local Table = {
  _nil = "",
  _border_type = BorderType.Single,
  _border = false,
  _row_separator = false,
  _column_separator = true,
  _header_separator = true,
}

---create a new table
---@return Table
function Table:new()
  local o = {
    _data = {},
    _nil = Table._nil,
    _border_type = Table._border_type,
    _border = Table._border,
    _row_separator = Table._row_separator,
    _column_separator = Table._column_separator,
    _header_separator = Table._header_separator,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---set the headers for the table
---@vararg any
---@return Table
function Table:headers(...)
  self._headers = { ... }
  return self
end

---add a row to the table
---@vararg any
---@return Table
function Table:row(...)
  self._data[#self._data + 1] = { ... }
  return self
end

---add a set of rows to the table
---@vararg any[]
---@return Table
function Table:rows(...)
  for _, row in ipairs({ ... }) do
    self:row(table.unpack(row))
  end
  return self
end

---set the default string to replace nil values in the table
---@param str string
---@return Table
function Table:null(str)
  self._nil = str
  return self
end

---set the border type of this table
---@param type BorderType
---@return Table
function Table:border_type(type)
  self._border_type = type
  return self
end

---enable borders
---@param enabled boolean?
---@return Table
function Table:border(enabled)
  if enabled == nil then
    enabled = true
  end
  self._border = enabled
  return self
end

---enable row separators
---@param enabled boolean?
---@return Table
function Table:row_separator(enabled)
  if enabled == nil then
    enabled = true
  end
  self._row_separator = enabled
  return self
end

---enable column separators
---@param enabled boolean?
---@return Table
function Table:column_separator(enabled)
  if enabled == nil then
    enabled = true
  end
  self._column_separator = enabled
  return self
end

---enable header separators
---@param enabled boolean?
---@return Table
function Table:header_separator(enabled)
  if enabled == nil then
    enabled = true
  end
  self._header_separator = enabled
  return self
end

---@private
function Table:replace_nil()
  local row_length = self:row_length()
  for idx = 1, row_length do
    self._headers[idx] = self._headers[idx] or self._nil
    for _, row in ipairs(self._data) do
      row[idx] = row[idx] or self._nil
    end
  end
end

---@private
function Table:format_str()
  local widths = self:column_widths()
  local formats = {}
  for _, width in ipairs(widths) do
    formats[#formats + 1] = string.format("%%-%ds", width)
  end
  local col_separator = "   "
  if self._column_separator then
    col_separator = " " .. BORDERS[self._border_type].vertical .. " "
  end
  return table.concat(formats, col_separator)
end

---@private
function Table:column_width(idx)
  local max = (self._headers[idx] or ""):len()
  for _, row in ipairs(self._data) do
    max = math.max(max, (tostring(row[idx]) or ""):len())
  end
  return max
end

---@private
function Table:column_widths()
  local res = {}
  local row_length = self:row_length()
  for idx = 1, row_length do
    res[#res + 1] = self:column_width(idx)
  end
  return res
end

---@private
function Table:row_length()
  local max = #self._headers
  for _, row in ipairs(self._data) do
    max = math.max(max, #row)
  end
  return max
end

---@private
function Table:render_row_separator()
  if self._row_separator == BorderType.None then
    return nil
  end
  local row_separator = BORDERS[self._border_type].horizontal
  local intersection = string.rep(row_separator, 3)
  if self._column_separator then
    intersection = row_separator .. BORDERS[self._border_type].inner_intersection .. row_separator
  end
  local widths = self:column_widths()
  local cols = {}
  for _, width in ipairs(widths) do
    cols[#cols + 1] = string.rep(row_separator, width)
  end
  return table.concat(cols, intersection)
end

---@private
function Table:render_rows()
  local fmt = self:format_str()
  local rows = {}
  for _, row in ipairs(self._data) do
    rows[#rows + 1] = string.format(fmt, table.unpack(row))
  end
  return rows
end

---@private
function Table:render_header_separator()
  local row_separator = BORDERS[self._border_type].horizontal
  local intersection = string.rep(row_separator, 3)
  if self._column_separator then
    intersection = row_separator .. BORDERS[self._border_type].inner_intersection .. row_separator
  end
  local widths = self:column_widths()
  local cols = {}
  for _, width in ipairs(widths) do
    cols[#cols + 1] = string.rep(row_separator, width)
  end
  return table.concat(cols, intersection)
end

---@private
function Table:render_header()
  local fmt = self:format_str()
  local res = {
    string.format(fmt, table.unpack(self._headers)),
  }
  if self._header_separator then
    res[#res + 1] = self:render_header_separator()
  end
  return res
end

function Table:render()
  -- work with copy of data to avoid modifying original data
  self:replace_nil()
  local res = self:render_header()
  local rows = self:render_rows()
  local row_sep = self:render_row_separator()
  for idx, row in ipairs(rows) do
    res[#res + 1] = row
    if self._row_separator and idx ~= #rows then
      res[#res + 1] = row_sep
    end
  end
  return table.concat(res, "\n")
end

luatables.Table = Table

return luatables
