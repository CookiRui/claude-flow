# Contract: md-parser.frontmatter-parser.field-parser

## Inputs
- Raw frontmatter string (text between --- delimiters, without the delimiters themselves)
- String containing key: value lines, potentially including YAML array syntax (e.g., tags: [a, b] or tags:\n  - a\n  - b)

## Outputs
- Object { tags: string[], date: string|null, status: string|null }
- tags normalized to string[] from either single-string, inline array [a, b], or block list (- a) syntax
- Default { tags: [], date: null, status: null } for empty, missing, or unparseable input

## Constraints
- Zero external dependencies — no js-yaml or similar; pure string parsing only
- Must handle both YAML array syntaxes: inline [a, b, c] and block list (- a per line)
- Must handle single-string tags value (e.g., tags: foo) by wrapping in array
- Must be tolerant of whitespace variations around colons and list items
- Only extracts tags, date, and status fields — ignores all other frontmatter keys
- Returns default object (never throws) for any malformed or empty input
- File location: src/parser.js
