local api = vim.api
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")
local conversation = require("navi.conversation")

local M = {}

function M.request_without_context()
    local current_buffer = api.nvim_win_get_buf(0)
    local row, col = unpack(api.nvim_win_get_cursor(0))

    prompt.open(function(content)
        conversation.push(content)

        openai.request(conversation.messages, function(response)
            if response == "\"\"" then
                return
            end

            conversation.pushResponse(response)

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, utils.cleanResponse(response))
        end)
    end)
end

function M.request_with_context(buf, start_position, end_position)
    local from_row = unpack(start_position)
    from_row = from_row - 1
    local to_row = unpack(end_position)

    if vim.env.NAVI_DEBUG == "true" then
        print("buf: " .. buf)
        print("start_position: " .. vim.inspect(start_position))
        print("end_position: " .. vim.inspect(end_position))
        print("from_row: " .. from_row)
        print("to_row: " .. to_row)
    end

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    if vim.env.NAVI_DEBUG == "true" then
        print("code: " .. code)
    end

    prompt.open(function(content)
        conversation.pushWithContext(code, content)

        openai.request(conversation.messages, function(response)
            if response == "\"\"" then
                return
            end

            conversation.pushResponse(response)

            api.nvim_buf_set_lines(buf, from_row, to_row, false, utils.cleanResponse(response))
        end)
    end)
end

return M
