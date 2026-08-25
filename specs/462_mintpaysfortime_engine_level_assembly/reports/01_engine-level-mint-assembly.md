# Engine-Level Assembly for `MintPaysForTimeFixed` at a Nonempty Universe

**Task**: 462 — `mintpaysfortime_engine_level_assembly`
**Phase**: research (no implementation)
**Target file**: `FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean`
(14,105 lines as of `e8d0055ec`; the file grew by ~674 lines under `ee0fe12a0`, so every line
number in the task description is stale and has been re-derived below)

---

## Verdict

**The assembly is genuinely plumbing, not open mathematics.** Every mathematical obligation the
three-way disjunct requires is already landed. What is missing is exactly what the task and C9
register entry 20 say is missing: a strengthened pick-stage bridge that keeps the *stage-one*
`findApplicableRule` equation alive, plus a rule-census case split at the `pickBranches` level.

This verdict is not asserted from reading. It is supported by **seven compiled probes** (below),
including a verbatim compile of the strengthened threading spine itself — the single declaration
the task calls "the missing work."

**One correction to the task's framing** is required and is stated in §6: the frame-class
restriction that actually falls out is `¬ (FrameClass.Dense ≤ fc)`, which is a *single* hypothesis
covering both `.Dense` and `.Dedekind` (because `Dense ≤ Dedekind` in the `FrameClass` partial
order). It should be stated that way rather than as two exclusions.

**One correction to the task's value claim** is required and is stated in §7: landing this
unlocks **no** downstream terminus. Not only do the nine `hlab` carriers stay vacuous (as the
critical update already says) — the `U`-level termini that carry no `hlab` also stay conditioned
on `UniverseClosedAt`, `DifficultyBounded`/`StepLengthBounded`, and
`PostBlockingSettles`/`PostBlockingSettlesRun`, of which C9 entries 9, 11 and 22 refute three.
The deliverable's value is that it **retires C9 entry 20's item (a)**, closing the last
non-density obstruction to the mint predicate itself.

---

## 1. Current line numbers (re-derived, all stale ones corrected)

| Declaration | Task said | Actual |
|---|---|---|
| `MintPaysForTimeFixed` (def) | 10499 | **10537** |
| `mintPaysForTimeFixed_of_mintPaysForTimeStable` | — | 10558 |
| `mintPaysForTimeFixed_signedUniverse_empty` | 11096 | **11147** |
| `applyRule_emitted_time_dichotomy` | 7048 | **7124** |
| `expandOnceUnblocked_ord_mono` | 1945 | **1945** (unchanged) |
| `mintPotential_lt_of_pick_linear_sigmaFixed` | — | 10575 |
| `mintPotential_lt_of_pick_branching_sigmaFixed` | — | 10587 |
| `sigma_formula_hit_of_sigmaFixed` | — | 10508 |
| `selfGuardPotential_lt_of_untlNeg` | — | 9250 |
| `selfGuardPotential_lt_of_snceNeg` | — | 9265 |
| `applyRule_untlNeg_active_ord` / `_snceNeg_active_ord` | — | 9222 / 9233 |
| `unorderedSuccessorLabelClosed_nonempty_false` | — | 11539 |
| C9 register (24 entries) | — | 13371 |
| D3 (`untl`/`snce`-free discharge) | — | 12571 |
| D4 (label residual replaced) | — | 12992 |

Private spine machinery (all in-file, so the new work must live in this file):
`pick_ord_eq` :972, `pickOrd_mono` :1928, `pickBranches`/`pick_branches_eq` :1131/:1139,
`pick_stage_source` :1163, `pickBranches_ordTimes` :1204, `resultBranch_sub` :2596,
`pick_stage_source_guarded` :2767, `pick_stage_source_noMint` :12738,
`pickBranches_knownTimes_subset` :12789.

---

## 2. C9 register entries read in full (14, 17, 18, 19, 20; amended 11 and 21)

Read at :13473 (11), :13529 (14), :13582 (17), :13635 (18), :13716 (19), :13790 (20), :13856 (21).

The load-bearing findings for this task:

