# Research Report: Task #600

**Task**: 600 - Rename dense extension to QTime (investigate first)
**Started**: 2026-09-16T11:42:00-07:00
**Completed**: 2026-09-16T12:05:00-07:00
**Effort**: Small (docstring-only outcome; ~30-60 min incl. `lake build`)
**Dependencies**: None (coordination notes for 584, 589 below)
**Sources/Inputs**: - Codebase (FormalSystem/ProofSystem/Axioms.lean, Semantics/FrameProperty.lean, Semantics/FrameClassValidity.lean, Semantics/Validity.lean, Metalogic/BXCanonical/Completeness.lean, Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean, Metalogic/Compactness.lean, Metalogic/WeakCanonical/PriorExpressivenessDense.lean), docs/theorem-index.md, paper ~/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex, specs/state.json
**Artifacts**: - specs/600_rename_dense_extension_qtime/reports/01_dense-vs-qtime-naming.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary
- **Verdict: do NOT rename `Dense` to `QTime`.** Record the rationale in docstrings and close.
- `FrameClass.ZTime` / `FrameClass.RTime` are named for their carrier because their semantic
  classes are *categorical*: `Sat .ZTime` = `IsZTime` (succ/pred-Archimedean) is exactly ℤ-time,
  `Sat .RTime` = `IsRTime` = `IsDense ∧ IsComplete` is exactly ℝ-time (Hölder dichotomy,
  `complete_duration_discrete_or_dense`). `Sat .Dense` = `TaskFrame.IsDense` = `DenselyOrdered
  F.Duration` is **not** categorical: it contains ℚ, ℝ, ℚ ×ₗ ℚ, etc. The name "QTime" would
  misdescribe the frame class.
- The partial order forbids narrowing the class to ℚ: `Dense ≤ RTime` (needed so Reynolds'
  density axioms `density`/`dense_indicator` are admissible at `.RTime`, argued in the
  `FrameClass` docstring) requires `Sat .RTime ⊆ Sat .Dense`, i.e. ℝ-frames must belong to the
  class. A class "≃ ℚ" would break `FrameClass.Sat.anti`.
- The *logic* does coincide with Th(ℚ-time): soundness over all dense frames plus the
  completeness countermodel `countermodel_dense_enriched`, which is built over
  `TemporalOrder.of Rat` (`cantorBfmcsDense ... : BFMCS Rat`), gives Th(dense frames) =
  Th(ℚ-time). That is a theorem about the class, not its definition, and the same holds of
  "the logic of any countable-dense witness"; it does not license renaming the class.
