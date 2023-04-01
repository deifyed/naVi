local http = require("http")
local instructions = require("navi.instructions")

local M = {}

function M.request(prompt, callback)
    http.request({
        http.methods.POST,
        "https://api.openai.com/v1/chat/completions",
        vim.fn.json_encode({
            model = "gpt-3.5-turbo",
            messages = {{
                role = "user",
                content = instructions.prefix .. "\n" .. prompt,
            }},
            max_tokens = 64,
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
