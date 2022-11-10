-- open lua repl with current file loaded
function LoadLua(pos)
  -- get buffer name
  local buf = vim.api.nvim_buf_get_name(0)
  -- make and move to window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd " .. pos)
  -- load file into terminal
  local command = "lua -i " .. buf
  vim.fn.termopen(command)
end

-- create user command
vim.api.nvim_create_user_command("LoadLua",
  function(opts)
    LoadLua(opts.args) -- positions
  end, { nargs = 1 })

vim.api.nvim_create_autocmd('FileType', {
  pattern = {'lua'},
  command = [[ 
  nnoremap <silent><buffer> <Space>rf :LoadLua J<CR>
  ]]
})
