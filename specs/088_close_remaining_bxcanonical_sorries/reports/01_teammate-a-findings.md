# Research Report: Task #88 -- Teammate A (Primary Approach)

**Task**: 88 -- Close 6 remaining BXCanonical sorries
**Date**: 2026-04-09
**Focus**: Standard representation theorem approach (NOT FMP shortcut)

## Key Findings

### Finding 1: The 6 Sorries Decompose Into Three Independent Problems

The 6 sorries are NOT a monolithic block. They decompose into three distinct mathematical problems with different difficulty levels:

| Problem | Files | Count | Core Issue |
|---------|-------|-------|------------|
| **A: Until/Since eventuality resolution** | Frame.lean (lines 632-704) | 4 | Guard condition requires bx_le linearity or equivalent |
| **B: imp Case B backward truth bridge** | CanonicalEmbedding.lean (line 418) | 1 | Constant histories collapse G/H, so backward bridge gives flatten(chi) not chi |
| **C: Full canonical model embedding** | Completeness.lean (line 160) | 1 | Depends on A+B; requires embedding BXPoints into a TaskModel |

**Problem A** is the hardest and blocks Problem C. Problem B is orthogonal to A but also blocks C.

### Finding 2: The Root Cause Is a Missing Axiom Equivalence

The BX axiom system is missing the derivability of **F(phi) <-> top U phi** (equivalently P(phi) <-> top S phi). This is the bridge between the F/P-based reasoning (used by g_content/h_content) and the Until/Since-based reasoning (used by the BX axioms for eventuality).

Under reflexive semantics, `F(phi) = neg(G(neg phi))` is semantically equivalent to `top U phi` because both mean "there exists s >= t with phi(s)". However:
- **Forward**: `top U phi -> F(phi)` IS derivable (BX10 instantiation, sorry-free)
- **Backward**: `F(phi) -> top U phi` is NOT derivable from BX1-BX10 alone

Evidence:
- `DovetailedChain.lean:572`: `sorry /- F_until_equiv removed in BX -/`
- `FiniteDeferral.lean:48`: `sorry /- F_until_equiv removed in BX -/`
- Task 85 research (teammate C): "F_until_equiv is NOT trivially derivable from BX1-BX10"
- Task 86 research report 08: "F(phi) <-> top U phi appears underivable without additional infrastructure"

**Why this matters**: The standard Burgess completeness proof converts F-eventualities to Until-eventualities, then uses Until's structural properties (BX5 self-accumulation, BX6 absorption, BX7 linearity) for eventuality resolution. Without the F-to-Until bridge, these structural properties are inaccessible for F-based eventualities.

### Finding 3: bx_le Linearity Is False and Unfixable

The canonical ordering `bx_le w v := g_content(w) subseteq v.formulas` is:
- Reflexive (from BX1: G(phi) -> phi)
- Transitive (from temp_4: G(phi) -> G(G(phi)))
- NOT linear (not a total preorder)

BX7 (linearity of Until) constrains Until-witness ordering WITHIN a single MCS. It does NOT force g_content-comparability between arbitrary MCS pairs. Task 86 report 08 proved this conclusively.

**Implications**: Any approach relying on bx_le being a linear order is blocked. This rules out the direct canonical model approach where the truth lemma for Until quantifies over ALL BXPoints in an interval.

### Finding 4: The Standard Burgess Construction Uses a Different Architecture

After extensive literature research, the standard completeness proof for Until/Since temporal logic (Burgess 1982, Xu 1988, Gabbay-Hodkinson-Reynolds 1994) does NOT use a single canonical model with a global truth lemma. Instead, it uses a **step-by-step construction** that builds a specific linear model:

1. **Start** with an MCS w_0 containing the formula to be falsified
2. **Construct** a chain of MCS points (indexed by integers or another linear order) using a Henkin-style extension
3. **At each step**, extend the current MCS to a successor MCS that resolves one pending eventuality (F-obligation or Until-obligation)
4. **Fair scheduling** ensures all eventualities are eventually resolved
5. **The truth lemma** is proved for THIS SPECIFIC CHAIN, not for all MCS simultaneously

The key difference from the current BXCanonical approach:
- BXCanonical tries to prove `until_iff_mcs` for ALL BXPoints -- this requires global linearity
- Burgess constructs a SPECIFIC linear chain and proves the truth lemma only for chain points

### Finding 5: The Chain Construction Needs F_until_equiv OR Its Equivalent

