# Contract: indexer.document-index.task-2.task-1

## Inputs
- filePath: string — absolute path to a .md file on disk
- rootPath: string — absolute path to the document root directory, used to compute relativePath
- parseFrontmatter(content: string) => { title: string, tags: string[], date: string, description: string } — injected frontmatter parser function
- fs.promises.readFile — Node.js built-in for async file reading
- path.relative, path.dirname — Node.js built-in for path computation

## Outputs
- docMetadata: { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string } — title defaults to '', description defaults to '', tags defaults to [], date defaults to null when empty/missing, relativePath uses forward slashes, directory is path.dirname(relativePath)

## Constraints
- Zero external dependencies — only Node.js stdlib (fs, path) and the injected parseFrontmatter
- Must be async — reads file via fs.promises.readFile with utf-8 encoding
- parseFrontmatter is injected as a parameter, not imported — enables testing and decoupling
- relativePath must use forward slashes regardless of OS (replace backslashes after path.relative)
- directory is derived from relativePath via path.dirname, not from the absolute filePath
- Empty or missing date from parseFrontmatter must be converted to null
- Missing title/description default to empty string, missing tags default to empty array
- File I/O errors may propagate — caller is responsible for skip-and-continue logic
- File location: src/indexer/read-and-parse-file.js — single module, single named export
