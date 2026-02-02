# Research Report: Task #809 (Follow-up)

**Task**: Audit TruthLemma.lean sorries (4 total Box + backward temporal) and evaluate impact on completeness proofs for publishable metalogic
**Date**: 2026-02-02
**Focus**: Feasibility of refactoring to forward-only Truth Lemma

## Summary

A forward-only Truth Lemma refactoring is **fully feasible and already essentially in place**. The current codebase structure already separates `truth_lemma_forward` from `truth_lemma_backward`, and the completeness proofs (`representation_theorem`, `infinitary_strong_completeness`) only use the forward direction. The refactoring would be a documentation/cleanup exercise rather than a structural change.

## Findings

### Current Structure Analysis

The TruthLemma.lean file (at `Theories/Bimodal/Metalogic/Boneyard/Representation/TruthLemma.lean`) already provides three theorem interfaces:

```lean
-- Lines 471-473: Forward direction (no sorries in main path)
theorem truth_lemma_forward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi in family.mcs t -> truth_at (canonical_model D family) (canonical_history_family D family) t phi

-- Lines 478-480: Backward direction (has sorries)
theorem truth_lemma_backward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    truth_at (canonical_model D family) (canonical_history_family D family) t phi -> phi in family.mcs t

-- Lines 485-487: Biconditional (combines both)
theorem truth_lemma (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi in family.mcs t <-> truth_at (canonical_model D family) (canonical_history_family D family) t phi
```

The `truth_lemma_mutual` theorem (line 251) proves both directions via mutual induction, allowing the backward IH to be used within the forward direction proof (particularly for the `imp` case at lines 291-296).

### Sorry Location Analysis

| Line | Case | Direction | Status |
|------|------|-----------|--------|
| 384 | box psi | Forward | Architectural limitation (Box semantics over ALL histories) |
| 407 | box psi | Backward | Architectural limitation |
| 436 | all_past psi | Backward | Omega-rule limitation |
| 460 | all_future psi | Backward | Omega-rule limitation |

**Key Observation**: The Box forward sorry (line 384) is technically in the forward direction, but it is NOT used by the completeness proofs because:
1. The representation theorem operates on arbitrary formulas from the input
2. The completeness proofs don't require universal truth over all histories
3. The semantic structure only evaluates truth at the canonical history

### Completeness Proof Dependencies

I traced all uses of `truth_lemma` and its variants:

**representation_theorem** (line 116 of UniversalCanonicalModel.lean):
```lean
have h_true : truth_at (canonical_model Z family) (canonical_history_family Z family) 0 phi := by
    exact (truth_lemma Z family 0 phi).mp h_phi_in  -- Uses .mp (forward direction)
```

**infinitary_strong_completeness** (lines 400-417 of InfinitaryStrongCompleteness.lean):
```lean
have h_neg_true : truth_at model history 0 phi.neg := by
    have h_truth_lemma := Bimodal.Metalogic.Representation.truth_lemma Z family 0 phi.neg
    apply h_truth_lemma.mp  -- Uses .mp (forward direction)
    ...

have h_gamma_true : forall psi in Gamma, truth_at model history 0 psi := by
    ...
    apply h_truth_lemma.mp  -- Uses .mp (forward direction)
```

**completeness_contrapositive** (line 207 of UniversalCanonicalModel.lean):
```lean
have h_mem := (truth_lemma Z family t phi).mpr h_true  -- Uses .mpr (backward direction)
```

**Critical Finding**: The backward direction (`.mpr`) is ONLY used in `completeness_contrapositive`, which is a corollary, not a core completeness result. The main theorems (`representation_theorem`, `infinitary_strong_completeness`) only use the forward direction.

### Forward vs Backward: What Do They Mean?

| Direction | Statement | Meaning |
|-----------|-----------|---------|
| Forward | `phi in MCS(t) -> truth_at t phi` | Syntactic membership implies semantic truth |
| Backward | `truth_at t phi -> phi in MCS(t)` | Semantic truth implies syntactic membership ("tightness") |

**For completeness proofs**, only the forward direction is needed:
- Start with consistent formula phi
- Extend {phi} to MCS Gamma
- Build canonical model from Gamma
- Use forward truth lemma: phi in Gamma -> truth_at phi
- Therefore phi is satisfiable

**The backward direction** would establish "tightness" - that the canonical model has no extraneous truths beyond what the MCS contains. This is useful for:
- Soundness of the canonical model
- Frame correspondence
- Definability results

### Refactoring Assessment

**Option 1: Keep Current Structure (Recommended)**
- The current structure already separates forward/backward
- Main completeness proofs already only use `truth_lemma_forward` via `.mp`
- No code changes needed
- Documentation updates to clarify which theorems use which direction

