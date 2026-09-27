# Implementation Plan: Sentence-to-Formula Translation, Proved Truth-Preserving

- **Task**: 679 - Lean Sentence-to-Formula translation, proved truth-preserving
- **Status**: [COMPLETED]
- **Effort**: 8.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/679_lean_sentence_formula_translation_truth/reports/01_sentence-formula-translation-truth.md`
- **Artifacts**: plans/01_sentence-formula-translation-truth.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/context/standards/artifact-management.md`
  - `.claude/context/standards/tasks.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/git-workflow.md`
- **Type**: lean4
- **Lean Intent**: true

## Overview

Define, in Lean, the consuming repository's source sentence AST (all 9 primitive plus 8 defined
operators, plus atoms), its elimination into this repository's six `Formula` primitives, and a
native source-side truth evaluation; then prove that the source evaluation agrees with `TruthAt`
of the translation at every frame, model, history and time. Expose the elimination through the
existing JSON wire vocabulary as a `lean_exe` plus a committed fixture file, so the consumer can
diff its own `translate` against this one mechanically rather than by reading. Definition of
done: a new `FormalSystem/SourceLanguage/` component carrying `sat_iff` with no `sorry` and no
new axiom, a `translate_sentence` executable reproducing the research report's verified
elimination table on a committed fixture list, and every repository gate green.

### Research Integration

The research report is the primary input and it is unusually load-bearing, because it did not
estimate — it executed. Four findings are carried into this plan as settled facts rather than
hypotheses:

- **The agreement theorem is assembly, not new mathematics.** `FormalSystem/Semantics/Truth.lean`
  already carries `@[simp, truth_norm]` characterizations for every derived operator the
  translation produces (`neg_iff`, `and_iff`, `or_iff`, `top_true`, `diamond_iff`, `box_iff`,
  `future_iff`, `past_iff`, `untl_iff`, `snce_iff`). A proof-of-concept of the whole result
  compiled clean; every induction case closes with `simp [Sat, tr, ih]`, with `cond`/`bicond`
  needing a trailing `tauto`. Phase 2's proof route is therefore validated, not proposed.
- **The elimination table was verified by execution against the consumer**, not inferred: for all
  16 runnable operators the Lean image's `Formula.toJson` is byte-identical modulo JSON
  whitespace to `to_json(translate(sentence))` run through ModelChecker's real `Syntax`/`translate`
  path. The table is reproduced verbatim in Phase 3's fixture list.
- **Two operators do not push through to the "natural" Lean operator**, and both would be
  silently wrong written the obvious way. The consumer's `\rightarrow` routes through `¬A ∨ B`, so
  its image is `Formula.or (neg A) B`, **not** `Formula.imp A B`; the consumer's `\future` is
  `¬\Future¬`, so its image is `(allFuture (neg A)).neg`, **not** `Formula.someFuture A`.
  `FormalSystem/MinusLanguage/Translation.lean` already documents and proves this phenomenon for
  `tr_someFuture_ne`; that idiom transfers directly and is the basis of the three `≠` results.
- **`next`/`prev` carry the one genuine semantic subtlety.** `Formula.next φ = untl ⊥ φ` means
  unconditionally "φ at some `s` with `(t,s)` empty", i.e. `∃ s, t ⋖ s ∧ φ at s`; the consumer
  means `t + 1`. Both forms compiled in the proof-of-concept. This plan states the `CovBy` form
  as the theorem and the `Order.succ`/`Order.pred` forms as corollaries under
  `[SuccOrder] [NoMaxOrder]` / `[PredOrder] [NoMinOrder]`, per the report's decision.

Two report-recommended items are deliberately promoted to their own phases rather than folded
into the Lean work, because this repository gates new modules mechanically: registering a new
top-level directory in `scripts/measure-refactor-partitions.py`'s `LANGUAGE_FILE_LAYERS` (without
a row `layer_of` raises and `check-metalogic-cycles.sh` fails) and in `ORGANISATION.md`'s layer
table, and regenerating the root `FormalSystem.lean` with `lake exe mk_all` (C33 asserts it is
byte-for-byte what the generator emits).

### Prior Plan Reference

No prior plan. This is the task's first planning round.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch, and no ROADMAP.md consultation was performed.

## Goals & Non-Goals

**Goals**:

- Define, prove, and expose: `Sentence`, `tr`, `Sat`, `tr_cond_ne`, `tr_someFut_ne`,
  `tr_somePast_ne`, `tr_injective`, `sat_iff`, `next_iff_covBy`, `prev_iff_covBy`,
  `next_iff_succ`, `prev_iff_pred`.
- Zero-debt: no `sorry`, no new axiom, no deferral. `#print axioms sat_iff` shows only the
  standard three.
- A mechanical, committed cross-check channel (fixture file plus `lean_exe translate_sentence`)
  that the consumer can diff its own `translate` against without reading Lean.
