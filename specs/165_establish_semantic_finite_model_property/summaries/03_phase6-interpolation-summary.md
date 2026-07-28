# Phase 6 — Interpolation, the Mathematical Core (WP4 stage 3)

**Status:** COMPLETE, sorry-free, both builds green. One dispatch (plan estimated three).
**Territory:** `FormalSystem/Metalogic/Decidability/Verified/Bridge/Interpolate.lean` (new), plus
the aggregator import in `FormalSystem/Metalogic/Decidability.lean`.

## What landed

All three sub-tasks (6.1, 6.2, 6.3), including the assembled induction the plan deferred past 6.3.

| Sub-task | Content | Status |
|---|---|---|
| 6.1 | Region structure, `regionExtend` (total on `D`), `atom`/`bot`/`imp`/`box` invariance | Complete |
| 6.2 | `someFuture`/`somePast`/`allFuture`/`allPast` invariance | Complete |
| 6.3 | `untl`/`snce` invariance and `interpInvariant`, the full induction | Complete |

`interpInvariant` verifies on `propext`, `Classical.choice`, `Quot.sound` only. No `sorry`, no
vacuous definitions, no new axioms.

## The correction the plan text needed

The plan specifies a model constant on **half-open** intervals `[d_i, d_{i+1})`. That partition is
wrong, and the failure is measured rather than suspected:

> `D = ℚ`, placed points `{0, 1}`, model constant on half-open regions, atom `p` true exactly on
> `[0, 1)`. Then `somePast p` is **false** at `0` (nothing below `0` satisfies `p`) and **true** at
> `1/2` (witness `1/4`) — yet `0` and `1/2` are half-open region-mates. Invariance fails.

A half-open region is closed on the left, so its least element has no region-mate below it, and
every past-directed operator separates that element from its own region. Reversing the orientation
to `(d_i, d_{i+1}]` moves the same failure onto the future-directed operators. No orientation of a
half-open partition works.

The landed partition treats each placed point as its own region and each gap as an open region:

```
SameRegion f r r' := ∀ i, (f i < r ↔ f i < r') ∧ (r < f i ↔ r' < f i)
```

"`r` and `r'` stand in the same order relation to every placed point". The regions are the
singletons `{d_i}` together with the open gaps `(d_i, d_{i+1})` and the two open rays. Singleton
regions are invariant trivially; open regions have members on both sides of any member, which is
exactly what the temporal cases need.

## Density is load-bearing; `.Discrete ℤ` is a proved obstruction

The step "an open region has a member strictly above (below) any of its members" is **false on
`ℤ`**: with placed points `{0, 2}` the gap `(0, 2)` is the singleton `{1}`. This is on record as a
theorem, `not_exists_gt_sameRegion_int`, not as a remark.

So `interpInvariant` and every temporal case carry `[DenselyOrdered D] [NoMaxOrder D]
[NoMinOrder D]`. `.Base ℚ`, `.Dense ℚ` and `.Dedekind ℝ` satisfy all three (checked by
`inferInstance` in the file). **`.Discrete ℤ` is not covered** and needs a separate route in Phase
7. This is the one genuinely open item Phase 6 creates, and it is a fact about the mathematics, not
a gap in the proofs.

## What the temporal cases did *not* need

The plan anticipated them consuming the branch saturation (`sat_*`) family and the trichotomy-
certified guard fact. They consume neither. `InterpInvariant` is a statement about the constructed
model, so it follows from the region structure and carrier density alone; the branch's saturation
facts are consumed one level up, by Phase 7's truth lemma, which is where model values get tied to
what the branch asserts. The lemma statements are the ones the plan specifies — only their
hypothesis lists are shorter.

## Verification

- `lake build FormalSystem.Metalogic.Decidability` — green, 1105 jobs
- `lake build BimodalTest` — green, 1955 jobs
- `grep sorry` on the new file — 0
- vacuous-definition scan on `Verified/Bridge/` — 0
- `^axiom ` count across `FormalSystem/` — unchanged (2, both in `Boneyard/`, both in prose)
- `lean_verify` on `interpInvariant` — `propext`, `Classical.choice`, `Quot.sound`

Full `lake build` still fails at `BXCanonical/Chronicle/CounterexampleElimination.lean`, which is
pre-existing and outside this phase's territory. No engine file was touched.

## Interface for Phase 7

`interpInvariant (hRC : ∀ τ ∈ Om, RegionConstant f τ) (χ : Formula) : InterpInvariant f M Om χ`.

Phase 7's `WorldHistory`/`Omega` construction must discharge `RegionConstant f τ` for every
`τ ∈ Om` — building the history's domain and states through `regionExtend` makes both
`domain_congr` and `states_congr` hold by construction. `exists_region_placement` supplies the
placement, preserving the explicit `(BranchOrder b ord h).le` shape that `Carrier.lean` fixed.
