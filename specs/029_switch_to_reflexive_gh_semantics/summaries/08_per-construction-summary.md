# Implementation Summary: Task #29 Per-Construction Strictness (Phases 4-5A)

## Overview

This summary covers the implementation of Phases 4 and 5A of the per-construction strictness approach for transitioning to reflexive G/H semantics.

## Completed Phases

### Phase 4: Clean Up Flawed Theorems [COMPLETED]

**Goal**: Remove cardinality-based theorems that are provably false.

**Files Modified**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Deletions**:
1. `exists_fresh_for_g_content` - Cardinality argument is flawed; a pathological MCS can cover all atoms via formulas like G(phi) where phi mentions every atom.
2. `fresh_for_g_content_some_decided_false` - Depended on the above.
3. `naming_set_consistent` - IRR-based proof that relied on the unsound IRR rule.
4. `exists_strict_fresh_atom` - Depended on `fresh_for_g_content_some_decided_false`.
5. `existsTask_strict_fresh_atom` - Depended on `exists_strict_fresh_atom`.

**Preserved**:
- `fresh_Gp_seed_consistent` - PROVEN theorem that works when a fresh atom IS provided by the specific construction. This is the key building block for per-construction strictness.

**Documentation Added**:
- Explanation of why universal fresh atom existence fails
- Updated deprecation warnings in `CanonicalIrreflexivityAxiom.lean`

### Phase 5A: Introduce Per-Construction Strictness Infrastructure [COMPLETED]

**Goal**: Create the lemmas that enable per-site strictness proofs.

**Files Modified**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**New Theorems**:

1. `lt_of_canonicalR_and_not_reverse`:
   ```lean
   theorem lt_of_canonicalR_and_not_reverse {M N : Set Formula}
       (h_M_mcs : SetMaximalConsistent M) (h_N_mcs : SetMaximalConsistent N)
       (h_fwd : CanonicalR M N)
       (h_not_bwd : ¬CanonicalR N M) :
       M ≠ N
   ```
   Core lemma for deriving distinctness from forward accessibility + backward non-accessibility.

2. `strict_of_formula_in_g_content_not_in_source`:
   ```lean
   theorem strict_of_formula_in_g_content_not_in_source {M W : Set Formula} {φ : Formula}
       (h_φ_in_g_W : φ ∈ g_content W)
       (h_φ_not_M : φ ∉ M) :
       ¬CanonicalR W M
   ```
   Workhorse lemma: when phi is in g_content(W) but not in M, we get backward non-accessibility.

3. `strict_of_formula_with_G_not_in_source`:
   ```lean
   theorem strict_of_formula_with_G_not_in_source {M W : Set Formula} {φ : Formula}
       (h_Gφ_in_W : Formula.all_future φ ∈ W)
       (h_φ_not_M : φ ∉ M) :
       ¬CanonicalR W M
   ```
   Variant for when G(phi) is directly in W.

## Mathematical Foundation

The key insight from team research (report 12):

1. **CanonicalR is a PREORDER** (reflexive + transitive), NOT a partial order
2. **Antisymmetry FAILS** - mutual accessibility is possible without equality
3. **Fresh atom existence is NOT provable in general** - pathological MCS can cover all atoms
4. **Per-construction strictness is the solution** - prove strictness from the specific formula witness at each call site

The pattern at each call site:
1. Construct witness W with some formula phi in W
2. Ensure G(phi) in W (so phi in g_content(W))
3. Show phi not in M (the source)
4. Apply `strict_of_formula_in_g_content_not_in_source` to get not-CanonicalR W M

## Remaining Work

### Phase 5B: Refactor Frame Condition Sites [NOT STARTED]
- ~18 sites in CanonicalSerialFrameInstance.lean, CantorApplication.lean, DovetailedTimelineQuot.lean
- Requires per-construction strictness using seriality + specific formula witnesses

### Phase 5C: Refactor Remaining Call Sites [NOT STARTED]
- ~12 sites in SaturatedChain.lean, FMCSTransfer.lean, ClosureSaturation.lean, etc.
- Each site needs analysis of what formula distinguishes the witness from the source

### Phase 6: Delete Axiom [NOT STARTED]
- Delete `canonicalR_irreflexive_axiom` once all call sites are fixed

### Phase 7-8: Documentation and T-Axiom Proofs [NOT STARTED]

## Verification

- `lake build` passes (1044 jobs)
- No new sorries introduced in modified files
- No new axioms introduced
- `fresh_Gp_seed_consistent` remains proven and available for use

## Files Summary

| File | Changes |
|------|---------|
| `Bundle/CanonicalIrreflexivity.lean` | Deleted 5 theorems, added 3 theorems, added documentation |
| `Canonical/CanonicalIrreflexivityAxiom.lean` | Updated documentation, added deprecation warnings |

## Call Site Analysis

Current call sites using `canonicalR_irreflexive` (to be refactored in Phase 5B/5C):
- CanonicalSerialFrameInstance.lean: 2 sites
- CantorApplication.lean: 3 sites (comments)
- DovetailedTimelineQuot.lean: 13 sites
- SaturatedChain.lean: 8 sites
- FMCSTransfer.lean: 2 sites
- ClosureSaturation.lean: 2 sites
- IncrementalTimeline.lean: 1 site
- TimelineQuotCanonical.lean: 2 sites

Total: ~33 code call sites + documentation references
