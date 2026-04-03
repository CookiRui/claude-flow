# Contract: indexer.directory-tree-builder.impl-tree-build

## Inputs
- Grouped path map: Record<string, DocEntry[]> where keys are directory paths (e.g. 'docs/api/auth') and values are arrays of document entries belonging to that directory
- DocEntry interface: { relativePath: string, frontmatter: object, [other metadata fields] } — individual document records produced by upstream indexing/parsing
- Root path or base directory string to serve as the tree root

## Outputs
- buildDirectoryTree(groupedMap): DirectoryTree — function that accepts the grouped path map and returns a nested tree
- DirectoryTree type: { name: string, path: string, children: DirectoryTree[], docs: DocEntry[] } — recursive node representing a directory with its subdirectories and contained documents

## Constraints
- Intermediate directory nodes must be created automatically even if they contain no direct documents (e.g. if docs exist at 'a/b/c', nodes for 'a' and 'a/b' must exist in the tree)
- children[] contains only DirectoryTree nodes (subdirectories); docs[] contains only DocEntry leaf items — no mixing
- Tree construction must handle arbitrary nesting depth without hardcoded level limits
- Path separator handling must be consistent (use '/' as canonical separator)
- Duplicate intermediate nodes must not be created — each unique directory path maps to exactly one DirectoryTree node
- Zero external dependencies — pure JS using only Node.js standard library (per Constitution §3)
- Implementation lives in src/directory-tree.js as a single exported function
