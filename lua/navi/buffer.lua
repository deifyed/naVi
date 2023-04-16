local log = require("navi.log")
local api = vim.api

local M = {}

function M.GetSelectedRows()
    local start_row = vim.fn.getpos("v")[2]
    local end_row = vim.fn.getcurpos()[2]

    if start_row > end_row then
        start_row, end_row = end_row, start_row
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

function M.GetSelectedLines(buf, from_row, to_row)
    if from_row > 0 then
        from_row = from_row - 1
    end

    log.d(vim.inspect({
        buf = buf,
        from_row = from_row,
        to_row = to_row,
    }))

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    return code
end

return M
