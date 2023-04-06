local http = require("http")

local M = {}

function M.request(messages, callback)
    if vim.env.OPENAI_TOKEN == nil then
        print("Please set the OPENAI_TOKEN environment variable")
        return
    end

    if vim.env.NAVI_DEBUG == "true" then
        print(vim.fn.json_encode(messages))
    end

    http.request({
        http.methods.POST,
        "https://api.openai.com/v1/chat/completions",
        vim.fn.json_encode({
            model = "gpt-3.5-turbo",
            messages = messages,
            max_tokens = 512,
            temperature = 0.6,
        }),
        headers = {
            ["Authorization"] = "Bearer " .. vim.env.OPENAI_TOKEN,
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

                    callback(data.choices[1].message.content)
                end)
            else
                print(response.status)
            end
        end
    })
end

return M
