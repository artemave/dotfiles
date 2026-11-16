import { atom, read, update } from 'claude-code'
import type { Register } from 'claude-code'

import type { Doc } from '../types'
import { diffBlocks } from './diff'

const PANE = 'doc-view'
const TOOL = 'mcp__doc-view__show_document'
const doc = atom({ plugin: 'doc-view', key: 'doc' } as const, null as Doc | null)

export const register: Register = on => {
  on('session.start', async ($, e, next) => {
    await $.tool.register({
      name: 'show_document',
      description:
        'Show the document the user is working on with you (a draft, summary, plan, notes, spec, ' +
        'email, etc.) in a live side pane, with what changed since the last call highlighted. ' +
        'Call it every time you create or revise such a document, passing the FULL current text as ' +
        'markdown, never a diff. Keep the same title across revisions of one document; a new title ' +
        'starts a new document. The user reads the document in the pane, so your reply can just ' +
        'say what changed.',
      inputSchema: {
        type: 'object',
        properties: {
          title: { type: 'string', description: 'Stable name of the document' },
          markdown: { type: 'string', description: 'The full current document' },
        },
        required: ['title', 'markdown'],
      },
      isDeferred: false,
    })
    await $.command.register({
      name: 'doc-view',
      description: 'Show the document pane',
    })

    return next(e)
  })

  on('command.run', { command: 'doc-view' }, async $ => {
    await $.ui.open({ id: PANE, title: 'Document' })

    return { text: 'Document pane opened.' }
  })

  on('tool.call', { tool: TOOL }, async ($, e) => {
    const { title, markdown } = e
    const shown = await update($, doc, current =>
      current?.title === title
        ? { title, text: markdown, previous: current.text, version: current.version + 1 }
        : { title, text: markdown, previous: null, version: 1 },
    )
    await $.ui.open({ id: PANE, title })

    return { result: `Shown "${title}" (version ${shown!.version}) in the document pane.` }
  })

  on('ui.render', { component: 'Pane', requestId: PANE }, async ($, e) => {
    const { Box, Text, Markdown } = $.ui.resolve(e)
    const current = await read($, doc)

    if (current === null) {
      return <Text dimColor>No document yet. Ask Claude to write or revise one.</Text>
    }

    const blocks = diffBlocks(current.previous, current.text)
    const count = (kind: string) => blocks.filter(block => block.kind === kind).length
    const summary =
      current.previous === null
        ? 'first version'
        : [
            `${count('changed')} changed`,
            `${count('added')} added`,
            `${count('removed')} removed`,
          ].join(' · ')

    return (
      <Box flexDirection="column" gap={1}>
        <Box flexDirection="column">
          <Text weight="bold">{current.title}</Text>
          <Text dimColor>
            v{current.version} · {summary}
          </Text>
        </Box>
        {blocks.map(block => {
          switch (block.kind) {
            case 'same':
              return <Markdown text={block.text} />
            case 'added':
              return (
                <Box borderStyle="round" borderColor="success" paddingX={1}>
                  <Markdown text={block.text} />
                </Box>
              )
            case 'changed':
              return (
                <Box borderStyle="round" borderColor="warning" paddingX={1}>
                  <Markdown text={block.text} />
                </Box>
              )
            case 'removed':
              return (
                <Text color="error" strikethrough wrap="truncate-end">
                  {block.before.split('\n')[0]}
                </Text>
              )
          }
        })}
      </Box>
    )
  })
}
