# Implementation Plan: Zone-Decomposition Direct Wiring at Sorry Sites

- **Task**: 305 - Rabinovich EA-formula implementation
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: Phases 1-5, 6a-6c [COMPLETED] from prior plans; sorry-free infrastructure
- **Research Inputs**: specs/305_rabinovich_ea_formula_implementation/reports/07_zone3-induction-design.md
- **Artifacts**: plans/12_zone-decomposition-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plans v10 (VecEA bridge) and v11 (depth-induction on `prior_exist_transfer_one_dir`) both BLOCKED on the same root cause: the standalone lemma `prior_exist_transfer_one_dir` as stated is architecturally unprovable. Its hypotheses (componentwise 1-var agreements + h_order) cannot produce multi-var agreement needed for the quantifier step.

The resolution (from targeted lean_goal analysis of all 5 sorry sites): **delete `prior_exist_transfer_one_dir` and wire the zone-3 transfer directly at each sorry site using zone-based case splitting**. The critical insight both previous plans missed: the witness w₂ is currently chosen via `cross_extend_bwd_1var` from h_t alone, which loses all ordering information relative to x'. The fix: case-split on w's zone and use zone-appropriate witness selection that preserves ordering relative to ALL env elements.

### Key Mechanism (Zone-Based Transfer)

At each sorry site, w is a witness in M with `nf_eval_nf M (K+1) 3 [w,x,t] sub_nf`. Case split on w's zone:

1. **Zone 1 (w < t < x)**: `cross_extend_bwd_1var` from h_t → w₂ < t'. Since t' < x' (from h_order), w₂ < t' < x'. All ordering atoms resolved.
2. **Zone 2 (w = t)**: Use t' directly as witness. Ordering inherited from h_order.
3. **Zone 3 (t < w < x)**: Key case. Use `char_fn` at depth K+1 for w's 1-var type to build temporal formula φ. By char_correct: temporal_truth M atomMap w φ. Temporal formula φ involves Until/Since with depth ≤ K+1. By h_t (depth-(K+2) 1-var agreement at t/t'): temporal_truth at t transfers. From temporal_truth N atomMap t' φ (which encodes "∃ point after t' with 1-var type matching w"), the Prior-UZ axiom on N (h_UZ_N) yields w₂ with t' < w₂ < x' and matching 1-var type.
4. **Zone 4 (w = x)**: Use x' directly.
5. **Zone 5 (x < w)**: `cross_extend_bwd_1var` from h_x → w₂ > x'. Since x' > t' (h_order), ordering resolved.

After witness selection with zone info:
- **Atoms** (depth K+1 arity 3): predicates from 1-var type matching (w₂ has same 1-var type as w at depth K+1), orders from zone placement.
- **Quantifier conditions** (depth K arity 4): Use induction on the NF depth d (from K+1 down to 0) WITHIN the sorry site context where ih_strong is available. At each depth step:
  - Find sub-witness with matching 1-var type using char_fn + Prior-UZ/SZ
  - Atoms transfer via zone analysis
  - Quantifier conditions recurse at depth d-1
  - Base case (d=0): purely atomic, no quantifier conditions

### Postmortem Constraints (Accumulated from v9-v11)

1. Do NOT attempt `nvar_transfer_from_1var_agree` — requires h_rvar (circular)
2. Do NOT seek full biconditional NF agreement at the new witness
3. Do NOT use `exist_transfer_from_full_agree` as PRIMARY mechanism for depth K+1
4. Do NOT modify existing sorry-free infrastructure
5. Do NOT create standalone bridge files
6. Do NOT attempt temporal formula conversion as a standalone transfer mechanism
7. NEW: Do NOT use `cross_extend_bwd_1var` from a SINGLE anchor for zone-3 witnesses — this loses ordering relative to the other env elements
8. NEW: Do NOT try to prove `prior_exist_transfer_one_dir` as stated — its signature is architecturally wrong

### Prior Plan Reference

Plan v10: BLOCKED (VecEA bridge). Plan v11: BLOCKED (depth-induction on prior_exist_transfer_one_dir). This plan abandons the standalone lemma approach entirely.

## Goals & Non-Goals

**Goals**:
- Delete or mark as dead code `prior_exist_transfer_one_dir` (lines 491-524)
- Replace the 4 sorry sites (lines 595/599/650/654) with zone-based inline proofs
- Fill the 5th sorry (line 524) is moot once the function is deleted — but the sorry at each call site must be independently resolved
- Achieve `lake build` clean on PriorComposition.lean
- Verify `completeness_discrete` compiles sorry-free

