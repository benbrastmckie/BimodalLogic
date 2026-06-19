# Implementation Plan: Close PriorComposition Sorry via Strong D-Induction

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IN PROGRESS] (Phases 1-7 completed, Phase 8 in progress)
- **Effort**: 20 hours (6-8 dispatch sessions)
- **Dependencies**: None (k=0 infrastructure is sorry-free, KampBypass.lean is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md, reports/11_vea-negation-closure-design.md, reports/12_fraisse-game-analysis.md, reports/13_literature-grounded-proof-strategy.md, reports/15_charpart-threading-design.md, reports/16_strong-d-induction-research.md
- **Artifacts**: plans/16_strong-d-induction-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v16 replaces the blocked Phase 6 from plan v15 with four new phases (6-9) grounded in the strong D-induction architecture from report 16. The Phase 6 blocker is definitive: simple K-induction creates circularity because zone-3 between-zone transfer at depth D requires the theorem at depth D-1, which is not provided by simple `induction K`. Report 16 confirms that `Nat.strong_induction_on` (already used at KampMutualInduction.lean:397) eliminates this circularity by providing the theorem at ALL lower depths.

Additionally, report 16 identified an independent blocker in NfCharFormula.lean:651 (3 sorry with incorrect arguments to `existPart_succ_n1_bypass`) that can be fixed quickly by restructuring to use `nf_2var_exist_formula_prior_filled`.

Current state (after Phases 6-7): KampBypass.lean is sorry-free (0 sorry). PriorComposition.lean has 2 sorry at lines 264, 315 (zone-3 quantifier parts of `prior_nonconstenv_2var_agree_until/since` under strong induction — unified from 4 sorry). NfCharFormula.lean critical path is sorry-free (1 sorry remains in deprecated dead-code `nf_2var_exist_formula_prior`).

### Research Integration

- Report 16 (strong-d-induction-research.md): Confirmed strong D-induction necessary. Identified zone-3 resolution via Prior-UZ/SZ witness placement + recursive depth argument. Identified NfCharFormula.lean:651 independent fix. Estimated 600-900 lines for PriorComposition + 20-50 lines for NfCharFormula.
- Report 15 (charpart-threading-design.md): Established CharPart-threading architecture (Phases 5 completed).
- Reports 09, 11, 12, 13: Established GeneralExistPartOrdered and BetweenZoneExistPart are FALSE; zone decomposition + Prior-UZ/SZ is the correct approach.

## Goals & Non-Goals

**Goals**:
- Fix NfCharFormula.lean:651 sorry (3 sorry, independent fix)
- Restructure `prior_nonconstenv_2var_agree_until/since` from simple `induction K` to strong induction on D=K+2
- Implement zone-3 witness construction using Prior-UZ/SZ + char_fn + recursive depth argument
- Close all 4 sorry in PriorComposition.lean
- Verify completeness chain through completeness_discrete

**Non-Goals**:
- Modifying KampBypass.lean (already sorry-free)
- Modifying KampMutualInduction.lean (CharPart flows through existing param chain)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines, all sorry-free)
- Proving GeneralExistPartOrdered or BetweenZoneExistPart (both FALSE)
- Proving nonconstenv_exist_transfer_general (FALSE)
- Using simple K-induction (circular)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone-3 quantifier recursion: arity grows at each recursive level | H | M | Arity is bounded by the fixed sub_nf; recursion is on depth alone. At depth 0, quantifier part vanishes (purely atomic). Factor into helper lemma. |
| Heartbeat limits exceeded by strong induction + zone decomposition | M | H | Factor zone analysis into private helpers. Use `set_option maxHeartbeats 800000` as safety valve. Split large proofs across multiple lemmas. |
| Prior-UZ/SZ squeeze fails to place w' in (t', x') | M | L | Argument is sound: existence above t' (from h_t transfer) + existence below x' (from h_x transfer) implies first occurrence above t' is <= point below x', so w_first is in (t', x'). |
| `Nat.strong_induction_on` type mismatch with theorem signature | L | L | Lean 4 provides multiple strong induction variants. If `Nat.strong_induction_on` doesn't fit, use `WellFoundedRelation` or `termination_by` with explicit decreasing argument. |
| NfCharFormula fix has unexpected dependencies | L | L | The fix uses `nf_2var_exist_formula_prior_filled` which already exists at KampMutualInduction.lean:425. The restructuring is local. |
| Env reindexing (Fin 3 -> carrier) creates type errors | M | M | Use explicit `Fin.cons` constructions matching existing patterns in PriorComposition.lean. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5 | -- (all completed) |
| 2 | 6 | 5 (completed) |
| 3 | 7 | 6 |
| 4 | 8 | 7 |
| 5 | 9 | 8 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove GeneralExistPartOrdered and Simplify Mutual Induction [COMPLETED]

