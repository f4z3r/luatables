local table = require("table")
local text = require("luatext")

local luatables = {}

if not table.unpack and unpack then
  table.unpack = unpack
end
---@class Table
local Table = {}

---create a new table
---@return Table
function Table:new()
  local o = {}
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
  self._data = self._data or {}
  self._data[#self._data + 1] = { ... }
  return self
end

---add a set of rows to the table
---@vararg any[]
---@return Table
function Table:rows(...)
  self._data = self._data or {}
  for _, row in ipairs({ ... }) do
    self:row(table.unpack(row))
  end
  return self
end

---@private
function Table:replace_nil()
  local row_length = self:row_length()
  for idx = 1, row_length do
    self._headers[idx] = self._headers[idx] or ""
    for _, row in ipairs(self._data) do
      row[idx] = row[idx] or ""
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
  return table.concat(formats, " ║ ")
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

function Table:render()
  local res = {}
  local format_str = self:format_str()
  self:replace_nil()
  res[#res + 1] = text
    :new(string.format(format_str, table.unpack(self._headers)))
    :bg(text.Color.White)
    :fg(text.Color.Black)
    :bold()
    :render()
  for _, row in ipairs(self._data) do
    res[#res + 1] = string.format(format_str, table.unpack(row))
  end
  return table.concat(res, "\n")
end

luatables.Table = Table

return luatables
