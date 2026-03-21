# Research Report: Task #870

**Task**: Zorn-based family selection for temporal coherence - Path Forward Synthesis
**Date**: 2026-02-12
**Session**: sess_1770923069_0047cd
**Focus**: Synthesize findings from research-006 and team research (task 880) to determine viable path forward

## Summary

This report synthesizes the findings from multiple research efforts on Task 870. The current implementation plan (implementation-004) is fundamentally blocked by three distinct mathematical problems:

1. **False lemma problem**: `multi_witness_seed_consistent_future/past` are mathematically FALSE
2. **Extension incompatibility problem**: Universal `forward_F` is incompatible with domain extension
3. **Gap case problem**: `non_total_has_boundary` is FALSE for domains with internal gaps

After evaluating five candidate solutions, the report recommends a decision point between (A) accepting documented technical debt in the Zorn approach or (B) pivoting to an alternative construction. No approach cleanly resolves all issues.

## Findings

### 1. The Three Fundamental Blockers

#### 1.1 False Lemma Problem

The lemmas `multi_witness_seed_consistent_future` (line 844) and `multi_witness_seed_consistent_past` (line 874) are **mathematically false**.

**The statement**:
```lean
theorem multi_witness_seed_consistent_future (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (Psis : List Formula) (h_F : forall psi in Psis, Formula.some_future psi in M) :
    SetConsistent ({phi | phi in Psis} union GContent M)
```

**Counterexample**: Let M be any MCS containing both `F(p)` and `F(neg p)`. This is consistent in temporal logic because:
- `F(p)` means "p holds at some future time" (say time 5)
- `F(neg p)` means "neg p holds at some different future time" (say time 10)
- Both can be satisfied simultaneously by different witness times

Then `Psis = [p, neg p]` and the seed `{p, neg p} union GContent(M)` is **inconsistent** because `{p, neg p}` derives bottom directly through propositional logic.

**Why this matters**: The "collect-into-one-MCS" strategy from implementation-004 (Phase 4) requires placing multiple F-obligation witnesses simultaneously. When the source MCS has conflicting F-obligations, the seed becomes inconsistent before Lindenbaum even runs.

**Transitive impact**: Lines 1120 and 1260 (pure past/future cases of `extensionSeed_consistent`) depend on these false lemmas and cannot be proven.

#### 1.2 Extension Incompatibility Problem (New Discovery from Task 880)

Team research discovered a deeper flaw: **universal `forward_F` is incompatible with domain extension**.

**Proof by counterexample**:
- Base family: domain = {0}, mcs(0) = M where `F(p) in M` and `F(neg p) in M`
- Attempt to extend to domain = {0, 1}
- Universal `forward_F` requires:
  - `F(p) in mcs(0)` implies `p in mcs(1)`
  - `F(neg p) in mcs(0)` implies `neg p in mcs(1)`
- But `p and neg p in mcs(1)` contradicts mcs(1) being maximal consistent

**Consequence**: Zorn's lemma may yield a maximal family with domain = {0} because no valid extension exists. The strengthened family strategy from implementation-004 Phase 2 has a fundamental gap - the structure requirements themselves prevent extension.

**Why this invalidates implementation-004**: The plan added universal `forward_F/backward_P` fields precisely to enable the collect-into-one-MCS argument. But these fields make extension impossible for certain families, defeating the purpose.

#### 1.3 Gap Case Problem

The lemma `non_total_has_boundary` (line 2091) is **false for domains with internal gaps**.

**Counterexample**: Consider a family with domain = Z \ {0} (all integers except 0).
- This domain has no upper boundary (unbounded above)
- This domain has no lower boundary (unbounded below)
- Yet domain is not Set.univ

The lemma claims every non-total domain has a boundary time. This is false for domains with internal gaps but no boundary.

**Impact**: The proof of `maximal_implies_total` relies on `non_total_has_boundary` to find a point where extension is possible. For gapped domains, this approach fails.

### 2. Current Sorry Inventory (12 Sites)

| Line | Location | Classification | Status |
|------|----------|----------------|--------|
| 844 | `multi_witness_seed_consistent_future` | Mathematically false | CANNOT be proven |
| 874 | `multi_witness_seed_consistent_past` | Mathematically false | CANNOT be proven |
| 888 | `extensionSeed_consistent` (cross-sign) | Seed consistency | SOLVABLE with existing infrastructure |
| 1120 | `extensionSeed_consistent` (pure past) | Blocked by false lemma | BLOCKED |
| 1260 | `extensionSeed_consistent` (pure future) | Blocked by false lemma | BLOCKED |
| 1764 | `extendFamilyAtUpperBoundary.forward_F` | Old-to-new propagation | Requires seed structure argument |
| 1786 | `extendFamilyAtUpperBoundary.backward_P` | New-to-old propagation | Requires GH-controlled Lindenbaum |
| 1928 | `extendFamilyAtLowerBoundary.forward_F` | New-to-old propagation | Requires GH-controlled Lindenbaum |
| 1968 | `extendFamilyAtLowerBoundary.backward_P` | Old-to-new propagation | Requires seed structure argument |
| 2091 | `non_total_has_boundary` (gap case) | Mathematically false | CANNOT be proven |
| 2161 | `maximal_implies_total` h_G_from_new | F/P recovery | Requires GH-controlled Lindenbaum |
| 2168 | `maximal_implies_total` h_H_from_new | F/P recovery | Requires GH-controlled Lindenbaum |