- Module docstrings that state honestly what the theorem does and does not certify: an
  independent verified reference for the consumer to validate against, **not** a discharge of the
  consumer's S4 obligation and **not** a route to deleting it.

**Non-Goals**:

- Writing anything in the ModelChecker repository. The consumer-side assertion belongs there and
  must not be written from here; the fixture file plus the report's table is what that work
  consumes.
- Fixing the consumer's known `\top` defect in `Sentence.update_types`. The Lean side covers
  `\top` unconditionally, which turns that exclusion into a visible fixture diff; repairing the
  Python is out of scope.
- Delegation — relocating the consumer's translation into a verified Lean pass. Revised Premise 3
  settled this as structurally infeasible; nothing in this plan promises obligation deletion.
- The stability modal `⊡`, the A1/A2/A3 (ADEQ) chain, and any `TruthEnv`/`*Clauses` instance for
  `Sentence` (the abstract clause layer is built for languages whose primitives are the shared
  five; 18 constructors are not that shape and the instance machinery would cost more than the
  `simp` proof it replaces).
- Consolidating the existing `Metalogic/DiscreteNonCompactness.lean` `truthAt_next_iff` with this
  component's `next_iff_succ`. The duplication is recorded in a docstring cross-reference; the
  merge is a separate concern (importing Metalogic from a layer-1 module would be an upward edge).

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.Truth
import Mathlib.Order.Cover
import Mathlib.Order.SuccPred.Basic

namespace FormalSystem.SourceLanguage

open FormalSystem.Syntax FormalSystem.Semantics

/-- The consuming repository's source sentence AST: all 9 primitive and 8 defined
operators, plus atoms. `untl`/`snce` are guard-first. -/
inductive Sentence : Type where
  | atom : Atom → Sentence
  | bot : Sentence
  | neg : Sentence → Sentence
  | wedge : Sentence → Sentence → Sentence
  | vee : Sentence → Sentence → Sentence
  | box : Sentence → Sentence
  | allFut : Sentence → Sentence
  | allPast : Sentence → Sentence
  | untl : Sentence → Sentence → Sentence
  | snce : Sentence → Sentence → Sentence
  | cond : Sentence → Sentence → Sentence
  | bicond : Sentence → Sentence → Sentence
  | top : Sentence
  | dia : Sentence → Sentence
  | someFut : Sentence → Sentence
  | somePast : Sentence → Sentence
  | next : Sentence → Sentence
  | prev : Sentence → Sentence

/-- Elimination of every defined operator into the six `Formula` primitives. -/
def tr : Sentence → Formula := sorry

/-- The source-side truth evaluation, mirroring the consumer's reference evaluator. -/
def Sat {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) :
    Sentence → Prop := sorry

theorem tr_cond_ne (A B : Sentence) : tr (Sentence.cond A B) ≠ Formula.imp (tr A) (tr B) := sorry

theorem tr_someFut_ne (A : Sentence) :
    tr (Sentence.someFut A) ≠ Formula.someFuture (tr A) := sorry

theorem tr_somePast_ne (A : Sentence) :
    tr (Sentence.somePast A) ≠ Formula.somePast (tr A) := sorry

theorem tr_injective : Function.Injective tr := sorry

theorem sat_iff {F : TaskFrame} (M : TaskModel F) (φ : Sentence) :
    ∀ (τ : WorldHistory F) (t : F.Duration), Sat M τ t φ ↔ TruthAt M τ t (tr φ) := sorry

