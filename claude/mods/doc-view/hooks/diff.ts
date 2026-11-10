export type Block =
  | { kind: 'same' | 'added'; text: string }
  | { kind: 'changed'; text: string; before: string }
  | { kind: 'removed'; before: string }

export function splitBlocks(text: string): string[] {
  const blocks: string[] = []
  let current: string[] = []
  let inFence = false
  for (const line of text.split('\n')) {
    if (/^\s*(```|~~~)/.test(line)) inFence = !inFence
    if (!inFence && line.trim() === '') {
      if (current.length > 0) blocks.push(current.join('\n'))
      current = []
    } else {
      current.push(line)
    }
  }
  if (current.length > 0) blocks.push(current.join('\n'))
  return blocks
}

export function diffBlocks(before: string | null, after: string): Block[] {
  const b = after.length === 0 ? [] : splitBlocks(after)
  if (before === null) return b.map(text => ({ kind: 'same', text }))
  const a = splitBlocks(before)

  const width = b.length + 1
  const lcs = new Int32Array((a.length + 1) * width)
  const at = (i: number, j: number) => lcs[i * width + j]!
  for (let i = a.length - 1; i >= 0; i--)
    for (let j = b.length - 1; j >= 0; j--)
      lcs[i * width + j] = a[i] === b[j] ? at(i + 1, j + 1) + 1 : Math.max(at(i + 1, j), at(i, j + 1))

  const out: Block[] = []
  let removed: string[] = []
  let added: string[] = []
  const flush = () => {
    const paired = Math.min(removed.length, added.length)
    for (let k = 0; k < paired; k++) out.push({ kind: 'changed', text: added[k]!, before: removed[k]! })
    for (const text of added.slice(paired)) out.push({ kind: 'added', text })
    for (const before of removed.slice(paired)) out.push({ kind: 'removed', before })
    removed = []
    added = []
  }

  let i = 0
  let j = 0
  while (i < a.length || j < b.length) {
    if (i < a.length && j < b.length && a[i] === b[j]) {
      flush()
      out.push({ kind: 'same', text: b[j]! })
      i++
      j++
    } else if (j < b.length && (i === a.length || at(i, j + 1) >= at(i + 1, j))) {
      added.push(b[j++]!)
    } else {
      removed.push(a[i++]!)
    }
  }
  flush()
  return out
}
