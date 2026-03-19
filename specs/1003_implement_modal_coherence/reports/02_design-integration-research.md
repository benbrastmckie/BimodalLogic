# Research Report: Design Integration for Modal Witness Infrastructure

**Task**: 1003 - Implement Sorry-Free Multi-Family Modal Coherence
**Date**: 2026-03-19
**Focus**: Integration of Task 1002 design with existing Lean infrastructure

## Summary

This research verifies that all infrastructure referenced in the Task 1002 design document exists and identifies the implementation steps needed to achieve sorry-free modal coherence. The design is sound and the implementation path is clear. The singleton BFMCS approach (canonicalMCSBFMCS as sole family) achieves modal saturation by construction because witness MCSes are automatically CanonicalMCS elements.

## Findings

### 1. Core Infrastructure Verification

All key theorems and definitions referenced in the design document exist and are sorry-free:

| Component | Location | Status | Signature |
|-----------|----------|--------|-----------|
| `saturated_modal_backward` | ModalSaturation.lean:328 | Sorry-free | `(B : BFMCS D) → is_modally_saturated B → fam ∈ B.families → ... → Box phi ∈ fam.mcs t` |
| `modal_witness_seed_consistent` | ChainFMCS.lean:322 | Sorry-free | `(M : Set Formula) → SetMaximalConsistent M → psi.diamond ∈ M → SetConsistent (ModalWitnessSeed M psi)` |
| `is_modally_saturated` | ModalSaturation.lean:73 | Definition | `∀ fam ∈ B.families, ∀ t psi, psi.diamond ∈ fam.mcs t → ∃ fam' ∈ B.families, psi ∈ fam'.mcs t` |
| `canonicalMCSBFMCS` | CanonicalFMCS.lean:184 | Sorry-free | `FMCS CanonicalMCS` |
| `MCSBoxContent` | ChainFMCS.lean:59 | Definition | `{phi | Formula.box phi ∈ M}` |
| `ModalWitnessSeed` | ChainFMCS.lean:293 | Definition | `{psi} ∪ MCSBoxContent M` |
| `lindenbaumMCS_set` | Construction.lean:142 | Definition | `Set Formula → SetConsistent S → Set Formula` |
| `lindenbaumMCS_set_extends` | Construction.lean:149 | Lemma | `S ⊆ lindenbaumMCS_set S h_cons` |
| `lindenbaumMCS_set_is_mcs` | Construction.lean:156 | Lemma | `SetMaximalConsistent (lindenbaumMCS_set S h_cons)` |

### 2. Design Document Accuracy

The design document (specs/1002.../reports/03_design-document.md) accurately identifies the construction strategy:

**Key Insight (Verified)**: Witness MCSes constructed via Lindenbaum extension are automatically `CanonicalMCS` elements because `CanonicalMCS` only requires `SetMaximalConsistent` -- there is no reachability requirement.

**Saturation by Construction**: For any Diamond(psi) in `canonicalMCSBFMCS.mcs t = t.world`:
1. Build `ModalWitnessData` with `source_mcs = t.world`
2. Construct witness MCS via `lindenbaumMCS_set (ModalWitnessSeed t.world psi) (modal_witness_seed_consistent ...)`
3. Witness MCS contains psi (by `lindenbaumMCS_set_extends`)
4. Witness MCS is a `CanonicalMCS` element (by `lindenbaumMCS_set_is_mcs`)
5. At the witness `CanonicalMCS` element `w`, `canonicalMCSBFMCS.mcs w = w.world` contains psi

### 3. Current Sorry Location

The design identifies **one active sorry** that task 1003 will eliminate:

**Location**: `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean:277`
```lean
noncomputable def singletonCanonicalBFMCS : BFMCS CanonicalMCS where
  ...
  modal_backward := fun fam hfam phi t h_all => by
    ...
    sorry  -- Line 277
```

**Resolution**: Replace `singletonCanonicalBFMCS` with the saturated construction. The singleton bundle `{canonicalMCSBFMCS}` IS already modally saturated -- the proof just needs to be completed.

### 4. Implementation Gap Analysis

| Design Component | Implementation Status | Gap |
|-----------------|----------------------|-----|
| `ModalWitnessData` | Not implemented | New structure needed |
| `buildWitnessMCS` | Exists in WitnessChainFMCS.lean | Same pattern, can reference |
| `witnessAsCanonicalMCS` | Not implemented | Trivial wrapper |
| `SaturatedCanonicalBFMCS` | Not implemented | Structure + theorem |
| `saturated_canonical_bfmcs_exists` | Not implemented | Main existence theorem |

### 5. Proof Strategy Verification

The design's proof for `saturated_canonical_bfmcs_exists` is sound:

