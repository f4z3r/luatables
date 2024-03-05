local table = require("table")

-- compatibility
if not table.unpack and unpack then
  table.unpack = unpack
end

local tables = require("luatables")

local function split(str, ch)
  local res = {}
  local start = 1
  local idx = string.find(str, ch, nil, true)
  while idx ~= nil do
    res[#res + 1] = string.sub(str, start, idx - 1)
    start = idx + 1
    idx = string.find(str, ch, start, true)
  end
  res[#res + 1] = string.sub(str, start)
  return res
end

local function trim_indent(str, offset, skip_empty)
  offset = offset or 0
  if skip_empty == nil then
    skip_empty = true
  end
  local start = string.find(str, "%S") - offset
  local lines = split(str, "\n")
  local res = {}
  for _, line in ipairs(lines) do
    local new = string.sub(line, start)
    if not (skip_empty and new == "") then
      res[#res + 1] = new
    end
  end
  return table.concat(res, "\n")
end

local function strip_ansi_escapes(str)
  local fmt = string.char(27) .. "%[[^m]+m"
  return string.gsub(str, fmt, "")
end

local function trim_trailing_ws(str)
  local clean = strip_ansi_escapes(str)
  local lines = split(clean, "\n")
  local res = {}
  for _, line in ipairs(lines) do
    res[#res + 1] = string.gsub(line, "%s+$", "")
  end
  return table.concat(res, "\n")
end

context("Tables:", function()
  local headers = { "Item", "Count", "Price", "Currency" }
  local data = {
    { "apple", 15, 7.5, "CHF" },
    { "orange", 3, 5, "CHF" },
    { "computer", 1, 1200, "USD" },
    { "total", 19 },
  }

  local tbl = tables.Table:new():headers(table.unpack(headers)):rows(table.unpack(data))

  describe("creating standard tables", function()
    it("should format standard text correctly", function()
      local out = tbl:render()
      local expected = trim_indent(
        [[
         Item     │ Count │ Price │ Currency
        ──────────┼───────┼───────┼──────────
         apple    │ 15    │ 7.5   │ CHF
         orange   │ 3     │ 5     │ CHF
         computer │ 1     │ 1200  │ USD
         total    │ 19    │       │
      ]],
        1
      )
      assert.are.equal(expected, trim_trailing_ws(out))
    end)
  end)
end)
