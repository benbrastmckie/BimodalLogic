# Task 337 (plan 12) Phase 2 Handoff — BLOCKED (sess_1783639750_29c89e_337)

## Status
- **Phase 1: COMPLETED** (green, axiom-clean `{propext, Classical.choice, Quot.sound}`, committed).
- **Phase 2 (O1): BLOCKED** — genuine landed-infrastructure gap (see below). The plan's own O1
  Rollback contingency is triggered.
- Phases 3–6: NOT STARTED (transitively blocked; the two public deliverables cannot be assembled
  without O1's sorted witness family).
- Full `lake build` GREEN. Sorry census in SharedWitness.lean unchanged at 7 (all in comments).

## Phase 1 landed (additive, after SW:7843, before the file `end`)
Primed tie-reporting order value substrate + one-value-per-class, needed because the target's
PRIMED order `kvE2_sepHonestOrder'` carries the tie-REPORTING `kvE2_sepSlotHonestVIdx` payload
(vs the unprimed order's tie-BREAKING `kvE2_sepSlotHonestGIdx`), so the banked value-sortedness
SW:4157 does not apply:
- `kvE2_sepSlotGIdx_honestOrder'` — primed halign bridge (mirror of SW:3995 with VIdx).
- `kvE2_sepSlotGIdx_honestOrder'_mono` — primed key monotone in slot value.
- `kvE2_sepSlotsLOf_honestOrder'_valueSorted` / `...ROf...` — primed merged lists value-sorted.
- `kvE2_sepTieRuns_key_const` — all elements of one tie class share the class key (unconditional).
- `kvE2_sepTieGroupedL_value_const` / `...R...` — one honest value per tie class.

## The blocker (four-element defect bar)
1. **Counterexample class of models**: A RIGHT-interior (`zWT3`) owner σ contributes an `.rXW`
   slot to the LEFT joint list (`kvE2_sepSlotsLFor`, SW:337). The LANDED `kvE2_sepSlotValue`
   `.rXW` branch (SW:3540) is `Classical.epsilon (fun v => x < v ∧ v < kvE2_sepAnchorVal σ ∧
   realizes χ)`. Since `kvE2_sepAnchorVal σ ∈ (w,t)` for right-interior owners and the predicate
   has NO `v < w` conjunct, for any honest model that also realizes χ at some point in
   `(w, anchorVal σ)` the epsilon can select `v ≥ w`. Hence `kvE2_sepSlotValue (.rXW σ χ) < w`
   is NOT provable.
2. **Current behavior**: `kvE2_sepBracketN_construct` (SW:5357) requires `(usL ++ w :: usR).Pairwise
   (· < ·)` — every LEFT per-class witness `< w`. The tie grouping pins each class witness to the
   shared `kvE2_sepSlotValue` (`kvE2_sepSlotHonestVIdx_eq_iff`, SW:5857). An all-`.rXW` LEFT tie
   class with shared value `≥ w` makes `usL`-last `≥ w`, so the construct is unfeedable and the
   grouped disjunct `.holds` is unestablishable for such models.
3. **Required behavior**: every `.rXW` honest value must be `< w`. The `kvE_sub2_zXU` zone bit
   (SubBracket2.lean:123, coord-1 = `(true,false)`) DOES force the honest zone witness `< w`
   (documented at SharedWitness.lean:104) — but that bound is discarded because the landed
   `kvE2_sepSlotValue` `.rXW` epsilon predicate omits the `v < w` conjunct.
4. **Isolation**: the defect is the WEAK epsilon predicate in the LANDED `kvE2_sepSlotValue`
   `.rXW` branch (task 340/342 asset), not any 337 lemma. Fixing it is a carrier edit, forbidden
   under this additive task.

## Fallback route ruled out
`kvE2_sepHonest_witnesses` (SW:4992) yields a correctly-around-`w` strict chain but (a) DROPS
`≥ w` pairs via `kvE2_sepGapRegions`/`kvE2_sepGapTypes` filtering (does not prove `< w`), (b)
needs per-slot distinct realizers `hnd` that fail for genuinely-tied models (the case 342's
tie-reporting order exists for), and (c) is a flat per-slot multiset, not the grouped per-class
one the target bracket needs.

## Recommended unblock (NEW upstream task — spawn)
Strengthen the LANDED `kvE2_sepSlotValue` `.rXW` branch predicate (SW:3540-3541) from
`x < v ∧ v < kvE2_sepAnchorVal σ ∧ realizes χ` to `x < v ∧ v < w ∧ realizes χ`. Satisfiability
comes from the `kvE_sub2_zXU` coord-1 (`w`) bit via `kvE_sub2_zoneHolds_cons_iff`
(SubBracket2.lean:538). Update `kvE2_sepSlotValue_rXW_spec` (SW:3642) and its consumers
(`kvE2_sepSlotValue_baseType_spec` SW:5909, `kvE2_sepHonestBasePairsL` SW:4602, region-rank
mono SW:3662) to the tighter bound. Then 337 plan 12 resumes: O1 pivot `usL`-last `< w` becomes
provable and Phases 2–6 proceed as planned. (Review symmetric bounds for other cross-region
slots while editing.)

## Next action for a successor
Do NOT re-dispatch 337 plan 12 as-is; it will re-hit this blocker at O1. First resolve the
carrier `.rXW` bound via a spawned task, then resume. Phase 1 assets remain valid and reusable.
