local table = require("table")
local text = require("luatext")
local utf8 = require("lua-utf8")

---@class Text
---@see https://github.com/f4z3r/luatext/blob/v1.0.0/docs/reference.md#text
local Text = text.Text

local luatables = {}

-- compatibility
if not table.unpack and unpack then
  table.unpack = unpack
end

local BORDERS = {
  single = {
    top = {
      left = "┌",
      center = "┬",
      right = "┐",
    },
    bottom = {
      left = "└",
      center = "┴",
      right = "┘",
    },
    inner = {
      left = "├",
      center = "┼",
      right = "┤",
    },
    vertical = "│",
    horizontal = "─",
  },
  double = {
    top = {
      left = "╔",
      center = "╦",
      right = "╗",
    },
    bottom = {
      left = "╚",
      center = "╩",
      right = "╝",
    },
    inner = {
      left = "╠",
      center = "╬",
      right = "╣",
    },
    vertical = "║",
    horizontal = "═",
  },
  fat = {
    top = {
      left = "┏",
      center = "┳",
      right = "┓",
    },
    bottom = {
      left = "┗",
      center = "┻",
      right = "┛",
    },
    inner = {
      left = "┣",
      center = "╋",
      right = "┫",
    },
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

---format strings respecting utf8 characters
---@param fmt string the format string
---@param ... any
---@return string
local function format(fmt, ...)
  local args, strings, pos = { ... }, {}, 0
  for spec in fmt:gmatch("%%.-([%a%%])") do
    pos = pos + 1
    local s = args[pos]
    if spec == "s" and type(s) == "string" and s ~= "" then
      table.insert(strings, s)
      args[pos] = "\1" .. ("\2"):rep(utf8.len(s) - 1)
    end
  end
  return (fmt:format(table.unpack(args)):gsub("\1\2*", function()
    return table.remove(strings, 1)
  end))
end

if _TEST then
  luatables.format = format
end

---replace nil values in an array with a replacement
---@param data any[]
---@param repl any
---@return any[]
local function replace_nil(data, repl)
  local res = {}
  for _, val in ipairs(data) do
    if val == nil then
      res[#res + 1] = repl
    else
      res[#res + 1] = val
    end
  end
  return res
end

---@class Table
---@field private _headers table?
---@field private _data table[]
---@field private _nil string
---@field private _border_type BorderType
---@field private _border boolean
---@field private _row_separator boolean
---@field private _column_separator boolean
---@field private _header_separator boolean
---@field private _padding number
local Table = {}

---create a new table
---@return Table
function Table:new()
  local o = {
    _data = {},
    _headers = nil,
    _nil = "",
    _border_type = BorderType.Single,
    _border = true,
    _row_separator = false,
    _column_separator = true,
    _header_separator = true,
    _padding = 1,
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

---format the individual cells of the table
---@param fun fun(i: number, j: number, content: Text): Text
---@return Table
function Table:format_cells(fun)
  error("not implemented")
  return self
end

---format the header row
---@param fun fun(headers: Text): Text
---@return Table
function Table:format_header(fun)
  error("not implemented")
  return self
end

---format the data rows
---@param fun fun(idx: number, row: Text): Text
---@return Table
function Table:format_rows(fun)
  error("not implemented")
  return self
end

---format the data rows
---@param fun fun(separator: Text): Text
---@return Table
function Table:format_separators(fun)
  error("not implemented")
  return self
end

---@private
function Table:column_width(idx)
  local max = utf8.len(self._headers[idx] or "")
  for _, row in ipairs(self._data) do
    max = math.max(max, utf8.len(tostring(row[idx]) or ""))
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
function Table:format_str()
  local padding = string.rep(" ", self._padding)
  local separator = " "
  if self._border_type ~= BorderType.None then
    separator = BORDERS[self._border_type].vertical
  end
  local widths = self:column_widths()
  local formats = {}
  for _, width in ipairs(widths) do
    formats[#formats + 1] = string.format("%%-%ds", width)
  end
  local col_separator = padding .. " " .. padding
  if self._column_separator then
    col_separator = padding .. separator .. padding
  end
  local fmt = table.concat(formats, col_separator)
  if self._border then
    fmt = separator .. padding .. fmt .. padding .. separator
  end
  return fmt
end

---@private
function Table:render_rows()
  local fmt = self:format_str()
  local rows = {}
  for _, row in ipairs(self._data) do
    rows[#rows + 1] = format(fmt, table.unpack(row))
  end
  return rows
end

---@private
function Table:render_header()
  local fmt = self:format_str()
  return format(fmt, table.unpack(self._headers))
end

---@private
function Table:render_separator(type)
  if self._border_type == BorderType.None then
    return nil
  end
  local borders = BORDERS[self._border_type]
  local separators = borders[type]
  local padding = string.rep(borders.horizontal, self._padding)
  local intersection = padding .. borders.horizontal .. padding
  if self._column_separator then
    intersection = padding .. separators.center .. padding
  end
  local widths = self:column_widths()
  local cols = {}
  for _, width in ipairs(widths) do
    cols[#cols + 1] = string.rep(borders.horizontal, width)
  end
  local fmt = table.concat(cols, intersection)
  if self._border then
    fmt = separators.left .. padding .. fmt .. padding .. separators.right
  end
  return fmt
end

---@private
function Table:render_bottom()
  return self:render_separator("bottom")
end

---@private
function Table:render_top()
  return self:render_separator("top")
end

---@private
function Table:render_row_separator()
  return self:render_separator("inner")
end

function Table:render()
  -- work with copy of data to avoid modifying original data
  local res = {}
  if self._border then
    res[#res + 1] = self:render_top()
  end
  res[#res + 1] = self:render_header()
  if self._header_separator then
    res[#res + 1] = self:render_row_separator()
  end
  local rows = self:render_rows()
  local row_sep = self:render_row_separator()
  for idx, row in ipairs(rows) do
    res[#res + 1] = row
    if self._row_separator and idx ~= #rows then
      res[#res + 1] = row_sep
    end
  end
  if self._border then
    res[#res + 1] = self:render_bottom()
  end
  return table.concat(res, "\n")
end

luatables.Table = Table

return luatables
