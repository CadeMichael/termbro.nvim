# Purpose 

- to get some of the functions/ functionality I missed from emacs into neovim and learn some lua 
- main goal is better terminal interop

# General Terminal Functions 

- CompileCurrent 

- CheatSheet

- OpenTerm

# Lang / Framework Functions

- LoadNode( position )

- ManagePy( position )

- LoadIRB ( position )

- RailsCommand ( Position, Project_rails, Command)

# Suggested keybindings

## General keybindings
- use these for all filetypes 

```lua
-- JS load
vim.api.nvim_create_autocmd(
  "FileType",
  {
    pattern = {
      "javascript",
    },
    command = [[
    nnoremap <silent><buffer> <Space>Lb :LoadNode J<CR>
    nnoremap <silent><buffer> <Space>Ls :LoadNode L<CR>
    ]],
  }
)

-- ruby load
vim.api.nvim_create_autocmd(
  "FileType",
  {
    pattern = {
      "ruby",
    },
    command = [[
    nnoremap <silent><buffer> <Space>Lb :LoadIRB J<CR>
    nnoremap <silent><buffer> <Space>Ls :LoadIRB L<CR>
    nnoremap <silent><buffer> <Space>rc :RailsCommand J true console --sandbox<CR>
    nnoremap <silent><buffer> <Space>rr :RailsCommand J true server<CR>
    ]],
  }
)

-- Python Django
vim.api.nvim_create_autocmd(
  "FileType",
  {
    pattern = {
      "python",
    },
    command = [[
    nnoremap <silent><buffer> <Space>Lb :ManagePy J<CR>
    nnoremap <silent><buffer> <Space>Ls :ManagePy L<CR>
    set listchars=eol:↵,multispace:---+
    ]],
  }
)
```

## Lang specific
- add these to a Filetype autocommand

```lua
-- Cht.sh
local keymap = vim.keymap.set

keymap('n', '<Space>cs', "<cmd> CheatSheet<CR>", { noremap = true, silent = true })
-- Compile
keymap('n', '<Space>cc', "<cmd> CompileCurrent<CR>", { noremap = true, silent = true })
-- terminal
keymap({ 'n', 'i' }, '<C-c><C-z>', '<cmd> OpenTerm<CR>', { noremap = true, silent = true })
keymap('t', '<C-c><C-z>', '<C-\\><C-N> <cmd> OpenTerm<CR>]', { noremap = true, silent = true })
```
