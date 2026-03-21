# Research Report: Task #1006 (Teammate B)

**Task**: Replace FlagBFMCS satisfies_at with canonical TaskFrame using truth_at
**Date**: 2026-03-19
**Focus**: Alternative patterns and prior art in the codebase

## Summary

This report surveys the existing codebase for patterns that task 1006 can directly
adapt. The key finding is that a complete, sorry-free implementation already exists
in the `Algebraic/` subsystem (`ParametricCanonical`, `ParametricHistory`,
`ParametricTruthLemma`, `ParametricRepresentation`). The "validity bridge approach"
of task 997 was an attempt to *embed* FlagBFMCS into this algebraic infrastructure;
task 1006 supersedes it by *directly constructing* the canonical TaskFrame from
FlagBFMCS data rather than bridging between two structures.

---

## Key Findings

### Finding 1: The Parametric Algebraic Subsystem Is the Exact Target

The `Algebraic/` subsystem provides a complete, sorry-free implementation of exactly
what task 1006 wants to build, but it requires a `BFMCS D` (bundle indexed by a group
type `D`). Task 1006 must replicate this same pattern directly on FlagBFMCS data.

The four key files form a clear pipeline:

1. **`ParametricCanonical.lean`**: Defines `ParametricCanonicalWorldState` (MCS-wrapped
   subtypes) and `ParametricCanonicalTaskFrame D` (the canonical TaskFrame with
   `CanonicalR`-based task_rel).

2. **`ParametricHistory.lean`**: Defines `parametric_to_history` (converts FMCS to
   WorldHistory), `ShiftClosedParametricCanonicalOmega`, and shift-closure proofs.

3. **`ParametricTruthLemma.lean`**: Proves `parametric_shifted_truth_lemma` — the
   central result connecting MCS membership to `truth_at`. This is sorry-free.

4. **`ParametricRepresentation.lean`**: Proves `parametric_representation_from_neg_membership`,
   which directly gives the completeness contradiction using `valid`'s definition.

### Finding 2: How AlgebraicBaseCompleteness.lean Calls valid

The existing completeness theorem (with a sorry in `construct_bfmcs_from_mcs_Int`)
shows exactly how to close the proof against `valid`:

```lean
-- From AlgebraicBaseCompleteness.lean lines 246-253
have h_true := h_valid Int (ParametricCanonicalTaskFrame Int) (ParametricCanonicalTaskModel Int)
  (ShiftClosedParametricCanonicalOmega B)
  (shiftClosedParametricCanonicalOmega_is_shift_closed B)
  (parametric_to_history fam)
  (parametricCanonicalOmega_subset_shiftClosed B ⟨fam, hfam, rfl⟩)
  t
exact h_false h_true
```

The pattern is: specialize `valid` at the specific TaskFrame/TaskModel/Omega/history,
then use the truth lemma to derive a contradiction.

### Finding 3: The Core Obstacle in Task 997 — Why It Was Superseded

`FlagBFMCSValidityBridge.lean` (task 997) documented the gap:

> `valid` requires `D : Type` with `AddCommGroup D`. FlagBFMCS uses `CanonicalMCS`
> directly (no group structure). Therefore, FlagBFMCS cannot directly instantiate
> `TaskFrame CanonicalMCS`.

Task 1006 resolves this differently: instead of adapting an existing `D`-indexed FMCS
into the `valid` framework, it proposes constructing the canonical TaskFrame with
`D = ChainFMCSDomain F` for a specific Flag `F`. However, `ChainFMCSDomain F` is a
subtype of `CanonicalMCS`, also lacking group structure. The actual resolution is to
use `D = Int` (or any suitable group) while constructing histories from Flag chains.

The critical insight from task 997 summary is:

> Both truth lemmas reduce to MCS membership:
> - FlagBFMCS: `satisfies_at ... phi <-> phi in (chainFMCS F).mcs x`
> - Parametric: `phi in fam.mcs t <-> truth_at ... (parametric_to_history fam) t phi`
> The bridge would follow if we could show correspondence of the structures.

