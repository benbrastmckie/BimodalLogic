# Research Report: Task 88 -- Teammate C (Critic) Findings, Round 2

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Role**: Critic -- gaps, invalid assumptions, and risks in the current implementation plan
**Focus**: Phase-by-phase risk analysis after Phase 1 completion

## Executive Summary

Phase 1 of the implementation plan has been executed (COMPLETED): `temp_linearity`, `temp_linearity_past`, `F_until_equiv`, and `P_since_equiv` are now proper axiom constructors in `Axioms.lean`, with soundness case arms added to `Soundness.lean`. Phase 2 (bx_le linearity) remains BLOCKED. This report identifies critical gaps in the proposed proof strategies for Phases 2-5, with focus on whether the newly added axioms are actually sufficient to close the remaining sorries.

## Key Findings

### Finding 1: The Phase 2 Proof Strategy Has a Fundamental Gap (HIGH CONFIDENCE: 90%)

The implementation plan proposes for Phase 2:

> "Given BXPoints w, v, suppose `F(phi) in u` for some phi witnessing w (via bx_forward_witness) and `F(psi) in u` witnessing v. Apply temp_linearity to get three cases, each yielding a bx_le relationship."

**The gap**: This argument has a structural mismatch. `bx_le w v` is defined as `g_content(w) ⊆ v.formulas` -- i.e., for all formulas phi, `G(phi) in w -> phi in v`. Proving totality of bx_le requires showing: for any two BXPoints w and v, either every G-formula of w is in v, or every G-formula of v is in w. Nothing in `temp_linearity` directly gives this.

`temp_linearity` says: `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)`. This is about F-formulas at a single MCS. To get bx_le(w, v) or bx_le(v, w), you would need: for any formula chi with `G(chi) in w`, chi is in v; or for any formula chi with `G(chi) in v`, chi is in w.

There is no obvious path from temp_linearity to this. The axiom is about future eventualities at a point; bx_le totality is a statement about G-closure relationships between two separate MCSs.

**The alternative plan path** (using F_until_equiv + BX7) is also suspect: `F(psi) -> top U psi` converts F to Until. BX7 (linear_until) says: if `(phi U psi) and (chi U theta)` hold simultaneously, their witnesses are linearly ordered. So if both `top U phi` and `top U psi` hold at some MCS u, then their witnesses are ordered. But "witnesses are ordered" in the BX7 sense means the Until-witnesses are ordered -- not that the corresponding bx_le successors are ordered. The Until-witness MCS for `top U phi` in w is a Lindenbaum extension of `{phi} union g_content(w)`, while bx_le(w, v) means g_content(w) is a subset of v. These are different relationships.

**Conclusion**: The plan's two proposed proof strategies for bx_le_total both have unresolved gaps. Phase 2 may require significant new infrastructure not currently in the codebase.

### Finding 2: The Docstring in Frame.lean Is Stale and Will Cause Confusion (MEDIUM CONFIDENCE: 95%)

Frame.lean lines 585-622 contain analysis from before Phase 1 was executed. The comment says:

> "Approach (B): Global bx_le linearity is FALSE (report 08). BX7 constrains Until-witness ordering, not g_content inclusion. No bridge exists."

This analysis was written when temp_linearity was NOT an axiom. After Phase 1, temp_linearity IS an axiom. Any implementer reading this docstring will be misled into thinking bx_le linearity has been ruled out. If Phase 2 is attempted, the implementer should first update this docstring to reflect the new axiom status, or else they may waste time trying approaches already documented as "blocked" when the new axiom context changes the situation.

**Risk**: Stale documentation causes incorrect assumptions about what is possible.

### Finding 3: The Guard Condition in Frame.lean Sorries Is More Complex Than the Plan Acknowledges (HIGH CONFIDENCE: 85%)

The plan for Phase 3 says for `bx_until_eventuality_resolution`:

> "Given `phi U psi in w` and `psi not in w`, use BX10 to get `F(psi)` witness v, apply bx_le_total to order intermediate points, use BX5 self-accumulation to propagate guard phi along the interval."

The sorry signature is:

