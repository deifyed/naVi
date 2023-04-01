local api = require('navi.api')

local M = {}

function M.navi()
    print("Hey from Navi!")
end

M.request_without_context = api.request_without_context
M.request_with_context = api.request_with_context

return M
