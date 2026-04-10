# claude-flow-unity

Unity game development preset for [claude-flow](https://github.com/CookiRui/claude-flow). Adds Unity-specific agents, AutoTest framework skill, .meta validation hooks, and batch mode scripts.

## Installation

```bash
# Requires the core plugin first
/plugin install claude-flow@claude-flow

# Install Unity preset
/plugin install claude-flow-unity@claude-flow

# Initialize Unity project config
/claude-flow-unity:init-unity
```

## What's Included

### Skills (2)

| Skill | Description |
|-------|-------------|
| `/claude-flow-unity:init-unity` | Auto-detect Unity editor, namespaces, scenes, assemblies and generate project config |
| `/claude-flow-unity:autotest` | AutoTest framework: IInputProvider pattern, TestCase JSON, batch mode execution |

### Agents (2)

| Agent | Description |
|-------|-------------|
| `unity-dev` | Unity C# developer: gameplay systems, component patterns, performance constraints, batch mode CLI |
| `git-ops` | Git specialist: .meta validation, Unity YAML merge, LFS operations, atomic commits |

### Hooks (1)

| Hook | Event | Purpose |
|------|-------|---------|
| `validate-meta-staged.sh` | PreToolUse (Bash) | Block git commit if .meta files are missing from staging area |

### Batch Mode Scripts (bin/)

| Script | Purpose |
|--------|---------|
| `unity-env.sh` | Unity environment setup |
| `unity-compile.sh` | C# compilation check |
| `unity-editmode-test.sh` | NUnit EditMode test runner |
| `unity-game-test.sh` | PlayMode / AutoTest runner |
| `unity-ops.sh` | Scene/Prefab/Material batch operations |
| `unity-check-editor.sh` | Unity editor version validation |
| `unity-parse-compile-log.sh` | Compile log analyzer |
| `unity-parse-test-results.py` | Test result parser (JUnit XML) |
| `gitea-api.sh` | Gitea API integration |

## Setup

After installing, run `/claude-flow-unity:init-unity` in your Unity project directory. It will:
1. Auto-detect Unity editor path, version, namespaces, scenes, assemblies
2. Generate Unity-specific constitution and rules
3. Configure batch mode scripts with detected paths
4. Set up protected paths (ProjectSettings/, Library/)

## Links

- [GitHub](https://github.com/CookiRui/claude-flow)
- [Unity Preset Documentation](https://github.com/CookiRui/claude-flow/tree/master/presets/unity)
