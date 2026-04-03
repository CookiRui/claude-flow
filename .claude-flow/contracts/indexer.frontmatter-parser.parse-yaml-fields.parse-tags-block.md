# Contract: indexer.frontmatter-parser.parse-yaml-fields.parse-tags-block

## Inputs
- Raw frontmatter string (content between --- delimiters, without the delimiters themselves) containing YAML-like key: value lines
- String may contain block-style tags with '- item' lines after a 'tags:' key with no inline value
- String may contain inline comma-separated tags (e.g. 'tags: foo, bar, baz')
- String may contain other fields: title, date, description as simple 'key: value' pairs

## Outputs
- parseYamlFields(raw: string) => { title: string, tags: string[], date: string, description: string }
- tags field returns string[] from block-style YAML ('tags:\n- a\n- b') => ['a', 'b']
- tags field returns string[] from inline comma-separated ('tags: a, b, c') => ['a', 'b', 'c']
- All fields default to empty values ('' for strings, [] for tags) when missing from input
- Exported as named function parseYamlFields from src/frontmatter-parser.js

## Constraints
- No external YAML library dependencies (js-yaml, yaml, gray-matter, etc.) — hand-rolled parser only per Constitution §3
- Must be a pure function: no side effects, no file I/O, no thrown exceptions
- Block-list '- item' lines belong to the nearest preceding 'tags:' key — collected until the next top-level key or end of input
- Must handle indentation variations (2-space, 4-space, tab, mixed whitespace) before '- item' in block-list syntax
- Must not break existing single-value tag parsing or YAML inline array syntax [a, b]
- Gracefully return default object { title: '', tags: [], date: '', description: '' } on malformed or empty input
- Each tag value must be whitespace-trimmed in both block and inline formats
