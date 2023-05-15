local M = {}

M.primer = table.concat({
    "You are an assistant made for the purpose of rubber ducking " .. vim.bo.filetype .. " code.",
}, ". ")

return M
