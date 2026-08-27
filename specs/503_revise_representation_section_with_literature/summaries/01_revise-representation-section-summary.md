# Implementation Summary: Task #503

- **Task**: 503 - revise_representation_section_with_literature
- **Status**: [COMPLETED]
- **Started**: 2026-08-26T16:44:00Z
- **Completed**: 2026-08-27T00:02:00Z
- **Effort**: ~7.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_revise-representation-section.md, notes/claim-audit.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Rewrote `= Toward a Representation Theorem <sec:representation>` in `typst/FormalFoundations.typ`
end to end, replacing the section's single undifferentiated notion of "representation theorem"
and its three-route framing with an explicit four-way distinction (algebraic embedding / duality /
task-frame representation / first-order axiomatization) and a six-rung ladder tracking each rung's
real status. Two factual errors were corrected (the interior-operator claim about `#allpast`/
`#allfuture`, and the anachronistic attribution of the ultrafilter-frame notation to Jónsson &
Tarski), a new subsection states the Goldblatt/Esakia duality and diagnoses the *Spherical*
obstruction as a compactness condition invisible to TM's similarity type, and the shift-set target
is re-scoped per frame class rather than treated as one uniform first-order payoff. All six phases
of the plan completed; both `typst/FormalFoundations.typ` and `typst/BimodalReference.typ` compile
cleanly and `scripts/typst-sync-check.sh` passes all three checks.

## What Changed

