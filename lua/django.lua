function ManagePy(pos)
  print("Run Manage.py Command t")
  -- try to find manage.py
  local exe = vim.fn.findfile("manage.py", ".;")
  -- if manage.py is in same dir
  if exe == "manage.py" then
    exe = "./" .. exe
  end
  -- init user set variables
  local dir
  local command
  -- vim can't find manage.py
  if exe == "" then
    -- get project root dir
    local lsp_dir = vim.lsp.buf.list_workspace_folders()[1]
    if lsp_dir == nil then
      lsp_dir = ""
    end
    -- let user modify dir
    dir = vim.fn.input("Directory=> ", lsp_dir, "file")
  else
    -- show manage.py path
    print("Manage.py=>  " .. exe)
  end
  -- get user command
  command = vim.fn.input("> ", "", "file")
  -- check for manage.py
  if exe == "" then
    exe = dir .. "/manage.py "
  end
  -- create command
  command = exe .. " " .. command
  -- create new window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd " .. pos)
  -- run command
  vim.fn.termopen(command)
end

-- create user command
vim.api.nvim_create_user_command("ManagePy",
  function(opts)
    ManagePy(opts.args)
  end, { nargs = 1 })

