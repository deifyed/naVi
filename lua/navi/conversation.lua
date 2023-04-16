local M = {}

M.messages = {
    prompt = {
        role = "system",
        content = table.concat({
            "You are an assistant made for the purpose of helping writing " .. vim.bo.filetype .. " code.",
            "- Always respond with your suggestions surrounded by codeblocks (```).",
            "- Do not provide explanations or comments.",
            "\n",
            "Example:\n",
            "user: scaffold a function style react component called 'Header'",
            "assistant: ```",
            "import React from 'react';",
            "",
            "function Header() {",
            "\treturn (",
            "\t\t<div>",
            "\t\t\t{/* your header code here */}",
            "\t\t</div>",
            "\t);",
            "}",
            "",
            "export default Header;",
            "```",
            "\n",
            "\n",
            'user: Consider the following code: ```\t<title>Title</title>```\nthe title should be "Hello world"',
            "assistant: ```\t<title>Hello world</title>```",
        }, "\n"),
    },
    review = {
        role = "system",
        content = table.concat({
            "You are an assistant made for the purpose of reviewing " .. vim.bo.filetype .. " code.",
            "\n\nYour review should contain:",
            "- Your suggestions for improvements",
            "- Your verdict of what parts that is good or bad",
            "- Provide line numbers",
            "- End with a general verdict as a short summary",
        }, "\n"),
    },
}

function M.push(list, content)
    local msg = {
        role = "user",
        content = content,
    }

    table.insert(list, msg)
end

function M.pushForReview(list, context)
    M.push(
        list,
        table.concat({
            "Review the following code:",
            "```" .. context .. "```",
        }, "\n")
    )
end

function M.pushWithContext(list, context, content)
    M.push(
        list,
        table.concat({
            "Consider the following code:",
            "```" .. context .. "```",
            content,
            "\n\nRemember:",
            "- Your suggestion will replace the provided code.",
            "- Your reply should contain identical code indentation.",
            "- Suggest only changes within the scope of the provided code. I will provide surrounding code.",
        }, "\n")
    )
end

function M.pushResponse(list, content)
    local msg = {
        role = "assistant",
        content = content,
    }

    table.insert(list, msg)
end

return M
