# Research Report: Task #870

**Task**: Zorn-based family selection for temporal coherence
**Date**: 2026-02-12
**Focus**: Phase 4 findings analysis and plan revision determination

## Summary

Phase 4 implementation discovered a **fundamental mathematical flaw**: the lemmas `multi_witness_seed_consistent_future` and `multi_witness_seed_consistent_past` are mathematically FALSE. This invalidates the "collect-into-one-MCS" strategy for pure past/future extension cases. The cross-sign case (both past and future domain times exist) remains viable. This report analyzes the implications, evaluates alternative approaches, and recommends plan revision.

## Findings

### 1. The False Lemma Problem

**Theorem as stated** (line 806-807):
```lean
theorem multi_witness_seed_consistent_future (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (Psis : List Formula) (h_F : forall psi in Psis, Formula.some_future psi in M) :
    SetConsistent ({phi | phi in Psis} union GContent M)
```

**Counterexample** (from phase-4-results.md):
Let M be any MCS containing both `F(p)` and `F(neg p)`. This is consistent in temporal logic because:
- `F(p)` means "p holds at some future time"
- `F(neg p)` means "neg p holds at some future time"
- Both can be true simultaneously (p at time 5, neg p at time 10)

Then `Psis = [p, neg p]`, and `{p, neg p} union GContent(M)` is inconsistent because `{p, neg p}` derives bottom directly.

**Why this matters**: The collect-into-one-MCS strategy assumed we could gather F-obligations from multiple source times into a single MCS. The counterexample shows that when source time s_max has conflicting F-obligations, the seed at s_max + 1 becomes inconsistent.

### 2. Current Sorry Inventory

After Phase 1 (dead code deletion) and Phase 2 (forward_F/backward_P structural fields):

| Line | Location | Type | Status |
|------|----------|------|--------|
| 844 | multi_witness_seed_consistent_future | False lemma | **CANNOT BE PROVEN** |
| 874 | multi_witness_seed_consistent_past | False lemma | **CANNOT BE PROVEN** |
| 888 | extensionSeed_consistent (cross-sign) | Seed consistency | SOLVABLE via cross-sign collection |
| 1120 | extensionSeed_consistent (pure past) | Seed consistency | BLOCKED - requires false lemma |
| 1260 | extensionSeed_consistent (pure future) | Seed consistency | BLOCKED - requires false lemma |
| 1764 | extendFamilyAtUpperBoundary.forward_F (old-to-new) | F/P propagation | REQUIRES new-to-old proof |
| 1786 | extendFamilyAtUpperBoundary.backward_P (new-to-old) | F/P propagation | REQUIRES GH-controlled Lindenbaum |
| 1928 | extendFamilyAtLowerBoundary.forward_F (new-to-old) | F/P propagation | REQUIRES GH-controlled Lindenbaum |
| 1968 | extendFamilyAtLowerBoundary.backward_P (old-to-new) | F/P propagation | REQUIRES new-to-old proof |
| 2091 | non_total_has_boundary (gap case) | Domain totality | FALSE for domains with internal gaps |
| 2161 | maximal_implies_total h_G_from_new | F/P recovery | REQUIRES GH-controlled Lindenbaum |
| 2168 | maximal_implies_total h_H_from_new | F/P recovery | REQUIRES GH-controlled Lindenbaum |

**Classification**:
- **Mathematically false (2)**: Lines 844, 874 (cannot be proven)
- **Blocked by false lemmas (2)**: Lines 1120, 1260
- **Require GH-controlled Lindenbaum (4)**: Lines 1786, 1928, 2161, 2168
- **Require alternative approach (1)**: Line 2091
- **Solvable with existing infrastructure (1)**: Line 888

### 3. Analysis of Augmented Seed Approach

Phase 3's fallback (implementation-004.md line 171):
> "If selective Lindenbaum proves too complex, use augmented seed approach: include negative GH constraints (neg(G psi) for psi not in all future MCSs) in the seed."

**Evaluation**: This approach has **limited applicability**.

**For cross-sign case**: Works well. If both past and future domain times exist:
- Past elements collect into mcs(s_max) where s_max is the maximum past source time
- Future elements collect into mcs(s_min) where s_min is the minimum future source time
- Since s_max < t < s_min with both in domain:
  - GContent from s_max propagates to s_min via forward_G (+ 4-axiom)
  - F-obligations from s_max propagate to s_min via forward_F (s_max < s_min)
  - HContent from s_min is already at s_min
  - P-obligations from s_min propagate backward
- All elements end up in mcs(s_min), which is consistent as an MCS

**For pure past/future cases**: **Does NOT work** because:
- At pure past boundary: F-obligations at s_max cannot propagate forward (no domain time > s_max)
- The problem is NOT about controlling which G/H formulas appear in the new MCS
- The problem is that the SEED ITSELF is inconsistent before any Lindenbaum extension
- Augmented seeds (adding neg(G psi)) don't help when {psi1, neg psi1} is already in the seed

**Selective witness blocking**: Not viable. The issue is that F(p) and F(neg p) in mcs(s_max) forces BOTH p and neg p into the seed simultaneously. This is a structural problem with the F-obligation definition, not a Lindenbaum extension problem.

### 4. Forward_F/Backward_P for Extended Family

The goal states at lines 1764, 1786, 1928, 1968 show the specific problems:

**Line 1764** (old-to-new at upper boundary):
```
Goal: phi in mcs_t
Given: phi.some_future in F.mcs s (where s is old, s' = t is new)
```
This is **solvable** if the seed includes FObligations and mcs_t extends the seed.

