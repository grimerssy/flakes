local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
    return
end

local servers = {}

for server, delta in pairs(servers) do
    local old = (lspconfig[server].manager or {}).config or {}
    local new = vim.tbl_deep_extend("force", old, delta(old))
    lspconfig[server].setup(new)
end
