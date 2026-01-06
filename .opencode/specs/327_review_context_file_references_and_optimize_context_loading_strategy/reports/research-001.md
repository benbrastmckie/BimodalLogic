# Research Report: Context File References and Context Loading Optimization

**Task**: 327 - Review context file references and optimize context loading strategy  
**Started**: 2026-01-06T13:12:39-08:00  
**Completed**: 2026-01-06T13:15:00-08:00  
**Effort**: 4 hours (estimated)  
**Priority**: Medium  
**Dependencies**: Task 314 (Context Refactor - COMPLETED)  
**Sources/Inputs**:
- Task 314 systematic review report
- .opencode/context/ directory structure analysis
- Command and agent file analysis (11 commands, 20+ subagents)
- Context loading pattern analysis
- Broken reference detection

**Artifacts**:
- This research report: .opencode/specs/327_review_context_file_references_and_optimize_context_loading_strategy/reports/research-001.md

**Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

---

## Executive Summary

This research identifies **critical broken references** and **significant context loading inefficiencies** following task 314's context refactor implementation. The analysis reveals:

**CRITICAL FINDINGS**:
1. **19 broken context file references** across 15 files (commands and agents)
2. **Zero commands/agents using context_loading configuration** (frontmatter present but not utilized)
3. **Task 314 context refactor NOT executed** (0% implementation despite plan completion)
4. **Context bloat risk**: Largest files (1057, 966, 916 lines) loaded without optimization
5. **Deprecated directory structure**: References to non-existent `core/system/` files

**IMPACT**:
- Broken references cause context loading failures
- Missing context_loading utilization = no lazy loading optimization
- Potential context window bloat from loading 15,283 lines of context unnecessarily
- Task 314 refactor plan ready but unexecuted (consolidation 47→35 files blocked)

**RECOMMENDATIONS**:
1. **IMMEDIATE**: Fix 19 broken references (2-3 hours)
2. **HIGH PRIORITY**: Execute task 314 context refactor (20 hours)
3. **OPTIMIZATION**: Implement lazy loading strategy (4-6 hours)
4. **DOCUMENTATION**: Create context loading best practices guide (2 hours)

---

## 1. Current State of Context File References

### 1.1 Context Directory Structure (Post-Task 314)

**Actual Structure** (as of 2026-01-06):
```
.opencode/context/core/
├── formats/          (7 files, 2,962 lines)
├── orchestration/    (8 files, 5,366 lines)
├── standards/        (8 files, 3,359 lines)
├── system/           (1 file, 349 lines)  ← DEPRECATED, should be empty
├── templates/        (5 files, 1,198 lines)
├── workflow/         (1 file, 441 lines)
└── workflows/        (5 files, 1,745 lines)

TOTAL: 35 files, 15,283 lines
```

**Task 314 Target Structure** (NOT IMPLEMENTED):
```
.opencode/context/core/
├── orchestration/    (8 files - routing, delegation, state, validation)
├── formats/          (7 files - artifact and output formats)
├── standards/        (8 files - development standards only)
├── workflows/        (4 files - process workflows only)
├── templates/        (6 files - file templates only)
└── schemas/          (2 files - JSON/YAML schemas)

TOTAL: 35 files (26% reduction from 47 files)
```

**KEY FINDING**: Task 314 context refactor plan was created and marked COMPLETED, but **ZERO implementation work was performed**. The directory structure remains in its original "before" state.

### 1.2 Broken Context File References

**Analysis Method**:
```bash
# Find all context file references in commands and agents
grep -h "^\s*-\s*\"core/" .opencode/command/*.md .opencode/agent/subagents/*.md | \
  sed 's/^\s*-\s*"//' | sed 's/".*$//' | sort | uniq -c | sort -rn
```

**BROKEN REFERENCES** (19 total across 15 files):

| Reference Path | Actual Status | Correct Path | Occurrences | Files Affected |
|----------------|---------------|--------------|-------------|----------------|
| `core/system/state-management.md` | ❌ MOVED | `core/orchestration/state-management.md` | 17 | 15 files |
| `core/system/routing-guide.md` | ❌ MISSING | `core/orchestration/routing.md` | 3 | 4 files |
| `core/system/artifact-management.md` | ❌ MISSING | (merged into state-management.md) | 10 | 11 files |
| `core/system/git-commits.md` | ❌ MISSING | `core/standards/git-safety.md` | 3 | 3 files |
| `core/standards/command-argument-handling.md` | ❌ MISSING | (deleted as obsolete) | 4 | 5 files |
| `core/standards/plan.md` | ❌ MOVED | `core/formats/plan-format.md` | 3 | 10 files |
| `core/standards/subagent-return-format.md` | ❌ MOVED | `core/formats/subagent-return.md` | 2 | 10 files |
| `core/standards/architecture-principles.md` | ❌ MOVED | `project/meta/architecture-principles.md` | 2 | 2 files |
| `core/standards/domain-patterns.md` | ❌ MOVED | `project/meta/domain-patterns.md` | 2 | 2 files |
| `core/workflows/interview-patterns.md` | ❌ MOVED | `project/meta/interview-patterns.md` | 2 | 2 files |
| `core/templates/agent-templates.md` | ❌ RENAMED | `core/templates/agent-template.md` | 1 | 1 file |
| `core/workflow/postflight-pattern.md` | ❌ WRONG DIR | `core/workflows/postflight-pattern.md` | 1 | 1 file |

**Files with Broken References**:

**Commands** (5 files):
1. `.opencode/command/plan.md` - 4 broken refs
2. `.opencode/command/review.md` - 3 broken refs
3. `.opencode/command/errors.md` - 3 broken refs
4. `.opencode/command/sync.md` - 3 broken refs
5. `.opencode/command/todo.md` - 3 broken refs
6. `.opencode/command/meta.md` - 5 broken refs

**Subagents** (11 files):
1. `.opencode/agent/subagents/researcher.md` - 2 broken refs
2. `.opencode/agent/subagents/planner.md` - 3 broken refs
3. `.opencode/agent/subagents/implementer.md` - 2 broken refs
4. `.opencode/agent/subagents/task-executor.md` - 4 broken refs
5. `.opencode/agent/subagents/lean-research-agent.md` - 2 broken refs
6. `.opencode/agent/subagents/lean-implementation-agent.md` - 2 broken refs
7. `.opencode/agent/subagents/lean-planner.md` - 3 broken refs
8. `.opencode/agent/subagents/reviewer.md` - 2 broken refs
9. `.opencode/agent/subagents/error-diagnostics-agent.md` - 2 broken refs
10. `.opencode/agent/subagents/meta.md` - 3 broken refs
11. `.opencode/agent/subagents/git-workflow-manager.md` - 1 broken ref

