# Contract: indexer.document-index.task-5.task-4

## Inputs
- parseFrontmatter(content: string) => { title: string, tags: string | string[] | undefined, date: string, description: string } — frontmatter parser that may return tags in any of: comma-separated string, single scalar string, proper string[], or undefined/missing
- normalizeTags(raw: string | string[] | undefined) => string[] — the function under test that converts raw frontmatter tags into a canonical flat string array
- Test framework (vitest or jest) with describe/it/expect available

## Outputs
- Test suite 'tags normalization variants' with four passing sub-cases that validate the normalizeTags contract
- Sub-case 1: comma-separated string (e.g. 'a,b,c') splits into ['a','b','c'] — asserts Array.isArray(result) === true and typeof element === 'string' for each
- Sub-case 2: single scalar string (e.g. 'solo') wraps to ['solo'] — asserts Array.isArray(result) === true, length === 1, typeof result[0] === 'string'
- Sub-case 3: proper array (['x','y']) passes through unchanged as string[] — asserts Array.isArray(result) === true and typeof element === 'string' for each
- Sub-case 4: missing/undefined input becomes [] — asserts Array.isArray(result) === true and result.length === 0

## Constraints
- Every assertion must check Array.isArray(result) === true to guarantee array type
- Every assertion must check typeof element === 'string' on each element to guarantee homogeneous string[]
- Zero external dependencies beyond the test runner — no yaml parsers, no fs access; tests operate on in-memory values only
- Tests must not depend on execution order — each sub-case is self-contained with its own input/expected pair
- Comma-separated string splitting must trim whitespace (e.g. 'a, b , c' → ['a','b','c'])
- Tests target the normalization logic within document-index, not the frontmatter parser itself
- File location must be tests/indexer/document-index.test.ts as specified by the task
