------------------
-- Zig Commands --
------------------

local handleOutput = function(data, regex, b, ns)
  -- check input
  if data then
    local msg = ''
    -- compose message from data
    for _, v in ipairs(data) do
      msg = msg .. v .. "\n"
    end
    local result = string.gmatch(msg, regex)
    local lines = {}
    for v in result do
      -- get just the line numbers
      table.insert(lines, string.match(v, '[0-9]+'))
    end
    if #lines > 0 then
      -- add marks to where tests failed
      for _, v in ipairs(lines) do
        -- make sure line exists in file
        local max = vim.api.nvim_buf_line_count(0)
        if tonumber(v) <= max then
          vim.api.nvim_buf_set_extmark(b, ns, tonumber(v) - 1, -1, {
            virt_text = { { ' ✗', 'ErrorMsg' } },
            -- overlay prevents conflict with diagnostic messages
            virt_text_pos = 'overlay',
          })
        end
      end
    end
    return msg
  end
end

function ZigTest()
  -- get current file (should be a test file)
  local file = vim.api.nvim_buf_get_name(0)
  print("Testing " .. file)
  -- compose command
  local command = "zig test " .. file
  local regex = file .. ':[0-9]+'
  -- get buffer information
  local b = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace('test')
  local function handleData(data)
    local msg = {}
    for _, v in ipairs(data) do
      table.insert(msg, v)
    end
    -- get the output as a string and set vir text
    local output = handleOutput(msg, regex, b, ns)
    -- if there is output message user
    if #output > 1 then
      vim.api.nvim_notify(output, vim.log.levels.DEBUG, {})
    end
  end
  -- table to store outputs
  vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
  -- wait for job to finish so msg can populate
  vim.fn.jobstart(vim.fn.split(command), {
    -- allows proper newlines
    stderr_buffered = true,
    stdout_buffered = true,
    cwd = vim.fn.getcwd(),
    -- handle err / out
    on_stderr = function(_, data)
      handleData(data)
    end,
    on_stdout = function(_, data)
      handleData(data)
    end,
  })
end

-- create user command
vim.api.nvim_create_user_command("ZigTest",
  function()
    ZigTest()
  end, {})