Even the chain-specific approach needs to convert F-eventualities to Until-eventualities for the eventuality resolution step. The Burgess approach assumes this conversion is available. Without `F(phi) -> top U phi`, the chain construction cannot ensure that F-obligations are resolved using Until's structural axioms.

However, there is a subtle alternative: the chain construction can handle F-eventualities DIRECTLY without converting them to Until. The active architecture (Bundle/SuccRelation.lean) already does this -- F-step deferral through the successor construction gives `F(theta) in chain(n)` implies `theta in chain(n+1) OR F(theta) in chain(n+1)`, without needing the Until bridge.

### Finding 6: The CanonicalEmbedding imp Case B Has a Known Fix

The sorry at CanonicalEmbedding.lean line 418 is about the backward truth bridge for G/H formulas nested inside implications. On constant histories, `truth_at G(alpha)` collapses to `truth_at alpha`, so the backward bridge gives `flatten(chi) in w` rather than `chi in w`.

The fix is a **two-point construction**: instead of using a constant history (all times map to the same BXPoint), construct a non-constant history where the G/H operators are non-trivial. Specifically:
- For `G(alpha)` inside `chi`, the history needs at least two distinct time-points with different BXPoints
- Use `bx_G_backward` to find a BXPoint v with alpha not in v, then construct a history visiting both w and v
- This requires solving Problem A first (the chain construction gives non-constant histories)

Alternatively, a pure proof-theoretic approach could work: show that for Until/Since-free formulas, `flatten(chi) in w` implies `chi in w` by structural induction. This uses the fact that G(alpha) -> alpha (BX1) and H(alpha) -> alpha (BX1'), so G and H in MCS are equivalent to their subformulas. However, the backward direction (chi in w -> flatten(chi) in w) already works; the gap is specifically in the forward direction when chi = imp(psi, chi') with temporal operators in chi'.

### Finding 7: Three Viable Approaches Remain

**Approach 1: Add F_until_equiv as an Axiom (Sound, Conservative)**

Add `F(phi) -> top U phi` (and its dual `P(phi) -> top S phi`) to the BX axiom system. This is:
- **Sound**: Already proven semantically valid (it is a tautology under reflexive Until semantics)
- **Conservative**: Does not change the set of valid formulas (since it IS valid)
- **Enabling**: Immediately unblocks the entire completeness proof chain

With F_until_equiv:
1. bx_le linearity becomes derivable (via BX7 + the bridge from F to Until)
2. Frame.lean's 4 sorries become provable (guard condition via linearity)
3. Non-constant histories become constructible (chain gives linear model)
4. CanonicalEmbedding sorry becomes solvable (non-constant history)
5. Completeness sorry follows from the full truth lemma

**Estimated effort**: 8-16 hours
**Confidence**: HIGH (the axiom is sound and the proof technique is well-established)

**Approach 2: Restructure the Proof to Use Chain-Specific Truth Lemma**

Replace the current `until_iff_mcs` (which quantifies over ALL BXPoints) with a chain-specific version that only quantifies over points on a constructed chain. The chain is linear by construction, avoiding the need for global bx_le linearity.

This requires:
1. Define a chain construction (Int -> BXPoint) with g_content successor properties
2. Prove chain-specific truth lemma for all formula cases
3. Build a TaskModel from the chain
4. Prove the completeness theorem using the chain model

The chain construction exists in two forms in the codebase:
- `DovetailedChain.lean` (deprecated, 6 sorries from same mismatch)
- `Bundle/SuccRelation.lean` + `SuccChainFMCS.lean` (active, partially working)

The active architecture handles F-resolution directly but Until-resolution is blocked. The fundamental issue: to prove Until's guard condition on the chain, we need to show that `phi U psi in chain(t)` with `psi not in chain(t)` implies `phi in chain(t)` AND the Until formula propagates forward. BX9 gives `phi or psi` at the current point. BX5 gives self-accumulation. But propagation through the chain requires either F_until_equiv or Until-induction.

**Estimated effort**: 20-40 hours (significant new infrastructure)
**Confidence**: MEDIUM (the approach is viable but the propagation issue may resurface)

**Approach 3: Derive F_until_equiv from BX Axioms (Optimal but Uncertain)**

If `F(phi) -> top U phi` can be derived from the existing BX axioms, all problems are solved without adding new axioms. The key question is whether the BX axiom set is powerful enough.

