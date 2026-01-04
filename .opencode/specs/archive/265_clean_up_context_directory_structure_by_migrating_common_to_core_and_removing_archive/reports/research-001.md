# Research Report: Context Directory Cleanup - Migrate common/ to core/ and Remove archive/

**Task**: 265  
**Date**: 2025-12-29  
**Researcher**: AI Research Agent  
**Status**: [PASS]

---

## Executive Summary

This research provides a comprehensive analysis of the context directory cleanup task, cataloging all files in `.opencode/context/archive/` and `.opencode/context/common/`, analyzing 120 references throughout the codebase, identifying content conflicts, and developing a detailed migration strategy.

**Key Findings**:
- Archive directory contains only 2 deprecated redirect files (1,863 lines total) - safe to remove
- Common directory contains 29 files (5,223 lines), of which 5 are deprecated redirects and 24 are active
- 120 references to common/ paths found across 17 files, but 0 references in active commands/agents
- All active references are in archived specs and documentation files
- 3 files have duplicates in core/ with significant content differences
- Migration can be completed with zero breaking changes to active workflows

**Recommendation**: Proceed with phased migration - update references first (low risk), then migrate active files, finally remove deprecated files and archive/ directory.

---

## 1. Content Audit

### 1.1 Archive Directory Inventory

**Location**: `.opencode/context/archive/`

| File | Lines | Status | Content Type | Disposition |
|------|-------|--------|--------------|-------------|
| command-lifecycle.md | 1,138 | Deprecated | Workflow documentation | DELETE - Superseded by agent files |
| delegation-patterns.md | 725 | Deprecated redirect | Redirect to core/standards/delegation.md | DELETE - Redirect only |
| **Total** | **1,863** | **All deprecated** | - | **DELETE entire directory** |

**Analysis**:
- `command-lifecycle.md`: Created 2025-12-28, deprecated same day by Task 246 Phase 3
- `delegation-patterns.md`: 726-line file, but first 30 lines show it's a deprecated redirect
- Both files have no active references in commands or agents
- Safe to delete immediately after reference migration

### 1.2 Common Directory Inventory

**Location**: `.opencode/context/common/`

**Summary Statistics**:
- Total files: 29 markdown files + 1 JSON schema + 1 YAML template + 1 JSON template
- Total lines (markdown): 5,223 lines
- Deprecated files: 5 (redirect files, 111 lines)
- Active files: 24 (5,112 lines)
- Subdirectories: standards/, system/, workflows/, templates/, schemas/

#### 1.2.1 Deprecated Files (Redirect Only)

| File | Lines | Deprecated Date | Replacement | Disposition |
|------|-------|----------------|-------------|-------------|
| standards/subagent-return-format.md | 27 | 2025-12-29 | core/standards/delegation.md#return-format | DELETE after migration |
| system/status-markers.md | 27 | 2025-12-29 | core/system/state-management.md#status-markers | DELETE after migration |
| system/state-schema.md | 30 | 2025-12-29 | core/system/state-management.md#state-schemas | DELETE after migration |
| workflows/subagent-delegation-guide.md | 28 | 2025-12-29 | core/standards/delegation.md#delegation-patterns | DELETE after migration |
| workflows/delegation-patterns.md | 29 | 2025-12-29 | core/standards/delegation.md | DELETE after migration |
| **Total** | **141** | - | - | **DELETE after ref migration** |

**Deprecation Period**: Until 2025-01-29 (1 month from 2025-12-29)

#### 1.2.2 Active Files - Standards

| File | Lines | Content | Core Equivalent | Migration Strategy |
|------|-------|---------|-----------------|-------------------|
| analysis.md | 152 | Analysis artifact standards | None | MOVE to core/standards/ |
| code.md | 164 | Code quality standards | None | MOVE to core/standards/ |
| command-argument-handling.md | 443 | Command argument parsing | None | MOVE to core/standards/ |
| commands.md | 70 | Command structure standards | core/standards/command-structure.md (612 lines) | MERGE or MOVE |
| documentation.md | 438 | Documentation standards, NO EMOJI | None | MOVE to core/standards/ |
| frontmatter-standard.md | 711 | YAML frontmatter requirements | None | MOVE to core/standards/ |
| patterns.md | 213 | Common design patterns | None | MOVE to core/standards/ |
| plan.md | 104 | Implementation plan structure | None | MOVE to core/standards/ |
| report.md | 66 | Report artifact standards | None | MOVE to core/standards/ |
| summary.md | 60 | Summary artifact standards | None | MOVE to core/standards/ |
| tasks.md | 227 | Task entry format, validation | None | MOVE to core/standards/ |
| tests.md | 127 | Test requirements | None | MOVE to core/standards/ |
| **Subtotal** | **2,775** | - | - | **11 MOVE, 1 MERGE** |

#### 1.2.3 Active Files - System

| File | Lines | Content | Core Equivalent | Migration Strategy |
|------|-------|---------|-----------------|-------------------|
| artifact-management.md | 270 | Lazy directory creation, naming | None | MOVE to core/system/ |
| context-guide.md | 89 | Context loading patterns | core/system/context-loading-strategy.md (102 lines) | MERGE |
| git-commits.md | 34 | Targeted commit patterns | core/standards/git-safety.md (536 lines) | MERGE or keep separate |
| self-healing-guide.md | 149 | Self-healing mechanisms | None | MOVE to core/system/ |
| **Subtotal** | **542** | - | - | **2 MOVE, 2 MERGE** |

#### 1.2.4 Active Files - Workflows

| File | Lines | Content | Core Equivalent | Migration Strategy |
|------|-------|---------|-----------------|-------------------|
| delegation.md | 82 | Delegation context template | core/standards/delegation.md (510 lines) | MERGE or DELETE |
| review.md | 164 | Review workflow and criteria | None | MOVE to core/workflows/ |
| sessions.md | 157 | Session management | None | MOVE to core/workflows/ |
| task-breakdown.md | 270 | Task decomposition patterns | None | MOVE to core/workflows/ |
| **Subtotal** | **673** | - | - | **3 MOVE, 1 MERGE/DELETE** |

