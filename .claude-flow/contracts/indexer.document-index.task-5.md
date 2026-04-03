# Contract: indexer.document-index.task-5

## Inputs
- DocMetadata interface: { title: string, tags: string[], date: string | null, description: string, relativePath: string, directory: string }
- FrontmatterData interface: { title: string, tags: string[], date: string, description: string }
- parseFrontmatter(content: string) => FrontmatterData — injected dependency for YAML extraction
- buildDocumentIndex(filePaths: string[], rootPath: string, parseFrontmatter: Function) => Promise<Map<string, DocMetadata>>
- readAndParseFile(filePath: string, rootPath: string, parseFrontmatter: Function) => Promise<DocMetadata>
- Node.js fs.promises.readFile for file I/O (mocked in tests)
- Node.js path module for relativePath/directory computation

## Outputs
- Unit test suite: tests/indexer/document-index.test.ts covering 6 acceptance scenarios
- Test: full frontmatter file produces correct DocMetadata with all fields populated
- Test: missing frontmatter file returns defaults (empty string title/description, empty array tags, null date)
- Test: tags normalization — comma-string, single scalar, array, and missing all produce string[]
- Test: unreadable file (I/O error) is skipped without throwing, Map omits it, console.warn called
- Test: relativePath uses forward slashes relative to rootPath; directory is path.dirname(relativePath)
- Test: Map key is the original input filePath string, not a normalized/resolved variant

## Constraints
- No external dependencies beyond test runner (vitest/jest) — mirrors Constitution §3 zero-dependency rule
- Mock readAndParseFile or fs.promises.readFile at module level; do not perform real file I/O
- Spy on console.warn to verify warning logs for skipped files include filePath and error message
- Tests must be independent — no shared mutable state or execution-order dependency
- parseFrontmatter is injected (not imported), so tests supply stub/mock implementations directly
- All tag normalization tests must assert result is string[] (Array.isArray + element type check)
- relativePath must use forward slashes even on Windows (path.relative + separator normalization)
- Date field: empty string from parser must convert to null in DocMetadata
- Map keys must be asserted with exact original filePath strings passed to buildDocumentIndex
