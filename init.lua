-- hs.logger.defaultLogLevel = 'debug'

require("jumpcut")
require("unclack")
require("tabber")

jumpcut = jumpcut.new({
  storeImages=true,
  nextShortcut={{"cmd", "alt"}, "up"},
  previousShortcut={{"cmd", "alt"}, "down"}
})
unclack = unclack.new({resetTime=0.5})
tabber = tabber.new()

hs.hotkey.bind({"cmd", "alt"}, "v", function() jumpcut:popup() end)
hs.hotkey.bind({"ctrl", "alt", "command"}, "M", function() unclack:toggle() end)
hs.hotkey.bind({"alt"}, "space", function() tabber:show() end)

jumpcut:start()
unclack:start()
tabber:start()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, 'r', function()
  hs.reload()
  hs.toggleConsole()
end)