**Summary by category**:
- Mathematically false (3): Lines 844, 874, 2091
- Blocked by false lemmas (2): Lines 1120, 1260
- Require GH-controlled Lindenbaum (4): Lines 1786, 1928, 2161, 2168
- Require seed structure argument (2): Lines 1764, 1968
- Solvable now (1): Line 888

### 3. What Works: Cross-Sign Case

The one bright spot: when the domain has times both above and below t (cross-sign case), seed consistency IS provable.

**Why cross-sign works**:
- Take `s_max = max past source time` and `s_min = min future source time`
- Since `s_max < t < s_min` with both in domain:
  - GContent from past propagates to `mcs(s_min)` via `forward_G` + 4-axiom
  - F-obligations from past propagate to `mcs(s_min)` via `forward_F` (both times in domain)
  - HContent from future is already at `s_min`
  - P-obligations from future propagate backward to `s_min`
- All elements collect into `mcs(s_min)`, which is consistent as an MCS

**Key insight**: F-obligations propagate to an EXISTING domain time, not to the new time being added. This avoids the multi-witness seed consistency problem.

### 4. Why the Single-Witness Lemma Works But Multi-Witness Fails

The proven lemma `temporal_witness_seed_consistent` handles exactly:
> If `F(psi) in M`, then `{psi} union GContent(M)` is consistent.

This is ONE witness for ONE F-obligation. The proof works because:
1. Assume `{psi} union GContent(M)` is inconsistent
2. Then `GContent(M) derives neg(psi)`
3. So `neg(G(neg(psi))) = F(psi)` should be inconsistent with M
4. But `F(psi) in M` and M is MCS, contradiction

**Why multi-witness fails**: When we have `F(p)` and `F(neg p)` in M:
- `{p} union GContent(M)` is consistent (by single-witness lemma)
- `{neg p} union GContent(M)` is consistent (by single-witness lemma)
- But `{p, neg p} union GContent(M)` is inconsistent because {p, neg p} is itself inconsistent

The problem is BEFORE Lindenbaum runs - the seed is already inconsistent.

### 5. Alternative Approach: DovetailingChain

DovetailingChain.lean provides an alternative construction with 4 different sorry sites:

| Sorry | Location | Issue |
|-------|----------|-------|
| 1 | `forward_G` when t < 0 | Cross-sign propagation |
| 2 | `backward_H` when t >= 0 | Cross-sign propagation |
| 3 | `forward_F` | Witness construction |
| 4 | `backward_P` | Witness construction |

**Key difference**: DovetailingChain's sorries are about cross-sign propagation (which we now know IS solvable) and F/P witness construction, NOT about seed consistency for conflicting obligations.

**Advantage**: DovetailingChain builds MCSs one at a time with explicit witness placement via dovetailing enumeration. It never needs to place multiple F-witnesses simultaneously.

**Disadvantage**: The cross-sign propagation sorries (1 and 2) require showing that the construction propagates G/H across the time=0 boundary. This requires tracking the construction order.

## Candidate Solutions

### Option A: Accept Technical Debt (Document and Defer)

**Approach**:
- Prove what is provable (cross-sign case)
- Delete false lemmas with counterexample documentation
- Mark pure past/future sorries as documented technical debt
- Document limitations clearly

**Pros**:
- Minimal effort
- Honest about limitations
- Frees resources for other work

**Cons**:
- Task 870 goal (sorry-free proof) not achieved
- `temporal_coherent_family_exists_zorn` remains sorry-dependent
- Technical debt persists

**Sorry outcome**: ~9 sorries remain (down from 12, but none eliminated by false lemma deletion, just recategorized)

**Risk**: Low effort, high debt

### Option B: Pivot to DovetailingChain Approach

**Approach**:
- Abandon Zorn-based construction
- Invest in completing DovetailingChain
- Cross-sign G/H propagation is now known to be solvable (same argument as Zorn cross-sign)
- F/P witness construction via dovetailing enumeration

**Pros**:
- DovetailingChain sorries may be more tractable
- Cross-sign propagation uses same "collect-into-one-MCS" we understand
- Explicit construction gives more control than Zorn

**Cons**:
- Significant pivot effort
- F/P witness construction still unsolved (different mechanism than Zorn)
- DovetailingChain code is less mature

**Sorry outcome**: 4 sorries to resolve (vs 12 in Zorn)

**Risk**: Medium effort, medium debt

### Option C: Combined One-at-a-Time Witness + GH-Controlled Lindenbaum

**Approach**:
- Use proven `temporal_witness_seed_consistent` for single witnesses
- Extend domain one time at a time, placing one witness per extension
- Use GH-controlled Lindenbaum to ensure new MCS doesn't introduce problematic G/H formulas
- Iterate until all F/P obligations witnessed

