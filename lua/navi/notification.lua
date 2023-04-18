vim.notify = require("notify")

local M = {}

local client_notifs = {}

local function getNotifData(token)
    if not client_notifs[token] then
        client_notifs[token] = {}
    end

    return client_notifs[token]
end

local spinner_frames = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function updateSpinner(token)
    local notif_data = getNotifData(token)

    if notif_data.spinner then
        local new_spinner = (notif_data.spinner + 1) % (#spinner_frames + 1)
        notif_data.spinner = new_spinner

        notif_data.notification = vim.notify(nil, nil, {
            hide_from_history = true,
            icon = spinner_frames[new_spinner + 1],
            replace = notif_data.notification,
        })

        vim.defer_fn(function()
            updateSpinner(token)
        end, 100)
    end
end

function M.Notify(token, kind, message, title)
    local notif_data = getNotifData(token)

    if kind == "begin" then
        notif_data.notification = vim.notify(message, vim.log.levels.INFO, {
            title = title,
            icon = spinner_frames[1],
            timeout = false,
            hide_from_history = false,
        })

        -- start spinner
        notif_data.spinner = 0
        updateSpinner(token)
    elseif kind == "end" and notif_data then
        notif_data.notification = vim.notify(message and message or "Completed successfully", vim.log.levels.INFO, {
            icon = "",
            replace = notif_data.notification,
            timeout = 3000,
        })

        -- end spinner
        notif_data.spinner = nil
    elseif kind == "failed" and notif_data then
        notif_data.notification = vim.notify(message and message or "Request failed!", vim.log.levels.ERROR, {
            icon = "✖",
            replace = notif_data.notification,
            timeout = 3000,
        })

        -- end spinner
        notif_data.spinner = nil
    end
end

return M
