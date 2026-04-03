# Contract: indexer.frontmatter-parser.parse-yaml-fields.parse-tags-block.parse-block-list

## Inputs
- Raw frontmatter string (content between --- delimiters, without the delimiters) containing YAML-like 'key: value' lines
- String may contain block-style tags with variable indentation ('tags:\n  - a\n  - b' or 'tags:\n    - a\n\t- b')
- String may contain inline comma-separated tags ('tags: foo, bar, baz') or YAML inline arrays ('tags: [a, b]')
- String may contain other simple fields: title, date, description as 'key: value' pairs

## Outputs
- parseYamlFields(raw: string) => { title: string, tags: string[], date: string, description: string }
- Block-style tags parsed into string[]: 'tags:\n  - a\n  - b' => ['a', 'b']
- Each tag value is whitespace-trimmed in both block and inline formats
- All fields default to empty values ('' for strings, [] for tags) when missing or malformed
- Exported as named function parseYamlFields from src/frontmatter-parser.js

## Constraints
- No external YAML library dependencies (js-yaml, yaml, gray-matter) — hand-rolled parser only per Constitution §3
- Must be a pure function: no side effects, no file I/O, no thrown exceptions
- Block-list '- item' lines belong to the nearest preceding 'tags:' key — collected until the next top-level key (non-indented line with ':') or end of input
- Must handle 2-space, 4-space, tab, and mixed indentation before '- ' in block-list syntax
- Must not break existing inline tag parsing (comma-separated or YAML inline array [a, b])
- Gracefully return default object { title: '', tags: [], date: '', description: '' } on malformed or empty input
- A 'tags:' line with no inline value signals block-list mode; a 'tags: value' line signals inline mode
