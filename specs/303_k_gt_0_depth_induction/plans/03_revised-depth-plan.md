# Implementation Plan: Task #303 (Revised)

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [PARTIAL]
- **Effort**: 10 hours
- **Dependencies**: None (k=0 infrastructure is sorry-free)
- **Research Inputs**: reports/01_team-research.md, .blocker-research.md
- **Artifacts**: plans/03_revised-depth-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the remaining sorries blocking `completeness_discrete`: the Until/Since backward directions in `existPart_succ_n1_bypass` (KampBypass.lean:356, 368) and the n>=2 case in `existPart_succ` (KampMutualInduction.lean:310). Phase 1 (mutual induction scaffold) and the forward direction + Eq zone backward of Phase 2 are already complete. The revised approach replaces the failed `compat_disj`-only formula with a cross-structure NF transfer strategy that uses the already-proved `nf_extend_fwd`/`nf_extend_bwd`/`exist_transfer_const_env` lemmas (KampBypass.lean:33-92) plus a new enriched formula encoding both 1-var type and quantifier conditions.

### Research Integration

Key findings integrated from blocker research:
1. `compat_disj` (disjunction over compatible 1-var NF types) is provably too weak for backward direction -- it encodes only 1-var predicate compatibility, not 2-var quantifier conditions
2. NfComposition.lean contains formal counterexample proving 1-var NF compositionality is FALSE for n>=2 on Prior structures
3. ExistPart signature limited to constant parent env `(fun _ => t)`, but Until/Since require non-constant parent `[x,t]`
4. Cross-structure NF transfer lemmas (`nf_extend_fwd`, `nf_extend_bwd`, `exist_transfer_const_env`) already proved in KampBypass.lean:33-92 provide the mechanism to bridge constant-env ExistPart to the non-constant case
5. Eq zone backward already closed in Phase 2 using `ih_exist` at constant env (KampBypass.lean:376-515)

### Prior Plan Reference

Replaces plans/02_depth-induction-plan.md. Phase 1 [COMPLETED] preserved. Phase 2 restructured into Phases 2-4. Original Phases 3-4 become Phases 5-6.

## Goals & Non-Goals

**Goals**:
- Close the 2 remaining sorries at KampBypass.lean:356, 368 (Until/Since backward)
- Close the n>=2 sorry at KampMutualInduction.lean:310
- Wire the sorry-free mutual induction into NfCharFormula and verify `completeness_discrete`
- Maintain all existing sorry-free infrastructure (no regressions)

**Non-Goals**:
- Closing `nf_exist_backward_prior` (NfCharFormula.lean:542, dead code)
- Modifying k=0 zone infrastructure (KampBypassCore/Until/Since are sorry-free)
- Generalizing ExistPart to arbitrary parent environments (constant env suffices via transfer)
- Creating new VecEA2-based files (the cross-structure transfer approach avoids this)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-structure transfer approach fails: `exist_transfer_const_env` cannot bridge the Until/Since quantifier gap | H | M | The lemma `exist_transfer_const_env` handles arity-2 existentials with constant envs. The challenge is connecting the Until/Since witness x's 1-var type to a constant-env transfer scenario. Fallback: full VecEA2 bracket construction (~1600 lines, see blocker-research.md). |
| Enriched formula for Until/Since exceeds heartbeat budget | M | M | Factor proofs into small private helper lemmas. Use `set_option maxHeartbeats 3200000` as in existing KampBypass files. |
| n>=2 arity-climbing at k>0 requires more infrastructure than k=0 | M | L | Same mathematical argument as depth-0 (bool_eq_of_iff_same + constant-base projection). The k>0 version needs quantifier-part transfer in addition to atom transfer, but `exist_transfer_const_env` provides exactly this. |
| Heartbeat/timeout in NormalForm enumeration | M | M | Decompose formula construction into definitional helpers outside proof terms. |
| Build regression from new imports | L | L | Build incrementally after each phase. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Revive Mutual Induction Scaffold [COMPLETED]

**Goal**: Create `KampMutualInduction.lean` with CharPart/ExistPart definitions, base cases, and sorry-free step cases from the boneyard.

**Tasks**:
- [x] Create `KampMutualInduction.lean` (358 lines)
- [x] Port CharPart/ExistPart definitions
- [x] Port charPart_zero, charPart_succ (sorry-free)
- [x] Port existPart_zero (sorry-free for all n)
- [x] Port existPart_succ skeleton (sorry at n>=2 k>0)
- [x] Port kamp_mutual_induction (combined Nat.rec)
- [x] Port nf_2var_exist_formula_prior_filled (NfCharFormula connector)
- [x] Verify build with expected sorry sites

**Timing**: 2 hours
**Depends on**: none
**Completed**: 2026-06-15

---

### Phase 2: Close Until Zone Backward via Cross-Structure Transfer [BLOCKED]