```lean
-- The singleton bundle {canonicalMCSBFMCS} is already saturated!
-- For any Diamond(psi) in canonicalMCSBFMCS.mcs t = t.world:
-- 1. Build witness MCS via Lindenbaum on ModalWitnessSeed
-- 2. Witness is a CanonicalMCS element (just SetMaximalConsistent)
-- 3. canonicalMCSBFMCS.mcs witness_t = witness_t.world contains psi
-- 4. This satisfies the saturation requirement
```

The key observation: `canonicalMCSBFMCS` maps each `t : CanonicalMCS` to `t.world`. So for the witness MCS `W`:
- Create `witness_t : CanonicalMCS := { world := W, is_mcs := ... }`
- `canonicalMCSBFMCS.mcs witness_t = witness_t.world = W`
- `W` contains `psi` by construction

### 6. File Structure Recommendation

Following the design document's file mapping:

```
Theories/Bimodal/Metalogic/Bundle/
├── ModalWitnessData.lean (NEW)
│   ├── ModalWitnessData structure
│   ├── buildWitnessMCS
│   ├── witnessAsCanonicalMCS
│   ├── buildWitnessMCS_contains_psi
│   └── buildWitnessMCS_contains_boxcontent
│
└── SaturatedConstruction.lean (NEW)
    ├── SaturatedCanonicalBFMCS structure
    ├── saturated_canonical_bfmcs_exists
    └── canonical_modal_backward (reuses saturated_modal_backward)
```

### 7. Potential Blockers (None Critical)

| Risk | Severity | Resolution |
|------|----------|------------|
| `lindenbaumMCS_from_set` vs `lindenbaumMCS_set` | Low | Use existing `lindenbaumMCS_set` (verified present) |
| Proof of saturation equality | Low | Use extensionality or work with membership |
| Integration with MultiFamilyBFMCS.lean | Low | Replace sorry with `saturated_modal_backward` call |

### 8. Zero-Debt Compliance

The design fully complies with zero-debt policy:
- No sorry deferral patterns recommended
- Clear path to eliminating the single remaining sorry
- All infrastructure already sorry-free
- No new axioms required

## Recommendations

### Implementation Order

1. **Create `ModalWitnessData.lean`** (~30 lines)
   - Define `ModalWitnessData` structure per design
   - Implement `buildWitnessMCS` using `lindenbaumMCS_set`
   - Define `witnessAsCanonicalMCS` wrapper

2. **Create `SaturatedConstruction.lean`** (~60 lines)
   - Define `SaturatedCanonicalBFMCS` structure
   - Prove `saturated_canonical_bfmcs_exists`
   - Wire `saturated_modal_backward` to derive `modal_backward`

3. **Update `MultiFamilyBFMCS.lean`** (~10 lines)
   - Replace `singletonCanonicalBFMCS` definition to use saturated construction
   - Remove the sorry

4. **Verify build passes with no sorries**
   - Run `lake build`
   - Confirm the sorry count decreases by 1

### Key Type Signatures

```lean
-- ModalWitnessData.lean
structure ModalWitnessData where
  inner_formula : Formula
  source_mcs : Set Formula
  source_is_mcs : SetMaximalConsistent source_mcs
  diamond_mem : inner_formula.diamond ∈ source_mcs

noncomputable def buildWitnessMCS (w : ModalWitnessData) : Set Formula :=
  lindenbaumMCS_set (ModalWitnessSeed w.source_mcs w.inner_formula)
    (modal_witness_seed_consistent w.source_mcs w.source_is_mcs w.inner_formula w.diamond_mem)

noncomputable def witnessAsCanonicalMCS (w : ModalWitnessData) : CanonicalMCS :=
  { world := buildWitnessMCS w
  , is_mcs := buildWitnessMCS_is_mcs w }
```

```lean
-- SaturatedConstruction.lean
theorem saturated_canonical_bfmcs_exists :
    ∃ B : BFMCS CanonicalMCS,
      canonicalMCSBFMCS ∈ B.families ∧
      is_modally_saturated B := by
  use { families := {canonicalMCSBFMCS}, ... }
  ...
```

## Context Extension Recommendations

None needed. The modal witness infrastructure is well-documented in the existing context files.

## Next Steps

1. Implementation can proceed directly following this research
2. The design is validated against the codebase
3. All referenced infrastructure is present and sorry-free
4. Estimated implementation effort: 2-3 hours

## References

- Design document: `specs/1002_design_modal_witness_infrastructure/reports/03_design-document.md`
- Core infrastructure: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`
- Witness seed: `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean`
- Lindenbaum: `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- BFMCS definition: `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- Current sorry location: `Theories/Bimodal/Metalogic/Algebraic/MultiFamilyBFMCS.lean:277`
