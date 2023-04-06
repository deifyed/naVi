local api = vim.api
local prompt = require("navi.prompt")
local openai = require("navi.openai")
local utils = require("navi.utils")
local instructions = require("navi.instructions")

local M = {}

function M.request_without_context()
    local current_buffer = api.nvim_win_get_buf(0)
    local row, col = unpack(api.nvim_win_get_cursor(0))

    prompt.open(function(content)
        openai.request(content, function(response)
            if response == "\"\"" then
                return
            end

            local splitResponse = utils.string_split(response, "\n")
            local unpackedResponse = {unpack(splitResponse, 2, utils.table_count(splitResponse) - 1)}

            if vim.env.NAVI_DEBUG == "true" then
                print(vim.inspect(splitResponse))
                print(vim.inspect(unpackedResponse))
            end

            api.nvim_buf_set_lines(current_buffer, row - 1, row - 1, false, unpackedResponse)
        end)
    end)
end

function M.request_with_context(buf, start_position, end_position)
    local from_row = unpack(start_position)
    from_row = from_row - 1
    local to_row = unpack(end_position)

    if vim.env.NAVI_DEBUG == "true" then
        print("buf: " .. buf)
        print("start_position: " .. vim.inspect(start_position))
        print("end_position: " .. vim.inspect(end_position))
        print("from_row: " .. from_row)
        print("to_row: " .. to_row)
    end

    local lines = api.nvim_buf_get_lines(buf, from_row, to_row, false)
    local code = table.concat(lines, "\n")

    if vim.env.NAVI_DEBUG == "true" then
        print("code: " .. code)
    end

    prompt.open(function(content)
        local enriched_content = instructions.enrichSelection(code, content)

        openai.request(enriched_content, function(response)
            if response == "\"\"" then
                return
            end

            local splitResponse = utils.string_split(response, "\n")
            local unpackedResponse = {unpack(splitResponse, 2, utils.table_count(splitResponse) - 1)}

            if vim.env.NAVI_DEBUG == "true" then
                print(vim.inspect(splitResponse))
                print(vim.inspect(unpackedResponse))
            end

            api.nvim_buf_set_lines(buf, from_row, to_row, false, unpackedResponse)
        end)
    end)
end

return M
