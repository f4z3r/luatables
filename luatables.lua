local table = require("table")
local text = require("luatext")
local utf8 = require("lua-utf8")

-- compatibility
if not table.unpack and unpack then
  table.unpack = unpack
end

---@class Text
---@see https://github.com/f4z3r/luatext/blob/v1.1.0/docs/reference.md#text
local Text = text.Text

local luatables = {}

-- re-exports
---@enum Color
---@see https://github.com/f4z3r/luatext/blob/v1.1.0/docs/reference.md#color
luatables.Color = text.Color
---@class Text
---@see https://github.com/f4z3r/luatext/blob/v1.1.0/docs/reference.md#text
luatables.Text = text.Text

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

---@enum BorderStyle
local BorderStyle = {
  Single = "single",
  Double = "double",
  Fat = "fat",
}

luatables.BorderStyle = BorderStyle

---@enum BorderType
local BorderType = {
  None = 0,
  TopBottom = 1,
  Sides = 2,
  All = 3,
}

luatables.BorderType = BorderType

---@enum Justify
local Justify = {
  Left = "-",
  Right = "",
}

luatables.Justify = Justify

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

local function always_true()
  return true
end

local function always_false()
  return false
end

local function left_justify()
  return Justify.Left
end

local function no_format_row(_, _, row)
  return row
end

local function no_format_cell(_, _, cell)
  return cell
end

local function no_format_seps(sep)
  return sep
end

