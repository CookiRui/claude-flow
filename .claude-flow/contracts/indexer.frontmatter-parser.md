# Contract: indexer.frontmatter-parser

## Inputs
- Raw markdown file content as a string (may or may not contain YAML frontmatter delimited by --- markers)

## Outputs
- parseFrontmatter(content: string) => { title: string, tags: string[], date: string, description: string } — always returns this shape with defaults (empty string / empty array) for missing fields

## Constraints
- Never throws on malformed YAML — returns default object on any parse failure
- No external dependencies — must use only Node.js built-ins or hand-rolled parsing (no js-yaml, gray-matter, etc.) per Constitution §3 zero-external-deps spirit
- Frontmatter block is defined as content between the first line '---' and the next '---'; anything outside is ignored
- tags field must always be an array even if source YAML has a single value or comma-separated string
- date field is returned as-is (string), no Date object coercion
- File: src/frontmatter-parser.js — single module, single named export parseFrontmatter
