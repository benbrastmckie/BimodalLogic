# Implementation Plan: Task #507 (v2)

- **Task**: 507 - Parameterize validity by FrameClass (frame-level shape)
- **Status**: [NOT STARTED]
- **Effort**: 12.5 hours
- **Dependencies**: None (the TaskFrame duration-bundling refactor this direction depends on has ALREADY LANDED -- see "Blocker resolution, verified" below)
- **Research Inputs**: `specs/507_parameterize_validity_by_frameclass/reports/01_frameclass-indexed-validity.md`
- **Artifacts**: plans/02_frame-level-validity-indexing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **Supersedes**: `plans/01_frameclass-indexed-validity.md` (duration-quantified `Sat`/`ValidIn` -- explicitly NOT the wanted notion; must not be followed)

## Overview

The proof side is fully parameterized by `FrameClass` (`Derivable fc`, `DerivationTree fc`,
`DerivationTree.lift` along `fc₁ ≤ fc₂`, `PartialOrder FrameClass`, `Axiom.minFrameClass` as the
declared single source of truth). The semantic side has none of it: 15 hand-copied validity
predicates and a family of copied semantic-consequence variants, each carrying an inlined binder
list instead of deriving its frame constraint from the class tag. This plan gives the `FrameClass`
tag a **semantic interpretation on bundled frames** and defines validity once against it:

```lean
FrameClass.Sat : FrameClass → TaskFrame → Prop            -- a predicate on FRAMES
ValidIn (fc : FrameClass) (φ : Formula) : Prop := ∀ F : TaskFrame, fc.Sat F → F.ValidOn φ
```

This mirrors `Derivable fc` exactly, which is the symmetry the task exists to restore.
`TaskFrame.ValidOn` (`def:frame-validity`) stays the single frame-level primitive and is not
duplicated. Definition of done: `Sat` interprets every `FrameClass` constructor as a named,
paper-grounded frame predicate; `ValidIn` and `SetSemanticConsequenceOn` are each defined once;
one monotonicity lemma replaces the five hand-written validity bridges and the four copied
set-consequence bridges; and every legacy predicate is either an abbreviation over the new
primitive or retired, with all call sites migrated.

### Blocker resolution, verified

The delegation required this plan to state explicitly whether the tree already bundles duration
into `TaskFrame`. **It does.** Verified by reading the source, not assumed:

- `FormalSystem/Semantics/TaskFrame.lean:1608` -- `structure TaskFrame where Duration : TemporalOrder; toFibre : FrameOver Duration`. Its own module docstring states the motivation in the exact terms this task needs: "a property of the temporal order alone cannot be predicated of a frame while the order is an *index* ... With `Duration` a field they are ordinary predicates on a `TaskFrame` -- `def:frame-properties` reads as the paper states it."
- `FormalSystem/Semantics/TemporalOrder.lean:76` -- `TemporalOrder` bundles the four algebra instances as instance-implicit fields.
- Every current validity predicate already quantifies `∀ (F : TaskFrame)` with `F.Duration`-indexed constraints (e.g. `ValidDense` at `Semantics/Validity.lean:199`).

**Consequence: no bundling phase is needed and no blocker is declared.** `Sat` can be a predicate
on frames today.

### Research Integration

What survives from `reports/01_frameclass-indexed-validity.md`, re-verified against the current
tree rather than taken on trust:

| Finding | Status against current tree |
|---------|------------------------------|
| The `FrameConditions` marker typeclasses are NOT reusable (`DiscreteTemporalFrame` omits `IsPredArchimedean`, silently widening the discrete class under `soundness_discrete`; `SerialFrame` adds `NoMaxOrder`/`NoMinOrder`) | **Holds.** `FrameConditions/Validity.lean:90` binds `[SuccOrder][PredOrder][IsSuccArchimedean][DiscreteTemporalFrame]` -- no `IsPredArchimedean` -- while `Semantics/Validity.lean:239`'s `ValidDiscrete` binds all four. Do not consume the marker layer. |
| `Sat` must be `Prop`-valued with an existential `Discrete` case, because `SuccOrder`/`PredOrder` are data-carrying | **Holds.** Both are structures carrying a function field. |
| `FrameConditions/Validity.lean` is nearly all dead code | **Verified stronger than reported.** `ValidLinear`, `ValidDenseFc`, `ValidDiscreteFc`, `ValidOnInt` each occur in exactly two files: their own, and the `FrameConditions.lean` aggregator's prose. `FrameConditions/Soundness.lean` -- the only other importer -- references none of them. Zero live consumers. |
| `ValidInt` / `ValidOnInt` are a definitional duplicate | **Holds.** `Semantics/IntTransfer.lean:374` and `FrameConditions/Validity.lean:192` are the same predicate; `ValidOnInt` has no external consumer. |
| Module placement: a new module in `Semantics/`, importing `Semantics.Validity` + `ProofSystem.Axioms` | **Holds; acyclicity re-verified.** `ProofSystem/Axioms.lean` imports only `FormalSystem.Syntax.Formula`, and no file under `ProofSystem/` imports `FormalSystem.Semantics`. |
| `haveI` on destructured instance binders breaks defeq with instances baked into dependent types; pass positionally with `@` | **Carry into implementation.** The in-tree warning at `Metalogic/SetConsequence.lean` is the precedent. |
| C14 scans docstrings for stale axiom counts; C15 pins paper anchors | **Carry into implementation.** See Risks. |

**Rejected from the report**: its recommendation to rename `ValidDedekind → ValidComplete`. See the
naming decision below.

### Prior Plan Reference

