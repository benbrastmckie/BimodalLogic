# Research Report: Task #67 — F_top Blocker Root Cause and Resolution

**Task**: 67 — prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Mode**: Team Research (2 teammates)
**Session**: sess_1774765691_502a81

## Summary

Team investigation confirms the F_top blocker is **genuine and structural**: `DeferralRestrictedSerialMCS` is self-contradictory for general phi because it simultaneously requires `F_top ∈ world` and `world ⊆ deferralClosure(phi)`, but `F_top ∉ deferralClosure(phi)` for general phi. Both teammates independently converge on **extending deferralClosure to always include seriality formulas** as the mathematically correct resolution. All alternative approaches (forward-only truth lemma, full MCS chain, filtration, singleton omega) are confirmed impossible due to the bidirectional truth lemma requirement.

## Key Findings

### 1. Blocker Is Structural, Not a Proof Gap (Both Teammates — HIGH confidence)

The blocker documented in plan 04 is definitively established as a mathematical fact:

- `DeferralRestrictedSerialMCS phi` requires both `has_F_top : F_top ∈ world` AND `is_drm : DeferralRestrictedMCS phi world`
- `DeferralRestrictedMCS` requires `world ⊆ deferralClosure phi`
- Together these force `F_top ∈ deferralClosure phi`
- `some_future_in_deferralClosure_is_in_closureWithNeg` (SubformulaClosure.lean:919) proves that any F-formula in deferralClosure must be in closureWithNeg
- `closureWithNeg(phi)` only contains subformulas of phi and their negations
- For phi without `F(neg bot)` as a subformula (e.g., `box p`, `p`), `F_top ∉ deferralClosure(phi)`

**Concrete counterexample**: For `phi = p`, `deferralClosure(p) = {p, neg p}`. F_top = `F(neg bot)` is clearly not in this set.

### 2. Root Cause: Restricted MCS Design Assumes Seed Already Has Seriality (Teammate A — HIGH confidence)

`DeferralRestrictedSerialMCS` was designed for seeds that ALREADY contain F_top and P_top (e.g., when starting from a full MCS). The `deferral_restricted_lindenbaum` extends a consistent set to a DeferralRestrictedMCS, but this MCS only has maximality within `deferralClosure(phi)`. Since F_top is NOT in `deferralClosure(phi)`, the theorem `theorem_in_drm` (which allows inserting theorems) cannot apply.

The symmetry is: full MCS contains ALL theorems including F_top. DeferralRestrictedMCS only contains theorems that are IN deferralClosure. This creates an unavoidable mismatch.

### 3. Why F_top Is Structurally Required (Both Teammates)

F_top drives the restricted forward chain:
- `constrained_successor_restricted` (SuccChainFMCS.lean:1996) requires `h_F_top : F_top ∈ u`
- F_top must propagate through each chain step for well-definedness
- `F_top_in_restricted_successor` (SuccChainFMCS.lean:2300) uses `h_drm.1.1 h_F_top` to derive `F_top ∈ deferralClosure phi` — the exact point of failure

### 4. All Alternative Approaches Confirmed Impossible (Teammate B — HIGH confidence)

| Alternative | Verdict | Reason |
|-------------|---------|--------|
| Forward-only truth lemma | Impossible | imp forward uses backward IH |
| Full MCS chain + scoped truth | Impossible | F-nesting unbounded in full MCS |
| Singleton Omega | Impossible | Box backward fails without modal saturation |
| Direct semantic proof | Impossible | Must go through bidirectional truth lemma |
| Filtration | Impossible | Same bidirectionality requirement |
| SerialDRM (decouple seriality) | Viable but complex | Requires rewriting `F_top_in_restricted_successor` |

### 5. All Sorry-Free Infrastructure Mapped (Teammate B)

| Component | Status | Location |
|-----------|--------|----------|
| `parametric_canonical_truth_lemma` | Sorry-free | ParametricTruthLemma.lean:207 |
| `construct_bfmcs_bundle` | Sorry-free | UltrafilterChain.lean:2853 |
| `not_provable_implies_neg_consistent` | Sorry-free | UltrafilterChain.lean:2966 |
| `restricted_forward_chain_forward_F` | Sorry-free | SuccChainFMCS.lean:2887 |
| `restricted_backward_chain_backward_P` | Sorry-free | SuccChainFMCS.lean:4238 |
| `build_restricted_tc_family` | Sorry-free (body) | SuccChainFMCS.lean:4642 |
| `deferral_restricted_lindenbaum` | Sorry-free | RestrictedMCS.lean:714 |
| `neg_consistent_gives_mcs_without_phi` | Sorry-free | RestrictedTruthLemma.lean:412 |
| `MCS_to_SerialMCS` | Sorry-free | SuccChainFMCS.lean:154 |

