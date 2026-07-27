# Phase 7.1 Handoff — Until/Since transport at ℝ, mechanical cases

## Immediate Next Action

Do **not** dispatch Phase 8. Phase 7.1's backward transport is refuted (details below), so the
route now has two open gap-facing obligations, not one. Decide at the orchestrator level whether
to (a) widen Phase 7.2's charter to cover the backward witness-side gap discharge as well as
forward case B, or (b) dispatch a sibling probe for it. Phase 7.2's forward case B is unaffected
and can still be dispatched as written; it now depends on `guard_transport_realLimitMCS`, which
is landed.

## Current State

New module `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean` (~300 lines
including docstring), imported from `FormalSystem/Metalogic/BXCanonical.lean`. Seven declarations,
all sorry-free, all with axioms exactly `[propext, Classical.choice, Quot.sound]`:

| Declaration | Namespace | Content |
|---|---|---|
| `guard_transport_realLimitMCS` | `…Metalogic.Bundle` | shared guard lemma: rational guard on `(a,b)` ⟹ real guard at every `r` with `a < r + δ < b` |
| `exists_rat_witness_of_realLimitMCS` | `…Metalogic.Bundle` | interpolation: real witness at `s` ⟹ rational `u` with `z < u ≤ s + δ` |
| `toRealBundle_forward_until_selected` | `…Metalogic.Bundle` | forward case A, `untl` |
| `toRealBundle_forward_since_selected` | `…Metalogic.Bundle` | forward case A, `snce` |
| `toRealBundle_backward_until_selected` | `…Metalogic.Bundle` | backward `untl` at a selected target |
| `toRealBundle_backward_since_selected_of_rat_witness` | `…Metalogic.Bundle` | backward `snce`, selected target **and** selected witness |
| `cantor_bfmcs_dense_real_restricted_tc` | `…BXCanonical.Chronicle` | chronicle real instance for restricted temporal coherence |

