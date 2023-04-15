local api = vim.api
local log = require("navi.log")
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")
local conversation = require("navi.conversation")

local M = {}

function M.request_without_context(cfg)
    local current_buffer = api.nvim_win_get_buf(0)
    local row, col = unpack(api.nvim_win_get_cursor(current_buffer))

    prompt.open(function(content)
        conversation.push(content)

        openai.request(cfg, conversation.messages, function(response)
            if response == "\"\"" then
                return
            end

            conversation.pushResponse(response)

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, utils.cleanResponse(cfg, response))
        end)
    end)
end

function M.request_with_context(cfg, buf, start_position, end_position)
    local from_row = unpack(start_position)
    if from_row > 0 then
        from_row = from_row - 1
    end

    local to_row = unpack(end_position)

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
        from_row = from_row,
        to_row = to_row,
    }))

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    log.d("code: " .. code)

    prompt.open(function(content)
        conversation.pushWithContext(code, content)

        openai.request(cfg, conversation.messages, function(response)
            if response == "\"\"" then
                return
            end

            local cleanResponse = utils.cleanResponse(cfg, response)

            conversation.pushResponse(cleanResponse)

            api.nvim_buf_set_lines(buf, from_row, to_row, false, cleanResponse)
        end)
    end)
end

return M
