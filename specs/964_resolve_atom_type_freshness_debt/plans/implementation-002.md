# Implementation Plan: Resolve Atom Type Freshness Debt (Revised)

- **Task**: 964 - resolve_atom_type_freshness_debt
- **Status**: [NOT STARTED]
- **Effort**: 8 hours (reduced from 14)
- **Dependencies**: Phases 1-5 completed
- **Research Inputs**: research-001.md, research-002.md, research-003.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan addresses the blocking issue discovered in research-003: the T-axiom (`H(phi) -> phi`) is NOT valid in TM logic because G/H use STRICT (irreflexive) temporal semantics. The standard Gabbay IRR proof relies on T-axiom to derive the contradiction.

**Key insight**: In strict temporal semantics, irreflexivity is a FRAME PROPERTY, not a syntactically derivable theorem. The proof must be semantic, showing that the canonical model construction enforces strict ordering.

### Previous Plan Status

| Phase | Status | Notes |
|-------|--------|-------|
| 1-5 | COMPLETED | Atom type infrastructure established |
| 6 | BLOCKED | T-axiom not available; syntactic proof fails |
| 7-8 | NOT STARTED | Superseded by new approach |

### Research Integration

- **research-003.md**: T-axiom is NOT part of TM logic; G/H are strict operators. Standard proof cannot derive `neg p in M'` from `H(neg p) in M'`. Recommends semantic approach.

## Goals & Non-Goals

**Goals**:
- Prove `canonicalR_irreflexive` using semantic argument about frame construction
- Remove the axiom declaration, replacing it with a theorem
- Verify downstream theorems compile without sorries

**Non-Goals**:
- Attempting the standard Gabbay IRR syntactic proof (blocked by missing T-axiom)
- Rewriting the existing 1360-line proof attempt

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Semantic proof requires new infrastructure | M | M | Build minimal frame properties; lean on existing canonical model lemmas |
| StrictOrderedTimeline definition not suitable | M | L | Verify irreflexivity is in typeclass; if not, derive from asymmetry |
| Integration with existing MCS machinery | L | L | Use existing SetMaximalConsistent properties |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `Bundle/CanonicalIrreflexivity.lean` at lines 1273, 1356

### Expected Resolution
- Phase 1 provides alternative proof path via semantic argument
- Existing sorries become unreachable (dead code) once theorem is proven

### New Sorries
- None. If semantic proof blocked, mark [BLOCKED] with requires_user_review: true

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom: `canonicalR_irreflexive` in `Canonical/CanonicalIrreflexivityAxiom.lean`

### Expected Resolution
- Phase 2 eliminates axiom by proving theorem semantically

## Implementation Phases

### Phase 1: Semantic Irreflexivity Proof [NOT STARTED]

- **Dependencies:** Phases 1-5 completed
- **Goal:** Prove canonicalR_irreflexive using frame semantics

**Approach:**

The canonical relation `CanonicalR` is defined in terms of `GContent` (formulas persisting to strict future). For self-accessibility `CanonicalR M M`:
- Semantically, this means the current world M accesses itself in the canonical frame
- In TM logic with strict G/H, this is definitionally impossible: strict operators exclude reflexive accessibility

**Proof Strategy:**

1. Show that `CanonicalR` is derived from the strict temporal frame
2. The frame's ordering relation is `StrictLT` (from `StrictOrderedTimeline`)
3. `StrictLT.irrefl` gives `not (t < t)` for any timeline point
4. Canonical model worlds correspond to timeline points
5. Hence `not (CanonicalR M M)` follows from frame irreflexivity

**Tasks:**
- [ ] Locate `StrictOrderedTimeline` definition and its `Irrefl` instance
- [ ] Trace how `CanonicalR` connects to frame ordering
- [ ] Write proof: `canonicalR_irrefl_semantic` using `StrictLT.irrefl`
- [ ] Verify proof compiles and closes all goals
- [ ] Run `lake build` to verify no errors

**Timing:** 4 hours

**Key Lemmas Needed:**
- `StrictOrderedTimeline.irrefl` or equivalent
- Connection between `CanonicalR` and frame ordering
- `canonicalWorld_embedding` (if exists) mapping MCS to frame points

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivitySemantic.lean` - new proof

**Verification:**
- `lean_goal` shows "no goals" at proof end
- `lake build Bimodal.Metalogic.Canonical.CanonicalIrreflexivitySemantic` succeeds
- `grep -n "\bsorry\b"` returns empty

---

### Phase 2: Replace Axiom with Theorem [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Remove the axiom and export semantic proof as theorem

**Tasks:**
- [ ] In `Canonical/CanonicalIrreflexivityAxiom.lean`:
  - Import the semantic proof module
  - Remove `axiom canonicalR_irreflexive`
  - Replace with `theorem canonicalR_irreflexive := canonicalR_irrefl_semantic`
- [ ] Update any downstream imports
- [ ] Run `lake build` on full metalogic module

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Verification:**
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- All downstream theorems compile

---

### Phase 3: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Verify entire codebase and clean up obsolete proof attempt

**Tasks:**
- [ ] Run `lake build` on entire project
- [ ] Verify downstream theorems are proven (no sorries):
  - `NoMaxOrder` on dense timeline
  - `NoMinOrder` on dense timeline
  - `DenselyOrdered` on dense timeline
- [ ] Consider removing or commenting out the obsolete `Bundle/CanonicalIrreflexivity.lean` syntactic proof attempt
- [ ] Run comprehensive checks: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/`

**Timing:** 1.5 hours

**Verification:**
- `lake build` succeeds
- `grep -rn "\bsorry\b" Theories/Bimodal/` shows no new sorries
- Axiom count reduced by 1

---

### Contingency: Hybrid Approach [FALLBACK]

If Phase 1's purely semantic approach is blocked (e.g., canonical model doesn't directly expose frame ordering):

**Alternative Strategy:**
1. Prove: "Any strict preorder is irreflexive"
2. Show: `CanonicalR` derives from a strict preorder
3. Conclude irreflexivity

This may require:
- Proving `CanonicalR` is transitive (via temp_4: `G(phi) -> G(G(phi))`)
- Proving `CanonicalR` is asymmetric (via duality lemmas)
- Deriving irreflexivity from `Asymm` or `Trans + Irrefl` typeclass

**Effort**: +2 hours if fallback needed

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Each phase commits successfully
- [ ] No regressions in existing functionality

## Artifacts & Outputs

- plans/implementation-002.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- New file: `CanonicalIrreflexivitySemantic.lean`

## Rollback/Contingency

- If semantic approach blocked: Mark [BLOCKED], document findings
- If frame ordering not directly accessible: Try hybrid approach (Contingency)
- Git checkpoints at each phase enable rollback
