--------------------------
-- Node & npm Functions --
--------------------------

-- load current file into node repl
function LoadNode(pos)
  -- get buffer name
  local buf = vim.api.nvim_buf_get_name(0)
  -- make and move to window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd " .. pos)
  -- start node
  local command = "node"
  vim.fn.termopen(command)
  -- paste into Node Repl
  vim.api.nvim_put(
    { -- command to send to Node
      ".load " .. buf .. "\r"
    },
    -- send as line
    "l",
    -- paste after cursor
    true,
    -- put ending cursor after paste
    true)
end

-- create user command
vim.api.nvim_create_user_command("LoadNode",
  function(opts)
    LoadNode(opts.args)
  end, { nargs = 1 })

-- run npm commands
function RunNpm()
  -- get root dir ie with package.json
  local root = vim.lsp.buf.list_workspace_folders()[1]
  -- build full command including dir change
  local go_root = "cd " .. root .. " && "
  local command = "npm " .. vim.fn.input("npm => ", "")
  -- create blank window
  vim.cmd ":wincmd n"
  vim.cmd ":wincmd J"
  -- run npm command
  vim.fn.termopen(go_root .. command)
end

-- create user command
vim.api.nvim_create_user_command("RunNpm",
  function()
    RunNpm()
  end, {})
