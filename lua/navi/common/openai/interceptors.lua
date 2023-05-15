local log = require("navi.common.log")
local strings = require("navi.common.utils.strings")
local tables = require("navi.common.utils.tables")

local M = {}

local codeblock_delimiter_prefix = "^```"

local function getCodeblockIndices(lines)
    local start = -1
    local stop = -1

    for i, line in ipairs(lines) do
        if line:find(codeblock_delimiter_prefix) ~= nil then
            if start == -1 then
                start = i + 1
            else
                stop = i - 1
            end
        end
    end

    if start == -1 and stop == -1 then
        start = 1
        stop = tables.length(lines)
    end

    return start, stop
end

function M.extractCodeblock(response)
    local splitResponse = strings.split(response, "\n")
    local start, stop = getCodeblockIndices(splitResponse)

    log.d(vim.inspect({
        response = response,
        splitResponse = splitResponse,
        start = start,
        stop = stop,
    }))

    if start ~= -1 and stop == -1 then -- Found a codeblock start, but no end. Probably a single line response.
        local cleanLine = splitResponse[1]:gsub("`", "")

        return { cleanLine }
    end

    if start == -1 or stop == -1 then -- No codeblocks found. GPT got confused.
        log.d("Start or stop index was -1, returning empty table")

        return { "" }
    end

    local unpackedResponse = { unpack(splitResponse, start, stop) }

    log.d(vim.inspect(unpackedResponse))

    return unpackedResponse
end

return M