`plans/01_frameclass-indexed-validity.md` is superseded and must not be followed: its Phase 1
defines `FrameClass.Sat (fc) (D : Type) [insts]` -- a predicate on the **carrier type** -- and a
duration-quantified `ValidIn`. That is duration validity, and landing it would harden the wrong
notion into the tree's single validity definition. What is taken from it as *reference only*:

- Effort calibration: 7 phases / 10.5h for a scope that assumed a 92-site binder-list migration.
  This plan re-scopes against the post-bundling tree (the binder-list migration is largely
  dissolved: constraints are already `F.Duration`-indexed) but adds the `valid` migration and a
  dedicated acceptance gate, landing at 9 phases / 12.5h.
- Its risk inventory (C2/C14 axiom baselines, `decide` on `FrameClass` order goals, the
  existential-instance hazard) is imported into Risks below.
- No phase is copied from it.

### Roadmap Alignment

`specs/ROADMAP.md` exists and was consulted. It carries no item that this plan directly closes;
its `isValid`-to-validity bridge item and the `minFrameClass = 45` anchor both sit downstream of
the vocabulary this plan unifies, so the plan is roadmap-compatible rather than roadmap-advancing.
No ROADMAP.md edits are in scope (`roadmap_flag` was not set).

### Grounding

`specs/reviews/review-2026-08-31-metalogic-systematicity.md` issue H1: "The semantic layer is not
indexed by `FrameClass`, while the proof layer is."

## The target design

### Paper grounding

`ValidIn fc` is the paper's class-restricted consequence `⊨_C`. `cor:tm-completeness` (pinned in
`specs/paper-definitions-of-record.md`): "Where `Γ ⊨_C φ` restricts `def:logical-consequence` to
models over task frames in a class `C` ...". `TaskFrame.ValidOn` is `def:frame-validity` and stays
the single frame-level primitive.

The frame predicates are `def:frame-properties`, verbatim: **Discrete** "if for any `x ∈ D`,
whenever there exists `y > x`, there is a least such `y' > x`"; **Dense** "if for any `x, y ∈ D`
where `x < y`, there exists `z ∈ D` where `x < z < y`"; **Complete** "if every nonempty `S ⊆ D`
bounded above has a least upper bound in `D`".

### The `Sat` interpretation of record

