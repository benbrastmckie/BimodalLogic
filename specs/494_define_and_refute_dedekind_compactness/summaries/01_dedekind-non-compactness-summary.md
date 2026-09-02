# Implementation Summary: Task #494

- **Task**: 494 - define_and_refute_dedekind_compactness
- **Type**: lean4
- **Plan**: `specs/494_define_and_refute_dedekind_compactness/plans/01_dedekind-non-compactness-refutation.md`
- **Research**: `specs/494_define_and_refute_dedekind_compactness/reports/01_dedekind-noncompactness-witness.md`
- **Status**: All five phases [COMPLETED]
- **Started**: TBD
- **Completed**: TBD
- **Artifacts**: TBD
- **Standards**: TBD

## What Was Built

`FrameClass.Dedekind` is now settled negatively, completing the four-class compactness picture.

**Part 1 — the four instantiations** (`FormalSystem/Metalogic/SetConsequence.lean`). The
`.Dedekind` row of the `FrameClass`-indexed family is named as four one-line instantiations:
`StrongCompletenessDedekind` (:600), `CompactDedekind` (:609), `SatisfiableDedekindSet` (:625),
`ModelExistenceDedekind` (:636). No new adapter and no new binder list were required — the plan's
rescoping premise held exactly.

**Part 2 — the refutation** (`FormalSystem/Metalogic/DedekindNonCompactness.lean`, new, 516
lines). The witness is

    dedWitness q = {G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤ : n ∈ ℕ},   Xq φ = untl ¬q (q ∧ φ)

- `dedWitness_core` — unsatisfiable over any `F.IsComplete` frame. Density is never used, so
  the result covers `ℤ` as well as `ℝ`-like carriers.
- `dedWitness_not_satisfiable` — the same at `SatisfiableDedekindSet`.
- `dedWitness_finitely_satisfiable` — every finite sublist holds at `0` in an `ℝ` model built as
  a `ShiftSet` (`rShift`), with `q` true exactly at the integers `1, …, N` for
  `N = (L.map qDepth).sum`.
- `dedekind_consequence_not_compact` — refutes `CompactDedekind`.
- `strongCompletenessDedekind_refuted` — refutes `StrongCompletenessDedekind`.

The infinite ω-family `{αₙ}` is load-bearing: it replaces the single formula `G(q → F q)` so that
every *finite* subset stays Dedekind-satisfiable. A finite unsatisfiable set would refute nothing
about compactness.

## Verification (actual in-tree results)

**`lake build`**: green at the close of every phase — Phase 1 (2514 jobs), Phases 2-5 (2515
jobs), each exit 0. The job-count rise from 2514 to 2515 at Phase 2 confirms the new module
genuinely entered the build closure via the `FormalSystem/Metalogic.lean` import.

**Sorries**: zero. `grep -rn "sorry" DedekindNonCompactness.lean SetConsequence.lean` returns only
the word `sorryAx` inside the audit docstring's prose.

**New axioms**: none. `grep -rn "^axiom " FormalSystem/` is unchanged.

**Axiom audit** — verbatim `lake build` output from the module's permanent `#print axioms`
commands:

```
'FormalSystem.Metalogic.qDepth_qAlpha' depends on axioms: [propext, Quot.sound]
'FormalSystem.Metalogic.dedWitness_core' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_not_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedWitness_finitely_satisfiable' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.dedekind_consequence_not_compact' depends on axioms: [propext, Classical.choice, Quot.sound]
'FormalSystem.Metalogic.strongCompletenessDedekind_refuted' depends on axioms: [propext, Classical.choice, Quot.sound]
```

All four headline results are exactly `[propext, Classical.choice, Quot.sound]`, matching the
acceptance criterion. `qDepth_qAlpha` carries a strict *subset* (`[propext, Quot.sound]`) — a
smaller dependency, not an extra axiom; recorded literally rather than rounded up.

**`DiscreteNonCompactness.lean`**: byte-identical to its pre-task state
(`git diff <pre-task> --stat` lists it not at all), as the plan's Non-Goals require.

## Documentation Reconciliation (Phase 5)

The plan's detector grep was run before and after editing. Baseline: 18 hits, of which 11
asserted or implied that the tree contains no Dedekind refutation. All were rewritten:

