local http = require("http")

local M = {}

function M.request(cfg, messages, callback)
    local token = vim.env.OPENAI_TOKEN or cfg.openai_token

    if token == '' then
        print("Missing OpenAI token. Please set the environment variable OPENAI_TOKEN or set the openai_token option in your config.")
        return
    end

    if cfg.debug then
        print(vim.fn.json_encode(messages))
    end

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
                print(err)
                return
            end

            if response.code < 400 then
                vim.schedule(function()
                    local data = vim.fn.json_decode(response.body)

                    if cfg.debug then
                        print(vim.inspect(data))
                    end

                    callback(data.choices[1].message.content)
                end)
            else
                print(response.status)
            end
        end
    })
end

return M
