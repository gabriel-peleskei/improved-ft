local rabbit_hop = require("improved-ft.rabbit-hop.api")
local utils = require("improved-ft.utils")

local M = {}

M.reset_state = function()
  M._cache = {
    hop_direction = "forward",
    rh_options = nil,
    changing_rh_options = nil,
  }
end
M.reset_state()

M._cache_options = function(rh_options)
  if utils.mode() == "operator-pending" then
    M._cache.changing_rh_options = rh_options
  end
  M._cache.rh_options = rh_options
end

local repeat_last_operator_pending_motion = function()
  local last_changing_rh_options = M._cache.changing_rh_options
  if last_changing_rh_options == nil then
    return
  end

  local rh_options = {
    pattern = last_changing_rh_options.pattern,
    direction = last_changing_rh_options.direction,
    offset = last_changing_rh_options.offset,
    insert_mode_target_side = last_changing_rh_options.insert_mode_target_side,
  }

  if vim.v.count ~= 0 then
    rh_options.count = vim.v.count
  end

  rabbit_hop.hop(rh_options)
end

---@param ignore_char_case boolean
---@param direction "forward"|"backward"
---@param offset number
M.hop = function(ignore_char_case, direction, offset)
  if utils.is_vim_repeat() then
    repeat_last_operator_pending_motion()
    return
  end

  local rh_options = {
    direction = direction,
    offset = offset,
    pattern = utils.get_user_inputed_pattern(ignore_char_case),
    count = vim.v.count1,
  }

  if rh_options.direction == "forward" then
    rh_options.insert_mode_target_side = "left"
  else
    rh_options.insert_mode_target_side = "right"
  end

  M._cache.hop_direction = rh_options.direction
  M._cache_options(rh_options)
  rabbit_hop.hop(rh_options)
end

---Repeats last hop forward.
---@param use_relative_repetition boolean
M.repeat_forward = function(use_relative_repetition)
  if utils.is_vim_repeat() then
    repeat_last_operator_pending_motion()
    return
  end

  if M._cache.rh_options == nil then
    return
  end

  local rh_options = {
    pattern = M._cache.rh_options.pattern,
    offset = M._cache.rh_options.offset,
    direction = "forward",
    insert_mode_target_side = "left",
    count = vim.v.count1,
  }

  if use_relative_repetition and M._cache.hop_direction == "backward" then
    rh_options.direction = "backward"
    rh_options.insert_mode_target_side = "right"
  end

  M._cache_options(rh_options)
  rabbit_hop.hop(rh_options)
end

---Repeats last hop backward.
---@param use_relative_repetition boolean
M.repeat_backward = function(use_relative_repetition)
  if utils.is_vim_repeat() then
    repeat_last_operator_pending_motion()
    return
  end

  if M._cache.rh_options == nil then
    return
  end

  local rh_options = {
    pattern = M._cache.rh_options.pattern,
    offset = M._cache.rh_options.offset,
    direction = "backward",
    insert_mode_target_side = "right",
    count = vim.v.count1,
  }

  if use_relative_repetition and M._cache.hop_direction == "backward" then
    rh_options.direction = "forward"
    rh_options.insert_mode_target_side = "left"
  end

  M._cache_options(rh_options)
  rabbit_hop.hop(rh_options)
end

return M