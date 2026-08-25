# Implementation Summary: Completeness Capstone — Consequence Completeness for All Classes

- **Task**: 362 - completeness capstone: consequence completeness for all classes, strong where compact
- **Plan**: `specs/362_completeness_capstone_consequence_all_classes_strong_where_compact/plans/01_consequence-completeness-all-classes.md`
- **Status**: All six phases [COMPLETED]
- **Type**: lean4
- **Session**: sess_1787662855_e59fd5

## Outcome

Finite-context **consequence completeness** now exists unconditionally for all four frame
classes. `lake build` is green at 2493 jobs; `latexmk` on `latex/BimodalReference.tex` compiles
with zero errors; **zero sorries were introduced**, and every new terminus is audited by
`#print axioms` at exactly `[propext, Classical.choice, Quot.sound]`.

Terminology discipline held throughout: every statement landed in Phases 1-3 takes
`Γ : Context = List Formula` and is therefore consequence completeness, **never strong**. The
only correct uses of "strong completeness" in the new material are the `Prop`-valued names for
open obligations over `Γ : Set Formula`.

## What Landed

### Leg A — `FormalSystem/Metalogic/StrongCompleteness.lean` (Phases 1-3)

Fourteen new declarations, replacing the three "Reserved / intentionally absent" prose blocks:

| Class | Relation | Declarations |
|-------|----------|--------------|
| Base | reuses the existing `SemanticConsequence` | 4: `semantic_deduction_base`, `consequence_completeness_base`, `soundness_base_consequence`, `completeness_base` |
| Dense | new `SemanticConsequenceDense` | 5: the def plus `semantic_deduction_dense`, `consequence_completeness_dense`, `soundness_dense_consequence`, `completeness_dense` |
| Discrete | new `SemanticConsequenceDiscrete` | 5: the def plus `semantic_deduction_discrete`, `consequence_completeness_discrete`, `soundness_discrete_consequence`, `completeness_discrete` |

Base takes no `SemanticConsequenceBase` synonym, per the research report's finding (1): the
general `SemanticConsequence` quantifies over *all* carriers, and for `FrameClass.Base` "all
carriers" **is** the class. No `import` line was added — the transitive reach to
`BXCanonical.Completeness` through `BXCanonical.CompletenessDedekind` holds. No `_of_engine`
layer: all three engines already exist and are consumed directly.

A nine-entry `#print axioms` audit block covers the three consequence termini, the three weak
corollaries, and the three soundness guards — a superset of the six the plan named.

### Leg B (reachable part only) — Phase 4

- `FormalSystem/Metalogic/SetConsequence.lean`: four new Base definitions —
  `StrongCompletenessBase`, `CompactBase`, `SatisfiableBaseSet`, `ModelExistenceBase` — each an
  exact mirror of its Dense sibling modulo the relation/validity symbol and the dropped
  `[DenselyOrdered D]` binder.
- `StrongCompleteness.lean`: `strongCompletenessBase_of_compact`, with the `engine` hypothesis
  **kept live deliberately**. It is now dischargeable at `BXCanonical.completeness`, and the
  docstring says so; keeping it open isolates `CompactBase` as the entire remaining obligation
  for Base strong completeness. `CompactBase` occurs exactly once in code, as that hypothesis.

### Legs C and D — documentation currency (Phases 4-6)

- **Dedekind prose softened** in four places (the plan named two). The tree contains no
  `CompactDedekind` definition and no refuting theorem, so "the Dedekind consequence relation is
  not compact" outran its evidence. Replaced everywhere with "unavailable on the primary
  source's own terms", plus an explicit **three-status** discipline now stated in
  `StrongCompleteness.lean`, `SetConsequence.lean`, `FormalSystem/Metalogic.lean` and the LaTeX:
  Base and Dense **open**, Discrete **machine-refuted**, Dedekind **unproved-not-refuted**.
- **`FormalSystem/Metalogic.lean`** (the repo-root aggregator, not `Metalogic/Metalogic.lean`):
  four new entries and two edited entries, docstring only.
