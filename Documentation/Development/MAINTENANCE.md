# TODO.md Maintenance Workflow

**Last Updated**: 2025-12-05

This document describes the workflow for maintaining TODO.md and related project tracking documentation. It establishes a Git-based history model where TODO.md contains only active work, and completion history is preserved through git commits and spec summaries.

## Related Documentation

**Three-Document Model** (consolidated from four documents on 2025-12-05):
- [TODO.md](../../TODO.md) - Active task tracking (active work only)
- [IMPLEMENTATION_STATUS.md](../ProjectInfo/IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking (includes Known Limitations section)
- [FEATURE_REGISTRY.md](../ProjectInfo/FEATURE_REGISTRY.md) - Feature tracking and implementation status
- [SORRY_REGISTRY.md](../ProjectInfo/SORRY_REGISTRY.md) - Technical debt tracking (sorry placeholders)
- [TACTIC_REGISTRY.md](../ProjectInfo/TACTIC_REGISTRY.md) - Tactic documentation and usage tracking

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
   - **FEATURE_REGISTRY.md**: Update feature completion status if applicable
   - **SORRY_REGISTRY.md**: Remove resolved placeholders
   - **TACTIC_REGISTRY.md**: Update if task involved tactic implementation

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
| 3 | FEATURE_REGISTRY.md | Update feature status if applicable |
| 4 | SORRY_REGISTRY.md | Remove resolved items |
| 5 | TACTIC_REGISTRY.md | Update tactic documentation if applicable |
| 6 | TODO.md | Remove task, update counts |
| 7 | Git commit | Comprehensive message |

### Decision Tree: Which Document to Update

```
Is this about module completion %?
  -> IMPLEMENTATION_STATUS.md

Is this about a gap/limitation being fixed?
  -> IMPLEMENTATION_STATUS.md Known Limitations section (remove entry)

Is this about a feature being implemented?
  -> FEATURE_REGISTRY.md (update feature status)

Is this about a sorry placeholder?
  -> SORRY_REGISTRY.md (remove/move to resolved)

Is this about a tactic being implemented or updated?
  -> TACTIC_REGISTRY.md (update tactic documentation)

Is this about task status?
  -> TODO.md (remove if complete, update if partial)

Is this about workflow or process?
  -> MAINTENANCE.md (this file)
```

### Cross-Reference Validation

After major updates, verify bidirectional links work:

```bash
# Check registry references
grep -l "IMPLEMENTATION_STATUS\|FEATURE_REGISTRY\|SORRY_REGISTRY\|TACTIC_REGISTRY" \
  TODO.md Documentation/ProjectInfo/*.md Documentation/Development/MAINTENANCE.md

# Check all core docs reference each other appropriately
for doc in TODO.md \
           Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md \
           Documentation/ProjectInfo/FEATURE_REGISTRY.md \
           Documentation/ProjectInfo/SORRY_REGISTRY.md \
           Documentation/ProjectInfo/TACTIC_REGISTRY.md \
           Documentation/Development/MAINTENANCE.md; do
  echo "=== $doc ==="
  grep -E "(TODO\.md|IMPLEMENTATION_STATUS|FEATURE_REGISTRY|SORRY_REGISTRY|TACTIC_REGISTRY|MAINTENANCE)" "$doc" || true
done
```

---

## Backwards Compatibility Policy

### Clean-Break Approach

This project explicitly **bans backwards compatibility layers** in favor of clean-break approaches. When making breaking changes, we update all affected code directly rather than maintaining compatibility shims.

**Rationale**:
- **Avoids Technical Debt**: Compatibility layers accumulate over time, increasing maintenance burden
- **Maintains Code Quality**: Direct updates ensure codebase remains clean and understandable
- **Simplifies Reasoning**: No need to track which compatibility mode is active
- **Reduces Test Surface**: Fewer code paths means fewer edge cases to test
- **Enables Refactoring**: Freedom to restructure without preserving old interfaces

### Clean-Break vs Compatibility Layer

**Clean-Break Approach** (PREFERRED):
```lean
-- Before: Old API
def oldFunction (x : Nat) : Nat := x + 1

-- After: Break directly, update all call sites
def newFunction (x : Nat) (y : Nat) : Nat := x + y
```

**Compatibility Layer Approach** (BANNED):
```lean
-- Old API maintained for backwards compatibility
@[deprecated newFunction] 
def oldFunction (x : Nat) : Nat := newFunction x 1

-- New API
def newFunction (x : Nat) (y : Nat) : Nat := x + y
```

### When to Use Clean-Breaks

Apply clean-break approach for:
- **API Changes**: Function signature modifications, renamed functions
- **Module Restructuring**: Moving definitions between files, namespace changes
- **Data Structure Changes**: Modified types, new fields
- **Workflow Changes**: Updated command patterns, new argument formats

### Implementation Process

1. **Identify Breaking Change**: Determine scope of impact
2. **Update All Call Sites**: Fix all usages in same commit
3. **Update Tests**: Ensure all tests reflect new API
4. **Update Documentation**: Synchronize docs with code changes
5. **Single Atomic Commit**: All changes in one commit prevents broken states

### Exceptions

The only acceptable "compatibility" is:
- **Temporary Migration Markers**: Clear TODO comments for multi-phase migrations
- **Explicit Version Boundaries**: Clean breaks at major version bumps
- **External API Stability**: For published libraries (not applicable to this project)

**Duration Limits**:
- Temporary migration markers must be resolved within 1 week
- No indefinite compatibility modes allowed

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

1. Identify sorry item in [SORRY_REGISTRY.md](../ProjectInfo/SORRY_REGISTRY.md)

2. Review resolution guidance and effort estimate

3. Check for blockers in [IMPLEMENTATION_STATUS.md - Known Limitations](../ProjectInfo/IMPLEMENTATION_STATUS.md#known-limitations)

4. Implement proof/function to remove sorry

5. Run `lake build` to verify compilation

6. Run `lake test` to verify tests pass

7. Update SORRY_REGISTRY.md (move to Resolved section or remove)

8. Update IMPLEMENTATION_STATUS.md (decrement sorry count for module)

9. Update TACTIC_REGISTRY.md if sorry resolution involved new tactics

10. Commit with clear message:
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

**Last Updated**: 2025-12-05
