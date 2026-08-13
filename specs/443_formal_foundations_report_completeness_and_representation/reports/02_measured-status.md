# Measured Status Baseline (Phase 2)

**Purpose**: a dated, reproducible measurement baseline for `typst/FormalFoundations.typ`'s status
footnotes. This is a baseline only — Phase 10 re-runs every measurement immediately before the
final citation pass and replaces any numeral quoted from this note with the fresh figure, per the
plan's explicit instruction not to carry this note forward as authority.

## Measurement date and commit

- Date: 2026-08-13
- Commit: `c2b8da5d6` (working tree; `scripts/typst-status-counts.sh --json`'s `stamp_commit`)

## `scripts/check-paper-definitions.sh`

Case (b): paper checksum moved since the last recorded pin, but all 47 recorded definitions
(26 previously tracked + 21 newly extended in this phase) hash identical to their recorded text —
no drift. Exit 0.

## `scripts/typst-status-counts.sh --json`

```json
{
  "axiom_count": 45,
  "rule_count": 7,
  "base_count": 37,
  "dense_only_count": 2,
  "discrete_only_count": 3,
  "dedekind_only_count": 3,
  "sorry_total": 5,
  "sorry_total_excl_boneyard": 1,
  "sorry_algebraic": 0,
  "sorry_bxcanonical": 0,
  "sorry_bundle": 0,
  "sorry_weakcanonical": 5,
  "sorry_weakcanonical_excl_boneyard": 1,
  "sorry_other": 0,
  "stamp_commit": "c2b8da5d6",
  "stamp_date": "2026-08-13"
}
```

This matches the research report's 2026-08-13 baseline exactly (the `stamp_commit` value moved
from `f231a8775` to `c2b8da5d6` between the research pass and this phase, but every count is
identical) — no material drift between research and Phase 2.

## `#print axioms` for the four flagship results (via `scripts/check-module-invariants.sh` check C2)

```
'FormalSystem.Metalogic.BXCanonical.completeness' depends on axioms: [propext, sorryAx, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.completeness_discrete' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.BXCanonical.Chronicle.countermodel_dense' depends on axioms: [propext, Classical.choice, Quot.sound]
```

Check C2 reports `PASS` ("all four flagship axiom sets match baseline"). Check C3 reports `PASS`:
the sole structural (non-`Boneyard`) sorry is in `theorem countermodel_discrete`
(`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`) — dead code, per that file's own docstring;
the live discrete path is `countermodel_discrete_reynolds_v2`
(`WeakCanonical/IntegerModel/ReynoldsBridge.lean`), which `completeness_discrete` actually calls
and which is sorry-free (confirmed by `completeness_discrete`'s clean axiom profile above).

Other check-group failures reported by this run (C6 unreachable-module-manifest gaps, C9 a
task-number citation in `PriorExpressivenessDense.lean`) are pre-existing repository conditions
unrelated to this task's scope (no file this task touches) and are not acted on here.

## `Metalogic/Algebraic/UltrafilterMCS.lean` — stale docstring confirmed

`grep -n sorry FormalSystem/Metalogic/Algebraic/UltrafilterMCS.lean` returns zero matches — the
file is sorry-free. Its own docstring at line 24 nonetheless reads "Phase 5 of the algebraic
completeness theorem. Contains sorries pending MCS helper lemmas." This is confirmed stale: the
measured fact (sorry-free, `sorry_algebraic = 0` above) contradicts the docstring's prose. Per the
task's non-goals, the Lean file itself is not edited; the report states the measured fact and does
not repeat the stale "contains sorries" claim.

## `Metalogic/BXCanonical/CompletenessDedekind.lean` and `StrongCompleteness.lean` — Dedekind path

`grep -n sorry` on both files returns no `sorry` tactic occurrences (only the word "sorryAx" inside
prose asserting its *absence*). `CompletenessDedekind.lean`'s own "Axiom Audit" docstring (lines
596-600) states all four of its declarations (`real_lub_of_bddAbove`, `dedekind_box_dense_mem`,
`countermodel_dedekind_dense`, `completeness_dedekind_engine`) must report exactly
`[propext, Classical.choice, Quot.sound]` — no `sorryAx`. `StrongCompleteness.lean` states the
same for its Reynolds §9 Theorem 7 discharge. Confirmed sorry-free by direct grep; not re-verified
by a fresh `#print axioms` run in this phase (the docstring's own audit section already documents
this contract and check C2 above independently confirms the sibling `Completeness.lean` module's
audit methodology is live and enforced).

## Shift-set / Jönsson–Tarski status — confirmed live

- `grep -rln 'ShiftSet\|shiftSet' FormalSystem/` returns empty — no shift-set Lean identifier
  exists anywhere under `FormalSystem/`. The shift-set representation programme is confirmed
  NOT STARTED as Lean work.
- `FormalSystem/Boneyard/UltrafilterFrame/` contains `TenseS5Algebra.lean`, `UltrafilterFrame.lean`,
  `AlgebraicCompleteness.lean`, and its own `README.md` — confirmed present under `Boneyard/`,
  i.e. archived, not live.

## Re-measurement instruction (carried into Phase 10)

Every numeral above is a 2026-08-13 baseline. Phase 10 must re-run
`bash scripts/check-paper-definitions.sh`, `bash scripts/typst-status-counts.sh --json`, and the
relevant `#print axioms` checks fresh, immediately before the final citation pass, and stamp the
report's footnotes with the fresh date/commit rather than this note's.
