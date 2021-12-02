local historySize = 100
local labelLength = 100
local honorClearContent = false

--

local jumpcut = hs.menubar.new()
jumpcut:setTooltip("Clipboard history")
local pasteboard = require("hs.pasteboard")
local settings = require("hs.settings")
local history = settings.get("dotfiles.jumpcut") or {}
local copied = nil

while (#history > historySize) do
   table.remove(history,1)
end

local function pasteItem(string, key)
   pasteboard.setContents(string)
   hs.eventtap.keyStroke({"cmd"}, "v")
end

local function clearAllItems()
   pasteboard.clearContents()
   history = {}
   settings.set("dotfiles.jumpcut", history)
end

local function clearLastItem()
   table.remove(history,#history)
   settings.set("dotfiles.jumpcut", history)
end

local function formatMenuItem(item)
   if (string.len(item) > labelLength) then
      return string.sub(item, 0, labelLength).."…"
   else
      return item
   end
end

local function storeItem(item)
   if (copied == item) then return end

   copied = item
   if (#history == historySize) then
      table.remove(history, 1)
   end
   table.insert(history, item)
   settings.set("dotfiles.jumpcut", history)
end

local function menu(key)
   data = {}
   if (#history == 0) then
      table.insert(data, {title = "None", disabled = true})
      return data
   end

   for _, item in pairs(history) do
      table.insert(data, 1, {title = formatMenuItem(item), fn = function() pasteItem(item, key) end })
   end

   table.insert(data, {title = "-"})
   table.insert(data, {title = "Clear All", fn = function() clearAllItems() end })

   return data
end

local function storeCopy(current_clipboard)
   if (current_clipboard == nil and honorClearContent) then
      clearLastItem()
   else
      storeItem(current_clipboard)
   end
end

watcher = hs.pasteboard.watcher.new(storeCopy)
watcher:start()

jumpcut:setTitle("✂️")
jumpcut:setMenu(menu)

hs.hotkey.bind({"cmd", "alt"}, "v", function() jumpcut:popupMenu(hs.mouse.absolutePosition()) end)
