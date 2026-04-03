# Contract: frontend-shell

## Inputs
- GET /api/tree — returns nested directory tree JSON (used to populate sidebar)
- GET /api/doc?path=X — returns rendered HTML, metadata, tags, backlinks, outgoing links for a document
- GET /api/tags (assumed) — returns tag list for the tags view
- GET /api/search?q=X (assumed) — returns search results for the search view

## Outputs
- index.html — single-page app shell with sidebar container, content area, and script/style includes
- css/style.css — responsive layout: sidebar + main content, mobile collapse, base typography
- js/app.js — hash router mapping #tree, #tags, #search, #doc/:path to view render functions
- js/app.js — fetchTree() function that calls /api/tree and renders directory tree in sidebar
- js/app.js — navigateTo(hash) API for programmatic navigation from other modules
- DOM contract: #sidebar, #content, .tree-node, .nav-link CSS selectors available for downstream JS modules

## Constraints
- Pure vanilla HTML/CSS/JS — no build step, no framework, no npm dependencies
- Client-side hash routing only (#view/param) — no server-side route handling required
- Sidebar directory tree must load asynchronously from /api/tree on page init
- Responsive: sidebar collapses to hamburger menu below 768px breakpoint
- All static files served from /static/ prefix by the backend
- Must degrade gracefully if API is unreachable (show error state, not blank page)
- Router must support deep-linking: loading index.html#doc/path/to/file.md directly renders that doc
- No inline styles or scripts — all CSS in style.css, all JS in app.js (or modular files)