```lean
bx_until_eventuality_resolution (w : BXPoint) (φ ψ : Formula)
    (h_until : Formula.untl φ ψ ∈ w.formulas)
    (h_not_psi : ψ ∉ w.formulas) :
    ∃ v : BXPoint, bx_le w v ∧ ψ ∈ v.formulas ∧
      ∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

Even with bx_le_total proved, there is a significant subtlety: the guard `∀ u, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u` requires that phi holds at EVERY BXPoint u strictly between w and v. With bx_le_total, for any u with `bx_le w u`, you can place u relative to v (either `bx_le u v` or `bx_le v u`). But to show `phi in u` for u in [w,v), you cannot simply use BX5 self-accumulation.

BX5 says `(phi U psi) -> (phi and (phi U psi)) U psi`. This means at w, there is a new eventuality `(phi and (phi U psi)) U psi`. But to propagate phi to an intermediate u requires knowing that `phi U psi in u`, which requires knowing `phi U psi` propagates forward. `phi U psi in w` does NOT give `G(phi U psi) in w` (this is the original X-vs-G mismatch). BX5 and self-accumulation do not resolve this.

The standard approach in the literature (Burgess 1984) uses "Until-induction" for exactly this purpose: from `phi U psi in w`, derive that `phi` holds until psi at every intermediate point by induction on the well-foundedness of the ordering. This requires the ordering to be well-founded (which linear integer orders are). But the canonical ordering on MCSs, even if total, may not be well-founded in any useful sense.

**Risk**: Even if bx_le_total is proved, the guard propagation argument may require a well-foundedness argument or explicit induction schema not currently in the codebase.

### Finding 4: The CanonicalEmbedding Sorry (Phase 4) Has TWO Distinct Incompleteness Problems (HIGH CONFIDENCE: 80%)

The plan frames Phase 4 as: "construct a two-point history using bx_le linearity." The sorry at line 418 occurs inside:

```lean
-- Case B: ψ not valid. Contrapositive argument.
-- ...MCS w constructed with ψ in w, χ not in w...
-- Gap: flatten(χ) in w doesn't imply χ in w when χ contains G or H.
sorry
```

There are actually two distinct problems here:

**Problem A (addressed by the plan)**: For chi containing G/H, a constant history collapses temporal operators. The plan proposes using bx_le linearity to construct a non-constant history. This is plausible IF bx_le_total is proved.

**Problem B (not addressed by the plan)**: The `usf_completeness` function is recursively defined on formula structure. In Case B for `ψ -> χ`, after constructing the countermodel for `ψ -> χ`, you need to show validity of `ψ -> χ` is violated. The proof uses `ih_ψ` and `ih_χ` (induction hypotheses on ψ and χ), but the current code only uses `ih_χ`. The ih_ψ hypothesis has type `untilSinceFree ψ -> valid ψ -> Nonempty (DerivationTree [] ψ)`, but ψ may not be valid (Case B is the case where ψ is NOT valid). So the IH for ψ is unused in Case B, which is correct. But the proof obligation for Case B requires showing a semantic counterexample where `ψ -> χ` is false, meaning ψ is true and χ is false. The issue is that `χ not in w` (syntactic) needs to become "χ is semantically false at some model point" (semantic). The standard bridge is the truth lemma applied to w. For the USF fragment, the truth lemma for G (i.e., `G(alpha) in w iff forall v >= w, alpha in v`) is proved in TruthLemma.lean via bx_G_forward + bx_G_backward, which are already sorry-free. So the backward truth direction for G is already available. The gap is specifically in the "embedding into a TaskModel" step: you need to exhibit an actual TaskModel (a concrete `Σ : D -> WorldHistory`, a concrete `F : TaskFrame`, etc.) where the formula is false. The current code builds a constant history, which is insufficient for temporal formulas.

**Risk**: Phase 4 requires not just bx_le_total but also the infrastructure for constructing non-constant WorldHistory objects from BXPoint chains. This infrastructure does not currently exist in CanonicalEmbedding.lean and would need to be built from scratch.

### Finding 5: The Completeness.lean Sorry (Phase 5) Is Not Simply "Downstream" (HIGH CONFIDENCE: 75%)

The plan and round-1 Teammate C report both characterize the Completeness.lean sorry as "downstream -- closes when others close." Reading the actual sorry more carefully:

```lean
-- Now we need: valid φ implies φ ∈ M (for any MCS M).
-- This requires the canonical model construction.
-- Build canonical TaskModel and show φ false at w₀.
sorry
```

This sorry requires constructing a concrete `TaskModel` (a value of type `TaskModel`) and proving that phi is false at w₀ in this model. The TruthLemma.lean provides the MCS-level truth lemma (e.g., `until_iff_mcs`), but the link between MCS membership and TaskModel truth still needs to be built. This bridge requires:

1. A concrete TaskModel where points are BXPoints, with proper WorldHistory and Omega definitions
2. Proof that canonical valuation is correct (already done for fragments)
3. Proof that the temporal structure (bx_le) correctly models the linear order in the TaskFrame

Items 1 and 3 depend on bx_le_total being proved AND the TaskFrame semantics being set up with bx_le as the underlying order. This is non-trivial infrastructure. The CanonicalEmbedding.lean module currently uses a different approach (constant histories with modal-equivalence-class Omega). The Phase 5 approach of "build canonical TaskModel and embed" needs a whole new embedding not currently in the codebase.

**Risk**: Phase 5 may require 4-8 hours of new infrastructure, not 1.5 hours as estimated.

### Finding 6: The Sorry Count Is Confirmed At 6 in BXCanonical, But More Sorries Exist Elsewhere (MEDIUM CONFIDENCE: 95%)

The grep confirms exactly 6 sorry locations in BXCanonical:
- Frame.lean:653, 675, 690, 704 (4 sorries)
- CanonicalEmbedding.lean:418 (1 sorry)
- Completeness.lean:160 (1 sorry)

TruthLemma.lean has NO sorry tactic calls (confirmed by grep).

However, there are additional sorries outside BXCanonical that the plan addresses in Phase 6:
- `Algebraic/UltrafilterChain.lean:3936, 3946` (2 sorries)
- `Bundle/SuccChainFMCS.lean:2166` (1 sorry)
- `Bundle/SuccRelation.lean:548` (1 sorry)
- `ConservativeExtension/Lifting.lean:233,236-240, 473,476-480` (10 sorries)

These are outside the BXCanonical module. The Phase 6 plan only mentions DovetailedChain and FiniteDeferral. Several of the ConservativeExtension sorries (tagged "temp_linearity removed in BX", "density removed in BX", etc.) may now be fixable since Phase 1 restored temp_linearity. But Phase 6 as written doesn't enumerate these, and the plan's "zero sorry markers tagged 'removed in BX'" verification check would require addressing all 10+ of them.

**Risk**: Phase 6 scope is larger than estimated (0.5 hours is unrealistic for 10+ ConservativeExtension sorries).

### Finding 7: bx_le Totality from temp_linearity -- The Missing Mathematical Link

This is the single most critical gap. Here is a careful analysis of whether the proof is feasible:

**What temp_linearity gives**: At any MCS w, if `F(phi) in w` and `F(psi) in w`, then one of three cases holds (phi and psi hold simultaneously, phi before psi, or psi before phi).

**What bx_le totality requires**: For any two BXPoints w and v, either `g_content(w) ⊆ v.formulas` or `g_content(v) ⊆ w.formulas`.

**The bridge** (if it exists): Suppose for contradiction that bx_le(w,v) fails AND bx_le(v,w) fails. Then there exists `G(phi) in w, phi not in v` and `G(psi) in v, psi not in w`. From `G(phi) in w`, by BX1 (G(phi) -> phi), `phi in w`. From `G(psi) in v`, `psi in v`. But we need `F(phi) in v` and `F(psi) in w` to apply temp_linearity. We have `phi in w` but not `F(phi) in v` from `G(phi) in w` directly. There is no obvious derivation here.

**Alternative via F_until_equiv**: If `F(phi) in w` for some phi, then `top U phi in w`. By BX7, if both `top U phi in w` and `top U psi in w`, we get ordered witnesses. But we need witnesses that correspond to MCSs w and v themselves, not arbitrary Until-witnesses. The Until-witness for `top U phi in w` is an MCS that contains phi but was Lindenbaum-extended from `{phi} union g_content(w)`. This MCS is >= w in bx_le, but it's not v.

**Conclusion**: There is no clear proof path from the newly added axioms to bx_le totality. The mathematical gap remains.

**CONFIDENCE**: The gap is real, but I cannot rule out that a clever Lean proof finds a path I haven't seen. Confidence that the simple plan strategies FAIL: 85%. Confidence that bx_le totality is simply impossible from current axioms: 60%.

## Critical Issues

### Issue 1: Phase 2 Strategy Is Under-Specified

The plan lists two alternative strategies for bx_le totality (F-witness approach via temp_linearity, and F_until_equiv + BX7 approach) but neither is spelled out at the level of detail needed to assess feasibility. Both have the structural gap described in Finding 1. Phase 2 needs either a detailed mathematical proof sketch or a go/no-go decision based on explicit failure.

### Issue 2: Circular Dependency Risk in Phase 3

The guard proof for `bx_until_eventuality_resolution` likely requires a well-founded induction argument on the interval [w,v). This is problematic because bx_le on MCSs may not be well-founded even if it is total. The BXPoint type is a quotient of all MCSs (uncountably many), and there is no a priori reason the ordering is Noetherian. If the ordering is not well-founded, Until-induction schemes cannot be applied.

### Issue 3: Phase 4 Requires New Infrastructure

Building non-constant WorldHistory objects from BXPoint chains requires:
- A `ChainType` or similar structure mapping `Int -> BXPoint`
- Proof that the chain's temporal structure matches the TaskFrame ordering
- Canonical valuation compatibility along the chain

This infrastructure does not exist in CanonicalEmbedding.lean. The 2-hour estimate for Phase 4 is likely 4-8 hours.

### Issue 4: The Until-Induction vs. bx_le Totality Choice

The plan implicitly assumes: (1) prove bx_le_total, then (2) use totality to close eventuality sorries. But there may be an alternative that avoids bx_le totality entirely: prove a WEAKER statement that is sufficient for the eventuality resolution. Specifically, rather than proving bx_le is total globally, prove: "given `phi U psi in w`, there exists a well-ordered chain C with w in C such that every bx_le-successor of C in C satisfies the guard." This is a chain-existence argument that uses Zorn's lemma, not bx_le totality.

This alternative was NOT explored in the plan. The Zorn-based approach was mentioned in the original sorry comment (`bx_until_eventuality_resolution` comment says "Viable path forward: redefine bx_le using Until-based witness ordering, or adopt a quasimodel/filtration approach"), but the plan doesn't pursue it.

## Recommended Mitigations

1. **For Phase 2**: Before attempting the proof, write out a detailed mathematical sketch (2-3 pages) of why temp_linearity + F_until_equiv should give bx_le totality. If no sketch emerges, escalate to a go/no-go decision. Do not attempt the Lean proof without a clear mathematical argument.

2. **For Phase 3**: Consult Burgess 1984 (Basic Tense Logic) or Goldblatt 1992 for the exact canonical model construction. The guard propagation argument in the literature uses Until-induction, not bx_le totality. Lean-formalize the literature proof directly rather than adapting the current approach.

3. **For Phase 4**: Add a scoped checkpoint to assess whether non-constant WorldHistory infrastructure exists. If not, estimate the infrastructure cost before committing to 2 hours.

4. **For Phase 5**: Reassess the "downstream" characterization. The sorry in Completeness.lean is not just a delegation -- it requires a concrete TaskModel construction that is independent new work.

5. **For Phase 6**: Expand the scope to enumerate all 10+ ConservativeExtension sorries and assess which are now fixable vs. which remain blocked.

6. **Update Frame.lean docstring**: Lines 585-622 contain stale analysis. Update before implementing Phase 2 to prevent confusion.

## Questions That Need Answering

1. **Mathematical**: Is there a proof from temp_linearity (in an MCS) to bx_le totality (between two MCSs)? What is the explicit proof sketch?

2. **Mathematical**: Does bx_le need to be well-founded for the guard propagation argument in `bx_until_eventuality_resolution`? If so, can well-foundedness be proved for BXPoints?

3. **Architectural**: Does TruthLemma.lean's `until_iff_mcs` need modification if the guard condition uses strict bx_lt (the `bx_le u v ∧ ¬bx_le v u` formulation)? Is this consistent with the standard reflexive Until semantics where the witness can be the same point?

4. **Lean-specific**: What is the type signature of `WorldHistory` and `TaskModel`? Does constructing a canonical TaskModel from BXPoints require any new Lean infrastructure not currently imported in `Completeness.lean`?

5. **Scope**: Should Phase 6 include the ConservativeExtension sorries? They are tagged "removed in BX" and many should be fixable now that the axioms are restored. Is the 0.5-hour estimate for Phase 6 realistic if these are included?

6. **Alternative**: Has the Zorn-based direct eventuality resolution (without bx_le totality) been seriously evaluated? This might close the 4 Frame.lean sorries without needing the contested bx_le_total proof.

## Confidence Levels

| Finding | Confidence |
|---------|-----------|
| Phase 2 strategy has a mathematical gap | 90% |
| Frame.lean docstring is stale and misleading | 95% |
| Guard propagation requires more than bx_le_total | 85% |
| Phase 4 has two distinct sub-problems | 80% |
| Phase 5 is not purely downstream | 75% |
| 6 sorries confirmed in BXCanonical, 10+ elsewhere | 95% |
| bx_le totality not directly provable from temp_linearity | 60% |

## Overall Assessment

The implementation plan is correct in its high-level direction: the axiom additions in Phase 1 are necessary and were correctly executed. The plan's primary weakness is in Phase 2, where the proposed proof strategies for bx_le totality are not mathematically justified at a level that would survive a serious Lean proof attempt. Phase 2 is the critical bottleneck: all of Phases 3, 4, and 5 depend on it.

**Minimum viable alternative**: If Phase 2 is blocked, consider a Zorn-based direct construction for the 4 Frame.lean eventuality sorries (using F_until_equiv to get witnesses without proving global bx_le totality). This would close 4 of 6 sorries while leaving the Completeness.lean sorry open as a known gap.