Full `lake build` green. Live sorries outside `Boneyard/` unchanged at exactly
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`. No chronicle declaration modified; no
new axioms; no vacuous definitions.

Not landed: `BFMCS.toRealBundle_restricted_backward_until_since` and
`cantor_bfmcs_dense_real_restricted_buc`. Nothing is in a half-written state — the module contains
no scaffolding for them.

## Key Decisions Made

1. **The plan's backward transport is false as stated and was not written down in any form.** Two
   counterexample families are recorded in full in the module docstring (section `Refutations`)
   and abridged in the plan's BLOCKER note. Both take a genuine model `M` over `ℝ`, set
   `m q := {χ | M, q ⊨ χ}` for rational `q` — making each `m q` maximal consistent at
   `FrameClass.Dedekind` for free and `forward_G`/`backward_H` semantic — and exploit that
   `realLimitMCS` at a gap is a limit **from below**, so it disagrees with `M`'s own theory there.
   - Refutation 1 (backward `snce`, **selected** target): `V(φ) = (0,g)`, `V(ψ) = (g,5)`, `g`
     irrational. Rational restricted backward coherence holds vacuously; the real witness pattern
     at `t := 5` is met by the gap witness `s := g` (there `φ ∈ limitSetBelow m g ⊆ limitMCSBelow
     m g`); but `snce φ ψ ∉ m 5`.
   - Refutation 2 (backward `untl`, **unselected** target): `V(ψ)` oscillating below `g` and equal
     to `(g,3)` above it, `V(φ) = (g,3)`. Rational restricted backward coherence holds; the real
     witness pattern at `t := g` is met by `s := 2`; but no rational below `g` carries `untl φ ψ`
     and `{q : ℚ | (q : ℝ) < g}` is a `limitFilterBelow g` generator.
2. **The exact structural cause, and the one case that survives.** `exists_rat_witness_of_real
   LimitMCS` descends from the witness. For `untl` the witness lies *above* the target, so the
   descent moves *into* the guarded interval `(t, s)` — that is why
   `toRealBundle_backward_until_selected` closes. For `snce` the witness lies *below* the target
   and the identical descent leaves the guarded interval, landing where nothing is known about
   `ψ`. The `snce` mirror is therefore stated with the witness's shifted coordinate assumed
   rational, which is not a convenience but the exact boundary of what is true.
3. **The chronicle instance is not settled either way.** Neither refuting family satisfies the
   *unrestricted* rational forward Until coherence that `cantorBfmcsDense` enjoys (Refutation 1:
   `untl φ.neg φ` holds at rationals of `(0,g)` with only the irrational witness `g`;
   Refutation 2: the same for the definable gap of `φ.neg` at `g`). So the refutations kill the
   generic transport the plan asks for, but leave `cantor_bfmcs_dense_real_restricted_buc` open.
4. **Bundle-level lemmas live in the Chronicle module.** They are declared inside
   `namespace FormalSystem.Metalogic.Bundle` within
   `Chronicle/ChronicleRealExtension.lean`, mirroring how Phase 6.2 put the generic
   `limitFutureWitness_of_priorU` in `Chronicle/ChronicleLimitGapWitness.lean`. This respects the
   phase's file-ownership declaration while keeping the names in the right namespace.
   `Bundle/RealExtensionBundle.lean` was **not** touched.

## What NOT to Try

- **Do not re-attempt the generic backward transport with tactics.** It is refuted, not stuck. A
  re-dispatch that produces a `sorry`-stubbed
  `BFMCS.toRealBundle_restricted_backward_until_since` would be stubbing a false statement.
- **Do not weaken by restricting the target to selected reals only.** Refutation 1 has a selected
  target; the gap enters through the *witness*, not the target.
- **Do not chase the `snce` mirror through `limitMCSBelow_cofinal_below`.** That is exactly the
  move that fails, for the reason in Key Decision 2, and it was tried first.
- **Do not thread a new undischarged predicate onto the terminus.** The Postmortem Constraints
  forbid it, and a witness-side gap discharge has no discharge path yet.

## Remaining Goals (verbatim from plan)

- [ ] Prove `BFMCS.toRealBundle_restricted_backward_until_since`
      (`TemporalCoherence.lean:589`). The witness-pattern direction is the easier of the two:
      a real witness `s` restricts to a rational one by interpolation, and the guard on
      `(t, s)` weakens to the rational guard.
- [ ] Mirror the backward direction and forward case A for `snce` (`Formula.snce`).
- [ ] Land `cantor_bfmcs_dense_real_restricted_buc` by composing the backward transport with
      `cantor_bfmcs_dense_restricted_buc` (`:680`). Do not modify that theorem.

The first and third are refuted as written; the second is landed for forward case A and for the
selected-witness backward form.

## Suggested Shape of the Follow-Up Probe

The missing ingredient, stated exactly: from `φ ∈ limitMCSBelow m g` at a gap `g`, produce a
rational `u` with `g < u < c` and `φ ∈ m u`, for a prescribed rational bound `c > g` at which the
guard already holds on `(g, c)`. The unbounded form is derivable from Phase 6.2's
`BFMCS.LimitFutureWitness` — `φ`-points are cofinal below `g` by `limitMCSBelow_cofinal_below`,
hence `someFuture φ ∈ limitSetBelow m g ⊆ limitMCSBelow m g` by `forward_G` and maximality — but
the **bound** `u < c` is what the `snce` case needs and what `LimitFutureWitness` does not supply.
That bound is the whole probe.

## References

- Plan: `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/03_strong-completeness-dedekind-v3.md`
  (Phase 7.1 heading and BLOCKER note at line ~1558)
- New module: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleRealExtension.lean`
- Prior phase: `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleLimitGapWitness.lean`
- Real bundle and predicates: `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean`,
  `FormalSystem/Metalogic/Bundle/RealExtension.lean`, `FormalSystem/Metalogic/Bundle/LimitMCS.lean`
- Predicate definitions: `FormalSystem/Metalogic/Bundle/TemporalCoherence.lean:558,589`
