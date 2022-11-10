----------------------------
-- Ruby & Rails Functions --
----------------------------

-- get helper functions
local help = require('helperFuncs')

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
function getRoot()
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
local function runProjRails()
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
    root = vim.fn.getcwd()
    rails = 'bin/rails'
  end
  -- return local vars
  return { rails, root }
end

-- Helper function to mark where tests break
local function markFailed(command, root, success, regex)
  -- get buffer & namespace
  local b = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace('test')
  -- clear any existing marks
  vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
  -- run command with blocking, synchronous lua io
  local result
  local lines = {}
  local output = ''
  -- create default message
  local message = '\n==All Tests Passed=='
  -- check for null handle
  vim.fn.jobwait({
    vim.fn.jobstart(command, {
      stderr_buffered = true,
      stdout_buffered = true,
      cwd = root,
      on_stderr = function(_, data)
        for _, v in ipairs(data) do
          output = output .. v .. "\n"
        end
      end,
      on_stdout = function(_, data)
        for _, v in ipairs(data) do
          output = output .. v .. "\n"
        end
      end,
    })
  })
  -- check proper test command ran
  local ran = string.match(output, success)
  -- make sure command runs
  if ran ~= nil and #ran ~= 0 then
    -- match for line numbers and populate table
    result = string.gmatch(output, regex)
    for v in result do
      -- get just the line numbers
      table.insert(lines, string.match(v, '[0-9]+'))
    end
  else
    message = "\n==Test Command Failed=="
  end
  -- if there are line numbers they represent failed tests
  if #lines > 0 then
    -- show user info on why tests failed
    vim.api.nvim_notify(output, vim.log.levels.INFO, {})
    -- add marks to where tests failed
    for _, v in ipairs(lines) do
      vim.api.nvim_buf_set_extmark(b, ns, tonumber(v) - 1, -1, {
        virt_text = { { ' ✗', 'ErrorMsg' } },
        -- overlay prevents conflict with diagnostic messages
        virt_text_pos = 'overlay',
      })
    end
  else
    -- tests either passed or command failed
    vim.api.nvim_notify(message, vim.log.levels.WARN, {})
  end
end

-- Test the current rails file
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
  -- get relative (to root dir) path of test file
  local test_file = help.splitFile(cur_file, "test")
  -- see if file is in 'test/' dir
  if test_file == nil then
    print('not a test file !')
    -- break out of function
    return
  end
  -- compose command
  local command = rails .. " test -v " .. test_file
  local regex = '.rb:[0-9]+'
  local success = 'Running'
  -- check rails being used
  if #rails ~= 9 then
    -- set dir before command
    command = 'cd ' .. root .. ' && ' .. command
    print('File: ' .. test_file)
    markFailed(command, root, success, regex)
    -- rails exe is in current dir
  else
    print(test_file)
    markFailed(command, root, success, regex)
  end
end

-- create user command
vim.api.nvim_create_user_command("RailsTestFile",
  function()
    RailsTestFile()
  end, {})
