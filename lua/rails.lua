----------------------------
-- Ruby & Rails Functions --
----------------------------

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
  local command = "irb -r " .. buf
  vim.fn.termopen(command)
end

-- create user command
vim.api.nvim_create_user_command("LoadIRB",
  function(opts)
    LoadIRB(opts.args) -- positions
  end, { nargs = 1 })

-- getting project root (without lsp)
local function getRoot()
  -- look for Gemfile as it is in root dir
  local gemfile = vim.fn.findfile('Gemfile', ';.')
  -- create a table of dirs leading to 'Gemfile'
  local file_tab = vim.fn.split(gemfile, '/')
  -- pop off 'Gemfile'
  table.remove(file_tab, #file_tab)
  -- compose table into dir path
  local root = table.concat(file_tab, '/')
  -- return root
  return root
end

-- get project specific rails
local function runProjRails ()
  -- set local vars
  local root = getRoot()
  local rails
  -- if root dir is > 2 current dir != root dir
  if #root > 2 then
    -- build path to rails exe
    root = '/' .. root
    rails = root .. '/bin/rails'
  else
    -- build path to rails exe
    rails = 'bin/rails'
  end
  -- return local vars
  return { rails, root }
end

function RailsTestFile()
  -- get variables from helper func
  local vars = runProjRails()
  local rails = vars[1]
  local root = vars[2]
  -- messages to user
  print("Run a Test File...\n")
  print("Project root => " .. root .. "\n")
  -- get current file (should be a test file)
  local cur_file = vim.api.nvim_buf_get_name(0)
  -- helper function to iterate through dirs of the cur file 
  -- and check if there is a 'test/' dir in its path
  local function splitFile(file, dir)
    -- split input file
    local file_tab = vim.fn.split(file, '/')
    -- keep track of deleted dirs to prevent delete nil loop
    local cnt = #file_tab
    -- loop through dirs removing until you hit 'test'
    while (file_tab[1] ~= dir and cnt ~= 0) do
      cnt = cnt - 1
      table.remove(file_tab, 1)
    end
    -- if file_tab is <= 1 then it isn't in 'test' dir
    if #file_tab <= 1 then
      -- bad file value
      return nil
    end
    -- current file is in 'test/' compose and return
    return table.concat(file_tab, "/")
  end
  -- get relative (to root dir) path of test file
  local test_file = splitFile(cur_file, "test")
  -- see if file is in 'test/' dir
  if test_file == nil then
    print('not a test file !')
    -- break out of function
    return
  end
  -- compose command
  local command = rails .. " test " .. test_file
  -- create new window
  vim.cmd(":wincmd n")
  vim.cmd(":wincmd J")
  -- rails exe is not in cur dir
  if #rails ~= 9 then
    -- set dir before command
    command = 'cd ' .. root .. ' && ' .. command
    print(test_file)
    vim.fn.termopen('cd ' .. root .. ' && ' .. command)
  -- rails exe is in current dir
  else
    print(test_file)
    vim.fn.termopen(command)
  end
end

-- create user command
vim.api.nvim_create_user_command("RailsTestFile",
  function()
    RailsTestFile()
  end, {})