Analysis of the backward direction `F(psi) -> top U psi`:
- `F(psi)` means `neg(G(neg psi))` means G(neg psi) is not in the MCS
- We need `top U psi` in the MCS
- By BX8: `psi -> top U psi` (reflexive case: witness at current time)
- But `F(psi)` doesn't give us `psi` at the current time -- it gives `psi` at SOME future time

The gap: BX8 only gives `top U psi` when `psi` is true NOW. When `psi` is only known to be true at some future time, we need a different argument. This requires "importing" the future witness into an Until formula, which is exactly what Until-induction does.

Could BX5+BX6+BX7 together derive this? BX5 (self-accumulation) says `phi U psi -> (phi and (phi U psi)) U psi`. BX6 (absorption) prevents infinite deferral. BX7 (linearity) orders witnesses. But none of these START from `F(psi)` -- they all require an EXISTING Until formula.

The most promising angle: use BX4 (connectedness) `phi -> G(P(phi))` combined with BX7. From `F(psi)`, we know there exists some future point with psi. At that point, `psi -> top U psi` (BX8), so `top U psi` holds there. By BX4, `G(P(top U psi))` holds there. But propagating this backward to the current point requires linearity, which brings us back to the same problem.

**Estimated effort**: 4-8 hours for analysis, potentially impossible
**Confidence**: LOW (multiple prior attempts have failed)

## Recommended Approach

**Primary Recommendation: Approach 1 (Add F_until_equiv as an axiom)**

This is the approach that achieves the user's stated goal of "a standard representation theorem to characterize the logic" with the highest confidence and most reasonable effort.

**Justification**:

1. **It IS the standard approach**: Burgess (1982), Xu (1988), and all subsequent completeness proofs for Until/Since temporal logic assume the equivalence F(phi) <-> top U phi (it is typically included in the axiom set or is immediately derivable). The BX axiom system's omission of this equivalence appears to be an oversight during the BX refactoring, not a deliberate design choice.

2. **It is sound and conservative**: The equivalence is a semantic tautology under reflexive Until semantics. Adding it changes nothing about which formulas are valid -- it only enriches the proof theory.

3. **It unblocks ALL 6 sorries through a single intervention**: Rather than fighting 6 separate battles, one axiom addition cascades through the entire proof.

4. **It follows the user's directive**: The user explicitly asked for "a standard representation theorem to characterize the logic rather than a FMP path to completeness." F_until_equiv is the missing piece that makes the standard representation theorem work.

**Concrete Implementation Plan**:

**Step 1**: Add two new axiom constructors to `Axiom` in `Axioms.lean`:
```lean
| F_until_equiv (φ : Formula) :
    Axiom ((Formula.some_future φ).imp (Formula.untl (Formula.neg Formula.bot) φ))
| P_since_equiv (φ : Formula) :
    Axiom ((Formula.some_past φ).imp (Formula.snce (Formula.neg Formula.bot) φ))
```

**Step 2**: Prove soundness in `SoundnessLemmas.lean` (straightforward -- same as removed F_until_equiv_valid).

**Step 3**: Derive bx_le linearity from BX7 + F_until_equiv. The argument:
- From F(phi) and F(psi), get (top U phi) and (top U psi)
- Apply BX7 to get linearity of witnesses
- This gives linearity of the F-based ordering, which IS bx_le

**Step 4**: Close the 4 Frame.lean sorries using linearity.

**Step 5**: Build non-constant histories (chain construction) to close CanonicalEmbedding.

**Step 6**: Close Completeness.lean using the full truth lemma.

**Alternative if user rejects adding axioms**: Approach 2 (chain-specific truth lemma). This is harder but avoids changing the axiom set. It requires 20-40 hours of new infrastructure but is mathematically viable.

## Evidence/Examples

### Code Evidence for the F_until_equiv Gap

`DovetailedChain.lean:571-572`:
```lean
have h_ax : [] ⊢ (Formula.some_future psi).imp (Formula.untl (Formula.neg Formula.bot) psi) :=
    sorry /- F_until_equiv removed in BX -/
```

`FiniteDeferral.lean:47-48`:
```lean
have h_ax : [] ⊢ (Formula.some_future ψ).imp (Formula.untl (Formula.neg Formula.bot) ψ) :=
    sorry /- F_until_equiv removed in BX -/
```

### The Semantic Equivalence Proof

Under the truth_at semantics (Truth.lean:128-129):
```
truth_at Until phi psi = exists s >= t, psi(s) AND forall r, t <= r AND r < s -> phi(r)
truth_at F(psi) = not(forall s >= t, not psi(s)) = exists s >= t, psi(s)
```

