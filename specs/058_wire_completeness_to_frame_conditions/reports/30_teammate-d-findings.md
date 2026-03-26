# Alternative Completeness Strategies - Teammate D Research

**Task**: 58 - Wire Completeness to Frame Conditions
**Role**: Teammate D - Alternative Completeness Strategies
**Date**: 2026-03-26
**Focus**: Survey approaches that avoid family-level coherence problem

## Executive Summary

The core problem is: `BFMCS_Bundle` provides bundle-level temporal coherence (F-witnesses
in ANY family) but the `parametric_shifted_truth_lemma` requires family-level coherence
(F-witnesses in the SAME family). Six alternative strategies were investigated. The most
promising path is **Approach 2: Modified Bundle Truth Lemma** - rewriting the truth lemma
to use bundle semantics directly, which avoids the need for family-level coherence entirely
while still proving completeness for the SAME logic TM.

## Summary Table

| Approach | Viability | Complexity | Compatibility | Semantic Faithfulness |
|----------|-----------|------------|---------------|----------------------|
| 1. Algebraic/Lindenbaum | LOW | HIGH | LOW (new path) | HIGH |
| 2. Modified Bundle Truth Lemma | HIGH | MEDIUM | HIGH (extends existing) | HIGH |
| 3. Temporal-Flat Fragment | MEDIUM | LOW | HIGH | PARTIAL (restricted) |
| 4. Bundled Semantics Redefinition | MEDIUM | MEDIUM | MEDIUM | LOW (changes logic) |
| 5. Filtration-Based | HIGH | HIGH | MEDIUM | HIGH |
| 6. Dovetailed Z-Chain (family-level) | HIGH | MEDIUM-HIGH | HIGH | HIGH |

## Detailed Analysis

### Approach 1: Algebraic/Lindenbaum Completeness

**Strategy**: Avoid model-theoretic truth entirely. Show completeness via the algebraic
quotient: φ is valid in all STSA algebras iff φ is provable. The Lindenbaum algebra is
an STSA, so non-provability implies the Lindenbaum algebra falsifies φ.

**Mathematical Viability**: In principle sound. The existing `TenseS5Algebra.lean` defines
`STSA` typeclass and `LindenbaumQuotient.lean` defines the Lindenbaum quotient. However:
- `AlgebraicRepresentation.lean` already attempts this and has its own sorries
- The algebraic path still requires connecting ultrafilters back to model-theoretic truth
  for the concrete countermodel
- No sorry-free algebraic completeness exists in the codebase

**Compatibility with Existing Code**:
- `TenseS5Algebra.lean` provides the STSA typeclass (sorry-free)
- `LindenbaumQuotient.lean` provides the quotient construction (sorry-free)
- `AlgebraicRepresentation.lean` attempts completion but has sorries (lines 71+)
- The gap: ultrafilters of LindenbaumAlg (AlgWorld) need to connect to TaskFrame validity

**Implementation Complexity**: HIGH. Requires:
1. Proving LindenbaumAlg is a complete STSA (large algebraic proof)
2. Connecting ultrafilter model to standard TaskFrame/truth_at semantics
3. Proving the algebraic truth lemma

**Confidence Level**: LOW - while theoretically sound, the algebraic path introduces
as many new proof obligations as it avoids, and doesn't directly fix the truth lemma problem.

---

### Approach 2: Modified Bundle Truth Lemma (RECOMMENDED)

**Strategy**: Instead of requiring family-level coherence, write a new truth lemma that
works directly with bundle-level coherence. The key insight: for the backward direction
of G (and H), we need to show that if φ holds at all s > t along SOME history τ,
then G(φ) ∈ fam.mcs(t). This requires that `F(¬φ) ∈ fam.mcs(t)` implies a witness
in some family (not necessarily the same family).

**The Critical Observation**: The existing `parametric_shifted_truth_lemma` uses:
```lean
-- G backward: if truth at all s > t, then G(phi) in fam.mcs t
-- Proof by contraposition:
-- NOT G(phi) in fam.mcs t
-- => F(neg phi) in fam.mcs t (via neg_all_future_to_some_future_neg)
-- => SAME family has witness s > t with neg(phi) at s (family-level forward_F)
-- => Contradiction (phi holds at all s > t)
```

