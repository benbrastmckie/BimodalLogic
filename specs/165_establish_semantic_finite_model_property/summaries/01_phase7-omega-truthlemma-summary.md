# Phase 7 (partial) — Omega and the per-history truth-lemma engine

- **Task**: 165 establish_semantic_finite_model_property
- **Phase**: 7 (Truth Lemma and Track A Decidability — MILESTONE), left `[PARTIAL]`
- **Plan**: `specs/165_establish_semantic_finite_model_property/plans/01_tableau-decidability-two-track.md`
- **Status**: 7.1 half landed, sorry-free, both builds green; 7.2 and 7.3 not started
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD

## Phases executed

Phase 7 only, task 7.1, first half. Single-phase focus honoured; no work past Phase 7.

## What landed

`FormalSystem/Metalogic/Decidability/Verified/Bridge/Omega.lean` (new)

- `regionFrame W ι D` — the countermodel's `TaskFrame`. States are `W × (Set ι × Set ι)`, a branch
  world paired with a region code; `TaskRel s d s' := d = 0 → s = s'`.
- `regionHistory f w Δ`, `regionOmega f` (an explicit `Set.range`), `worldHistory_ext`,
  `timeShift_regionHistory`, `mem_regionOmega_iff`, `regionOmega_total`,
  `shiftClosed_regionOmega` — the shift-closure obligation discharged.
- `truthAt_box_iff`, `truthAt_box_congr`, `truthAt_box_congr_history` — for any shift-closed `Om`,
  `box φ` holds at a point iff `φ` holds at every history and every time.
- `regionHistory_eq_timeShift`, `truthAt_regionHistory_offset`, `truthAt_box_iff_base` — the
  reduction of `Ω` to the base histories, and the `box` interface the truth lemma consumes.
- `regionConstant_regionHistory_zero`, `not_regionConstant_regionHistory_one`.

`FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` (new)

- `InterpInvariantAt f M Om τ χ` and every case (`atom`, `bot`, `imp`, `box`, `neg`, `top`,
  `untl`, `snce`, and the four derived temporal operators), the assembled `interpInvariantAt`,
  `interpInvariantAt_of_interpInvariant`, and `interpInvariantAt_regionHistory`.
- A documented "What the truth lemma still needs" section stating obligations O1-O3.

`FormalSystem/Metalogic/Decidability.lean` — both modules registered with docstring entries.

## Measured design corrections

1. **`Ω = Set.univ` is unusable.** It contains the empty history, at which every atom is false, so
   a single such history falsifies `□p`. `Set.univ_shift_closed` is therefore not the fallback the
   plan named; `regionOmega` is an explicit range.
2. **Phase 6's `∀ τ ∈ Ω, RegionConstant f τ` is unsatisfiable for any shift-closed `Ω`.** Cofinitely
   many translates make any two points region-mates, forcing constant states and a time-blind
   model. Witness in-tree: `not_regionConstant_regionHistory_one`. The interface moves to the
   per-history `InterpInvariantAt`; Phase 6's file is untouched and its region lemmas are consumed
   verbatim.
3. **Engine probes** (against `buildTableau`): `□p → □Gp`, `□p → □□p`, `□p → G□p`, `□p → ¬◇F¬p`,
   `Gp → Fp`, `¬(Gp ∧ G¬p)`, `¬(Hp ∧ H¬p)`, `F ⊤`, `P ⊤` all CLOSE; control `Fp → p` stays OPEN.
   This is the adequacy check for reading `□` as the universal modality.

## Final verification

| Check | Result |
|-------|--------|
| `sorry` in new files | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 |
| `lake build FormalSystem.Metalogic.Decidability` | green (1107 jobs) |
| `lake build BimodalTest` | green (1957 jobs) |
| Axiom audit (7 headline theorems) | `propext`, `Classical.choice`, `Quot.sound` only |

Known out-of-territory RED (pre-existing, untouched): full `lake build` fails at
`FormalSystem/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean`.

## Plan deviations

- Task 7.1's "`WorldHistory`/`Omega` with total `domain := fun _ => True` and universal `TaskRel`"
  — domain is total as specified; `TaskRel` is the weakest the frame axioms permit, because
  `nullity_identity` is an iff and forbids a universal relation.
- Task 7.1's "`Set.univ_shift_closed` as fallback" — not used, see correction 1.
- The Phase 6 handoff's "build the history's domain and states through `regionExtend` so
  `RegionConstant` holds by construction" — not done, see correction 2; the region code is carried
  in the state directly and region-constancy is proved for the base history only.

## What remains

O1 the valuation, O2 the gap policy (the remaining mathematical content), O3 a `sat_box_temporal`
saturation lemma; then 7.2 and 7.3. Stated precisely in `TruthLemma.lean` and in the plan's
PHASE 7 STATUS banner, and mirrored in `.orchestrator-handoff.json`.
