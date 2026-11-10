import { describe, expect, test } from 'claude-code/testing'

import { diffBlocks } from './diff'

const TOOL = 'mcp__doc-view__show_document'
const SURFACES = ['terminal', 'desktop'] as const

describe('diffBlocks', () => {
  test('marks changed, added and removed blocks', async () => {
    const before = 'Intro\n\nKeep\n\nOld para\n\nGone'
    const after = 'Intro\n\nKeep\n\nNew para\n\nExtra'
    expect(diffBlocks(before, after)).toEqual([
      { kind: 'same', text: 'Intro' },
      { kind: 'same', text: 'Keep' },
      { kind: 'changed', text: 'New para', before: 'Old para' },
      { kind: 'changed', text: 'Extra', before: 'Gone' },
    ])
    expect(diffBlocks('A\n\nB', 'A\n\nB\n\nC')).toEqual([
      { kind: 'same', text: 'A' },
      { kind: 'same', text: 'B' },
      { kind: 'added', text: 'C' },
    ])
    expect(diffBlocks('A\n\nB\n\nC', 'A\n\nC')).toEqual([
      { kind: 'same', text: 'A' },
      { kind: 'removed', before: 'B' },
      { kind: 'same', text: 'C' },
    ])
  })

  test('keeps a code fence with blank lines as one block', async () => {
    expect(diffBlocks(null, '```\na\n\nb\n```')).toEqual([{ kind: 'same', text: '```\na\n\nb\n```' }])
  })
})

for (const surface of SURFACES) {
  test(`pane highlights the latest revision on ${surface}`, async ($, on) => {
    on('ui.open', () => ({ value: { isPlaced: true } }))
    await $.tool.call({ tool: TOOL, input: { title: 'Plan', markdown: 'Goal\n\nStep one' } })
    await $.tool.call({ tool: TOOL, input: { title: 'Plan', markdown: 'Goal\n\nStep one, revised\n\nStep two' } })

    const pane = await $.ui.mount({
      plugin: 'doc-view',
      surface,
      component: 'Pane',
      requestId: 'doc-view',
      props: {} as never,
    })

    expect(await pane.find({ type: 'Text', text: 'v2 · 1 changed · 1 added · 0 removed' })).toBeDefined()
    const boxes = await pane.findAll({ type: 'Box' })
    const colors = boxes.map(box => box.props.borderColor).filter(Boolean)
    expect(colors).toEqual(['warning', 'success'])
  })
}

test('a new title starts a new document with nothing highlighted', async ($, on) => {
  on('ui.open', () => ({ value: { isPlaced: true } }))
  await $.tool.call({ tool: TOOL, input: { title: 'A', markdown: 'one' } })
  await $.tool.call({ tool: TOOL, input: { title: 'B', markdown: 'two' } })

  const pane = await $.ui.mount({
    plugin: 'doc-view',
    surface: 'terminal',
    component: 'Pane',
    requestId: 'doc-view',
    props: {} as never,
  })

  expect(await pane.find({ text: 'v1 · first version' })).toBeDefined()
})
