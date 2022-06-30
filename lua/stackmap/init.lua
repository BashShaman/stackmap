local log = G.log
local fn = G.fn

local M = {
  _stack = {}
}

M.setup = function ()
end

M.clear = function(mode)
  M._stack[mode] = nil
end

local find = function (storage, key)
  local rsl = nil
  for _, keymap in ipairs(storage) do
    if key == keymap.lhs then
      rsl = keymap
      break
    end
  end
  return rsl
end

M.push = function (mode, couples)
  local keys = {}
  local keymaps = {}
  local storage = vim.api.nvim_get_keymap(mode)
  for key, action in pairs(couples) do
    local keymap = find(storage, key)
    if keymap then
      keymaps[key] = keymap
    else
      table.insert(keys, key)
    end
    vim.keymap.set(mode,key, action)
  end
  M._stack = {
    [mode] = {
      keys = keys,
      keymaps = keymaps
    }
  }
end

M.pop = function (mode)
  local cache = M._stack[mode]
  fn.foreach(cache.keys, function (key)
    vim.keymap.del(mode, key)
  end)
  for key, keymap in pairs(cache.keymaps) do
    -- TODO: handle options for the mapping
    local rhs = keymap.rhs or keymap.callback
    vim.keymap.set(mode, key, rhs)
  end
  M.clear(mode)
end

return M
