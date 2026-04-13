# Implementation Plan: Close BXCanonical Temporal Coherence Sorries

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (task 92 already completed)
- **Research Inputs**: reports/04_team-research.md, reports/02_team-research.md
- **Artifacts**: plans/04_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 4 remaining sorry in `CanonicalModel.lean` that block `bx_completeness` from being sorry-free. The sorries are: `bx_fmcs_forward_F` (line 495), `bx_fmcs_backward_P` (line 501), `bx_bfmcs_buc` (line 584), and `bx_bfmcs_fuc` (line 589). The approach uses **restricted temporal coherence with deferral seeds**: rather than proving full forward_F/backward_P for all formulas (which the dovetailed chain cannot satisfy due to Lindenbaum extension killing F-obligations at resolving steps), we prove restricted versions scoped to `deferralClosure(root)` and create a restricted truth lemma that accepts `restricted_temporally_coherent` instead of `temporally_coherent`. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Four rounds of research (Reports 01-04) established:

- **Neither** the finite-tree nor the consistent-tuple strategy is viable standalone. BX11 forces tree degeneration to a path; consistent tuples either collapse to MCS or break the truth lemma.
- The **restricted temporal coherence + deferral seed** approach is unanimously recommended. The `successor_deferral_seed` from `SuccExistence.lean` provides "resolve-or-defer" semantics, scoped to the finite set `deferralClosure(root)` with F-nesting bounded by `closure_F_bound(root)`.
- The **critical gap** is whether `parametric_representation_from_neg_membership` accepts restricted coherence. Current signature requires full `temporally_coherent`. A restricted truth lemma must be created.
- The existing `bounded_witness` theorem in `CanonicalTaskRelation.lean` formalizes the F-depth bound that guarantees deferral chains terminate.

### Prior Plan Reference

The prior plan (02_bxcanonical-embedding.md) completed Phases 2-4 (BFMCS packaging, bridge proof, Completeness.lean wiring) but left Phase 1 [PARTIAL] with forward_F/backward_P as open sorries. It identified three mitigation paths; subsequent research eliminated biased Lindenbaum (Report 03) and confirmed restricted temporal coherence as the viable path. Effort calibration from the prior plan: chain construction took ~2 hours (matching estimate), BFMCS packaging took ~1.5 hours (matching estimate). The forward_F blocker was discovered mid-implementation, adding ~4 hours of research and plan revision. This plan accounts for that by front-loading the parametric infrastructure adaptation before touching the chain.

### Roadmap Alignment

- Closes the sole remaining active-path sorry (1 of 1) blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical

## Goals & Non-Goals

**Goals**:
- Close all 4 sorry in `CanonicalModel.lean` (forward_F, backward_P, buc, fuc)
- Create a restricted truth lemma accepting `restricted_temporally_coherent` for a target formula
- Modify chain construction to use `successor_deferral_seed` from `SuccExistence.lean`
- Prove restricted forward_F/backward_P within `deferralClosure(root)` scope
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Dense time completeness (`D = Rat`), which is a separate task (68)
- Proving full (unrestricted) `temporally_coherent` for the dovetailed chain
- Closing sorries in the Algebraic module outside the parametric path
- Refactoring the existing parametric truth lemma (we create a parallel restricted version)
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Restricted truth lemma requires more adaptation than expected | H | M | The existing truth lemma's structural induction on phi naturally restricts to subformulas. Only the G/H backward cases use temporal coherence (lines 336, 356, 520, 540). The restricted version replaces `h_tc fam hfam` with `h_rtc fam hfam` plus a subformula membership proof. Estimate: 150-200 lines of adapted code. |
| Deferral seed consistency proof is harder than expected at resolving steps | H | L | `successor_deferral_seed_consistent` is already proven sorry-free in `SuccExistence.lean`. We reuse it directly. |
| Until/Since coherence (buc/fuc) requires forward_F that we only have in restricted form | M | M | `backward_until_from_step` in `UntilSinceCoherence.lean` is parameterized by a step-transfer hypothesis, not by temporal coherence. We prove step-transfer for the enriched chain. For fuc: Until membership implies witness via BX9 (reflexive intro) or G-propagation + F-witness. |
| `bounded_witness` proof in `CanonicalTaskRelation.lean` has incompatible API | M | L | We verified `bounded_witness` signature: it takes `iter_F n phi in u`, `iter_F (n+1) phi not in u`, and a chain relation. Our chain satisfies the required relation via `g_content` inclusion. |
| Axiom contamination from unexpected sorry in dependency chain | H | L | Team research verified zero sorry in all parametric infrastructure files. Run `#print axioms` after each phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Restricted Truth Lemma and Representation [NOT STARTED]

