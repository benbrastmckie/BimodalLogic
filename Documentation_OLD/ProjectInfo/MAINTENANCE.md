# TODO.md Maintenance Workflow

**Last Updated**: 2025-12-05

This document describes the workflow for maintaining TODO.md and related project tracking documentation. It establishes a Git-based history model where TODO.md contains only active work, and completion history is preserved through git commits and spec summaries.

## Related Documentation

**Five-Document Model** (consolidated from four documents on 2025-12-05; expanded to five on 2025-12-26):
- [TODO.md](../../TODO.md) - Active task tracking (active work only)
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking (includes Known Limitations section)
- [FEATURE_REGISTRY.md](FEATURE_REGISTRY.md) - Feature tracking and capability documentation
- [SORRY_REGISTRY.md](SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [TACTIC_REGISTRY.md](TACTIC_REGISTRY.md) - Custom tactic documentation and usage

---

## Git-Based History Model

### Philosophy

**TODO.md contains only active work. Git commits and spec summaries preserve completion history permanently.**

This model provides:
- Minimal TODO.md (300-400 lines vs 800+)
- Searchable history via `git log`
- Rich implementation details via spec summaries
- No manual completion log maintenance
- Clear separation: TODO.md = future, git = past

### Benefits

1. **Reduced Maintenance**: No completion log to update after each task
2. **Better Searchability**: Git queries are more powerful than table scanning
3. **Permanent History**: Commits never deleted, always available
4. **Rich Context**: Spec summaries provide 10-100x more detail than log entries
5. **Single Responsibility**: TODO.md focuses on planning, not history

---

## Task Lifecycle

### 1. Adding New Tasks

1. Determine priority (High/Medium/Low) based on:
   - **High**: Blocking bugs, correctness issues, essential features (complete within 1 month)
   - **Medium**: Enhancements, optimizations, quality improvements (complete within 3 months)
   - **Low**: Future work, research, extensions (complete within 6-12 months)

2. Estimate effort conservatively (see Effort Estimation section)

3. Identify blocking dependencies (inline with task):
   ```markdown
   **Blocking**: Task N (description)
   **Dependencies**: Task M must be complete
   ```

4. Create task entry in appropriate priority section

5. Update Overview section task counts

6. Commit with clear message:
   ```bash
   git commit -m "Add Task N: [description]"
   ```

### 2. Starting Active Work

1. Update task status inline: `**Status**: IN PROGRESS`

2. Create spec directory (for non-trivial tasks):
   ```bash
   mkdir -p .claude/specs/NNN_task_name/{plans,reports,summaries}
   ```

3. Create plan document if needed

4. Commit start:
   ```bash
   git commit -m "Start Task N: [description]"
   ```

### 3. Completing Tasks

1. Create implementation summary in spec directory (if spec exists)

2. Update related documentation:
   - **IMPLEMENTATION_STATUS.md**: Update module status, sorry counts, and Known Limitations section
   - **SORRY_REGISTRY.md**: Remove resolved placeholders

3. **Remove completed task from TODO.md entirely** (don't mark as complete)

4. Update TODO.md Overview counts

5. Commit with comprehensive message:
   ```bash
   git commit -m "Complete Task N: [description]

   - [Key changes made]
   - [Files modified]
   - [Tests added/updated]

   Plan: .claude/specs/NNN_task_name/plans/plan.md
   Summary: .claude/specs/NNN_task_name/summaries/summary.md"
   ```

### 4. Partial Completion

For tasks with multiple phases that span sessions:

1. Update task status: `**Status**: PARTIAL COMPLETE (X/Y phases)`

2. Document completed work inline with task

3. Create iteration summary in spec directory

4. Keep task in TODO.md until fully complete

---

## Documentation Synchronization

### When Task Completes

Update these files in order:

| Order | File | Updates |
|-------|------|---------|
| 1 | Spec summaries | Create completion summary |
| 2 | IMPLEMENTATION_STATUS.md | Module %, sorry counts, Known Limitations section |
| 3 | FEATURE_REGISTRY.md | Add new features, update feature status |
| 4 | SORRY_REGISTRY.md | Remove resolved items |
| 5 | TACTIC_REGISTRY.md | Add/update custom tactics |
| 6 | TODO.md | Remove task, update counts |
| 7 | Git commit | Comprehensive message |

### Decision Tree: Which Document to Update

```
Is this about module completion %?
  -> IMPLEMENTATION_STATUS.md

Is this about a gap/limitation being fixed?
  -> IMPLEMENTATION_STATUS.md Known Limitations section (remove entry)

Is this about a new feature or capability?
  -> FEATURE_REGISTRY.md (add entry with status and description)

Is this about a sorry placeholder?
  -> SORRY_REGISTRY.md (remove/move to resolved)

Is this about a custom tactic?
  -> TACTIC_REGISTRY.md (add/update tactic documentation)

Is this about task status?
  -> TODO.md (remove if complete, update if partial)

Is this about workflow or process?
  -> MAINTENANCE.md (this file)
```

### Cross-Reference Validation

After major updates, verify bidirectional links work:

```bash
# Check registry references
grep -l "SORRY_REGISTRY.md" TODO.md Documentation/ProjectInfo/*.md
grep -l "FEATURE_REGISTRY.md" TODO.md Documentation/ProjectInfo/*.md
grep -l "TACTIC_REGISTRY.md" TODO.md Documentation/ProjectInfo/*.md

# Check all core docs reference each other appropriately
for doc in TODO.md Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md \
           Documentation/ProjectInfo/FEATURE_REGISTRY.md \
           Documentation/ProjectInfo/SORRY_REGISTRY.md \
           Documentation/ProjectInfo/TACTIC_REGISTRY.md; do
  echo "=== $doc ==="
  grep -E "(TODO\.md|IMPLEMENTATION_STATUS|FEATURE_REGISTRY|SORRY_REGISTRY|TACTIC_REGISTRY|MAINTENANCE)" "$doc"
done
```

---

## Completion History Queries

### Git Log Queries

```bash
# View all task completions
git log --all --grep="Complete Task" --oneline --date=short

# Find when specific task completed
git log --all --grep="Task 7" --grep="complete" --oneline

# View completion details
git show <commit-hash>

# Show TODO.md at specific point in time
git show <commit-hash>:TODO.md

# Compare TODO.md between commits
git diff <commit1> <commit2> -- TODO.md

# Search all commits for term
git log --all -S "Perpetuity" --oneline

# Find commits that modified specific file
git log --oneline -- Logos/Core/Theorems/Perpetuity.lean

# View commit history with dates
git log --all --pretty=format:"%h %ad %s" --date=short

# Count commits since date
git log --all --since="2025-12-01" --oneline | wc -l
```

### Spec Summary Queries

```bash
# Find all summary files
find .claude/specs -name "*summary*.md" -o -name "*FINAL*.md"

# Search summaries for task
grep -r "Task 7" .claude/specs/*/summaries/

# List summaries by size (find detailed docs)
find .claude/specs -name "*summary*.md" -exec du -h {} \; | sort -hr

# Find recent summaries
find .claude/specs -name "*summary*.md" -mtime -7

# Count total summary files
find .claude/specs -name "*summary*.md" | wc -l

# View specific summary
cat .claude/specs/025_soundness_automation_implementation/summaries/004_iteration_3_final_summary.md
```

### Sorry Placeholder Queries

```bash
# Count active sorry placeholders
grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null | wc -l

# List sorry locations with context
grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null

# Find sorry in specific module
grep -n "sorry" Logos/Core/Theorems/Perpetuity.lean

# Search commit history for sorry resolutions
git log --all --grep="sorry" --oneline

# Find when file became sorry-free
git log --all -S "sorry" -- Logos/Core/Semantics/Truth.lean
```

---

## Sorry Placeholder Workflow

### Resolution Process

1. Identify sorry item in [SORRY_REGISTRY.md](SORRY_REGISTRY.md)

2. Review resolution guidance and effort estimate

3. Check for blockers in [IMPLEMENTATION_STATUS.md - Known Limitations](IMPLEMENTATION_STATUS.md#known-limitations)

4. Implement proof/function to remove sorry

5. Run `lake build` to verify compilation

6. Run `lake test` to verify tests pass

7. Update SORRY_REGISTRY.md (move to Resolved section or remove)

8. Update IMPLEMENTATION_STATUS.md (decrement sorry count for module)

9. Commit with clear message:
   ```bash
   git commit -m "Resolve sorry at File.lean:123 - [description]"
   ```

### Blocker Resolution

If resolution is blocked:

1. Document blocker in SORRY_REGISTRY.md entry
2. Cross-reference to IMPLEMENTATION_STATUS.md Known Limitations section
3. Mark status as BLOCKED
4. Create workaround if possible
5. Create task in TODO.md if unblocking requires significant work

---

## Priority Classification

### High Priority (complete within 1 month)

- Blocking bugs preventing normal usage
- Correctness issues affecting proof validity
- Essential features required for MVP
- CI/build failures

### Medium Priority (complete within 3 months)

- Enhancements improving developer experience
- Optimizations for performance
- Quality improvements (tests, documentation)
- Non-blocking bugs

### Low Priority (complete within 6-12 months)

- Future work beyond current scope
- Research and experimentation
- Layer 1/2/3 extensions
- Nice-to-have features

---

## Effort Estimation

Use conservative estimates based on complexity:

| Effort | Description | Examples |
|--------|-------------|----------|
| 1-2 hours | Bug fix, small enhancement | Fix typo, add missing test |
| 4-6 hours | Feature implementation, proof | Implement tactic, prove theorem |
| 10-20 hours | Module implementation, refactor | New module, significant changes |
| 40-60 hours | Major system component | Decidability module, automation |
| 70-90 hours | Complex proof infrastructure | Completeness proofs |

**Guidelines**:
- Double your initial estimate for unfamiliar code
- Add 50% for code requiring coordination with other modules
- Account for test writing (typically 20-30% of implementation time)
- Include documentation time (typically 10-20%)

---

## TODO.md Structure

### Required Sections

1. **Overview** (10-15 lines)
   - Layer completion percentage
   - Active task count
   - Next milestone
   - Quick links to related docs

2. **Quick Links**
   - Links to STATUS, LIMITATIONS, REGISTRY, MAINTENANCE docs

3. **Priority Sections** (High/Medium/Low)
   - Active tasks only
   - Inline dependencies and blocking information
   - Status, effort, and description

4. **Completion History**
   - Git query examples
   - Reference to this MAINTENANCE.md

### Task Entry Format

```markdown
### N. Task Title
**Effort**: X-Y hours
**Status**: Not Started | IN PROGRESS | PARTIAL COMPLETE
**Priority**: High | Medium | Low (reason)
**Blocking**: Task M (description) [if applicable]
**Dependencies**: Task M must be complete [if applicable]

**Description**: [What needs to be done]

**Action Items**:
1. [Specific step]
2. [Specific step]

**Files**:
- `path/to/file.lean` (description)

---
```

---

## Commit Message Standards

### Task Completion

```
Complete Task N: [brief description]

- [Key change 1]
- [Key change 2]
- [Tests added/updated]

Plan: .claude/specs/NNN_task_name/plans/plan.md
Summary: .claude/specs/NNN_task_name/summaries/summary.md
```

### Sorry Resolution

```
Resolve sorry at File.lean:123 - [description]

- Implemented [proof/function]
- [Any related changes]

Updates SORRY_REGISTRY.md and IMPLEMENTATION_STATUS.md
```

### Documentation Update

```
Update documentation: [brief description]

- [What was updated]
- [Why it was updated]
```

---

## Troubleshooting

### Desynchronized Sorry Counts

If SORRY_REGISTRY.md count doesn't match actual:

```bash
# Get actual count
grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null | wc -l

# Compare with registry
grep -c "^- \*\*.*\.lean:" Documentation/ProjectInfo/SORRY_REGISTRY.md
```

Fix by updating SORRY_REGISTRY.md to match actual codebase state.

### Missing Spec Summaries

If task completed but no summary exists:

```bash
# Check if spec directory exists
ls -la .claude/specs/NNN_task_name/

# Check git log for completion commit
git log --all --grep="Task N" --oneline
```

Create retrospective summary if needed for documentation.

### Broken Cross-References

If links between documents are broken:

```bash
# Check all markdown links
grep -rn "\[.*\](.*\.md)" Documentation/ProjectInfo/*.md TODO.md

# Verify linked files exist
for link in $(grep -oh '\[.*\]([^)]*\.md)' TODO.md | grep -oh '([^)]*)' | tr -d '()'); do
  [ -f "$link" ] || echo "Missing: $link"
done
```

---

## Backwards Compatibility Policy

### Philosophy: Clean-Break Over Compatibility Layers

This project follows a **clean-break approach** to code evolution, explicitly avoiding backwards compatibility layers in favor of direct, breaking changes when necessary.

### Policy

**NEVER** create backwards compatibility layers:
- No deprecated function wrappers
- No legacy API shims
- No compatibility mode flags
- No dual code paths for old/new behavior

**ALWAYS** use clean-break approach:
- Make breaking changes directly
- Update all call sites in same commit
- Document migration in commit message
- Remove old code completely

### Rationale

**Technical Debt**: Compatibility layers accumulate technical debt that compounds over time:
- Increased code complexity (maintaining two implementations)
- Higher maintenance burden (bugs must be fixed in both paths)
- Slower development velocity (changes require updating both paths)
- Reduced code quality (unclear which path is "correct")
- Harder onboarding (new contributors must learn both old and new)

**Clean-Break Benefits**:
- Single source of truth (one implementation)
- Clear migration path (all code uses new approach)
- Easier refactoring (no legacy constraints)
- Better code quality (no cruft or workarounds)
- Faster development (change once, done)

### Examples

**Bad (Compatibility Layer)**:
```lean
-- Old API (deprecated but kept for compatibility)
def oldFunction (x : Nat) : Nat := x + 1

-- New API
def newFunction (x : Nat) : Nat := x + 2

-- Compatibility wrapper
@[deprecated newFunction]
def oldFunction := newFunction
```

**Good (Clean-Break)**:
```lean
-- Simply replace old implementation with new one
def function (x : Nat) : Nat := x + 2  -- Changed from x + 1

-- Update all call sites in same commit
-- Document change in commit message
```

### When Breaking Changes Are Acceptable

Breaking changes are acceptable when:
1. **Internal APIs**: Code is not exposed to external users
2. **Early Development**: Project is pre-1.0 or in active development
3. **Clear Improvement**: New approach is objectively better
4. **Manageable Scope**: All call sites can be updated in single commit
5. **Documented Migration**: Commit message explains what changed and why

### Migration Process

When making breaking changes:

1. **Plan**: Identify all call sites that need updating
2. **Implement**: Make the breaking change
3. **Update**: Update all call sites in same commit
4. **Test**: Verify all tests pass with new implementation
5. **Document**: Write clear commit message explaining:
   - What changed
   - Why it changed
   - How to migrate (if not obvious)
6. **Commit**: Single atomic commit with all changes

### Exceptions

The only acceptable "compatibility" is:
- **Data migration scripts**: For persistent data (databases, config files)
- **Version detection**: To handle different external library versions
- **Feature flags**: For gradual rollout of new features (temporary, removed after rollout)

These are not compatibility layers because they:
- Don't maintain dual code paths indefinitely
- Have clear removal timeline
- Serve operational needs, not code convenience

### Related Standards

- Task 169: Implemented clean-break approach for /implement command (removed backward compatibility, updated 80+ files in single commit)
- LEAN_STYLE_GUIDE.md: Prefer direct changes over deprecated wrappers
- VERSIONING.md: Breaking changes are acceptable pre-1.0

---

## Update Instructions for /review Command

When the `/review` command completes a repository analysis, it should update the following files to reflect findings and register remaining work:

### Files to Update

1. **IMPLEMENTATION_STATUS.md** - Update module completion percentages, sorry counts, and Known Limitations section
   - Add new gaps/limitations discovered during review
   - Remove limitations that have been resolved
   - Update completion percentages based on current state

2. **FEATURE_REGISTRY.md** - Register new features or capabilities discovered
   - Add entries for undocumented features found in code
   - Update feature status based on implementation state
   - Cross-reference with IMPLEMENTATION_STATUS.md

3. **SORRY_REGISTRY.md** - Update sorry placeholder tracking
   - Add newly discovered sorry placeholders
   - Remove resolved placeholders
   - Update resolution guidance based on findings

4. **TACTIC_REGISTRY.md** - Update custom tactic documentation
   - Add newly discovered tactics
   - Update tactic descriptions and usage examples
   - Cross-reference with implementation files

### Task Registration Workflow

After updating the registry/status files, `/review` should create tasks in TODO.md for all remaining work identified during the review:

1. **Use /add command** to register each identified task
   - Ensures proper task numbering via state.json
   - Maintains lazy directory creation (no project roots created)
   - Preserves all task metadata and status markers

2. **Task metadata requirements**:
   - Clear description of work to be done
   - Effort estimate based on complexity
   - Priority based on impact and urgency
   - Language metadata (lean, markdown, etc.)
   - Dependencies and blocking relationships

3. **Do NOT implement tasks** - `/review` only identifies and registers work
   - Implementation happens via `/implement` command
   - Planning happens via `/plan` command
   - Research happens via `/research` command

### Repository-Agnostic Design

These instructions are general and apply to any repository using this workflow system. The specific file paths may vary by repository, but the workflow remains consistent:

- Locate the repository's MAINTENANCE.md file
- Read this "Update Instructions for /review Command" section
- Update the files listed in this section
- Register tasks for remaining work via /add

---

## Maintenance History

### 2025-12-20: Emoji Removal (Project #007)

**Action**: Removed all emojis from repository, added emoji ban to style guides
**Files Modified**: 7 (4 emoji removal, 3 documentation updates)
**Rationale**: Maintain professional, technical tone; improve consistency
**Verification**: Zero emojis in target files, all builds pass
**Prevention**: Style guides updated, emoji ban documented

**Details**:
- Removed ~122 emojis from 4 documentation files
- Updated 3 style guides with emoji prohibition
- Replaced emojis with text-based status markers
- Preserved 1,909 mathematical symbols (↔, →, ∧, ∨, etc.)
- All verification checks passed (target files, build, symbols)

**Files Modified**:
- Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
- Documentation/ProjectInfo/SORRY_REGISTRY.md
- .opencode/README.md
- .opencode/QUICK-START.md
- Documentation/Development/LEAN_STYLE_GUIDE.md
- context/core/standards/docs.md
- Documentation/Development/CONTRIBUTING.md

**Summary**: .opencode/specs/007_emoji_removal/summaries/implementation-summary.md

---

**Last Updated**: 2025-12-20
