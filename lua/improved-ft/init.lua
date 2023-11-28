local jump = require("improved-ft.jump")

local M = {}

M._reset_state = function()
  M._jump_options_manager = require("improved-ft.jump-options-manager").new()
end
M._reset_state()

---@param opts IFT_UserJumpOptions
M.jump = function(opts)
  local jump_options = M._jump_options_manager.get_from_user_options(opts)
  jump(jump_options)
end

M.repeat_forward = function()
  local jump_options = M._jump_options_manager.get_repeating_options("forward")
  if jump_options ~= nil then
    jump(jump_options)
  end
end

M.repeat_backward = function()
  local jump_options = M._jump_options_manager.get_repeating_options("backward")
  if jump_options ~= nil then
    jump(jump_options)
  end
end

---@class IFT_SetupOptions
---@field use_default_mappings boolean

---@param opts IFT_SetupOptions
M.setup = function(opts)
  opts = opts or {}

  if opts.use_default_mappings then
    local map = function(key, fn, fn_options, description)
      vim.keymap.set({ "n", "x", "o" }, key, function()
        fn(fn_options)
      end, {
        desc = description,
      })
    end

    local description = "Jump forward to a given char"
    map("f", M.jump, { direction = "forward", offset = "none" }, description)

    description = "Jump backward to a given char"
    map("<S-f>", M.jump, { direction = "backward", offset = "none" }, description)

    description = "Jump forward before a given char"
    map("t", M.jump, { direction = "forward", offset = "pre" }, description)

    description = "Jump backward before a given char"
    map("<S-t>", M.jump, { direction = "backward", offset = "pre" }, description)

    map(";", M.repeat_forward, nil, "Jump forward to a last given char")
    map(",", M.repeat_backward, nil, "Jump backward to a last given char")
  end
end

return M
