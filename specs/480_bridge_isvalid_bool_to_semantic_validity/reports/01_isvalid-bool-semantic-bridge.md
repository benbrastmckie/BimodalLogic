# Research Report: Bridging `isValid`'s `Bool` to Semantic Validity

**Task**: 480 — `bridge_isvalid_bool_to_semantic_validity`
**Type**: lean4 | **Session**: `sess_1787662855_e59fd5_480` | **Dispatch**: 1
**File scope**: `FormalSystem/Metalogic/Decidability/Correctness.lean`,
`FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`

---

## Executive Summary

The task is **fully solved and verified**. Every theorem proposed below was written, compiled
against the current tree with `lake env lean`, and checked with `#print axioms`. All are
sorry-free and depend only on `[propext, Classical.choice, Quot.sound]`. No new imports are
needed; no changes outside `Correctness.lean` are required for the theorems themselves.

Three findings materially shape the implementation, and each *strengthens* the deliverable
beyond the sketch in the task description:

1. **The right core lemma is about `DecisionResult`, not about `isValid`.** Stating
   `sound_of_isValid (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ` once covers *every*
   entry point — `decide`, `decideBlocking`, `decideAuto`, `decideAutoAdaptive` — because they
   all return the same result type. `isValid_sound` then becomes a one-line corollary. Proving
   it directly against `isValid`'s unfolding would produce a weaker lemma that has to be
   re-proved for `decideBlocking`.
2. **The conclusion is `⊨ φ` unrelativized, and it is independent of `fc`.** This is not a
   simplification — it is forced by the types. `DecisionResult.valid` carries `⊢ φ`, which is
   `DerivationTree FrameClass.Base [] φ`; the payload is a *Base* derivation no matter which
   `fc` was passed to `decide`. So `isValid φ .Dedekind = true` yields validity over **all**
   task frames, not merely Dedekind ones. The four frame-class-relativized forms are then free
   corollaries via the already-landed `Validity.valid_implies_*` monotonicity lemmas.
3. **The module docstrings in scope actively contradict the new theorem and must be amended.**
   `Correctness.lean:98-105` states "No such statement is written here until it can be proved",
   and `Decidability.lean:144-147` says the `isValid`-shaped statement is open. Both refer to
   the *biconditional*; landing the sound direction makes that prose misleading unless it is
   narrowed to say the *completeness* direction alone is still owed. This is a required edit,
   not a nicety — leaving it is exactly the name/proof mismatch the retirement note exists to
   prevent.

**Negative finding (must not be attempted):** `isKnownValid = true → ⊨ φ` is **not** provable
today. `isKnownValid` is true on `extractionFailed`, which carries no `⊢ φ` witness; deriving
validity from a closed tableau is the open `valid_iff_allClosed` obligation (task 430) plus the
extraction-completeness obligation (task 482). Any plan phase that proposes it is proposing open
mathematics under an engineering label.

---

## What Already Exists (verified in-tree)

| Fact | Location | Status |
|------|----------|--------|
| `decide_sound (φ) (d : ⊢ φ) : ⊨ φ` | `Correctness.lean:61` | landed, sorry-free |
| `decide_sound' … (_h : decide … = .valid proof) : ⊨ φ` | `Correctness.lean:68` | landed; `_h` unused |
| `DecisionResult` (4 constructors, in `Type`) | `DecisionProcedure.lean:76-85` | — |
| `DecisionResult.isValid : … → Bool` (`valid _ => true`, else `false`) | `DecisionProcedure.lean:93` | — |
| `isValid (φ) (fc := .Base) : Bool := (decide φ (fc := fc)).isValid` | `DecisionProcedure.lean:317` | — |
| `isTautology φ fc := isValid φ fc` | `DecisionProcedure.lean:460` | — |
| `isContradiction φ fc := isValid φ.neg fc` | `DecisionProcedure.lean:465` | — |
| `isSatisfiable φ fc := decide ¬(isValid φ.neg fc = true)` | `DecisionProcedure.lean:323` | — |
| `valid φ` = truth at every `D, F, M, τ` total, `t` | `Semantics/Validity.lean:100`; notation `⊨` at `:103` | — |
| `Validity.valid_implies_valid_dense` | `Semantics/Validity.lean:349` | landed |
| `Validity.valid_implies_valid_discrete` | `Semantics/Validity.lean:356` | landed |
| `Validity.valid_implies_validDedekind` | `Semantics/Validity.lean:364` | landed |
| `Validity.valid_implies_validDedekindDense` | `Semantics/Validity.lean:371` | landed |

