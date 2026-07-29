# The `boxAnchoredCheck` Consequence — a Handoff Finding for Task 165

Task 418 — Phase 5 artifact. Records what the removal of the six group-3 temporal-copy blocks
from `applyRule`'s `.boxNeg` and `.diamondPos` arms costs the verified bridge, so that task 165
inherits a measured, enumerated gap rather than an unexplained red row.

**Nothing in this document is a defect in the fix.** The blocks were unsound; removing them was
correct. What follows is the price, stated precisely.

**Nothing here is repaired by this task, and nothing here licenses reinstating the blocks**, in
narrowed form or otherwise.

---

## 1. Measurement — `boxAnchoredCheck` before and after

*(Section filled in from the Phase 5 scratch probe; see §1.3 for the raw run.)*

### 1.1 Before (Phase 2 baseline, `HEAD = 6c4dc2711`)

From `Tests/BimodalTest/BoxSpreadProbe.lean` rows A/B/C, green under `lake build BimodalTest`:

| Row | Formula | frame class | `spread` | `anchor` | `grid` | `\|W\|` | `\|T\|` |
|---|---|---|---|---|---|---|---|
| A | `(□p ∧ ◇q) → r` | `.Base` | `false` | **`true`** | `true` | 2 | 7 |
| B | `(□p ∧ ◇(G q)) → r` | `.Base` | `false` | **`true`** | `true` | 2 | 7 |
| C | `(□p ∧ ◇q) → r` | `.Dense` | `false` | **`true`** | `true` | 2 | 10 |

### 1.2 After (measured, this phase — not predicted)

Measured with a scratch `#eval` probe (`scratch_418_anchor.lean`, not committed) that reproduces
`BoxSpreadProbe.probe` verbatim against the post-fix engine:

| Row | Formula | frame class | `spread` | `anchor` | `grid` | `\|W\|` | `\|T\|` |
|---|---|---|---|---|---|---|---|
| A | `(□p ∧ ◇q) → r` | `.Base` | `false` | **`false`** | **`false`** | 2 | 7 |
| B | `(□p ∧ ◇(G q)) → r` | `.Base` | `false` | **`false`** | **`false`** | 2 | 7 |
| C | `(□p ∧ ◇q) → r` | `.Dense` | `false` | **`false`** | **`false`** | 2 | **8** |

### 1.2.1 Two results beyond what the plan predicted