---replace nil values in an array with a replacement
---@param data any[]
---@param repl any
---@return any[]
local function replace_nil(data, repl, fill)
  local res = {}
  for idx = 1, fill do
    local val = data[idx]
    if val == nil then
      res[#res + 1] = repl
    else
      res[#res + 1] = val
    end
  end
  return res
end

---@alias FilterCallback fun(idx: number): boolean
---@alias JustifyCallback fun(idx: number): Justify
---@alias RowType "data" | "separator"

---@class Table
---@field private _headers table?
---@field private _data table[]
---@field private _nil string
---@field private _border_style BorderStyle
---@field private _border_type BorderType
---@field private _row_separator FilterCallback
---@field private _column_separator FilterCallback
---@field private _header_separator boolean
---@field private _padding number
---@field private _justify Justify[]|JustifyCallback
---@field private _format_rows fun(idx: number, type: RowType, row: Text): Text
---@field private _format_cells fun(i: number, j: number, content: Text): Text
---@field private _format_seps fun(separator: Text): Text
local Table = {}

---create a new table
---@return Table
function Table:new()
  local o = {
    _data = {},
    _headers = nil,
    _nil = "",
    _border_style = BorderStyle.Single,
    _border_type = BorderType.None,
    _row_separator = always_false,
    _column_separator = always_true,
    _header_separator = true,
    _padding = 1,
    _justify = left_justify,
    _format_rows = no_format_row,
    _format_cells = no_format_cell,
    _format_seps = no_format_seps,
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
---@param style BorderStyle
---@return Table
function Table:border_style(style)
  self._border_style = style
  return self
end

---enable borders
---@param type BorderType?
---@return Table
function Table:border(type)
  if type == nil then
    type = BorderType.All
  end
  self._border_type = type
  return self
end

---enable row separators
---@param enabled FilterCallback|boolean?
---@return Table
function Table:row_separator(enabled)
  if enabled == nil or (type(enabled) == "boolean" and enabled) then
    enabled = always_true
  elseif not enabled then
    enabled = always_false
  end
  ---@cast enabled FilterCallback
  self._row_separator = enabled
  return self
end

---enable column separators
---@param enabled FilterCallback|boolean?
---@return Table
function Table:column_separator(enabled)
  if enabled == nil or (type(enabled) == "boolean" and enabled) then
    enabled = always_true
  elseif not enabled then
    enabled = always_false
  end
  ---@cast enabled FilterCallback
  self._column_separator = enabled
  return self
end

---justify columns
---@param justify Justify[]|JustifyCallback
---@return Table
function Table:justify(justify)
  if type(justify) ~= "function" then
    local copy = justify
    justify = function(idx)
      return copy[idx]
    end
  end
  self._justify = justify
  return self
end

---update padding
---@param padding number
---@return Table
function Table:padding(padding)
  self._padding = padding
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
  self._format_cells = fun
  return self
end

---format the data rows
---@param fun fun(idx: number, type: RowType, row: Text): Text
---@return Table
function Table:format_rows(fun)
  self._format_rows = fun
  return self
end

---format the data rows
---@param fun fun(separator: Text): Text
---@return Table
function Table:format_separators(fun)
  self._format_seps = fun
  return self
end

---@private
function Table:column_width(idx)
  local max = 0
  if self._headers then
    max = utf8.len(self._headers[idx] or "")
  end
  for _, row in ipairs(self._data) do
    local data = row[idx]
    if data == nil then
      data = self._nil
    end
    max = math.max(max, utf8.len(tostring(data) or ""))
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
function Table:side_borders()
  return self._border_type == BorderType.All or self._border_type == BorderType.Sides
end

---@private
function Table:top_borders()
  return self._border_type == BorderType.All or self._border_type == BorderType.TopBottom
end

---@private
function Table:row_length()
  local max = table.maxn(self._headers or {})
  for _, row in ipairs(self._data) do
    max = math.max(max, table.maxn(row))
  end
  return max
end

---@private
function Table:render_row(idx, data)
  local width = self:row_length()
  local widths = self:column_widths()
  local padding = string.rep(" ", self._padding)
  local res = {}
  -- replace nils
  data = replace_nil(data, self._nil, width)
  -- if outside border
  if self:side_borders() then
    res[#res + 1] = self._format_seps(Text:new(BORDERS[self._border_style].vertical))
  end
  -- data
  for j = 1, width do
    -- apply separator
    if j ~= 1 then
      local separator = " "
      if self._column_separator(j) and self._border_style ~= BorderStyle.None then
        separator = BORDERS[self._border_style].vertical
      end
      res[#res + 1] = self._format_seps(Text:new(separator))
    end
    -- apply padding
    local fmt = string.format("%%s%%%s%ds%%s", self._justify(j), widths[j])
    local val = Text:new(format(fmt, padding, tostring(data[j]), padding))
    -- apply formatting for cell
    res[#res + 1] = self._format_cells(idx, j, val)
  end
  -- if outside border
  if self:side_borders() then
    res[#res + 1] = self._format_seps(Text:new(BORDERS[self._border_style].vertical))
  end
  -- apply row formatting
  local str = Text:new():append(table.unpack(res))
  str = self._format_rows(idx, "data", str)
  return str:render()
end

---@private
function Table:render_separator(idx, type)
  if self._border_style == BorderStyle.None then
    return nil
  end
  local borders = BORDERS[self._border_style]
  local separators = borders[type]
  local padding = string.rep(borders.horizontal, self._padding)
  local widths = self:column_widths()
  local res = ""
  for i, width in ipairs(widths) do
    if i ~= 1 then
      local separator = borders.horizontal
      if self._column_separator(i) then
        separator = separators.center
      end
      res = res .. separator .. padding
    end
    res = res .. string.rep(borders.horizontal, width) .. padding
  end
  if self:side_borders() then
    res = separators.left .. padding .. res .. separators.right
  else
    res = padding .. res
  end
  return self._format_seps(self._format_rows(idx, "separator", Text:new(res))):render()
end

---@private
function Table:render_bottom(idx)
  return self:render_separator(idx, "bottom")
end

---@private
function Table:render_top()
  return self:render_separator(-1, "top")
end

---@private
function Table:render_row_separator(idx)
  return self:render_separator(idx, "inner")
end

---render the Table
---@return string
function Table:render()
  -- work with copy of data to avoid modifying original data
  local res = {}
  if self:top_borders() then
    res[#res + 1] = self:render_top()
  end
  if self._headers then
    res[#res + 1] = self:render_row(0, self._headers)
    if self._header_separator then
      res[#res + 1] = self:render_row_separator(0)
    end
  end
  for idx, row in ipairs(self._data) do
    if self._row_separator(idx) and idx ~= 1 then
      res[#res + 1] = self:render_row_separator(idx)
    end
    res[#res + 1] = self:render_row(idx, row)
  end
  if self:top_borders() then
    res[#res + 1] = self:render_bottom(#self._data + 1)
  end
  return table.concat(res, "\n")
end

luatables.Table = Table

return luatables
