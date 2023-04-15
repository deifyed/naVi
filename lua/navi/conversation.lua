local M = {}

M.messages = {
    { role = "system", content = table.concat({
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
        "user: Consider the following code: ```\t<title>Title</title>```\nthe title should be \"Hello world\"",
        "assistant: ```\t<title>Hello world</title>```",
    }, "\n") },
}

function M.push(content)
    local msg = {
        role = "user",
        content = content
    }

    table.insert(M.messages, msg)
end

function M.pushWithContext(context, content)
    M.push(table.concat({
        "Consider the following code:",
        "```" .. context .. "```",
        content,
        "\n\nRemember:",
        "- Your suggestion will replace the provided code.",
        "- Your reply should contain identical code indentation.",
        "- Suggest only changes within the scope of the provided code. I will provide surrounding code.",
    }, "\n"))
end

function M.pushResponse(content)
    local msg = {
        role = "assistant",
        content = content
    }

    table.insert(M.messages, msg)
end

return M
