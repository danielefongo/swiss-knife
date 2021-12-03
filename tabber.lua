tabber = {}
tabber.__index = tabber

fuzzy = require("utils.fuzzy")
table_utils = require("utils.table")

local function sortByScore(t, a, b)
  return t[b].score < t[a].score
end

function tabber:_focus(win)
  win.win:focus()
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
end

function tabber.new()
  local u = setmetatable({keys = {}}, tabber)
  u.chooser = nil
  return u
end

return tabber