- **Entry 14** — `MintPaysForTime` as literally stated is refuted (`mintPaysForTime_untlNeg_false`).
  Two obvious repairs are closed: re-indexing `mintPotential` on `freshTimeRules`
  (`witnessPresent_eq_false_of_not_freshLabel`), and dropping disjunct 1's cardinality conjunct
  (`splitOrderedRank_lt_of_knownTimes_lt`, `mintPaysForTime_rank_repair_false`).
  **Neither route is touched by this task**: the predicate here is `MintPaysForTimeFixed`, whose
  disjunct 1 already carries both conjuncts and whose potential is still indexed on
  `freshLabelRules ×ˢ U`. No re-indexing, no conjunct removal.

- **Entry 17** — the `selfGuardRules ×ˢ U` ledger, refuted *as a statement about the unoriented
  arm*, with the refutation later withdrawn in that scope by entry 19. The register is explicit
  that `mintPaysForTimeAt_reuse_false` is still true about `MintPaysForTimeAt` (a *different*
  predicate, whose third disjunct is the bare `selfGuardPotential` drop). **This task does not
  touch `MintPaysForTimeAt` and does not weaken disjunct 3 to the bare drop** — see entry 19's
  route 2, which is what forbids that.

- **Entry 18** — the arm-orientation repair; no `nextTime` redefinition, no `TimeOrdering`
  highwater field, no run-level mint counter. **This task edits no engine definition at all.**

- **Entry 19** — route 4 ("the discharge at a nonempty universe") is named as *the one thing left*,
  with the density coordinate as its blocker, and its own closing sentence withdrawn by entry 20.

- **Entry 20** — the operative entry. Its "*What is left*" paragraph names exactly two items:
  **(a)** the engine-level assembly (this task) and **(b)** the density coordinate (`gapPotential`,
  explicitly out of scope). It states in terms: *"A discharge at frame classes outside `.Dense` /
  `.Dedekind` needs only (a)."* This task is (a), and the register itself is the warrant that (a)
  suffices at those frame classes.

- **Entry 11 (amended)** and **Entry 21 (amended)** — cover the `UnorderedSuccessorLabelClosed`
  refutation and its consequence for the nine carriers. Both already say what the critical update
  says. **Neither needs a new entry for this task**, and §8 below recommends amending 20 rather
  than adding entry 25.

**Nothing in this task's plan re-attempts any registered route.** The census case split, the
strengthened bridge, and the frame-class hypothesis are all new territory that no entry covers.

---

## 3. What already exists — the complete obligation map

The three-way disjunct of `MintPaysForTimeFixed` (:10537) at an unordered successor `nb` with
`o := (expandOnceUnblocked b ord fc tr).2`:

| Disjunct | Conjunct 1 | Conjunct 2 |
|---|---|---|
| 1 | `nb.knownTimes.card ≤ b.knownTimes.card` | `splitOrderedRank Tmax nb o ≤ splitOrderedRank Tmax b ord` |
| 2 | `mintTimeBudget U σ nb o ≤ mintTimeBudget U σ b ord` | `mintPotential U σ nb o < mintPotential U σ b ord` |
| 3 | `mintTimeBudget nb o + selfGuardPotential o ≤ mintTimeBudget b ord + selfGuardPotential ord` | `selfGuardPotential o < selfGuardPotential ord` |

with `mintTimeBudget U σ b ord = b.knownTimes.toFinset.card + mintPotential U σ b ord` (:3960).

### Rule census (all 36 constructors, partitioned; probe 7 decides the partition)

`freshTimeRules` (:6578) has nine members. `freshLabelRules` (:3030) has eight.
`freshLabelRules ∩ freshTimeRules` = {`allFutureNeg`, `allPastNeg`, `someFuturePos`,
`somePastPos`, `untlPos`, `sncePos`} — six. `freshTimeRules \ freshLabelRules` = {`untlNeg`,
`snceNeg`, `densityRule`} — three.

