# Research Report: Lean Plan Format Alignment

## Overview

This report documents the differences between the current plan format in `001-propositional-theorem-derivations-plan.md` and the standard /lean-plan format used by the lean-plan-architect agent.

## Key Differences Identified

### 1. Metadata Section Structure

**Current Format**:
```markdown
- **Status**: [NOT STARTED]
- **Created**: 2025-12-09
- **Workflow**: /lean-plan
- **Feature**: Complete remaining propositional theorem derivations (Tasks 27-29)
- **Lean File**: /path/to/file.lean
- **Lean Project**: /path/to/project
```

**Standard /lean-plan Format**:
```markdown
## Metadata
- **Date**: YYYY-MM-DD
- **Feature**: [One-line formalization description]
- **Scope**: [Mathematical domain and formalization approach]
- **Status**: [NOT STARTED]
- **Estimated Hours**: [low]-[high] hours
- **Complexity Score**: [Numeric value]
- **Structure Level**: 0
- **Estimated Phases**: [N]
- **Standards File**: [Absolute path to CLAUDE.md]
- **Research Reports**: [Links]
- **Lean File**: [Absolute path]
- **Lean Project**: [Absolute path]
```

**Required Changes**:
- Add `## Metadata` heading
- Rename `Created` to `Date`
- Add `Scope` field (mathematical domain description)
- Add `Estimated Hours` field (range format)
- Add `Complexity Score` field (numeric)
- Add `Structure Level` field (always 0 for Lean plans)
- Add `Estimated Phases` field
- Add `Standards File` field (path to CLAUDE.md)
- Add `Research Reports` field (links to reports)
- Reorder fields to standard sequence

### 2. Phase Metadata Format

**Current Format**:
```markdown
## Phase 1: Negation Introduction (NI) [NOT STARTED]

**Goal**: Prove `ni`: ...
**Estimated Hours**: 4-5 hours
```

**Standard /lean-plan Format**:
```markdown
### Phase 1: Negation Introduction (NI) [NOT STARTED]
implementer: lean
lean_file: /absolute/path/to/file.lean
dependencies: []

**Effort**: 3-4 hours
```

**Required Changes**:
- Change `## Phase` (H2) to `### Phase` (H3) - **CRITICAL for parser compatibility**
- Add `implementer: lean` field immediately after heading
- Add `lean_file:` field with absolute path
- Add `dependencies:` field with array notation (e.g., `[]` or `[1]`)
- Rename `**Estimated Hours**:` to `**Effort**:`
- Remove or relocate `**Goal**:` into theorem specifications

### 3. Phase Routing Summary Table

**Current Format**: Missing

**Standard /lean-plan Format**:
```markdown
## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
| 3 | lean | lean-implementer |
| 4 | lean | lean-implementer |
| 5 | software | implementer-coordinator |
```

**Required Changes**:
- Add `### Phase Routing Summary` section immediately after `## Implementation Phases` heading
- Include table mapping each phase to its implementer type

### 4. Theorem Specification Format

**Current Format**:
```markdown
### Implementation Steps

- [ ] `theorem_ni_step1`: Derive `(A :: Γ) ⊢ ⊥` from `h1` and `h2` using modus ponens
  - Goal: `(A :: Γ) ⊢ Formula.bot`
  - Strategy: `Derivable.modus_ponens (A :: Γ) B Formula.bot h1 h2`
```

**Standard /lean-plan Format**:
```markdown
**Theorems**:
- [ ] `theorem_name`: [Brief description]
  - Goal: `[Lean 4 type signature]`
  - Strategy: [Proof approach with tactics]
  - Complexity: Simple|Medium|Complex
  - Estimated: [hours] hours
```

**Required Changes**:
- Rename `### Implementation Steps` to `**Theorems**:` (or keep within consistent structure)
- Add `Complexity:` field to each theorem (Simple/Medium/Complex)
- Add `Estimated:` field to each theorem
- Ensure Goal uses proper Lean 4 type signature notation

### 5. Success Criteria Section

**Current Format**:
```markdown
### Success Criteria

- [ ] `ni` theorem compiles without error
- [ ] `ni` has zero `sorry` markers
- [ ] Docstring explains proof strategy
- [ ] Test case: `ni` applied to derive `⊢ ¬(A ∧ ¬A)`
```

**Standard /lean-plan Format**:
Success criteria is typically embedded in global `## Success Criteria` section at top level, or converted to testing patterns:

```markdown
**Testing**:
```bash
lake build
grep -c "sorry" path/to/file.lean
```

**Required Changes**:
- Move success criteria to global section at top
- Add bash testing block to each phase

### 6. Missing Sections

The standard /lean-plan format includes these sections not present in current plan:

1. **Key Discovery/Background section** (optional but valuable)
2. **Phase dependency graph visualization** (optional)
3. **Critical Risks and Mitigations** section
4. **Testing Strategy** section with per-phase tests
5. **Notes** section for important insights
6. **References** section

## Implementation Priority

### Critical (Must Fix for /lean-implement Compatibility):
1. Change `## Phase` to `### Phase` headings
2. Add `implementer: lean` field to all phases
3. Add `lean_file:` field to all Lean phases
4. Add `dependencies:` field to all phases (array format)
5. Add Phase Routing Summary table

### Important (Standard Compliance):
1. Add `## Metadata` heading
2. Reorder and add missing metadata fields
3. Add `Complexity:` and `Estimated:` to theorem specs

### Optional (Enhanced Quality):
1. Add global Success Criteria section
2. Add Risk Assessment section
3. Add dependency graph visualization
4. Add bash testing blocks

## Recommended Revision Approach

1. **Preserve content**: Keep all theorem specifications and proof strategies
2. **Restructure format**: Apply standard heading hierarchy and field order
3. **Add missing metadata**: Include all required fields for /lean-implement
4. **Maintain compatibility**: Ensure phases route correctly to lean-implementer

## Example Transformed Phase

**Before**:
```markdown
## Phase 1: Negation Introduction (NI) [NOT STARTED]

**Goal**: Prove `ni`: if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`

**Estimated Hours**: 4-5 hours

### Theorem Specification
...
```

**After**:
```markdown
### Phase 1: Negation Introduction (NI) [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Propositional.lean
dependencies: []

**Effort**: 4-5 hours

**Objective**: Prove `ni`: if `Γ, A ⊢ ¬B` and `Γ, A ⊢ B`, then `Γ ⊢ ¬A`

**Theorems**:
- [ ] `ni`: Negation Introduction
  - Goal: `(A B : Formula) → (h1 : (A :: Γ) ⊢ B.neg) → (h2 : (A :: Γ) ⊢ B) → Γ ⊢ A.neg`
  - Strategy: Apply modus_ponens to derive contradiction, then deduction theorem
  - Complexity: Medium
  - Estimated: 4-5 hours
...
```

---

**Report Generated**: 2025-12-09
**Research Complexity**: 2
**Purpose**: Document format differences for plan revision
