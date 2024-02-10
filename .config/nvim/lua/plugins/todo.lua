return {
    "folke/todo-comments.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local todo = require("todo-comments")

        todo.setup {
            keywords = {
                PERF = { icon = "" },
                NOTE = { icon = "" },
                TODO = { icon = "" },
                HACK = { icon = "" },
                WARN = { icon = "" },
                FIX  = { icon = "" },
            },
        }
        -- example:
        -- PERF:
        -- NOTE:
        -- TODO:
        -- HACK:
        -- WARN:
        -- FIX: 
    end,
}
