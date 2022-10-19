------------------------
-- Terminal Functions --
------------------------

-- Guess the intended command
local guess_command = function()
  local ft_commands = {}
  -- create a table of ftypes
  ft_commands["go"] = "go build "
  ft_commands["javascript"] = "npm "
  ft_commands["lua"] = "lua "
  ft_commands["python"] = "python "
  ft_commands["rust"] = "cargo build "
  ft_commands["zig"] = "zig build-exe "
  -- get filetype
  local ft = vim.bo.filetype
  local command = ""
  if ft_commands[ft] ~= nil then
    -- use guess
    command = ft_commands[ft]
  end

  return command
end

-- get dir to run cmd
local get_dir = function()
  -- get current dir
  local cur_dir = vim.fn.getcwd()
  -- see if there is a lsp root dir
  local lsp_dir = vim.lsp.buf.list_workspace_folders()[1]
  if lsp_dir ~= nil then
    cur_dir = lsp_dir
  end
  -- allow user to modify working dir
  local dir = vim.fn.input(
    "Directory=> ",
    cur_dir,
    "file")
  return dir
end

-- parody of emacs compile command
function Compile()
  print("Compile Current Project...\n")
  -- get dir and cmd
  local dir = get_dir()
  local cmd = guess_command()
  -- create blank buf
  vim.cmd("wincmd n")
  vim.cmd("wincmd J")
  -- allow user to change command
  local command = vim.fn.input("> ", cmd, "file")
  -- cd to dir and run command
  vim.fn.termopen("cd " .. dir .. " && " .. command)
end

-- make Compile() a user function
vim.api.nvim_create_user_command("CompileCurrent",
  function()
    Compile()
  end, {})

-- determine if there is a terminal buf
function IsTerm()
  -- get all buffers
  local bufs = vim.api.nvim_list_bufs()
  -- tables for term buffs on or off screen
  local onScreen = {}
  local offScreen = {}
  -- iterate through bufs
  for _, b in ipairs(bufs) do
    -- get name
    local bName = vim.api.nvim_buf_get_name(b)
    -- check for term
    if string.find(bName, "term://") ~= nil then
      -- get window id (non null if on screen)
      local id = vim.fn.win_findbuf(b)[1]
      -- term on screen
      if id then
        table.insert(onScreen, b)
        -- term off screen
      else
        table.insert(offScreen, b)
      end
    end
  end
  -- there is an active term
  if onScreen[1] or offScreen[1] then
    -- prioritize on screen
    if onScreen[1] then
      -- get buffer
      local b = onScreen[1]
      -- get term window id
      local id = vim.fn.win_findbuf(b)[1]
      -- set cursor to term window
      vim.api.nvim_set_current_win(id)
    else
      -- get buffer
      local b = offScreen[1]
      -- prevent new blank buff
      vim.cmd(":wincmd v")
      -- move to bottom
      vim.cmd(":wincmd J")
      -- set to terminal
      vim.api.nvim_set_current_buf(b)
    end
    -- terminal found
    return true
  end
  -- no term buffers
  return false
end

-- open or move to terminal window
function OpenTerm()
  -- get current buffer & name
  local buf = vim.api.nvim_get_current_buf();
  local bufName = vim.api.nvim_buf_get_name(buf);
  -- check if you're in a term
  local type = vim.fn.split(bufName, ":")[1]
  if type == "term" then
    -- switch windows
    vim.cmd [[:wincmd w]]
    return
    -- find a term or make one and switch
  elseif IsTerm() ~= true then
    vim.cmd("bel split")
    vim.cmd("terminal")
  end
end

-- create user command
vim.api.nvim_create_user_command("OpenTerm",
  function()
    OpenTerm()
  end, {})

-- ask a programming question
function CheatSheet()
  print("Ask Your Question...")
  -- get user question
  local question = vim.fn.input("?> ", "")
  if question == "" then return end
  -- split on \s
  local question_table = vim.fn.split(question)
  -- turn table into url
  local url = ""
  for _, v in ipairs(question_table) do
    url = url .. "/" .. v
  end
  -- create blank window
  vim.cmd ":wincmd n"
  vim.cmd ":wincmd J"
  -- ask the internet
  vim.fn.termopen("curl cht.sh/" .. url)
end

-- create user command
vim.api.nvim_create_user_command("CheatSheet",
  function()
    CheatSheet()
  end, {})

------------------------

----------
-- Node --
----------
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

------------
-- DJango --
------------
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

----------
-- Ruby --
----------
-- create user command
vim.api.nvim_create_user_command("LoadIRB",
  function(opts)
    LoadIRB(opts.args) -- positions
  end, { nargs = 1 })

-- open rails console in sandbox
function RailsCommand(pos, proj_rails, cmd)
  -- init variables
  local dir
  local command
  -- get project root dir
  local lsp_dir = vim.lsp.buf.list_workspace_folders()[1]
  -- if user wants proj specific rails
  if proj_rails then
    -- allow user to modify root dir
    dir = vim.fn.input("Directory=> ", lsp_dir, "file")
    command = dir .. "/bin/rails "
  else
    command = "rails "
  end
  -- create new window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd " .. pos)
  -- run command
  vim.fn.termopen(command .. cmd)
end

-- create user command
vim.api.nvim_create_user_command("RailsCommand",
  function(opts)
    RailsCommand(opts.fargs[1], -- position
      opts.fargs[2], -- proj rails
      opts.fargs[3]) -- rails command
  end, { nargs = '+' })

-- open ruby repl with current file loaded
function LoadIRB(pos)
  -- get buffer name
  local buf = vim.api.nvim_buf_get_name(0)
  -- make and move to window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd " .. pos)
  -- load file into terminal
  local command = "irb -r" .. buf
  vim.fn.termopen(command)
end
