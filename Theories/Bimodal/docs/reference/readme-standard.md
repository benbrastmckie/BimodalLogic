# README Standard for Theories/Bimodal/

This document defines the template and required sections for all README files in the
`Theories/Bimodal/` directory tree.

**Last verified: 2026-05-29**

> **Note**: This README standard was established before task 131 (module reorganization,
> NOT STARTED). After task 131 completes, verify that all READMEs still match the actual
> directory and file structure.

---

## Required Sections

Every README in a Lean-containing directory MUST include:

1. **Title** — Single `# Title` heading matching the directory name
2. **Scope description** — 1-3 sentences describing what this directory contains and its role in the overall library
3. **Module inventory table** — Table listing every `.lean` file and subdirectory:
   - Columns: File/Directory | Lines | Description
   - Generate with `scripts/readme-inventory.sh <dir>`
4. **Key definitions and results** — Bullet list of the most important definitions, theorems, and types
5. **Cross-links** — Navigation footer (see template below)
6. **Last verified date** — `*Last verified: YYYY-MM-DD*` at the bottom

---

## Optional Sections

Include these sections as appropriate:

- **Sorry status** — If files contain sorry, document count and impact
- **Architecture notes** — Dependency diagrams or flowcharts for complex directories
- **Verification commands** — Shell commands to verify documented claims
- **Design notes** — Implementation decisions worth preserving

---

## README Template

```markdown
# DirectoryName

One-sentence summary of purpose.

Optional: 1-2 additional sentences on context or significance.

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Foo.lean` | NNN | Brief description |
| `Bar.lean` | NNN | Brief description |
| `Baz/` | — | Subdirectory: brief description |

## Key Definitions

- `TypeName`: What it represents
- `functionName`: What it computes
- `theoremName`: What it proves

## Dependencies

- **Imports from**: `ParentDir/Foo.lean`, `SiblingDir/`
- **Imported by**: `DependentDir/`

## Related Documentation

- [Parent README](../README.md)
- [Sibling README](../Sibling/README.md)
- [Child README](Child/README.md)

---

*Last verified: YYYY-MM-DD*

> **Note**: This README was last verified before task 131 (module reorg) -- verify
> file list is still current after that task completes.
```

---

## Module Inventory Table

The inventory table must be exhaustive: every `.lean` file and every subdirectory
that contains `.lean` files must appear as a row.

**Generating the table**: Use `scripts/readme-inventory.sh <directory>` to produce a
draft table. Review and annotate the descriptions before committing.

**Line counts**: Use `wc -l` for accurate counts. The `readme-inventory.sh` script
computes these automatically.

**Subdirectory entries**: Use `DirName/` (trailing slash) in the File column.
Use `—` in the Lines column. Describe the subdirectory's purpose in one phrase.

---

## Cross-Link Requirements

Every README must link to:
- Its **parent directory** README (except the root `Theories/Bimodal/README.md`)
- Any **child directory** READMEs (for directories with subdirectories)
- Closely **related sibling** READMEs (as applicable)

**Bidirectional linking**: If README A links to README B, README B must link to README A.

---

## Verification Date

Every README must end with a "Last verified" date:

```markdown
*Last verified: YYYY-MM-DD*
```

Update this date whenever you verify the README matches the current directory contents.
The task 131 note must accompany every "Last verified" line.

---

## File Naming Convention

All `.md` files in `Theories/Bimodal/docs/` must use **lowercase kebab-case**.

### Rule

New documentation files must be named in lowercase kebab-case:
- Words separated by hyphens, all lowercase
- Examples: `axiom-reference.md`, `implementation-status.md`, `proof-patterns.md`, `tactic-development.md`

### Exception

`README.md` is excluded from this rule. The uppercase `README.md` filename is a universal
convention recognized by Git forges (GitHub, GitLab) and documentation tools.

### Rationale

Lowercase kebab-case is the repository-wide convention for documentation files. It avoids
case-sensitivity issues across operating systems and provides consistent, readable filenames.

### Migration Reference

The following files were renamed from SCREAMING_SNAKE_CASE to kebab-case in task 223:

| Old Name | New Name |
|----------|----------|
| `AXIOM_REFERENCE.md` | `axiom-reference.md` |
| `OPERATORS.md` | `operators.md` |
| `TACTIC_REFERENCE.md` | `tactic-reference.md` |
| `ARCHITECTURE.md` | `architecture.md` |
| `EXAMPLES.md` | `examples.md` |
| `PROOF_PATTERNS.md` | `proof-patterns.md` |
| `QUICKSTART.md` | `quickstart.md` |
| `TACTIC_DEVELOPMENT.md` | `tactic-development.md` |
| `TROUBLESHOOTING.md` | `troubleshooting.md` |
| `TUTORIAL.md` | `tutorial.md` |
| `IMPLEMENTATION_STATUS.md` | `implementation-status.md` |
| `KNOWN_LIMITATIONS.md` | `known-limitations.md` |
| `PERFORMANCE_TARGETS.md` | `performance-targets.md` |
| `TACTIC_REGISTRY.md` | `tactic-registry.md` |
| `TEST_COVERAGE.md` | `test-coverage.md` |

---

## Lint Compliance

A README passes the lint check (`scripts/readme-lint.sh`) when:

1. All `.lean` files in the directory appear in the module inventory table
2. All subdirectories containing `.lean` files appear in the table
3. No broken relative links (file references that do not exist on disk)
4. "Last verified" date is present
5. Required sections (title, scope, inventory, cross-links) are present
