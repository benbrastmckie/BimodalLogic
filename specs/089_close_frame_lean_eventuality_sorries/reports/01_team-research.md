# Research Report: Task #89

**Task**: Close 4 Frame.lean eventuality resolution sorries
**Date**: 2026-04-10
**Mode**: Team Research (4 teammates)

## Summary

The 4 Frame.lean eventuality resolution sorries (`bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, `bx_since_backward`) are **accurately described** at lines 653, 675, 690, 704. However, the task description contains significant strategic mischaracterizations: BXCanonical is NOT on the main completeness path, the downstream "automatic closure" claim is false, and the sorries are likely **unprovable as currently stated** (10% confidence) due to the universal quantification over all BXPoints requiring bx_le interval linearity, which is proved false. The most impactful action is re-adding the `temp_linearity` axiom (2-4h), which transforms the problem from 40-80h/intractable to 8-16h/tractable.

## Key Findings

### 1. BXCanonical Is NOT on the Critical Completeness Path (Unanimous, 98% confidence)

All 4 teammates independently confirmed: the BXCanonical module is a **third, independent** completeness approach (Path C). The active completeness path (`completeness_over_Int`) runs through `FrameConditions/Completeness.lean` via dovetailed chains and UltrafilterChain (Path B). `bx_completeness` is never referenced outside `BXCanonical/Completeness.lean`. Closing these 4 sorries does NOT advance the primary representation theorem goal.

### 2. The "Completeness.lean:160 Closes Automatically" Claim Is False

BXCanonical/Completeness.lean:154 has a sorry that depends on MORE than these 4 sorries:
- A canonical TaskModel construction embedding BXPoints into a TaskFrame
- G/H truth lemma cases requiring non-constant histories
- The 4 Until/Since eventuality resolution lemmas

Only the third item is addressed by task 89. The task description should be corrected.

### 3. The Sorries Are Likely Unprovable As Currently Stated (10% confidence of closure)

The universal quantification `∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas` requires proving φ holds at **arbitrary MCS** between w and v, which requires bx_le interval linearity. Report 08 from task 86 proved global bx_le linearity is false. BX7 (Until linearity) is a formula-level axiom within a single MCS and cannot produce ordering relationships between different MCS (Teammate A: 0% confidence for this approach).

The X-vs-G mismatch is well-established empirically (12 dead ends, 6+ months) but Teammate C notes **no formal countermodel has been constructed** to prove impossibility rigorously.

### 4. Re-Adding `temp_linearity` Axiom Is the Highest-Impact Action (90% confidence)

Task 88 research (4 teammates, 95% confidence) identified removal of `temp_linearity` as a mathematical error. The axiom:
- Is semantically valid (sorry-free proof in Soundness.lean:285)
- Was present in every standard axiomatization
- Makes bx_le provably linear (total order on BXPoints)
- **Transforms task 89 from 40-80h to 8-16h**
- Also potentially unblocks the Bundle path's Until/Since coherence

Estimated effort to re-add: 2-4 hours (add Axiom constructor, soundness case, update pattern matches).

### 5. The Until/Since Coherence Problem Is Shared Across All Paths (90% confidence)

The mathematical obstacle is isomorphic in all three completeness paths:
- **Path B (active)**: `forward_until_since_coherent` sorry in FrameConditions/Completeness.lean
- **Path C (BXCanonical)**: The 4 Frame.lean sorries
- **Dovetailed**: `DovetailedFMCS_forward_F/backward_P` (deprecated)

All face the same core challenge: fair scheduling for Until/Since eventuality resolution over g_content-based orderings.

### 6. Mathematical Approaches Assessed

| Approach | Confidence | Effort | Verdict |
|----------|-----------|--------|---------|
| Redefine bx_le via Until witnesses | 15% | 25-35h | Breaks G truth lemma; cascading reproofs |
| Quasimodel/Filtration (GHR 1994) | 60% | 15-25h | Sound but requires large new infrastructure |
| Interval linearity from BX7 | 0% | N/A | Provably blocked (formula-level vs MCS-level) |
| Burgess-style chain construction | 45-55% | 15-20h | Most aligned with Bundle architecture |
| Signature weakening | Viable | 10-15h | Converts BXCanonical into chain-based (loses identity) |
| Re-add temp_linearity + close directly | 90% | 8-16h | **Recommended** |

## Synthesis

### Conflicts Resolved

1. **Abandon vs. Fix**: Teammate B recommends abandoning entirely; Teammate D recommends axiom re-addition first. **Resolution**: These are compatible. WITHOUT temp_linearity, abandon is correct (90% confidence sorries are unprovable). WITH temp_linearity, the sorries become tractable. The decision hinges on whether the axiom is re-added.

2. **Quasimodel viability**: Teammate A gives 60% confidence; Teammate C notes it's unvalidated for this axiom set; Teammate D cites GHR linearization issues. **Resolution**: Quasimodel is the best pure-math approach IF temp_linearity is not re-added, but it's heavy (15-25h, 2000 LOC) and uncertain. Axiom re-addition is strictly preferable.

3. **BXCanonical value**: Teammates B and C question investing in a non-critical-path module. Teammate D identifies fragment completeness publication value and reusable infrastructure. **Resolution**: BXCanonical has value as reference infrastructure and for a fragment completeness publication, but should not be prioritized over Path B work.

### Gaps Identified

1. **No formal impossibility proof**: The X-vs-G mismatch is empirically strong but lacks a formal countermodel. A 2-MCS counterexample would establish impossibility at 100% confidence.

2. **BX6+BX7 combination unexplored**: Teammate C asks whether absorption (BX6) + linearity (BX7) together yield a form of Until-induction. This specific combination has not been investigated.

3. **temp_linearity recommendation from task 88 was not acted upon**: The most impactful research finding from task 88 (re-add the axiom, 2-4h) was not implemented. Task 88 instead chose deletion of CanonicalEmbedding.lean.

4. **Since cases assumed to mirror Until**: The h_content infrastructure for Since has not been independently verified (Teammate C).

### Recommendations

**Priority 1 (2-4h)**: Re-add `temp_linearity` axiom. This unblocks both BXCanonical and potentially the Bundle path. It is mathematically correct and was erroneously removed.

**Priority 2 (8-16h)**: IF temp_linearity is re-added, close the 4 Frame.lean sorries using standard canonical model techniques with linear bx_le.

**Priority 3 (0h alternative)**: IF temp_linearity is NOT re-added, mark the 4 sorries as deprecated/not-on-critical-path and focus on task 83's restricted coherence path instead. Keep BXCanonical as reference infrastructure.

**Priority 4 (1-2h)**: Close task 82 (FMP, 2 sorries) for independent publication value, regardless of task 89 disposition.

**Task description corrections needed**:
- Remove "Completeness.lean:160 closes automatically" (false)
- Add acknowledgment that BXCanonical is not on the main completeness path
- Condition effort estimate on temp_linearity: 8-16h WITH axiom, 40-80h WITHOUT (and likely to fail)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary mathematical approaches | completed | Medium (55% for best approach) |
| B | Alternative patterns and bypass | completed | High (90% sorries unprovable as-is) |
| C | Critic (assumptions, gaps, accuracy) | completed | High (task description misleading) |
| D | Strategic horizons and cross-task | completed | High (temp_linearity is key enabler) |

## References

### Codebase
- `Theories/Bimodal/Metalogic/BXCanonical/Frame.lean` — 4 sorry sites (lines 653, 675, 690, 704)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — Additional sorry (line 154)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — BX1-BX12 axiom definitions
- `specs/ROAD_MAP.md` — Completeness architecture and dead ends
- `specs/086_close_bxcanonical_completeness_sorries/reports/08_bxle-linearity-research.md` — bx_le linearity proved false

### Literature
- Burgess (1982/1984): Step-by-step chain construction for Until completeness
- Goldblatt (1992): Discrete frame completeness with Next operator
- Gabbay-Hodkinson-Reynolds (1994): Quasimodel approach for real-time temporal logic
- Venema (1993): Extensions to strict linear orderings
