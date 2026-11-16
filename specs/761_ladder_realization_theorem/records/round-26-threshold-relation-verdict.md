# Round 26 — the object-dependent threshold relation: verdict record

Route (N-1) of decision 19. Plan: `plans/26_object-dependent-threshold-refutation-first.md`.
Wired probe: `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean`
(gate entry `scripts/check-evidence-probes.sh:3057`).

## 1. Phase 11.43 — the branching-pending fixture `B5` (outcome (a): THE FIXTURE LANDS)

This section records an object and nothing else. **No relation is stated here and no refutation
or path forth is attempted** (Ruling 19); both are Phase 11.44's.

### Entry re-derivation (against the live probe, not the plan)

- Probe length at entry: 568 lines — matches the plan's figure. No drift.
- `R4` block line numbers at entry: `Fintype R4` `:352`, `stepR` `:354`, `pendR` `:364`, `rotR`
  `:369`, `stepR_pend` `:375`, `three_mem_objCycleLens_R4` `:380`, `fwdR` `:400`, `bwdR` `:434`,
  `objAt_rot` `:453` — all nine match the plan. No drift.
- Gate wiring: `scripts/check-evidence-probes.sh:3057` lists
  `seam-gluing-ray-product/ladder-row-link-residue-obstruction` — matches.
- `objCycleLens` (`RaySummary/CounterQuotient.lean:525`): `l ∈ objCycleLens step pend` iff
  `0 < l ∧ l ≤ Fintype.card Q ∧ ∃ f : ℕ → Q, (∀ i, step (f i) (f (i+1)) = true) ∧
  (∀ i, pend (f i) = true) ∧ f l = f 0`. Both new memberships are stated and proved in that shape,
  as `two_mem_objCycleLens_C3` and `three_mem_objCycleLens_R4` are.
- One structural note, not a drift: the `R4` block sits inside a `namespace ProbeRowResidue` that
  closes at `:564`, followed by the headline's `#print axioms` pin. "Appended after the `R4`
  block" is therefore realized as a NEW `namespace ProbeRowResidue … end ProbeRowResidue` section
  appended at end of file (the file already re-opens its namespace once, at `:279`). No landed
  line was edited: `git diff` on the probe is 259 insertions, 0 deletions.

### The fixture as built (probe lines 569-827)

| Item | Declaration | Statement |
|---|---|---|
| object | `B5` | five states `b0 b1 b2 b3 idle`, `DecidableEq` derived, explicit `Fintype` |
| step | `stepB` | `b0→b1`, `b0→b2`, `b1→b0`, `b2→b3`, `b3→b0`; every pending state `→ idle`; `idle→idle` |
| pending | `pendB` | `b0`-`b3` pending, `idle` not |
| THE BRANCH | `branching_pendB` | `pendB b0 = true ∧ stepB b0 b1 = true ∧ stepB b0 b2 = true ∧ b1 ≠ b2 ∧ pendB b1 = true ∧ pendB b2 = true` |
| 2-cycle | `two_mem_objCycleLens_B5` | `2 ∈ objCycleLens stepB pendB` (walk `b0 → b1 → b0`) |
| 3-cycle | `three_mem_objCycleLens_B5` | `3 ∈ objCycleLens stepB pendB` (walk `b0 → b2 → b3 → b0`, helper `cyc3B`) |
| seriality | `fwdB`, `bwdB` | `∀ t x, ∃ y, RladAdm stepB pendB t x y` and `∀ t x, ∃ y, RladAdm stepB pendB (t-1) y x` |
| NON-VACUITY | `gB`, `gB_isLadderPath` | `IsLadderPath stepB pendB gB`, all positions `u : ℤ` |
| the witness walks the branch | `gB_takes_both_branches` | `objAt gB (-5) = b0 ∧ objAt gB (-4) = b1 ∧ objAt gB (-3) = b0 ∧ objAt gB (-2) = b2` |
| the witness is not idle | `cntAt_gB_neg` | `cntAt gB (-k) = k` for every `k : ℕ` |

