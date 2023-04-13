local napi = require('navi.api')
local api = vim.api

local M = {
    config = {
        debug = vim.env.NAVI_DEBUG == "true",
        openai_token = "",
        openai_model = "gpt-3.5-turbo",
        openai_max_tokens = 512,
        openai_temperature = 0.6,
    }
}

function get_visual_selection(buf)
    local start_position = api.nvim_buf_get_mark(buf, "<")
    local end_position = api.nvim_buf_get_mark(buf, ">")

    return start_position, end_position
end

function M.openRange()
    if M.config.debug then
        print("Opening navi.request_with_context()")
        print(vim.inspect(start_position), vim.inspect(end_position))
    end

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = get_visual_selection(buf)
    
    napi.request_with_context(M.config, buf, start_position, end_position)
end

function M.open()
    if M.config.debug == "true" then
        print("Opening navi.request_without_context()")
    end

    napi.request_without_context(M.config)
end

function M.setup(opts)
    for k,v in pairs(opts) do
        M.config[k] = v
    end
end

return M
