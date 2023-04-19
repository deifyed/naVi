local api = vim.api
local log = require("navi.log")
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")
local conversation = require("navi.conversation")
local buffer = require("navi.buffer")

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
        request(cfg, "prompt", content, nil, function(response)
            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, response)
        end)
    end)
end

function M.request_review(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    log.d(vim.inspect({ code = code }))

    request(cfg, "review", nil, code, function(response)
        if cfg.report_window.window == "floating" then
            buffer.CreateFloatingWindowWithNewBuffer(cfg, response, " OpenAI review report ")
        else
            buffer.CreateNewBufferWithContent(response)
        end
    end)
end

function M.request_with_context(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    log.d(vim.inspect({ code = code }))

    prompt.open(cfg, function(content)
        request(cfg, "promptWithContext", content, code, function(response)
            api.nvim_buf_set_lines(buf, from_row, to_row, false, response)
        end)
    end)
end

return M
