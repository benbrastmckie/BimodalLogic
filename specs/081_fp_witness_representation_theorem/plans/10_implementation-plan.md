# Implementation Plan: F/P Witness Representation Theorem

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 12 hours
- **Dependencies**: None (self-contained bypass of existing sorry chain)
- **Research Inputs**: reports/10_streamlined-guide.md
- **Artifacts**: plans/10_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sorry in `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) which blocks `completeness_over_Int` and `discrete_completeness_fc`. The strategy bypasses the existing sorry-bearing restricted chain (which fails at `constrained_successor_seed_restricted_consistent`, SuccChainFMCS.lean:2082) by building a simplified restricted seed that is trivially consistent (all elements are subsets of the parent DRM). The simplified chain provides only weak f_step (resolve-or-defer), but bounded F-nesting within deferralClosure guarantees resolution in finitely many steps. A new restricted completeness theorem replaces the existing sorry-dependent path.

### Research Integration

Report 10 (streamlined-guide.md) provides the verified 10-step roadmap. Key findings integrated:
- The existing `constrained_successor_seed_restricted` includes `boundary_resolution_set` and `f_content` which make consistency unprovable (the sorry at line 2082)
- The simplified seed uses only `g_content ∪ deferralDisjunctions ∪ p_step_blocking_formulas_restricted`, all of which are subsets of the parent DRM, making consistency trivial
- Box propagation follows from g_content propagation + the derivable theorem `Box(a) -> G(Box(a))` -- no seed modification needed
- The existing `RestrictedTemporallyCoherentFamily` structure and `restricted_truth_lemma` infrastructure can be reused

## Goals & Non-Goals

**Goals**:
- Close the sorry in `bfmcs_from_mcs_temporally_coherent` (or bypass it entirely)
- Make `completeness_over_Int` and `discrete_completeness_fc` sorry-free for the blocking sorry
- Build a self-contained completeness proof via simplified restricted chains
- Reuse existing infrastructure: `DeferralRestrictedSerialMCS`, `deferral_restricted_lindenbaum`, `RestrictedTemporallyCoherentFamily`, `restricted_truth_lemma`

**Non-Goals**:
- Fix the existing `constrained_successor_seed_restricted_consistent` sorry (bypassed instead)
- Address `dense_completeness_fc` (separate issue, line ~390)
- Address sorries in `CanonicalConstruction.lean` or the algebraic `RestrictedTruthLemma.lean` G/H propagation
- Remove the fuel=0 base case sorries (semantically unreachable, not on critical path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Box(a) -> G(Box(a))` not derivable from existing axioms | H | L | Axioms modal_4 and modal_future are formalized; derivation is 2 steps. Verify with `lean_goal` before relying on it. |
| Weak f_step insufficient for bounded forward_F induction | H | L | The bounded F-nesting argument is mathematically well-established; the existing `closure_F_bound` and `f_nesting_depth` infrastructure supports it. |
| Restricted truth lemma backward G case requires G-propagation through chain (existing sorry at RestrictedTruthLemma.lean:116) | H | M | The new completeness proof does NOT route through the existing `restricted_truth_lemma`. It builds a semantic truth lemma that handles G/H via forward_F/backward_P + DRM negation completeness. |
| Modal coherence across families within deferralClosure | M | M | Box propagation via g_content is automatic; the family-level modal coherence only needs box_class_agree at each time point, which follows from `Box(a) in chain(0) -> Box(a) in chain(n)`. |
| New file imports cause `lake build` regressions | L | L | Add imports incrementally; run `lake build` after each phase. |
| `DeferralRestricted` vs `ClosureRestricted` type mismatch for seed subset proof | M | M | Verify `simplified_restricted_seed` elements satisfy `DeferralRestricted` by checking that each component returns elements in `deferralClosure`. |

## Implementation Phases

### Phase 1: Simplified Restricted Seed and Successor [NOT STARTED]

