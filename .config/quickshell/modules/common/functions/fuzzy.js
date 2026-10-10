.pragma library

// Scores how well `query` matches `text`: every query letter must appear in
// `text` in order (case-insensitive, spaces in the query ignored).
// Returns -1 for no match; higher is better. Matches at the start of the text
// or of a word, and runs of consecutive letters, score extra.
function score(query, text) {
  const q = query.toLowerCase().replace(/\s+/g, "")
  const t = (text || "").toLowerCase()
  if (q === "")
    return 0
  if (t === "")
    return -1

  let total = 0
  let run = 0
  let pos = 0
  for (let i = 0; i < q.length; i++) {
    const found = t.indexOf(q[i], pos)
    if (found < 0)
      return -1
    run = (i > 0 && found === pos) ? run + 1 : 0
    total += 1 + 2 * run
    if (found === 0 || " -_./".includes(t[found - 1]))
      total += 3
    pos = found + 1
  }

  if (t.startsWith(q))
    total += 10
  else if (t.includes(q))
    total += 5
  // Prefer shorter texts when everything else is equal ("Files" over "Files Settings").
  return total - t.length * 0.01
}

// Returns the items that match `query`, best first. `fields(item)` gives the
// strings to search; the first one counts in full, the rest at half weight
// (e.g. the app name, then its generic name and keywords).
function filter(query, items, fields) {
  const scored = []
  for (const item of items) {
    const texts = fields(item)
    let best = -1
    for (let i = 0; i < texts.length; i++) {
      const s = score(query, texts[i])
      if (s >= 0)
        best = Math.max(best, i === 0 ? s : s / 2)
    }
    if (best >= 0)
      scored.push({ item, score: best })
  }
  scored.sort((a, b) => b.score - a.score)
  return scored.map(r => r.item)
}
