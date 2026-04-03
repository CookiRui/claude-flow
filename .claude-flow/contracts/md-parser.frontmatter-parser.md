# Contract: md-parser.frontmatter-parser

## Inputs
- Raw markdown string content that may or may not contain YAML frontmatter delimited by --- fences at the start of the document
- Frontmatter fields: tags (string or array), date (string), status (string) — all optional within the YAML block

## Outputs
- parseFrontmatter(content: string) => { tags: string[], date: string|null, status: string|null }
- Default empty metadata object { tags: [], date: null, status: null } when frontmatter is missing or malformed
- Remaining markdown body content after frontmatter extraction (if needed by downstream consumers)

## Constraints
- Zero external dependencies — no js-yaml or gray-matter; parse the subset (tags, date, status) manually from the --- delimited block
- tags field must always be normalized to an array, even if the source YAML provides a single string value
- Frontmatter must only be recognized at the very start of the document (leading --- on line 1), not arbitrary --- pairs mid-document
- Malformed YAML or missing closing --- fence must not throw — return default empty metadata instead
- Function must be a named export (parseFrontmatter) from src/parser.js for downstream import
