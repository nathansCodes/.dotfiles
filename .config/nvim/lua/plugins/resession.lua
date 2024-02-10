return {
    "stevearc/resession.nvim",
    config = function()
        local resession = require("resession")

        resession.setup {
            autosave = {
                enabled = true,
                interval = 60,
                notify = false,
            },
        }

        vim.api.nvim_create_autocmd("UIEnter", {
            callback = function()
                -- Only load the session if nvim was started with no args
                if vim.fn.argc(-1) == 0 then
                    -- Save these to a different directory, so our manual sessions don't get polluted
                    resession.load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true })
                end
            end,
        })
        vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if vim.api.nvim_buf_get_name(0) ~= "[No Name]" then
                    resession.save(vim.fn.getcwd(), { dir = "dirsession", notify = false })
                end
            end,
        })

        local function get_session_name()
            local name = vim.fn.getcwd()
            local branch = vim.trim(vim.fn.system("git branch --show-current"))
            if vim.v.shell_error == 0 then
                return name .. branch
            end
            return name
        end

        vim.api.nvim_create_autocmd("VimEnter", {
            callback = function()
                -- Only load the session if nvim was started with no args
                if vim.fn.argc(-1) == 0 then
                    resession.load(get_session_name(), { dir = "dirsession", silence_errors = true })
                end
            end,
        })

        vim.api.nvim_create_autocmd("VimLeave", {
            callback = function()
                resession.save(get_session_name(), { dir = "dirsession", notify = false })
            end,
        })
    end,
}