1. **`boxGridCheck` also collapses to `false`.** The plan predicted only that `boxAnchoredCheck`
   would go false. The *grid* — `T(□φ)` puts `T(φ)` at every known label, which is the conclusion
   `sat_box_grid_of_anchored` produces and the thing `truthAt_box_iff_base` actually consumes —
   is `false` too, on all three rows. This is mechanically unsurprising in hindsight (`boxProps`
   places `T(p)` at the fresh world at the box formula's *own* time only, and without `T(Gp)`
   there, `allFuturePos` cannot spread it along that world's row) but it materially changes the
   handoff: the loss is not confined to a convenient intermediate invariant. **This closes off
   repair option (c) as it was formulated** — see §5(c).
2. **Row C's `|T|` moved, 10 → 8.** The `.Dense` branch now mints two fewer times. Fewer emitted
   formulas means fewer density obligations, so the saturated branch is genuinely smaller. This
   is a structural (bucket-d) change, not a verdict change: the row is still `OPEN`.

Rows A and B keep `|W|=2 |T|=7` exactly, so the deletion did not change the branch's world/time
skeleton at `.Base` — only its formula content.

### 1.3 Mechanism measurement — the minted world's contents

The same probe reports, on row A's open branch, what is actually present at the minted world
`w1` (`hasPosAt ob χ w` = "is `T(χ)` on the branch at world `w`"):

```
MECH: worlds=[0, 1] Gp@w0=true Gp@w1=false Hp@w1=false p@w1=true boxp@w1=false
```

Read directly:

| Fact | Value | Supplier |
|---|---|---|
| `T(Gp)` at the **original** world `w0` | `true` | `boxTemporal`, from `T(□p) @ w0` |
| `T(Gp)` at the **minted** world `w1` | **`false`** | nothing — this is the removed blocks' former job |
| `T(Hp)` at `w1` | **`false`** | likewise |
| `T(p)` at `w1` | `true` | `boxProps` — content only, at the box formula's own time |
| `T(□p)` at `w1` | **`false`** | nothing — `boxProps` strips the box |

This is the mechanism claim measured rather than argued: the minted world receives the box
formula's *content* and nothing else, so no `T(Gp)`/`T(Hp)` anchor exists there, and no `T(□p)`
sits there for `boxTemporal` to fire on.

### 1.4 Headline anchor row — `(G p) → □(G p)`

The `buildTableau` / `decide` verdict on the task's headline formula is a **Phase 6** measurement,
not a Phase 5 one; it is recorded in `after-verdicts.md` and in the task summary, not here. This
document is scoped to the `boxAnchoredCheck` consequence.

### 1.5 Isolation check at Phase 5 end

`git diff <phase-3-commit> -- FormalSystem/Metalogic/Decidability/Tableau.lean` is **empty**: the
engine edit is byte-identical to its Phase 3 state. No propagation block was added to compensate
for anything measured above.

---

## 2. Mechanism — can anything else put `T(Gφ)`/`T(Hφ)` at a freshly minted world?

The plan asserted, from a static read, that **no** rule other than the six deleted blocks can
place `T(Gφ)` or `T(Hφ)` at a freshly minted world. Checking each candidate route in
`FormalSystem/Metalogic/Decidability/Tableau.lean` against the current source:

| Route | Arm | What it actually emits | Can it put `T(Gφ)`/`T(Hφ)` at a fresh world? |
|---|---|---|---|
| `boxProps` in `.boxNeg`/`.diamondPos` | `Tableau.lean:552-558`, `577-584` | For each `T(□inner)` on the branch, `SignedFormula.pos inner {world := freshWorld, time := bsf.label.time}` — the **content only**, never the box formula | Only indirectly; see the refinement below |
| `.boxPos` | `Tableau.lean:539-545` | `SignedFormula.pos ψ {world := w, time := l.time}` for each **already-known** world `w` | No — content only, and `knownWorlds` at the time it fires |
| `.boxTemporal` | `Tableau.lean:611-616` | `T(Gψ)` and `T(Hψ)` **at the same label `l`**, triggered only by `T(□ψ)` at `l` | Only if a `T(□ψ)` is already sitting at the fresh world |
| `.allFuturePos` / `.allPastPos` | `Tableau.lean:619-625` and its past twin | `SignedFormula.pos ψ {world := l.world, time := t'}` — same world, other times; requires `T(Gψ)`/`T(Hψ)` **already present** | No — same world, and presupposes what is in question |
| `boxDiamondPersistence` | `Tableau.lean:432-441` | `{bsf with label := {bsf.label with time := freshTime}}` over `boxPosAtWorldTime`/`diamondNegAtWorldTime` — relabels the **time** only | No — within one world, across times |
| `.allFutureNeg` / `.allPastNeg` `gProps` | `Tableau.lean:634-…` | `{world := l.world, time := freshTime}` | No — same world |

### 2.1 Refinement — the plan's mechanism claim is *nearly* right, and the exception matters

**Refuted as stated; confirmed for the cases that matter.**

There *is* a second route, which the plan's static read missed: `boxProps` maps `T(□inner)` to
`T(inner)` at the fresh world. When `inner` is itself a box — `T(□□χ)` — that puts `T(□χ)` **at
the fresh world**, and `.boxTemporal` then fires there and yields `T(Gχ)` and `T(Hχ)` at the
fresh world. So for *nested* box formulas, `T(Gχ)` can still reach a minted world without the
deleted blocks.

Corroborating evidence, independent of this analysis: `Saturation.lean`'s MT4 row
(`□(□p) → G(□p)`) and MT6 (`□p → □(Gp)`) both still print `PASS` after the deletion — unchanged
from the Phase 2 baseline. The nested route is real and still functions.

This exception does **not** rescue `boxAnchoredCheck`. That check quantifies over *every*
`T(□inner)` in `b.boxPosFormulas` and demands, for every known world, some time carrying `T(inner)`,
`T(G inner)` and `T(H inner)` together. For an outermost `T(□p)` with `p` atomic — the shape rows
A/B/C exercise — the fresh world receives `T(p)` from `boxProps` but nothing supplies `T(Gp)` or
`T(Hp)` there, because `.boxTemporal` needs a `T(□p)` at that world and `boxProps` deliberately
strips the box. The check therefore fails on exactly the branches it used to pass on.

**Corrected mechanism statement**: the deleted blocks were the only route by which `T(Gφ)`/`T(Hφ)`
could reach a freshly minted world *for an outermost box formula* `T(□φ)`. For nested boxes the
`boxProps` + `boxTemporal` composition survives. `boxAnchoredCheck`'s failure is driven by the
outermost case, which is the universally-quantified one, so the check fails regardless.

---

## 3. Carrier list — every lemma taking `hBA : boxAnchoredCheck b = true`

Re-derived by `grep -rn "boxAnchoredCheck" FormalSystem/ Tests/` on the post-fix tree, not by
trusting the plan's line numbers. Every entry below was confirmed to still typecheck under the
green `lake build` at the end of Phase 4.

### 3.1 Definition and its immediate consumers — `Verified/Bridge/BoxSaturation.lean`

| Line | Declaration | Role |
|---|---|---|
| 501 | `def boxAnchoredCheck (b : Branch) : Bool` | the definition |
| 543 | `theorem boxAnchored_of_check {b} (h : boxAnchoredCheck b = true) : BoxAnchored b` | check → invariant |
| 599 | `theorem sat_box_grid_of_check (b) (timeOrd) … (hBA : boxAnchoredCheck b = true) …` | the shape the truth lemma consumes |

`theorem sat_box_grid_of_anchored` (same file, immediately above `sat_box_grid_of_check`) takes
the *Prop* `BoxAnchored b` rather than the `Bool` equation. It is the fourth carrier in substance
even though `grep` for `boxAnchoredCheck` does not name it, and it is where the loss actually
bites: `boxAnchored_of_check` is the bridge whose input has stopped being computable.

### 3.2 `Verified/Bridge/IntTruth.lean` — 6 carriers

| Line | Declaration |
|---|---|
| 351 | `theorem branchTruthAt_box` |
| 853 | `theorem branchTruthAt_untl` |
| 866 | `theorem branchTruthAt_snce` |
| 886 | `theorem branchTruthAt` — **the truth lemma itself** |
| 1030 | `theorem not_valid_of_hasOpen_int` |
| 1059 | `theorem not_validDiscrete_of_hasOpen_int` |

The plan listed line 366 as a seventh carrier. **Refuted**: line 366 in the current tree is not a
`boxAnchoredCheck` binder. The plan's seven-entry list for this file is six.

### 3.3 `Verified/Bridge/DenseTruth.lean` — 5 carriers

| Line | Declaration |
|---|---|
| 84 | `theorem branchTruthAt_of_temporal` |
| 582 | `theorem branchTruthAt_dense` |
| 613 | `theorem exists_countermodel_dense` |
| 654 | `theorem not_validDense_of_hasOpen` |
| 677 | `theorem not_validDedekindDense_of_hasOpen` |

All five predicted lines confirmed exactly.

### 3.4 Prose-only mentions (not carriers)

`Decidability.lean:72,85,87`; `IntTruth.lean:596`; `TemporalGate.lean:13,354`;
`TruthLemma.lean:362,381,399`; `RegionLabel.lean:95,249`; `Valuation.lean:94,555`;
`BoxSpreadProbe.lean:16,64`; `RegionGateProbe.lean:16`; `TemporalWitnessProbe.lean:73`.
These name the check in documentation or in a probe helper; none binds it as a hypothesis.

### 3.5 Carrier count

**14 carriers** (3 in `BoxSaturation.lean` + `sat_box_grid_of_anchored` as the substantive
fourth, 6 in `IntTruth.lean`, 5 in `DenseTruth.lean`) — the plan predicted 14 across three files
and the total happens to match, but the composition differs: the plan over-counted `IntTruth.lean`
by one (line 366) and did not count `sat_box_grid_of_anchored`.

---

## 4. What is precisely lost

**Nothing breaks at typecheck.** `lake build` is green (1983 jobs, RC 0) with the blocks removed
and with no repair to any of the 14 carriers. Every one of them takes `boxAnchoredCheck b = true`
(or `BoxAnchored b`) as a **hypothesis it never unfolds**, so removing the engine behavior that
made the hypothesis true cannot make any of them fail to elaborate.

What is lost is *dischargeability*. Before the fix, a caller holding a concrete open branch from
a real `buildTableau` run could discharge `hBA` by computation — `decide`, or `rfl` on the `Bool`
equation — because `boxAnchoredCheck` evaluated to `true` on that branch. After the fix it
evaluates to `false` on multi-world branches, so:

> `sat_box_grid_of_check`'s second side condition is no longer establishable on real engine
> output, and therefore the truth lemma's `box` case (`branchTruthAt_box`, `IntTruth.lean:351`)
> loses a side condition it could previously supply for itself.

Concretely, the chain `not_valid_of_hasOpen_int` → `branchTruthAt` → `branchTruthAt_box` →
`sat_box_grid_of_check` → `boxAnchored_of_check` still exists as a chain of true implications; it
simply no longer has a computable way to feed its first premise on branches with more than one
world. Single-world branches are unaffected (`boxAnchoredCheck` quantifies over `knownWorlds`, so
with one world the anchor is the box formula's own label and `boxProps`/`boxTemporal` at that
world supply it).

**And the chain's *output* is gone too, not just its input.** §1.2 measures `boxGridCheck = false`
on the same branches. So it is not the case that the grid conclusion survives by some other route
and only the anchor lemma has become unusable: on a real multi-world branch, `T(□φ)` genuinely
does *not* reach every known label any more. `sat_box_grid_of_anchored` is still a true theorem —
`BoxAnchored b` really does imply the grid — but on post-fix engine output both its hypothesis and
its conclusion are false, which is consistent and is exactly why nothing breaks at typecheck. The
open question this hands to task 165 is not "how do we discharge `hBA`" but "what does the `box`
case of the truth lemma get to assume about a minted world at all".

---

## 5. Repair options — *for task 165 to choose*, not performed here

Each is a design change to the engine's saturation strategy or to the bridge, with its own
soundness obligation. None is implemented by this task, deliberately: choosing one re-opens the
question this task exists to close, and it belongs with whoever owns the truth lemma.

### (a) Propagate `T(□φ)` itself to the fresh world

Add to `boxProps` (or beside it) an emission of `SignedFormula.pos (.box inner) {world := freshWorld, …}`
alongside the existing `T(inner)`. `.boxTemporal` then fires at the fresh world and supplies
`T(Gφ)`/`T(Hφ)` there — restoring the anchor by a route that is *derived* rather than copied.

**What must be proved**: that `T(□φ)` at `(w,t)` entails `T(□φ)` at `(w', t)` for the minted `w'`.
This is S5's own axiom 4/5 pattern (`□φ → □□φ`), so it is very likely sound — but it must be
discharged as a `RuleSound` obligation, not asserted, and it changes branch size (every box
formula now spreads to every world as a *formula*, not just as content), which has termination
and fuel consequences the subformula-property and `Fuel.lean` bounds must absorb.

**Note**: this is exactly the `BoxContextClosed` invariant that `TruthLemma.lean`'s O3 note
records as *refuted in tree* — refuted as a description of what the engine did, not as a
soundness claim. Reinstating it as a deliberate engine change is a different proposition from
asserting the engine already maintains it, and the distinction is worth keeping straight.

### (b) Copy `T(Gφ)`/`T(Hφ)` to the fresh world only when box-derived

Track provenance: emit the temporal copy only for those `T(Gφ)`/`T(Hφ)` that `.boxTemporal`
produced from some `T(□φ)`, never for temporal formulas that arrived on the branch some other way.

**What must be proved**: that the provenance predicate is decidable on a branch (the branch is a
flat `List SignedFormula` with no derivation history, so provenance is not currently recoverable —
this option requires a data-structure change), and that `T(□φ)` at `(w,t)` justifies `T(Gφ)` at
`(w',t)`. The latter follows from `boxToFuture` composed with option (a)'s obligation, which
suggests (a) is the cheaper route to the same guarantee.

### (c) Restructure the `box` case so it needs no anchor

Weaken `BoxAnchored`, or change `branchTruthAt_box` to derive `T(φ)` at every known label of `w'`
without routing through a per-world anchor time.

**What must be proved**: some replacement invariant that the post-fix engine *does* satisfy.

**Measured status: this option is closed as formulated.** The natural version of it was "prove
the grid directly, bypassing the anchor" — attractive because `boxGridCheck`, not
`boxAnchoredCheck`, is what `truthAt_box_iff_base` actually consumes. §1.2 measures
`boxGridCheck = false` on all three probe rows post-fix. The grid is not a weaker thing that
survives; it fails for the same reason the anchor does. Any repair in this family must therefore
weaken what the `box` case demands of the branch — not merely re-route to a different existing
check — and must then re-establish `truthAt_box_iff_base` from the weaker thing. That is a
substantially larger piece of work than options (a) or (b), and it is the reason those two, which
restore an engine-side supply, look like the better-value routes despite carrying their own
soundness obligations.

---

## 6. Corpus-side evidence — the gap is wider than `boxAnchoredCheck`

Appended from the Phase 6 corpus measurement (`after-verdicts.md`). **This is the single most
important addition to this document, and it was not anticipated by the plan.**

`boxAnchoredCheck` is not the only decidable branch gate that collapses. The corpus measurement
shows the *whole family* of decidable branch gates going `true → false` on multi-world branches,
and always on the same formulas — the ones that mint a world:

| Gate | Where | Probe row that measures it | Before | After |
|---|---|---|---|---|
| `boxAnchoredCheck` | `Bridge/BoxSaturation.lean:501` | `BoxSpreadProbe` A/B/C | `true` | **`false`** |
| `boxGridCheck` | `Bridge/BoxSaturation.lean` | `BoxSpreadProbe` A/B/C | `true` | **`false`** |
| `regionGate` | `Bridge/RegionLabel.lean` | `RegionGateProbe` A, B, H | `true` | **`false`** |
| `regionLabelCheck` | `Bridge/RegionLabel.lean` | `RegionGateProbe` A, B, H; `RayRegionProbe` D; `TemporalWitnessProbe` row D ×6 | `true` | **`false`** |
| `rayUpOk` / `rayDnOk` | `RayRegionProbe` helpers over `Bridge/RegionLabel.lean` | `RayRegionProbe` D | `true` | **`false`** |

The candidate-label grids make the cause explicit. `RegionGateProbe` row A moves from
`cands=[[3,3,3,3,3,3,3,3], [3,3,3,3,3,3,3,3]]` to
`cands=[[3,3,3,3,3,3,3,3], [0,0,0,0,0,0,0,0]]`: world 0's regions are untouched, and **world 1 —
the minted world — drops from three eligible labels per region to zero**. `RayRegionProbe` row D
moves `rays=[(2, 2), (5, 5)]` to `rays=[(2, 2), (0, 0)]` — same story, the second world's ray
loses its witness. Every moved gate is a gate quantifying over the minted world, and every
unmoved one is single-world.

**What this means for task 165.** The inherited open item is not "re-establish
`boxAnchoredCheck`". It is: *a freshly minted `□`/`◇`-witness world now carries only the witness
plus modal-universal content, and every branch-level gate that expected temporal content there
fails.* Repair options (a) and (b) in §5 would restore the temporal content and so would likely
restore this whole family at once, which is a point in their favour that §5's per-gate framing
understates. Option (c) — weaken what the bridge demands — would have to be applied gate by gate
across at least `BoxSaturation.lean` and `RegionLabel.lean`, not just to the `box` case.

**And a matching point in the fix's favour.** Every one of these gates was previously computing
`true` *because of* the unsound copies. A `true` that rests on an unsound premise is not evidence
the branch has the property; it is the defect propagating into the verification layer. The
corpus was measuring the bug and reporting it as health. That is the strongest available argument
that these rows moved for the right reason.

---

## 7. Phase 7 addendum — the corpus now pins the gap rather than the bug

The moved rows enumerated in §6 have been realigned to their measured values, so the gap this
document describes is now **pinned by the test corpus** instead of being a prose claim. Concretely,
task 165 inherits a corpus that asserts, and will keep asserting:

| Where | What is now pinned |
|---|---|
| `BoxSpreadProbe.lean` rows A, B, C | `anchor=false grid=false` on every two-world branch |
| `RegionGateProbe.lean` rows A, B, H | the minted world's candidate vector is all-zero — no eligible region label at any rank |
| `RegionGateProbe.lean` row C | the `.Dense` exception: count falls `3 → 1`, not to `0`, so `gate`/`check` survive |
| `RayRegionProbe.lean` row D | the minted world's ray is `(0, 0)` |
| `TemporalWitnessProbe.lean` row D ×6 | `regionLabelCheck=false`, and the ray self-demands with it |
| `BoxNegPreservationProbe.lean` rows 1, 3, 4 | `.boxNeg` emits the witness alone and manufactures no opposite-sign pair |

**This changes the shape of the inherited obligation in a useful way.** Any repair option from §5
that restores temporal content at the minted world — (a) or (b) — will move this whole family of
rows back, in one commit, and the corpus will say so row by row. Option (c), weakening what the
bridge demands, will leave them false and must instead justify each one. The corpus is now a
decision instrument for that choice rather than a casualty of it.

### The `boxAnchoredCheck` gate is *not* the only thing lost, and the corpus now shows the width

`regionLabelCheck` (`RegionLabel.lean`) and the two ray self-demands moved alongside
`boxAnchoredCheck`/`boxGridCheck`. All four are branch-level gates quantifying over the minted
world, and all four failed for the same single reason: the minted world receives the box
formula's `T(φ)` from `boxProps` and nothing else — no `T(Gφ)`, no `T(Hφ)`. A repair aimed only
at `BoxAnchored` would leave the region-label and ray families still false.

### One new corpus row was added, and it pins what is still owed

`CrossWorldPropagationProbe.lean` row F pins the `decide` **constructor** on `(G p) → □(G p)`:

```
(isValid, isInvalid, isFuelExhausted, isExtractionFailed, isUndecided)
  = (false, false, true, false, true)
```

Pre-fix this was `(false, false, false, true, false)` — `extractionFailed`, which by R7 semantics
asserts the formula is valid. It is not. The five pre-existing rows in that file all call
`isValid`, which collapses `.invalid`, `.fuelExhausted` and `.extractionFailed` to a single
`false`, so none of them could see this move; row B in particular passed green across the entire
fix without moving. Row F exists so that the outcome still owed — `.invalid` with an extracted
countermodel — cannot land, or fail to land, unnoticed.
