local api = vim.api
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local buffer = require("navi.buffer")
local interceptors = require("navi.openai.interceptors")
local dialogue = require("navi.dialogue")
local code_building = require("navi.dialogue.code-building")
local code_review = require("navi.dialogue.code-review")
local code_explanation = require("navi.dialogue.code-explanation")

local codeBuildingDialog = dialogue.New(code_building.primer)
local codeReviewDialog = dialogue.New(code_review.primer)

local M = {}

function M.request_without_context(cfg)
    local current_window = api.nvim_get_current_win()
    local current_buffer = api.nvim_win_get_buf(current_window)
    local row = unpack(api.nvim_win_get_cursor(current_window))

    prompt.open(cfg, function(content)
        codeBuildingDialog.PushUserMessage(content)

        local responseHandler = function(codeblock)
            if codeblock == nil then
                return
            end

            codeBuildingDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, codeblock)
        end

        openai.request({
            cfg = cfg,
            response_interceptor = interceptors.extractCodeblock,
            callback = responseHandler,
            messages = codeBuildingDialog.GetMessages(),
        })
    end)
end

function M.request_review(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)
    local msg = code_review.prefixContent(code)

    codeReviewDialog.PushUserMessage(msg)

    local responseHandler = function(response)
        if response == nil then
            return
        end

        codeReviewDialog.PushAssistantMessage(response)

        if cfg.report_window.window == "floating" then
            buffer.CreateFloatingWindowWithNewBuffer(cfg, response, " OpenAI review report ")
        else
            buffer.CreateNewBufferWithContent(response)
        end
    end

    openai.request({
        cfg = cfg,
        messages = codeReviewDialog.GetMessages(),
        callback = responseHandler,
    })
end

function M.request_with_context(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    prompt.open(cfg, function(content)
        local msg = code_building.withCodeContext(code, content)
        codeBuildingDialog.PushUserMessage(msg)

        local responseHandler = function(codeblock)
            if codeblock == nil then
                return
            end

            codeBuildingDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

            api.nvim_buf_set_lines(buf, from_row, to_row, false, codeblock)
        end

        openai.request({
            cfg = cfg,
            messages = codeBuildingDialog.GetMessages(),
            response_interceptor = interceptors.extractCodeblock,
            callback = responseHandler,
        })
    end)
end

function M.ExplainRange(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    local codeExplanationDialog = dialogue.New(code_explanation.primer)
    codeExplanationDialog.PushUserMessage(code_explanation.withCodeContext(code))

    local responseHandler = function(response)
        if response == nil then
            return
        end

        if cfg.report_window.window == "floating" then
            buffer.CreateFloatingWindowWithNewBuffer(cfg, response, " OpenAI explanation ")
        else
            buffer.CreateNewBufferWithContent(response)
        end
    end

    openai.request({
        cfg = cfg,
        messages = codeExplanationDialog.GetMessages(),
        callback = responseHandler,
    })
end

return M
