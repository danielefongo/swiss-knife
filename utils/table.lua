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

-- https://www.reddit.com/r/lua/comments/417v44/comment/cz0oydn/?utm_source=share&utm_medium=web2x&context=3
function shallowEqual(a,b) --algorithm is O(n log n), due to table growth.
  if #a ~= #b then return false end -- early out
  local t1,t2 = {}, {} -- temp tables
  for k,v in pairs(a) do -- copy all values into keys for constant time lookups
      t1[k] = (t1[k] or 0) + 1 -- make sure we track how many times we see each value.
  end
  for k,v in pairs(b) do
      t2[k] = (t2[k] or 0) + 1
  end
  for k,v in pairs(t1) do -- go over every element
      if v ~= t2[k] then return false end -- if the number of times that element was seen don't match...
  end
  return true
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
  slice = slice,
  shallowEqual = shallowEqual
}
