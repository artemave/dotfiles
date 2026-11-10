export type Doc = {
  title: string
  text: string
  previous: string | null
  version: number
}

declare module 'claude-code' {
  interface PluginState {
    'doc-view': { doc: Doc | null }
  }
}
