# Research Report: Task #853 - Construct CoherentBundle from Context

**Task**: 853 - construct_coherentbundle_from_context
**Date**: 2026-02-03
**Focus**: Construct CoherentBundle from consistent context, Lindenbaum construction, constantIndexedMCSFamily, coherent witnesses with Zorn's lemma
**Session ID**: sess_1738615424_629724

## Summary

Task 853 is the main entry point for completeness theorem integration via the CoherentBundle approach. The goal is to construct a saturated `CoherentBundle` from a consistent context, converting it to an axiom-free `BMCS`. The key infrastructure from tasks 851 and 852 is complete: `CoherentBundle.toBMCS` is fully proven with no sorries. The remaining work is constructing a saturated CoherentBundle by: (1) building a base family via Lindenbaum, (2) creating a singleton CoherentBundle, and (3) adding coherent witnesses for all Diamond formulas using Zorn's lemma or iteration. The primary challenge is preserving mutual coherence when adding witnesses.

## Executive Summary

**Key Findings**:
1. `CoherentBundle` structure is fully defined and `toBMCS` conversion is complete (no sorries)
2. `constantIndexedMCSFamily` creates the base family from an MCS
3. `constructCoherentWitness` creates coherent witnesses for Diamond formulas (proven for constant families)
4. The main gap is assembling witnesses into a saturated `CoherentBundle` while preserving mutual coherence
5. Three sorries in `SaturatedConstruction.lean` (lines 714, 733, 785) document the Lindenbaum control problem but these are in a different code path

**Recommended Approach**:
- Use the constant-family witness construction from `CoherentConstruction.lean`
- Build saturation iteratively or via Zorn's lemma
- The key theorem `diamond_boxcontent_consistent_constant` provides the consistency proof for witness seeds

## Context and Dependencies

### Prerequisites (Completed)

| Task | Status | Contribution |
|------|--------|--------------|
| 851 | COMPLETED | Defined `CoherentBundle`, `UnionBoxContent`, `MutuallyCoherent`, basic lemmas |
| 852 | COMPLETED (subsumed) | `CoherentBundle.toBMCS` fully proven in task 851 |
| 844 | COMPLETED | `CoherentWitness`, `diamond_boxcontent_consistent_constant` |

### Downstream Impact

This task directly enables:
- Axiom-free completeness theorem
- Elimination of `singleFamily_modal_backward_axiom` in `Construction.lean`
- Publication-ready proof of TM logic completeness

## Findings

### 1. Existing Infrastructure Analysis

#### 1.1 CoherentBundle Structure (CoherentConstruction.lean:474-487)

```lean
structure CoherentBundle (D : Type*) [...] where
  families : Set (IndexedMCSFamily D)
  all_constant : forall fam in families, IsConstantFamily fam
  nonempty : families.Nonempty
  eval_family : IndexedMCSFamily D
  eval_family_mem : eval_family in families
  mutually_coherent : MutuallyCoherent families
```

**Key Properties**:
- `all_constant`: All families are time-independent (fam.mcs t = fam.mcs s)
- `mutually_coherent`: Every family contains `UnionBoxContent` from all families

#### 1.2 Saturation Predicate (CoherentConstruction.lean:496-499)

```lean
def CoherentBundle.isSaturated (B : CoherentBundle D) : Prop :=
  forall phi : Formula, forall fam in B.families, forall t : D,
    Formula.neg (Formula.box phi) in fam.mcs t ->
    exists fam' in B.families, Formula.neg phi in fam'.mcs t
```

**Note**: The saturation uses `neg(Box phi)` directly rather than `diamondFormula` to avoid syntactic mismatch issues.

#### 1.3 toBMCS Conversion (CoherentConstruction.lean:580-612)

```lean
noncomputable def CoherentBundle.toBMCS (B : CoherentBundle D)
    (h_sat : B.isSaturated) : BMCS D where
  -- modal_forward: from chi_in_all_families (mutual coherence)
  -- modal_backward: by contraposition using saturation
```

**Status**: Fully proven, no sorries. This is the target endpoint for the construction.

#### 1.4 Base Family Construction (Construction.lean:130-161)

