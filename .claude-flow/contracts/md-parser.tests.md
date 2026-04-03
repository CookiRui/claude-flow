# Contract: md-parser.tests

## Inputs
- src/parser.js exporting parse(content: string) => { metadata: { tags: string[], date: string|null, status: string|null }, html: string, rawContent: string }
- src/parser.js exporting parseFrontmatter(content: string) => { tags: string[], date: string|null, status: string|null }
- Markdown strings with YAML frontmatter delimited by --- fences at document start
- Edge-case inputs: no frontmatter, empty body after frontmatter, scalar tag value, tags as YAML array, special characters (& < > " ') in markdown body

## Outputs
- src/parser.test.js test suite validating: valid frontmatter extraction produces correct metadata object and HTML
- Test case: missing frontmatter returns defaults { tags: [], date: null, status: null }
- Test case: empty body after frontmatter produces empty html string
- Test case: scalar tag in frontmatter is normalized to single-element string array
- Test case: special characters (& < > etc.) in markdown body render correctly in HTML output

## Constraints
- Zero external dependencies for parser implementation — no js-yaml, gray-matter, or similar; tests may use a standard test runner (jest/vitest)
- tags must always be string[] in output, regardless of input format (missing → [], scalar → [value], array → array)
- Frontmatter recognized only at document start (line 1 must be ---); mid-document --- pairs are body content, not frontmatter
- Missing or malformed frontmatter must not throw — return default empty metadata
- HTML output must faithfully render standard markdown elements including special characters without corruption
- All tests must be runnable via standard test runner and pass independently (no test order dependency)