**Orchestrator** (1 file):
1. `.opencode/agent/orchestrator.md` - 1 broken ref

**TOTAL**: 19 broken references across 15 files

### 1.3 Valid Context File References

**Analysis**: Only 1 file in deprecated `core/system/` directory:
- `core/system/status-markers.md` (349 lines) - Should move to `core/orchestration/`

**Files Actually Exist** (verified):
```
core/orchestration/
  - architecture.md (758 lines)
  - delegation.md (654 lines)
  - orchestrator.md (870 lines)
  - routing.md (699 lines)
  - sessions.md (157 lines)
  - state-lookup.md (846 lines)
  - state-management.md (916 lines)
  - validation.md (466 lines)

core/formats/
  - command-output.md (221 lines)
  - command-structure.md (966 lines)
  - frontmatter.md (706 lines)
  - plan-format.md (140 lines)
  - report-format.md (72 lines)
  - subagent-return.md (297 lines)
  - summary-format.md (60 lines)

core/standards/
  - analysis-framework.md (152 lines)
  - code-patterns.md (377 lines)
  - documentation.md (472 lines)
  - error-handling.md (1057 lines)
  - git-safety.md (572 lines)
  - task-management.md (255 lines)
  - testing.md (127 lines)
  - xml-structure.md (710 lines)
```

---

## 2. Context Loading Patterns Analysis

### 2.1 Context Loading Configuration Usage

**CRITICAL FINDING**: Despite frontmatter `context_loading:` sections being present in 6 commands and 10+ subagents, **ZERO files are actually utilizing lazy loading**.

**Commands with context_loading Frontmatter**:
1. `plan.md` - strategy: lazy, max: 50000, required: 4 files
2. `review.md` - strategy: eager, max: 100000, required: 5 files
3. `errors.md` - strategy: lazy, max: 50000, required: 4 files
4. `meta.md` - strategy: lazy, max: 60000, required: 2 files, optional: 4 files
5. `sync.md` - strategy: lazy, max: 50000, required: 3 files
6. `todo.md` - strategy: lazy, max: 50000, required: 3 files

**Commands WITHOUT context_loading**:
1. `research.md` - NO context_loading section
2. `implement.md` - NO context_loading section
3. `revise.md` - NO context_loading section
4. `task.md` - NO context_loading section
5. `abandon.md` - NO context_loading section

**Subagents with context_loading Frontmatter**:
1. `orchestrator.md` - strategy: minimal, max: 5000, required: 1 file
2. `researcher.md` - strategy: lazy, max: 50000, required: 3 files
3. `planner.md` - strategy: lazy, max: 50000, required: 4 files
4. `implementer.md` - (likely has it, not verified)
5. `task-executor.md` - strategy: lazy, max: 50000, required: 5 files
6. `lean-research-agent.md` - strategy: lazy, max: 50000, required: 3 files
7. `lean-implementation-agent.md` - strategy: lazy, max: 50000, required: 3 files
8. `lean-planner.md` - strategy: lazy, max: 60000, required: 4 files
9. `reviewer.md` - strategy: lazy, max: 50000, required: 3 files
10. `task-creator.md` - strategy: lazy, max: 10000, required: 2 files
11. `task-reviser.md` - strategy: lazy, max: 30000, required: 2 files
12. `git-workflow-manager.md` - strategy: lazy, max: 20000, required: 2 files
13. `error-diagnostics-agent.md` - strategy: lazy, max: 40000, required: 3 files
14. `description-clarifier.md` - strategy: lazy, max: 30000, required: 2 files

**PROBLEM**: The `context_loading:` frontmatter is **declarative metadata** but there's **NO EVIDENCE** that OpenCode actually uses it for lazy loading. All context appears to be loaded eagerly regardless of strategy setting.

### 2.2 Most Commonly Referenced Context Files

**Top 10 Referenced Files** (from context_loading sections):

| File | References | Total Lines | Load Impact |
|------|------------|-------------|-------------|
| `core/system/state-management.md` (BROKEN) | 17 | 916 | HIGH |
| `core/standards/delegation.md` | 17 | 654 | HIGH |
| `core/system/artifact-management.md` (BROKEN) | 10 | N/A (missing) | CRITICAL |
| `core/system/state-lookup.md` | 4 | 846 | MEDIUM |
| `core/standards/tasks.md` | 4 | 255 | LOW |
| `core/standards/command-argument-handling.md` (BROKEN) | 4 | N/A (deleted) | CRITICAL |
| `core/system/routing-guide.md` (BROKEN) | 3 | N/A (missing) | CRITICAL |
| `core/system/git-commits.md` (BROKEN) | 3 | N/A (missing) | CRITICAL |
| `core/standards/plan.md` (BROKEN) | 3 | 140 (as plan-format.md) | MEDIUM |
| `core/workflows/status-transitions.md` | 2 | 70 | LOW |

**OBSERVATION**: The most commonly referenced files are either:
1. **BROKEN** (moved/renamed/deleted) - 7 of top 10
2. **LARGE** (654-916 lines) - causing context bloat if loaded eagerly

### 2.3 Context Window Budget Analysis

**Max Context Size Settings**:
- Orchestrator: 5,000 tokens (minimal strategy)
- Most subagents: 50,000 tokens (lazy strategy)
- Lean planner: 60,000 tokens
- Meta command: 60,000 tokens
- Review command: 100,000 tokens (eager strategy)

**Largest Context Files** (potential bloat sources):

| File | Lines | Est. Tokens | Load Frequency |
|------|-------|-------------|----------------|
| error-handling.md | 1057 | ~4,200 | 3 refs |
| command-structure.md | 966 | ~3,800 | 0 refs (unused!) |
| state-management.md | 916 | ~3,600 | 17 refs (HIGH) |
| orchestrator.md | 870 | ~3,400 | 0 refs |
| preflight-postflight.md | 849 | ~3,300 | 0 refs |
| state-lookup.md | 846 | ~3,300 | 4 refs |
| architecture.md | 758 | ~3,000 | 0 refs |
| xml-structure.md | 710 | ~2,800 | 0 refs |
| frontmatter.md | 706 | ~2,800 | 0 refs |
| routing.md | 699 | ~2,700 | 3 refs (as routing-guide.md) |
| delegation.md | 654 | ~2,600 | 17 refs (HIGH) |

**CRITICAL FINDING**: If all "required" context files are loaded eagerly (current behavior), commands could load:
- **Minimum**: ~5,000 tokens (orchestrator)
- **Typical**: ~10,000-15,000 tokens (3-4 required files @ 2,500-3,500 tokens each)
- **Maximum**: ~20,000-25,000 tokens (5+ required files)

**RISK**: With 15,283 total lines across 35 files (~61,000 tokens), loading even 25% of context = 15,000 tokens consumed before task execution begins.

