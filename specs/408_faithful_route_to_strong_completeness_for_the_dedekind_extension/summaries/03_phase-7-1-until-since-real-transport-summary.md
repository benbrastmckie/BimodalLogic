# Phase 7.1 Summary — Until/Since transport at ℝ, the mechanical cases

- **Status**: PARTIAL (phase marked `[BLOCKED]` on two of its eight tasks)
- **Plan**: `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/03_strong-completeness-dedekind-v3.md`
- **Module**: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (new)

## What was landed

Seven declarations, all sorry-free, all with `#print axioms` exactly
`[propext, Classical.choice, Quot.sound]`.

| Declaration | Content |
|---|---|
| `guard_transport_realLimitMCS` | The shared guard lemma. A rational guard covering every rational of `(a, b)` covers every real `r` with `a < r + δ < b`. Selected `r`: `realLimitMCS_of_rat`. Unselected `r`: `a` is itself a `limitSetBelow` threshold, upgraded by `limitSetBelow_subset_limitMCSBelow`. Phase 7.2 depends on this. |
| `exists_rat_witness_of_realLimitMCS` | Rational interpolation of a real witness: `φ ∈ realLimitMCS m δ s` and `z < s + δ` give a rational `u` with `z < u ≤ s + δ` and `φ ∈ m u`. Selected: the selecting rational, with equality. Unselected: `limitMCSBelow_cofinal_below`. |
| `toRealBundle_forward_until_selected` | Forward case A for `untl`. |
| `toRealBundle_forward_since_selected` | Forward case A for `snce`. |
| `toRealBundle_backward_until_selected` | Backward `untl` at a selected target — the one backward case that is true. |
| `toRealBundle_backward_since_selected_of_rat_witness` | Backward `snce` at a selected target **from a selected witness** — the exact boundary of what is true on that side. |
| `cantor_bfmcs_dense_real_restricted_tc` | The chronicle real instance for restricted temporal coherence: `BFMCS.toRealBundle_restricted_temporally_coherent` composed with `cantor_bfmcs_dense_restricted_tc` and Phase 6.2's `cantor_bfmcs_dense_limit_future_witness`, with the closure-containment hypothesis threaded through unchanged and `hfc` threaded, not discharged. |

## What was refuted

`BFMCS.toRealBundle_restricted_backward_until_since` — the plan's first task, and the premise
that "the witness-pattern direction is the easier of the two" — is **false**. Two counterexample
families are written out in full in the module docstring, section `Refutations`, and abridged in
the plan's `BLOCKER` note. Both take a genuine model `M` over the flow `ℝ` and set
`m q := {χ | M, q ⊨ χ}` for rational `q`, which makes every `m q` maximal consistent at
`FrameClass.Dedekind` for free and `forward_G`/`backward_H` semantic.

1. **Backward `snce`, at a selected target.** `V(φ) = (0, g)`, `V(ψ) = (g, 5)` with `g`
   irrational. Rational restricted backward coherence holds vacuously; the real witness pattern
   at `t := 5` is met by the *gap* witness `s := g`, where `φ` lies in `limitMCSBelow m g` because
   it is eventually true from below; but `snce φ ψ ∉ m 5`.
2. **Backward `untl`, at an unselected target.** `V(ψ)` oscillating below the gap `g` and equal
   to `(g, 3)` above it, `V(φ) = (g, 3)`. The real witness pattern at `t := g` is met by
   `s := 2`; but no rational below `g` carries `untl φ ψ`, and `{q : ℚ | (q : ℝ) < g}` is a
   `limitFilterBelow g` generator.

**Structural cause.** `realLimitMCS` limits from below, so `exists_rat_witness_of_realLimitMCS`
descends. For `untl` the witness is above the target and the descent moves *into* the guarded
interval — that is why `toRealBundle_backward_until_selected` closes. For `snce` the witness is
below the target and the identical descent leaves the guarded interval, landing where nothing is
known about `ψ`.

**Scope of the refutation.** It kills the generic transport, whose only hypothesis on the
rational bundle is restricted backward coherence. It does **not** settle
`cantor_bfmcs_dense_real_restricted_buc`: neither family satisfies the unrestricted rational
forward Until coherence that `cantorBfmcsDense` enjoys (in family 1, `untl φ.neg φ` holds at
rationals of `(0, g)` with only the irrational witness `g`; in family 2, likewise for the
definable gap of `φ.neg`). Settling it requires a **bounded** witness-side gap discharge — from
`φ ∈ limitMCSBelow m g` produce a rational `u` with `g < u < c` for a prescribed bound `c` — and
the unbounded form of that follows from Phase 6.2's `BFMCS.LimitFutureWitness` while the bound
does not. That is Phase-7.2-class work and was not attempted here, per this phase's own stop rule.

## Verification

- `lake build FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleRealExtension`: green.
- Full `lake build`: green.
- Live sorries outside `Boneyard/`: unchanged at exactly
  `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`. Zero new sorries.
- Vacuous definitions introduced: 0. New axioms: 0. Chronicle declarations modified: 0.

## Plan deviations

- Tasks 1 and 6 could not be executed as written and are annotated `(BLOCKED — refuted)` in the
  plan checklist, with a full `BLOCKER` block under the phase heading.
- Task 4 ("mirror the backward direction and forward case A for `snce`") is annotated partial:
  the forward mirror is complete; the backward mirror exists only in its selected-witness form,
  which is the boundary of what is true.
- Bundle-level lemmas were declared inside `namespace FormalSystem.Metalogic.Bundle` within the
  Chronicle module rather than in `Bundle/RealExtensionBundle.lean`, respecting the phase's
  file-ownership declaration and mirroring Phase 6.2's placement of `limitFutureWitness_of_priorU`.
