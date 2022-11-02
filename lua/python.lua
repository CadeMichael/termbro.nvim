-- open python repl with current file loaded
function LoadPy(pos)
  -- get buffer name
  local buf = vim.api.nvim_buf_get_name(0)
  -- make and move to window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd " .. pos)
  -- load file into terminal
  local command = "python -i " .. buf
  vim.fn.termopen(command)
end

-- create user command
vim.api.nvim_create_user_command("LoadPy",
  function(opts)
    LoadPy(opts.args) -- positions
  end, { nargs = 1 })
