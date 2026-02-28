# Research Report: Task #881 (Team Research v4)

**Task**: Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-13
**Mode**: Team Research (2 teammates)
**Session**: sess_1771025990_5d87c1

## Summary

Team research investigating whether constant witness families are mathematically necessary and what the mathematically correct path forward is. **Key conclusion**: Constant families are a **design choice for simplification**, not a mathematical necessity. The BMCS approach correctly implements product frame semantics for S5 × temporal logic. For a fully zero-compromise completeness theorem covering ALL formulas (including `Box(G φ)`), witness families must be temporally coherent, which requires building them via dovetailing construction rather than as constant families. The 4 DovetailingChain sorries are the key blockers.

## Key Findings

### Finding 1: Constant Families are a Design Choice, Not Mathematical Necessity

**Teammate A** analyzed the codebase and found that constancy is explicitly documented as a simplification (SaturatedConstruction.lean:453-460):

> "To simplify the proof, we work with constant families where mcs t = mcs s for all t, s."

**Why constancy was chosen**:
1. **Time-invariant BoxContent**: Makes witness seed construction tractable
2. **Simplified box_coherence proofs**: Can check at single time point
3. **Uniform witness construction**: All witnesses use same pattern

**What would be needed without constancy**:
1. Time-indexed BoxContent: `BoxContent(M, t) = {chi | ∃ fam' ∈ M, Box chi ∈ fam'.mcs t}`
2. Cross-time consistency proofs
3. Modified witness construction for non-constant families

### Finding 2: BMCS Approach is Mathematically Correct (Product Frame Semantics)

**Teammate B** confirmed that the BMCS approach correctly implements product frame semantics for S5 × temporal logic:

**Product Frame Definition**: F = (W × T, R_modal, R_temporal) where:
- W = set of S5 worlds (equivalence classes)
- T = time domain (Int)
- R_modal = universal relation within bundle (S5 property)
- R_temporal = ordering on T

**BMCS Correspondence**:
- Each `IndexedMCSFamily` = one S5 "world" (coherent theory across time)
- `modal_forward`/`modal_backward` = universal accessibility within bundle
- Int indexing = temporal positions

**Constant families are semantically valid for S5**: A constant family represents an S5 world that exists uniformly across time, which is standard in S5 semantics.

### Finding 3: The Core Tension - Fully Resolved

**The conflict**:
- Modal saturation creates **constant** witness families (via Lindenbaum)
- Constant families need `F psi → psi` (temporal forward saturation)
- **Proven counterexample**: `{F(p), ¬p}` is consistent but cannot extend to temporally forward-saturated MCS

**Critical insight from Teammate B**: This is a **fundamental property of temporal logic**, not a proof gap. Not every consistent set can extend to a temporally saturated MCS.

**Resolution options**:

| Option | Scope | Complexity | Mathematical Soundness |
|--------|-------|------------|------------------------|
| Eval-only temporal coherence | Formulas without `Box(G/H ...)` | Low | Sound for restricted scope |
| Dovetailing per-witness | ALL formulas | High | Fully sound |
| Truth lemma restructuring | Formulas without `Box(G/H ...)` | Medium | Sound for restricted scope |

### Finding 4: Zero-Compromise Path Forward

For a **fully general completeness theorem** (including `Box(G φ)` formulas), we need:

```lean
theorem fully_saturated_temporally_coherent_bmcs_exists
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (B : BMCS Int),
      (∀ gamma ∈ Gamma, gamma ∈ B.eval_family.mcs 0) ∧
      -- ALL families temporally coherent (not just eval)
      (∀ fam ∈ B.families,
        (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
        (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s)) ∧
      -- Full modal saturation
      is_modally_saturated B
```

**Implementation approach**:

1. **Modify `exists_fullySaturated_extension`** to use temporally coherent witness construction
2. When adding witness W for `Diamond psi`:
   - Build W using dovetailing chain from `{psi} ∪ BoxContent`
   - This gives W with `forward_F` and `backward_P`
   - Adding W preserves `box_coherence` AND temporal coherence

**Pre-requisites**:
- Resolve the 4 DovetailingChain sorries first
- This unblocks the per-witness dovetailing construction

### Finding 5: Why Truth Lemma Restructuring is a Scope Restriction

**Teammate B** traced the truth lemma recursion and found:

Evaluating `Box (G p)` at eval_family:
1. Box case: recurse on `G p` at ALL families (including witnesses)
2. At witness family, evaluate `G p` using G backward case
3. G backward uses `forward_F` of the witness family

**Conclusion**: `Box (G φ)` formulas REQUIRE temporal coherence at witness families.

