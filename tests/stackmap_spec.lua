local fn = G.fn
local log = G.log

local find_keymap = function (storage, key)
  local rsl = nil
  for _, mapping in ipairs(storage) do
    if mapping.lhs == key then
      rsl = mapping
      break
    end
  end
  return rsl
end

describe('stackmap', function ()
  local mode = 'n'

  local keys = {
    '1-key',
    '2-key',
    '3-key',
    '4-key',
    '5-key',
  }

  local actions = {
    '1-action',
    '2-action',
    '3-action',
    '4-action',
    function ()
      print("5-action")
    end
  }

  fn.foreach(keys, function (key, index)
    vim.keymap.set(mode,key, actions[index])
  end)

  before_each(function ()
    require('stackmap').clear(mode)
    fn.foreach(keys, function (key)
      pcall(vim.keymap.del, mode, key)
    end)
    vim.keymap.set(mode, keys[#keys], actions[#actions])
  end)

  it('can require', function ()
    require 'stackmap'
  end)

  it('can push one', function ()
    local key = keys[1]
    local action = actions[1]
    require('stackmap').push(mode, { [key] = action })
    local storage = vim.api.nvim_get_keymap(mode)
    local expected = action
    local got = find_keymap(storage, key).rhs
    assert.are.same(expected, got)
  end)

  it('can push multiple', function ()
    local couples = fn.reduce(keys, function (couples, key, index)
      couples[key] = actions[index]
      return couples
    end, {})
    require('stackmap').push(mode, couples)
    local storage = vim.api.nvim_get_keymap(mode)
    fn.foreach(keys, function (key, index)
      local expected = actions[index]
      local got = find_keymap(storage, key)
      assert.are.same(expected, got.rhs or got.callback)
    end)
  end)

  it('can pop one', function ()
    local key = keys[1]
    local action = actions[1]
    local storage_start = vim.api.nvim_get_keymap(mode)
    require('stackmap').push(mode, { [key] = action })
    require('stackmap').pop(mode)
    local storage_final = vim.api.nvim_get_keymap(mode)
    local expected = find_keymap(storage_start, key)
    local got = find_keymap(storage_final, key)
    assert.are.same(expected, got)
  end)

  it('can pop multiple', function ()
    local couples = fn.reduce(keys, function (couples, key, index)
      couples[key] = actions[index]
      return couples
    end, {})
    local storage_start = vim.api.nvim_get_keymap(mode)
    require('stackmap').push(mode, couples)
    require('stackmap').pop(mode)
    local storage_final = vim.api.nvim_get_keymap(mode)
    fn.foreach(keys, function (key)
      local expected = find_keymap(storage_start, key)
      local got = find_keymap(storage_final, key)
      assert.are.same(expected, got)
    end)
  end)
end)

