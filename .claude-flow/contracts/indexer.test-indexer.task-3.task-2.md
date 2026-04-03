# Contract: indexer.test-indexer.task-3.task-2

## Inputs
- parseFrontmatter function exported from the indexer module, accepting a string and returning a parsed frontmatter object
- Set of malformed fixture strings (e.g., missing delimiters, empty body, invalid YAML, partial fields, binary garbage, unclosed delimiters)

## Outputs
- Test suite in tests/test-indexer.js with one test per malformed fixture asserting: (1) parseFrontmatter does not throw, (2) return value deep-equals {title:'', tags:[], date:'', description:''}

## Constraints
- Each malformed fixture must have its own dedicated test case (not a shared loop-only assertion)
- Tests must assert non-throwing behavior explicitly (e.g., assert.doesNotThrow or try/catch with fail)
- Expected safe default is exactly {title:'', tags:[], date:'', description:''} — no extra keys, no nulls, no undefined
- tags must be an empty Array instance, not null or undefined
- Tests must not modify or monkey-patch parseFrontmatter; test the real implementation
- No external test dependencies beyond Node.js built-in assert/test runner (per §3 zero-external-deps spirit)
