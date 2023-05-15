local api = vim.api
local log = require("navi.common.log")
local buffer = require("navi.common.buffer")
local chat = require("navi.features.chat")
local explain = require("navi.features.explain")
local prompt = require("navi.features.prompt")
local review = require("navi.features.review")

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

function M.Review()
    log.d("Opening navi.Review()")

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = buffer.GetSelectedRows()

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    review.RequestReview(M.config, buf, start_position, end_position)
end
function M.requestReview()
    log.w("navi.requestReview() is deprecated. Use navi.Review() instead")

    M.Review()
end

function M.Explain()
    log.d("Opening navi.Explain()")

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = buffer.GetSelectedRows()

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    explain.ExplainRange(M.config, buf, start_position, end_position)
end
function M.explainRange()
    log.w("navi.explainRange() is deprecated. Use navi.Explain() instead")

    M.Explain()
end

function M.Append()
    log.d("Opening navi.Append()")

    prompt.PromptWithoutContext(M.config)
end
function M.open()
    log.w("navi.open() is deprecated. Use navi.Append() instead")

    M.Append()
end

function M.Edit()
    log.d("Opening navi.Edit()")

    local buf = api.nvim_get_current_buf()
    local start_position, end_position = buffer.GetSelectedRows()

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    prompt.PromptWithContext(M.config, buf, start_position, end_position)
end
function M.openRange()
    log.w("navi.openRange() is deprecated. Use navi.Edit() instead")

    M.Edit()
end

function M.EditBuffer()
    log.d("Opening navi.EditBuffer()")

    local buf = api.nvim_get_current_buf()
    local start_position = 1
    local end_position = api.nvim_buf_line_count(buf)

    log.d(vim.inspect({
        buf = buf,
        start_position = start_position,
        end_position = end_position,
    }))

    prompt.PromptWithContext(M.config, buf, start_position, end_position)
end
function M.openFile()
    log.w("navi.openFile() is deprecated. Use navi.EditBuffer() instead")

    M.EditBuffer()
end

function M.Chat()
    log.d("Opening navi.Chat()")

    chat.OpenChat(M.config)
end
function M.openChat()
    log.w("navi.openChat() is deprecated. Use navi.Chat() instead")

    M.Chat()
end

function M.setup(opts)
    for k, v in pairs(opts) do
        M.config[k] = v
    end

    log.setup(M.config)
end

return M
