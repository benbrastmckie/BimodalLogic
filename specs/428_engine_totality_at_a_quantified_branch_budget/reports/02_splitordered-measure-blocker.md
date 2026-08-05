# Research Report: the `.splitOrdered` progress measure

- **Task**: 428 — engine_totality_at_a_quantified_branch_budget
- **Started**: TBD
- **Completed**: TBD
- **Effort**: TBD
- **Dependencies**: TBD
- **Sources/Inputs**: TBD
- **Artifacts**: TBD
- **Standards**: TBD
- **Question**: does the proposed order-theoretic measure unblock Phase 4 task 4.1, and what
  concrete Phase 4/6 re-plan follows?
- **Method**: every claim below marked **VERIFIED** was type-checked against the real repo via
  `lean_run_code` at Lean v4.33.0-rc1 with the project's own imports. Claims marked
  **UNVERIFIED** are argued, not checked, and are flagged individually.

## Verdict

**The proposed measure works, with one correction to its shape.** The implementation agent's
candidate — "the count of incomparable pairs among `b.knownTimes` under `ord`, strictly
decreasing at each `timeLinearity` firing" — is correct for the two `addFuture` arms but **not**
for the identification arm, where the ordering is *rewritten* rather than extended and the
monotonicity argument does not apply.

The repair is to make the measure **lexicographic**:

```
splitOrderedMeasure b ord := ( b.knownTimes.toFinset.card , (incompPairs b ord).card )
```

- arms 1 and 2 (`addFuture`) leave the branch *literally unchanged*, so the first component is
  equal and the second strictly decreases;
- arm 3 (`identifyTime`) strictly decreases the first component, so **no fact about the rewritten
  `TimeOrdering` is needed at all**.

That second point is the substantive finding: the lexicographic split sidesteps the hardest part
of the original proposal (proving that `TimeOrdering.identifyTime`'s constraint substitution
preserves comparability of the surviving times), which I did not need to prove and which the
re-plan below does not require anyone to prove.

**But the measure does not by itself bound split depth**, which is what Phase 6 actually needs.
See "The residual gap" below — this is the honest limit of the result, and it changes the shape
of the Phase 6 re-plan.

## What made this tractable: existing infrastructure

My initial concern was fatal-looking: `futureOf`/`pastOf` are defined via `reachableForward`/
`reachableBackward`, which are `private` to `SignedFormula.lean` and therefore unreachable from
`Fuel.lean` — the same class of obstruction as the `temporalCount`/`modalCount` privacy issue
already recorded as finding 4 in the phase-4 handoff.

**That obstruction does not apply.** `Fuel.lean:98` already carries
`open private reachableForward reachableBackward from …`, and lines 690–905 already provide the
full BFS calculus: `PathN`, `bfsClosure`, `reachableForward_eq`/`reachableBackward_eq`,
`mem_bfsClosure_of_mem_visited`, `bfsClosure_sound`, `BfsInv`, `bfsClosure_complete_aux`,
`bfsClosure_complete`, `PathN.snoc`, `PathN.reverse`, `mem_directFutureOf_iff`, and
`orderDual_holds`. Every lemma below is a consumer of that existing calculus; **none of it needs
to be built, and no engine file is edited.**

## Verified results

All of the following type-check. They are stated in the order they should be landed.

### Monotonicity of the closures (the core of arms 1–2)

| Lemma | Statement | Status |
|---|---|---|
| `pathN_mono` | `(∀ x y, y ∈ f x → y ∈ g x) → PathN f n a b → PathN g n a b` | **VERIFIED** |
| `directFutureOf_mono` | constraints ⊆ constraints′ → `directFutureOf` grows | **VERIFIED** |
| `directPastOf_mono` | mirror | **VERIFIED** |
| `futureOf_mono` | constraints ⊆ constraints′ → `futureOf` grows, **at the same fuel 100** | **VERIFIED** |
| `pastOf_mono` | mirror | **VERIFIED** |

`futureOf_mono` is the load-bearing one and it is 6 lines: `bfsClosure_sound` extracts a path of
length `1 ≤ n ≤ 100`, `pathN_mono` transports it along the bigger edge set, `bfsClosure_complete`
re-finds it at the same fuel. The fuel bound is not an obstacle precisely because soundness and
completeness are stated at a *matching* bound — the same observation `orderDual_holds` already
relies on.

### The new edge is actually seen

| Lemma | Statement | Status |
|---|---|---|
| `mem_futureOf_addFuture` | `t₂ ∈ (ord.addFuture t₁ t₂).futureOf t₁` | **VERIFIED** |
| `mem_pastOf_addFuture` | `t₂ ∈ (ord.addFuture t₂ t₁).pastOf t₁` | **VERIFIED** |

