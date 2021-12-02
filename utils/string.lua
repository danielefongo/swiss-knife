local function slice(table, first, last, step)
   local sliced = {}
   for i = first or 1, last or #table, step or 1 do
      sliced[#sliced+1] = table[i]
   end
   return sliced
end

function string.limitShape(item, maxWith, maxHeight)
  local lines = {}
  for line in string.gmatch(item, "([^\n]+)") do
     if (string.len(line) > maxWith) then
        line = string.sub(line, 0, maxWith).."…"
     end
     table.insert(lines, line)
  end

  shortenedLines = slice(lines, 0, maxHeight, 1)
  if not (#shortenedLines == #lines) then
     table.insert(shortenedLines, "…")
  end
  return table.concat(shortenedLines, "\n")
end
