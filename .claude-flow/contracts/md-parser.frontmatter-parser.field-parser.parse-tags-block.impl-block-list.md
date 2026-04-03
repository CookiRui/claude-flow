# Contract: md-parser.frontmatter-parser.field-parser.parse-tags-block.impl-block-list

## Inputs
- Raw frontmatter string (text between --- delimiters, without delimiters) passed from parseFrontmatter's delimiter-extraction step
- Frontmatter string may contain 'tags:' key with no inline value, followed by indented '- item' lines (YAML block-list syntax)
- Frontmatter string may alternatively contain inline array 'tags: [a, b]' or single-string 'tags: foo' (existing paths, must not regress)
- Other key:value lines (date, status, unknown keys) interspersed before/after the tags block

## Outputs
- tags field parsed into string[] from block-list '- item' lines (e.g., 'tags:\n  - alpha\n  - beta' → ['alpha', 'beta'])
- Complete metadata object { tags: string[], date: string|null, status: string|null } with tags correctly populated regardless of syntax variant
- parseFrontmatter named export from src/parser.js — signature: parseFrontmatter(content: string) => { tags: string[], date: string|null, status: string|null }
- Default { tags: [], date: null, status: null } for empty, missing, or malformed input (never throws)

## Constraints
- Zero external dependencies — pure string parsing only, no js-yaml or similar (Constitution §3)
- Block-list collection trigger: 'tags:' line with no value after the colon; subsequent indented '- item' lines are collected as tag entries
- Block-list terminates at the next top-level key (line matching /^\S+\s*:/) or end of input
- Must handle indentation variations: 2-space, 4-space, tab, and mixed leading whitespace before '- item'
- Must not break existing inline array [a, b] parsing or single-string 'tags: foo' wrapping
- Whitespace-tolerant around colons, list-item dashes, and tag values (trim all extracted strings)
- Only extracts tags, date, and status fields — all other frontmatter keys are silently ignored
- Function must never throw — return default object for any malformed input
- File location: src/parser.js, exported as named export parseFrontmatter
