---
description: "Analyze the codebase and generate project-level configuration (constitution, rules, CLAUDE.md). Use after installing the claude-flow plugin to set up project-specific files."
argument-hint: [project description] [--lang en]
---

# /init

Analyze the current codebase and generate project-level configuration files. The claude-flow plugin already provides skills, agents, and hooks — this command generates the project-specific files that complement the plugin.

**Language:** All generated file content must be written in **Chinese (中文) by default**. If the user passes `--lang en` as an argument, use English instead.

## What this generates (project-specific files)

- `CLAUDE.md` — project overview and architecture
- `.claude/constitution.md` — project-specific architectural constraints
- `.claude/rules/*.md` — coding style, git workflow, security rules
- `.claudeignore` — files to exclude from AI context
- `REVIEW.md` — code review standards
- `.claude-flow/learnings/INDEX.md` — meta-learning storage for `/claude-flow:deep-task`
- `.github/workflows/ci.yml` — CI/CD (optional, GitHub only)

## What the plugin already provides (DO NOT generate these)

- Skills: tdd, verification, brainstorming, deep-task, bug-fix, feature-plan-creator, autosolve, upgrade
- Agents: feature-builder, code-reviewer, test-writer
- Hooks: protect-files, validate-bash, reinject-context, pre-compact, lint-feedback
- Scripts: persistent-solve.py, repo-map.py, scope-loader.py

---

## Phase 0: Detect Project State

First, determine whether this is an **existing project** or a **new (empty) project**:

- Use Glob to check for source code files (`**/*.{ts,js,py,go,rs,cs,java,jsx,tsx}`)
- Check for manifest files (package.json, go.mod, Cargo.toml, *.csproj, pyproject.toml, etc.)

**If source files found** → go to Phase 1A (Existing Project)
**If no source files found** → go to Phase 1B (New Project)

## Phase 1A: Existing Project — Codebase Analysis (NO file writing)

Scan the project to understand its structure. Use Glob, Grep, Read tools:

1. **Detect project type and tech stack**
   - Check for: package.json, go.mod, Cargo.toml, *.csproj, pyproject.toml, pom.xml, build.gradle, etc.
   - Identify primary language(s), frameworks, and build tools
   - Check for existing test frameworks and linting tools

2. **Map the architecture**
   - Identify top-level directory structure and purpose of each directory
   - Find entry points (main files, route definitions, etc.)
   - Detect patterns: layered architecture, module boundaries, communication patterns
   - Identify shared/common code vs domain-specific code

3. **Identify constraints AI would violate**
   - Check for custom wrappers (logging, HTTP client, error handling) — AI would use stdlib instead
   - Check for architectural patterns (DI, event bus, actor model) — AI would use direct imports
   - Check for performance-sensitive paths — AI would write allocating code
   - Check for enforced tech choices (specific ORM, async library, etc.)

4. **Detect CI/CD and workflow patterns**
   - Check for `.github/workflows/`, `.gitlab-ci.yml`, `Jenkinsfile`, `.gitea/`, etc.
   - Check git branch naming patterns: `git branch -a` to identify conventions
   - Identify protected/generated directories that AI should not touch (build/, dist/, vendor/, etc.)
   - Check for `.env` files or secrets patterns

5. **Check existing configuration**
   - Look for existing CLAUDE.md, .claude/ directory, .claudeignore
   - If configs already exist, ask user whether to overwrite or merge

6. **Present findings and confirm**

   Output a summary via AskUserQuestion:
   ```
   Detected:
   - Language: {detected}
   - Framework: {detected}
   - Architecture: {detected pattern}
   - Test framework: {detected}
   - Linter: {detected}

   Proposed constitution articles:
   §1: {proposed constraint}
   §2: {proposed constraint}
   ...

   Proceed with generation? (Or tell me what to adjust)
   ```

   **Must wait for user confirmation before Phase 2.**

## Phase 1B: New Project — Guided Setup (NO file writing)

Ask the user to describe the project via AskUserQuestion. Gather in 1-2 rounds:

**Round 1 (required):**
```
This looks like a new project. Tell me about it:

1. Language & framework? (e.g., TypeScript + Next.js, Python + FastAPI, Go + Gin, C# + Unity)
2. What does it do? (one sentence)
3. Any specific architecture? (e.g., monorepo, microservices, layered, ECS)
```

**Round 2 (if needed, based on Round 1 answers):**
```
A few more details:
- Test framework preference? (e.g., Jest, pytest, go test)
- Linter preference? (e.g., ESLint, Ruff, golangci-lint)
- Any hard constraints? (e.g., "must use SQLAlchemy not raw SQL", "no class components")
```

