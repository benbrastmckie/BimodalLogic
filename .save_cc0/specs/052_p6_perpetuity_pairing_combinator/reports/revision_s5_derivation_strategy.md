# Revision Research: S5 Derivation Strategy for P6 Plan

## Context

The P6 implementation plan (001-p6-perpetuity-pairing-combinator-plan.md) originally proposed adding S5 Modal Axiom 5 (`◇φ → □◇φ`) as a new axiom to the TM logic system. However, the P5 implementation plan (050_p5_perpetuity_s5_derivation) demonstrates that this property is **derivable** from existing TM axioms without adding any new axioms.

## P5 Plan Key Insights

The P5 plan establishes that `modal_5` (the S5 characteristic for diamond) can be derived as follows:

### Phase 1 of P5: Diamond-4 Derivation
- **Theorem**: `diamond_4 : ⊢ φ.diamond.diamond.imp φ.diamond`
- **Strategy**: Apply M4 (`□φ → □□φ`) to `¬φ`, then contrapose
- **No new axioms required**

### Phase 2 of P5: Modal-5 Derivation
- **Theorem**: `modal_5 : ⊢ φ.diamond.imp φ.diamond.box`
- **Strategy**: Compose MB on `◇φ` with lifted `diamond_4`
  1. MB on `◇φ`: `⊢ ◇φ → □◇◇φ`
  2. Necessitate `diamond_4`: `⊢ □(◇◇φ → ◇φ)`
  3. MK distribution: `⊢ □◇◇φ → □◇φ`
  4. Compose: `⊢ ◇φ → □◇φ`
- **No new axioms required**

## Impact on P6 Plan

### Phase 1 (S5 Axiom Addition) - REMOVE ENTIRELY
The original Phase 1 proposed:
- Adding `modal_5` constructor to `Axiom` inductive type
- Proving soundness of `modal_5` axiom
- Adding test for `modal_5` axiom
- Updating CLAUDE.md axiom count (12 → 13)

**This entire phase should be removed** because:
1. P5 plan derives `modal_5` as a theorem, not an axiom
2. No changes to Axioms.lean needed
3. No soundness proof needed (theorems are automatically sound)
4. No axiom count increase
5. No test for axiom needed (theorem test is in P5 plan)

### Phase 2 (Persistence and P5) - UPDATE DEPENDENCY
- Remove dependency on Phase 1 (axiom addition)
- Add dependency on P5 plan completion (provides `modal_5` theorem)
- Strategy for `persistence` lemma remains the same (uses `modal_5`)
- P5 derivation remains the same (uses `persistence`)

### Phases 3-4 (Duality and P6) - NO CHANGES
- These phases don't depend on how `modal_5` is obtained
- Strategy remains unchanged

### Phase 5 (Pairing) - NO CHANGES
- Independent of S5-related work

## Revised Dependencies

### Original Dependency Chain
```
Phase 1 (add axiom) → Phase 2 (P5) → Phases 3-4 (P6)
                                   ↗
                      Phase 3 (duality)
```

### Revised Dependency Chain
```
P5 Plan (derive modal_5) → Phase 1 (P5 + persistence) → Phase 2 (P6)
                                                      ↗
                           Phase 2 depends on duality lemmas
```

## Files Affected by Revision

### Files NO LONGER Modified (removed from plan)
- Logos/Core/ProofSystem/Axioms.lean (no axiom addition)
- Logos/Core/Metalogic/Soundness.lean (no soundness proof)
- LogosTest/Core/ProofSystem/AxiomsTest.lean (no axiom test)

### Files Still Modified
- Logos/Core/Theorems/Perpetuity.lean (persistence, P5, P6 theorems)
- LogosTest/Core/Theorems/PerpetuityTest.lean (theorem tests)
- TODO.md (task updates)
- Documentation/ProjectInfo/SORRY_REGISTRY.md (remove persistence sorry)
- CLAUDE.md (update perpetuity status only, NOT axiom count)

## Estimated Effort Changes

| Phase | Original Hours | Revised Hours | Reason |
|-------|----------------|---------------|--------|
| Phase 1 (axiom) | 3-5 | 0 | Removed entirely |
| Phase 2 (P5) | 4-6 | 2-3 | Simpler (assumes modal_5 available) |
| Phase 3 (duality) | 10-14 | 10-14 | No change |
| Phase 4 (P6) | 6-10 | 6-10 | No change |
| Phase 5 (pairing) | 8-12 | 8-12 | No change |
| **Total** | **31-47** | **26-39** | ~5-8 hours saved |

## Revision Summary

1. **Delete Phase 1** (S5 axiom addition) - not needed
2. **Renumber remaining phases** (2→1, 3→2, 4→3, 5→4)
3. **Add prerequisite** dependency on P5 plan completion
4. **Update file modification summary** to remove axiom-related files
5. **Update LOC estimates** to reflect reduced scope
6. **Update documentation section** to clarify P5 plan dependency

## Conclusion

The P6 plan should be revised to leverage the P5 plan's derivation of `modal_5` as a theorem rather than adding it as a new axiom. This simplifies the implementation, maintains the existing axiom count (12), and creates a cleaner logical structure where the S5 characteristic property emerges from the existing TM axioms rather than being posited independently.