- The paper names it by density: **TM**_d / **BX**_d, "the dense task frames" (`def:TMplus`,
  `cor:tm-completeness`: "TM_d is strongly complete over the dense task frames", vs "TM_z and
  TM_r are weakly complete over ℤ-time and ℝ-time"). The Lean triple Dense/ZTime/RTime already
  tracks the paper subscripts d/z/r one-for-one; docs/theorem-index.md row "TM_d (dense) |
  `FrameClass.Dense`" records this.
- The paper uses "ℚ-time" precisely where ℚ differs from the dense class: "Kamp's theorem does
  not extend to ℚ-time" (line ~1083) -- yet it does hold over ℝ, a dense frame. Expressiveness
  names like `uSExpressivelyCompleteOverDensePrior` are about dense flows, so a blanket
  Dense->Q rename would be mathematically wrong at those sites.

## Context & Scope
Researched whether the frame-class tag `FrameClass.Dense` (and derived names
`ValidDense`, `derivable_of_validDense`, `detCompletenessDense`, `cantorBfmcsDense`,
`StrongCompletenessDense`, `CompactDense`, `PlusValidDense`, `SemanticConsequenceDense`, ...)
should become `QTime` for uniformity with `ZTime`/`RTime`. Constraint from task: rename only if
there is good reason; otherwise record rationale in the relevant docstring and close.

## Findings
### Codebase Patterns
- `FormalSystem/ProofSystem/Axioms.lean:538` `inductive FrameClass | Base | Dense | ZTime | RTime`,
  order Base ≤ everything, Dense ≤ RTime, ZTime incomparable. Docstring explains the RTime-above-
  Dense placement (Reynolds 1992 p.168) but gives **no** rationale for the name `Dense`.
- `FormalSystem/Semantics/FrameClassValidity.lean:118` `FrameClass.Sat`:
  `.Dense ↦ F.IsDense`, `.ZTime ↦ F.IsZTime`, `.RTime ↦ F.IsRTime`; module table anchors `.Dense`
  to `def:frame-properties`' Dense clause.
- `FormalSystem/Semantics/FrameProperty.lean:111` `abbrev TaskFrame.IsDense := DenselyOrdered
  F.Duration` ("Dense clause, verbatim"). `IsRTime`'s docstring has a section "Why this class is
  named `IsRTime`" explaining carrier naming via categoricity -- the natural place for a
  reciprocal note. The module docstring's "The two narrowed classes" section likewise explains
  that only the narrowed (categorical) classes get carrier names while the bare paper clauses
  keep the paper's name. `IsDense` is a bare paper clause that is *not* narrowed, hence keeps
  "Dense" -- the existing convention already implies the current name.
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean:144` `countermodel_dense_enriched`
  produces `F : FrameOver (TemporalOrder.of Rat)`; `derivable_of_validDense` (line 264) closes
  via it. `Chronicle.cantorBfmcsDense : BFMCS (fc := fc) Rat`.
- Strong completeness holds for Dense (`Metalogic/Compactness.lean:217 strongCompletenessDense`)
  but fails for RTime (`Metalogic/DedekindNonCompactness.lean`) -- another structural sign that
  the dense class behaves like an elementary (non-categorical) class, not a named carrier.
- Scale if a rename were ever done: ~430 `.Dense`/`FrameClass.Dense` sites, 49 `ValidDense`,
  plus dozens of derived names; but many `Dense` identifiers (`EpsilonDense`, `GoodDense`,
  `ContempEquivDense`, `DenseModelSurgery`, `DedekindINFDense`, `PriorExpressivenessDense`)
  refer to order-density / Reynolds' notions and must not be renamed at all.

### External Resources
- Paper `possible_worlds.tex`: `def:frame-properties` (Dense clause, ~l.3225), `app:dense`
  (`GGφ → Gφ` iff Dense, ~l.3349), `def:BX-d` "Dense Burgess--Xu Tense Logic BX_d" (~l.4107),
  `def:TMplus` intended classes "the dense task frames for TM_d, ℤ-time for TM_z, and ℝ-time for
  TM_r" (~l.4134), `cor:tm-completeness` "TM_d Strongly complete over the dense task frames"
  (~l.4349), l.1417 "discrete Archimedean orders are exactly ℤ-time, the dense and complete
  orders exactly ℝ-time".
- Model theory: for US-formulas, satisfiability over some dense order transfers to ℚ
  (downward Löwenheim-Skolem + Cantor); in this tree the equivalent fact is witnessed
  constructively by the ℚ countermodel. No Mathlib search was needed (naming question).

### Recommendations
1. Keep `FrameClass.Dense` and all derived names unchanged.
2. Add a "Why this class is named `Dense` and not `QTime`" paragraph to the `FrameClass`
   docstring in `FormalSystem/ProofSystem/Axioms.lean`, covering: (a) ZTime/RTime are named for
   their carrier because their classes are categorical; (b) the dense class is not (ℚ, ℝ,
   ℚ ×ₗ ℚ...), and cannot be narrowed to ℚ without breaking `Dense ≤ RTime` / `Sat.anti`;
   (c) its logic nevertheless equals the ℚ-time logic, since the completeness countermodel
   (`countermodel_dense_enriched`) lives over `Rat`; (d) the name matches the paper's TM_d/BX_d
   and `def:frame-properties`' Dense clause, so Dense/ZTime/RTime tracks the paper's d/z/r.
3. Add a short reciprocal pointer on `TaskFrame.IsDense` (FrameProperty.lean) next to the
   existing `IsRTime` naming section, and optionally one sentence in the
   `FrameClassValidity.lean` interpretation table notes. Do not duplicate the full argument
   (one canonical site: the `FrameClass` docstring).
4. Verify with `lake build` (detached/guarded) and the paper-anchor/citation lints
   (C15 anchors, `check-task-references.sh` -- no task numbers in docstrings).
5. No sorry, axiom, or proof change involved.

## Decisions
- Rename rejected: semantic class is non-categorical; order structure requires ℝ ∈ class; paper
  vocabulary is "dense"; ℚ-specific phrasing in paper marks a genuine difference (Kamp).
- No `user_decision` required: the task description delegates the choice conditional on
  finding good reason, and the evidence is one-directional.
- Optional (not recommended for this task): a named corollary `validDense_iff_validOverRat`
  would make claim (c) machine-checked; only add if cheap, otherwise cite
  `derivable_of_validDense` + `soundness_dense`.

## Risks & Mitigations
- Docstring insertion in `Axioms.lean` shifts line numbers cited as `Axioms.lean:NNN`
  elsewhere; task 589 (basename/line citations) is ordered terminal and re-measures, so no
  action needed beyond noting it. Prefer citing declaration names, not lines, in the new prose.
- Task 584 (paper vocabulary reconciliation) is unaffected -- keeping `Dense` is consistent with
  the paper; mention to avoid it re-raising the question.
- Stating "Th(dense) = Th(ℚ-time)" in prose must be precise: it is about theorems of
  `Derivable .Dense []` vs validity over frames with duration `TemporalOrder.of Rat`, following
  from soundness + the Rat countermodel.

## Tactic Survey Results
- Not applicable (no tactic survey performed)

## Context Extension Recommendations
- **Topic**: Frame-class naming convention (carrier names only for categorical classes)
- **Gap**: The convention is implicit, split between `IsRTime`'s docstring and FrameProperty's
  module docstring
- **Recommendation**: The new `FrameClass` docstring paragraph suffices; no context file needed.

## Appendix
- Searches: `grep FrameClass.Dense|.Dense` (Semantics, Metalogic), identifier inventory of
  `*Dense*`, `grep TemporalOrder.of Rat`, paper grep for `dense|mathbb{Q}|TM_|BX_`,
  in-flight task scan of specs/state.json (584, 589, 599 checked for overlap).
