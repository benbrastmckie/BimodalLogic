# Implementation Summary: Close Remaining BXCanonical Sorries

- **Task**: 88 - Close remaining 6 BXCanonical sorries
- **Status**: PARTIAL (Phase 1 completed, Phases 2-5 blocked, Phase 6 partial)
- **Session**: sess_1775763467_ef830c

## Completed Work

### Phase 1: Restore Axioms and Prove Soundness [COMPLETED]

Added 4 new axiom constructors to the BX axiom system:

1. **temp_linearity** (BX11): `F(phi) and F(psi) -> F(phi and psi) or F(phi and F(psi)) or F(F(phi) and psi)` - Future witnesses are linearly ordered
2. **temp_linearity_past** (BX11'): Past dual of BX11
3. **F_until_equiv** (BX12): `F(phi) -> top U phi` - Bridges F-formulas to Until-formulas
4. **P_since_equiv** (BX12'): Past dual of BX12

Soundness proved for all 4 axioms across all soundness theorem variants:
- `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` in Soundness.lean
- Local validity proofs in SoundnessLemmas.lean (4 match sites updated)
- Swap validity proofs in SoundnessLemmas.lean (2 match sites with inline proofs)
- Direct soundness theorem case arms (2 match sites)

Files modified:
- `Theories/Bimodal/ProofSystem/Axioms.lean` (4 new constructors, docstring updates)
- `Theories/Bimodal/Metalogic/Soundness.lean` (6 case sites updated, 3 validity theorems added)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (4 case sites updated, 6 new helper theorems)

### Phase 6: Fix Downstream Sorries [PARTIAL]

Closed 4 downstream sorries:
- `LinearityDerivedFacts.lean:78`: `sorry /- temp_l removed in BX -/` -> `DerivationTree.axiom [] _ (Axiom.temp_linearity phi psi)`
- `DovetailedChain.lean:572`: `sorry /- F_until_equiv removed in BX -/` -> `DerivationTree.axiom [] _ (Axiom.F_until_equiv psi)`
- `DovetailedChain.lean:953`: `sorry /- P_since_equiv removed in BX -/` -> `DerivationTree.axiom [] _ (Axiom.P_since_equiv psi)`
- `DovetailedChain.lean:898`: `sorry /- BX: derive temp_4 from BX1 -/` -> `DerivationTree.axiom [] _ (Axiom.temp_4 phi)`

Also attempted `FiniteDeferral.lean:48` but this file has pre-existing import errors (bad imports to deleted modules).

## Blocked Phases

### Phase 2: Derive bx_le Linearity [BLOCKED]

**Root cause**: bx_le linearity (totality) is NOT provable even with temp_linearity as an axiom.

The canonical ordering `bx_le w v` is defined as `g_content(w) subset v.formulas` (i.e., `forall phi, G(phi) in w -> phi in v`). For this to be total, we would need: for ANY two MCSs w, v, either all G-formulas of w are in v, or vice versa.

Adding temp_linearity constrains F-witness ordering within a single MCS, but does NOT constrain the global relationship between arbitrary MCSs. Two MCSs can have incomparable G-content even when both satisfy temp_linearity. This is the "X-vs-G mismatch" identified in task 85/86.

**Mathematical reality**: The canonical model for temporal logics on linear orders forms a TREE (partial order), not a linear order. Completeness proofs in the literature (Burgess 1984, Xu 1988) work by extracting specific chains from this tree, not by proving the whole tree is linear.

### Phases 3-5 [BLOCKED by Phase 2]

All depend on bx_le linearity which is not achievable.

## Sorries Remaining

6 sorries in BXCanonical module (unchanged from pre-implementation):
- Frame.lean: 4 (eventuality resolution, lines 653, 675, 690, 704)
- CanonicalEmbedding.lean: 1 (usf_completeness imp Case B, line 418)
- Completeness.lean: 1 (full bx_completeness, line 160)

## Verification

- `lake build` succeeds with zero errors
- No new `axiom` declarations introduced
- No new sorries introduced
- 4 sorries closed in non-BXCanonical modules
- All pre-existing sorries in BXCanonical unchanged

## Recommendations for Future Work

To close the BXCanonical sorries, a fundamentally different approach is needed:

1. **Chain extraction approach**: Instead of proving bx_le linearity on ALL MCSs, extract a specific linearly-ordered chain of MCSs starting from a given MCS w0. This is the standard Burgess/Xu approach. Requires new infrastructure for chain construction with Until-formula propagation.

2. **Quasimodel/filtration approach**: Build a finite model (quasimodel) and lift to full completeness via the finite model property. Avoids the canonical model entirely.

3. **Redefine bx_le**: Instead of using g_content inclusion, define the canonical ordering via Until-witness chains. This would make bx_le linear by construction but requires reproving reflexivity, transitivity, and the G/H truth lemma.
