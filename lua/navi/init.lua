local napi = require('navi.api')
local api = vim.api


local M = {}

function get_visual_selection(buf)
    local start_position = api.nvim_buf_get_mark(buf, "<")
    local end_position = api.nvim_buf_get_mark(buf, ">")

    return start_position, end_position
end

function M.openRange()
    if vim.env.NAVI_DEBUG == "true" then
        print("Opening navi.request_with_context()")
        print(vim.inspect(start_position), vim.inspect(end_position))
    end

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = get_visual_selection(buf)
    
    napi.request_with_context(buf, start_position, end_position)
end

function M.open()
    if vim.env.NAVI_DEBUG == "true" then
        print("Opening navi.request_without_context()")
    end

    napi.request_without_context()
end

return M
