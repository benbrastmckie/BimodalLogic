# Research Report: Task #449

**Task**: 449 - Truth Lemma
**Started**: 2026-01-13T19:14:00Z
**Completed**: 2026-01-13T19:45:00Z
**Effort**: 15-20 hours
**Priority**: Low
**Dependencies**: Task 448 (completed), Task 458 (completed)
**Sources/Inputs**: FiniteCanonicalModel.lean, Task 458 implementation summary, parent task 257 research
**Artifacts**: specs/449_truth_lemma/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The truth lemma requires proving correspondence between finite world state membership and semantic truth evaluation across six formula constructors
- Task 458 established the finite canonical model infrastructure with 17 sorry gaps, including 8 in the truth lemma itself
- Key missing infrastructure: closure monotonicity proof (closure_mono), subformula containment lemmas, and canonical box/temporal transfer properties
- Recommended approach: Complete closure_mono first (unlocks imp case), then use IH-based recursion for remaining cases with transfer properties from finite_task_rel

## Context & Scope

Task 449 is Phase 6 of the completeness proofs (Task 257). It proves the truth lemma for the finite canonical model, establishing:

```lean
theorem finite_truth_lemma (phi : Formula) (h : FiniteHistory phi)
    (t : FiniteTime (temporalBound phi)) (psi : Formula) (h_mem : psi ∈ closure phi) :
    (h.states t).models psi h_mem ↔ finite_truth_at phi h t psi
```

This is the key completeness lemma connecting syntactic membership in world states to semantic truth in the finite canonical model.

**Constraints**:
- Must work within the finite model structure established by Task 458
- Uses Int-based task relation (not the original Duration-based approach)
- Proof must be constructive where possible (Lean 4 with Mathlib)

## Findings

### Current State of finite_truth_lemma (FiniteCanonicalModel.lean:1188)

The theorem has the correct structure with proof by induction on formula constructors. Current status by case:

| Case | Status | Sorry Count | Blocking Issue |
|------|--------|-------------|----------------|
| atom | PROVEN | 0 | - |
| bot | PROVEN | 0 | - |
| imp | PARTIAL | 2 | Missing closure containment lemmas |
| box | PARTIAL | 2 | Missing canonical box property |
| all_past | PARTIAL | 2 | Missing temporal transfer composition |
| all_future | PARTIAL | 2 | Missing temporal transfer composition |

### Required Infrastructure

#### 1. Closure Monotonicity (closure_mono)

**Location**: FiniteCanonicalModel.lean:301
**Current**: `theorem closure_mono ... := sorry`

**Required proof**: If `psi ∈ closure phi`, then `closure psi ⊆ closure phi`.

This is needed because:
- The imp case requires proving `psi ∈ closure phi` and `chi ∈ closure phi` when `(psi.imp chi) ∈ closure phi`
- Similarly for box, all_past, all_future subformulas

**Proof strategy**:
```lean
theorem closure_mono {phi psi : Formula} (h : psi ∈ closure phi) :
    closure psi ⊆ closure phi := by
  intro chi h_chi
  simp [closure] at *
  -- chi is a subformula of psi, psi is a subformula of phi
  -- By transitivity of subformula relation (needs Formula.subformulas_trans)
  exact Formula.subformulas_trans h_chi h
```

**Missing lemma**: `Formula.subformulas_trans : chi ∈ subformulas psi → psi ∈ subformulas phi → chi ∈ subformulas phi`

This requires structural induction on Formula. The lemma should be added to SignedFormula.lean or Formula.lean.

#### 2. Subformula Containment Lemmas

Existing lemmas (proven):
- `self_mem_closure`: phi ∈ closure phi
- `imp_left_mem_closure`: psi ∈ closure (psi.imp chi)
- `imp_right_mem_closure`: chi ∈ closure (psi.imp chi)
- `box_sub_mem_closure`: psi ∈ closure (psi.box)
- `all_past_sub_mem_closure`: psi ∈ closure (psi.all_past)
- `all_future_sub_mem_closure`: psi ∈ closure (psi.all_future)

**Needed lemmas** (for using closure_mono in truth lemma):
```lean
-- When imp is in closure, both sides are too
lemma imp_in_closure_left (h : Formula.imp psi chi ∈ closure phi) :
    psi ∈ closure phi := closure_mono h (imp_left_mem_closure psi chi)

lemma imp_in_closure_right (h : Formula.imp psi chi ∈ closure phi) :
    chi ∈ closure phi := closure_mono h (imp_right_mem_closure psi chi)

-- Similarly for box and temporal operators
lemma box_in_closure (h : Formula.box psi ∈ closure phi) :
    psi ∈ closure phi := closure_mono h (box_sub_mem_closure psi)

lemma all_past_in_closure (h : Formula.all_past psi ∈ closure phi) :
    psi ∈ closure phi := closure_mono h (all_past_sub_mem_closure psi)

lemma all_future_in_closure (h : Formula.all_future psi ∈ closure phi) :
    psi ∈ closure phi := closure_mono h (all_future_sub_mem_closure psi)
```