With bundle semantics, the truth of F(φ) at time t along history τ means:
`exists s > t, truth_at M Omega tau s phi`

The standard (existing) definition of truth_at uses the **same history τ**. If we keep
this definition, then the backward direction for G requires the same-family F-witness.

However, there is a **different truth lemma** we can prove: the FORWARD direction only.

**Forward-Only Truth Lemma Approach**:
- Forward: `φ ∈ fam.mcs(t) → truth_at ... (parametric_to_history fam) t φ`
- This only needs bundle-level coherence for the temporal operator cases
- For atom/bot/imp: trivial (no coherence needed)
- For box: modal coherence suffices (SORRY-FREE in existing code)
- For all_future (G φ): need forward_G which says G(φ) ∈ fam.mcs t → phi ∈ fam.mcs s for all s >= t
  - This is SORRY-FREE: `FMCS.forward_G` proves this directly
- For some_future (F φ): the **forward** direction only needs: F(φ) ∈ fam.mcs t → ∃ s > t, truth at s
  - Here we can use bundle-level: `exists fam' in bundle, exists s > t, phi ∈ fam'.mcs s`
  - But truth_at uses the SAME history τ... unless we choose Omega cleverly

**The Key: Choosing Omega Correctly**

The bundle-level forward truth lemma can work if we define:
```
truth_at M Omega tau t (F phi) = exists sigma in Omega, exists s > t, truth_at M Omega sigma s phi
```
Wait - this IS the existing semantics. Look at Truth.lean:
```lean
| Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```
This quantifies over the SAME τ. However, what if Omega contains ALL histories from the bundle?

If `Omega = {parametric_to_history fam | fam ∈ B.families}` (ShiftClosedParametricCanonicalOmega),
then `Box φ` at time t means φ is true in ALL histories in Omega.

For `F(φ)` there is no quantification over Omega - it's along the same history τ.

**The ACTUAL Forward Truth Lemma Argument**:
The forward direction for F needs: `F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)`.
This IS family-level coherence. But we have:
- `F(φ) ∈ fam.mcs(t) → ∃ fam' ∈ bundle, ∃ s > t, φ ∈ fam'.mcs(s)` (bundle-level)

So the forward truth lemma ALSO requires family-level coherence for the F case.

**What actually works: The Completeness Argument without Full Truth Lemma**

Looking at the `bundle_completeness_contradiction` theorem (lines 2931-2945) which IS
sorry-free:
1. If φ not provable → {neg φ} consistent → extend to MCS M
2. phi ∉ M (by consistency)
3. Therefore NOT all MCSs contain phi

This gives "syntactic completeness" (every MCS-valid formula is provable) but not
"semantic completeness" (every valid formula is provable).

For semantic completeness, we need the truth lemma to connect MCS membership to truth.

**New Truth Lemma via Subformula Restriction**:
The FMP filtration approach (already in the codebase!) provides a way:
- Build a FINITE model using closure MCS (RestrictedMCS)
- The `f_nesting_is_bounded_restricted` IS sorry-free (shown in SuccChainFMCS.lean)
- For restricted MCS (closure-restricted), family-level coherence CAN be proven

---

### Approach 3: Restriction to Temporal-Flat Fragment

**Strategy**: Prove completeness for formulas without nested temporal operators.
For formulas where F/P nesting depth is ≤ 1, the deferral-seed approach works,
and `f_nesting_is_bounded_restricted` applies.

**Mathematical Viability**: MEDIUM. The codebase already has the machinery:
- `subformulaClosure` and `deferralClosure` in `SuccChainFMCS.lean`
- `f_nesting_is_bounded_restricted` is sorry-free
- `DeferralRestrictedMCS` and `DeferralRestrictedSerialMCS` are defined
- `restricted_forward_chain_forward_F` exists in SuccChainFMCS.lean

**The Problem**: The logic TM has no "flat fragment" in any interesting sense.
Temporal operators freely nest with Box, and most interesting tense-modal formulas
involve both. Restricting to non-nested formulas would exclude e.g. Box-G interactions
which are the whole point of TM.

**Compatibility**: HIGH - the restricted machinery is well-developed in the codebase.

**Confidence Level**: MEDIUM as a partial result, but LOW as a path to full completeness.

