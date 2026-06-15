# Implementation Plan: Complete Kamp Bypass Sorries and Downstream Wiring

- **Task**: 273 - chronicle_gap_contradiction_proof
- **Status**: [IN PROGRESS]
- **Effort**: 8 hours
- **Dependencies**: Plan v30 Phase 1 [COMPLETED], Plan v30 Phase 2 [IN PROGRESS] (3/7 sorries filled)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/31_kamp-bypass-sorry-goals.md
- **Artifacts**: plans/32_depth0-sorries-completion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 remaining sorries in KampBypass.lean (4 depth-0 wiring sorries + 1 depth >= 2 arity-climbing sorry) and wire the results through NfCharFormula.lean and RabinovichGeneralized.lean to make the full Kamp expressive completeness chain sorry-free. Then verify whether chronicle_gap_contradiction is unblocked. The 4 depth-0 sorries are mechanical wiring -- all mathematical infrastructure exists sorry-free in ZoneBridge.lean, VecEADecomp.lean, and KampForward.lean. The depth >= 2 sorry requires substantial new mathematical content (arity-climbing induction). Definition of done: `kamp_prior_expressive_completeness` and `US_expressively_complete_over_prior` show no sorryAx.

### Research Integration

Report 31 (goal-state analysis, 2026-06-14) provided lean_goal output for all 5 sorry sites, identified available hypotheses and infrastructure, assessed feasibility (HIGH for eq, MEDIUM for since/bracket, MEDIUM-HIGH for forward, LOW for depth >= 2), and recommended fill order: L753 (eq) -> L1615 (since) -> L1284 (bracket) -> L1503 (forward) -> L1703 (depth >= 2). Key finding: all depth-0 sorries are zone-by-zone wiring with existing sorry-free infrastructure. The bracket sorry (L1284) requires a witness-sorting/permutation argument for IntervalPattern construction when pos_between has multiple elements.

### Prior Plan Reference

Plan v30 (5 phases): Phase 1 (ssn_order_consistent filter) COMPLETED. Phase 2 (depth-0 wiring) IN PROGRESS with 3/7 sorries filled and 4 remaining. Phases 3-5 NOT STARTED. Key lessons: (1) `unfold atom_eval + exact h` technique resolves Fin.cons/Fin.cases proof-term mismatch after subst; (2) zone extraction helpers and zone-temporal bridge lemmas compose ZoneBridge theorems with nf_depth0_char_formula_correct; (3) eq_case_orders helper extracts equality consistency from ssn_order_consistent. Effort calibration from v30: filling 3 sorries + adding infrastructure took approximately 500 lines in the first dispatch. Postmortem constraints (binding): DO NOT extract NF data from formula truth (enriched formula avoids this), DO NOT use wrong-depth characteristic formulas, DO NOT encode negative intervals as blocking guards, DO NOT attempt nf_3var_from_1var_nfs at fixed arity, DO NOT cycle between formula-level and NF-level fixes.

### Roadmap Alignment

- Advances: Kamp chain closure (kamp_prior_expressive_completeness -> US_expressively_complete_over_prior) -- one of two independent sorry chains blocking completeness_discrete
- The other chain (succ_cofinal via Reynolds k-equivalence bypass, task 202) is independent
- chronicle_gap_contradiction may be unblocked once the Kamp chain is sorry-free

## Goals & Non-Goals

**Goals**:
- Fill the 4 remaining depth-0 sorries in KampBypass.lean (lines 753, 1284, 1503, 1615)
- Fill the depth >= 2 sorry in KampBypass.lean (line 1703) via arity-climbing induction
- Fill existPart_succ n >= 2 sorry in RabinovichGeneralized.lean (line 465)
- Verify the full Kamp chain (kamp_prior_expressive_completeness, US_expressively_complete_over_prior) is sorry-free
- Verify chronicle_gap_contradiction status after Kamp chain closure