The object has exactly five states, as the Scope Hypothesis estimated; the ladder conditions do
not make the branch unreachable (`gB_takes_both_branches`). The estimate held.

### The non-vacuity witness

`gB u`, for `u ≤ 0`, is the state `(walkB (u % 5), -u, 0)`: pending, countdown `-u`, register `0`,
the object walking with period `5` along `b0 → b1 → b0 → b2 → b3 → b0` — the `2`-cycle then the
`3`-cycle, so the path leaves `b0` by EACH branch infinitely often. At `u = 0` the countdown is
`0` at `b0` and the region ends into the idle sink; for `u > 0` it is `(idle, 0, 0)`.
`gB_isLadderPath` is proved at every `u : ℤ` (three cases: both pending, the region end `u = 0`,
both idle), not at one index. Two additions beyond the plan's five items, both in service of
item 5 and neither a relation: `gB_takes_both_branches` and `cntAt_gB_neg`, so that "a ladder
path exists" cannot be read as "the idle path exists".

A measured property of the fixture Phase 11.44 should hold in view: `stepB idle q` is true only
at `q = idle` (the shape `C3` and `R4` also have), so a pending region over `B5` is never entered
from an idle state — every pending position of a ladder path has an all-pending past with the
countdown growing by one per step backwards. `gB` has exactly that shape.

### The `(K1)` constraint this object carries (RECORDED, not imposed)

By `two_mem_objCycleLens_B5` and `three_mem_objCycleLens_B5`, a modulus `P + 1` that `(K1)` admits
for `B5` satisfies `2 ∣ P + 1` and `3 ∣ P + 1`, hence `6 ∣ P + 1`. This is a hypothesis any
refutation stated over `B5` must carry (as `not_Srel_xC_yC` carries `2 ∣ P + 1`); the divisibility
`6 ∣ P + 1` itself is NOT compiled as a lemma here, and no parameter condition (`paramsOkK1`,
`paramsOkK4`, `Tc`, `Tn`) was touched.

### Which obstruction lemma the fixture is aimed at

`LnkRow.region_end_obj`. On `C3` and `R4` the object walk inside a pending region is forced
(`objAt_flip`, `objAt_rot`), so a countdown congruence determines where the second path's region
ends. On `B5` it does not: from `b0` the walk chooses between a cycle of length `2` and one of
length `3`, so the second path's walk is not a function of its countdown and a congruence modulo
`P + 1` supplies no walk. Whether that freedom helps the path forth (the second path may CHOOSE a
walk ending at the right object) or defeats it is exactly what Phase 11.44 measures; this phase
does not say.

### Axioms (pinned in the probe by `#guard_msgs`)

- `branching_pendB`, `fwdB`, `bwdB`, `gB_takes_both_branches`: `[propext]`
- `two_mem_objCycleLens_B5`, `three_mem_objCycleLens_B5`, `gB_isLadderPath`:
  `[propext, Classical.choice, Quot.sound]`

No `sorry`, no `axiom`, no `native_decide`, no vacuous definition.

### Verification (Phase 11.43)

- `lake env lean` on the probe: exit 0, no output (every `#guard_msgs` pin matches).
- Full `lake build` through `lake-build-guard.sh`: guard exit 0, "Build completed successfully
  (2976 jobs)", zero `error:` lines. No library module was edited, so no `.olean` freshness check
  applies.
- `bash scripts/check-evidence-probes.sh`: exit 0, "PASS all 65 wired probe(s) compile" — the
  total Phase 11.41's summary recorded (65), unchanged; the probe's own row reads PASS.
- `bash .claude/scripts/verify-deploy.sh`: exit 0, "PASS -- 15 check(s), 0 failure(s)".
- `git diff` on the probe: 259 insertions, 0 deletions (APPEND ONLY held).
- Placeholder scan of the probe: no hit outside the header-docstring sentence and the
  `#print axioms` pins.

**Phase 11.44 is licensed**: it attacks `R4` and `B5`, and states its `B5` refutation under the
hypothesis `6 ∣ P + 1` (or the two divisibilities separately).
