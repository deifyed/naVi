# naVi

Your NeoVim assistant.

## Usage

`<C-n>` will open a prompt. Use this prompt to tell naVi what to do. For example, insert a React component outline.

Select text and press `<C-n>` to prompt naVi to make changes to the selected text. For example, remove a bug.

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

Configure your OpenAI token like this:

```bash
export OPENAI_TOKEN=<token>
```

Debug messages can be turned on with:

```bash
export NAVI_DEBUG=true
```

## FAQ

- Where can I get an OpenAI token?
    > https://platform.openai.com/
- I'm already using the `<C-n>` keybinding. How can I change it?
    > You can't yet. I'm new to Lua and the NeoVim API. Getting there though.
- Can naVi close nVim for me?
    > AI has come far, but not that far.
