#!/usr/bin/env python3
"""
Markdown Indexer Engine

Scans a knowledge base directory for .md files, parses YAML frontmatter
(date/tags/status), and builds an in-memory index with directory tree structure.

Usage:
    from indexer import KnowledgeIndex
    idx = KnowledgeIndex("/path/to/knowledge-base")
    idx.build()
    docs = idx.documents        # list of doc dicts
    tree = idx.directory_tree   # nested dict representing folder structure
"""

import os
import re
import time
from pathlib import Path

# Regex to extract YAML frontmatter between --- delimiters
_FRONTMATTER_RE = re.compile(r"\A---\s*\n(.*?\n)---\s*\n", re.DOTALL)

# Simple YAML-like parsers for the fields we care about
_DATE_RE = re.compile(r"^date:\s*(.+)$", re.MULTILINE)
_STATUS_RE = re.compile(r"^status:\s*(.+)$", re.MULTILINE)
_TAGS_RE = re.compile(r"^tags:\s*\[([^\]]*)\]", re.MULTILINE)

# First markdown heading as fallback title
_HEADING_RE = re.compile(r"^#\s+(.+)$", re.MULTILINE)


def _parse_frontmatter(content):
    """Parse YAML frontmatter from markdown content without external deps.

    Returns dict with keys: date, tags, status (all may be None).
    """
    result = {"date": None, "tags": [], "status": None}

    m = _FRONTMATTER_RE.match(content)
    if not m:
        return result

    fm = m.group(1)

    date_m = _DATE_RE.search(fm)
    if date_m:
        result["date"] = date_m.group(1).strip().strip("'\"")

    status_m = _STATUS_RE.search(fm)
    if status_m:
        result["status"] = status_m.group(1).strip().strip("'\"")

    tags_m = _TAGS_RE.search(fm)
    if tags_m:
        raw = tags_m.group(1)
        result["tags"] = [
            t.strip().strip("'\"") for t in raw.split(",") if t.strip()
        ]

    return result


def _extract_title(content, filename):
    """Extract title from first heading, falling back to filename."""
    m = _HEADING_RE.search(content)
    if m:
        return m.group(1).strip()
    return Path(filename).stem


def _extract_wikilinks(content):
    """Extract [[wikilink]] targets from content."""
    return re.findall(r"\[\[([^\]]+)\]\]", content)


