local api = vim.api
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")

local M = {}

function M.request_without_context()
    local current_buffer = api.nvim_win_get_buf(0)
    local row, col = unpack(api.nvim_win_get_cursor(0))

    prompt.open(function(content)
        openai.request(content, function(response)
            if response == "\"\"" then
                return
            end

            local splitResponse = utils.string_split(response, "\n")
            local unpackedResponse = {unpack(splitResponse, 2, utils.table_count(splitResponse) - 1)}

            if vim.env.NAVI_DEBUG == "true" then
                print(vim.inspect(splitResponse))
                print(vim.inspect(unpackedResponse))
            end

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, unpackedResponse)
        end)
    end)
end

function M.request_with_context()
    prompt.open()
end

return M
