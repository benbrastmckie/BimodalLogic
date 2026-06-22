# Implementation Plan: VecEA Bridge for Zone-3 Existential Transfer

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Phases 1-5, 6a-6c [COMPLETED] from prior plans; sorry-free VecEA translation pipeline
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/07_zone3-induction-design.md
- **Artifacts**: plans/10_vecEA-bridge-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v9 (zone3-induction-plan) attempted to resolve the 5 sorries in PriorComposition.lean via a depth-decreasing induction on the NF depth d. Phase 1 was BLOCKED because the char-NF architecture inherently loses 1 depth level per `exist_transfer_from_full_agree` invocation, creating an unpatchable circular dependency. Three implementation cycles confirmed this.

The resolution: build a bridge from the NF layer (`NormalForm sig d r`) to the VecEA layer for 3-var non-constant-env existential transfer. Rabinovich's Proposition 3.5 (V-EA to TL conversion) is ALREADY sorry-free in Translation.lean + VecEATranslation.lean + RabinovichTranslation.lean. The depth-0 3-var VecEA decomposition is sorry-free in VecEADecomp.lean, and the NF-to-VecEA conversion is sorry-free in NfToVecEA.lean.

The fix composes these existing sorry-free components: convert the bounded 3-var existential into a temporal formula via the VecEA2 pipeline, transfer the temporal formula using 1-var agreement (from h_t at depth K+2), then extract the witness on the target side. This avoids the depth gap entirely because temporal formulas transfer via 1-var agreement at the appropriate depth.

Definition of done: `PriorComposition.lean` compiles sorry-free; `lake build` succeeds with no sorry on the critical path through KampBypass to completeness_discrete.

### Research Integration

Report 07 (zone3-induction-design) analyzed 8 approaches to the zone-3 transfer and verified that all bidirectional char-NF approaches hit the h_rvar circularity. The VecEA bridge approach resolves this by avoiding the NF-layer depth induction entirely, instead converting through the temporal formula layer.

### Prior Plan Reference

Plan v9 was BLOCKED at Phase 1. The depth-induction approach is abandoned. The sorry-free infrastructure from earlier plans (nvar_transfer_from_1var_agree, zone 1/2/4/5 transfer) remains intact and useful.

### Postmortem Constraints

1. Do NOT attempt `nvar_transfer_from_1var_agree` at depth K+1 arity 3 -- requires h_rvar at depth K+2 arity 3 (circular, proven by 8 failed approaches across 3 cycles).
2. Do NOT seek full biconditional NF agreement at the new witness -- only temporal transfer is needed.
3. Do NOT use `exist_transfer_from_full_agree` as the primary mechanism for depth K+1 -- it outputs depth K (one short).
4. Do NOT modify existing sorry-free infrastructure (NfToVecEA, VecEADecomp, VecEATranslation, RabinovichTranslation, NfComposition, VecEAClosure, etc.).

## Goals & Non-Goals

**Goals**:
- Build a bridge lemma converting 3-var depth-0 existential to a temporal formula at the base variable
- Use 1-var agreement to transfer the temporal formula across structures
- Fill all 5 sorry sites in PriorComposition.lean (line 524, 595, 599, 650, 654)
- Achieve `lake build` clean on the entire Kamp module
- Verify `completeness_discrete` compiles sorry-free