**Goal**: Delete the false GeneralExistPartOrdered definition, its sorry proofs, and revert kamp_mutual_induction to a 2-conjunct form (CharPart + ExistPart).

**Completed**: 2026-06-17

---

### Phase 2: Remove ih_general_exist from existPart_succ_n1_bypass [COMPLETED]

**Goal**: Remove the ih_general_exist parameter and restructure k>0 Until/Since zones to encode quantifier conditions without it.

**Completed**: 2026-06-17

---

### Phase 3: Research and Design V-EA Negation Closure [COMPLETED]

**Goal**: Research Rabinovich's V-EA negation closure (Lemma 5.1) and design the Lean formalization needed to close the between-zone sorry from Phase 2.

**Completed**: 2026-06-17

---

### Phase 4: Implement Enriched Bracket-Formula Encoding [COMPLETED]

**Goal**: Replace top/bot quant_conj encoding with Prior composition transfer. Make KampBypass.lean sorry-free.

**Completed**: 2026-06-17

---

### Phase 5: Delete FALSE Lemmas, Add CharPart Parameters, Update Call Sites [COMPLETED]

**Goal**: Restructure PriorComposition.lean by deleting 3 FALSE/unprovable lemmas, adding CharPart parameters, updating call sites.

**Completed**: 2026-06-17

---

### Phase 6: NfCharFormula Quick Fix [COMPLETED]

**Goal**: Fix the 3 sorry in NfCharFormula.lean:651 by restructuring argument passing to use `nf_2var_exist_formula_prior_filled` instead of passing `sorry` as `ih_char`, `ih_exist`, and `ih_all_char` arguments.

**Tasks**:
- [x] Read NfCharFormula.lean around line 651 to understand the current sorry structure
- [x] Identify the call to `existPart_succ_n1_bypass` with 3 sorry arguments
- [x] Restructure `nf_characterizable_temporal_prior_classical` (or the surrounding context) to:
  - Extract ExistPart from `kamp_mutual_induction` via `nf_2var_exist_formula_prior_filled` (KampMutualInduction.lean:425)
  - Pass the extracted ExistPart as the correct argument instead of sorry
  - OR restructure `nf_2var_exist_formula_prior` to take ih_char/ih_exist/ih_all_char as additional parameters
  *(deviation: altered — added `ih_exist_2var` param to `nf_characterizable_temporal_prior_classical` instead of modifying `nf_2var_exist_formula_prior`; also inlined `nf_2var_exist_depth0_tl` in `existPart_zero` to break sorry propagation)*
- [x] Verify: `lake build NfCharFormula` succeeds *(deviation: 1 sorry remains in dead-code `nf_2var_exist_formula_prior` k+2 branch, but `nf_characterizable_temporal_prior_classical` is sorry-free)*
- [x] Verify: `lake build KampBypass` still succeeds with 0 sorry

**Sorry budget**: Reduced 3 sorry from critical path. `nf_characterizable_temporal_prior_classical`, `charPart_succ`, `existPart_zero` are now sorry-free. `nf_2var_exist_formula_prior` retains 1 sorry in dead-code k+2 branch (not reachable from completeness chain).

**Timing**: 1 hour (1 dispatch session)

**Completed**: 2026-06-18

