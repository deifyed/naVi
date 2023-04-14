local log = require("navi.log")

local M = {}

local codeblock_delimiter_prefix = "^```"

function string_split(inputstr, sep)
        if sep == nil then
                sep = "%s"
        end
        local t={}
        for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
                table.insert(t, str)
        end
        return t
end

function get_codeblock_indices(lines)
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

    return start, stop
end

function M.cleanResponse(cfg, response)
    local splitResponse = string_split(response, "\n")
    local start, stop = get_codeblock_indices(splitResponse)

    log.d("start: " .. start)
    log.d("stop: " .. stop)

    if cfg.debug and start == stop then
        return {"error: no code block found. see :messages for more info"}
    end

    local unpackedResponse = {unpack(splitResponse, start, stop)}

    log.d(vim.inspect(splitResponse))
    log.d(vim.inspect(unpackedResponse))

    return unpackedResponse
end


return M
