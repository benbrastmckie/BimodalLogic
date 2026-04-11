# Phase 5 Handoff: Direct BX7 Approach Blocked

## Summary

The direct BX7-based proof approach (Plan v5, Phase 5) is BLOCKED after thorough investigation. The four Frame.lean sorries (`bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`) cannot be closed using BX7/BX11 alone due to a fundamental circularity in the proof structure.

## Key Finding: Circularity in Guard Proof

The central obstacle is a circularity between the Until truth lemma and the guard property:

1. **Forward direction** (`bx_until_eventuality_resolution`): Given `phi U psi in w`, need to show that at intermediate BXPoints u (with `bx_le w u`, `bx_le u v`, `not bx_le v u`), `phi in u`. The natural approach is to use BX5 (self-accumulation) to get `(phi and (phi U psi)) U psi in w`, then derive `phi in u` from the guard of this Until formula. But deriving `phi in u` from the guard of an Until formula at w requires the FORWARD DIRECTION of the Until truth lemma -- exactly what we're trying to prove.

2. **Backward direction** (`bx_until_backward`): Given `bx_le w v`, `psi in v`, guard phi on [w,v), need `phi U psi in w`. By contradiction with enriched seed, get u with `neg(phi U psi) in u`, `bx_le w u`, `bx_le u v`. The case `not bx_le v u` triggers the guard giving `phi in u`, but `phi in u` and `F(psi) in u` do NOT imply `phi U psi in u`. The case `bx_le v u` cannot be ruled out (the enriched seed plus g_content(v) may be consistent).

## What Was Proved

A key helper lemma was successfully proved:

**G_phi_F_psi_implies_until**: `G(phi) in w` and `F(psi) in w` implies `phi U psi in w`.

Proof: BX12 gives `top U psi in w`. BX2 (left_mono_until) with `G(top -> phi)` (derived from `G(phi)` via prop_s + temporal_necessitation + temp_k_dist) gives `top U psi -> phi U psi`.

This lemma was used to show:

**enriched_seed_with_G_phi_inconsistent**: The seed `{neg(phi U psi), G(phi)} union g_content(w) union h_content(v)` is inconsistent (given `bx_le w v` and `psi in v`).

Consequence: any MCS extending the enriched seed `{neg(phi U psi)} union g_content(w) union h_content(v)` must contain `F(neg phi)` (i.e., `G(phi)` cannot be in the MCS).

## Why BX7/BX11 Don't Close the Gap

### BX7 (linear_until)
BX7 relates two Until formulas at the same point: `(phi U psi) and (chi U theta) -> three-way disjunction`. When applied to `phi U psi` and `top U psi`, the three cases reduce to trivially equivalent formulas because `top` (a tautology) doesn't constrain the guard. Applying BX7 with self-accumulated forms (`(phi and (phi U psi)) U psi`) also doesn't help -- the resulting cases are equivalent to what we started with.

### BX11 (temp_linearity)
BX11 gives `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`, constraining the ordering of F-witnesses. Applied to `F(neg(phi U psi))` and `F(psi)`:
- Case 1: F(neg(phi U psi) and psi) -- contradiction via BX8 (psi -> phi U psi).
- Case 2: F(neg(phi U psi) and F(psi)) -- reproduces the same situation at a further point (infinite regress).
- Case 3: F(F(neg(phi U psi)) and psi) -- psi witness before neg(phi U psi) witness, no contradiction.

Case 2 creates an infinite regress that cannot be resolved without well-ordering or induction on the temporal structure.

### bx_le non-totality
The core issue: `bx_le` (g_content inclusion) is a preorder but NOT a total order. BX11 constrains F-witnesses to be ordered, but this ordering is on the F-accessible points, not on g_content inclusion. Two MCSs can have `bx_le u v` and `bx_le v u` (agreeing on all G-content and H-content) while differing on non-modal formulas like `phi U psi`.

## Root Cause

The BX1-12 axiom system is complete for LINEAR temporal logic with Until/Since. The standard completeness proof (Burgess 1984, Goldblatt 1992) establishes linearity of the canonical ordering first, then proves the Until truth lemma. In BX's canonical model, linearity of `bx_le` is NOT available because `bx_le` is defined as g_content inclusion, which is strictly weaker than the orderings used in standard proofs.

The BX axiom system encodes linearity through BX7 (Until linearity) and BX11 (F-linearity), but these constrain the ordering of WITNESSES within Until/F formulas, not the g_content-based ordering between BXPoints. There is no bridge between "F-witnesses are ordered" and "g_content inclusion is total on intervals."

## Recommendations

### Immediate: Declare Phase 5 BLOCKED

The direct BX7 approach has been thoroughly investigated and found non-viable. The plan's Gate D criterion ("if proof stalls after 15h, evaluate feasibility") is triggered.

### Option A: Quotient/Filtration Model (Plan v5 Phase 9 Contingency)

Define equivalence classes on BXPoints by Sigma-agreement: `w ~ v iff forall f in Sigma, f in w.formulas <-> f in v.formulas`. In the quotient:
- The ordering IS total (from BX7/BX11 applied to the finite set of equivalence classes)
- The Until truth lemma follows from totality
- Estimated effort: 40-60h as a new task

### Option B: Redefine bx_le Using Until-Based Ordering

Replace `bx_le w v := g_content(w) subseteq v.formulas` with an ordering that directly uses Until-witness comparisons. This would make the ordering total by construction (from BX7). However, this would require rewriting all of Frame.lean and downstream consumers. Estimated effort: 60-80h.

### Option C: Add Until-Induction as an Axiom

Add the Until-induction schema `(psi or (phi and G(theta)) -> theta) -> (phi U psi -> theta)` to the axiom system. This is sound for linear temporal frames and directly enables the truth lemma. Minimal code changes but adds a new axiom.

**Recommendation**: Option A (quotient/filtration) as a new task. Options B and C have higher risk and broader impact.

## Files Modified

None. The investigation was conducted using `lean_run_code` and prototype proofs without modifying any source files.

## Proved Artifacts (Not Yet in Codebase)

The following lemmas were verified via `lean_run_code` and can be added to the codebase if useful:

1. `G_phi_F_psi_implies_until`: `G(phi) in w, F(psi) in w -> phi U psi in w`
2. `enriched_seed_with_G_phi_inconsistent`: `{neg(phi U psi), G(phi)} union g_content(w) union h_content(v)` is inconsistent

These could be useful for the quotient/filtration approach.

## Session

Session ID: sess_1775924610_34c8e8