**Non-Goals**:
- Proving full biconditional r-var NF agreement
- Modifying the outer strong induction structure
- Changes to NfToVecEA/VecEADecomp/VecEATranslation
- Dead-code sorry elimination in NfCharFormula/EANegation

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone-3 temporal formula transfer via char_fn only works at temporal level, not NF level | H | M | The quantifier conditions require NF-level transfer. Use induction on d within the sorry site: at each depth, zone analysis handles atoms, and recursion at d-1 handles quantifier conditions. At d=0, purely atomic. |
| Prior-UZ/SZ may not guarantee witness in the EXACT interval (t', x') | M | M | Check semantic_prior_UZ type signature. If it gives "exists point with property" rather than "exists point IN interval", need additional argument for zone placement. |
| The quantifier condition recursion needs 1-var agreement for each new sub-witness | M | H | At each recursive step, the sub-witness is found via char_fn + Prior-UZ/SZ which gives matching 1-var type. This provides the 1-var agreement needed for the next level. |
| Lean termination checker for inline recursive proof | M | M | Use well-founded recursion on d or explicit Nat.rec. |
| The 4 sorry sites have slightly different contexts (Until vs Since, forward vs backward) | L | H | Template the zone analysis for one sorry site, then adapt. The structure is symmetric. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

---

### Phase 1: Zone-Based Transfer for Until Forward (Line 595) [BLOCKED]

