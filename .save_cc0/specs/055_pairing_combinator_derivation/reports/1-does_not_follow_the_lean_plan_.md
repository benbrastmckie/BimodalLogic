# Research Report: Lean Plan Standards Gap Analysis

## Metadata
- **Date**: 2025-12-09
- **Topic**: Gap analysis between existing pairing combinator plan and /lean-plan standards
- **Complexity**: 2 (Medium)
- **Related Plan**: [001-pairing-combinator-derivation-plan.md](../plans/001-pairing-combinator-derivation-plan.md)

## Executive Summary

The existing pairing combinator derivation plan (001-pairing-combinator-derivation-plan.md) was created manually and does not conform to the standards required by the /lean-plan command. This report identifies the specific gaps and provides recommendations for revision.

## Standards Sources Analyzed

1. **lean-plan-architect.md** (.claude/agents/lean-plan-architect.md) - Primary source for Lean-specific plan format
2. **plan-metadata-standard.md** (.claude/docs/reference/standards/plan-metadata-standard.md) - Canonical metadata field requirements
3. **lean-plan.md** (.claude/commands/lean-plan.md) - Command orchestration requirements

## Identified Gaps

### 1. Missing Required Metadata Fields

**Current Metadata** (lines 3-13):
```markdown
## Metadata
- **Feature**: Derive pairing combinator...
- **Status**: [NOT STARTED]
- **Created**: 2025-12-09
- **Complexity**: 3 (Deep...)
- **Estimated Effort**: 8-12 hours
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: .../Perpetuity.lean
- **TODO Reference**: Task 21...
```

**Missing Required Fields**:
- ❌ **Date** - Uses non-standard "Created" field name
- ❌ **Standards File** - Required absolute path to CLAUDE.md
- ❌ **Research Reports** - Required markdown links or "none"
- ❌ **Scope** - Recommended for complexity > 2

**Non-Standard Fields Present**:
- "Created" → Should be "Date"
- "Estimated Effort" → Should be "Estimated Hours"
- "TODO Reference" → Not in standard (can keep as workflow-specific)

### 2. Missing Phase Routing Summary

**Required** (per lean-plan-architect.md STEP 2):
```markdown
## Implementation Phases

### Phase Routing Summary
| Phase | Type | Implementer Agent |
|-------|------|-------------------|
| 1 | lean | lean-implementer |
| 2 | lean | lean-implementer |
```

**Current**: No Phase Routing Summary table exists.

### 3. Missing Phase-Level Metadata Fields

**Required Field Order** (per lean-plan-architect.md):
1. Phase heading: `### Phase N: Title [NOT STARTED]`
2. `implementer:` field (lean or software)
3. `lean_file:` field (for lean phases)
4. `dependencies:` field (array notation)

**Current Phase Format** (example from Phase 1):
```markdown
### Phase 1: Derive Flip Combinator (C) [NOT STARTED]

**Goal**: Derive the C (flip) combinator...
- **Lean File**: .../Perpetuity.lean
- **Goal**: {A B C : Formula} : ⊢ ...
- **Strategy**: Use S and K axioms...
- **Complexity**: Medium (20-25 lines)
- **dependencies**: []
```

**Issues**:
- Missing `implementer:` field entirely
- `lean_file:` field not in correct position (should be after heading)
- `dependencies:` uses bullet format, not field format
- **Goal** field exists twice (phase-level and task-level)

### 4. Task/Theorem Format Non-Compliance

**Required Theorem Format** (per lean-plan-architect.md):
```markdown
- [ ] `theorem_name`: [Brief description]
  - Goal: `∀ a b : Type, property a b`
  - Strategy: Use `Mathlib.Theorem.Name` via `exact` tactic
  - Complexity: Simple (direct application)
  - Estimated: 0.5 hours
```

**Current Task Format**:
```markdown
- [ ] `theorem_flip` - Derive flip combinator
  - Goal: `⊢ (A → B → C) → (B → A → C)`
  - Strategy:
    1. Use K axiom: ...
    2. Use S axiom...
  - Complexity: Medium
```

**Issues**:
- Missing "Estimated:" field for each theorem
- Strategy is multi-line numbered list instead of single-line tactic reference
- No explicit Mathlib theorem references in Strategy

### 5. Missing Lean-Specific Validation Section

**Required** (per lean-plan-architect.md STEP 3):
```markdown
**Testing**:
```bash
# Verify compilation
lake build

# Check no sorry markers
grep -c "sorry" path/to/file.lean
```
```

**Current**: Has "Success Criteria" with checkboxes, but not the programmatic bash validation block.

### 6. Phase Heading Level Inconsistency

**Standard**: `### Phase N:` (level 3 heading with three hashes)

**Current**: Uses `### Phase N:` ✓ (correct)

### 7. Missing Optional but Recommended Fields

- **Complexity Score**: Numeric value (0-100) - not present
- **Structure Level**: Should be 0 for single-file Lean plans - not present
- **Estimated Phases**: Count of phases - not present

## Compliance Summary

| Requirement | Status | Priority |
|-------------|--------|----------|
| Required Metadata Fields | ❌ Partial | HIGH |
| Phase Routing Summary | ❌ Missing | HIGH |
| Phase-Level `implementer:` | ❌ Missing | HIGH |
| Phase-Level `lean_file:` position | ❌ Wrong position | MEDIUM |
| Phase-Level `dependencies:` format | ❌ Wrong format | MEDIUM |
| Theorem `Estimated:` field | ❌ Missing | MEDIUM |
| Strategy single-line format | ❌ Non-standard | LOW |
| Testing bash block | ❌ Missing | MEDIUM |
| Optional metadata fields | ⚠️ Missing | LOW |

## Recommended Revisions

### Metadata Section Revision

Replace current metadata with standard-compliant format:

```markdown
## Metadata
- **Date**: 2025-12-09
- **Feature**: Derive pairing combinator (`A → B → A ∧ B`) from K and S propositional axioms
- **Scope**: Combinator calculus derivation proving pairing axiom as theorem using flip, app1, app2 lemmas
- **Status**: [NOT STARTED]
- **Estimated Hours**: 8-12 hours
- **Complexity Score**: 51
- **Structure Level**: 0
- **Estimated Phases**: 6
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/CLAUDE.md
- **Research Reports**:
  - [Mathlib Search Results](../reports/001-mathlib-theorems.md)
  - [Proof Strategies](../reports/002-proof-strategies.md)
  - [Project Structure](../reports/003-project-structure.md)
- **Lean File**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
```

### Add Phase Routing Summary

Insert after `## Implementation Phases` heading:

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
| 6 | software | implementer-coordinator |
```

### Phase Format Revision

Transform each phase to:

```markdown
### Phase 1: Derive Flip Combinator (C) [NOT STARTED]
implementer: lean
lean_file: /home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
dependencies: []

**Objective**: Derive the C (flip) combinator: `⊢ (A → B → C) → (B → A → C)`

**Complexity**: Medium

**Theorems**:
- [ ] `theorem_flip`: Derive flip combinator
  - Goal: `{A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))`
  - Strategy: Apply K axiom then S axiom redistribution, compose with B combinator
  - Complexity: Medium
  - Estimated: 2 hours

**Testing**:
```bash
lake build
grep -c "sorry" Logos/Core/Theorems/Perpetuity.lean
```

**Expected Duration**: 2 hours
```

## References

- [Lean Plan Architect Agent](.claude/agents/lean-plan-architect.md)
- [Plan Metadata Standard](.claude/docs/reference/standards/plan-metadata-standard.md)
- [/lean-plan Command](.claude/commands/lean-plan.md)
