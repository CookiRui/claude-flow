# Contract: indexer.test-indexer.task-2.task-2

## Inputs
- buildDocumentIndex(filePaths: string[], rootPath: string, parseFrontmatter: Function) => Promise<Map<string, DocMetadata>> — the function under test
- tests/fixtures/ directory containing both valid .md files with parseable frontmatter AND at least one malformed/unparseable .md file
- parseFrontmatter(content: string) => { title, tags, date, description } — injected dependency that returns defaults or throws on malformed input
- Known count of valid (parseable) .md fixture files, determined by inspecting fixtures at test time

## Outputs
- Test assertion: documentIndex.size === count of valid/parseable .md fixture files (strictly less than total .md files when malformed fixtures exist)
- Verified behavior: malformed/unreadable .md files are silently excluded from the returned Map (no throw, no entry)

## Constraints
- Malformed frontmatter files must be silently excluded — no throw, Map.size < total fixture file count
- Test must programmatically determine expected valid count (e.g., by enumerating fixtures and subtracting known-malformed ones), not hardcode a magic number
- File I/O or parse errors on individual files must not abort the entire index build — skip and continue
- Zero external test dependencies beyond the project's chosen test framework (Jest/Vitest)
- Tests must not depend on filesystem ordering — use Map.size for count, not array index
- Forward-slash paths required in all Map keys and metadata on all platforms including Windows
