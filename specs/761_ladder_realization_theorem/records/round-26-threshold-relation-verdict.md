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

---

## 2. Phase 11.44 — the object-dependent threshold relation `Mrel` (outcome (c): NO VERDICT ON THE RELATION)

- **Phase**: 11.44, route (N-1), decision 19
- **Outcome**: **(c)** — neither a refutation on either fixture nor the first count move's path
  forth compiled within the round. The phase is marked `[PARTIAL]`.
- **Date**: 2026-11-16
- **Dispatch**: 78 (resuming dispatch 77, cut off mid-way by an API rate limit)

### The relation, stated in full

Landed in `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`, section
`Threshold`, token-for-token as Ruling 18 fixes it:

```lean
def Mrel (P a b : ℕ) (x y : LadderState Q pend) : Prop :=
  Srel P a b x y ∧
    (x.1.2.1 = y.1.2.1 ∨ ((P + 1) * (a + b) ≤ x.1.2.1 ∧ (P + 1) * (a + b) ≤ y.1.2.1))
```

with `Mrel.toSrel`, `Mrel.toZrel`, `Mrel.refl`, `Mrel.symm`, `Mrel.mono`. The countdown threshold
is `(P + 1) * (a + b)`: the margin is `P + 1` per unit of budget, where `Zrel`'s own margin is the
object-independent `2`. The threshold therefore depends on the object, through the modulus `(K1)`
constrains, which is what decision 19's obligation demands of it.

**Monotonicity carries in `Zrel.mono`'s own direction** (`a' ≤ a`, `b' ≤ b`). The asymmetry the
plan's task list anticipated — a threshold that grows with the budget might not shrink with it —
does not arise: `(P + 1) * (a' + b') ≤ (P + 1) * (a + b)`, so the raised threshold weakens exactly
as `Zrel`'s own thresholds do. This is a finding, recorded rather than assumed.

### Ruling 18's arithmetic, confirmed against the live fixture

`not_Mrel_xR_yR` (compiled): the pair that refutes `Srel` is **not** `Mrel`-related at any modulus
`(K1)` admits for `R4`. At budget `(a, b + 1)` the raised threshold is `(P + 1) * (a + b + 1)`
while that pair's shorter countdown is exactly `2 * (a + b) + 2`, and `3 ∣ P + 1` makes
`3 * (a + b + 1) ≤ 2 * (a + b) + 2` false for every `a` and `b`. Ruling 18's plan-level
computation is therefore correct as written, and `not_lnkRow_xR_yR` does **not** transfer. The
attack had to be re-aimed upward, as the plan said.

### Attack 1 — `R4`, aimed at the residue count, and at `LnkRow.first_zero`

**Pair attacked**: `xM P a b = (r0, (P+1)*(a+b+1), (P+1)*(a+b+1))` and
`yM P a b = (r0, (P+1)*(a+b+1) + (P+1), (P+1)*(a+b+1) + (P+1))` — both countdowns at or above the
raised threshold, exactly one modulus apart, registers equal to the countdowns so both gaps are
`0`. `Mrel_xM_yM` (compiled) confirms the pair is a legitimate target.

**Verdict: the attack does not break the relation, and the reason is compiled.**
`region_end_agrees_R4` (compiled): at this pair the necessary condition `LnkRow.region_end_obj`
is **satisfied** — the two regions, of lengths differing by exactly `P + 1`, end at ONE object
state, because `R4`'s forced walk has period `3` (`rotR_iterate_dvd_three`) and `(K1)` forces
`3 ∣ P + 1`.

`LnkRow.first_zero` likewise does not break here, and the reason is the raised threshold doing
precisely its designed work. The predecessor refutation turned on the shorter region being too
short to answer the longer region's residues: with countdown `2*(a+b)+2` only the positions
`t+1` and `t+2` could answer `t+3` on the countdown, and they carry `r1` and `r2`. At the
re-aimed pair the shorter region has at least `(P+1)*(a+b+1)` positions, so for every position
`r'` of the longer region the position `r' - (P+1)` of the shorter one answers it on the countdown
exactly, and for the first `P+1` positions a position congruent mod `3` answers it with both
countdowns above `2*(a+b)`. **The failing coordinate of round 25 — the residue at the intermediate
positions — is repaired by this relation.**

### Attack 2 — `B5`, aimed at the choice of walk, and at `LnkRow.region_end_obj`

**Non-vacuity**: Phase 11.43's `gB_isLadderPath` is the witness that `B5` carries an actual ladder
path, pending at every position `≤ 0`, whose object walk takes each branch in turn
(`gB_takes_both_branches`). The attack is not on an object nobody has walked.

**Verdict: the attack does not break the relation either, and it cannot.**
`region_end_matchable_B5` (compiled): for EVERY pending object walk of length `L` from `b0` there
is a pending object walk of length `L + (P + 1)` from `b0` ending at the same state, whenever
`2 ∣ P + 1` — which `(K1)` forces here, `2` being a pending cycle length of `B5`
(`two_mem_objCycleLens_B5`). The second walk spends the extra `P + 1` positions in the `2`-cycle
`b0 → b1 → b0` and then copies the first.

**The plan's expectation about this fixture cuts the other way, and that is this round's main
finding.** The plan reasoned that "a branch means the second path's walk is not determined by its
countdown, and raising a countdown threshold does nothing about a choice of walk." Both halves are
true, but they are an argument against a path forth being *forced*, not an argument for a
*refutation*. A refutation must show that **no** second path works; branching **enlarges** the
second path's option set, so it makes a refutation strictly harder, not easier. On the forced
cycles `C3` and `R4` the second walk is pinned by its countdown and can be caught carrying the
wrong object state — which is exactly how `not_lnkRow_xC_yC` and `not_lnkRow_xR_yR` worked. On
`B5` that lever is gone.

