vim.keymap.set('n', '<F10>', function ()
  G.log("Current time: " .. os.time())
end)

vim.keymap.set('n', '<F8>', function ()
  G.log("Hello: " .. os.time())
end)
