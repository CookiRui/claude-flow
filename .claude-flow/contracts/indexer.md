# Contract: indexer

## Inputs
- Root directory path to knowledge-base (string, absolute or relative)
- Markdown parser capable of extracting YAML frontmatter (title, tags, date, description) from .md files
- File system access (recursive directory traversal, file read)

## Outputs
- Document index: Map<filePath, { title, tags[], date, description, relativePath, directory }> for all 1596 .md files
- Tag-to-docs map: Map<tag, filePath[]> — reverse index from each tag to the documents containing it
- Directory tree: nested object representing the folder hierarchy { name, path, children[], docs[] }
- Index metadata: { totalDocs, totalTags, buildTimeMs, rootPath }

## Constraints
- Must complete full index build in under 5 seconds for 1596 files
- In-memory only — no database or persistent cache required
- Recursive scan must handle arbitrary directory depth
- Frontmatter parsing must tolerate missing/malformed YAML without crashing (skip or use defaults)
- Single entry point: src/indexer.js
- Must handle non-.md files gracefully (ignore them)
- Tag map must be case-normalized to avoid duplicate keys (e.g., 'JavaScript' vs 'javascript')
- Directory tree must reflect actual filesystem structure, not flattened paths