| Bucket | Size | Disjunct | Supplied by |
|---|---|---|---|
| `ruleMintsFreshTime r = false` | 27 (+ `serialityRule`, `timeLinearity` from stages 2/3) | 1 | `applyRule_emitted_time_mem` :6887 → subset → `Finset.card_le_card` + `splitOrderedRank_le_of_knownTimes_subset` :12838 + `pickOrd_mono` :1928 |
| `freshLabelRules ∩ freshTimeRules` | 6 | 2 | `mintPotential_lt_of_pick_linear_sigmaFixed` :10575 / `..._branching_sigmaFixed` :10587 for conjunct 2; `knownTimes_card_le_succ_of_unorderedSuccessor` :7196 + omega for conjunct 1 |
| `untlNeg`, `snceNeg` | 2 | 3 | `selfGuardPotential_lt_of_untlNeg` :9250 / `..._snceNeg` :9265 for conjunct 2; :7196 + `mintPotential_expandOnceUnblocked` :3156 + omega for conjunct 1 |
| `densityRule` | 1 | — | **excluded** by `¬(Dense ≤ fc)` via `findApplicableRule_isApplicable` :12711 |

### The arithmetic of the two "conjunct 1" obligations, checked

Both are `omega` from landed facts, and both are exactly balanced — worth recording because a
reader may suspect the budget conjunct is the hidden obstruction:

- **Disjunct 2.** `|kt nb| ≤ |kt b| + 1` (:7196) and `mintPotential nb o + 1 ≤ mintPotential b ord`
  (the pick lemma). Sum: `mintTimeBudget nb o ≤ mintTimeBudget b ord`. Exact, with no slack.
- **Disjunct 3.** `|kt nb| ≤ |kt b| + 1` (:7196), `mintPotential nb o ≤ mintPotential b ord`
  (:3156, since `untlNeg`/`snceNeg` ∉ `freshLabelRules` and the state only grows), and
  `selfGuardPotential o + 1 ≤ selfGuardPotential ord` (:9250/:9265). Sum: the combined-budget
  conjunct. Exact, with no slack.

This is entry 19's route 2 working as designed: the combined conjunct is what the self-guarded
mint's one unit of budget buys.

### Hypothesis availability at the consuming site

Every hypothesis the payment lemmas need is one `MintPaysForTimeFixed` already binds:
`hconf : ∀ x ∈ b, x ∈ U` ✔; `hfix : SigmaFixed σ b` ✔ (and `sigmaTimeStable_of_sigmaFixed` :10388
weakens it for disjunct 3); `hri : RunInvariant b ord` ✔, whose `.ordTimesKnown` field supplies
the `OrdTimesKnown b ord` that :6887, :7124 and :7196 all require; `sf ∈ b` ✔ from the pick.
**No new hypothesis is added to the predicate, and no figure changes.**

---

## 4. The gap, stated precisely

`pick_stage_source` (:1163) — the existing bridge — concludes

```
∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o)
```

This is enough for disjunct 3 (`selfGuardPotential_lt_of_untlNeg` is stated against
`(applyRule untlNeg ⟨Sign.neg, φ, l⟩ b ord).2`) and for disjunct 1 (`applyRule_emitted_time_mem`
is stated against `applyRule`). It is **not** enough for disjunct 2: the pick lemmas at :10575 and
:10587 are stated against

```
findApplicableRule sf₀ b ord fc = some (r, RuleResult.linear fs, o)
```

because their proofs consume `findApplicableRule_guard_linear` / `_branching` — the
`witnessPresent … = false` guard, which lives in `findApplicableRule`'s `if`, **not** in
`applyRule`. `pick_stage_source` discards exactly that equation.

**That, and only that, is the "threading through `expandOnceUnblocked`'s three stages" the task
names.** The file already has two precedents for the fix — `pick_stage_source_guarded` (:2767,
attaches the fresh-world guard) and `pick_stage_source_noMint` (:12738, attaches the no-mint fact)
— so the pattern is established, not invented.

The frame-class exclusion also needs the stage-one equation (`findApplicableRule_isApplicable`
:12711 is stated at `findApplicableRule`), which is a second reason the strengthened bridge is the
right shape.

---

## 5. Compiled evidence (seven probes, all green)

Written against the built `MintBound` olean and compiled with `lake env lean`. Sources archived at
`/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/add4402f-c2e5-4916-bae3-1c3219140b0b/scratchpad/Probe462{,b,c,d}.lean`.
They were removed from the repository root; nothing in the tree was modified.