#### 1.2.5 Active Files - Templates

| File | Lines | Content | Core Equivalent | Migration Strategy |
|------|-------|---------|-----------------|-------------------|
| command-template.md | 135 | Template for new commands | core/templates/command-template.md (240 lines) | MERGE - core is newer |
| meta-guide.md | 462 | Meta-documentation guide | None | MOVE to core/templates/ |
| orchestrator-template.md | 273 | Orchestrator patterns | None | MOVE to core/templates/ |
| subagent-template.md | 222 | Template for new agents | None | MOVE to core/templates/ |
| **Subtotal** | **1,092** | - | - | **3 MOVE, 1 MERGE** |

#### 1.2.6 Active Files - Schemas

| File | Type | Content | Disposition |
|------|------|---------|-------------|
| frontmatter-schema.json | JSON | JSON schema for frontmatter validation | MOVE to core/schemas/ |
| state-template.json | JSON | State file template | MOVE to core/templates/ |
| subagent-frontmatter-template.yaml | YAML | Frontmatter template | MOVE to core/templates/ |

### 1.3 Core Directory Inventory (For Comparison)

**Location**: `.opencode/context/core/`

| Subdirectory | Files | Total Lines | Purpose |
|--------------|-------|-------------|---------|
| standards/ | 8 | 3,743 | Consolidated standards (delegation, error-handling, git-safety, etc.) |
| system/ | 5 | 1,965 | System patterns (orchestrator, routing, state-management, etc.) |
| templates/ | 1 | 240 | Command template (newer version) |
| workflows/ | 2 | 159 | Workflow patterns (delegation-guide, status-transitions) |
| **Total** | **16** | **6,107** | **Consolidated, modern structure** |

---

## 2. Reference Analysis

### 2.1 Reference Count Summary

| Reference Type | Count | Location |
|----------------|-------|----------|
| Total `@.opencode/context/common/` references | 120 | Across 17 files |
| References in active commands | 0 | None |
| References in active agents | 0 | None |
| References in archived specs | 78 | 11 archived spec files |
| References in active specs | 5 | TODO.md, 4 active spec files |
| References in documentation | 21 | SYSTEM_IMPROVEMENT_PLAN.md, PHASE_5_SUMMARY.md |
| References in context files | 16 | context/archive/, context/index.md, context/common/ |
| References to `@.opencode/context/archive/` | 0 | None found |

**Critical Finding**: Zero references in active commands and agents means migration has zero risk of breaking active workflows.

### 2.2 Detailed Reference Breakdown

#### 2.2.1 Most Referenced Files

| File Referenced | Reference Count | Status |
|-----------------|-----------------|--------|
| @.opencode/context/core/workflows/command-lifecycle.md | 18 | Deprecated, in archive/ |
| @.opencode/context/core/system/status-markers.md | 19 | Deprecated redirect |
| @.opencode/context/core/standards/subagent-return-format.md | 16 | Deprecated redirect |
| @.opencode/context/core/system/git-commits.md | 15 | Active, needs migration |
| @.opencode/context/core/workflows/subagent-delegation-guide.md | 13 | Deprecated redirect |
| @.opencode/context/core/system/artifact-management.md | 3 | Active, needs migration |
| @.opencode/context/core/standards/tasks.md | 1 | Active, needs migration |
| @.opencode/context/core/standards/plan.md | 1 | Active, needs migration |
| @.opencode/context/core/standards/summary.md | 1 | Active, needs migration |
| @.opencode/context/core/workflows/review.md | 3 | Active, needs migration |

#### 2.2.2 Files with References (Categorized)

**Archived Specs** (78 references, 11 files):
- `.opencode/specs/archive/127_context_refactor/plans/context-references-plan-001.md` (9 refs)
- `.opencode/specs/archive/199_optimize_self_healing/reports/research-001.md` (4 refs)
- `.opencode/specs/archive/237_investigate_and_systematically_fix_context_window_/reports/research-001.md` (3 refs)
- `.opencode/specs/archive/244_phase_1_context_index_and_research_frontmatter_prototype/reports/research-001.md` (5 refs)
- `.opencode/specs/211_standardize_command_lifecycle_procedures/plans/implementation-001.md` (4 refs)
- `.opencode/specs/211_standardize_command_lifecycle_procedures/reports/research-001.md` (1 ref)
- `.opencode/specs/229_review_and_optimize_orchestrator_command_integration_for_context_efficiency/reports/research-001.md` (17 refs)
- `.opencode/specs/233_research_and_fix_systematic_command_execution_failures_causing_incomplete_todomd_updates/reports/research-001.md` (5 refs)
- `.opencode/specs/234_systematically_improve_commands_to_protect_context_window_and_eliminate_confirmation_prompts/reports/research-001.md` (45 refs)
- Other archived specs (various)

**Active Specs** (5 references, 2 files):
- `.opencode/specs/TODO.md` (1 ref) - Reference in task 265 description
- Active spec research reports (4 refs)

**Documentation** (21 references, 2 files):
- `.opencode/SYSTEM_IMPROVEMENT_PLAN.md` (1 ref)
- `.opencode/PHASE_5_SUMMARY.md` (1 ref)
- Other documentation (19 refs)

**Context Files** (16 references, 4 files):
- `.opencode/context/archive/command-lifecycle.md` (16 refs) - Self-references
- `.opencode/context/index.md` (5 refs) - Index references
- `.opencode/context/core/templates/command-template.md` (4 refs) - Template references
- `.opencode/context/core/workflows/review.md` (3 refs) - Workflow references
- `.opencode/context/core/system/context-guide.md` (1 ref) - Guide reference

### 2.3 Reference Update Mapping

**Phase 1: Update Deprecated Redirect References** (63 references)

