# Contract: task-6.task-3

## Inputs
- GET /api/tree -> JSON recursive directory tree structure (nodes with name, path, children[])
- GET /api/doc?path=X -> JSON with markdown content, metadata, and backlinks list
- GET /api/tags -> JSON array of tag objects (name, count) for tag cloud
- GET /api/search?q=X -> JSON array of search result objects (path, title, snippet)
- POST /api/doc -> accepts JSON body {path, content} to save edited markdown
- marked.js library loaded globally (window.marked) for markdown-to-HTML rendering
- highlight.js library loaded globally (window.hljs) for code block syntax highlighting
- HTML page with #tree-container, #doc-content, #backlinks-panel, #tag-cloud, #search-input, #search-results elements

## Outputs
- Recursive collapsible directory tree rendered in #tree-container with expand/collapse toggle
- Rendered markdown document with syntax-highlighted code blocks in #doc-content
- Backlinks list rendered in #backlinks-panel for the currently viewed document
- Clickable tag cloud pills rendered in #tag-cloud, filtering or navigating by tag
- Search results list rendered in #search-results from query input
- Wikilinks ([[target]] and [[target|alias]]) rendered as clickable <a> elements triggering in-app navigation
- Edit/save toggle: edit button swaps #doc-content to textarea with raw markdown, save button POSTs and re-renders

## Constraints
- Single file: all logic in web/static/js/app.js, no build step or module bundler
- No external dependencies beyond marked.js and highlight.js (already loaded via <script> tags)
- Tree rendering must be recursive and support lazy or eager expand/collapse without full page reload
- Wikilink parsing must handle both [[target]] and [[target|alias]] syntax via marked.js extension or post-processing
- Document navigation is in-app (no full page reload); clicking tree nodes, wikilinks, search results, and tags all use the same document-load function
- Edit mode must preserve raw markdown round-trip: rendered HTML -> edit textarea shows original markdown -> save -> re-render
- Code blocks must be highlighted via highlight.js integration with marked.js renderer
- All API calls use fetch(); errors must be handled gracefully with user-visible feedback
- No Python dependencies (this is a frontend JS file; Constitution §3 is N/A but no npm/bundler either)