Instantiating Until with phi = top = neg bot:
```
truth_at (top U psi) = exists s >= t, psi(s) AND forall r, t <= r AND r < s -> top(r)
```

Since `top(r)` is always true (neg bot is a tautology), the guard is vacuous, so:
```
truth_at (top U psi) = exists s >= t, psi(s) = truth_at F(psi)
```

### Literature Support

From the SEP supplement on Burgess-Xu axiomatization: Prior's temporal operators P and F are definable in terms of S and U as `P(phi) := top S phi` and `F(phi) := top U phi`. This definitional equivalence is ASSUMED in all standard completeness proofs for Until/Since logic.

The BX axiom system kept G/H/F/P as independent operators (defined via all_future/all_past/some_future/some_past) but removed the axiom connecting F to Until. This created a "semantic gap": the operators are semantically equivalent but proof-theoretically disconnected.

### Soundness of F_until_equiv

The soundness proof already exists conceptually in the codebase. The old axiom system had `F_until_equiv_valid` (referenced at Soundness.lean:722) which was removed when the BX refactoring dropped the axiom. Re-adding it and re-proving soundness is straightforward.

## Confidence Level

**HIGH** for Approach 1 (add F_until_equiv).

**Justification**:
- The mathematical technique is well-established (60+ years of literature)
- The axiom is sound (semantic tautology under reflexive semantics)
- The existing codebase has partial infrastructure that was disabled when F_until_equiv was removed
- The only risk is that additional unexpected obstacles surface during implementation, but 8 prior task rounds have thoroughly mapped the problem space
- Multiple independent research threads (tasks 83, 85, 86) converge on the same diagnosis

**MEDIUM** for Approach 2 (chain-specific truth lemma) -- viable but substantially more work.

**LOW** for Approach 3 (derive F_until_equiv from BX) -- likely impossible.

## Appendix

### Sorry Site Inventory

| # | File | Line | Type | Signature |
|---|------|------|------|-----------|
| 1 | Frame.lean | 653 | Forward Until eventuality | `bx_until_eventuality_resolution` |
| 2 | Frame.lean | 675 | Backward Until | `bx_until_backward` |
| 3 | Frame.lean | 690 | Forward Since eventuality | `bx_since_eventuality_resolution` |
| 4 | Frame.lean | 704 | Backward Since | `bx_since_backward` |
| 5 | CanonicalEmbedding.lean | 418 | imp Case B | `usf_completeness` |
| 6 | Completeness.lean | 160 | Full completeness | `bx_completeness` |

### Search Queries Used

- Grep for `sorry` across BXCanonical/
- Grep for `F_until_equiv`, `temp_linearity`, `DovetailedChain`
- Web search for Burgess 1984, Xu 1988, Reynolds 2003, Venema 1993 completeness proofs
- Web search for canonical model Until eventuality resolution techniques
- SEP supplement on Burgess-Xu axiom system
- Codebase analysis of Truth.lean semantics, Axioms.lean, TemporalDerived.lean

### Key Files Analyzed

- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` -- 4 sorry sites
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean` -- 1 sorry site
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- 1 sorry site
- `Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean` -- truth lemma architecture
- `Theories/Bimodal/Metalogic/BXCanonical/BXCanonical.lean` -- module overview
- `Theories/Bimodal/Syntax/Formula.lean` -- formula structure
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- BX axiom system
- `Theories/Bimodal/Semantics/Truth.lean` -- semantic definitions
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- derived theorems
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- deprecated chain (same sorry)
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean` -- deprecated (same sorry)
- `specs/086_close_bxcanonical_completeness_sorries/reports/08_bxle-linearity-research.md` -- task 86 analysis
- `specs/086_close_bxcanonical_completeness_sorries/summaries/08_chain-eventuality-summary.md` -- task 86 summary

### References

- Burgess, J.P. (1982). "Axioms for tense logic. I. Since and until." Notre Dame J. Formal Logic 23(4).
- Xu, M. (1988). Simplification of Burgess's axiomatization for reflexive linear orders.
- Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic." JSL 58(3).
- Gabbay, D.M., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects." OUP.
- Goldblatt, R. (1992). "Logics of Time and Computation." CSLI.
- Stanford Encyclopedia of Philosophy, "Temporal Logic" supplement on Burgess-Xu axiom system.