**BLOCKER** (Phase 2):
- **What failed**: The compositionality approach (1-var NF types + ordering determine 2-var NF type) is FORMALLY FALSE on Prior structures. Counterexample: M=(Z,<) with no predicates, env1=(0,2), env2=(0,1), k=1. All points have same 1-var NF (translation symmetry), same ordering (both 0 < 2 and 0 < 1), but different 2-var NFs (interval (0,2) contains 1, interval (0,1) is empty). Z with no predicates IS a Prior structure (UZ/SZ trivially satisfied).
- **What was tried**: (1) Cross-structure NF transfer via nf_extend_fwd/nf_extend_bwd -- requires depth-(k'+2) 2-var agreement which presupposes compositionality. (2) Formula enrichment via ih_exist -- ih_exist requires constant parent env (fun _ => t), but Until zone quantifier conditions involve [y, x, t] with non-constant parent [x, t]. (3) Using ih_exist at x with x's parent_atoms -- gives env [y, x, x] not [y, x, t]. (4) nf_extend_fwd at arity 1 -- produces depth-(k'+1) 2-var agreement (one depth too low; need depth-(k'+2)).
- **Why stuck**: The ExistPart signature restricts to constant parent env `(fun _ => t)`. The Until zone's 3-var conditions have non-constant parent `[x, t]`. No existing infrastructure bridges this gap.
- **What is needed**: One of: (a) Strengthen ExistPart to handle 2-var parent envs (major restructuring of mutual induction). (b) Generalize VecEA2 bracket construction from k=0 to k>0, encoding zone-specific quantifier conditions via nested temporal operators and ih_exist at lower depth. (c) Adopt Rabinovich's negation closure argument (Lemma 5.1) as the proof mechanism. All are substantial architectural changes requiring plan revision.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder.

**Goal**: Fill the `sorry` at KampBypass.lean:356 (Until zone backward, `succ k'` branch, `true, false` case). The backward direction must show: given `temporal_truth M atomMap t (Formula.untl compat_disj Formula.top)`, produce a witness `x > t` with `nf_eval_nf M (k'+1+1) 2 [x, t] sub_nf`.

**Strategy (INVALIDATED)**: The compositionality-based strategy is invalid because compositionality is false on Prior structures (see NfComposition.lean counterexample and analysis above).

**Tasks**:
- [ ] **Task 2.1**: *(deviation: skipped -- compositionality is false on Prior structures, cannot prove prior_2var_nf_transfer_until)*
- [ ] **Task 2.2**: *(deviation: skipped -- depends on Task 2.1)*
- [ ] **Task 2.3**: *(deviation: skipped -- depends on Task 2.1)*

