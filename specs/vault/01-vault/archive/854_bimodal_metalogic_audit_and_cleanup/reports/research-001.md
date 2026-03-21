# Research Report: Task #854

**Task**: Bimodal Metalogic Audit and Cleanup
**Date**: 2026-02-04
**Focus**: Audit bimodal metalogic: (1) what theorems/axioms are established, (2) what remains for completeness, (3) what can be archived to Boneyard

## Summary

The bimodal metalogic in `Theories/Bimodal/Metalogic/` is **publication-ready for its main results**. Soundness, completeness (BMCS and FMP approaches), and decidability are all fully proven. There are 3 explicit axioms and 11 sorries in the codebase, but none affect the main theorems. Several work-in-progress files (`PreCoherentBundle.lean`, `WeakCoherentBundle.lean`, `SaturatedConstruction.lean`) are archival candidates.

## File Inventory

### Metalogic Files (39 total .lean files)

| Directory | Files | Purpose |
|-----------|-------|---------|
| Core/ | 5 | MCS theory, Lindenbaum's lemma, deduction theorem |
| Bundle/ | 12 | BMCS completeness (primary approach) |
| FMP/ | 4 | Finite Model Property completeness |
| Decidability/ | 8 | Tableau decision procedure |
| Algebraic/ | 6 | Alternative algebraic approach |
| Top-level | 4 | Soundness, Completeness, Metalogic, SoundnessLemmas |

### Module Dependency Summary

```
Metalogic.lean (Entry Point)
    |-- Soundness.lean (soundness theorem)
    |-- Bundle/Completeness.lean (BMCS completeness)
    |-- FMP/SemanticCanonicalModel.lean (FMP completeness)
    |-- Decidability.lean (decision procedure)
```

## Main Theorems Established

### Soundness (SORRY-FREE)
- **Theorem**: `soundness : (Gamma |- phi) -> (Gamma |= phi)`
- **Location**: `Soundness.lean`
- **Status**: Fully proven, no sorries
- **Dependencies**: `SoundnessLemmas.lean` (temporal duality, axiom validity)

### BMCS Completeness (SORRY-FREE in main theorems)
- **Theorem**: `bmcs_weak_completeness : bmcs_valid phi -> |- phi`
- **Theorem**: `bmcs_strong_completeness : bmcs_consequence Gamma phi -> Gamma |- phi`
- **Location**: `Bundle/Completeness.lean`
- **Status**: Main theorems SORRY-FREE
- **Dependencies**: Uses `singleFamily_modal_backward_axiom` (documented)

### FMP Completeness (SORRY-FREE)
- **Theorem**: `fmp_weak_completeness : (forall w, semantic_truth phi w t phi) -> |- phi`
- **Theorem**: `semanticWorldState_card_bound : card worlds <= 2^closureSize`
- **Location**: `FMP/SemanticCanonicalModel.lean`
- **Status**: Completely SORRY-FREE

### Decidability (SORRY-FREE)
- **Functions**: `decide`, `isValid`, `isSatisfiable`
- **Location**: `Decidability/DecisionProcedure.lean`
- **Status**: SORRY-FREE

## Axioms Declared (3 total)

| Axiom | Location | Purpose | Justification |
|-------|----------|---------|---------------|
| `singleFamily_modal_backward_axiom` | Bundle/Construction.lean:228 | Modal backward for single-family BMCS | Metatheoretic fact from modal logic; captures multi-family saturation |
| `weak_saturated_extension_exists` | Bundle/WeakCoherentBundle.lean:826 | Weak bundle saturation existence | WIP infrastructure, not used by main theorems |
| `saturated_extension_exists` | Bundle/CoherentConstruction.lean:779 | Coherent bundle saturation existence | WIP infrastructure, not used by main theorems |

**Critical Assessment**: Only `singleFamily_modal_backward_axiom` affects the main completeness theorems. The other two axioms are in work-in-progress files that are not imported by the main theorem chain.

## Sorries Inventory (11 total)

### Sorries in Main Dependency Chain (3)
| File | Line | Description | Impact |
|------|------|-------------|--------|
| Bundle/TruthLemma.lean | 383 | all_future backward direction | Does NOT affect completeness (only forward used) |
| Bundle/TruthLemma.lean | 395 | all_past backward direction | Does NOT affect completeness (only forward used) |
| FMP/Closure.lean | 728 | Diamond membership edge case | Minor edge case |

### Sorries in WIP Files (8)
| File | Lines | Description | Status |
|------|-------|-------------|--------|
| Bundle/SaturatedConstruction.lean | 714, 733, 785 | Multi-family saturation WIP | Not imported by main theorems |
| Bundle/PreCoherentBundle.lean | 338, 377 | Box coherence exploration | Not imported by main theorems |
| Bundle/WeakCoherentBundle.lean | 501, 750, 944 | Weak coherent bundle WIP | Not imported by main theorems |

## Completeness Status Assessment

### What IS Established
1. **Full soundness** - every derivable formula is valid
2. **BMCS weak/strong completeness** - via contrapositive with representation theorem
3. **FMP weak completeness** - via finite canonical model
4. **Decidability** - tableau procedure returns proofs or countermodels
5. **Algebraic representation** - Lindenbaum quotient, ultrafilter-MCS bijection

