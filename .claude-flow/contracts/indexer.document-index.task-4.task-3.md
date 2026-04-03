# Contract: indexer.document-index.task-4.task-3

## Inputs
- buildDocumentIndex(filePaths: string[], rootPath: string, parseFrontmatter: Function) => Promise<Map<string, docMetadata>> — the system under test, from src/indexer/build-document-index.js
- readAndParseFile(filePath, rootPath, parseFrontmatter) => Promise<docMetadata> — internal dependency of buildDocumentIndex, must be mocked/stubbed to control per-file success or failure
- docMetadata shape: { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string } — the value type stored in the returned Map
- console.warn — must be spied/mocked to verify warning calls on file failures

## Outputs
- Test suite at tests/indexer/build-document-index.test.js covering 3 scenarios: happy path (all files parse), partial failure (some files throw), total failure (all files throw)
- Verified behavior: Map contains all entries with correct filePath keys on full success
- Verified behavior: Map omits failed files and retains successful ones on partial failure
- Verified behavior: Map is empty (size 0) when all files throw
- Verified behavior: console.warn called once per failed file with filePath and error message
- Verified behavior: original filePath strings (not normalized/resolved) are used as Map keys

## Constraints
- Pure unit tests — no real file I/O; readAndParseFile must be mocked at the module level (jest.mock or vi.mock) to control per-file outcomes
- Zero external dependencies beyond the test runner (Jest/Vitest) and the module under test
- Each test must be independent — no shared mutable state; console.warn spy must be restored after each test
- readAndParseFile mock must be configurable per-file: resolve with docMetadata for success cases, reject with Error for failure cases
- Map key assertion must compare against the exact input filePath string, not a path.resolve'd or normalized variant
- console.warn assertions must verify both the filePath and the error message appear in the warning
- Test file is JavaScript (.js), consistent with the src module language
- All tests must pass with zero failures