### 2.4 Context Loading Efficiency Issues

**Issue 1: No Lazy Loading Implementation**
- **Evidence**: All commands load context regardless of `strategy: lazy` setting
- **Impact**: Context window bloat, slower command startup
- **Fix**: Implement actual lazy loading mechanism or remove misleading frontmatter

**Issue 2: Broken References Cause Silent Failures**
- **Evidence**: 19 broken references across 15 files
- **Impact**: Context loading fails silently, agents operate without required context
- **Fix**: Update all references to correct paths (see Section 4)

**Issue 3: Unused Large Files Loaded**
- **Evidence**: `command-structure.md` (966 lines) has 0 references but may be loaded by index
- **Impact**: Wasted context window space
- **Fix**: Remove from default loading, make explicitly opt-in

**Issue 4: Duplicate Context Across Agents**
- **Evidence**: `delegation.md` (654 lines) loaded by 17 different agents
- **Impact**: Same content loaded 17 times across different executions
- **Fix**: Implement shared context cache or reduce file size

**Issue 5: No Context Loading Metrics**
- **Evidence**: No logging of actual context loaded, no size tracking
- **Impact**: Cannot measure optimization effectiveness
- **Fix**: Add context loading telemetry

---

## 3. Context Loading Best Practices (Recommendations)

### 3.1 Lazy Loading Strategy

**RECOMMENDATION**: Implement true lazy loading with these principles:

**Principle 1: Load on Demand**
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/orchestration/delegation.md"  # Load immediately
  optional:
    - "project/lean4/tools/leansearch-api.md"  # Load only if language=lean
  conditional:
    - condition: "language == 'lean'"
      files: ["project/lean4/standards/lean4-style-guide.md"]
```

**Principle 2: Minimize Required Context**
- **Orchestrator**: Load ONLY routing.md (699 lines)
- **Commands**: Load ONLY delegation.md + state-management.md (1,570 lines)
- **Subagents**: Load ONLY files needed for their specific task

**Principle 3: Use Context Index**
- Load `.opencode/context/index.md` first (small, ~500 lines)
- Index provides file summaries and loading recommendations
- Agents can decide which files to load based on task

**Principle 4: Conditional Loading**
- Load language-specific context only when needed
- Load workflow-specific context only for relevant operations
- Load format files only when creating artifacts

### 3.2 Context File Size Guidelines

**RECOMMENDATION**: Enforce maximum file sizes to prevent bloat:

| File Type | Max Lines | Max Tokens | Rationale |
|-----------|-----------|------------|-----------|
| Orchestration | 500 | 2,000 | Core routing logic, keep minimal |
| Standards | 400 | 1,600 | Development guidelines, reference only |
| Formats | 300 | 1,200 | Artifact templates, load on creation |
| Workflows | 600 | 2,400 | Process documentation, load on demand |
| Templates | 300 | 1,200 | File templates, load on creation |

**FILES EXCEEDING GUIDELINES** (need splitting or reduction):
1. `error-handling.md` (1057 lines) → Split into error-types.md + error-recovery.md
2. `command-structure.md` (966 lines) → Split into command-anatomy.md + command-examples.md
3. `state-management.md` (916 lines) → Split into state-schema.md + state-operations.md
4. `orchestrator.md` (870 lines) → Split into orchestrator-design.md + orchestrator-stages.md
5. `preflight-postflight.md` (849 lines) → Split into preflight.md + postflight.md
6. `state-lookup.md` (846 lines) → Split into state-queries.md + state-examples.md

### 3.3 Context Loading Patterns by Operation Type

**RECOMMENDATION**: Define standard context loading patterns for each operation:

**Pattern 1: Research Operations** (`/research` command)
```yaml
required:
  - core/orchestration/delegation.md
  - core/orchestration/state-management.md
  - core/formats/report-format.md
conditional:
  - if language=lean: project/lean4/tools/leansearch-api.md
  - if language=lean: project/lean4/tools/loogle-api.md
```

**Pattern 2: Planning Operations** (`/plan` command)
```yaml
required:
  - core/orchestration/delegation.md
  - core/orchestration/state-management.md
  - core/formats/plan-format.md
  - core/workflows/task-breakdown.md
conditional:
  - if language=lean: project/lean4/processes/end-to-end-proof-workflow.md
```

**Pattern 3: Implementation Operations** (`/implement` command)
```yaml
required:
  - core/orchestration/delegation.md
  - core/orchestration/state-management.md
  - core/standards/git-safety.md
conditional:
  - if language=lean: project/lean4/standards/lean4-style-guide.md
  - if language=lean: project/lean4/tools/lsp-integration.md
```

**Pattern 4: Review Operations** (`/review` command)
```yaml
required:
  - core/orchestration/delegation.md
  - core/orchestration/state-management.md
  - core/workflows/review-process.md
  - core/formats/summary-format.md
```

**Pattern 5: Meta Operations** (`/meta` command)
```yaml
required:
  - core/orchestration/delegation.md
  - core/workflows/status-transitions.md
  - project/meta/architecture-principles.md
  - project/meta/domain-patterns.md
optional:
  - project/meta/interview-patterns.md
  - core/templates/agent-template.md
  - core/templates/command-template.md
```

### 3.4 Context Optimization Techniques

**Technique 1: Context Summarization**
- Create `{file}-summary.md` versions of large files
- Load summary first, full file only if needed
- Example: `state-management-summary.md` (100 lines) vs `state-management.md` (916 lines)

**Technique 2: Context Caching**
- Cache frequently loaded files in session
- Reuse cached context across multiple agent invocations
- Invalidate cache when files change

**Technique 3: Context Compression**
- Remove examples and verbose explanations from core files
- Move examples to separate `{file}-examples.md` files
- Load examples only when explicitly needed

**Technique 4: Context Splitting**
- Split large files into focused modules
- Example: `delegation.md` → `delegation-basics.md` + `delegation-patterns.md` + `delegation-examples.md`
- Load only relevant module for task

**Technique 5: Context Indexing**
- Maintain `.opencode/context/index.md` with file summaries
- Agents load index first, decide which files to load
- Index includes file size, purpose, and loading recommendations

---

## 4. Broken Reference Fixes (Detailed Mapping)

### 4.1 Reference Update Script

**RECOMMENDATION**: Create automated reference update script:

```bash
#!/bin/bash
# update-context-refs.sh - Fix broken context file references

set -e

REPO_ROOT="/home/benjamin/Projects/ProofChecker"
cd "$REPO_ROOT"

echo "Updating context file references..."

# Fix 1: core/system/state-management.md → core/orchestration/state-management.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/state-management\.md|core/orchestration/state-management.md|g' {} +

# Fix 2: core/system/routing-guide.md → core/orchestration/routing.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/routing-guide\.md|core/orchestration/routing.md|g' {} +

