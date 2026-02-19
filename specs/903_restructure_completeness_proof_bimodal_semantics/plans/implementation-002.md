# Implementation Plan: Task #903 (Revised)

- **Task**: 903 - Restructure completeness proof for Bimodal task semantics
- **Version**: 002
- **Status**: [COMPLETED]
- **Effort**: 8 hours (reduced from 10h - cleanup already done by task 905)
- **Dependencies**: Task 905 (cleanup) - COMPLETED
- **Research Inputs**:
  - specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-001.md
  - specs/903_restructure_completeness_proof_bimodal_semantics/reports/research-002.md
- **Previous Version**: implementation-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

This is version 002, revised after task 905 completion. Task 905 performed the preparatory cleanup:
- Moved 8 orphan files (7,605 lines, 100 sorries) to `Boneyard/Bundle/`
- Removed FALSE axiom `singleFamily_modal_backward_axiom` from Construction.lean
- Codebase now has 117 sorries, 3 axioms in active Theories/

**Key changes from v001**:
- Phase 5 no longer includes Boneyard file moves (done by task 905)
- Phase 5 no longer includes FALSE axiom removal (done by task 905)
- Phase 5 is now focused solely on the standard completeness theorems
- Total effort reduced from 10h to 8h

## Overview

This plan restructures the completeness proof for Bimodal TM logic so that it terminates in the standard semantic definitions from `Theories/Bimodal/Semantics/` (TaskFrame, TaskModel, WorldHistory, truth_at, satisfiable) rather than the parallel BMCS semantics (bmcs_truth_at, bmcs_valid). The approach follows research-002's definitive recommendation: construct a canonical TaskFrame with restricted WorldState (bundle MCS only), trivial task_rel, and constant-family BMCS. This avoids both the bridge-theorem indirection and the unsolved modal saturation problem for unrestricted CanonicalWorldState. All proof debt concentrates in a single sorry-backed theorem asserting existence of a temporally saturated, modally saturated constant-family BMCS.

### Research Integration

- **research-001.md**: Identified 7 structural divergences between current BMCS completeness and standard semantics. Inventoried Boneyard candidates (now moved by task 905). Confirmed BMCS completeness chain is sorry-free (modulo construction axiom).
- **research-002.md**: Exhaustive case analysis proved bridge theorem requires identical core work as direct construction plus unnecessary indirection. Proved S5 axioms do NOT guarantee universal accessibility (multiple equivalence classes possible). Identified constant-family BMCS with restricted WorldState as the only clean resolution. Temporal backward works via contraposition (existing `temporal_backward_G`/`temporal_backward_H`).

## Goals & Non-Goals

**Goals**:
- Prove `standard_representation : ContextConsistent [phi] -> satisfiable Int [phi]` using the actual `satisfiable` definition from `Semantics/Validity.lean`
- Prove `standard_weak_completeness : valid phi -> Nonempty (DerivationTree [] phi)` using the actual `valid` definition
- Prove `standard_strong_completeness : semantic_consequence Gamma phi -> ContextDerivable Gamma phi` using the actual `semantic_consequence` definition
- Reuse existing semantic definitions verbatim (no reimplementation)
- Reuse existing BMCS infrastructure (modal_forward/backward, temporal_backward_G/H)
- Concentrate all proof debt in a single, well-characterized sorry

**Non-Goals**:
- Eliminating the sorry in the BMCS construction chain (that is a separate task)
- Building a bridge theorem between bmcs_truth_at and truth_at (rejected by research)
- Replacing or modifying the existing BMCS completeness results (they remain valid for the Henkin semantics)
- Constructing a non-trivial task_rel for the canonical frame
- Boneyard file moves (already done by task 905)
- FALSE axiom removal (already done by task 905)
- Addressing RecursiveSeed chain (deferred pending task 864)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lean type issues with restricted WorldState subtype | M | M | Test early with a minimal compilation check; the subtype may need careful universe handling |
| Box case of truth lemma has subtle coverage issue | H | L | Construction ensures all WorldHistories map to bundle MCS by design; verify with lean_goal at each step |
| Constant-family temporal coherence requires careful proof | M | M | Reuse existing `temporal_backward_G`/`temporal_backward_H` from TemporalCoherentConstruction.lean |
| Convexity proof for canonical WorldHistory | L | L | Universal domain (fun _ => True) is trivially convex |

## Sorry Characterization

### Current State (Post Task 905)
- 117 sorries in active Theories/ (excluding Boneyard/Examples)
- Key sorries in Bundle/: `fully_saturated_bmcs_exists_int`, temporal coherent construction (~12), DovetailingChain (~4), TruthLemma EvalBMCS (~4), Construction modal_backward (~1)

### Expected Resolution
- This task does NOT resolve existing sorries. It builds on top of the existing sorry-free BMCS completeness chain.

### New Sorries
- ONE new sorry-backed theorem: existence of a constant-family BMCS with temporal saturation and modal saturation. This concentrates the proof obligation for the direct construction approach.
- All other new definitions and theorems target sorry-free proofs.

