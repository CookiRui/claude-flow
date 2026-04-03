# Contract: task-2.apply-fixes

## Inputs
- kanban.json file conforming to schema: {goal, start_time, updated_at, summary: {total, done, failed, running, pending, total_cost_usd}, tree: [{id, description, status, complexity, cost_usd, commit_hash, children[]}]}
- Audit report identifying specific CSS/JS issues across all 7 features (summary bar, progress bar, tree rendering, collapse/expand, drag-and-drop/file-browse, auto-refresh, theme toggle, filter, keyboard shortcuts)
- Acceptance criteria for each of the 7 features that must pass simultaneously

## Outputs
- Single self-contained HTML file (scripts/kanban-viewer.html) with all CSS and JS inline, no external dependencies
- validateKanban(data) function preserving current schema contract: requires object with 'summary' (object) and 'tree' (array) fields
- All 7 features functional without CSS/JS conflicts: (1) summary bar with stats + progress bar, (2) collapsible tree with chevron rotation, (3) drag-drop and click-to-browse file loading, (4) auto-refresh with 3s interval and dot indicator, (5) dark/light theme toggle with localStorage persistence, (6) filter input matching id/description with ancestor expansion, (7) keyboard shortcuts (R/E/C/F/T/Esc) suppressed in input fields

## Constraints
- Single-file HTML: all CSS in <style>, all JS in <script>, zero external dependencies (no CDN links, no imports)
- CSS changes must not break cross-feature interactions — e.g., filter-hidden vs collapsed classes, theme variables must apply to all components uniformly
- JS changes must preserve existing event listener architecture — no duplicate listeners, no broken references after re-render (filter re-application in render())
- validateKanban() signature and validation logic must remain backward-compatible: accepts {summary: object, tree: array}, throws Error on invalid input
- Theme CSS variables (--bg-*, --text-*, --status-*, --border-color) must be defined for both [data-theme='dark'] and [data-theme='light'] with no missing tokens
- All fixes applied in a single edit pass — no intermediate broken states between individual fixes
- DOM id references in JS must match HTML element ids exactly (error-banner, progress-bar, tree-container, filter-input, etc.)