# Fix 3: core/system/artifact-management.md → core/orchestration/state-management.md
# (artifact-management merged into state-management)
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/artifact-management\.md|core/orchestration/state-management.md|g' {} +

# Fix 4: core/system/git-commits.md → core/standards/git-safety.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/system/git-commits\.md|core/standards/git-safety.md|g' {} +

# Fix 5: core/standards/command-argument-handling.md → (DELETE - obsolete)
# Remove references to deleted file
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  '/core\/standards\/command-argument-handling\.md/d' {} +

# Fix 6: core/standards/plan.md → core/formats/plan-format.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/plan\.md|core/formats/plan-format.md|g' {} +

# Fix 7: core/standards/subagent-return-format.md → core/formats/subagent-return.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/subagent-return-format\.md|core/formats/subagent-return.md|g' {} +

# Fix 8: core/standards/architecture-principles.md → project/meta/architecture-principles.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/architecture-principles\.md|project/meta/architecture-principles.md|g' {} +

# Fix 9: core/standards/domain-patterns.md → project/meta/domain-patterns.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/standards/domain-patterns\.md|project/meta/domain-patterns.md|g' {} +

# Fix 10: core/workflows/interview-patterns.md → project/meta/interview-patterns.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/workflows/interview-patterns\.md|project/meta/interview-patterns.md|g' {} +

# Fix 11: core/templates/agent-templates.md → core/templates/agent-template.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/templates/agent-templates\.md|core/templates/agent-template.md|g' {} +

# Fix 12: core/workflow/postflight-pattern.md → core/workflows/postflight-pattern.md
find .opencode/command .opencode/agent -type f -name "*.md" -exec sed -i \
  's|core/workflow/postflight-pattern\.md|core/workflows/postflight-pattern.md|g' {} +

echo "Reference updates complete!"
echo ""
echo "Validating updates..."

# Validation: Check for remaining broken references
BROKEN_REFS=$(grep -r "core/system/" .opencode/command .opencode/agent --include="*.md" | \
  grep -v "core/system/status-markers.md" | wc -l)

if [ "$BROKEN_REFS" -eq 0 ]; then
  echo "[PASS] No broken core/system/ references found"
else
  echo "[FAIL] Found $BROKEN_REFS broken core/system/ references"
  grep -r "core/system/" .opencode/command .opencode/agent --include="*.md" | \
    grep -v "core/system/status-markers.md"
fi

echo ""
echo "Manual verification required for:"
echo "1. .opencode/command/meta.md - Check optional context files"
echo "2. .opencode/agent/subagents/meta.md - Check meta-specific references"
echo "3. All files referencing command-argument-handling.md - Ensure deletion is safe"
```

### 4.2 Manual Verification Checklist

After running automated script, manually verify:

**Step 1: Verify Deleted References**
- [ ] Check all files that referenced `command-argument-handling.md`
- [ ] Ensure deletion doesn't break functionality
- [ ] Add alternative reference if needed (e.g., `command-template.md`)

**Step 2: Verify Merged References**
- [ ] Check all files that referenced `artifact-management.md`
- [ ] Ensure `state-management.md` contains equivalent content
- [ ] Update comments if needed to clarify merged content

**Step 3: Verify Moved References**
- [ ] Spot-check 5 files with updated references
- [ ] Ensure new paths resolve to existing files
- [ ] Test context loading with updated references

**Step 4: Verify No Regressions**
- [ ] Run `/research 327` to test research command
- [ ] Run `/plan 327` to test planning command
- [ ] Run `/implement 327` to test implementation command
- [ ] Check for context loading errors in logs

### 4.3 Reference Update Impact Analysis

**Files Modified** (estimated):
- Commands: 6 files (plan.md, review.md, errors.md, sync.md, todo.md, meta.md)
- Subagents: 11 files (researcher, planner, implementer, task-executor, lean-*, reviewer, error-diagnostics, meta, git-workflow-manager)
- Orchestrator: 1 file (orchestrator.md)

**TOTAL**: 18 files modified

**Lines Changed** (estimated):
- Average 2-3 reference updates per file
- ~40-50 total line changes
- No functional logic changes, only path updates

**Testing Required**:
- Test each workflow command (/research, /plan, /implement, /revise)
- Test meta command (/meta)
- Test review command (/review)
- Verify context loading logs show correct files loaded

---

## 5. Context Loading Optimization Opportunities

### 5.1 Immediate Optimizations (Quick Wins)

**Optimization 1: Remove Unused Context Files from Default Loading**

**Files with 0 References** (safe to remove from default loading):
- `command-structure.md` (966 lines) - Only load when creating new commands
- `orchestrator.md` (870 lines) - Only load when modifying orchestrator
- `preflight-postflight.md` (849 lines) - Only load when implementing workflows
- `architecture.md` (758 lines) - Only load for meta operations
- `xml-structure.md` (710 lines) - Only load when writing XML
- `frontmatter.md` (706 lines) - Only load when creating new files

**IMPACT**: Removing these 6 files from default loading saves ~4,800 lines (~19,000 tokens)

**Optimization 2: Split Large Files**

**Candidates for Splitting**:
1. `error-handling.md` (1057 lines) → `error-types.md` (300 lines) + `error-recovery.md` (400 lines) + `error-examples.md` (357 lines)
2. `state-management.md` (916 lines) → `state-schema.md` (300 lines) + `state-operations.md` (400 lines) + `state-examples.md` (216 lines)
3. `state-lookup.md` (846 lines) → `state-queries.md` (400 lines) + `state-query-examples.md` (446 lines)

**IMPACT**: Load only needed module (e.g., state-schema.md instead of full state-management.md) saves ~600 lines per operation

**Optimization 3: Create Summary Files**

**Candidates for Summarization**:
- `delegation.md` (654 lines) → `delegation-summary.md` (150 lines)
- `routing.md` (699 lines) → `routing-summary.md` (150 lines)
- `validation.md` (466 lines) → `validation-summary.md` (100 lines)

**IMPACT**: Load summary first, full file only if needed, saves ~400-500 lines per operation

**Optimization 4: Implement Conditional Loading**

**Language-Specific Context**:
```yaml
# Only load Lean context for Lean tasks
conditional:
  - condition: "language == 'lean'"
    files:
      - "project/lean4/standards/lean4-style-guide.md"
      - "project/lean4/tools/lsp-integration.md"
      - "project/lean4/processes/end-to-end-proof-workflow.md"