**Goal**: Define the simplified restricted seed (without `boundary_resolution_set` and `f_content`) and prove its consistency is trivial, then build the successor via `deferral_restricted_lindenbaum`.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` with imports from `SuccChainFMCS`, `SuccExistence`, `RestrictedMCS`, `TemporalContent`
- [ ] Define `simplified_restricted_seed`:
  ```lean
  def simplified_restricted_seed (phi : Formula) (u : Set Formula) : Set Formula :=
    g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u
  ```
- [ ] Prove `simplified_restricted_seed_subset_u`: Every element of the seed is in `u`. Strategy: Use existing lemmas `g_content_subset_deferral_restricted_mcs`, `deferralDisjunctions_subset_deferral_restricted_mcs` (or prove from definitions: `g_content u = {phi | G(phi) in u}`, and by DRM closure `G(phi) in u -> phi in u`), and `p_step_blocking_restricted_subset` (verify exists, or prove: each element is `neg(P(chi))` where `P(chi) not in u`, hence `neg(P(chi)) in u` by DRM negation completeness for deferralClosure formulas).
- [ ] Prove `simplified_restricted_seed_consistent`: Since seed is a subset of consistent `u`, it is consistent. Use `SetConsistent_subset`.
- [ ] Prove `simplified_restricted_seed_subset_dc`: All seed elements are in `deferralClosure`. Use existing `g_content_subset_deferralClosure`, `deferralDisjunctions_subset_deferralClosure`, `p_step_blocking_restricted_subset_dc` (or prove from definitions).
- [ ] Define `simplified_successor_restricted` via `deferral_restricted_lindenbaum` applied to the seed.
- [ ] Prove successor properties: `simplified_successor_is_drm`, `simplified_successor_g_persistence` (g_content of u is in seed, seed is in successor), `simplified_successor_f_step` (weak: `F(psi) in u` implies `psi in successor OR F(psi) in successor`, from deferralDisjunction `psi ∨ F(psi)` in seed and DRM maximality), `simplified_successor_p_step`, `simplified_successor_has_F_top`, `simplified_successor_has_P_top`.
- [ ] Run `lake build` to verify no errors.

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` (NEW, ~250 lines)

**Verification**:
- `lake build` succeeds with no new sorries in the new file
- All theorems in the file are sorry-free
- `simplified_successor_f_step` correctly states the weak resolve-or-defer property

---

### Phase 2: Forward Chain Construction [NOT STARTED]

**Goal**: Build the forward chain from a DeferralRestrictedSerialMCS by iterating the simplified successor, and prove chain-level properties.

**Tasks**:
- [ ] Define `SimplifiedForwardChainAt` (recursive DeferralRestrictedSerialMCS at each step):
  ```lean
  noncomputable def simplifiedForwardChainAt (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) : Nat -> DeferralRestrictedSerialMCS phi
    | 0 => M0
    | n + 1 => ⟨simplified_successor_restricted phi
        (simplifiedForwardChainAt phi M0 n).world
        (simplifiedForwardChainAt phi M0 n).is_drm
        (simplifiedForwardChainAt phi M0 n).has_F_top,
        simplified_successor_is_drm ...,
        simplified_successor_has_F_top ...,
        simplified_successor_has_P_top ...⟩
  ```