```lean
noncomputable def constantIndexedMCSFamily (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    IndexedMCSFamily D where
  mcs := fun _ => M
  is_mcs := fun _ => h_mcs
  -- Temporal coherence via T-axioms (same MCS at all times)
```

**Property**: Creates a constant family that trivially satisfies all temporal coherence conditions.

#### 1.5 Coherent Witness Construction (CoherentConstruction.lean:349-364)

```lean
noncomputable def constructCoherentWitness (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) (psi : Formula) (t : D)
    (h_diamond : diamondFormula psi in base.mcs t) : CoherentWitness base
```

**Key Theorem** (`diamond_boxcontent_consistent_constant`, lines 244-316):
- For a constant family `base` with `Diamond psi in base.mcs t`
- The set `{psi} U BoxContent(base)` is consistent
- This enables Lindenbaum extension to build the witness MCS

### 2. The Saturation Challenge

#### 2.1 Single Witness vs. Full Saturation

A `CoherentWitness` is coherent with its single base family. The challenge is extending this to **mutual coherence** across multiple witnesses.

**The Problem**:
1. Witness W1 for Diamond psi1 contains BoxContent(base)
2. Witness W2 for Diamond psi2 contains BoxContent(base)
3. But W1 may contain Box formulas NOT in W2, and vice versa
4. Adding both to a bundle may break `MutuallyCoherent`

#### 2.2 The Solution: Shared BoxContent

**Key Insight**: If we build ALL witnesses from the same `UnionBoxContent`, mutual coherence is preserved by construction.

For a collection C of constant families:
1. Compute `UnionBoxContent(C)` = union of all `BoxContent(fam)` for fam in C
2. For each unsatisfied Diamond psi, build witness with seed `{psi} U UnionBoxContent(C)`
3. Since all witnesses share the same UnionBoxContent, they are mutually coherent

**Challenge**: UnionBoxContent grows as we add witnesses. Need to show the iteration stabilizes.

#### 2.3 Existing Sorries in SaturatedConstruction.lean

The module `SaturatedConstruction.lean` has 3 sorries (lines 714, 733, 785) for a different approach (general `FamilyCollection`). These stem from:

| Line | Issue | Root Cause |
|------|-------|------------|
| 714 | `{psi} U BoxContent(M)` consistency | Multi-family BoxContent spans different times |
| 733 | BoxContent time mismatch | `exists s` vs specific `t` |
| 785 | Lindenbaum adds uncontrolled Box formulas | Breaking box_coherence when adding W to M |

**These sorries are in a DIFFERENT code path** that uses `FamilyCollection` (non-constant families). The `CoherentBundle` approach in `CoherentConstruction.lean` avoids these issues by restricting to constant families.

### 3. Construction Strategy

#### 3.1 Phase 1: Build Base Family

```lean
-- From a consistent context Gamma
let h_set_cons := list_consistent_to_set_consistent h_cons
let M := lindenbaumMCS Gamma h_cons  -- or lindenbaumMCS_set for set version
let h_mcs := lindenbaumMCS_is_mcs Gamma h_cons
let base := constantIndexedMCSFamily M h_mcs
```

**Property**: `base` is a constant family containing all of Gamma.

#### 3.2 Phase 2: Create Initial CoherentBundle

```lean
noncomputable def initialCoherentBundle (base : IndexedMCSFamily D)
    (h_const : IsConstantFamily base) : CoherentBundle D where
  families := {base}
  all_constant := fun fam hfam => by simp at hfam; rw [hfam]; exact h_const
  nonempty := Set.singleton_nonempty base
  eval_family := base
  eval_family_mem := Set.mem_singleton base
  mutually_coherent := MutuallyCoherent_singleton base h_const
```

**Property**: A singleton is trivially mutually coherent (proven via T-axiom).

#### 3.3 Phase 3: Saturation via Witnesses

**Two Options**:

**Option A: Iterative Saturation (Finite Diamond set)**
```lean
-- For each unsatisfied Diamond psi in the closure of target formula
-- 1. Compute current UnionBoxContent
-- 2. Show {psi} U UnionBoxContent is consistent
-- 3. Build constant witness via Lindenbaum
-- 4. Add witness to bundle
-- 5. Repeat until all Diamonds satisfied
```

