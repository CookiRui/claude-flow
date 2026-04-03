# Contract: indexer.document-index

## Inputs
- rootPath: string — absolute path to the document root directory
- filePaths: string[] — list of .md file paths discovered by upstream scanner
- frontmatter parser: function that extracts YAML frontmatter fields (title, tags, date, description) from a .md file's content

## Outputs
- Map<filePath, docMetadata> where docMetadata = { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string }
- Each entry keyed by absolute or canonical filePath
- relativePath computed relative to rootPath, directory derived from relativePath's parent

## Constraints
- Zero external dependencies — Node.js standard library + custom frontmatter parser only
- Must handle files with missing or partial frontmatter gracefully (default empty tags[], null date, empty string for missing title/description)
- File I/O errors on individual files must not abort the entire index — skip and continue with remaining files
- Map key must be the original filePath as provided in the input array for consistent downstream lookup
- buildDocumentIndex must be async (files read from disk) and return Promise<Map>
- tags must always be normalized to a flat string array even if frontmatter provides a comma-separated string or single value
