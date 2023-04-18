local api = vim.api
local log = require("navi.log")
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")
local conversation = require("navi.conversation")
local buffer = require("navi.buffer")
local notification = require("navi.notification")

local function request(cfg, type, content, context, callback)
    conversation.PushRequest(type, content, context)

    openai.request(cfg, conversation.GetConversation(type)["messages"], function(response)
        if response == '""' then
            return
        end

        local cleanResponse = utils.cleanResponse(response)

        log.d(vim.inspect({ cleanResponse = cleanResponse }))

        conversation.PushResponse(type, table.concat(cleanResponse, "\n"))

        callback(cleanResponse)
    end)
end

local M = {}

function M.request_without_context(cfg)
    local current_window = api.nvim_get_current_win()
    local current_buffer = api.nvim_win_get_buf(current_window)
    local row = unpack(api.nvim_win_get_cursor(current_window))

    prompt.open(cfg, function(content)
        notification.Notify("prompt", "begin", "Request sent...", "Requesting code help from OpenAI")
        request(cfg, "prompt", content, nil, function(response)
            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, response)
            notification.Notify("prompt", "end", nil, "Requesting code help from OpenAI")
        end)
    end)
end

function M.request_review(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    log.d(vim.inspect({ code = code }))

    notification.Notify("review", "begin", "Request sent...", "Requesting review from OpenAI")

    request(cfg, "review", nil, code, function(response)
        buffer.CreateNewBufferWithContent(response)
        notification.Notify("review", "end", nil, "Requesting review from OpenAI")
    end)
end

function M.request_with_context(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    log.d(vim.inspect({ code = code }))
    notification.Notify(
        "promptWithContext",
        "begin",
        "Request sent...",
        "Requesting code help with context from OpenAI"
    )

    prompt.open(cfg, function(content)
        request(cfg, "promptWithContext", content, code, function(response)
            api.nvim_buf_set_lines(buf, from_row, to_row, false, response)
            notification.Notify("promptWithContext", "end", nil, "Requesting code help with context from OpenAI")
        end)
    end)
end

return M