**Goal**: Create a restricted parametric truth lemma that accepts `restricted_temporally_coherent root` (plus restricted Until/Since coherence) instead of full `temporally_coherent`, for evaluating a specific target formula `root`. Then create a restricted representation theorem that uses it.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean`
- [ ] Define `restricted_parametric_canonical_truth_lemma` with signature accepting `B.restricted_temporally_coherent root`, `B.backward_until_since_coherent`, `B.forward_until_since_coherent`, proving `phi in fam.mcs t <-> truth_at ... phi` for `phi` a subformula of `root`
- [ ] Adapt the G/H backward cases to use restricted forward_F/backward_P with subformula membership proof (the induction gives us `phi` is a subformula of `root`, so `neg phi in deferralClosure root`)
- [ ] Define `restricted_parametric_representation_from_neg_membership` that uses the restricted truth lemma
- [ ] Verify `lake build` compiles the new file with no sorry
- [ ] Run `#print axioms restricted_parametric_representation_from_neg_membership` to check for axiom contamination

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` -- New file (~200 lines): restricted truth lemma + representation theorem

**Verification**:
- `lake build` compiles with no errors in the new file
- New theorems have no sorry
- `#print axioms` shows only `propext`, `Classical.choice`, `Quot.sound`

---

### Phase 2: Modify Chain Construction for Deferral Seeds [NOT STARTED]

**Goal**: Replace the current `fwd_succ`/`bwd_pred` chain step functions with versions that use `successor_deferral_seed` from `SuccExistence.lean`, ensuring F/P obligations are preserved via resolve-or-defer disjunctions rather than the current f_carry/p_carry approach that fails at resolving steps.

**Tasks**:
- [ ] Modify `fwd_succ` to use `successor_deferral_seed` (which includes `g_content(M) union deferralDisjunctions(M)`) instead of `forward_temporal_witness_seed` at resolving steps and `g_content union f_carry` at non-resolving steps
- [ ] Prove `fwd_succ_deferral`: for each `F(phi) in M` where `phi in deferralClosure(root)`, the successor MCS contains either `phi` (resolved) or `F(phi)` (deferred), via the deferral disjunction `phi v F(phi)` in the seed
- [ ] Symmetrically modify `bwd_pred` to use past deferral seed with `p_step_blocking_formulas_restricted`
- [ ] Prove `bwd_pred_deferral`: symmetric property for `P(phi)` obligations
- [ ] Update `fwd_chain`, `bwd_chain`, `int_chain` signatures and proofs to thread through `root : Formula` parameter
- [ ] Verify existing proofs (`forward_G`, `backward_H`, `box_stable`, `g_content` propagation) still hold with the modified chain
- [ ] Verify `lake build` compiles (sorry count may temporarily increase during refactor)

**Timing**: 2.5 hours

**Depends on**: 1 (need to know the exact restricted coherence API to target)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Modify chain construction (~150 lines changed): replace fwd_succ/bwd_pred, add deferral properties

**Verification**:
- `lake build` compiles (sorry still expected for forward_F/backward_P/buc/fuc, but chain construction is updated)
- `fwd_succ_deferral` and `bwd_pred_deferral` have no sorry

---

### Phase 3: Prove Restricted Forward_F, Backward_P, and Until/Since Coherence [NOT STARTED]

**Goal**: Close the 4 sorry in `CanonicalModel.lean` using the deferral chain from Phase 2 and the restricted coherence definitions.

