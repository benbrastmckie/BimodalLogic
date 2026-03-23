# Implementation Summary: Task #988

**Status**: BLOCKED
**Date**: 2026-03-18
**Session**: sess_1773792880_132dac

## Overview

Executed plan v6 for dense algebraic completeness. Conducted deep analysis of the 4
sorries in ClosureSaturation.lean. All phases remain blocked.

## Phase 1 Analysis: The 4 Sorries

### Sorry 1 (Line 659): timelineQuotFMCS_forward_F, m > 2k case

**Goal**:
```
h_phi_W : phi ∈ W  (W from canonical_forward_F, but W may not be in timeline)
⊢ ∃ s, p < s ∧ phi ∈ timelineQuotFMCS.mcs s
```

**Blocker**: `canonical_forward_F` produces an arbitrary MCS `W` via Lindenbaum.
`W` is NOT necessarily in the staged timeline `TimelineQuot`. The staged timeline
contains only MCSs reachable from the root via the staged construction process.
For late-added points `p` (stage m > 2k), the witness for `F(phi)` was supposed to
be added at stage 2k+1, but `p` wasn't in the build at that stage.

**Fix required**: Dovetailing construction that re-processes F-obligations for
newly added points, or architecture ensuring all F-witnesses are eventually added.
Task 982's DovetailedTimelineQuot is designed for this purpose.

### Sorry 2 (Line 664): timelineQuotFMCS_forward_F, density point case

**Goal**:
```
h_q_in_dense : q ∈ denseTimelineUnion
h_R_pq : CanonicalR p.mcs q.mcs  (q is CanonicalR-successor of p, but phi ∉ q.mcs)
⊢ ∃ s, p < s ∧ phi ∈ timelineQuotFMCS.mcs s
```

**Blocker**: `q` is a CanonicalR-successor of `p` with `g_content(p.mcs) ⊆ q.mcs`,
but `F(phi) ∈ p.mcs` does NOT imply `phi ∈ q.mcs` (since `F(phi) = ¬G(¬phi)` is
not G-shaped and doesn't transfer via CanonicalR). We need a DIFFERENT successor
that contains phi, not just any CanonicalR-successor.

**Fix required**: Same as Sorry 1 - need dovetailing to find the specific witness
for `phi` rather than just any CanonicalR-successor.

### Sorry 3 (Line 679): timelineQuotFMCS_backward_P

**Goal**:
```
h_P : phi.some_past ∈ timelineQuotFMCS.mcs t
⊢ ∃ s < t, phi ∈ timelineQuotFMCS.mcs s
```

**Blocker**: Symmetric to forward_F. The backward witness may not be in the
staged timeline. Requires dovetailing for P-obligations.

### Sorry 4 (Line 724): modal_backward for singleton BFMCS

**Goal**:
```
h_all : ∀ fam' ∈ {timelineQuotFMCS}, φ ∈ fam'.mcs t
(simplifies to: φ ∈ timelineQuotFMCS.mcs t)
⊢ φ.box ∈ timelineQuotFMCS.mcs t
```

**Blocker**: **ARCHITECTURALLY IMPOSSIBLE**. This asks to prove `φ ∈ mcs(t) → □φ ∈ mcs(t)`
for an arbitrary MCS. This is not a theorem of TM logic (it would require S5's
"reflexivity of Box" in reverse direction, or the axiom `φ → □φ`).

The `ModalSaturation.lean` module provides `saturated_modal_backward` which
proves `modal_backward` for modally SATURATED bundles (multi-family). In a singleton
bundle {F}, "diamond ψ ∈ mcs(t)" means "some family in {F} has ψ" = "ψ ∈ F.mcs t",
but `◇ψ ∈ mcs(t)` does NOT imply `ψ ∈ mcs(t)` in general.

**Fix required**: Use a multi-family BFMCS where families = {ratFMCS_M | M : all MCSs}
and prove modal saturation holds. For this approach, if `◇ψ ∈ fam.mcs t`, then ψ
is consistent (by MCS properties), so ∃ MCS M' with ψ ∈ M', and we need M' to
appear as `ratFMCS_{M'}.mcs t` for some specific root construction. This is hard
because different families place different MCSs at the same rational time t.

## Key Architectural Insight

The parallel file `CanonicalEmbedding.lean` independently runs into the SAME issues:
- `ratFMCS_forward_F`: sorry (line 181) - same F-witness gap
- `ratFMCS_backward_P`: sorry (line 192) - same P-witness gap
- `ratBFMCS.modal_backward`: sorry (line 231) - same singleton impossibility

The ClosureSaturation.lean and CanonicalEmbedding.lean are two attempts at the same
fundamental problem and both are blocked.

## Why Plan v6 Is Blocked

Plan v6 states "the 4 sorries are the entire bottleneck" - but these sorries represent
**deep architectural gaps**, not just missing proof steps:

1. **Forward_F/backward_P** require a dovetailing construction that re-processes
   F/P-obligations for late-added timeline points. This is precisely the work of
   task 982 (DovetailedTimelineQuot) and task 986 (BFMCS for Int).

2. **modal_backward singleton** is fundamentally unprovable. The BFMCS construction
   must use modal saturation via a multi-family bundle.

## Required Architectural Changes

To complete task 988, one of these approaches is needed:

### Option A: Wait for task 982
Task 982 (DovetailedTimelineQuot) will provide a sorry-free forward_F/backward_P
for a timeline over Rat. The modal_backward issue still requires non-singleton bundle.

### Option B: Build modally saturated BFMCS over Rat
- Use `saturated_modal_backward` from ModalSaturation.lean
- Build families = {for each MCS M, an FMCS Rat containing M at its root time}
- Prove modal saturation: ◇ψ ∈ mcs(t) → ∃ family with ψ ∈ mcs(t)
- This is cleaner but requires sorry-free forward_F for each family

### Option C: Use CanonicalMCS approach differently
The `canonicalMCSBFMCS` FMCS has sorry-free forward_F/backward_P (CanonicalMCS is
special: each domain element IS an MCS). But CanonicalMCS lacks AddCommGroup, so
the parametric representation theorem doesn't apply directly. Would need a different
representation theorem that works for D = CanonicalMCS, or a transport lemma.

## Phases Completed

0 out of 3 phases completed.

## Next Steps

1. Implement task 982 (DovetailedTimelineQuot) which provides the sorry-free
   F/P coherence needed for Phase 1
2. After task 982, design a non-singleton BFMCS Rat using modal saturation
3. Revise plan v6 to reflect the multi-family BFMCS approach
