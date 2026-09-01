# Implementation Plan: Task #507

> **SUPERSEDED -- DO NOT FOLLOW.** Replaced by `plans/02_frame-level-validity-indexing.md`.
> This version's Phase 1 defines `FrameClass.Sat` as a predicate on the duration CARRIER TYPE
> and a duration-quantified `ValidIn`. That is duration validity, which is explicitly not the
> notion this project wants; landing it would harden the wrong notion into the tree's single
> validity definition. The replacement defines `Sat : FrameClass -> TaskFrame -> Prop` on
> bundled frames, mirroring `Derivable fc`. Retained for its risk inventory and effort
> calibration only.

- **Task**: 507 - Parameterize validity by FrameClass (ROOT FIX for metalogic systematicity H1)
- **Status**: [NOT STARTED]
- **Effort**: 10.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/507_parameterize_validity_by_frameclass/reports/01_frameclass-indexed-validity.md
- **Artifacts**: plans/01_frameclass-indexed-validity.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Give the proof-side `FrameClass` tag a semantic interpretation (`FrameClass.Sat`), define validity
once as `ValidIn fc φ`, and replace the five hand-copied monotonicity lemmas and the four copied
`SetSemanticConsequence*_mono` lemmas with one antitonicity lemma each, pointing the same direction
as `DerivationTree.lift`. The design is **already prototyped and compiled sorry-free** against the
current tree (report §4); the implementation is transcription plus mechanical migration, not
derivation. The migration is deliberately **additive first, subtractive second**: existing
statements are preserved as derived corollaries so the ~115 application sites in `Soundness.lean`
and `Correctness.lean` — and the C2/C14 axiom baselines that sit downstream of them — never move.
Done when `lake build` is green, no `sorry` is introduced, `check-module-invariants.sh` passes, and
the four flagship axiom profiles are byte-identical to baseline.

### Research Integration

The plan is built directly on report §4 (the verified prototype), §2 (the measured 92-site call
census), §5 (hazards), and §6 (the recommended decomposition). Four report findings reshape the
task as originally described and are binding on this plan:

1. **The marker typeclasses in `FrameConditions/FrameClass.lean` are the WRONG ingredient.** The
   task description names them as "the missing ingredient"; they are not. `SerialFrame` adds
   `[NoMaxOrder] [NoMinOrder]` (harmless — both are `infer_instance`-derivable from the `Valid*`
   binder set) and `DiscreteTemporalFrame` **omits** `[IsPredArchimedean]`, which `ValidDiscrete`
   binds. Routing `soundness_discrete` through it would silently widen the discrete carrier class.
   `Sat` is therefore defined fresh against the raw Mathlib predicates, matching the existing
   `Valid*` binder sets on the nose so the migration is provably content-free.
2. **`Sat` must be a `Prop`-valued `def`, never a marker class.** `SuccOrder`/`PredOrder` are
   data-carrying, so the Discrete case is an existential over instances; and monotonicity requires
   *recovering* constraint content (`Dense ≤ Dedekind` must extract `DenselyOrdered D`), which an
   instance-implicit marker discards.
3. **`FrameConditions/Validity.lean` is nearly all dead.** `ValidLinear`, `ValidDenseFc`,
   `ValidDiscreteFc`, `ValidOverInt` and all nine of its bridge theorems have zero external
   consumers. Only `ValidOver` is used. It is a layer to delete, not extend.
