# Implementation Plan: Close PriorComposition Sorry via CharPart-Threading Architecture

- **Task**: 303 - k_gt_0_depth_induction
- **Status**: [IN PROGRESS] (Phases 1-5 completed, Phase 6 blocked — restructuring needed)
- **Effort**: 16 hours (5-7 dispatch sessions)
- **Dependencies**: None (k=0 infrastructure is sorry-free, KampBypass.lean is sorry-free)
- **Research Inputs**: reports/09_interval-splitting-mapping.md, reports/11_vea-negation-closure-design.md, reports/12_fraisse-game-analysis.md, reports/13_literature-grounded-proof-strategy.md, reports/15_charpart-threading-design.md
- **Artifacts**: plans/15_charpart-threading-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/formats/plan-format.md
  - .claude/rules/plan-format-enforcement.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v15 replaces the blocked Phases 5-7 from plan v14. The Phase 5 blocker is definitive: `depth0_3var_exist_transfer_until` and `depth0_3var_exist_transfer_since` are FALSE (counterexample: Z with P=evens, t=t'=-1, x=4, x'=0). The standalone `exist_transfer_3var_nonconstenv` is also unprovable without Prior+CharPart hypotheses. Report 15 designed a complete CharPart-threading architecture that eliminates all three FALSE/unprovable lemmas and restructures the proof to use temporal formula semantics for the between-zone transfer.

The fix threads `char_kp1_fn`/`char_kp1_correct` parameters (formula-level CharPart(K+1)) through `prior_nonconstenv_2var_agree_until/since` and `prior_2var_transfer_until/since`. These parameters are already available in `existPart_succ_n1_bypass` (KampBypass.lean:425-432) and need only be forwarded to the PriorComposition call sites. No changes are needed to `kamp_mutual_induction` or `KampMutualInduction.lean` -- the CharPart flows through the existing parameter chain.

Current state (after Phase 5 + cleanup): KampBypass.lean is sorry-free (0 sorry). PriorComposition.lean has 4 sorry at lines 264, 285, 336, 354 (quantifier parts of `prior_nonconstenv_2var_agree_until/since` in K=0 and K>0 cases). All FALSE/unprovable intermediate lemmas have been deleted (~247 lines removed). The 4 sorry trace to a single root cause: the between-zone (zone 3) existential transfer requires the full theorem at lower depth, creating circularity under simple K-induction. The fix is to restructure to strong induction on total depth D=K+2.

### Research Integration

