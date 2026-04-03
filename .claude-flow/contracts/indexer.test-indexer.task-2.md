# Contract: indexer.test-indexer.task-2

## Inputs
- buildDocumentIndex(filePaths: string[], rootPath: string, parseFrontmatter: Function) => Promise<Map<string, DocMetadata>> — the function under test
- tests/fixtures/ — directory of .md files with valid/parseable frontmatter and at least one malformed/unparseable file
- DocMetadata shape: { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string }
- parseFrontmatter(content: string) => { title, tags, date, description } — injected dependency

## Outputs
- Test: documentIndex.size equals count of valid+parseable .md fixture files (malformed/unreadable files excluded from Map)
- Test: every Map key is the exact original filePath string from the input array, using forward slashes
- Test: every DocMetadata.relativePath uses forward slashes (no backslashes), is relative to rootPath
- Test: every DocMetadata.directory uses forward slashes, equals path.dirname(relativePath) with forward slashes

## Constraints
- Map keys must be identity-equal to input filePaths — no path.resolve() or normalization
- Forward-slash paths required on all platforms including Windows (backslash → forward-slash conversion)
- Unparseable or unreadable .md files must be silently excluded from the Map (no throw), so size < total fixture files when malformed fixtures exist
- Zero external test dependencies beyond Node.js built-in test runner or the project's chosen framework (Jest/Vitest)
- Tests must not depend on filesystem ordering — assert via Map.has() / Set equality, not array index