4. **`ValidDedekind` has no frame class** (it is the paper's TM⁺_c) and must stop sharing a stem
   with `FrameClass.Dedekind`. Renaming it to `ValidComplete` costs 3 code sites and closes the
   docstring hazard structurally rather than by warning.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only and is not modified by this plan. This task supplies
vocabulary for two roadmap items rather than completing either: "consequence completeness for all
four frame classes" (ROADMAP.md:72) and the "`Decidable (⊨ φ)` instances for the four frame
classes" (ROADMAP.md:121). It also directly serves the roadmap's PROVEN-vs-SORRY-FREE discipline:
the `ValidDedekind` trap (report §5.1) is exactly a "predicate that computes without being the
property its name suggests," and this plan closes it by making the wrong statement unwritable.

## Goals & Non-Goals

**Goals**:
- A `FrameClass → carrier-constraint` interpretation (`FrameClass.Sat`) with its antitonicity lemma.
- `ValidIn (fc) (φ)` and `SetSemanticConsequenceOn (fc) (Γ) (φ)` defined once, with all 8 bridges to
  the existing predicates.
- ONE monotonicity lemma (`validIn_mono`) replacing the five hand-written `valid_implies_*` lemmas,
  including the currently-`private` `validDedekindDense_of_validDense`; and one
  (`setSemanticConsequenceOn_mono_fc`) replacing the four copied `*_mono` lemmas.
- The dead `FrameConditions/Validity.lean` surface retired; `ValidDedekind` renamed to
  `ValidComplete`; `ValidOverInt`/`ValidInt` deduplicated.
- Sorry-free, `lake build` green, `check-module-invariants.sh` passing, flagship axiom profiles
  unchanged.

**Non-Goals**:
- Unifying the four `soundness_*` inductions into `Derivable fc Γ φ → SetSemanticConsequenceOn fc Γ φ`
  (review issue H2, ~23 theorems across four files). This plan supplies the vocabulary that theorem
  needs; proving it is a separate task.
- The BL⁺ mirror (`BLValid*`, 4 predicates + 3 lemmas). Cheap once `Sat` exists, since `Sat` is
  language-agnostic — file as follow-up.
- `SatisfiableBaseSet/DenseSet/DiscreteSet` → `SatisfiableSetOn fc` (the ∃-dual, and the missing
  `SatisfiableDedekindDenseSet` row) — file as follow-up.
- Relocating `inductive FrameClass` into a shared low-level module to remove the
  `Semantics → ProofSystem` import seam. Cleaner layering, but it moves a namespace referenced by
  ~45 axiom constructors and every `DerivationTree`/`Derivable` signature.
- Any change to the *statements* of `valid_implies_valid_dense`, `valid_implies_valid_discrete`,
  `valid_implies_validDedekindDense`, or the four `SetSemanticConsequence*` predicates before
  Phase 6. Statement stability is the mechanism that protects the axiom baselines.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Flagship axiom profiles drift (C2/C14 cover `BXCanonical.completeness{,_dense,_discrete}`, `Chronicle.countermodel_dense`, `Decidability.sound_of_isValid`, `completeness_dedekind` — all six downstream of the migrated predicates) | H | M | Phases 1-5 change no statement, only bodies. Run `bash scripts/check-module-invariants.sh` at every phase boundary; treat any C2 delta as a stop condition, not a baseline to update |
| `Semantics → ProofSystem` import seam introduces a cycle or an unwanted global dependency | H | L | Report verified `ProofSystem.Axioms` transitively imports nothing from `Semantics/` or `Metalogic/`. Confine the seam to the one new module; **do not** import `FormalSystem.FrameConditions` from it (see Phase 1 note on inlining `ValidOver`) |
| Naming collision: six `Semantics/` modules carry a bare `open TaskFrame`, and `TaskFrame.ValidOn` already exists (16 occurrences) | M | M | Use `ValidIn`, never `ValidOn`; introduce no new notation (`⊨[D]` is taken by `ValidOver`, `⊨` by `valid`) |
| Destructuring the `Sat .Discrete` existential breaks defeq with instances baked into `F`'s and `M`'s types (the hazard `SetConsequence.lean:322-328` already warns about) | M | M | Use the report §4.2 pattern — `obtain ⟨s, p, ha, hb⟩ := hs; exact @h D _ _ _ s p ha hb _ …`, passing instances positionally with `@`. **Never** re-install with `haveI` |
| C14 rejects a new/rewritten docstring for a stale axiom count | M | M | Every new or rewritten docstring must say **45** axiom constructors, never 14/21/42/44 |
| C15 rejects a new docstring's paper anchor | L | M | Reuse existing anchors (`def:logical-consequence`, `def:frame-validity`) or cite none |
| C9 rejects a task-number citation under `FormalSystem/` | M | L | Never write "task 507" or any task number into a `.lean` file; cite durable anchors (module path, definition name) |
| Phase 5 (`axiom_*_valid` collapse) fails to converge inside one dispatch | M | M | Explicit off-ramp: Phases 1-4 already satisfy all four stated deliverables. Mark Phase 5 `[PARTIAL]` or `[COMPLETED WITH EXCLUSIONS]`, revert to last green, and file the remainder |
| Phase 6/7 redefinition breaks proof scripts that `intro` the old instance-implicit binders (the real source of the 92-site count — application sites are safe, *definition-consuming* sites are not) | M | H | Declared `atomic-batch`: the file set is one objective, intermediate red states expected and uncommitted. Both phases have their own off-ramp back to the Phase 5 green |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5 | 2 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 6 |

Phases within the same wave can execute in parallel. Phases 2 and 3 have disjoint file territory
(Phase 2 owns `Semantics/Validity.lean`, `Metalogic/Soundness.lean`, `Metalogic/SetConsequence.lean`;
Phase 3 owns `FrameConditions/**` only), so parallel dispatch is safe if desired; sequential
execution is equally acceptable and simpler to gate.

---

### Phase 1: Introduce the FrameClass-indexed layer [NOT STARTED]

**Goal**: A new module carrying `FrameClass.Sat`, `Sat.anti`, `ValidIn`, `validIn_mono`,
`SetSemanticConsequenceOn`, its two monotonicity lemmas, and all 8 bridges — additive, with zero
call-site churn anywhere in the tree.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/FrameClassValidity.lean`, importing
      `FormalSystem.Semantics.Validity` and `FormalSystem.ProofSystem.Axioms` **only**.
- [ ] Transcribe report §4.1 verbatim: `FrameClass.Sat` (4-case match; Discrete is the existential
      `∃ (s : SuccOrder D) (p : PredOrder D), @IsSuccArchimedean D _ s ∧ @IsPredArchimedean D _ p`)
      and `FrameClass.Sat.anti` (`cases fc₁ <;> cases fc₂ <;> simp_all [FrameClass.Sat, LE.le]`),
      both inside `namespace FormalSystem.ProofSystem`.
- [ ] Define `ValidIn` with the `ValidOver` body **inlined**, NOT by importing
      `FormalSystem.FrameConditions.ValidOver`. The inlined form is:
      `∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D], fc.Sat D → ∀ (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (_ : τ.IsTotal) (t : D), TruthAt M τ t φ`.
      Report §3.3 rules out importing `FrameConditions/` from `Semantics/` (it would invert the
      current direction, since `FrameConditions/Soundness.lean` imports `Metalogic/Soundness.lean`).
      The §4.2 bridge proofs are unaffected by the inlining — they already thread `F M τ hτ t`
      positionally.
- [ ] Transcribe `validIn_mono` (report §4.1) and the four bridges `validIn_{base,dense,discrete,dedekind}_iff`
      (report §4.2) verbatim.
- [ ] Transcribe `SetSemanticConsequenceOn`, `setSemanticConsequenceOn_mono`,
      `setSemanticConsequenceOn_mono_fc` (report §4.4) and the four
      `ssc_{base,dense,discrete,dedekind}_iff` bridges (structurally identical to §4.2 with the
      `h_all` argument threaded).
- [ ] Add `import FormalSystem.Semantics.FrameClassValidity` to `FormalSystem/Semantics.lean`
      (C8 aggregator convention; the aggregator currently lists 18 imports at lines 7-24) and add a
      matching entry to its `## Submodules` docstring list.
- [ ] Confirm no `sorry` and no new `axiom` was introduced.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the report's prototype compiles verbatim against the
current tree modulo the `ValidOver` inlining, and that the new declarations create no ambiguity in
the six `Semantics/` modules carrying a bare `open TaskFrame`. Confirm by `lake build` over the
whole tree (not just the new module) — an ambiguity introduced by a new namespace member surfaces
only at those consumers.

**Files to modify**:
- `FormalSystem/Semantics/FrameClassValidity.lean` - NEW; the entire report §4.1/§4.2/§4.4 content
- `FormalSystem/Semantics.lean` - add one import (C8) plus one `## Submodules` docstring row

**Verification**:
- `lake build` green
- `bash scripts/check-module-invariants.sh` passes (C8 aggregator, C14 docstring counts say 45,
  C15 anchors resolve or are absent)
- `grep -c sorry FormalSystem/Semantics/FrameClassValidity.lean` returns 0
- The new module does not import `FormalSystem.FrameConditions` (grep the import block)

---

### Phase 2: Collapse the monotonicity lemmas onto the single one [NOT STARTED]

**Goal**: Every hand-written monotonicity lemma becomes a one-liner instance of `validIn_mono` or
`setSemanticConsequenceOn_mono_fc`, with **statements byte-identical to today's**.

**Tasks**:
- [ ] Replace the bodies of `valid_implies_valid_dense` (`Semantics/Validity.lean:349`),
      `valid_implies_valid_discrete` (`:356`), and `valid_implies_validDedekindDense` (`:371`) with
      the report §4.3 one-liners. Statements unchanged.
- [ ] Delete the `private validDedekindDense_of_validDense` at `Metalogic/Soundness.lean:1469` and
      re-export the general form from the new layer (report §4.3 proves it as a one-liner); fix its
      internal call sites to reference the public lemma.
- [ ] Leave `valid_implies_validDedekind` (`Validity.lean:364`) and
      `validDedekindDense_of_validDedekind` (`:383`) hand-written — `ValidDedekind` has no frame
      class and cannot join the `ValidIn` family (report §5.2; probe 14 confirms they compile
      unchanged).
- [ ] Replace the bodies of the four `setSemanticConsequence*_mono` lemmas
      (`Metalogic/SetConsequence.lean:124,130,136,144`) with `setSemanticConsequenceOn_mono` plus the
      corresponding `ssc_*_iff` bridge. Statements unchanged.
- [ ] Add `FormalSystem.Semantics.FrameClassValidity` to the import list of the touched modules as
      needed; verify no import cycle results.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts that ~115 application sites (38 in `axiom_dense_valid`, 39 in
`axiom_discrete_valid`, ~38 in the Dedekind analogue at `Soundness.lean:1763ff`, plus 3 in
`Decidability/Correctness.lean:152,159` and one Dedekind site) keep working untouched because the
statements do not move, and that `valid_implies_validDedekind` /
`validDedekindDense_of_validDedekind` have zero external call sites. Confirm at implementation time
by re-running the comment-stripped grep for each lemma name and by the fact that this phase's diff
touches no call site.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - three proof bodies replaced (lines ~349, ~356, ~371)
- `FormalSystem/Metalogic/Soundness.lean` - delete the `private` lemma at ~1469, redirect its uses
- `FormalSystem/Metalogic/SetConsequence.lean` - four proof bodies replaced (~124, 130, 136, 144)

**Verification**:
- `lake build` green
- **Axiom profiles byte-identical to baseline** for the six C2/C14-covered theorems. This is the
  phase's defining gate: `bash scripts/check-module-invariants.sh` and compare C2 output to the
  pre-phase capture. Any delta is a stop condition.
- `git diff` shows zero changes to any lemma *statement*

---

### Phase 3: Retire the dead `FrameConditions/Validity.lean` surface [NOT STARTED]

**Goal**: Delete the zero-consumer definitions and bridge theorems in `FrameConditions/Validity.lean`,
keeping only `ValidOver`, and repoint the module docstring at the new layer.

**Tasks**:
- [ ] Re-confirm zero external consumers for `ValidLinear` (`:79`), `ValidDenseFc` (`:89`),
      `ValidDiscreteFc` (`:100`), `ValidOverInt` (`:199`) and the nine bridge theorems, by
      comment-stripped grep across `FormalSystem/` and `Tests/`, **before** deleting anything.
- [ ] Delete them. Keep `ValidOver` (`:59`) and its `⊨[D]` notation — they are used by
      `FrameConditions/Soundness.lean` and `FrameConditions/Compatibility.lean`.
- [ ] Rewrite the module docstring to point at `FormalSystem/Semantics/FrameClassValidity.lean` as
      the load-bearing layer. Docstring must say 45 (C14) and reuse an existing paper anchor or none
      (C15). No task numbers (C9).
- [ ] Optionally retire the marker classes in `FrameConditions/FrameClass.lean` (`LinearTemporalFrame`,
      `SerialFrame`, `DenseTemporalFrame`, `DiscreteTemporalFrame`, `DedekindTemporalFrame`) or
      re-derive them from `Sat`. `DedekindTemporalFrame` has zero consumers of any kind. If this
      does not land cleanly, leave them and file a follow-up — it is not required by any deliverable.
- [ ] Update `FormalSystem/FrameConditions.lean` aggregator if any module is removed outright.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: Asserts the four definitions and nine bridge theorems have **zero** consumers
outside `FrameConditions/Validity.lean`, and that `import FormalSystem.FrameConditions` appears
exactly once outside the subtree (in `FormalSystem/FormalSystem.lean`). Confirm by comment-stripped
grep over `FormalSystem/**` and `Tests/**` before deletion; if any consumer is found, keep that
symbol and record the discrepancy rather than adapting the consumer.

**Files to modify**:
- `FormalSystem/FrameConditions/Validity.lean` - delete 4 defs + 9 bridge theorems; keep `ValidOver`;
  rewrite module docstring
- `FormalSystem/FrameConditions/FrameClass.lean` - optional marker-class retirement/re-derivation
- `FormalSystem/FrameConditions.lean` - aggregator update only if a module is removed

**Verification**:
- `lake build` green
- The diff touches nothing outside `FormalSystem/FrameConditions/` (plus the aggregator)
- `bash scripts/check-module-invariants.sh` passes (C8, C9, C14, C15)

---

### Phase 4: `ValidDedekind → ValidComplete` rename and `ValidInt`/`ValidOverInt` dedup [NOT STARTED]

**Goal**: Remove the name-stem collision between the frame-class-free TM⁺_c predicate and
`FrameClass.Dedekind`, and collapse the verified definitional duplicate.

**Tasks**:
- [ ] Rename `ValidDedekind → ValidComplete` (`Semantics/Validity.lean:301`),
      `valid_implies_validDedekind → valid_implies_validComplete` (`:364`), and
      `validDedekindDense_of_validDedekind → validDedekindDense_of_validComplete` (`:383`).
- [ ] Rewrite the `ValidComplete` docstring: it is the paper's TM⁺_c (complete simpliciter, model
      class `{ℤ, ℝ}` up to `≃+o`); `ProofSystem/Axioms.lean:519-524` already states that no
      `FrameClass` element picks it out. Replace the old "retargeting `soundness_dedekind` at this
      yields a refutable theorem" warning with a statement of why the trap is now structurally
      closed: `ValidIn .Dedekind` is the only way to state `.Dedekind` validity and it is the dense
      one by construction (report §5.1). C14: say 45. C15: existing anchor or none. C9: no task
      numbers.