| Old Reference | New Reference | Count | Files Affected |
|---------------|---------------|-------|----------------|
| @.opencode/context/core/system/status-markers.md | @.opencode/context/core/system/state-management.md | 19 | 7 files |
| @.opencode/context/core/workflows/command-lifecycle.md | (Remove - deprecated) | 18 | 6 files |
| @.opencode/context/core/standards/subagent-return-format.md | @.opencode/context/core/standards/delegation.md | 16 | 6 files |
| @.opencode/context/core/workflows/subagent-delegation-guide.md | @.opencode/context/core/standards/delegation.md | 13 | 6 files |
| @.opencode/context/core/system/state-schema.md | @.opencode/context/core/system/state-management.md | 0 | 0 files |
| @.opencode/context/core/workflows/delegation-patterns.md | @.opencode/context/core/standards/delegation.md | 0 | 0 files |

**Phase 2: Update Active File References** (57 references)

| Old Reference | New Reference | Count | Files Affected |
|---------------|---------------|-------|----------------|
| @.opencode/context/core/system/git-commits.md | @.opencode/context/core/standards/git-safety.md | 15 | 7 files |
| @.opencode/context/core/system/artifact-management.md | @.opencode/context/core/system/artifact-management.md | 3 | 3 files |
| @.opencode/context/core/workflows/review.md | @.opencode/context/core/workflows/review.md | 3 | 2 files |
| @.opencode/context/core/standards/tasks.md | @.opencode/context/core/standards/tasks.md | 1 | 1 file |
| @.opencode/context/core/standards/plan.md | @.opencode/context/core/standards/plan.md | 1 | 1 file |
| @.opencode/context/core/standards/summary.md | @.opencode/context/core/standards/summary.md | 1 | 1 file |
| @.opencode/context/core/standards/patterns.md | @.opencode/context/core/standards/patterns.md | 1 | 1 file |
| @.opencode/context/core/system/context-guide.md | @.opencode/context/core/system/context-loading-strategy.md | 1 | 1 file |
| (Other active files) | (Corresponding core/ paths) | 31 | Various |

---

## 3. Content Conflict Resolution

### 3.1 Duplicate Files Analysis

Three files exist in both common/ and core/ with different content:

#### 3.1.1 subagent-return-format.md

**Common version**: 27 lines (deprecated redirect)
**Core version**: 212 lines (full specification)

**Conflict**: None - common/ is deprecated redirect, core/ is authoritative
**Resolution**: DELETE common/ version, KEEP core/ version
**Action**: Update all 16 references to point to core/standards/delegation.md

#### 3.1.2 delegation.md

**Common version**: 82 lines (delegation context template)
**Core version**: 510 lines (unified delegation standard)

**Conflict**: Different purposes
- Common: Temporary context template for delegation invocations
- Core: Comprehensive delegation standard with patterns, safety, return format

**Resolution**: MERGE or RENAME
- Option A: Merge common/ template into core/ as section
- Option B: Rename common/ to delegation-context-template.md and move to core/templates/
- **Recommendation**: Option B - keep as separate template, move to core/templates/

#### 3.1.3 command-template.md

**Common version**: 135 lines (older template)
**Core version**: 240 lines (newer template with frontmatter)

**Conflict**: Core version is newer and more comprehensive
**Resolution**: DELETE common/ version, KEEP core/ version
**Action**: Update 4 references to point to core/templates/command-template.md

### 3.2 Potential Merge Candidates

#### 3.2.1 git-commits.md vs git-safety.md

**core/system/git-commits.md**: 34 lines (targeted commit patterns)
**core/standards/git-safety.md**: 536 lines (comprehensive git safety guide)

**Analysis**:
- git-commits.md: Focused on commit message patterns and scoping
- git-safety.md: Comprehensive guide including safety, rollback, commit patterns

**Conflict**: git-safety.md already includes commit patterns
**Resolution**: MERGE git-commits.md into git-safety.md or DELETE if redundant
**Recommendation**: Review git-safety.md content, merge unique content from git-commits.md, delete common/ version

#### 3.2.2 context-guide.md vs context-loading-strategy.md

**core/system/context-guide.md**: 89 lines (context loading patterns)
**core/system/context-loading-strategy.md**: 102 lines (lazy-loading strategy)

**Analysis**:
- context-guide.md: General context loading patterns
- context-loading-strategy.md: Specific lazy-loading strategy from Task 244

**Conflict**: Overlapping content, different focus
**Resolution**: MERGE into single file
**Recommendation**: Merge into core/system/context-loading-strategy.md, preserve unique patterns

#### 3.2.3 commands.md vs command-structure.md

**core/standards/commands.md**: 70 lines (command structure standards)
**core/standards/command-structure.md**: 612 lines (comprehensive command structure)

**Analysis**:
- commands.md: Basic command structure standards
- command-structure.md: Comprehensive structure with frontmatter, stages, examples

**Conflict**: command-structure.md is superset
**Resolution**: DELETE commands.md if redundant, or MERGE unique content
**Recommendation**: Review for unique content, merge if needed, delete common/ version

### 3.3 Files Requiring Content Consolidation

| File Pair | Common Lines | Core Lines | Strategy |
|-----------|--------------|------------|----------|
| git-commits.md / git-safety.md | 34 | 536 | MERGE unique content into git-safety.md |
| context-guide.md / context-loading-strategy.md | 89 | 102 | MERGE into context-loading-strategy.md |
| commands.md / command-structure.md | 70 | 612 | DELETE commands.md (redundant) |
| delegation.md (common) / delegation.md (core) | 82 | 510 | RENAME common to delegation-context-template.md, MOVE to core/templates/ |

---

## 4. Migration Strategy

### 4.1 Migration Phases

**Phase 1: Reference Updates** (Low Risk)
- Update all 120 references to point to new locations
- Focus on deprecated redirects first (63 refs)
- Then update active file references (57 refs)
- Validate no broken references
- **Estimated Time**: 2-3 hours

**Phase 2: Content Migration** (Medium Risk)
- Move active files from common/ to core/
- Merge duplicate files
- Resolve content conflicts
- Update context index
- **Estimated Time**: 3-4 hours

