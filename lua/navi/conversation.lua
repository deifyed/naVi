local M = {}

M.messages = {
    { role = "system", content = "You are an " .. vim.bo.filetype .. " assistant. Your role is to provide compilable code" },
    { role = "user", content = "I will provide any necessary context." },
    { role = "user", content = "If you are unable to provide an answer, reply with an empty string, i.e.: \"\"." },
    { role = "user", content = "Do not add any extra notes. The entirety of your reply must be code." },
    { role = "user", content = "When I ask you to consider certain parts of code, suggest changes to the relevant part only. Code surrounding the part I ask you to consider must be left out" },
}

function M.push(content)
    local msg = {
        role = "user",
        content = content
    }

    table.insert(M.messages, msg)
end

function M.pushWithContext(context, content)
    M.push("Consider the following:\n\n```" .. context .. "```\n\n")
    M.push(content)
end

function M.pushResponse(content)
    local msg = {
        role = "assistant",
        content = content
    }

    table.insert(M.messages, msg)
end

return M