- [ ] Update the ~15-20 prose references to `ValidDedekind` across docstrings and `docs/` so C14/C15
      and C12/C13 link resolution stay green.
- [ ] Retire `ValidOverInt` if Phase 3 has not already removed it, keeping `ValidInt`
      (`Semantics/IntTransfer.lean:336`). The two are the same predicate — the report verified
      `example (φ : Formula) : ValidInt φ = ValidOverInt φ := rfl` compiles.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: Asserts `ValidDedekind` has exactly **3** comment-stripped code occurrences
(its own `def` plus two lemmas) and ~15-20 prose references, and `ValidOverInt` has zero external
consumers. Confirm with a comment-stripped grep before renaming and a full-text grep for prose
after; a code count above 3 means the rename is wider than planned and the phase should be re-scoped
rather than pushed through.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - rename 3 declarations, rewrite the hazard docstring
- `FormalSystem/Semantics/IntTransfer.lean` - keep `ValidInt`; docstring note if `ValidOverInt` retired
- `FormalSystem/FrameConditions/Validity.lean` - remove `ValidOverInt` if still present
- Prose sites across `FormalSystem/**` docstrings and `docs/**` - reference updates

**Verification**:
- `lake build` green
- `bash scripts/check-module-invariants.sh` passes — C14 (no stale axiom counts, `.lean` docstrings
  included), C15 (paper anchors), C12/C13 (markdown paths and links), C9 (no task numbers)
