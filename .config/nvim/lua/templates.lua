vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "main.tex",
  callback = function()
    local path = vim.fn.expand "~/.config/nvim/templates/template.tex"
    local file = io.open(path, "r")

    if file then
      local content = {}
      for line in file:lines() do
        table.insert(content, line)
      end
      file:close()
      vim.api.nvim_buf_set_lines(0, 0, 0, false, content)
    end

    local sty_path = vim.fn.expand "%:p:h" .. "/evan.sty"
    local template_path = vim.fn.expand "~/.config/nvim/templates/evan.sty" -- Path to stored template

    -- Check if evan.sty already exists
    local file = io.open(sty_path, "r")
    if not file then
      -- Open template file and read content
      local template_file = io.open(template_path, "r")
      if template_file then
        local content = template_file:read "*a" -- Read entire file
        template_file:close()

        -- Write the content to the new evan.sty
        local new_file = io.open(sty_path, "w")
        if new_file then
          new_file:write(content)
          new_file:close()
          print "Created evan.sty with template content."
        else
          print "Error: Unable to create evan.sty"
        end
      else
        print("Error: Template file not found at " .. template_path)
      end
    else
      file:close()
    end
  end,
})
