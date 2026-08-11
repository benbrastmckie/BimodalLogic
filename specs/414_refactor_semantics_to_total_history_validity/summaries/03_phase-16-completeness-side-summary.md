# Phase 16 — Box-Clause Repair, Completeness Side

- **Plan**: `specs/414_refactor_semantics_to_total_history_validity/plans/03_omega-free-totality-refactor.md`
- **Phase**: 16 of 23 — `[COMPLETED]`
- **Session**: `sess_1786425971_d3ac87`
- **Commits**: `684a51ca3`, `19353e9f6`

## What This Phase Did

Repaired every completeness-side consumer of the retargeted box clause, then executed the phase's
final task: rewriting the countermodel existentials from the Omega form to the totality form.

The predicate is TOTALITY throughout — `WorldHistory.IsTotal τ := ∀ t, τ.domain t`,
`def:world-history`'s cut `X = D`. No `IsMax`, no compatibility shim, no parallel validity notion.

### Step 1 — Mechanical box-clause repair (2 + 2 errors)

The dispatch predicted 2 errors in `Algebraic/FlowFrame.lean`; both were exactly the predicted
shape and both were repaired by routing through bridging assets already proved in Phase 11 rather
than by re-deriving anything:

| Site | Was | Now |
|---|---|---|
| `FlowFrame.lean:662` | `obtain ⟨⟨fam', w₀'⟩, rfl⟩ := h_σ_mem` | `obtain ⟨fam', w₀', rfl⟩ := bundleFlow_total_eq σ h_σ_mem` |
| `FlowFrame.lean:672` | `bundleFlowHistory_mem_omega _ _` | `bundleFlowHistory_total _ _` |