## Synthesis

### Conflicts Resolved

**None** — both teammates independently converge on Approach A (extend deferralClosure) as the correct resolution. Teammate A recommends extending with `{F_top, P_top, neg bot, neg F_top, neg P_top}`, while Teammate B recommends `{F_top, P_top}` plus possibly `neg bot`. The exact set needs careful analysis of downstream usage.

### Resolution: Extend deferralClosure with Seriality Formulas (Approach A)

**The mathematically correct solution** is to define an extended deferral closure:

```lean
def extendedDeferralClosure (phi : Formula) : Set Formula :=
  deferralClosure phi ∪ {F_top, P_top, Formula.neg Formula.bot}
```

**Why this is correct**:
1. F_top and P_top are theorems — they hold in every consistent set
2. Including them in the closure is semantically justified (standard in textbook completeness proofs)
3. F-nesting bound still holds: F_top has depth 1, adding at most 1 to the bound
4. The restricted chain construction remains valid

**Downstream changes required**:

1. **SubformulaClosure.lean** (~649): Extend `deferralClosure` definition
2. **SubformulaClosure.lean** (~919): Update `some_future_in_deferralClosure_is_in_closureWithNeg` — becomes "all F-formulas except F_top are in closureWithNeg"
3. **SubformulaClosure.lean** (~752): Update `max_F_depth_deferralClosure_eq` for F_top depth
4. **SuccChainFMCS.lean**: 14 call sites of the above theorem need special-casing for F_top
5. **SuccExistence.lean**: 2 call sites need the same update

**Pattern at each call site**: The existing pattern is:
```
F(chi) ∈ deferralClosure → F(chi) ∈ closureWithNeg → chi ∈ subformulaClosure → chi ∈ deferralClosure
```
The update adds a branch for F_top:
```
F(chi) ∈ deferralClosure →
  if F(chi) = F_top then chi = neg bot ∈ deferralClosure (by extension)
  else F(chi) ∈ closureWithNeg → chi ∈ subformulaClosure → chi ∈ deferralClosure
```

### Gaps Identified

1. **Exact set of formulas to add**: Whether `neg bot` alone suffices or whether `neg F_top`, `neg P_top` are also needed for DRM negation completeness arguments
2. **Whether `neg bot ∈ subformulaClosure(phi)` holds for all phi**: It does NOT (requires `bot ∈ subformulaClosure(phi)`). This means the extended closure must also include `neg bot` directly, not just derive it
3. **Impact on F-nesting depth theorems**: Adding F_top (depth 1) may change `max_F_depth_deferralClosure_eq` by at most 1, but the termination argument uses B^2 fuel which should still suffice

### Why This Is the Mathematically Principled Fix

In standard textbook completeness proofs for temporal logic (e.g., Blackburn, de Rijke, Venema):
- The closure/Fischer-Ladner set always includes seriality formulas
- The "background axioms" of the logic (seriality for linear temporal logic) are built into the closure from the start
- Our omission of seriality formulas from `deferralClosure` was an oversight in the original design

The fix aligns the Lean formalization with standard mathematical practice.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Root cause analysis of F_top blocker | Completed | HIGH |
| B | Alternative proof architectures | Completed | HIGH |

## References

- `SubformulaClosure.lean:919` — `some_future_in_deferralClosure_is_in_closureWithNeg` (the blocking lemma)
- `SubformulaClosure.lean:649` — `deferralClosure` definition (target for extension)
- `SuccChainFMCS.lean:2272` — `DeferralRestrictedSerialMCS` structure
- `SuccChainFMCS.lean:2300` — `F_top_in_restricted_successor` (uses F_top ∈ deferralClosure)
- `SuccChainFMCS.lean:1996` — `constrained_successor_restricted` (requires h_F_top)
- `RestrictedMCS.lean:714` — `deferral_restricted_lindenbaum` (sorry-free)
- `RestrictedMCS.lean:1322` — `theorem_in_drm` (conditional on closure membership)
