local api = vim.api
local buffer = require("navi.common.buffer")
local dialogue = require("navi.common.dialogue")
local openai = require("navi.common.openai")
local interceptors = require("navi.common.openai.interceptors")
local prompt = require("navi.common.prompt")
local code_building = require("navi.features.prompt.dialogue")

local codeBuildingDialog = dialogue.New(code_building.primer)

local M = {}

function M.PromptWithoutContext(cfg)
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

function M.PromptWithContext(cfg, buf, from_row, to_row)
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

return M