**Phase 3: Cleanup** (Low Risk)
- Remove deprecated redirect files
- Remove archive/ directory
- Remove common/ directory
- Validate directory structure
- **Estimated Time**: 1 hour

**Phase 4: Validation** (Critical)
- Test all commands still function
- Verify context loading works
- Check for broken references
- Run validation scripts
- **Estimated Time**: 2 hours

**Total Estimated Time**: 8-12 hours (matches task estimate)

### 4.2 Detailed Migration Plan

#### Phase 1: Reference Updates (2-3 hours)

**Step 1.1: Update Deprecated Redirect References** (1 hour)

```bash
# Update status-markers.md references (19 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/system/status-markers\.md|@.opencode/context/core/system/state-management.md|g' {} +

# Update subagent-return-format.md references (16 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/standards/subagent-return-format\.md|@.opencode/context/core/standards/delegation.md|g' {} +

# Update subagent-delegation-guide.md references (13 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/workflows/subagent-delegation-guide\.md|@.opencode/context/core/standards/delegation.md|g' {} +

# Remove command-lifecycle.md references (18 refs) - deprecated, no replacement
find .opencode -type f -name "*.md" -exec sed -i '/@\.opencode\/context\/common\/workflows\/command-lifecycle\.md/d' {} +
```

**Step 1.2: Update Active File References** (1-2 hours)

```bash
# Update git-commits.md references (15 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/system/git-commits\.md|@.opencode/context/core/standards/git-safety.md|g' {} +

# Update artifact-management.md references (3 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/system/artifact-management\.md|@.opencode/context/core/system/artifact-management.md|g' {} +

# Update review.md references (3 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/workflows/review\.md|@.opencode/context/core/workflows/review.md|g' {} +

# Update tasks.md, plan.md, summary.md, patterns.md references (4 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/standards/tasks\.md|@.opencode/context/core/standards/tasks.md|g' {} +
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/standards/plan\.md|@.opencode/context/core/standards/plan.md|g' {} +
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/standards/summary\.md|@.opencode/context/core/standards/summary.md|g' {} +
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/standards/patterns\.md|@.opencode/context/core/standards/patterns.md|g' {} +

# Update context-guide.md references (1 ref)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/system/context-guide\.md|@.opencode/context/core/system/context-loading-strategy.md|g' {} +

# Update command-template.md references (4 refs)
find .opencode -type f -name "*.md" -exec sed -i 's|@\.opencode/context/core/templates/command-template\.md|@.opencode/context/core/templates/command-template.md|g' {} +
```

**Step 1.3: Validate References** (30 min)

```bash
# Check for remaining common/ references
rg "@\.opencode/context/common/" .opencode/

# Check for archive/ references
rg "@\.opencode/context/archive/" .opencode/

# Verify all references point to existing files
# (Manual verification or script)
```

#### Phase 2: Content Migration (3-4 hours)

**Step 2.1: Create Target Directories** (5 min)

```bash
mkdir -p .opencode/context/core/standards
mkdir -p .opencode/context/core/system
mkdir -p .opencode/context/core/workflows
mkdir -p .opencode/context/core/templates
mkdir -p .opencode/context/core/schemas
```

**Step 2.2: Migrate Standards Files** (1 hour)

```bash
# Move active standards files
mv .opencode/context/core/standards/analysis.md .opencode/context/core/standards/
mv .opencode/context/core/standards/code.md .opencode/context/core/standards/
mv .opencode/context/core/standards/command-argument-handling.md .opencode/context/core/standards/
mv .opencode/context/core/standards/documentation.md .opencode/context/core/standards/
mv .opencode/context/core/standards/frontmatter-standard.md .opencode/context/core/standards/
mv .opencode/context/core/standards/patterns.md .opencode/context/core/standards/
mv .opencode/context/core/standards/plan.md .opencode/context/core/standards/
mv .opencode/context/core/standards/report.md .opencode/context/core/standards/
mv .opencode/context/core/standards/summary.md .opencode/context/core/standards/
mv .opencode/context/core/standards/tasks.md .opencode/context/core/standards/
mv .opencode/context/core/standards/tests.md .opencode/context/core/standards/

# Delete redundant commands.md (covered by command-structure.md)
rm .opencode/context/core/standards/commands.md
```

**Step 2.3: Migrate System Files** (1 hour)

```bash
# Move active system files
mv .opencode/context/core/system/artifact-management.md .opencode/context/core/system/
mv .opencode/context/core/system/self-healing-guide.md .opencode/context/core/system/

# Merge context-guide.md into context-loading-strategy.md
# (Manual merge - preserve unique patterns)

# Merge git-commits.md into git-safety.md
# (Manual merge - add commit patterns section if missing)
```

**Step 2.4: Migrate Workflow Files** (30 min)

```bash
# Move active workflow files
mv .opencode/context/core/workflows/review.md .opencode/context/core/workflows/
mv .opencode/context/core/workflows/sessions.md .opencode/context/core/workflows/
mv .opencode/context/core/workflows/task-breakdown.md .opencode/context/core/workflows/

# Rename and move delegation.md template
mv .opencode/context/core/workflows/delegation.md .opencode/context/core/templates/delegation-context-template.md
```

**Step 2.5: Migrate Template Files** (30 min)

```bash
# Move active template files
mv .opencode/context/core/templates/meta-guide.md .opencode/context/core/templates/
mv .opencode/context/core/templates/orchestrator-template.md .opencode/context/core/templates/
mv .opencode/context/core/templates/subagent-template.md .opencode/context/core/templates/

# Move non-markdown templates
mv .opencode/context/core/templates/state-template.json .opencode/context/core/templates/
mv .opencode/context/core/templates/subagent-frontmatter-template.yaml .opencode/context/core/templates/

# Delete redundant command-template.md (core version is newer)
rm .opencode/context/core/templates/command-template.md
```

**Step 2.6: Migrate Schema Files** (10 min)

```bash
# Create schemas directory
mkdir -p .opencode/context/core/schemas

# Move schema files
mv .opencode/context/common/schemas/frontmatter-schema.json .opencode/context/core/schemas/
```

