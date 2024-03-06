# luatables

Library to render tables nicely to the terminal.

## Examples

### Simple Tables

A simple table can be generated from data:

```lua
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

local tbl = tables.Table
    :new()
    :headers(unpack(headers)) -- or table.unpack on newer Lua versions
    :rows(unpack(data))

print(tbl:render())
```

This produces a simple table, without any additional formatting:

![Simple table](assets/simple.gif)

## API

The entire API is documented in [the reference document](/docs/reference.md).

## Installation

## Development

## Roadmap

- [ ] docs
- [ ] cleanup on render functions
- [ ] validate compatibility with Lua 5.3+
- [ ] independent justification for headers
- [ ] centered justification
- [ ] text width limitation columns
- [ ] text wrapping into multiline cells