class KnowledgeIndex:
    """In-memory index of a markdown knowledge base."""

    def __init__(self, root_dir):
        self.root_dir = Path(root_dir).resolve()
        self.documents = []         # list of doc dicts
        self.directory_tree = {}    # nested dict: name -> children / __docs__
        self.tag_index = {}         # tag -> [doc_indices]
        self.path_map = {}          # relative_path -> doc index
        self.wikilink_map = {}      # title_lower -> doc index
        self._build_time = None

    def build(self):
        """Scan the knowledge base and build all indices."""
        start = time.perf_counter()

        self.documents.clear()
        self.directory_tree.clear()
        self.tag_index.clear()
        self.path_map.clear()
        self.wikilink_map.clear()

        for dirpath, _dirnames, filenames in os.walk(self.root_dir):
            # Skip hidden directories and common non-content dirs
            rel_dir = Path(dirpath).relative_to(self.root_dir)
            parts = rel_dir.parts
            if any(p.startswith(".") for p in parts):
                continue
            if any(p in ("node_modules", "__pycache__") for p in parts):
                continue

            for fname in filenames:
                if not fname.endswith(".md"):
                    continue

                full_path = Path(dirpath) / fname
                rel_path = full_path.relative_to(self.root_dir)
                rel_str = rel_path.as_posix()

                try:
                    content = full_path.read_text(encoding="utf-8", errors="replace")
                except OSError:
                    continue

                fm = _parse_frontmatter(content)
                title = _extract_title(content, fname)
                wikilinks = _extract_wikilinks(content)

                doc = {
                    "path": rel_str,
                    "title": title,
                    "tags": fm["tags"],
                    "date": fm["date"],
                    "status": fm["status"],
                    "wikilinks": wikilinks,
                }

                idx = len(self.documents)
                self.documents.append(doc)
                self.path_map[rel_str] = idx
                self.wikilink_map[title.lower()] = idx

                # Build tag index
                for tag in fm["tags"]:
                    self.tag_index.setdefault(tag, []).append(idx)

                # Insert into directory tree
                self._insert_tree(rel_str, idx)

        self._build_time = time.perf_counter() - start

    def _insert_tree(self, rel_path, doc_idx):
        """Insert a document into the directory tree structure."""
        parts = rel_path.split("/")
        node = self.directory_tree

        # Navigate/create directory nodes
        for part in parts[:-1]:
            if part not in node:
                node[part] = {"__docs__": []}
            node = node[part]

        # Add document to leaf directory
        if "__docs__" not in node:
            node["__docs__"] = []
        node["__docs__"].append(doc_idx)

    def get_tree_json(self):
        """Return directory tree as a JSON-serializable structure.

        Returns a list of nodes: {name, type, children, doc_index}
        """
        return self._tree_to_list(self.directory_tree)

    def _tree_to_list(self, node):
        """Convert nested dict tree to a list of node dicts."""
        result = []

        # Collect directories first (sorted), then documents
        dirs = []
        docs = node.get("__docs__", [])

        for key, value in sorted(node.items()):
            if key == "__docs__":
                continue
            dirs.append({
                "name": key,
                "type": "directory",
                "children": self._tree_to_list(value),
            })

        # Add document entries
        doc_entries = []
        for di in docs:
            doc = self.documents[di]
            doc_entries.append({
                "name": Path(doc["path"]).name,
                "type": "file",
                "doc_index": di,
                "title": doc["title"],
            })

        return dirs + sorted(doc_entries, key=lambda x: x["name"])

    def search(self, query):
        """Simple full-text search across titles and paths.

        Returns list of doc indices matching the query.
        """
        query_lower = query.lower()
        results = []
        for i, doc in enumerate(self.documents):
            if (query_lower in doc["title"].lower()
                    or query_lower in doc["path"].lower()):
                results.append(i)
        return results

    def get_backlinks(self, doc_index):
        """Find documents that link to the given document via wikilinks."""
        target_doc = self.documents[doc_index]
        target_title_lower = target_doc["title"].lower()
        target_path_stem = Path(target_doc["path"]).stem.lower()

        backlinks = []
        for i, doc in enumerate(self.documents):
            if i == doc_index:
                continue
            for link in doc.get("wikilinks", []):
                link_lower = link.lower()
                if link_lower == target_title_lower or link_lower == target_path_stem:
                    backlinks.append(i)
                    break
        return backlinks

    def stats(self):
        """Return index statistics."""
        return {
            "total_documents": len(self.documents),
            "total_tags": len(self.tag_index),
            "build_time_seconds": round(self._build_time, 3) if self._build_time else None,
        }


if __name__ == "__main__":
    import sys
    import json

    if len(sys.argv) < 2:
        print("Usage: python indexer.py <knowledge-base-path>", file=sys.stderr)
        sys.exit(1)

    kb_path = sys.argv[1]
    if not os.path.isdir(kb_path):
        print(f"Error: {kb_path} is not a valid directory", file=sys.stderr)
        sys.exit(1)

    idx = KnowledgeIndex(kb_path)
    idx.build()

    s = idx.stats()
    print(f"Indexed {s['total_documents']} documents, "
          f"{s['total_tags']} unique tags in {s['build_time_seconds']}s")

    # Show top tags
    top_tags = sorted(idx.tag_index.items(), key=lambda x: -len(x[1]))[:15]
    print("\nTop tags:")
    for tag, doc_ids in top_tags:
        print(f"  {tag}: {len(doc_ids)} docs")

    # Show sample documents with frontmatter
    with_fm = [d for d in idx.documents if d["date"] or d["tags"]]
    print(f"\nDocuments with frontmatter: {len(with_fm)}/{s['total_documents']}")