**Line 1786** (new-to-old at upper boundary):
```
Goal: phi in F.mcs s' (old domain time)
Given: phi.some_past in mcs_t (new boundary time)
```
This is **hard**: P phi in new MCS doesn't automatically mean phi is in old MCS times. Requires GH-controlled Lindenbaum that ensures P phi in new MCS only if psi was already witnessed in past domain.

### 5. Phase Viability Assessment

| Phase | Status | Viability | Reason |
|-------|--------|-----------|--------|
| Phase 1 | COMPLETED | N/A | Dead code deleted |
| Phase 2 | COMPLETED | N/A | forward_F/backward_P fields added |
| Phase 3 | NOT STARTED | **Viable but insufficient** | GH-controlled Lindenbaum helps but doesn't fix seed inconsistency |
| Phase 4 | PARTIAL | **Cross-sign VIABLE, pure cases NOT VIABLE** | Fundamental false lemma discovered |
| Phase 5 | NOT STARTED | **Requires rethinking** | Depends on 3-4 |
| Phase 6 | NOT STARTED | Depends on prior phases | Cleanup |

### 6. Alternative Approaches

**Option A: Accept partial victory (cross-sign only)**
- Prove extensionSeed_consistent for cross-sign case only
- Accept that pure past/future extension may fail for some families
- This changes the theorem from "every family can be extended" to "families meeting certain conditions can be extended"
- Impact: Construction may get stuck at families with only past or only future domain times

**Option B: Change seed construction for pure cases**
- Instead of including all F-obligations at pure past boundary, only include F-obligations that have been "witnessed compatible"
- Add a pre-check: before including psi in seed from F(psi) in mcs(s), verify that psi doesn't contradict other seed elements
- Challenge: This is non-computable (requires deciding consistency)

**Option C: Multi-time extension strategy**
- Instead of adding one time, add multiple times simultaneously (e.g., add both t and t+1)
- F-obligations from s_max can propagate to t+1 instead of t
- Challenge: Requires rethinking entire Zorn structure

**Option D: Domain restriction approach**
- Accept that not all partial families can be extended
- Prove that families satisfying additional coherence properties (e.g., "witnessable F-obligations") can be extended
- Use Zorn on the restricted class
- The singleton base family vacuously satisfies any additional property

**Option E: Construction-time witness placement**
- Instead of hoping F-obligations are compatible at extension time, pre-place witnesses during construction
- This is the RecursiveSeed approach used in DovetailingChain.lean
- Challenge: DovetailingChain has its own 4 sorries for different reasons

## Recommendations

### Primary Recommendation: Create implementation-005.md with revised strategy

**Key Changes**:

1. **Bifurcate seed consistency**:
   - Cross-sign case: Provable via collect-into-one-MCS
   - Pure cases: Requires fundamentally different approach

2. **Phase 3 revision**: GH-controlled Lindenbaum is still valuable for new-to-old propagation, but does NOT solve the pure case seed inconsistency

3. **Phase 4 revision**:
   - Delete false lemmas (multi_witness_seed_consistent_future/past)
   - Prove cross-sign case of extensionSeed_consistent
   - Accept pure cases as technical debt with documented remediation path

4. **Phase 5 revision**:
   - Modify `non_total_can_extend` to only claim extension is possible for boundaries where cross-sign conditions hold, OR use Option D (domain restriction)

5. **New Phase 3.5**: Implement Option D - add coherence predicate to base family and prove it propagates through chain upper bound

### Specific Implementation Guidance

**For cross-sign (line 888)**:
```
Strategy: Find s_min (minimum future source time). All seed elements propagate to mcs(s_min):
- GContent from past: via GContent_propagates_forward to s_max, then forward_G to s_min
- FObligations from past: via forward_F to s_min
- HContent from future: via HContent_propagates_backward to s_min
- PObligations from future: via backward_P to s_min (or already at s_min)
```

**For pure cases**: Mark as documented technical debt with remediation path "requires RecursiveSeed integration or domain restriction approach"

### Secondary Recommendation: Consider abandoning Zorn approach

The Zorn approach assumes ANY partial family can be extended. The false lemma discovery shows this is not true for all families. Alternatives:

1. **RecursiveSeed (DovetailingChain)**: Pre-places witnesses during construction, avoids the F-obligation collection problem
2. **Explicit chain construction**: Build the family one time at a time with explicit witness placement, not via Zorn maximality

However, both alternatives have their own sorries. The Zorn approach has value because it separates concerns:
- Seed consistency (mathematical question about temporal logic)
- Extension mechanics (Lindenbaum + coherence preservation)
- Domain totality (Zorn maximality argument)

## References

- `specs/870_zorn_family_temporal_coherence/phases/phase-4-results.md` - Full false lemma analysis
- `specs/870_zorn_family_temporal_coherence/plans/implementation-004.md` - Current plan
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - Implementation with sorry locations
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Proven single-witness consistency

## Next Steps

1. Create implementation-005.md with revised phase structure
2. Delete or mark as deprecated the false lemmas (lines 806-874)
3. Implement cross-sign case of extensionSeed_consistent (line 888)
4. Add domain restriction predicate if pursuing Option D
5. Document remaining sorries as technical debt per proof-debt-policy.md

## Technical Debt Summary

After implementing recommendations:

| Sorry | Classification | Remediation Path |
|-------|----------------|------------------|
| Pure past seed (1120) | Development placeholder | RecursiveSeed integration or domain restriction |
| Pure future seed (1260) | Development placeholder | RecursiveSeed integration or domain restriction |
| F/P propagation (4 sites) | Development placeholder | GH-controlled Lindenbaum (Phase 3) |
| Gap case (2091) | Development placeholder | Domain restriction approach |
| New-to-old (2161, 2168) | Development placeholder | GH-controlled Lindenbaum |

Total: 9 sorries remaining as technical debt (down from 11 after Phase 1-2, but classification changed)