**Tasks**:
- [ ] Prove `bx_fmcs_restricted_forward_F`: For `phi in deferralClosure(root)`, if `F(phi) in chain(t)`, then within `closure_F_bound(root)` steps, either a resolving step places `phi` directly, or the deferral chain exhausts nesting depth and `bounded_witness` applies. Use well-founded induction on F-nesting depth within `deferralClosure(root)`.
- [ ] Prove `bx_fmcs_restricted_backward_P`: Symmetric argument using `closure_P_bound` and `bounded_witness_backward`.
- [ ] Replace the unrestricted `bx_fmcs_forward_F` sorry with a call to the restricted version (or restructure `bx_bfmcs_tc` to use `restricted_temporally_coherent`)
- [ ] Replace `bx_bfmcs_tc` with `bx_bfmcs_restricted_tc`: prove `(bx_bfmcs M h).restricted_temporally_coherent root` using restricted forward_F/backward_P
- [ ] Prove `bx_bfmcs_buc` (backward Until/Since coherence): use `backward_until_from_step` from `UntilSinceCoherence.lean` with step-transfer property derived from the chain's `g_content` propagation. The step transfer for Until: `Until(phi, psi) in chain(t+1)` and `phi in chain(t)` implies `Until(phi, psi) in chain(t)` via `backward_until_from_step`.
- [ ] Prove `bx_bfmcs_fuc` (forward Until/Since coherence): For `Until(phi, psi) in chain(t)`, use BX9 (`Until(phi, psi) -> phi v psi`) to get `psi in chain(t)` (witness at `s = t`, reflexive) or `phi in chain(t)` (guard holds). If `psi in chain(t)`, witness is `s = t` with vacuous guard. If only `phi in chain(t)`, propagate via G to `chain(t+1)` and use forward_F for the Until obligation.
- [ ] Verify all 4 sorry are closed: `grep sorry CanonicalModel.lean` returns empty

**Timing**: 2 hours

**Depends on**: 2 (needs the deferral chain with its properties)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Close sorries, add restricted coherence proofs (~150 lines new)

**Verification**:
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` returns no matches
- `lake build` compiles with no sorry in BXCanonical/

---

### Phase 4: Wire Restricted Infrastructure into Completeness [NOT STARTED]

**Goal**: Update `bx_countermodel` and `bx_completeness` to use the restricted representation theorem from Phase 1, passing `restricted_temporally_coherent root` instead of `temporally_coherent`.

**Tasks**:
- [ ] Update `bx_countermodel` signature to accept a root formula and use `restricted_parametric_representation_from_neg_membership` instead of `parametric_representation_from_neg_membership`
- [ ] Update `bx_construct_bfmcs` to return `restricted_temporally_coherent root` instead of `temporally_coherent`
- [ ] Update `bx_completeness` in `Completeness.lean` to pass the target formula as `root`
- [ ] Verify `lake build` succeeds with zero sorry
- [ ] Run `#print axioms bx_completeness` and verify output
- [ ] Run full `lake build` to check for regressions

**Timing**: 1 hour

**Depends on**: 2 (restricted coherence proofs), 3 (restricted representation theorem)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Update bridge section (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Minor signature update (~5 lines)

**Verification**:
- `lake build` succeeds with zero errors, zero sorry
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

## Testing & Validation

- [ ] `lake build` completes with zero errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No regressions: full `lake build` succeeds for the entire project
- [ ] Restricted truth lemma file has no sorry of its own

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` -- New file (~200 lines): restricted truth lemma and representation theorem
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Modified (~300 lines changed): deferral chain, restricted coherence proofs, updated bridge
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Minor update (~5 lines): use restricted representation
- `specs/093_complete_bxcanonical_embedding/summaries/04_bxcanonical-embedding-summary.md` -- Implementation summary (created after completion)

## Rollback/Contingency

- `RestrictedParametricTruthLemma.lean` is a new file and can be deleted without affecting existing code.
- `CanonicalModel.lean` modifications can be reverted with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (restoring the sorry-bearing version).
- `Completeness.lean` changes are minimal and easily reverted.
- **Fallback if restricted truth lemma proves too complex**: Instead of creating a separate file, modify `parametric_shifted_truth_lemma` in-place to accept a `TemporalCoherenceHyp` typeclass that can be instantiated with either full or restricted coherence. This is more invasive but avoids code duplication.
- **Fallback if deferral seeds don't close forward_F**: Return to the biased Lindenbaum approach (building a custom Lindenbaum extension that preferentially preserves F-obligations). This was deprioritized by research but not proven impossible.
