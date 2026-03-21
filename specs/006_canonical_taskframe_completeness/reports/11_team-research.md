# Research Report: Pure-Syntax D vs Parametric D - Decision Analysis

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Mode**: Team Research (2 teammates)
**Session**: sess_1774032038_e78030
**Focus**: Advantages of pure-syntax D construction, torsor approach feasibility, and potential blockers

## Executive Summary

The user asks whether pursuing the torsor approach (D = Aut+(T)) is worth the investment in proving Holder's theorem and homogeneity.

**Bottom Line**: The torsor approach is philosophically compelling but carries medium risk. For Task 1006's immediate goal (completeness theorems), Cantor transfer is safer. However, if the "structure from axioms" vision is a priority, the torsor approach is achievable with ~180 lines of new proofs and has no identified blocking dependencies.

---

## Team Contributions

| Teammate | Focus | Key Finding | Confidence |
|----------|-------|-------------|------------|
| A | Philosophical advantages | Pure-syntax D provides modularity; same construction for all logic variants | High |
| B | Feasibility/blockers | Torsor viable (~180 lines); main risk is base logic homogeneity | Medium-High |

No conflicts. Both converge on: Cantor transfer is safer; torsor is worthwhile if "structure from axioms" matters.

---

## Key Findings

### 1. Advantages of Pure-Syntax D (Teammate A)

**Philosophical Value**:

| Approach | D Definition | Source of Structure |
|----------|--------------|---------------------|
| Parametric | D = Int or Rat | External object imported |
| Pure-Syntax | D = Aut+(T) | Intrinsic, derived from axioms |

With parametric D, we *impose* algebraic structure. With torsor D, the algebraic structure is a *consequence* of the modal axioms - density forces dense action, which (via Holder) forces commutativity.

**Modularity Advantage**:

```
Base Logic → CanonicalTimeline → D = Aut+(T) (AddGroup)
  + DN axiom → DenselyOrdered T → D ≃ (Rat, +) via Holder
  + DF/DB axioms → LocallyFiniteOrder T → D ≃ (Int, +)
```

The **same D = Aut+(T) construction** works for all variants. The specific algebraic structure emerges from axiom-driven properties of T.

**Practical Impact**:

| Aspect | Pure-Syntax D | Parametric D |
|--------|---------------|--------------|
| Initial setup | Harder (Holder + homogeneity) | Simpler |
| Understanding *why* | Clear causal chain | Structure appears ad hoc |
| Extending to variants | Same construction | Separate D for each |
| Truth lemma | Same complexity | Same complexity |

### 2. Torsor Approach Feasibility (Teammate B)

**What Must Be Proven**:

| Requirement | Estimated Lines | Status | Blocking? |
|-------------|-----------------|--------|-----------|
| Holder's theorem | ~80 | Not in Mathlib | No - standard proof available |
| Homogeneity (AddTorsor) | ~100 | Needs back-and-forth | No - pattern exists |
| Countability of T | ~20 | Pattern in ConstructiveFragment.lean | No |
| Rigidity (for Holder) | ~15 | Follows from no-endpoints | No |
| **Total** | **~180** | | **No blockers identified** |

**Dependency Analysis** (No Circularity):

```
TaskFrame D requires:
  ├── AddCommGroup D
  │     ├── Holder's theorem
  │     │     ├── Rigidity (from no-fixed-points in dense order)
  │     │     └── Bi-invariant order (from order-preservation)
  │     └── [Independent of AddTorsor]
  └── AddTorsor D T
        ├── Homogeneity (back-and-forth)
        │     ├── Countable T
        │     └── No endpoints (from seriality saturation)
        └── [Independent of Holder]
```

**Risk Assessment**:

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Holder proof harder than expected | Low | Medium | Mathlib OrderedGroup infrastructure helps |
| Homogeneity fails for base logic | **Medium** | Medium | Conservative extension argument |
| Countability gaps | Low | Medium | Follow ConstructiveFragment pattern |
| Overall success probability | **70-80%** | | |

### 3. The "Structure from Axioms" Vision Concretized

**How It Works**:

| Logic | Axioms Added | T Properties | D Properties |
|-------|--------------|--------------|--------------|
| Base | (none) | Linear, countable | AddGroup |
| Dense | +DN | +DenselyOrdered | +Archimedean → abelian |
| Discrete | +DF/DB | +LocallyFiniteOrder | +Cyclic (≃ Int) |

**Critical Insight**: For base logic, D is only AddGroup - we need additional structure (from DN or homogeneity argument) to get AddCommGroup. This is the main uncertainty.

### 4. Comparison: Torsor vs Cantor Transfer

| Aspect | Torsor (D = Aut+(T)) | Cantor (D = Rat via ≃o) |
|--------|---------------------|-------------------------|
| Works for | Base, dense, discrete | Dense only (or conservative ext) |
| New proof work | ~180 lines | 0 lines |
| Philosophical purity | High (structure from syntax) | Medium (Rat as canonical representative) |
| Risk level | Medium | Low |
| Long-term value | High (unified construction) | Medium (case-by-case) |

