local api = vim.api
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local buffer = require("navi.buffer")
local interceptors = require("navi.openai.interceptors")
local dialogue = require("navi.dialogue")
local code_building = require("navi.dialogue.code-building")
local code_review = require("navi.dialogue.code-review")
local code_explanation = require("navi.dialogue.code-explanation")

local codeBuildingDialog = dialogue.New(code_building.primer)
local codeReviewDialog = dialogue.New(code_review.primer)
local chatDialog = dialogue.New("")

local M = {}

function M.request_without_context(cfg)
    local current_window = api.nvim_get_current_win()
    local current_buffer = api.nvim_win_get_buf(current_window)
    local row = unpack(api.nvim_win_get_cursor(current_window))

    prompt.open(cfg, function(content)
        codeBuildingDialog.PushUserMessage(content)

        local responseHandler = function(codeblock)
            if codeblock == nil then
                return
            end

            codeBuildingDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, codeblock)
        end

        openai.request({
            cfg = cfg,
            response_interceptor = interceptors.extractCodeblock,
            callback = responseHandler,
            messages = codeBuildingDialog.GetMessages(),
        })
    end)
end

function M.request_review(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)
    local msg = code_review.prefixContent(code)

    codeReviewDialog.PushUserMessage(msg)

    local responseHandler = function(response)
        if response == nil then
            return
        end

        codeReviewDialog.PushAssistantMessage(response)

        if cfg.report_window.window == "floating" then
            buffer.CreateFloatingWindowWithNewBuffer(cfg, response, " OpenAI review report ")
        else
            buffer.CreateNewBufferWithContent(response)
        end
    end

    openai.request({
        cfg = cfg,
        messages = codeReviewDialog.GetMessages(),
        callback = responseHandler,
    })
end

function M.request_with_context(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    prompt.open(cfg, function(content)
        local msg = code_building.withCodeContext(code, content)
        codeBuildingDialog.PushUserMessage(msg)

        local responseHandler = function(codeblock)
            if codeblock == nil then
                return
            end

            codeBuildingDialog.PushAssistantMessage(table.concat(codeblock, "\n"))

            api.nvim_buf_set_lines(buf, from_row, to_row, false, codeblock)
        end

        openai.request({
            cfg = cfg,
            messages = codeBuildingDialog.GetMessages(),
            response_interceptor = interceptors.extractCodeblock,
            callback = responseHandler,
        })
    end)
end

function M.ExplainRange(cfg, buf, from_row, to_row)
    local code = buffer.GetSelectedLines(buf, from_row, to_row)

    local codeExplanationDialog = dialogue.New(code_explanation.primer)
    codeExplanationDialog.PushUserMessage(code_explanation.withCodeContext(code))

    local responseHandler = function(response)
        if response == nil then
            return
        end

        if cfg.report_window.window == "floating" then
            buffer.CreateFloatingWindowWithNewBuffer(cfg, response, " OpenAI explanation ")
        else
            buffer.CreateNewBufferWithContent(response)
        end
    end

    openai.request({
        cfg = cfg,
        messages = codeExplanationDialog.GetMessages(),
        callback = responseHandler,
    })
end

local function generateChatInterface(on_input_callback)
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
    api.nvim_command("stopinsert")
    api.nvim_feedkeys("i", "n", true)

    api.nvim_buf_set_keymap(input_buffer, "i", "<CR>", "", {
        callback = function()
            local lines = api.nvim_buf_get_lines(input_buffer, 0, -1, false)

            api.nvim_buf_set_lines(input_buffer, 0, -1, false, {})

            on_input_callback(lines)
        end,
    })

    return message_log_buffer, input_buffer
end

local function setChatMessages(buf, messages)
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

local chatState = {
    message_log_buffer = nil,
    input_buffer = nil,
}

function M.OpenChat(cfg)
    local on_input_callback = function(lines)
        local input = table.concat(lines, "\n")

        chatDialog.PushUserMessage(input)

        setChatMessages(chatState.message_log_buffer, chatDialog.GetMessages())

        openai.request({
            cfg = cfg,
            messages = chatDialog.GetMessages(),
            callback = function(response)
                if response == nil then
                    return
                end

                chatDialog.PushAssistantMessage(table.concat(response, "\n"))

                setChatMessages(chatState.message_log_buffer, chatDialog.GetMessages())
            end,
        })
    end

    local message_log_buffer, input_buffer = generateChatInterface(on_input_callback)

    chatState.message_log_buffer = message_log_buffer
    chatState.input_buffer = input_buffer
end

return M
