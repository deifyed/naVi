-- log_level = 0: no logging
-- log_level = 1: log errors
-- log_level = 2: log errors and warnings
-- log_level = 3: log errors, warnings, and info
-- log_level = 4: log errors, warnings, info, and debug
-- log_level = 5: log everything

local M = { log_level = 1 }

function M.error(msg)
    if M.log_level >= 1 then
        print("[naVi] ERROR: " .. msg)
    end
end

function M.warn(msg)
    if M.log_level >= 2 then
        print("[naVi] WARN: " .. msg)
    end
end

function M.debug(msg)
    if M.log_level >= 4 then
        print("[naVi] DEBUG: " .. msg)
    end
end

M.d = M.debug
M.e = M.error
M.w = M.warn

function M.setup(cfg)
    if cfg.debug then
        M.log_level = 5
    end

    M.d("[naVi] log_level: " .. M.log_level)
end

return M
