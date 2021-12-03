table_utils = require("utils.table")

function string.limitShape(item, maxWith, maxHeight)
  local lines = {}
  for line in string.gmatch(item, "([^\n]+)") do
     if (string.len(line) > maxWith) then
        line = string.sub(line, 0, maxWith).."…"
     end
     table.insert(lines, line)
  end

  shortenedLines = table_utils.slice(lines, 0, maxHeight, 1)
  if not (#shortenedLines == #lines) then
     table.insert(shortenedLines, "…")
  end
  return table.concat(shortenedLines, "\n")
end
