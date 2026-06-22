# Implementation Plan: Task #305 -- char_fn + Prior-UZ/SZ Proof (v13)

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None (all infrastructure sorry-free)
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/08_nf-eval-boost-design.md
- **Artifacts**: plans/13_charfn-prior-proof-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Complete the proof of `prior_exist_transfer_one_dir` (PriorComposition.lean line 524) using Rabinovich's Lemma 5.3 Duplicator strategy: char_fn + Prior-UZ/SZ witness placement. Then wire the 4 sorry sites (lines 595/599/650/654) to use this lemma, eliminating all sorry from PriorComposition.lean. Finally verify sorry elimination propagates through KampBypass to `completeness_discrete`.

Four previous plan versions (v9-v12) all failed because they attempted to bridge the depth-1 gap algebraically. Research report 08 definitively established that the gap is structural to the NF framework (depth-D agreement gives depth-(D-1) transfer, always). The correct approach uses char_fn to characterize 1-var types as temporal formulas, then Prior-UZ/SZ to find witnesses with full-depth matching -- avoiding the cross_extend depth loss entirely.

### Research Integration

Report 08 (nf-eval-boost-design) provides:
- H4-verified proof that no algebraic boost is possible (Finding 2)
- Confirmation that char_fn + Prior-UZ/SZ avoids depth loss (Finding 3, Challenge 2 VERIFIED)
- Verification that `prior_exist_transfer_one_dir` has the correct signature (Finding 4)
- Call site verification for all 4 sorry sites with exact parameter mappings (Section "Call Site Verification")
- Proof sketch: Nat.rec on d, with zone-based witness finding at each depth step
- Risk identification: zone-3 interval bounding is MEDIUM confidence (Challenge 3)

### Prior Plan Reference

Plans v9-v12 each attempted a different strategy for the same 5 sorry sites:
- **v9**: Zone-3 one-directional induction (blocked: char-NF approach loses 1 depth per arity increase)
- **v10**: VecEA bridge via Prop 3.5 pipeline (blocked: requires new files, circular depth dependency)
- **v11**: Depth-induction fill for prior_exist_transfer_one_dir (blocked: same algebraic gap)
- **v12**: Zone-decomposition direct wiring (blocked: delete prior_exist_transfer_one_dir was wrong)

Key lessons: (1) The depth gap K -> K+1 cannot be bridged algebraically. (2) prior_exist_transfer_one_dir has the CORRECT signature -- do not delete it. (3) Cross_extend_bwd_1var should NOT be the primary witness mechanism for zone-3. (4) Witnesses must be found via temporal formula characterization (char_fn), not quantifier extraction.

### Roadmap Alignment

ROADMAP.md identifies the critical path: Task 303/305 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free `completeness_discrete`. This plan directly advances the SOLE remaining blocker identified in the roadmap.

## Goals & Non-Goals

**Goals**:
- Complete the proof of `prior_exist_transfer_one_dir` at line 524 (~100-150 lines)
- Wire the 4 sorry sites (lines 595/599/650/654) using `prior_exist_transfer_one_dir`
- Achieve PriorComposition.lean sorry-free
- Verify `completeness_discrete` compiles without sorryAx