Report 15 (charpart-threading-design.md) established:
1. `depth0_3var_exist_transfer_until/since` are FALSE -- delete them
2. `exist_transfer_3var_nonconstenv` is unprovable without Prior+CharPart -- delete it
3. Add `char_kp1_fn`/`char_kp1_correct` params to `prior_nonconstenv_2var_agree_until/since` and `prior_2var_transfer_until/since`
4. Call sites in KampBypass.lean (lines 611, 678) already have char_kp1/char_kp1_correct in scope -- just forward them
5. K=0 base: zone decomposition with Prior-UZ/SZ squeeze argument for between-zone; outer zones use `cross_extend_bwd_1var`
6. K>0 step: IH gives depth-(K'+2) 2-var h_xt; zone decomposition at higher depth using CharPart for between-zone depth boost
7. No changes needed to KampMutualInduction.lean, KampBypassCore.lean, KampBypassUntil.lean, or KampBypassSince.lean

Reports 09, 11, 12, 13 (prior research) established:
- GeneralExistPartOrdered and BetweenZoneExistPart are both FALSE -- do not re-attempt
- The between-zone has recursive structure terminating at depth 0 where everything is purely atomic
- Rabinovich Lemma 5.1 argument (Prior-UZ/SZ + CharPart) is the correct approach

### Prior Plan Reference

Plan v14 Phases 1-4 are all COMPLETED. Phase 5 is BLOCKED (FALSE lemmas). Phases 6-7 are NOT STARTED but designed around assumptions invalidated by the Phase 5 blocker. This revision replaces Phases 5-7 entirely with three new phases grounded in the CharPart-threading architecture from report 15.

### Roadmap Alignment

Advances: "Task 303 (k>0 depth induction via Rabinovich Section 5 Lemma 5.1) -> sorry-free completeness_discrete" -- the SOLE remaining blocker on the critical path.

## Goals & Non-Goals

**Goals**:
- Delete FALSE lemmas `depth0_3var_exist_transfer_until/since` and unprovable `exist_transfer_3var_nonconstenv`
- Add `char_kp1_fn`/`char_kp1_correct` parameters to `prior_nonconstenv_2var_agree_until/since` and `prior_2var_transfer_until/since`
- Update KampBypass.lean call sites to forward the CharPart parameters
- Implement zone-based between-zone transfer using Prior-UZ/SZ + CharPart at K=0 and K>0
- Close all 4 sorry in PriorComposition.lean
- Verify the completeness chain through completeness_discrete

**Non-Goals**:
- Modifying KampBypass.lean beyond the two call sites (lines 611, 678) that pass prior_2var_transfer params
- Modifying KampMutualInduction.lean (CharPart already flows through existing param chain)
- Modifying k=0 infrastructure (KampBypassCore/Until/Since, ~4400 lines, all sorry-free)
- Proving GeneralExistPartOrdered or BetweenZoneExistPart (both FALSE, documented in reports 09/12)
- Implementing arity-climbing recursion (unnecessary if CharPart is threaded correctly per report 13)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zone 3 (between-zone) requires full theorem at lower depth — not just endpoint conditions | H | CONFIRMED | Simple K-induction creates circularity. Restructure to strong D-induction (D=K+2) so IH provides theorem at ALL lower depths. This is the current blocker. |
| Strong D-induction restructuring changes theorem signature or breaks callers | M | L | The external signature of `prior_nonconstenv_2var_agree_until/since` is unchanged — only the internal induction scheme changes. KampBypass call sites are unaffected. |
| Zone 3 at depth D still requires complex case analysis after restructuring | M | M | With strong IH, the zone-3 argument becomes: (1) cross_extend for candidate witness, (2) IH at D-1 for depth-(D-2) transfer at candidate, (3) Prior-UZ/SZ for between-zone placement. Factor into private helpers. |
| Heartbeat limits exceeded by strong induction + zone decomposition | M | H | Factor zone analysis into private helpers. Use `set_option maxHeartbeats 800000` as safety valve. |
| `Nat.strong_rec_on` or equivalent not available for the induction scheme needed | L | L | Lean 4 provides `Nat.strongRecOn`, `WellFoundedRelation`, and manual well-founded recursion. Alternatively, prove a standalone `strong_prior_nonconstenv_2var_agree` by Nat.strongRecOn and have the original theorems call it. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4 | -- (all completed) |
| 2 | 5 | 4 (completed) |
| 3 | 6 | 5 |
| 4 | 7 | 6 |

Phases within the same wave can execute in parallel.

### Phase 1: Remove GeneralExistPartOrdered and Simplify Mutual Induction [COMPLETED]

**Goal**: Delete the false GeneralExistPartOrdered definition, its sorry proofs, and revert kamp_mutual_induction to a 2-conjunct form (CharPart + ExistPart).

**Tasks**:
- [x] Delete `GeneralExistPartOrdered` abbrev and its sorry theorems from GeneralExistPart.lean
- [x] Simplify KampMutualInduction.lean to 2-conjunct (CharPart + ExistPart)
- [x] Remove ih_general_exist from existPart_succ parameter
- [x] Fix nf_2var_exist_formula_prior_filled extractor from `.2.1` to `.2` for 2-conjunct form
- [x] Verify: `lake build GeneralExistPart` succeeds with no sorry

**Timing**: 1.5 hours

**Depends on**: none

**Completed**: 2026-06-17

---

### Phase 2: Remove ih_general_exist from existPart_succ_n1_bypass [COMPLETED]

**Goal**: Remove the ih_general_exist parameter and restructure k>0 Until/Since zones to encode quantifier conditions without it.

**Tasks**:
- [x] Remove ih_general_exist parameter from existPart_succ_n1_bypass signature
- [x] Restructure Until zone (true/false) using direct sub_nf.2 ssn truth values
- [x] Restructure Since zone (false/true) with mirror approach
- [x] Update existPart_succ call site in KampMutualInduction.lean
- [x] Verify: `lake build KampBypass` succeeds -- 2 sorry remain (backward directions only)

**Timing**: 2.5 hours

**Depends on**: 1

**Completed**: 2026-06-17

---

### Phase 3: Research and Design V-EA Negation Closure [COMPLETED]

**Goal**: Research Rabinovich's V-EA negation closure (Lemma 5.1) and design the Lean formalization needed to close the between-zone sorry from Phase 2.

**Tasks**:
- [x] Study Rabinovich Lemma 5.1 and map to existing codebase
- [x] Design Lean type signatures for negation-closure lemma
- [x] Estimate effort for between-zone implementation
- [x] Write research report (11_vea-negation-closure-design.md)

**Result**: Between-zone case requires 500-800 lines. Phase 4 re-scoped as multi-session implementation.

**Timing**: 2 hours

**Depends on**: 2

**Completed**: 2026-06-17

---

### Phase 4: Implement Enriched Bracket-Formula Encoding [COMPLETED]

**Goal**: Replace top/bot quant_conj encoding with Prior composition transfer. Make KampBypass.lean sorry-free. Prove supporting lemmas in PriorComposition.lean.

**Sub-phases completed**:
- Phase 4a [COMPLETED]: Enriched backward direction with partial proof structure in KampBypass.lean
- Phase 4b [COMPLETED]: Prior composition transfer -- KampBypass.lean now 0 sorry. Sorry moved to PriorComposition.lean (6 sorry -> reduced in 4c)
- Phase 4c [COMPLETED]: Proved `prior_second_1var_from_2var` via `nf_skipIdx_cross` projection. PriorComposition.lean reduced from 6 to 4 sorry
- Phase 4d [BLOCKED -> SUPERSEDED]: The FALSE lemmas block. Report 15 designed the CharPart-threading fix.

**Timing**: 6 hours (4a-4c completed)

**Depends on**: 3

**Completed**: 2026-06-17 (sub-phases 4a-4c)

---

### Phase 5: Delete FALSE Lemmas, Add CharPart Parameters, Update Call Sites [COMPLETED]

**Goal**: Restructure PriorComposition.lean by deleting the 3 FALSE/unprovable lemmas, adding `char_kp1_fn`/`char_kp1_correct` parameters to the 4 theorems that need them, and updating the 2 call sites in KampBypass.lean. The sorry count should remain at 4 (moved to new locations in the restructured base case and inductive step).

**Tasks**:
- [x] Delete `depth0_3var_exist_transfer_until` (PriorComposition.lean, lines 200-274)
- [x] Delete `depth0_3var_exist_transfer_since` (PriorComposition.lean, lines 277-345)
- [x] Delete `exist_transfer_3var_nonconstenv` (PriorComposition.lean, lines 370-480)
- [x] Add parameters to `prior_nonconstenv_2var_agree_until` (after h_order_N):
  ```lean
  (char_kp1_fn : NormalForm sig (K + 1) 1 → Formula)
  (char_kp1_correct : ∀ (nf_1 : NormalForm sig (K + 1) 1)
      (M : OrderedMonadicStructure sig)
      (h_UZ : semantic_prior_UZ M atomMap)
      (h_SZ : semantic_prior_SZ M atomMap)
      (t : M.carrier),
      temporal_truth M atomMap t (char_kp1_fn nf_1) ↔
      nf_eval_nf M (K + 1) 1 (fun _ => t) nf_1)
  ```
- [x] Add same parameters to `prior_nonconstenv_2var_agree_since`
- [x] Add same parameters to `prior_2var_transfer_until` (after h_order₀)
- [x] Add same parameters to `prior_2var_transfer_since` (after h_order₀)
- [x] Restructure K=0 base case of `prior_nonconstenv_2var_agree_until`:
  - Keep atom part (nonconstenv_atom_agree_until) -- sorry-free
  - Replace quantifier part call to `exist_transfer_3var_nonconstenv` with `sorry` (placeholder for Phase 6)
- [x] Restructure K=succ K' step of `prior_nonconstenv_2var_agree_until`:
  - Keep atom part -- sorry-free
  - Replace quantifier part call to `exist_transfer_3var_nonconstenv` with `sorry` (placeholder for Phase 6)
- [x] Mirror both restructurings for `prior_nonconstenv_2var_agree_since`
- [x] Update `prior_2var_transfer_until` body to forward `char_kp1_fn`/`char_kp1_correct` to `prior_nonconstenv_2var_agree_until`
- [x] Update `prior_2var_transfer_since` body to forward parameters similarly
- [x] Update KampBypass.lean: construct `char_k`/`char_k_correct` from `ih_char` via `Exists.choose` *(deviation: altered -- char_kp1 is at depth k+1=k'+2 but prior_2var_transfer needs depth k'+1, so constructed from ih_char instead)*
- [x] Update KampBypass.lean: pass `char_k char_k_correct` to `prior_2var_transfer_until`
- [x] Update KampBypass.lean: pass `char_k char_k_correct` to `prior_2var_transfer_since`
- [x] Verify: `lake build PriorComposition` succeeds
- [x] Verify: `lake build KampBypass` succeeds (still 0 sorry)
- [x] Verify: sorry count in PriorComposition.lean is exactly 4 (2 in K=0 base, 2 in K>0 step of the until/since pair)

**Sorry budget**: 4 sorry (same count, moved to new structural positions).

**Timing**: 2 hours (1 dispatch session)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- delete 3 lemmas, add params to 4 theorems, restructure proof bodies
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- update 2 call sites (lines ~611, ~678) to forward char_kp1 params

**Files NOT modified**:
- `KampMutualInduction.lean` -- no changes needed (CharPart flows through existing param chain)
- `KampBypassCore.lean`, `KampBypassUntil.lean`, `KampBypassSince.lean` -- no changes needed

**Verification**:
- `lake build PriorComposition` succeeds
- `lake build KampBypass` succeeds with 0 sorry
- `grep -c sorry PriorComposition.lean` returns exactly 4

---

### Phase 6: Implement Zone-Based Between-Zone Transfer (Closes All 4 Sorry) [BLOCKED]

**Goal**: Replace the 4 sorry from Phase 5 with complete proofs using zone-based between-zone transfer with Prior-UZ/SZ squeeze and CharPart temporal formula encoding.

**Status**: BLOCKED — simple K-induction creates circularity. Requires restructuring to strong induction on total depth D=K+2.

**Cleanup completed** (dispatches 2026-06-18):
- [x] Delete `nonconstenv_exist_transfer_general` (FALSE at D=0 when n > 0; counterexample: Z, P=evens, envM=[10,0], envN=[2,0])
- [x] Delete `nonconstenv_exist_transfer_until/since` (called FALSE theorem)
- [x] Delete `zone_compatible_witness_bwd/fwd` (FALSE — zone-3 witness not guaranteed)
- [x] Delete `pred_agree_from_1var`, `pred_agree_from_1var_mono` (only used by deleted code)
- [x] Restructure quantifier parts of `prior_nonconstenv_2var_agree_until/since` with sorry + zone decomposition comments
- [x] Verify `lake build PriorComposition` succeeds (4 sorry at lines 264, 285, 336, 354)
- [x] Verify `lake build KampBypass` succeeds (0 sorry)

**Approaches attempted and ruled out** (5 dispatch sessions):
1. **Direct zone decomposition at K=0**: Zones 1,2,4,5 work via `cross_extend_bwd_1var`. Zone 3 (between-zone) fails — `cross_extend` from h_x and h_t give witnesses on separate sides but cannot guarantee a single witness in (t', x').
2. **Prior-UZ/SZ squeeze alone**: Gives first/last occurrences of predicate pattern above t'/below x', but these are 1-var conditions. The 3-var NF requires simultaneous conjunction of "above t'" AND "below x'" at a single point — not guaranteed by two independent Prior applications.
3. **Decomposition into depth-1 2-var first**: Circular — depth-1 2-var at [x,t] needs depth-0 3-var transfer, which is the very thing being proved.
4. **`nonconstenv_exist_transfer_general`**: FALSE (counterexample found). Between-zone transfer at depth 0 requires 2-var agreement at anchor pair, not just independent 1-var.
5. **`zone_compatible_witness_bwd/fwd`**: FALSE — zone-3 witness existence not provable from endpoint conditions.

**Root cause** (confirmed across 5 dispatches):
The depth-0 between-zone existential transfer is NOT independently provable from endpoint 1-var agreements alone. The between-zone is a 2-variable interval containment property that requires the full theorem at lower depth. The current simple `induction K` structure does not provide this.

**Required restructuring** (from analysis dispatch 2026-06-18):
Restructure `prior_nonconstenv_2var_agree_until/since` from simple `induction K` to **strong induction on total depth D=K+2**:
- At depth D, the quantifier part asks about depth-(D-1) 3-var transfers
- The depth-(D-1) 3-var transfer uses `cross_extend` to get candidate witnesses
- The depth-(D-2) quantifier conditions at the candidates transfer via P(D-2)
- P(D-2) is available from the strong IH (provides theorem at ALL lower depths)
- This eliminates circularity: zone-3 at depth D uses the theorem at depth D-1 (from IH), not the current depth

**Tasks remaining**:
- [ ] Restructure `prior_nonconstenv_2var_agree_until` to use strong induction on D=K+2 (replace `induction K` with `Nat.strong_rec_on` or equivalent)
- [ ] Implement zone decomposition for depth-(D-1) 3-var existential transfer:
  - Zones 1,2,4,5: `cross_extend_bwd_1var` (straightforward, patterns established)
  - Zone 3 (between): use IH at D-1 to get depth-(D-2) transfer, then `cross_extend` + Prior-UZ/SZ for the depth-(D-1) witness
- [ ] Mirror for `prior_nonconstenv_2var_agree_since`
- [ ] Verify `lake build PriorComposition` succeeds with 0 sorry
- [ ] Verify `lake build KampBypass` succeeds with 0 sorry

**Sorry budget**: 0. Target: reduce from 4 to 0.

**Timing**: 8-12 hours (2-3 dispatch sessions, restructuring + zone proofs)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` — restructure induction and implement zone-based transfer

**Verification**:
- `lake build PriorComposition` succeeds with 0 sorry
- `lake build KampBypass` succeeds with 0 sorry
- `lean_verify prior_nonconstenv_2var_agree_until` shows no sorryAx
- `lean_verify prior_nonconstenv_2var_agree_since` shows no sorryAx

---

### Phase 7: End-to-End Verification and Cleanup [NOT STARTED]

**Goal**: Verify the full completeness chain from `kamp_mutual_induction` through `completeness_discrete`, clean up dead code, and confirm zero sorry in the entire Kamp pipeline.

**Tasks**:
- [ ] Run `lean_verify kamp_mutual_induction` -- confirm no sorryAx
- [ ] Run `lean_verify completeness_discrete` -- confirm no sorryAx
- [ ] Run full `lake build` -- confirm no regressions
- [ ] Remove any dead imports or unused helper lemmas introduced during Phases 4-6
- [ ] Remove the "Fraisse game" comment block in PriorComposition.lean that references a now-superseded approach
- [ ] Update the module docstring in PriorComposition.lean to reflect the final proof strategy (CharPart-threading + zone-based Prior-UZ/SZ)
- [ ] Verify sorry count across the entire Kamp directory: `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`

**Sorry budget**: 0. No sorry in Kamp pipeline.

**Timing**: 1 hour (1 dispatch session)

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- cleanup
- Possibly other files in the Kamp directory if dead code is found

**Verification**:
- `lake build` succeeds
- `lean_verify completeness_discrete` clean (no sorryAx, only standard axioms)
- `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/Kamp/` returns 0 results (excluding comments)

## Testing & Validation

- [x] After Phase 1: `lake build GeneralExistPart` succeeds; no sorry in remaining code
- [x] After Phase 2: `lake build KampBypass` succeeds; sorry count = 2 (at between-zone sites only)
- [x] After Phase 3: Research report written with actionable design
- [x] After Phase 4 (4a-4c): KampBypass.lean sorry-free; PriorComposition.lean reduced to 4 sorry
- [x] After Phase 5: `lake build PriorComposition` + `lake build KampBypass` succeed; sorry count in PriorComposition = 4 (restructured positions at lines 264, 285, 336, 354); KampBypass sorry = 0
- [ ] After Phase 6: `lake build PriorComposition` succeeds; sorry count = 0; `lean_verify prior_nonconstenv_2var_agree_until` clean
- [ ] After Phase 7: `lean_verify completeness_discrete` clean; `lake build` succeeds; no sorry in Kamp directory

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/GeneralExistPart.lean` -- simplified (false definitions deleted) [Phase 1]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampMutualInduction.lean` -- simplified to 2-conjunct [Phase 1]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- sorry-free, CharPart forwarding to PriorComposition [Phases 2, 4b, 5]
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/PriorComposition.lean` -- CharPart-threaded zone-based transfer with Prior-UZ/SZ [Phases 5, 6, 7]
- `specs/303_k_gt_0_depth_induction/plans/15_charpart-threading-plan.md` -- this plan
- `specs/303_k_gt_0_depth_induction/reports/15_charpart-threading-design.md` -- key research input for this revision

## Rollback/Contingency

1. **Phase 6 strong-induction restructuring fails to compile**: The external signature is unchanged; only the internal proof structure changes. If `Nat.strongRecOn` creates type-level issues, use manual well-founded recursion with `have : D' < D := ...` and `termination_by D`.

2. **Phase 6 zone-3 argument still fails after restructuring**: With the strong IH providing the theorem at all lower depths, the zone-3 argument should be: cross_extend for witness, IH at D-1 for sub-NF transfer, Prior-UZ/SZ for placement. If this still fails, the mathematical approach needs revisiting — create a focused research dispatch to investigate alternative proof architectures.

3. **Any phase**: `git revert` to restore pre-attempt state. Do NOT re-attempt: GeneralExistPartOrdered, BetweenZoneExistPart, `depth0_3var_exist_transfer_until/since`, `exist_transfer_3var_nonconstenv`, `nonconstenv_exist_transfer_general`, `zone_compatible_witness_bwd/fwd` (all confirmed FALSE or unprovable as standalone statements across 10+ dispatch sessions).