Once `FlowFrame.lean` went green, two further errors of identical lineage surfaced in
`WeakCanonical/IntegerModel/ReynoldsBridge.lean` (also on this phase's file list), which had been
compiling behind the red chain: the same `rcases`-on-a-totality-function failure at `:1087` and
the same Omega-witness-where-totality-is-required mismatch at `:952`. Repaired the same way,
through `multiFam_total_eq` and a new `multiFamHistory_total`.

Note on the Phase 15 agent's tip: the `intro`-arity sweep was **not** what fixed these. The
`intro h_box σ h_σ_mem` arity was already correct — the box clause went from `∀ σ, σ ∈ Omega → …`
to `∀ σ, σ.IsTotal → …`, which is the same arity. These four were genuine (if small) judgment
sites requiring the Phase 11 bridge, not cascade artifacts. That is a real difference from the
`DenseValidity.lean` / `FrameClassVariants.lean` experience and is worth recording for Phase 17.

### Step 2 — Countermodel existentials rewritten to totality form

This is the phase's fifth task, and it turned out to be load-bearing rather than cosmetic: with
Phase 18's binder delta already landed, `valid`/`ValidDense`/`ValidDiscrete`/`ValidDedekindDense`
consume `(τ : WorldHistory F) (_ : τ.IsTotal) (t : D)`, so a countermodel yielding
`τ ∈ Omega` for an existentially bound opaque `Omega` is unusable by its own consumer. Every
completeness theorem in `BXCanonical/Completeness.lean` was red for exactly this reason.

Six existentials of the shape

```
∃ … (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
    (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D), ¬TruthAt TM Omega τ t φ
```

became

```
∃ … (τ : WorldHistory F) (_ : τ.IsTotal) (t : D), ¬TruthAt TM Set.univ τ t φ
```

in `countermodel_dense_enriched`, `countermodel_dedekind_dense`, `Chronicle.countermodel_dense`,
`countermodel_discrete_reynolds_v2`, `MCSMixedCase`'s wrapper, and `countermodel_discrete`.
The four consumer sites in `Completeness.lean` and the one in `CompletenessDedekind.lean` were
updated to match.

### Carrier decision

`TruthAt` still carries its Omega parameter (Phase 22 deletes it), so the rewritten statements
supply the inert transient carrier `Set.univ` — the same carrier the Phase 18 `Valid*` definitions
already use. Rather than introduce a `truthAt_carrier_irrelevant` transport at each site, the
underlying truth lemmas were retargeted to `Set.univ` directly:
`bundleFlow_truth_lemma`, `bundleFlow_completeness_from_neg_membership`,
`fc_theorem_true_in_bundle_flow_model` (`Bundle/LimitMCS.lean`), and the two `suffices`-level
truth-correspondence statements inside `countermodel_discrete_reynolds_v2` and
`countermodel_dedekind_dense`. **No transport call was introduced**, and no
Omega-valued definition was deleted, so Phase 21's deletion of `bundleFlowOmega`,
`multiFamOmegaGen`, `multiFamOmega` and their `ShiftClosed` proofs is unobstructed.

## Assets Added

Two totality witnesses, mirroring the existing `bundleFlowHistory_total`:

- `multiFamHistoryGen_total` (`Algebraic/FlowFrame.lean`) — generic flow frame
- `multiFamHistory_total` (`WeakCanonical/IntegerModel/ReynoldsBridge.lean`) — the `ℤ` case

Both are `fun _ => trivial`: definitional, since the history carries `domain := fun _ => True`.

## Verification

| Gate | Result |
|---|---|
| Phase-16 scope build | GREEN (all 8 modified files + full completeness stack) |
| Tree build | RED at 17 errors, all owned by Phase 17 |
| Live sorries repo-wide | 1 — `WeakCanonical/Transfer.lean:1084`, pre-existing |
| Sorries introduced | 0 |
| New axioms | 0 |
| Vacuous definitions | 0 |
| `BimodalTest` `#guard_msgs` baseline | untouched |

### Statements preserved modulo the totality binder

The phase's own verification criterion. Axiom audits are byte-identical to before:

- `completeness_dense` — `[propext, Classical.choice, Quot.sound]`
- `completeness_discrete` — `[propext, Classical.choice, Quot.sound]`
- `Chronicle.countermodel_dense` — `[propext, Classical.choice, Quot.sound]`
- `countermodel_dedekind_dense` — `[propext, Classical.choice, Quot.sound]`
- `completeness_dedekind_engine` — `[propext, Classical.choice, Quot.sound]`
- `completeness` — `[propext, sorryAx, Classical.choice, Quot.sound]`, the single pre-existing
  debt from `countermodel_discrete`, unchanged

### Test baseline not re-baselined

The ten pre-existing `BimodalTest` `#guard_msgs` mismatches (`TableauConformance.lean` 7,
`RegionGateProbe.lean` 2, `BoxSpreadProbe.lean` 1) were not touched. No edit in this phase reaches
any test file, and none of the rewritten statements appears in a `#guard_msgs` expectation.

## Remaining Tree Breakage (Phase 17's territory, untouched)

| File | Count | Owner |
|---|---|---|
| `Decidability/Verified/Decidable.lean` | 16 | Phase 17 |
| `Decidability/Verified/Bridge/Interpolate.lean` | 1 | Phase 17 |

Both are explicitly on Phase 17's task list and were deliberately left alone.

## Plan Corrections Recorded

1. Three paths in the phase's `Files to modify` list do not exist as written; the real locations
   are all under `BXCanonical/` (`BXCanonical/CompletenessDedekind.lean`,
   `BXCanonical/Chronicle/ChronicleMonadicBridge.lean`,
   `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`).
2. `ChronicleMonadicBridge.lean` required no edit — it has no `TruthAt` box site and no
   countermodel existential.
3. Two countermodel existentials outside the phase's file list had to be rewritten with the rest,
   because `completeness` destructures both: `Chronicle/MCSMixedCase.lean` and
   `WeakCanonical/Transfer.lean`.
4. `Bundle/LimitMCS.lean` needed a carrier retarget, not a box-clause repair.