Baseline: `lake build FormalSystem.Metalogic.Decidability.Correctness` completes successfully
(1391 jobs, exit 0). `Correctness.lean` and `DecisionProcedure.lean` contain zero `sorry`
occurrences in code (the single textual hit at `Correctness.lean:96` is the phrase "sorry-free"
in prose).

---

## The Statement Question: which form does downstream need?

The task description asks whether to state `isValid_sound` unrelativized or in a
frame-class-relativized form. **Answer: state the unrelativized `⊨ φ` form as primary, and add
the three relativized forms as corollaries.** Reasoning:

- `⊨ φ` (`Semantics/Validity.lean:100`) quantifies over every temporal type `D` with
  `AddCommGroup`/`LinearOrder`/`IsOrderedAddMonoid`/`Nontrivial`, with no frame-class side
  condition. The frame-class-relative predicates `ValidDense`, `ValidDiscrete`,
  `ValidDedekindDense` (`Validity.lean:206`, `:248`, `:336`) simply add binders, so `⊨ φ` is the
  *strongest* of the four.
- `decide_sound` already delivers `⊨ φ` from a Base derivation, and — the load-bearing point —
  the `.valid` constructor's payload type is `⊢ φ` = `DerivationTree FrameClass.Base [] φ` for
  *every* `fc`. So no weakening is possible or needed; relativizing the conclusion to match `fc`
  would deliver strictly less than what is provable.
- The "four `Decidable` instances" the task alludes to would be
  `Decidable (⊨ φ)`, `Decidable (ValidDense φ)`, `Decidable (ValidDiscrete φ)`,
  `Decidable (ValidDedekindDense φ)`. Each needs a biconditional, so none can be built from this
  task's output alone; but each will consume its *sound* half from exactly the corollary shapes
  given below. Providing all four now means task 430 has nothing to re-derive on this side.

Note for task 430's benefit: the fact that `isValid φ .Dense = true` yields unrelativized `⊨ φ`
means the eventual biconditional at `fc = .Dense` **cannot** be `isValid φ .Dense = true ↔ ⊨ φ`
in the naive form — its right-to-left direction would be false in general if the Dense engine can
close tableaux for formulas valid only on dense orders. Whichever way that resolves, it is a
constraint on 430's statement, discovered here, and worth carrying forward.

---

## Verified Implementation (compiles as written)

All of the following was compiled as a single file importing only
`FormalSystem.Metalogic.Decidability.Correctness`. Insert into `Correctness.lean` immediately
after `decide_sound'` (i.e. after line 71), inside the existing
`namespace FormalSystem.Metalogic.Decidability` and its existing `open` block. **No new imports.**

### Core lemma

```lean
theorem sound_of_isValid {φ : Formula} (r : DecisionResult φ) (h : r.isValid = true) : ⊨ φ := by
  cases r with
  | valid proof => exact decide_sound φ proof
  | invalid c => simp [DecisionResult.isValid] at h
  | fuelExhausted => simp [DecisionResult.isValid] at h
  | extractionFailed => simp [DecisionResult.isValid] at h
```

`DecisionResult φ` lives in `Type` (its `valid` constructor carries derivation *data*), so
eliminating into the `Prop` goal `⊨ φ` is unproblematic — no large-elimination restriction
applies. The three non-`valid` arms reduce `DecisionResult.isValid` definitionally to `false`,
and `simp` closes `false = true`.

### The target theorem and its Bool-API siblings

