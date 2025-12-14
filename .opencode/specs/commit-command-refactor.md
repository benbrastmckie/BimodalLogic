# Commit Command Refactor Design

**Spec ID**: `commit-command-refactor`  
**Created**: 2025-12-14  
**Status**: Draft for Review  
**Source**: `.opencode/command/commit-openagents.md`  
**Target**: `.opencode/command/commit.md`

---

## Executive Summary

Rename and refactor `commit-openagents.md` to `commit.md`, transforming it from an overly complex, opencode-agents-specific command into a streamlined commit helper tailored for the **Logos LEAN 4 proof system project**. Remove unnecessary features (npm tests, version bumping, agent-specific logic) and focus on creating excellent, conventional commits for a LEAN 4 formal verification codebase.

---

## Current State Analysis

### What the Current Command Does

The `commit-openagents.md` command is designed for an **opencode-agents** repository with:
- **npm-based testing** (`npm run test:general`, `npm run test:coder`)
- **Multiple agents** (general, coder) requiring smoke tests
- **Automatic version bumping** via CI/CD
- **Evaluation framework** (`evals/`) with specific scopes
- **Node.js/TypeScript** project structure

### What This Repository Actually Is

**Logos** is a **LEAN 4 formal verification project** with:
- **Build system**: Lake (LEAN's build tool), not npm
- **Testing**: `lake test` (LEAN unit tests)
- **Linting**: `lake lint` (LEAN linter)
- **CI/CD**: GitHub Actions running `lake build`, `lake test`, `lake lint`
- **No version bumping automation** (manual versioning in `lakefile.toml`)
- **Primary directories**:
  - `Logos/` - Main library code (proof system, semantics, theorems)
  - `LogosTest/` - Test suite
  - `Archive/` - Pedagogical examples
  - `Documentation/` - User and developer docs
  - `.opencode/` - AI agent system

### Mismatch Analysis

| Current Feature | Relevant to Logos? | Action |
|----------------|-------------------|--------|
| npm smoke tests | ❌ No npm in project | **Remove** |
| Agent-specific scopes (evals, agents) | ❌ Wrong domain | **Replace** with LEAN-specific scopes |
| Version bumping awareness | ❌ No automation | **Remove** |
| `package.json` checks | ❌ No package.json | **Remove** |
| Conventional commits format | ✅ Good practice | **Keep** |
| Smart file staging | ✅ Useful | **Keep** (adapt scopes) |
| Pre-commit validation | ✅ Useful | **Keep** (use `lake build/test`) |
| Commit message analysis | ✅ Useful | **Keep** |
| Push workflow | ✅ Useful | **Keep** |

---

## Proposed Refactor Design

### 1. Command Metadata

```yaml
---
description: Smart commit helper for Logos LEAN 4 proof system with build validation and conventional commits
---
```

### 2. Workflow Stages

#### Stage 1: Pre-Commit Validation

**Purpose**: Ensure code quality before committing

**Actions**:
```bash
# Run in parallel
lake build          # Verify project builds
lake test           # Run test suite
git status --porcelain
git diff --cached
```

**Validation Rules**:
- ✅ `lake build` must succeed (no compilation errors)
- ⚠️ `lake test` failures → ask user if they want to proceed
- ✅ Check for uncommitted changes
- ⚠️ Warn if committing with `sorry` placeholders (optional check)

**Removed**:
- ❌ npm smoke tests
- ❌ Agent-specific tests

#### Stage 2: Analyze Changes

**Purpose**: Understand what changed and why

**Actions**:
```bash
git status                    # See all untracked files
git diff                      # See staged and unstaged changes
git log --oneline -10         # See recent commit style
```

**Analysis**:
- Identify scope: `core`, `semantics`, `theorems`, `tests`, `docs`, `automation`, `archive`, `opencode`
- Detect change type: new feature, bug fix, refactor, proof completion, documentation
- Check for sensitive info (none expected in this repo, but good practice)

#### Stage 3: Smart File Staging

**Auto-stage based on change type**:

| Change Type | Auto-stage Pattern |
|------------|-------------------|
| Core logic changes | `Logos/Core/**/*.lean` |
| Semantics changes | `Logos/Core/Semantics/**/*.lean` |
| Theorem additions | `Logos/Core/Theorems/**/*.lean` |
| Test changes | `LogosTest/**/*.lean` |
| Documentation | `Documentation/**/*.md` |
| Archive examples | `Archive/**/*.lean` |
| OpenCode agents | `.opencode/agent/**/*.md` |
| Build config | `lakefile.toml`, `lean-toolchain` |
| CI/CD | `.github/workflows/*.yml` |

**Never auto-stage**:
- `.lake/` (build artifacts)
- `*.olean` (compiled LEAN files)
- `.DS_Store`, `*.swp`, `*~` (editor artifacts)
- `.env*` files (if any)

#### Stage 4: Generate Commit Message

**Format**: Conventional Commits (plain text only, no emojis)

```
<type>(<scope>): <description>

[optional body]
```

**Types** (LEAN 4 project-specific):
- `feat` - New features (axioms, theorems, tactics, operators)
- `fix` - Bug fixes (proof errors, soundness issues)
- `proof` - Proof completions (removing `sorry`, completing theorems)
- `refactor` - Code restructuring (proof simplification, module reorganization)
- `test` - Test additions or modifications
- `docs` - Documentation updates
- `chore` - Maintenance (dependencies, cleanup, file organization)
- `ci` - CI/CD pipeline changes
- `perf` - Performance improvements (proof search, tactic efficiency)

**Scopes** (LEAN 4 project-specific):
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

**Examples**:
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

#### Stage 5: Commit Analysis

**Analysis checklist**:
- List all files changed/added
- Summarize nature of changes (new theorem, proof completion, refactor, etc.)
- Identify primary scope
- Determine purpose/motivation (why this change?)
- Assess impact (soundness, completeness, API changes)
- Check for `sorry` placeholders (warn if adding new ones)
- Draft concise message focusing on "why" not "what"
- Ensure conventional commit format
- Verify message is specific, not generic

**Special checks for LEAN 4**:
- ⚠️ Adding new `sorry`? → Mention in commit body
- ✅ Removing `sorry`? → Highlight in message (`proof: complete X`)
- ⚠️ Changing axioms? → Requires careful review
- ⚠️ Modifying soundness proofs? → High-impact change

#### Stage 6: Execute Commit

```bash
git add <relevant-files>
git commit -m "<type>(<scope>): <description>"
git status  # Verify commit succeeded
```

**Post-commit checks**:
- Verify commit hash created
- Show commit message
- Confirm no unintended files staged

#### Stage 7: Post-Commit Actions

**Ask user**:
```
Commit created: <commit-hash>
Message: <commit-message>

Would you like to:
1. Push to remote (git push origin main)
2. Create another commit
3. Done
```

**If user chooses push**:
```bash
git push origin main
```

**Then inform**:
```
Pushed to remote!

This will trigger:
- GitHub Actions CI/CD workflow
- lake build (verify compilation)
- lake test (run test suite)
- lake lint (check code quality)
```

**Removed**:
- ❌ Version bumping notifications
- ❌ CHANGELOG.md update notifications
- ❌ Agent-specific smoke test notifications

---

## 3. Repository-Specific Rules

### Build Validation

**Before committing**:
- `lake build` must succeed (compilation errors block commit)
- `lake test` should pass (failures warn but don't block)
- `lake lint` warnings are informational only

### Files to Check

**No version files to sync** (removed from original):
- ~~`VERSION` file~~ (doesn't exist)
- ~~`package.json` version~~ (doesn't exist)
- ~~`CHANGELOG.md`~~ (manual updates only)

**LEAN-specific checks**:
- `lakefile.toml` - Build configuration
- `lean-toolchain` - LEAN version pinning
- `lake-manifest.json` - Dependency lock file (auto-generated, usually don't commit manually)

### Pre-Commit Hooks

**This repo may have pre-commit hooks that**:
- Run `lake lint`
- Format LEAN code (if configured)
- Check for `sorry` placeholders

**If hooks modify files**:
- Inform user that files were auto-formatted
- Ask if they want to amend the commit

---

## 4. Error Handling

### If Build Fails

```
⚠️ lake build failed

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
⚠️ lake test failed

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
ℹ️ No changes to commit. Working tree is clean.

Recent commits:
<git log --oneline -5>

Would you like to:
1. Check git status
2. View recent commits
3. Exit
```

### If Merge Conflicts

```
⚠️ Merge conflicts detected. Please resolve conflicts first.

Conflicted files:
<list-files>

Run: git status
```

### If Adding New `sorry`

```
⚠️ Warning: This commit adds new 'sorry' placeholders

Files with new sorry:
<list-files-with-sorry>

This increases technical debt. Consider:
1. Complete the proof before committing
2. Add a TODO comment explaining the sorry
3. Proceed anyway (will be tracked in SORRY_REGISTRY.md)

What would you like to do?
```

---

## 5. Agent Behavior Notes

**Core principles**:
- **Never commit without validation** - Always run `lake build` first
- **Smart staging** - Only stage relevant files based on change scope
- **Conventional commits** - Strictly follow format (plain text only, no emojis)
- **Scope awareness** - Use LEAN-specific scopes
- **Build awareness** - Remind user that push triggers CI/CD
- **Sorry tracking** - Warn when adding new `sorry` placeholders
- **Atomic commits** - Each commit should have a single, clear purpose
- **Push guidance** - Always ask before pushing to remote

**Removed behaviors**:
- ❌ Version bumping awareness
- ❌ npm test execution
- ❌ Agent-specific validation
- ❌ CHANGELOG.md checks

---

## 6. Quick Reference

### Common Workflows

**New Theorem**:
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

**Documentation Update**:
```bash
git add Documentation/UserGuide/TUTORIAL.md
git commit -m "docs(tutorial): add examples for modal operators"
git push origin main
```

**Refactoring**:
```bash
git add Logos/Core/Automation/Tactics.lean
git commit -m "refactor(automation): simplify modal_k_tactic implementation"
git push origin main
```

**Test Addition**:
```bash
git add LogosTest/Theorems/PerpetuityTest.lean
git commit -m "test(theorems): add test cases for perpetuity principles"
git push origin main
```

---

## 7. Success Criteria

A successful commit should:
- Pass `lake build` (no compilation errors)
- Follow conventional commit format (plain text, no emojis)
- Have appropriate LEAN-specific scope
- Be atomic (single purpose)
- Have clear, concise message
- Not include build artifacts (`.lake/`, `*.olean`)
- Trigger appropriate CI/CD workflows when pushed
- Minimize new `sorry` placeholders (warn if adding)

**Removed criteria**:
- ❌ Pass smoke tests for agents
- ❌ Version file synchronization
- ❌ CHANGELOG.md updates

---

## 8. Implementation Plan

### Phase 1: Core Refactor
1. **Rename file**: `commit-openagents.md` → `commit.md`
2. Update command description and metadata
3. Replace npm validation with `lake build`/`lake test`
4. Update scopes to LEAN-specific values
5. Update types to include `proof` type
6. Remove version bumping logic
7. Remove agent-specific references
8. Remove all emojis from output messages

### Phase 2: LEAN-Specific Features
1. Add `sorry` detection and warning
2. Add LEAN file staging patterns
3. Update error messages for `lake` commands
4. Add build artifact exclusion patterns
5. Update commit message examples

### Phase 3: Documentation
1. Update `.opencode/README.md` to reference new `/commit` command
2. Add usage examples to command file
3. Document LEAN-specific scopes and types

### Phase 4: Testing
1. Test with various change types (feat, proof, fix, refactor, docs)
2. Test build failure handling
3. Test test failure handling
4. Test `sorry` detection
5. Test file staging logic

---

## 9. Migration Notes

### Breaking Changes
- **File renamed**: `commit-openagents.md` → `commit.md`
- **Command name changes**: `/commit-openagents` → `/commit`
- Scopes completely changed (LEAN-specific)
- Validation commands changed (npm → lake)
- No version bumping notifications
- All emojis removed from output

### Backward Compatibility
- None required (this is a project-specific refactor)
- Old command will be removed entirely

### User Communication
- Update `.opencode/README.md` with new command
- Document new scopes and types
- Provide examples for common workflows

---

## 10. Open Questions for Review

1. **Scope granularity**: Are the proposed scopes (`core`, `syntax`, `semantics`, etc.) at the right level of detail? Should we have more fine-grained scopes (e.g., `semantics/taskframe`, `semantics/truth`)?

2. **`proof` type**: Should proof completions use `proof` type or `feat` type? Or should we use `fix` when removing `sorry`?

3. **`sorry` warnings**: Should adding new `sorry` placeholders block commits or just warn? Current design: warn only.

4. **Test failures**: Should test failures block commits or just warn? Current design: warn only (build failures block).

5. **Lint failures**: Should `lake lint` warnings block commits? Current design: informational only.

6. **Commit message body**: Should we encourage/require commit bodies for certain types (e.g., `proof` completions explaining the approach)?

7. **Branch awareness**: Should the command behave differently on `main` vs `develop` branches (stricter validation on `main`)?

8. **Auto-staging**: Should the command auto-stage files or always ask the user to confirm staging?

---

## 11. Example Commit Messages

### Good Examples

```
feat(theorems): add perpetuity principle P6 with full proof

Completes the perpetuity principles suite (P1-P6). P6 establishes
that occurrent necessity is perpetual: ▽□φ → □△φ.

Proof strategy: contraposition of P5(¬φ) + bridge lemmas + double_contrapose.
```

```
proof(metalogic): complete soundness proof for modal_5_collapse axiom

Removes sorry from soundness_modal_5_collapse. Proof uses S5 symmetry
and transitivity properties of the accessibility relation.
```

```
fix(semantics): correct task frame nullity condition

The nullity axiom required ∀t, task(t,t) = ∅, but implementation
incorrectly allowed non-empty self-tasks. Fixed condition in TaskFrame.lean.
```

```
refactor(automation): simplify modal_k_tactic implementation

Reduces proof steps from 8 to 4 by using mkAppM instead of manual
expression construction. No behavioral changes.
```

```
test(theorems): add test cases for perpetuity principles P1-P6

Adds comprehensive test coverage for all 6 perpetuity principles,
including edge cases and contrapositive forms.
```

```
docs(architecture): update TM logic specification

Clarifies the distinction between □ (metaphysical necessity) and
△ (temporal always) in the Architecture Guide.
```

### Bad Examples (to avoid)

```
update stuff
(too vague, no type/scope, no description)

fix: bug
(no scope, uninformative description)

feat: added some theorems
(no scope, vague description, past tense)

feat(theorems): add P6!
(emojis not allowed - keep messages plain text)

WIP: working on soundness
(WIP commits should not be pushed to main)
```

---

## 12. Appendix: Comparison Table

| Feature | Old (commit-openagents) | New (commit) |
|---------|------------------------|--------------|
| **Target Repo** | opencode-agents (npm/TypeScript) | Logos (LEAN 4) |
| **Validation** | `npm run test:general/coder` | `lake build`, `lake test` |
| **Scopes** | evals, agents, subagents, scripts | core, syntax, semantics, theorems, automation, tests, docs |
| **Types** | feat, fix, refactor, test, docs, chore, ci, perf | feat, fix, **proof**, refactor, test, docs, chore, ci, perf |
| **Version Bumping** | ✅ Automatic via CI/CD | ❌ Manual only |
| **Special Checks** | package.json, VERSION, CHANGELOG.md | `sorry` detection, build artifacts |
| **File Staging** | evals/, scripts/, .opencode/agent/ | Logos/, LogosTest/, Documentation/, .opencode/ |
| **CI/CD Awareness** | npm tests, version bumping, CHANGELOG | lake build/test/lint |
| **Complexity** | High (267 lines, many features) | Medium (streamlined, focused) |

---

**End of Specification**

**Next Steps**: Review this design, provide feedback on open questions, and approve for implementation.