**Non-Goals**:
- Modifying any existing sorry-free infrastructure (cross_extend, nvar_transfer, etc.)
- Proving full biconditional r-var agreement (one-directional existential transfer suffices)
- Eliminating dead-code sorrys in NfCharFormula.lean
- Creating new files -- all work is in PriorComposition.lean

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone-3 interval bounding fails (witness between envN_i and envN_j not guaranteed) | H | M | Use BOTH endpoints' 1-var agreements: Prior-UZ from below gives r0 >= envN_i, Prior-SZ from above gives r1 <= envN_j. If direct bounding fails, fall back to ih_strong at d < K for the bounded case, or construct a 2-endpoint squeeze argument using the order atom encoding in the 2-var existential. |
| Nat.rec on d with universally-quantified r triggers Lean termination checker issues | M | L | The well-founded measure is d alone (decreasing). If Lean rejects, use explicit `termination_by d` or `decreasing_by omega`. Arity r increasing is invisible to the kernel since it is universally quantified. |
| IH application at d requires h_1var at exactly depth (d+1), which is tight | M | L | Report 08 Challenge 4 verified: z' gets depth-(d+1) from char_fn, env elements get depth-(d+2) from outer h_1var, both >= d+1. Use nf_agreement_monotone to weaken if needed. |
| The 4 sorry sites have slightly different contexts (Until vs Since, forward vs backward) | L | H | Template one wiring (line 595, Until forward), then adapt. Backward = swap M/N + h_1var.symm. Since = same as Until but prior_exist_transfer_one_dir does not depend on order direction. |
| Proof exceeds 200 lines at line 524 | M | M | Factor zone analysis into a shared helper lemma. The depth-0 base case is ~40 lines, each induction step ~50-80 lines. If total exceeds bounds, split into depth-0 helper + depth-succ helper. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Complete `prior_exist_transfer_one_dir` (Line 524 Sorry) [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: The zone-3 witness placement: finding z' in the interval (envN_i, envN_j) with matching depth-d 1-var NF type when z is between envM_i and envM_j.
- **What was tried**: (1) cross_extend_bwd_1var from envM_i gives z' > envN_i but not necessarily < envN_j; (2) cross_extend from envM_j gives z' < envN_j but not necessarily > envN_i; (3) char_fn + Prior-UZ gives first occurrence above envN_i but no bound below envN_j; (4) algebraic approach via exist_transfer_from_full_agree always falls one depth short.
- **Why stuck**: The depth-d 2-var type at [z, envM_i] encodes z's relationship to envM_i but NOT to envM_j. So the witness from cross_extend at envM_i has no guaranteed position relative to envN_j. The char_fn + Prior-UZ approach gives first occurrence above envN_i, but proving it's below envN_j requires establishing that the temporal formula (char_fn d nf_z) is satisfied in the open interval (envN_i, envN_j). This in turn requires showing that either z'_from_i < envN_j or z'_from_j > envN_i, neither of which follows from the available 2-var matchings.
- **What is needed**: A proof that on Prior structures, if a temporal formula phi is satisfied at z'_i > envN_i (from 2-var transfer at envM_i) and at z'_j < envN_j (from 2-var transfer at envM_j), then HasAttainedINF.first_occ can find a witness in the open interval (envN_i, envN_j). This requires showing z'_j > envN_i OR z'_i < envN_j. This may require a stronger transfer mechanism that uses BOTH endpoints simultaneously (a 3-var argument), or a novel use of the Prior-UZ/SZ axioms to bound the first occurrence.
- **Additional context**: The strong induction structure introduces a K/K_outer mismatch: inside Nat.strong_induction_on, the induction variable K is universally quantified but h_x/h_t/char_correct are fixed at K_outer. The wiring of prior_exist_transfer_one_dir at the call sites requires K ≤ K_outer, which is not formally available in the typing context. This prevents direct application of the lemma at the sorry sites even if the lemma were proved.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Fill the sorry at line 524 with the full proof by Nat.rec on d, using char_fn + Prior-UZ/SZ for witness placement at each depth level.

**Tasks**:
- [ ] Read the existing signature (lines 491-514) and verify the proof state at line 524 using `lean_goal`
- [ ] Implement Nat.rec on d (the first universally quantified Nat after the sorry):
  - **Base case (d=0)**: Sub is purely atomic (NormalForm sig 0 (r+1)). Zone analysis on z relative to envM using linear order decidability. For each zone:
    - Zone "equal to envM_i": use envN_i directly; predicates match from h_1var
    - Zone "beyond all env elements": use cross_extend_bwd_1var from nearest env element
    - Zone "between envM_i and envM_j": use char_fn at depth 0 to characterize z's predicate type. Transfer existence via h_1var quantifier condition at envM_i/envN_i (depth 1 includes depth-0 existential transfer). Prior-UZ localizes first occurrence in correct interval.
  - Verify atoms (predicates + orders) match at z'. No quantifier conditions at depth 0.
- [ ] Implement the inductive step (d -> d+1):
  - **Step 1 -- Find z' with full-depth-(d+1) 1-var matching**: Compute phi = char_fn (d+1) (nf_characteristic of z at depth d+1). char_correct gives temporal_truth M atomMap z phi. Zone analysis determines target interval in N. Transfer temporal existence via h_1var quantifier condition. Prior-UZ/SZ localizes z' in correct interval. char_correct converts back: nf_eval_nf N (d+1) 1 (fun _ => z') nf_z. Full depth matching, no loss.
  - **Step 2 -- Verify atoms at [z', envN]**: Predicates from 1-var matching. Orders from zone placement + h_order.
  - **Step 3 -- Transfer quantifier conditions**: For each chi : NormalForm sig d (r+2), need (exists u, nf_eval M d (r+2) (Fin.cons u (Fin.cons z envM)) chi) -> (exists u', nf_eval N d (r+2) (Fin.cons u' (Fin.cons z' envN)) chi). Apply **IH at d** with env = (Fin.cons z envM)/(Fin.cons z' envN) (arity r+1). The h_1var' at depth (d+1) is available: z/z' have depth-(d+1) from char_fn, envM_i/envN_i have depth-(d+2) >= (d+1) from outer h_1var. h_order' inherits from zone placement + outer h_order.
- [ ] Verify the entire proof compiles using `lean_goal` at key intermediate points
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` to confirm the sorry at line 524 is eliminated

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- replace sorry at line 524 with proof (~100-150 lines)

**Verification**:
- `lean_goal` at key proof positions shows well-formed intermediate states
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds
- Sorry count drops from 5 to 4 (the 4 downstream consumers remain)

---

### Phase 2: Wire Sorry Sites (Lines 595/599/650/654) [NOT STARTED]

**Goal**: Replace the cross_extend + sorry pattern at all 4 sorry sites with direct applications of `prior_exist_transfer_one_dir`, eliminating all sorry from PriorComposition.lean.

**Tasks**:
- [ ] **Line 595 (Until forward)**: Replace `exact <w2, sorry>` with application of `prior_exist_transfer_one_dir`. Parameters:
  - M, N, h_UZ_M, h_SZ_M, h_UZ_N, h_SZ_N: from outer context
  - K: from strong induction variable
  - char_fn, char_correct: from outer parameters
  - d = K+1, hd: K+1 <= K+1 by le_refl
  - r = 2, envM = ![x, t] (or Fin.cons x (fun _ => t) restricted), envN = ![x', t']
  - h_1var: from h_x and h_t at depth K+2 (weakened via nf_agreement_monotone if K < K_outer)
  - h_order: from h_order_M/h_order_N (t < x <-> t' < x', x < x is false <-> x' < x' is false, etc.)
  - sub = sub_nf, existential witness from <w, hw>
  - Remove the `cross_extend_bwd_1var` call (or keep only if needed for type conversion)
- [ ] **Line 599 (Until backward)**: Apply `prior_exist_transfer_one_dir` with M and N swapped:
  - Source structure = N, target structure = M
  - h_1var.symm for the biconditional flip
  - h_UZ_N, h_SZ_N become the source Prior axioms
  - h_UZ_M, h_SZ_M become the target Prior axioms
  - Remove the `cross_extend_fwd_1var` call
- [ ] **Line 650 (Since forward)**: Same as Until forward but the Since theorem has h_order_M : x < t and h_order_N : x' < t'. `prior_exist_transfer_one_dir` is order-agnostic (it works for any env order via h_order parameter). Apply with same parameter mapping as line 595 but using Since-specific order hypotheses.
- [ ] **Line 654 (Since backward)**: Apply with M/N swapped, symmetric to line 599.
- [ ] Verify PriorComposition.lean compiles sorry-free: `grep -n sorry PriorComposition.lean` returns no proof sorry lines
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` clean

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- replace 4 sorry sites (~60-100 lines total, removing cross_extend calls and inserting prior_exist_transfer_one_dir applications)

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns only comment lines (no proof sorry)
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds sorry-free
- `lean_verify` on `prior_nonconstenv_2var_agree_until` and `prior_nonconstenv_2var_agree_since` confirms no sorryAx

---

### Phase 3: Integration Verification (KampBypass to completeness_discrete) [NOT STARTED]

**Goal**: Verify that sorry elimination in PriorComposition.lean propagates through the call chain to `completeness_discrete`, and the full project builds clean.

**Tasks**:
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` -- verify sorry-free
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` -- verify sorry-free
- [ ] Run `lean_verify` on `completeness_discrete` (fully qualified: `Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior.completeness_discrete` or similar) to confirm no sorryAx
- [ ] Run full `lake build` -- verify clean project build with zero errors
- [ ] Final sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` to confirm only non-critical dead-code sorrys remain (NfCharFormula.lean)
- [ ] Document any remaining non-critical sorrys found during the audit

**Timing**: 1 hour

**Depends on**: 2

**Files to verify** (no modifications expected):
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean`
- `Theories/Bimodal/Metalogic/Completeness.lean` (or wherever completeness_discrete is defined)

**Verification**:
- `lake build` succeeds with no errors
- `lean_verify` on `completeness_discrete` reports no sorryAx
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` shows only NfCharFormula.lean dead-code sorrys

## Testing & Validation

- [ ] Phase 1: `prior_exist_transfer_one_dir` compiles sorry-free (base + inductive step)
- [ ] Phase 1: `lean_goal` at IH application points confirms well-formed goals
- [ ] Phase 2: All 4 sorry sites eliminated (grep confirmation)
- [ ] Phase 2: `prior_nonconstenv_2var_agree_until` and `_since` compile sorry-free
- [ ] Phase 2: `lean_verify` confirms no sorryAx on both theorems
- [ ] Phase 3: `completeness_discrete` compiles sorry-free (no sorryAx)
- [ ] Phase 3: Full `lake build` succeeds
- [ ] Phase 3: Final sorry audit confirms only dead-code sorrys remain

## Artifacts & Outputs

- `specs/305_rabinovich_ea_formula_implementation/plans/13_charfn-prior-proof-plan.md` -- this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- sorry-free (Phases 1-2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- sorry-free critical path (Phase 3, verification only)

## Postmortem Constraints (from v9-v12)

Previous plans failed for specific reasons that this plan MUST avoid:

1. **Do NOT use `cross_extend_bwd_1var` for zone-3 witness finding** -- it extracts from NF quantifier conditions and loses one depth level. Use char_fn + Prior-UZ/SZ instead.
2. **Do NOT use `nvar_transfer_from_1var_agree` at depth K+1 arity 3** -- it needs h_rvar at depth K+2 arity 3 (circular).
3. **Do NOT use `exist_transfer_from_full_agree` as PRIMARY mechanism for depth K+1** -- it gives depth K only. It IS usable as a sub-mechanism within the recursive descent at LOWER depths.
4. **Do NOT modify existing sorry-free infrastructure** -- all changes are in PriorComposition.lean.
5. **MUST use char_fn + Prior-UZ/SZ for witness placement** -- this is Rabinovich's Lemma 5.3 strategy: temporal formula characterization + first-occurrence analysis, not quantifier extraction.

## Rollback/Contingency

- **Phase 1** modifies only the sorry at line 524. Rollback = restore the sorry.
- **Phase 2** modifies the 4 sorry sites. Rollback = `git checkout -- PriorComposition.lean` restores all sorrys.
- **Phase 3** is verification only -- no rollback needed.
- Git per-phase commits enable rollback to any intermediate state.
- **If zone-3 interval bounding proves intractable**: Consider factoring the proof into an unbounded witness step (char_fn gives existence above envN_i) + bounded localization step (Prior-SZ gives last occurrence below envN_j). If both endpoints fail, investigate using the 2-var existential from ih_strong at d < K to provide an explicit interval-bounded witness.
