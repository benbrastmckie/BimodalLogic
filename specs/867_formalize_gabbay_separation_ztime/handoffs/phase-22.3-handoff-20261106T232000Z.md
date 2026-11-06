# Phase 22.3 Handoff — `uTypeCount` and GHR Lemma 10.2.6

- **Status**: [COMPLETED]
- **Dispatch**: 18 (session sess_1794005409_20566a)
- **Plan**: `specs/867_formalize_gabbay_separation_ztime/plans/03_structural-route-measure-split.md`

## Immediate next action

Phase 23 (GHR Lemma 10.2.7, the `untl`-nesting induction). Its part (b) obligation can now cite
`uTypes_sepMulti` / `hasPureUTypes_sepMulti` — 10.2.6's conclusion re-establishes its own
hypothesis, so a 10.2.7 step that consumes a 10.2.6 output needs no fresh type-cleanliness
argument. **Re-size Phase 23 before starting it**: its Scope Hypothesis rests on the same false
premise this phase's did (that the abstraction/reindexing device was already landed). The device
is landed now and is reusable, so the correction should be downward, not upward — but the plan's
printed number is not trustworthy as written.

## Proof state

No open goals. `lean-sorry-census.sh`: `sorry_count: 0` across all eight resolved source roots.
Full unscoped guarded `lake build`: exit 0, zero `error:`, 2961 jobs; `.olean` newer than source
for the touched module.

## What landed

All additive, in the module Phases 22.1 and 22.2 built; zero new modules.

`FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` (268 -> 1000 lines), in five
groups:

1. **The measure**: `uTypes` (maximal `untl` subformulas, deduplicated), its five equation/
   membership lemmas, `uTypes_nodup`, `uTypeCount`, and the measure's API —
   `uTypes_eq_singleton_of_mem`, `maxLeaf_le_of_mem_uTypes`, `uTypes_eq_nil_of_isSOnly`,
   `isSOnly_of_uTypes_empty`, `isSOnly_of_uTypeCount_le_zero`, and the two bridges
   `uTypes_of_isUTyped` and `isUSingleType_of_uTypes`.
2. **GHR 10.2.6's precondition**: `IsPureType`, `HasPureUTypes`, with
   `uTypes_eq_self_of_isPureType` and `isSeparated_of_isPureType`. No new inductive predicate —
   the hypothesis is a condition on the measured list, which is what GHR's own statement says.
3. **The abstraction and reindexing device** (see Deviations — this was supposed to be already
   landed): `mapU`, `mapS`, `substLeaf`, `usTruth_substLeaf`, `substLeaf_eq_self_of_lt`,
   `abstrFn`, `unabstrFn`, `unabstrFn_of_lt`, `unabstrFn_abstrFn_of_mem`, `unabstrFn_cases`,
   `mem_uTypes_unabstrFn`, `mapS_unabstrFn`, `isSeparated_unabstrFn`, `mem_uTypes_mapU`,
   `substLeaf_mapU_abstr`.
4. **The three decrease obligations, separately named**: `uTypes_mapU_abstr` with its instance
   `uTypes_mapU_abstr_eq_head` (part a), `uTypes_sepU` (part b, a one-line citation of
   `isUTyped_sepU`), `uTypeCount_snce_substLeaf_le` with `mem_uTypes_substLeaf_of_isSOnly` and
   `hasPureUTypes_snce_substLeaf` (part c).
5. **GHR 10.2.6**: `mapS_substLeaf_spec` (the reindex-and-recurse pass), `sepBody`,
   `sepBody_nil`, `sepBody_cons`, `sepFuel`, `sepMulti`, `sepFuel_spec`, and the three
   conclusions `isSeparated_sepMulti`, `usTruth_sepMulti`, `uTypes_sepMulti`, plus
   `hasPureUTypes_sepMulti`.

Also: two new imports (`Mathlib.Data.List.Dedup`, `Mathlib.Data.List.Perm.Subperm`); module
docstring rewritten (title, Main Results, and a new section recording the two formalization
choices); `SeparationZ/README.md` module row, three Key Results bullets and the `## Not landed`
section (which now opens at Lemma 10.2.7); `typst/generated/status.typ`, `README.md`,
`FormalSystem/Metalogic/README.md` regenerated counts.

## Key decisions

- **The measure is read off the formula, not threaded as a parameter list** — the plan's
  instruction, kept. `HasPureUTypes` is then GHR's hypothesis verbatim.
