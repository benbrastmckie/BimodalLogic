# Continuation handoff (plan v4) — end of orchestration cycle

**Plan**: `plans/04_ordtimesknown-strengthening-totality.md`
**Baseline for this dispatch**: `d497179c4`. **Head**: `f6c27f190`.

## What this cycle closed

**The `OrdTimesKnown` repair is landed in full.** Phases 4, 4.1, 4.2, 4.3 all `[COMPLETED]`, each
green on its **first** build attempt. Phase 8 is `[IN PROGRESS]` with its first two tasks landed.

| Phase | Marker | Commit |
|---|---|---|
| 4.1 transcription (18 decls) | `[COMPLETED]` | `4195ad325` |
| 4.2 branching + engine level | `[COMPLETED]` | `ecac0e120` |
| 4.3 ordered split + `RunInvariant` | `[COMPLETED]` | `869fef2dc` |
| 4 (goal now met) | `[COMPLETED]` | (in `869fef2dc`) |
| 8, tasks 1-2 only | `[IN PROGRESS]` | `f6c27f190` |

**R8 did not bite.** `applyRule_ordTimesKnown_branching` closed on the first attempt under exactly
the substitutions the plan specified. Its `[BLOCKED]` clause was never triggered.

## Exact resume point: Phase 8, task 3

Tasks 1-2 landed: `contains_mono`, `knownWorlds_mono`, `witnessPresent_branch_mono`,
`witnessPresent_ord_mono` (all `[propext, Quot.sound]`).

Tasks 3-4 NOT started. **Task 3 has an unstated prerequisite the plan does not name**: combining
the two monotonicity lemmas into `expandOnceUnblocked_preserves_witness` needs an engine-level
**ordering-growth** lemma

```
∀ p ∈ ord.constraints, p ∈ (expandOnceUnblocked b ord fc tr).2.constraints
```

for the non-arm-3 shapes, i.e. the ordering half of the phase's Scope Hypothesis (a). Nothing like
it is landed. It will need an `applyRule` case analysis in the shape of
`applyRule_ordTimesKnown_nonbranching`, plus `TimeOrdering.addFuture_constraints_mono`
(`Fuel.lean:1077`) and an `addPast` mirror. Branch growth is already available:
`expandOnceUnblocked_split_subset` (`Fuel.lean:1711`) and the `fs ++ b` shape for `.extended`.

Then the four shapes assemble as the plan describes, with arm 3 from the landed
`arm3_preserves_witness` (`:716`) and its `IrreflOrd` drawn from `RunInvariant.irreflOrd`.

## Scope Hypothesis findings (recorded, per the plan)

- **Phase 8 (b) CONFIRMED**: `witnessPresent` (`Tableau.lean:1838`) has eight real arms plus a
  `_ => false` default. Every real arm is a `knownWorlds`/`futureOf`/`pastOf` `any` search whose
  body is a positive combination of `Branch.contains` tests joined by `||`/`&&`. **No negation
  anywhere — no anti-monotone clause.** The material finding the plan asked to watch for does not
  occur.
- **Phase 8 (a) NOT yet confirmed** — it is the prerequisite above.
- **Phase 4.3 CONFIRMED**: `expandOnceUnblocked_splitOrdered_shape` (`:788`) gives exactly three
  arms, `[(b, ord.addFuture t₁ t₂), (b, ord.addFuture t₂ t₁), (b.identifyTime t₂ t₁, ord.identifyTime t₂ t₁)]`.
  No fourth arm. `firstIncomparablePair_spec` supplies both membership facts directly.
- **Phase 4.2 CONFIRMED**: `pick_stage_source`, `pick_ord_eq`, `pick_branches_eq` are all
  invariant-agnostic and were reused unchanged.

## Build-time findings (R6 / R8)

Whole-module `lake build` of `MintBound`, measured this cycle:

| After | wall | user |
|---|---|---|
| Phase 4.1 | 31s | 2m20s |
| Phase 4.2 | 36s | 3m01s |
| Phase 4.3 | 36s | 2m57s |
| Phase 8 tasks 1-2 | **120s** | **5m10s** |

The strong `.branching` analogue cost about what the weak twin did — R8's elaboration worry did
not materialise. **The Phase 8 monotonicity lemmas are the expensive ones**: they roughly tripled
wall time. `witnessPresent_ord_mono` required the module's standing `maxHeartbeats 4000000`;
**the figure was never raised above it.** A successor adding more 36×2 case splits should expect
the module build to keep growing and should measure rather than assume.

## Gotchas for the successor

- `TimeOrdering.futureOf_mono` / `TimeOrdering.pastOf_mono` (`Fuel.lean:914`, `:927`) are in the
  `TimeOrdering` namespace and **must be qualified** — bare names do not resolve from
  `MintBound`.
- A `set_option … in` must come **before** the docstring, not between docstring and `theorem`.
- `simp only […] <;>` inside a `cases rule <;> cases sign` chain fails with "simp made no
  progress" on the `_ => false` default arms. Wrap it: `(try simp only […])`.
- `exact fun h => Bool.noConfusion h` is the clean discharge for those default arms — it fails
  fast on real arms, so it is safe as the first `first` alternative (unlike `simp`, which can
  succeed without closing and wrongly commit).
- `mem_knownTimes_of_mem` also exists in `BoxSaturation.lean:261`, but in namespace
  `…Decidability.Verified.Bridge` and off `MintBound`'s import path — no clash.

## Constraint status (verified this cycle)

- `Saturation.lean` `ae47004e06e77f2846cc3e1dfa408382`, `Tableau.lean`
  `cfd82332c8e400ac97ab709ece5dfb4a`, `Fuel.lean` `8a395bd7117a682c1f8302a2ac5f0f1f` — **all
  three match the plan's recorded baselines exactly.**
- Diff vs `d497179c4`: **573 insertions, 0 deletions**, one file. Purely additive; no landed
  declaration edited, renamed, or deleted. All four weak-invariant producers plus
  `applyRule_irreflOrd`, `expandOnceUnblocked_ordTimes`, `expandOnceUnblocked_irreflOrd` confirmed
  still present.
- 0 `sorry`, 0 `axiom`, 0 `NoSplit`, 0 vacuous placeholders, 0 task-number citations in
  `MintBound.lean`.
- `lake build` (full repo, 2333 jobs) green.
- Pre-existing, NOT from this task: 71 `task N` citations elsewhere under `FormalSystem/`
  (identical count at the dispatch baseline). Outside this plan's scope.

## Still ahead — unchanged risk posture

- **Phase 10 is the plan's single genuinely new bet (R2)** and remains untouched. Its first task
  is a read-and-confirm on R3 (`Tmax` must come independently from T2's
  `timeFinset_card_le_of_not_blocked`, `Fuel.lean:588`, **not** from the mint chain). Settle the
  arm-3 injection question — `rhoSF` is **not injective on `U`** — *before* writing any induction.
- **Phase 9's `WorldWitness` discharge (R4)** still never attempted. Named fallback exists; never
  an axiom.
- Phase 13's `.splitOrdered` arm is now unblocked in principle: the IH that could not be
  re-established at arm 3 under the weak invariant is exactly
  `expandOnceUnblocked_splitOrdered_ordTimesKnown`.

## Deviations

None. Every phase followed the plan's task sequence exactly; no substitutions, no narrowing, no
escalations needed.
