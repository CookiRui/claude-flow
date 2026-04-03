# Contract: indexer.frontmatter-parser.parse-yaml-fields

## Inputs
- Raw frontmatter string (content between --- delimiters, without the delimiters themselves)
- String contains YAML-like key: value lines for title, tags, date, and description fields

## Outputs
- Object with four fields: { title: string, tags: string[], date: string, description: string }
- All fields default to empty values ('' for strings, [] for tags) when missing from input
- tags field supports both YAML array syntax ('- item' lines) and comma-separated inline syntax

## Constraints
- Hand-rolled parser only — no YAML library dependencies (js-yaml, yaml, etc.)
- Must handle simple 'key: value' single-line pairs
- Must handle multi-line YAML array tags (lines starting with '- ')
- Must handle comma-separated inline tags (e.g. 'tags: foo, bar, baz')
- Must be a pure function: no side effects, no file I/O
- Exported as named function parseYamlFields from src/frontmatter-parser.js
- Gracefully handle malformed or empty input without throwing
