# Phase 25 Summary: The `trivialEventWitnessed` guard

**Landed variant: A (suppress).** Phases 26-28 branch on this.

## What landed

One file changed: `FormalSystem/Metalogic/Decidability/Tableau.lean`, **62 insertions, 7
deletions**. No other file in the tree was edited.

1. **`def trivialEventWitnessed`** (`Tableau.lean:1924`), inserted immediately after
   `witnessPresent`'s `| _, _, _ => false` closing arm. Signature mirrors `witnessPresent`
   (`rule`, `sf`, `_branch`, `timeOrd`); the branch parameter is deliberately unused, because the
   test is purely ordering-shaped. Arms exactly as the plan specifies:
   - `.someFuturePos` / `.untlPos` on `.untl event guard` →
     `event == Formula.top && guard == Formula.top && !(timeOrd.futureOf l.time).isEmpty`
   - `.somePastPos` / `.sncePos` on `.snce event guard` →
     `event == Formula.top && guard == Formula.top && !(timeOrd.pastOf l.time).isEmpty`
   - every other rule/shape → `false`

   `Formula.top` is a plain `def` (not `@[match_pattern]`), so the `⊤` test is a `BEq`
   comparison against the named `Formula.top` rather than a spelled-out `.imp .bot .bot`
   pattern. This keys the guard on the syntactic constant exactly as required, and keeps the
   source readable at the point where the soundness argument is load-bearing.

2. **Docstring** carrying the soundness argument (⊤ is true at every label, so an already-ordered
   time discharges the existential obligation with no witness formula to duplicate — the same
   satisfiability-preserving argument as `Tableau.lean:1786-1787`, specialised) **and** the
   explicit warning that generalising to a non-valid event `ψ` is unsound and that keying on
   `Formula.top` is load-bearing rather than a convenience.

3. **Two consultation sites**, both inside `findApplicableRule`, both as a disjunct beside
   `witnessPresent` and never in place of it: the `.linear` fresh-label guard (`:1957`) and the
   `.branching` fresh-label guard (`:1981`), each now reading
   `if witnessPresent … || trivialEventWitnessed … then none`.