#### 3. Canonical Box Property

The box case of the truth lemma requires showing:
- **Forward**: If `box(psi)` is true at state `t`, then `psi` is true at all histories at `t`
- **Backward**: If `psi` is true at all histories at `t`, then `box(psi)` is true at state `t`

**Issue**: The current finite_truth_at definition for box uses:
```lean
| Formula.box psi =>
    ∀ h' : FiniteHistory phi, finite_truth_at phi h' t psi
```

This quantifies over ALL finite histories, but the world state `h.states t` only captures ONE world state. The bridge requires:

**Canonical Property**: For the canonical model, if `box(psi)` is in a world state, then `psi` must be true at all accessible states. The finite_task_rel's box transfer property ensures this:

```lean
-- From finite_task_rel definition
(∀ psi : Formula,
  ∀ h_box : Formula.box psi ∈ closure phi,
  ∀ h_psi : psi ∈ closure phi,
  w.models (Formula.box psi) h_box → u.models psi h_psi)
```

**Strategy for box case**:
1. Forward: Use box_t (T axiom: box(psi) → psi) for the current history, then show consistency of box(psi) across all histories via canonical construction
2. Backward: Show that if psi holds at all histories, then box(psi) must be in the world state (by negation completeness of MCS)

**Missing piece**: Need to formalize that all FiniteHistory instances at the same time point share consistent modal properties.

#### 4. Temporal Transfer Composition

The temporal cases require showing:
- **Forward**: If `all_future(psi)` at time `t`, then `psi` at all `s > t`
- **Backward**: If `psi` at all `s > t`, then `all_future(psi)` at `t`

The finite_task_rel provides:
```lean
-- Future transfer: all_future(psi) at w implies psi at u when d > 0
(∀ psi : Formula,
  ∀ h_fut : Formula.all_future psi ∈ closure phi,
  ∀ h_psi : psi ∈ closure phi,
  d > 0 → w.models (Formula.all_future psi) h_fut → u.models psi h_psi)
```

**Strategy for temporal cases**:
1. Use FiniteHistory.respects_task to connect states at different times
2. Apply IH after establishing psi ∈ closure phi (via closure containment lemmas)
3. Use transfer properties from finite_task_rel

**Key insight from Task 458**: The FiniteHistory structure already enforces:
```lean
respects_task : ∀ t t' : FiniteTime k,
    finite_task_rel phi (states t) ((toInt k t') - (toInt k t)) (states t')
```

This provides the task relation between any two time points, which can be used with the transfer properties.

### Proof Strategy for Each Case

#### Atom Case (DONE)
Already proven. Uses definition of valuation.

#### Bot Case (DONE)
Already proven. Uses consistency (bot never true).

#### Imp Case (2 sorries)

**Forward** (h_imp → h_psi_true → chi true):
```lean
-- Have: (psi.imp chi) true at state t (h_imp)
-- Have: psi true semantically (h_psi_true)
-- Goal: chi true semantically

-- Step 1: Get h_psi : psi ∈ closure phi
have h_psi := imp_in_closure_left h_mem
-- Step 2: Get h_chi : chi ∈ closure phi
have h_chi := imp_in_closure_right h_mem
-- Step 3: Apply local consistency of world state
-- If imp true and psi true in world state, then chi true
have h_psi_state : (h.states t).models psi h_psi := by
  exact (ih_psi t h_psi).mpr h_psi_true
have h_chi_state := imp_correct (h.states t) psi chi h_mem h_psi h_chi h_imp h_psi_state
-- Step 4: Convert back via IH
exact (ih_chi t h_chi).mp h_chi_state
```

**Backward** (semantic implication → syntactic):
```lean
-- Have: finite_truth_at psi → finite_truth_at chi (h_impl)
-- Goal: (psi.imp chi) true at state t

-- This requires showing that if the semantic implication holds,
-- then the syntactic implication is in the world state.
-- By local consistency of FiniteWorldState.
```

#### Box Case (2 sorries)

This is the most challenging case. Requires establishing that the canonical model has the property that box(psi) in a state implies psi accessible everywhere.

**Forward**:
```lean
-- Have: box(psi) true at state t
-- Goal: for all h' : FiniteHistory phi, finite_truth_at phi h' t psi

intro h'
have h_psi := box_in_closure h_mem
-- Need: (h'.states t).models psi h_psi
-- By canonical property: box(psi) at any state implies psi at all accessible states
-- Since all histories at t are accessible (via nullity), psi holds
```

**Key insight**: For the finite canonical model, different histories at the same time point represent different "modal branches". The box operator semantics requires psi to hold in ALL branches.

#### Temporal Cases (4 sorries)

Similar structure to box but uses temporal transfer instead of modal transfer.