**Option B: Zorn's Lemma (Full saturation)**
```lean
-- Define partial order on CoherentBundles by family inclusion
-- Show chains have upper bounds (union preserves mutual coherence)
-- Apply zorn_subset_nonempty
-- Maximal element must be saturated (otherwise could add witness)
```

**Recommended**: Option A for clarity; Option B for mathematical elegance.

#### 3.4 Key Lemma Needed: Multi-Family Witness Consistency

The generalization of `diamond_boxcontent_consistent_constant`:

```lean
theorem diamond_unionboxcontent_consistent (B : CoherentBundle D)
    (psi : Formula) (fam : IndexedMCSFamily D) (h_fam : fam in B.families) (t : D)
    (h_diamond : diamondFormula psi in fam.mcs t) :
    SetConsistent ({psi} U UnionBoxContent B.families)
```

**Proof Sketch**:
1. By `MutuallyCoherent`, all families contain `UnionBoxContent`
2. In particular, `fam.mcs t` contains `UnionBoxContent` (at time t, by constancy at all times)
3. The proof of `diamond_boxcontent_consistent_constant` applies with `UnionBoxContent` replacing `BoxContent(base)`
4. The K-distribution chain argument uses `generalized_modal_k` + `set_mcs_closed_under_derivation`

### 4. Mathlib Resources

| Resource | Location | Usage |
|----------|----------|-------|
| `zorn_subset_nonempty` | `Mathlib.Order.Zorn` | Zorn's lemma for subset partial order |
| `IsChain` | `Mathlib.Order.Chain` | Chain predicate for Zorn |
| `Set.sUnion` | Core | Union of chain for upper bound |

The existing `box_coherence_sUnion` lemma (SaturatedConstruction.lean:469-487) shows chains preserve box coherence. A similar lemma for `MutuallyCoherent` is needed.

### 5. Integration with Completeness

#### 5.1 Main Entry Point Signature

```lean
/-- Construct a saturated CoherentBundle from a consistent context -/
noncomputable def constructCoherentBundleFromContext
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    { B : CoherentBundle D // B.isSaturated } := ...

/-- Convert to BMCS for completeness theorem -/
noncomputable def construct_coherent_bmcs
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) : BMCS D :=
  let B := constructCoherentBundleFromContext Gamma h_cons
  B.val.toBMCS B.property
```

#### 5.2 Context Preservation

```lean
theorem construct_coherent_bmcs_contains_context
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    forall g in Gamma, g in (construct_coherent_bmcs Gamma h_cons).eval_family.mcs 0
```

This follows from:
1. Base family contains Gamma (Lindenbaum extension)
2. eval_family is the base family (initial bundle)
3. Saturation preserves eval_family

## Sorry Characterization

### Sorries in Related Modules

| Module | Count | Category | Impact |
|--------|-------|----------|--------|
| `SaturatedConstruction.lean` | 3 | Different approach | Not used by CoherentBundle path |
| `Construction.lean` | 1 axiom | Construction assumption | `singleFamily_modal_backward_axiom` |
| `CoherentConstruction.lean` | 0 | N/A | Fully proven |

**Key Point**: The `CoherentBundle.toBMCS` conversion has **no sorries**. The sorries in `SaturatedConstruction.lean` are in a different code path (`FamilyCollection`) that this task does not use.

### Task 853 Target

This task should produce code with **zero new sorries**. The main construction can be:
- Fully proven using the constant-family approach, OR
- Documented with explicit axioms if full proof is infeasible

**Remediation Path**: The `diamond_boxcontent_consistent_constant` theorem provides the foundation. Extending to `UnionBoxContent` requires careful generalization but follows the same structure.

## Recommendations

### Implementation Plan Outline

**Phase 1: Initial CoherentBundle Construction**
- Define `initialCoherentBundle` from a constant base family
- Prove `MutuallyCoherent_singleton` (exists at line 435)
- Prove `initialCoherentBundle_contains_context`

