local M = {}

M.messages = {
    { role = "system", content = table.concat({
        "You are an assistant made for the purpose of helping writing software code.",
        "- Respond with your answers in markdown (```).",
        "- Do not respond with anything that is not " .. vim.bo.filetype .. " code.", -- Do not provide explanations.
        "- If the user provides code, the reply should be interchangeable with the most recent provided code. Meaning, the user should be able to replace the reply with the provided code and it should work.",
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
        "Example:\n",
        "user: consider the following:```\n",
        "\t\t<div>",
        "\t\t\t{/* your header code here */}",
        "\t\t</div>",
        "```",
        "user: the div should be a header tag",
        "assistant: ```",
        "\t\t<header>",
        "\t\t\t{/* your header code here */}",
        "\t\t</header>",
        "```",
        "\n",
        "\n",
        "Example:\n",
        "user: consider the following:```\n",
        "\t\t<header>",
        "\t\t\t{/* your header code here */}",
        "\t\t</header>",
        "```",
        "user: the header should contain a h1 with the text 'Hello World'",
        "assistant: ```",
        "\t\t<header>",
        "\t\t\t<h1>Hello World</h1>",
        "\t\t</header>",
        "```",
        "\n",
        "\n",
        "Example:\n",
        "user: consider the following:```\n",
        "\t\t<header>",
        "\t\t\t<h1>Hello World</h1>",
        "\t\t</header>",
        "```",
        "user: the h1 should be clickable and navigate the user to '/home'",
        "assistant: ```",
        "\t\t<header>",
        "\t\t\t<h1><a href='/home'>Hello World</a></h1>",
        "\t\t</header>",
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
