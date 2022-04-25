local M = {}

local defaults = {
  terminals = {
    list = {},
    type_opts = {
      float = {
        relative = 'editor',
        row = 0.3,
        col = 0.25,
        width = 0.5,
        height = 0.4,
        border = "single",
      },
      horizontal = { location = "rightbelow", split_ratio = .3, },
      vertical = { location = "rightbelow", split_ratio = .5 },
    }
  },
  behavior = {
    close_on_exit = true,
    auto_insert = true,
  },
  mappings = {
    toggle = {
      float = "<A-i>",
      horizontal = "<A-h>",
      vertical = "<A-v>",
    },
    new = {
      float = "<C-i>",
      horizontal = "<C-h>",
      vertical = "<C-v>",
    },
  }
}

local set_behavior = function(behavior)
  if behavior.close_on_exit then
    vim.api.nvim_create_autocmd({"TermClose"},{
      callback = function()
        vim.schedule_wrap(vim.api.nvim_input('<CR>'))
      end
    })
  end
  if behavior.auto_insert then
    vim.api.nvim_create_autocmd({"BufEnter"}, {
      callback = function() vim.cmd('startinsert') end,
      pattern = 'term://*'
    })
    vim.api.nvim_create_autocmd({"BufLeave"}, {
      callback = function() vim.cmd('stopinsert') end,
      pattern = 'term://*'
    })
  end
end

local create_mappings = function (mappings)
  local opts = { noremap = true, silent = true }
  vim.tbl_map(function(method)
    for type, mapping in pairs(method) do
      vim.keymap.set({'n', 't'}, mapping, function ()
        require("nvterm.terminal")[method](type)
      end, opts)
    end
  end, mappings)
end

M.setup = function (config)
  config = config and vim.tbl_deep_extend("force", defaults, config) or defaults
  local types = {'horizontal', 'vertical', 'float'}
  for _, type in pairs(types) do
    if config[type] then
      config.terminals.type_opts[type] = vim.tbl_deep_extend("force", config.terminals.type_opts[type], config[type])
      config[type] = nil
    end
  end
  set_behavior(config.behavior)
  create_mappings(config.mappings)
  require("nvterm.terminal").init(config.terminals)
end

return M
