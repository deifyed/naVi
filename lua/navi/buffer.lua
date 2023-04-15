local api = vim.api

local M = {}

function M.GetSelection(buf)
    local start_row = vim.fn.getpos("v")[2]
    local end_row = vim.fn.getcurpos()[2]

    return start_row, end_row
end

return M