- `grep -rn 'ValidDedekind\b' FormalSystem/ docs/` returns only `ValidDedekindDense` matches

---

### Phase 5: Collapse the `axiom_*_valid` triple into one `axiom_validIn` [NOT STARTED]

**Goal**: Replace three ~40-line `cases h with` blocks plus `axiom_valid` with one frame-class-indexed
theorem. This is the single largest concrete payoff of the task.

**Tasks**:
- [ ] State `axiom_validIn {φ} (h : Axiom φ) (fc : FrameClass) (h_fc : h.minFrameClass ≤ fc) : ValidIn fc φ`
      in `Metalogic/Soundness.lean`.
- [ ] Prove it as one 45-case match. The Base rows (37 of them) are each
      `validIn_mono (FrameClass.base_le fc) ((validIn_base_iff _).mpr (…_valid …))`, reusing the same
      base-axiom validity lemmas `axiom_valid` (`Soundness.lean:875`) already uses directly. The
      remaining rows discharge from their own frame class via `validIn_mono` against `h_fc`.
- [ ] Retain `axiom_valid` (`:875`), `axiom_dense_valid` (`:929`), `axiom_discrete_valid` (`:990`)
      and the Dedekind analogue (`~:1753ff`) as **statement-unchanged corollaries** of `axiom_validIn`
      via the `validIn_*_iff` bridges. Do not delete them in this phase — their statements are what
      protect the axiom baselines.