**Timing**: 3 hours
**Depends on**: none (builds on completed Phase 1 infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- add compositionality lemma, fill Until backward sorry

**Verification**:
- `lean_goal` at the Until sorry site shows no goals
- KampBypass.lean builds with at most 1 zone sorry remaining (Since)

---

### Phase 3: Close Since Zone Backward [NOT STARTED]

**Goal**: Fill the `sorry` at KampBypass.lean:368 (Since zone backward, `succ k'` branch, `false, true` case). This is symmetric to the Until case but with reversed ordering.

**Strategy**: Mirror the Until compositionality lemma with x < t instead of x > t. The `Formula.snce compat_disj Formula.top` backward yields x < t with matching 1-var type. The transfer argument is identical modulo direction.

**Tasks**:
- [ ] **Task 3.1**: Prove `prior_2var_nf_transfer_since` (or generalize the Until version to handle both directions via a `direction : Bool` parameter). If the Until lemma is parameterized by direction, this phase reduces to instantiation. Estimated ~50-150 lines (less if parameterized).
- [ ] **Task 3.2**: Apply the transfer to the Since backward direction, mirroring Phase 2's application. Estimated ~50-100 lines.
- [ ] **Task 3.3**: Verify `lean_verify` on `existPart_succ_n1_bypass` shows NO `sorryAx` (all zone sorries closed).

**Timing**: 2 hours
**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- add Since transfer (or reuse Until's), fill Since backward sorry

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass` shows NO `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds with 0 sorries

---

### Phase 4: Close n>=2 Sorry in existPart_succ [NOT STARTED]

**Goal**: Fill the `sorry` at KampMutualInduction.lean:310 (existPart_succ n>=2 case). With n=1 at all depths now sorry-free, close n>=2 using the constant-base projection pattern.

**Strategy**: Same as the k=0 pattern in `existPart_zero` (lines 183-285): when all base variables equal t, the (n+2)-var existential projects to a 2-var existential. The atom part projects via `bool_eq_of_iff_same`. The quantifier part: at depth k+1, the (n+3)-var quantifier conditions at depth k with constant base `(fun _ => t)` project to 3-var conditions. Use `exist_transfer_const_env` to show the quantifier conditions are equivalent.

**Tasks**:
- [ ] **Task 4.1**: In `KampMutualInduction.lean`, replace the `sorry` in the `succ n''` case of `existPart_succ` with the satisfiable/unsatisfiable case split (Classical.em), mirroring `existPart_zero`'s n>=2 pattern.
- [ ] **Task 4.2**: For the satisfiable case: project sub_nf to a 2-var NF sub_nf_2, use n=1 ExistPart to get the 2-var formula A_2. Prove atom equivalence via `bool_eq_of_iff_same` and quantifier equivalence via `exist_transfer_const_env` (both directions). Estimated ~100-200 lines.
- [ ] **Task 4.3**: Verify `lean_verify` on `existPart_succ` and `kamp_mutual_induction` show NO `sorryAx`.

**Timing**: 2 hours
**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- fill n>=2 sorry

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ` shows NO `sorryAx`
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_mutual_induction` shows NO `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` succeeds with 0 sorries

---

### Phase 5: Wire Mutual Induction into NfCharFormula [NOT STARTED]

**Goal**: Connect the sorry-free mutual induction to the live NfCharFormula dispatch. Verify the entire completeness chain is sorry-free.

**Tasks**:
- [ ] **Task 5.1**: Check whether `existPart_succ_n1_bypass` being sorry-free automatically makes the NfCharFormula dispatch sorry-free (since the call chain goes `nf_2var_exist_formula_prior` -> `nf_2var_exist_formula_prior_filled` -> `kamp_mutual_induction` -> `existPart_succ` -> `existPart_succ_n1_bypass`). If yes, no NfCharFormula changes needed.
- [ ] **Task 5.2**: Run `lean_verify` on `nf_2var_exist_formula_prior_filled` to confirm no `sorryAx`.
- [ ] **Task 5.3**: Run `lean_verify` on `nf_characterizable_temporal_prior_classical` to confirm no `sorryAx`.
- [ ] **Task 5.4**: Run `lean_verify` on `kamp_prior_expressive_completeness` to confirm no `sorryAx`.
- [ ] **Task 5.5**: Run `lean_verify` on `completeness_discrete` to confirm no `sorryAx` (or identify remaining sorry chains from other paths).

**Timing**: 0.5 hours
**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- potentially update dispatch (only if needed)

**Verification**:
- `lean_verify` on entire completeness chain shows no `sorryAx` from this path
- `lake build` succeeds with no new sorries introduced

---

### Phase 6: Final Verification and Cleanup [NOT STARTED]

**Goal**: Full project build verification, boneyard cleanup, and summary.

**Tasks**:
- [ ] **Task 6.1**: Run full `lake build` to confirm no regressions.
- [ ] **Task 6.2**: Update `RabinovichGeneralized.lean` boneyard archive comment to note live version is in `KampMutualInduction.lean`.
- [ ] **Task 6.3**: Write implementation summary.

**Timing**: 0.5 hours
**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Boneyard/RabinovichPath/RabinovichGeneralized.lean` -- update archive comment

**Verification**:
- `lake build` succeeds with no regressions
- k=0 path (KampBypassCore/Until/Since) remains untouched and sorry-free

## Testing & Validation

- [ ] `lean_verify` on `existPart_succ_n1_bypass` at all depths shows no `sorryAx`
- [ ] `lean_verify` on `existPart_succ` shows no `sorryAx`
- [ ] `lean_verify` on `kamp_mutual_induction` shows no `sorryAx`
- [ ] `lean_verify` on `nf_2var_exist_formula_prior_filled` shows no `sorryAx`
- [ ] `lean_verify` on `completeness_discrete` to assess remaining sorry count
- [ ] Full `lake build` with no regressions
- [ ] k=0 path (KampBypassCore/Until/Since) remains untouched and sorry-free

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- EXISTING: mutual induction scaffold, Phase 4 fills n>=2 sorry
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- EXISTING: Phases 2-3 fill Until/Since backward sorries, add compositionality lemmas
- `specs/303_k_gt_0_depth_induction/summaries/03_revised-depth-summary.md` -- implementation summary

## Rollback/Contingency

If the cross-structure transfer approach fails for Until/Since (Risk 1):
1. **Fallback A**: Full VecEA2 bracket construction at depth k. Create KampBypassUntilK.lean (~800-1200 lines) and KampBypassSinceK.lean (~800-1200 lines) mirroring the k=0 infrastructure. This is higher effort but follows a proven pattern. See blocker-research.md "Alternative: VecEA2-based Until/Since formula at depth k" section.
2. **Fallback B**: Reformulate the mutual induction with a strengthened ExistPart that supports non-constant parent environments (Approach C from blocker research). Higher architectural risk.
3. The Phase 1 scaffold and forward directions remain intact regardless -- no regression possible.
4. `git revert` any Phase 2+ commits to restore the pre-attempt state.
