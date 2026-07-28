# Phase 7.1′ — Until/Since transport at ℝ: the three unlanded backward cases

- **Status**: COMPLETED
- **Date**: 2026-07-27
- **Plan**: `plans/04_strong-completeness-dedekind-v4.md`, Phase 7.1
- **Grounding report**: `reports/04_backward-transport-blocker.md`, §3
- **Territory**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` only

## What landed

Six new declarations, all sorry-free, all with axioms exactly
`[propext, Classical.choice, Quot.sound]`.

| Declaration | Role |
|---|---|
| `toRealBundle_backward_until_unselected` | case 2 — `untl` at an unselected target |
| `exists_rat_since_witness_below_of_limitGuardBelow` | shared: relocates the `snce` witness to a rational strictly below the gap |
| `toRealBundle_backward_since_selected_of_gap_witness` | case 3′ — `snce`, selected target, gap witness |
| `toRealBundle_backward_since_unselected` | case 4 — `snce` at an unselected target |
| `BFMCS.toRealBundle_restricted_backward_until_since` | the strengthened transport, all four cases |
| `cantor_bfmcs_dense_real_restricted_buc` | the phase deliverable (chronicle instance) |

The strengthened signature differs from the refuted one by exactly one hypothesis:

```lean
theorem BFMCS.toRealBundle_restricted_backward_until_since {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_rbuc : B.RestrictedBackwardUntilSinceCoherent root)
    (h_lgb : B.LimitGuardBelow) :
    (B.toRealBundle).RestrictedBackwardUntilSinceCoherent root
```

`h_lgb` is discharged at the chronicle instance by the guard gap lemma's chronicle discharge, so
the deliverable carries no new hypothesis beyond the `FrameClass.Dedekind ≤ fc` threading that
`cantor_bfmcs_dense_real_restricted_tc` already has.

## The mathematical content

The refuted guard-free statement fails because descending from an `snce` witness leaves the
interval the *real* guard covers. The correction is that the guarded interval does not stop at
the gap: a formula guarding an interval abutting a gap from above cannot have a right gap there,
because that configuration is Reynolds' `γ⁻` — "Dually there is `γ⁻` and *right gaps*"
(Reynolds 1992, §5, printed p.175) — and `Axiom.prior_S_gap` excludes it. `LimitGuardBelow`
extends the guard past the gap; `limitMCSBelow_cofinal_below` then descends into the extension,
placing the new witness at a rational strictly between two existing rational points, which is
Burgess 1982 I's own construction move (`z = (x + y)/2`, printed pp.372-373).

Case 4 needs no gap lemma at the target itself: with the relocated witness `u`, rational backward
coherence fires at *every* rational of `(u, T)` at once, so the conclusion lands in
`limitSetBelow` with threshold `(u : ℝ)`.

## Docstring correction

The module claimed that neither refuting family satisfies the unrestricted rational **forward**
Until coherence that `cantorBfmcsDense` enjoys, "in Refutation 2 the same happens for the
definable gap of `φ.neg` at `g`". That was unsupported for Refutation 2 and no forward violation
is constructible there. The paragraph now records the guard-side exclusion (which is what the
transport actually consumes) and, for Refutation 2, the supported **backward** failure via the
separating formula `β := ψ ∨ ¬K⁻ψ ∨ ¬K⁺ψ`. A dangling reference to the never-existing
`toRealBundle_backward_since_selected_is_refuted` was repointed at the relocation lemma. The
absence note now states that the backward side is complete and that
`cantor_bfmcs_dense_real_restricted_fuc` is the module's only remaining gap.

## Verification

- `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension` — green
- `lake build` (full) — green
- Live sorries outside `Boneyard/` — unchanged at exactly
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`
- No new sorries, no vacuous definitions, no new axioms
- `#print axioms` on all six new declarations — `[propext, Classical.choice, Quot.sound]`

## Deviations

1. The module gained `import …Chronicle.ChronicleLimitGuardWitness`, required to see the guard
   discharge. Its import set is identical to this module's existing one, so no cycle.
2. Cases 3′ and 4 share one relocation lemma instead of duplicating the descent. It handles
   selected and unselected witnesses uniformly (always interpolating a rational between `S` and
   `T`), so it needs no case split on the target either. Cases 1 and 3 still consume the landed
   selected-case lemmas exactly as specified.
3. The docstring pass also repaired the dangling cross-reference described above.

## Not done, deliberately

Forward case B — `cantor_bfmcs_dense_real_restricted_fuc` — remains the next phase's sole
deliverable. The guard-below mechanism does not transfer to it: there the guard is the
*conclusion*, so nothing supplies the antecedent, and the interval-failure family recorded
against it stands unrefuted.