- [ ] Use `by decide` for closed `FrameClass` order goals (`FrameClass` has `DecidableEq` and a
      `DecidableRel` for `≤` at `Axioms.lean:549`; the regression `example`s already rely on this).

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Asserts 45 axiom constructors of which 37 carry `minFrameClass = .Base`, and
that `axiom_dense_valid`/`axiom_discrete_valid`/the Dedekind analogue apply exactly one monotonicity
lemma to that same 37-lemma set. Confirm at implementation time by counting the `cases` arms in each
of the three blocks and cross-checking against `Axiom.minFrameClass` (`Axioms.lean:~611`) before
writing the collapsed match; a mismatch means some arm is not a pure monotonicity application and
must be carried over by hand.

**Off-ramp (explicit)**: If this does not converge inside one dispatch, revert to the Phase 4 green,
mark this phase `[PARTIAL]` (or `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions`
record), and proceed to close the task. **Phases 1-4 already satisfy all four stated deliverables**;
Phase 5 is consolidation, not a deliverable.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` - add `axiom_validIn`; re-derive the four existing
  `axiom_*_valid` theorems as corollaries

**Verification**:
- `lake build` green
- Axiom profiles byte-identical to baseline for the six C2/C14-covered theorems
- `bash scripts/check-module-invariants.sh` passes
- Net line reduction in `Soundness.lean` (the three ~40-line blocks collapse)

---

### Phase 6: Redefine `ValidDense`/`ValidDiscrete`/`ValidDedekindDense` on `ValidIn` [NOT STARTED]

**Goal**: The three frame-class-carrying validity predicates stop being independent copies and become
`def X φ := ValidIn .Y φ`, with their definition-consuming proof sites migrated.

**Tasks**:
- [ ] Redefine `ValidDense` (`Semantics/Validity.lean:206`), `ValidDiscrete` (`:248`) and
      `ValidDedekindDense` (`:336`) as `ValidIn .Dense` / `ValidIn .Discrete` / `ValidIn .Dedekind`.
- [ ] Fix every site that *consumes the definition* (i.e. `intro`s the old instance-implicit binders
      or unfolds the predicate), as distinct from the many sites that merely *apply* it — application
      sites are unaffected. Highest-churn files by comment-stripped count: `Soundness.lean` (23),
      `StrongCompleteness.lean` (11), `Semantics/Validity.lean` (10),
      `Decidability/BiLasso/Assembly.lean` (9), `Decidability/Correctness.lean` (3), plus 1-2 each in
      `BXCanonical/Completeness.lean`, `BXCanonical/CompletenessDedekind.lean`,
      `DiscreteNonCompactness.lean`, `Decidability/Verified/Bridge/{DenseTruth,IntTruth}.lean`,
      `SoundnessLemmas/CoValidity.lean`, `Tests/BimodalTest/TableauConformance.lean`.
- [ ] When destructuring the `Sat .Discrete` existential, use the report §4.2 `@`-positional pattern.
      **Never** re-install instances with `haveI` — it breaks defeq with the instances baked into
      `F`'s and `M`'s types (the hazard `SetConsequence.lean:322-328` already documents).
- [ ] Update the docstrings of the three predicates to name the frame class they abbreviate.

**Timing**: 2 hours

**Depends on**: 4, 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Asserts a 72-site comment-stripped occurrence count for these three names
(`ValidDiscrete` 28, `ValidDedekindDense` 23, `ValidDense` 18, minus overlap), of which only the
definition-consuming subset needs editing. Confirm at implementation time by re-running the
comment-stripped grep per file and, more decisively, by the compiler: build after the three
redefinitions and let the error list enumerate the true consuming set. The plan's per-file counts
are an upper bound on churn, not a work list.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - three definitions rewritten
- `FormalSystem/Metalogic/Soundness.lean`, `Metalogic/StrongCompleteness.lean`,
  `Metalogic/Decidability/BiLasso/Assembly.lean`, `Metalogic/Decidability/Correctness.lean`,
  `Metalogic/BXCanonical/{Completeness,CompletenessDedekind}.lean`,
  `Metalogic/DiscreteNonCompactness.lean`,
  `Metalogic/Decidability/Verified/Bridge/{DenseTruth,IntTruth}.lean`,
  `Metalogic/SoundnessLemmas/CoValidity.lean` - proof-script migration at definition-consuming sites
- `Tests/BimodalTest/TableauConformance.lean` - same

**Verification**:
- `lake build` green (one green commit for the whole batch; intermediate per-file states are expected
  red and MUST NOT be committed)
- Axiom profiles byte-identical to baseline
- `bash scripts/check-module-invariants.sh` passes
- No `sorry` introduced anywhere

**Off-ramp**: revert to the Phase 5 green and close the task; the deliverables do not depend on this.

---

### Phase 7: Redefine the four `SetSemanticConsequence*` on `SetSemanticConsequenceOn` [NOT STARTED]

**Goal**: The set-level half of the same collapse — the four byte-identical-except-the-binder-line
definitions become abbreviations, completing the symmetry with `SetDerivable` + `setDerivable_mono`.

**Tasks**:
- [ ] Redefine `SetSemanticConsequenceBase/Dense/Discrete/DedekindDense`
      (`Metalogic/SetConsequence.lean:79,87,97,106`) as `SetSemanticConsequenceOn .Base/.Dense/.Discrete/.Dedekind`.
- [ ] Migrate the definition-consuming sites: 20 internal to `SetConsequence.lean`, 3 in
      `StrongCompleteness.lean`, 2 in `DiscreteNonCompactness.lean`.
- [ ] Same `@`-positional destructuring discipline for the Discrete existential; no `haveI`.
- [ ] Update `SetConsequence.lean`'s module docstring to record that the file now carries one
      definition and one monotonicity lemma per side (`SetDerivable`/`setDerivable_mono` and
      `SetSemanticConsequenceOn`/`setSemanticConsequenceOn_mono_fc`) — the symmetry the review asked
      for. C14: 45. C15: existing anchor or none. C9: no task numbers.
- [ ] File the three deferred follow-ups (H2 soundness unification, the BL⁺ mirror, `SatisfiableSetOn`)
      in the implementation summary.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Asserts 20 comment-stripped occurrences of these four names
(`SetSemanticConsequenceDiscrete` 7, `Base` 5, `Dense` 5, `DedekindDense` 3) plus 25 call sites
(20 internal + 3 in `StrongCompleteness.lean` + 2 in `DiscreteNonCompactness.lean`). Confirm by
comment-stripped grep and by building after the four redefinitions to let the compiler enumerate the
true consuming set.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` - four definitions rewritten, ~20 internal sites,
  module docstring
