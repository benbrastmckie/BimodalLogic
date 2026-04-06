# Implementation Plan: Close Restricted Coherence Sorries via Reflexive Semantics Switch

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [IN PROGRESS]
- **Effort**: 10 hours
- **Dependencies**: None (task 82 FMP TruthPreservation and task 68 dense_completeness_fc are out of scope)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/26_team-research.md, specs/083_close_restricted_coherence_sorries/reports/27_team-research.md
- **Artifacts**: plans/26_completeness-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Switch from strict to reflexive temporal semantics for G/H operators (keeping Until/Since strict), add T-axiom constructors, and close the 2 main sorries (`succ_chain_restricted_forward_F`, `succ_chain_restricted_backward_P`) using a hybrid construction: deterministic chain backbone for G/H propagation + Lindenbaum detours for F-witness resolution enabled by T-axiom seed consistency. This is the standard approach in the literature (Burgess 1984, GHR 1994), which previous plans failed to implement because they attempted to resolve F-obligations within a purely deterministic chain under strict semantics.

### Research Integration

Report 26 (team research, 3 teammates) established:
- T-axiom fixes Lindenbaum seed consistency: F(psi) in M implies {psi} union g_content(M) is consistent
- Hybrid construction (deterministic + Lindenbaum detours) avoids both the independent extension problem (pre-Task 81) and the F-resolution circularity (Tasks 81-83)
- Mixed semantics (reflexive G/H with >=, strict U/S with >) is standard
- Boneyard/TAxiomDependentCode/ contains ~300 lines of restorable hybrid chain code
- Critical gap: Until persistence through Lindenbaum detours needs explicit handling

Report 27 (team research, 3 teammates — advantages/disadvantages/literature) confirmed:
- Mixed semantics IS the standard: Burgess-Xu axiom system has G(φ)→φ as axiom BX1
- No fatal logical inconsistencies in the mixed approach
- Until/Since axioms need NO changes (keep strict witnesses, X/Y-based formulations)
- 4 sorries in SuccChainFMCS.lean directly closable by T-axiom (annotated `was: temp_t_future`)
- Seriality and density axioms become trivially valid (lose frame correspondence but encoded separately in typeclasses)
- CanonicalIrreflexivity.lean becomes obsolete (ExistsTask M M holds under reflexive semantics)
- F(φ)/P(φ) now include present — derived theorems need semantic review
- `always` middle conjunct becomes redundant (leave definition unchanged, update comments)
- All parametric infrastructure (DeterministicChain, ParametricTruthLemma, box_class_agree) survives unchanged

## Goals & Non-Goals

**Goals**:
- Close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` (UltrafilterChain.lean)
- Close `restricted_chain_G_step` and `restricted_chain_H_step` (RestrictedTruthLemma.lean) if they remain relevant
- Switch G/H semantics from strict (<) to reflexive (<=) in Truth.lean
- Add T-axiom constructors (G(phi)->phi, H(phi)->phi) to Axioms.lean
- Prove T-axiom soundness
- Update FMCS structure to use reflexive coherence (>=)
- Achieve sorry-free `completeness_over_Int`

**Non-Goals**:
- FMP TruthPreservation (task 82)
- Dense completeness `dense_completeness_fc` (task 68)
- Old full-coherence sorry `bfmcs_from_mcs_temporally_coherent` (bypassed by restricted path)
- Rewriting the dovetailed chain (deprecated, separate architectural limitation)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Seed consistency lemma fails in Lean | H | M | Phase 1 is a prototype; abort before full migration if it fails |
| Until persistence breaks through Lindenbaum detours | H | M | Include Until obligations in Lindenbaum seed; fallback: restrict to G/H-only chain and handle Until separately |
| Soundness proofs break for existing axioms under reflexive semantics | M | L | Density axiom (GG->G) becomes trivial; discrete axioms need checking but should hold for >= |
| Regression in 20+ files during semantics switch | M | M | Phase 2 is mechanical; run `lake build` after each file change |
| Independent extension problem resurfaces | H | L | Deterministic chain backbone handles G-propagation; Lindenbaum detours only for F-witnesses |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Prototype Seed Consistency Lemma [COMPLETED]

**Goal**: Prove the key lemma in a scratch file to validate the approach before committing to full migration. If this fails, the plan is abandoned.

**Tasks**:
- [ ] Create scratch file `Theories/Bimodal/Scratch/SeedConsistency.lean`
- [ ] Define reflexive `truth_at` (G/H use <=) in scratch context or import and override
- [ ] Add T-axiom constructors as local axioms: `temp_t_future : Axiom (G(phi) -> phi)` and `temp_t_past : Axiom (H(phi) -> phi)`
- [ ] Prove: if F(psi) in M (MCS with T-axiom), then neg(psi) not in g_content(M). Argument: F(psi) in M => neg(G(neg(psi))) in M => G(neg(psi)) not in M (by MCS) => neg(psi) not in g_content(M) (since g_content(M) = {phi | G(phi) in M})
- [ ] Prove: {psi} union g_content(M) is consistent (Lindenbaum seed consistency)
- [ ] Prove: Lindenbaum extension of {psi} union g_content(M) yields MCS containing psi as F-witness
- [ ] Verify Until obligations: if (top U psi) in M, show how it propagates through g_content seed
- [ ] Delete scratch file after confirming results (code moves to real files in Phase 3)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Scratch/SeedConsistency.lean` - create and delete

