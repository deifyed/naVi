local openai = require("navi.common.openai")
local dialogue = require("navi.common.dialogue")
local ui = require("navi.features.chat.ui")
local chat_dialogue = require("navi.features.chat.dialogue")

local M = {}

local chatDialogue = dialogue.New(chat_dialogue.primer)

local chatState = {
    message_log_buffer = nil,
    input_buffer = nil,
}

function M.OpenChat(cfg)
    local on_input_callback = function(lines)
        local input = table.concat(lines, "\n")

        chatDialogue.PushUserMessage(input)

        ui.SetChatMessages(chatState.message_log_buffer, chatDialogue.GetMessages())

        openai.request({
            cfg = cfg,
            messages = chatDialogue.GetMessages(),
            callback = function(response)
                if response == nil then
                    return
                end

                chatDialogue.PushAssistantMessage(table.concat(response, "\n"))

                ui.SetChatMessages(chatState.message_log_buffer, chatDialogue.GetMessages())
            end,
        })
    end

    local message_log_buffer, input_buffer = ui.GenerateChatInterface(on_input_callback)

    chatState.message_log_buffer = message_log_buffer
    chatState.input_buffer = input_buffer
end

return M
