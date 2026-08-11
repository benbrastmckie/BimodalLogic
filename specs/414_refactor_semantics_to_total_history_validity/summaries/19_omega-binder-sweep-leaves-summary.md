# Phase 19 — Omega-binder sweep A (leaves): execution summary

- **Plan of record**: `plans/03_omega-free-totality-refactor.md`, Phase 19
- **Outcome**: `[COMPLETED]`. `lake build` green (2331 jobs), 0 sorries introduced, 0 new axioms.
- **Phases complete after this dispatch**: 19 of 23.

## What the phase actually was

Decision D orders the Omega collapse reverse-topologically: leaves first (`Tests/**`,
`Examples/**`, `Automation/**`, `FrameConditions/**`), `Semantics/Truth.lean`'s own parameter
last. This phase is the leaf sweep.

A census on the now-green tree found that **three of the four named directory trees held no
binder at all**:

| Tree | Binders found | Disposition |
|------|---------------|-------------|
| `FormalSystem/Automation/**` | 4 theorems in `PrefilterSoundness.lean` | Removed |
| `Tests/BimodalTest/**` | none | 5 stale docstrings retargeted |
| `FormalSystem/Examples/**` | none — no `TruthAt` call site whatsoever | Nothing to do |
| `FormalSystem/FrameConditions/**` | none — `Validity.lean` / `Soundness.lean` already pass `Set.univ` | Nothing to do |

## The declaration work

`FormalSystem/Automation/PrefilterSoundness.lean` — four theorems
(`isUnsatBotTemporal_not_truth`, `unfulfillable_until_not_truth`,
`unfulfillable_since_not_truth`, `false_consequent_not_truth`) each dropped
`{Omega : Set (WorldHistory F)}` and now write `Set.univ` at every `TruthAt` position. The single
explicit-argument site, `Truth.bot_false Omega`, became `Truth.bot_false Set.univ`. No proof
script changed otherwise; no tactic was re-derived.

**Reverse-topological precondition, verified rather than assumed**: a name-grep for all four
theorems across the whole tree (Boneyard excluded) returns no consumer outside the file itself.
All four are true leaves, so the precondition holds vacuously and the phase could not have
broken a downstream signature.

## Carrier convention and the Phase 22 surface

A leaf cannot become argument-free while `TruthAt` still takes its inert `_Omega` parameter —
that deletion is Phase 22's first task. Dropping a leaf's binder therefore means supplying the
value the validity layer already supplies, `Set.univ` (settled by Phase 18 in
`Semantics/Validity.lean`, documented there against `truthAt_carrier_irrelevant`).

Consequently **this phase adds nothing to the Phase 22 unwind surface**.
`truthAt_carrier_irrelevant` is not invoked anywhere in the phase, because leaves with no
consumers never need to bridge between carriers. The unwind surface remains exactly the five
sites enumerated at the end of Phase 17: `truthAt_of_isValid` in `Verified/Decidable.lean`, and
four direct `truthAt_carrier_irrelevant` calls in `Bridge/IntTruth.lean` (2) and
`Bridge/DenseTruth.lean` (2).

## Prose retargeting

Six docstring passages still described the box modality as `∀ σ ∈ Ω, …`, a reading Phase 14
retired. All were rewritten to the totality clause: the `PrefilterSoundness.lean` module header
plus five `Tests/BimodalTest` probe files (`BoxNegReachabilityProbe`, `BoxNegPreservationProbe`,
`CrossWorldPropagationProbe`, `UntlSnceCopyProbe`).

The probes' substantive claims are unchanged, not weakened: each argued a formula invalid because
*some other history in `Ω`* refutes the `□`-consequent, and each now argues it invalid because
*some other total history* does. The witnesses those probes rely on are total, so the arguments
survive the retarget intact.

The replacement text in `PrefilterSoundness.lean` was deliberately worded to avoid the literal
tokens `Omega` and `ShiftClosed`, so the phase's own verification grep is satisfied literally
rather than by an "explanatory prose" exemption.

## A note on scope estimation

The Execution Status section's lesson 1 says a census on a red tree is a lower bound. This phase
is the mirror case and worth recording alongside it: the census here was taken on a **green**
tree and was an accurate measurement — the over-sizing came from the plan's *a priori* directory
list, which named four trees where only one carried work. Both failure modes are live in this
plan; only red-tree counts are systematically low, while *a priori* guesses have been
systematically high (`Soundness.lean` "70 declarations" → 0; `Verified/Decidable.lean` "42" → 16;
this phase's "four trees" → 1).

## Verification

| Gate | Result |
|------|--------|
| `lake build` | GREEN, 2331 jobs |
| Live sorries (repo-wide) | 1 — pre-existing `Metalogic/WeakCanonical/Transfer.lean:1084`, untouched |
| New axioms | 0 |
| Vacuous definitions | 0 |
| Territory grep `Omega\|ShiftClosed\|Ω` over all four trees | returns nothing |
| `lake build BimodalTest` | ten `#guard_msgs` mismatches, unmoved from the recorded pre-existing baseline (`TableauConformance` 7, `RegionGateProbe` 2, `BoxSpreadProbe` 1) — see the caveat below |

The test-target mismatches remain the carried caveat the plan records; nothing in this phase can
reach them, since every edit is either a `Prop`-valued statement or a comment and no
`#eval`-reachable computable definition was touched.

**Caveat, stated precisely rather than rounded off**: the `lake build BimodalTest` run was still
elaborating its remaining modules when this summary was written — that target runs past forty
minutes, dominated by `TableauConformance`'s `#eval` blocks. All three modules carrying the
baseline mismatches had already elaborated and reproduced their counts exactly (7 + 2 + 1, plus
three per-file `Lean exited with code 1` lines, for the same 13 error lines the baseline shows).
The unelaborated remainder has never carried a mismatch in any prior dispatch. The phase's
required gate is `lake build` on the `FormalSystem` default target, which completed GREEN.

## Commits

- `5f8e8af0b` — `task 414 phase 19.1: drop Omega binders from Automation/PrefilterSoundness`
- `c6493b7a6` — `task 414 phase 19.2: retire Omega prose from the leaf test probes`