For formulas WITHOUT nested `Box (G/H ...)` patterns, eval-only temporal coherence suffices. This is a **scope restriction**, not mathematical unsoundness.

## Conflicts Resolved

### Conflict: Is constancy necessary or just convenient?

**Teammate A**: Constancy is a simplification choice, not necessity
**Teammate B**: Constant families are semantically valid for S5 (product frame correspondence)

**Resolution**: Both agree. Constancy is:
- Mathematically valid (correct product frame semantics)
- A simplification choice (not the only way to achieve modal saturation)
- The source of the temporal coherence conflict (requires TemporalForwardSaturated MCS)

### Conflict: Is truth lemma restructuring a compromise?

**Teammate A**: Restructuring is "most promising" alternative
**Teammate B**: Restructuring is a "scope restriction" (excludes `Box(G/H ...)` formulas)

**Resolution**: Both are correct. Restructuring:
- Is mathematically sound for restricted formula class
- Is NOT a full solution for all formulas
- Is a pragmatic step if full solution is deferred

## Gaps Identified

1. **DovetailingChain 4 sorries unresolved**: These block the per-witness construction
2. **No implementation of temporally coherent witness families**: Would require `buildDovetailingChainFamily` per witness
3. **No formal definition of "temporally safe" formulas**: The syntactic class where eval-only coherence suffices

## Recommendations

### Zero-Compromise Path (Recommended)

**Phase 1: Resolve DovetailingChain sorries**
- Fix cross-sign propagation (forward_G, backward_H)
- Implement witness enumeration for F/P formulas
- This is necessary regardless of which path is chosen

**Phase 2: Build temporally coherent witness families**
- Modify `exists_fullySaturated_extension` to use dovetailing per-witness
- Replace `constantWitnessFamily` with `buildDovetailingChainFamily` pattern
- Prove box_coherence is preserved

**Phase 3: Wire to axiom elimination**
- Combine modal saturation with per-family temporal coherence
- Replace `fully_saturated_bmcs_exists_int` axiom with constructed proof

### Pragmatic Path (Alternative)

If zero-compromise is too expensive:

1. **Define "temporally safe" formulas** syntactically (no nested `Box(G/H ...)`)
2. **Document scope restriction** in completeness theorem
3. **Use eval-only temporal coherence** for completeness over safe formulas
4. **Keep the sorry** for full formula completeness as documented technical debt

## Proof Debt Inventory

| Location | Sorries | Nature | Resolution Path |
|----------|---------|--------|-----------------|
| DovetailingChain.lean:606 | 1 | Cross-sign forward_G | Track GContent from all prior MCS |
| DovetailingChain.lean:617 | 1 | Cross-sign backward_H | Symmetric to above |
| DovetailingChain.lean:633 | 1 | forward_F witness | Implement (time, formula) enumeration |
| DovetailingChain.lean:640 | 1 | backward_P witness | Symmetric to above |
| TemporalCoherentConstruction.lean:842 | 1 | BMCS existence | Combine modal + temporal construction |

**Critical path**: DovetailingChain sorries → Temporal witness families → BMCS existence

## Teammate Contributions

| Teammate | Angle | Key Contribution | Confidence |
|----------|-------|------------------|------------|
| A | Constant families analysis | Detailed code trace showing constancy is simplification choice; truth lemma restructuring approach | High |
| B | Mathematical correctness | Product frame validation; full path to zero-compromise; scope analysis of restructuring | High |

## References

### Teammate Reports
- `specs/881_modally_saturated_bmcs_construction/reports/teammate-a-findings.md`
- `specs/881_modally_saturated_bmcs_construction/reports/teammate-b-v4-findings.md`

### Prior Research
- research-006.md: Truth lemma restructuring proposal (this report supersedes)
- research-004.md: Henkin counterexample proof
- research-005.md: Int specialization safety analysis

### Key Code Files
- `SaturatedConstruction.lean`: Modal saturation (sorry-free, constant families)
- `DovetailingChain.lean`: Temporal coherence construction (4 sorries)
- `TruthLemma.lean`: Truth lemma with recursion analysis
- `TemporalCoherentConstruction.lean`: BMCS existence (1 sorry)

## Conclusion

**Answer to user's concern**: Constant families are NOT inherently wrong - they correctly implement S5 product frame semantics. The issue is that they conflict with temporal coherence requirements. The mathematically correct path forward is to:

1. Build witness families via dovetailing (non-constant)
2. This requires resolving DovetailingChain's 4 sorries first
3. The result is a fully general completeness theorem with no scope restrictions

**No compromises needed** - just significant implementation work on the temporal construction.