**From task 880 analysis**:
| Component | Seed Consistency | New-to-Old | Base Case |
|-----------|-----------------|------------|-----------|
| One-at-a-Time Witness | Solved | Requires separate | Straightforward |
| GH-Controlled Lindenbaum | NOT solved | Solved | Straightforward |
| **Combined** | Solved | Solved | Straightforward |

**Pros**:
- Theoretically cleanest
- Addresses all known blockers
- Could achieve sorry-free proof

**Cons**:
- Very high complexity (essentially new construction)
- GH-controlled Lindenbaum infrastructure doesn't exist
- Extensive refactoring needed

**Sorry outcome**: Potentially 0 (but high uncertainty)

**Risk**: Very high effort, low debt IF successful

### Option D: Domain Restriction Approach

**Approach**:
- Accept that not all partial families can be extended
- Define predicate for "extendable families" (e.g., families without conflicting F/P obligations at any boundary)
- Prove Zorn on the restricted class
- Singleton base family satisfies predicate vacuously

**Pros**:
- Preserves Zorn approach
- Avoids false lemma problem by restricting domain

**Cons**:
- Changes theorem statement (weaker result)
- Complex predicate definition
- Must prove predicate preserved through chain upper bound
- Gap case still problematic

**Sorry outcome**: Unknown (depends on predicate design)

**Risk**: Medium effort, medium debt

### Option E: Weaken Theorem Statement

**Approach**:
- Prove `temporal_coherent_family_exists_zorn` only for specific starting contexts
- Or prove G/H coherence only (drop F/P requirement)
- Or prove for families meeting additional properties

**Pros**:
- Something is better than nothing
- May be sufficient for downstream use cases

**Cons**:
- Weaker than originally intended
- May not satisfy publication requirements
- Feels like giving up

**Sorry outcome**: 0 sorries in weaker theorem, but original goal unmet

**Risk**: Low effort, goal not achieved

## Recommendations

### Primary Recommendation: Choose Between A or B

The user should make an explicit choice between:

**Option A (Document and Defer)** if:
- Task 870 can remain blocked without impacting other work
- Resources better spent elsewhere
- A sorry-dependent temporal construction is acceptable for now

**Option B (Pivot to DovetailingChain)** if:
- Sorry-free temporal construction is required for downstream proofs
- Willing to invest ~8-12 hours in alternative approach
- Cross-sign propagation argument can be extracted and reused

### Secondary Recommendation: Delete False Lemmas Now

Regardless of which path forward is chosen:

1. Delete or clearly mark `multi_witness_seed_consistent_future` (line 844)
2. Delete or clearly mark `multi_witness_seed_consistent_past` (line 874)
3. Add counterexample documentation explaining WHY they're false
4. Update sorry classifications in SORRY_REGISTRY.md

This prevents future confusion and wasted effort.

### Tertiary Recommendation: Factor Out Cross-Sign Proof

The cross-sign seed consistency argument works for BOTH approaches:
- In Zorn: `extensionSeed_consistent` cross-sign case (line 888)
- In DovetailingChain: cross-sign G/H propagation (lines 606, 617)

**Recommendation**: Create shared lemma in TemporalContent.lean:
```lean
lemma cross_sign_content_collects_to_mcs
    (F : PartialFamily) (s_past s_future : Int)
    (h_past : s_past in F.domain) (h_future : s_future in F.domain)
    (h_lt : s_past < s_future) :
    forall phi, phi in GContent(F.mcs s_past) -> phi in F.mcs s_future
```

This factors out the reusable insight and reduces duplication.

### Decision Matrix

| Criterion | A: Accept Debt | B: Pivot | C: Combined | D: Restrict | E: Weaken |
|-----------|---------------|----------|-------------|-------------|-----------|
| Effort | Low | Medium | Very High | Medium | Low |
| Sorry-free? | No | Possible | Possible | Unlikely | Yes (weaker) |
| Original goal? | No | Yes | Yes | Partial | No |
| Risk | Low | Medium | High | Medium | Low |
| Recommendation | If blocked OK | If sorry-free needed | Only if time permits | Not recommended | Last resort |

## References

- Task 870 implementation plan v004: `specs/870_zorn_family_temporal_coherence/plans/implementation-004.md`
- Task 870 research-006: `specs/870_zorn_family_temporal_coherence/reports/research-006.md`
- Task 880 team research: `specs/880_augmented_extension_seed_approach/reports/research-001.md`
- ZornFamily.lean: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- DovetailingChain.lean: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`

## Next Steps

Based on user choice:

**If Option A (Accept Debt)**:
1. Delete false lemmas with documentation
2. Prove cross-sign case (line 888)
3. Update SORRY_REGISTRY.md with final classification
4. Mark task as [PARTIAL] or [COMPLETED] with documented debt

**If Option B (Pivot to DovetailingChain)**:
1. Create new task for DovetailingChain completion
2. Port cross-sign argument to resolve DovetailingChain lines 606, 617
3. Design F/P witness construction strategy
4. Archive Zorn approach attempts with lessons learned