- **`latex/subfiles/04-Metalogic.tex`**: four false claims about the Lean tree removed, the moot
  "one remaining sorry" paragraph replaced, two stale summary-table rows corrected, and the
  plan's four currency edits applied.

## Deferred — spawn recommendation for S2-S5

**Leg B's substance was not attempted, by design, and is recorded here rather than as a `sorry`.**
Genuine strong completeness for Base and Dense needs a bespoke ultraproduct route, decomposed by
361's `design/04_subtask-decomposition.md` into four separate multi-phase subtasks that **do not
exist as task entries**:

- **S2** — ultraproduct carrier over `{L : List Formula // ∀ ψ ∈ L, ψ ∈ Γ}`
- **S3** — Łoś lemma for `TruthAt`
- **S4** — `ModelExistenceBase` / `ModelExistenceDense`, hence `CompactBase` / `CompactDense`
- **S5** — strong completeness for Base and Dense

**Authorization**: 361's GATING RULE is explicit that these may be *created* once 424's gate
passes, and nothing more. Task 424 is `[COMPLETED]` with a **PASSED** verdict, so the gate is
satisfied and spawning S2-S5 is authorized. **Recommend spawning them now that this task has
landed.** With `strongCompletenessBase_of_compact` and `strongCompletenessDense_of_compact` both
in place, S5 reduces to a one-line corollary of S4 for each class.

**Why the chronicle route cannot simply be extended** (361's Q2 finding, the more informative
half, verified against the tree during this implementation): every `BXCanonical` countermodel
routes through `bundleFlow_completeness_from_neg_membership`
(`FormalSystem/Metalogic/Algebraic/FlowFrame.lean:791`), whose three coherence hypotheses
(`BFMCS.RestrictedTemporallyCoherent` and the two `Restricted*UntilSinceCoherent` siblings) are
relative to a single `root : Formula` and quantify over `deferralClosure root`, while the engine
additionally demands `φ ∈ subformulaClosure root`. Both closures are `Finset Formula`-valued.
An infinite `Γ` needs coherence over `⋃_{ψ ∈ Γ} subformulaClosure ψ`, which is not a `Finset`
and has no single root to be relative to. Hence the recommended route abandons the chronicle
rather than extending it.

**Q1** — is `⊨_Base` / `⊨_Dense` compact? — remains **likely but not proved**.

## Scope Extensions — both TAKEN

Both were flagged in the plan as explicit, user-visible decisions, and both were named in the
implementing dispatch's delegation context, so both were taken in full:

| Extension | File | Taken? |
|-----------|------|--------|
| Phase 4 | `FormalSystem/Metalogic/SetConsequence.lean` | Yes — 4 defs |
| Phase 6 | `latex/subfiles/04-Metalogic.tex` | Yes — 4 false claims + 4 currency edits |

## Plan Deviations

1. **Phase 4, S2-S5 docstring note — altered.** The plan asks that 424's PASSED gate and the
   S2-S5 decomposition be recorded in the `strongCompletenessBase_of_compact` docstring.
   `.claude/rules/no-task-references-in-deliverables.md` forbids task-number citations outside
   `specs/**`, and `FormalSystem/**` is a deliverable. The substance is recorded in full without
   the numbers: the gate is stated as passed, the four-step ultraproduct route is named, the
   deliberate non-attempt is stated, and the structural obstruction is given. The numbered
   references live in this summary, where they are permitted. Same adaptation applied to the
   LaTeX in Phase 6.

No other deviations. Every plan step was executed as written, in order.

## Discrepancies Found and Recorded

1. **The plan's leg-A total is arithmetically wrong.** Phase 3's Scope Hypothesis says leg A
   totals "twelve" declarations "(4 + 5 + 5)". That sum is **fourteen**. The three per-phase
   counts are each exactly as specified and each was confirmed at implementation time; only the
   sum was misstated. No class picked up an unplanned relation and none lost a soundness guard.

