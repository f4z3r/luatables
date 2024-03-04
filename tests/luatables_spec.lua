local utf8 = require("lua-utf8")

local tables

context("Utilities:", function()
  setup(function()
    _G._TEST = true
    tables = require("luatables")
  end)

  teardown(function()
    _G._TEST = nil
  end)

  describe("when calling format, it", function()
    it("should format standard text correctly", function()
      local text = tables.format("-%s-", "text")
      assert.are.equal("-text-", text)
    end)

    it("should format utf8 strings correctly", function()
      local text = tables.format("#%-2s#", "é")
      assert.are.equal(4, utf8.len(text))
      assert.are.equal(5, text:len())
    end)
  end)
end)