```lean
theorem isValid_sound (φ : Formula) (fc : FrameClass) (h : isValid φ fc = true) : ⊨ φ :=
  sound_of_isValid _ h

theorem decide_isValid_sound (φ : Formula) (searchDepth tableauFuel : Nat) (fc : FrameClass)
    (h : (decide φ searchDepth tableauFuel fc).isValid = true) : ⊨ φ :=
  sound_of_isValid _ h

theorem isTautology_sound (φ : Formula) (fc : FrameClass)
    (h : isTautology φ fc = true) : ⊨ φ :=
  isValid_sound φ fc h

theorem isContradiction_sound (φ : Formula) (fc : FrameClass)
    (h : isContradiction φ fc = true) : ⊨ φ.neg :=
  isValid_sound φ.neg fc h

theorem not_isSatisfiable_sound (φ : Formula) (fc : FrameClass)
    (h : isSatisfiable φ fc = false) : ⊨ φ.neg := by
  simp only [isSatisfiable, decide_eq_false_iff_not, not_not] at h
  exact isValid_sound φ.neg fc h
```

`isTautology_sound` and `isContradiction_sound` typecheck by *definitional* unfolding
(`isTautology φ fc` is literally `isValid φ fc`), so no tactic is needed.

### Frame-class-relativized corollaries

```lean
theorem isValid_validDense (φ : Formula) (fc : FrameClass) (h : isValid φ fc = true) :
    ValidDense φ :=
  Validity.valid_implies_valid_dense (isValid_sound φ fc h)

theorem isValid_validDiscrete (φ : Formula) (fc : FrameClass) (h : isValid φ fc = true) :
    ValidDiscrete φ :=
  Validity.valid_implies_valid_discrete (isValid_sound φ fc h)

theorem isValid_validDedekindDense (φ : Formula) (fc : FrameClass) (h : isValid φ fc = true) :
    ValidDedekindDense φ :=
  Validity.valid_implies_validDedekindDense (isValid_sound φ fc h)
```

### Alternate-entry-point corollaries

```lean
theorem decideBlocking_isValid_sound (φ : Formula) (searchDepth tableauFuel : Nat)
    (fc : FrameClass) (maxBranches : Nat)
    (h : (decideBlocking φ searchDepth tableauFuel fc maxBranches).isValid = true) : ⊨ φ :=
  sound_of_isValid _ h

theorem decideAuto_isValid_sound (φ : Formula) (fc : FrameClass)
    (h : (decideAuto φ fc).isValid = true) : ⊨ φ :=
  sound_of_isValid _ h
```

These are free: they are the same `sound_of_isValid` applied at a different result term. They
matter because `decideBlocking` (`DecisionProcedure.lean:283`) is a second, independently
maintained entry with its own `.valid` arms, and `decideAuto`/`decideAutoAdaptive` are what the
dataset drivers actually call.

### Verified axiom cleanliness

Every theorem above was checked. Representative output (the probe file used the provisional name
`isValid_sound_dedekind` for what is proposed above as `isValid_validDedekindDense`; the
statement and proof are identical):

```
'FormalSystem.Metalogic.Decidability.sound_of_isValid' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.isValid_sound' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.isContradiction_sound' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.isValid_sound_dedekind' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.decideBlocking_isValid_sound' depends on axioms:
  [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.Decidability.not_isSatisfiable_sound' depends on axioms:
  [propext, Classical.choice, Quot.sound]
```

No `sorryAx`. Acceptance criterion "`#print axioms` clean" is met.

---

## Tactic Survey Results

| Goal | Approach | Result | Notes |
|------|----------|--------|-------|
| `sound_of_isValid`, `.valid` arm | `exact decide_sound φ proof` | success | direct |
| `sound_of_isValid`, other 3 arms | `simp [DecisionResult.isValid] at h` | success | `h : false = true` after defeq reduction |
| `isValid_sound` | `sound_of_isValid _ h` (term mode) | success | unification finds `r := decide φ 10 1000 fc` |
| `isTautology_sound` | `isValid_sound φ fc h` (term mode) | success | definitional; no tactic |
| `not_isSatisfiable_sound` | `simp at h` (unrestricted) | **fail** | `maximum recursion depth` — `simp` tries to evaluate the `decide` term |
| `not_isSatisfiable_sound` | `simp only [isSatisfiable, decide_eq_false_iff_not, not_not] at h` | success | targeted rewriting avoids the blow-up |
| relativized corollaries | `Validity.valid_implies_*` (term mode) | success | all four monotonicity lemmas pre-exist |

