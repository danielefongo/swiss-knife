unclack = {}
unclack.__index = unclack

function unclack:_setTitle()
  if self.enabled then
    self.menu:setTitle("❌🎤")
  else
    self.menu:setTitle("🎤")
  end
end

function unclack:_muteInput(bool)
  for _, device in ipairs(hs.audiodevice.allInputDevices()) do
    device:setMuted(bool)
  end
end

function unclack:_handleKey(event)
  if event:getType() == 10 and self.enabled then
    self:_muteInput(true)
    self.delayedMicrophoneEnable:start()
  end
end

function unclack:start()
  self.keyEventHandler:start()
  self:_setTitle()
end

function unclack:toggle()
  self.enabled = not self.enabled
  self:_muteInput(false)
  self:_setTitle()
end

function unclack.new(init)
  local u = setmetatable({keys = {}}, unclack)
  u.resetTime = init.resetTime or 0.5

  u.enabled = false
  u.menu = hs.menubar.new()
  u.delayedMicrophoneEnable = hs.timer.delayed.new(u.resetTime, function() u:_muteInput(false) end)
  u.keyEventHandler = hs.eventtap.new({hs.eventtap.event.types.keyDown}, function(e) u:_handleKey(e) end)

  return u
end


return unclack
