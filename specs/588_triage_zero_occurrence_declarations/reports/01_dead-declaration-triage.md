# Sweep Evidence Report: Task #588

**Task**: 588 — Triage the 1,029 zero-occurrence declarations C17 reports
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence.
**Effort**: Large, but naturally sampled — this is a triage task with a reporting deliverable, not a delete-everything task.
**Dependencies**: **585** (the warning burn-down touches many of the same files and its unused-simp cluster overlaps this scan's candidates) and **591** (Automation renames change the names this scan reports). Run after both so the measurement is taken once, against final names.
**Sources/Inputs**:
- `bash scripts/check-module-invariants.sh` C17 output
- `scripts/check-module-invariants.sh` lines defining C17's scan
- `specs/reviews/review-2026-09-16.md`, Finding L1

## Executive Summary

- **C17 reports 1,029 declarations whose base identifier appears nowhere outside its own
  declaring line**, scanning `FormalSystem/` + `Tests/` + repo-wide markdown. It is explicitly
  REPORTED, never gated, and explicitly described in the harness as approximate.
- **It has never been triaged.** 1,029 is large enough that the number itself has stopped being
  informative — nobody reads a 1,029-line INFO block, which is presumably why the C17 output caps
  its display at 20 entries plus "… and 1,009 more".
- **The scan is textual, so false positives are guaranteed**, and the task is to characterise
  them, not to delete on the raw list. Known false-positive classes to expect: `simp`-set members
  reached by attribute rather than by name, `instance` declarations resolved by typeclass search,
  `lean_exe` entry points (`main`), constructors and projections reached through pattern matching,
  and declarations whose only consumers are in `FormalSystem/Boneyard/` (excluded from every
  walker).
- **There is at least one strong true-positive signal.** The `Automation/Normalization.lean`
  `*_fold` / `*_unfold` cluster contributes ten consecutive entries — `release_unfold` (146),
  `weak_until_unfold` (150), `trigger_unfold` (154), `weak_since_unfold` (158), `top_fold` (753),
  `diamond_fold` (760), `some_future_fold` (764), `some_past_fold` (768), `next_fold` (772),
  `prev_fold` (776). Ten sibling declarations all unreferenced is not the shape of a false
  positive; it is the shape of a normalization layer whose consumers were removed. Note that
  `FormalSystem/Boneyard/RetiredTactics/Normalization.lean` exists — seven tactic macros were
  lifted out of this very file on 2026-09-07 — so these ten are plausibly the lemmas those macros
  used.

## Why this is worth doing rather than suppressing

The repository already demonstrates the value: `Boneyard/RetiredTactics/README.md` records that
fourteen declarations and two modules were retired *on exactly this measurement* — "zero
invocations anywhere in the live library and zero in `Tests/`, counting only real invocations and
not docstring mentions or the defining file's own round-trip examples." That is C17's criterion,
applied by hand, with a good outcome. This task is that same exercise at scale.

Note the phrase "not docstring mentions": C17 counts markdown and docstring occurrences as
references, so it is *more* permissive than the criterion that retired the tactics. A declaration
C17 flags has not even a docstring mention elsewhere.

## Recommended approach

This should produce a **classification**, and only then deletions.

1. **Stratify the 1,029 by declaration kind and directory** before reading any of them. Expect the
   shape to be very uneven; `Automation/` in particular is likely over-represented because
   exporters and generators have entry points nothing else calls.
2. **Mechanically eliminate the known false-positive classes** — `instance`, `@[simp]`/`@[aesop]`
   attributed declarations, `main`, anything in a `lean_exe` root closure. Report how many that
   removes. This alone may cut the list substantially and is the highest-value first step.
3. **Re-run the remainder with `Boneyard/` included as a reference source.** A declaration whose
   only consumer is archived is a different case from one with no consumer at all, and the two
   deserve different dispositions.
4. **Triage the survivors by cluster, not by line.** Ten `*_fold` lemmas are one decision, not
   ten. Look for sibling groups in the same file.
5. **Deliver a report with a disposition per cluster**: keep (with the reason it is unreferenced),
   archive, or delete. Execute only the unambiguous ones in this task; spawn follow-ups for
   anything contentious.
6. Consider whether C17 should grow the false-positive filters from step 2 permanently, so the
   number it reports is the number that matters. That is arguably the most durable deliverable
   here — a C17 that reports 80 real candidates is read; one that reports 1,029 is not.

## Explicit non-goals

- Do not gate C17. The harness is deliberate that it "never affects FAILURES", and a textual
  approximation should not become a build gate.
- Do not delete anything whose only evidence of deadness is this scan and whose removal would
  change an axiom baseline (C2/C14) or a paper-anchor citation (C15).

## Verification

- `lake build` exits 0; `bash scripts/check-module-invariants.sh` passes in full after every
  deletion batch — in particular C2/C14 axiom baselines unmoved, C15 anchors unbroken, C21
  `MainResults.lean` subset intact.
- C17's reported count drops, and the drop is accounted for line by line in the task summary:
  how many were filtered as false positives, how many archived, how many deleted.
- If C17's filters were extended: the new count is recorded in `docs/development/MODULE_INVARIANTS.md`.
