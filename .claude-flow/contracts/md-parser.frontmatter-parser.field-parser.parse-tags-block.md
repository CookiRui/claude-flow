# Contract: md-parser.frontmatter-parser.field-parser.parse-tags-block

## Inputs
- Raw frontmatter string containing key:value lines, where tags field uses YAML block-list syntax ('- item' per line with leading indentation)
- Upstream parseFrontmatter extracts the text between --- delimiters and passes it to field parsing logic

## Outputs
- tags field parsed from block-list '- item' lines into a string[] (e.g., ['alpha', 'beta'])
- Complete metadata object { tags: string[], date: string|null, status: string|null } with tags correctly populated from block-list syntax
- Existing inline array [a, b] and single-string tag parsing continues to work unchanged

## Constraints
- Zero external dependencies — pure string parsing only, no js-yaml or similar (Constitution §3)
- Must handle indentation variations: 2-space, 4-space, tab, and mixed leading whitespace before '- item'
- Block-list items belong to the nearest preceding key (tags:) — lines starting with '- ' after 'tags:' with no value on the same line are collected until the next top-level key or end of input
- Must not break existing parsing of inline array syntax [a, b] or single-string tags values
- Must never throw — return default { tags: [], date: null, status: null } for malformed input
- Function is a named export (parseFrontmatter) from src/parser.js
- Only extracts tags, date, and status fields — all other frontmatter keys are ignored
