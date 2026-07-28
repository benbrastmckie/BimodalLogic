# Phase 4 (4.3d residuals 1-2): `OrderDual` discharged, and the world dimension bounded

**Task:** 165 — establish semantic finite model property
**Phase:** 4 — Termination (WP3: T1, T2, T3), sub-phase 4.3d
**Status:** Phase 4 remains `[PARTIAL]` — residuals 1 and 2 done, residual 3 (branching arms) and
4.2d (general `closureStep` termination) outstanding.
**Territory:** `FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean` only. No engine
edit; the wave-3 territory contract is intact.

## What landed

Three green commits, all sorry-free:

| Commit | Content |
|---|---|
| `a5e0354cb` | `OrderDual` discharged via `open private` + BFS path characterisation |
| `c5d9191d5` | The world dimension: `WorldWitness`, `worldFinset_card_le`, `chain_le_worlds_bounded` |
| `a9c80fa95` | Doc note recording that `chain_le_soundFuel'`'s `hL` is undischargeable once `W > 1` |

### Residual 1 — `OrderDual` is now a theorem

`orderDual_holds : ∀ ord, OrderDual ord`. The two consumers,
`timeChain_of_linearity_saturated` and `chain_le_worlds_of_linearity_saturated`, both drop their
`hd` parameter.

The route was the one the prior dispatch recorded, and it worked unchanged:
`open private reachableForward reachableBackward from …SignedFormula`. Pure consumption — no
engine edit, no re-proof. (`open` cannot take a docstring; the accompanying prose has to be a
plain `/- -/` comment.)

The shared breadth-first shape of `futureOf`/`pastOf` is factored out as `bfsClosure` and proved
equal to both private helpers, then characterised by paths:

- `PathN f n a b` — a path of exactly `n` edges in a successor function.
- `bfsClosure_sound` — membership yields a path of `1..fuel` edges. **The `1 ≤ n` lower bound is
  load-bearing**: without it, membership could be witnessed by the empty path, which says nothing,
  and the duality would not follow.
- `PathN.snoc` / `PathN.reverse` — reversal against a converse relation, which needs `snoc`
  because `PathN` peels edges from the source and reversal must attach them at the target.
- `mem_directFutureOf_iff` — the two one-step relations are converses (both say
  `(x, y) ∈ ord.constraints`).

**The prior dispatch's prediction was correct: completeness was the hard half.** It is outright
*false* as naively stated — a BFS whose `visited` contains a node it never expanded misses
everything downstream of that node. What rules this out is `BfsInv` (every visited node is either
still on the frontier or has had all successors recorded), which holds at the `[]` seed and is
preserved by a layer step. Completeness is then a **joint** induction over the frontier and
visited statements: the visited statement at length `m+1` needs the frontier statement at the
*same* length, so neither is provable alone.

Both closures run at the same default fuel (`100`), so the path length soundness bounds is exactly
the one completeness can spend. `orderDual_holds` needs only `propext` and `Quot.sound` — not even
`Classical.choice`.

### Residual 2 — the world dimension

**Why worlds are bounded at all.** Exactly two rules mint fresh worlds, `boxNeg` (on `F(□ψ)`) and
`diamondPos` (on `T(◇ψ)`); every other `ruleMintsFreshLabel` constructor mints a fresh *time*.
Neither modal rule carries an internal guard — `applyRule`'s `boxNeg` arm returns
`.linear (witness :: …)` unconditionally — so what stops them re-firing is `findApplicableRule`,
which gates every fresh-label rule behind `witnessPresent`. The **shape** of that gate is the
entire argument:

```
-- modal (boxNeg): quantified over EVERY known world
branch.knownWorlds.any fun w => branch.contains (.neg ψ { world := w, time := l.time })

-- temporal (allFutureNeg): world HELD FIXED, quantified over times
(timeOrd.futureOf l.time).any fun t => branch.contains (.neg ψ { world := l.world, time := t })
```

The modal guard is **world-indifferent**. Once any world carries `F(ψ)` at time `t`, no `F(□ψ)` at
time `t` mints again — not at that world, not at any other. A minted world is therefore identified
by the **sign, formula and time** of its witness and never by its own index. That is S5 universal
accessibility showing up as a termination fact, and it is what makes the world count boundable.

**What was proved.** `WorldWitness C S b` records the discipline as a branch invariant (outside a
seed set `S`, distinct worlds carry witnesses with distinct signatures, confined to the stock and
to times the branch mentions). `worldFinset_card_le` then counts it:

