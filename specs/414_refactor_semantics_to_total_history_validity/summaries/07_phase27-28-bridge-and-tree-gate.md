# Phases 27 and 28 — the saturation-extraction bridge, and the tree-wide green gate

**Status**: both phases `[COMPLETED]`. **The red window opened at Phase 25 is closed.**

`lake build` (default `FormalSystem` target) is **green at 2331 jobs**, identical to the Phase 24
baseline, with the live non-Boneyard sorry count still **1** and zero `axiom` declarations.

---

## 0. The phases were executed 28-then-27, deliberately

The plan schedules 27 (Bridge) before 28 (`CountermodelExtraction`). That order is
**unexecutable**, for an import-direction reason that is measured rather than suspected:

```
Verified/Bridge/BoxSaturation.lean:7
    imports FormalSystem.Metalogic.Decidability.CountermodelExtraction
Verified/Bridge/PropSaturation.lean, Verified/Bridge/TemporalSaturation.lean
    import BoxSaturation
```

With `CountermodelExtraction.lean` red, **no module under `Bridge/` can be built at all**, so
Phase 27 as scheduled would have spent an entire dispatch unable to verify anything. The
executed sequence was therefore:

1. Phase 28's `CountermodelExtraction.lean` repair,
2. Phase 27's Bridge and Termination work,
3. Phase 28's tree-wide gate.

No task in either phase was skipped, altered, or deferred. The reordering is recorded in the plan
under both phase headings so a later reader does not read it as an accident.

---

## 1. What the guard change actually broke, and why it splits two ways

Phase 25 changed the fresh-label suppression test from

```lean
if witnessPresent rule sf branch timeOrd then none else some …
```

to

```lean
if witnessPresent rule sf branch timeOrd
    || trivialEventWitnessed rule sf branch timeOrd then none else some …
```

at `Tableau.lean:1956-1957` (the `.linear` arm) and `:1980-1981` (the `.branching` arm).

Every saturation lemma downstream reads that `if` backwards: from
`findApplicableRule … = none` it recovers the guard's condition. Under the old guard the
condition *was* `witnessPresent … = true`. Under the new one it is a disjunction, and the lemmas
split into **three** groups, not the two the plan's Scope Hypothesis anticipated:

| Group | Sites | Statement change | Why |
|---|---|---|---|
| **A. Second disjunct definitionally `false`** | `.boxNeg` (`CountermodelExtraction.lean:517`), `.boxNeg` witness in `MintBound.lean` | **none** | `trivialEventWitnessed` returns `false` on every rule outside the four positive temporal minting rules. The `||` still has to be *reduced*, but the guard collapses back to `witnessPresent` alone. |
| **B. Second disjunct refutable from a hypothesis already in scope** | `.untlPos`, `.sncePos` (both files) | **none** | These are the genuine-Until / genuine-Since branches, which carry `hg' : (guard == ⊤) = false`. `trivialEventWitnessed` requires `guard == ⊤`, so `hg'` refutes it outright. |
| **C. Second disjunct genuinely reachable** | `.someFuturePos`, `.somePastPos` (both files) | **yes — the ordered-witness disjunct** | These are the `guard = ⊤` branches. When additionally `event = ⊤` — i.e. the formula is `F ⊤` / `P ⊤` — the guard fires on the *ordering* and the branch may carry no witness at all. |

Group C is the whole point. `trivialEventWitnessed` consults `timeOrd.futureOf` /
`timeOrd.pastOf` and **never reads the branch**. On `F ⊤` the old conclusion — "some `t'` at which
the event or the guard is *literally on the branch*" — is therefore **false**. The statements were
widened rather than asserted past their truth.

**Groups A and B are a finding, not a formality.** The plan sized Phase 28 at "four temporal
witness lemmas … mirroring Phase 27's disjunction". In fact only two of the four needed any
statement change, and `.boxNeg` — which the plan correctly ruled OUT of the suppression set —
still needed a one-line *proof* repair, because the `||` must be reduced even where the second
disjunct is definitionally `false`. That is a proof-script change, not a move of `.boxNeg` into
the suppression set: its conclusion, its hypotheses, and its consumer
(`Bridge/IntTruth.lean:381`) are all unchanged.

---

## 2. The widened statements

### `CountermodelExtraction.lean` — `sat_untl_pos`

```lean
(∃ t' ∈ b.knownTimes,
  (⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
  (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .untl event guard, ⟨w, t'⟩⟩ ∈ b))
∨ (event = Formula.top ∧ guard = Formula.top ∧ timeOrd.futureOf t ≠ [])
```

`sat_snce_pos` is the past-directed mirror, with `timeOrd.pastOf t ≠ []`.

### `Verified/Bridge/TemporalSaturation.lean` — `sat_untl_pos_future`

