local M = {}

function M.New(primer)
    local dialogue = { messages = { { role = "system", content = primer or "" } } }

    function dialogue.PushUserMessage(content)
        local msg = { role = "user", content = content }

        table.insert(dialogue.messages, msg)
    end

    function dialogue.PushAssistantMessage(content)
        local msg = { role = "assistant", content = content }

        table.insert(dialogue.messages, msg)
    end

    function dialogue.GetMessages()
        return dialogue.messages
    end

    return dialogue
end

return M
