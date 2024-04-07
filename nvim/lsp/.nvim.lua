local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
    return
end

local servers = {}

--- @return unknown
local function extend_config(old, new)
    if type(new) ~= "table" then
        return new
    end
    if new._append then
        for _, v in ipairs(new._append) do
            table.insert(old, v)
        end
        return old
    end
    if new._compose then
        return function(...)
            old(...)
            return new._compose(...)
        end
    end
    for k in pairs(new) do
        old[k] = extend_config(old[k], new[k])
    end
    return old
end

for server, override in pairs(servers) do
    local manager = lspconfig[server].manager or {}
    local config = extend_config(manager.config or {}, override)
    lspconfig[server].setup(config)
end