**Non-Goals**:
- Proving full biconditional r-var NF agreement for the zone-3 witness
- Modifying the outer strong induction structure of prior_nonconstenv_2var_agree_until/since
- Changes to NfToVecEA.lean, VecEADecomp.lean, VecEATranslation.lean, or RabinovichTranslation.lean
- Dead-code sorry elimination in NfCharFormula.lean or EANegation.lean
- Restructuring the already sorry-free `nvar_transfer_from_1var_agree`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| VecEA2 translation at depth 0 covers only the bracket zone (t < y < x), not all 6 zones | H | M | VecEADecomp.lean already handles all 6 zones at depth 0 with sorry-free zone-specific theorems. Use the zone-matching dispatch. |
| The temporal formula produced by VecEA2 translation has depth > K+2, exceeding h_t's agreement level | H | L | Depth budget: sub_nf at depth K+1 arity 3 => depth-0 existential at arity 3 => VecEA2 translation adds at most 1 Until/Since nesting => temporal formula at depth <= 1. h_t gives depth-(K+2) 1-var agreement, which captures depth-1 temporal formulas for all K >= 0. |
| The NF quantifier layer (depth > 0) requires recursive treatment beyond the depth-0 VecEA decomposition | H | M | At depth d+1: the quantifier part of `sub_nf` gives `exists z, nf_eval M d (r+1) [z, ...] chi`. Use the IH of the outer strong induction on K (at K-1) to get depth-(K+1) 2-var agreement, whose quantifier condition gives the depth-K 3-var existential transfer at lower depth. Alternatively, use `prior_exist_transfer_one_dir` recursively at depth d < K+1. |
| `cross_extend_bwd_1var` witness w2 may not land in zone 3 (between t' and x') | M | M | The temporal formula approach bypasses zone placement entirely. The temporal formula holds at ALL points where the NF type matches, so we only need 1-var agreement transfer -- no zone placement required. |
| K=0 edge case: ih_strong is vacuous | M | L | At K=0 the goal is depth-1 3-var transfer. The sub_nf decomposes into atoms (depth 0) + quantifier conditions (depth-0 4-var). The depth-0 case uses VecEA decomposition directly; quantifier conditions at depth 0 are purely atomic and transfer via h_x/h_t. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: NF-to-Temporal Bridge Lemma (Depth 0, 3-var) [NOT STARTED]

