# Contract: indexer.test-indexer.task-3

## Inputs
- parseFrontmatter(content: string) => FrontmatterData — must handle malformed YAML without throwing, returning {title: '', tags: [], date: '', description: ''}
- buildDocumentIndex(filePaths: string[], rootPath: string, parseFrontmatter: Function) => Promise<Map<string, DocMetadata>> — per-file try/catch that calls console.warn on error and continues
- DocMetadata type: {title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string}
- Test fixtures: .md files with malformed frontmatter (unclosed delimiters, invalid YAML, binary garbage, missing fields)
- console.warn global — spyable for assertion

## Outputs
- Test suite in tests/test-indexer.js verifying: malformed frontmatter produces DocMetadata with empty string title, empty tags array, null date, empty description
- Test assertion: console.warn is called at least once per malformed file (with filePath and error message in args)
- Test assertion: no exception propagates from parseFrontmatter or buildDocumentIndex on malformed input
- Test assertion: one bad file does not abort the index build — remaining valid files still appear in the resulting Map

## Constraints
- Zero external dependencies beyond test framework (Jest or Vitest) — no js-yaml, gray-matter, etc.
- console.warn spy must be restored after each test to ensure test isolation
- Tests must not depend on shared mutable state — each test sets up its own fixtures and spies
- Malformed frontmatter variants must include: unclosed --- delimiters, non-YAML content between delimiters, completely empty frontmatter, fields with wrong types (e.g. tags as number)
- Date field: empty string from parser must map to null in DocMetadata
- All file paths in fixtures and assertions use forward slashes (cross-platform)
- Sequential async processing in buildDocumentIndex — tests must exercise the continuation-after-error path with multiple files where at least one is malformed