- `FormalSystem/Metalogic/StrongCompleteness.lean` - 3 sites
- `FormalSystem/Metalogic/DiscreteNonCompactness.lean` - 2 sites

**Verification**:
- `lake build` green (one green commit for the batch)
- Axiom profiles byte-identical to baseline
- `bash scripts/check-module-invariants.sh` passes
- No `sorry` introduced anywhere

**Off-ramp**: revert to the Phase 6 green and close the task.

---

## Testing & Validation

- [ ] `lake build` exits 0 with no errors and no warnings introduced by this task
- [ ] `grep -rn '\bsorry\b' FormalSystem/` shows no new occurrences (C3 asserts the inventory is zero)
- [ ] `bash scripts/check-module-invariants.sh` passes, specifically:
  - C1 build, C2 flagship axiom sets, C3 sorry inventory
  - C8 aggregator convention (the new `Semantics/FrameClassValidity.lean` is imported by
    `FormalSystem/Semantics.lean`)
  - C9 no task-number citations under `FormalSystem/`
  - C14 no stale axiom counts in `docs/`, `README.md`, or `FormalSystem/**/*.lean` docstrings — every
    new or rewritten docstring says **45**
  - C15 every paper-anchor citation resolves against `specs/paper-definitions-of-record.md`
- [ ] Axiom profiles for `BXCanonical.completeness`, `BXCanonical.completeness_dense`,
      `BXCanonical.completeness_discrete`, `Chronicle.countermodel_dense`,
      `Decidability.sound_of_isValid`, and `completeness_dedekind` are byte-identical to the
      pre-Phase-1 baseline. Capture the baseline before Phase 1 and diff at every phase boundary.
