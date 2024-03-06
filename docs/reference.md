# API Reference

<a name="top"></a>

<!--toc:start-->
- [API Reference](#api-reference)
  - [Example](#example)
  - [Table](#table)
    - [Table:new](#tablenew)
    - [Table:headers](#tableheaders)
    - [Table:row](#tablerow)
    - [Table:rows](#tablerows)
    - [Table:null](#tablenull)
    - [Table:border_style](#tableborder_style)
    - [Table:border](#tableborder)
    - [Table:row_separator](#tablerow_separator)
      - [Example](#example)
    - [Table:column_separator](#tablecolumn_separator)
    - [Table:header_separator](#tableheader_separator)
    - [Table:justify](#tablejustify)
    - [Table:padding](#tablepadding)
    - [Table:format_cells](#tableformat_cells)
    - [Table:format_rows](#tableformat_rows)
    - [Table:format_separators](#tableformat_separators)
    - [Table:render](#tablerender)
  - [RowType](#rowtype)
  - [FilterCallback](#filtercallback)
  - [JustifyCallback](#justifycallback)
  - [BorderType](#bordertype)
  - [BorderStyle](#borderstyle)
  - [Justify](#justify)
  - [Text](#text)
  - [Color](#color)
<!--toc:end-->

---

## Example

This repository provides a main type, the `Table`. Such tables can be populated with data and then
formatted and styled to your hearts desire.

For instance:

```lua
local string = require("string")
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

local function format_cells(i, _, cell)
  if string.find(cell:get_raw_text(), "n/a") then  -- if "n/a", change the text of the cell
                                                   -- string.find is required as the cell text
                                                   -- contains padding spacing
    return cell:dim()      -- uses LuaText formatting,
  end                      -- see https://github.com/f4z3r/luatext/blob/main/docs/reference.md

  if i == #data then       -- format the last row differently
    cell:bold():fg(58)     -- set text to bold and green
  end                      -- this could also be achieved via applying formatting on row level

  return cell              -- otherwise don't add additional formatting
end

local function format_rows(i, _, row)
  if i == 0 then          -- index 0 is the header row
    return row:fg(tables.Color.Red)  -- format header row with red text
  end
  return row              -- otherwise don't add additional formatting
end

local function format_seps(sep)
  return sep:fg(tables.Color.Cyan)   -- format separators (and borders) in cyan
end

local tbl = tables.Table
    :new()                      -- create new table
    :headers(unpack(headers))   -- set headers
    :rows(unpack(data))         -- _add_ data
    :null("n/a")                -- replace nil values
    :border()                   -- set full borders
    :border_style(tables.BorderStyle.Double)  -- set border style
    :header_separator()         -- create a separator between headers and data
    :format_rows(format_rows)   -- format rows
    :format_separators(format_seps)  -- format separators (precedence over rows)
    :format_cells(format_cells) -- format rows (precedence over rows)

print(tbl:render())             -- render and print the table
```

This generates the table as follows:

![Colored table](../assets/colored.gif)

[Back to the top](#top)

## Table

<!-- TODO: add note on the table -->

### Table:new

```lua
(method) Table:new()
  -> Table
```

Create a new empty `Table`.

[Back to the top](#top)

### Table:headers

```lua
(method) Table:headers(...any)
  -> Table
```

Add headers to the table. If called several times, the second call will overwrite the headers from
the first call.

Parameters:
- `...` — The header values. `tostring()` will be called on these values when rendered.

[Back to the top](#top)

### Table:row

```lua
(method) Table:row(...any)
  -> Table
```

Append a row to the end of the table. The number of values does not need to match other rows.
Missing values will be treated an `nil`. `nil` values between other values need to be explicitly
passed to the method.

Parameters:
- `...` — The values of the row. `tostring()` will be called on these values when rendered.

[Back to the top](#top)

### Table:rows

```lua
(method) Table:rows(...any[])
  -> Table
```

Append several rows to the end of the table. Rows are passed as tables. Behaves like `Table:row`
called several times for each row passed as arguments.

Parameters:
- `...` — The rows, each passed as a table.

[Back to the top](#top)

### Table:null

```lua
(method) Table:null(str: string)
  -> Table
```

Replace `nil` values when rendering the table by `str`.

Parameters:
- `str` — The value to replace `nil` cells in the `Table`.

[Back to the top](#top)

### Table:border_style

```lua
(method) Table:border_style(style: BorderStyle)
  -> Table
```

Apply a style to the table separators.

Parameters:
- `style` — The style to apply.

> See the [`BorderStyle`](#borderstyle) type.

[Back to the top](#top)

### Table:border

```lua
(method) Table:border(type?: BorderType)
  -> Table
```

Apply a border to the `Table`.

Parameters:
- `type` — The type of border. If none is provided, `BorderType.All` is applied.

> See the [`BorderType`](#bordertype) type.

[Back to the top](#top)

### Table:row_separator

```lua
(method) Table:row_separator(enabled?: FilterCallback|boolean)
  -> Table
```

Apply row separators between data rows.

Parameters:
- `enabled` — If a boolean is provided, applies the separators between all rows. If a
  `FilterCallback` is provided, a separator is applied **before** the row of the index provided to
  the callback. Thus returning `true` on index 1 has no effect. Applying a separator before the
  first row is done with the [`Table:header_separator()`](#tableheader_separator) method.

> See the [`FilterCallback`](#filtercallback) alias.

#### Example

The example below will only add a separator before the very last line in the table. This can for
instance be useful when the last row is a summarizing row such as showcasing totals.

```lua
local data = {...}
local function filter(idx)
    return idx == #data
end
tbl:row_separator(filter)
```

[Back to the top](#top)

### Table:column_separator

```lua
(method) Table:column_separator(enabled?: FilterCallback|boolean)
  -> Table
```

Apply column separators between columns.

Parameters:
- `enabled` — Behaves the same as in [`Table:row_separator()`](#tablerow_separator).

> See the [`FilterCallback`](#filtercallback) alias.

> Note that applying column separators only to the data part of the `Table`, and not having
> separators in the header (or vice versa), is currently not supported.

[Back to the top](#top)

### Table:header_separator

```lua
(method) Table:header_separator(enabled?: boolean)
  -> Table
```

Apply a separator between headers and data rows.

Parameters:
- `enabled` — Enable the header separator. If nothing is provided, `true` is assumed.

[Back to the top](#top)

### Table:justify

```lua
(method) Table:justify(justify: Justify[]|JustifyCallback)
  -> Table
```

Apply justification to columns.

Parameters:
- `justify` — If a table is provided, the corresponding entry will be applied to each column. In
  such a case the table **must** have the same length as the longest row in the `Table`. If a
  function is passed, this will be called with the index of each column to get the justification.

> See the [`JustifyCallback`](#justifycallback) alias.

> See the [`Justify`](#justify) type.

[Back to the top](#top)

### Table:padding

```lua
(method) Table:padding(padding: number)
  -> Table
```

Apply justification to columns.

Parameters:
- `padding` — The number of spaces to pad each cell. In other words, the number of spaces between
  the content of the cell and the separators.

[Back to the top](#top)

### Table:format_cells

```lua
(method) Table:format_cells(fun: fun(i: number, j: number, content: Text): Text)
  -> Table
```

Apply formatting to cells. This formatting takes precedence over all other formatting settings.

Parameters:
- `fun` — A function taking the row and column indexes of the cell, and its content as a
  [`luatext.Text`](https://github.com/f4z3r/luatext/blob/main/docs/reference.md#text). Formatting
  can directly be applied to `content`. Modifying the data contained within `content` (i.e. changing
  the actual text) will break rendering. `content` contains the entire cell contents, including
  potential padding. This function is also called for the header, in which case `i` is 0.

[Back to the top](#top)

### Table:format_rows

```lua
(method) Table:format_rows(fun: fun(idx: number, type: RowType, row: Text): Text)
  -> Table
```

Apply formatting to an entire row. Formatting cells and separators take precedence over the
formatting provided in this method.

Parameters:
- `fun` — A function taking the row index, the row type, and the actual row content as a
  [`luatext.Text`](https://github.com/f4z3r/luatext/blob/main/docs/reference.md#text). Formatting
  can directly be applied to `row`. Modifying the data contained within `row` (i.e. changing
  the actual text) will break rendering.

> For following tables, the function will be called with the index and type described next to it:
>
> ```
>                                            Index   Type
> ┌─────────────────────────────────────┐    -1      "separator"
> │ Item       Count   Price   Currency │    0       "data"
> ├─────────────────────────────────────┤    0       "separator"
> │ apple      15      7.5     CHF      │    1       "data"
> ├─────────────────────────────────────┤    1       "separator"
> │ orange     3       5       CHF      │    2       "data"
> ├─────────────────────────────────────┤    2       "separator"
> │ computer   1       1200    USD      │    3       "data"
> ├─────────────────────────────────────┤    3       "separator"
> │ total      19                       │    4       "data"
> └─────────────────────────────────────┘    4       "separator"
> ```

> See the [`Rowtype`](#rowtype) enum.

[Back to the top](#top)

### Table:format_separators

```lua
(method) Table:format_separators(fun: fun(separator: Text): Text)
  -> Table
```

Apply formatting to separators. This takes precedence over row formatting.

Parameters:
- `fun` — A function taking the separator or sequence of separators as a
  [`luatext.Text`](https://github.com/f4z3r/luatext/blob/main/docs/reference.md#text). Formatting
  can directly be applied to `separator`. Modifying the data contained within `separator` (i.e.
  changing the actual text) will break rendering.

[Back to the top](#top)

### Table:render

```lua
(method) Table:render()
  -> string
```

Render the table as a string.

[Back to the top](#top)

## RowType

An raw enumeration, can be either `"data"` or `"separator"`. Represents the type of row being
rendered. Data rows are rows that contain standard cells. Separator rows are rows containing
exclusively separator symbols. These rows are only rendered when using `row_separator()`.

[Back to the top](#top)

## FilterCallback

A type alias for:

```lua
fun(idx: number): boolean
```

[Back to the top](#top)

## JustifyCallback

A type alias for:

```lua
fun(idx: number): Justify
```

> See the [`Justify`](#justify) type.

[Back to the top](#top)

## BorderType

```lua
table
```

An enum for the border type of the table. Can be any of:

- `None`: do not add borders around the table (default when creating tables).
- `TopBottom`: only apply borders above and below the table.
- `Sides`: only apply borders on the sides (left and right) of the table.
- `All`: apply borders everywhere (identical to `BorderType.TopBottom + BorderType.Sides`).

[Back to the top](#top)

## BorderStyle

```lua
table
```

An enum for the border style. Can be any of:

- `Single` (default when creating tables)
- `Double`
- `Fat`

[Back to the top](#top)

## Justify

```lua
table
```

An enum expressing text justification. Can be:

- `Left` (default for all columns when creating tables).
- `Right`

> `Center` is currently not supported but on the roadmap.

[Back to the top](#top)

## Text

This is a re-export of [`luatext.Text`](https://github.com/f4z3r/luatext/blob/main/docs/reference.md#text).

[Back to the top](#top)

## Color

This is a re-export of [`luatext.Color`](https://github.com/f4z3r/luatext/blob/main/docs/reference.md#color).

[Back to the top](#top)