**Step 2.7: Update Context Index** (30 min)

Update `.opencode/context/index.md` to reflect new structure:
- Remove all references to common/
- Add new core/ file entries
- Update navigation section
- Update consolidation summary

#### Phase 3: Cleanup (1 hour)

**Step 3.1: Remove Deprecated Files** (10 min)

```bash
# Remove deprecated redirect files
rm .opencode/context/core/standards/subagent-return-format.md
rm .opencode/context/core/system/status-markers.md
rm .opencode/context/core/system/state-schema.md
rm .opencode/context/core/workflows/subagent-delegation-guide.md
rm .opencode/context/core/workflows/delegation-patterns.md

# Remove merged files
rm .opencode/context/core/system/git-commits.md
rm .opencode/context/core/system/context-guide.md
```

**Step 3.2: Remove Archive Directory** (5 min)

```bash
# Verify no active references
rg "@\.opencode/context/archive/" .opencode/

# Remove archive directory
rm -rf .opencode/context/archive/
```

**Step 3.3: Remove Common Directory** (5 min)

```bash
# Verify all files migrated
ls -la .opencode/context/common/

# Remove empty subdirectories
rmdir .opencode/context/common/standards
rmdir .opencode/context/common/system
rmdir .opencode/context/common/workflows
rmdir .opencode/context/common/templates
rmdir .opencode/context/common/schemas

# Remove common directory
rmdir .opencode/context/common/
```

**Step 3.4: Verify Directory Structure** (10 min)

```bash
# Verify final structure
tree .opencode/context/

# Expected structure:
# .opencode/context/
# ├── core/
# │   ├── standards/
# │   ├── system/
# │   ├── templates/
# │   ├── workflows/
# │   └── schemas/
# ├── project/
# │   ├── lean4/
# │   ├── logic/
# │   ├── repo/
# │   ├── math/
# │   └── physics/
# ├── system/
# └── index.md
```

**Step 3.5: Update Documentation** (30 min)

Update documentation to reflect new structure:
- Update SYSTEM_IMPROVEMENT_PLAN.md
- Update PHASE_5_SUMMARY.md
- Update any migration documentation
- Update context/index.md final summary

#### Phase 4: Validation (2 hours)

**Step 4.1: Reference Validation** (30 min)

```bash
# Check for broken references
rg "@\.opencode/context/common/" .opencode/
rg "@\.opencode/context/archive/" .opencode/

# Verify all core/ references point to existing files
for ref in $(rg -o "@\.opencode/context/core/[^ ]*" .opencode/ | sort -u); do
  file="${ref#@}"
  if [ ! -f "$file" ]; then
    echo "BROKEN: $ref"
  fi
done
```

**Step 4.2: Command Testing** (1 hour)

Test all workflow commands:
```bash
# Test /research command
# Test /plan command
# Test /implement command
# Test /revise command
# Test /review command
# Test /task command
# Test /todo command
```

**Step 4.3: Context Loading Validation** (20 min)

Verify context files load correctly:
- Check orchestrator loads routing context
- Check agents load execution context
- Verify lazy-loading works
- Check context window usage

**Step 4.4: Final Validation** (10 min)

```bash
# Run any validation scripts
# Verify git status clean
# Check for any errors in logs
```

### 4.3 File Mapping Table

Complete mapping of all files from common/ to core/:

| Source (common/) | Destination (core/) | Action | Notes |
|------------------|---------------------|--------|-------|
| standards/analysis.md | standards/analysis.md | MOVE | No conflict |
| standards/code.md | standards/code.md | MOVE | No conflict |
| standards/command-argument-handling.md | standards/command-argument-handling.md | MOVE | No conflict |
| standards/commands.md | - | DELETE | Redundant with command-structure.md |
| standards/documentation.md | standards/documentation.md | MOVE | No conflict |
| standards/frontmatter-standard.md | standards/frontmatter-standard.md | MOVE | No conflict |
| standards/patterns.md | standards/patterns.md | MOVE | No conflict |
| standards/plan.md | standards/plan.md | MOVE | No conflict |
| standards/report.md | standards/report.md | MOVE | No conflict |
| standards/subagent-return-format.md | - | DELETE | Deprecated redirect |
| standards/summary.md | standards/summary.md | MOVE | No conflict |
| standards/tasks.md | standards/tasks.md | MOVE | No conflict |
| standards/tests.md | standards/tests.md | MOVE | No conflict |
| system/artifact-management.md | system/artifact-management.md | MOVE | No conflict |
| system/context-guide.md | system/context-loading-strategy.md | MERGE | Merge into existing |
| system/git-commits.md | standards/git-safety.md | MERGE | Merge into existing |
| system/self-healing-guide.md | system/self-healing-guide.md | MOVE | No conflict |
| system/state-schema.md | - | DELETE | Deprecated redirect |
| system/status-markers.md | - | DELETE | Deprecated redirect |
| workflows/delegation.md | templates/delegation-context-template.md | RENAME+MOVE | Different purpose |
| workflows/delegation-patterns.md | - | DELETE | Deprecated redirect |
| workflows/review.md | workflows/review.md | MOVE | No conflict |
| workflows/sessions.md | workflows/sessions.md | MOVE | No conflict |
| workflows/subagent-delegation-guide.md | - | DELETE | Deprecated redirect |
| workflows/task-breakdown.md | workflows/task-breakdown.md | MOVE | No conflict |
| templates/command-template.md | - | DELETE | Core version newer |
| templates/meta-guide.md | templates/meta-guide.md | MOVE | No conflict |
| templates/orchestrator-template.md | templates/orchestrator-template.md | MOVE | No conflict |
| templates/subagent-template.md | templates/subagent-template.md | MOVE | No conflict |
| templates/state-template.json | templates/state-template.json | MOVE | No conflict |
| templates/subagent-frontmatter-template.yaml | templates/subagent-frontmatter-template.yaml | MOVE | No conflict |
| schemas/frontmatter-schema.json | schemas/frontmatter-schema.json | MOVE | No conflict |

