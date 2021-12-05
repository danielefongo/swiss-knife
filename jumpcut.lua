require("utils.string")
local table_utils = require("utils.table")
local pasteboard = require("hs.pasteboard")
local settings = require("hs.settings")
local MAX_PREVIEW_SIZE = 200

jumpcut = {}
jumpcut.__index = jumpcut

local function preview(image)
   size = image:size()
   maxSize = math.max(size.h, size.w)
   ratio = math.min(1, MAX_PREVIEW_SIZE / maxSize)
   newSize = {h = math.floor(size.h * ratio), w = math.floor(size.w * ratio)}
   return image:setSize(newSize)
end

function jumpcut:_pasteItem(item)
   self.editingPasteboard = true
   pasteboard.writeAllData(item)
   hs.eventtap.keyStroke({"cmd"}, "v")
end

function jumpcut:_clearLastItem()
   table.remove(self.history,#self.history)
   settings.set("dotfiles.jumpcut", self.history)
end

function jumpcut:_storeItem(item)
   if #self.history > 0 and table_utils.shallowEqual(item, self.history[#self.history]) then
      return
   end

   self.actualIndex = 0
   if (#self.history == self.historySize) then
      table.remove(self.history, 1)
   end
   table.insert(self.history, item)
   settings.set("dotfiles.jumpcut", self.history)
end

function jumpcut:_handleCopy()
   if self.editingPasteboard then
      self.editingPasteboard = false
      return
   end

   textContent = hs.pasteboard.readString()
   imageContent = hs.pasteboard.readImage()
   data = hs.pasteboard.readAllData()

   if imageContent then
      if not self.storeImages then
         return
      end
      data["preview"] = preview(imageContent):encodeAsURLString()
   end
   if textContent then
      data["text"] = textContent
   end
   self:_storeItem(data)
   self.actualIndex = 0
end

function jumpcut:_menubarTitle(item, lines)
   local elements = {}
   if item["preview"] then
      table.insert(elements, "📷")
   end
   if item["text"] then
      table.insert(elements, item["text"])
   end
   return string.limitShape(table.concat(elements, " + "), self.labelLength, lines)
end

function jumpcut:_menubar(key)
   data = {}
   if (#self.history == 0) then
      table.insert(data, {title = "None", disabled = true})
      return data
   end

   for _, item in pairs(self.history) do
      title = self:_menubarTitle(item)
      table.insert(data, 1, {title = title, fn = function() self:_pasteItem(item) end })
   end

   table.insert(data, {title = "-"})
   table.insert(data, {title = "Clear All", fn = function() self:clearAll() end })

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
   self.history = settings.get("dotfiles.jumpcut") or {}
   while (#self.history > self.historySize) do
      table.remove(self.history,1)
   end
   self.clipboardWatcher:start()
   self.menu:setTitle("✂️")
   self.menu:setMenu(function() return self:_menubar() end)
end

function jumpcut:clearAll()
   self.editingPasteboard = true
   pasteboard.clearContents()
   self.history = {}
   settings.set("dotfiles.jumpcut", self.history)
end

function jumpcut:popup()
   if (#self.history == 0) then
      return
   end

   if not self.popupOpen then
      self.popupOpen = true
      self.nextCommandHandler = hs.hotkey.bind(self.nextShortcut[1], self.nextShortcut[2], function() self:_popupNext() end)
      self.previousCommandHandler = hs.hotkey.bind(self.previousShortcut[1], self.previousShortcut[2], function() self:_popupPrevious() end)
      self.enterCommandHandler = hs.hotkey.bind({}, "return", function() self:_popupSelected() end)
   end

   local selectedItem = self.history[#self.history - self.actualIndex]
   local selectedIndex = self.actualIndex + 1

   hs.alert.closeSpecific(self.previousPopup)
   self.delayedPopupClose:start()
   if selectedItem["preview"] then
      image = hs.image.imageFromURL(selectedItem["preview"])
      self.previousPopup = hs.alert.showWithImage(selectedIndex, image, self.popupStyle, hs.window.focusedWindow():screen(), self.popupDuration)
   elseif selectedItem["text"] then
      text = selectedIndex .. ")\n" .. string.limitShape(selectedItem["text"], self.labelLength, self.labelHeight)
      self.previousPopup = hs.alert.show(text, self.popupStyle, hs.window.focusedWindow():screen(), self.popupDuration)
   end
end

function jumpcut.new(init)
   local j = setmetatable({keys = {}}, jumpcut)
   j.storeImages = init.storeImages or false
   j.historySize = init.historySize or 100
   j.labelLength = init.labelLength or 100
   j.labelHeight = init.labelHeight or 10
   j.popupDuration = init.popupDuration or 2
   j.popupStyle = init.popupStyle or {strokeWidth=1, fillColor={alpha=1}, textSize=14, radius=6}
   j.honorClearContent = init.honorClearContent or false
   j.nextShortcut = init.nextShortcut or {{}, "up"}
   j.previousShortcut = init.previousShortcut or {{}, "down"}

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