- `typst/FormalFoundations.typ` — `<sec:representation>` rewritten: new four-way opening
  distinction and six-rung ladder table/diagram (replacing the old three-route table and
  Jönsson--Tarski-labelled diagram); corrected `#definition("The Lindenbaum--Tarski Algebra")`
  block (box is an interior operator, `#allpast`/`#allfuture` are not, no `G` on the quotient);
  three named gaps to a BAO for TM plus the `sigmaQuot compose H compose sigmaQuot` next step; a
  new tense-algebra remark (TA/TD-dual give complete additivity for free, attributed to the
  literature); an anachronism fix for the `η(a) = {U : a ∈ U}` notation with a footnote citing the
  1951/52 papers' actual "perfect extension" terminology; a new `== Duality, Canonicity, and the
  Obstruction Diagnosed <sec:duality>` subsection (Jónsson-Tarski's inclusion vs. the equality
  completeness needs; a Canonicity definition and condensed Sahlqvist classification table for
  TM's axioms; a Descriptive General Frame definition and the Goldblatt/Esakia duality theorem;
  the "Spherical, diagnosed" remark; the open question re-posed over the descriptive general frame
  rather than the bare ultrafilter frame; Route T / Route M; a scoping remark on the "not a general
  frame" claim made elsewhere in the document); `== The Shift-Set Target` rewritten with the
  per-axiom first-order/second-order qualification, the two non-elementarity facts and their three
  consequences, a per-class breakdown (base/dense/discrete/complete), and a re-scoped declared
  gate; `== The Obstruction`'s closing remarks rewritten (the disjoint-union aside settled rather
  than left open, the stale end-of-section open question replaced, a new "What remains genuinely
  unsettled" closing inventory); the document abstract's stale "three candidate routes" sentence
  corrected for consistency.
- `typst/bibliography.bib` — six new entries: `venema2007algebrascoalgebras`, `gehrkevosmaer2011`,
  `goldblatt2003ghv`, `derijke1995sahlqvist`, `venema1993antiaxioms`, `fine1975elementarymodal`.
- `specs/503_revise_representation_section_with_literature/notes/claim-audit.md` — new working
  note (created): 12 VERIFIED items (re-checked directly against live Lean source and the
  corpus), 3 PROVISIONAL items (must appear hedged), 4 EXCLUDED items (must not appear at all),
  and the bibliography-addition table.

## Decisions

- Reframed the target theorem as the Goldblatt/Esakia duality (`BAO_τ ≃ DGF_τ^op`) rather than
  Jónsson-Tarski, following the research report: Jónsson-Tarski gives an embedding and an
  inclusion `V_Λ ⊆ HSPCmK`, not the equality strong completeness needs.
- Diagnosed *Spherical* as a compactness condition (shape-identical to BdRV's `compact` on a
  general frame) that fails to descend to TM's bare ultrafilter frame because fibers are
  duration-indexed and no operator of TM's similarity type denotes the duration relation — not an
  idiosyncratic frame axiom, and not evidence the obstruction is an artifact of how *Spherical* is
  phrased.
- Condensed the audit note's 14-row Sahlqvist classification to a 4-row grouped table in the
  Typst prose, since the section's role is the status claim (canonical vs. not, and why) rather
  than a full literature-survey reproduction of every axiom; the full per-axiom derivation stays
  in `notes/claim-audit.md` for anyone checking the classification.
- Left the two retained `== The Obstruction` arguments (the discharge-pattern inventory and the
  group-structure argument) unchanged on the Phase 6 redundancy pass, judging them non-duplicate
  with the new `@sec:duality` diagnosis: each makes a distinct point (an inventory of which
  existing Lean-side proof techniques fail and why, versus the topological compactness diagnosis).
- Added a citation for `gehrkevosmaer2011` (initially drafted uncited) via a footnote on the
  Jónsson-Tarski paragraph noting `Em(A)` is the modern "canonical extension" in that source's
  terminology, rather than dropping the bibliography entry, since the source genuinely supports
  that specific terminological point.

## Plan Deviations

- None (implementation followed plan). One item worth flagging as an in-scope refinement rather
  than a deviation: the plan's Phase 1 Scope Hypothesis estimated "roughly fourteen rows" for the
  Sahlqvist table; the audit note carries the full 14+ row classification, while the Typst prose
  itself uses a condensed 4-row grouped table (see Decisions above) — both are within Phase 4's
  task list, which asked for the classification to be "included," not reproduced row-for-row.

## Verification

- Build: N/A (documentation-only task; no Lean code written, per the plan's Non-Goals)
- Tests: N/A
- Compile: `typst compile typst/FormalFoundations.typ` — exit 0, only pre-existing "unknown font
  family" warnings (unrelated to this task). `typst compile typst/BimodalReference.typ` — exit 0,
  same pre-existing warnings only.
- `scripts/typst-sync-check.sh`: all 3 checks pass (Check 1 backtick resolution: 0 violations
  across 567 candidates; Check 2 count freshness: 0 mismatches; Check 3 machine appendix: 0
  mismatches).
- Files verified: Yes — all `#leansrc` pointers and backticked Lean identifiers in the revised
  section independently confirmed against live `FormalSystem/` source before use (see
  `notes/claim-audit.md`'s VERIFIED list), not carried over from the research report unread.

## Impacts

- `<sec:representation>` now states an internally consistent, literature-grounded account of what
  a representation theorem for TM would require, which of its six rungs are done or available off
  the shelf, and which are genuinely blocked or provably out of reach — replacing prose that
  conflated four different theorems under one name and mis-cited two of its own claims.
- The smallest concrete next step toward closing rung 2 (a `G` operator on the Lindenbaum quotient,
  `sigmaQuot ∘ hQuot ∘ sigmaQuot`, plus normality/additivity) is now named explicitly in the prose
  for a future implementation task to pick up; no Lean code was written here per the plan's
  Non-Goals.
- The project's declared gate for the semantic-compactness programme is now stated per frame
  class rather than uniformly, which changes what future work against `TM_f`/`TM_c` can claim to
  be authorized by it.

## Follow-ups

- None required by this task. Candidate future work named in the revised prose itself (not
  committed to here): defining `gQuot` and proving normality/additivity on the Lindenbaum quotient
  (rung 2); acquiring Sambin & Vaccaro 1988, S. K. Thomason 1972/1975, Goldblatt 1976, and
  Gehrke & Jónsson 2004 when literature discovery tooling is available, to support a fuller
  historical narrative than the current proxied one; checking whether `Spherical` actually holds
  on the descriptive general frame of a TM-algebra once metric operators are added (Route M).

## References

- `specs/503_revise_representation_section_with_literature/plans/01_revise-representation-section.md`
- `specs/503_revise_representation_section_with_literature/reports/01_representation-literature-research.md`
- `specs/503_revise_representation_section_with_literature/notes/claim-audit.md`