Then present a summary for confirmation, same format as Phase 1A step 6 but based on user's answers instead of code scanning.

**Must wait for user confirmation before Phase 2.**

## Phase 2: Generate Configuration Files

Generate all files based on Phase 1 analysis. Every file must contain **concrete, project-specific content** — no placeholders left.

### 2.1 Generate `CLAUDE.md`

Root entry point. Content:
- Project name (from package.json/go.mod/etc. or directory name)
- Architecture overview (actual directory structure — from Phase 1A scan or Phase 1B scaffold)
- @import references to subsystem CLAUDE.md files (if multi-module)

Keep under 30 lines. No generic rules — only project-specific structure.

### 2.2 Generate `.claude/constitution.md`

- **Existing project**: 4-7 articles based on Phase 1A constraint analysis. Each article must have correct/wrong paired code examples **using the project's actual code patterns**.
- **New project**: 2-4 articles based on user's stated constraints and the chosen stack's best practices.

Include the Session State Protocol section and Governance section with enforcement protocol.

### 2.3 Generate `.claude/rules/coding-style.md`

1-3 rules that supplement the constitution with concrete coding details.
Each rule references a constitution article (per Constitution §N).
End with a self-check checklist.

### 2.3b Generate `.claude/rules/git-workflow.md`

Based on Phase 1 analysis of git history and branch conventions:
- **Commit message format**: detect existing pattern from `git log --oneline -20`, or default to `type(scope): description`
- **Branch naming**: detect from `git branch -a`, or default to conventions
- **Atomic commits**: always include this rule
- End with a self-check checklist

### 2.3c Generate `.claude/rules/security.md`

Based on detected project type:
- **No secrets in code**: always include — use env vars
- **Input validation**: include if the project has HTTP endpoints, CLI inputs, or external API calls
- **Dependency safety**: include if the project has a package manager with lockfile
- End with a self-check checklist

### 2.4 Generate `.claudeignore`

Based on detected project type:
- Always include: build artifacts, dependencies, IDE files, logs
- Language-specific: node_modules/, vendor/, bin/, obj/, target/, etc.
- Project-specific: large assets, generated code, etc.

### 2.5 Generate `REVIEW.md`

Generate a project-specific code review standards file:
- **Code Tiers**: Classify project directories into **Production** and **Tooling** tiers
- **Performance**: Rules based on detected performance constraints
- **Maintainability**: Project's naming conventions, module boundaries
- **Correctness & Security**: Project-specific validation rules

### 2.6 Initialize `.claude-flow/learnings/`

Create the learnings directory structure for `/claude-flow:deep-task` meta-learning:
1. Create directory `.claude-flow/learnings/`
2. Create `INDEX.md` with empty index

### 2.7 Generate `.github/workflows/ci.yml` (if applicable)

Only generate if:
- The project does NOT already have CI/CD configuration
- The project is hosted on GitHub (check `git remote -v` for github.com)

## Phase 3: Verification

1. Read back each generated file and verify:
   - No `{placeholder}` text remains in any file
   - Constitution articles reference actual project patterns
   - Code examples are syntactically correct for the project's language
   - .claudeignore covers the project's build artifacts

2. Output a summary:
   ```
   Generated:
   - CLAUDE.md (N lines)
   - .claude/constitution.md (N articles)
   - .claude/rules/coding-style.md (N rules)
   - .claude/rules/git-workflow.md
   - .claude/rules/security.md
   - .claudeignore
   - REVIEW.md
   - .claude-flow/learnings/INDEX.md

   Plugin-provided (already available):
   - Skills: /claude-flow:tdd, /claude-flow:verification, /claude-flow:brainstorming,
     /claude-flow:deep-task, /claude-flow:bug-fix, /claude-flow:feature-plan-creator,
     /claude-flow:autosolve, /claude-flow:upgrade
   - Agents: feature-builder, code-reviewer, test-writer
   - Hooks: protect-files, validate-bash, reinject-context, pre-compact, lint-feedback

   Next steps:
   - Review the generated constitution — adjust if any article is wrong
   - Review REVIEW.md — add project-specific performance/security rules
   - Start using: just describe your task, Claude Code will follow the framework
   - For complex features: /claude-flow:feature-plan-creator <name>
   - For bugs: /claude-flow:bug-fix <description>
   - For complex cross-module tasks: /claude-flow:deep-task <goal>
   ```

## Prohibited Actions

- Do not leave any `{placeholder}` in generated files
- Do not generate generic/boilerplate rules that AI already follows by default
- Do not skip user confirmation in Phase 1
- Do not overwrite existing configuration without user permission
- Do not generate skills, commands, agents, or hooks — the plugin provides these
