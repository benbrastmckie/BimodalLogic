# Implementation Plan: Task #749 (Revised)

- **Task**: 749 - Establish sorry-free completeness using semantic_weak_completeness
- **Version**: 002
- **Created**: 2026-01-29
- **Status**: [BLOCKED]
- **Effort**: 8-12 hours (original estimate)
- **Actual**: 2 hours (architectural analysis)
- **Priority**: High
- **Dependencies**: None (builds on existing sorry-free semantic_weak_completeness)
- **Research Inputs**:
  - specs/749_establish_sorry_free_completeness_via_semantic_weak_completeness/reports/research-001.md
  - specs/749_establish_sorry_free_completeness_via_semantic_weak_completeness/summaries/implementation-summary-20260129.md
  - specs/755_implement_option_c_forward_truth_lemma/reports/research-001.md (Option C analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revision Rationale**: The original plan (v001) attempted to bridge truth correspondence by fixing sorries in TruthLemma.lean. The partial implementation revealed that those sorries are **architectural limitations**, not missing proofs:

1. **Box sorries (lines 366, 389)**: Universal quantification over ALL world histories requires semantic architecture changes
2. **Temporal backward sorries (lines 416, 438)**: Requires omega-rule (infinitely many premises), not expressible in TM logic

**New Approach**: Based on task 755 research, prove truth correspondence via **structural induction over the subformula closure** directly in SemanticCanonicalModel.lean. This avoids the TruthLemma.lean architecture and instead uses:
- The finite closure structure (`closure phi` is finite and contains all subformulas)
- `IsLocallyConsistent` properties ensuring assignments respect formula structure
- The existing sorry-free `semantic_weak_completeness` contrapositive construction

### Key Technical Insight

The goal is to prove:
```lean
theorem truth_at_implies_semantic_truth (phi : Formula) ... :
    truth_at (SemanticCanonicalModel phi) tau 0 phi →
    semantic_truth_at_v2 phi (tau.states 0 ht) (BoundedTime.origin ...) phi
```

This requires bridging:
- **Recursive truth** (`truth_at`): Evaluates formula by structural recursion
- **Assignment truth** (`semantic_truth_at_v2`): Looks up formula in FiniteWorldState's truth assignment

The solution is to prove that for formulas in the closure, the assignment IS consistent with recursion due to `IsLocallyConsistent` properties.

## Goals & Non-Goals

**Goals**:
- Prove `truth_at_imp_iff_semantic` for implication using local consistency and IH
- Prove `truth_at_box_iff_semantic` via box collapse in finite bounded-time model
- Prove `truth_at_G_iff_semantic` and `truth_at_H_iff_semantic` for temporal operators
- Remove sorry from `truth_at_implies_semantic_truth` via structural induction
- Achieve sorry-free `sorry_free_weak_completeness: valid phi -> provable phi`

**Non-Goals**:
- Fixing TruthLemma.lean sorries (architectural limitations, not our approach)
- Proving truth correspondence for arbitrary formulas (only need closure members)
- Full biconditional (only need forward direction for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Box collapse proof complexity | High | Medium | Box semantics collapse in finite model - same SemanticWorldState at same time |
| Temporal quantification bounds | Medium | Medium | BoundedTime domain is finite `[-k, k]`; use this constraint |
| IsLocallyConsistent gaps | Medium | Low | Audit and strengthen if needed before main proof |
| Type coercion complexity | Medium | Medium | Use existing helper lemmas, create new ones as needed |

## Implementation Phases

### Phase 1: Audit and Strengthen Local Consistency [BLOCKED]

**Goal**: Ensure `IsLocallyConsistent` includes all required properties for the inductive proof

**Status**: BLOCKED - Architectural analysis reveals fundamental limitations.

**Findings**:
The current `IsLocallyConsistent` definition (lines 88-104 in FiniteWorldState.lean) includes:
1. Bot is false: `∀ h : ⊥ ∈ closure φ, v ⟨⊥, h⟩ = false` ✓
2. Modus ponens: `v (ψ → χ) = true → v ψ = true → v χ = true` ✓
3. T-axiom for box: `v (□ψ) = true → v ψ = true` ✓

**Missing for biconditional truth correspondence**:
- **Negation completeness**: `v ψ = true ∨ v (¬ψ) = true` (NOT included)
- **Implication converse**: `(v ψ = false ∨ v χ = true) → v (ψ → χ) = true` (NOT included)
- **Temporal T-axiom**: `v (Gψ) = true → v ψ = true` and `v (Hψ) = true → v ψ = true` (NOT included)

**Root Cause**: `IsLocallyConsistent` captures SOUNDNESS properties (what can be derived from true assumptions), not COMPLETENESS properties (what MUST be true when something is valid). The missing properties are only guaranteed for MCS-derived states.

**Recommendation**: Do NOT strengthen `IsLocallyConsistent` as this would change the semantics of `FiniteWorldState`. Instead, pursue Alternative C (MCS-restricted proof) or accept that `semantic_weak_completeness` is the primary sorry-free result.

**Files reviewed**:
- `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean` - IsLocallyConsistent definition
- `Theories/Bimodal/Metalogic/FMP/Closure.lean` - closure_mcs_imp_iff, closure_mcs_neg_complete

---

### Phase 2: Truth Correspondence for Implication [BLOCKED]

**Goal**: Prove truth_at for implication matches semantic_truth_at_v2

**Status**: BLOCKED - Requires biconditional IH which requires negation completeness (missing).

**Analysis**:

The proof requires **mutual induction** (proving both directions simultaneously), similar to `truth_lemma_mutual` in Representation/TruthLemma.lean (lines 233-438).

**Forward direction** (truth_at imp → semantic imp):
- Need: `(truth_at ψ → truth_at χ) → assignment(ψ → χ) = true`
- Approach: Use negation completeness to case split on `assignment(ψ → χ)`
- If `assignment(¬(ψ → χ)) = true`, derive contradiction via mutual IH
- **BLOCKED**: Negation completeness not available for general FiniteWorldStates

**Backward direction** (semantic imp → truth_at imp):
- Have: `assignment(ψ → χ) = true`
- Want: `truth_at ψ → truth_at χ`
- Approach: Assume `truth_at ψ`, by backward IH get `semantic ψ`, apply modus ponens to get `semantic χ`, by forward IH get `truth_at χ`
- **BLOCKED**: Requires forward IH which requires forward direction

**Why MCS-derived states work**: `closure_mcs_imp_iff` provides:
```lean
(ψ → χ) ∈ S ↔ (ψ ∈ S → χ ∈ S)
```
This is exactly the biconditional needed, but only for MCS members, not arbitrary assignments.

**Timing**: N/A (blocked)

---

### Phase 3: Box Collapse in Finite Model [BLOCKED]

**Goal**: Prove box truth correspondence by showing box semantics collapse in finite bounded-time model

**Status**: BLOCKED - The "box collapse" claim is incorrect; different histories CAN have different states.

**Analysis**:

The original claim was: "Different WorldHistories at the same BoundedTime yield the same SemanticWorldState"

**This is FALSE**: The `htEquiv` equivalence only says two pairs (h1, t1) and (h2, t2) are equivalent if `h1.states t1 = h2.states t2`. Two different `FiniteHistory` objects CAN have different `FiniteWorldState`s at the same time.

**The real architectural issue** (from Representation/TruthLemma.lean lines 323-365):
- Box quantifies over ALL world histories: `∀ σ : WorldHistory F, truth_at M σ t ψ`
- Each history σ can have a DIFFERENT world state at time t
- Truth at atoms depends on the world state's assignment
- Therefore `truth_at M τ 0 (□ψ)` requires ψ to be true at ALL possible world states at time 0, not just τ's state

**Why this cannot be proven**:
From `truth_at (□ψ)`, we know ψ is true for all histories at time 0. But `semantic_truth_at_v2 (□ψ)` just checks the assignment at τ's world state. The assignment is independent of what other world states contain.

**Same issue as Representation/TruthLemma.lean**: The box cases there are also marked `sorry` (lines 366, 389) with the same architectural limitation documented.

**Timing**: N/A (blocked)

---

### Phase 4: Temporal Operators at Bounded Time [BLOCKED]

**Goal**: Prove truth correspondence for G (all_future) and H (all_past)

**Status**: BLOCKED - Same fundamental issue as implication: requires biconditional IH.

**Analysis**:

**Forward direction** (truth_at G → semantic G):
- Have: `∀ s ≥ 0, truth_at M τ s ψ` (G quantifies over all times ≥ 0)
- Want: `assignment(Gψ) = true` at τ's state at time 0
- **Issue**: The assignment at time 0 is independent of truth at other times

**Why finite domain doesn't help**:
Even with finite time domain [-k, k], the issue is NOT about finiteness. The problem is that:
1. `truth_at` at time s depends on τ's state at time s
2. `semantic_truth_at_v2` at time 0 checks the assignment at time 0
3. The assignment at time 0 for Gψ is a SINGLE boolean, not computed from other times

**For MCS-derived states**: The IndexedMCSFamily coherence conditions ensure:
- `Gψ ∈ mcs(t) → ψ ∈ mcs(s)` for all s ≥ t (`forward_G` condition)
- This allows forward truth lemma to work

**For arbitrary FiniteWorldStates**: No such coherence is guaranteed. The assignment can set Gψ=false even when ψ is true at all future times.

**Reference**: Same issue in Representation/TruthLemma.lean lines 403-438 (backward direction marked sorry due to omega-rule limitation).

**Timing**: N/A (blocked)

---

### Phase 5: Main Truth Correspondence Theorem [BLOCKED]

**Goal**: Prove `truth_at_implies_semantic_truth` by structural induction using phases 1-4

**Status**: BLOCKED - Phases 1-4 are all blocked, so this phase cannot proceed.

**Summary of Blocking Issues**:

| Case | Issue | Reference |
|------|-------|-----------|
| atom | ✓ PROVEN | `truth_at_atom_iff_semantic` lines 554-568 |
| bot | ✓ PROVEN | `truth_at_bot_iff_semantic` lines 573-588 |
| imp | BLOCKED | Requires negation completeness (Phase 2) |
| box | BLOCKED | Architectural: box quantifies over all histories (Phase 3) |
| all_past | BLOCKED | Same as imp + temporal coherence (Phase 4) |
| all_future | BLOCKED | Same as imp + temporal coherence (Phase 4) |

**Fundamental Architectural Issue**:

The `truth_at_implies_semantic_truth` theorem tries to prove that if `truth_at` (recursive evaluation) holds, then `semantic_truth_at_v2` (assignment lookup) holds. This is the "forward truth lemma" direction.

For MCS-derived world states, this works because the MCS construction ENSURES the assignment matches recursion. For arbitrary `FiniteWorldState`s (which only satisfy `IsLocallyConsistent`), the assignment is NOT constrained to match recursion.

**Documentation Update**: The theorem's docstring has been updated with detailed architectural analysis explaining why this sorry cannot be removed with the current FMP architecture.

**Timing**: N/A (blocked)

---

### Phase 6: Final Verification and Documentation [IN PROGRESS]

**Goal**: Document findings and update architecture notes

**Updated Tasks**:
- [x] Run `lake build` on project - succeeds with expected sorries
- [x] Update `truth_at_implies_semantic_truth` docstring with architectural analysis
- [ ] Update `Theories/Bimodal/Metalogic/FMP/README.md` with completeness status
- [ ] Create implementation summary documenting the architectural findings

**Timing**: 0.5 hours

**Files modified**:
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Updated docstring for `truth_at_implies_semantic_truth` with detailed architectural analysis (lines 609-653)
- This plan file - Updated phases 1-5 with blocking analysis

**Current Sorry Count in SemanticCanonicalModel.lean**:
- Line 226: `compositionality` (documented architectural limitation)
- Line 653: `truth_at_implies_semantic_truth` (forward truth lemma gap)

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.FMP.SemanticCanonicalModel` succeeds
- [ ] `lake build` full project succeeds
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean | grep -v compositionality` returns no matches
- [ ] `sorry_free_weak_completeness` is usable without warnings about sorries in dependencies

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean`
- Modified: `Theories/Bimodal/Metalogic/FMP/README.md`
- `summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If the full inductive proof proves intractable:

1. **Alternative A - MCS-Restricted Proof**: Restrict to MCS-derived world states only (simpler since `worldStateFromClosureMCS_models_iff` directly connects MCS membership to assignment)

2. **Alternative B - Accept Semantic Completeness**: Document that `semantic_weak_completeness` is the primary sorry-free completeness result, working for the "semantic truth" notion

3. **Document Obstacles**: If specific cases fail, document which (likely box or temporal) and why

The existing code remains functional - all changes are additive or modify only the sorry-marked theorems.

## References

- Task 755 research: `specs/755_implement_option_c_forward_truth_lemma/reports/research-001.md`
- Closure infrastructure: `Theories/Bimodal/Metalogic/FMP/Closure.lean`
- FiniteWorldState: `Theories/Bimodal/Metalogic/FMP/FiniteWorldState.lean`
- Truth semantics: `Theories/Bimodal/Semantics/Truth.lean`
