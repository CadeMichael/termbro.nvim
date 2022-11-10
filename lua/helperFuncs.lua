----------------------
-- Helper functions --
----------------------

local helpers = {}

-- helper function to iterate through dirs of the cur file
-- and check if there is a 'test/' dir in its path
helpers.splitFile = function(file, dir)
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

-- Helper function to mark where tests break
helpers.markFailed = function(command, success, regex)
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
      cwd = vim.fn.getcwd(),
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

return helpers