The one real pitfall found: an unrestricted `simp at h` on the `isSatisfiable` hypothesis exceeds
`maxRecDepth` because `isSatisfiable` unfolds to `Decidable.decide ¬(isValid φ.neg fc = true)` and
`simp` attempts to reduce the enclosed decision-procedure call. Use `simp only` with the three
named lemmas. Do **not** work around this by raising `maxRecDepth`.

---

## Required Documentation Amendments

These are in file scope and are part of the deliverable, not optional polish.

1. **`Correctness.lean:16-24` (module "Main Theorems" list)** — add `sound_of_isValid` /
   `isValid_sound` as the Bool-API bridge.
2. **`Correctness.lean:98-105`** — the paragraph "What is still owed, and is deliberately not
   stated here" currently reads as though *no* `isValid`-shaped statement exists. Narrow it: the
   **sound direction is now landed**; what remains owed is the **completeness direction**
   (`⊨ φ → isValid φ fc = true`) and therefore the biconditional and the four `Decidable`
   instances. Keep the retirement narrative for `validity_decidable` /
   `validity_has_decision_procedure` intact — it is about a different defect.
3. **`Decidability.lean:144-147`** — same narrowing. *This file is outside the declared
   `file_scope`.* Recommended handling: make the edit (it is three lines of prose and leaving it
   produces a documented contradiction), and record the scope extension explicitly in the
   implementation summary. If scope is to be held strictly, the alternative is a follow-up
   documentation task — but the contradiction must not simply be left in the tree.
4. Add a docstring note on `sound_of_isValid` recording the negative finding: `isKnownValid` is
   **not** a sound-direction hypothesis, because `extractionFailed` carries no witness. This is
   the F1 conflation guard the audit asked for, stated at the point of use.

---

## Risks and Non-Risks

- **Non-risk: proof fragility.** Every proof is either term-mode or a four-way `cases` with
  definitional reduction. Nothing depends on `decide`'s internal control flow, on fuel figures,
  or on tableau behaviour. Changing `decide`'s algorithm cannot break these.
- **Non-risk: build time.** All additions are in one already-built module, with no new imports.
- **Real risk: scope creep into task 430.** The temptation is to state the biconditional or an
  `isKnownValid` variant. Both are open. The completion gate for this task is the sound direction
  only.
- **Real risk: the docstring edit being skipped.** Landing `isValid_sound` while
  `Correctness.lean:105` still says no such statement is written is a self-contradicting tree.
  Treat item 2 above as blocking.
- **Minor: linter.** A `getProof?`-shaped variant
  (`sound_of_getProof? (h : r.getProof? = some d) : ⊨ φ`) compiles but triggers the
  `unusedVariables` linter, since `d`'s type already carries the content. It is not recommended;
  `sound_of_isValid` subsumes it.

---

## Recommended Phase Decomposition

A single implementation phase is appropriate; the work is roughly 60 lines of Lean plus
docstrings, well inside one agent run.

**Phase 1 — Land the bridge and amend the prose.**
- Insert the ten theorems above into `Correctness.lean` after line 71, with docstrings.
- Amend `Correctness.lean:16-24` and `:98-105`; amend `Decidability.lean:144-147`.
- Verify: `lake build` green; `#print axioms` on all new theorems shows exactly
  `[propext, Classical.choice, Quot.sound]`; `grep -c sorry` unchanged (1 prose hit in
  `Correctness.lean`, 0 in `DecisionProcedure.lean`).

If the planner prefers two phases, split at the docstring boundary (theorems first, prose second)
— but both must land before the task is complete.

---

## Sources

All claims verified in-tree at commit `09b87a88a`. No external literature was referenced; the
task cites no literature source, so the literature-extraction protocol does not apply.
