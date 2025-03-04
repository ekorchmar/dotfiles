-- Get the first line of a CSV file
local first_line = vim.api.nvim_buf_get_lines(0, 1, 2, false)[1]
local tabs = first_line:gsub("[^\t]", "")

if #tabs >= 2 then
    -- We are in a TSV file
    vim.bo.filetype = "tsv"
end
