# Implementation Plan: Task #938

- **Task**: 938 - port_logic_math_context_files
- **Status**: [NOT STARTED]
- **Effort**: 0.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/938_port_logic_math_context_files/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Port 2 context files from the Theory repository to ProofChecker. The original task scope of ~15 files has been reduced to just 2 files that are relevant to this project: `topological-foundations-domain.md` (logic domain) and `dependent-type-theory.md` (math/foundations). The remaining files support hyperintensional logics which are not relevant to this system.

### Research Integration

Research report `research-001.md` identified all source files and copy commands. This plan uses a subset of that research based on the user's scope override.

## Goals & Non-Goals

**Goals**:
- Port `topological-foundations-domain.md` to `.claude/context/project/logic/domain/`
- Port `dependent-type-theory.md` to `.claude/context/project/math/foundations/`
- Create the `math/foundations/` directory (does not exist)
- Update README.md files to reference new files

**Non-Goals**:
- Port hyperintensional logic files (bilateral, counterfactual, mereology, etc.)
- Port category theory files
- Port bilattice-theory, scott-topology, monoidal-posets files
- Update existing files (task-semantics.md, lattices.md) from Theory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Source file path changes | L | L | Verified paths exist before planning |
| Cross-references in files broken | L | L | Files are standalone domain documentation |

## Implementation Phases

### Phase 1: Setup and Copy Files [COMPLETED]

- **Dependencies:** None
- **Goal:** Create target directory and copy both context files from Theory

**Tasks:**
- [ ] Create directory `.claude/context/project/math/foundations/`
- [ ] Copy `topological-foundations-domain.md` from Theory to ProofChecker logic/domain/
- [ ] Copy `dependent-type-theory.md` from Theory to ProofChecker math/foundations/

**Timing:** 5 minutes

**Files to create/modify:**
- `.claude/context/project/math/foundations/` - new directory
- `.claude/context/project/logic/domain/topological-foundations-domain.md` - new file
- `.claude/context/project/math/foundations/dependent-type-theory.md` - new file

**Verification:**
- Both files exist and are non-empty
- File contents match source

---

### Phase 2: Update README Files [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Update logic and math README.md files to list the new files

**Tasks:**
- [ ] Add `topological-foundations-domain.md` to logic/README.md domain file list
- [ ] Add foundations subdirectory entry to math/README.md
- [ ] Add `dependent-type-theory.md` reference to math/README.md

**Timing:** 10 minutes

**Files to modify:**
- `.claude/context/project/logic/README.md` - add domain file reference
- `.claude/context/project/math/README.md` - add foundations section

**Verification:**
- README files reference new files
- File paths are correct

---

### Phase 3: Update index.json [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Add new files to the context index for discoverability

**Tasks:**
- [ ] Add entry for `topological-foundations-domain.md` to index.json
- [ ] Add entry for `dependent-type-theory.md` to index.json

**Timing:** 10 minutes

**Files to modify:**
- `.claude/context/index.json` - add 2 new entries

**Verification:**
- `jq` query finds new entries
- No JSON syntax errors

## Testing & Validation

- [ ] Both ported files exist in target locations
- [ ] README.md files updated with new references
- [ ] index.json contains entries for both new files
- [ ] No broken cross-references in ported files

## Artifacts & Outputs

- `.claude/context/project/logic/domain/topological-foundations-domain.md` (new)
- `.claude/context/project/math/foundations/dependent-type-theory.md` (new)
- `.claude/context/project/logic/README.md` (updated)
- `.claude/context/project/math/README.md` (updated)
- `.claude/context/index.json` (updated)
- `specs/938_port_logic_math_context_files/summaries/implementation-summary-{DATE}.md` (completion)

## Rollback/Contingency

If changes need to be reverted:
1. Delete new files: `topological-foundations-domain.md`, `dependent-type-theory.md`
2. Remove `math/foundations/` directory
3. Revert README.md and index.json changes via git
