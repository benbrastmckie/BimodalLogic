# Phase 7.3 Summary — the guard gap lemma, above (`limitGuardAbove_of_priorU`)

- **Task**: 408 — faithful route to strong completeness for the Dedekind extension
- **Plan**: `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/05_strong-completeness-dedekind-v5.md`
- **Phase**: 7.3 (R3a) — `[COMPLETED]`
- **Mode**: hard, single-phase dispatch, one agent run (as charted)

## What landed

New module `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGuardAbove.lean` (224 lines),
containing exactly the two declarations the plan specifies:

1. **`limitGuardAbove_of_priorU`** — the general Prior-U guard lemma. At an unselected real `r`,
   `ψ ∈ limitSetBelow m r` yields a rational `c > r` with `ψ` at every rational of `(r, c)`.
   Equivalently: the `ψ`-region has no definable **left** gap at `r`.
2. **`cantor_bfmcs_dense_limit_guard_above`** — the chronicle discharge, obtained by self-root
   instantiation of `cantor_bfmcs_dense_restricted_fuc` / `_buc` at `root := Formula.untl α β`,
   discharged with `self_mem_subformulaClosure`. The self-root instantiation elaborated exactly as
   the plan predicted; no signature discrepancy arose, and no chronicle declaration was touched.

One import line was added to `FormalSystem/Metalogic/BXCanonical.lean` (the actual aggregator for
`Chronicle/`). No other file in the tree was modified.

## Statement 2's shape — a recorded observation, not a deviation

The plan describes Statement 2 as "a verbatim clone of `cantor_bfmcs_dense_limit_guard_below`".
That sibling's conclusion is the bundle predicate `BFMCS.LimitGuardBelow`. There is no
`BFMCS.LimitGuardAbove` predicate in `Bundle/RealExtensionBundle.lean`, and this phase's territory
forbids adding one (Phase 7.4 owns the bundle-predicate work, where `BFMCS.LimitGuardEventual` is
introduced). The discharge is therefore stated with its conclusion written out explicitly over
`(cantorBfmcsDense …).families` — the same proposition the predicate would abbreviate. When Phase
7.4 introduces its predicate, this theorem applies to it directly with no restatement.

## Proof structure (following the plan's steps 1-4)

- `hev` supplies a real threshold `z < r` with `ψ` uninterrupted on `(z, r)`; a rational
  `x ∈ (z, r)` is fixed by `exists_rat_btwn`.
- `U(⊤, ψ) ∈ m x` from `hUb`, with `⊤ ∈ m ·` by `theorem_in_mcs (hm ·) (identity …)`.
- **Case 1** (`F(¬ψ) ∉ m x`): `ψ` holds at every rational above `x`; any `c > r` from
  `exists_rat_gt` works. No axiom appeal.
- **Case 2** (`F(¬ψ) ∈ m x`): `Axiom.prior_U_gap ψ` gives `untl (ψ.neg ∨ kPlus ψ.neg) ψ ∈ m x`;
  `hUf` yields an endpoint `e > x`. Trichotomy on `(e : ℝ)` vs `r`: `(e : ℝ) < r` forces `ψ ∈ m e`,
  hence `kPlus ψ.neg ∈ m e`, contradicted by `U(⊤, ψ.neg.neg) ∈ m e` built from the below-gap
  interval; `(e : ℝ) = r` is excluded by `hr`. So `e` is the required `c`.

**Unselectedness is used exactly once**, at the `(e : ℝ) = r` branch. There is no outer
`by_contra`. Each case and each interpolation is its own named `have`.

## Literature grounding (H3, Tier 1 — transcription-grade)

Verified verbatim against the corpus before transcription, per the binding directive:

- Reynolds 1992, printed p.176 (Theorem 3): the Prior-U contradiction pattern this lemma is —
  "Suppose for contradiction that `M ⊨ U'(A, B)(t)` … By Prior-U applied to `B` we have
  `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."
- Reynolds 1992, printed p.175: the `γ⁺` / `A` left gap / definable gap passage — the excluded
  configuration.
- Reynolds 1992, printed pp.176, 178: §6's uniform discipline — the gap axiom is applied to the
  formula uninterruptedly true on the interval abutting the gap, never to a witness.
- Burgess 1982 I, printed p.369: the variants table has no Dedekind or continuity variant, which
  is why the axiom is needed here at all.

The docstring records the **expressive-completeness non-inheritance caveat**: Reynolds obtains his
own gap-facing formulas by expressive completeness (printed pp.176-178); nothing of the kind is
inherited, because `ψ` here is a hypothesis binder rather than a constructed formula.

## Verification

| Check | Result |
|---|---|
| `lake build …ChronicleLimitGuardAbove` | green, first attempt, no repair cycle |
| `lake build` (full) | `Build completed successfully (1903 jobs)` |
| Live sorries outside `Boneyard/` | exactly 1: `WeakCanonical/Transfer.lean:1242` (baseline, unchanged) |
| Vacuous definitions introduced | 0 |
| New axioms | 0 |
| `#print axioms limitGuardAbove_of_priorU` | `[propext, Classical.choice, Quot.sound]` |
| `#print axioms cantor_bfmcs_dense_limit_guard_above` | `[propext, Classical.choice, Quot.sound]` |

## Plan bookkeeping

Phase 8's heading marker was corrected from `[IN PROGRESS]` to `[NOT STARTED]`, as the v5 revision
rationale required. Phase 8's text was not otherwise touched. Phase 7.5 (`[USER GATED]`) was not
touched.

## Deviations

None. No amendment was required, and none was made.