**BLOCKER** (Phase 1):
- **What failed**: Cannot prove `nf_eval_nf N (K+1) 3 [w₂,x',t'] sub_nf` from available hypotheses at line 595. Every approach hits a depth-1 gap: to transfer depth-(K+1) 3-var existentials, one needs depth-(K+2) 2-var agreement (which IS the theorem being proved — circular), OR depth-(K+1) 3-var agreement (unavailable; ih_strong only provides depth-K 3-var via exist_transfer_from_full_agree).
- **What was tried**:
  1. **cross_extend_bwd_1var from h_t** (existing code): gives w₂ with depth-(K+1) 2-var agreement at [w,t]/[w₂,t'] but LOSES ordering info w₂ vs x' (the "zone problem"). This is the original approach that was already in sorry.
  2. **ih_strong quantifier transfer**: depth-K 3-var existential transfer from depth-(K+1) 2-var agreement at [x,t]/[x',t']. Gives w₂ with CORRECT zone placement (t' < w₂ < x') but only depth-K 3-var agreement. Atoms match ✓, but quantifier conditions at depth K require depth-K 4-var existential transfer, which needs depth-(K+1) 3-var agreement (not available). Off by 1 at every recursive level.
  3. **nvar_transfer_from_1var_agree**: Sorry-free lemma in codebase, but requires h_rvar (depth-(K+2) 3-var agreement) which is circular.
  4. **reconstruction_depth_agree**: Goes DOWN from high depth, not UP. Can't bootstrap depth-K to depth-(K+1).
  5. **exist_transfer_from_full_agree on hw₂**: Gives depth-K 3-var transfer at [?,w,t]/[?,w₂,t'], wrong env shape for 4-var conditions at [?,w,x,t]/[?,w₂,x',t'].
  6. **"NF eval boost" by depth induction**: Provably correct in principle (d decreases at each level, base case at d=0 is purely atomic). At each level: atoms from lower-depth agreement ✓, quantifier witnesses from exist_transfer ✓, recursive verification by IH ✓. BUT the d=0 base case requires finding a witness in a SPECIFIC ZONE of N via Prior-UZ/SZ, which requires interval existence transfer, which requires 2-var agreement at the zone boundary pair. This 2-var agreement is NOT available from just depth-0 r-var agreement. It IS available from ih_strong and hw₂ at the top level, but not at arbitrary inner levels. The proof requires threading these specific hypotheses through all recursive levels.
- **Why stuck**: The fundamental issue is a depth-1 gap that propagates at every level of recursion. The proof IS constructive (the "NF eval boost" + exist_transfer chain terminates at depth 0), but formalizing it requires a new helper lemma (`nf_eval_boost_prior`) that:
  (a) Takes Prior-UZ/SZ + char_fn as hypotheses
  (b) Does induction on d with universally quantified r
  (c) At d=0: performs zone-based witness placement using HasAttainedINF.first_occ + char_fn
  (d) At d+1: uses exist_transfer_from_full_agree for witnesses + IH for verification
  (e) Needs to thread 1-var agreements from h_t/h_x through all recursive levels (not just depth-d r-var agreement)
  This helper is ~100-150 lines and involves complex Fin manipulation for zone analysis.
- **What is needed**:
  1. A helper lemma `nf_eval_boost_prior` (or equivalent) that bootstraps depth-d r-var agreement to one-directional depth-(d+1) eval transfer on Prior structures. This is the "EF game duplicator strategy" translated to NF terms.
  2. OR: restructure the outer strong induction to prove r-var agreement for ALL arities r simultaneously (not just r=2), so ih_strong provides the needed h_rvar. This would require modifying the theorem statement (currently `prior_nonconstenv_2var_agree_until`), which the plan forbids.
  3. OR: add a "variable projection" lemma extracting m-var agreement from n-var agreement (for m ≤ n, by restricting to a subset of variables). This would allow extracting 2-var agreement at zone boundary pairs from higher-arity agreements.
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Goal**: Replace the sorry at line 595 (Until forward direction) with a zone-based proof that case-splits on w's position and handles each zone with appropriate witness selection and NF depth induction.

**Tasks**:
- [ ] Read the exact proof context at line 595 using lean_goal. Identify all available hypotheses (ih_strong, h_t, h_x, h_order_M, h_order_N, char_fn, char_correct, h_UZ_M, h_UZ_N, h_SZ_M, h_SZ_N, etc.)
- [ ] Remove the `cross_extend_bwd_1var` call at line 594 (or leave if useful for zones 1/5)
- [ ] Implement zone case split using `Decidable` or `lt_trichotomy` on w vs t and w vs x:
  - Zone 1 (w < t): `cross_extend_bwd_1var M t N t' h_t w` → w₂ < t' < x'. Use hw₂ for 2-var agreement at [w,t]/[w₂,t']. Construct nf_eval at [w₂,x',t'] from:
    - Atoms: order (w₂ < t' from cross_extend, t' < x' from h_order) + predicates (from 1-var type of w₂ matching w via hw₂)
    - Quantifier conditions: recursive proof by Nat.rec on sub_nf depth
  - Zone 2 (w = t): witness = t'. sub_nf holds via rewriting + h_t agreement
  - Zone 3 (t < w < x): Use char_fn at depth (K+1) for w's 1-var type nf_1. char_correct gives temporal_truth M atomMap w (char_fn (K+1) nf_1). Need to find w₂ with t' < w₂ < x' and matching 1-var type. Strategy depends on Prior-UZ/SZ mechanism — investigate whether h_UZ_N directly provides a witness with temporal_truth N atomMap w₂ (char_fn ...) in the interval.
  - Zone 4 (w = x): witness = x'. sub_nf holds via rewriting + h_x agreement  
  - Zone 5 (x < w): Symmetric to zone 1 using h_x
- [ ] For the quantifier conditions at each zone: define a local proof by Nat.rec on the NF depth d, using the zone-determined ordering + 1-var type matching at each level
- [ ] Verify sorry at line 595 is eliminated
- [ ] Run `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` (may still have 4 other sorries)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (~100-150 lines at the line 595 sorry site)

**Verification**:
- Sorry count drops from 5 to 4 (or 3 if line 524 becomes dead code)

---

### Phase 2: Wire Remaining Sorry Sites (599/650/654) + Cleanup [NOT STARTED]

**Goal**: Apply the same zone-based pattern from Phase 1 to the 3 remaining sorry sites. Delete `prior_exist_transfer_one_dir` if no longer needed.

**Tasks**:
- [ ] Line 599 (Until backward): Symmetric to 595 with M↔N swapped. Adapt zone analysis for reverse direction.
- [ ] Line 650 (Since forward): Same as 595 but with reversed zone ordering (x < t instead of t < x). Zones shift accordingly.
- [ ] Line 654 (Since backward): Symmetric to 650 with M↔N swapped.
- [ ] Factor common zone analysis into a local helper if the 4 proofs share enough structure
- [ ] Delete or comment out `prior_exist_transfer_one_dir` (lines 491-524) since it's no longer called
- [ ] Verify PriorComposition.lean compiles sorry-free

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` (~200-300 lines for 3 sorry sites + cleanup)

**Verification**:
- `grep -n sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` returns no results
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.PriorComposition` succeeds

---

### Phase 3: Integration Verification and Sorry Audit [NOT STARTED]

**Goal**: Verify sorry elimination propagates through KampBypass to completeness_discrete.

**Tasks**:
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` — sorry-free
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampMutualInduction` — sorry-free
- [ ] `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` — sorry-free
- [ ] `lean_verify` on `completeness_discrete` — no sorry axiom
- [ ] Full `lake build` — clean
- [ ] Sorry audit: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`

**Timing**: 0.5 hours

**Depends on**: 2

**Verification**:
- `lake build` succeeds
- `lean_verify completeness_discrete` reports no sorry axiom

## Testing & Validation

- [ ] Phase 1: Line 595 sorry eliminated; zone-based proof compiles
- [ ] Phase 2: All 4 sorry sites eliminated; PriorComposition.lean sorry-free
- [ ] Phase 3: completeness_discrete sorry-free; full lake build clean

## Artifacts & Outputs

- `plans/12_zone-decomposition-plan.md` — this plan
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` — sorry-free (Phases 1-2)

## Rollback/Contingency

- Phase 1 modifies sorry at line 595. Rollback = git revert.
- Phase 2 modifies 3 more sorries + deletes prior_exist_transfer_one_dir. Rollback = git revert.
- Phase 3 is verification only.
- **If zone-3 temporal transfer via char_fn + Prior-UZ does not work**: investigate whether `HasAttainedINF.first_occ` or `nf_characteristic_satisfies` provides a direct mechanism for placing witnesses in specific intervals. The Prior-UZ/SZ axioms ARE the mechanism Rabinovich uses for zone-3 in the original paper.
- **If quantifier condition recursion hits the same depth gap**: the recursion decreases d while preserving zone-determined ordering at each level. At d=0 the NF is purely atomic and the gap disappears. If intermediate steps fail, check whether `nf_agreement_monotone` can weaken available agreements to the needed depth.
