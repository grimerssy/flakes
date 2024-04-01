local ok, lspconfig = pcall(require, "lspconfig")
if not ok then
    return
end

local servers = {
    rust_analyzer = {
        cmd = {
            "docker",
            "compose",
            "run",
            "--rm",
            "--entrypoint",
            "rust-analyzer",
            "cargo",
        },
    },
}

for server, override in pairs(servers) do
    local config = override
    if lspconfig[server].manager then
        local existing_config = lspconfig[server].manager.config
        config = vim.tbl_deep_extend("force", existing_config, override)
        for _, cb in ipairs({ "on_init", "on_attach" }) do
            if existing_config[cb] and override[cb] then
                config[cb] = function(...)
                    existing_config[cb](...)
                    override[cb](...)
                end
            end
        end
    end
    lspconfig[server].setup(config)
end
