local http = require("http")
local log = require("navi.log")

local M = {}

function M.request(cfg, messages, callback)
    local token = vim.env.OPENAI_TOKEN or cfg.openai_token

    if token == '' then
        log.e("Missing OpenAI token. Please set the environment variable OPENAI_TOKEN or set the openai_token option in your config.")

        return
    end

    log.d(vim.fn.json_encode(messages))

    http.request({
        http.methods.POST,
        "https://api.openai.com/v1/chat/completions",
        vim.fn.json_encode({
            model = cfg.openai_model,
            messages = messages,
            max_tokens = cfg.openai_max_tokens,
            temperature = cfg.openai_temperature,
        }),
        headers = {
            ["Authorization"] = "Bearer " .. token,
            ["Content-Type"] = "application/json"
        },
        callback = function(err, response)
            if err then
                log.e(err)

                return
            end

            if response.code < 400 then
                vim.schedule(function()
                    local data = vim.fn.json_decode(response.body)

                    log.d(vim.inspect(data))

                    callback(data.choices[1].message.content)
                end)
            else
                log.d(response.status)
            end
        end
    })
end

return M
