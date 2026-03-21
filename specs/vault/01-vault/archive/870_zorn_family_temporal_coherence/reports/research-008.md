# Research Report: Task #870

**Task**: Zorn-based family selection for temporal coherence - Strategic Path Analysis
**Date**: 2026-02-12
**Mode**: Team Research (2 teammates)
**Session**: sess_1770947549_cdaca1
**Focus**: Systematic analysis of past implementation attempts to improve the plan for a sorry-free path

## Summary

Team research conducted systematic analysis of all four implementation versions (v001-v004) of the Zorn-based approach, revealing a fundamental pattern: **Zorn's lemma provides existence without construction trace**, making F/P witness placement impossible to verify. The research confirms that DovetailingChain is a more tractable alternative - it has 4 sorries (vs Zorn's 6 active sorries), 2 of which are immediately SOLVABLE using the well-understood cross-sign collect-into-one-MCS argument. The remaining 2 DovetailingChain sorries are enumeration tracking problems (not consistency impossibilities), making them qualitatively different from Zorn's mathematically FALSE lemmas.

## Key Findings

### 1. Implementation Version Analysis

| Version | Core Strategy | Failure Mode | Surviving Infrastructure |
|---------|---------------|--------------|--------------------------|
| v001 | Full temporal properties in structure | Base family impossibility (F/P requires witnesses outside singleton domain) | Basic structure concept, partial order, chain upper bound pattern |
| v002 | Remove F/P from structure (G/H only) | Seed consistency: GContent + HContent + FObligations + PObligations cannot be proven consistent | GHCoherentPartialFamily, Preorder instance, buildBaseFamily, chainUpperBound, zorn_maximal_exists |
| v003 | Boundary-only extension | G-distribution fallacy (G(A or B) does NOT imply G(A) or G(B)), gap domains have no boundary | extendFamilyAtBoundary, boundarySeed, cross-sign argument structure |
| v004 | Strengthened family (universal forward_F) | Universal forward_F incompatible with domain extension (conflicting F-obligations prevent any extension) | Dead code deleted, cross-sign remains viable |

### 2. The Three Mathematically FALSE Lemmas

| Lemma | Location | Counterexample |
|-------|----------|----------------|
| `multi_witness_seed_consistent_future` | Line 844 | MCS with F(p) and F(neg p) -> seed {p, neg p} is inconsistent |
| `multi_witness_seed_consistent_past` | Line 874 | Symmetric to future case |
| `non_total_has_boundary` | Line 2091 | Domain Z \ {0} has no boundary times but is not Set.univ |

**Critical insight**: These are not implementation bugs that can be fixed - they are mathematically false statements. No amount of proof effort will succeed.

### 3. The Common Failure Pattern

All Zorn-based approaches share this fundamental problem:

**Zorn gives existence, not construction**:
1. We get a maximal element non-constructively
2. Cannot trace HOW each MCS was built
3. Cannot verify WHICH seeds were used at each extension
4. Cannot confirm F/P obligations were properly witnessed

**The single-witness vs multi-witness gap**:
- WORKS: `temporal_witness_seed_consistent` - if F(psi) in M, then {psi} union GContent(M) is consistent
- FAILS: Multiple F-obligations may conflict ({p, neg p} from F(p) and F(neg p))
- This is not a proof gap - it's a mathematical impossibility

### 4. DovetailingChain Comparison

| Criterion | ZornFamily | DovetailingChain |
|-----------|------------|------------------|
| Total sorries | 6 active | 4 |
| Mathematically FALSE lemmas | 3 | 0 |
| Solvable now | 0 | 2 (cross-sign) |
| Construction trace available | No | Yes |
| F/P witness mechanism | Implicit (Zorn maximality) | Explicit (dovetailing enumeration) |

**DovetailingChain sorries**:
| Line | Type | Solvability |
|------|------|-------------|
| 606 | forward_G cross-sign | **SOLVABLE** - same collect-into-one-MCS as Zorn cross-sign |
| 617 | backward_H cross-sign | **SOLVABLE** - symmetric |
| 633 | forward_F witnesses | Requires enumeration tracking (not consistency argument) |
| 640 | backward_P witnesses | Symmetric |

### 5. Salvageable Infrastructure from Zorn Work

**Fully proven lemmas that transfer directly**:
- `GHCoherentPartialFamily` structure concept
- `GContent_consistent`, `HContent_consistent`
- `GContent_propagates_forward`, `HContent_propagates_backward` (4-axiom)
- `temporal_witness_seed_consistent`, `temporal_witness_seed_consistent_past` (single-witness)
- Chain upper bound construction pattern