**Summary**:
- MOVE: 24 files
- DELETE: 8 files (5 deprecated redirects, 3 redundant)
- MERGE: 2 files
- RENAME+MOVE: 1 file
- **Total**: 35 files processed

---

## 5. Risk Assessment

### 5.1 Breaking Changes Analysis

**Risk Level**: LOW

**Rationale**:
1. Zero references in active commands and agents
2. All references are in archived specs and documentation
3. Deprecated files already have 1-month deprecation period
4. Migration can be done incrementally with validation at each step

**Potential Breaking Changes**:

| Change Type | Risk | Impact | Mitigation |
|-------------|------|--------|------------|
| Reference updates | LOW | Archived specs may have broken links | Update all references before file moves |
| File moves | LOW | Context loading may fail if references not updated | Validate references before cleanup |
| File deletions | LOW | Deprecated redirects may be referenced | Keep redirects until 2025-01-29 |
| Content merges | MEDIUM | Merged content may lose information | Manual review of merges |

### 5.2 Impact on Active Tasks

**Active Tasks Analysis**:
- Task 189: research_divide_flag (researched) - No impact
- Task 221: fix_comprehensive_status_update_failures (completed) - No impact
- Task 226: fix_review_command (completed) - No impact
- Task 240: systematically_investigate_and_fix_persistent_workflow_command_stage_7_postflight_failures (researched) - No impact
- Task 256: add_meta_command_from_openagents_with_system_builder_subagents (planned) - No impact

**Conclusion**: Zero impact on active tasks

### 5.3 Impact on Active Workflows

**Workflow Analysis**:
- /research command: No common/ references - No impact
- /plan command: No common/ references - No impact
- /implement command: No common/ references - No impact
- /revise command: No common/ references - No impact
- /review command: No common/ references - No impact
- /task command: No common/ references - No impact
- /todo command: No common/ references - No impact

**Conclusion**: Zero impact on active workflows

### 5.4 Validation Steps

**Pre-Migration Validation**:
1. Verify all references identified
2. Verify target directories exist or can be created
3. Verify no active commands/agents reference common/
4. Backup current state

**During Migration Validation**:
1. After each file move: Verify file exists at destination
2. After reference updates: Verify no broken references
3. After merges: Verify merged content is complete
4. After deletions: Verify no active references

**Post-Migration Validation**:
1. Run all workflow commands
2. Verify context loading works
3. Check for broken references
4. Verify directory structure correct
5. Run any automated tests

### 5.5 Rollback Strategy

**Rollback Triggers**:
- Broken references found after migration
- Commands fail to execute
- Context loading fails
- Critical information lost in merges

**Rollback Procedure**:
1. Restore from git commit before migration
2. Identify specific failure point
3. Fix issue in isolation
4. Re-attempt migration with fix

**Rollback Prevention**:
- Use git commits at each phase
- Validate at each step
- Manual review of merges
- Test commands before final cleanup

---

## 6. Implementation Approach

### 6.1 Recommended Approach: Phased Migration

**Rationale**:
- Minimizes risk by validating at each step
- Allows rollback at any point
- Provides clear checkpoints
- Enables incremental testing

**Phases**:
1. Reference Updates (2-3 hours) - Update all 120 references
2. Content Migration (3-4 hours) - Move and merge files
3. Cleanup (1 hour) - Remove deprecated files and directories
4. Validation (2 hours) - Test and verify

**Alternative: Atomic Migration**:
- Single commit with all changes
- Higher risk, faster execution
- Harder to rollback
- **Not recommended** due to complexity

### 6.2 Testing Strategy

**Unit Testing**:
- Test each file move individually
- Verify file exists at destination
- Verify file content unchanged (except merges)

**Integration Testing**:
- Test context loading after migration
- Test command execution after migration
- Test reference resolution after migration

**Regression Testing**:
- Run all workflow commands
- Verify no broken references
- Check context window usage
- Verify git commits work

**Validation Testing**:
- Run validation scripts
- Check for errors in logs
- Verify directory structure
- Check git status

### 6.3 Dependencies Between Steps

**Critical Dependencies**:
1. Reference updates MUST complete before file moves
2. File moves MUST complete before deletions
3. Validation MUST occur after each phase

**Parallel Opportunities**:
- Reference updates can be done in parallel (different file types)
- File moves can be done in parallel (different subdirectories)
- Validation can be done incrementally

### 6.4 Git Commit Strategy

**Recommended Commits**:

1. **Commit 1**: Update deprecated redirect references
   - Message: "task 265: update deprecated redirect references (63 refs)"
   - Scope: All files with deprecated references

2. **Commit 2**: Update active file references
   - Message: "task 265: update active file references (57 refs)"
   - Scope: All files with active references

3. **Commit 3**: Migrate standards files
   - Message: "task 265: migrate core/standards/ to core/standards/"
   - Scope: 11 standards files

4. **Commit 4**: Migrate system files
   - Message: "task 265: migrate core/system/ to core/system/"
   - Scope: 4 system files + merges

5. **Commit 5**: Migrate workflow files
   - Message: "task 265: migrate core/workflows/ to core/workflows/"
   - Scope: 4 workflow files

6. **Commit 6**: Migrate template and schema files
   - Message: "task 265: migrate core/templates/ and common/schemas/ to core/"
   - Scope: 6 template files + 1 schema

7. **Commit 7**: Remove deprecated files and directories
   - Message: "task 265: remove deprecated files and archive/ directory"
   - Scope: 8 deprecated files + archive/ + common/

8. **Commit 8**: Update context index and documentation
   - Message: "task 265: update context index and documentation"
   - Scope: index.md, SYSTEM_IMPROVEMENT_PLAN.md, etc.

**Total**: 8 commits, each with clear scope and purpose

---

## 7. Validation Checklist

### 7.1 Pre-Migration Checklist

- [ ] All references identified (120 total)
- [ ] All files cataloged (29 common/, 2 archive/)
- [ ] Target directories identified
- [ ] Backup created (git commit)
- [ ] Migration plan reviewed
- [ ] Risk assessment complete
- [ ] Rollback strategy defined

