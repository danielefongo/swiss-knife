tabber = {}
tabber.__index = tabber

fuzzy = require("utils.fuzzy")
table_utils = require("utils.table")

-- workaround: focus chooser when opening it from non-hammerspoon windows
local hammerSpoonFilter = hs.window.filter.new()
hammerSpoonFilter:allowApp("Hammerspoon")
hammerSpoonFilter:subscribe(hs.window.filter.windowCreated, function (a)
  if (a:title() == "Chooser") then
    a:focus()
  end
end)

local function sortByScore(t, a, b)
  return t[b].score < t[a].score
end

function tabber:_focus(win)
  if win then
    win.win:focus()
  end
end

function tabber:_close()
  win = self.chooser:selectedRowContents()
  if win then
    win.win:close()
  end
  self.chooser:show()
end

function tabber:_choices(input)
  local choices = {}
  local sortedChoices = {}

  for _, win in pairs(hs.window.allWindows()) do
    winDescription = win:application():title().." - "..win:title()
    score = fuzzy.score(input, winDescription)
    table.insert(choices, {text=winDescription, win=win, score=score})
  end

  for _,win in table_utils.sortedPairs(choices, sortByScore) do
    table.insert(sortedChoices, win)
  end

  self.chooser:choices(sortedChoices)
end

function tabber:show()
  self.chooser:show()
end

function tabber:start()
  self.chooser = hs.chooser.new(function(win) tabber:_focus(win) end)
  self.chooser:queryChangedCallback(function(input) tabber:_choices(input) end)
  self.chooser:rightClickCallback(function() tabber:_close(chooserino) end)
end

function tabber.new()
  local u = setmetatable({keys = {}}, tabber)
  u.chooser = nil
  return u
end

return tabber
