-- ~/.config/nvim/lua/osc52_forced.lua
-- Robust OSC52 helper that FORCE-wraps for tmux and autosends yanks.

local M = {}

local default_cfg = {
  max_length = 120000,  -- Base64 bytes; increase only if you know your terminal accepts it
  autosend = true,      -- automatically send on TextYankPost
  notify = false,       -- show small messages (false = quieter)
  force_tmux = true,    -- IMPORTANT: force tmux wrapping even if vim.env.TMUX is empty
}

local function notify(msg, level)
  if not M.cfg.notify then return end
  pcall(vim.notify, msg, level or vim.log.levels.INFO)
end

-- pure-lua base64 encoder
local function base64_encode(data)
  local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
  local s = {}
  local len = #data
  local i = 1
  while i <= len do
    local c1 = data:byte(i) or 0
    local c2 = data:byte(i+1) or 0
    local c3 = data:byte(i+2) or 0
    local n = c1 * 65536 + c2 * 256 + c3
    local c1i = math.floor(n / 262144) % 64
    local c2i = math.floor(n / 4096) % 64
    local c3i = math.floor(n / 64) % 64
    local c4i = n % 64
    s[#s+1] = b:sub(c1i+1,c1i+1)
    s[#s+1] = b:sub(c2i+1,c2i+1)
    s[#s+1] = b:sub(c3i+1,c3i+1)
    s[#s+1] = b:sub(c4i+1,c4i+1)
    i = i + 3
  end
  local pad = len % 3
  local out = table.concat(s)
  if pad == 1 then out = out:sub(1, -3) .. "==" end
  if pad == 2 then out = out:sub(1, -2) .. "=" end
  return out
end

-- wrap and send sequence (ensures tmux wrapper if requested)
local function send_osc52_raw(text)
  local b64 = base64_encode(text)
  if #b64 > M.cfg.max_length then
    notify(("osc52: too large (%d > %d)"):format(#b64, M.cfg.max_length), vim.log.levels.WARN)
    return false
  end
  local seq = "\27]52;c;" .. b64 .. "\7"

  -- force tmux wrapping if configured (avoids depending on remote $TMUX)
  if M.cfg.force_tmux or vim.env.TMUX then
    -- avoid double wrapping
    if not seq:match("^%x1bPtmux;") and not seq:match("^%z") then
      seq = "\27Ptmux;\27\27" .. seq .. "\27\\"
    end
  end

  local ok, err = pcall(vim.api.nvim_chan_send, vim.v.stderr, seq)
  if not ok then
    notify("osc52 send failed: "..tostring(err), vim.log.levels.ERROR)
    return false
  end
  return true
end

-- public copy: string -> send to local clipboard
function M.copy(text)
  if type(text) ~= "string" or text == "" then return false end
  return send_osc52_raw(text)
end

-- copy the unnamed register (or specific register)
function M.copy_register(reg)
  reg = reg or '"'
  local ok, val = pcall(vim.fn.getreg, reg, 1)
  if not ok then val = vim.fn.getreg(reg) end
  if type(val) == "table" then val = table.concat(val, "\n") end
  if not val or val == "" then notify("osc52: empty register", vim.log.levels.WARN); return false end
  return M.copy(val)
end

-- visual copy helper (simple, robust)
function M.copy_visual()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    notify("osc52: not in visual mode", vim.log.levels.WARN)
    return
  end
  -- get visual selection via marks
  local start_pos = vim.fn.getpos("'<")
  local end_pos = vim.fn.getpos("'>")
  local srow, scol = start_pos[2], start_pos[3]
  local erow, ecol = end_pos[2], end_pos[3]
  local lines = vim.api.nvim_buf_get_lines(0, srow-1, erow, false)
  if #lines == 0 then return end
  -- cut columns
  lines[1] = string.sub(lines[1], scol, #lines[1])
  lines[#lines] = string.sub(lines[#lines], 1, ecol)
  M.copy(table.concat(lines, "\n"))
end

-- autosend on yank
local function enable_autosend()
  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("Osc52ForcedGroup", { clear = true }),
    callback = function()
      local text = vim.fn.getreg('"')
      if type(text) == "table" then text = table.concat(text, "\n") end
      if not text or text == "" then return end
      -- schedule so it doesn't block UI
      vim.schedule(function()
        M.copy(text)
      end)
    end,
  })
end

function M.setup(cfg)
  M.cfg = vim.tbl_extend("force", default_cfg, cfg or {})
  -- always set a safe clipboard provider so + register works locally if needed
  -- but primary behavior is OSC52 forced
  if M.cfg.autosend then enable_autosend() end

  -- create convenience user command
  vim.api.nvim_create_user_command("Osc52Copy", function(opts)
    if opts.args == "" then M.copy_register('"') else M.copy_register(opts.args) end
  end, { nargs = "?" })

  -- visual mapping convenience (safe)
  vim.keymap.set('v', '<leader>y', M.copy_visual, { noremap = true, silent = true })
  notify("osc52_forced: loaded", vim.log.levels.DEBUG)
end

return M