**Non-Goals**:
- Filling NfCharFormula.lean:542 (nf_exist_backward_prior) -- bypassed, dead code on critical path
- Modifying sorry-free infrastructure (ZoneBridge.lean, VecEADecomp.lean, KampForward.lean, NfToVecEA.lean)
- Filling StaviCompleteness.lean sorries (nf_2var_existential_transfer -- separate chain)
- Proving succ_cofinal (task 202, Reynolds bypass)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Bracket witness ordering (L1284): IntervalPattern requires strictly increasing witnesses; pos_between list order may not match model order | M | M | Use Classical.choice + sorting by model's decidable linear order. nf_y_proj is injective on pos_between (proved in report 31), so distinct SSNs yield distinct witnesses that can be sorted. Segment guards hold everywhere in (t,x) via h_seg, so reordering is safe. |
| Forward direction zone extraction (L1503): Reversing enriched formula requires extracting zone conditions from conjunctions | M | L | Each zone follows the same pattern (zone_bridge_* backward direction). formula_conjList_iff provides conjunction extraction. Mirror structure of the backward direction already proved. |
| Since formula asymmetry (L1615): enriched_bypass_since uses flat disjList + Since, not VVecEA2 | M | L | The flat encoding is actually simpler. Since temporal semantics directly provides x < t and guard conditions. Zone bridges are symmetric (zone_bridge_below_t works for y > x in the Since direction with swapped roles). |
| Depth >= 2 arity-climbing (L1703): Generalizing bypass to arbitrary depth requires IH at all arities + Fin arithmetic at higher arities | H | H | Start with n=1 case only (sufficient for NfCharFormula wiring). The IH char_kp1_correct provides temporal formulas at depth k+1 for 1-var NFs. Quantifier conditions at depth k+1 for 3-var are depth-k' 3-var existentials -- use IH recursively. If Lean type-level issues arise, specialize rather than generalize. |
| Heartbeat budget exhaustion: KampBypass.lean already uses maxHeartbeats 800000-1600000 | M | M | Factor each sorry fill into small helper lemmas (private def). Keep proof terms compact. Use set_option maxHeartbeats locally if needed. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases are fully sequential. Each depends on the prior.

---

### Phase 1: Fill eq case (L753) and Since case (L1615) [IN PROGRESS]

**Goal**: Close the two most self-contained depth-0 sorries. The eq case (L753) is the easiest sorry (HIGH feasibility, ~80-120 lines) where x=t collapse eliminates zone complexity. The Since case (L1615) is self-contained and mirrors Until but with flat disjList encoding (~150-200 lines).

**Tasks**:
- [ ] Fill `existPart_succ_n1_bypass_k0_eq` compatible subcase (L974). Strategy: when both order bools are false, `witness_eq_t_of_no_order` forces x=t. The enriched_bypass_eq formula is a disjunction over compatible nf_x values. For backward: given x with nf_eval, x=t, find nf_x = nf_characteristic, show it appears in the disjunction via Fintype.complete, show char_1(nf_x) holds via char_1_correct, show quant_conjuncts hold using zone bridges adapted for x=t (zone_bridge_eq_t, zone_bridge_eq_x, eq_case_orders). For forward: extract nf_x from disjunction, use char_1_correct to get nf_eval at t, reconstruct nf_eval at (t,t) from pred_compat + t_compat + h_atoms. *(deviation: altered — proof path fully validated: simp [enriched_bypass_eq] + rw [formula_disjList_iff] works; ssn_xt_compat_{x,t}_preds are PRIVATE requiring manual extraction; ~250 lines needed for 6 zone cases x 2 directions; recipe documented in handoffs/eq-case-recipe-20260614.md)*
- [ ] Fill `existPart_succ_n1_bypass_k0_since` (L1615). Strategy: provide `enriched_bypass_since atomMap h_surj char_1 sub_nf parent_atoms` as the witness formula A. Prove backward direction (exists x < t, nf_eval -> formula truth): Given x < t with nf_eval, extract nf_x = nf_characteristic. Find the right disjunct matching nf_x. Show pre_at_t holds at t (above_t and eq_t zones via zone_bridge_above_x and zone_bridge_eq_t). Show pt_x holds at x (eq_x and below_x zones via zone_bridge_eq_x and zone_bridge_below_t). Show guard holds between x and t (negative between SSNs via seg_guard analog). Prove forward direction (formula truth -> exists x, nf_eval): from Since semantics, extract x < t. Extract nf_x from disjunction. Reconstruct nf_eval from temporal conditions using zone bridges backward. *(deviation: deferred — waiting for eq case to succeed first to establish pattern)*
- [ ] Verify `lake build` passes with 3 remaining sorries (bracket L1284, forward L1503, depth >= 2 L1703)

