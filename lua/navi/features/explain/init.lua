local buffer = require("navi.common.buffer")
local dialogue = require("navi.common.dialogue")
local openai = require("navi.common.openai")
local code_explanation = require("navi.features.explain.dialogue")

local M = {}

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