Task 1006 takes the direct path: build an FMCS D directly from Flag chain data, then
apply the existing `parametric_shifted_truth_lemma` directly.

### Finding 4: FlagBFMCS Has All Properties Needed as a BFMCS Analogue

`FlagBFMCS` provides:
- `modally_saturated` — replaces `modal_forward`/`modal_backward` from BFMCS
- `temporally_complete` — via `allFlagsBFMCS` using `Set.univ`
- Full truth lemma (`satisfies_at_iff_mem`) — sorry-free

`ChainFMCS.lean` provides:
- `chainFMCS : Flag CanonicalMCS → FMCS (ChainFMCSDomain F)` — the per-flag FMCS
- `chainFMCS_forward_G`, `chainFMCS_backward_H` — temporal coherence facts
- `ChainFMCSDomain F` is a `LinearOrder` (inheriting from `CanonicalMCS` preorder)

The challenge is that `ChainFMCSDomain F` lacks `AddCommGroup` structure. Task 1006's
description mentions using "Flag chain positions" as the duration domain `D`.

### Finding 5: The BFMCS-to-FMCS Construction Pattern for D = Int

`IntFMCSTransfer.lean` provides the existing pattern for constructing an `FMCS Int`
from an MCS (with sorries at `forward_F`/`backward_P`). Task 1006 aims to eliminate
these sorries by using Flag chains directly, since Flags are maximal chains in
`CanonicalMCS` and every MCS appears in some Flag (by `canonicalMCS_in_some_flag`).

The key insight is: a Flag chain provides all temporal witnesses. If `M` has `F(phi)`,
then by `canonical_forward_F`, some `M'` with `phi` and `CanonicalR M M'` exists.
Since the Flag is a chain, `M'` must be in the same Flag (or reachable via Flag
construction). The `allFlagsBFMCS` uses all Flags precisely because this guarantees
temporal completeness.

### Finding 6: The `parametric_to_history` Pattern Is Directly Reusable

The `ParametricHistory.lean` conversion (`parametric_to_history`) converts any
`FMCS D` to a `WorldHistory (ParametricCanonicalTaskFrame D)`:

```lean
-- ParametricHistory.lean lines 62-90
def parametric_to_history (fam : FMCS D) : WorldHistory (ParametricCanonicalTaskFrame D) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => True.intro
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := ...  -- uses fam.forward_G
```

The `domain = True` trick (every time is in the domain) eliminates all domain complexity.
This pattern is essential: any new construction for FlagBFMCS should use the same trick.

### Finding 7: The `CanonicalConstruction.lean` Non-Parametric Pattern (D = Int hardcoded)

`CanonicalConstruction.lean` shows the older non-parametric version (D = Int):
- `CanonicalWorldState = { M : Set Formula // SetMaximalConsistent M }` (same as parametric)
- `canonical_task_rel` uses `CanonicalR` (same pattern, hardcoded to Int)
- `to_history` converts FMCS Int to WorldHistory
- `shifted_truth_lemma` — the sorry-free truth lemma for Int

This confirms the construction pattern is stable across D choices.

### Finding 8: SeparatedTaskFrame Pattern — Instantiating Parametric at a Concrete D

`SeparatedTaskFrame.lean` shows how to instantiate `ParametricCanonicalTaskFrame` at
`D = TimelineQuot`:

```lean
noncomputable def SeparatedCanonicalTaskFrame :
    TaskFrame (TimelineQuot root_mcs root_mcs_proof) :=
  ParametricCanonicalTaskFrame (TimelineQuot root_mcs root_mcs_proof)
```

The W/D separation insight (from task 982 research): WorldState = all MCSs (not just
those in the timeline), while D = specific ordered group. This is directly applicable to
the FlagBFMCS → TaskFrame construction: use `D = Int` (or `ChainFMCSDomain F` with
appropriate structure), `W = ParametricCanonicalWorldState` (all MCSs).

