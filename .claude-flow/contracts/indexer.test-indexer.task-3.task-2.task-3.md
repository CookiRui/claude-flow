# Contract: indexer.test-indexer.task-3.task-2.task-3

## Inputs
- parseFrontmatter(content: string) => { title: string, tags: string[], date: string, description: string } from src/frontmatter-parser.js
- Test fixtures directory (tests/fixtures/) containing malformed/empty/missing-frontmatter .md files — each fixture file is a distinct test case
- Node.js fs module for reading fixture file contents
- Node.js assert module (assert.doesNotThrow, assert.deepStrictEqual) or equivalent test framework assertions

## Outputs
- One named test case per fixture file in tests/test-indexer.js, each verifying parseFrontmatter does not throw when given that fixture's content
- Deep-equality assertion per fixture confirming result matches safe-default shape { title: '', tags: [], date: '', description: '' }
- Array instance assertion per fixture confirming result.tags is an Array (instanceof Array check)

## Constraints
- Each fixture must have its own individually named test case — no shared/looped anonymous tests
- Must use assert.doesNotThrow (or test-framework equivalent) to explicitly verify non-throwing behavior, not just absence of caught errors
- Deep-equality check must compare against exact object { title: '', tags: [], date: '', description: '' } — no partial matching
- tags field must be verified as an Array instance (instanceof Array or Array.isArray) in addition to deep-equal
- Zero external dependencies beyond the test framework — no js-yaml, gray-matter, etc. (Constitution §3)
- Safe-default shape must match the parseFrontmatter contract: title/date/description are empty strings, tags is empty array — no null values
- Test file path is tests/test-indexer.js — must not create additional test files for this task