Both are 4 lines via a one-edge `PathN` and `bfsClosure_complete`. The pair is that the *same*
witness pair `(t₁, t₂)` is killed by arm 1 through the `futureOf` conjunct and by arm 2 through
the `pastOf` conjunct — so **arm 2 needs no appeal to `orderDual_holds`**, which is how I
originally expected to have to do it.

### What the trigger guarantees

| Lemma | Statement | Status |
|---|---|---|
| `firstIncomparablePair_spec` | `firstIncomparablePair b ord = some (t₁,t₂)` → `t₁ ∈ b.knownTimes ∧ t₂ ∈ b.knownTimes ∧ t₂ ≠ t₁ ∧ t₂ ∉ ord.futureOf t₁ ∧ t₂ ∉ ord.pastOf t₁` | **VERIFIED** |

This is the `some`-direction companion to the landed `comparable_of_firstIncomparablePair_none`,
and it did not exist. Everything downstream consumes it.

### The measure and its decrease

```lean
def incomparableB (ord : TimeOrdering) (p : TimeIndex × TimeIndex) : Bool :=
  p.2 != p.1 && !(ord.futureOf p.1).contains p.2 && !(ord.pastOf p.1).contains p.2

def incompPairs (b : Branch) (ord : TimeOrdering) : Finset (TimeIndex × TimeIndex) :=
  ((b.knownTimes ×ˢ b.knownTimes).filter (incomparableB ord)).toFinset
```

`incomparableB` is `firstIncomparablePair`'s own test, transcribed verbatim rather than
re-derived — deliberate, so the measure cannot drift from the trigger it is meant to track.

| Lemma | Statement | Status |
|---|---|---|
| `incomparableB_mono` / `incompPairs_mono` | constraints ⊆ constraints′ → `incompPairs b ord' ⊆ incompPairs b ord` | **VERIFIED** |
| `incompPairs_lt_addFuture` | on the trigger's own hypotheses, `(incompPairs b (ord.addFuture t₁ t₂)).card < (incompPairs b ord).card` | **VERIFIED** |
| `src_not_mem_knownTimes_identifyTime` | `src ≠ tgt → src ∉ (b.identifyTime src tgt).knownTimes` | **VERIFIED** |
| `knownTimes_identifyTime_subset` | `tgt ∈ b.knownTimes` → identification introduces no new times | **VERIFIED** |
| `knownTimes_card_lt_identifyTime` | `((b.identifyTime t₂ t₁).knownTimes).toFinset.card < (b.knownTimes).toFinset.card` | **VERIFIED** |

So all three arms of `applyRule .timeLinearity` — whose shape is pinned by the already-landed
`applyRule_timeLinearity_arms` — strictly decrease the lexicographic measure. **The blocker's
"what is needed to unblock" is met.**

## The residual gap (this is the important part)

The verified measure decreases at every `timeLinearity` firing. It does **not** give a global
split-depth bound, because of an interaction the phase-4 blocker did not name:

**`.split` can mint fresh times, which increases `knownTimes` and so resets the order measure
upward.** `ruleMintsFreshLabel` contains `.untlPos` and `.sncePos`, both of which are *branching*
rules; and `.untlNeg`/`.snceNeg` are `ruleSelfGuarded` with their passive arms retired, so they
now fire only through an active arm that also mints a fresh time. Therefore:

- the order measure bounds `.splitOrdered` depth **between** fresh-time mints, not globally;
- branch-cardinality growth bounds `.split` depth;
- neither bounds the other, and a naive lexicographic combination of the two fails in both
  orderings — `.splitOrdered` arm 3 can *shrink* the branch (identification merges signed
  formulas), so `|U| − |b.toFinset|` moves the wrong way there, while `.split` fresh-minting
  moves `|knownTimes|` the wrong way.

**Consequence for Phase 6**: a fuel figure cannot be built from these two measures alone. It
needs an a-priori bound `|b.knownTimes| ≤ Tmax` carried as an invariant. With such a bound the
`.splitOrdered` depth between mints is at most `Tmax + Tmax²`, and the whole figure closes.

This is not a reintroduction of `NoSplit` by another name, and the distinction is worth being
precise about: `NoSplit` *forbids* the split constructors outright, so any theorem carrying it is
vacuous on branching runs. A `knownTimes` cardinality bound *permits* both split constructors and
merely quantifies the time dimension — it is the same kind of hypothesis as the existing
`hU : ∀ b, P b → ∀ x ∈ b, x ∈ U`, which the landed `expandBranchWithFuel_isSome_of_noSplit`
already carries without anyone calling it vacuous.

