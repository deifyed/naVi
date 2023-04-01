local api = require('navi.api')

local M = {}

function M.navi_open()
    api.request_without_context()
end

return M