2. **A fourth (and fifth) instance of the false `sorryAx` claim surfaced in the LaTeX**, and was
   fixed as Phase 6's Scope Hypothesis directs. Beyond the three named sites, the Weak
   Completeness theorem footnote and the Metalogic Implementation table's `Weak Completeness`
   row both restated that `completeness` (Base) carries one live `sorryAx`. Both are false —
   `BXCanonical.completeness` audits at `[propext, Classical.choice, Quot.sound]`. Two adjacent
   stale-but-not-false claims were corrected in the same pass (the roadmap sentence calling the
   consequence result "conditional", and the architecture diagram's node label).

3. **The plan cites an archived symbol name.** Phase 6 asks that the chronicle obstruction be
   attributed to `fully_restricted_parametric_completeness_from_neg_membership`. That name
   survives only in `FormalSystem/Boneyard/`; the live engine is
   `bundleFlow_completeness_from_neg_membership` (`Algebraic/FlowFrame.lean:791`). The
   structural claim is exactly right and was verified against the live definitions; only the
   name needed correcting, in both the Lean docstring and the LaTeX.

4. **A pre-existing dangling Lean citation was found and deliberately NOT fixed.**
   `latex/subfiles/04-Metalogic.tex:48` cites `temp_future_valid` for the TF axiom. No such
   declaration exists anywhere in `FormalSystem/`, under that or any TF-specific name
   (`modal_future_valid`, the MF row above it, does exist). It entered with the `latex/`
   relocation commit long before this task, sits in the axiom-validity table rather than in any
   region Phase 6 is directed to edit, and is not newly cited. Recorded rather than silently
   widening the phase. **This is a live documentation defect worth a follow-up.**

5. **`specs/TODO.md`'s dependency-status block is stale and self-contradicting.** The plan
   records this and the implementation did not re-litigate it: 361 is completed and archived at
   `specs/archive/361_strong_completeness_architecture_and_weak_terminus_gap_analysis/`, 424 is
   `[COMPLETED]` with a PASSED verdict, and the three weak-completeness engines leg A consumes
   (`BXCanonical.completeness`, `completeness_dense`, `completeness_discrete`) were confirmed
   present and sorry-free by direct build audit.

6. **LaTeX overfull hboxes in `04-Metalogic.tex` went from 40 to 57.** Zero errors either way.
   The increase is inherent to citing more unbreakable `\texttt{}` Lean identifiers in denser
   prose; the file's worst offender (276pt) is pre-existing and untouched, and two of the
   largest pre-existing boxes actually narrowed as a result of these edits. Long path tokens in
   the new prose were shortened to claw back three of them. Cosmetic, not a build failure.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (full tree) | Green, 2493 jobs |
| `lake build FormalSystem.Metalogic.StrongCompleteness` | Green after every phase |
| Direct dependents built (shadowing check) | `FormalSystem.Metalogic`, `FormalSystem.Metalogic.DiscreteNonCompactness` — both green |
| `#print axioms` on all new termini | Exactly `[propext, Classical.choice, Quot.sound]` |
| Sorries introduced | **Zero**. Every `sorry` in `FormalSystem/` is pre-existing and under `Boneyard/` |
| New axioms | **Zero**. `grep -c "^axiom "` unchanged at 7 |
| Vacuous definitions | **Zero**. The one grep match (`FormalSystem/Examples/TemporalStructures.lean:538`) is pre-existing, untouched, and not vacuous — it proves a real statement whose target happens to reduce |
| `latexmk` on `latex/BimodalReference.tex` | 0 errors, 35 pages |
| Lean symbols cited in the LaTeX | 103 checked; every one newly cited exists |
| Plan compliance (all 19 named declarations) | Passed |
| "Reserved"/"intentionally absent" prose | None survives |
| Terminology audit | No `Context`-based result is called "strong completeness" in any touched file |
| Task-number references outside `specs/**` | None |

## Files Modified

- `FormalSystem/Metalogic/StrongCompleteness.lean` — 15 new declarations, extended axiom audit, softened Dedekind prose, refreshed module docstring
- `FormalSystem/Metalogic/SetConsequence.lean` — 4 new Base definitions, refreshed module docstring
- `FormalSystem/Metalogic.lean` — tracking table (module docstring only)
- `latex/subfiles/04-Metalogic.tex` — false claims removed, currency edits
