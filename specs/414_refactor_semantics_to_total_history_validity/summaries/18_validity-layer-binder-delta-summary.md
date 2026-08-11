# Phase 18 — Validity-layer binder delta (executed out of order, before Phases 15-17)

## Re-sequencing check (performed first, before any edit)

Phase 18 declares `**Depends on**: 14` and nothing else. Phase 14 was already
`[COMPLETED WITH EXCLUSIONS]`. Phases 15, 16, and 17 each independently declare
`**Depends on**: 14` as well, so there is no prerequisite edge from 18 into any of them.
Re-sequencing is sound; the phase ran in full. The plan now records the re-sequencing in the
Phase 18 heading block so the on-disk order reflects what happened.

## What changed

The charter §2 two-move delta — drop `Omega` / `ShiftClosed Omega` / `τ ∈ Omega`, add the
totality constraint `(_ : τ.IsTotal)` — applied to every definition that bound the triple in its
body:

| Definition | File | Notes |
|---|---|---|
| `valid`, `SemanticConsequence` | `Semantics/Validity.lean` | already carried `[Nontrivial D]`; no binder added |
| `ValidDense`, `ValidDiscrete`, `ValidDedekind`, `ValidDedekindDense` | `Semantics/Validity.lean` | all four already carried `[Nontrivial D]` |
| `satisfiable`, `SatisfiableAbs`, `FormulaSatisfiable` | `Semantics/Validity.lean` | `[Nontrivial D]` **added** to all three |
| `ValidOver` | `FrameConditions/Validity.lean` | 18 application sites re-threaded |
| `IsValid` | `Metalogic/SoundnessLemmas/Core.lean` | plus its sole local consumer `valid_at_triple` |
| `SemanticConsequenceDedekindDense` | `Metalogic/StrongCompleteness.lean` | 6 application sites re-threaded |

`unsatisfiable_implies_all` gained `[Nontrivial D]` as the plan required;
`unsatisfiable_implies_all_fixed` had the same omission and was aligned with it.

## The strategic sorry is discharged

`Validity.lean:458` `valid_of_valid_box` — this phase was its recorded `follow_up_task`. The
proof is now

```
intro D _ _ _ _ F M τ hτ t
exact h D F M τ hτ t τ hτ
```

exactly the one-liner the Phase 14 docstring predicted, with the totality witness fed back in as
the box witness. `sorry_inventory` is **empty**. The only `sorry` remaining anywhere in
`FormalSystem/` is the pre-existing, untouched `WeakCanonical/Transfer.lean:1085`.

## One addition beyond the task list: `truthAt_carrier_irrelevant`

`TruthAt` still takes a set argument (`_Omega`, the transient carrier Phase 22 deletes), so the
delta could not simply drop it — every call site must pass something, and `Set.univ` is the value
the module docstring already identified as equivalent.

The load-bearing fact is that **the carrier is not definitionally irrelevant**. Verified directly:

```lean
example … : TruthAt M Om1 τ x φ = TruthAt M Om2 τ x φ := rfl
-- Type mismatch: rfl has type ?m = ?m
```

So a consumer holding a `Set.univ`-carried truth cannot silently transport it to its own carrier.
`truthAt_carrier_irrelevant` is that transport, proved by induction on `φ`. It becomes vacuous and
should be deleted together with the parameter in Phase 22.

## Paper alignment

`valid` and `SemanticConsequence` now carry `def:logical-consequence` verbatim in their
docstrings. `H_F` is rendered as `τ.IsTotal` — the target predicate is **totality**, never
`IsMax`. `ShiftClosed` is documented as unnecessary in the *statement* of validity because
totality is trivially preserved by `timeShift` (`WorldHistory.isTotal_timeShift`).

The satisfiable family carries an explicit **"No paper anchor"** note: its totality constraint and
`[Nontrivial D]` binder are a design decision inherited from `valid` so the two notions are duals
over one history class — not a reconciliation finding, and not attributable to any anchor.

## Verification

| Check | Result |
|---|---|
| `Semantics.Validity` builds | green (757/757) |
| `FrameConditions.Validity` builds | green (866/866) |
| `SoundnessLemmas.Core` builds | green (758/758) |
| `StrongCompleteness` builds | **not verifiable** — behind the still-red `DenseValidity`/`Soundness` chain; its 6 edits are mechanical and unverified |
| `lake build` tree-green | **no** — 98 errors in 4 files (see below) |
| `sorry` count in scope | 0 (strategic sorry discharged) |
| `sorry` count tree | 1 (pre-existing `Transfer.lean:1085`) |
| `grep "Omega\|ShiftClosed" Semantics/Validity.lean` | 4 hits, all docstring prose describing the retired architecture historically; zero in any binder, body, or statement |
| vacuous definitions | 0 (the one regex hit, `Examples/TemporalStructures.lean:284`, is a genuine theorem whose domain is definitionally `True`, and is untouched) |
| `^axiom` declarations | 4, unchanged |
| `BimodalTest` `#guard_msgs` | not re-baselined; the test suite is behind the red chain and was not reached. Nothing in this phase touches tableau, region-gate, or box-spread expectations. |

## Residual breakage and the resize for Phases 15-17

98 errors in 4 files. `FrameConditions/Validity.lean` went from 8 errors (caused by this phase's
`valid` delta) to green within this phase.

- **`SoundnessLemmas/DenseValidity.lean` — 94** (was 8). 80 are `introN` arity failures from the
  `IsValid` delta: a mechanical sweep dropping `Omega h_sc` and renaming `h_mem` to `hτ` across
  ~100 references. Only 14 need judgment, and they are the pre-existing ones.
- **`Algebraic/FlowFrame.lean` — 2**, unchanged from Phase 14.
- **`Bridge/Interpolate.lean` — 1**, unchanged from Phase 14.
- **`Automation/PrefilterSoundness.lean` — 1**, unchanged.

Two corrections to the pre-dispatch expectation, stated plainly:

1. **Family A did not dissolve wholesale.** The four `DenseValidity` family-A sites were absorbed
   into the general sweep, but `PrefilterSoundness.lean:96:29` is still family A and still needs
   its own repair. `FlowFrame` and `Interpolate` are untouched by the delta.
2. **`DenseValidity.lean` is in no phase's "Files to modify" list**, including Phase 15's. That
   gap pre-dates this phase — Phase 14 assigned its sites to Phase 15 by judgment, not by the file
   list. It now carries 96% of the remaining breakage and must be added to Phase 15 explicitly.
   No later Omega-binder sweep (Phases 19-21) claims it either, so the mechanical work is not
   duplicated by deferring or by doing it now.
