# Implementation Plan: Task #303 -- ExistPart_r Generalization

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (k=0 infrastructure and Phase 1 scaffold are sorry-free)
- **Research Inputs**: reports/02_depth-induction-resolution.md
- **Artifacts**: plans/04_existpart-r-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the SOLE remaining sorry blocking `completeness_discrete` by generalizing ExistPart to ExistPart_r, parameterized by parent NF types instead of just parent atoms. The current ExistPart restricts the parent env to constant `(fun _ => t)`, which works for the Eq zone (where x=t) but fails for Until/Since zones (where the env is `[x, t]` with x != t). ExistPart_r at `r >= 1` carries `r` parent NF types at depth k+1, enabling the Until zone to pass `[nf_x, nf_t]` as parent context. This approach is the natural Lean analog of GHR94 Section 12.8 (Def. 12.8.13, Thm. 12.8.15), which parameterizes decomposition formulas by full NF types at each point. The plan is complete when `lean_verify` on `completeness_discrete` shows no `sorryAx` from this path.

### Research Integration

Key findings from reports/02_depth-induction-resolution.md:

1. **Sole blocker confirmed**: KampBypass.lean lines 356, 368 (Until/Since backward at k>0). Root cause: ExistPart uses constant-parent env `(fun _ => t)`, but Until/Since zones need `[y, x, t]` where x != t. The 1-var NF of x does NOT determine the 2-var NF at `[x, t]` -- this is a genuine information gap.
2. **Path A (ExistPart_r) recommended**: Strengthen ExistPart to carry parent NF types at depth k+1. At r=1, this specializes to current ExistPart. At r=2, it handles Until/Since zones. GHR94 Section 12.8 provides strong literature support.
3. **Path B removed**: Feferman-Vaught composition is strictly heavier and fails for the same structural reason.
4. **NfCharFormula.lean:542 is dead code**: Not on critical path.
5. **n>=2 sorry** (KampMutualInduction.lean:310): Depends on n=1 case; resolves with `bool_eq_of_iff_same` technique.

### Prior Plan Reference

Prior plan (plans/03_revised-depth-plan.md) attempted a cross-structure NF transfer approach using the existing constant-parent ExistPart. Phase 1 (mutual induction scaffold) completed successfully. Phase 2 [BLOCKED]: compositionality is formally false on Prior structures (1-var NF agreement does NOT determine 2-var NF). The blocker analysis across 5 cycles conclusively showed that modifying ExistPart itself is necessary rather than working within the constant-parent constraint. Effort calibration: prior plan estimated 10 hours; this plan adjusts to 8 hours based on the more focused ExistPart_r approach with clearer literature grounding.

### Roadmap Alignment

- Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete"
- This is identified as the SOLE remaining blocker on the critical path to sorry-free discrete completeness.

## Goals & Non-Goals

**Goals**:
- Define ExistPart_r in KampMutualInduction.lean replacing the current ExistPart
- Adapt the mutual induction to use ExistPart_r
- Close the 2 remaining sorries at KampBypass.lean:356, 368 (Until/Since backward)
- Close the n>=2 sorry at KampMutualInduction.lean:310
- Verify the entire completeness chain is sorry-free from this path

**Non-Goals**:
- Closing NfCharFormula.lean:542 (dead code, not on critical path)
- Modifying k=0 zone infrastructure (KampBypassCore/Until/Since are sorry-free)
- General Feferman-Vaught composition theorem (Path A subsumes the needed functionality)
- Restructuring the NfCharFormula dispatch (it should work via the existing connector)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| ExistPart_r signature change breaks existing sorry-free proofs (Eq zone, k=0) | H | L | ExistPart_r at r=1 is exactly ExistPart; existing proofs instantiate at r=1 with trivial parent_nfs wrapper. Test k=0 and Eq zone after Phase 1. |
| existPart_zero generalization to r>1 is more complex than estimated | M | M | The k=0 case uses only atoms (no quantifier structure). The r>1 generalization adds parent NF hypotheses that are not needed at depth 0 -- they can be ignored. Start with r=1 adapter, only generalize if needed. |
| Until/Since backward proof at k>0 requires deeper nf_extend_fwd/bwd chains than available | H | M | The key transfer is: parent NF types at depth k+1 give depth-k agreement at extended arity via nf_extend_fwd. This is exactly what nf_extend_fwd was built for. If the chain needs more steps, factor into helper lemmas. |
| n>=2 arity-climbing at k>0 requires new infrastructure beyond bool_eq_of_iff_same | M | L | The r>1 parent_nfs provide the extra context needed. Worst case add ~100 lines of adaptation. |
| Heartbeat timeouts from enlarged formula/proof terms | M | M | Factor proofs into small private helpers. Use set_option maxHeartbeats as in existing KampBypass files. |

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