- [ ] `Tests/BimodalTest/` builds and passes

## Artifacts & Outputs

- `FormalSystem/Semantics/FrameClassValidity.lean` (new) — `FrameClass.Sat`, `Sat.anti`, `ValidIn`,
  `validIn_mono`, 4 validity bridges, `SetSemanticConsequenceOn`, 2 monotonicity lemmas, 4
  consequence bridges
- Modified: `FormalSystem/Semantics.lean`, `FormalSystem/Semantics/Validity.lean`,
  `FormalSystem/Semantics/IntTransfer.lean`, `FormalSystem/FrameConditions/Validity.lean`,
  `FormalSystem/FrameConditions/FrameClass.lean` (optional),
  `FormalSystem/Metalogic/Soundness.lean`, `FormalSystem/Metalogic/SetConsequence.lean`,
  `FormalSystem/Metalogic/StrongCompleteness.lean`, and the migration files enumerated in Phases 6-7
- `specs/507_parameterize_validity_by_frameclass/summaries/01_*-summary.md` — implementation summary
  recording the three filed follow-ups (H2 soundness unification, BL⁺ mirror, `SatisfiableSetOn`)

## Rollback/Contingency

Every phase ends at a green `lake build` and is committed at that boundary, so rollback is
`git revert` (or reset to) the last green phase commit. Phases 5, 6 and 7 each carry an explicit
off-ramp: Phases 1-4 alone satisfy all four stated deliverables and the full acceptance criteria
(sorry-free, green build, invariants passing, axiom profiles unchanged), so abandoning any of the
last three phases leaves the task completable rather than blocked. If Phase 1 itself fails to
compile — the least likely outcome, since the prototype was verified — delete the new module and its
aggregator import; the tree returns to its exact pre-task state with no other file touched.

Before any intentional rollback on a dirty tree, run
`bash .claude/scripts/git-snapshot.sh 507` first (destructive git on uncommitted work is blocked by
the `guard-destructive-git.sh` hook otherwise).
