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

-- https://stackoverflow.com/a/30757399
function equal(t1,t2,ignore_mt)
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then return false end
  -- non-table types can be directly compared
  if ty1 ~= 'table' and ty2 ~= 'table' then return t1 == t2 end
  -- as well as tables which have the metamethod __eq
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then return t1 == t2 end
  for k1,v1 in pairs(t1) do
     local v2 = t2[k1]
     if v2 == nil or not equal(v1,v2) then return false end
  end
  for k2,v2 in pairs(t2) do
     local v1 = t1[k2]
     if v1 == nil or not equal(v1,v2) then return false end
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
  equal = equal
}
