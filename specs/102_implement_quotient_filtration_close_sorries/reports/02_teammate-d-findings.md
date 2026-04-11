# Teammate D Findings: Strategic Horizons for Until/Since Sorry Closure

- **Task**: 102 - implement_quotient_filtration_close_sorries
- **Role**: Teammate D (Horizons)
- **Date**: 2026-04-11

## Key Findings

### 1. Project Roadmap Context

The ROAD_MAP.md (rewritten by task 91) shows the 4 Frame.lean Until/Since sorries are the single largest blocker to the BX completeness theorem. The priority chain is:

1. **Tasks 90/92 (Until/Since sorries)** -- this is task 102's target
2. **Task 93 (Box modal-equivalence + TaskModel embedding)** -- 2 remaining sorries
3. **Task 95 (#print axioms audit)** -- final verification
4. **Task 94 (archive legacy strict-semantics code)** -- drops ~210 legacy sorries

Closing the 4 Frame.lean sorries would reduce the active-path sorry count from 6 to 2, unlocking task 93. The 6 Realization.lean sorries (which delegate to Frame.lean) close automatically. This represents the critical path to the representation theorem goal: "TM is complete with respect to TaskFrames over totally ordered abelian groups."

### 2. Symmetry Analysis: Until vs Since, Forward vs Backward

The 4 sorries are NOT equally hard. There is a precise 2x2 structure:

| | Forward (eventuality resolution) | Backward (derive U/S from guard) |
|---|---|---|
| **Until** | `bx_until_eventuality_resolution` (Frame:607) | `bx_until_backward` (Frame:618) |
| **Since** | `bx_since_eventuality_resolution` (Frame:630) | `bx_since_backward` (Frame:641) |

**Until/Since symmetry**: Since is a clean temporal mirror of Until. Every BX axiom has a primed mirror (BX2/BX2', BX5/BX5', etc.). The `bx_le` ordering reverses direction: Until uses `bx_le w v` (forward), Since uses `bx_le v w` (backward). The h_content/g_content duality (`h_content_subset_implies_g_content_reverse`) handles the direction swap. Realization.lean confirms this: the Since versions are structurally identical to the Until versions with directions reversed.

**Conclusion**: Solving Until automatically provides the Since solution via mechanical mirroring. The real problem space is 2 sorries, not 4.

**Forward vs Backward asymmetry**: The forward direction (eventuality resolution) is harder than the backward direction:
- Forward must CONSTRUCT a witness v and PROVE the guard for ALL intermediate u -- an existential + universal quantifier combination
- Backward must DERIVE a contradiction from assuming the formula is absent -- a contradiction argument using the enriched seed

However, both share the same root blocker: the guard condition requires `phi in u` for arbitrary intermediate BXPoints, and `bx_le` only propagates G-content, not arbitrary subformulas.

### 3. The Root Cause is Architectural, Not Mathematical

The fundamental insight from task 101's research (confirmed by my analysis of Frame.lean and Realization.lean) is:

**The `bx_le := g_content inclusion` ordering is non-standard and is the root cause of all blockers.**

Standard completeness proofs in the literature (Burgess 1982/84, Xu 1988, Goldblatt 1992, Venema 1993, Reynolds 1994) do NOT use g_content inclusion as the canonical temporal ordering. The standard approaches either:
- (a) Build linearity into the ordering from the start (Burgess's original construction)
- (b) Work in a finite quotient model where linearity is ensured by construction (Goldblatt's filtration)
- (c) Use step-by-step/constructive completeness methods that avoid needing a global ordering (de Jongh, Veltman, Verbrugge)

The codebase chose `bx_le := g_content inclusion` because it provides clean reflexivity (BX1) and transitivity (temp_4). But this ordering is:
- Reflexive (from BX1: G(phi) -> phi)
- Transitive (from temp_4: G(phi) -> G(G(phi)))
- **NOT total**: two MCSs can have incomparable g_content
- **NOT antisymmetric in a useful way**: `bx_le w v` and `bx_le v w` does not imply `w = v`

This means the Frame.lean sorry signatures may be UNPROVABLE as stated. The guard `not bx_le v u` (expressing "u is strictly below v") is strictly stronger than what the semantic truth condition needs. In a linear order, `not bx_le v u` with `bx_le u v` means u < v. In the `bx_le` preorder, there can exist u with `bx_le u v`, `not bx_le v u`, but with u and v agreeing on all Sigma-formulas -- a scenario impossible in a linear order.

### 4. Literature Approaches

The temporal logic completeness literature offers several distinct proof strategies for Until:

**Strategy A: Burgess's Original (1982/84) -- Direct chain construction**
- Builds MCSs along a chain that is linear by construction
- Each step discharges at least one "defect" (an Until formula whose goal is absent)
- The guard is automatic because the chain IS the model's temporal ordering
- **Applicability**: Would require replacing bx_le with a chain-constructed ordering. High disruption but high certainty.

**Strategy B: Goldblatt's Filtration (1992) -- Finite quotient model**
- Works with equivalence classes of MCSs modulo a finite formula set Sigma
- The quotient ordering can be made linear on realized equivalence classes
- Truth lemma proved for the finite quotient, then lifted back
- **Applicability**: The approach explored by tasks 101/102. Task 101 showed it is viable but requires modified Frame.lean signatures (sigma_strict guard instead of not-bx_le guard).

**Strategy C: Constructive Completeness (de Jongh, Veltman, Verbrugge)**
- Builds the model point by point, ensuring consistency at each step
- Does not assume a pre-existing canonical model
- Linearity is ensured by the construction process
- **Applicability**: Would require a fundamentally different proof architecture. Not compatible with the existing BXCanonical module structure.

**Strategy D: Until-Induction Axiom (derived rule)**
- Derive the rule `(psi or (phi and X(theta)) -> theta) -> (phi U psi -> theta)` from BX5+BX6+BX7+BX10
- This directly closes the guard proofs without needing ordering totality
- **Applicability**: The X operator is semantically degenerate under reflexive semantics (X(phi) = phi). The Until-induction axiom in its standard form requires a meaningful "next step" operator. Under reflexive semantics, it may collapse.

### 5. Creative Approaches

**Approach 1: Zorn's Lemma for Linear Extension**

Could we use Zorn's lemma (or the well-ordering theorem) to extend `bx_le` restricted to Sigma to a total order on the relevant subset of BXPoints?

The idea: Take the partial order induced by sigma_le on the set of BXPoints between w and v. Apply Szpilrajn's extension theorem (every partial order has a linear extension) to get a total order.

**Problem**: A linear extension of sigma_le exists, but we have no control over WHERE phi-holding points fall in the extension. The guard requires phi at ALL intermediate points, not just some linear arrangement of them. A random linear extension could place a phi-failing point in the interval.

**Verdict**: Not viable. The linear extension is non-constructive and provides no formula-membership guarantees.

**Approach 2: Well-Ordering of Finite BXPoint Quotient**

The set of Sigma-equivalence classes is finite (at most 2^|Sigma|). Could we well-order them and use the well-ordering to define a linear temporal ordering?

**Problem**: Same as Approach 1 -- a well-ordering exists but has no semantic content. We need the ordering to RESPECT the Until-witness structure.

**Verdict**: Not viable for the same reason.

**Approach 3: Custom "Reachable via Defect-Discharge" Relation**

Define: `w -->_dd v` iff v is obtained from w by one defect-discharge step (enriched Lindenbaum extension that resolves at least one Until defect).

Then define: `w <=_dd v` iff there exists a defect-discharge chain from w to v.

This relation IS a well-founded partial order (defect count strictly decreases). It is also compatible with bx_le (each step maintains bx_le).

**Problem**: This ordering is only defined on chain members, not on arbitrary intermediate BXPoints. The guard requires phi for ALL u with bx_le w u, bx_le u v, not just chain members.

**Verdict**: Useful as the core of the construction, but insufficient alone. The guard extension lemma (extending from chain members to all intermediate points) is still needed.

**Approach 4: Skip Intermediate Points Entirely**

Instead of proving the guard for ALL intermediate u, could we construct the witness v such that there ARE no strictly intermediate points?

In a total order, this would mean choosing v to be the "next" point after w. But in the bx_le preorder, even "adjacent" BXPoints can have intermediate points inserted.

More precisely: could we construct v such that for every u with bx_le w u and bx_le u v, we also have bx_le v u? This would make the guard vacuously true.

**Problem**: This requires v to be the MINIMUM element above w -- but bx_le has no minimum elements (it's a dense preorder in general).

**Verdict**: Not viable in the current ordering.

**Approach 5: Replace bx_le with a Chain-Based Linear Ordering**

Define the canonical temporal ordering as:
```
w <= v  :=  w appears before v in a defect-discharge chain from some root point
```

This is linear by construction. The guard becomes trivial because ALL points in the model are chain members.

**Tradeoffs**:
- Requires completely rewriting bx_le_refl, bx_le_trans, bx_G_forward, bx_G_backward, bx_forward_witness, bx_backward_witness, bx_H_forward, bx_H_backward, box_preserved_along_bx_le, bx_modal_equiv_of_bx_le
- The new ordering would still need reflexivity (immediate from chain structure) and transitivity (from chain ordering)
- G-forward/backward would need to be re-proved using the chain structure
- Lines affected: ~250 in Frame.lean + ~100 in TruthLemma.lean + ~150 in Realization.lean

**Verdict**: High-certainty but high-cost approach (~500 lines of changes, ~20+ hours).

**Approach 6: Modify Frame.lean Signatures + Guard Extension (Current Plan)**

This is the approach adopted by task 102's plan. Key steps:
1. Replace `not bx_le v u` with `sigma_strict Sigma u v` in the guard
2. Prove the guard extension lemma using enrichedClosure properties
3. Update TruthLemma.lean and Realization.lean call sites

**The critical open question**: Does the enrichedClosure provide enough G/H-enrichment to determine phi membership at arbitrary intermediate BXPoints? The answer depends on whether:

```
g_content(w) intersect Sigma  subset  u.formulas
h_content(v) intersect Sigma  subset  u.formulas
sigma_strict Sigma u v
```

together imply `phi in u.formulas`. Task 101's analysis was inconclusive on this point.

## Strategic Recommendations (Ranked by Viability)

### Recommendation 1: Continue with Approach 6 (Modified Signatures + Guard Extension) [MEDIUM CONFIDENCE]

This is the current plan's approach. Phase 1 (SigmaOrdering) and Phase 2 (DefectChain) are already partially implemented and building clean. The critical Phase 3 (Guard Extension) is untested.

**Advantages**: Minimal disruption to existing infrastructure. Only Frame.lean signatures and their call sites change. The existing bx_le infrastructure (reflexivity, transitivity, forward/backward witnesses) is preserved.

**Risks**: The guard extension lemma may be unprovable. The enrichedClosure's G/H-enrichment is designed for locus control (determining WHICH Hintikka points are realizable), not for determining formula membership at arbitrary intermediate BXPoints. These are different mathematical problems.

**Fallback**: If Phase 3 fails, pivot to Recommendation 2.

### Recommendation 2: Replace bx_le Entirely (Approach 5) [HIGH CONFIDENCE, HIGH COST]

Define the canonical ordering via a concrete defect-discharge chain construction. All points in the model are chain members, making the guard trivial.

**Advantages**: High mathematical certainty. The construction is standard in the literature. No need for the guard extension lemma at all.

**Risks**: Extensive rewriting of Frame.lean infrastructure (~500 lines). Risk of introducing new bugs. Requires re-proving all existing infrastructure lemmas.

**Estimated effort**: 20+ hours beyond current progress. But this is a ONE-TIME cost that eliminates the highest-risk phase entirely.

### Recommendation 3: Derive Until-Induction as a Theorem [LOW-MEDIUM CONFIDENCE]

Attempt to derive the Until-induction rule from BX5+BX6+BX7+BX10 within the existing BX axiom system. If successful, this directly closes all 4 Frame.lean sorries without any signature changes.

**Advantages**: Zero infrastructure changes. The existing Frame.lean signatures are correct IF Until-induction is available.

**Risks**: The Until-induction rule may not be derivable under reflexive semantics with half-open guards. The X operator (used in the standard induction statement) is semantically degenerate (X(phi) = phi). The induction would need to be reformulated without X.

**Investigation path**: Try to prove `(phi U psi) -> G(phi) or exists v >= w, psi in v and phi in v` as a derived theorem from BX5+BX6+BX9+BX10+BX12. If this holds, it provides a "first witness" property that makes the guard trivial.

### Recommendation 4: Hybrid Approach [MEDIUM CONFIDENCE, MEDIUM COST]

Build an independent finite linear model ALONGSIDE the canonical model:
1. For each Until formula `phi U psi` at w, construct a finite defect-discharge chain
2. Prove the truth lemma for phi U psi WITHIN this finite chain (trivial: chain is linear by construction)
3. The chain provides the witness v and the guard proof
4. Frame.lean sorry is closed by: "the chain's endpoint v satisfies bx_le w v (by construction), psi in v (by chain termination), and the guard holds because every intermediate u's Sigma-signature matches some chain member (the key lemma)"

This is essentially Approach 6 but with a clearer separation: the chain provides the EXISTENCE of the witness and guard, while the guard extension lemma ONLY needs to show Sigma-signature matching (not full formula membership).

**Advantage over pure Approach 6**: The problem reduces to showing that sigma_strict intermediate points must have Sigma-signatures that appear on the chain. This is a combinatorial/finite-set argument, possibly simpler than directly proving phi membership.

## Cost-Benefit Analysis

| Approach | New Lean Code | Risk of Further Blockers | Impact on Existing Proofs | Alignment with ROAD_MAP |
|---|---|---|---|---|
| **6 (Current Plan)** | ~400 lines new, ~100 lines modified | MEDIUM (guard extension is unproven) | LOW (only signatures change) | HIGH (directly addresses sorry items) |
| **5 (Replace bx_le)** | ~200 lines new, ~500 lines rewritten | LOW (standard technique) | HIGH (rewrites core infrastructure) | HIGH (but delays by 20h) |
| **3 (Until-Induction)** | ~100 lines new | HIGH (may not be derivable) | ZERO | HIGHEST (if it works) |
| **Hybrid (4)** | ~300 lines new, ~100 lines modified | MEDIUM-LOW | LOW-MEDIUM | HIGH |

## Confidence Level

**MEDIUM overall**. The analysis confirms that the fundamental mathematical problem (bx_le non-totality) is well-understood and has known solutions in the literature. The uncertainty is in which specific implementation path will work within the existing codebase architecture with minimal disruption.

The highest-confidence path (Approach 5: replace bx_le) has the highest cost. The current plan (Approach 6) is a reasonable bet but has a meaningful risk of the guard extension lemma failing. Recommendation 3 (Until-induction) should be investigated first as a low-cost, high-reward option -- even a few hours of investigation could either close all sorries immediately or rule out this path definitively.

**Suggested investigation order**:
1. Spend 2-3 hours investigating Until-induction (Recommendation 3)
2. If that fails, continue with the current plan (Recommendation 1)
3. If Phase 3 (guard extension) fails, pivot to bx_le replacement (Recommendation 2)

## Cross-Reference: Remaining Goals Beyond These 10 Sorries

After the 4 Frame.lean + 6 Realization.lean sorries:
- **2 remaining active-path sorries**: Box modal-equivalence (Frame.lean:440) and TaskModel embedding (Completeness.lean:154), both assigned to task 93
- **1 dense completeness sorry** (task 68, independent track)
- **2 FMP truth preservation sorries** (task 82, decidability track)
- **1 soundness sorry** (density frame condition)
- **~14 pedagogical sorries** (examples, intentional)
- **~210 legacy sorries** (to be archived by task 94)

The TaskModel embedding sorry (Completeness.lean:154) is particularly interesting strategically: if the approach to closing the Frame.lean sorries involves building a finite linear model, that SAME construction could potentially close the TaskModel embedding sorry as well, since the finite model IS a TaskModel. This would reduce the remaining active-path sorries from 2 to 1 (only the Box modal-equivalence would remain).
