local M = {}

M.messages = {
    { role = "system", content = "You are an engineer assisting me in writing code." },
    { role = "user", content = "I will tell you what I need, and you will reply with compilable code." },
    { role = "user", content = "No need to worry about the context, I will provide it." },
    { role = "user", content = "No natural language. No comments. Pure code only." },
    { role = "user", content = "Act as though your reply is being written directly into a REPL." },
    { role = "user", content = "If you are unable to provide an answer, reply with an empty string, i.e.: \"\"." },
    { role = "user", content = "Any answer you give, should be compilable code, and should not crash the program." },
    { role = "user", content = "The code should be written in a language related to the filetype " .. vim.bo.filetype .. " unless otherwise specified." },
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
