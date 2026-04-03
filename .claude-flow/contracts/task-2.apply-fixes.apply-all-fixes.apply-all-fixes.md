# Contract: task-2.apply-fixes.apply-all-fixes.apply-all-fixes

## Inputs
- scripts/kanban-viewer.html current source (single-file HTML with embedded CSS and JS)
- CSS: duplicate `.drop-zone` selectors at lines 110-119 (properties block) and line 121 (`cursor: pointer` only) that must be merged
- CSS: dark theme tokens (lines 8-26, 14 custom properties) and light theme tokens (lines 28-45, 14 custom properties) to verify parity
- CSS: `.tree-node.filter-hidden` rule (line 319) and `.node-children.collapsed` rule (line 232) to confirm non-conflict
- JS: all `document.getElementById()` call-sites (ids: error-banner, total, done, running, pending, failed, cost, progress-bar, progress-bar-container, drop-zone, tree-controls, tree-container, goal-bar, goal-text, filter-input, refresh-dot, auto-refresh, theme-toggle, file-input, expand-all, collapse-all, shortcuts-help)
- HTML: all `id=` attributes on DOM elements to cross-reference against JS getElementById calls

## Outputs
- scripts/kanban-viewer.html with exactly one `.drop-zone` CSS rule block (merged, including `cursor: pointer`)
- Both `:root/[data-theme='dark']` and `[data-theme='light']` define identical sets of 14 CSS custom property names
- Confirmed: `filter-hidden` applies `display:none` on `.tree-node` elements, `collapsed` applies `display:none` on `.node-children` elements — different targets, no conflict
- Confirmed: every `getElementById(id)` in JS has a matching `id=` attribute in HTML, and no orphan ids exist
- validateKanban function (lines 439-450) byte-identical to original — zero modifications

## Constraints
- Single atomic edit pass — all CSS/JS fixes applied together, no intermediate broken states
- validateKanban function must remain completely unchanged (structure, logic, and formatting)
- Merge duplicate `.drop-zone` into the first/original block (lines 110-119), delete the second occurrence (line 121)
- Theme token parity: if any token is added/removed from one theme, it must be mirrored in the other
- filter-hidden must only target `.tree-node`, collapsed must only target `.node-children` — these selectors must never be swapped or merged
- No new DOM ids may be introduced; no existing ids may be renamed or removed
- File remains a single self-contained HTML file with no external dependencies
- Constitution §4: commit and push after verified edit
