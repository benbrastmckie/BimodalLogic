# Implementation Summary: Task #444

- **Task**: 444 - Overhaul FormalFoundations.typ presentation
- **Status**: [COMPLETED]
- **Started**: 2026-08-13T16:04:00Z
- **Completed**: 2026-08-13T21:55:00Z
- **Effort**: ~6 hours
- **Dependencies**: None
- **Artifacts**: plans/02_formalfoundations-presentation-overhaul.md, definitions-of-record-444.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

`typst/FormalFoundations.typ` was rewritten from a seven-section, 390-line report into a
five-section document presenting, for Dana Scott reading cold, the mechanics of the completeness
results, the state of decidability, and the direction for a representation theorem. All eleven
`FIX:` tags are discharged, one genuine mathematical error is corrected, and four further fidelity
defects were found and fixed during the work. The document went from roughly 6 mathematical
environments to 63.

## What Changed

- `typst/FormalFoundations.typ` — rewritten. Five sections in payload order: The System (semantics
  first); What Is Proved; The Completeness Construction; Two Costs of the Semantics; Toward a
  Representation Theorem. Every mathematical object now lives in a `#definition`, `#theorem`,
  `#lemma`, `#proposition`, or `#corollary`; motivating prose survives only as bounded `#remark`s.
- `typst/bibliography.bib` — six entries added (Goldblatt, Chagrov–Zakharyaschev, Jónsson–Tarski
  I and II, Stone, Scott), each because it is actually cited.
- `typst/sync-check-whitelist.txt` — three paper anchors added with one-line reasons.
- `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md` — new: 19
  verbatim paper anchors, the G1/G2/G3 decisions, re-stamped counts, the FIX disposition table,
  and the Phase 10 audit verdicts.

## Decisions

- **G2 (Since/Until argument order).** The document's convention gloss was backwards. Verified
  from three sources read directly — the paper's own clause, `def:BLplus-defined`, and
  `Semantics/Truth.lean:153` — that the paper is guard-first and the Lean tree event-first. The
  document now uses the paper's infix `◁`/`▷`, guard-first; the Lean-convention footnote is
  dropped; and the discreteness indicator is written `Next⊤` everywhere, never `U(⊤,⊥)`, which
  removes the hazard at the one site where it bites.
- **G1 (BX identification).** The paper's 11 primary axioms and the Lean tree's 22 BX Temporal
  constructors are in exact bijection, one axiom to one future/past pair; the numeric gap is
  TD-duality bookkeeping. The reconciliation is stated and the hedge retained, since no theorem
  establishes the two axiomatizations prove the same sentences.
- **G3 (topology depth).** Definition plus theorem, since this is the reader's own most-developed
  question. The T1/R0 Separation theorem is stated with proof, and the
  partial-history-as-restriction question is posed as a live definitional question.
- **FIX-231** was executed by rewriting, not deleting: the discreteness dichotomy became the
  motivation for the case split, stated internally in `BL⁺`. The two-fibre figure was retired.

## Plan Deviations

- **Phase 6, discrete-branch credits** altered: the plan directed crediting Kamp at the
  construction, but the branch does not use Kamp's theorem — it uses Reynolds k-equivalence. Kamp
  moved to its own remark, cited to the 1968 dissertation rather than the 1971 paper.
- **Phase 11, page budget** excluded with a `#### Reasoned Exclusions` record: 28 pages against a
  17-page reference. Three compression levers were tried and measured before excluding.

## Verification

- Build: `typst compile typst/FormalFoundations.typ` exits 0; `typst compile
  typst/BimodalReference.typ` exits 0 (shared-module integrity).
- Tests: `scripts/typst-sync-check.sh` exits 0; `scripts/typst-status-counts.sh --json` agrees
  with the document's status table on all five fields.
- `grep -c "FIX:"` returns 0 (was 11). E2 register grep returns 0 (baseline 20). E5 vague-gloss
  grep returns 0. E6 task-number grep returns 0.
- No modification to `FormalSystem/**`, `typst/chapters/**`, `typst/BimodalReference.typ`, or
  `specs/ROADMAP.md`.

## Impacts

- Four fidelity defects were corrected that were live in the previous version: the atom
  interpretation (`|p| ⊆ H_F × D` for `|p_i| ⊆ W`, with the atomic clause `τ(x) ∈ |p_i|`); a
  citation to `limit_chronicle`, which is not a declaration but only a docstring mention; the
  claim that the discrete branch runs through Kamp's theorem; and the standard miscitation of
  Kamp's expressive-completeness result to the 1971 paper.
- Section 3 is now written at a formality that makes it liftable into
  `typst/chapters/04-metalogic.typ`, where a reuse channel already exists.
- `FormalSystem/Metalogic/Algebraic/README.md` was found stale — it lists
  `AlgebraicCompleteness.lean` as live and sorry-free, but that file is under
  `Boneyard/UltrafilterFrame/`. Routed around, not edited (non-goal).

## Follow-ups

- The `Metalogic/Algebraic/README.md` staleness above is worth a separate fix.
- `specs/decisions/untl-snce-argument-order.md` quotes a since-corrected version of the paper's
  footnote and is stale on that point; the live paper now states the mismatch correctly.
- `typst/chapters/01-syntax.typ` carries user-authored FIX tags asking for the same infix,
  guard-first Since/Until convention adopted here, plus an ordering preference (since before
  until, past before future). Applying that across the reference manual is unstarted.

## References

- `specs/444_overhaul_formalfoundations_presentation/plans/02_formalfoundations-presentation-overhaul.md`
- `specs/444_overhaul_formalfoundations_presentation/reports/01_team-research.md`
- `specs/444_overhaul_formalfoundations_presentation/definitions-of-record-444.md`
- `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`