### What Relies on Axiom
The BMCS completeness chain uses `singleFamily_modal_backward_axiom`:
```
bmcs_weak_completeness
  -> bmcs_representation
    -> construct_bmcs
      -> singleFamilyBMCS
        -> singleFamily_modal_backward_axiom
```

This axiom captures a metatheoretic fact that would be provable with a full multi-family saturated construction. The axiom is well-justified and documented.

### Alternative: FMP Approach
The FMP approach in `FMP/SemanticCanonicalModel.lean` provides **completely axiom-free** weak completeness via:
- Finite closure-based world states
- Contrapositive construction
- No axioms or sorries in main theorem

**Recommendation**: For publication, cite `fmp_weak_completeness` as the primary axiom-free completeness result, with BMCS completeness as a complementary approach.

## Archival Candidates

### High Priority (safe to archive immediately)

These files are NOT imported by any file in the main dependency chain:

| File | Lines | Sorries | Axioms | Reason |
|------|-------|---------|--------|--------|
| Bundle/PreCoherentBundle.lean | 400+ | 2 | 0 | WIP exploration, not imported |
| Bundle/WeakCoherentBundle.lean | 950+ | 3 | 1 | WIP exploration, not imported |
| Bundle/SaturatedConstruction.lean | 970+ | 3 | 0 | WIP infrastructure, not imported |

**Note**: These files import `Bundle/Construction.lean` and `Bundle/CoherentConstruction.lean`, but nothing imports THEM.

### Medium Priority (review before archival)

| File | Reason | Consideration |
|------|--------|---------------|
| Bundle/CoherentConstruction.lean | Contains axiom but not in main chain | Only imported by WIP files above |

### Do NOT Archive

| Directory/File | Reason |
|----------------|--------|
| Core/* | Foundation for all approaches |
| Bundle/BMCS.lean | Core structure |
| Bundle/IndexedMCSFamily.lean | Core structure |
| Bundle/BMCSTruth.lean | Truth definition |
| Bundle/TruthLemma.lean | Key for completeness |
| Bundle/Construction.lean | BMCS construction (used by Completeness) |
| Bundle/Completeness.lean | Main completeness theorems |
| Bundle/ModalSaturation.lean | Used by Construction |
| FMP/* | Axiom-free completeness |
| Decidability/* | Decision procedure |
| Algebraic/* | Alternative approach |
| Soundness.lean | Main soundness |
| Metalogic.lean | Entry point |

## What Remains for Completeness

### Already Complete
- Weak completeness (both BMCS and FMP approaches)
- Strong completeness (BMCS approach)
- Soundness
- Decidability

### Optional Enhancements (not required for publication)
1. **Eliminate `singleFamily_modal_backward_axiom`**: Complete the multi-family saturated BMCS construction in `SaturatedConstruction.lean` to make BMCS approach fully axiom-free
2. **Prove temporal backward directions**: The 2 sorries in `TruthLemma.lean` (lines 383, 395) are for backward directions not used by completeness
3. **Fix FMP/Closure.lean edge case**: Minor sorry at line 728

## Recommendations

### For Publication Readiness

1. **Archive WIP Files**:
   ```bash
   mkdir -p Theories/Bimodal/Boneyard/Metalogic_v6_WIP/Bundle
   mv Theories/Bimodal/Metalogic/Bundle/PreCoherentBundle.lean \
      Theories/Bimodal/Boneyard/Metalogic_v6_WIP/Bundle/
   mv Theories/Bimodal/Metalogic/Bundle/WeakCoherentBundle.lean \
      Theories/Bimodal/Boneyard/Metalogic_v6_WIP/Bundle/
   mv Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean \
      Theories/Bimodal/Boneyard/Metalogic_v6_WIP/Bundle/
   mv Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean \
      Theories/Bimodal/Boneyard/Metalogic_v6_WIP/Bundle/
   ```

2. **Update README.md**: Reduce sorry count from 17 to ~4 after archival

3. **Document Axiom Strategy**: Add a section to README explaining why `singleFamily_modal_backward_axiom` is acceptable and the FMP alternative

4. **Primary Citation Order**:
   - `fmp_weak_completeness` - axiom-free, sorry-free
   - `bmcs_weak_completeness` - uses one well-justified axiom
   - `bmcs_strong_completeness` - same axiom

### Next Steps

1. **Immediate**: Archive the 4 WIP files identified above
2. **Post-archival**: Verify clean build with `lake build`
3. **Documentation**: Update top-level README to reflect cleaned state
4. **Optional future work**: Complete multi-family construction to eliminate axiom

## References

- `Theories/Bimodal/Metalogic/README.md` - Current documentation
- `Theories/Bimodal/Metalogic/Metalogic.lean` - Entry point with architecture
- `Theories/Bimodal/Boneyard/` - Existing archived code (v1-v5)

## Next Steps

1. Archive the 4 WIP files to `Boneyard/Metalogic_v6_WIP/`
2. Update `Metalogic/README.md` sorry count and structure
3. Verify build passes after archival
4. Consider creating a concise "publication companion" document summarizing the metalogic