---

## Recommended Approach

### The Direct Construction (bypassing the bridge problem)

The cleanest path follows the `AlgebraicBaseCompleteness.lean` pattern but using FlagBFMCS
as the BFMCS analogue. The construction:

**Step A**: Use `D = Int` (or any suitable group). Use the `allFlagsBFMCS` construction.

**Step B**: Build a `BFMCS Int` from `FlagBFMCS` where:
- Each Flag `F` in `B.flags` contributes an FMCS Int via a chain-to-Int mapping.
- The modal coherence conditions are satisfied using `FlagBFMCS.modally_saturated`.

This is the approach that `IntFMCSTransfer.lean` was attempting (with sorries). The
sorry-free version requires constructing the dovetailing chain that includes all
temporal witnesses.

**Alternative (the task 1006 specification approach)**: Construct a canonical TaskFrame
directly where `D = ChainFMCSDomain F` for the evaluation Flag. This requires:
- Showing `ChainFMCSDomain F` has `AddCommGroup` structure (NOT currently available)
- OR using a different embedding of Flag chain positions into an ordered group

**Recommended concrete approach**: Construct `BFMCS Int` from `FlagBFMCS` using the
following insight: `CanonicalMCS` is a linear order (via `CanonicalR`), and each Flag is
a chain in this order. An order-preserving map from `ChainFMCSDomain F` into `Int` exists
when `F` is countable (which it is, since formulas are countable and each MCS is a subset
of formulas). This gives an embedding `embed_flag : Flag → Int → FMCS Int`.

The key reusable components are:
1. `ParametricCanonicalTaskFrame Int` — ready to use unchanged
2. `ParametricCanonicalTaskModel Int` — ready to use unchanged
3. `parametric_to_history` — ready to use with Int-indexed FMCS
4. `parametric_shifted_truth_lemma` — ready to use if BFMCS Int constructed
5. `ShiftClosedParametricCanonicalOmega` + `shiftClosedParametricCanonicalOmega_is_shift_closed` — ready to use
6. `parametric_representation_from_neg_membership` — closes the proof against `valid`

The only missing piece is the sorry-free `BFMCS Int` construction from FlagBFMCS data
that handles temporal coherence (`forward_F`, `backward_P`).

### Why FlagBFMCS Provides the Missing F/P Witnesses

The `allFlagsBFMCS` approach with `flags = Set.univ` means every `CanonicalMCS` is in
some Flag. When the canonical construction (via `temporal_coherent_family_exists_CanonicalMCS`)
produces F/P witnesses, they exist as `CanonicalMCS` elements, which are in some Flag.
Therefore the temporal coherence conditions for `allFlagsBFMCS` are satisfied.

The task description item "(2) duration domain D parametrically from Flag chain positions"
suggests embedding Flag chain positions into an ordered group. The existing
`ChainFMCSDomain F` is a subtype of `CanonicalMCS` with a `LinearOrder`. Since `CanonicalMCS`
is countable (each is a subset of a countable set of formulas), one can use a
`RelIso ChainFMCSDomain F ↪ Int` to embed into Int.

---

## Evidence/Examples

### Pattern 1: Direct TaskFrame Construction (CanonicalConstruction.lean)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

Lines 122-160: `CanonicalWorldState` definition (same pattern as task 1006 needs)
Lines 156-159: `canonical_task_rel` using CanonicalR

### Pattern 2: Parametric TaskFrame (ParametricCanonical.lean)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`

Lines 63-64: `ParametricCanonicalWorldState := { M : Set Formula // SetMaximalConsistent M }`
Lines 85-89: `parametric_canonical_task_rel` — the task relation pattern to reuse
Lines 199-206: `ParametricCanonicalTaskFrame D` definition — the constructor to call

### Pattern 3: History Conversion (ParametricHistory.lean)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean`