| # | Claim probed | Result |
|---|---|---|
| 1 | `findApplicableRule sf b ord fc = some (densityRule, _, _)` is impossible when `¬(Dense ≤ fc)` | ✅ compiles (`simp only [isApplicable] at hA; split at hA <;> simp_all`) |
| 2 | `untlNeg`'s ACTIVE guard is recoverable from a non-`notApplicable` result | ✅ compiles |
| 3 | `allFutureNeg` yields `.linear` or `.notApplicable`, never `.persistent`/`.branchingOrdered` | ✅ compiles |
| 4 | **The strengthened pick-stage bridge itself** (full statement, all three stages) | ✅ compiles |
| 5 | `isApplicable untlNeg sf fc = true` recovers `sf = ⟨.neg, φ, l⟩` with `asUntil? φ = some (e,g)` | ✅ compiles |
| 6 | `untlPos` yields `.branching` or `.notApplicable` | ✅ compiles |
| 7 | The four-bucket rule census is `decide`-able over all 36 constructors | ✅ compiles |

Probe 4 is the decisive one. Its statement is:

```lean
theorem probe_pick_stage_source_rule (b : Branch) (ord : TimeOrdering)
    (fc : FormalSystem.ProofSystem.FrameClass) (tr : EventualityTracker) :
    ∀ r res o,
      (match findUnexpandedUnblockedWith b ord fc (blockedTimes b ord fc tr) with
       | some sf => findApplicableRule sf b ord fc
       | none => …serial stage… | none => …linearity stage… | none => none)
        = some (r, res, o) →
      ∃ sf, sf ∈ b ∧ applyRule r sf b ord = (res, o) ∧
        (findApplicableRule sf b ord fc = some (r, res, o)
          ∨ ruleMintsFreshTime r = false)
```

Stage one supplies the left disjunct verbatim (`Or.inl h`); stages two and three supply the right
one from `findApplicableSerialRule_rule` (:2741) and `findApplicableLinearityRule_rule` (:2753),
since neither `serialityRule` nor `timeLinearity` is in `freshTimeRules`. The proof is a
44-line structural copy of `pick_stage_source_noMint` and **compiled on the first attempt**.

### Two facts the probes settled that a paper reading would have got wrong

1. **`untlNeg`/`snceNeg` have no live PASSIVE arm.** `Tableau.lean:1022-1142` retires it; the `if`
   falls through to `(.notApplicable, timeOrd)`. So a non-`notApplicable` result *forces* the
   ACTIVE guard, and the disjunct-3 guard extraction is a one-`by_contra` inversion rather than a
   two-way arm analysis. Probe 2.
2. **None of the six witness-guarded minting rules ever returns `.persistent`.** Arm boundaries in
   `applyRule` are 764/795/804/835/867/879/911/925/973; the `.persistent` shapes at 795 and 867
   belong to `allPastPos` and `someFutureNeg`, which are *not* in the six. Combined with
   `findApplicableRule_result_ne_notApplicable` (:11845), the disjunct-2 bucket is exactly two
   result shapes, both already covered by the landed pick lemmas. Probes 3 and 6.

---

## 6. The frame-class hypothesis — state it as one condition, not two

`FrameClass`'s `LE` (`Axioms.lean:526-533`) has `Dense ≤ Dense` and `Dense ≤ Dedekind` and nothing
else above `Dense`. `densityRule` reaches `findApplicableRule` only through `allRulesForFC`
(`Tableau.lean:1652`), whose `dense` component is gated on `decide (Dense ≤ fc)`, and
`isApplicable .densityRule .pos (.allFuture _) fc = decide (Dense ≤ fc)` (`Tableau.lean:383`).

Therefore the single hypothesis

```lean
(hfc : ¬ (FormalSystem.ProofSystem.FrameClass.Dense ≤ fc))
```

excludes `.Dense` **and** `.Dedekind` simultaneously and admits exactly `.Base` and `.Discrete`.
The task asked for the restriction to be stated explicitly and not hidden — this is the honest and
minimal way to do it. Stating it as two disequalities would be both weaker in form and redundant.

