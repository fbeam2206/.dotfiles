-- Dictionary menu for elephant/walker.
-- Offline WordNet lookups via sdcv; data lives in ~/.stardict/dic/wordnet.
-- Cache = false, so GetEntries(query) runs on every keystroke.

Name = "dictionary"
NamePretty = "Dictionary"
Icon = "accessories-dictionary"
Description = "WordNet definitions"
Cache = false
History = false
SearchName = false

-- No %VALUE% in the command, so elephant pipes the entry's Value to stdin.
Actions = {
  copy_definition = "wl-copy",
}

local MIN_QUERY = 3
local MAX_SUBTEXT = 110
local DICT = "WordNet"

-- Typing "?word" runs a spelling-tolerant search instead of an exact one.
-- Kept behind a prefix on purpose: sdcv's fuzzy mode answers "firefox" with
-- firebox/fireboat/firefly and "zellij" with bell jar/Bellini, which would be
-- unusable noise given this menu sits in walker's default provider set.
local FUZZY_PREFIX = "?"
local MAX_FUZZY = 8

local POS_LABEL = {
  n = "noun",
  v = "verb",
  adj = "adjective",
  adv = "adverb",
}

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function shq(s)
  return "'" .. s:gsub("'", "'\\''") .. "'"
end

local function pango_escape(s)
  s = s:gsub("&", "&amp;")
  s = s:gsub("<", "&lt;")
  s = s:gsub(">", "&gt;")
  return s
end

local function truncate(s, n)
  if #s <= n then
    return s
  end
  return s:sub(1, n - 1) .. "…"
end

-- Only look up things that plausibly are words. Keeps the dictionary quiet
-- while typing app names, and avoids spawning sdcv on every stray keystroke.
local function sanitize(query)
  local q = trim(query or "")
  if #q < MIN_QUERY then
    return nil
  end
  if not q:match("^%a[%a%s%-']*$") then
    return nil
  end
  return q:lower()
end

local function lookup(word, fuzzy)
  -- Dropping --exact-search lets sdcv return near-spelling matches.
  local exact = fuzzy and "" or "--exact-search "
  local cmd = string.format(
    "sdcv --non-interactive --utf8-output --json-output %s--use-dict %s %s 2>/dev/null",
    exact, shq(DICT), shq(word))

  local handle = io.popen(cmd)
  if not handle then
    return nil
  end

  local out = handle:read("*a")
  handle:close()

  if not out or trim(out) == "" then
    return nil
  end

  local decoded = jsonDecode(out)
  if type(decoded) ~= "table" then
    return nil
  end

  return decoded
end

-- WordNet bodies look like:
--   run
--        n 1: a score in baseball made by a runner touching all four
--             bases safely; "the Yankees scored 3 runs" [syn: {tally}]
--        2: the act of testing something; "in the experimental trials"
--        v 1: move fast by using one's feet
-- The part of speech is tagged only on the first sense of a group; later
-- senses in that group are bare numbers. A group with a single sense is
-- written "n :" with no number at all. Continuation lines belong to the
-- sense above them.
local function parse_senses(definition)
  local senses = {}
  local current = nil
  local pos = nil

  local function push(p, n, text)
    current = { pos = p, num = n, text = trim(text) }
    table.insert(senses, current)
  end

  for line in definition:gmatch("[^\n]+") do
    local tag, num, rest = line:match("^%s*(%a[%a%-]*)%s+(%d+):%s*(.*)$")
    local solo_tag, solo_rest = line:match("^%s*(%a[%a%-]*)%s+:%s*(.*)$")
    local n, body = line:match("^%s*(%d+):%s*(.*)$")

    if tag then
      pos = tag
      push(pos, tonumber(num), rest)
    elseif solo_tag then
      pos = solo_tag
      push(pos, 1, solo_rest)
    elseif n and pos then
      push(pos, tonumber(n), body)
    elseif current then
      local cont = trim(line)
      if cont ~= "" then
        -- A line ending in "-" is a word hyphenated across the wrap,
        -- e.g. "{how-\ndo-you-do}" -- rejoin it without a space.
        if current.text:sub(-1) == "-" then
          current.text = current.text .. cont
        else
          current.text = current.text .. " " .. cont
        end
      end
    end
  end

  return senses
end

-- One entry per part of speech, in the order WordNet lists them.
local function group_by_pos(senses)
  local order = {}
  local groups = {}

  for _, sense in ipairs(senses) do
    if not groups[sense.pos] then
      groups[sense.pos] = {}
      table.insert(order, sense.pos)
    end
    table.insert(groups[sense.pos], sense)
  end

  return order, groups
end

-- Pull a sense apart into gloss, usage examples and synonym/antonym lists,
-- dropping WordNet's "[syn: {a}, {b}]" braces along the way. The gloss is
-- whatever precedes the first quoted example, which avoids dragging in
-- trailing citation fragments like '- Connor Cruise O\'Brien'.
local function split_sense(text)
  local syn, ant
  local body = text

  body = body:gsub("%[syn:%s*(.-)%]", function(s)
    syn = s:gsub("[{}]", "")
    return ""
  end)

  body = body:gsub("%[ant:%s*(.-)%]", function(s)
    ant = s:gsub("[{}]", "")
    return ""
  end)

  local examples = {}
  for ex in body:gmatch('"(.-)"') do
    table.insert(examples, ex)
  end

  local gloss = body:match('^(.-)"') or body
  gloss = gloss:gsub("%s+", " ")
  gloss = trim(gloss):gsub("[;,:%s%-]+$", "")

  return gloss, examples, syn, ant