**Depends on**: 5 (completed)

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- added `ih_exist_2var` param, removed call to sorry'd function
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- updated `charPart_succ` call, inlined `nf_2var_exist_depth0_tl` in `existPart_zero`
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean` -- added import, provided `ih_exist_2var` from `nf_2var_exist_formula_prior_filled`

**Verification (completed)**:
- `lake build` succeeds (full project, 1759 jobs)
- `lean_verify charPart_succ`: no sorryAx
- `lean_verify existPart_zero`: no sorryAx
- `lean_verify nf_characterizable_temporal_prior_classical`: no sorryAx
- `lake build KampBypass` succeeds with 0 sorry

---

### Phase 7: Strong D-Induction Scaffolding [COMPLETED]

**Goal**: Replace simple `induction K` with `Nat.strong_induction_on D` (where D=K+2) in PriorComposition.lean. Restructure the main theorems to be parametric in D. The IH provides the theorem at all depths < D.

**Tasks**:
- [x] Factor out `strong_prior_nonconstenv_2var_agree_until_aux` with explicit D parameter: *(deviation: skipped — separate aux theorem unnecessary; `Nat.strong_induction_on K` applied directly inside the existing theorem body is cleaner and type-checks without wrapper)*
- [x] Implement the outer wrapper using `Nat.strong_induction_on`:
  ```lean
  theorem prior_nonconstenv_2var_agree_until ... := by
    exact Nat.strong_induction_on K (fun K ih_strong nf => by ...)
  ```
  *(deviation: altered — used strong induction on K directly rather than on D=K+2; this is equivalent since `ih_strong : ∀ m < K, theorem_at_(m+2)` covers all depths 2..K+1)*
- [x] Inside the aux theorem, split into atom part (reuse existing `nonconstenv_atom_agree_until` -- sorry-free) and quantifier part (sorry placeholder for Phase 8)
- [x] Apply IH at D-1 to get depth-(D-1) 2-var at [x,t]/[x',t'] (from `nf_agreement_monotone` weakening h_x, h_t from depth D to D-1) *(deviation: deferred to task Phase 8 — IH is now available in context via ih_strong; actual application happens when closing sorry)*
- [x] Mirror all restructuring for `prior_nonconstenv_2var_agree_since`
- [x] Verify: `lake build PriorComposition` succeeds (2 sorry remain -- consolidated from 4 because strong induction unifies K=0/K=succ cases)
- [x] Verify: `lake build KampBypass` still succeeds with 0 sorry

**Sorry budget**: 2 (reduced from 4; strong induction unifies K=0 and K=succ K' into single case per theorem, consolidating 2 sorry per theorem into 1).

**Timing**: 30 minutes (1 dispatch session)

**Completed**: 2026-06-19

**Depends on**: 6

**Files modified**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- restructured induction from simple `induction K` to `Nat.strong_induction_on K`

**Key patterns used**:
- `Nat.strong_induction_on` usage: matches KampMutualInduction.lean:410 pattern
- Lambda absorbs the nf quantifier: `fun K ih_strong nf => by` avoids variable shadowing
- `nf_agreement_monotone` not needed in scaffolding phase (will be used in Phase 8 to invoke IH)
- char_correct bound: `d <= K+1 = D-1` covers all needed depths

**Verification (completed)**:
- `lake build PriorComposition` succeeds (988 jobs, warnings only)
- `lake build KampBypass` succeeds (1247 jobs) with 0 sorry
- `grep -c sorry PriorComposition.lean` returns exactly 2 (one per main theorem, inside strong induction)
- Both sorry positions have `ih_strong : ∀ m < K, ...` available in context

---

### Phase 8: Zone-3 Witness Construction [BLOCKED]

**Goal**: Implement the zone-3 between-zone argument for the Until direction. Use Prior-UZ/SZ to place witness w' in (t', x') with the correct depth-(D-1) 1-var NF, then prove w' satisfies the sub-NF by reconstructing atom part + quantifier part. The quantifier part recurses at depth D-2 (terminates at depth 0 = purely atomic).

**BLOCKER** (Phase 8):
- **What failed**: Cannot close sorry for zone-3 existential transfer. Goal: `∃ w, nf_eval M (K+1) 3 [w,x,t] sub_nf ↔ ∃ w', nf_eval N (K+1) 3 [w',x',t'] sub_nf`
- **What was tried**: (1) cross_extend_bwd_1var from h_t gives w₂ > t' but unknown w₂ < x'. From h_x gives w₁ < x' but unknown t' < w₁. (2) Attempted external helper theorems — blocked by Nat.strong_induction_on K✝/K variable mismatch. (3) Explored nf_extend_bwd, constenv_2var_determines, nf_skipIdx_cross — all give one depth SHORT of what's needed.
- **Why stuck**: Three independent obstacles: (a) Prior-UZ/SZ witness placement needs char_fn transfer + squeeze argument not yet formalized; (b) Quantifier part at depth K+1 requires depth-K (n+1)-var transfer, creating recursive same-type problem at lower depth / higher arity — needs secondary induction; (c) Nat.strong_induction_on binding prevents calling external helpers (K✝ vs K).
- **What is needed**: (1) Restructure to avoid K✝/K issue (define `have` helper INSIDE the strong induction body, or use `suffices` pattern with explicit K coercion). (2) Implement depth-0 n-var atomic transfer base case (find point with matching predicates + orders using Prior density). (3) Implement Prior-UZ witness placement: char_fn transfer via temporal_truth + h_t, then apply semantic_prior_UZ to get first occurrence in correct zone. (4) Implement nested depth induction for quantifier part (Nat.rec from K+1 down to 0, proving n-var transfer at each level using Prior witness at previous level).
- **Prohibited**: Do NOT use sorry, def X := True, or vacuous placeholder

**Tasks**:
- [ ] Implement zone decomposition helper that classifies witness w into zones:
  - Zone 1 (w < t): use `cross_extend_bwd_1var` from h_t
  - Zone 2 (w = t): trivial (use t' directly)
  - Zone 3 (t < w < x): the hard case (implemented below)
  - Zone 4 (w = x): trivial (use x' directly)
  - Zone 5 (w > x): use `cross_extend_bwd_1var` from h_x
- [ ] For zone 3 (t < w < x), implement witness placement:
  1. Get w's depth-(D-1) 1-var NF: `nf_w`
  2. Characterize via `char_fn (D-1) nf_w` (char_correct covers d <= D-1)
  3. From h_t (depth-D 1-var at t/t'): transfer "existence above t of type nf_w" to get w1' > t' with depth-(D-1) 2-var at [w,t]/[w1',t']
  4. From h_x (depth-D 1-var at x/x'): transfer "existence below x of type nf_w" to get w2' < x' with depth-(D-1) 2-var at [w,x]/[w2',x']
  5. Apply `semantic_prior_UZ` at t' with char formula: first occurrence w_first > t' satisfying char is <= w2' < x', so w_first is in (t', x')
  6. w_first has depth-(D-1) 1-var agreement with w (via `nf_agreement_from_shared_nf`)
- [ ] Prove w_first satisfies sub_nf at [w_first, x', t']:
  - Atom part: from 1-var agreements at w_first/w, x'/x, t'/t + known order relations
  - Quantifier part: depth-(D-2) 4-var existential transfer at [y,w,x,t]/[y',w_first,x',t']
    - Apply strong IH at D-1 to (w, w_first) pair with weakened 1-var agreements
    - From depth-(D-1) 2-var at [x,t]/[x',t'] (already obtained in Phase 7 scaffolding)
    - Use `nf_extend_bwd` from depth-(D-1) 2-var to get depth-(D-2) witnesses
    - Recursive argument terminates at depth 0 (purely atomic, no quantifier conditions)
- [ ] Implement helper lemma: `zone3_exist_transfer_until` that encapsulates the zone-3 argument
- [ ] Close the 1 Until sorry (line 264, unified K case under strong induction) using zone decomposition
- [ ] Verify: `lake build PriorComposition` succeeds with 1 sorry remaining (Since case only)

**Sorry budget**: 1 (Until direction closed, Since direction remaining — 1 sorry per theorem after Phase 7 unification).

**Timing**: 6-8 hours (2-3 dispatch sessions)

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- zone-3 implementation

**Key infrastructure**:
| Name | Location | Purpose |
|------|----------|---------|
| `Nat.strong_induction_on` | Lean core / Mathlib | Strong induction on Nat |
| `nf_agreement_monotone` | NormalForm.lean:339 | Depth weakening |
| `nf_agreement_from_shared_nf` | NormalForm.lean:291 | Unique NF implies agreement |
| `nf_characteristic_satisfies` | NormalForm.lean:224 | M satisfies its own characteristic |
| `cross_extend_bwd_1var` | KampComposition.lean:97 | 1-var to 2-var lift |
| `nf_extend_bwd` | KampBypass.lean:57 | General arity extension |
| `exist_transfer_nvar_constenv` | KampComposition.lean:122 | Constant-env existential transfer |
| `semantic_prior_UZ` | PriorDefs.lean:22 | First occurrence above |
| `semantic_prior_SZ` | PriorDefs.lean:33 | Last occurrence below |

**Verification**:
- `lake build PriorComposition` succeeds
- `grep -c sorry PriorComposition.lean` returns exactly 2 (Since cases)
- `lake build KampBypass` succeeds with 0 sorry

---

### Phase 9: Until/Since Mirror Completion and End-to-End Verification [NOT STARTED]

**Goal**: Complete the Since direction (mirror of Until from Phase 8) and verify the full completeness chain. The Since cases are structurally identical to Until modulo direction reversal (using `semantic_prior_SZ` instead of `semantic_prior_UZ`, reversing order relations).

**Tasks**:
- [ ] Implement `zone3_exist_transfer_since` by mirroring `zone3_exist_transfer_until`:
  - Reverse order: x < t (since direction), x' < t'
  - Use `semantic_prior_SZ` (last occurrence below) instead of `semantic_prior_UZ`
  - Apply `cross_extend_bwd_1var` from h_x for zones below x, from h_t for zones above t
  - Zone 3 for since: x < w < t (between x and t, reversed direction)
- [ ] Close the 1 Since sorry (line 315, unified K case under strong induction)
- [ ] Verify: `lake build PriorComposition` succeeds with 0 sorry
- [ ] Run `lean_verify prior_nonconstenv_2var_agree_until` -- confirm no sorryAx
- [ ] Run `lean_verify prior_nonconstenv_2var_agree_since` -- confirm no sorryAx
- [ ] Run `lean_verify kamp_mutual_induction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Remove any dead imports or unused helper lemmas
- [ ] Update module docstring in PriorComposition.lean to reflect final proof strategy
- [ ] Verify sorry count across entire Kamp directory: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`

**Sorry budget**: 0. Target: reduce from 2 to 0.

**Timing**: 4-6 hours (1-2 dispatch sessions)

**Depends on**: 8

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- Since mirror + cleanup

**Verification**:
- `lake build` succeeds
- `lean_verify completeness_discrete` clean (no sorryAx, only standard axioms)
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` returns 0 results (excluding comments)

