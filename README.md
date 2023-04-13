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

### Configure keybindings

in `~/.config/nvim/after/plugin/naVi.lua`:

```
local navi = require('navi')

vim.api.nvim_set_keymap('v', '<C-PageDown>', '', { callback = navi.openRange })
vim.api.nvim_set_keymap('i', '<C-PageDown>', '', { callback = navi.open })
```

### Configure OpenAI token

```bash
export OPENAI_TOKEN=<token>
```

### Print debug messages

```bash
export NAVI_DEBUG=true
```

and be read with `:messages`.

## FAQ

- Where can I get an OpenAI token?
    > https://platform.openai.com/
- Can naVi close nVim for me?
    > AI has come far, but not that far. We'll have to wait for human alignment before attempting this.
