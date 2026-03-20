# Security Rules

> Supplements the constitution with details it can't cover. If derivable from the constitution, delete it.

## Rule 1: No secrets in code (per Constitution §{N})

Never hardcode API keys, passwords, tokens, or any credentials directly in source code. Always load secrets from environment variables or a secrets manager.

```{language}
// ✅ Correct
const apiKey = process.env.API_KEY;

// ❌ Wrong
const apiKey = "sk-abc123hardcodedtoken";
```

**Exceptions:** {exception-scenarios — e.g., non-sensitive public configuration values such as public base URLs may be inlined if they carry no security risk}

## Rule 2: Input validation at boundaries (per Constitution §{N})

Validate all user input and external API responses at system boundaries before processing. Apply allowlists over blocklists where possible. {project-specific-validation-rules — e.g., required fields, type constraints, length limits for this project}

```{language}
// ✅ Correct
{correct-validation-example}

// ❌ Wrong
{wrong-validation-example — e.g., passing raw user input directly to a database query or shell command}
```

**Exceptions:** {exception-scenarios — e.g., internal service-to-service calls within a trusted network boundary may relax validation requirements per {project-trust-policy}}

## Rule 3: Dependency safety (per Constitution §{N})

Only use approved dependencies. Do not introduce packages that are abandoned, have known critical CVEs, or are outside the project's allowed list. {dependency-policy — e.g., allowed package registries, forbidden packages, and the process for requesting a new dependency}

```text
// ✅ Correct
{allowed-package-example}

// ❌ Wrong
{forbidden-package-example}
```

**Exceptions:** {exception-scenarios — e.g., temporary use of a flagged package is permitted only with explicit approval documented in {approval-doc-location}}

## Self-check Checklist

- [ ] Are there any hardcoded secrets, tokens, or passwords in the changed files?
- [ ] Is all user input and external data validated at entry points before use?
- [ ] Do all new dependencies appear on the project's approved dependency list?