**Goal**: Create a new file `PriorExistPart.lean` containing a bridge lemma that converts a depth-0 3-var bounded existential (zone 3: t < w < x) into a temporal formula, and proves that 1-var agreement at depth 2 suffices to transfer it.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorExistPart.lean` with imports from VecEADecomp, VecEATranslation, NfToVecEA, RabinovichTranslation, PriorComposition
- [ ] Define `nf_3var_to_temporal`: given `ssn : NormalForm sig 0 3` with zone-3 order booleans (t < y, y < x), construct the temporal formula equivalent to `exists y, t < y < x /\ nf_eval M 0 3 [y,x,t] ssn`. Use `nf_3var_bracket_tyx` from VecEADecomp to get VecEA2, then `bracketBuildRight` from VecEATranslation to get the temporal formula.
- [ ] Prove `nf_3var_to_temporal_correct`: the temporal formula at t is equivalent to the bounded 3-var existential. Compose `nf_3var_bracket_tyx_correct` with `bracketBuildRight_correct` (or the full VecEA2.translateLeft_correct).
- [ ] Define `nf_3var_to_temporal_since` for the Since zone (x < y, y < t) using `nf_3var_bracket_xyt` and `bracketBuildLeft`.
- [ ] Prove `nf_3var_to_temporal_since_correct` analogously.
- [ ] Define the transfer lemma `depth0_zone3_exist_transfer_until`: given `ssn : NormalForm sig 0 3`, `exists w in M, t < w < x /\ nf_eval M 0 3 [w,x,t] ssn` and depth-2 1-var agreement at x/x' and t/t', produce `exists w' in N, t' < w' < x' /\ nf_eval N 0 3 [w',x',t'] ssn`. Strategy: convert to temporal formula via `nf_3var_to_temporal_correct`, transfer via h_t (depth-2 temporal truth agreement from 1-var agreement), convert back.
- [ ] Prove `depth0_zone3_exist_transfer_since` symmetrically.
- [ ] For non-zone-3 cases at depth 0 (zones 1,2,4,5 and equality cases): these are already handled by existing sorry-free code in PriorComposition.lean. Verify no new lemmas needed.
- [ ] Verify the file compiles sorry-free with `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorExistPart`

**Timing**: 2 hours

**Depends on**: none

**Files to create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorExistPart.lean` (~300-400 lines)

**Key Mechanism**:
```
Given: ∃ w ∈ (t,x), nf_eval M 0 3 [w,x,t] ssn
  1. nf_3var_bracket_tyx_correct: ↔ VecEA2.holds M atomMap t x
  2. VecEA2.translateLeft_correct (or bracketBuildRight_correct): ↔ temporal_truth M atomMap t φ
  3. h_t at depth 2: temporal_truth M atomMap t φ ↔ temporal_truth N atomMap t' φ
     (φ has depth ≤ 1, h_t gives depth-2 1-var agreement which captures depth-1 temporal formulas)
  4. Reverse steps 2,1 on N: temporal_truth N atomMap t' φ → VecEA2.holds N → ∃ w'
```

**Note on temporal depth**: The VecEA2 with n=1 bracket witness translates to a single Until formula `β U (α ∧ G β')` or similar. This has temporal depth 1. The 1-var agreement at depth d captures temporal formulas of depth ≤ d-1 (since temporal connectives correspond to NF quantifier levels). So h_t at depth K+2 captures temporal formulas of depth ≤ K+1, which includes depth-1 for all K >= 0.

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorExistPart` succeeds sorry-free
- `lean_verify` on the bridge lemmas shows no sorry axiom

---

### Phase 2: Rewire `prior_exist_transfer_one_dir` [NOT STARTED]

**Goal**: Replace the sorry at line 524 of PriorComposition.lean with a proof that uses the depth-0 bridge from Phase 1 for the base case and recursive NF decomposition for higher depths.

**Tasks**:
- [ ] Add `import Bimodal.Metalogic.WeakCanonical.Kamp.PriorExistPart` to PriorComposition.lean
- [ ] Replace the sorry at line 524 with a proof by `Nat.rec` on `d`:
  - **Base case (d=0)**: Sub_nf is a depth-0 NF at arity r+1. The existential `exists z, nf_eval M 0 (r+1) [z, env...] sub_nf` decomposes by zone. For the zone-3 case (z between two env elements): apply `depth0_zone3_exist_transfer_until` or `_since` from Phase 1, instantiated with the appropriate env elements and their 1-var agreement. For non-zone-3 cases: the existing zone 1/2/4/5 handling (cross_extend) suffices.
  - **Inductive step (d+1)**: Sub_nf at depth d+1 has atom part and quantifier part. The atom part transfers via depth-0 existential transfer (base case). The quantifier part asks for depth-d existentials at arity r+2. Apply the IH at depth d (strictly smaller) for these. The termination argument is d decreasing.
- [ ] Handle the arity-general case: the bridge lemma from Phase 1 is for arity 3 (env = [x,t]). For general arity r, the env has r elements and the existential adds one. Generalize by projecting the r-var env to the relevant 2 elements for the temporal formula transfer.
- [ ] Verify `prior_exist_transfer_one_dir` compiles sorry-free
- [ ] Check that existing uses of `prior_exist_transfer_one_dir` (if any) still type-check

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (~100-200 lines replacing the sorry block)

**Key Depth Budget**:
- h_1var provides depth-(d+1) 1-var agreement at each env element
- Phase 1 bridge needs depth-2 1-var agreement for the depth-0 case: d+1 >= 2 when d >= 1, and the d=0 case is handled separately (atoms only at depth 0, no temporal formula needed)
- For d=0: the sub_nf is purely atomic, transfer via h_1var and h_order directly
- For d >= 1: the bridge converts depth-0 zone-3 existentials to temporal formulas; quantifier conditions at depth d recurse to depth d-1

**Verification**:
- `prior_exist_transfer_one_dir` compiles sorry-free
- Sorry count in PriorComposition.lean drops from 5 to 4

---

### Phase 3: Fill Downstream Sorry Sites (Lines 595/599/650/654) [NOT STARTED]

**Goal**: Apply `prior_exist_transfer_one_dir` at the 4 sorry sites in `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since` to complete the biconditional zone-3 transfer.

**Tasks**:
- [ ] Fill line 595 (Until forward): The context has `w : M.carrier`, `hw : nf_eval_nf M (K+1) 3 [w,x,t] sub_nf`, and `w2 : N.carrier` with `hw2` giving cross_extend properties. Replace `sorry` with:
  - Construct the env/env' arguments for `prior_exist_transfer_one_dir` (env = `Fin.cons x (fun _ => t)`, env' = `Fin.cons x' (fun _ => t')`)
  - Provide h_1var: depth-(K+2) 1-var agreement at x/x' (from h_x) and t/t' (from h_t)
  - Provide h_order: order matching (from h_order_M, h_order_N)
  - Provide char_fn and char_correct from the outer theorem parameters
  - Apply with d = K+1, sub = sub_nf, getting `exists w', nf_eval N (K+1) 3 [w',x',t'] sub_nf`
- [ ] Fill line 599 (Until backward): Symmetric -- apply `prior_exist_transfer_one_dir` with M and N swapped (or use the reverse direction). The `cross_extend_fwd_1var` gives a witness in M, but we need to show the sub_nf holds. Apply the transfer from N to M.
- [ ] Fill line 650 (Since forward): Same structure as Until forward but with reversed order (x < t). Adjust env ordering.
- [ ] Fill line 654 (Since backward): Symmetric to line 650.
- [ ] Verify PriorComposition.lean compiles sorry-free

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (~60-100 lines replacing 4 sorry sites)

**Key Insight**: The 4 sorry sites all have the same structure: given `exists w in M/N, nf_eval (K+1) 3 [w,x,t] sub_nf`, produce `exists w' in N/M`. This is exactly what `prior_exist_transfer_one_dir` proves. The only difference between the 4 sites is the direction (M-to-N vs N-to-M) and the order zone (Until: t < x vs Since: x < t).

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns no results
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds sorry-free

