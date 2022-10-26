# Purpose 

- to get some of the functions/ functionality I missed from emacs into neovim and learn some lua 
- main goal is better terminal interop
- there are several 'supported' frameworks or languages with extended funcitonality
  - the main goal with these is to make commands that would otherwise be executed in the terminal easier
  - they aren't full featured enough to stand on their own legs (yet) so I've kept them as part of **termbro**

# General Terminal Functions 

- CompileCurrent 

- CheatSheet

- OpenTerm

# Lang / Framework Functions

- **Node & Npm**
  - interactively run `npm` commands from project root 
	- lsp server required (for finding root dir)
- **Ruby & Ruby on Rails**
  - run the server
  - open a console 
  - basic function for sending any command you might want
  - testing a file 
	- current buffer must be the file to be tested
- **Django**
  - interactively run `manage.py` commands

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