### Remaining Debt
After this implementation:
- The new sorry is the single concentration point for all proof debt in the standard completeness path
- It is well-characterized mathematically: "for any consistent context, there exists a set of MCS that are temporally saturated and modally connected, forming constant families"
- Remediation priority: high (blocks publication of standard completeness)
- Downstream: `standard_representation`, `standard_weak_completeness`, `standard_strong_completeness` all inherit this sorry

## Axiom Characterization

### Current State (Post Task 905)
- 3 axioms in active Theories/
- FALSE axiom `singleFamily_modal_backward_axiom` already removed by task 905

### New Axioms
- ONE new axiom (sorry-backed): `constant_family_bmcs_exists_int` asserting existence of constant-family BMCS with required saturation properties. This is mathematically sound and standard in modal logic.

### Remaining Debt
After this implementation:
- 1 new axiom for the direct construction (constant-family BMCS existence)
- Pre-existing axioms unchanged
- Zero-axiom target: requires constructive saturation proofs

## Implementation Phases

### Phase 1: Canonical Frame, Model, and History Definitions [NOT STARTED]

- **Dependencies:** None
- **Goal:** Create the new `Representation.lean` file with the canonical semantic objects that reuse existing TaskFrame, TaskModel, and WorldHistory definitions

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Representation.lean` with module header and imports
- [ ] Define `ConstantBMCS` structure (or predicate on existing BMCS) requiring: all families are constant (fam.mcs t = fam.mcs 0 for all t), temporal saturation, and modal saturation
- [ ] Define `constant_family_bmcs_exists_int` as the sorry-backed existence theorem for constant-family BMCS from consistent contexts
- [ ] Define `canonicalWorldState B` as the restricted WorldState type: `{S : Set Formula // exists fam, fam in B.families /\ S = fam.mcs 0}`
- [ ] Define `canonicalFrame B : TaskFrame Int` using `canonicalWorldState B` as WorldState and `task_rel := fun _ _ _ => True`
- [ ] Prove `canonicalFrame` satisfies nullity and compositionality (both trivial)
- [ ] Define `canonicalModel B : TaskModel (canonicalFrame B)` with `valuation w p := Formula.atom p in w.val`
- [ ] Define `canonicalHistory B fam hfam : WorldHistory (canonicalFrame B)` for each family in the bundle, with universal domain and constant states mapping to `fam.mcs 0`
- [ ] Prove `canonicalHistory` satisfies convexity (trivial, universal domain), respects_task (trivial, task_rel = True)
- [ ] Verify all definitions compile with `lake build`

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Representation.lean` (NEW) - all canonical definitions

**Verification:**
- `lake build` succeeds with no errors on the new file
- `lean_hover_info` confirms types match expected signatures
- canonicalFrame, canonicalModel, canonicalHistory all type-check

---

### Phase 2: Truth Lemma (Atom, Bot, Imp Cases) [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove the easy cases of the canonical truth lemma relating MCS membership to standard truth_at

**Tasks:**
- [ ] State the canonical truth lemma: `phi in fam.mcs 0 <-> truth_at (canonicalModel B) (canonicalHistory B fam hfam) t phi` (note: for constant families, truth is time-independent)
- [ ] Prove the atom case: forward uses universal domain + valuation definition; backward extracts atom from existence witness
- [ ] Prove the bot case: MCS consistency gives bot not in MCS; truth_at bot = False
- [ ] Prove the imp case: forward uses MCS modus ponens + IH; backward uses MCS negation completeness + IH
- [ ] Verify each case compiles individually using lean_goal

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Representation.lean` - add truth lemma cases

**Verification:**
- lean_goal shows "no goals" for each completed case
- The remaining cases (box, all_future, all_past) can have sorry placeholders

---

### Phase 3: Truth Lemma (Box Case) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove the box case of the canonical truth lemma -- the critical case that previous approaches failed on

**Tasks:**
- [ ] Prove box forward: `Box phi in fam.mcs 0 -> forall sigma : WorldHistory (canonicalFrame B), truth_at (canonicalModel B) sigma t phi`
  - Use modal_forward: Box phi in fam.mcs 0 gives phi in fam'.mcs 0 for all fam' in B.families (since constant, fam'.mcs t = fam'.mcs 0)
  - For arbitrary sigma, sigma.states t ht is some element of canonicalWorldState B, which by definition is some fam'.mcs 0 for fam' in B.families
  - Therefore phi in (sigma.states t ht).val
  - Apply IH backward at the specific family fam' to get truth_at for sigma
- [ ] Prove box backward: `(forall sigma, truth_at ... sigma t phi) -> Box phi in fam.mcs 0`
  - Instantiate sigma to canonicalHistory B fam' for each fam' in B.families
  - By IH forward, get phi in fam'.mcs 0 for all fam'
  - Apply modal_backward to get Box phi in fam.mcs 0
- [ ] Handle the subtype casting carefully: extracting the family witness from `canonicalWorldState B` membership
- [ ] Verify box case compiles with lean_goal

**Timing:** 2.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Representation.lean` - complete box case of truth lemma

**Verification:**
- lean_goal shows "no goals" for the box case
- No sorry in the box case

---

### Phase 4: Truth Lemma (Temporal Cases: G, H) [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove the all_future (G) and all_past (H) cases of the canonical truth lemma

**Tasks:**
- [ ] Prove all_future forward: `G phi in fam.mcs 0 -> forall s >= t, truth_at ... s phi`
  - For constant families: G phi in fam.mcs 0 implies phi in fam.mcs 0 by temporal T axiom (G phi -> phi)
  - By IH, phi in fam.mcs 0 gives truth_at at any time s (since history is constant)
- [ ] Prove all_future backward: `(forall s >= t, truth_at ... s phi) -> G phi in fam.mcs 0`
  - By IH backward at each s >= t: phi in fam.mcs 0 (constant family, same for all s)
  - Apply `temporal_backward_G` from TemporalCoherentConstruction.lean: if phi in fam.mcs s for all s >= t, then G phi in fam.mcs t
  - For constant families: fam.mcs t = fam.mcs 0, so G phi in fam.mcs 0
- [ ] Prove all_past forward and backward (symmetric to all_future, using temporal_backward_H)
- [ ] Handle the constant-family time collapse: truth_at at any time t is equivalent since the history assigns the same MCS everywhere
- [ ] Verify both temporal cases compile

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Representation.lean` - complete temporal cases of truth lemma

**Verification:**
- lean_goal shows "no goals" for all_future and all_past cases
- Complete truth lemma has no sorry (assuming the constant-family BMCS existence sorry)

---

### Phase 5: Standard Completeness Theorems [NOT STARTED]

- **Dependencies:** Phase 3, Phase 4
- **Goal:** Derive the three standard completeness theorems from the truth lemma

**Note:** Boneyard cleanup and FALSE axiom removal were completed by task 905. This phase focuses solely on the completeness theorems.

**Tasks:**
- [ ] Prove `standard_representation : (phi : Formula) -> ContextConsistent [phi] -> satisfiable Int [phi]`
  - Apply `constant_family_bmcs_exists_int` to get a constant-family BMCS B
  - phi in B.eval_family.mcs 0 (from construction)
  - Apply truth lemma forward to get truth_at at (canonicalModel B, canonicalHistory B eval_family, 0)
  - Package as satisfiable existential: exists F, M, tau, t, forall psi in [phi], truth_at M tau t psi
- [ ] Prove `standard_weak_completeness : valid phi -> Nonempty (DerivationTree [] phi)`
  - By contraposition: if not derivable, then neg phi is consistent
  - By standard_representation, neg phi is satisfiable in Int
  - Therefore phi is not valid (exhibit countermodel)
  - Contradiction
- [ ] Prove `standard_strong_completeness : semantic_consequence Gamma phi -> ContextDerivable Gamma phi`
  - By contraposition: if Gamma does not derive phi, then Gamma ++ [neg phi] is consistent
  - By standard_representation (context version), all of Gamma ++ [neg phi] are satisfiable
  - Therefore phi is not a semantic consequence of Gamma
  - Contradiction
- [ ] Verify all three completeness theorems compile
- [ ] Run full `lake build` to confirm no regressions

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Representation.lean` - standard completeness theorems

**Verification:**
- lean_verify on standard_representation, standard_weak_completeness, standard_strong_completeness
- `lake build` succeeds with no errors
- Theorems use actual `satisfiable`, `valid`, `semantic_consequence` definitions from Semantics/Validity.lean

---

## Testing & Validation

- [ ] `lake build` succeeds with zero errors after all phases
- [ ] `lean_verify` on `standard_representation` shows expected axiom dependencies (only constant_family_bmcs_exists_int)
- [ ] `lean_verify` on `standard_weak_completeness` shows no unexpected axioms
- [ ] `lean_verify` on `standard_strong_completeness` shows no unexpected axioms
- [ ] The truth lemma itself (excluding the BMCS existence sorry) is sorry-free
- [ ] Standard completeness theorems use the actual `satisfiable`, `valid`, `semantic_consequence` definitions from Semantics/Validity.lean (not bmcs_ variants)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation.lean` (NEW) - canonical frame/model/history, truth lemma, standard completeness theorems
- `specs/903_restructure_completeness_proof_bimodal_semantics/plans/implementation-002.md` (this file)
- `specs/903_restructure_completeness_proof_bimodal_semantics/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

- The new `Representation.lean` file is entirely additive -- deleting it reverts all changes
- Existing BMCS completeness in `Bundle/Completeness.lean` is untouched and remains functional
- If the box case of the truth lemma proves intractable at the Lean level despite the mathematical analysis, fall back to a sorry with detailed documentation of the gap
