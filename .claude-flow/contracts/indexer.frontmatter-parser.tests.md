# Contract: indexer.frontmatter-parser.tests

## Inputs
- A frontmatter parser module/function that accepts a string (file content) and returns a parsed object with fields extracted from YAML frontmatter delimited by `---`
- The parser must handle these fields: name, description, type, and tags (at minimum, based on the memory file format in .claude/projects)
- Tags field accepts multiple formats: YAML list, comma-separated string, single value

## Outputs
- A test suite in tests/frontmatter-parser.test.js that validates parser correctness across all specified scenarios
- Test coverage report confirming: happy path (all fields present), each field missing individually, no frontmatter block, malformed YAML, tags as list/comma-string/single-value
- Edge case coverage: empty file, only delimiters (--- with nothing between), extra --- lines in body

## Constraints
- Test file must be JavaScript (*.test.js), implying a JS test runner (Jest, Vitest, or similar)
- Tests must be pure unit tests — no file I/O, no network; parser receives string input directly
- All tests must pass (zero failures) as stated in acceptance criteria
- No external dependencies beyond the test runner and the parser module under test (constitution §3 spirit: minimal deps)
- Tests must not depend on execution order — each test case must be independent
- Tag parsing tests must cover all three formats: YAML list (`- tag1\n- tag2`), comma-separated string (`tag1, tag2`), and single scalar value (`tag1`)