**Timing**: 2 hours (~200-300 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- fill L753 and L1615 sorry sites

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- grep for sorry shows only 3 remaining (L1284, L1503, L1703)

---

### Phase 2: Fill bracket case (L1284) [NOT STARTED]

**Goal**: Close `backward_holdsLeft_of_nf_eval` bracket case. Requires constructing an IntervalPattern.holds witness with strictly increasing witnesses for positive between_tx SSNs.

**Tasks**:
- [ ] Prove nf_y_proj injectivity on pos_between: since all SSNs in pos_between are in the between_tx zone with identical x/t predicates, distinct SSNs must have distinct y-predicates (nf_y_proj). Factor as a helper lemma.
- [ ] For each positive SSN in pos_between, extract witness y_i from h_eval_quant + between_tx_temporal_iff: each gives `exists y, t < y AND y < x AND nf_eval_nf M 0 1 (fun _ => y) (nf_y_proj ssn_i)`. Use Classical.choice to obtain a function assigning witnesses.
- [ ] Construct the strictly increasing witness sequence: sort the witnesses by model order (M.carrier has DecidableLinearOrder). The sorted sequence is strictly increasing because witnesses have distinct predicate profiles (nf_y_proj injective), and the model's linear order separates them.
- [ ] Verify IntervalPattern.holds conditions: (a) witnesses are strictly increasing (from sorting), (b) all in (t, x) (from between_tx zone extraction), (c) pointTypes match at sorted positions (construct permutation mapping sorted positions to pos_between indices), (d) segmentTypes hold on all intervals (follows from h_seg: seg_guard holds for ALL y in (t,x)).
- [ ] Verify `lake build` passes with 2 remaining sorries (forward L1503, depth >= 2 L1703)

**Timing**: 1.5 hours (~100-150 lines)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- fill L1284 sorry site

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- grep for sorry shows only 2 remaining (L1503, L1703)

---

### Phase 3: Fill forward direction (L1503) [NOT STARTED]

**Goal**: Close `forward_nf_eval_of_holdsLeft` -- the hardest depth-0 sorry. Given h_endLeft, h_endRight, h_bracket, h_t_lt_x, reconstruct `nf_eval_nf M 1 2 (Fin.cons x (fun _ => t)) sub_nf`. This is the reverse of the backward direction: extract NF conditions from temporal formula truth.

**Tasks**:
- [ ] Prove the atom part of nf_eval_nf: (a) predicate atoms at x (index 0): extract from h_endRight -> char_1_correct -> nf_eval at x -> atom conditions via nf_x_compat_check; (b) predicate atoms at t (index 1): from h_atoms directly; (c) order atoms: h_gt/h_lt + h_t_lt_x give the order conditions.
- [ ] Prove the quantifier part zone-by-zone. For each ssn, case-split on ssn_zone_until:
  - below_t zone: extract from h_endLeft conjunction -> pre_conditions_at_t_until -> Since/snce formulas -> zone_bridge_below_t backward
  - eq_t zone: extract from h_endLeft conjunction -> char_y at t -> zone_bridge_eq_t backward
  - between_tx zone (positive): extract from h_bracket -> IntervalPattern.holds -> bracket witnesses -> zone_bridge_between_tx backward
  - between_tx zone (negative): extract from h_bracket -> segment guards -> neg(char_y) in (t,x) -> no witness exists
  - eq_x zone: extract from h_endRight conjunction -> char_y or neg(char_y) at x -> zone_bridge_eq_x backward
  - above_x zone: extract from h_endRight conjunction -> Until(char_y, top) or neg -> zone_bridge_above_x backward
- [ ] Wire the atom part and quantifier part together into the nf_eval_nf conclusion
- [ ] Verify `existPart_succ_n1_bypass_k0` is sorry-free at depth 0 (all 4 depth-0 sorries now filled). Run `lean_verify existPart_succ_n1_bypass_k0` -- should show no sorryAx.
- [ ] Verify `lake build` passes with 1 remaining sorry (depth >= 2 L1703)

**Timing**: 2 hours (~150-200 lines)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- fill L1503 sorry site

**Verification**:
- `lean_verify Bimodal.Metalogic.WeakCanonical.Kamp.existPart_succ_n1_bypass_k0` shows no sorryAx
- `lake build Bimodal.Metalogic.WeakCanonical.Kamp.KampBypass` succeeds
- grep for sorry shows only 1 remaining (L1703)

---

### Phase 4: Fill depth >= 2 (L1703) and wire into NfCharFormula/RabinovichGeneralized [NOT STARTED]

**Goal**: Fill the `existPart_succ_n1_bypass` succ k' case (depth >= 2) via arity-climbing induction, fill `existPart_succ` n >= 2 in RabinovichGeneralized.lean, and verify the full Kamp chain is sorry-free.

**Tasks**:
- [ ] Implement the depth k+1 enriched bypass formula. At depth k'+2, sub_nf has depth-(k'+1) 3-var quantifier conditions. The IH `char_kp1_correct` gives temporal formulas for depth-(k'+2) 1-var NFs. For each compatible nf_x, construct: char_{k'+2}(nf_x) as point type at x, and for each quantifier SSN, use the IH recursively to encode the existential as a temporal formula. The enriched formula follows the same pattern as depth 0 but replaces depth-0 zone conditions with IH-derived temporal formulas. (~100-150 lines)
- [ ] Prove the backward direction at depth k+1: given x with nf_eval_nf at depth k'+2, show the enriched formula holds. Atom part from char_kp1_correct. Each positive quantifier condition from the IH biconditional forward direction. Each negative condition from the negated IH biconditional. Temporal wrapping (Until/Since) from x's zone. (~100-150 lines)
- [ ] Prove the forward direction at depth k+1: given the enriched formula holds, extract x from Until/Since semantics. Extract nf_x from the disjunction and char_kp1_correct. Extract each quantifier condition from the conjunction via the IH biconditional backward direction. Assemble nf_eval_nf. (~100-200 lines)
- [ ] Fill `existPart_succ` n >= 2 (RabinovichGeneralized.lean:465). The generalized bypass at arbitrary arity n fills this. Call the bypass with appropriate arity parameter. (~30-50 lines)
- [ ] Verify the full Kamp chain:
  - `lean_verify existPart_succ_n1_bypass` -- no sorryAx at all depths
  - `lean_verify nf_2var_exist_formula_prior` -- no sorryAx
  - `lean_verify kamp_prior_expressive_completeness` -- no sorryAx
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx

**Timing**: 2 hours (~300-500 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- fill L1703 sorry (depth >= 2)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- fill existPart_succ n >= 2 (L465)

**Verification**:
- `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- `lean_verify US_expressively_complete_over_prior` shows no sorryAx
- `lake build` on full Kamp module succeeds

---

### Phase 5: Chronicle gap verification and full build [NOT STARTED]

**Goal**: With the Kamp chain sorry-free, check whether chronicle_gap_contradiction is unblocked. Run full verification to identify remaining sorry chains for completeness_discrete.

**Tasks**:
- [ ] Run `lean_verify completeness_discrete` to identify all remaining sorryAx. Determine which trace through the Kamp chain (should be zero) vs the succ_cofinal chain (task 202).
- [ ] Check `lean_verify chronicle_gap_contradiction` -- determine if it is unblocked by the Kamp chain closure or if it depends on other sorry sites (succ_cofinal, nf_2var_existential_transfer in StaviCompleteness.lean).
- [ ] If chronicle_gap_contradiction is unblocked: fill it using the now sorry-free model surgery infrastructure + Kamp expressive completeness (~50-80 lines). If it remains blocked by the Stavi chain or succ_cofinal: document the remaining blockers.
- [ ] Run `lake build` on the full project -- verify 0 build errors.
- [ ] Document the final sorry inventory: which sorries remain, what tasks own them.

**Timing**: 0.5 hours (~50-80 lines if fillable, otherwise verification only)

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- fill chronicle_gap_contradiction if unblocked
- No other files modified in this phase

**Verification**:
- `lean_verify completeness_discrete` -- remaining sorryAx should trace only through task 202 chain (succ_cofinal) and/or Stavi chain
- `lake build` succeeds (full project, 0 errors)

---

## Testing & Validation

- [ ] After Phase 1: grep shows 3 remaining sorries in KampBypass.lean (L1284, L1503, L1703)
- [ ] After Phase 2: grep shows 2 remaining sorries (L1503, L1703)
- [ ] After Phase 3: `lean_verify existPart_succ_n1_bypass_k0` shows no sorryAx
- [ ] After Phase 4: `lean_verify kamp_prior_expressive_completeness` shows no sorryAx
- [ ] After Phase 4: `lean_verify US_expressively_complete_over_prior` shows no sorryAx
- [ ] After Phase 5: `lean_verify completeness_discrete` identifies remaining sorry chains (succ_cofinal only)
- [ ] After Phase 5: `lake build` full project succeeds with 0 errors

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampBypass.lean` -- all 5 sorries filled (~650-1100 new lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/RabinovichGeneralized.lean` -- existPart_succ n >= 2 filled (~30-50 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- chronicle_gap_contradiction filled if unblocked (~50-80 lines)
- `specs/273_chronicle_gap_contradiction_proof/plans/32_depth0-sorries-completion.md` -- this plan

## Rollback/Contingency

**If bracket witness ordering (Phase 2) is harder than estimated**: Skip the permutation argument. If pos_between has at most 1 element (common case), the bracket reduces to a single witness or trivial segment guard. Prove the n=0 and n=1 subcases first. If n >= 2 is rare/impossible in practice, add an axiom sorry with a clear TODO.

**If forward direction (Phase 3) zone extraction is tedious**: Factor each zone case into a separate helper lemma. The backward direction (already proved) validates the zone-bridge approach. If any zone case is unexpectedly hard, use sorry with a targeted TODO and proceed to Phase 4.

**If depth >= 2 (Phase 4) Lean type-level issues arise**: Specialize to n=1 (arity 2) only -- this is sufficient for NfCharFormula wiring. The n >= 2 case at RabinovichGeneralized.lean:465 can remain as sorry with documentation. Depth-0 and depth-1 sorry-free status (Phases 1-3) provides value regardless.

**If chronicle_gap_contradiction (Phase 5) remains blocked**: Document which sorry chain blocks it. The Kamp chain closure (Phases 1-4) is the primary deliverable. The chronicle gap depends on both the Kamp chain AND the Stavi chain -- if only the Kamp chain is closed, the gap remains blocked by the Stavi chain.

**If the approach fails entirely**: All existing sorry-free code (~5000+ lines) remains valid. Each phase is independently valuable: Phase 1 alone fills 2 sorries, Phases 1-3 make depth 0 sorry-free, and Phase 4 extends to all depths.
