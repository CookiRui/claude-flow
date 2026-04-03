# Contract: indexer.document-index.task-4

## Inputs
- filePaths: string[] — list of .md file paths discovered by upstream scanner
- rootPath: string — absolute path to the document root directory
- parseFrontmatter(content: string) => { title: string, tags: string[], date: string, description: string } — injected frontmatter parser function
- readAndParseFile(filePath, rootPath, parseFrontmatter) => Promise<docMetadata> — async per-file parser from src/indexer/read-and-parse-file.js that reads a single file and returns { title, tags, date, relativePath, directory, description }

## Outputs
- Map<string, docMetadata> — keys are the original filePath strings from the input array, values are { title: string, tags: string[], date: string|null, description: string, relativePath: string, directory: string }
- The Map contains only successfully parsed files; files that threw I/O errors are omitted
- The returned Map is complete — all filePaths have been attempted before the Promise resolves

## Constraints
- Must iterate every element of filePaths — no early abort on error
- I/O errors from readAndParseFile on individual files must be caught per-file (try/catch inside the loop), logged as a warning via console.warn, and skipped — the loop continues with remaining files
- Map key must be the original filePath string as provided in the input array, not a normalized or resolved variant
- Function is async and returns Promise<Map<string, docMetadata>>
- Zero external dependencies — Node.js stdlib only, plus the injected readAndParseFile and parseFrontmatter
- Files are processed sequentially (await inside for-loop) to avoid file descriptor exhaustion on large sets
- Warning log for skipped files must include the filePath and the error message for debuggability
