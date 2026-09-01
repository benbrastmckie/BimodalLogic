# Implementation Summary: Parameterize validity by FrameClass (frame-level shape)

- **Task**: 507 - Parameterize validity by FrameClass
- **Plan**: `specs/507_parameterize_validity_by_frameclass/plans/02_frame-level-validity-indexing.md` (v2; supersedes v1)
- **Status**: COMPLETED — 9/9 phases
- **Type**: lean4

## What was built

The proof side of this tree was already parameterized by `FrameClass` (`Derivable fc`,
`DerivationTree fc`, `DerivationTree.lift` along `fc₁ ≤ fc₂`, `Axiom.minFrameClass`). The semantic
side had none of it: fifteen hand-copied validity predicates and four byte-identical
set-consequence variants, each carrying an inlined binder list rather than deriving its frame
constraint from a class tag. That asymmetry — issue H1 of
`specs/reviews/review-2026-08-31-metalogic-systematicity.md` — is now closed.

The semantic interpretation is a predicate on **bundled frames**, mirroring `Derivable fc`:

```lean
FrameClass.Sat : FrameClass → TaskFrame → Prop
ValidOnFrames (P : TaskFrame → Prop) (φ : Formula) : Prop := ∀ F, P F → F.ValidOn φ
ValidIn (fc : FrameClass) (φ : Formula) : Prop := ValidOnFrames fc.Sat φ
```

`TaskFrame.ValidOn` (`def:frame-validity`) remains the single frame-level primitive and is not
duplicated.

## Deliverables, verified against the tree