**Also checked**: no rule in `discreteRules` (`priorUZ`, `priorSZ`, `z1Rule`), `dedekindRules`
(`priorUGap`, `priorSGap`, `sepRule`) or the non-density half of `denseRules`
(`denseIndicatorClosure`) is in `freshTimeRules`. So `densityRule` is genuinely the only
frame-gated obstruction, and `.Discrete` needs no separate treatment.

---

## 7. What this actually unlocks — and what it does not

This section discharges the task's explicit requirement to determine precisely which downstream
consumers the result unlocks.

### It does NOT unlock the nine `hlab` carriers

Confirmed independently. The nine live carriers of `hlab : UnorderedSuccessorLabelClosed fc L` are
at **:6225, :6449, :6491, :6516, :10080, :10110, :11059, :11077, :12971**. Since
`unorderedSuccessorLabelClosed_nonempty_false` (:11539) makes that predicate's satisfiability set
exactly `{∅}`, and `signedUniverse C ∅ = ∅`, all nine are vacuous conditionals at every nonempty
`L`. Discharging `hmint` changes none of that. This matches the sibling task's conclusion exactly.

### It also does NOT unlock the `U`-level termini

This is stronger than the critical update claimed, and it needs saying. Every `hmint`-carrying
theorem without `hlab` was inspected:

| Theorem | Line | Other hypotheses |
|---|---|---|
| `budgetPotentialAt_step_unordered_fixed` | 10757 | `UniverseClosedAt fc U` |
| `stepDecreases_budgetPotentialAt_fixed` | 10915 | `UniverseClosedAt`, `DifficultyBounded fc U D` |
| `expandBranchWithFuel_isSome_of_budget_fixed` | 10964 | `UniverseClosedAt`, `DifficultyBounded`, `ArmSettlement` |
| `buildTableauAt_isSome_of_budget_fixed` | 10983 | `UniverseClosedAt`, `DifficultyBounded`, `PostBlockingSettles` |
| `buildTableauAt_isSome_at_seed_fixed` | 11000 | same |
| `buildTableauAt_isSome_of_lengthBudget_fixed` | 11018 | `UniverseClosedAt`, `StepLengthBounded`, `PostBlockingSettles` |
| `buildTableauAt_isSome_at_seed_lengthBudget_fixed` | 11033 | same |
| `buildTableauAt_isSome_of_budget_fixed_run` | 12430 | `UniverseClosedAt`, `DifficultyBounded`, `ArmSettlement`, `PostBlockingSettlesRun` |
| `buildTableauAt_isSome_at_seed_fixed_run` | 12449 | same |

Every one carries `UniverseClosedAt fc U`, which C9 entry 11 records as refuted at a fixed finite
`signedUniverse C L` (`universeClosedAt_fresh_world_escapes` :5939), with no `L`-side repair
available (`freshWorldHeadroom_not_universal`). Most additionally carry `DifficultyBounded`
(entry 9: refuted at *any* `D` for a `U` the engine fires on) or `PostBlockingSettles` (entry 22:
refuted by two witnesses) or `PostBlockingSettlesRun` (entry 24: not discharged).

**Conclusion to state in the deliverable's docstring, unambiguously:** landing
`MintPaysForTimeFixed` at a nonempty universe makes **no** terminus in this file non-vacuous. It
removes one name from the residual list; three or four others remain on every chain, and several
of those are refuted rather than merely open.

### What it DOES deliver

1. **It retires C9 entry 20's item (a)** — the last non-density obstruction to the mint predicate
   itself. After this, entry 20's "what is left" reads: the density coordinate, and nothing else.
2. **It generalizes D3.** `mintPaysForTimeFixed_signedUniverse_untlSnceFree` (:12897) already
   discharges at a nonempty `signedUniverse C L`, but only for `untl`/`snce`-free `C` — a stock on
   which no member of `freshTimeRules` is even applicable, so every step trivially lands in
   disjunct 1 and σ never appears. The new result holds for **every** `C`, temporal operators
   included, which is precisely the case entry 20 calls "the hard one". It supersedes
   `mintPaysForTimeFixed_signedUniverse_empty` (:11147) as advertised, and does so for arbitrary
   `C` rather than only on a syntactic fragment.
