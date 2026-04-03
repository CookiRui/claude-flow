#!/usr/bin/env python3
"""
Scope Loader — Load module-scoped constitution and rules based on affected files.

Usage:
    python scripts/scope-loader.py                                    # Auto-detect from git diff
    python scripts/scope-loader.py --files "net/client.py,ui/app.py"  # Specify files
    python scripts/scope-loader.py --module networking                 # Specify module
    python scripts/scope-loader.py --format json                      # JSON output
    python scripts/scope-loader.py --format inject                    # stdout injection (default)

How it works:
    1. Determines affected files (from --files, --module, or git diff)
    2. Maps files to modules using .repo-map/config.json
    3. Finds module-level .claude/constitution.md and .claude/rules/*.md
    4. Outputs resolution order: root -> module (additive, not replacing)

Module rules directory convention:
    project/
    ├── .claude/constitution.md              # Root (always loaded)
    ├── .claude/rules/*.md                   # Root rules
    ├── networking/.claude/constitution.md   # Module-specific
    └── networking/.claude/rules/*.md        # Module-specific rules
"""

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

# ============================================================
# Module Detection (shared with repo-map.py, kept standalone)
# ============================================================

REPO_MAP_DIR = ".repo-map"
CONFIG_FILE = os.path.join(REPO_MAP_DIR, "config.json")

IGNORE_DIRS = {
    "node_modules", ".git", "__pycache__", ".next", "dist", "build",
    "bin", "obj", "target", ".venv", "venv", "vendor", "Packages",
    "Library", "Temp", "Logs", "UserSettings", ".repo-map",
}

NON_MODULE_DIRS = {
    "docs", "doc", "tests", "test", "bin", "obj", "dist", "build",
    "scripts", "tools", "config", "configs", ".github", ".gitea",
    ".claude", ".claude-flow", "node_modules", "__pycache__",
}

LANGUAGE_EXTS = {".py", ".ts", ".tsx", ".js", ".jsx", ".cs", ".java", ".go", ".rs"}


def load_config(root):
    """Load .repo-map/config.json or return defaults."""
    config_path = os.path.join(root, CONFIG_FILE)
    if os.path.isfile(config_path):
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                return json.load(f)
        except (json.JSONDecodeError, OSError):
            pass
    return {"modules": {}, "exclude_dirs": [], "auto_detect": True}


def detect_modules(root, config):
    """Detect modules from top-level directories and config."""
    modules = []
    seen_names = set()

    for name, info in config.get("modules", {}).items():
        paths = info.get("paths", [name + "/"])
        desc = info.get("description", "")
        modules.append({"name": name, "paths": paths, "description": desc})
        seen_names.add(name)

    if config.get("auto_detect", True):
        exclude = set(config.get("exclude_dirs", []))
        try:
            entries = sorted(os.listdir(root))
        except OSError:
            entries = []

        for entry in entries:
            if entry in seen_names or entry.startswith("."):
                continue
            if entry.lower() in NON_MODULE_DIRS or entry in IGNORE_DIRS or entry in exclude:
                continue
            full_path = os.path.join(root, entry)
            if not os.path.isdir(full_path):
                continue
            has_source = False
            for dirpath, dirnames, filenames in os.walk(full_path):
                dirnames[:] = [d for d in dirnames if d not in IGNORE_DIRS and not d.startswith(".")]
                for fn in filenames:
                    if Path(fn).suffix in LANGUAGE_EXTS:
                        has_source = True
                        break
                if has_source:
                    break
            if has_source:
                modules.append({"name": entry, "paths": [entry + "/"], "description": ""})

    modules.append({"name": "_root", "paths": [""], "description": "Root-level & utility files"})
    return modules


def classify_file_to_module(filepath, modules):
    """Given a relative file path, return which module it belongs to."""
    fp = filepath.replace("\\", "/")

    for mod in modules:
        if mod["name"] == "_root":
            continue
        for mod_path in mod["paths"]:
            mod_path = mod_path.replace("\\", "/")
            if mod_path and (fp.startswith(mod_path) or fp.startswith(mod_path.rstrip("/"))):
                return mod["name"]

    return "_root"


# ============================================================
# Affected Files Detection
# ============================================================

def get_affected_files_from_git(root):
    """Get affected files from git diff (staged + unstaged + untracked)."""
    changed = set()
    commands = [
        ["git", "diff", "--name-only", "HEAD"],
        ["git", "diff", "--name-only"],
        ["git", "diff", "--staged", "--name-only"],
        ["git", "ls-files", "--others", "--exclude-standard"],
    ]

    for cmd in commands:
        try:
            result = subprocess.run(
                cmd, capture_output=True, text=True, cwd=root, timeout=10
            )
            if result.returncode == 0:
                for line in result.stdout.strip().splitlines():
                    line = line.strip()
                    if line:
                        changed.add(line.replace("\\", "/"))
        except (subprocess.TimeoutExpired, FileNotFoundError):
            continue

    return list(changed)


def get_affected_modules(files, root):
    """Map files to module names."""
    config = load_config(root)
    modules = detect_modules(root, config)

    affected = set()
    for f in files:
        mod_name = classify_file_to_module(f, modules)
        if mod_name != "_unclassified":
            affected.add(mod_name)

    return sorted(affected)


# ============================================================
# Rule Resolution
# ============================================================

