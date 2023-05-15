local buffer = require("navi.common.buffer")
local dialogue = require("navi.common.dialogue")
local openai = require("navi.common.openai")
local code_review = require("navi.features.review.dialogue")

local codeReviewDialog = dialogue.New(code_review.primer)

local M = {}

function M.RequestReview(cfg, buf, from_row, to_row)
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

return M
