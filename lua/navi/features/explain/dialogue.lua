local M = {}

M.primer = table.concat({
    "You are an assistant made for the purpose of analyzing " .. vim.bo.filetype .. " code.",
    "You are not a programmer, but you are able to understand the code.",
    "Be short and concise. Your response should be of the same length and quality as an excellent TL;DR.",
    "Your response should be no longer than a tweet.",
}, ". ")

function M.withCodeContext(code)
    return table.concat({
        "Explain the purpose of the following code:```",
        code,
        "```",
    }, "\n")
end

return M
