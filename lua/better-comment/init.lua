local M = {}

local api = vim.api
local cmd = vim.api.nvim_create_autocmd
local treesitter = vim.treesitter
local opts = {
    tags = {
        {
            name = "TODO",
            fg = "white",
            bg = "#0a7aca",
            bold = true,
            virtual_text = "",
        },
        {
            name = "FIX",
            fg = "white",
            bg = "#f44747",
            bold = true,
            virtual_text = "",
        },
        {
            name = "WARNING",
            fg = "#FFA500",
            bg = "",
            bold = false,
            virtual_text = "",
        },
        {
            name = "!",
            fg = "#f44747",
            bg = "",
            bold = true,
            virtual_text = "",
        }

    },
}


M.Setup = function(config)
    if config and config.tags then
        opts.tags = vim.tbl_deep_extend("force", opts.tags, config.tags or {})
    end

    local augroup = vim.api.nvim_create_augroup("better-comments", {clear = true})
    cmd({ 'BufWinEnter', 'BufFilePost', 'BufWritePost' }, {
        group = augroup,
        callback = function()
            local current_buffer = api.nvim_get_current_buf()
            local current_buffer_name = api.nvim_buf_get_name(current_buffer)
            if current_buffer_name == '' then
                return
            end
            local fileType = api.nvim_buf_get_option(current_buffer, "filetype")
            local success, parsed_query = pcall(function()
                return treesitter.query.parse(fileType, [[(comment) @all]])
            end)
            if not success then
                return
            end
            local commentsTree = treesitter.query.parse(fileType, [[(comment) @all]])

            -- FIX: Check if file has treesitter
            local root = Get_root(current_buffer, fileType)
            local comments = {}
            for _, node in commentsTree:iter_captures(root, current_buffer, 0, -1) do
                local range = { node:range() }
                table.insert(comments, {
                    line = range[1],
                    col_start = range[2],
                    finish = range[4],
                    text = vim.treesitter.get_node_text(node, current_buffer)
                })
            end

            if comments == {} then
                return
            end
            Create_hl(opts.tags)

            for id, comment in ipairs(comments) do
                for hl_id, hl in ipairs(opts.tags) do
                    if string.find(comment.text, hl.name) then
                        if hl.virtual_text ~= "" then
                            local ns_id = vim.api.nvim_create_namespace(hl.name)
                            local v_opts = {
                                id = id,
                                virt_text = { { hl.virtual_text, "" } },
                                virt_text_pos = 'overlay',
                                virt_text_win_col = comment.finish + 2,
                            }
                            api.nvim_buf_set_extmark(current_buffer, ns_id, comment.line, comment.line, v_opts)
                        end

                        vim.api.nvim_buf_add_highlight(current_buffer, 0, tostring(hl_id), comment.line,
                            comment.col_start,
                            comment.finish)
                    end
                end
            end

        end
    })
end

Get_root = function(bufnr, filetype)
    local parser = vim.treesitter.get_parser(bufnr, filetype, {})
    local tree = parser:parse()[1]
    return tree:root()
end

function Create_hl(list)
    for id, hl in ipairs(list) do
        vim.api.nvim_set_hl(0, tostring(id), {
            fg = hl.fg,
            bg = hl.bg,
            bold = hl.bold,
        })
    end
end

return M
