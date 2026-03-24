# Teammate B Findings: Historical Analysis and Alternative Approaches

**Task**: 48 - prove_succ_chain_fam_bounded_f_depth
**Date**: 2026-03-23
**Focus**: Identify untried approaches after 12+ plan versions

## Key Findings

After reviewing all 24 prior reports, 12 plans, and 9 summaries, I've identified the core mathematical issue and several genuinely untried approaches.

## Summary of Failed Approaches

### v1-v3: Direct approaches
**What was tried**: Prove boundedness for arbitrary MCS using standard arguments.
**Why it failed**: The claim `f_nesting_is_bounded` is FALSE for arbitrary MCS. An MCS can contain F(phi), FF(phi), FFF(phi), ... infinitely. Task 47 proved this only for RestrictedMCS (bounded by finite closure).

### v4: Restricted p_step_blocking
**What was tried**: Prove p_step_blocking_formulas stay in DeferralRestrictedMCS.
**Why it failed**: Works when P(psi) is in deferralClosure, but fails for boundary cases where P(psi) is NOT in deferralClosure but H(neg psi) IS.

### v5: Fuel-based recursion
**What was tried**: Track fuel/iterations to prove termination.
**Why it failed**: The fuel bound invariant cannot be maintained because formulas can defer indefinitely.

### v6: bounded_witness pattern
**What was tried**: Port the working unrestricted `bounded_witness` to restricted case.
**Why it failed**: 2 critical sorries remain at lines 2360, 3012 for boundary case (FF not in dc). DRM negation completeness only applies when BOTH psi and psi.neg are in deferralClosure.

### v7-v9: boundary_resolution_set
**What was tried**: Add chi to seed when FF(chi) not in dc to force resolution.
**Why it failed**: The derivability blocker - chi.neg CAN be in u while F(chi) is also in u (semantic meaning: "chi is false now but will be true in some future"). Adding chi to seed with chi.neg derivable makes seed inconsistent.

### v10: chi-in-u restriction
**What was tried**: Only add chi to boundary_resolution_set when chi is already in u.
**Why it failed**: Build errors in existing code blocked verification of new approach.

### v11: Lindenbaum Succ lifting
**What was tried**: Lift restricted chain to full MCS via extendToMCS, apply working bounded_witness, transfer back.
**Why it failed**: **FATAL** - Succ does NOT lift through independent Lindenbaum extensions. Two `Classical.choose` applications for `extendToMCS(chain(k))` and `extendToMCS(chain(k+1))` are independent; the first can freely add G(chi) formulas disconnected from the second. The g_content property cannot transfer.

### v12: DRM negation completeness
**What was tried**: Prove negation completeness within dc for formulas where neg is also in dc.
**Why it failed**: Research report #22 incorrectly claimed closureWithNeg is closed under negation. **It is NOT**. `closureWithNeg = subformulaClosure ∪ image neg subformulaClosure`. The double negation `neg(neg(psi))` is NOT in closureWithNeg unless it's already a subformula.

## Untried Approaches

### Approach A: Filtration Method (UNTRIED)
**Description**: Build a finite model directly from the Fischer-Ladner closure using filtration/equivalence classes instead of Lindenbaum MCS construction.

**Why it might work**:
- Naturally finite - no escape problem
- Standard technique in modal logic (Blackburn, de Rijke, Venema - "Modal Logic" Ch 2.3)
- The completeness proof doesn't NEED infinite MCS, it needs decidability within closure
- FMP (Finite Model Property) for temporal logic guarantees a finite counter-model exists

**Mathematical sketch**:
1. Define equivalence on worlds: w ~ w' iff for all psi in closure, M,w |= psi ↔ M,w' |= psi
2. Build filtrated frame on equivalence classes
3. Show truth lemma holds for closure formulas
4. Succ relation defined by existence of representative successors

**Risk**: Requires significant architectural change. Not quick fix.
**Effort**: 8-12 hours

### Approach B: Weaken the Theorem Statement (UNTRIED)

**Description**: Instead of proving `restricted_bounded_witness` as stated, prove a weaker version with stronger hypotheses that callers can provide.

**Why it might work**: The only caller is `restricted_forward_chain_F_coherence`. Examine what it ACTUALLY needs:
- It calls with `iter_F (d-1) psi` where `d` comes from `restricted_forward_chain_F_bounded`
- The d-value is chosen such that `iter_F d psi` leaves deferralClosure

**Concrete weakening**:
```lean
theorem restricted_bounded_witness_strong (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (psi : Formula) (d : Nat)
    (h_d_ge : d ≥ 1)
    (h_Fd : iter_F d psi ∈ restricted_forward_chain phi M0 k)
    (h_Fd1_not : iter_F (d + 1) psi ∉ restricted_forward_chain phi M0 k)
    (h_psi_in_dc : psi ∈ deferralClosure phi)  -- NEW
    (h_all_in_dc : ∀ i ≤ d, iter_F i psi ∈ deferralClosure phi) -- NEW: all intermediate in dc
    : psi ∈ restricted_forward_chain phi M0 (k + d)
```

**Risk**: Need to verify callers can provide the new hypotheses.
**Effort**: 2-3 hours

### Approach C: Forward Simulation (UNTRIED)

**Description**: Instead of proving F-coherence via negation completeness, construct an explicit witness path.