### 7.2 Phase 1 Validation (Reference Updates)

- [ ] All deprecated redirect references updated (63 refs)
- [ ] All active file references updated (57 refs)
- [ ] No broken references found
- [ ] Git commit created
- [ ] Validation script run

### 7.3 Phase 2 Validation (Content Migration)

- [ ] All standards files moved (11 files)
- [ ] All system files moved (4 files)
- [ ] All workflow files moved (4 files)
- [ ] All template files moved (6 files)
- [ ] All schema files moved (1 file)
- [ ] All merges completed (2 files)
- [ ] All deletions completed (8 files)
- [ ] Context index updated
- [ ] Git commits created (6 commits)
- [ ] Validation script run

### 7.4 Phase 3 Validation (Cleanup)

- [ ] All deprecated files removed (5 files)
- [ ] Archive directory removed
- [ ] Common directory removed
- [ ] Directory structure verified
- [ ] Documentation updated
- [ ] Git commit created
- [ ] Validation script run

### 7.5 Phase 4 Validation (Final Testing)

- [ ] All workflow commands tested
- [ ] Context loading verified
- [ ] No broken references found
- [ ] Directory structure correct
- [ ] Git status clean
- [ ] Validation script run
- [ ] Final review complete

---

## 8. Rollback Procedure

### 8.1 Rollback Triggers

**Immediate Rollback**:
- Critical command failure
- Context loading failure
- Data loss detected
- Broken references in active workflows

**Deferred Rollback**:
- Broken references in archived specs
- Minor documentation issues
- Non-critical validation failures

### 8.2 Rollback Steps

**Step 1: Identify Failure Point**
- Determine which phase failed
- Identify specific commit
- Document failure reason

**Step 2: Restore from Git**
```bash
# Identify last good commit
git log --oneline

# Rollback to last good commit
git reset --hard <commit-hash>

# Verify rollback successful
git status
```

**Step 3: Analyze Failure**
- Review error logs
- Identify root cause
- Determine fix

**Step 4: Fix and Retry**
- Apply fix in isolation
- Test fix
- Re-attempt migration

### 8.3 Partial Rollback

If only specific files need rollback:

```bash
# Rollback specific file
git checkout <commit-hash> -- <file-path>

# Verify file restored
git diff <file-path>
```

---

## 9. Recommendations

### 9.1 Primary Recommendation: Phased Migration

**Recommendation**: Proceed with phased migration as outlined in Section 4.

**Rationale**:
1. Zero risk to active workflows (no active references)
2. Clear validation at each step
3. Easy rollback if issues arise
4. Matches task estimate (8-12 hours)

**Benefits**:
- Minimizes risk
- Provides clear checkpoints
- Enables incremental testing
- Allows for course correction

**Risks**:
- Slightly longer execution time
- More git commits
- Requires discipline to validate at each step

### 9.2 Alternative Recommendation: Atomic Migration

**Recommendation**: Single commit with all changes

**Rationale**:
- Faster execution (6-8 hours)
- Single git commit
- Simpler to review

**Benefits**:
- Faster completion
- Cleaner git history
- Less overhead

**Risks**:
- Higher risk if issues arise
- Harder to rollback
- Less validation
- **Not recommended** for this task

### 9.3 Content Merge Recommendations

**git-commits.md → git-safety.md**:
- Review git-safety.md for commit pattern coverage
- If missing, add "Commit Message Patterns" section
- Preserve targeted commit examples from git-commits.md
- Delete git-commits.md after merge

**context-guide.md → context-loading-strategy.md**:
- Merge general patterns into lazy-loading strategy
- Preserve unique examples
- Update section headings for clarity
- Delete context-guide.md after merge

**commands.md → command-structure.md**:
- Verify command-structure.md covers all content
- If redundant, delete commands.md
- If unique content, merge into command-structure.md

**delegation.md (common) → delegation-context-template.md**:
- Rename to delegation-context-template.md
- Move to core/templates/
- Keep as separate template (different purpose than core/standards/delegation.md)

### 9.4 Reference Update Recommendations

**Deprecated Redirects**:
- Update all references immediately
- Remove redirect files after 1-month deprecation period (2025-01-29)
- Document deprecation in migration notes

**Active Files**:
- Update references before moving files
- Validate references after updates
- Test context loading after updates

**Archive References**:
- Update archived spec references for completeness
- Low priority (archived specs not actively used)
- Can be done in parallel with active references

### 9.5 Validation Recommendations

**Automated Validation**:
- Create validation script to check for broken references
- Run after each phase
- Include in git pre-commit hook

**Manual Validation**:
- Test all workflow commands after migration
- Verify context loading works
- Check context window usage

**Continuous Validation**:
- Monitor for errors after migration
- Check logs for context loading issues
- Verify git commits work correctly

---

## 10. Conclusion

### 10.1 Summary

This research has comprehensively analyzed the context directory cleanup task, identifying:
- 2 files in archive/ (1,863 lines) - all deprecated, safe to remove
- 29 files in common/ (5,223 lines) - 5 deprecated, 24 active
- 120 references to common/ paths - 0 in active commands/agents
- 3 duplicate files with content conflicts - all resolvable
- Clear migration path with zero risk to active workflows

### 10.2 Key Findings

1. **Zero Active References**: No active commands or agents reference common/ or archive/, eliminating risk of breaking active workflows

2. **Deprecated Files**: 5 deprecated redirect files in common/ can be safely removed after reference updates

3. **Content Conflicts**: 3 duplicate files have clear resolution strategies (merge or delete)

4. **Migration Complexity**: Moderate - 120 references to update, 24 files to move, 2 files to merge, 8 files to delete

5. **Time Estimate**: 8-12 hours matches task estimate, with clear phase breakdown

### 10.3 Next Steps

