local M = {}

function M.GetSelection()
    local start_row = vim.fn.getpos("v")[2]
    local end_row = vim.fn.getcurpos()[2]

    if start_row > end_row then
        start_row, end_row = end_row, start_row
    end

    return start_row, end_row
end

return M
