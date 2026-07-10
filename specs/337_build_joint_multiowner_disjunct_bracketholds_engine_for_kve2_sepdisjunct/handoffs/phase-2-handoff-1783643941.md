# Task 337 — Phase 2 Handoff (carrier fix COMPLETE; Phases 3–7 remain)

**Session**: sess_1783639750_29c89e_337
**Commit**: `0b4adc9ea` (task 337 phase 2)
**Build**: `lake build ...SharedWitness` GREEN. Sorry count in SharedWitness = 7 (all prose).

## What Phase 2 accomplished (the authorized `.rXW` carrier fix — DONE, verified)

The below-pivot `v < w` bound is RESTORED on the `.rXW` value chain. Three authorized sites +
their consumers, all green and axiom-clean:

1. `kvE_sub2_zoneHolds_zXU` (SubBracket2.lean:565) — conclusion now `x < v ∧ v < w ∧ v < x1`
   (keeps the coord-1 `hp1`, `v < w = hp1.1.mpr rfl`).
2. `kvE_subBracket2_complete_extract` zXU field (SubBracket2.lean:619-620/631) — the plan's named
   authorized consumer; conclusion now `∃ v, x < v ∧ v < w ∧ v < x1 ∧ realizes χ`.
3. `kvE2_sepSlotValue_rXW_spec` (SharedWitness.lean:~3648) — conclusion now `x < v ∧ v < w ∧ realizes`.
4. `.rXW` branch of `kvE2_sepSlotValue` (SharedWitness.lean:~3540) — epsilon upper bound `v < w`.

**Blast-radius correction (important):** `complete_extract`'s zXU field has THREE consumers, not
the one the plan stated. All re-projected mechanically (drop the new `v < w` conjunct), each
preserving its own public signature byte-for-byte:
- SharedWitness.lean:~2770 (zXW3 left-interior honest bundle) — re-projected.
- SharedWitness.lean:~3464 (zXW3 anchor-relative honest bundle) — re-projected.
- **SubBracket2V.lean:~1904** (`hrealXU`) — NOT listed in the plan's blast radius; re-projected.

**STOP-condition (task 342) — CLEARED.** `lean_verify` MCP is UNRELIABLE here (returned
contradictory `sorryAx` across runs after external `lake build` — stale LSP state). Use the
DETERMINISTIC `#print axioms` at build time instead. Ground truth:
`kvE2_sepBody_complete_holds'`, `kvE2_sepBody_complete`, and `kvE2_sepSlotValue_rXW_spec` ALL
report exactly `[propext, Classical.choice, Quot.sound]` — NO `sorryAx`. No regression.
(EANegation.lean:834/1129 have two real `sorry`s but are OFF the axiom path — confirmed by the
clean `#print axioms`.)

**Phase-7 gate reference caps (post-fix, re-measured):** SharedWitness `kvE_sub2_`=107, `x1 <`=73;
SubBracket2 `kvE_sub2_`=46, `x1 <`=4.

## What remains (Phases 3–7) — NOT STARTED

O1 (Phase 3), O2 (Phase 4), O3(a) segment-eval family (Phase 5, plan-flagged as likely to exceed
one dispatch), O3(b) gap discharge (Phase 6), O4 assembly + the two public theorems (Phase 7).
The private engine `kvE2_sepBracketN_construct` (SharedWitness.lean:~5365) is the assembly target;
its signature (hlenL/hlenR/hsort/hrange/hptL/hptW/hptR/hseg0/hsegmid/hseglast) enumerates exactly
the obligations O1–O3 must supply.

### Immediate next action (Phase 3, O1)
With Phase 2 landed, `usL`-last `< w` is now provable PER-SLOT (do NOT use value-sortedness — plan
12 line-140 mitigation is retracted/unsound):
- LEFT slots all `< w`: `.lXU` (`x<v<x1<w`), `.lUW` (`x1<v<w`), `.rXW` (`x<v<w`, from the
  strengthened `kvE2_sepSlotValue_rXW_spec` — now `.2.1` gives `v < w` directly).
- RIGHT slots all `> w`: `.lWT`, `.rWX1`, `.rX1T` from their value specs.
Combine with Phase-1 substrate: `kvE2_sepSlotsLOf_honestOrder'_valueSorted` (:~7935),
`kvE2_sepSlotHonestVIdx_mono` (:~5842), `kvE2_sepSlotGIdx_honestOrder'_mono` (:~7919),
`kvE2_sepTieGroupedL_value_const`/`...R...` (:~8013/:~8043), `kvE2_sepTieGroupedL_flatten` (:~2064).

### CAUTION for the successor (unresolved understanding gap)
The tie-class semantics need careful verification before authoring O1: `kvE2_sepSlotGIdx` is
described (comment at SW:~3526) as `ordRank` of `(value, slotIndex)` with an index tiebreak "giving
injectivity WITHOUT value-distinctness" — which naively would make every `kvE2_sepTieRuns` class a
singleton, contradicting task 342's tie-admitting purpose. Resolve exactly what key ties before
proving strict cross-class monotonicity of the mapped class-value list. This gap is WHY this
dispatch stopped at Phase 2 rather than risk an incorrect O1.

### Binding prohibitions still in force
No vacuous close / `False.elim` / `sorry` on any live path. Do NOT touch `kvE2_sepSlotsLOf`/`LFor`.
Do NOT weaken O1's strict `<`. `hLR` stays deleted. Axiom-clean `{propext, Classical.choice,
Quot.sound}`. LITMUS NS:437: no `x1 < e_i` relative-position literal. Verify axioms with
`#print axioms`, NOT `lean_verify`.
