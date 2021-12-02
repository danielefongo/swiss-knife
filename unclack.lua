local enabled = false
local resetTime = 0.5

--

local unclack = hs.menubar.new()

local function setTitle()
  if enabled then
    unclack:setTitle("❌🎤")
  else
    unclack:setTitle("🎤")
  end
end

local function muteInput(bool)
  for _,device in ipairs(hs.audiodevice.allInputDevices()) do
    device:setMuted(bool)
  end
end

local delayedEnableMicrophone = hs.timer.delayed.new(resetTime, hs.fnutils.partial(muteInput, false))

local function keyEventCallback(event)
  if event:getType() == 10 and enabled then
    muteInput(true)
    delayedEnableMicrophone:start()
  end
end

local function toggleUnclack()
  enabled = not enabled
  setTitle()
end

setTitle()
keyEventtap = hs.eventtap.new({hs.eventtap.event.types.keyDown}, keyEventCallback)
keyEventtap:start()
hs.hotkey.bind({"ctrl", "alt", "command"}, "M", toggleUnclack)