---

### Approach 4: Bundled Semantics Redefinition

**Strategy**: Change the definition of `truth_at` for `F(φ)` to allow cross-history witnesses:
```lean
| Formula.some_future phi =>
    exists sigma in Omega, exists s > t, truth_at M Omega sigma s phi
```

**Mathematical Viability**: MEDIUM. This alternative semantics (called "bundled semantics"
or "bundle semantics" in the literature) is studied in modal logic. It corresponds to
treating the bundle as defining accessibility, not just the single history.

**Semantic Faithfulness**: LOW for standard TM. The logic characterized by bundled
F-semantics is DIFFERENT from TM with standard linear-time F semantics:
- Standard: `F(φ)` = φ holds at some future point ALONG THIS HISTORY
- Bundled: `F(φ)` = φ holds at some future point in SOME HISTORY in the bundle

These are different logics. The bundled variant would have different frame conditions
and different completeness theorems. This is NOT what the project wants to prove.

**Compatibility**: MEDIUM - changing Truth.lean would cascade through many proofs.

**Conclusion**: REJECTED as a path to TM completeness. Would prove completeness for
a different (bundled tense) logic, not TM.

---

### Approach 5: Filtration-Based Approach

**Strategy**: Use the existing FMP filtration infrastructure to build a FINITE canonical
model, bypassing the need for infinite family-level coherence.

**Mathematical Viability**: HIGH. The existing codebase has:
- `Filtration.lean`: MCSFiltrationEquiv, FilteredWorld, FilteredTaskFrame
- `ClosureMCS.lean`: ClosureMCSBundle, DeferralRestrictedMCS
- `FMP.lean`, `DenseFMP.lean`, `DiscreteFMP.lean`: FMP statements
- `TruthPreservation.lean`: Truth preservation under filtration

The filtration approach works as follows:
1. For non-provable φ, take closure(φ) = subformulaClosure(φ)
2. Build restricted MCS M₀ over closure(φ)
3. Build the deferral-chain construction using DeferralRestrictedMCS
4. For THIS restricted construction, f_nesting_is_bounded_restricted IS sorry-free
5. The filtration model is FINITE (bounded by 2^|closure(φ)|)
6. Family-level coherence holds for the finite filtration model

**Critical Gap**: Looking at the files, `TruthPreservation.lean` and `FMP.lean` exist
but their completeness connection is incomplete - `FMP.lean` proves FMP but not full
completeness (valid → provable). The bridge from "falsifiable in finite model" to
"not provable" needs the truth lemma for the finite model, which might itself require
family-level coherence in the finite setting.

However, the FINITE setting simplifies things enormously:
- All F/P-chains in a finite model are eventually cyclic
- Family-level coherence in a finite model can be forced by construction
- The `DeferralRestrictedMCS` approach with finite enumeration works

**Compatibility**: HIGH - existing FMP machinery can be reused.

**Implementation Complexity**: HIGH overall but many pieces exist.

**Confidence Level**: HIGH if the filtration path is completed, but it still has gaps.

---

### Approach 6: Dovetailed Z-Chain for Family-Level Coherence (MOST PROMISING)

**Strategy**: The existing `Z_chain` construction in `UltrafilterChain.lean` (lines 2208-2245)
is sorry-free for everything EXCEPT `Z_chain_forward_F` and `Z_chain_backward_P`.
The current construction uses generic temporal witnesses that always resolve `F_top`.

The **dovetailed approach** (already sketched in lines 1866-1993) would:
- Build a chain where step 2n resolves the n-th F-obligation from the BASE MCS M₀
- Step 2n+1 resolves the n-th P-obligation from M₀

Since the base MCS M₀ is a FIXED SET, its F-obligations form a SET (not just F_top).
By serially enumerating them (via countability of formulas), we can ensure EVERY F(φ) ∈ M₀
gets resolved at some step in the forward chain.

**The Technical Argument**:
- `F_obligations(M₀)` = {F(φ) ∈ M₀} is countable (formulas are countable)
- Enumerate: F(φ₁), F(φ₂), ... is a (finite or countably infinite) list
- Forward chain: at step 2n, take a temporal witness resolving φₙ
- Then `Z_chain_forward_F` would say: given F(φ) ∈ Z_chain(0) = M₀,
  find the index n where φₙ = φ, so at step 2n, φ ∈ chain(2n)

