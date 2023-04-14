local M = {}

M.messages = {
    { role = "system", content = table.concat({
        "You are an assistant made for the purpose of helping writing " .. vim.bo.filetype .. " code.",
        "- Respond with your answers in markdown (```).",
        "- Do not provide explanations or comments.",
        "- Preserve indentation.",
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
    M.push("Consider the following code only:```\n" .. context .. "```")
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