**Verification**:
- `lake build Bimodal.Scratch.SeedConsistency` compiles with no sorries
- The seed consistency argument holds as stated in the research

---

### Phase 2: Core Definitions Switch (Semantics + Axioms + FMCS) [COMPLETED]

**Goal**: Switch G/H from strict to reflexive semantics in all core definition files. Add T-axioms. Update FMCS structure.

**Tasks**:
- [ ] **Truth.lean**: Change `all_past` from `s < t` to `s ≤ t`, `all_future` from `t < s` to `t ≤ s`. Keep `untl`/`snce` with strict `<`/`>`.
- [ ] **Truth.lean**: Update docstrings to reflect reflexive G/H semantics
- [ ] **Axioms.lean**: Add `temp_t_future (phi : Formula) : Axiom ((Formula.all_future phi).imp phi)` constructor
- [ ] **Axioms.lean**: Add `temp_t_past (phi : Formula) : Axiom ((Formula.all_past phi).imp phi)` constructor
- [ ] **Axioms.lean**: Mark both as `.Base` category; update axiom count in docstrings (16 -> 18)
- [ ] **Axioms.lean**: Do NOT remove seriality_future, seriality_past, or density axioms — they become derivable but removing them would break downstream proofs. Add comments noting redundancy under reflexive semantics.
- [ ] **Axioms.lean**: Do NOT change Until/Since axioms (unfold, intro, induction, connectedness) — they remain correct as-is since U/S keep strict semantics
- [ ] **FMCSDef.lean**: Change `forward_G` from `t < t'` to `t ≤ t'`, `backward_H` from `t' < t` to `t' ≤ t`
- [ ] **FMCSDef.lean**: Update docstrings to reflect reflexive coherence
- [ ] Run `lake build` and fix all downstream compilation errors (expect 20-30 files with type mismatches on `<` vs `≤`)
- [ ] Fix Soundness.lean: existing axiom soundness proofs that use strict `<` must be updated to `≤`
- [ ] Fix all `forward_G`/`backward_H` call sites in UltrafilterChain.lean, DeterministicFMCS.lean, ParametricHistory.lean, ParametricTruthLemma.lean to use `≤` hypotheses
- [ ] Fix density axiom soundness (GG->G becomes trivially true under reflexive semantics since `≤` is transitive)
- [ ] Update `succ_chain_restricted_forward_F`/`backward_P` signatures if inequality direction changes

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Semantics/Truth.lean` - reflexive G/H
- `Theories/Bimodal/ProofSystem/Axioms.lean` - T-axiom constructors
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` - reflexive coherence
- `Theories/Bimodal/Metalogic/Soundness.lean` - axiom soundness updates
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - temporal lemma updates
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - call site fixes
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` - call site fixes
- `Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean` - call site fixes
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` - call site fixes
- ~15 additional files with downstream compilation errors

**Verification**:
- `lake build` succeeds (possibly with remaining sorries, but no new ones)
- T-axiom constructors exist and are categorized as Base
- FMCS uses `≤` not `<`

