-- minimal fzy, ref: https://github.com/jhawthorn/fzy/blob/master/src/match.c

local SCORE_GAP_LEADING = -0.005
local SCORE_GAP_TRAILING = -0.005
local SCORE_GAP_INNER = -0.01
local SCORE_MATCH_CONSECUTIVE = 1.0
local SCORE_MAX = math.huge
local SCORE_MIN = -math.huge
local MATCH_MAX_LENGTH = 1024

local fuzzy = {}

function asChars(string)
  local chars = {}
  for i = 1, string.len(string) do
    chars[i] = string:sub(i, i)
  end
  return chars
end

function fuzzy.score(needle, haystack)
  local n = string.len(needle)
  local m = string.len(haystack)
  local needle = string.lower(needle)
  local haystack = string.lower(haystack)
  local needleChars = asChars(needle)
  local haystackChars = asChars(haystack)

  if n == 0 or m == 0 or n > m or m > MATCH_MAX_LENGTH then
    return SCORE_MIN
  elseif needle == haystack then
    return SCORE_MAX
  else
    -- local matchBonus = precomputeBonus(haystack)
    local D = {}
    local M = {}

    for i = 1, n do
      D[i] = {}
      M[i] = {}

      local previousScore = SCORE_MIN
      local gapScore = i == n and SCORE_GAP_TRAILING or SCORE_GAP_INNER

      for j = 1, m do
        if needleChars[i] == haystackChars[j] then
          local score = SCORE_MIN
          if i == 1 then
            score = ((j - 1) * SCORE_GAP_LEADING) -- + matchBonus[j]
          elseif j > 1 then
            local a = M[i-1][j-1] -- + matchBonus[j]
            local b = D[i-1][j-1] + SCORE_MATCH_CONSECUTIVE
            score = math.max(a, b)
          end
          D[i][j] = score
          previousScore = math.max(score, previousScore + gapScore)
          M[i][j] = previousScore
        else
          D[i][j] = SCORE_MIN
          previousScore = previousScore + gapScore
          M[i][j] = previousScore
        end
      end
    end
    return M[n][m]
  end
end

return fuzzy