---

### Phase 4: Integration Verification and Cleanup [NOT STARTED]

**Goal**: Verify sorry elimination propagates through KampBypass to completeness_discrete, and run full project build.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify sorry-free
- [ ] Run `lean_verify` on `completeness_discrete` to confirm no sorry axiom
- [ ] Run full `lake build` -- verify clean project build
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` to confirm only non-critical dead-code sorries remain (NfCharFormula.lean, EANegation.lean)
- [ ] Optional cleanup: remove or comment out the stale `prior_zone3_exist_transfer` definition from plan v9 if any was written (Phase 1 of plan v9 was BLOCKED, so this may not exist)

**Timing**: 0.5 hours

**Depends on**: 3

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`

**Verification**:
- `lake build` succeeds with no sorry on critical path
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior.completeness_discrete` reports no sorry axiom
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only NfCharFormula.lean and EANegation.lean non-critical sorries

## Testing & Validation

- [ ] Phase 1: PriorExistPart.lean compiles sorry-free; bridge lemmas type-check
- [ ] Phase 2: `prior_exist_transfer_one_dir` compiles sorry-free; sorry count drops to 4
- [ ] Phase 3: All 4 downstream sorry sites eliminated; PriorComposition.lean sorry-free
- [ ] Phase 4: `completeness_discrete` compiles sorry-free (no sorry axiom)
- [ ] Phase 4: Full `lake build` succeeds
- [ ] Final sorry audit confirms only non-critical-path sorries remain

## Artifacts & Outputs

- `plans/10_vecEA-bridge-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorExistPart.lean` -- new file (Phase 1)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry-free (Phases 2-3)

## Rollback/Contingency

- Phase 1 creates a new file only. Rollback = delete PriorExistPart.lean.
- Phase 2 modifies the sorry at line 524. Rollback = `git revert` to pre-Phase-2 commit.
- Phase 3 modifies 4 sorry sites. Rollback = `git revert` to pre-Phase-3 commit.
- Phase 4 is verification only. No rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If the VecEA bridge does not produce temporal formulas within h_t's depth budget**: investigate whether the VecEA2 translation adds more than 1 depth level. Worst case, strengthen h_t to depth K+3 (would require modifying the outer theorem signatures, significant refactor).
- **If the arity generalization in Phase 2 is non-trivial**: factor the bridge to work with 2 designated env elements and ignore the rest, projecting the r-var env down.