---

### Phase 3: T-Axiom Soundness and FMCS Reflexive Coherence [COMPLETED]

**Goal**: Prove T-axiom validity under reflexive semantics. Update FMCS construction to provide reflexive coherence fields. Restore and adapt Boneyard code.

**Tasks**:
- [ ] Prove `temp_t_future` soundness: G(phi) true at t under reflexive semantics (all s >= t have phi) implies phi true at t (take s = t)
- [ ] Prove `temp_t_past` soundness: H(phi) true at t under reflexive semantics (all s <= t have phi) implies phi true at t (take s = t)
- [ ] Update `SuccChainFMCS` to provide `forward_G` with `≤`: when t = t', phi in mcs(t) follows from T-axiom applied to G(phi) in mcs(t); when t < t', existing chain stepping logic applies
- [ ] Restore relevant code from `Boneyard/TAxiomDependentCode/TargetedChainArchive.lean` (~lines for `targeted_forward_chain_forward_G`, `targeted_backward_chain_backward_H`, `targeted_fam_forward_G`, `targeted_fam_backward_H`)
- [ ] Adapt restored code: replace `sorry /- was: temp_t_future phi -/` with actual T-axiom invocation `DerivationTree.axiom _ _ (Axiom.temp_t_future phi)`
- [ ] Verify `DeterministicFMCS` provides `forward_G`/`backward_H` with `≤` (the strict case is the existing chain; the reflexive case t=t' is trivial)
- [ ] Close the 4 directly closable sorries in `SuccChainFMCS.lean` that are annotated with `was: temp_t_future`/`temp_t_past` — replace `sorry` with `DerivationTree.axiom [] _ (Axiom.temp_t_future ...)` or equivalent
- [ ] Simplify density axiom soundness proof (GG→G becomes trivial under ≥ transitivity)
- [ ] Simplify seriality axiom soundness proofs (G→F trivial: G(φ)→φ→F(φ) taking s=t)

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - T-axiom soundness cases + simplify density/seriality
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - SuccChainFMCS reflexive coherence + close 4 T-axiom sorries
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` - DeterministicFMCS reflexive coherence
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - becomes obsolete; extract utility functions, delete rest

**Verification**:
- `lake build` succeeds
- T-axiom soundness proofs are sorry-free
- FMCS constructions provide `forward_G`/`backward_H` with `≤`

---

### Phase 4: Close the Main Sorries (Hybrid F-Resolution) [NOT STARTED]

**Goal**: Close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` using the seed consistency + Lindenbaum detour argument.

**Tasks**:
- [ ] Implement seed consistency lemma in UltrafilterChain.lean: `f_witness_seed_consistent`: if F(psi) in M (MCS), then {psi} union g_content(M) is consistent
- [ ] Implement Lindenbaum detour: given F(psi) in succ_chain_fam(S, n), construct MCS at n+1 containing psi via Lindenbaum extension of {psi} union g_content(succ_chain_fam(S, n))
- [ ] Prove `succ_chain_restricted_forward_F`: for psi in deferralClosure(root), F(psi) in succ_chain_fam(S, n) implies exists m > n with psi in succ_chain_fam(S, m). Use: take m = n+1, apply Lindenbaum detour
- [ ] Prove `succ_chain_restricted_backward_P`: symmetric argument for P(psi) using h_content and past Lindenbaum extension
- [ ] Handle Until persistence: verify that Until obligations in succ_chain_fam(S, n) propagate to the Lindenbaum extension at n+1 (either through g_content inclusion or by adding Until obligations to the seed)
- [ ] If Lindenbaum detour changes the chain construction (away from pure x_content stepping), update the chain definition or provide an alternative chain that interleaves x_content steps with Lindenbaum detours

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - close the 2 main sorries
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - possibly add Lindenbaum extension helper
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` - seed consistency infrastructure

**Verification**:
- `succ_chain_restricted_forward_F` compiles with no sorry
- `succ_chain_restricted_backward_P` compiles with no sorry
- `lake build` succeeds

---

### Phase 5: Cleanup, Auxiliary Sorries, and Verification [NOT STARTED]

**Goal**: Close auxiliary sorries, remove deprecated code, verify full completeness path is sorry-free.

**Known issue from Phases 1-3**: `F_until_equiv_valid` and `P_since_equiv_valid` in Soundness.lean now have sorries — under mixed semantics, F(ψ) includes the present (≤) but Until requires strict future (>), so `F(ψ) → ⊤ U ψ` is no longer valid. These axioms may need to be removed or the equivalence reformulated.

**Tasks**:
- [ ] Resolve `F_until_equiv` / `P_since_equiv` axiom validity gap (remove axioms or reformulate)
- [ ] Close or remove `restricted_chain_G_step` and `restricted_chain_H_step` in RestrictedTruthLemma.lean (may be unnecessary with reflexive coherence making the proofs simpler)
- [ ] Verify `bfmcs_restricted_temporally_coherent` is sorry-free (it delegates to the now-closed `succ_chain_restricted_forward_F`/`backward_P`)
- [ ] Verify `restricted_bundle_validity_implies_provability` is sorry-free
- [ ] Verify `completeness_over_Int` is sorry-free
- [ ] Verify `discrete_completeness_fc` is sorry-free
- [ ] Delete irreflexivity infrastructure from `CanonicalIrreflexivity.lean` (ExistsTask M M now holds under reflexive semantics). Extract `atoms_of_set`/`fresh_for_set` utilities if used elsewhere.
- [ ] Evaluate whether DovetailedChain.lean deprecated sorries should be updated or the file deleted
- [ ] Update `always` operator comment in Formula.lean (middle conjunct now redundant under reflexive G/H but leave definition unchanged)
- [ ] Update `weak_future`/`weak_past` documentation (now semantically identical to G/H)
- [ ] Review derived theorems involving F(φ)/P(φ) in TemporalDerived.lean (these now include present: φ → F(φ) is valid)
- [ ] Add comments to seriality/density axioms noting they are derivable under reflexive semantics
- [ ] Update docstrings and module documentation to reflect reflexive semantics (Truth.lean header, Axioms.lean counts, ~30 files with "strict" references)
- [ ] Run `lake build` on full project to verify no regressions
- [ ] Count remaining sorries in entire `Theories/Bimodal/` tree; document any that remain (should only be `dense_completeness_fc` and any task 82 items)

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` - close or remove auxiliary sorries
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - evaluate for deletion
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` - evaluate deprecated sorries
- `Theories/Bimodal/FrameConditions/Completeness.lean` - update documentation
- Various files - docstring updates

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/` shows only expected remaining sorries (dense_completeness_fc, task 82 items)
- `completeness_over_Int` and `discrete_completeness_fc` are fully sorry-free

## Testing & Validation

- [ ] `lake build` compiles entire project with no errors after each phase
- [ ] Seed consistency prototype (Phase 1) compiles sorry-free before committing to migration
- [ ] T-axiom soundness proofs are sorry-free
- [ ] `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` are sorry-free
- [ ] `completeness_over_Int` is sorry-free
- [ ] `discrete_completeness_fc` is sorry-free
- [ ] No new sorries introduced (sorry count should decrease, not increase)
- [ ] Until/Since semantics still use strict witnesses (backward compatibility)

## Artifacts & Outputs

- `plans/26_completeness-closure.md` (this file)
- Modified `Theories/Bimodal/Semantics/Truth.lean` (reflexive G/H)
- Modified `Theories/Bimodal/ProofSystem/Axioms.lean` (T-axiom constructors)
- Modified `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` (reflexive FMCS)
- Modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (closed sorries)
- Potentially deleted `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

## Rollback/Contingency

- **Phase 1 failure**: If seed consistency lemma cannot be proved in Lean, abandon the reflexive switch entirely. The scratch file is deleted; no codebase changes were made.
- **Phase 2-5 failure**: Git revert to pre-Phase 2 commit. The reflexive switch is atomic within a feature branch.
- **Until persistence failure**: If Until obligations do not propagate through Lindenbaum detours, fall back to restricting the F-resolution to formulas that do not involve Until (narrower sorry scope). Alternatively, add Until formulas explicitly to the Lindenbaum seed.
- **General**: Each phase commits independently. Revert to any phase boundary if needed.
