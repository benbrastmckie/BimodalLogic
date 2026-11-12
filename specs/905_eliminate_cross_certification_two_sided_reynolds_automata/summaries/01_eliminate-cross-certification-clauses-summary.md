# Implementation Summary: Task #905

- **Task**: 905 - Eliminate the cross-certification clauses of the two-sided Reynolds automata, or show them load-bearing
- **Status**: [COMPLETED]
- **Started**: 2026-11-12T02:43:00Z
- **Completed**: 2026-11-12T03:42:00Z
- **Effort**: ~4 hours across five phases and five implementer dispatches
- **Dependencies**: None blocking. Task 901 (completed) supplied the architecture of record, which is this plan's sole edit target.
- **Artifacts**: plans/01_eliminate-cross-certification-clauses.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

The research dispatch answered (Q3) — is the clause-(a) cross-certification of the two-sided
Reynolds automata eliminable — in the affirmative: both clause (a)s are subsumed by their own
automaton's clause (b) (Theorem 1), the one further fact clause (b) cannot itself supply is
seeded from chronicle clause K1 alone (the section-8 seed lemma), and the truth lemma's
emergent-walk Step 3 is replaced by a four-link bootstrap Step 3′. This implementation carried
that eliminated design into
`specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`,
the architecture of record, across five phases: repair a located defect in the pure-literal
closure (D1), drop both clause (a)s and the clause-(a) first-transition obligation, land the
seed lemma and replace Step 3 with Step 3′, apply a second located defect repair (D2) and trace
it forward to Lemma 7+, and close the ledger (Executive Summary, Finding 16.3, section 6,
Decision 5, Recommendation 5, section 17, the evidence-tier table, and a dated amendment note).
Every edit is markdown prose inside one `specs/**` artifact; no Lean source, `lake` invocation,
or `require` was touched, and no completeness claim is made.

## What Changed

- `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md` — amended in place across all five phases:
  - Phase 1: `PastLits`/`FutLits` (section 1.1) repaired to be closed under same-polarity subformulas of the translations (defect D1); Lemma 5.1 re-cites the repaired definition.
  - Phase 2: both automata's clause (a)s dropped from `Viol⁺`/`Viol⁻` (sections 5.2-5.3); the clause-(a) first-transition obligation dropped from `ρ⁺(s₀⁺, ĉ)` (section 5.4); Theorem 1 (the elimination) added.
  - Phase 3: the chronicle seed lemma (Lemma 2, seeded from K1 alone) landed in section 8; Finding 14.4's Step 3 replaced by the four-link Step 3′.
  - Phase 4: Claim 1⁺'s consequent restated to the conditional form clause (b) actually delivers (defect D2 repair); Claim 1⁻ mirrored; Claim 2⁺ re-pointed to Lemma 7.3's conditional form (consumption point S2); the forward trace to Lemma 7+ read end to end and confirmed unaffected.
  - Phase 5: the header's `**Amended by**` note, the Executive Summary's cross-certification and Lean-position bullets, section 6 (new Finding 4(i) rule-inventory point), Finding 16.3 ((Q3) answered in the affirmative, bi-infinite branch closed), Decision 5, Recommendation 5 (alphabet-shrink expectation withdrawn), section 17's cardinality sentence, and the evidence-tier table (one row replaced by eight) all brought into line with the eliminated design.
- `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/issues.jsonl` — issue and win entries recorded as they arose across all five phases.

## Decisions

- Theorem 1 (clause (a) subsumed by clause (b) via the bar-translation's purity) and the chronicle
  seed lemma (seeded from K1 alone, with no circularity against the truth lemma's own induction)
  are adopted as the design of record in place of cross-certification.
- The bi-infinite-automaton alternative (the third admissible answer to (Q3)) is recorded as
  closed, not merely open: `ExtDerivation`'s rule set offers only `aaAnte` and its `reflectTime`
  mirror, neither of which can name a bi-infinite run, so the alternative is unusable regardless
  of what ω-automata theory supplies (Finding 4(i)). The supporting claim that the standard
  bi-infinite-recognizability reduction is itself a forward/backward cut-and-split is marked
  *recalled*, not held — the Literature corpus was swept and holds no substantive source.
- Recommendation 5's original expectation that the elimination would "shrink the alphabet's
  enlargement" is withdrawn as not holding: both `{δ_pt}` and `{δ_ft}` remain required by the two
  clause (b)s and are additionally consumed as Theorem 1's `γ`-instances, so the enlargement is
  exactly as forced after the elimination as before. The honest gain is one ω-regularity argument
  and one first-transition obligation per automaton.
- Every historical/ledger reference to the eliminated device in the target report uses the
  hyphenated form `clause-(a)`, never the literal space-separated substring `clause (a)`, per the
  plan's own `grep -n 'clause (a)'` = zero-hits verification criterion (established in Phase 4
  and carried forward in Phase 5).

## Plan Deviations

- None (implementation followed the plan exactly across all five phases).

## Impacts

- A future reader of task 901's report now reads the eliminated design throughout — both automata
  are one disjunct smaller, and the circularity argument closes on clause (b) plus chronicle
  clause K1 rather than on a cross-certifying device — with no surviving occurrence presenting
  cross-certification as the design of record.
- The alphabet enlargement is unaffected: no downstream Lean-position claim ((O1)/(O3)/(O4))
  moves, since removing a disjunct from two violation languages changes an automaton's language,
  not a cardinality.
- The bi-infinite-automaton question is closed rather than left as a standing open item, removing
  one item a future formalization attempt might otherwise have had to re-investigate.

## Follow-ups

- None. (Q3) is answered, the ledger is reconciled, and no Lean item is filed, per the dispatch's
  own "report only, no Lean work; no completeness claim" scope.

## References

- Plan: `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/plans/01_eliminate-cross-certification-clauses.md`
- Research report: `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/reports/01_eliminate-cross-certification-clauses.md`
- Target (amended): `specs/901_two_sided_reynolds_engine_paper_proof/reports/01_two-sided-reynolds-engine-paper-proof.md`
- Phase handoffs: `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/handoffs/phase-{1,2,3,4,5}-handoff-*.md`
- Issue log: `specs/905_eliminate_cross_certification_two_sided_reynolds_automata/issues.jsonl`
