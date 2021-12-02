-- hs.logger.defaultLogLevel = 'debug'

require("jumpcut")
require("unclack")

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'r', function()
  hs.reload()
  hs.toggleConsole()
end)