- **The induction carries the count as an explicit budget, not as Lean well-founded recursion.**
  This is forced, not preferred: the recursive call is fired by `mapS` at the separated form's
  `snce` constituents, which are neither subterms of the definition's argument nor in scope at
  elaboration time, so no `decreasing_by` goal can be stated for it. `sepMulti` instantiates the
  budget at `uTypeCount`, so the budget never reaches the statement of the lemma. Recorded at
  `sepFuel` and in the module docstring.
- **`usTruth_congr_of_update` is unused and was the wrong tool.** `usTruth_substLeaf` moves the
  substitution onto the leaf valuation and is strictly stronger; the equivalence half of 10.2.6
  is a five-line `calc` with no freshness side-condition on the valuation. `freshLeaf` is still
  load-bearing, but only for the syntactic round trip `substLeaf_mapU_abstr`.
- **Part (b) cites `isUTyped_sepU` and never `isUTyped_sepSnce`**, as the plan rules. The only
  `isUTyped_sepSnce` occurrence in the module outside prose is Phase 22.2's own landed proof of
  `isUTyped_sepU` at line 263, untouched.
- **No input position asks for more than it needs.** 10.2.5's hypothesis is discharged as
  `IsUSingleType` (`hsingle`), 10.2.4's as `IsUTyped` (`htyped`); `IsSeparated` appears at no
  input position (D-f).
- `List.dedup` was chosen over `List.union` for the measure: it needs only `DecidableEq USForm`
  (already derived) and `List.mem_dedup`/`List.nodup_dedup` are the two lemmas the measure's API
  rests on.

## Deviations

Two, both annotated inline on their checklist items, plus a confirmed-false Scope Hypothesis.

1. **The recursion mechanism and the device** (on the "prove it by strong recursion on
   `uTypeCount`" item): the route, the measure and every step are exactly as specified, but two
   sub-claims of the bullet did not hold — the budget-vs-well-founded point and the
   `usTruth_congr_of_update` point above.
2. **Inventory regeneration** (on the typst item): `README.md` and
   `FormalSystem/Metalogic/README.md` also needed `--emit-inventory`. Fourth consecutive phase.

**Scope Hypothesis: CONFIRMED FALSE, and its own stated diagnosis is also false.** 48 new
`def`/`theorem`/`inductive` declarations against a predicted five (zero new modules did hold).
The hypothesis said an overshoot would mean part (b) had been re-proved; part (b) is a one-line
citation, so that cause is ruled out. The real cause is the task text's assertion that
"Phase 1's `freshLeaf` and `usTruth_congr_of_update` are the whole device" — the tree carries no
substitution operation on `USForm` in either direction, so group 3 above had to be built from
nothing. The full diagnosis is written into the plan under the Scope Hypothesis.

## Measured gates

- Scoped guarded build of `...SeparationZ.Hierarchy`: exit 0, zero `error:`, 1492 jobs, zero
  warnings.
- Full unscoped guarded `lake build`: exit 0, zero `error:`, 2961 jobs, `.olean` newer than
  source for the touched module.
- `lean-sorry-census.sh`: `sorry_count: 0`.
- Vacuous-pattern grep: 1 hit, pre-existing at `FormalSystem/Examples/TemporalStructures.lean:495`
  (a `trivial` whose goal genuinely is `True`-shaped), in a file this phase does not touch.
- `axiom ` declarations: 14, unchanged from the Phase 22.2 baseline, none in a touched file.
- Axiom profiles, measured by `#print axioms` under `lake env lean`: `uTypes` and `uTypeCount`
  depend on no axioms; `sepBody`, `sepFuel` and `sepMulti` on `propext`; every theorem of this
  phase on `propext, Classical.choice, Quot.sound`. All within the three standard axioms the
  landed eliminations already carry — nothing new.
- Blocking check — the separating function compiles without `noncomputable`: the only occurrences
  of the token in the module are inside docstrings explaining its absence, and
  `#eval sepMulti ...` returns a value.
- Blocking check — `uTypeCount` is a total structural recursion: no `partial`, no well-founded
  `sorry`; `sepFuel` is structural on its `ℕ` budget.
- Blocking check — D-h ruling not bypassed: `grep -rn 'snceDepthAbove\|hasUntl'` over
  `SeparationZ/` returns nothing.
- `check-module-invariants.sh`: ALL CHECKS PASSED (exit 0) after the inventory regeneration.
- `check-metalogic-cycles.sh`: exit 0, recorded cycle and upward import set unchanged.
- `typst-sync-check.sh --fix`: PASS (status.typ regenerated; module map and machine appendix
  already in sync).