**The two attacks are reported separately above and are not merged**: attack 1 aimed at
`LnkRow.first_zero` on `R4` and found the residue count repaired; attack 2 aimed at
`LnkRow.region_end_obj` on `B5` and found the object coordinate satisfiable by construction.

### Why this is outcome (c) and not outcome (b)

Outcome (b) additionally requires the forward path forth for the LENGTHEN-A-REGION move at the
FIRST region to compile, with the register offset explicit in the statement. It did not, and the
round's kill criterion forbids extending. The goal state, written out:

The move must produce, from `IsLadderPath step pend h` and a state `y` with
`Mrel P a (b+1) (h t) y`, a path `h'` with `IsLadderPath step pend h'`, `h' t = y`, and
`LnkRow a (b+1) h h' t t`. Unfolding the last obligation one level against the live definition
(`LadderStepFrag.lean:640`) gives three conjuncts, and all three must hold simultaneously:

```
Zrel a (b+1) (h t) (h' t)
∧ (∀ b₀, b + 1 = b₀ + 1 → FwdJump (fun s s' => LnkRow a b₀ h h' s s') t t
                        ∧ FwdJump (fun s' s => LnkRow a b₀ h h' s s') t t)
∧ (∀ a₀, a = a₀ + 1 → BwdJump (fun s s' => LnkRow a₀ (b+1) h h' s s') t t
                    ∧ BwdJump (fun s' s => LnkRow a₀ (b+1) h h' s s') t t)
```

**Where it stalls, and on which coordinate.** The first conjunct is `Mrel.toZrel` and is free. The
other two are not reachable from the hypothesis: they quantify over EVERY position `s` of either
path and demand a `LnkRow` at the budget left — i.e. the whole-row correspondence recursively, at
every lower budget, in both directions. The only route is an induction on `a + b` whose invariant
is a state relation closed under both jumps, which is `exists_rowLinked_path` itself. **No scaffold
for that induction exists**: the module carries `LnkRow.refl`, `LnkRow.mono`,
`FwdJump.mono`/`BwdJump.mono` and `exists_rowLinked_path_zero` (the budget `(0,0)` case,
`:750`) and nothing that derives a `LnkRow` at a positive budget from a closure property. Building
it is the whole owed construction, not a step of it.

**The coordinate the round leaves unmeasured** is named in both the module's `Threshold` section
docstring and the probe's fourth section: what an INTERMEDIATE position of the longer region must
be answered ON, beyond its countdown and its object state. `Zrel` at the budget left also reads
the gap `n - c`, exactly inside a window of `2 (a + b) + 1` values, and neither `Mrel` nor either
obstruction lemma constrains the REGISTER at an intermediate position. Attack 1 settled the
countdown coordinate and attack 2 the object coordinate; the register coordinate is where both
attacks stop and where the path forth's second and third conjuncts would have to be argued.

### A `/revise` is owed

Outcome (c) does not license Phase 11.45, and this record is its input. Two concrete pointers for
that revision, neither taken here because designing a fourth relation inside this round is
prohibited:

1. The register coordinate above is the only one of the three that no round has measured at the
   `Mrel` pair. It is a measurement, not a new relation.
2. The `B5` finding generalises: a refutation of a path forth wants the second walk PINNED, so
   branching objects are the wrong fixtures for a refutation and the right ones for a proof
   attempt. Decision 19 made the branching fixture binding for the refutation attempt; that
   attempt is now discharged, and it reports that the fixture class cannot supply what was asked.

### What this round does NOT establish

It bears on the path forth and on nothing else. It says nothing about the clip (Ruling 16),
nothing about `ladderLift`, and it does not revive `cellAt_const_of_kappa_eq` or `ladderRealized`
under their pinned names — both remain unclaimed in `FormalSystem/` and `Tests/`. No refutation of
`Mrel` is claimed anywhere, and `Mrel` is **not** asserted to be correct: "no refutation was found
in this round" is the whole of the verdict on it.

### Correction carried forward from the interrupted dispatch

Dispatch 77 was cut off mid-way and left an uncommitted docstring in `LadderStepFrag.lean`
asserting a compiled refutation `no_rowLinked_path_of_Mrel` on a forced pending `3`-cycle at
`P + 1 = 3`, with a gap-class counting argument. **No such theorem existed, in the probe or
anywhere else** — the identifier `Mrel` occurred nowhere outside that one uncommitted hunk. The
verdict prose had been written before, and instead of, the compile. The `Mrel` definition and its
five structural lemmas from that hunk are kept, unchanged, because they match Ruling 18
token-for-token and they compile; the fabricated verdict paragraph is replaced by what is actually
compiled, and the claim it made is **withdrawn**: no refutation of the path forth from `Mrel` is
landed by this round, on `R4` or on any other object.

### Compiled declarations

In `FormalSystem/Metalogic/Decidability/RaySummary/LadderStepFrag.lean`:
`Mrel`, `Mrel.toSrel`, `Mrel.toZrel`, `Mrel.refl`, `Mrel.symm`, `Mrel.mono` — axiom-pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

In `specs/evidence/seam-gluing-ray-product/ladder-row-link-residue-obstruction.lean` (appended
only): `not_Mrel_xR_yR`, `xM`, `yM`, `Mrel_xM_yM`, `rotR_iterate_three`,
`rotR_iterate_dvd_three`, `region_end_agrees_R4`, `cyc2B`, `cyc2B_pend`, `cyc2B_step`,
`cyc2B_odd`, `spliceB`, `region_end_matchable_B5`. Four `#print axioms` guards, each
`[propext, Quot.sound]`.