Lines 62-90: `parametric_to_history fam` — converts FMCS to WorldHistory
  - `domain := fun _ => True` — the key simplification
  - `states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩`
  - `respects_task` proof uses `fam.forward_G`

Lines 110-126: `ParametricCanonicalOmega` and `ShiftClosedParametricCanonicalOmega`

### Pattern 4: Shift-Closed Omega Proof (ParametricHistory.lean)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean`

Lines 151-157: `shiftClosedParametricCanonicalOmega_is_shift_closed` — shift-closure proof
Lines 161-167: `parametricCanonicalOmega_subset_shiftClosed` — membership bridge

### Pattern 5: Truth Lemma (ParametricTruthLemma.lean)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`

Lines 60-62: `ParametricCanonicalTaskModel D` — valuation = MCS membership
Lines 174-180: `parametric_canonical_truth_lemma` signature
Lines 329-334: `parametric_shifted_truth_lemma` — the key lemma for completeness

### Pattern 6: Closing the Proof Against `valid` (AlgebraicBaseCompleteness.lean)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`

Lines 229-253: `algebraic_base_completeness` — the complete proof pattern.
The key lines 246-253 show exactly how to specialize `valid` and derive contradiction.

### Pattern 7: Why Task 997's Bridge Approach Failed

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FlagBFMCSValidityBridge.lean`

Lines 50-60: The documented obstacle — `CanonicalMCS` lacks `AddCommGroup` structure.
Lines 228-241: The sorry + detailed comments explaining the required construction.

The bridge approach tried to connect FlagBFMCS to the parametric frame via embedding.
Task 1006 supersedes this by constructing the canonical TaskFrame *starting from* Flag
chain data as the primary construction, not as a bridge.

### Pattern 8: FlagBFMCS Temporally Complete (all Flags)

File: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean`

Lines 57-79: `FlagBFMCS.temporally_complete` definition and `allFlagsBFMCS_temporally_complete`
  — confirms that using all Flags gives the temporal completeness needed for F/P witnesses.

Lines 300-367: `mem_of_satisfies_at_all_future` — uses temporal completeness to find F witnesses
via `canonicalMCS_in_some_flag` (Zorn's lemma). This is the sorry-free mechanism.

---

## Confidence Level

**High** — the existing parametric algebraic infrastructure in `Algebraic/` is well-tested
and directly applicable. The construction pattern is clear. The main technical challenge
(constructing a sorry-free `BFMCS Int` from Flag data with F/P coherence) is the same
challenge that was partially addressed in task 1004 (dovetailing chain), and the
`allFlagsBFMCS` with `temporally_complete` provides the key mechanism that was missing
in the old `IntBFMCS` approach.

The recommended approach (use `ParametricCanonicalTaskFrame Int` + build FMCS Int from
Flag chain data) is strongly supported by:
- The sorry-free truth lemma in `ParametricTruthLemma.lean`
- The sorry-free completeness logic in `ParametricRepresentation.lean`
- The sorry-free temporal completeness in `FlagBFMCSTruthLemma.lean`

The only implementation risk is the Int embedding of `ChainFMCSDomain F`, which requires
either an explicit order-embedding construction or leveraging the `CanonicalFMCS`
infrastructure that already exists in `CanonicalFMCS.lean`.

---

## Next Steps

1. Examine `CanonicalFMCS.lean` and `temporal_coherent_family_exists_CanonicalMCS` to
   understand if the F/P witnesses are already available at the `CanonicalMCS` level.

2. Check whether `FMCS (ChainFMCSDomain F)` (from `chainFMCS`) can be lifted to
   `FMCS Int` via a countable order-embedding without new sorries.

3. Verify that `FlagBFMCS.modally_saturated` can replace `BFMCS.modal_backward` in
   the parametric truth lemma's box case.

The primary reuse opportunity is: call `parametric_shifted_truth_lemma` directly with
the appropriate BFMCS Int constructed from FlagBFMCS, then apply
`parametric_representation_from_neg_membership` to close the completeness proof against `valid`.
