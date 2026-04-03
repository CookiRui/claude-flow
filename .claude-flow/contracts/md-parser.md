# Contract: md-parser

## Inputs
- File path (string) or raw markdown string containing YAML frontmatter delimited by --- fences
- Markdown files (.md) accessible via filesystem with structure: YAML frontmatter (tags, date, status fields) followed by markdown body

## Outputs
- Object { metadata: { tags: string[], date: string, status: string, [key: string]: any }, html: string, rawContent: string }
- metadata.tags: array of strings extracted from YAML frontmatter 'tags' field
- html: markdown body (everything after closing --- of frontmatter) converted to HTML string
- rawContent: original unprocessed markdown body as a string

## Constraints
- YAML frontmatter must be delimited by --- at the start of the file; files without valid frontmatter should return empty/default metadata
- Must handle edge cases: missing frontmatter, empty tags, missing fields (date/status default to null)
- tags must always be returned as an array, even if frontmatter specifies a single value or omits it (default to [])
- HTML conversion must sanitize or faithfully render standard markdown (headings, lists, code blocks, links, images)
- Module exports a synchronous or async parse function from src/parser.js
- Tests in src/parser.test.js must cover: valid frontmatter extraction, missing frontmatter, empty body, tags as array and scalar, special characters in markdown body
