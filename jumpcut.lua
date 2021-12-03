require("utils.string")
local pasteboard = require("hs.pasteboard")
local settings = require("hs.settings")

jumpcut = {}
jumpcut.__index = jumpcut

function jumpcut:_pasteItem(item)
   self.copiedItem = item
   pasteboard.setContents(item)
   hs.eventtap.keyStroke({"cmd"}, "v")
end

function jumpcut:_clearAllItems()
   pasteboard.clearContents()
   self.history = {}
   settings.set("dotfiles.jumpcut", self.history)
end

function jumpcut:_clearLastItem()
   table.remove(self.history,#self.history)
   settings.set("dotfiles.jumpcut", self.history)
end

function jumpcut:_storeItem(item)
   if (self.copiedItem == item) then return end

   self.actualIndex = 0
   self.copiedItem = item
   if (#self.history == self.historySize) then
      table.remove(self.history, 1)
   end
   table.insert(self.history, item)
   settings.set("dotfiles.jumpcut", self.history)
end

function jumpcut:_handleCopy(current_clipboard)
   if (current_clipboard == nil and self.honorClearContent) then
      self:_clearLastItem()
   else
      self:_storeItem(current_clipboard)
   end
end

function jumpcut:_menubar(key)
   data = {}
   if (#self.history == 0) then
      table.insert(data, {title = "None", disabled = true})
      return data
   end

   for _, item in pairs(self.history) do
      title = string.limitShape(item, self.labelLength, 1)
      table.insert(data, 1, {title = title, fn = function() self:_pasteItem(item) end })
   end

   table.insert(data, {title = "-"})
   table.insert(data, {title = "Clear All", fn = function() self:_clearAllItems() end })

   return data
end

function jumpcut:_closePopup()
   hs.alert.closeSpecific(self.previousPopup)
   self.delayedPopupClose:stop()
   self.popupOpen = false
   if not (self.nextCommandHandler == nil) then
      self.nextCommandHandler:delete()
      self.previousCommandHandler:delete()
      self.enterCommandHandler:delete()
   end
end

function jumpcut:_popupPrevious()
   self.actualIndex = math.min(self.actualIndex + 1, #self.history - 1)
   self:popup()
end

function jumpcut:_popupNext()
   self.actualIndex = math.max(self.actualIndex - 1, 0)
   self:popup()
end

function jumpcut:_popupSelected()
   self:_closePopup()
   self:_pasteItem(self.history[#self.history - self.actualIndex], event)
end

function jumpcut:start()
   self.history = settings.get("dotfiles.jumpcut") or {"ciao"}
   while (#self.history > self.historySize) do
      table.remove(self.history,1)
   end
   self.clipboardWatcher:start()
   self.menu:setTitle("✂️")
   self.menu:setMenu(function() return self:_menubar() end)
end

function jumpcut:showMenu()
   self.menu:popupMenu(hs.mouse.absolutePosition())
end

function jumpcut:popup()
   if not self.popupOpen then
      self.popupOpen = true
      self.nextCommandHandler = hs.hotkey.bind(self.nextShortcut[1], self.nextShortcut[2], function() self:_popupNext() end)
      self.previousCommandHandler = hs.hotkey.bind(self.previousShortcut[1], self.previousShortcut[2], function() self:_popupPrevious() end)
      self.enterCommandHandler = hs.hotkey.bind({}, "return", function() self:_popupSelected() end)
   end

   local selectedItem = self.history[#self.history - self.actualIndex]

   hs.alert.closeSpecific(self.previousPopup)
   trimmedItem = string.limitShape(selectedItem, self.labelLength, self.labelHeight)
   showedItem = (self.actualIndex+1)..")\n"..trimmedItem
   self.delayedPopupClose:start()
   self.previousPopup = hs.alert.show(showedItem, self.popupStyle, hs.window.focusedWindow():screen(), self.popupDuration)
end

function jumpcut.new(init)
   local j = setmetatable({keys = {}}, jumpcut)
   j.historySize = init.historySize or 100
   j.labelLength = init.labelLength or 100
   j.labelHeight = init.labelHeight or 10
   j.popupDuration = init.popupDuration or 2
   j.popupStyle = init.popupStyle or {strokeWidth=1, fillColor={white=1, alpha=0.1}, textSize=14, radius=6}
   j.honorClearContent = init.honorClearContent or false
   j.nextShortcut = init.nextShortcut or {{}, "up"}
   j.previousShortcut = init.previousShortcut or {{}, "down"}

   j.copiedItem = nil
   j.actualIndex = 0
   j.popupOpen = false
   j.previousPopup = nil
   j.nextCommandHandler = nil
   j.previousCommandHandler = nil
   j.history = {}
   j.menu = hs.menubar.new()
   j.clipboardWatcher = hs.pasteboard.watcher.new(function(e) j:_handleCopy(e) end)
   j.delayedPopupClose = hs.timer.delayed.new(j.popupDuration, function(e) j:_closePopup(e) end)
   return j
end

return jumpcut
