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

return helpers