**Phase 2: Witness Addition with Mutual Coherence**
- Generalize `diamond_boxcontent_consistent_constant` to `UnionBoxContent`
- Define `addCoherentWitness` that adds a witness while preserving mutual coherence
- Prove the key lemma: witness with `{psi} U UnionBoxContent` is mutually coherent with existing families

**Phase 3: Saturation Construction**
- Option A: Iterative saturation for finite Diamond closure
- Option B: Zorn's lemma for full saturation
- Prove maximality implies saturation

**Phase 4: Main Entry Point and Integration**
- Define `constructCoherentBundleFromContext`
- Define `construct_coherent_bmcs` using `toBMCS`
- Prove context preservation theorem

### Risk Assessment

| Risk | Impact | Mitigation |
|------|--------|------------|
| `UnionBoxContent` consistency proof fails | High | Start with proof sketch, verify structure matches `diamond_boxcontent_consistent_constant` |
| Mutual coherence not preserved on witness addition | High | Build witness with full UnionBoxContent, not just single-family BoxContent |
| Zorn termination argument | Medium | Can use finite closure approach as alternative |
| Integration complexity | Low | `toBMCS` is already proven; just need to construct saturated bundle |

### Success Criteria

1. `constructCoherentBundleFromContext` produces a saturated `CoherentBundle`
2. `construct_coherent_bmcs` produces a valid `BMCS` with no axiom usage
3. Context preservation theorem proven
4. Zero new sorries (or clearly documented axioms if needed)
5. Compiles without errors

## References

### Codebase Files

- `Theories/Bimodal/Metalogic/Bundle/CoherentConstruction.lean` - Main CoherentBundle implementation
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Base family construction, axiom-based approach
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Zorn infrastructure (different path)
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS structure definition
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Saturation theory
- `Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean` - Lindenbaum re-exports
- `Theories/Bimodal/Metalogic/Core/MCSProperties.lean` - MCS lemmas

### Related Tasks

- Task 851: Define CoherentBundle structure (COMPLETED)
- Task 852: Implement toBMCS conversion (COMPLETED, subsumed by 851)
- Task 844: CoherentWitness implementation (COMPLETED)
- Task 842: Zorn's lemma research (COMPLETED)

### Mathlib References

- `Mathlib.Order.Zorn` - `zorn_subset_nonempty`
- `Mathlib.Data.Set.Basic` - Set operations
- `Mathlib.Data.Finset.Basic` - Finite set operations

## Next Steps

1. Create implementation plan based on this research
2. Implement Phase 1 (initial bundle) as a first milestone
3. Focus on the key lemma: `diamond_unionboxcontent_consistent`
4. Choose between iterative vs. Zorn approach based on proof complexity
5. Integrate with completeness theorem

## Appendix: Key Type Signatures

```lean
-- Existing (CoherentConstruction.lean)
def BoxContent (fam : IndexedMCSFamily D) : Set Formula
def UnionBoxContent (families : Set (IndexedMCSFamily D)) : Set Formula
def MutuallyCoherent (families : Set (IndexedMCSFamily D)) : Prop
structure CoherentBundle (D : Type*) [...]
def CoherentBundle.isSaturated (B : CoherentBundle D) : Prop
def CoherentBundle.toBMCS (B : CoherentBundle D) (h_sat : B.isSaturated) : BMCS D

-- Existing (Construction.lean)
def ContextConsistent (Gamma : List Formula) : Prop
def constantIndexedMCSFamily (M : Set Formula) (h_mcs : SetMaximalConsistent M) : IndexedMCSFamily D
def lindenbaumMCS (Gamma : List Formula) (h_cons : ContextConsistent Gamma) : Set Formula

-- Needed (This Task)
def initialCoherentBundle (base : IndexedMCSFamily D) (h_const : IsConstantFamily base) : CoherentBundle D
theorem diamond_unionboxcontent_consistent (B : CoherentBundle D) ...
def addCoherentWitness (B : CoherentBundle D) (psi : Formula) ... : CoherentBundle D
def constructCoherentBundleFromContext (Gamma : List Formula) (h_cons : ...) : { B // B.isSaturated }
def construct_coherent_bmcs (Gamma : List Formula) (h_cons : ...) : BMCS D
theorem construct_coherent_bmcs_contains_context (Gamma : List Formula) ...
```