**Why it might work**:
- F(psi) in u means there EXISTS a successor satisfying psi (semantically)
- Instead of deriving that F(psi) doesn't propagate, CONSTRUCT the witness
- Use the deterministic forward chain structure: at each step, psi either resolves or defers
- Track which step must resolve psi by finite closure argument

**Mathematical sketch**:
1. F(psi) in chain(k), psi in deferralClosure
2. By finite closure, psi can only defer finitely many times
3. Define `resolution_step(k, psi)` = first k' >= k where psi in chain(k') or F(psi) not in dc
4. Show resolution_step is well-defined (bounded by closure size)
5. Prove by well-founded recursion that psi eventually lands

**Risk**: Complex well-founded recursion setup
**Effort**: 4-6 hours

### Approach D: Two-Phase Proof (UNTRIED)

**Description**: Split the proof into two cases with different proof strategies.

**Case 1**: FF(psi) in deferralClosure
- Use existing infrastructure
- Negation completeness for FF(psi) is available
- v6 approach works for this case

**Case 2**: FF(psi) NOT in deferralClosure (the boundary)
- Key insight: Since FF(psi) not in dc, F(psi) must either:
  - (a) Be in subformulaClosure (F(psi) in dc via closureWithNeg), OR
  - (b) Not be in dc at all
- For (b): F(psi) not in dc means F(psi) can't be in any chain element, so the F-obligation resolves immediately
- For (a): F(psi) in subformulaClosure means neg(F(psi)) = G(psi.neg) in closureWithNeg in dc
- Apply negation completeness at F(psi) level instead of FF(psi) level

**Risk**: Need to verify case (a) gives enough to complete proof
**Effort**: 3-4 hours

### Approach E: Semantic Transfer (UNTRIED)

**Description**: Use model existence to prove syntactic consistency.

**Why it might work**:
- Every MCS has a model (Henkin construction)
- The restricted chain satisfies semantic Succ (by construction)
- F(psi) in u means semantically there exists successor with psi
- Use this to argue that the chain must contain psi at some point

**Mathematical sketch**:
1. Let M be canonical model where chain(k) is world w_k
2. F(psi) in chain(k) means M, w_k |= F(psi)
3. So exists w' such that R(w_k, w') and M, w' |= psi
4. By chain seriality, w' is reachable by finite steps
5. If psi in deferralClosure, then psi must be decided at some chain element
6. Use finite closure to bound the number of steps

**Risk**: Requires formalizing more semantic infrastructure
**Effort**: 6-8 hours

## Recommended Path

**Primary recommendation: Approach D (Two-Phase Proof)**

This approach:
1. Avoids the fundamental closureWithNeg non-closure issue
2. Works with existing infrastructure
3. Only requires proving the boundary case differently
4. Has clear mathematical structure

**Key insight for Case (a) of Approach D**:
When FF(psi) not in dc but F(psi) in subformulaClosure:
- F(psi) in subformulaClosure means F(psi) was originally a subformula of phi
- neg(F(psi)) = G(psi.neg) is in closureWithNeg (since F(psi) is a subformula)
- So BOTH F(psi) and neg(F(psi)) are in deferralClosure
- DRM negation completeness applies to F(psi)!
- Either F(psi) in chain(k+1) or neg(F(psi)) = G(psi.neg) in chain(k+1)
- If G(psi.neg) in chain(k+1), then by T-axiom psi.neg in chain(k+1)
- But we started with F(psi) in chain(k), so psi in f_content(chain(k))
- By f_step: psi in chain(k+1) or F(psi) in chain(k+1)
- With G(psi.neg) in chain(k+1), we have psi.neg in chain(k+1)
- Consistency: can't have both psi and psi.neg
- So must have F(psi) in chain(k+1), not psi

Wait, this leads to the deferral case again. Let me reconsider...

**Corrected Case (a) analysis**:
- F(psi) in chain(k), FF(psi) not in chain(k) (given)
- We want to show psi in chain(k+1)
- F-step: psi in chain(k+1) OR F(psi) in chain(k+1)
- Need to exclude F(psi) in chain(k+1)
- If F(psi) in chain(k+1), and F(psi) in dc, then...
- We need to show contradiction

The issue remains: we cannot directly exclude F(psi) from chain(k+1) without negation completeness at FF(psi) level.

**Revised recommendation: Approach B (Weaken Theorem)**

The safest path is to examine the actual caller (`restricted_forward_chain_F_coherence`) and verify whether adding `h_all_in_dc : ∀ i ≤ d, iter_F i psi ∈ deferralClosure phi` as a hypothesis is acceptable. The caller uses `restricted_forward_chain_F_bounded` which explicitly provides a bound where iterations leave dc, so the hypothesis should be satisfiable for all i < d.

## Confidence Level

**Medium-High**

- HIGH confidence in the historical analysis (all approaches verified in code)
- HIGH confidence that Lindenbaum Succ lifting is fatal (team research confirmed independently)
- MEDIUM confidence in Approach D working (needs more detailed case analysis)
- HIGH confidence that callers could provide strengthened hypotheses (Approach B)

## References

- All 24 reports in specs/048_*/reports/
- All 12 plans in specs/048_*/plans/
- summaries/13_drm-negation-summary.md (most recent)
- SuccChainFMCS.lean:2340-2440, 2990-3030 (actual sorries)
- RestrictedMCS.lean:940-1090 (DRM infrastructure)
- CanonicalTaskRelation.lean:651-680 (working bounded_witness)