```lean
∃ t', strictBefore timeOrd t t' = true ∧
  ((t' ∈ b.knownTimes ∧
      ((⟨.pos, event, ⟨w, t'⟩⟩ ∈ b) ∨
        (⟨.pos, guard, ⟨w, t'⟩⟩ ∈ b ∧ ⟨.pos, .untl event guard, ⟨w, t'⟩⟩ ∈ b)))
    ∨ (event = Formula.top ∧ guard = Formula.top))
```

`sat_snce_pos_past` is the mirror, with `strictBefore timeOrd t' t`.

**`strictBefore` moved OUT of the disjunction and is now delivered unconditionally.** This is the
load-bearing design decision and it makes the bridge lemmas *stronger* in shape, not weaker:
`trivialEventWitnessed` tests exactly `futureOf`/`pastOf` non-emptiness, so an ordered witness is
available in the trivial case too, and `strictBefore_of_mem_futureOf` applies unchanged.

**What the trivial case trades away, stated plainly**: `t' ∈ b.knownTimes` and branch membership,
in exchange for `event = ⊤`. That is a usable trade, not a hollowing-out — `⊤` is true at every
label of every model, so the truth lemma's `untl` case gets its semantic witness obligation
discharged immediately, and it gets the *position* it actually needs from the unconditional
`strictBefore`.

**`t' ∈ b.knownTimes` is deliberately NOT asserted in the trivial case.** `futureOf` is a closure
over the ordering constraints and can name a time no branch formula mentions — the head note of
`TemporalSaturation.lean` says exactly this — so that membership is genuinely unavailable there.
Asserting it would have been the unsound convenience.

**No consumer broke.** `sat_untl_pos_future` and `sat_snce_pos_past` have **no term-level
consumers** at present: the only references are `TemporalGate.lean`'s import and prose mentions in
`Decidability.lean:79-80` and `Bridge/IntTruth.lean:541-542`. `sat_untl_pos` / `sat_snce_pos` in
`CountermodelExtraction.lean` likewise have none. The tree-wide green build is the check.

---

## 3. Phase 27 census (taken before any edit)

| Location | `witnessPresent` | Notes |
|---|---|---|
| `Bridge/BoxSaturation.lean` | 1 | `:241`, docstring prose |
| `Bridge/PropSaturation.lean` | 1 | `:23`, docstring prose |
| `Bridge/TemporalSaturation.lean` | 10 | 2 prose + 8 term-level (four `hwit` sites + four follow-up `simp only` unfoldings) |
| `Termination/Fuel.lean` | 6 | |
| `Termination/MintBound.lean` | 111 | |

`saturated_downward_closed`: **zero** occurrences anywhere under `Verified/`, in either spelling.
`trivialEventWitnessed`: zero under `Verified/` before this phase.

The plan's Scope Hypothesis for `Bridge/` — "the term-level surface is `TemporalSaturation.lean`'s
four `hwit` sites and nothing else" — is **confirmed exactly**.

### Per-module build results

| Module | Before | After | Jobs |
|---|---|---|---|
| `Bridge/BoxSaturation` | GREEN | GREEN (untouched) | 1357 |
| `Bridge/PropSaturation` | GREEN | GREEN (untouched) | 1358 |
| `Bridge/TemporalSaturation` | RED, 4 errors (`:115`, `:130`, `:160`, `:175`) | GREEN | 1359 |
| `Termination/Fuel` | GREEN | GREEN (untouched) | 1355 |
| `Termination/MintBound` | **RED, 2 errors** | GREEN | 1356 |
| `CountermodelExtraction` | RED, 5 errors | GREEN | 1353 |

Variant B held for `PropSaturation` and `BoxSaturation` — both were already green and needed no
edit. Variant A applied to `TemporalSaturation`.

---

## 4. Scope finding: `MintBound.lean` was red, independently of this dispatch

The Phase 26 record reads as "`CountermodelExtraction.lean` is the single red module in a
1355/1357-green build". **`Termination/MintBound.lean` was also red**, with 2 errors at `:5730`
and `:5731`.

This is **not** breakage caused by this dispatch, and that is measured rather than assumed:
MintBound's import closure is `Fuel → {TimeTypeBound, Saturation}` and **never reaches
`CountermodelExtraction`**; no file under `Termination/` references it. `Fuel.lean` — which
MintBound imports — was itself green throughout. The redness dates from Phase 25's edit to
`Tableau.lean`.

**Size: one `rfl` lemma plus its docstring.** Both errors are the same failure. The file installs a
local simp set for the `boxNeg` witness that includes
`wp_bn : witnessPresent .boxNeg freshWorldWitness freshWorldBranch TimeOrdering.empty = false`, but
had no counterpart for the guard's new second disjunct, so `false || trivialEventWitnessed …`
would not reduce and `findApplicableRule_freshWorldWitness` stalled. Adding

```lean
private theorem tw_bn :
    trivialEventWitnessed .boxNeg freshWorldWitness freshWorldBranch TimeOrdering.empty
      = false := rfl
```

to the `attribute [local simp]` list closes both. **None of the file's other 111 `witnessPresent`
occurrences were affected**, which is itself the confirmation the plan asked for — report 05 was
right not to name MintBound as a widening site.

