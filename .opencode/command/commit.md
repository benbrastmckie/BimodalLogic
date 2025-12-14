---
description: Smart commit helper for Logos LEAN 4 proof system with build validation and conventional commits
---

# Commit Command

You are an AI agent that helps create well-formatted git commits for the **Logos LEAN 4 proof system project**. This command handles the complete commit workflow including validation, testing, and pushing changes.

## Instructions for Agent

When the user runs this command, execute the following workflow:

### 1. Pre-Commit Validation

Run these checks in parallel:
```bash
lake build                # Verify project builds
lake test                 # Run test suite
git status --porcelain
git diff --cached
```

**Validation Rules:**
- `lake build` must succeed (no compilation errors)
- `lake test` failures → ask user if they want to proceed
- Check for uncommitted changes
- Warn if committing with `sorry` placeholders (optional check)

### 2. Analyze Changes

- Run `git status` to see all untracked files
- Run `git diff` to see both staged and unstaged changes
- Run `git log --oneline -10` to see recent commit style
- Identify the scope of changes (core, semantics, theorems, tests, docs, automation, archive, opencode)
- Detect change type (new feature, bug fix, refactor, proof completion, documentation)
- Check for sensitive information (none expected, but good practice)

### 3. Stage Files Intelligently

**Auto-stage based on change type:**
- Core logic changes → stage `Logos/Core/**/*.lean`
- Semantics changes → stage `Logos/Core/Semantics/**/*.lean`
- Theorem additions → stage `Logos/Core/Theorems/**/*.lean`
- Test changes → stage `LogosTest/**/*.lean`
- Documentation → stage `Documentation/**/*.md`
- Archive examples → stage `Archive/**/*.lean`
- OpenCode agents → stage `.opencode/agent/**/*.md`
- Build config → stage `lakefile.toml`, `lean-toolchain`
- CI/CD → stage `.github/workflows/*.yml`
- If user provides specific files → stage only those

**Never auto-stage:**
- `.lake/` (build artifacts)
- `*.olean` (compiled LEAN files)
- `.DS_Store`, `*.swp`, `*~` (editor artifacts)
- `.env*` files (if any)

### 4. Generate Commit Message

**Follow Conventional Commits (plain text only, no emojis):**
```
<type>(<scope>): <description>

[optional body]
```

**Types for this repo:**
- `feat` - New features (axioms, theorems, tactics, operators)
- `fix` - Bug fixes (proof errors, soundness issues)
- `proof` - Proof completions (removing `sorry`, completing theorems)
- `refactor` - Code restructuring (proof simplification, module reorganization)
- `test` - Test additions or modifications
- `docs` - Documentation updates
- `chore` - Maintenance (dependencies, cleanup, file organization)
- `ci` - CI/CD pipeline changes
- `perf` - Performance improvements (proof search, tactic efficiency)

**Scopes for this repo:**
- `core` - Core proof system (`Logos/Core/ProofSystem/`)
- `syntax` - Formula syntax (`Logos/Core/Syntax/`)
- `semantics` - Task semantics (`Logos/Core/Semantics/`)
- `metalogic` - Soundness/completeness (`Logos/Core/Metalogic/`)
- `theorems` - Key theorems (`Logos/Core/Theorems/`)
- `automation` - Tactics and proof search (`Logos/Core/Automation/`)
- `tests` - Test suite (`LogosTest/`)
- `archive` - Pedagogical examples (`Archive/`)
- `docs` - Documentation (`Documentation/`)
- `opencode` - AI agent system (`.opencode/`)
- `build` - Build configuration (`lakefile.toml`)
- `ci` - GitHub Actions

**Examples:**
```
feat(theorems): add perpetuity principle P6 with full proof
proof(metalogic): complete soundness proof for modal_5_collapse axiom
fix(semantics): correct task frame nullity condition
refactor(automation): simplify modal_k_tactic implementation
test(theorems): add test cases for perpetuity principles P1-P6
docs(architecture): update TM logic specification
chore(core): reorganize Theorems module structure
ci: add lake lint to GitHub Actions workflow
```

### 5. Commit Analysis

<commit_analysis>
- List all files that have been changed or added
- Summarize the nature of changes (new theorem, proof completion, refactor, etc.)
- Identify the primary scope (core, semantics, theorems, tests, docs, etc.)
- Determine the purpose/motivation behind changes
- Assess impact on the overall project (soundness, completeness, API changes)
- Check for `sorry` placeholders (warn if adding new ones)
- Check for sensitive information (API keys, tokens, etc.)
- Draft a concise commit message focusing on "why" not "what"
- Ensure message follows conventional commit format
- Verify message is specific and not generic
</commit_analysis>

