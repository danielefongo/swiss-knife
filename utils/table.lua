-- https://stackoverflow.com/a/15706820
function sortedPairs(t, order)
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end

function slice(table, first, last, step)
  local sliced = {}
  for i = first or 1, last or #table, step or 1 do
     sliced[#sliced+1] = table[i]
  end
  return sliced
end

return {
  sortedPairs = sortedPairs,
  slice = slice
}