**all_future forward**:
```lean
-- Have: all_future(psi) true at state t
-- Goal: for all s > t, finite_truth_at phi h s psi

intro s h_s_lt
have h_psi := all_future_in_closure h_mem
-- Get duration from t to s
let d := (toInt k s) - (toInt k t)
have h_d_pos : d > 0 := by omega
-- Use respects_task to get finite_task_rel between states
have h_rel := h.respects_task t s
-- Apply future transfer from finite_task_rel
have h_s_psi : (h.states s).models psi h_psi := by
  exact h_rel.2.1 psi h_mem h_psi h_d_pos h_fut
-- Convert via IH
exact (ih t s h_psi).mp h_s_psi
```

### Lindenbaum Extension Dependency

The truth lemma itself does NOT require Lindenbaum directly. However:
- Weak/strong completeness (Task 450) requires Lindenbaum to construct countermodels
- The existence lemmas (finite_forward/backward_existence) require Lindenbaum

Task 472 is specifically for "Lindenbaum extension for finite closures" and is a medium priority follow-on task.

### Compositionality Gaps (Task 458)

The compositionality proof has 7 sorry gaps related to mixed-sign temporal durations. These don't block the truth lemma directly but affect:
- Proving respects_task for histories with complex time patterns
- Full verification of frame properties

**Recommendation**: Accept compositionality gaps for now; they represent edge cases in temporal reasoning that may require strengthening finite_task_rel.

## Decisions

1. **Focus on closure_mono first**: This single lemma unlocks the imp case and makes all subformula containment lemmas derivable.

2. **Accept box case complexity**: The box case requires the canonical property that is inherent to the construction. May need auxiliary lemmas about history consistency.

3. **Use respects_task for temporal cases**: The FiniteHistory structure already provides the key bridge via its respects_task field.

4. **Defer to Task 450 for completeness theorems**: The truth lemma is self-contained; completeness follows once truth lemma is proven.

## Recommendations

### Priority 1: Complete closure_mono (4-6 hours)

1. Add `Formula.subformulas_trans` to SignedFormula.lean:
```lean
theorem subformulas_trans {chi psi phi : Formula}
    (h1 : chi ∈ subformulas psi) (h2 : psi ∈ subformulas phi) :
    chi ∈ subformulas phi := by
  induction phi with
  | atom _ => simp [subformulas] at h2; subst h2; exact h1
  | bot => simp [subformulas] at h2; subst h2; exact h1
  | imp a b iha ihb =>
    simp [subformulas] at h2
    rcases h2 with rfl | h2
    · exact self_mem_subformulas _
    · cases List.mem_append.mp h2 with
      | inl ha => exact List.mem_cons_of_mem _ (List.mem_append_left _ (iha ha))
      | inr hb => exact List.mem_cons_of_mem _ (List.mem_append_right _ (ihb hb))
  -- Similar for box, all_past, all_future
```

2. Use it to prove closure_mono in FiniteCanonicalModel.lean

3. Add derived lemmas: imp_in_closure_left/right, box_in_closure, etc.

### Priority 2: Complete imp case (2-3 hours)

With closure_mono, the imp case becomes straightforward using:
- Local consistency of FiniteWorldState (already exists as imp_correct)
- IH for psi and chi at the same time point

### Priority 3: Complete box case (4-6 hours)

Requires careful reasoning about:
- Canonical property of box formulas
- All histories at same time point
- May need auxiliary lemma about modal consistency

### Priority 4: Complete temporal cases (3-4 hours)

Use respects_task from FiniteHistory structure:
- Provides finite_task_rel between any two time points
- Future/past transfer properties in finite_task_rel do the heavy lifting

### Estimated Total: 13-19 hours

This aligns with the task estimate of 15-20 hours.

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| closure_mono harder than expected | Medium | Fall back to case-by-case proofs for specific operators |
| Box case canonical property unclear | High | Consult Task 458 notes, may need to strengthen FiniteWorldState |
| Temporal cases need stronger respects_task | Medium | respects_task already provides full relation; should suffice |
| Compositionality gaps affect proof | Low | Gaps are for mixed-sign cases not needed in truth lemma |

## Appendix

### Search Queries Used

1. `lean_local_search "closure"` - Found closure definitions and theorems
2. `lean_local_search "truth_lemma"` - Found existing axiom in Completeness.lean
3. `lean_local_search "finite_task_rel"` - Found definition in FiniteCanonicalModel.lean
4. `lean_local_search "subformulas"` - Found subformulas definition in SignedFormula.lean
5. `lean_leansearch "truth lemma canonical model modal logic"` - Mathlib model theory
6. `lean_leanfinder "subformula closure finite type decidable"` - Finite/Fintype concepts
7. `lean_leansearch "subformula closure monotonicity inclusion"` - Closure monotonicity patterns

### Key Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean` - Main implementation
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` - Subformula definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean` - Formula type and properties
- `/home/benjamin/Projects/ProofChecker/specs/458_extend_canonical_history_full_domain/summaries/implementation-summary-20260113.md` - Task 458 completion summary

### References

- Task 257 plan (implementation-002.md): Overall completeness proof structure
- Task 458 summary: Finite canonical model infrastructure
- research-008.md: Agnostic duration construction (superseded by finite approach)