```
b.worldFinset.card ≤ S.card + 2 * C.card * b.timeFinset.card
```

by injecting the non-seed worlds into `signedUniverse C b.timeLabels` — the same shape as the
file's existing `branch_card_le`, run against times-only labels, which is exactly where the
world-indifference is spent. `chain_le_worlds_bounded` composes it with T2 to discharge **both**
cardinalities: no `W`, no `hW`, no `OrderDual`.

**Evidence.** `worldWitness_self` shows the invariant is satisfiable, and three `#guard_msgs` rows
run the engine's *real* `witnessPresent`: a witness at world 7 suppresses `boxNeg` asked at world
3 (`true`), a witness at a different *time* does not (`false`), and the temporal mirror
`allFutureNeg` does not (`false`). All three predictions matched on first compile.

## Finding: `soundFuel'` is not the general fuel figure

This is new and it affects what 4.3's deliverable can claim.

`chain_le_soundFuel'` takes `hL : L.card ≤ 2 ^ (2 * C.card)` on the **label** set. But T2 bounds
**times** (`timeFinset_card_le_of_not_blocked`), and a label is a world *and* a time. So `hL` asks
for `|worlds| * |times|` to sit under the T2 *time* figure — true only if the run stays in one
world.

The theorem is **not wrong**: `hL` is a hypothesis, not a claim. What does not exist is any route
from T2 to `hL` once a `boxNeg` or `diamondPos` fires. With
`|worlds| ≤ |S| + 2*|C|*2^(2*|C|)`, the honest figure is `chain_le_worlds_bounded`'s, which
exceeds `soundFuel' φ = 2*n*2^(2*n)` by roughly `2*|C|*2^(2*|C|)` — `soundFuel'` has no world
factor in it at all.

`soundFuel'` was **not** redefined. That is a plan-level decision and is left to a revision, which
should choose between (a) redefining `soundFuel'` with a world factor, (b) keeping it as the
explicitly single-world figure under a name that says so, or (c) restating 4.3's deliverable
against `chain_le_worlds_bounded`. No claim in `Fuel.lean` now asserts `soundFuel'` suffices in
the presence of fresh worlds.

## Verification

| Check | Result |
|---|---|
| `lake build FormalSystem.Metalogic.Decidability` | green, 1054 jobs |
| `lake build BimodalTest` | green, 1949 jobs |
| `lean-sorry-census.sh` on `Verified/` | `sorry_count: 0` |
| Vacuous definitions in `Decidability/` | 0 |
| `^axiom` in `Decidability/` | 0 |
| Axioms of new headline theorems | `orderDual_holds`: `propext`, `Quot.sound`. `worldFinset_card_le`, `chain_le_worlds_bounded`: + `Classical.choice` |
| Regression corpus | 11 prior `#guard_msgs` rows still green, + 3 new (WorldProbes) = 14 |

`lake build` (full) is RED at `BXCanonical/Chronicle/CounterexampleElimination.lean` — pre-existing,
outside this territory, does not import `Decidability/`.

## Preserved

Nothing regressed. All of `TrichStock`, `BranchStock`, the three pick-extraction lemmas,
`expandOnceUnblocked_extended_stock`, `signedUniverse`, `chain_le_stock`, `chain_le_soundFuel'`,
`labelFinset`/`worldFinset`/`timeFinset`, `TimeChain`, `timeFinset_card_le_of_not_blocked`,
`comparable_of_firstIncomparablePair_none`, `timeChain_of_linearity_saturated`, `NoSplit`,
`expandBranchWithFuel_isSome_of_noSplit`/`_of_stock`, `noSplit_nil` still build. The only signature
changes are the two `hd : OrderDual ord` parameters, deliberately removed because they are now
provable; no consumer outside `Fuel.lean` referenced them.

## Outstanding in Phase 4

1. **Residual 3 — the branching arms.** `.split`/`.splitOrdered` fold over sub-branches
   (`Saturation.lean:665, :690`) and can report `none` through `resolveOpenArm` (`:661-664,
   :686-689`). `branchesUsed` increments by `branches.length`, not by 1, so the linear invariant
   `branchesUsed + fuel ≤ maxBranches` does not carry over — a tree-shaped budget is needed.
2. **4.2d — general `closureStep` termination.** Independent, blocks nothing.
3. **`WorldWitness` as a theorem.** Deriving it from the rule set is a 36-case induction over
   `applyRule` of the same shape and size as T1, and belongs with that work.
