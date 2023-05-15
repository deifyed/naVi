local http = require("http")
local log = require("navi.common.log")
local notification = require("navi.common.notification")
local strings = require("navi.common.utils.strings")

local M = {}

local function getOpenAIToken(opts)
    if vim.env.OPENAI_TOKEN then
        log.w("OPENAI token is deprecated, use opts or OPENAI_API_KEY environment variable")

        return vim.env.OPENAI_TOKEN
    end

    if vim.env.OPENAI_API_KEY then
        return vim.env.OPENAI_API_KEY
    end

    return opts.cfg.openai_token or ""
end

function M.request(user_opts)
    local opts = {
        cfg = {},
        response_interceptor = function(response)
            return strings.split(response, "\n")
        end,
        callback = function(_) end,
        messages = {},
    }

    for k, v in pairs(user_opts) do
        opts[k] = v
    end

    local token = getOpenAIToken(opts)

    if token == "" then
        log.e("Missing OpenAI token. Please set the environment variable OPENAI_TOKEN")
        log.e("or set the openai_token option in your config.")

        return
    end

    log.d(vim.fn.json_encode(opts.messages))

    notification.Notify(token, "begin", "Request sent...", "Requesting help from OpenAI")

    http.request({
        http.methods.POST,
        "https://api.openai.com/v1/chat/completions",
        vim.fn.json_encode({
            model = opts.cfg.openai_model,
            messages = opts.messages,
            max_tokens = opts.cfg.openai_max_tokens,
            temperature = opts.cfg.openai_temperature,
        }),
        headers = {
            ["Authorization"] = "Bearer " .. token,
            ["Content-Type"] = "application/json",
        },
        callback = function(err, response)
            if err then
                log.e(err)

                notification.Notify(token, "failed", nil, nil)

                return
            end

            if response.code > 400 then
                log.d(vim.inspect(response))

                notification.Notify(token, "failed", nil, nil)
            end

            vim.schedule(function()
                local data = vim.fn.json_decode(response.body)

                log.d(vim.inspect(data))
                if data then
                    if data.choices[1].message.content == '""' then
                        return
                    end

                    local interceptedResponse = opts.response_interceptor(data.choices[1].message.content)

                    log.d(vim.inspect({ interceptedResponse = interceptedResponse }))

                    opts.callback(interceptedResponse)
                end
            end)

            notification.Notify(token, "end", nil, nil)
        end,
    })
end

return M