end

-- Groups are { {label = "noun", senses = {...}}, ... }. Exact lookups render
-- one entry per part of speech; fuzzy lookups render one entry per candidate
-- word, with every part of speech folded into that entry.
local function build_value(word, groups)
  local lines = {}

  for _, group in ipairs(groups) do
    table.insert(lines, word .. "  (" .. group.label .. ")")
    table.insert(lines, "")

    for _, sense in ipairs(group.senses) do
      local gloss, examples, syn, ant = split_sense(sense.text)

      if #group.senses > 1 then
        table.insert(lines, string.format("%d. %s", sense.num, gloss))
      else
        table.insert(lines, gloss)
      end

      for _, ex in ipairs(examples) do
        table.insert(lines, string.format('     "%s"', ex))
      end
      if syn then
        table.insert(lines, "     syn: " .. syn)
      end
      if ant then
        table.insert(lines, "     ant: " .. ant)
      end
    end

    table.insert(lines, "")
  end

  return trim(table.concat(lines, "\n"))
end

local function build_preview(word, groups, suggestion_for)
  local lines = {}

  if suggestion_for then
    table.insert(lines, string.format("<small>instead of <i>%s</i></small>",
      pango_escape(suggestion_for)))
    table.insert(lines, "")
  end

  for _, group in ipairs(groups) do
    table.insert(lines, string.format("<big><b>%s</b></big>  <i>%s</i>",
      pango_escape(word), pango_escape(group.label)))
    table.insert(lines, "")

    for _, sense in ipairs(group.senses) do
      local gloss, examples, syn, ant = split_sense(sense.text)

      if #group.senses > 1 then
        table.insert(lines, string.format("<b>%d.</b> %s",
          sense.num, pango_escape(gloss)))
      else
        table.insert(lines, pango_escape(gloss))
      end

      for _, ex in ipairs(examples) do
        table.insert(lines, string.format('    <i>"%s"</i>', pango_escape(ex)))
      end
      if syn then
        table.insert(lines, string.format("    <small>syn: %s</small>",
          pango_escape(syn)))
      end
      if ant then
        table.insert(lines, string.format("    <small>ant: %s</small>",
          pango_escape(ant)))
      end

      table.insert(lines, "")
    end
  end

  return table.concat(lines, "\n")
end

-- Elephant scores an entry as the best fuzzy match across its haystack
-- (Text, Subtext, then Keywords), minus min(index*5, 50) for how far down the
-- haystack that match sat. Every suggestion carries the same raw query, so
-- they would otherwise all tie and be re-sorted alphabetically -- burying the
-- likeliest correction. Padding the keyword list with inert entries pushes the
-- raw query one slot further down for each successive candidate, which turns
-- sdcv's ranking into a 5-point score gap. If elephant ever changes that
-- formula the suggestions simply go back to tying, which is what they did
-- before this existed.
local function ranked_keywords(raw, rank)
  local keywords = {}
  for _ = 1, rank do
    table.insert(keywords, "\1")
  end
  table.insert(keywords, raw)
  return keywords
end

local function make_entry(headword, groups, opts)
  local labels = {}
  for _, g in ipairs(groups) do
    table.insert(labels, g.label)
  end

  local first = split_sense(groups[1].senses[1].text)

  return {
    Text = string.format("%s  ·  %s", headword, table.concat(labels, ", ")),
    Subtext = truncate(first, MAX_SUBTEXT),
    Value = build_value(headword, groups),
    Preview = build_preview(headword, groups, opts.suggestion_for),
    PreviewType = "pango",
    Icon = "accessories-dictionary",
    Keywords = opts.keywords,
    Actions = {
      copy_word = "wl-copy " .. shq(headword),
      speak = "espeak " .. shq(headword),
    },
  }
end

function GetEntries(query)
  local entries = {}
  local raw = query or ""

  -- "?word" -> spelling-tolerant search; anything else stays exact.
  local fuzzy = false
  local text = raw
  local stripped = raw:match("^%" .. FUZZY_PREFIX .. "%s*(.*)$")

  if stripped then
    fuzzy = true
    text = stripped
  end

  local word = sanitize(text)
  if not word then
    return entries
  end

  local results = lookup(word, fuzzy)
  if not results then
    return entries
  end

  for _, result in ipairs(results) do
    if #entries >= MAX_FUZZY then
      break
    end

    local definition = result["definition"]
    local headword = result["word"] or word

    if type(definition) == "string" and definition ~= "" then
      local order, by_pos = group_by_pos(parse_senses(definition))
      local groups = {}

      for _, pos in ipairs(order) do
        table.insert(groups, { label = POS_LABEL[pos] or pos, senses = by_pos[pos] })
      end

      if #groups > 0 then
        if fuzzy then
          -- One row per candidate word. The raw query goes in Keywords so the
          -- suggestion still scores well against what was actually typed --
          -- calcScore takes the best match across text/subtext/keywords.
          local corrected = headword:lower() ~= word:lower()

          table.insert(entries, make_entry(headword, groups, {
            keywords = ranked_keywords(raw, #entries),
            suggestion_for = corrected and word or nil,
          }))
        else
          for _, group in ipairs(groups) do
            table.insert(entries, make_entry(headword, { group }, {
              keywords = { headword },
            }))
          end
        end
      end
    end
  end

  return entries
end
