# Implementation Summary: Task #509

- **Task**: 509 - Parameterize the compactness and strong-completeness family by `FrameClass`
- **Plan**: `specs/509_parameterize_compactness_and_strong_completeness_family/plans/01_frameclass-indexed-compactness-family.md`
- **Type**: lean4
- **Status**: Complete — all six phases closed
- **Session**: sess_1788282938_f2ac03

## What Landed

The satisfiability / model-existence / compactness / strong-completeness row is now **one
`FrameClass`-indexed family**, defined once in `FormalSystem/Metalogic/SetConsequence.lean`:

| Declaration | Location |
|---|---|
| `SatisfiableSet (fc) (Γ)` | `SetConsequence.lean:153` |
| `ModelExistence (fc)` | `:163` |
| `Compact (fc)` | `:174` |
| `StrongCompleteness (fc)` | `:184` |
| `SatisfiableSet.base_of_forall` / `.dense_of_forall` / `.discrete_of_forall` / `.dedekind_of_forall` | `:299` / `:305` / `:315` / `:325` |

All **eleven** per-class names are retained as instantiations with statements unchanged
(`StrongCompletenessBase:446`, `CompactBase:453`, `SatisfiableBaseSet:466`,
`ModelExistenceBase:478`, the four Dense siblings at `:494/:499/:505/:517`, and the three
Discrete ones at `:539/:559/:566`). The plan's prose says "ten"; its own table enumerates eleven,
and eleven were done.

The four duplicated theorems became **two**, both generic in `fc`, in
`FormalSystem/Metalogic/StrongCompleteness.lean`:

| Was | Now |
|---|---|
| `strongCompletenessBase_of_compact` + `strongCompletenessDense_of_compact` | `strongCompleteness_of_compact:356` |
| `compactBase_of_modelExistence` + `compactDense_of_modelExistenceDense` | `compact_of_modelExistence:404` |

Both keep their `engine` / hypothesis parameters live, per task 493's explicit instruction. The
one edit outside `FormalSystem/Metalogic/` is the generic `ValidIn.of_not`
(`FormalSystem/Semantics/Validity.lean:514`), which the collapsed bridge's contrapositive needs
and which was missing tree-wide although all four per-class `of_not` lemmas existed.

## Why It Was Cheap: Task 507 Already Paid For It

`Semantics/Validity.lean` defines `valid := ValidIn .Base`, `ValidDense := ValidIn .Dense`,
`ValidDiscrete := ValidIn .Discrete` as plain `def`s. So `Compact fc` stated with `ValidIn fc (…)`
is **definitionally equal** to the per-class versions. Verified by compiled `rfl` before the
redefinition landed:

```
Compact .Base = CompactBase            StrongCompleteness .Base = StrongCompletenessBase
Compact .Dense = CompactDense          StrongCompleteness .Dense = StrongCompletenessDense
Compact .Discrete = CompactDiscrete    StrongCompleteness .Discrete = StrongCompletenessDiscrete
SatisfiableSet .Dense = SatisfiableDenseSet    ModelExistence .Dense = ModelExistenceDense
```

Eight `rfl`s; no proof work was performed where `rfl` sufficed. The two exceptions,
`SatisfiableBaseSet` and `SatisfiableDiscreteSet`, were verified propositionally equivalent
first, then *made* definitional by being redefined as the instantiations.

## Acceptance

| Criterion | Result |
|---|---|
| `lake build FormalSystem BimodalTest` | **green, 2566 jobs**, explicit targets, zero errors |
| Sorry-free | live scope (`FormalSystem/` outside `Boneyard/`) has **zero** structural sorries; census `sorry_inventory` empty after excluding the pre-existing `Boneyard` set |
| New axioms | **none** — `^axiom ` count is 8 at both `ac6080ae2` (pre-implementation) and HEAD |
| Axiom profile | all twelve audited declarations report exactly `[propext, Classical.choice, Quot.sound]` |

Audited: `compactBase`, `compactDense`, `strongCompletenessBase`, `strongCompletenessDense`,
`modelExistenceBase`, `modelExistenceDense`, `compact_of_modelExistence`,
`strongCompleteness_of_compact`, `archWitness_finitely_satisfiable`,
`archWitness_not_satisfiable`, `discrete_consequence_not_compact`,
`strongCompletenessDiscrete_refuted`.