---

## 5. Report 05 claim 11 settled: extraction returns `some`

Measured with a scratchpad driver compiled by `lake env lean` under a **900 s bound; actual
2.1 s, EXIT=0**. Fuel 1000 throughout. **No probe file was read, edited, or re-baselined** —
Phase 29.2 owns that.

| Measurement | Result |
|---|---|
| `buildTableau ((G p) → □(G p)) 1000 .Base` | `(2, 40)` — reproduces Phase 26 exactly |
| `extractCountermodelFromTableau …` | **`some`** |
| `decide … 10 1000 .Base` → `(isValid, isInvalid, isFuelExhausted)` | `(false, true, false)` |
| Extracted `SimpleCountermodel` | `trueAtoms = [p,p,p,p,p,p]`, `falseAtoms = [p]` |
| `SimpleCountermodel.isConsistent` | `false` |

**Claim 11 is confirmed `true`.** `DecisionProcedure.lean:209`'s `extractCountermodelSimple` call
is reached, and the procedure returns an honest `.invalid` verdict rather than stopping at
`.fuelExhausted`. **Phase 29.2's row 11 re-baselines to `true`, not to `false`.**

### Declared, bounded caveat — `isConsistent = false`

`SimpleCountermodel` is the **Layer-0** representation: it tracks only *which atoms* are true or
false and discards the `(world, time)` label. A branch that legitimately carries `T(p)` at some
labels and `F(p)` at the `boxNeg`-minted world therefore flattens to an atom list containing `p`
on both sides. This is a property of the Layer-0 flattening, **not** evidence that the branch is
unsatisfiable — Phase 26 measured that `saturateBlocked` never closes this branch, through step 48.

**It is not a regression.** Before the guard landed, this formula returned `(0, 0)` /
`.fuelExhausted`, so no countermodel was produced at all and there was nothing to be consistent.
The guard strictly improved the outcome.

**Un-owned question, flagged rather than settled**: whether `DecisionProcedure.lean:209` should
report the Layer-1 `SemanticCountermodel` (which keeps labels, and so can be consistent) instead
of, or alongside, the Layer-0 `SimpleCountermodel`. No phase of this plan owns that. It is raised
in the orchestrator handoff, not decided here.

---

## 6. Tree-wide gate — measured at exit

| Gate | Phase 24 baseline | Measured | Verdict |
|---|---|---|---|
| `lake build` (default target) | green, 2331 jobs | **green, 2331 jobs** | matches exactly |
| Live non-Boneyard `sorry` | 1, `Metalogic/WeakCanonical/Transfer.lean:1084` | **1**, same location | unchanged |
| Actual `axiom` declarations | 0 | **0** | unchanged |
| Lines matching `^axiom ` | 6 | **6** | unchanged |
| New `sorry` / new `axiom` in this diff | — | **0 / 0** | clean |
| `witnessPresent` definition | byte-identical since Phase 25 | `Tableau.lean` **untouched this dispatch**, `git diff` empty | unchanged |

**On the "6 axioms" figure.** The Phase 28 Verification bullet reads as though six real axioms
exist. They do not. All six `^axiom ` matches are **prose lines inside comments and docstrings**
that happen to begin with the word "axiom" at column 0 —
`Semantics/Extension/Extension.lean:175`, `Semantics/TaskFrame.lean:516`,
`Semantics/FrameAxioms.lean:22` and `:262`, plus two under `Boneyard/`. There are **zero** actual
`axiom` declarations in `FormalSystem/`, inside Boneyard or out. The count is unchanged either
way; the clarification is recorded so a later reader does not go hunting for six axioms.

Files changed, all three under the declared territory:

```
FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean       | 119 +++++++++-----
FormalSystem/Metalogic/Decidability/Verified/Bridge/TemporalSaturation.lean | 131 +++++++++++-----
FormalSystem/Metalogic/Decidability/Verified/Termination/MintBound.lean     |   9 +-
```

No probe file was weakened, deleted, fuel-lowered, excluded from the build, or re-baselined. No
`sorry` was introduced. No axiom was introduced. `witnessPresent` is unmodified.

---

## 7. `[UNVERIFIED]` at exit

- **`lake build BimodalTest`** — not run. It is a separate target, it hangs, and **Phase 29.1 owns
  it**. Its state is unchanged from the Phase 21 record: unmeasured, not green.
- **The ten pre-existing `#guard_msgs` mismatches** — untouched and still excluded by name.
- **Probe row 9's pinned `(0, 0)`** — still pinned as-is in
  `Tests/BimodalTest/BoxNegReachabilityProbe.lean`. The measured value is `(2, 40)`, recorded for
  Phase 29.2, **not applied**.

---

## 8. Commits

| Commit | Content |
|---|---|
| `f1becd953` | phase 28.1 — `CountermodelExtraction.lean` under the widened guard (module green, 1353 jobs) |
| `023072412` | phase 27 — Bridge variant A, PropSaturation/BoxSaturation variant B, MintBound scope finding |