**Special checks for LEAN 4:**
- Adding new `sorry`? → Mention in commit body
- Removing `sorry`? → Highlight in message (`proof: complete X`)
- Changing axioms? → Requires careful review
- Modifying soundness proofs? → High-impact change

### 6. Execute Commit

```bash
git add <relevant-files>
git commit -m "<type>(<scope>): <description>"
git status  # Verify commit succeeded
```

### 7. Post-Commit Actions

**Ask user:**
```
Commit created: <commit-hash>
Message: <commit-message>

Would you like to:
1. Push to remote (git push origin main)
2. Create another commit
3. Done
```

**If user chooses push:**
```bash
git push origin main
```

**Then inform:**
```
Pushed to remote!

This will trigger:
- GitHub Actions CI/CD workflow
- lake build (verify compilation)
- lake test (run test suite)
- lake lint (check code quality)
```

## Repository-Specific Rules

### Build Validation

**Before committing:**
- `lake build` must succeed (compilation errors block commit)
- `lake test` should pass (failures warn but don't block)
- `lake lint` warnings are informational only

### Files to Check

**LEAN-specific checks:**
- `lakefile.toml` - Build configuration
- `lean-toolchain` - LEAN version pinning
- `lake-manifest.json` - Dependency lock file (auto-generated, usually don't commit manually)

### Pre-Commit Hooks

**This repo may have pre-commit hooks that:**
- Run `lake lint`
- Format LEAN code (if configured)
- Check for `sorry` placeholders

**If hooks modify files:**
- Inform user that files were auto-formatted
- Ask if they want to amend the commit

## Error Handling

### If Build Fails

```
WARNING: lake build failed

Errors:
<build-output>

Options:
1. Fix build errors and retry
2. View full build log
3. Cancel commit

What would you like to do?
```

### If Tests Fail

```
WARNING: lake test failed

Failures:
<test-output>

Options:
1. Fix test failures and retry
2. Proceed anyway (not recommended for main branch)
3. Cancel commit

What would you like to do?
```

### If No Changes Detected

```
INFO: No changes to commit. Working tree is clean.

Recent commits:
<git log --oneline -5>

Would you like to:
1. Check git status
2. View recent commits
3. Exit
```

### If Merge Conflicts

```
WARNING: Merge conflicts detected. Please resolve conflicts first.

Conflicted files:
<list-files>

Run: git status
```

### If Adding New `sorry`

```
WARNING: This commit adds new 'sorry' placeholders

Files with new sorry:
<list-files-with-sorry>

This increases technical debt. Consider:
1. Complete the proof before committing
2. Add a TODO comment explaining the sorry
3. Proceed anyway (will be tracked in SORRY_REGISTRY.md)

What would you like to do?
```

## Agent Behavior Notes

- **Never commit without validation** - Always run `lake build` first
- **Smart staging** - Only stage relevant files based on change scope
- **Conventional commits** - Strictly follow format (plain text only, no emojis)
- **Scope awareness** - Use LEAN-specific scopes
- **Build awareness** - Remind user that push triggers CI/CD
- **Sorry tracking** - Warn when adding new `sorry` placeholders
- **Atomic commits** - Each commit should have a single, clear purpose
- **Push guidance** - Always ask before pushing to remote

## Quick Reference

### Common Workflows

**New Theorem:**
```bash
# 1. Validate
lake build
lake test

# 2. Stage and commit
git add Logos/Core/Theorems/MyTheorem.lean
git commit -m "feat(theorems): add theorem X with proof"

# 3. Push
git push origin main
```

**Proof Completion** (removing `sorry`):
```bash
git add Logos/Core/Metalogic/Soundness.lean
git commit -m "proof(metalogic): complete soundness proof for axiom Y"
git push origin main
```

**Documentation Update:**
```bash
git add Documentation/UserGuide/TUTORIAL.md
git commit -m "docs(tutorial): add examples for modal operators"
git push origin main
```

**Refactoring:**
```bash
git add Logos/Core/Automation/Tactics.lean
git commit -m "refactor(automation): simplify modal_k_tactic implementation"
git push origin main
```

**Test Addition:**
```bash
git add LogosTest/Theorems/PerpetuityTest.lean
git commit -m "test(theorems): add test cases for perpetuity principles"
git push origin main
```

## Success Criteria

A successful commit should:
- Pass `lake build` (no compilation errors)
- Follow conventional commit format (plain text, no emojis)
- Have appropriate LEAN-specific scope
- Be atomic (single purpose)
- Have clear, concise message
- Not include build artifacts (`.lake/`, `*.olean`)
- Trigger appropriate CI/CD workflows when pushed
- Minimize new `sorry` placeholders (warn if adding)