Nothing was discharged. `ModelExistenceBase`/`ModelExistenceDense` keep their existing
ultraproduct proofs; every conditional result is exactly as strong as before.

### Gates

| Gate | Result |
|---|---|
| `scripts/readme-lint.sh` | FAIL on **exactly** the recorded pre-existing exclusion — `MISSING: FormalSystem/Semantics/Ultraproduct/README.md`. Broken references: 0. No new failure. |
| `scripts/check-module-invariants.sh` | Only C6 fails, on **exactly** the recorded pre-existing exclusion: the same four unmanifested unreachable modules (`SpWitness`, `TMCompletenessReduction`, `Z1Countermodel`, `Semantics.LexCarrier`). **C14 PASSES both halves** — documented axiom/sorry counts, and the axiom baseline for `sound_of_isValid` / `completeness_dedekind` / `strongCompletenessBase` / `strongCompletenessDense`. **C15 PASSES** (47 paper anchors). C3 (structural sorry inventory ZERO), C5, C12 and C13 (markdown path and link resolution) all pass, so no citation edit in Phase 5 broke a reference. |

## The Friction Points, and Four Sites the Plan Did Not Enumerate

Both planned friction points behaved as the probes recorded:

1. **`SatisfiableDiscreteSet` re-nesting.** `Sat .Discrete` is `TaskFrame.IsSuccArchDiscrete`, a
   plain `def` wrapping `∃ (_ : SuccOrder D) (_ : PredOrder D), _ ∧ _`, which the anonymous
   constructor does not unfold. Introduction sites (`DiscreteNonCompactness.lean:197`, `:256`,
   `:285`) went through `SatisfiableSet.discrete_of_forall`; the `rintro` at `:229` re-nested.
2. **`Compactness.lean`'s bare `inferInstance`.** Type-ascribed, per `probe_509c.lean` §C3.
   Instance synthesis reduces only at reducible transparency, so it could not see through
   `TaskFrame.IsDense`.

Phase 3's Scope Hypothesis ("exactly six call sites") was **falsified**. Four further sites
needed repair, all handled in the same phase per that hypothesis's own instruction:

| Site | What broke | Repair |
|---|---|---|
| `DiscreteNonCompactness.lean:259`, `:288` | the two `obtain ⟨F, _, _, _, _, M, …⟩` *eliminations* of `archWitness_finitely_satisfiable`; the plan enumerated only introduction sites | one nesting pair each |
| `DiscreteNonCompactness.lean:261` | `hvalid.apply` — `hc _ _ hcons` now yields `ValidIn .Discrete φ`, so dot notation resolves on `ValidIn`, which has no `.apply` | spelled out as `ValidDiscrete.apply hvalid F M τ hτ t`, accepted by defeq |
| `Compactness.lean:85` | `choose F M τ hτ t ht` — `SatisfiableBaseSet` gained the `∃ _ : True` slot, so `choose` must bind one more component | `choose F _hF M τ hτ t ht` |

## Plan Deviations

1. **Phase 4's commit boundary merged into Phase 3's `atomic-batch`** *(altered)*. Phase 3's
   redefinition of `SatisfiableBaseSet` / `SatisfiableDenseSet` breaks the *bodies* of the four
   theorems Phase 4 deletes — `compactBase_of_modelExistence`'s `refine ⟨F, M, τ, hτ, t, ?_⟩`
   loses its slot count, and `compactDense_of_modelExistenceDense`'s bare `inferInstance` goes
   invisible. Committing Phase 3 alone green would have required throwaway repairs to two
   theorems deleted minutes later — the same throwaway-transport pattern the plan forbids for
   `modelExistenceBase'`. Every task in both phases was executed as written and in the planned
   order (redefinition first, then theorem collapse); only the commit boundary moved.
2. **`strongCompletenessDiscrete_of_compact` omitted** *(skipped)* — under the plan's own
   "otherwise omit rather than leave it unexplained" clause. Nothing consumes it, and the status
   it would record is already stated in `strongCompleteness_of_compact`'s docstring, which names
   `.Discrete` as the class where the reduction is live but the antecedent refuted.

No other step was skipped, altered, or deferred. The negative control
`probe_509b_negative_control.lean` is **untouched and still failing**, which is its purpose.

## Documentation Surface

Zero stale references remain outside `specs/`. Rewritten:

- **In-tree**: `FormalSystem/Metalogic.lean`, `Metalogic/StrongCompleteness.lean`,
  `Metalogic/Compactness.lean`, `Metalogic/SetConsequence.lean` (including its module docstring,
  which now records the indexing and the deliberate absence of the `.Dedekind` row), and
  `Metalogic/README.md`'s line counts.
- **Docs**: `docs/user-guide/architecture.md` (seven citation rows plus the reductions
  paragraph), `docs/reference/API_REFERENCE.md` (both tables), and
  `docs/project-info/known-limitations.md`.
- **Read and left alone, no claim became false**: `README.md:164`,
  `docs/project-info/implementation-status.md:68-69`,
  `docs/development/MODULE_ORGANIZATION.md:294-295`,
  `FormalSystem/Semantics/Ultraproduct/Carrier.lean:15`.

`FormalSystem/Metalogic/README.md`'s `StrongCompleteness.lean` line count was recorded as 943
against a live 1,060 — **pre-existing staleness from task 508**, not caused here. Corrected to
1,002 along with the other four counts.

## The Dedekind Handoff

**The follow-on task's Part 1 is four `abbrev`s and two one-line theorems**, not a fourth hand
copy of an eleven-declaration group. All six are **already compiled**, in `probe_509.lean` Part E:

```lean
abbrev SatisfiableDedekindDenseSet : Set Formula → Prop := SatisfiableSet FrameClass.Dedekind
abbrev ModelExistenceDedekindDense : Prop := ModelExistence FrameClass.Dedekind
abbrev CompactDedekindDense        : Prop := Compact FrameClass.Dedekind
abbrev StrongCompletenessDedekindDense : Prop := StrongCompleteness FrameClass.Dedekind

theorem compactDedekindDense_of_modelExistence (h : ModelExistenceDedekindDense) :
    CompactDedekindDense := compact_of_modelExistence h

theorem strongCompletenessDedekindDense_of_compact (hc : CompactDedekindDense) :
    StrongCompletenessDedekindDense :=
  strongCompleteness_of_compact hc (fun ψ hψ => completeness_dedekind ψ hψ)
```

The engine is already available and already of exactly the right shape: `completeness_dedekind`
(`StrongCompleteness.lean:566`), since `ValidDedekindDense = ValidIn .Dedekind` definitionally.
Its consequence-relation counterpart `SetSemanticConsequenceDedekindDense` **already exists**
(`SetConsequence.lean:125`, with `.of_forall` / `.apply` at `:271` / `:280`) — task 508 landed
it. The `SatisfiableSet.dedekind_of_forall` adapter (`SetConsequence.lean:325`) landed here.
Dedekind is now absent only as a *name*, not as available structure.

**Why the follow-on's Part 2 stays genuinely hard.** The `.Dedekind` satisfiability slot is
`IsDedekind F = IsDense F ∧ IsComplete F` (`Semantics/FrameProperty.lean:172`) — an `And`, with
no successor structure at all. The `Order.succ^[n]` machinery that `archWitness_not_satisfiable`
(`DiscreteNonCompactness.lean:229`) turns on has nothing to act on, so `archWitness` **cannot be
reused** and a genuinely new non-compactness witness is required. The Dedekind adapter's binder
shape is `⟨F, ⟨inst, hlub⟩, M, τ, hτ, t, h⟩`, compiled in
`probe_509b_negative_control.lean` §B6 — one of the control file's deliberately *succeeding*
fragments.

## Files Modified

| File | Change |
|---|---|
| `FormalSystem/Semantics/Validity.lean` | `+13/-0` — the generic `ValidIn.of_not` |
| `FormalSystem/Metalogic/SetConsequence.lean` | the indexed family, four adapters, eleven redefinitions, module docstring |
| `FormalSystem/Metalogic/StrongCompleteness.lean` | four theorems become two; `#print axioms` block and audit prose rewritten |
| `FormalSystem/Metalogic/Compactness.lean` | `choose` arity, `trivial` slot, ascribed `inferInstance`, four call sites rewired |
| `FormalSystem/Metalogic/DiscreteNonCompactness.lean` | six tuple/pattern sites reshaped |
| `FormalSystem/Metalogic.lean` | prose: two reductions become one, two bridges become one |
| `FormalSystem/Metalogic/README.md` | five line counts corrected |
| `docs/user-guide/architecture.md`, `docs/reference/API_REFERENCE.md`, `docs/project-info/known-limitations.md` | citations and prose |