| Constructor | `Sat` | Anchor |
|-------------|-------|--------|
| `.Base` | `True` | -- (unconstrained: `def:logical-consequence`'s own class) |
| `.Dense` | `TaskFrame.IsDense F` (`DenselyOrdered F.Duration`) | `def:frame-properties` Dense |
| `.Discrete` | `TaskFrame.IsSuccArchDiscrete F` | `def:TMplus-f` (Hölder narrowing to `ℤ`-time) |
| `.Dedekind` | `TaskFrame.IsDedekind F` = `IsDense F ∧ IsComplete F` | `def:frame-properties` Complete + Dense; `cor:tm-completeness`'s TM⁺_c target |

**The Discrete property and the `ℤ`-time class are two predicates, not one.** `def:frame-properties`'s
bare Discrete clause is recorded as `TaskFrame.IsDiscrete`. `def:TMplus-f` narrows TM⁺_f's target to
`ℤ`-time via Hölder ("the successor-Archimedean discrete class to which BX_f and TM⁺_f are sound and
complete is exactly `ℤ`-time"), and it is *that* narrowed class the proof side's `FrameClass.Discrete`
admits axioms for (`prior_UZ`, `prior_SZ`, `z1`). So `Sat .Discrete` is the narrowed predicate
`IsSuccArchDiscrete`, and `IsDiscrete` stands beside it as the paper's bare property. Conflating the
two would silently widen the class under `soundness_discrete` -- the same defect the marker-typeclass
layer already has.

**The Complete property and the dense-and-complete class are likewise two predicates.**
`TaskFrame.IsComplete` is `def:frame-properties`'s bare Complete (which admits `ℤ`);
`TaskFrame.IsDedekind` is dense-and-complete, `cor:tm-completeness`'s TM⁺_c target and the
`soundness_dedekind` target. One predicate each, no bridged duplicates.

### Naming decision of record: `Dedekind`, not `Complete`

`def:frame-properties` calls this class **Complete**. This tree keeps `FrameClass.Dedekind`,
`TaskFrame.IsDedekind`, and `ValidDedekind` instead. This is a **deliberate, recorded deviation from
paper naming, and the only naming deviation sanctioned on this front**: "complete" is already
load-bearing here for *proof-theoretic* completeness (`completeness`, `completeness_dense`,
`completeness_discrete`, `completeness_dedekind`, `StrongCompleteness.lean`), so `FrameClass.Complete`
would collide with the tree's most-cited word; "Dedekind complete" is the standard and unambiguous
name for the order-theoretic property. The report's recommendation to rename `ValidDedekind →
ValidComplete` is **rejected** on the same ground.

The deviation MUST be documented at the definition site (`TaskFrame.IsDedekind` and
`FrameClass.Sat`), citing `def:frame-properties` as the definition of record and naming the
divergence explicitly. A docstring that cites the anchor without naming the divergence does not
satisfy this requirement.

### The one monotonicity lemma, and why it takes a predicate

`Sat` is **antitone** in the `FrameClass` order: a larger class tag means a *more constrained*
frame class. `.Base ≤ fc` for all `fc` (`Sat .Base = True`); `.Dense ≤ .Dedekind` and
`Sat .Dedekind F = IsDense F ∧ IsComplete F → IsDense F = Sat .Dense F`. So

```lean
ValidIn.mono : fc₁ ≤ fc₂ → ValidIn fc₁ φ → ValidIn fc₂ φ
```

points the same direction as `DerivationTree.lift` (`ProofSystem/Derivation.lean:184`), which is
the symmetry the review asked for.

`ValidIn.mono` is stated as a corollary of a primitive that is antitone in an arbitrary frame
predicate:

```lean
def ValidOnFrames (P : TaskFrame → Prop) (φ : Formula) : Prop := ∀ F, P F → F.ValidOn φ
def ValidIn (fc : FrameClass) (φ : Formula) : Prop := ValidOnFrames fc.Sat φ
theorem ValidOnFrames.mono {P Q} (h : ∀ F, Q F → P F) : ValidOnFrames P φ → ValidOnFrames Q φ
```

This is what lets **one** lemma cover all five existing bridges rather than four. `ValidDedekind`
(bare Complete) has no `FrameClass` member -- `ProofSystem/Axioms.lean`'s `FrameClass` docstring
states so explicitly -- so it cannot be `ValidIn`-anything, but it *is*
`ValidOnFrames TaskFrame.IsComplete`, and `validDedekindDense_of_validDedekind` then falls out of
the same `ValidOnFrames.mono`.

### The migration lever

`ValidIn` is defined through `TaskFrame.ValidOn`, whose history quantifier is the bundled
`(τ : TaskFrame.HF F)`, whereas every legacy predicate uses the predicate form
`(τ : WorldHistory F) (_ : τ.IsTotal)`. `valid_iff_forall_validOn` (`Semantics/Validity.lean:606`)
already proves these agree, but they are not definitionally equal, so redefining a legacy predicate
as an abbreviation changes the shape every `intro`/application site sees. To keep each call site a
mechanical one-line edit rather than a proof rewrite, Phase 2 lands the bridge pair **before** any
call site is touched:

```lean
theorem ValidOnFrames.of_forall_total {P φ}
    (h : ∀ (F : TaskFrame), P F → ∀ (M : TaskModel F) (τ : WorldHistory F),
           τ.IsTotal → ∀ t : F.Duration, TruthAt M τ t φ) : ValidOnFrames P φ
theorem ValidOnFrames.apply_total {P φ} (h : ValidOnFrames P φ)
    (F : TaskFrame) (hF : P F) (M : TaskModel F) (τ : WorldHistory F)
    (hτ : τ.IsTotal) (t : F.Duration) : TruthAt M τ t φ
```

Migration then reads: a goal site becomes `refine ValidOnFrames.of_forall_total ?_; intro F hF M τ hτ t`;
a hypothesis site becomes `h.apply_total F ⟨…⟩ M τ hτ t`. **No call-site phase may begin before
these two exist and are green.**

## Goals & Non-Goals

**Goals**:
- A `FrameClass → TaskFrame → Prop` interpretation, with each constructor mapped to a named,
  paper-anchored frame predicate.
- `ValidIn (fc) (φ)` and `SetSemanticConsequenceOn (fc) (Γ) (φ)` each defined exactly once.
- ONE monotonicity lemma replacing `valid_implies_valid_dense` / `_valid_discrete` /
  `_validDedekind` / `_validDedekindDense` (`Semantics/Validity.lean:339,346,354,361`) and
  `validDedekindDense_of_validDedekind` (`:373`), pointing the same direction as
  `DerivationTree.lift`; likewise ONE set-consequence monotonicity-in-`fc` lemma beside the
  existing single `setDerivable_mono`.
- Every legacy validity/consequence predicate retained as an abbreviation over the new primitive
  or retired outright, with every call site migrated.
- The `ValidDedekind` hazard closed structurally: the `.Dedekind` soundness target's binder list is
  computed from the frame class, so the refutable statement the `Validity.lean:292` docstring warns
  about becomes unwritable rather than merely warned against.
- Sorry-free; `lake build` green; `bash scripts/check-module-invariants.sh` passes; axiom profiles
  unchanged on the flagship theorems.

**Non-Goals**:
- Relocating `inductive FrameClass` out of `ProofSystem/Axioms.lean` into a shared low-level module.
  Cleaner layering, but it moves a namespace ~45 axiom constructors and every `DerivationTree`/
  `Derivable` signature reference. Follow-up if the `Semantics → ProofSystem.Axioms` seam proves
  unpopular.
- Renaming `ValidDedekind`, `FrameClass.Dedekind`, or introducing `FrameClass.Complete`. Explicitly
  rejected above.
- Adding a `FrameClass` member for bare Complete (TM⁺_c simpliciter). No axiom set for
  `Th(ℤ) ∩ Th(ℝ)` exists in this tree.
- New notation. `⊨` is taken by `valid` and `⊨[D]` by `ValidOver`.
- Changing any theorem's mathematical content. Statements are preserved up to the proved
  legacy/new equivalences throughout; nothing is strengthened or weakened.
- Discharging `CompactBase`/`CompactDense` or any other open assumption encountered en route.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C2 axiom baselines diverge on `BXCanonical.completeness{,_dense,_discrete}` | H | M | Legacy predicate *statements* are preserved as abbreviations, so the flagship theorem statements do not change. Run `bash scripts/check-module-invariants.sh` at EVERY phase boundary, not only at the end. A divergence is a HARD STOP, never a re-baseline. |
| C14 baselines diverge on `completeness_dedekind` / the decidability soundness bridge | H | M | Same gate; C14 additionally scans `FormalSystem/**/*.lean` docstrings for stale axiom counts -- any new or rewritten docstring must say 45, never 14/21/42/44. |
| C15 rejects a paper-anchor citation in a new docstring | M | M | Only cite anchors already pinned in `specs/paper-definitions-of-record.md`. The five this plan uses -- `def:frame-properties`, `def:TMplus-f`, `cor:tm-completeness`, `def:logical-consequence`, `def:frame-validity` -- were each confirmed present in the record before this plan was written. Do not invent an anchor. |
| Destructuring the `Sat .Discrete` existential with `haveI` breaks defeq with instances baked into `F`'s and `M`'s types | H | H | Use `obtain ⟨…⟩` with bare `_` names and pass instances positionally via `@`, never `haveI`. The in-tree precedent warning is in `Metalogic/SetConsequence.lean`'s existential-destructuring note. |
| The retained name `ValidDedekind` (bare Complete) now differs from `ValidIn .Dedekind` (dense-and-complete) -- a reader may assume they match | M | H | **Stated concern, proceeding as directed** (the rename is explicitly rejected by the task). Mitigation is mandatory and load-bearing: `ValidDedekind`'s docstring must open by naming the mismatch and pointing at `ValidIn .Dedekind` / `ValidDedekindDense` as the `soundness_dedekind` target, and `TaskFrame.IsComplete` must carry the reciprocal pointer. Phase 4 does not close without both. |
| `valid` migration (31 candidate files) churns proofs beyond its phase budget | M | M | Phased last, behind every other migration, with an explicit off-ramp (Phase 8). |
| A phase's asserted file list turns out wrong at implementation time | M | M | Every phase asserting a count or file list carries a `Scope Hypothesis` line naming the confirming command. |
| Retiring `FrameConditions/Validity.lean` predicates breaks the `FrameConditions.lean` aggregator's prose | L | M | The aggregator's mentions are docstring prose, not code; C5/C13 lint markdown paths, not Lean identifiers. Rebuild after edit. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 2 |
| 4 | 5, 6, 7 | 4 |
| 5 | 8 | 5, 6, 7 |
| 6 | 9 | 8 |

Phases within the same wave can execute in parallel. Phases 5, 6 and 7 partition the
`Metalogic/` migration by file territory and touch disjoint files: Phase 5 owns the
soundness/completeness trio, Phase 6 the canonical-model and decidability remainder, and Phase 7
owns `Metalogic/SetConsequence.lean` alone.

---

### Phase 1: Frame properties from `def:frame-properties` [NOT STARTED]

**Goal**: A new module holding every frame-level property predicate this task needs, each grounded
in a pinned paper anchor, with the `Dedekind`-vs-`Complete` naming deviation recorded at the
definition site. No consumer yet.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/FrameProperty.lean`, importing `FormalSystem.Semantics.Validity`.
- [ ] Define `TaskFrame.IsDense (F : TaskFrame) : Prop := DenselyOrdered F.Duration`, citing
      `def:frame-properties`' Dense clause.
- [ ] Define `TaskFrame.IsDiscrete (F : TaskFrame) : Prop` as `def:frame-properties`' Discrete
      clause verbatim (`∀ x, (∃ y, x < y) → ∃ y', IsLeast {z | x < z} y'`, or the equivalent
      least-positive-element form -- state which and why in the docstring).
- [ ] Define `TaskFrame.IsSuccArchDiscrete (F : TaskFrame) : Prop` as the existential over the
      binder bundle `ValidDiscrete` currently carries: `∃ (_ : SuccOrder F.Duration)
      (_ : PredOrder F.Duration), IsSuccArchimedean F.Duration ∧ IsPredArchimedean F.Duration`.
      Docstring must cite `def:TMplus-f`'s Hölder sentence and state that this, not `IsDiscrete`,
      is what `FrameClass.Discrete` admits axioms for.
- [ ] Define `TaskFrame.IsComplete (F : TaskFrame) : Prop :=
      ∀ s : Set F.Duration, s.Nonempty → BddAbove s → ∃ x, IsLUB s x`, citing
      `def:frame-properties`' Complete clause. Docstring must note that `ℤ` satisfies it and point
      at `IsDedekind`.
- [ ] Define `TaskFrame.IsDedekind (F : TaskFrame) : Prop := F.IsDense ∧ F.IsComplete`, citing
      `def:frame-properties` + `cor:tm-completeness`'s TM⁺_c clause, and carrying the **recorded
      naming deviation**: paper says Complete, this tree says Dedekind, because "complete" is
      load-bearing for proof-theoretic completeness here.
- [ ] Prove `TaskFrame.isDense_of_isDedekind` and `TaskFrame.isComplete_of_isDedekind`
      (`And.left`/`And.right` -- named so downstream sites cite a lemma, not a projection).
- [ ] Add the module to the `FormalSystem/Semantics.lean` aggregator (C8 convention).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts that the four anchors it cites (`def:frame-properties`,
`def:TMplus-f`, `cor:tm-completeness`, `def:frame-validity`) all resolve against the pinned record.
Confirm with `grep -n 'def:frame-properties\|def:TMplus-f\|cor:tm-completeness\|def:frame-validity' specs/paper-definitions-of-record.md`
before writing the docstrings, and with `bash scripts/check-module-invariants.sh --no-build` (C15)
after.

**Files to modify**:
- `FormalSystem/Semantics/FrameProperty.lean` - NEW; the five frame predicates + two projections
- `FormalSystem/Semantics.lean` - one added import

**Verification**:
- `lake build FormalSystem.Semantics.FrameProperty` green, zero sorries
- Every predicate's docstring cites a pinned anchor; `IsDedekind`'s names the naming deviation
- `bash scripts/check-module-invariants.sh --no-build` passes (C8 aggregator, C15 anchors)

---

### Phase 2: `FrameClass.Sat`, `ValidOnFrames`, `ValidIn`, and the one monotonicity lemma [NOT STARTED]

**Goal**: The FrameClass-indexed layer exists and is proved equivalent to every legacy predicate,
without any legacy definition changing yet. This is the phase that lands the migration lever.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/FrameClassValidity.lean`, importing
      `FormalSystem.Semantics.FrameProperty` + `FormalSystem.ProofSystem.Axioms`. Module docstring
      must state why this seam (`Semantics → ProofSystem.Axioms`) is confined to one module, and
      record the verified acyclicity (`Axioms.lean` imports only `Syntax.Formula`).
- [ ] Define `FrameClass.Sat : FrameClass → TaskFrame → Prop` per the table in "The `Sat`
      interpretation of record" above, with the per-constructor anchors in the docstring.
- [ ] Prove `FrameClass.Sat.anti {fc₁ fc₂} (h : fc₁ ≤ fc₂) {F} : fc₂.Sat F → fc₁.Sat F`
      (case split on both constructors; `decide` discharges the closed order goals).
- [ ] Define `ValidOnFrames (P : TaskFrame → Prop) (φ : Formula) : Prop := ∀ F, P F → F.ValidOn φ`.
- [ ] Define `ValidIn (fc : FrameClass) (φ : Formula) : Prop := ValidOnFrames fc.Sat φ`.
- [ ] Prove `ValidOnFrames.mono` (antitone in the predicate) -- **the one monotonicity lemma**.
- [ ] Prove `ValidIn.mono : fc₁ ≤ fc₂ → ValidIn fc₁ φ → ValidIn fc₂ φ` as its corollary via
      `Sat.anti`. Docstring must name `DerivationTree.lift` (`ProofSystem/Derivation.lean:184`) as
      the proof-side lemma it mirrors.
- [ ] Prove the migration lever: `ValidOnFrames.of_forall_total` and `ValidOnFrames.apply_total`
      (see "The migration lever" above), routed through `valid_iff_forall_validOn`'s `.val`/
      `.property` bridge.
- [ ] Prove the five equivalence bridges, legacy on the left, with legacy definitions still
      untouched: `valid φ ↔ ValidIn .Base φ`, `ValidDense φ ↔ ValidIn .Dense φ`,
      `ValidDiscrete φ ↔ ValidIn .Discrete φ`, `ValidDedekindDense φ ↔ ValidIn .Dedekind φ`,
      `ValidDedekind φ ↔ ValidOnFrames TaskFrame.IsComplete φ`.
- [ ] Add the module to the `FormalSystem/Semantics.lean` aggregator.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the `Semantics → ProofSystem.Axioms` import introduces no
cycle. Confirm at implementation time with
`grep -rn 'import FormalSystem.Semantics' FormalSystem/ProofSystem/` (must be empty) and by the
build itself.

**Files to modify**:
- `FormalSystem/Semantics/FrameClassValidity.lean` - NEW; `Sat`, `Sat.anti`, `ValidOnFrames`,
  `ValidIn`, both monotonicity lemmas, the lever pair, the five bridges
- `FormalSystem/Semantics.lean` - one added import

**Verification**:
- `lake build` green, zero sorries in the new module
- All five bridges proved (no `sorry`, no `admit`)
- `bash scripts/check-module-invariants.sh` passes, C2 baselines unchanged

---

### Phase 3: Retire the dead `FrameConditions` validity surface and the `ValidInt` duplicate [NOT STARTED]

**Goal**: Delete the five `FrameConditions` validity predicates and their bridge lemmas -- all
verified to have zero live consumers -- and collapse the `ValidInt`/`ValidOnInt` definitional
duplicate onto `ValidInt`.

**Tasks**:
- [ ] Re-confirm zero live consumers before deleting anything (see Scope Hypothesis).
- [ ] Delete `ValidLinear`, `ValidDenseFc`, `ValidDiscreteFc`, `ValidOnInt` and the bridge lemmas
      that mention only them (`valid_dense_of_valid_dense_fc`, `valid_dense_fc_of_valid_dense`,
      `valid_dense_fc_iff_valid_dense`, `valid_discrete_fc_of_valid_discrete`,
      `valid_linear_of_valid`, `valid_dense_fc_of_valid_linear`, `valid_discrete_fc_of_valid_linear`,
      `valid_on_Int_of_valid_discrete`) from `FormalSystem/FrameConditions/Validity.lean`.
- [ ] Keep whatever in that file has a live consumer (`ValidOver`, `valid_of_forall_valid_over`,
      `valid_over_of_valid` if still referenced) -- confirm per-declaration, do not delete by file.
- [ ] If the file empties out, delete it and its import from `FormalSystem/FrameConditions.lean`;
      otherwise leave a module docstring recording what was retired and why.
- [ ] Update the `FrameConditions.lean` aggregator prose that names the deleted predicates.
- [ ] Retarget any consumer of `ValidOnInt` onto `Semantics.ValidInt` (`Semantics/IntTransfer.lean:374`).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts each deleted predicate has zero consumers outside its own
file and the aggregator's prose. Confirm per name, immediately before deleting, with
`grep -rn --include=*.lean '\bValidLinear\b' FormalSystem/ Tests/` (and likewise for each). A hit
outside `FrameConditions/Validity.lean` and `FrameConditions.lean` retracts that deletion and it is
recorded as a Reasoned Exclusion instead.

**Files to modify**:
- `FormalSystem/FrameConditions/Validity.lean` - retire the dead surface (possibly delete the file)
- `FormalSystem/FrameConditions.lean` - import + aggregator prose

**Verification**:
- `lake build` green, zero sorries
- `bash scripts/check-module-invariants.sh` passes (C4 imports resolve, C6 rot guard, C8 aggregator)

---

### Phase 4: Redefine the `Semantics/` predicates on the new primitive [NOT STARTED]

**Goal**: `valid`'s four class-restricted siblings and the whole BL⁺ mirror become abbreviations
over `ValidIn`/`ValidOnFrames`; the five hand-written monotonicity bridges collapse onto
`ValidOnFrames.mono`; every `Semantics/`-internal call site migrates. `valid` itself is deliberately
NOT touched here (Phase 8).

**Tasks**:
- [ ] Redefine in `Semantics/Validity.lean`: `ValidDense := ValidIn .Dense`,
      `ValidDiscrete := ValidIn .Discrete`, `ValidDedekindDense := ValidIn .Dedekind`,
      `ValidDedekind := ValidOnFrames TaskFrame.IsComplete`. Preserve each existing docstring's
      substantive content (the Hölder-dichotomy discussion, the `soundness_dedekind` hazard note,
      the Reynolds citation) -- these are load-bearing, not decoration.
- [ ] Write the mandatory `ValidDedekind` mismatch docstring: it is NOT `ValidIn .Dedekind`; the
      `soundness_dedekind` target is `ValidDedekindDense`. Add the reciprocal pointer on
      `TaskFrame.IsComplete`. (Risks table, row 5 -- the phase does not close without both.)
- [ ] Replace `valid_implies_valid_dense`, `valid_implies_valid_discrete`,
      `valid_implies_validDedekind`, `valid_implies_validDedekindDense`, and
      `validDedekindDense_of_validDedekind` with one-line corollaries of `ValidOnFrames.mono` /
      `ValidIn.mono`. Keep every existing name as a callable alias -- do not break call sites in
      this phase for the sake of deleting a name.
- [ ] Mirror the same shape in `Semantics/BLValidity.lean`: `BLValidIn (fc) (φ : BLFormula)` (BL⁺
      has its own `BLTruthAt`, so it needs its own indexed predicate over the same `Sat`),
      `BLValidDense`/`BLValidDiscrete`/`BLValidDedekindDense` as abbreviations, and the three
      `blValid_implies_*` lemmas collapsed onto one.
- [ ] Migrate `Semantics/`-internal call sites: `IntTransfer.lean`, `DurationClassification.lean`,
      `IntNormalForm.lean`, `Extension/PeriodicExtension.lean`, and `Validity.lean`'s own remaining
      uses, using `of_forall_total` / `apply_total`.
- [ ] Move `Validity.lean`'s class-restricted definitions to whichever module keeps the import
      graph acyclic (`FrameClassValidity.lean` is downstream of `Validity.lean`, so either relocate
      the four definitions into `FrameClassValidity.lean` and re-export, or move `ValidIn` upstream
      -- decide at implementation time and record the choice in the module docstring). **This is
      the one structural decision left open by this plan**; both resolutions are acceptable, an
      import cycle is not.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts the `Semantics/`-internal migration surface is the six
files named above. Confirm with
`grep -rln --include=*.lean -E '\b(ValidDense|ValidDiscrete|ValidDedekind|ValidDedekindDense|BLValid[A-Za-z]*)\b' FormalSystem/Semantics/`
at phase start; any additional file joins this phase rather than being deferred.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - four redefinitions, five lemmas collapsed, docstrings
- `FormalSystem/Semantics/FrameClassValidity.lean` - possible relocation target (see last task)
- `FormalSystem/Semantics/BLValidity.lean` - `BLValidIn` + three abbreviations + one lemma
- `FormalSystem/Semantics/IntTransfer.lean`, `DurationClassification.lean`, `IntNormalForm.lean`,
  `Extension/PeriodicExtension.lean` - call-site migration

**Verification**:
- `lake build` green, zero sorries
- `bash scripts/check-module-invariants.sh` passes; C2 axiom baselines byte-identical
- `ValidDedekind` and `TaskFrame.IsComplete` each carry the reciprocal mismatch pointer

---

### Phase 5: Migrate the soundness/completeness territory [NOT STARTED]

**Goal**: `Metalogic/Soundness.lean`, `Metalogic/SoundnessLemmas/CoValidity.lean`, and
`Metalogic/StrongCompleteness.lean` compile against the redefined predicates, with statements
unchanged.

**Tasks**:
- [ ] Migrate `Metalogic/Soundness.lean` (the largest single surface) with `of_forall_total` /
      `apply_total`; `soundness_dense`, `soundness_discrete`, `soundness_dedekind` and their
      `_valid` empty-context forms keep their exact statements.
- [ ] Confirm `soundness_dedekind` still targets `ValidDedekindDense`, never `ValidDedekind` --
      and note in a comment that the new definition makes the wrong target structurally distinct
      (`ValidOnFrames IsComplete` vs `ValidIn .Dedekind`) rather than merely warned against.
- [ ] Migrate `Metalogic/SoundnessLemmas/CoValidity.lean`.
- [ ] Migrate `Metalogic/StrongCompleteness.lean`, including `completeness_dense`,
      `completeness_discrete`, `completeness_dedekind`, and the `soundness_*_consequence` family.
- [ ] Where a proof previously discharged an instance binder with `intro F _`, use the `obtain
      ⟨…⟩` + positional `@` pattern for the `Sat .Discrete` existential -- **never `haveI`**.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts three files carry ~78 of the ~118 non-`Semantics`
occurrences. Confirm the exact per-file counts at phase start with
`grep -rc --include=*.lean -E '\b(ValidDense|ValidDiscrete|ValidDedekind|ValidDedekindDense)\b' FormalSystem/Metalogic/Soundness.lean FormalSystem/Metalogic/StrongCompleteness.lean FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean`
- `FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`
- `FormalSystem/Metalogic/StrongCompleteness.lean`

**Verification**:
- `lake build` green, zero sorries
- `bash scripts/check-module-invariants.sh` passes; C2 and C14 axiom baselines byte-identical
- No `haveI` introduced on a destructured instance binder

---

### Phase 6: Migrate the canonical-model, decidability, and remaining territory [NOT STARTED]

**Goal**: Every remaining consumer outside `Metalogic/SetConsequence.lean` compiles against the
redefined predicates.

**Tasks**:
- [ ] Migrate `Metalogic/BXCanonical/Completeness.lean` and `BXCanonical/CompletenessDedekind.lean`.
- [ ] Migrate `Metalogic/Decidability/`: `BiLasso/Assembly.lean`, `BiLasso/Check.lean`,
      `Correctness.lean`, `Tableau.lean`, `Verified/Decidable.lean`,
      `Verified/Bridge/{Carrier,DenseTruth,IntTruth}.lean`.
- [ ] Migrate `Metalogic/WeakCanonical/PriorDefsDense.lean`,
      `WeakCanonical/DenseModelSurgery/Singletons.lean`, `Metalogic/DiscreteNonCompactness.lean`,
      `Theorems/DedekindDerived.lean`, `ProofSystem/Axioms.lean`'s docstring references, and
      `Tests/BimodalTest/TableauConformance.lean`.
- [ ] Refresh `Metalogic.lean` and `Semantics.lean` docstring prose that describes the old
      per-class predicate family.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts a ~16-file remainder after Phases 4 and 5. Confirm at
phase start with
`grep -rln --include=*.lean -E '\b(ValidDense|ValidDiscrete|ValidDedekind|ValidDedekindDense)\b' FormalSystem/ Tests/`
minus the files owned by Phases 4, 5, and 7. Any file appearing that is not in the list above is
added to this phase, not deferred.

**Files to modify**: the ~16 files enumerated in the tasks above (confirmed by the Scope Hypothesis
command)

**Verification**:
- `lake build` green, zero sorries
- `bash scripts/check-module-invariants.sh` passes; C2/C14 baselines byte-identical

---

### Phase 7: Collapse the set-consequence family [NOT STARTED]

**Goal**: The smoking gun closed. `SetSemanticConsequenceOn (fc)` defined once beside
`SetDerivable (fc)`, with one monotonicity-in-`Γ` lemma and one monotonicity-in-`fc` lemma replacing
the four byte-identical copies.

**Tasks**:
- [ ] Define `SetConsequenceOnFrames (P : TaskFrame → Prop) (Γ : Set Formula) (φ : Formula)` and
      `SetSemanticConsequenceOn (fc : FrameClass) (Γ) (φ) := SetConsequenceOnFrames fc.Sat Γ φ` in
      `Metalogic/SetConsequence.lean`, immediately beside `SetDerivable (fc)`.
- [ ] Prove `setSemanticConsequenceOn_mono` (in `Γ`) -- the exact analogue of `setDerivable_mono`
      -- and `setSemanticConsequenceOn_mono_fc` (in `fc`, via `Sat.anti`) -- the analogue of
      `DerivationTree.lift`.
- [ ] Redefine `SetSemanticConsequenceBase/Dense/Discrete/DedekindDense` as abbreviations over
      `SetSemanticConsequenceOn`, replacing the four `*_mono` copies with corollaries of the one
      lemma while keeping every existing name callable.
- [ ] Replace the stale line-number citations in those four docstrings ("Binder list: `valid`
      (`Validity.lean:94`)" etc. -- all four now point at wrong lines) with a citation of the
      `Sat` interpretation instead. Cite by name, not by line number.
- [ ] Migrate the file's own consumers and any external consumer of the four names.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts the four `SetSemanticConsequence*` names have consumers in
at most three files. Confirm with
`grep -rln --include=*.lean -E '\bSetSemanticConsequence(Base|Dense|Discrete|DedekindDense)\b' FormalSystem/ Tests/`.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - the collapse
- any external consumer the Scope Hypothesis command surfaces

**Verification**:
- `lake build` green, zero sorries
- Exactly one definition and one monotonicity-in-`Γ` lemma remain per axis
- `bash scripts/check-module-invariants.sh` passes

---

### Phase 8: `valid := ValidIn .Base`, with off-ramp [NOT STARTED]

**Goal**: The last of the 15 predicates joins the family, completing the symmetry claim
`valid = ValidIn .Base` beside `Derivable .Base`.

**Tasks**:
- [ ] Redefine `valid φ := ValidIn .Base φ` in `Semantics/Validity.lean`, preserving the
      `def:logical-consequence` docstring verbatim and adding the `Sat .Base = True` note.
- [ ] Keep the `⊨` notation bound to `valid`.
- [ ] Migrate every `valid` call site with `of_forall_total` / `apply_total`. The `True` argument
      at `.Base` is discharged by `trivial`; if that reads badly at scale, add a `.Base`-specialized
      `valid.apply` / `valid.of_forall_total` pair rather than repeating `trivial`.
- [ ] Likewise `BLValid := BLValidIn .Base`.
- [ ] Re-run the full gate after each file, not only at the end -- `valid` sits under every C2 and
      C14 flagship theorem.

**Timing**: 2 hours

**Depends on**: 5, 6, 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts ~110 candidate lines across ~31 files, most of them
docstring prose rather than code. Confirm the code-only surface at phase start with
`grep -rn --include=*.lean -E '(^|[^A-Za-z_.])valid[ ]+(φ|phi|ψ|psi|\(|\{)' FormalSystem/ Tests/`
and triage prose out before sizing the work.

**Off-ramp (pre-declared)**: if the abbreviation churns proofs beyond this phase's budget or moves
any C2/C14 axiom baseline, revert `valid` to its current standalone `def` and keep
`valid_iff_validIn_base` (already proved in Phase 2) as the bridge. Record the outcome as
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` table naming `valid` as the single
excluded item, the budget or baseline evidence as the Reason, and the failing command output as the
Evidence. **A moved axiom baseline is a HARD STOP that triggers this off-ramp, never a re-baseline.**

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean`, `FormalSystem/Semantics/BLValidity.lean`
- the code-only `valid` consumers the Scope Hypothesis command surfaces

**Verification**:
- `lake build` green, zero sorries
- C2 axiom baselines byte-identical, or the off-ramp taken and recorded

---

### Phase 9: Tree-wide acceptance [NOT STARTED]

**Goal**: The task's stated acceptance criteria demonstrated, not asserted.

**Tasks**:
- [ ] `lake build` from clean: green, zero errors.
- [ ] Zero `sorry` in everything touched -- verify by content, never by line number.
- [ ] `bash scripts/check-module-invariants.sh` (full, with build) passes: B0, C1-C15.
- [ ] C2 axiom profiles for `BXCanonical.completeness`, `completeness_dense`,
      `completeness_discrete` byte-identical to baseline; C14's `completeness_dedekind` and the
      decidability soundness bridge likewise.
- [ ] C14 docstring-count scan: no new or rewritten docstring asserts a stale axiom count.
- [ ] C15: every paper anchor cited by a new docstring resolves against
      `specs/paper-definitions-of-record.md`.
- [ ] C9: zero task-number citations under `FormalSystem/` (per
      `.claude/rules/no-task-references-in-deliverables.md` -- new docstrings must cite filenames
      and anchors, never task numbers).
- [ ] Confirm the deliverables one by one against the tree: (1) the `Sat` interpretation exists;
      (2) `ValidIn` and `SetSemanticConsequenceOn` are each defined exactly once; (3) one
      monotonicity lemma covers all five former validity bridges and all four former
      set-consequence copies; (4) each of the 15 legacy predicates is an abbreviation or gone, with
      no orphaned call site.
- [ ] Write the implementation summary to
      `specs/507_parameterize_validity_by_frameclass/summaries/`.

**Timing**: 1 hour

**Depends on**: 8

**Verification Tier**: full

**Files to modify**:
- `specs/507_parameterize_validity_by_frameclass/summaries/01_frame-level-validity-indexing-summary.md` - NEW

**Verification**:
- Every command above run and its output recorded in the summary, including any that failed

---

## Testing & Validation

- [ ] `lake build` exits 0 at every phase boundary
- [ ] `bash scripts/check-module-invariants.sh` exits 0 at every phase boundary
- [ ] C2 axiom baselines byte-identical across the whole task (HARD STOP on divergence)
- [ ] C14 axiom/sorry documented-count scan clean
- [ ] C15 paper-anchor resolution clean for every new docstring
- [ ] Zero `sorry`, asserted by content
- [ ] Grep proves exactly one definition of `ValidIn` and one of `SetSemanticConsequenceOn`
- [ ] Grep proves no surviving hand-written per-class monotonicity lemma body (aliases pointing at
      the one lemma are fine; copies are not)
- [ ] `Tests/BimodalTest/TableauConformance.lean` compiles unchanged in statement

## Artifacts & Outputs

- `FormalSystem/Semantics/FrameProperty.lean` (new)
- `FormalSystem/Semantics/FrameClassValidity.lean` (new)
- Modified: `Semantics/{Validity,BLValidity,IntTransfer,DurationClassification,IntNormalForm}.lean`,
  `Semantics/Extension/PeriodicExtension.lean`, `Semantics.lean`
- Modified: `Metalogic/{Soundness,StrongCompleteness,SetConsequence,DiscreteNonCompactness}.lean`,
  `Metalogic/SoundnessLemmas/CoValidity.lean`, `Metalogic/BXCanonical/*`,
  `Metalogic/Decidability/*`, `Metalogic/WeakCanonical/*`, `Metalogic.lean`
- Retired: the dead `FrameConditions/Validity.lean` surface; `ValidOnInt`
- `specs/507_parameterize_validity_by_frameclass/summaries/01_frame-level-validity-indexing-summary.md`

## Rollback/Contingency

Every phase ends at a green `lake build` and is committed, so rollback is per-phase `git revert`.
The critical path is Phases 1-2-4: if Phase 4's redefinition proves unworkable, Phases 1-3 stand
alone as a net improvement (the frame predicates and the indexed layer exist and are proved
equivalent to the legacy ones; the dead surface is gone) and the legacy definitions are untouched.
Phases 5-8 are call-site migration only and can be abandoned individually without leaving the tree
red, since each legacy name remains callable throughout.

If a C2 or C14 axiom baseline moves at any point: **stop, do not re-baseline**. Revert the phase,
identify which definitional change altered elaboration, and reduce that change to a proved
equivalence rather than an abbreviation.
