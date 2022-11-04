------------------------
-- Terminal Functions --
------------------------

-- Guess the intended command
local last_command = '' -- set to blank on first load

-- create a table of ftypes
local ft_commands = {}
ft_commands["go"] = "go build "
ft_commands["javascript"] = "npm "
ft_commands["lua"] = "lua "
ft_commands["python"] = "python "
ft_commands["rust"] = "cargo build "
ft_commands["zig"] = "zig build-exe "

local guess_command = function()
  -- check for LastCommand
  if last_command ~= '' then
    return last_command
  end
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
  -- allow user to change command
  local command = vim.fn.input("> ", cmd, "file")
  -- make sure the command was entered
  if command then
    -- set LastCommand
    last_command = command
    -- create blank buf
    vim.cmd("wincmd n")
    vim.cmd("wincmd J")
    -- cd to dir and run command
    vim.fn.termopen("cd " .. dir .. " && " .. command)
  end
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
  -- exit on no question
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