## Testing & Validation

- [x] After Phase 1: `lake build GeneralExistPart` succeeds; no sorry in remaining code
- [x] After Phase 2: `lake build KampBypass` succeeds; sorry count = 2 (at between-zone sites only)
- [x] After Phase 3: Research report written with actionable design
- [x] After Phase 4 (4a-4c): KampBypass.lean sorry-free; PriorComposition.lean reduced to 4 sorry
- [x] After Phase 5: `lake build PriorComposition` + `lake build KampBypass` succeed; sorry count in PriorComposition = 4; KampBypass sorry = 0
- [x] After Phase 6: `lake build NfCharFormula` succeeds; sorry at line 651 eliminated from critical path (dead-code sorry remains)
- [x] After Phase 7: `lake build PriorComposition` succeeds; sorry count = 2 (reduced from 4 by strong induction unifying K=0/K=succ cases)
- [ ] After Phase 8: `lake build PriorComposition` succeeds; sorry count = 2 (Until closed, Since remaining)
- [ ] After Phase 9: `lean_verify completeness_discrete` clean; `lake build` succeeds; no sorry in Kamp directory

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfCharFormula.lean` -- sorry at line 651 fixed [Phase 6]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- strong D-induction + zone-based Prior-UZ/SZ transfer [Phases 7, 8, 9]
- `specs/303_k_gt_0_depth_induction/plans/16_strong-d-induction-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/16_strong-d-induction-research.md` -- key research input

## Rollback/Contingency

1. **Phase 6 NfCharFormula fix breaks callers**: The fix is local to one call site. If restructuring `nf_characterizable_temporal_prior_classical` proves complex, alternatively pass the IH arguments explicitly from the outer caller scope.

2. **Phase 7 strong induction doesn't compile**: Multiple strong induction variants exist in Lean 4. Fallbacks: `WellFoundedRelation` with `termination_by D`, or `have : D - 1 < D := Nat.sub_lt ...` with recursive call.

3. **Phase 8 zone-3 argument fails at depth gap**: If the depth-(D-2) from nf_extend_bwd is insufficient, prove an intermediate lemma that directly establishes the existential transfer zone by zone without needing full 3-var agreement. The recursion on depth (terminating at 0 = atoms) is mathematically sound.

4. **Phase 8/9 heartbeat exceeded**: Factor the zone-3 proof into 3+ private helpers (one per zone class). Use `set_option maxHeartbeats 800000` per helper.

5. **Any phase**: `git revert` to restore pre-attempt state. Do NOT re-attempt: GeneralExistPartOrdered, BetweenZoneExistPart, `depth0_3var_exist_transfer_until/since`, `exist_transfer_3var_nonconstenv`, `nonconstenv_exist_transfer_general`, `zone_compatible_witness_bwd/fwd` (all confirmed FALSE or unprovable across 10+ dispatch sessions).
