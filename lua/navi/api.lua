local api = vim.api
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local strings = require("navi.string_utils")

local M = {}

function M.request_without_context()
    local current_buffer = api.nvim_win_get_buf(0)
    local row, col = unpack(api.nvim_win_get_cursor(0))

    prompt.open(function(content)
        openai.request(content, function(response)
            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, strings.split(response, "\n"))
        end)
    end)
end

function M.request_with_context()
    prompt.open()
end

return M