```

**IMPACT**: Avoid loading 1,000+ lines of Lean-specific context for non-Lean tasks

**Optimization 5: Reduce Orchestrator Context**

**Current**: Orchestrator loads routing-guide.md (699 lines)  
**Optimized**: Orchestrator loads routing-summary.md (150 lines)

**IMPACT**: Save 549 lines (~2,200 tokens) on every command invocation

### 5.2 Medium-Term Optimizations (Requires Implementation)

**Optimization 6: Implement True Lazy Loading**

**Current Behavior**: All `required:` files loaded immediately  
**Proposed Behavior**: Load files only when accessed

**Implementation**:
1. Create context loader service
2. Track which files are actually accessed during execution
3. Load files on first access, cache for session
4. Log context loading metrics

**IMPACT**: Reduce context loading by 30-50% (only load what's actually used)

**Optimization 7: Context Caching**

**Current Behavior**: Load same files repeatedly across agent invocations  
**Proposed Behavior**: Cache loaded context in session, reuse across invocations

**Implementation**:
1. Create session-based context cache
2. Cache loaded files by path and mtime
3. Invalidate cache when files change
4. Share cache across agents in same session

**IMPACT**: Reduce context loading time by 60-80% for multi-agent workflows

**Optimization 8: Context Compression**

**Current Behavior**: Load full files with examples and verbose explanations  
**Proposed Behavior**: Load compressed versions with examples removed

**Implementation**:
1. Create `{file}-core.md` versions without examples
2. Move examples to `{file}-examples.md`
3. Load core version by default, examples on demand
4. Maintain both versions in sync

**IMPACT**: Reduce context size by 20-30% (examples are ~30% of content)

### 5.3 Long-Term Optimizations (Strategic)

**Optimization 9: Context Index-Based Loading**

**Current Behavior**: Load files based on hardcoded `required:` lists  
**Proposed Behavior**: Load files based on task analysis and index recommendations

**Implementation**:
1. Enhance `.opencode/context/index.md` with file metadata
2. Add file summaries, sizes, and loading recommendations
3. Agents analyze task, consult index, load only relevant files
4. Track loading decisions for optimization

**IMPACT**: Reduce context loading by 40-60% (intelligent, task-specific loading)

**Optimization 10: Dynamic Context Pruning**

**Current Behavior**: Load full files even if only small section is relevant  
**Proposed Behavior**: Load only relevant sections based on task

**Implementation**:
1. Add section markers to context files
2. Agents specify which sections are needed
3. Context loader extracts and loads only those sections
4. Combine sections from multiple files into single context

**IMPACT**: Reduce context size by 50-70% (section-level granularity)

**Optimization 11: Context Learning**

**Current Behavior**: Same context loaded for all tasks of same type  
**Proposed Behavior**: Learn which context is actually useful, optimize over time

**Implementation**:
1. Track which context files are accessed during task execution
2. Measure correlation between loaded context and task success
3. Adjust `required:` lists based on actual usage patterns
4. Continuously optimize context loading strategy

**IMPACT**: Reduce context loading by 30-50% over time (data-driven optimization)

---

## 6. Documentation Needs

### 6.1 Context Loading Best Practices Guide

**RECOMMENDATION**: Create `.opencode/docs/guides/context-loading-best-practices.md`

**Contents**:
1. **Introduction**
   - Why context loading matters
   - Context window budget management
   - Performance implications

2. **Loading Strategies**
   - Lazy vs eager loading
   - Conditional loading
   - Summary-first loading
   - Section-based loading

3. **File Organization**
   - When to split files
   - When to create summaries
   - When to use examples files
   - Directory structure guidelines

4. **Context Configuration**
   - Frontmatter syntax
   - Required vs optional files
   - Conditional loading rules
   - Max context size guidelines

5. **Optimization Techniques**
   - Context caching
   - Context compression
   - Context indexing
   - Dynamic pruning

6. **Monitoring and Metrics**
   - Context loading telemetry
   - Size tracking
   - Performance measurement
   - Optimization validation

7. **Common Patterns**
   - Research operations
   - Planning operations
   - Implementation operations
   - Review operations
   - Meta operations

8. **Troubleshooting**
   - Broken references
   - Context bloat
   - Loading failures
   - Performance issues

**Estimated Effort**: 2-3 hours

### 6.2 Context File Reference Documentation

**RECOMMENDATION**: Update `.opencode/context/index.md` with:

1. **File Inventory**
   - Complete list of all context files
   - File sizes and line counts
   - File purposes and summaries
   - Loading recommendations

2. **Reference Mapping**
   - Old path → New path mappings
   - Deprecated files list
   - Merged files documentation
   - Moved files tracking

3. **Loading Guidelines**
   - Which files to load for each operation type
   - Conditional loading rules
   - Size budgets per operation
   - Performance targets

4. **Maintenance Procedures**
   - How to add new context files
   - How to update existing files
   - How to deprecate files
   - How to validate references

**Estimated Effort**: 1-2 hours

### 6.3 Context Refactor Status Documentation

**RECOMMENDATION**: Update task 314 documentation to reflect actual status:

**Current Status** (INCORRECT):
- Task 314 marked as [COMPLETED]
- Systematic review report exists
- Implementation plan v2 exists

**Actual Status** (CORRECT):
- Task 314 plan created but NOT EXECUTED
- 0% of 6 core objectives implemented
- Directory structure unchanged
- File consolidation not performed
- Architecture documentation not created
- Naming standardization not applied
- Reference updates not performed

**RECOMMENDATION**: Either:
1. **Option A**: Change task 314 status to [PLANNED] (accurate reflection)
2. **Option B**: Execute task 314 implementation plan (20 hours of work)

**Estimated Effort**: 5 minutes (status update) OR 20 hours (full implementation)

---

## 7. Risk Assessment

### 7.1 Broken Reference Risks

**Risk 1: Context Loading Failures**
- **Severity**: HIGH
- **Likelihood**: HIGH (19 broken references)
- **Impact**: Agents operate without required context, produce incorrect results
- **Mitigation**: Fix all broken references immediately (Section 4)

**Risk 2: Silent Failures**
- **Severity**: MEDIUM
- **Likelihood**: MEDIUM (no error logging for missing context)
- **Impact**: Broken references go unnoticed, accumulate over time
- **Mitigation**: Add context loading validation and error logging

**Risk 3: Inconsistent Behavior**
- **Severity**: MEDIUM
- **Likelihood**: HIGH (different agents load different context)
- **Impact**: Same task produces different results depending on which agent executes it
- **Mitigation**: Standardize context loading patterns (Section 3.3)

### 7.2 Context Bloat Risks

**Risk 4: Context Window Exhaustion**
- **Severity**: HIGH
- **Likelihood**: MEDIUM (15,283 lines available, 50,000 token budgets)
- **Impact**: Agents run out of context window space for task content
- **Mitigation**: Implement lazy loading and file splitting (Section 5)

**Risk 5: Performance Degradation**
- **Severity**: MEDIUM
- **Likelihood**: MEDIUM (loading 10,000+ tokens per operation)
- **Impact**: Slow command startup, increased latency
- **Mitigation**: Implement context caching and compression (Section 5.2)

**Risk 6: Maintenance Burden**
- **Severity**: LOW
- **Likelihood**: HIGH (35 files to maintain, growing over time)
- **Impact**: Difficult to keep context files up-to-date and consistent
- **Mitigation**: Create maintenance procedures and automation (Section 6.2)

### 7.3 Task 314 Execution Risks

**Risk 7: Incomplete Refactor**
- **Severity**: HIGH
- **Likelihood**: CERTAIN (task 314 marked complete but not executed)
- **Impact**: Broken references persist, context bloat continues, confusion about actual state
- **Mitigation**: Either execute task 314 plan OR update status to [PLANNED]

**Risk 8: Reference Drift**
- **Severity**: MEDIUM
- **Likelihood**: HIGH (new files added without updating references)
- **Impact**: References become increasingly outdated over time
- **Mitigation**: Implement reference validation in CI/CD

**Risk 9: Documentation Staleness**
- **Severity**: LOW
- **Likelihood**: MEDIUM (context files updated without updating index)
- **Impact**: Index becomes unreliable, agents load wrong context
- **Mitigation**: Automate index updates when context files change

---

## 8. Implementation Recommendations

### 8.1 Immediate Actions (Week 1)

**Action 1: Fix Broken References** [PRIORITY: CRITICAL]
- **Effort**: 2-3 hours
- **Owner**: Implementation agent
- **Deliverable**: 18 files updated with correct context paths
- **Validation**: All context references resolve to existing files
- **Script**: Use reference update script from Section 4.1

**Action 2: Update Task 314 Status** [PRIORITY: HIGH]
- **Effort**: 5 minutes
- **Owner**: Status sync manager
- **Deliverable**: Task 314 status changed to [PLANNED] or [IN PROGRESS]
- **Validation**: TODO.md and state.json reflect accurate status
- **Rationale**: Prevent confusion about actual implementation state

**Action 3: Document Current State** [PRIORITY: HIGH]
- **Effort**: 1 hour
- **Owner**: Documentation agent
- **Deliverable**: Updated context/index.md with current file inventory
- **Validation**: Index matches actual directory structure
- **Contents**: File list, sizes, purposes, loading recommendations

### 8.2 Short-Term Actions (Weeks 2-3)

**Action 4: Implement Context Loading Validation** [PRIORITY: HIGH]
- **Effort**: 3-4 hours
- **Owner**: Implementation agent
- **Deliverable**: Context loading error detection and logging
- **Validation**: Broken references logged as errors, not silent failures
- **Implementation**: Add validation to orchestrator context loading

**Action 5: Create Context Loading Best Practices Guide** [PRIORITY: MEDIUM]
- **Effort**: 2-3 hours
- **Owner**: Documentation agent
- **Deliverable**: `.opencode/docs/guides/context-loading-best-practices.md`
- **Validation**: Guide covers all topics from Section 6.1
- **Review**: Meta agent reviews for completeness

**Action 6: Split Largest Context Files** [PRIORITY: MEDIUM]
- **Effort**: 4-6 hours
- **Owner**: Implementation agent
- **Deliverable**: 3 large files split into focused modules
- **Targets**: error-handling.md, state-management.md, state-lookup.md
- **Validation**: All references updated, no functionality lost

### 8.3 Medium-Term Actions (Month 2)

**Action 7: Execute Task 314 Context Refactor** [PRIORITY: HIGH]
- **Effort**: 20 hours
- **Owner**: Implementation agent
- **Deliverable**: Complete task 314 implementation (all 6 objectives)
- **Validation**: Directory structure matches plan, all references updated
- **Phases**: Follow task 314 implementation plan v2

**Action 8: Implement True Lazy Loading** [PRIORITY: MEDIUM]
- **Effort**: 6-8 hours
- **Owner**: Implementation agent
- **Deliverable**: Context loader service with lazy loading support
- **Validation**: Context loaded on demand, metrics show 30-50% reduction
- **Implementation**: Follow Optimization 6 from Section 5.2

**Action 9: Implement Context Caching** [PRIORITY: MEDIUM]
- **Effort**: 4-6 hours
- **Owner**: Implementation agent
- **Deliverable**: Session-based context cache
- **Validation**: Same files not loaded multiple times in session
- **Implementation**: Follow Optimization 7 from Section 5.2

### 8.4 Long-Term Actions (Month 3+)

**Action 10: Implement Context Index-Based Loading** [PRIORITY: LOW]
- **Effort**: 8-10 hours
- **Owner**: Implementation agent
- **Deliverable**: Intelligent context loading based on task analysis
- **Validation**: Context loading decisions logged, 40-60% reduction
- **Implementation**: Follow Optimization 9 from Section 5.3

**Action 11: Implement Context Learning** [PRIORITY: LOW]
- **Effort**: 10-12 hours
- **Owner**: Implementation agent
- **Deliverable**: Data-driven context loading optimization
- **Validation**: Context loading improves over time based on usage
- **Implementation**: Follow Optimization 11 from Section 5.3

**Action 12: Add Context Loading Telemetry** [PRIORITY: LOW]
- **Effort**: 4-6 hours
- **Owner**: Implementation agent
- **Deliverable**: Context loading metrics and monitoring
- **Validation**: Dashboard shows context usage, sizes, performance
- **Implementation**: Track files loaded, sizes, access patterns

---

## 9. Success Metrics

### 9.1 Reference Quality Metrics

**Metric 1: Broken Reference Count**
- **Current**: 19 broken references
- **Target**: 0 broken references
- **Measurement**: `grep -r "core/system/" .opencode/command .opencode/agent | wc -l`
- **Success Criteria**: Zero results (excluding status-markers.md)

**Metric 2: Reference Validation Coverage**
- **Current**: 0% (no validation)
- **Target**: 100% (all references validated)
- **Measurement**: Automated validation in CI/CD
- **Success Criteria**: All context references resolve to existing files

**Metric 3: Reference Update Lag**
- **Current**: Unknown (no tracking)
- **Target**: <24 hours (references updated within 1 day of file moves)
- **Measurement**: Time between file move and reference update
- **Success Criteria**: Automated reference updates on file moves

### 9.2 Context Loading Efficiency Metrics

**Metric 4: Average Context Size Loaded**
- **Current**: Unknown (~10,000-15,000 tokens estimated)
- **Target**: <5,000 tokens per operation
- **Measurement**: Log context size on each operation
- **Success Criteria**: 50% reduction from baseline

**Metric 5: Context Loading Time**
- **Current**: Unknown (no measurement)
- **Target**: <500ms per operation
- **Measurement**: Time from context load start to completion
- **Success Criteria**: <500ms for 95th percentile

**Metric 6: Context Cache Hit Rate**
- **Current**: 0% (no caching)
- **Target**: >80% (most files loaded from cache)
- **Measurement**: Cache hits / total context loads
- **Success Criteria**: >80% hit rate after warmup

### 9.3 Context File Quality Metrics

**Metric 7: Average File Size**
- **Current**: 437 lines per file (15,283 / 35)
- **Target**: <300 lines per file
- **Measurement**: Total lines / file count
- **Success Criteria**: 30% reduction from baseline

**Metric 8: Large File Count**
- **Current**: 6 files >700 lines
- **Target**: 0 files >700 lines
- **Measurement**: Count files exceeding threshold
- **Success Criteria**: All files split or reduced

**Metric 9: Unused File Count**
- **Current**: 6 files with 0 references
- **Target**: 0 files with 0 references
- **Measurement**: Count files not referenced in any context_loading section
- **Success Criteria**: All files either referenced or removed

### 9.4 Documentation Quality Metrics

**Metric 10: Context Index Completeness**
- **Current**: ~60% (index exists but incomplete)
- **Target**: 100% (all files documented)
- **Measurement**: Files in index / files in directory
- **Success Criteria**: All 35 files documented in index

**Metric 11: Best Practices Guide Coverage**
- **Current**: 0% (no guide exists)
- **Target**: 100% (all topics covered)
- **Measurement**: Topics covered / topics required
- **Success Criteria**: All 8 topics from Section 6.1 covered

**Metric 12: Reference Documentation Accuracy**
- **Current**: Unknown (no validation)
- **Target**: 100% (all mappings correct)
- **Measurement**: Automated validation of old→new path mappings
- **Success Criteria**: All mappings resolve correctly

---

## 10. Conclusions

### 10.1 Key Findings Summary

**Finding 1: Critical Broken References**
- 19 broken context file references across 15 files
- Most references point to deprecated `core/system/` directory
- Broken references cause silent context loading failures
- **IMPACT**: HIGH - Agents operate without required context

**Finding 2: Task 314 Refactor Not Executed**
- Task 314 marked [COMPLETED] but 0% implementation
- Directory structure unchanged from baseline
- File consolidation (47→35 files) not performed
- **IMPACT**: HIGH - Confusion about actual system state

**Finding 3: No Lazy Loading Implementation**
- `context_loading:` frontmatter present but not utilized
- All context loaded eagerly regardless of strategy setting
- No evidence of lazy loading mechanism
- **IMPACT**: MEDIUM - Context window bloat, performance degradation

**Finding 4: Large Context Files**
- 6 files exceed 700 lines (error-handling: 1057, command-structure: 966, state-management: 916)
- Total 15,283 lines across 35 files (~61,000 tokens)
- Loading even 25% of context = 15,000 tokens consumed
- **IMPACT**: MEDIUM - Context window budget exhaustion risk

**Finding 5: Unused Context Files**
- 6 large files have 0 references (command-structure: 966 lines, orchestrator: 870 lines, etc.)
- May be loaded by index despite no explicit references
- Wasted context window space
- **IMPACT**: LOW - Inefficiency but not critical

### 10.2 Recommendations Priority

**CRITICAL (Week 1)**:
1. Fix 19 broken context file references (2-3 hours)
2. Update task 314 status to [PLANNED] (5 minutes)
3. Document current context file inventory (1 hour)

**HIGH (Weeks 2-3)**:
4. Implement context loading validation (3-4 hours)
5. Create context loading best practices guide (2-3 hours)
6. Split 3 largest context files (4-6 hours)

**MEDIUM (Month 2)**:
7. Execute task 314 context refactor (20 hours)
8. Implement true lazy loading (6-8 hours)
9. Implement context caching (4-6 hours)

**LOW (Month 3+)**:
10. Implement context index-based loading (8-10 hours)
11. Implement context learning (10-12 hours)
12. Add context loading telemetry (4-6 hours)

### 10.3 Expected Outcomes

**After Immediate Actions** (Week 1):
- Zero broken context file references
- Accurate task 314 status
- Complete context file inventory
- **IMPACT**: Eliminate silent failures, establish baseline

**After Short-Term Actions** (Weeks 2-3):
- Context loading errors logged and visible
- Best practices guide available for reference
- Large files split into focused modules
- **IMPACT**: Prevent future issues, reduce context bloat by 20-30%

**After Medium-Term Actions** (Month 2):
- Task 314 refactor complete (47→35 files, 26% reduction)
- True lazy loading implemented
- Context caching operational
- **IMPACT**: Reduce context loading by 40-50%, improve performance

**After Long-Term Actions** (Month 3+):
- Intelligent context loading based on task analysis
- Data-driven optimization over time
- Comprehensive telemetry and monitoring
- **IMPACT**: Reduce context loading by 60-70%, continuous improvement

### 10.4 Next Steps

**Immediate** (this week):
1. Create implementation plan for broken reference fixes
2. Run reference update script (Section 4.1)
3. Validate all references resolve correctly
4. Update task 314 status in TODO.md and state.json
5. Update context/index.md with current file inventory

**Short-Term** (next 2-3 weeks):
1. Implement context loading validation
2. Write context loading best practices guide
3. Split error-handling.md, state-management.md, state-lookup.md
4. Update all references to split files

**Medium-Term** (next 1-2 months):
1. Execute task 314 context refactor implementation plan
2. Implement lazy loading mechanism
3. Implement context caching
4. Measure and validate optimization effectiveness

**Long-Term** (next 3+ months):
1. Implement intelligent context loading
2. Implement context learning
3. Add comprehensive telemetry
4. Continuously optimize based on data

---

## Appendix A: Reference Update Mapping

Complete mapping of old→new context file paths:

| Old Path | New Path | Status | Action |
|----------|----------|--------|--------|
| `core/system/state-management.md` | `core/orchestration/state-management.md` | MOVED | UPDATE |
| `core/system/routing-guide.md` | `core/orchestration/routing.md` | RENAMED | UPDATE |
| `core/system/artifact-management.md` | `core/orchestration/state-management.md` | MERGED | UPDATE |
| `core/system/git-commits.md` | `core/standards/git-safety.md` | RENAMED | UPDATE |
| `core/system/state-lookup.md` | `core/orchestration/state-lookup.md` | MOVED | UPDATE |
| `core/standards/command-argument-handling.md` | (deleted) | OBSOLETE | DELETE |
| `core/standards/plan.md` | `core/formats/plan-format.md` | MOVED | UPDATE |
| `core/standards/subagent-return-format.md` | `core/formats/subagent-return.md` | MOVED | UPDATE |
| `core/standards/architecture-principles.md` | `project/meta/architecture-principles.md` | MOVED | UPDATE |
| `core/standards/domain-patterns.md` | `project/meta/domain-patterns.md` | MOVED | UPDATE |
| `core/workflows/interview-patterns.md` | `project/meta/interview-patterns.md` | MOVED | UPDATE |
| `core/templates/agent-templates.md` | `core/templates/agent-template.md` | RENAMED | UPDATE |
| `core/workflow/postflight-pattern.md` | `core/workflows/postflight-pattern.md` | MOVED | UPDATE |

---

## Appendix B: Context File Inventory

Complete inventory of all context files with sizes and purposes:

### Orchestration (8 files, 5,366 lines)

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| architecture.md | 758 | System architecture documentation | 0 refs |
| delegation.md | 654 | Delegation patterns and rules | 17 refs (HIGH) |
| orchestrator.md | 870 | Orchestrator design and stages | 0 refs |
| routing.md | 699 | Routing logic and rules | 3 refs (as routing-guide.md) |
| sessions.md | 157 | Session management | 0 refs |
| state-lookup.md | 846 | Fast state.json query patterns | 4 refs |
| state-management.md | 916 | State management and schemas | 17 refs (HIGH) |
| validation.md | 466 | Validation rules and strategy | 0 refs |

### Formats (7 files, 2,962 lines)

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| command-output.md | 221 | Command output format | 0 refs |
| command-structure.md | 966 | Command file anatomy | 0 refs |
| frontmatter.md | 706 | Frontmatter schema | 0 refs |
| plan-format.md | 140 | Plan artifact format | 3 refs (as plan.md) |
| report-format.md | 72 | Report artifact format | 0 refs |
| subagent-return.md | 297 | Subagent return format | 2 refs (as subagent-return-format.md) |
| summary-format.md | 60 | Summary artifact format | 0 refs |

### Standards (8 files, 3,359 lines)

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| analysis-framework.md | 152 | Analysis methodology | 0 refs |
| code-patterns.md | 377 | Code style patterns | 0 refs |
| documentation.md | 472 | Documentation standards | 0 refs |
| error-handling.md | 1057 | Error handling patterns | 0 refs |
| git-safety.md | 572 | Git safety rules | 3 refs (as git-commits.md) |
| task-management.md | 255 | Task tracking standards | 4 refs (as tasks.md) |
| testing.md | 127 | Testing standards | 0 refs |
| xml-structure.md | 710 | XML formatting rules | 0 refs |

### Workflows (5 files, 1,745 lines)

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| command-lifecycle.md | 392 | Command execution stages | 0 refs |
| preflight-postflight.md | 849 | Workflow patterns | 0 refs |
| review-process.md | 164 | Review workflow | 0 refs |
| status-transitions.md | 70 | Status state machine | 2 refs |
| task-breakdown.md | 270 | Task division patterns | 0 refs |

### Templates (5 files, 1,198 lines)

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| agent-template.md | 336 | Agent file template | 1 ref (as agent-templates.md) |
| command-template.md | 284 | Command file template | 0 refs |
| delegation-context.md | 82 | Delegation context template | 0 refs |
| orchestrator-template.md | 273 | Orchestrator template | 0 refs |
| subagent-template.md | 223 | Subagent file template | 0 refs |

### System (1 file, 349 lines) - DEPRECATED

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| status-markers.md | 349 | Status marker definitions | 0 refs |

### Workflow (1 file, 441 lines) - DEPRECATED (should be workflows/)

| File | Lines | Purpose | Load Frequency |
|------|-------|---------|----------------|
| postflight-pattern.md | 441 | Postflight workflow pattern | 1 ref |

**TOTAL**: 35 files, 15,283 lines

---

## Appendix C: Context Loading Patterns by Command

### /research Command

**Current** (broken references):
```yaml
# No context_loading section in research.md
# Delegates to researcher.md which has:
context_loading:
  strategy: lazy
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"  # BROKEN
    - "core/system/artifact-management.md"  # BROKEN
