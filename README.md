# naVi - Your NeoVim assistant

<p align="center">
    <b>Natural language first based development</b>
    <br /><br />
    <img src="./assets/logo.png" />
</p>

## Usage

`navi.Append()` will open a prompt. Use this prompt to tell naVi what to do. For example, insert a React component outline.

`navi.Edit()` will open a prompt using the current selection as context. Use this prompt to get naVi to make
changes to the selected text. For example, remove a bug.

`navi.EditBuffer()` will open a prompt using the current file as context. Use this prompt to get naVi to make
changes to the current file. For example, add a new function.

`navi.Review()` will request a review using the current selection as context. The final report will open in a separate window,
and will not alter the selected text.

`navi.Explain()` will provide an explanation of code using the current selection as context. The explanation will
open in a separate window and will not alter the selected text.

`navi.Chat()` will open a chat interface where you can discuss your code with GPT.

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
### Lazy

Add the following to your Lazy.vim config

    {
      'deifyed/naVi',
      dependencies = { 
        {
          "jcdickinson/http.nvim", build = "cargo build --workspace --release",
        },
      },
      config = function()
        require("navi").setup({ })
      end,
      keys = {
        { "<leader>na", "<cmd>lua require('navi').Append()<cr>", mode = "n", desc = "NaVI append" },
        { "<leader>ne", "<cmd>lua require('navi').Edit()<cr>", mode = "v", desc = "NaVI edit" },
        { "<leader>nb", "<cmd>lua require('navi').EditBuffer()<cr>", mode = "n", desc = "NaVI edit buffer" },
        { "<leader>nr", "<cmd>lua require('navi').Review()<cr>", mode = "v", desc = "NaVI review" },
        { "<leader>nx", "<cmd>lua require('navi').Explain()<cr>", mode = "v", desc = "NaVI explain" },
        { "<leader>nc", "<cmd>lua require('navi').Chat()<cr>", mode = "n", desc = "NaVI chat" },
      },
    }


## Configuration

in `~/.config/nvim/after/plugin/navi.lua`:

```lua
local navi = require('navi')

navi.setup({
    -- OpenAI token. Required
    openai_token = "<token>", -- Alternatively, use environment variable OPENAI_TOKEN=<token>
    -- OpenAI model. Optional. Default is gpt-3.5-turbo
    openai_model = "gpt-3.5-turbo",
    -- OpenAI max tokens. Optional. Default is 512
    openai_max_tokens = 512,
    -- OpenAI temperature. Optional. Default is 0.6
    openai_temperature = 0.6,
    -- Debug mode. Optional. Default is false
    debug = false, -- Alternatively, use environment variable NAVI_DEBUG=true
    -- Setup for input window 
    prompt_window = {
        border = "single",
        style = "minimal",
        relative = "editor",
    },
    -- Setup for window showing various reports
    report_window = {
        -- Specifies if the report will be shown in a vertical window or in a floating window.
        window = "floating",
        border = "single",
        style = "minimal",
        relative = "editor",
    },
})

-- Set keybindings
vim.api.nvim_set_keymap('v', '<leader>ne', '', { callback = navi.Edit })
vim.api.nvim_set_keymap('i', '<leader>na', '', { callback = navi.Append })
vim.api.nvim_set_keymap('v', '<leader>nr', '', { callback = navi.Review })
vim.api.nvim_set_keymap('v', '<leader>ne', '', { callback = navi.Explain })
vim.api.nvim_set_keymap('n', '<leader>nc', '', { callback = navi.Chat })
```

## Roadmap

- Make the current file context of the chat interface
- Make the chat toggleable
- Improve prompts

## FAQ

- Where can I get an OpenAI token?
    > https://platform.openai.com/
- Can naVi close nVim for me?
    > AI has come far, but not that far. We'll have to wait for human alignment before attempting this.
- Neat! How can I contribute?
    > Great! Check out the [contributing guide](./CONTRIBUTING.md) for more information.
