local api = vim.api
local log = require("navi.log")
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")
local conversation = require("navi.conversation")

local M = {}

function M.request_without_context(cfg)
    local current_window = api.nvim_get_current_win()
    local current_buffer = api.nvim_win_get_buf(current_window)
    local row = unpack(api.nvim_win_get_cursor(current_window))

    prompt.open(cfg, function(content)
        conversation.push(conversation.messages.prompt, content)

        openai.request(cfg, conversation.messages.prompt, function(response)
            if response == '""' then
                return
            end

            conversation.pushResponse(conversation.messages.prompt, response)

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, utils.cleanResponse(response))
        end)
    end)
end

function M.request_review(cfg, buf, from_row, to_row)
    if from_row > 0 then
        from_row = from_row - 1
    end

    log.d(vim.inspect({
        buf = buf,
        from_row = from_row,
        to_row = to_row,
    }))

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    prompt.open(cfg, function()
        conversation.pushForReview(conversation.messages.review, code)

        openai.request(cfg, conversation.messages.review, function(response)
            if response == '""' then
                return
            end

            local cleanResponse = utils.cleanResponse(response)
            log.d(vim.inspect({ cleanResponse = cleanResponse }))

            conversation.pushResponse(conversation.messages.review, table.concat(cleanResponse, "\n"))

            api.nvim_buf_set_lines(buf, from_row, to_row, false, cleanResponse)
        end)
    end)
end

function M.request_with_context(cfg, buf, from_row, to_row)
    if from_row > 0 then
        from_row = from_row - 1
    end

    log.d(vim.inspect({
        buf = buf,
        from_row = from_row,
        to_row = to_row,
    }))

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    log.d(vim.inspect({ code = code }))

    prompt.open(cfg, function(content)
        conversation.pushWithContext(conversation.messages.prompt, code, content)

        openai.request(cfg, conversation.messages.prompt, function(response)
            if response == '""' then
                return
            end

            local cleanResponse = utils.cleanResponse(response)
            log.d(vim.inspect({ cleanResponse = cleanResponse }))

            conversation.pushResponse(conversation.messages.prompt, table.concat(cleanResponse, "\n"))

            api.nvim_buf_set_lines(buf, from_row, to_row, false, cleanResponse)
        end)
    end)
end

return M