1. **The `Sat` interpretation exists**, with every constructor mapped to a named, paper-anchored
   frame predicate in `FormalSystem/Semantics/FrameProperty.lean`:

   | Constructor | `Sat` | Anchor |
   |-------------|-------|--------|
   | `.Base` | `True` | `def:logical-consequence` |
   | `.Dense` | `TaskFrame.IsDense` | `def:frame-properties` Dense |
   | `.Discrete` | `TaskFrame.IsSuccArchDiscrete` | `def:TMplus-f` (Hölder narrowing to ℤ-time) |
   | `.Dedekind` | `TaskFrame.IsDedekind` = `IsDense ∧ IsComplete` | `def:frame-properties` Complete + `cor:tm-completeness` |

   `TaskFrame.IsDiscrete` (the paper's *bare* Discrete clause) stands beside
   `IsSuccArchDiscrete` rather than being conflated with it — conflating them would silently
   widen the class under `soundness_discrete`, the defect the `FrameConditions` marker-typeclass
   layer already had.

2. **`ValidIn` and `SetSemanticConsequenceOn` are each defined exactly once.** Confirmed by
   content: `FormalSystem/Semantics/Validity.lean:284` and
   `FormalSystem/Metalogic/SetConsequence.lean:97` are the only definitions of either name.

3. **One monotonicity lemma per axis.** `ValidOnFrames.mono` (antitone in an arbitrary frame
   predicate) subsumes all five former validity bridges — `valid_implies_valid_dense`,
   `_valid_discrete`, `_validDedekind`, `_validDedekindDense`, and
   `validDedekindDense_of_validDedekind` — each now a one-line corollary with its name still
   callable. `setConsequenceOnFrames_mono` likewise replaces the four copied set-consequence
   `*_mono` proofs, and `setSemanticConsequenceOn_mono_fc` (via `FrameClass.Sat.anti`) is the
   semantic analogue of `DerivationTree.lift`. Taking a *predicate* rather than a tag is what lets
   one lemma cover `ValidDedekind` too, which has no `FrameClass` member.

4. **Every legacy predicate is an abbreviation or retired**, with all call sites migrated:
   `valid`, `ValidDense`, `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense`, `BLValid`,
   `BLValidDense`, `BLValidDiscrete`, `BLValidDedekindDense`, and the four
   `SetSemanticConsequence*` names. Retired outright: `ValidLinear`, `ValidDenseFc`,
   `ValidDiscreteFc`, `ValidOnInt` and their eight bridge lemmas — each re-confirmed to have zero
   live consumers immediately before deletion.

## Structural decisions of record

- **`ValidIn` moved upstream, not the class-restricted predicates downstream.**
  `FrameProperty.lean` imports `Semantics.TaskFrame` (the five predicates are properties of
  frames and need no validity notion), `FrameClassValidity.lean` holds `Sat`/`Sat.anti` and is the
  sole module under `Semantics/` importing anything from `ProofSystem/`, and `Validity.lean`
  declares `ValidOnFrames`, `ValidIn`, both monotonicity lemmas, the adapters, and the four
  class-restricted predicates — beside `TaskFrame.ValidOn`, where they belong. The alternative
  (relocating the four predicates into `FrameClassValidity.lean`) would have forced a new import
  line into ~27 consuming files for no gain in layering.

- **Per-class binder adapters, not `haveI`.** Each predicate carries `.of_forall` / `.apply`
  (plus `.of_not` where a site used to `unfold`) whose hypothesis type reproduces the
  pre-abbreviation binder list verbatim, instance binders included. This is load-bearing, not
  cosmetic: a hypothesis of type `TaskFrame.IsDense F` has head symbol `TaskFrame.IsDense`, so
  typeclass resolution cannot see the `DenselyOrdered` inside it and every downstream
  `exists_between` would fail. Introducing the witness through an adapter whose binder is written
  `[DenselyOrdered F.Duration]` puts it back where instance search finds it. **Zero `haveI` on a
  destructured instance binder was introduced** (`git diff | grep '^+.*haveI'` → 0 matches).

- **`Dedekind`, not `Complete` — a recorded deviation from paper naming.** `def:frame-properties`
  calls the class Complete; "complete" is already load-bearing here for *proof-theoretic*
  completeness, so `FrameClass.Complete` would collide with this tree's most-cited word. The
  deviation is named explicitly at the definition site (`TaskFrame.IsDedekind`, `FrameClass.Sat`),
  not merely anchored.

- **The `ValidDedekind` hazard is now structural.** `ValidDedekind` is
  `ValidOnFrames TaskFrame.IsComplete` (bare Complete, which admits ℤ) and is therefore *not* any
  `ValidIn`; the `soundness_dedekind` target is `ValidDedekindDense = ValidIn .Dedekind`. The two
  are now distinct types rather than a docstring warning, and each carries the reciprocal pointer
  (`ValidDedekind` ↔ `TaskFrame.IsComplete`).

## Acceptance gate (Phase 9) — commands run and their output

| Check | Result |
|-------|--------|
| `lake build` (guarded, detached) | **green**, 2508/2508 targets, zero `error:` lines |
| B0 Boneyard exclusion self-test | PASS |
| C1 `lake build` / `lake build BimodalTest` exit 0 | PASS |
| C2 four flagship axiom sets vs baseline | PASS — byte-identical |
| C3 structural sorry inventory across `FormalSystem/` | PASS — **ZERO** |
| C4–C8, C10–C13, C15 | PASS |
| C9 task-number citations under `FormalSystem/` | PASS — zero |
| C14 documented axiom/sorry counts + Dedekind/decidability baselines | PASS — byte-identical |
| Sorry census over touched territory | `sorry_count: 0` |
| Vacuous-definition scan (`:= True/Unit/trivial`) | 0 |
| New `axiom` declarations | 0 |

C2 baseline, unchanged:

```
'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
```

C14 baseline, unchanged:

```
'FormalSystem.Metalogic.Decidability.sound_of_isValid' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.completeness_dedekind' depends on axioms: [propext, Classical.choice, Quot.sound]
```

C9D reports 138 task-number citations under `docs/` — pre-existing, not enforced, and untouched by
this work.

The pre-existing `sorryAx` on `compactBase_of_modelExistence` / `completeness_base` is an open
assumption (`CompactBase`) that predates this task and is an explicit Non-Goal of the plan. It is
outside the C2 and C14 baseline sets and was not moved.

## Plan Deviations

- **Phase 1** — *altered*: `FrameProperty.lean` imports `Semantics.TaskFrame` rather than
  `Semantics.Validity`, placing it upstream of `Validity.lean`. This is what made the Phase 4
  "move `ValidIn` upstream" resolution available.
- **Phase 2** — *altered*: `ValidOnFrames` and `ValidIn` are declared in `Semantics/Validity.lean`,
  not `FrameClassValidity.lean`, because they are defined through `TaskFrame.ValidOn`, which lives
  there.
- **Phase 3** — *altered*: `ValidOver` did not exist in the tree (already removed).
  `valid_of_forall_valid_over` / `valid_over_of_valid` were **kept**: they have zero consumers
  today but are fibration bridges, not part of the dead frame-class surface.
  *skipped*: retargeting `ValidOnInt` consumers — it had none. One unrelated fallout was repaired:
  `FrameConditions/Soundness.lean` had been getting `LinearTemporalFrame`/`DenseTemporalFrame`/
  `DiscreteTemporalFrame` transitively through the removed import; it now declares the import
  directly.
- **Phase 4** — the plan's one open structural decision was resolved as "move `ValidIn` upstream";
  recorded above and in the module docstrings. Migration used per-class adapters rather than the
  generic lever alone (the generic lever exists as specified).
- **Phase 6** — *altered*: `BXCanonical/CompletenessDedekind.lean` was missed by the first
  implementation pass and left the tree red at `:597`; repaired by routing
  `completeness_dedekind_engine`'s application of `h_valid` through `ValidDedekindDense.apply`.
  Axiom profile unchanged.
- **Phase 8** — *altered*: a third adapter, `valid.of_not`, was added beyond the plan's two, for
  the one contrapositive site (`compactBase_of_modelExistence`) that opened the definition with
  `unfold valid; push Not`. It mirrors the `ValidDense.of_not` precedent from Phase 4.
  *altered*: the gate was run per build rather than per file; the first Phase 8 build left four
  modules red (`FrameConditions/Soundness.lean`, `Metalogic/BaseLanguageSoundness.lean`,
  `Metalogic/Decidability/Correctness.lean`, `Metalogic/StrongCompleteness.lean`), all repaired.
  The pre-declared off-ramp was **not** taken: no axiom baseline moved.

## Files

**New**: `FormalSystem/Semantics/FrameProperty.lean`, `FormalSystem/Semantics/FrameClassValidity.lean`

**Modified**: `FormalSystem/Semantics/{Validity,BLValidity,IntTransfer}.lean`, `FormalSystem/Semantics.lean`,
`FormalSystem/FrameConditions/{Validity,Soundness}.lean`, `FormalSystem/FrameConditions.lean`,
`FormalSystem/Metalogic/{Soundness,StrongCompleteness,SetConsequence,DiscreteNonCompactness,BaseLanguageSoundness}.lean`,
`FormalSystem/Metalogic/SoundnessLemmas/CoValidity.lean`,
`FormalSystem/Metalogic/BXCanonical/{Completeness,CompletenessDedekind}.lean`,
`FormalSystem/Metalogic/Decidability/{Correctness,BiLasso/Assembly,Verified/Bridge/DenseTruth,Verified/Bridge/IntTruth}.lean`

**Retired**: the dead `FrameConditions/Validity.lean` frame-class surface; `ValidOnInt`

## Commits

- `7892cb57f` — phases 4-7: predicates on `ValidIn`, Metalogic migration, set-consequence collapse
- `463b00103` — phase 8: `valid := ValidIn .Base`, `BLValid := BLValidIn .Base`
