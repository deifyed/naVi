local M = {}

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

function table_count(t)
        local count = 0
        for _ in pairs(t) do count = count + 1 end
        return count
end

function M.cleanResponse(cfg, response)
    local splitResponse = string_split(response, "\n")
    local unpackedResponse = {unpack(splitResponse, 2, table_count(splitResponse) - 1)}

    if cfg.debug then
        print(vim.inspect(splitResponse))
        print(vim.inspect(unpackedResponse))
    end

    return unpackedResponse
end


return M
