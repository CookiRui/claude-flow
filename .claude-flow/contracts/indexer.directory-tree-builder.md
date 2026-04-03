# Contract: indexer.directory-tree-builder

## Inputs
- rootPath: string — absolute filesystem path to the root directory of the tree
- mdFilePaths: string[] — list of markdown file paths (absolute or relative to rootPath) discovered by upstream indexer/glob

## Outputs
- DirectoryTree: { name: string, path: string, children: DirectoryTree[], docs: Array<{ name: string, path: string }> } — recursive tree object where children[] contains subdirectory nodes and docs[] contains markdown files in that directory
- buildDirectoryTree(rootPath, mdFilePaths) — single named export function returning the DirectoryTree root node

## Constraints
- Tree structure must mirror actual filesystem hierarchy — no flattening or virtual grouping
- Each node's path must be relative to rootPath using forward slashes (portable across OS)
- Files appear only in docs[] of their direct parent directory node, not duplicated in ancestors
- Empty intermediate directories (no docs, no children with docs) should be pruned from the tree
- Pure function — no filesystem I/O; operates solely on the provided mdFilePaths list
- Zero external dependencies — Node.js built-in path module only
- File: src/directory-tree.js — single module, single named export
