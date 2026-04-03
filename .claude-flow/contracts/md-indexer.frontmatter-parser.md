# Contract: md-indexer.frontmatter-parser

## Inputs
- Raw markdown text (str) that may or may not contain YAML frontmatter delimited by --- lines

## Outputs
- parse_frontmatter(text: str) -> dict with keys 'tags' (list[str]), 'date' (str), 'status' (str); missing fields omitted from dict
- Returns empty dict ({}) for missing, malformed, or unparseable frontmatter

## Constraints
- stdlib-only: no PyYAML, no third-party imports (Constitution §3)
- Never raises exceptions on any input — all errors caught and return {}
- Frontmatter block defined as content between first line '---' and next '---'
- tags field parsed as YAML-style list (bracket notation [a, b] or dash-prefixed lines)
- date and status parsed as plain string values
- File location: scripts/md_indexer/md_indexer.py
- Python script must follow unified entry structure (coding-style Rule 2)
