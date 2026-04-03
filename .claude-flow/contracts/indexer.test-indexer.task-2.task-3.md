# Contract: indexer.test-indexer.task-2.task-3

## Inputs
- Indexer module/function that accepts file paths and returns a Map keyed by those paths
- Set of valid input filePath strings using forward slashes (e.g. 'src/foo.md', 'docs/bar.md')
- Existing test patterns in tests/test-indexer.test.ts for setup/import conventions

## Outputs
- Test case asserting Map.has(filePath) returns true for each original input filePath
- Test case asserting Map keys use forward slashes and are identity-equal (===) to the original input strings
- Test case asserting no path normalization (no backslash conversion, no trailing slash removal, no ./ prefix stripping) is applied to keys

## Constraints
- Keys must be checked with Map.has() using the exact original filePath string — no re-encoding or normalization before lookup
- Forward slashes only — backslash paths must not appear as Map keys
- Identity equality (===) between input filePath and the corresponding Map key, not just structural equality
- Test must live in tests/test-indexer.test.ts alongside existing indexer tests
- No external dependencies beyond what the test file already imports (Constitution §3: zero external deps)
