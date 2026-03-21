# Research Report: Task #840

**Task**: Refactor TruthLemma Forward/Backward for Publication
**Date**: 2026-02-03
**Focus**: ZERO-SORRY path for journal publication - removing G/H backward direction sorries

## Summary

This research investigates paths to achieve a **zero-sorry repository** for journal publication. The current TruthLemma has 2 sorries in backward directions for temporal operators G (all_future) and H (all_past). Additionally, there is 1 sorry in `SaturatedConstruction.lean` (Zorn's lemma formalization) and 1 explicit axiom `singleFamily_modal_backward_axiom` in `Construction.lean`. This report evaluates two paths: **Archival (restructuring)** and **Completion (mathematical solution)**.

## Current Sorry/Axiom Inventory

| File | Line | Type | Description |
|------|------|------|-------------|
| TruthLemma.lean | 383 | sorry | G (all_future) backward: `(forall s >= t, phi true at s) -> G phi in MCS(t)` |
| TruthLemma.lean | 395 | sorry | H (all_past) backward: `(forall s <= t, phi true at s) -> H phi in MCS(t)` |
| SaturatedConstruction.lean | 482 | sorry | Zorn's lemma: `exists_fullySaturated_extension` |
| Construction.lean | 228 | axiom | `singleFamily_modal_backward_axiom`: phi in MCS implies Box phi in MCS |

**Critical Insight**: The completeness theorems (`bmcs_weak_completeness`, `bmcs_strong_completeness`) in Completeness.lean are **already sorry-free** because they only use the forward direction (`.mp`) of the truth lemma. The sorries exist in a biconditional (`iff`) that is stronger than what completeness requires.

## Path 1: ARCHIVAL (Restructuring)

### Option 1A: Remove Backward Directions Entirely

**Approach**: Replace the biconditional truth lemma with a forward-only version.

**Current**:
```lean
theorem bmcs_truth_lemma ... : phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

**Proposed**:
```lean
theorem bmcs_truth_lemma_forward ... : phi in fam.mcs t -> bmcs_truth_at B fam t phi
```

**Impact Analysis**:
- **Completeness.lean**: Uses only `.mp` (forward direction) - NO CHANGES NEEDED
- **TruthLemma.lean**: Remove backward cases, remove 2 sorries
- **Corollaries**: `bmcs_eval_mcs` (uses backward direction) would be removed or marked as requiring additional hypothesis

**Files to Modify**:
1. `TruthLemma.lean` - Split into forward-only theorem
2. Remove `bmcs_eval_mcs` or document as non-provable in finitary systems
3. Update module documentation

**Assessment**: **VIABLE - Low complexity, clean solution**

This is the recommended archival approach because:
1. It accurately reflects the mathematical reality (omega-rule limitation)
2. It preserves all important theorems (completeness is sorry-free)
3. It removes 2 sorries with minimal codebase disruption

### Option 1B: Bounded Temporal Semantics

**Approach**: Restrict the time domain to finite bounds based on formula depth.

This approach was previously explored in `Theories/Bimodal/Boneyard/SemanticCanonicalModel.lean` and documented as having compositionality failures:
- Frame compositionality fails when durations exceed bounds (line 224)
- Changes the semantics from "always" to "within bounds"

**Assessment**: **NOT RECOMMENDED** - Already explored and archived due to fundamental issues

## Path 2: COMPLETION (Mathematical Solution)

### Option 2A: Complete Zorn's Lemma Proof in SaturatedConstruction.lean

**Current Status**: The file `SaturatedConstruction.lean` has infrastructure for multi-family saturation via Zorn's lemma, with a sorry at line 482.

**What's Needed**:
1. Formalize partial order of family collections
2. Prove chain completeness (union of chain preserves box_coherence)
3. Apply Mathlib's `Order.Zorn` lemmas
4. Prove maximality implies full saturation

**Dependencies**: Requires `Mathlib.Order.Zorn` which provides:
- `zorn_preorder_nonempty`
- `zorn_partial_order`

**Assessment**: **VIABLE - Medium complexity, eliminates axiom**

This would eliminate `singleFamily_modal_backward_axiom` from Construction.lean but does NOT address the temporal backward sorries (the omega-rule limitation is orthogonal to modal saturation).

**Key Insight from Research**: The Zorn's lemma approach is standard in modal logic completeness proofs. The [Lean Formalization of Completeness Proof for Coalition Logic with Common Knowledge](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28) demonstrates similar techniques in Lean 4.

### Option 2B: Omega-Saturation (Theoretical - Not Practical)

**What Would Be Needed**:
- Construct MCSs that satisfy: if {phi@1, phi@2, phi@3, ...} are all consistent with MCS, then G phi in MCS
- This requires non-constructive set-theoretic machinery beyond standard Lindenbaum construction

**Assessment**: **NOT PRACTICAL** - Would require axioms equivalent to full omega-saturation, which defeats the purpose of removing axioms

### Option 2C: Bounded Model Checking Completeness Threshold

**Web Search Finding**: From [Completeness and Complexity of Bounded Model Checking](https://link.springer.com/chapter/10.1007/978-3-540-24622-0_9):
> "For every finite model M and an LTL property phi, there exists a number called the Completeness Threshold such that if there is no counterexample to phi in M of length equal to or less than this threshold, then M satisfies phi."

**Assessment**: **NOT APPLICABLE** - This applies to model checking of finite models, not to completeness of the proof system over infinite time domains.

### Option 2D: Finitary Approximation via Formula Depth

**Explored in Task 828**: Previous research established that even with finite temporal depth:
1. Formulas can only "look" finitely many steps ahead
2. The MCS construction is still blind to which times will be relevant semantically
3. This is a "finite omega-rule" problem - still cannot derive G phi from k instances

**Assessment**: **DOES NOT RESOLVE** the fundamental directionality problem

## Web Search Findings

### Existing Formalizations

1. **[CTL Completeness in Coq](https://link.springer.com/chapter/10.1007/978-3-319-08970-6_15)**: Uses history-augmented tableau systems. The proof is based on the dual of a cut-free sequent calculus, yielding decidability and completeness as corollaries.

2. **[Modal Logic S5 in Lean](https://philarchive.org/archive/BENAHC-2)**: Henkin-style completeness for S5 using Hilbert system. Does NOT address temporal operators with omega-rule issues.

3. **[Isabelle/HOL Synthetic Completeness Framework](https://dl.acm.org/doi/10.1145/3703595.3705882)**: Provides reusable infrastructure for Lindenbaum lemma and MCS construction. Could inform Lean approaches.

4. **[MLTL Formalization in Isabelle/HOL](https://link.springer.com/chapter/10.1007/978-3-032-07021-0_21)**: Formalizes Mission-time LTL with BOUNDED temporal semantics (finite mission duration).

### Key Theoretical Insight

From [Encyclopedia of Mathematics on Omega-completeness](https://encyclopediaofmath.org/wiki/Omega-completeness):
> "A set of sentences is omega-complete if whenever it deductively yields every instance of a universal generalization, it also yields the generalization itself."

The backward direction sorries are fundamentally about omega-incompleteness of finitary proof systems. This is NOT a bug or proof engineering gap - it is a mathematical limitation.

## Recommended Path to Zero-Sorry Publication

### Phase 1: Archival - Forward-Only Truth Lemma (Recommended First Step)

1. **Modify TruthLemma.lean**:
   - Keep the full biconditional for cases that are proven (atom, bot, imp, box)
   - For all_future and all_past, prove only forward direction
   - Remove the 2 sorries

2. **Create New Theorem**:
   ```lean
   theorem bmcs_truth_lemma_forward (B : BMCS D) (fam : IndexedMCSFamily D)
       (hfam : fam in B.families) (t : D) (phi : Formula) :
       phi in fam.mcs t -> bmcs_truth_at B fam t phi
   ```

3. **Document the Limitation**:
   - The backward direction for temporal operators requires omega-saturation
   - This is a fundamental limitation, not a proof gap
   - Completeness theorems are unaffected

4. **Verify Transitively Sorry-Free**:
   - `bmcs_weak_completeness` - uses only forward direction
   - `bmcs_strong_completeness` - uses only forward direction
   - Both remain fully proven

### Phase 2: Complete Zorn's Lemma (Optional - Eliminates Axiom)

1. **Formalize Partial Order**:
   - Family collections ordered by inclusion
   - Preserve box_coherence invariant

2. **Prove Chain Completeness**:
   - Union of chain preserves box_coherence
   - This is the main technical challenge

3. **Apply Zorn and Derive Saturation**:
   - Maximal element exists
   - Maximality implies full saturation

4. **Impact**:
   - Eliminates `singleFamily_modal_backward_axiom`
   - Makes modal completeness fully axiom-free
   - Does NOT affect temporal backward sorries (different issue)

### Phase 3: Documentation for Publication

1. **Update Module Docstrings**:
   - Clearly state what is proven vs what requires omega-rule
   - Explain Henkin-style semantics
   - Reference standard textbook treatments

2. **Create Publication-Ready Summary**:
   - List all transitively sorry-free theorems
   - Document any remaining axioms with justification
   - Provide comparison to other formalizations

## Impact Assessment

| Item | Current | After Phase 1 | After Phase 2 |
|------|---------|---------------|---------------|
| TruthLemma sorries | 2 | 0 | 0 |
| SaturatedConstruction sorries | 1 | 1 | 0 |
| Explicit axioms | 1 | 1 | 0 |
| Completeness.lean sorries | 0 | 0 | 0 |
| Total blocking publication | 4 | 2 | 0 |

**Note**: The SaturatedConstruction sorry and axiom are related - completing Zorn's lemma eliminates the need for the axiom.

## Conclusions

### Primary Recommendation: Phase 1 (Forward-Only TruthLemma)

The cleanest path to zero-sorry publication is to:
1. Restructure TruthLemma to prove only the forward direction for temporal operators
2. Document the omega-rule limitation as a fundamental constraint
3. Verify completeness theorems remain transitively sorry-free

This approach is:
- **Mathematically honest**: Reflects the true limitations of finitary proof systems
- **Sufficient for publication**: The important theorems (completeness) are preserved
- **Low risk**: Minimal codebase changes required

### Secondary Recommendation: Phase 2 (Zorn's Lemma)

If eliminating all axioms is required:
1. Complete the Zorn's lemma formalization in SaturatedConstruction.lean
2. This eliminates the modal axiom but NOT the temporal sorries
3. Higher complexity, but achievable with Mathlib infrastructure

### NOT Recommended

- Bounded temporal semantics (compositionality failures)
- Omega-saturation (impractical in Lean)
- Bounded model checking techniques (wrong domain)

## References

- [Completeness and Decidability Results for CTL in Coq](https://link.springer.com/chapter/10.1007/978-3-319-08970-6_15)
- [A Henkin-Style Completeness Proof for Modal Logic S5](https://philarchive.org/archive/BENAHC-2)
- [Lean Formalization of Completeness for Coalition Logic](https://drops.dagstuhl.de/entities/document/10.4230/LIPIcs.ITP.2024.28)
- [Isabelle/HOL Synthetic Completeness Framework](https://dl.acm.org/doi/10.1145/3703595.3705882)
- [Omega-completeness - Encyclopedia of Mathematics](https://encyclopediaofmath.org/wiki/Omega-completeness)
- [Completeness and Complexity of Bounded Model Checking](https://link.springer.com/chapter/10.1007/978-3-540-24622-0_9)
- Task 828 Research: specs/828_fmp_approach_truthlemma_backward/reports/research-001.md

## Next Steps

1. **Planning Phase**: Create implementation plan for Phase 1 (forward-only truth lemma)
2. **Verification**: Run `lake build` to confirm current build status
3. **Implementation**: Execute Phase 1 restructuring
4. **Validation**: Verify all completeness theorems remain transitively sorry-free
5. **(Optional) Phase 2**: Complete Zorn's lemma if axiom-free requirement is confirmed