### 5. The Sign-Only Observation

From `ParametricCanonical.lean`, the task relation only uses the **sign** of d:

```lean
parametric_canonical_task_rel M d N :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

**Implication**: The AddCommGroup structure is required by frame axioms (nullity, compositionality, converse), not by temporal operator evaluation. Both approaches satisfy these axioms - the difference is where the structure comes from.

### 6. Potential Blockers Assessment

**Identified Blockers**:

| Issue | Status | Severity |
|-------|--------|----------|
| F/P "off-chain" witnesses | Documented in 09_fp-crux-analysis.md | **Shared by both approaches** |
| Base logic homogeneity | Uncertain | Medium (can use conservative ext) |
| Holder not in Mathlib | Expected | Low (standard proof) |

**Non-Blockers** (confirmed):

- Countability: Pattern exists in ConstructiveFragment.lean
- LinearOrder on T: Proven in BidirectionalReachable.lean
- No endpoints: Follows from seriality saturation
- Circularity: None detected in dependency chain

---

## Synthesis: Is the Torsor Approach Worth It?

### Arguments FOR Pursuing Torsor:

1. **Unified construction**: Same D = Aut+(T) for base/dense/discrete
2. **Structure from axioms**: D's properties become theorems, not assumptions
3. **Future-proof**: New logic variants automatically inherit correct D
4. **Philosophically satisfying**: Duration structure is discovered, not imposed
5. **Modest effort**: ~180 lines for full infrastructure

### Arguments AGAINST (for now):

1. **Task 1006 scope**: Immediate goal is completeness, not philosophical purity
2. **Cantor transfer exists**: Working code in Boneyard for dense case
3. **Base logic uncertainty**: May need conservative extension anyway
4. **Risk**: New proofs could uncover unexpected issues

### Decision Framework

**If philosophical purity is a priority**: Pursue torsor approach.
- Effort: ~2-4 hours for Holder + homogeneity
- Risk: Medium (70-80% success)
- Payoff: D emerges from axioms; unified construction for all variants

**If practical completion is the priority**: Use Cantor transfer.
- Effort: 0 (existing code)
- Risk: Low
- Payoff: Dense completeness done; defer philosophical concerns

**Compromise**: Cantor transfer for Task 1006, create follow-up task for torsor construction.

---

## Recommendations

### For Task 1006 (Immediate)

Use **Cantor isomorphism transfer** for dense completeness:
- DovetailedTimelineQuot ≃o Rat is PROVEN
- Transfer AddCommGroup from Rat
- Focus effort on F/P infrastructure (Phase 1 of v4 plan)

### For Future Work (Recommended Follow-Up)

Create new task: "Establish pure-syntax D via torsor construction"
1. Prove Holder's theorem (~80 lines)
2. Prove homogeneity via back-and-forth (~100 lines)
3. Wire to base completeness
4. Document as alternative to Cantor transfer

This gives the "structure from axioms" result without blocking Task 1006 progress.

### Base Completeness Path

**Option A** (Simpler): Conservative extension
- Base-valid ⊆ Dense-valid (show inclusion)
- Use dense completeness (Cantor transfer) for base

**Option B** (If torsor done): Direct torsor construction
- Use D = Aut+(T) for base logic
- Requires homogeneity to hold (may need seriality saturation)

---

## Gaps and Uncertainties

1. **Base logic homogeneity**: Not proven that Aut+(T) is transitive for base logic timeline. May require seriality saturation or fall back to conservative extension.

2. **Countability verification**: ConstructiveFragment pattern exists but not yet applied to BidirectionalQuotient explicitly.

3. **Holder proof complexity**: Estimated 80 lines; could be more if bi-invariance proof is subtle.

4. **F/P infrastructure**: The "off-chain" witness problem (09_fp-crux-analysis.md) affects both approaches equally. This remains the critical path blocker.

---

## Conclusion

The torsor approach is **viable and philosophically compelling** but represents a medium-risk investment of ~180 lines of new infrastructure. For Task 1006's immediate goals, Cantor transfer is recommended. The torsor approach should be pursued as a follow-up task if "structure from axioms" is valued.

The key remaining blocker for both approaches is the F/P witness problem, which is the focus of Phase 1 in the current implementation plan.

---

## References

- `TranslationGroup.lean` - Existing torsor construction (AddGroup proven)
- `BidirectionalReachable.lean` - Timeline construction (LinearOrder proven)
- `ConstructiveFragment.lean` - Countability pattern
- `09_fp-crux-analysis.md` - F/P blocker documentation
- `10_team-research.md` - Previous team research
- [Archimedean group - Wikipedia](https://en.wikipedia.org/wiki/Archimedean_group) - Holder's theorem background
