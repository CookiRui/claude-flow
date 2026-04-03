# Contract: indexer.test-indexer

## Inputs
- buildDocumentIndex(filePaths: string[], rootPath: string, parseFrontmatter: Function) => Promise<Map<string, DocMetadata>>
- buildDirectoryTree(rootPath: string, mdFilePaths: string[]) => DirectoryTree
- parseFrontmatter(content: string) => FrontmatterData { title, tags, date, description }
- Top-level indexer entry point returning { documentIndex, tagMap, directoryTree, metadata }
- Test fixture directory at tests/fixtures/ containing: valid .md files with full frontmatter, files with missing fields, malformed frontmatter files, empty directories, nested subdirectory structure, ~1596 files for performance benchmark

## Outputs
- Test suite (tests/test-indexer.js) validating correct document count from full fixture scan
- Tests verifying tag normalization (case-folding, comma-split, block-list, single scalar)
- Tests verifying DirectoryTree structure matches fixture directory layout (children, docs, pruned empty dirs)
- Tests verifying graceful handling of malformed frontmatter (no throw, defaults returned, console.warn logged)
- Tests verifying missing fields produce safe defaults (empty string/empty array/null)
- Tests verifying empty directories are pruned from tree output
- Tests verifying Map keys are original file paths with forward-slash relative paths
- Performance test asserting full index build completes under 5 seconds for 1596 files
- Test fixtures (tests/fixtures/) as reusable reference data for downstream integration tests

## Constraints
- Zero external dependencies — test framework (Jest/Vitest) is the only non-stdlib import
- All relative paths in assertions must use forward slashes regardless of OS
- Tag normalization must be case-insensitive (e.g., 'JavaScript' → 'javascript' in tagMap keys)
- Malformed frontmatter must never throw — parser returns defaults and indexer skips gracefully with console.warn
- Performance benchmark: full build of 1596-file fixture must complete in < 5000ms
- DocMetadata shape: { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string }
- DirectoryTree shape: { name: string, path: string, children: DirectoryTree[], docs: Array<{name, path}> }
- Document index Map key is the original input filePath string, not normalized
- Empty directories must not appear in DirectoryTree output (pruned)
- File I/O errors must be caught per-file — one bad file must not abort the entire index build
