local log = require("navi.common.log")
local api = vim.api

local M = {}

function M.GetSelectedRows()
    local start_row = vim.fn.getpos("v")[2]
    local end_row = vim.fn.getcurpos()[2]

    if start_row > end_row then
        start_row, end_row = end_row, start_row
    end

    if start_row > 0 then
        start_row = start_row - 1
    end

    return start_row, end_row
end

function M.CreateNewBufferWithContent(content)
    -- create new window
    vim.cmd("new")
    local current_window = api.nvim_get_current_win()
    local current_buffer = vim.api.nvim_win_get_buf(current_window)

    -- set content
    vim.api.nvim_buf_set_lines(current_buffer, -1, -1, true, content)

    vim.api.nvim_buf_set_option(current_buffer, "modifiable", false)
end

function M.CreateFloatingWindowWithNewBuffer(cfg, content, title)
    local buf = api.nvim_create_buf(false, true)

    -- Turn on text wrapping
    api.nvim_create_autocmd({ "BufEnter" }, {
        buffer = buf,
        callback = function()
            api.nvim_command("set wrap")
            api.nvim_command("set linebreak")
        end,
    })

    api.nvim_buf_set_option(buf, "bufhidden", "wipe")

    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local win_height = math.ceil(height * 0.5 - 4)
    local win_width = math.ceil(width * 0.5)

    local row = math.ceil((height - win_height) / 2 - 1)
    local col = math.ceil((width - win_width) / 2)

    local opts = {
        style = cfg.report_window.style,
        border = cfg.report_window.border,
        relative = cfg.report_window.relative,
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        title = title,
    }

    api.nvim_buf_set_lines(buf, -1, -1, true, content)
    api.nvim_buf_set_option(buf, "modifiable", false)

    local win = api.nvim_open_win(buf, true, opts)

    -- Close then window when <ESC> pressed
    api.nvim_buf_set_keymap(buf, "n", "<ESC>", "", {
        callback = function()
            api.nvim_win_close(win, false)
        end,
    })
end

function M.GetSelectedLines(buf, from_row, to_row)
    log.d(vim.inspect({
        buf = buf,
        from_row = from_row,
        to_row = to_row,
    }))

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    log.d(vim.inspect({ code = code }))

    return code
end

return M
