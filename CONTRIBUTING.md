# Contribute

## Basics

For now, I'm prioritizing speed - meaning I'm not going to be too picky about contributions as long as they work and
match the general direction of the project. See the [roadmap](./README.md#roadmap) for more info.

1. Fork the repo
2. Make your changes
3. Open a PR
4. I'll review it and (very likely) merge it

## Code style (Suggestions, but not requirements)

### Using pre-commit

Use [pre-commit](https://pre-commit.com/) for linting and formatting. After installing, run `pre-commit install` in
    the root of the project. N.B.: pre-commit expects luacheck to be installed locally on your machine. See
    [luacheck](#luacheck)

### Individually

- Use [stylua](https://github.com/JohnnyMorganz/StyLua) for formatting. After installing it, run `stylua .` in the root
    of the project.
- Use [luacheck](https://github.com/mpeterv/luacheck) for linting. Install it with [luarocks](https://luarocks.org/)
    and run `luacheck .` in the root of the project.

## Commit messages

- Prefix commit messages with ✅ for new features, 🐛 for bug fixes, and 👌 for anything else.
- Use the imperative mood in the subject line. E.g. "Add feature X" instead of "Added feature X" or "Adding feature X"
- Try to adhere to "What changed" and "Why it changed" format. E.g. "Add feature X to do Y" instead of "Add feature X".
    If there's not enough space for the "Why" in the subject line, add it to the body of the commit message.

## My workflow (not necessarily the best one)

1. Clone the repo
2. Follow the [installation instructions](./README.md#installation), but use the local path to the cloned repository 
    instead.
3. Make your changes
4. Close and open another instance of NeoVim to test out features
