# Contract: indexer.document-index.task-2.task-4

## Inputs
- readAndParseFile(filePath, rootPath, parseFrontmatter) — async function from src/indexer/read-and-parse-file.js
- parseFrontmatter(content: string) => { title: string, tags: string[], date: string, description: string } — injectable mock/stub for testing
- Node.js fs.promises.readFile — mocked to supply controlled file content without disk I/O
- Node.js path module (path.relative, path.dirname) — used by SUT for relativePath/directory computation

## Outputs
- Test suite at tests/indexer/test-read-and-parse-file.js validating docMetadata shape: { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string }
- Coverage of 7 scenarios: (1) full frontmatter → correct docMetadata, (2) empty frontmatter → title='', tags=[], date=null, description='', (3) comma-separated tags string → array, (4) single tag value → array, (5) empty date string → null, (6) Windows backslash paths → forward-slash relativePath, (7) directory equals parent of relativePath

## Constraints
- Pure unit tests — no real file I/O; fs.readFile and parseFrontmatter must be mocked/stubbed
- Zero external dependencies beyond the test runner (Jest/Vitest) and the module under test
- Each test must be independent — no shared mutable state or execution-order dependency
- Tests must run cross-platform: path normalization tests must verify forward slashes regardless of host OS
- parseFrontmatter is injected as a parameter (not imported), so tests pass a stub directly — no module mocking needed for the parser
- All tests must pass with zero failures
- Test file is JavaScript (.js), consistent with the src module language