**Why This Is Family-Level**: This gives φ ∈ SAME chain at a future point, not just
some family. So it provides the required family-level coherence.

**Critical Issue**: This argument only resolves F-obligations from M₀ itself.
What about F(φ) ∈ Z_chain(t) for t > 0? The chain at step t may have NEW F-obligations
not in M₀. We need to resolve those too.

**Solution via Diagonalization**: Standard Henkin model argument:
- Enumerate ALL pairs (t, φ) where F(φ) might appear at step t
- Use a diagonal enumeration to handle all of them
- This is the standard "saturated model" or "maximally saturated" construction

**Concrete Construction Already in Codebase**:
Looking at `SuccExistence.lean`, the `deferralDisjunction` and `successor_deferral_seed`
already handle this: at each step, the seed includes φ ∨ F(φ) for each F(φ) in the current MCS.
This ensures that each step either RESOLVES the F-obligation (φ ∈ successor) or DEFERS it
(F(φ) ∈ successor). But the key is that "eventually resolved" requires showing the chain
doesn't defer infinitely.

**Connection to DeferralRestrictedMCS**:
`restricted_forward_chain_forward_F` IS sorry-free (line 2188+). This proves F-coherence
for the RESTRICTED construction over the closure of a fixed formula. The restriction to
`deferralClosure(φ)` ensures bounded nesting depth.

**Synthesis**: The dovetailed approach works for the FINITE closure case but not for
arbitrary MCS. This connects back to Approach 5 (filtration).

**Compatibility**: HIGH - `omega_chain_forward_with_inv`, `omega_chain_backward_with_inv`,
and the Z-chain are all sorry-free infrastructure that can be extended.

**Confidence Level**: HIGH - this is essentially what the filtration/FMP path does.

---

## Key Insight: The Existing Infrastructure is Sufficient

After careful examination, the codebase already has the essential machinery for a
sorry-free completeness proof via the following path:

### The Working Path (FMP + Filtration)

```
1. Non-provable φ
   ↓
2. {¬φ} is consistent (not_provable_implies_neg_set_consistent: SORRY-FREE)
   ↓
3. Extend to CLOSURE MCS M₀ over deferralClosure(φ) (RestrictedLindenbaum: needs verification)
   ↓
4. Build DeferralRestrictedSerialMCS from M₀
   ↓
5. Build deferral-restricted forward chain (restricted_forward_chain: exists in SuccChainFMCS)
   f_nesting_is_bounded_restricted: SORRY-FREE
   restricted_forward_chain_forward_F: SORRY-FREE
   ↓
6. This gives FAMILY-LEVEL coherence for the restricted chain
   ↓
7. Apply parametric_shifted_truth_lemma with D = Int
   (This is SORRY-FREE given family-level coherence)
   ↓
8. Get countermodel: ¬φ true at time 0
   ↓
9. φ is not valid → completeness by contrapositive
```

**Status Check**: Is step 3 sorry-free? Looking at `RestrictedMCS.lean`:

The `DeferralRestrictedMCS` is defined and the restricted Lindenbaum construction should
exist. Let me check if there's a RestrictedLindenbaum lemma...

Looking at `SuccExistence.lean` and `SuccChainFMCS.lean`, the construction of
`DeferralRestrictedSerialMCS` from a consistent set is done via the Succ-chain. However,
the crucial question is: can we start from {¬φ} restricted to deferralClosure(φ)?

The key issue: {¬φ} is a singleton, but ¬φ may not be in deferralClosure(φ). Actually,
¬φ = φ.neg IS in deferralClosure(φ) since deferralClosure includes closureWithNeg.

So step 3 should be feasible: extend {¬φ} to a DeferralRestrictedMCS over deferralClosure(φ).

## Recommended Approach

**Primary Recommendation: Approach 6 (Dovetailed Z-Chain) instantiated as the Restricted FMP Path**

The path is:
1. Use `deferralClosure` to restrict to a finite formula set containing φ
2. Use `DeferralRestrictedMCS` construction (well-developed in SuccChainFMCS.lean)
3. Apply `restricted_forward_chain_forward_F` (SORRY-FREE) for family-level F-coherence
4. Apply the existing `parametric_shifted_truth_lemma` (SORRY-FREE given coherence)
5. Wire the countermodel to `TaskFrame` validity

