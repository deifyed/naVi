local http = require("http")
local log = require("navi.log")
local notification = require("navi.notification")
local strings = require("navi.utils.strings")

local M = {
    opts = {
        cfg = {},
        response_interceptor = function(response)
            return strings.split(response, "\n")
        end,
        callback = function(_) end,
        messages = {},
    },
}
function M.do_stuff(response)
    local data = vim.fn.json_decode(response.body)

    log.d(vim.inspect(data))
    if data then
        if data.choices[1].message.content == '""' then
            return nil
        end

        local interceptedResponse = M.opts.response_interceptor(data.choices[1].message.content)

        log.d(vim.inspect({ interceptedResponse = interceptedResponse }))

        M.opts.callback(interceptedResponse)
    end
end

function M.callback(token, err, response)
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
        M.do_stuff(response)
    end)

    notification.Notify(token, "end", nil, nil)
end

function M.request(user_opts)
    for k, v in pairs(user_opts) do
        M.opts[k] = v
    end

    local token = vim.env.OPENAI_TOKEN or M.opts.cfg.openai_token

    if token == "" then
        log.e("Missing OpenAI token. Please set the environment variable OPENAI_TOKEN")
        log.e("or set the openai_token option in your config.")
        return
    end

    log.d(vim.fn.json_encode(M.opts.messages))

    notification.Notify(token, "begin", "Request sent...", "Requesting help from OpenAI")

    http.request({
        http.methods.POST,
        "https://api.openai.com/v1/chat/completions",
        vim.fn.json_encode({
            model = M.opts.cfg.openai_model,
            messages = M.opts.messages,
            max_tokens = M.opts.cfg.openai_max_tokens,
            temperature = M.opts.cfg.openai_temperature,
        }),
        headers = {
            ["Authorization"] = "Bearer " .. token,
            ["Content-Type"] = "application/json",
        },
        callback = function(err, response)
            M.callback(token, err, response)
        end,
    })
end

return M