### Phase 1: Define ExistPart_r and Adapt Mutual Induction [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: ExistPart_r and NfCompose are both FALSE on Prior structures. Counterexample in NfComposition.lean:20-36: on (Z, <), pairs (0,2) and (0,1) have identical arity-1 NFs and matching orders, but different arity-2 NFs due to differing zone structure (element between 0 and 2 exists; none between 0 and 1).
- **What was tried**: (1) ExistPart_r with r parent NFs — formula cannot distinguish pairs with same NF types but different zone structure. (2) NfCompose(k) composition theorem — provably false counterexample documented in codebase. (3) nf_extend_fwd chain — depth gap: loses one depth level per arity increase, cannot reach target depth.
- **Why stuck**: The constant-parent constraint in ih_exist (`fun _ => t`) cannot express `[y, x, t]` with distinct x, t. The 2-var NF at [x, t] depends on zone interior structure, not just individual NF types.
- **What is needed**: Zone-explicit temporal formula encoding (Rabinovich Section 5 approach) — decompose quantifier conditions by y's position relative to x and t, encode each zone as a nested temporal formula.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Replace the ExistPart definition with ExistPart_r parameterized by parent NF types, and adapt the mutual induction scaffold so the project builds (with existing sorries remaining).

**Tasks**:
- [ ] Define `ExistPart_r` in KampMutualInduction.lean:
  ```
  abbrev ExistPart_r (atomMap : Formula -> sig.preds) (h_surj : ...) (k : Nat) : Prop :=
    forall (n : Nat) (_ : n >= 1) (r : Nat) (_ : r >= 1)
      (char_k : NormalForm sig k 1 -> Formula)
      (char_k_correct : ...)
      (parent_nfs : Fin r -> NormalForm sig k 1)
      (sub_nf : NormalForm sig k (n + r)),
    exists A, forall M h_UZ h_SZ (env : Fin r -> M.carrier),
      (forall i, nf_eval_nf M k 1 (fun _ => env i) (parent_nfs i)) ->
      (temporal_truth M atomMap (env 0) A <->
       exists x, nf_eval_nf M k (n + r) (Fin.cons x env) sub_nf)
  ```
  NOTE: The exact Lean signature may need adjustment for depth indexing. The key constraint is that parent_nfs are at depth k (same as sub_nf's depth), not k+1. The caller (existPart_succ_n1_bypass at depth k+1) passes char_{k+1} NF types as parent context. Verify the correct depth alignment during implementation.
- [ ] Adapt `existPart_zero` signature to match ExistPart_r (r=1 case should be straightforward; r>1 at depth 0 uses only atoms, parent NF hypotheses can be absorbed)
- [ ] Adapt `existPart_succ` signature to match ExistPart_r
- [ ] Adapt `kamp_mutual_induction` to prove CharPart(k) AND ExistPart_r(k)
- [ ] Adapt `nf_2var_exist_formula_prior_filled` connector to extract from ExistPart_r at r=1
- [ ] Verify the project builds (`lake build`) with existing sorries unchanged (no new sorries, no regressions)

**Timing**: 2 hours
**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- ExistPart_r definition, mutual induction adaptation
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- update existPart_succ_n1_bypass signature to accept ExistPart_r's ih_exist

**Verification**:
- `lake build` succeeds with no new sorries
- Existing sorry-free proofs (charPart_zero, charPart_succ, existPart_zero, Eq zone backward) remain sorry-free
- Sorry sites remain only at KampBypass.lean:356, 368 and KampMutualInduction.lean:310

---

### Phase 2: Close Until/Since Backward via ExistPart_r at r=2 [NOT STARTED]

**Goal**: Fill the sorry at KampBypass.lean:356 (Until zone backward) and 368 (Since zone backward) using ExistPart_r with r=2 parent NF types.

**Tasks**:
- [ ] In the Until backward branch (line 356), construct the enriched formula:
  - For each compatible pair (nf_x, nf_t) where nf_x matches sub_nf's atom part and nf_t matches parent_atoms:
  - Use `ih_exist` at r=2 with `parent_nfs = [nf_x, nf_t]` and appropriate sub_nf restriction
  - The temporal formula becomes: `char_kp1(nf_t) AND Until(char_kp1(nf_x) AND ih_exist_formula, top)`
  - Build the disjunction over all compatible pairs
- [ ] Prove backward direction: from the temporal formula, extract the Until witness x with `char_kp1(nf_x)` holding, then use the ih_exist_formula to reconstruct the full 2-var NF evaluation
- [ ] Prove forward direction: from exists x with nf_eval_nf, show the temporal formula holds (should follow the existing fwd_disj pattern with enrichment)
- [ ] Mirror the Until proof for the Since backward branch (line 368) with reversed ordering
- [ ] Verify both sorry sites are closed: `lean_goal` at lines 356 and 368 shows no goals

**Timing**: 2.5 hours
**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- fill Until and Since backward sorries with ExistPart_r-based proofs

**Verification**:
- `lean_goal` at KampBypass.lean lines 356, 368 shows no goals
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass` shows no `sorryAx` from Until/Since zones
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds

---

### Phase 3: Close n>=2 Sorry in existPart_succ [NOT STARTED]

**Goal**: Fill the sorry at KampMutualInduction.lean:310 (existPart_succ n>=2 case). With n=1 at all depths sorry-free, close n>=2 using the constant-base projection pattern from existPart_zero.

**Tasks**:
- [ ] In KampMutualInduction.lean, replace the sorry in the `succ n''` case of existPart_succ with the satisfiable/unsatisfiable case split (Classical.em), mirroring existPart_zero's n>=2 pattern
- [ ] For the satisfiable case: use the M0 witness to determine which sub-NFs are realized. Project sub_nf to a 2-var NF (or use ExistPart_r at r=1 with appropriate parent_nfs) to get the formula. Prove atom equivalence via `bool_eq_of_iff_same` and quantifier equivalence via the parent NF agreement chain.
- [ ] For the unsatisfiable case: use Formula.bot (same as existing pattern)
- [ ] Verify `lean_verify` on `existPart_succ` and `kamp_mutual_induction` show no `sorryAx`

**Timing**: 1.5 hours
**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- fill n>=2 sorry

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ` shows no `sorryAx`
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.kamp_mutual_induction` shows no `sorryAx`
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` succeeds with 0 sorries

---

### Phase 4: Wire and Verify Completeness Chain [NOT STARTED]

**Goal**: Verify the entire completeness chain from `existPart_succ_n1_bypass` through `completeness_discrete` is sorry-free. Fix any remaining wiring issues.

**Tasks**:
- [ ] Run `lean_verify` on `nf_2var_exist_formula_prior_filled` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `nf_characterizable_temporal_prior_classical` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `kamp_prior_expressive_completeness` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `US_expressively_complete_over_prior` to confirm no `sorryAx`
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no `sorryAx` from this path (or identify remaining sorry chains from other paths)
- [ ] Fix any wiring issues discovered during verification (e.g., NfCharFormula connector adjustments)

**Timing**: 1 hour
**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- only if connector adjustments needed
- Any other files in the completeness chain if wiring issues found

**Verification**:
- `lean_verify` on entire completeness chain shows no `sorryAx` from this path
- `lake build` succeeds with no new sorries

---

### Phase 5: Final Build Verification and Cleanup [NOT STARTED]

**Goal**: Full project build, boneyard annotation, and implementation summary.

**Tasks**:
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update boneyard comment in `RabinovichGeneralized.lean` to note live version is in KampMutualInduction.lean with ExistPart_r
- [ ] Verify k=0 infrastructure (KampBypassCore/Until/Since) remains untouched and sorry-free
- [ ] Write implementation summary

**Timing**: 1 hour
**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Boneyard/RabinovichPath/RabinovichGeneralized.lean` -- update archive comment

**Verification**:
- `lake build` succeeds with no regressions
- k=0 path remains untouched and sorry-free
- Implementation summary written to specs/303_k_gt_0_depth_induction/summaries/

## Testing & Validation

- [ ] After Phase 1: `lake build` succeeds with no new sorries; existing sorry-free proofs preserved
- [ ] After Phase 2: `lean_verify` on `existPart_succ_n1_bypass` shows no `sorryAx` from Until/Since zones
- [ ] After Phase 3: `lean_verify` on `kamp_mutual_induction` shows no `sorryAx`
- [ ] After Phase 4: `lean_verify` on `completeness_discrete` assesses remaining sorry count from this path
- [ ] After Phase 5: Full `lake build` with no regressions; k=0 path untouched

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- ExistPart_r definition and sorry-free mutual induction
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- Sorry-free Until/Since backward proofs using ExistPart_r
- `specs/303_k_gt_0_depth_induction/plans/04_existpart-r-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/summaries/04_existpart-r-summary.md` -- implementation summary

## Rollback/Contingency

If ExistPart_r cannot close the Until/Since backward sorries (Risk 3 materializes):

1. **Diagnose the specific failure point**: Identify which step of the nf_extend_fwd/bwd chain fails and whether the issue is depth alignment, arity mismatch, or a genuinely missing lemma.
2. **Adapt ExistPart_r signature**: If the parent_nfs depth indexing is wrong (e.g., needs depth k+1 instead of k), adjust the signature. The literature (GHR94 Section 12.8) parameterizes by the decomposition at each point, which may require a different depth arrangement.
3. **Fallback to VecEA2 bracket construction at depth k**: Create KampBypassUntilK.lean and KampBypassSinceK.lean mirroring the k=0 infrastructure with ih_exist formulas for quantifier conditions. Higher effort (~1600 lines) but follows a proven pattern.
4. Phase 1 scaffold and all forward directions remain intact -- no regression possible.
5. `git revert` any phase commits to restore the pre-attempt state.
