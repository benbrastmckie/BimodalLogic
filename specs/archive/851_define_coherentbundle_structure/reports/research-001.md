# Research Report: Task #851 - Define CoherentBundle Structure

- **Task**: 851 - define_coherentbundle_structure
- **Started**: 2026-02-03T12:00:00Z
- **Completed**: 2026-02-03T14:30:00Z
- **Effort**: 3 hours
- **Dependencies**: Task 842 (Zorn's lemma research), Task 844 (CoherentWitness implementation)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/BMCS.lean`
  - `specs/842_formalize_zorn_lemma_exists_fullySaturated_extension/reports/research-003.md`
  - `specs/844_redesign_metalogic_precoherent_bundle_construction/reports/research-003.md`
  - Mathlib `FirstOrder.Language.Theory.CompleteType`
  - Mathlib `Order.Zorn`
- **Artifacts**: `specs/851_define_coherentbundle_structure/reports/research-001.md`
- **Standards**: status-markers.md, artifact-management.md, tasks.md, report.md

## Project Context

- **Upstream Dependencies**: `BMCS`, `CoherentWitness`, `BoxContent`, `IndexedMCSFamily`, `zorn_subset_nonempty`
- **Downstream Dependents**: `exists_fullySaturated_extension` completion, BMCS construction from consistent context, completeness theorem
- **Alternative Paths**: Single-family construction with `singleFamily_modal_backward_axiom` (works but uses axiom)
- **Potential Extensions**: Multi-modal logics, tense completeness with interleaved modal/temporal saturation

## Executive Summary

- **CoherentBundle** should collect `CoherentWitness` instances while enforcing mutual coherence via a shared `BoxContent` computation spanning ALL families
- The key architectural insight is the **Product Construction Pattern**: instead of building witnesses sequentially and proving they preserve coherence, define CoherentBundle as the set of all families satisfying a coherence predicate
- **Mutual coherence** requires extending `BoxContent` from single-family to multi-family: `UnionBoxContent(families)` collects Box contents from ALL families at ALL times
- **Zorn's lemma** is correctly deployed in `SaturatedConstruction.lean` but the chain-union proof for `box_coherence_pred` is already complete (lines 469-487)
- Three sorries remain in `SaturatedConstruction.lean` (lines 714, 733, 785) with a common root cause: Lindenbaum extension adds uncontrolled Box formulas
- Recommended approach: **Constant-Family Witnesses** with **Shared BoxContent** leveraging the completed `diamond_boxcontent_consistent_constant` theorem

## Context and Scope

### Current State of CoherentWitness

The `CoherentWitness` structure in `CoherentConstruction.lean` captures a witness family that is coherent with a single base family:

```lean
structure CoherentWitness (base : IndexedMCSFamily D) where
  family : IndexedMCSFamily D
  witnessed : Formula
  contains_witnessed : forall t : D, witnessed in family.mcs t
  contains_boxcontent : forall chi, chi in BoxContent base -> forall t : D, chi in family.mcs t
```

**Limitation**: Witnesses are coherent WITH base but not WITH each other. Two witnesses W1 and W2 may contain Box formulas whose contents are not in the other witness.

### BMCS Requirements

The BMCS structure requires two coherence conditions:
- `modal_forward`: Box phi in ANY family implies phi in ALL families
- `modal_backward`: phi in ALL families implies Box phi in EACH family

For a CoherentBundle to convert to BMCS, we need **mutual coherence**: every family must contain BoxContent from ALL other families.

### Existing Sorries in SaturatedConstruction.lean

| Line | Location | Root Cause | Impact |
|------|----------|------------|--------|
| 714 | `h_psi_in_L` case | `{psi} U BoxContent(M)` consistency proof | Blocks witness construction |
| 733 | `not h_psi_in_L` case | BoxContent uses `exists s`, need `chi in fam.mcs t` | Time-coherence mismatch |
| 785 | `h_extended_coherence` | Lindenbaum adds uncontrolled Box formulas to W | Breaks W-to-M coherence |

## Findings

### 1. The Lindenbaum Control Problem

All three sorries stem from a fundamental architectural issue:

**Problem**: Standard Lindenbaum extension extends a consistent set to an MCS by adding formulas one by one. This process can add `Box alpha` where `alpha` is NOT in any existing family's MCS, breaking the mutual coherence invariant.

**Why it breaks**: When we construct witness W for Diamond psi:
1. W starts with `{psi} U BoxContent(M)` (seed is coherent by design)
2. Lindenbaum extends this to MCS W_set
3. W_set may now contain `Box gamma` where `gamma` is not in any M-family
4. Adding W to M gives M' = M U {W}
5. For `box_coherence_pred(M')`, we need: if `Box chi in W.mcs s`, then `chi in fam.mcs s` for all `fam in M`
6. But chi = gamma may not be in M-families - CONTRADICTION

### 2. The diamond_boxcontent_consistent_constant Success

Task 844 successfully proved `diamond_boxcontent_consistent_constant`:

```lean
theorem diamond_boxcontent_consistent_constant (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) (psi : Formula) (t : D)
    (h_diamond : diamondFormula psi in base.mcs t) :
    SetConsistent (WitnessSeed base psi)
```

**Key insight**: For CONSTANT families (where `fam.mcs t = fam.mcs s` for all t, s), BoxContent is time-independent. The proof uses `generalized_modal_k` combined with `set_mcs_closed_under_derivation` to derive a contradiction from assumed inconsistency.

### 3. Mathlib CompleteType Pattern

Mathlib's `FirstOrder.Language.Theory.CompleteType` provides a relevant pattern:

```lean
structure CompleteType where
  toTheory : L[[alpha]].Theory
  subset' : (L.lhomWithConstants alpha).onTheory T <= toTheory
  isMaximal' : toTheory.IsMaximal
```

**Pattern insight**: Instead of constructing complete types one at a time and hoping they're consistent, CompleteType is defined as a STRUCTURE with maximal consistency as a REQUIREMENT. The space of all CompleteTypes is well-defined by this predicate.

**Application to CoherentBundle**: Define CoherentBundle as the set of all families satisfying a coherence predicate, not as an iteratively constructed collection.

### 4. Zorn's Lemma Infrastructure

The Zorn's lemma framework in `SaturatedConstruction.lean` is correctly structured:

- `box_coherence_pred`: Predicate on family sets (line 460)
- `box_coherence_sUnion`: Chains preserve coherence (lines 469-487) - COMPLETE, NO SORRY
- `zorn_subset_nonempty`: Applied correctly (line 545)

The Zorn framework is sound. The issue is proving maximality implies full saturation (lines 567-819).

### 5. Mutual Coherence via UnionBoxContent

**Definition proposal**:

```lean
def UnionBoxContent (families : Set (IndexedMCSFamily D)) : Set Formula :=
  {chi | exists fam in families, exists t : D, Formula.box chi in fam.mcs t}
```

**Mutual coherence invariant**:

```lean
def MutuallyCoherent (families : Set (IndexedMCSFamily D)) : Prop :=
  forall fam in families, forall chi in UnionBoxContent families, forall t : D, chi in fam.mcs t
```

This is STRONGER than `box_coherence_pred` but is the correct invariant for BMCS construction.

### 6. The Constant-Family Witness Strategy

**Observation**: All witnesses constructed via `constructCoherentWitness` are constant families (via `constantWitnessFamily`). This means:
1. The time-mismatch issue (sorry at line 733) is avoided
2. The `diamond_boxcontent_consistent_constant` theorem applies

**Strategy**: Build CoherentBundle exclusively from constant families:

```lean
structure CoherentBundle (D : Type*) [...] where
  families : Set (IndexedMCSFamily D)
  all_constant : forall fam in families, IsConstantFamily fam
  nonempty : families.Nonempty
  mutually_coherent : MutuallyCoherent families
```

## Sorry Characterization

### Current State

The sorries at lines 714, 733, 785 of `SaturatedConstruction.lean` remain unresolved. These block:
- `FamilyCollection.exists_fullySaturated_extension`
- `constructSaturatedBMCS`
- The axiom-free path to completeness

### Transitive Impact

All code using `constructSaturatedBMCS` inherits sorry status:
- `construct_bmcs_saturated`
- Any completeness theorem using the saturation-based approach

**Currently working alternative**: `singleFamilyBMCS_withAxiom` uses `singleFamily_modal_backward_axiom` and has no sorries (besides the axiom itself).

### Remediation Path

The recommended remediation requires implementing CoherentBundle with the constant-family constraint, which sidesteps the Lindenbaum control problem:

1. **Restrict to constant families**: Since all witnesses are constant, the time-mismatch issues disappear
2. **Compute UnionBoxContent at construction time**: Build witnesses with full UnionBoxContent, not just single-family BoxContent
3. **Iterate until saturation**: Since constant families have time-independent BoxContent, the iteration terminates when all Diamond formulas have witnesses

### Publication Status

These sorries block publication of axiom-free completeness. Remediation priority: medium (axiom-based approach is acceptable for initial publication, axiom elimination is enhancement).

## Recommendations

### 1. Define CoherentBundle Structure (Priority: High)

```lean
structure CoherentBundle (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  families : Set (IndexedMCSFamily D)
  all_constant : forall fam in families, IsConstantFamily fam
  nonempty : families.Nonempty
  eval_family : IndexedMCSFamily D
  eval_family_mem : eval_family in families
  mutually_coherent : forall fam in families, forall chi,
    (exists fam' in families, exists t, Formula.box chi in fam'.mcs t) ->
    forall t, chi in fam.mcs t
```

### 2. Implement Iterative Saturation for Constant Families (Priority: High)

Since constant families have time-independent BoxContent, implement:

```lean
noncomputable def saturateCoherentBundle (initial : CoherentBundle D) : CoherentBundle D :=
  -- Iterate: for each unsatisfied Diamond psi in any family:
  --   1. Compute UnionBoxContent(current families)
  --   2. Build witness W with seed {psi} U UnionBoxContent
  --   3. W is constant by construction
  --   4. Add W to bundle
  -- Terminate when all Diamonds satisfied (or use Zorn's lemma)
```

### 3. Prove Saturation Preserves Mutual Coherence (Priority: High)

The key lemma:

```lean
theorem saturation_preserves_mutual_coherence (B : CoherentBundle D) (psi : Formula)
    (h_diamond : exists fam in B.families, diamondFormula psi in fam.mcs 0)
    (W : IndexedMCSFamily D) (h_W_const : IsConstantFamily W)
    (h_W_contains : {psi} U UnionBoxContent B.families <= W.mcs 0) :
    MutuallyCoherent (B.families U {W})
```

### 4. Convert CoherentBundle to BMCS (Priority: Medium)

```lean
noncomputable def CoherentBundle.toBMCS (B : CoherentBundle D)
    (h_saturated : forall psi fam in B.families, forall t,
      diamondFormula psi in fam.mcs t -> exists fam' in B.families, psi in fam'.mcs t) :
    BMCS D where
  families := B.families
  nonempty := B.nonempty
  modal_forward := -- from mutually_coherent + T-axiom
  modal_backward := -- from h_saturated via contraposition
  eval_family := B.eval_family
  eval_family_mem := B.eval_family_mem
```

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| UnionBoxContent consistency proof may fail | High | Generalize `diamond_boxcontent_consistent_constant` to multi-family UnionBoxContent |
| Iteration may not terminate | Medium | Use Zorn's lemma with the correct partial order (families ordered by inclusion) |
| Constant-family restriction too limiting | Low | All practical witnesses are constant; general case can use constant-bundle-per-time |
| Integration complexity with existing code | Medium | Maintain backward compatibility via adapter functions |

## Appendix

### References

1. `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - CoherentWitness, BoxContent, WitnessSeed
2. `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - FamilyCollection, Zorn framework
3. `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS structure definition
4. `Mathlib.ModelTheory.Types` - `FirstOrder.Language.Theory.CompleteType`
5. `Mathlib.Order.Zorn` - `zorn_subset_nonempty`
6. `Mathlib.Order.Ideal` - `Order.isIdeal_sUnion_of_isChain` (chain union preserves property)

### Key Definitions Summary

| Name | Location | Purpose |
|------|----------|---------|
| `BoxContent` | CoherentConstruction.lean:80 | Set of chi where Box chi appears in a family |
| `WitnessSeed` | CoherentConstruction.lean:113 | {psi} U BoxContent(base) for witness construction |
| `IsConstantFamily` | CoherentConstruction.lean:185 | Family where mcs is same at all times |
| `CoherentWitness` | CoherentConstruction.lean:155 | Witness with coherence proofs |
| `FamilyCollection` | SaturatedConstruction.lean:224 | Collection with box_coherence property |
| `box_coherence_pred` | SaturatedConstruction.lean:460 | Predicate for mutual Box-content membership |

### Proposed Type Signatures

```lean
-- Core structure
structure CoherentBundle (D : Type*) [...] where
  families : Set (IndexedMCSFamily D)
  all_constant : forall fam in families, IsConstantFamily fam
  nonempty : families.Nonempty
  eval_family : IndexedMCSFamily D
  eval_family_mem : eval_family in families
  mutually_coherent : MutuallyCoherent families

-- Union-based BoxContent
def UnionBoxContent (families : Set (IndexedMCSFamily D)) : Set Formula :=
  {chi | exists fam in families, chi in BoxContent fam}

-- Mutual coherence predicate
def MutuallyCoherent (families : Set (IndexedMCSFamily D)) : Prop :=
  forall fam in families, forall chi in UnionBoxContent families, forall t : D, chi in fam.mcs t

-- Saturation predicate
def CoherentBundle.isSaturated (B : CoherentBundle D) : Prop :=
  forall psi fam, fam in B.families -> forall t, diamondFormula psi in fam.mcs t ->
    exists fam' in B.families, psi in fam'.mcs t

-- BMCS conversion
noncomputable def CoherentBundle.toBMCS (B : CoherentBundle D) (h_sat : B.isSaturated) : BMCS D
```