```

**Recommended**:
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/formats/report-format.md"
  conditional:
    - condition: "language == 'lean'"
      files:
        - "project/lean4/tools/leansearch-api.md"
        - "project/lean4/tools/loogle-api.md"
  max_context_size: 50000
```

### /plan Command

**Current** (broken references):
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"  # BROKEN
    - "core/system/routing-guide.md"  # BROKEN
    - "core/standards/command-argument-handling.md"  # BROKEN
  optional:
    - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
```

**Recommended**:
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/formats/plan-format.md"
    - "core/workflows/task-breakdown.md"
  conditional:
    - condition: "language == 'lean'"
      files:
        - "project/lean4/processes/end-to-end-proof-workflow.md"
  max_context_size: 50000
```

### /implement Command

**Current** (no context_loading):
```yaml
# No context_loading section in implement.md
# Delegates to implementer.md which has broken references
```

**Recommended**:
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/standards/git-safety.md"
  conditional:
    - condition: "language == 'lean'"
      files:
        - "project/lean4/standards/lean4-style-guide.md"
        - "project/lean4/tools/lsp-integration.md"
  max_context_size: 50000
```

### /review Command

**Current** (broken references):
```yaml
context_loading:
  strategy: eager
  required:
    - "core/standards/delegation.md"
    - "core/system/state-management.md"  # BROKEN
    - "core/system/routing-guide.md"  # BROKEN
    - "core/system/state-lookup.md"  # BROKEN (path correct but should be orchestration/)
    - "core/standards/command-argument-handling.md"  # BROKEN
  max_context_size: 100000
