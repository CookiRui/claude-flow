---
name: init-unity
description: "Analyze Unity project and generate project-specific configuration. Detects editor path, namespaces, scenes, assemblies, and fills all project-level placeholders."
argument-hint: [--force]
---

# /init-unity

Scan the current Unity project, auto-detect configuration values, and generate project-level files. Run this after installing the claude-flow and claude-flow-unity plugins.

---

## Phase 0: Locate Unity Project

1. Check current directory for `Assets/` + `ProjectSettings/`
2. If not found, scan first-level subdirectories
   - 1 match → auto-select
   - Multiple → AskUserQuestion
   - None → error exit
3. Read `ProjectSettings/ProjectSettings.asset` for `productName` and `companyName`
4. Determine repo root via `git rev-parse --show-toplevel`

---

## Phase 1: Auto-Detect (no file writes)

### 1.1 Unity Editor Path
- Read `Library/EditorInstance.json` if Unity is running
- Read `ProjectSettings/ProjectVersion.txt` for version, search common install paths
- Windows: `C:/Program Files/Unity/Hub/Editor/{version}/Editor/Unity.exe`
- macOS: `/Applications/Unity/Hub/Editor/{version}/Unity.app/Contents/MacOS/Unity`

### 1.2 Namespaces and Assemblies
- Search `Assets/**/*.asmdef`, read `name` fields
- Infer root namespace from asmdef names or `namespace` declarations in `.cs` files
- Identify test assembly, core assembly, autotest assembly

### 1.3 Scene Paths
- Search `Assets/**/*.unity`
- Classify by name: Main/Game → default scene, Test/Sandbox → test scene

### 1.4 Test Case Path
- Search `Assets/**/AutoTest/` or `Assets/**/TestCases/`
- Default: `Assets/Tests/AutoTest/Cases`

### 1.5 Batch Mode Entry Classes
- Grep for `UnityOpsRunner`, `BatchPlayModeRunner`, `BatchCompile`
- Use template values if unity-runtime/ exists

### 1.6 Build/Test/Lint Commands
- Assemble from detected values
- Detect `.editorconfig` or `dotnet format` for lint

### 1.7 Git Info
- Detect base branch from `git branch -a`
- Detect remote type (GitHub/Gitea/GitLab)

---

## Phase 2: User Confirmation

Present detected values via AskUserQuestion. **Must wait for confirmation.**

---

## Phase 3: Generate Project Files

Generate project-level configuration:

### Constitution (.claude/constitution.md)
Unity-specific articles:
- §1: All input through IInputProvider, never UnityEngine.Input directly
- §2: No allocations in Update/FixedUpdate/LateUpdate hot paths
- §3: .meta files must always be committed alongside their assets
- §4: Assembly definitions enforce dependency boundaries

### Rules (.claude/rules/)
- `unity-scripts.md` — C# naming, component patterns, performance
- `unity-assets.md` — .meta rules, asset organization, LFS

### Hook Configuration (.claude-flow/protected-files.json)
- Hard-protected: `ProjectSettings/`
- Soft-protected: `Library/`, `Temp/`, `Logs/`

### REVIEW.md
Unity-specific review dimensions:
- Performance: GC.Alloc in hot paths, uncached GetComponent, LINQ in Update
- Assets: .meta integrity, LFS tracking, scene/prefab corruption

### Batch Mode Scripts
Copy and configure `.claude/scripts/unity-*.sh` with detected values.

---

## Phase 4: Verification

1. Grep all modified files for remaining `{placeholder}` patterns
2. Verify shell script paths point to real files
3. Output summary with detected values and ready-to-use commands

---

## Prohibited Actions

- Do not leave any `{placeholder}` in generated files
- Do not modify user's existing C# code
- Do not skip user confirmation