**Cross-sign consistency argument** (works for both approaches):
```
When both past and future domain times exist:
1. All past elements collect into mcs(s_max) via 4-axiom propagation
2. All future elements collect into mcs(s_min) via backward propagation
3. Since s_max < t < s_min, forward_G connects them
4. Everything ends up in mcs(s_min), which is consistent as MCS
```

## Synthesis

### Conflicts Resolved

No conflicts between teammates. Both independently concluded:
1. Zorn approach has fundamental mathematical blockers (FALSE lemmas)
2. DovetailingChain is more tractable
3. Cross-sign case is solvable with same argument for both approaches
4. F/P witness tracking requires construction trace that Zorn hides

### Gaps Identified

1. **Cross-sign implementation**: The argument is well-understood but not yet implemented for DovetailingChain
2. **F/P enumeration tracking**: DovetailingChain needs infrastructure to track which F/P obligations have been witnessed during dovetailing construction
3. **GH-controlled Lindenbaum**: Alternative approach if DovetailingChain pivot is not preferred (6-8 hours estimated)

### Recommendations

**Primary Recommendation: Pivot to DovetailingChain**

Rationale:
- 4 sorries vs 6 active sorries in Zorn
- 2 of 4 are immediately solvable (cross-sign)
- Remaining 2 are enumeration problems, not consistency impossibilities
- Explicit construction provides trace for F/P verification
- Estimated effort: 6-9 hours

**Implementation steps**:
1. Factor out cross-sign collection lemma as shared infrastructure (2 hours)
2. Apply to DovetailingChain lines 606, 617 (1-2 hours)
3. Design F/P witness enumeration tracking (3-5 hours)
4. Document Zorn approach lessons and archive

**Secondary Recommendation: Accept Technical Debt**

If DovetailingChain pivot is not desired:
- Delete FALSE lemmas from ZornFamily with counterexample documentation
- Prove cross-sign case only (line 888)
- Accept remaining sorries as documented technical debt
- Mark task as [PARTIAL] with clear remediation path
- Estimated effort: 2-3 hours

## Hard Constraints for Any Solution

Any viable approach to temporal coherent family existence must satisfy ALL of these:

1. **No multi-witness seed placement**: Cannot place multiple F-witnesses simultaneously
2. **Single-witness only**: Use `temporal_witness_seed_consistent` pattern
3. **Cross-sign requires both directions**: Extension at time t needs domain times on both sides
4. **Some families cannot be extended**: Conflicting F-obligations at boundaries block growth
5. **Construction trace required for F/P**: Must track which obligations were witnessed

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Systematic implementation analysis | completed | medium-high |
| B | Alternative approaches analysis | completed | medium-high |

## Decision Matrix

| Approach | Effort | Sorry-Free? | Risk | Recommendation |
|----------|--------|-------------|------|----------------|
| DovetailingChain pivot | 6-9 hours | Possibly (2 sorries remain) | Medium | **Primary** |
| Combined one-at-a-time + GH-Lindenbaum | 12-17 hours | Possibly (0 sorries if successful) | High | Only if time permits |
| Accept Zorn debt | 2-3 hours | No (6 sorries, 3 mathematically false) | Low | If blocked status OK |

## References

- Implementation plans: `specs/870_zorn_family_temporal_coherence/plans/implementation-{001-004}.md`
- Implementation summaries: `specs/870_zorn_family_temporal_coherence/summaries/*.md`
- Research reports: `specs/870_zorn_family_temporal_coherence/reports/research-{001-007}.md`
- Task 880: `specs/880_augmented_extension_seed_approach/reports/research-001.md`
- ZornFamily.lean: `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean`
- DovetailingChain.lean: `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Proof debt policy: `.claude/context/project/lean4/standards/proof-debt-policy.md`

## Next Steps

Based on user choice:

**If DovetailingChain pivot**:
1. Create new task for DovetailingChain completion
2. Port cross-sign argument to DovetailingChain (lines 606, 617)
3. Design F/P enumeration tracking
4. Archive ZornFamily attempt with lessons learned

**If Accept Technical Debt**:
1. Delete FALSE lemmas with counterexample documentation
2. Prove cross-sign case (line 888)
3. Update SORRY_REGISTRY.md
4. Mark task as [PARTIAL]