- [ ] Define `simplified_forward_chain phi M0 n := (simplifiedForwardChainAt phi M0 n).world`
- [ ] Prove `simplified_forward_chain_is_drm`: Each element is a DRM (direct from the structure).
- [ ] Prove `simplified_forward_chain_g_persistence`: `g_content(chain(n)) ⊆ chain(n+1)`. Follows from `simplified_successor_g_persistence`.
- [ ] Prove `simplified_forward_chain_f_step`: Weak f_step propagates through chain. `F(psi) in chain(n) -> psi in chain(n+1) OR F(psi) in chain(n+1)`.
- [ ] Prove `simplified_forward_chain_has_F_top` and `simplified_forward_chain_has_P_top`.
- [ ] Run `lake build`.

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` (append, ~150 lines)

**Verification**:
- All chain-level properties are sorry-free
- `simplified_forward_chain_f_step` compiles with correct type signature

---

### Phase 3: Forward F via Bounded F-Nesting [NOT STARTED]

**Goal**: Prove that every F-obligation in the simplified forward chain is eventually resolved, using bounded F-nesting depth within deferralClosure.

**Tasks**:
- [ ] Prove `simplified_forward_chain_F_bounded`: If `iter_F d psi in chain(n)` with `d >= 1` and `iter_F (d+1) psi not in chain(n)`, then `psi in chain(m)` for some `m > n`. Strategy: By well-founded induction on fuel (paralleling `restricted_forward_bounded_witness_fueled`). At each step, the weak f_step either resolves (done) or defers. On deferral, find the new boundary depth using `f_nesting_is_bounded_restricted` and recurse with decreased depth argument.
- [ ] Prove the key helper: `simplified_forward_chain_F_resolves_or_defers`: If `F(psi) in chain(n)`, then either `psi in chain(n+1)` or `F(psi) in chain(n+1)`. This follows directly from `simplified_successor_f_step`.
- [ ] Prove the boundary-finding lemma: If `F(psi) in chain(n)` and `F(psi) in deferralClosure phi`, find `d >= 1` such that `iter_F d psi in chain(n)` and `iter_F (d+1) psi not in chain(n)`. Use `f_nesting_is_bounded_restricted` to bound `d`.
- [ ] Prove `simplified_forward_chain_forward_F`:
  ```lean
  theorem simplified_forward_chain_forward_F (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
      (h_F : Formula.some_future psi ∈ simplified_forward_chain phi M0 n) :
      ∃ m : Nat, n < m ∧ psi ∈ simplified_forward_chain phi M0 m
  ```
  Strategy: Find boundary depth d via the boundary-finding lemma, then apply `simplified_forward_chain_F_bounded` with fuel = B*B+1 where B = `closure_F_bound phi`.
- [ ] Run `lake build`.

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` (append, ~250 lines)

**Verification**:
- `simplified_forward_chain_forward_F` is sorry-free
- The fuel-based termination is accepted by Lean's termination checker
- No dependency on `constrained_successor_seed_restricted_consistent`

---

### Phase 4: Backward Chain and Backward P [NOT STARTED]

**Goal**: Build the symmetric backward chain construction and prove backward_P coherence.

**Tasks**:
- [ ] Define `simplified_predecessor_seed` (symmetric to simplified_restricted_seed, using `h_content` instead of `g_content`, and appropriate backward components):
  ```lean
  def simplified_predecessor_seed (phi : Formula) (u : Set Formula) : Set Formula :=
    h_content u ∪ pastDeferralDisjunctions u ∪ f_step_blocking_formulas_restricted phi u
  ```
  Note: Check if `pastDeferralDisjunctions` and `f_step_blocking_formulas_restricted` exist. The existing backward chain in SuccChainFMCS.lean (line ~4000) uses `constrained_predecessor_seed_restricted`. Identify the backward analogues of each forward component.
- [ ] Prove `simplified_predecessor_seed_subset_u`, `simplified_predecessor_seed_consistent`, `simplified_predecessor_seed_subset_dc` (symmetric to Phase 1).
- [ ] Define `simplified_predecessor_restricted` via `deferral_restricted_lindenbaum`.
- [ ] Prove successor properties for backward direction: `simplified_predecessor_is_drm`, `simplified_predecessor_h_persistence`, `simplified_predecessor_p_step` (weak: `P(psi) in u -> psi in predecessor OR P(psi) in predecessor`), `simplified_predecessor_has_F_top`, `simplified_predecessor_has_P_top`.
- [ ] Define `simplified_backward_chain` by iterating `simplified_predecessor_restricted`.
- [ ] Prove `simplified_backward_chain_backward_P` using bounded P-nesting (symmetric to Phase 3's forward_F proof).
- [ ] Run `lake build`.

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` (append, ~350 lines)

**Verification**:
- `simplified_backward_chain_backward_P` is sorry-free
- Backward construction mirrors forward construction symmetrically

---

### Phase 5: Combined Chain, Box Propagation, and TC Family [NOT STARTED]

**Goal**: Combine forward/backward chains into an Int-indexed chain, prove box_class_agree propagation, and build a `RestrictedTemporallyCoherentFamily`.

**Tasks**:
- [ ] Define `simplified_succ_chain_fam`:
  ```lean
  noncomputable def simplified_succ_chain_fam (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (n : Int) : Set Formula :=
    match n with
    | Int.ofNat k => simplified_forward_chain phi M0 k
    | Int.negSucc k => simplified_backward_chain phi M0 (k + 1)
  ```
- [ ] Prove `simplified_succ_chain_fam_is_drm`, `simplified_succ_chain_fam_zero`, `simplified_succ_chain_fam_succ` (Succ relation between adjacent elements).
- [ ] Prove derived theorems for box propagation (may go in a separate section or file):
  - `box_implies_G_box`: `Box(a) -> G(Box(a))` derivable in TM. Proof: `Box(a) -> Box(Box(a))` by modal_4, then `Box(Box(a)) -> G(Box(a))` by modal_future.
  - `neg_box_implies_G_neg_box`: `neg(Box(a)) -> G(neg(Box(a)))` derivable in TM. Proof: `neg(Box(a)) -> Box(neg(Box(a)))` by S5 negative introspection (axiom 5), then `Box(neg(Box(a))) -> G(neg(Box(a)))` by modal_future.
- [ ] Prove `simplified_forward_chain_box_agree`: `Box(a) in chain(0) -> Box(a) in chain(n)` for all n. Strategy: `Box(a) in chain(0)` implies `G(Box(a)) in chain(0)` by `box_implies_G_box` + DRM closure. Then `Box(a) in g_content(chain(0)) subset chain(1)`. Iterate.
- [ ] Prove `simplified_forward_chain_neg_box_agree`: `neg(Box(a)) in chain(0) -> neg(Box(a)) in chain(n)`. Symmetric using `neg_box_implies_G_neg_box`.
- [ ] Build `simplified_tc_family`:
  ```lean
  noncomputable def build_simplified_tc_family (phi : Formula)
      (seed : DeferralRestrictedSerialMCS phi) : RestrictedTemporallyCoherentFamily phi where
    seed := seed
    forward_F := fun n psi h => ...  -- from simplified_forward_chain_forward_F + backward lifting
    backward_P := fun n psi h => ... -- from simplified_backward_chain_backward_P + forward lifting
  ```
  Note: The Int-indexed forward_F at negative positions uses the backward chain's forward F property (or prove that forward obligations in the backward chain are resolved by the backward chain's structure).
- [ ] Run `lake build`.

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` (append, ~250 lines)
- Possibly `Theories/Bimodal/Theorems/` for derived modal theorems (~40 lines)

**Verification**:
- `build_simplified_tc_family` produces a sorry-free `RestrictedTemporallyCoherentFamily`
- Box propagation theorems are sorry-free
- The Int-indexed chain handles both positive and negative indices correctly

---

### Phase 6: Restricted Completeness Theorem and Wiring [NOT STARTED]

**Goal**: Build the restricted completeness theorem and wire it into the existing `completeness_over_Int`, closing the blocking sorry.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/RestrictedCompleteness.lean` with imports.
- [ ] Build restricted BFMCS-like structure (if needed) or work directly with `RestrictedTemporallyCoherentFamily`:
  - For the completeness argument, we need: (1) an MCS at time 0 containing neg(phi), (2) a model where neg(phi) is true, (3) contradiction with validity.
  - The existing `restricted_ext_neg_excludes_phi` (RestrictedTruthLemma.lean:381) already gives us phi not in ext(0) when neg(phi) is in the seed.
  - Route through `construct_bfmcs_bundle` applied to the extended MCS at time 0, or build a direct semantic argument.
- [ ] Define the canonical model from the simplified chain:
  - Option A (reuse existing): Use `restricted_chain_ext` to get full MCS at each time point, then feed into `construct_bfmcs_bundle`. The `build_simplified_tc_family` provides the family-level temporal coherence that `bfmcs_from_mcs_temporally_coherent` needs.
  - Option B (direct): Build a TaskFrame/TaskModel directly from the simplified chain, define truth evaluation, and prove the truth lemma. This avoids the existing BFMCS machinery but requires more new code.
  - **Recommended**: Option A -- use `restricted_chain_ext` at time 0 to get an MCS M0, build BFMCS from M0, and prove temporal coherence using the simplified chain's properties.
- [ ] Prove `restricted_completeness`:
  ```lean
  theorem restricted_completeness (phi : Formula)
      (h_valid : valid_over Int phi) :
      Nonempty (DerivationTree [] phi)
  ```
  Proof outline:
  1. By contradiction: assume not provable.
  2. `not_provable_implies_neg_set_consistent` gives `SetConsistent {neg(phi)}`.
  3. `build_restricted_serial_mcs_from_neg_consistent` gives DeferralRestrictedSerialMCS with neg(phi).
  4. `build_simplified_tc_family` gives RestrictedTemporallyCoherentFamily.
  5. `restricted_ext_neg_excludes_phi` gives phi not in ext(0).
  6. ext(0) is a full MCS (by `restricted_chain_ext_is_mcs`).
  7. Build canonical BFMCS_Bundle from ext(0) via `construct_bfmcs_bundle`.
  8. The simplified chain's temporal coherence transfers to the BFMCS bundle -- this is the key step. Prove `bfmcs_from_mcs_temporally_coherent` for this specific MCS by showing the BFMCS families correspond to the simplified chain families.
  9. Apply `shifted_truth_lemma` to get phi true at canonical model (from validity).
  10. By truth lemma backward: phi in ext(0). Contradiction.
- [ ] Wire into existing infrastructure. Modify `Completeness.lean`:
  - Either fill the sorry in `bfmcs_from_mcs_temporally_coherent` using the simplified chain argument.
  - Or replace `completeness_over_Int` to call `restricted_completeness` directly:
    ```lean
    theorem completeness_over_Int {phi : Formula} :
        CompletenessOverIntStatement phi := by
      intro h_valid
      exact restricted_completeness phi h_valid
    ```
- [ ] Run `lake build` to verify full project compiles.

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedCompleteness.lean` (NEW, ~300 lines)
- `Theories/Bimodal/FrameConditions/Completeness.lean` (modify ~5 lines: wire `completeness_over_Int` to use `restricted_completeness`)

**Verification**:
- `restricted_completeness` is sorry-free
- `completeness_over_Int` is sorry-free (modulo any remaining non-blocking sorries)
- `discrete_completeness_fc` is sorry-free (it delegates to `completeness_over_Int`)
- `lake build` succeeds across the full project
- `lean_verify` on `completeness_over_Int` shows no sorry dependencies in the critical path

## Testing & Validation

- [ ] `lake build` succeeds with no new sorries in the new files
- [ ] `lean_verify` on `restricted_completeness` confirms no sorry axioms used
- [ ] `lean_verify` on `completeness_over_Int` confirms the blocking sorry is closed
- [ ] `lean_verify` on `discrete_completeness_fc` confirms sorry-free
- [ ] Each phase's theorems compile independently (incremental verification)
- [ ] The simplified seed consistency proof (`simplified_restricted_seed_consistent`) uses only `SetConsistent_subset` and the seed-subset-of-u lemma -- no sorry
- [ ] The forward_F proof terminates (Lean accepts the `termination_by fuel` clause)
- [ ] Box propagation through the chain is verified for both `Box(a)` and `neg(Box(a))`

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SimplifiedChain.lean` -- Simplified restricted seed, successor, forward/backward chains, temporal coherence family (~1250 lines)
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedCompleteness.lean` -- Restricted completeness theorem (~300 lines)
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- Modified to wire completeness_over_Int (~5 lines changed)
- `specs/081_fp_witness_representation_theorem/summaries/10_execution-summary.md` -- Execution summary

## Rollback/Contingency

- All new code is in new files (`SimplifiedChain.lean`, `RestrictedCompleteness.lean`), so rollback is simply deleting these files and reverting the 5-line change to `Completeness.lean`.
- If Phase 6 wiring fails (the BFMCS temporal coherence transfer is harder than expected), the simplified chain and its properties remain valuable infrastructure. An alternative wiring approach through direct semantic model construction can be pursued.
- If the bounded F-nesting argument (Phase 3) encounters unexpected difficulties, fall back to proving `constrained_successor_seed_restricted_consistent` directly using the classical reasoning approach outlined in SuccChainFMCS.lean:2034-2059 (iterated deduction theorem with negation trading).
- Git tags before each phase enable granular rollback.
