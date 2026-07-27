# Implementation Summary: Task #405

- **Task**: 405 - Prove semantic validity of the Prior-U and Prior-S gap axioms over dense
  Dedekind-complete duration groups
- **Plan**: `plans/01_discharge-prior-gap-sorries.md`
- **Status**: [COMPLETED]
- **Phases**: 2 of 2 complete

## Outcome

Both Prior gap sorries in `FormalSystem/Metalogic/Soundness.lean` are discharged. The file's
sorry count dropped from 4 to exactly 2, and the two survivors are `sep_valid` and
`sep_swap_valid` — task 406's territory, untouched here.

| Check | Result |
|---|---|
| `lake build` | green, 1892 jobs, exit 0 |
| `grep -c '^  sorry$' Soundness.lean` | 2 (baseline 4) |
| `#print axioms prior_U_gap_valid` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms prior_S_gap_valid` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms exists_isGLB_of_lub` | `[propext]` |
| New axioms introduced | 0 (repo total unchanged at 2) |
| Files modified | 1 (`FormalSystem/Metalogic/Soundness.lean`) |
| Import block / build graph | unchanged |

## Phase 1: Transcribe the verified proofs and rebuild

The research dispatch had already written, compiled, and verified both proofs before reverting,
leaving an archived copy of the proved file. Rather than retype the ~65 lines of tactic script,
the three known-good hunks were re-applied and the result checked byte-for-byte against that
archive (`diff -q` reported the files identical). This eliminated transcription risk entirely.

Landed:
- `private theorem exists_isGLB_of_lub` — recovers a greatest lower bound from the binder set's
  least-upper-bound hypothesis, via `isLUB_lowerBounds` on the lower-bound set. Chosen over the
  order-reversing negation route because it needs no additive-group structure.
- `prior_U_gap_valid` — supremum construction over `A`, the set of right endpoints of
  φ-intervals starting at `t`.
- `prior_S_gap_valid` — the infimum dual over `B`, the set of left endpoints of φ-intervals
  ending at `t`.

Neither theorem **statement** was altered; both are verified-exact transcriptions of Reynolds
1992 lines 114 and 116, and a changed statement would have been a regression rather than a fix.
Both remain at `ValidDedekindDense`. The proofs would in fact support the stronger
`ValidDedekind`, but generalizing is a recorded hard non-goal: `soundness_dedekind` must target
`ValidDedekindDense` because `Dense ≤ Dedekind` admits `Axiom.density` and
`Axiom.dense_indicator`, both false on `ℤ`.

Committed at this green milestone (`8852689c6`) before Phase 2 began, per the
commit-per-green-substep mandate.

## Phase 2: Repair the now-false prose

Comment-only edits; no tactic line changed (confirmed by inspecting the phase diff).

- The two `-- sorry: … follow-up:` docstring blocks became proof-summary prose, citing Reynolds
  1992 printed p.168 and describing the supremum/infimum constructions. The Prior-S block names
  `exists_isGLB_of_lub` as the bridge and records the mirrored trichotomy-branch ordering.
- The section comment no longer claims four lemmas of debt. The heading is de-scoped to
  "Semantic validity of the three Reynolds axioms", and the debt claim now lives in a single
  trailing paragraph naming `sep_valid` and `sep_swap_valid` and marked as deletable outright —
  so the follow-up work that discharges them can remove it without surgical editing.
- Added the informational note that the Prior gap proofs consume only the least-upper-bound
  hypothesis and the linear order, so the axioms hold on *every* Dedekind-complete linear order;
  the `DenselyOrdered` binder is present for chain consistency, not mathematical necessity. This
  is documentation only — the binder set was deliberately not weakened.
- No task numbers appear in the new prose, per
  `.claude/rules/no-task-references-in-deliverables.md`.

## Plan Deviations

- **Helper placement relocated (altered).** The plan's Phase 1 step said to insert
  `exists_isGLB_of_lub` "after the Prior-U docstring block ending at :1457", which contradicts
  report §6.1's "after the section comment ending at line 1447". The plan's wording was followed
  literally in Phase 1 (matching the archived artifact byte-for-byte), but it places the helper
  *between* the Prior-U docstring and `prior_U_gap_valid` — so that docstring silently documents
  the helper instead of the theorem. Since Phase 2 exists precisely to stop comments from
  asserting things that are not true, the helper was moved above the Prior-U docstring in Phase
  2, following report §6.1. The helper is still immediately above `prior_U_gap_valid`, the proof
  text is unchanged, and the helper gained a docstring of its own. This defect was latent in the
  archived artifact and would otherwise have shipped.

No other deviations: the binder set was not generalized, no `Truth.and_iff`/`Truth.or_iff`
lemmas were added, no time-reversal transfer lemma was built, and `axiom_dedekind_valid` /
`axiom_dedekind_swap_valid` needed no modification.

## Notes for Follow-Up Work

`sep_valid` and `sep_swap_valid` remain the only debt in the Dedekind soundness chain. The
section comment's final paragraph is written to be deleted wholesale once they are discharged,
and their `-- sorry:` docstring blocks are still in the original format — the pattern used here
(replace the block with proof-summary prose citing the source and the construction) transfers
directly.

## Artifacts

- `FormalSystem/Metalogic/Soundness.lean` — the only modified file
- `specs/405_.../summaries/01_discharge-prior-gap-sorries-summary.md` — this file
