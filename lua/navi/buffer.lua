local M = {}

function M.GetSelection()
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

return M