theorem next_iff_covBy {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ ∃ s : F.Duration, t ⋖ s ∧ TruthAt M τ s φ := sorry

theorem prev_iff_covBy {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.prev φ) ↔ ∃ s : F.Duration, s ⋖ t ∧ TruthAt M τ s φ := sorry

theorem next_iff_succ {F : TaskFrame} [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.next φ) ↔ TruthAt M τ (Order.succ t) φ := sorry

theorem prev_iff_pred {F : TaskFrame} [PredOrder F.Duration] [NoMinOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : Formula) :
    TruthAt M τ t (Formula.prev φ) ↔ TruthAt M τ (Order.pred t) φ := sorry

end FormalSystem.SourceLanguage
```

This block was type-checked as written against the current build with `lake env lean`: no errors,
only the expected `declaration uses 'sorry'` warnings. The `Sentence` constructor list, the
`{F : TaskFrame}` implicit binder shape, the `∀ τ t` after the colon in `sat_iff` (following
`plusTruthAt_ofFormula` / `quantTruthAt_ofFormula`), and the `CovBy` / `SuccOrder` / `PredOrder`
instance requirements are therefore confirmed signatures rather than sketches. The implementation
may add declarations beyond this set (the `rfl` push-through equations, `DecidableEq`, `complexity`
mirrors); it must not weaken or rename any statement here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A future reader "simplifies" `\rightarrow`'s image to `Formula.imp`, or `\future`'s to `Formula.someFuture`, changing the subformula closure and hence the certificate label domain | H | M | The three `≠` results (Phase 1) plus a `#guard` on the corresponding fixture rows (Phase 3). Both fail loudly |
| The `succ`/`pred` corollary is promoted to the main statement, making the module silently false on dense orders (`next φ` is unsatisfiable there — `Metalogic/DedekindNonCompactness.lean` records this) | H | M | `CovBy` stays the theorem; the reason goes in the `SentenceTruth.lean` docstring with the dense-order citation |
| The Lean translation drifts from the consumer's as the consumer evolves, so the theorem certifies the wrong encoding | H | M | The Phase 4 fixture channel is the only defense that does not rely on reading. It is a committed data file compared by both sides, and both module docstrings say so |
| Over-claiming in a docstring — that this discharges S4, or that the consumer may delete its obligation | M | M | Revised Premise 3 is settled. Docstrings say "independent verified reference for the consumer to validate against"; the consumer's `TRUST_PIPELINE.md` row stays. Phase 2's verification explicitly greps its own docstring for the forbidden claim |
| The box-clause difference (`TruthAt`'s all-histories-same-time vs. the consumer's evaluator's all-lassos-all-positions, which is `□△φ`) is mistaken for a defect and "fixed" | M | M | Use `TruthAt`'s own box clause; record the extensional-equivalence-under-shift-closure note in the docstring, citing `Truth.box_always_iff` and `Semantics/ShiftSet.lean` |
| A new top-level directory trips an unregistered-module gate (`layer_of` raises; C33 byte-compare on the root aggregator; readme-lint's per-directory README requirement) | M | H | Phase 1 registers the directory in the same phase that creates it, and its verification runs the specific gates rather than only `lake build` |
| `FormalSystem/Semantics/ShiftSet.lean` is in sibling task 681's declared `file_scope`; this plan only cites it from a docstring | L | L | Cite it, never edit it. No file in this plan's `file_scope` overlaps 681's |
| Siblings 677, 680 share this working tree with no declared `file_scope` | M | M | Per the dispatch concurrency note: re-read every file immediately before editing; stage only this task's own explicit file list, never a directory or glob `git add`; never run `git-snapshot.sh` in its reverting default mode; treat a build failure outside this plan's file set as possibly a sibling's in-flight edit and report a foreign commit rather than proceeding |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 4 |
| 4 | 6 | 2, 4 |

Phases within the same wave can execute in parallel. Phases 2, 3 and 4 touch disjoint file sets
(`FormalSystem/SourceLanguage/SentenceTruth.lean` plus its gate rows; `Tests/BimodalTest/`;
`BimodalTools/` plus `lakefile.toml`), so parallel dispatch is safe — but each must re-read
`scripts/measure-refactor-partitions.py`, `FormalSystem.lean`, `FormalSystem/SourceLanguage.lean`
and `FormalSystem/SourceLanguage/README.md` immediately before touching them, since Phase 2 is
the only one of the three that edits any of those.

---

### Phase 1: The source language and its elimination [COMPLETED]

**Goal**: `FormalSystem/SourceLanguage/Sentence.lean` exists, compiles, and is registered in every
mechanism that gates a new top-level library directory. This is the syntax half only — it imports
nothing from `FormalSystem/Semantics/`.

**Tasks**:

- [x] Create `FormalSystem/SourceLanguage/Sentence.lean` with the standard 5-line copyright
      header (2026), importing `FormalSystem.Syntax.Formula` and nothing from
      `FormalSystem/Semantics/` (this is what makes it layer 0; `Syntax.Atom` already imports
      `FormalSystem.Init`, so C24 is satisfied transitively).
- [x] Declare `Sentence` exactly as the Challenge block gives it, with a per-constructor docstring
      naming the consumer's surface form (`\wedge`, `\Until`, `\rightarrow`, `\future`, ...) and
      stating for `untl`/`snce` that argument 1 is the guard and argument 2 the event.
- [x] Define `tr : Sentence → Formula` implementing the report's verified elimination table,
      including the four rows that are not the obvious operator: `cond A B ↦ ((tr A).neg).or (tr B)`,
      `bicond A B ↦ (((tr A).neg).or (tr B)).and (((tr B).neg).or (tr A))`,
      `someFut A ↦ ((tr A).neg.allFuture).neg`, `somePast A ↦ ((tr A).neg.allPast).neg`.
- [x] Add `@[simp]` `rfl` push-through equations for the operators that do commute with `tr`
      (`neg`, `wedge`, `vee`, `box`, `allFut`, `allPast`, `untl`, `snce`, `top`, `dia`, `next`,
      `prev`).
- [x] Prove `tr_cond_ne`, `tr_someFut_ne`, `tr_somePast_ne` in the
      `MinusLanguage/Translation.lean` `tr_someFuture_ne` idiom, each with a docstring saying the
      inequality is deliberate and naming the consequence of "simplifying" it (a different
      subformula closure, hence a different certificate label domain).
- [x] Prove `tr_injective` (`Function.Injective tr`), following `MinusLanguage/Translation.lean`'s
      `tr_injective`. *(deviation: altered — the statement is FALSE and was replaced by
      `tr_not_injective`, its disproof. `tr (cond A B) = tr (vee (neg A) B)` by `rfl`, because the
      elimination sends each defined operator onto the very abbreviation it stands for; `top`/`neg bot`,
      `dia`/`neg (box (neg ·))` and the existential tenses collide the same way. The
      `MinusLanguage` precedent does not transfer: that translation is primitive-to-primitive and
      same-name, this one collapses 17 operators onto 6. The consequence — no inverse pass is
      checkable, so the conformance channel compares forward only — is recorded in the module
      docstring and the directory README.)*
- [x] Record the range invariant in the module docstring: no `Formula.imp` in the range of `tr` is
      the image of a source-level implication — `imp` appears only inside the encodings of
      `neg`/`and`/`or`/`top` and of the two universal tenses.
- [x] Create `FormalSystem/SourceLanguage.lean` sibling aggregator (C8: sibling `X.lean` beside
      `X/`, never `X/X.lean`) importing `FormalSystem.SourceLanguage.Sentence`, with a module
      docstring in the `FormalSystem/MinusLanguage.lean` shape including a Module Invariant
      paragraph stating syntax-before-semantics within the directory and the
      `grep -rln 'import FormalSystem.Semantics' FormalSystem/SourceLanguage/` check.
- [x] Create `FormalSystem/SourceLanguage/README.md` (readme-lint check 1 is gated: every
      directory containing `.lean` files needs one) with a "Last verified" date and a per-file row.
- [x] Add `"SourceLanguage": {"Sentence": 0}` to `LANGUAGE_FILE_LAYERS` in
      `scripts/measure-refactor-partitions.py`, and the matching row to `ORGANISATION.md`'s layer
      table plus its prose list of language directories.
- [x] Regenerate the root aggregator with `lake exe mk_all --lib FormalSystem` (C33 byte-compares
      `FormalSystem.lean` against the generator's output — never hand-edit it).
- [x] Add the component's rows to `README.md` (the directory tree and the language table) and
      `FormalSystem/README.md` (the `SourceLanguage.lean` aggregator row and the directory row).

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: `Sentence` is asserted to need exactly 18 constructors (17 operators plus
atoms) and `tr` exactly 18 rows, and the elimination table is asserted to be the report's
Appendix table verbatim. Confirm at implementation time by checking the constructor count against
the Appendix table's 18 rows and by the Phase 3 `#guard` rows, which pin every row independently.
The gate-registration file list (`measure-refactor-partitions.py`, `ORGANISATION.md`,
`FormalSystem.lean`, two READMEs) is asserted to be complete; confirm by running the gates named
under Verification rather than by inspection, and add whatever a failure names.

**Files to modify**:

- `FormalSystem/SourceLanguage/Sentence.lean` — new: the type, `tr`, push-through equations, three
  `≠` results, `tr_injective`
- `FormalSystem/SourceLanguage.lean` — new: sibling aggregator
- `FormalSystem/SourceLanguage/README.md` — new: directory README
- `scripts/measure-refactor-partitions.py` — add the `SourceLanguage` key to `LANGUAGE_FILE_LAYERS`
- `ORGANISATION.md` — add the directory to the layer table and the per-file-layering prose
- `FormalSystem.lean` — regenerated by `lake exe mk_all --lib FormalSystem`
- `README.md`, `FormalSystem/README.md` — component rows

**Verification**:

- `lake build FormalSystem.SourceLanguage.Sentence` green, zero warnings.
- `lake build` green (the default target closure now includes the new module).
- `bash scripts/check-metalogic-cycles.sh` PASSes, and its syntax-before-semantics assertion
  reports the new layer-0 module (not a degenerate set).
- `python3 scripts/measure-refactor-partitions.py upward-edges` runs without
  `UnlayeredModuleError` and reports no new upward edge and no stale row.
- `lake exe checkInitImports` clean.
- `bash scripts/readme-lint.sh` reports no missing README.
- `bash scripts/check-copyright-headers.sh` clean.
- `git diff --stat FormalSystem.lean` shows only the two generated import lines.

---

### Phase 2: The truth evaluation and the agreement theorem [COMPLETED]

**Goal**: `FormalSystem/SourceLanguage/SentenceTruth.lean` proves `sat_iff` against `TruthAt`
itself, plus the four `next`/`prev` characterizations, with no `sorry` and no new axiom.

**Tasks**:

- [x] Create `FormalSystem/SourceLanguage/SentenceTruth.lean` importing
      `FormalSystem.SourceLanguage.Sentence` and `FormalSystem.Semantics.Truth` (this is what makes
      it layer 1).
- [x] Define `Sat` mirroring the consumer's reference evaluator (`_eval_mc_ast`) clause for
      clause, with the two deliberate departures recorded inline: `box` uses `TruthAt`'s own
      same-time all-histories quantifier, and `next`/`prev` use `CovBy` rather than `t ± 1`.
- [x] Prove `sat_iff` by `induction φ` with `∀ τ t` after the colon and `intro τ t` per case —
      generalizing over both is required, not optional: `box`/`dia` need the hypothesis at a
      different history, the four tense cases plus `untl`/`snce`/`next`/`prev` at a different
      time. Each case closes with `simp [Sat, tr, ih]`; `atom`/`bot` are `Iff.rfl`; `cond` and
      `bicond` need a trailing `tauto`.
- [x] Prove `next_iff_covBy` and `prev_iff_covBy` by
      `simp only [Formula.next, Truth.untl_iff, Truth.bot_false]` then `constructor` with
      `rintro`/`exact` (`CovBy` is an `And` here, so no `CovBy.*` API is needed).
- [x] Prove `next_iff_succ` from `next_iff_covBy` via `Order.covBy_succ` plus the two `not_lt`
      projections and `le_antisymm` — **not** `(Order.covBy_succ t).unique`, which does not exist
      for this `And`-shaped `CovBy`. Prove `prev_iff_pred` dually.
- [x] Write the module docstring recording, each as a named paragraph: (a) that `CovBy` is the
      theorem and `succ`/`pred` the corollaries, because `next φ` is unsatisfiable on a dense
      carrier (cite `Metalogic/DedekindNonCompactness.lean`), while the consumer's ℤ-time
      instantiation is what makes the corollary operative; (b) that `TruthAt`'s box clause is
      all-histories-same-time while the consumer's evaluator is all-lassos-all-positions (`□△φ`,
      `Truth.box_always_iff`), the two coinciding only because the certificate framework's `H_F`
      is closed under time shift (cite `Semantics/ShiftSet.lean` and
      `Semantics/TruthTransport.lean`'s `timeShift_preserves_truth`) — so a future reader must not
      "fix" the Lean side to match the Python; (c) a cross-reference to
      `Metalogic/DiscreteNonCompactness.lean`'s `truthAt_next_iff`, noting the deliberate
      duplication and that consolidation is out of scope because importing Metalogic here would be
      an upward edge; (d) that this is an independent verified reference for the consumer to
      validate its implementation against — it certifies the *encoding*, not the consumer's Python
      (nothing about `translate`'s memoization, `WeakKeyDictionary` identity keying, or
      `update_types` expansion is in scope) — and it does **not** discharge the consumer's S4
      obligation or license deleting it.
- [x] Add `"SentenceTruth": 1` to the `LANGUAGE_FILE_LAYERS["SourceLanguage"]` row, import the
      module from `FormalSystem/SourceLanguage.lean`, add its README row, and regenerate
      `FormalSystem.lean` with `lake exe mk_all --lib FormalSystem`.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: the proof is asserted to need no new mathematics — every case closing with
`simp [Sat, tr, ih]` plus `tauto` on `cond`/`bicond`, on the strength of a compiling
proof-of-concept. Confirm by the build plus `#print axioms sat_iff`; if any case needs a lemma not
already in `Semantics/Truth.lean`, that is a scope deviation to report, not to absorb silently.

**Files to modify**:

- `FormalSystem/SourceLanguage/SentenceTruth.lean` — new: `Sat`, `sat_iff`, the four `next`/`prev`
  results, the four docstring notes
- `FormalSystem/SourceLanguage.lean` — add the import
- `FormalSystem/SourceLanguage/README.md` — add the file row, refresh "Last verified"
- `scripts/measure-refactor-partitions.py` — add the `SentenceTruth` layer-1 row
- `FormalSystem.lean` — regenerated

**Verification**:

- `lake build` green, zero warnings on the new file.
- `#print axioms sat_iff` shows exactly `propext`, `Classical.choice`, `Quot.sound` and nothing
  else; same for the four `next`/`prev` results.
- `grep -c sorry FormalSystem/SourceLanguage/SentenceTruth.lean` is 0.
- `bash scripts/check-metalogic-cycles.sh` PASSes and now counts a layer-1 module in the
  `SourceLanguage` directory.
- `lake exe checkInitImports` clean.
- The docstring contains none of "discharges S4", "delete the obligation", or "no longer needed" —
  grep for each.

---

### Phase 3: Fixture `#guard` rows pinning the elimination table [COMPLETED]

**Goal**: every row of the report's verified elimination table is pinned by an executable
`#guard`, so a later "simplification" of `tr` fails a test instead of passing silently.

**Tasks**:

- [x] Create `Tests/BimodalTest/Syntax/SentenceTranslationTest.lean` (the `#`-command linter is
      disabled for the `BimodalTest` library, which is why these probes cannot live under
      `FormalSystem/`).
- [x] Add one `#guard` per elimination-table row, comparing `tr` of an atomic instance of each of
      the 18 constructors against the Lean image written out explicitly, using `Formula`'s `BEq`.
- [x] Add a `#guard` for `\top` specifically, with a comment noting that the consumer's corpus
      excludes this tag because of a known `TopOperator` defect in its own `update_types`, and
      that the Lean side covers it unconditionally.
- [x] Add an asymmetric `Until`/`Since` row whose operand swap changes the image, so a future
      regression to event-first fails here rather than passing silently.
- [x] Add a nested `someFut`/`allFut` row and a nested `cond` row, the two families that do not
      push through.
- [x] Register the module in `Tests/BimodalTest.lean` and add its row to
      `Tests/BimodalTest/README.md` if that file carries a per-file inventory.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: 18 constructor rows plus 4 structural rows is asserted to cover the table.
Confirm by counting `#guard` lines against the Appendix table's row count and checking that every
constructor name of `Sentence` appears at least once in the file.

**Files to modify**:

- `Tests/BimodalTest/Syntax/SentenceTranslationTest.lean` — new
- `Tests/BimodalTest.lean` — add the import
- `Tests/BimodalTest/README.md` — inventory row if the file carries one

**Verification**:

- `lake build BimodalTest` green — a failing `#guard` is a build error, so green is the assertion.
- Every `Sentence` constructor name appears in the test file (grep per constructor).
- Deliberately breaking one row locally (e.g. changing `cond`'s image to `Formula.imp`) makes the
  build fail; revert immediately. This is the non-vacuity control and it is not optional.

---

### Phase 4: The conformance channel — codec, executable, committed fixtures [COMPLETED]

**Goal**: the consumer can diff its own `translate` against this one mechanically: a `Sentence`
JSON codec in the existing tag vocabulary, a `translate_sentence` executable, and a committed
fixture file.

**Tasks**:

- [x] Create `BimodalTools/SentenceExport.lean` with `Sentence.toJson` in the established
      `Formula.toJson` style (`BimodalTools/DataExport.lean`), using a `sentence`-side tag
      vocabulary that mirrors the constructor names and keeps `untl`/`snce` on **named**
      `event`/`guard` fields so the wire stays order-free even though the constructor is not.
- [x] Add `pSentence`, the reader, in the `BimodalTools/JsonParse.lean` `pFormula` style, and a
      `translateSentenceLineToJson : String → String` performing parse → `tr` → `Formula.toJson`
      and returning a structured error string on a parse failure.
- [x] Create `BimodalTools/TranslateSentenceMain.lean`: the root-namespace `main` and nothing else,
      reading one line on stdin and printing one JSON line on stdout, mirroring
      `BimodalTools/CheckCertificateMain.lean`. The name is forced by C25N
      (`PascalCase(target)Main`).
- [x] Add the `[[lean_exe]] name = "translate_sentence"`, `root = "BimodalTools.TranslateSentenceMain"`,
      `supportInterpreter = true` block to `lakefile.toml` with the usage comment the sibling
      entries carry.
- [x] Import `BimodalTools.SentenceExport` from `BimodalTools.lean` (the aggregator imports every
      non-`Main` tooling module; C6 depends on this).
- [x] Commit `data/sentence-translation-fixtures.jsonl`: one line per fixture, each an object *(deviation: altered — relocated to `Tests/fixtures/sentence-translation-fixtures.jsonl`. `/data` is gitignored in its entirety (line 107 of `.gitignore`, with `data/*.jsonl` at line 68), and no file under `data/` is tracked — `data/README.md` included. A shared cross-repository artifact that cannot be obtained from git is not one, so the file was moved to a tracked path beside its reader rather than punching a hole in `.gitignore`. Every reference was updated, including in the already-committed Phase 1/2 files, and `Tests/fixtures/README.md` records why the directory exists.)*
      carrying the consumer's surface form, the source-sentence JSON, and the expected translated
      `Formula` JSON. Include at minimum one atomic instance of each of the 17 operators, the
      `\top` case, one asymmetric `\Until`/`\Since` instance, and one nested `\future`/`\Future`
      pair.
- [x] Document the wire schema and the fixture-file contract in `BimodalTools/README.md`, beside
      the `Formula` wire format and the tableau bridge protocol, stating explicitly that the
      consumer must compare **parsed JSON, not bytes** (`Formula.toJson` emits `", "`/`": "`
      separators which `json.dumps`'s defaults happen to match but nothing guarantees).

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: the fixture list is asserted to need 17 + 3 entries and the codec to need no
wire-format extension beyond a `sentence`-side tag set. Confirm by running the executable over
every fixture line and diffing against the file's own expected field; a fixture the codec cannot
round-trip is a scope deviation to report.

**Files to modify**:

- `BimodalTools/SentenceExport.lean` — new: `Sentence.toJson`, `pSentence`,
  `translateSentenceLineToJson`
- `BimodalTools/TranslateSentenceMain.lean` — new: the executable root
- `BimodalTools.lean` — add the `SentenceExport` import
- `lakefile.toml` — the `translate_sentence` `lean_exe` block
- `Tests/fixtures/sentence-translation-fixtures.jsonl` — new: the committed fixture list (relocated from `data/`, which is gitignored; see the Phase 4 deviation)
- `BimodalTools/README.md` — wire schema and fixture contract

**Verification**:

- `lake build BimodalTools` green.
- `lake exe translate_sentence` run over each fixture line reproduces that line's expected
  translated-formula JSON (compare parsed, not bytes).
- The emitted JSON parses back through `pFormula` for every fixture (round-trip).
- `bash scripts/check-module-invariants.sh` C25/C25N pass: the new `lean_exe` root compiles and is
  named `TranslateSentenceMain`.
- `python3 scripts/lake_targets.py` (or the C25 path that reads it) sees the new target.

---

### Phase 5: Round-trip test and the hand-off note [COMPLETED]

**Goal**: the conformance channel is regression-protected inside this repository, and the
consumer-side work has a written contract to consume.

**Tasks**:

- [x] Create `Tests/BimodalToolsTest/SentenceCodecTest.lean` asserting, per fixture, that
      `pSentence` parses the source JSON, `tr` produces the expected `Formula`, `Formula.toJson`
      of it re-parses through `pFormula` to the same term, and `Sentence.toJson ∘ pSentence` is
      the identity on the source JSON modulo whitespace.
- [x] Import the module from `Tests/BimodalToolsTest.lean`, checking first that it imports no
      executable root that would collide with the root-namespace `main` already in that
      environment (the file's own comment records this hazard).
- [x] Add the hand-off note to `BimodalTools/README.md`: what the consumer must assert
      (`to_json(translate(s))` equals `lake exe translate_sentence`'s output for every fixture
      line), that the assertion belongs in the ModelChecker repository and is not written from
      here, and that the fixture file is the shared artifact.
- [x] Add a `Tests/BimodalToolsTest/README.md` inventory row.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: the fixture count in the test equals the fixture file's line count. Confirm
by comparing the test's assertion count against `wc -l` on the fixture file at implementation
time.

**Files to modify**:

- `Tests/BimodalToolsTest/SentenceCodecTest.lean` — new
- `Tests/BimodalToolsTest.lean` — add the import
- `Tests/BimodalToolsTest/README.md` — inventory row
- `BimodalTools/README.md` — the hand-off note

**Verification**:

- `lake build BimodalToolsTest` green.
- `lake test` green (the `BimodalTest` test driver), with no `main`-collision error in the tools
  test environment.

---

### Phase 6: Record the cross-repository contract as durable context [COMPLETED]

**Goal**: the elimination table, the two non-push-through facts, the `next`/`prev` order caveat
and the box-clause note exist somewhere a future dispatch on either side of the boundary can find
them — they currently live only in the consumer's Python docstrings and this task's report.

**Tasks**:

- [x] Read `source_dir` from `/home/benjamin/Projects/BimodalLogic/.claude-extensions.json` and
      author the file under that source store at the path mirroring
      `.claude/context/project/lean4/domain/sentence-translation-contract.md` — never hand-author
      under `.claude/**`, which is a regenerated deploy artifact
      (`.claude/rules/source-store-deploy-boundary.md`).
- [x] Content: the 18-row elimination table; that `\rightarrow` is `or (neg A) B` and
      `\future`/`\past` are the double-negated universal tense, with the closure consequence of
      getting either wrong; the `CovBy`-vs-`succ` caveat; the box same-time-vs-all-times note; the
      fixture-file and `lean_exe` channel; and the scope limit (this certifies the encoding, not
      the consumer's Python, and does not discharge the consumer's obligation).
- [x] Reference durable anchors only — filenames, declaration names, section headings. No task
      numbers: this file is outside `specs/**`
      (`.claude/rules/no-task-references-in-deliverables.md`).
- [x] Add the file to the lean extension's context index if that extension's manifest carries one.

**Timing**: 0.5 hours

**Depends on**: 2, 4

**Verification Tier**: prose

**Files to modify**:

- `<source_dir>/extensions/lean/.../context/project/lean4/domain/sentence-translation-contract.md`
  — new (exact path resolved from `.claude-extensions.json` at implementation time)

**Verification**:

- Diff read-through: every changed hunk is prose in a new markdown file.
- `bash .claude/scripts/check-task-references.sh` (or the repo-wide lint equivalent) reports no
  task-number citation in the new file.
- The file is under the resolved `source_dir`, not under `.claude/`.

---

## Testing & Validation

- [x] `lake build` green with zero warnings on every new file.
- [x] `lake build BimodalTools` and `lake build BimodalToolsTest` green.
- [ ] `lake test` green. *(deviation: altered — `lake build BimodalTest` (the test driver's library) was run instead and is green, and `check-module-invariants.sh` reports `PASS C1 lake build BimodalTest exits 0`. The `lake test` wrapper was not invoked separately.)*
- [x] `bash scripts/check-module-invariants.sh` green — in particular C3 (zero structural
      `sorry`), C6 (no new unreachable module), C8 (aggregator convention), C19 (docstring
      coverage floor), C24 (`Init` reachability), C25/C25N (the new `lean_exe` root compiles and is
      correctly named), C28 (warning budget), C33 (root aggregator byte-for-byte from `mk_all`).
- [x] `bash scripts/check-metalogic-cycles.sh` PASSes, with the new directory contributing a
      layer-0 and a layer-1 module and no upward edge.
- [x] `lake exe checkInitImports` clean.
- [x] `bash scripts/readme-lint.sh` reports no missing README and no broken relative link.
- [x] `#print axioms sat_iff` shows only `propext`, `Classical.choice`, `Quot.sound`.
- [x] `lake exe translate_sentence` reproduces every fixture line's expected output, compared as
      parsed JSON.
- [x] Non-vacuity control (Phase 3): a deliberately wrong `tr` row fails the `#guard` build.
      Recorded as run, then reverted.

## Artifacts & Outputs

- `FormalSystem/SourceLanguage/Sentence.lean` — `Sentence`, `tr`, push-through equations,
  `tr_cond_ne`, `tr_someFut_ne`, `tr_somePast_ne`, `tr_injective`
- `FormalSystem/SourceLanguage/SentenceTruth.lean` — `Sat`, `sat_iff`, `next_iff_covBy`,
  `prev_iff_covBy`, `next_iff_succ`, `prev_iff_pred`
- `FormalSystem/SourceLanguage.lean`, `FormalSystem/SourceLanguage/README.md`
- `BimodalTools/SentenceExport.lean`, `BimodalTools/TranslateSentenceMain.lean`
- `Tests/fixtures/sentence-translation-fixtures.jsonl` — the shared cross-repository fixture list
- `Tests/BimodalTest/Syntax/SentenceTranslationTest.lean`,
  `Tests/BimodalToolsTest/SentenceCodecTest.lean`
- Edits: `lakefile.toml`, `BimodalTools.lean`, `BimodalTools/README.md`, `FormalSystem.lean`
  (regenerated), `README.md`, `FormalSystem/README.md`, `ORGANISATION.md`,
  `scripts/measure-refactor-partitions.py`, `Tests/BimodalTest.lean`,
  `Tests/BimodalToolsTest.lean`
- A context file under the resolved extension source store recording the cross-repository contract
- `specs/679_lean_sentence_formula_translation_truth/summaries/01_*-summary.md` at completion

## Rollback/Contingency

Every phase is a separable, additively-scoped commit, so rollback is per-phase rather than
wholesale.

- **Preferred route**: `git revert` the phase's own commit. Phases 3, 5 and 6 are purely additive
  (new test/doc files plus one aggregator import each) and revert cleanly. Phase 4 additionally
  removes one `lakefile.toml` block; Phases 1 and 2 additionally require re-running
  `lake exe mk_all --lib FormalSystem` after the revert so `FormalSystem.lean` matches the
  generator again (C33), and removing the directory's `LANGUAGE_FILE_LAYERS` rows in the same
  commit (a stale row fails `check-metalogic-cycles.sh` assertion B).
- **Before any rollback that would discard uncommitted work**, take a snapshot first per
  `context/contracts/recovery.md`'s rollback rung, including its out-of-scope override flag if the
  dirty tree carries tracked modifications outside this task's `file_scope` — which it may, since
  siblings 677, 680 and 681 share this tree. Do **not** emit a bare default-mode
  `git-snapshot.sh 679` as a routine start-of-phase checkpoint; a defensive checkpoint before
  risky work uses `--no-revert`, which is durable without reverting the working tree.
- **Contingency if `sat_iff` does not close as the proof-of-concept did**: the `cond`/`bicond`
  cases are the only classical ones, and the fallback is an explicit `constructor` with
  `by_cases` on the antecedent rather than `tauto`. If a case needs a characterization absent from
  `Semantics/Truth.lean`, prove it locally in `SentenceTruth.lean` and report it as a scope
  deviation — do not weaken the statement, and do not introduce a `sorry`.
- **Contingency if the fixture channel disagrees with the report's table**: that is a finding, not
  a build break. Record the specific row, keep the Lean side matching the consumer's actual
  executed output (the table was produced by running the consumer, so a disagreement means the
  consumer changed), and report it rather than silently re-deriving the table.
