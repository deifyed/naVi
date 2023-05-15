local api = vim.api

local M = {}

function M.SetChatMessages(buf, messages)
    local formattedMessages = {}

    for _, message in ipairs(messages) do
        local content = message.content:gsub("\n", " ")

        if message.role == "user" then
            table.insert(formattedMessages, "You: " .. content)
        elseif message.role == "assistant" then
            table.insert(formattedMessages, "Navi: " .. content)
        end
    end

    api.nvim_buf_set_option(buf, "modifiable", true)
    api.nvim_buf_set_lines(buf, 0, -1, false, formattedMessages)
    api.nvim_buf_set_option(buf, "modifiable", false)
end

function M.GenerateChatInterface(on_input_callback)
    vim.cmd("vsplit")
    vim.cmd("wincmd l")

    local current_win = api.nvim_get_current_win()
    api.nvim_win_set_width(current_win, 60)

    -- Create a new buffer
    local message_log_buffer = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(message_log_buffer, 0, -1, false, {})
    api.nvim_buf_set_option(message_log_buffer, "modifiable", false)
    api.nvim_create_autocmd({ "BufEnter" }, {
        buffer = message_log_buffer,
        callback = function()
            api.nvim_command("set wrap")
            api.nvim_command("set linebreak")
        end,
    })

    -- Add the new buffer to the current window
    api.nvim_win_set_buf(current_win, message_log_buffer)

    vim.cmd("split")
    vim.cmd("wincmd j")

    current_win = api.nvim_get_current_win()
    api.nvim_win_set_height(current_win, 5)

    local input_buffer = api.nvim_create_buf(false, true)
    api.nvim_buf_set_lines(input_buffer, 0, -1, false, {})
    api.nvim_buf_set_name(input_buffer, "Navi Chat")

    -- Add the new buffer to the current window
    api.nvim_win_set_buf(current_win, input_buffer)
    api.nvim_command("startinsert")

    api.nvim_buf_set_keymap(input_buffer, "i", "<CR>", "", {
        callback = function()
            local lines = api.nvim_buf_get_lines(input_buffer, 0, -1, false)

            api.nvim_buf_set_lines(input_buffer, 0, -1, false, {})

            on_input_callback(lines)
        end,
    })

    return message_log_buffer, input_buffer
end

return M
