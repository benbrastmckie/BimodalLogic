# Research Report: Task #870 (Diagnostic Update)

**Task**: 870 - Zorn-based family selection for temporal coherence
**Date**: 2026-02-12
**Mode**: Team Research (3 teammates)
**Focus**: Analyze blockers and propose plan revisions

## Executive Summary

Team research identified **critical flaws** in the current proof approach and proposed **concrete solutions**:

1. **Critical Finding**: The multi-witness proof sketch is fundamentally flawed because **G does NOT distribute over disjunction** in temporal logic
2. **Recommended Solution**: Restructure to use **boundary-only domain extension** - eliminates extendFamily sorries entirely
3. **Alternative**: Use **induction on witness count** for multi-witness consistency

## Team Contributions

| Teammate | Focus | Key Finding |
|----------|-------|-------------|
| A | State Analysis | 12 sorries, line 650 is root blocker |
| B | Multi-Witness Patterns | G ≠ distribute over ∨ (proof sketch broken) |
| C | ExtendFamily Alternatives | Boundary-only extension eliminates sorries |

## Critical Finding: Broken Proof Sketch

### The Flaw (Teammate B)

The proof sketch at lines 591-607 assumes:
```
G(neg(psi_1) | neg(psi_2) | ...) in M
implies
G(neg(psi_1)) | G(neg(psi_2)) | ... in M (or at least some G(neg(psi_j)) in M)
```

**THIS IS FALSE.** G does NOT distribute over disjunction.

**Counter-example**:
- G(rain | snow) can be true (at all future times, it rains or snows)
- But G(rain) and G(snow) can both be false (neither always happens)

This invalidates the entire multi_witness_seed_consistent proof strategy.

### Impact

- Lines 650, 680 cannot be proven with current strategy
- Lines 926, 1066 are blocked on these
- The proof approach needs fundamental restructuring

## Recommended Plan Revision

### Approach 1: Boundary-Only Domain Extension (Teammate C - RECOMMENDED)

**Key Insight**: The extendFamily sorries (lines 1311, 1342) arise because we try to extend at arbitrary times. If we only extend at **boundary times** (greater than ALL or less than ALL existing domain elements), the problematic cases become vacuously true.

**Changes Required**:

1. **Add boundary predicate**:
```lean
def isBoundaryTime (F : GHCoherentPartialFamily) (t : Int) : Prop :=
  t ∉ F.domain ∧ ((∀ s ∈ F.domain, s < t) ∨ (∀ s ∈ F.domain, t < s))
```

2. **Modify extendFamily** to require boundary condition
   - forward_G from new time: vacuously true (no s' > t in domain)
   - backward_H from new time: vacuously true (no s' < t in domain)

3. **Restructure maximal_implies_total**:
   - Old: "If t missing, add t" - fails for non-boundary t
   - New: "If t missing, add boundary time adjacent to the gap first"
   - Prove: every non-total domain has a boundary time that can be added

**Estimated effort**: ~170 lines changed, primarily in maximal_implies_total

### Approach 2: Induction on Witness Count (Teammate B - Alternative)

For multi_witness_seed_consistent_future/past, use induction instead of the broken disjunction approach:

**Base case (k=0)**: GContent(M) is consistent ✓ (already proven)
**Base case (k=1)**: Single witness case ✓ (temporal_witness_seed_consistent)
**Inductive step**: Adding one more psi to consistent set preserves consistency

**Key lemma needed**:
```lean
lemma extend_single_witness_consistency (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (S : Set Formula) (psi : Formula)
    (h_F : Formula.some_future psi ∈ M)
    (h_G_sub : GContent M ⊆ S)
    (h_cons : SetConsistent S) :
    SetConsistent (insert psi S)
```

This may still be difficult but avoids the G-distribution fallacy.

## Revised Phase Structure

### Recommended Plan v003

**Phase 1**: Boundary Extension Infrastructure (NEW)
- Add isBoundaryTime predicate
- Modify extendFamily to require boundary
- Simplify forward_G/backward_H proofs (they become trivial)
- Effort: 2-3 hours

**Phase 2**: Restructure Maximal Implies Totality (REVISED)
- New lemma: non-total domain has boundary time
- New proof: fill domain from boundaries inward
- Effort: 4-6 hours

**Phase 3**: Extension Seed Consistency (SIMPLIFIED)
- Cross-sign case: may become unnecessary with boundary-only approach
- Pure past/future: with boundary extension, these simplify significantly
- Effort: 2-3 hours

**Phase 4**: F/P Recovery (UNCHANGED)
- Should follow naturally once Phases 1-3 complete
- Effort: 1-2 hours

**Total revised estimate**: 9-14 hours (down from 12-16)

## Current Sorry Analysis (Teammate A)

| Line | Phase | Type | Status with New Approach |
|------|-------|------|--------------------------|
| 650 | 3 | multi-witness future | May be avoidable with boundary approach |
| 680 | 3 | multi-witness past | May be avoidable with boundary approach |
| 694 | 3 | cross-sign | Simplifies with boundary extension |
| 926 | 3 | F-obligations | Simplifies with boundary extension |
| 1066 | 3 | P-obligations | Simplifies with boundary extension |
| 1311 | 5 | forward_G | **ELIMINATED** by boundary requirement |
| 1342 | 5 | backward_H | **ELIMINATED** by boundary requirement |
| 1477 | 6 | F recovery | Depends on Phases 1-3 |
| 1486 | 6 | F alias | Auto-resolves |
| 1522 | 6 | P recovery | Depends on Phases 1-3 |
| 1530 | 6 | P alias | Auto-resolves |

**Key insight**: Boundary-only extension **eliminates 2 sorries outright** (1311, 1342) and likely simplifies several others.

## Conflicts and Resolutions

### Conflict: Multi-Witness Strategy

- **Teammate B**: Recommends induction approach, notes G-distribution is wrong
- **Teammate C**: Recommends bypassing multi-witness via boundary extension

**Resolution**: Boundary extension (Teammate C) is preferred because:
1. Eliminates sorries rather than finding new proof strategies
2. Structural change is cleaner than complex derivation manipulation
3. May make multi-witness theorems unnecessary for seed consistency

### No other conflicts identified

## Recommendations

### Immediate Action

1. **Create revised plan v003** incorporating boundary-only extension approach
2. **Implement isBoundaryTime predicate** and test it
3. **Prototype simplified extendFamily** to verify sorries disappear

### Do NOT Continue With

1. Current multi-witness proof strategy (fundamentally broken)
2. Trying to prove G distributes over disjunction (it doesn't)

### Long-Term Consideration

If boundary-only approach proves difficult, consider:
- Two-phase construction: Use DovetailingChain for initial segment, Zorn for extension
- Accept multi-witness theorems as axioms with documentation (not recommended)

## References

### Teammate Reports
- `specs/870_zorn_family_temporal_coherence/reports/teammate-a-findings.md`
- `specs/870_zorn_family_temporal_coherence/reports/teammate-b-findings.md`
- `specs/870_zorn_family_temporal_coherence/reports/teammate-c-findings.md`

### Previous Research
- research-001.md: Initial approach
- research-002.md: Deep-dive unified solution
- research-003.md: Implementation diagnostic

### Code Files
- `Theories/Bimodal/Metalogic/Bundle/ZornFamily.lean` - Main implementation
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Single-witness proof
