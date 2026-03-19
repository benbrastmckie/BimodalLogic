# Team Research Report: Task #982

**Task**: Wire dense completeness domain connection
**Date**: 2026-03-17
**Mode**: Team Research (2 teammates)
**Session**: sess_1773784620_425488

## Summary

Two research teammates conducted parallel investigation into the mathematically correct approach for the TM base logic and dense/discrete extensions, focusing on whether each proof system should generate an appropriate parametric D with the right properties for frame construction, canonical model, and TruthLemma establishment.

**Consensus Finding**: The forward_F gap in TimelineQuot is a **genuine architectural issue**, not a proof engineering problem. The "m > 2k" case (where a StagedPoint enters after its F-formula was processed) cannot be closed within the current staged construction. However, this gap can be bypassed entirely by working at the family level rather than the time level.

**Strategic Recommendation**: Use **Path B** (BFMCS Rat with witness families) for 10-15 hours of work, leveraging existing sorry-free infrastructure. The mathematically "purer" fix (dovetailing the staged construction) is 15-20 hours but gives a cleaner result.

---

## Key Findings

### Finding 1: The LinearOrder Constraint is Localized (HIGH confidence)

Both teammates independently identified that `[LinearOrder D]` in ParametricTruthLemma is used in exactly ONE place: `parametric_box_persistent` (line 155), which calls `lt_trichotomy`. The main truth lemma inductive cases only require `Preorder`.

**Implication**: If completeness can avoid `parametric_box_persistent` or if a Preorder-compatible version can be built, CanonicalMCS becomes viable as D directly.

### Finding 2: The forward_F Gap is Genuine and Fundamental (HIGH confidence)

The staged construction adds F-witnesses at stage 2k+1 for formula encoded as k. Points entering at stage m > 2k have no guarantee their F-witnesses were added. This is the "m > 2k" edge case documented in ClosureSaturation.lean:378-658.

**Standard completeness proofs use dovetailing enumeration** of (time, formula) pairs to ensure fairness. The current staged construction uses a simpler enumeration without this guarantee.

### Finding 3: CanonicalMCS has Sorry-Free F/P Witnesses (HIGH confidence)

`canonicalMCS_forward_F` and `canonicalMCS_backward_P` are **sorry-free** because when D = CanonicalMCS, every witness MCS is automatically in the domain. The coverage problem disappears when using all MCSs.

**Key insight**: The gap is not about witness existence but about witness domain membership.

### Finding 4: Modal Saturation Resolves modal_backward (HIGH confidence)

`saturated_modal_backward` in ModalSaturation.lean is sorry-free. Any BFMCS proven `is_modally_saturated` gets `modal_backward` for free. This resolves the blocking sorry in both task 982 and task 987.

### Finding 5: Standard Completeness Proofs Construct D from Syntax (HIGH confidence)

Goldblatt/BdRV completeness proofs treat D as **constructed from MCSs** via quotient + characterization. The axioms (DN, DF) constrain algebraic properties of D, not its carrier type. The codebase pipeline matches this standard approach.

---

## Synthesis

### Conflicts Resolved

| Aspect | Teammate A | Teammate B | Resolution |
|--------|-----------|-----------|------------|
| Primary recommendation | Fix staged construction (dovetailing) | Use BFMCS Rat with witness families | **Both viable**; B is faster, A is cleaner |
| LinearOrder handling | Preorder truth lemma (8-12h new work) | Use Rat (already LinearOrder) | **Use Rat** - leverages existing infrastructure |
| forward_F fix | Dovetailing enumeration | Witness families at FAMILY level | **Witness families** - existing proofs suffice |

### Gaps Identified

1. **CanonicalMCS → Rat bridge**: The Cantor isomorphism maps TimelineQuot to Rat, but witness families need explicit construction
2. **Shift-closed Omega dependency**: May need simplification to avoid `parametric_box_persistent`
3. **Task 987 parallel blocker**: Same `modal_backward` + `forward_F` sorries exist there

---

## Recommended Architecture

### The Mathematically Correct Approach

Each proof system (base, dense, discrete) should generate its own D:

| System | D Construction | Properties |
|--------|---------------|------------|
| Base TM | CanonicalMCS (Preorder) | Just Preorder |
| Dense TM | TimelineQuot → Rat via Cantor | LinearOrder + DenselyOrdered + AddCommGroup |
| Discrete TM | DiscreteTimelineQuot → Int | LinearOrder + SuccOrder + AddCommGroup |

The Truth Lemma works over FMCS D where D has appropriate properties. The frame (WorldState, Omega) uses MCS-based world states, not D-indexed.

### Recommended Path: BFMCS Rat with Witness Families (10-15 hours)

**Phase 1**: Build `BFMCS Rat` where:
- Primary family maps Rat times to MCSs via `cantor_iso.symm` then `timelineQuotMCS`
- Witness families for each F/P obligation: new FMCS Rat rooted at Lindenbaum-extended witness MCS

**Phase 2**: Prove `is_modally_saturated` by construction, apply `saturated_modal_backward`

**Phase 3**: Apply `parametric_algebraic_representation_conditional`

### Alternative Path: Dovetailing (15-20 hours)

Modify staged construction to use dovetailing enumeration of (time, formula) pairs. This is the standard Henkin approach and gives a cleaner result, but requires more infrastructure changes.

---

## Decision Framework for User

| If you want... | Choose... | Effort |
|----------------|----------|--------|
| Fastest path to dense completeness | Path B (Rat witness families) | 10-15h |
| Mathematically cleanest result | Path A (dovetailing fix) | 15-20h |
| Just base completeness now | CanonicalMCS truth lemma | 8-12h |
| Both base and dense | Either path resolves both | - |

**Note**: Task 987 (algebraic base completeness) is blocked by the same sorries. Resolving task 982 via either path also unblocks task 987.

---

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Mathematical foundations | completed | HIGH |
| B | Alternative approaches | completed | MEDIUM-HIGH |

### Teammate A Summary
Focused on standard completeness proof techniques (Goldblatt, BdRV). Identified dovetailing as the mathematically standard approach. Confirmed that CanonicalMCS is complete for F/P witnesses but lacks LinearOrder.

### Teammate B Summary
Focused on existing codebase components and alternatives. Identified that LinearOrder is used only in `parametric_box_persistent`. Confirmed task 987 has identical architecture and blockers.

---

## References

- `CanonicalFMCS.lean:293-311` - Sorry-free `temporal_coherent_family_exists_CanonicalMCS`
- `ModalSaturation.lean` - Sorry-free `saturated_modal_backward`
- `ParametricTruthLemma.lean:155` - Single `lt_trichotomy` usage
- `ClosureSaturation.lean:378-658` - Documented forward_F gap analysis
- `AlgebraicBaseCompleteness.lean` - Task 987 parallel structure

---

## Next Steps

1. **Immediate**: Run `/plan 982` to create revised implementation plan based on Path B (BFMCS Rat with witness families)
2. **Alternative**: If preferring mathematical purity, choose Path A (dovetailing)
3. **Consider**: Creating subtask for task 987 dependency resolution
