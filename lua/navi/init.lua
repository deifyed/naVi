local api = vim.api
local log = require("navi.log")
local buffer = require("navi.buffer")
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

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = buffer.GetSelectedRows()

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    napi.request_review(M.config, buf, start_position, end_position)
end

function M.explainRange()
    log.d("Opening navi.ExplainRange()")

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = buffer.GetSelectedRows()

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    napi.ExplainRange(M.config, buf, start_position, end_position)
end

function M.open()
    log.d("Opening navi.request_without_context()")

    napi.request_without_context(M.config)
end

function M.openRange()
    log.d("Opening navi.request_with_context()")

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = buffer.GetSelectedRows()

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    napi.request_with_context(M.config, buf, start_position, end_position)
end

function M.openFile()
    log.d("Opening navi.request_with_context()")

    local buf = api.nvim_get_current_buf()
    local start_position = 1
    local end_position = api.nvim_buf_line_count(buf)

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    napi.request_with_context(M.config, buf, start_position, end_position)
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
