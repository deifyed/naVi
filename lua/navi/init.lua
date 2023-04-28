local log = require("navi.log")
local napi = require("navi.api")

local M = {
    config = {
        debug = vim.env.NAVI_DEBUG == "true",
        openai_token = "",
        openai_model = "gpt-3.5-turbo",
        openai_max_tokens = 512,
        openai_temperature = 0.6,
        prompt_window = {
            border = "single",
            style = "minimal",
            relative = "editor",
        },
        report_window = {
            window = "floating",
            border = "single",
            style = "minimal",
            relative = "editor",
        },
    },
}

log.setup(M.config)

function M.requestReview()
    log.d("Opening navi.request_review()")

    napi.request_review(M.config)
end

function M.explainRange()
    log.d("Opening navi.ExplainRange()")

    napi.ExplainRange(M.config)
end

function M.open()
    log.d("Opening navi.request_without_context()")

    napi.request_without_context(M.config)
end

function M.openRange()
    log.d("Opening navi.request_with_context()")

    napi.request_with_context(M.config)
end

function M.openFile()
    log.d("Opening navi.request_with_context()")

    napi.request_with_context(M.config)
end

function M.openChat()
    log.d("Opening navi.request_chat()")

    napi.OpenChat(M.config)
end

function M.setup(opts)
    for k, v in pairs(opts) do
        M.config[k] = v
    end

    log.setup(M.config)
end

return M
