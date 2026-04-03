# Contract: task-6

## Inputs
- GET /api/tree — directory_tree: nested dict {name, path, children[], docs[]} representing folder hierarchy
- GET /api/doc?path=<relativePath> — {title, content (raw markdown), tags[], date, description, backlinks: string[]}
- GET /api/tags — tag_list: dict[tag, filePath[]] for tag cloud rendering
- GET /api/search?q=<query> — results: [{path, title, snippet}] matching documents
- POST /api/doc?path=<relativePath> body={content} — save edited markdown, returns {success: bool}
- GET /api/backlinks?path=<relativePath> — backlink_map entry: list of {path, title} that link to this doc
- Upstream indexer outputs: file_list, tag_list, directory_tree, link_map, backlink_map, metadata (as defined in md-indexer contract)

## Outputs
- index.html — single-page app with three-column layout: collapsible directory tree (left), markdown content + search + tag cloud (center), backlinks panel (right)
- style.css — responsive CSS grid/flexbox layout, tree expand/collapse styles, tag cloud pill styles, code block highlight theme, editor textarea styles
- app.js — client-side JS: tree toggle, API fetch for doc/tags/search/backlinks, markdown-to-HTML rendering with code highlighting (via marked.js + highlight.js CDN), wikilink click navigation, edit/save toggle with textarea
- DOM events: click on tree node → loads doc in center pane; click on tag pill → filters by tag; click on wikilink → navigates to linked doc; click on backlink → navigates to linking doc; click edit button → textarea mode; click save → POST to API

## Constraints
- No build step — vanilla HTML/CSS/JS only; external libs (marked.js, highlight.js) loaded via CDN <script> tags
- All API calls use fetch() against localhost:5000; paths are relative strings using forward slashes as defined by upstream indexer
- Directory tree must support recursive expand/collapse and reflect actual filesystem hierarchy (per indexer.directory-tree-builder contract)
- Tag cloud must use case-normalized tags (per indexer contract: tag map keys are case-normalized)
- Markdown rendering must convert [[target]] and [[target|alias]] wikilinks to clickable <a> elements that trigger in-app navigation (per md-indexer contract wikilink format)
- Edit mode is a simple <textarea> replacement of the rendered view — no WYSIWYG editor; save triggers POST and re-renders
- Code blocks must have syntax highlighting via highlight.js
- Search is delegated to backend API — frontend only renders results, no client-side full-text search
- Files: web/templates/index.html, web/static/css/style.css, web/static/js/app.js — Flask convention (Jinja2 templates + static assets)
- Zero Python dependency additions — frontend is pure static assets served by the existing Flask app
