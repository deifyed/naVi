# naVi

Your NeoVim assistant.

## Usage

`<keybinding>` in insert mode will open a prompt. Use this prompt to tell naVi what to do. For example, insert a React 
component outline.

Select text and press in visual mode `<keybinding>` to prompt naVi to make changes to the selected text. For example, 
remove a bug.

## Installation

### Requirements

- [Rust](https://www.rust-lang.org/tools/install)
- [NeoVim](https://neovim.io/)

### Packer

Add the following to your Packer config

```lua
    use({
        'deifyed/naVi',
        requires = {'jcdickinson/http.nvim', run = 'cargo build --workspace --release'},
    })
```

## Configuration

in `~/.config/nvim/after/plugin/naVi.lua`:

```lua
local navi = require('navi')

navi.setup({
    openai_token = "<token>", -- Or use the environment variable OPENAI_TOKEN
    openai_model = "gpt-3.5-turbo",
    openai_max_tokens = 512,
    openai_temperature = 0.6,
    debug = false, -- Print debug messages. View with :messages. Can also be set with the environment variable NAVI_DEBUG
})

-- Set keybindings
vim.api.nvim_set_keymap('v', '<C-PageDown>', '', { callback = navi.openRange })
vim.api.nvim_set_keymap('i', '<C-PageDown>', '', { callback = navi.open })
```

## FAQ

- Where can I get an OpenAI token?
    > https://platform.openai.com/
- Can naVi close nVim for me?
    > AI has come far, but not that far. We'll have to wait for human alignment before attempting this.