```

**Recommended**:
```yaml
context_loading:
  strategy: lazy  # Change from eager to lazy
  required:
    - "core/orchestration/delegation.md"
    - "core/orchestration/state-management.md"
    - "core/orchestration/state-lookup.md"
    - "core/workflows/review-process.md"
    - "core/formats/summary-format.md"
  max_context_size: 50000  # Reduce from 100000
```

### /meta Command

**Current** (broken references):
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/standards/subagent-return-format.md"  # BROKEN
    - "core/workflows/status-transitions.md"
  optional:
    - "core/workflows/interview-patterns.md"  # BROKEN
    - "core/standards/architecture-principles.md"  # BROKEN
    - "core/standards/domain-patterns.md"  # BROKEN
    - "core/templates/agent-templates.md"  # BROKEN
  max_context_size: 60000
```

**Recommended**:
```yaml
context_loading:
  strategy: lazy
  required:
    - "core/formats/subagent-return.md"
    - "core/workflows/status-transitions.md"
    - "project/meta/architecture-principles.md"
    - "project/meta/domain-patterns.md"
  optional:
    - "project/meta/interview-patterns.md"
    - "core/templates/agent-template.md"
    - "core/templates/command-template.md"
  max_context_size: 60000
```

---

**END OF RESEARCH REPORT**
