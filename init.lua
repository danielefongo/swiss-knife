-- hs.logger.defaultLogLevel = 'debug'

require("jumpcut")
require("unclack")

unclack = unclack.new({resetTime=0.5})
jumpcut = jumpcut.new({})

hs.hotkey.bind({"ctrl", "alt", "command"}, "M", function() unclack:toggle() end)
hs.hotkey.bind({"cmd", "alt"}, "v", function() jumpcut:popup() end)

unclack:start()
jumpcut:start()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'r', function()
  hs.reload()
  hs.toggleConsole()
end)