4. **`saturated_downward_closed` widened** (variant A's declared cost), in both clauses:
   - `.linear`: `ruleMintsFreshLabel rule = true → witnessPresent … = true ∨ trivialEventWitnessed … = true`
   - `.branching`: `… ∨ (ruleMintsFreshLabel rule = true ∧ (witnessPresent … = true ∨ trivialEventWitnessed … = true))`

   The new disjunct is discharged by replacing each clause's `by_contra hw` with
   `obtain ⟨hw1, hw2⟩ := not_or.mp hw` and refuting both disjuncts before the `if_neg`.

## Scope Hypothesis: REFUTED (measured)

The plan's stated confirmation command was run against variant B (redirect) with
`saturated_downward_closed` untouched. It went **RED**:

| Site | Failure | Statement or proof? |
|------|---------|---------------------|
| `findApplicableRule_extending_adds_new` (`Tableau.lean:2839`) | `cases` dependent elimination failed | statement still true; needs a NEW progress argument |
| `saturated_downward_closed` `.linear` clause | `simp` made no progress | proof repair only |
| `saturated_downward_closed` `.branching` clause | `simp` made no progress | proof repair only |

Per the plan's own decision rule, variant A's widening is therefore the actual scope, and variant
A was landed. Note the shape of the refutation: the hypothesis named
`saturated_downward_closed` as the thing that might need widening, and it was right that
something breaks — but the *load-bearing* break was a third theorem the hypothesis never
mentioned, `findApplicableRule_extending_adds_new`, the strict-progress lemma.

The plan's output estimate was refuted in the *opposite* direction from its framing: it predicted
variant A would roughly double variant B's ~150 lines to ~300. The landed variant A is 62
insertions.

### Independent second obstacle to variant B — `[UNVERIFIED: derived, not built]`

`findApplicableRule_applyRule_eq`
(`FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean:238-242`) states:

```
(h : findApplicableRule sf b ord fc = some (r, res, o)) : (applyRule r sf b ord).1 = res
```

Variant B's redirect returns a `res` that is by construction not `applyRule`'s result, so this
theorem is falsified at the **statement** level, not broken at the proof level. Repairing it
would mean re-architecting the termination argument (T1 speaks about `applyRule`), which is far
outside this phase and outside the plan's estimate for variant A.

This is recorded as `[UNVERIFIED]` because it was **not measured**: measuring it would have
required first repairing variant B inside `Tableau.lean`, work the primary refutation above had
already made moot. It is derived from reading the theorem statement, which is quoted above so the
derivation can be checked without re-running anything.

**Method note for future phases**: the plan's confirmation command cannot detect this class of
break at all. `Fuel.lean` is *downstream* of `Tableau.lean`, so `lake build
…Decidability.Tableau` never compiles it. A variant-B revival that passed the stated
confirmation would still have been architecturally blocked, silently.

## Verification results

| Check | Result |
|-------|--------|
| `lake build FormalSystem.Metalogic.Decidability.Tableau` | **GREEN**, 689 jobs |
| `lake build FormalSystem.Metalogic.Decidability.Saturation` | **GREEN**, 1352 jobs; every in-file `PASS …` assertion (FC, PL, AN, FA series) passing |
| `witnessPresent` byte-identical | **YES** — 50-line `def` block diffed against baseline commit `049c84321`, zero differences |
| `trivialEventWitnessed` occurrences | definition (`:1924`) + exactly two consultation sites inside `findApplicableRule` (`:1957`, `:1981`), plus the two variant-A widening occurrences in `saturated_downward_closed` and one comment |
| New `sorry` in diff | **0** |
| New `axiom` in diff | **0** |
| Files touched outside territory | **none** (`git status --short -- FormalSystem/ Tests/` shows only `Tableau.lean`) |

Not run, deliberately: `lake build BimodalTest` (hangs today; Phase 29.1 owns it) and the
tree-wide `lake build` (not this phase's gate — Phase 28's).

## Green / knowingly red at exit

**Green (measured this dispatch)**: `FormalSystem.Metalogic.Decidability.Tableau`,
`FormalSystem.Metalogic.Decidability.Saturation`.

**Knowingly unmeasured, not knowingly red**: every other module in the tree. The declared red
window for Phases 25-28 permits modules outside the territory to be red at exit, but this
dispatch has no evidence that any of them *is* red. Under variant A the changes are conservative
in the direction that matters — `findApplicableRule` gains only a new `none` path, so every
`some` output it produces is unchanged. That keeps `findApplicableRule_applyRule_eq` and
`findApplicableRule_branching_guard` (`Fuel.lean`) true as stated. The plausible downstream cost
is instead in `CountermodelExtraction.lean` and the `Verified/Bridge/*` modules, which
`unfold findApplicableRule` and read its guard structure directly and may need the same
`not_or.mp` treatment. **This is a prediction, not a measurement — recorded `[UNVERIFIED]`.**

## Incidental findings

- The dispatch named `FormalSystem/Automation/Tableau.lean` as the territory. **That file does
  not exist.** The plan's path, `FormalSystem/Metalogic/Decidability/Tableau.lean`, does, and is
  the file every symbol named in Phase 25 actually lives in. The plan's path was followed. The
  same wrong path appears in the standing Phase 29.2 re-baseline attribution, which should be
  corrected there before Phase 29.2 runs.
- `isApplicable .untlPos` is `(asUntil? φ).isSome`, and `asUntil?` returns `none` when
  `guard == Formula.top`. So `.untlPos` can never fire on the `F ⊤` trigger, and its arm in
  `trivialEventWitnessed` is unreachable-but-harmless defensive code. The plan called for the arm
  and it was written as specified; this note only records that it is dead rather than active, so
  Phase 26's measurement is not read as evidence about it. The `.sncePos` arm is the exact
  time-reversal mirror and is dead for the same reason.
- `trivialEventRedirect`, the variant B machinery, was **removed** rather than left in the file as
  unreferenced dead code. It survives in commit `d49b977c0`'s successor state and in the variant
  B build measurement above, should Phase 26+ want to revisit it.

## Commits

| Commit | Content |
|--------|---------|
| `d49b977c0` | phase 25.1: `trivialEventWitnessed` definition, additive, not yet consulted; Tableau green |
| `edcecd551` | phase 25.2: consultation at both sites, `saturated_downward_closed` widened, variant A landed; Tableau + Saturation green |