| File | Hunks |
|------|-------|
| `Metalogic/StrongCompleteness.lean` | 6 (`:73-83` ledger row, `:84-90` "three statuses", `:460-463`, `:515`, `:543`, `:823`) |
| `Metalogic/SetConsequence.lean` | 3 (module docstring, adapter block, `:436-438`) |
| `Metalogic.lean` | 3 (import, `:115-117`, module bullets at `:190`/`:197`) |
| `Metalogic/Compactness.lean` | 1 (`:65`) |
| `Metalogic/README.md` | 2 (new `DedekindNonCompactness.lean` row; `SetConsequence.lean` line count 568 → 638) |

**The plan's predicted site list was an undercount.** It enumerated 5 `StrongCompleteness.lean`
hunks; the baseline grep surfaced a 6th at `:515` (in `completeness_dedekind_of_engine`'s
docstring: "unavailable on the primary source's own terms and no route to it is known"). It was
rewritten with the rest. This vindicates the plan's own instruction to treat the grep, not the
checklist, as authoritative.

`FormalSystem/Semantics/README.md` was checked as the plan directs: its only Dedekind mentions
(`:17`, `:19`) are unrelated to compactness status. **No change needed** — recorded rather than
silently skipped.

Every surviving detector hit is either a reference to the now-real name `CompactDedekind`, or the
one deliberate historical note at `StrongCompleteness.lean:107` recording that the
"unavailable on the primary source's own terms" status is superseded rather than softened.

Reynolds 1992 §9 Theorem 7 is preserved throughout as the *weak* completeness citation. The
refutation does not contradict it; it accounts for its scope.

## Plan Deviations

1. **Phase 2, generality refinement — altered (in the plan's favour).** The bounded
   `(hlub : F.IsComplete)` refinement succeeded on its first attempt, so `dedWitness_core` uses
   the named form rather than the unfolded `∀ s, s.Nonempty → BddAbove s → ∃ x, IsLUB s x` the
   research verified. The plan said to delete the confirming `example` on success; it was kept
   instead, as a `private example`, because it documents the definitional identity the named
   binder depends on.
2. **Phase 3, warning count — altered.** Research predicted one cosmetic `push_cast` warning, in
   `rTruth_alpha`. Dropping the `⊢` silenced it as predicted, but a *second*, unpredicted
   `'push_cast' tactic does nothing` warning surfaced in `dedWitness_finitely_satisfiable`
   (`by push_cast; omega` → `by omega`). Both are fixed; the module builds with zero warnings.
3. **Phase 3, Scope Hypothesis — corrected by count.** Research §5 predicted three sites needing
   explicit-ℝ restatement before `exact_mod_cast`. The actual count is **four**: `hr'` in
   `rTruth_gap`, `hy'` in `rTruth_bound`, and `hr'` + `hrs'` in `rTruth_alpha`.
4. **Phase 3, redundant import — dropped.** `Mathlib.Data.Real.Basic` was not added;
   `Semantics/ShiftSet.lean` already pulls `Mathlib.Data.Real.*`. The plan explicitly permits
   either choice; the choice is recorded in the file.
5. **Phase 4, axiom audit block — made permanent.** The plan allowed either removing the
   temporary `#print axioms` block or keeping it if it matches house style. It matches:
   `DiscreteNonCompactness.lean` keeps live `#print axioms` commands plus an `## Axiom Audit`
   docstring section. The new module mirrors that, so the audit re-runs on every build rather
   than being a one-time claim in a summary.
6. **Phase 5, one additional site.** `StrongCompleteness.lean:515`, not in the plan's enumerated
   list, was surfaced by the baseline grep and reconciled. See the table above.

No deviation was a descope: every checklist item in all five phases was executed.

## Artifacts

- `FormalSystem/Metalogic/DedekindNonCompactness.lean` (new, 516 lines)
- `FormalSystem/Metalogic/SetConsequence.lean` (four defs + 3 doc hunks)
- `FormalSystem/Metalogic.lean` (import + 3 doc hunks)
- `FormalSystem/Metalogic/StrongCompleteness.lean` (6 doc hunks)
- `FormalSystem/Metalogic/Compactness.lean` (1 doc hunk)
- `FormalSystem/Metalogic/README.md` (module table)