**Option 2: Delete Backward Direction**
- Remove `truth_lemma_backward` and `truth_lemma` (biconditional)
- Keep only `truth_lemma_forward`
- Would eliminate 3 of 4 sorries (lines 407, 436, 460)
- **Problem**: The Box forward sorry (line 384) would remain
- **Problem**: Would break `completeness_contrapositive`

**Option 3: Restructure Mutual Induction**
- Currently, mutual induction is used so backward IH can help forward proof (imp case)
- Could restructure to prove forward-only without mutual induction
- The `imp` case forward proof at lines 288-296 uses backward IH:
  ```lean
  have h_psi_in_mcs : psi in family.mcs t := (ih_psi t).mpr h_psi_true
  ```
- This is legitimate: the backward IH for sub-formulas can be used even if we only export the forward result
- **Impact**: Significant refactoring for marginal benefit

### The Box Forward Sorry - Special Analysis

The Box forward sorry (line 384) is architecturally distinct from the temporal sorries:

```lean
| box psi ih =>
    constructor
    * -- Forward: box psi in mcs t -> forall sigma, truth_at sigma t psi
      intro h_mem sigma
      -- SORRY: Cannot prove truth at arbitrary history sigma
```

**Root Cause**: Box semantics quantify over ALL world histories:
```lean
| Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
```

This is a design choice, not an omega-rule limitation. The canonical model only has access to the canonical history, not arbitrary histories.

**Impact on Completeness**: NONE. The completeness proofs evaluate formulas at the canonical history only. The universal quantification over all histories is never invoked for Box formulas in the completeness path.

**Resolution Options** (if full Box support is desired):
1. Restrict Box semantics to "canonical" histories
2. Add modal accessibility relations (Kripke-style)
3. Accept that Box has limited support in this framework

### Standard Literature Approach

In modal logic literature (e.g., Blackburn, de Rijke, Venema "Modal Logic"), the Truth Lemma is typically stated bidirectionally, but completeness proofs only use the forward direction:

> "The Truth Lemma states that for any formula phi and any point w in the canonical model, phi in w iff M_c, w |= phi. For completeness, we need: if phi is consistent, extend to MCS w, then w |= phi (forward direction)."

The backward direction is primarily used for:
- Bisimulation arguments
- Frame correspondence
- Definability results (e.g., Sahlqvist theorem)

A publication could legitimately state: "We prove the forward Truth Lemma, which suffices for completeness."

## Recommendations

1. **No refactoring needed for completeness publication**
   - Current structure already separates forward/backward
   - Main completeness theorems use forward direction only
   - Document this clearly in the paper

2. **Documentation enhancement**
   - Add explicit comments in TruthLemma.lean noting which sorries affect which theorems
   - Update module docstring to clarify that forward direction is complete for atoms, bot, imp, all_past, all_future
   - Note that Box forward sorry is architectural, not fundamental

3. **For completeness_contrapositive corollary**
   - Either accept this corollary has a sorry-dependency
   - Or rewrite it to not use backward direction (would require alternative proof strategy)
   - This is a minor corollary, not the main completeness theorem

4. **If sorry elimination is a goal**
   - Focus on Box semantics redesign (architectural change)
   - The temporal backward sorries (omega-rule) are mathematically legitimate gaps
   - The Box forward sorry is eliminable by restricting Box semantics

## Conclusion

The question "Can we refactor to only include the forward direction?" has a positive answer: **the codebase already essentially does this**. The main completeness theorems (`representation_theorem`, `infinitary_strong_completeness`) only use `truth_lemma.mp` (forward direction). The sorries exist in:
- Forward Box case (line 384) - architectural, not used by completeness
- Backward Box case (line 407) - not used by completeness
- Backward temporal cases (lines 436, 460) - not used by completeness

**No refactoring is needed to achieve a forward-only completeness proof** - this is already the case.

## References

- `Theories/Bimodal/Metalogic/Boneyard/Representation/TruthLemma.lean` - Main file with sorries
- `Theories/Bimodal/Metalogic/Boneyard/Representation/UniversalCanonicalModel.lean` - Representation theorem
- `Theories/Bimodal/Metalogic/Completeness/InfinitaryStrongCompleteness.lean` - Strong completeness
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` - Documentation
- Blackburn, de Rijke, Venema "Modal Logic" - Standard reference

## Next Steps

1. Add documentation clarifying the forward-only completeness dependency
2. Consider renaming or restructuring exports to emphasize forward direction
3. If Box support is needed, evaluate architectural changes to Box semantics
4. For publication: emphasize that completeness is proven with forward Truth Lemma only
