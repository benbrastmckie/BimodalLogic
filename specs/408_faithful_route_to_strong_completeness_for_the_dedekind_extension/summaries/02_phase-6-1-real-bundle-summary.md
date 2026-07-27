# Phase 6.1 Summary — The BFMCS real bundle, box time-stability, restricted temporal coherence

- **Task**: 408 (faithful route to the Dedekind-extension consequence terminus)
- **Plan**: `specs/408_faithful_route_to_strong_completeness_for_the_dedekind_extension/plans/02_strong-completeness-dedekind-v2.md`
- **Phase**: 6.1 — `[BLOCKED]` (five of six proof tasks completed sorry-free; the sixth landed
  only under an explicit added hypothesis)
- **Date**: 2026-07-27

## What landed

New module `FormalSystem/Metalogic/Bundle/RealExtensionBundle.lean` (334 lines, 7 declarations),
plus one import line and one contents line in `FormalSystem/Metalogic/Bundle.lean`.

| Declaration | Status |
|---|---|
| `negBoxIntrospection` (`fc`-generic `¬□φ → □¬□φ`) | sorry-free |
| `box_forward_in_fmcs` | sorry-free |
| `box_stable_in_fmcs` | sorry-free |
| `mem_realLimitMCS_of_forall` | sorry-free |
| `box_mem_realLimitMCS_iff` | sorry-free |
| `BFMCS.toRealBundle` (both modal fields) | sorry-free |
| `BFMCS.LimitFutureWitness` (new predicate isolating the gap) | definition |
| `BFMCS.toRealBundle_restricted_temporally_coherent` | sorry-free, **conditional** |

## Verification

- `lake build FormalSystem.Metalogic.Bundle.RealExtensionBundle`: green on the first attempt at
  each of the three sub-steps (no fix-forward cycles were needed).
- Full `lake build`: green, 1895 jobs.
- Live sorries outside `Boneyard/`: exactly `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1242`
  (unchanged; `lean-sorry-census.sh --cross-check` reports `compiler_sorry_count: 0`, the 161
  stripper hits being `Boneyard/` plus comment text).
- Axioms: all seven declarations reduce to `[propext, Classical.choice, Quot.sound]`;
  `negBoxIntrospection` needs only `propext`. No `sorryAx`, no new `axiom`, no vacuous
  definition, no `modal_past`.

## Findings

**Box time-stability needs only `forward_G`.** The plan's routing was correct and cheaper than
budgeted. `negBoxIntrospection` (from `Axiom.modal_5_collapse`, via contraposition and double
negation, built at `FrameClass.Base` and lifted by `FrameClass.base_le`) converts the
backward-in-time obligation into a forward push of `□¬□φ`, closed off by `Axiom.modal_t`.
`Axiom.modal_future` is not needed separately — `temporalFutureDerived` already packages it.
S5 negative introspection exists in-tree as `negBoxToBoxNegBox` (`BXCanonical/Frame.lean`) but
only at `Base` and in a module above `Bundle/` in the import graph, so the `fc`-generic form was
landed here under the plan's own fallback clause.

**The real-shift closure did exactly what v2 predicted.** `modal_backward` positions its witness
family as `fam'.toRealShift ((q:ℝ) - t)`, whose value at `t` is `fam'.mcs q` by
`realLimitMCS_of_rat`; no threshold argument occurs anywhere in either modal field. The direct
form proved shorter than the plan's contrapositive phrasing.

**v2's temporal-coherence transport has a defect.** The `someFuture` half at unselected real
points is not a consequence of `RestrictedTemporallyCoherent` for the rational bundle. The plan's
threshold check ("`t < s' - δ` from `p < s'` and `p < t + δ`") is unsound: those two facts are
jointly satisfied by any `s' ∈ (p, t + δ)`, giving a witness below `t`. The counterexample —
`φ`-points accumulating at an irrational `r` from below with `¬φ` everywhere above `r` — is
recorded at the four-element defect bar in the plan's Phase 6.1 BLOCKER block and in the
docstring of `BFMCS.LimitFutureWitness`. The `somePast` half is unaffected and landed
unconditionally, because the extension limits from below.

## Deviations

1. `BFMCS.toRealBundle_restricted_temporally_coherent` takes an added named hypothesis,
   `B.LimitFutureWitness root`. Raised as a blocker (plan heading `[BLOCKED]`, full BLOCKER
   block, inline checklist annotation) rather than silently substituted, per
   `.claude/rules/plan-compliance.md`.
2. `box_forward_in_fmcs` was factored out of `box_stable_in_fmcs`; the plan named only the
   latter. The forward push is needed at two different formulas (`φ` and `(□φ).neg`), so a
   `have` local to `φ` does not suffice.
3. `negBoxIntrospection` was landed `fc`-generically in this module rather than imported, for
   the import-graph reason above. The plan's task text explicitly permits this.

## Follow-up required

Discharge `BFMCS.LimitFutureWitness root` for `cantorBfmcsDense`
(`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`), or replace it with a property of the
Cantor back-and-forth chronicle that implies it. This is a research obligation and a new
prerequisite of Phase 8's terminus. Phase 7 is not blocked by it, but should expect the same
below-only asymmetry in `forward_until_since_coherent`.