**UNVERIFIED**: that `Tmax` is suppliable for the engine's own seed run. This is exactly what
Phase 7 ("close the world dimension", `worldFuel'`/`WorldWitness`) is for, and T2
(`TimeTypeBound.lean`) is the intended source. I did not verify that T2's bound is in a form
Phase 7 can actually discharge, and the phase-4 handoff's own framing of `WorldWitness` as "an
invariant, **not** discharged there" is a warning sign. **This is the residual risk of the whole
re-plan and should not be presented as settled.** The fallback, if T2 does not deliver, is to
bound fresh-time mints directly via the `witnessPresent` guard (each existential signed formula
mints at most one witness, and the existential formulas live in the finite universe `U`) — an
independent route to the same bound, at higher cost.

## A second, separate gap found

Task 4.1's **first** half is also not fully landed. `expandOnceUnblocked_split_card_le` is
non-strict; the strict version is what a `.split` depth bound needs. It **is** provable — the
`.branching` arm of `findApplicableRule` (`Tableau.lean:1924-1934`) rejects the result when
`bss.any (fun fs => fs.all branch.contains)`, so every accepted arm contributes a formula the
branch lacks — but it needs **three** cases, because two predicates bypass that guard:

1. ordinary rules — the `bss.any …` guard gives it directly;
2. `ruleSelfGuarded` (`.untlNeg`, `.snceNeg`) — their surviving active arm mints a fresh time, so
   its output sits at a label the branch does not carry;
3. `ruleMintsFreshLabel` (`.untlPos`, `.sncePos` among the branching rules) — same argument.

**UNVERIFIED**: I did not machine-check the strict `.split` lemma. The guard structure above is
read from source and is strong evidence, not proof.

## Concrete re-plan

### Revised Phase 4 — order-theoretic measure (all VERIFIED above)

In dependency order, all in `Fuel.lean`, all consuming only already-landed lemmas:

1. `pathN_mono`
2. `directFutureOf_mono`, `directPastOf_mono`
3. `futureOf_mono`, `pastOf_mono` — consume `bfsClosure_sound`, `bfsClosure_complete`
4. `mem_futureOf_addFuture`, `mem_pastOf_addFuture` — consume `bfsClosure_complete`
5. `firstIncomparablePair_spec` — companion to landed `comparable_of_firstIncomparablePair_none`
6. `incomparableB`, `incompPairs` (defs)
7. `incomparableB_mono`, `incompPairs_mono`
8. `incompPairs_lt_addFuture` — arms 1 and 2
9. `src_not_mem_knownTimes_identifyTime`, `knownTimes_identifyTime_subset`,
   `knownTimes_card_lt_identifyTime` — arm 3
10. `splitOrderedMeasure` + `splitOrderedMeasure_lt_of_timeLinearity`: the lexicographic
    combination, dispatching on the landed `applyRule_timeLinearity_arms`

### Revised Phase 4b — the strict `.split` half (UNVERIFIED, three cases)

11. `expandOnceUnblocked_split_card_lt`, by the three-case analysis above. Carries a
    `Scope Hypothesis`: if case 2 or 3 does not close, keep the non-strict
    `expandOnceUnblocked_split_card_le` and carry strictness as a hypothesis rather than
    narrowing the statement.

### Revised Phase 6 — fuel figure from both measures **plus a carried time bound**

12. Add `hT : ∀ b, P b → b.knownTimes.toFinset.card ≤ Tmax` to the invariant bundle, alongside the
    existing `hU`. State plainly in the docstring that this is a *bound*, not an exclusion, and
    why that differs from `NoSplit`.
13. Define the split-aware figure over `(|U|, Tmax, β)` — `.split` depth ≤ `|U|`, `.splitOrdered`
    depth between mints ≤ `Tmax + Tmax²`. Do not overload `soundFuel'`/`worldFuel'`.
14. Prove `expandBranchWithFuel_isSome_of_budget` with `NoSplit` **deleted**, consuming Phase 5's
    fold lemmas and the landed `allocateFuelProportionally_ge` / `splitBudget_preserved` /
    `budget_le_of_betaBudget`.
15. Keep the branching non-vacuity witness the original Phase 6 asked for. It matters more now:
    it is what demonstrates `hT` did not silently become `NoSplit`.

Phases 5, 7, 8 keep their existing task lists. Phase 7 gains the explicit obligation of
discharging `hT` for the engine's seed run, which is the re-plan's main risk.

## Constraints check

Nothing proposed here edits `buildTableau`, its `fuel := 1000` default, `expandBranchWithFuel`'s
`maxBranches := 50000` default, or `ExpandedTableau.hasOpen`. All additions are new lemmas and
defs in `Fuel.lean` (`file_scope`-compliant). No `NoSplit` reintroduction, no admitted
`WorldWitness`, no `sorry`, and the refuted unconditional `buildTableau_isSome` is not revisited.

## Files inspected

`Fuel.lean` (esp. 89-160, 655-920, 1250-1600), `Saturation.lean`, `SignedFormula.lean` (340-380,
660-800), `Tableau.lean` (370-430, 1480-1525, 1900-1945), plus the phase-4 handoff and the
implementation summary. No files were modified; no commits were made.