1. **Immediate**: Review this research report
2. **Planning**: Create implementation plan based on Section 4 migration strategy
3. **Execution**: Proceed with phased migration
4. **Validation**: Test at each phase, validate final state
5. **Completion**: Update TODO.md, create git commits, mark task [COMPLETED]

### 10.4 Success Criteria

- [ ] No files remain in context/archive/
- [ ] No files remain in context/common/
- [ ] All unique content migrated to core/ or project/
- [ ] All 120 references updated to point to new locations
- [ ] No broken context references
- [ ] Context index updated
- [ ] All commands and agents still function correctly
- [ ] Directory structure simplified (only core/ and project/)

---

## Appendices

### Appendix A: Complete File Inventory

**Archive Directory** (2 files, 1,863 lines):
1. command-lifecycle.md (1,138 lines) - Deprecated
2. delegation-patterns.md (725 lines) - Deprecated redirect

**Common Directory** (29 files, 5,223 lines):

**Deprecated** (5 files, 141 lines):
1. standards/subagent-return-format.md (27 lines)
2. system/status-markers.md (27 lines)
3. system/state-schema.md (30 lines)
4. workflows/subagent-delegation-guide.md (28 lines)
5. workflows/delegation-patterns.md (29 lines)

**Active - Standards** (12 files, 2,775 lines):
1. analysis.md (152 lines)
2. code.md (164 lines)
3. command-argument-handling.md (443 lines)
4. commands.md (70 lines)
5. documentation.md (438 lines)
6. frontmatter-standard.md (711 lines)
7. patterns.md (213 lines)
8. plan.md (104 lines)
9. report.md (66 lines)
10. summary.md (60 lines)
11. tasks.md (227 lines)
12. tests.md (127 lines)

**Active - System** (4 files, 542 lines):
1. artifact-management.md (270 lines)
2. context-guide.md (89 lines)
3. git-commits.md (34 lines)
4. self-healing-guide.md (149 lines)

**Active - Workflows** (4 files, 673 lines):
1. delegation.md (82 lines)
2. review.md (164 lines)
3. sessions.md (157 lines)
4. task-breakdown.md (270 lines)

**Active - Templates** (4 files, 1,092 lines):
1. command-template.md (135 lines)
2. meta-guide.md (462 lines)
3. orchestrator-template.md (273 lines)
4. subagent-template.md (222 lines)

**Active - Schemas/Templates** (3 files):
1. schemas/frontmatter-schema.json
2. templates/state-template.json
3. templates/subagent-frontmatter-template.yaml

### Appendix B: Reference Breakdown by File

**Files with Most References**:
1. `.opencode/specs/234_systematically_improve_commands_to_protect_context_window_and_eliminate_confirmation_prompts/reports/research-001.md` (45 refs)
2. `.opencode/specs/229_review_and_optimize_orchestrator_command_integration_for_context_efficiency/reports/research-001.md` (17 refs)
3. `.opencode/context/archive/command-lifecycle.md` (16 refs)
4. `.opencode/specs/archive/127_context_refactor/plans/context-references-plan-001.md` (9 refs)
5. `.opencode/specs/archive/244_phase_1_context_index_and_research_frontmatter_prototype/reports/research-001.md` (5 refs)

**Files with Active References** (non-archived):
1. `.opencode/specs/TODO.md` (1 ref) - Task 265 description
2. `.opencode/context/index.md` (5 refs) - Index references
3. `.opencode/SYSTEM_IMPROVEMENT_PLAN.md` (1 ref)
4. `.opencode/PHASE_5_SUMMARY.md` (1 ref)

### Appendix C: Validation Scripts

**Reference Validation Script**:
```bash
#!/bin/bash
# validate-references.sh

echo "Checking for common/ references..."
common_refs=$(rg "@\.opencode/context/common/" .opencode/ | wc -l)
echo "Found $common_refs references to common/"

echo "Checking for archive/ references..."
archive_refs=$(rg "@\.opencode/context/archive/" .opencode/ | wc -l)
echo "Found $archive_refs references to archive/"

echo "Checking for broken core/ references..."
broken=0
for ref in $(rg -o "@\.opencode/context/core/[^ ]*" .opencode/ | sort -u); do
  file="${ref#@}"
  if [ ! -f "$file" ]; then
    echo "BROKEN: $ref"
    ((broken++))
  fi
done
echo "Found $broken broken references"

if [ $common_refs -eq 0 ] && [ $archive_refs -eq 0 ] && [ $broken -eq 0 ]; then
  echo "PASS: All references valid"
  exit 0
else
  echo "FAIL: References need attention"
  exit 1
fi
```

**Directory Structure Validation Script**:
```bash
#!/bin/bash
# validate-structure.sh

echo "Validating directory structure..."

# Check archive/ removed
if [ -d ".opencode/context/archive" ]; then
  echo "FAIL: archive/ directory still exists"
  exit 1
fi

# Check common/ removed
if [ -d ".opencode/context/common" ]; then
  echo "FAIL: common/ directory still exists"
  exit 1
fi

# Check core/ exists
if [ ! -d ".opencode/context/core" ]; then
  echo "FAIL: core/ directory missing"
  exit 1
fi

# Check core/ subdirectories
for dir in standards system workflows templates schemas; do
  if [ ! -d ".opencode/context/core/$dir" ]; then
    echo "FAIL: core/$dir directory missing"
    exit 1
  fi
done

echo "PASS: Directory structure valid"
exit 0
```

---

## Sources and Citations

1. Task 265 description in `.opencode/specs/TODO.md`
2. Context index at `.opencode/context/index.md`
3. Task 246 consolidation summary (Phase 3 completion)
4. Task 240 OpenAgents migration research
5. File system analysis via `find`, `wc`, `ls` commands
6. Reference analysis via `rg` (ripgrep) searches
7. Content analysis via `head`, `diff`, `cat` commands
8. Git history analysis for file creation dates
9. State.json analysis for active task tracking
10. Command and agent file analysis for active references

---

**Research Completed**: 2025-12-29  
**Total Research Time**: ~2 hours  
**Confidence Level**: High  
**Recommendation**: Proceed with phased migration
