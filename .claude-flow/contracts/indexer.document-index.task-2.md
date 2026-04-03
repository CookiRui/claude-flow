# Contract: indexer.document-index.task-2

## Inputs
- filePath: string — absolute path to a single .md file on disk
- rootPath: string — absolute path to the document root directory, used to compute relativePath
- parseFrontmatter(content: string) => { title: string, tags: string[], date: string, description: string } — frontmatter parser that extracts YAML fields from raw markdown content

## Outputs
- docMetadata: { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string } — title defaults to empty string if missing, description defaults to empty string if missing, tags defaults to empty array if missing, date defaults to null if missing, relativePath is filePath relative to rootPath, directory is the parent directory of relativePath

## Constraints
- Zero external dependencies — Node.js standard library (fs, path) + custom frontmatter parser only
- Must handle files with missing or partial frontmatter gracefully: empty string for missing title/description, empty array for missing tags, null for missing date
- File I/O errors on individual files must not throw — caller (buildDocumentIndex) handles skip-and-continue, but this function may propagate errors for the caller to catch
- relativePath must use forward slashes (path.relative + normalize) for cross-platform consistency
- directory is derived from relativePath's parent via path.dirname, not from the absolute path
- Function must be async (reads file from disk via fs.promises.readFile)
- tags must be normalized to a flat string array even if frontmatter provides a comma-separated string or single value
- date field from frontmatter parser is string; this function converts missing/empty date to null
