# Contract: md-indexer

## Inputs
- Root directory path to knowledge-base containing 1600+ .md files
- Each .md file may contain optional YAML frontmatter delimited by '---' with fields: tags (list[str]), date (str/date), status (str)
- Each .md file body may contain wikilinks in [[target]] or [[target|alias]] format

## Outputs
- file_list: list[str] — all .md file paths relative to root
- tag_list: dict[str, list[str]] — tag -> list of file paths that carry that tag
- directory_tree: nested dict representing the folder hierarchy of .md files
- link_map: dict[str, list[str]] — file -> list of outgoing wikilink targets (forward links)
- backlink_map: dict[str, list[str]] — file -> list of files that link to it (reverse links)
- metadata: dict[str, dict] — file -> parsed frontmatter (tags, date, status)

## Constraints
- Python standard library only (no PyYAML, no third-party packages) — YAML frontmatter must be parsed manually
- In-memory index only; no database or persistent cache
- Must handle 1600+ files without excessive memory or time; single-pass scan preferred
- Wikilink parsing must support both [[target]] and [[target|alias]] forms
- Frontmatter parsing must tolerate missing/malformed frontmatter gracefully (skip, don't crash)
- All paths in index must be relative to the knowledge-base root and use forward slashes
- Unit tests must cover: file discovery, tag extraction, directory tree structure, forward links, backlinks, and edge cases (no frontmatter, empty files, broken links)
