local api = vim.api
local prompt = require("navi.prompt")

local M = {}

function M.request_without_context()
    local current_buffer = api.nvim_win_get_buf(0)
    local row, col = unpack(api.nvim_win_get_cursor(0))

    prompt.open(current_buffer, row)
end

function M.request_with_context()
    prompt.open()
end

return M
