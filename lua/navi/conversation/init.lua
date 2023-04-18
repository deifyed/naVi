local templates = require("navi.conversation.templates")
local log = require("navi.log")

local converstations = {}

local function setupConversation(type)
    local conv = {}

    conv[type] = {}

    conv[type]["pre"] = templates.messages[type].pre
    conv[type]["post"] = templates.messages[type].post
    conv[type]["messages"] = templates.messages[type].init

    return conv[type]
end

local function push(list, content)
    local msg = {
        role = "user",
        content = content,
    }

    table.insert(list, msg)
end

local M = {}

function M.GetConversation(type)
    if not converstations[type] then
        converstations[type] = setupConversation(type)
    end

    return converstations[type]
end

-- Add request from user to conversation
function M.PushRequest(type, content, context)
    local conv = M.GetConversation(type)

    local ctn = ""
    local ctx = ""

    if content then
        ctn = content
    end

    if context then
        ctx = context
    end

    local text = table.concat({ conv["pre"], "```", ctx, "```", ctn, conv["post"], "\n" })
    log.d(text)
    push(conv["messages"], text)
end

-- Add response from openAI to conversation
function M.PushResponse(type, content)
    local msg = {
        role = "assistant",
        content = content,
    }

    local list = M.GetConversation(type)

    table.insert(list["messages"], msg)
end

return M