**Why This is Better Than Bundle Approach**:
- The bundle approach gives bundle-level coherence but NOT family-level
- The restricted chain approach gives family-level coherence BY CONSTRUCTION
- Family-level coherence directly plugs into `parametric_shifted_truth_lemma`
- No need to rewrite the truth lemma

**Key Missing Piece**: Connecting DeferralRestrictedMCS/chain to BFMCS structure.
The restricted chain is a SINGLE family (not a bundle), and `parametric_shifted_truth_lemma`
requires a BFMCS with temporally_coherent. We need to:
- Wrap the single restricted chain as a degenerate BFMCS (one-family bundle)
- Prove this one-family bundle satisfies `BFMCS.temporally_coherent`
- The modal backward coherence for a singleton bundle: Box φ ∈ fam.mcs t ↔ φ ∈ fam.mcs t
  (since there's only one family, "all families" = just this one)
  But wait: Box φ ∈ fam.mcs t → φ ∈ fam.mcs t via the T axiom (sorry-free)
  And φ ∈ fam.mcs t → Box φ ∈ fam.mcs t requires S5 modal saturation

**The S5 Modal Saturation Problem**:
For a singleton Omega, Box semantics collapses to individual truth at each time.
This is exactly the problem noted in `SuccChainTruth.lean` (line 37): the "Box backward"
case requires that φ ∈ MCS implies Box φ ∈ MCS, which is NOT generally true without
modal saturation.

**Therefore**: The restricted chain approach needs either:
1. A richer bundle (multiple families) to handle Box correctly
2. The `boxClassFamilies` construction which IS sorry-free for modal coherence

**Combined Approach**:
1. Start from non-provable φ
2. Extend {¬φ} to MCS M₀ (full, not restricted)
3. Build `boxClassFamilies M₀` (sorry-free modal coherence)
4. Each family in `boxClassFamilies` is a RESTRICTED chain (over box-class of M₀)
5. For family-level F-coherence: use that each family IS a restricted deferral chain
6. Key theorem needed: each family in `boxClassFamilies` satisfies family-level F-coherence

This is exactly the blocked `boxClassFamilies_temporally_coherent` (line 1822 - SORRY).
But the reason it's blocked is `f_nesting_is_bounded` being FALSE for arbitrary MCS.

**Final Resolution**: The REAL path is:
- `boxClassFamilies` contains families indexed by arbitrary MCSs in the box-class
- These arbitrary MCSs can have unbounded F-nesting (that's why f_nesting_is_bounded is false)
- HOWEVER, for a SPECIFIC non-provable formula φ, we only need to falsify φ
- We can build a SMALLER bundle using deferral-restricted MCSs over deferralClosure(φ)
- Within this smaller bundle, f_nesting is bounded, and family-level coherence holds

## Comparison Matrix

| Criterion | Approach 2 (Bundle TL) | Approach 5 (FMP) | Approach 6 (Dovetailed) |
|-----------|------------------------|------------------|------------------------|
| Sorry-free potential | MEDIUM | HIGH | HIGH |
| Code reuse | HIGH | MEDIUM | HIGH |
| Math correctness | HIGH (new TL needed) | HIGH | HIGH |
| Lean complexity | MEDIUM | HIGH | MEDIUM |
| Preserves semantics | YES | YES | YES |
| Bundle vs family | Bundle | Either | Family (correct) |
| FMP dependency | NO | YES | YES |
| Key blocker | New truth lemma | RestrictedLindenbaum | Box-class + restriction |

## Concrete Recommendations

### Short-Term (Most Likely to Yield Progress)

**Approach 6 Variant**: Prove that the BFMCS built from `boxClassFamilies M₀` has
family-level coherence when M₀ is a **deferral-restricted MCS** over `deferralClosure(φ)`.

Steps:
1. Prove: if M₀ is a DeferralRestrictedMCS over deferralClosure(φ), then each family
   in boxClassFamilies(M₀) is ALSO deferral-restricted (or at least has bounded F-nesting)
2. Apply `f_nesting_is_bounded_restricted` to get family-level F-coherence
3. Plug into `construct_bfmcs` (or a restricted variant) to get a sorry-free BFMCS
4. Apply `parametric_shifted_truth_lemma` to conclude

This requires:
- `deferralClosure_closed_under_box_class`: if M₀ is closure-restricted, MCSs in same
  box-class are also closure-restricted → needs research
- `restricted_boxClassFamilies_temporally_coherent`: the blocked theorem, but now with
  the restriction hypothesis

### Medium-Term

**Approach 5 Complement**: Complete the FMP/filtration path which is already well-started:
- `FMP.lean` has the finite model statement but needs the truth lemma for filtration
- `TruthPreservation.lean` has some infrastructure
- The finite model HAS bounded F-nesting by finiteness, so filtration gives family-level coherence

## Confidence Assessment

- **That a sorry-free completeness proof exists**: HIGH (95%)
- **That the restricted/closure approach is the right path**: HIGH (85%)
- **That the bundle approach can be avoided**: HIGH (80%)
- **That the bundle approach can be fixed**: MEDIUM (60%) - requires new truth lemma
- **That Approach 6 (restricted dovetailed) is the most direct**: HIGH (80%)

## References

### Codebase Files

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
  - Lines 1866-2495: Omega-enumeration construction (sorry-free forward/backward chains)
  - Lines 2424-2494: Z_chain_forward_F and backward_P (SORRY - the key gap)
  - Lines 2758-2945: BFMCS_Bundle construction (sorry-free)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
  - Lines 715+: f_nesting_is_bounded_restricted (SORRY-FREE)
  - Lines 2188+: restricted_forward_chain_forward_F (SORRY-FREE)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
  - Lines 165-178: temporal_backward_G (SORRY-FREE)
  - Lines 216-219: BFMCS.temporally_coherent definition
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
  - The parametric_shifted_truth_lemma (SORRY-FREE given family-level coherence)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/FMP/Filtration.lean`
  - Filtration construction
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Decidability/FMP/FMP.lean`
  - FMP statement and proof

### Key Theorems Status

| Theorem | File | Status |
|---------|------|--------|
| parametric_shifted_truth_lemma | ParametricTruthLemma.lean | SORRY-FREE (needs h_tc) |
| temporal_backward_G | TemporalCoherence.lean | SORRY-FREE |
| boxClassFamilies_bundle_forward_F | UltrafilterChain.lean | SORRY-FREE |
| boxClassFamilies_temporally_coherent | UltrafilterChain.lean | SORRY (line 1822) |
| Z_chain_forward_F | UltrafilterChain.lean | SORRY (line 2485) |
| f_nesting_is_bounded_restricted | SuccChainFMCS.lean | SORRY-FREE |
| restricted_forward_chain_forward_F | SuccChainFMCS.lean | SORRY-FREE |
| construct_bfmcs | UltrafilterChain.lean | SORRY (depends on blocked) |
| construct_bfmcs_bundle | UltrafilterChain.lean | SORRY-FREE |

### Textbook References

- Goldblatt, "Logics of Time and Computation" (1992): Chapter 5 covers completeness
  for tense logics via Henkin models with temporal saturation
- Blackburn, de Rijke, Venema "Modal Logic" (2001): Ch 4.2 covers canonical models,
  Ch 4.9 covers frame completeness for modal logics
- Reynolds, "An axiomatization of full computation tree logic" (2001): Shows how
  bundled semantics differs from path-based semantics for temporal logic
- Zanardo, "Branching-time logic with quantification over branches" (1996): Discusses
  bundle semantics for tense logic and its relationship to linear tense logic

### Key Mathematical Insight from Literature

The standard Henkin completeness proof for tense logic (Goldblatt Ch 5) uses a
"maximal saturated set" construction where:
1. The base MCS is extended with Henkin witnesses for ALL F-obligations simultaneously
2. This requires transfinite induction over all formulas
3. The resulting model satisfies family-level coherence by the explicit saturation

This is exactly the dovetailed/enumeration approach in UltrafilterChain.lean lines 1866+.
The gap (Z_chain_forward_F sorry) is that the current construction only resolves F_top,
not all F-obligations. The fix: build a more careful chain that tracks which F-obligations
from the BASE MCS have been resolved.