def find_root_constitutions(root):
    """Find root-level constitution."""
    result = []
    path = os.path.join(root, ".claude", "constitution.md")
    if os.path.isfile(path):
        result.append({"scope": "root", "path": ".claude/constitution.md"})
    return result


def find_root_rules(root):
    """Find root-level rules."""
    result = []
    rules_dir = os.path.join(root, ".claude", "rules")
    if os.path.isdir(rules_dir):
        for fn in sorted(os.listdir(rules_dir)):
            if fn.endswith(".md"):
                result.append({"scope": "root", "path": ".claude/rules/" + fn})
    return result


def find_module_constitutions(module_names, root):
    """Find constitution.md files for each module."""
    result = []
    for mod_name in module_names:
        if mod_name == "_root":
            continue
        path = os.path.join(root, mod_name, ".claude", "constitution.md")
        if os.path.isfile(path):
            result.append({
                "scope": mod_name,
                "path": mod_name + "/.claude/constitution.md",
            })
    return result


def find_module_rules(module_names, root):
    """Find rules/*.md files for each module."""
    result = []
    for mod_name in module_names:
        if mod_name == "_root":
            continue
        rules_dir = os.path.join(root, mod_name, ".claude", "rules")
        if os.path.isdir(rules_dir):
            for fn in sorted(os.listdir(rules_dir)):
                if fn.endswith(".md"):
                    result.append({
                        "scope": mod_name,
                        "path": mod_name + "/.claude/rules/" + fn,
                    })
    return result


def resolve_all(root, module_names):
    """Full resolution: root + module constitutions and rules."""
    constitutions = find_root_constitutions(root) + find_module_constitutions(module_names, root)
    rules = find_root_rules(root) + find_module_rules(module_names, root)

    code_maps = {}
    l0_path = os.path.join(root, REPO_MAP_DIR, "L0.md")
    if os.path.isfile(l0_path):
        code_maps["L0"] = REPO_MAP_DIR + "/L0.md"

    l1_paths = []
    for mod_name in module_names:
        l1_path = os.path.join(root, REPO_MAP_DIR, "modules", mod_name + ".md")
        if os.path.isfile(l1_path):
            l1_paths.append(REPO_MAP_DIR + "/modules/" + mod_name + ".md")
    if l1_paths:
        code_maps["L1"] = l1_paths

    return {
        "affected_modules": module_names,
        "constitutions": constitutions,
        "rules": rules,
        "code_maps": code_maps,
    }


# ============================================================
# Output Formatters
# ============================================================

def format_inject(resolution, root):
    """Format for stdout injection into hooks."""
    lines = []

    if resolution["affected_modules"]:
        lines.append("# Affected modules: " + ", ".join(resolution["affected_modules"]))
        lines.append("# Module rules are additive to root rules (they extend, not replace)")
        lines.append("")

    for item in resolution["constitutions"]:
        full_path = os.path.join(root, item["path"])
        if os.path.isfile(full_path):
            scope_label = "root" if item["scope"] == "root" else "module:" + item["scope"]
            lines.append("--- [" + scope_label + " constitution: " + item["path"] + "] ---")
            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    lines.append(f.read().rstrip())
            except OSError:
                lines.append("[error reading " + item["path"] + "]")
            lines.append("")

    for item in resolution["rules"]:
        full_path = os.path.join(root, item["path"])
        if os.path.isfile(full_path):
            scope_label = "root" if item["scope"] == "root" else "module:" + item["scope"]
            lines.append("--- [" + scope_label + " rule: " + item["path"] + "] ---")
            try:
                with open(full_path, "r", encoding="utf-8") as f:
                    lines.append(f.read().rstrip())
            except OSError:
                lines.append("[error reading " + item["path"] + "]")
            lines.append("")

    return "\n".join(lines)


def format_json_output(resolution):
    """Format as JSON."""
    return json.dumps(resolution, indent=2, ensure_ascii=False)


# ============================================================
# CLI
# ============================================================

def main():
    parser = argparse.ArgumentParser(
        description="Scope Loader — Load module-scoped constitution and rules"
    )
    parser.add_argument("root", nargs="?", default=".",
                        help="Project root directory")
    parser.add_argument("--files",
                        help="Comma-separated list of affected files")
    parser.add_argument("--module",
                        help="Explicitly specify module name(s), comma-separated")
    parser.add_argument("--format", choices=["inject", "json"], default="inject",
                        help="Output format (default: inject)")

    args = parser.parse_args()
    root = os.path.abspath(args.root)

    # Force utf-8 on Windows
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    # Determine affected modules
    if args.module:
        module_names = [m.strip() for m in args.module.split(",") if m.strip()]
    elif args.files:
        files = [f.strip() for f in args.files.split(",") if f.strip()]
        module_names = get_affected_modules(files, root)
    else:
        files = get_affected_files_from_git(root)
        if not files:
            print("No affected files detected.", file=sys.stderr)
            sys.exit(0)
        module_names = get_affected_modules(files, root)

    if not module_names:
        print("No modules affected.", file=sys.stderr)
        sys.exit(0)

    # Resolve
    resolution = resolve_all(root, module_names)

    # Output
    if args.format == "json":
        print(format_json_output(resolution))
    else:
        output = format_inject(resolution, root)
        if output.strip():
            print(output)
        else:
            print("# No module-scoped rules found.", file=sys.stderr)


if __name__ == "__main__":
    main()
