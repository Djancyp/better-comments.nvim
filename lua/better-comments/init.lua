-- TODO: don't having to resave to remove extmark
-- TODO: see the others TODO

---@class (exact) CommentHighlight
---@field name string
---@field fg string?
---@field bg string?
---@field bold boolean?
---@field underline boolean?
---@field virtual_text string?

local M = {}

local api, treesitter = vim.api, vim.treesitter
local au = api.nvim_create_autocmd
---@class BetterCommentsConfig
local opts = {
    default = true,
    ---@type CommentHighlight[]
    tags = {
        {
            name = "TODO",
            fg = "white",
            bg = "#0a7aca",
            bold = true,
        },
        {
            name = "FIX",
            fg = "white",
            bg = "#f44747",
            bold = true,
        },
        {
            name = "WARNING",
            fg = "#FFA500",
            bold = false,
        },
        {
            name = "!",
            fg = "#f44747",
            bold = true,
        }

    },
}


---@param bufnr integer
---@param filetype string
local function Get_root(bufnr, filetype)
    local parser = treesitter.get_parser(bufnr, filetype, {})
    local tree = parser:parse()[1]
    return tree:root()
end

---@param list CommentHighlight[]
local function Create_hl(list)
    for id, hl in ipairs(list) do
        api.nvim_set_hl(0, tostring(id), {
            fg = hl.fg,
            bg = hl.bg,
            bold = hl.bold,
            underline = hl.underline,
        })
    end
end

---@param config? BetterCommentsConfig
function M.setup(config)
    config = config or {}
    if config.default==false then
        opts.tags = {}
    end
    if config.tags then
        opts.tags = vim.tbl_deep_extend("force", opts.tags, config.tags or {})
    end

    local augroup = api.nvim_create_augroup("better-comments", {clear = true})
    au({ 'BufWinEnter', 'BufFilePost', 'BufWritePost', 'TextChanged', 'TextChangedI'  }, {
        group = augroup,
        callback = function()
            local current_buffer = api.nvim_get_current_buf()
            local current_buffer_name = api.nvim_buf_get_name(current_buffer)
            if current_buffer_name == '' then
                return
            end
            local fileType = vim.bo[current_buffer].filetype
            local success = pcall(treesitter.query.parse, fileType, [[(comment) @all]])
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
                    text = treesitter.get_node_text(node, current_buffer)
                })
            end

            if comments == {} then
                return
            end
            Create_hl(opts.tags)

            for id, comment in ipairs(comments) do
                for hl_id, hl in ipairs(opts.tags) do
                    if string.find(comment.text, hl.name) then
                        local ns_id = api.nvim_create_namespace(hl.name)
                        if hl.virtual_text and hl.virtual_text ~= "" then
                            local v_opts = {
                                id = id,
                                virt_text = { { hl.virtual_text, "" } },
                                virt_text_pos = 'overlay',
                                virt_text_win_col = comment.finish + 2,
                            }

                            -- FIX: comment.line -> 0 in col
                            api.nvim_buf_set_extmark(current_buffer, ns_id, comment.line, 0, v_opts)
                        end

                        -- FIX: using for ns_id ns_id instead of 0 
                        -- so that when we clear the namespace the color also clear
                        api.nvim_buf_add_highlight(current_buffer, ns_id, tostring(hl_id), comment.line,
                            comment.col_start,
                            comment.finish)
                    else
                        -- FIX: added else to delted extmark

                        -- TODO: THIS PART IS CALLED A LOT FIND A WAY TO NOT CHECK EVERY TIME
                        if hl.virtual_text ~= "" then
                            local ns_id = api.nvim_create_namespace(hl.name)

                            -- FIX: clearing the namespace to delete the extmark and the color 
                            api.nvim_buf_clear_namespace(current_buffer, ns_id, comment.line, comment.line+1)
                        end
                    end
                end
            end
        end
    })
end
M.Setup = M.setup -- Preserve backwards compatability!

return M
