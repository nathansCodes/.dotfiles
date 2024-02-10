return {
    -- debugging
    "nvim-lua/plenary.nvim",
    {
        "mfussenegger/nvim-dap",
        dependencies = { "rcarriga/nvim-dap-ui" },
        config = function()
            local dap, dapui = require('dap'), require("dapui")

            dapui.setup()

            vim.keymap.set("n", "<leader>dbc", function()
                dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
            end)
            vim.keymap.set("n", "<leader>db",  function() dap.toggle_breakpoint() end)
            vim.keymap.set("n", "<leader>dc",  function() dap.continue()          end)
            vim.keymap.set("n", "<leader>ds",  function() dap.step_over()         end)
            vim.keymap.set("n", "<leader>di",  function() dap.step_into()         end)
            vim.keymap.set("n", "<leader>do",  function() dap.step_out()          end)
            vim.keymap.set("n", "<leader>dq",  function() dap.close()             end)

            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },
    "theHamsta/nvim-dap-virtual-text",
    "nvim-telescope/telescope-dap.nvim",
    {"puremourning/vimspector", build = "python3 install_gadget.py --all"},
}
