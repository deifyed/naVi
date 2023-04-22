local api = vim.api
local log = require("navi.log")
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local buffer = require("navi.buffer")
local dialogue = require("navi.dialogue")
local code_building = require("navi.dialogue.code-building")
local code_review = require("navi.dialogue.code-review")

local codeBuildingDialog = dialogue.New(code_building.primer)
local codeReviewDialog = dialogue.New(code_review.primer)

local M = {}

function M.request_without_context(cfg)
    local current_window = api.nvim_get_current_win()
    local current_buffer = api.nvim_win_get_buf(current_window)
    local row = unpack(api.nvim_win_get_cursor(current_window))

    prompt.open(cfg, function(content)
        codeBuildingDialog.PushUserMessage(content)

        openai.requestCodeblock(cfg, codeBuildingDialog.GetMessages(), function(codeblock)
            if codeblock == nil then
                return
            end

            codeBuildingDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, codeblock)
        end)
    end)
end

function M.request_review(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    log.d(vim.inspect({ code = code }))

    local msg = code_review.prefixContent(code)

    codeReviewDialog.PushUserMessage(msg)

    openai.requestCodeblock(cfg, codeReviewDialog.GetMessages(), function(codeblock)
        if codeblock == nil then
            return
        end

        codeReviewDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

        if cfg.report_window.window == "floating" then
            buffer.CreateFloatingWindowWithNewBuffer(cfg, codeblock, " OpenAI review report ")
        else
            buffer.CreateNewBufferWithContent(codeblock)
        end
    end)
end

function M.request_with_context(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    log.d(vim.inspect({ code = code }))

    prompt.open(cfg, function(content)
        local msg = code_building.withCodeContext(code, content)
        codeBuildingDialog.PushUserMessage(msg)

        openai.requestCodeblock(cfg, codeBuildingDialog.GetMessages(), function(codeblock)
            if codeblock == nil then
                return
            end

            codeBuildingDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

            api.nvim_buf_set_lines(buf, from_row, to_row, false, codeblock)
        end)
    end)
end

return M
