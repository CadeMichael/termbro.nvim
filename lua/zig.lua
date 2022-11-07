------------------
-- Zig Commands --
------------------

local handleOutput = function(data, regex, b, ns)
  if data then
    local msg = ''
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
      for i, v in ipairs(lines) do
        local max = vim.api.nvim_buf_line_count(0)
        -- odd numbers represent zig stdlib files
        if tonumber(v) <= max and i % 2 == 0 then
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
  local regex = '.zig:[0-9]+'
  local b = vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace('test')
  vim.api.nvim_buf_clear_namespace(b, ns, 0, -1)
  vim.fn.jobstart(vim.fn.split(command), {
    cwd = vim.fn.getcwd(),
    on_stderr = function(_, data)
      local msg = handleOutput(data, regex, b, ns)
      if #msg > 1 then
        vim.api.nvim_notify(msg, vim.log.levels.INFO, {})
      end
    end,
    on_stdout = function(_, data)
      local msg = handleOutput(data, regex, b, ns)
      if #msg > 1 then
        vim.api.nvim_notify(msg, vim.log.levels.INFO, {})
      end
    end,
  })
end

-- create user command
vim.api.nvim_create_user_command("RailsTestFile",
  function()
    ZigTest()
  end, {})