3. **It is satisfiable, not vacuous.** `signedUniverse_nonempty` (:12922) plus any nonempty `C`
   containing a temporal operator gives a witness — and unlike `hlab`, the discharged hypothesis
   is a *theorem* at that witness.

---

## 8. Recommended implementation shape (for the planner)

New section **D5**, placed after D4's boundary note (~:13370) and **before** the C9 register, so
the register stays last.

| # | Declaration | Kind | Est. lines | Risk |
|---|---|---|---|---|
| 1 | `pick_stage_source_rule` | private, strengthened bridge | ~45 | **none** — probe 4 compiled it verbatim |
| 2 | `findApplicableRule_ne_densityRule` | density exclusion | ~10 | none — probe 1 |
| 3 | `applyRule_untlNeg_active_guard` / `_snceNeg_active_guard` | guard inversion | ~12 ×2 | none — probe 2 |
| 4 | `isApplicable_untlNeg_trigger` / `_snceNeg_trigger` | trigger-shape recovery | ~10 ×2 | none — probe 5 |
| 5 | six `applyRule_*_result` shape lemmas (model: `applyRule_boxNeg_result`) | shape inversion | ~10 ×6 | low — probes 3, 6 |
| 6 | `pickBranches_mintPays` | private, the four-bucket case split | **~200-280** | moderate: bulk, not novelty |
| 7 | `expandOnceUnblocked_mintPays` | engine lift via `pick_ord_eq` + `pick_branches_eq` | ~30 | none — template at :1224 |
| 8 | `mintPaysForTimeFixed_of_not_dense` | the discharge | ~15 | none |
| 9 | `mintPaysForTimeFixed_signedUniverse_of_not_dense` | `signedUniverse` instantiation | ~8 | none |
| 10 | Section prose + entry-20 amendment | docs | ~60 | none |

Total ≈ 500-600 lines, of which one declaration (#6) carries the bulk. Sizing note for phase
decomposition: #1-#5 are independent leaf lemmas and can be one phase; #6 should be its own phase;
#7-#10 a third.

**Alternative to #5** worth costing during planning: rather than six shape lemmas, add a
`.persistent` variant of `mintPotential_lt_of_pick_linear_sigmaFixed`. `nonBranchingResultBranch`
treats `.linear` and `.persistent` alike and `applyRule_fresh_witness_nonbranching` is already
shape-agnostic, so the variant is likely three lines and removes six lemmas. Not verified by
probe; decide during implementation.

### Constraints the implementation must honour

- `Fuel.lean`, `Saturation.lean`, `Tableau.lean` are md5-pinned: **no edits**. Nothing in the plan
  above needs one.
- No previously-landed declaration is altered. All ten items are additions.
- `MintPaysForTimeFixed`'s statement is not touched — no new hypothesis, no weakened disjunct, no
  re-indexed potential. (Entries 14, 17, 19 route 2 all forbid variants of that; none is proposed.)
- The frame-class restriction goes in the theorem statement as `¬ (Dense ≤ fc)`, visible, per §6.
- The docstring must state §7's negative finding explicitly, or the deliverable repeats the exact
  failure mode entry 21 documents for
  `buildTableauAt_isSome_at_seed_lengthBudget_signedUniverse_untlSnceFree`.

### C9 register

**Do not add entry 25.** Entry 20's "*What is left*" paragraph should be amended in place: item
(a) becomes landed, naming the new theorems, and the paragraph should carry §7's finding that the
discharge unlocks no terminus. Entries 11 and 21 already cover the `hlab` side and need no change
(the critical update's guidance to check them first is correct — they do cover it).

---

## 9. Residual risk

The single moderate-risk item is #6, and its risk is volume rather than novelty: four buckets ×
two result shapes, each closing from a landed lemma, with `omega` for both budget conjuncts. Every
bucket's closer has been individually identified above and every inversion it needs has been
compiled. No step in the plan requires a lemma that does not exist, and no step requires weakening
the predicate.

**No `sorry` is anticipated, and none would be acceptable** — the zero-debt gate applies. If #6
turns out to need a fact not on this list, the correct response is to stop and record it, not to
defer it.
