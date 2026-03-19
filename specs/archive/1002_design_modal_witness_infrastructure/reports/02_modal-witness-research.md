# Research Report: Task #1002

**Task**: Design Modal Witness Infrastructure for Multi-Family BFMCS
**Date**: 2026-03-19
**Focus**: Plan-recommended research + boneyard resource review

## Summary

The singleton BFMCS approach in MultiFamilyBFMCS.lean cannot prove `modal_backward` because "phi in MCS implies Box phi in MCS" is not valid in general modal logic. The solution requires a multi-family construction where Diamond witnesses reside in different families, enabling the contrapositive argument. The codebase already contains the core infrastructure: `saturated_modal_backward` in ModalSaturation.lean proves modal_backward from modal saturation, and `modal_witness_seed_consistent` in ChainFMCS.lean proves that `{psi} union BoxContent(M)` is consistent when `Diamond(psi) in M`.

## Findings

### Existing Boneyard Resources

Reviewed all files in `Theories/Bimodal/Boneyard/`:

| File | Relevance | Reusable Content |
|------|-----------|------------------|
| Task971/BFMCSTruth.lean | Archived | Defines `bmcs_truth_at` with box quantifying over bundle families |
| Task971/TruthLemma.lean | Archived | Complete truth lemma proof using modal_forward/backward |
| Task970/TemporalCoherentConstruction.lean | Partially Deprecated | `temporal_backward_G/H` theorems, `TemporalCoherentFamily` structure |
| Task956_IntRat/CanonicalCompleteness.lean | Boneyard | Int-specific approaches, largely superseded |

**Key Observation**: The archived files in Task971 show the complete BFMCS truth lemma infrastructure is working when modal_forward and modal_backward are provided. The bottleneck is constructing a BFMCS where modal_backward holds without sorry.

### Current BFMCS Infrastructure Analysis

**Location**: `Theories/Bimodal/Metalogic/Bundle/`

1. **BFMCS.lean** (lines 88-119): Defines the BFMCS structure with:
   - `families : Set (FMCS D)` - the bundle of families
   - `modal_forward : forall fam in families, forall phi t, Box phi in fam.mcs t -> forall fam' in families, phi in fam'.mcs t`
   - `modal_backward : forall fam in families, forall phi t, (forall fam' in families, phi in fam'.mcs t) -> Box phi in fam.mcs t`

2. **MultiFamilyBFMCS.lean** (lines 174-280): The current blocked implementation:
   - Constructs `singletonCanonicalBFMCS` with a single family
   - `modal_forward` proven trivially via T-axiom
   - `modal_backward` has sorry at line 277

**Why modal_backward Fails for Singleton**:

The proof attempts to show: If phi in t.world (the only family's MCS), then Box phi in t.world.

The attempted argument:
1. Assume neg(Box phi) in t.world
2. Get Diamond(neg phi) in t.world (via box_dne_theorem contrapositive)
3. Diamond(neg phi) requires a witness where neg phi holds
4. In singleton, the only accessible world is t.world itself
5. So neg phi would be in t.world, contradicting phi in t.world

**The Gap**: Step 4 requires "the only accessible world is t.world itself" which is a **semantic** property not derivable from **syntactic** MCS membership. An MCS containing {phi, Diamond(neg phi)} is perfectly consistent - it represents a world where phi is true locally but possibly false elsewhere.

### Existing Solution Infrastructure

**ModalSaturation.lean** (lines 328-367): The `saturated_modal_backward` theorem ALREADY proves modal_backward from modal saturation:

```lean
theorem saturated_modal_backward (B : BFMCS D) (h_sat : is_modally_saturated B)
    (fam : FMCS D) (hfam : fam ∈ B.families) (phi : Formula) (t : D)
    (h_all : forall fam' in B.families, phi in fam'.mcs t) :
    Formula.box phi in fam.mcs t
```

The proof by contraposition:
1. Assume phi in all families but neg(Box phi) in fam.mcs t
2. By box_dne_theorem: Diamond(neg phi) in fam.mcs t
3. By modal saturation: exists fam' with neg phi in fam'.mcs t
4. But phi in ALL families including fam' - contradiction

**Modal Saturation Definition** (line 73):
```lean
def is_modally_saturated (B : BFMCS D) : Prop :=
  forall fam in B.families, forall t : D, forall psi : Formula,
    psi.diamond in fam.mcs t -> exists fam' in B.families, psi in fam'.mcs t
```

### Modal Witness Seed Consistency

**ChainFMCS.lean** (lines 59-100): Contains `MCSBoxContent` definition and `modal_witness_seed_consistent`:

```lean
def MCSBoxContent (M : Set Formula) : Set Formula :=
  {phi | Formula.box phi in M}

theorem modal_witness_seed_consistent -- Proven
```

This proves: If Diamond(psi) in MCS M, then {psi} union BoxContent(M) is consistent.

The proof follows the same pattern as `forward_temporal_witness_seed_consistent`:
1. If the seed is inconsistent, L subset seed derives bot
2. Case split on whether psi is in L
3. Use generalized modal K to show Box(bot) or Box(neg psi) in M
4. Contradict with Diamond(psi) in M

### CanonicalFMCS.lean: All-MCS Approach (Sorry-Free)

**Location**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

This is the **key architectural pattern** to follow. It provides:

1. **CanonicalMCS type** (line 78): All maximal consistent sets
2. **canonicalMCSBFMCS** (line 184): FMCS over CanonicalMCS
3. **canonicalMCS_forward_F** (line 222): SORRY-FREE
4. **canonicalMCS_backward_P** (line 240): SORRY-FREE

The insight: By using ALL MCSes as the domain, witnesses are automatically in the domain.

### Multi-Family Modal Coherence Design

The correct approach follows from ModalSaturation.lean + CanonicalFMCS.lean:

**Phase 1: Define Modally Saturated Bundle**

The bundle should contain:
- The primary family (CanonicalMCS -> MCS)
- Witness families for every Diamond formula

**Phase 2: Witness Family Construction**

For Diamond(psi) in family fam at time t:
1. Seed = {psi} union BoxContent(fam.mcs t)
2. Extend via Lindenbaum to get witness MCS
3. Wrap as CanonicalMCS -> forms witness family

**Phase 3: Bundle Closure**

Use Zorn's lemma or explicit enumeration to close under Diamond witnesses.

### Key Structures and Lemmas

**Existing Proven Lemmas to Use**:

```lean
-- ModalSaturation.lean
theorem saturated_modal_backward -- Key theorem
theorem diamond_implies_psi_consistent -- Seed consistency
lemma SetMaximalConsistent.neg_box_implies_box_neg_box -- Axiom 5

-- ChainFMCS.lean
def MCSBoxContent (M : Set Formula) : Set Formula
theorem MCSBoxContent_subset_of_CanonicalR -- BoxContent propagation
theorem MCSBoxContent_subset_Boxg_content -- Content hierarchy

-- CanonicalFMCS.lean
noncomputable def canonicalMCSBFMCS : FMCS CanonicalMCS
theorem canonicalMCS_forward_F -- F-witness sorry-free
theorem canonicalMCS_backward_P -- P-witness sorry-free
```

**New Structures Needed**:

```lean
/-- A diamond witness links Diamond(psi) in one family to psi in another. -/
structure DiamondWitness (D : Type*) [Preorder D] where
  source_family : FMCS D
  time : D
  inner_formula : Formula
  diamond_mem : inner_formula.diamond in source_family.mcs time
  witness_family : FMCS D
  witness_mem : inner_formula in witness_family.mcs time

/-- A BFMCS is modally closed if every Diamond has a witness in the bundle. -/
def is_modally_closed (B : BFMCS D) : Prop := is_modally_saturated B

/-- The modal saturation closure of a BFMCS. -/
noncomputable def modal_saturation_closure (B_init : BFMCS D) : BFMCS D
```

**Key Lemma Statements Needed**:

```lean
-- 1. Modal witness seed construction
def modal_witness_seed (M : Set Formula) (psi : Formula) : Set Formula :=
  {psi} union MCSBoxContent M

-- 2. Seed consistency (likely already proven as diamond_implies_psi_consistent)
theorem modal_witness_seed_consistent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_diamond : psi.diamond in M) :
    SetConsistent (modal_witness_seed M psi)

-- 3. Witness family construction
noncomputable def construct_modal_witness_family (D : Type*) [Preorder D]
    (base_fam : FMCS D) (t : D) (psi : Formula)
    (h_diamond : psi.diamond in base_fam.mcs t) : FMCS D

-- 4. Witness family contains psi
theorem witness_family_contains_psi (base_fam : FMCS D) (t : D) (psi : Formula)
    (h_diamond : psi.diamond in base_fam.mcs t) :
    psi in (construct_modal_witness_family D base_fam t psi h_diamond).mcs t

-- 5. BoxContent propagation to witness
theorem witness_family_boxcontent_propagates (base_fam : FMCS D) (t : D) (psi : Formula)
    (h_diamond : psi.diamond in base_fam.mcs t) :
    MCSBoxContent (base_fam.mcs t) subset
    (construct_modal_witness_family D base_fam t psi h_diamond).mcs t

-- 6. Closure construction produces saturated bundle
theorem modal_closure_is_saturated (B_init : BFMCS D) :
    is_modally_saturated (modal_saturation_closure B_init)

-- 7. Final theorem: saturated bundle satisfies modal_backward
-- (Already proven as saturated_modal_backward)
```

## Recommendations

1. **Use existing `saturated_modal_backward`** (ModalSaturation.lean line 328) - do NOT rewrite the contrapositive proof. Focus on constructing a saturated bundle.

2. **Follow CanonicalFMCS.lean pattern**: Use ALL CanonicalMCS elements as the domain. This makes witness MCSes automatically domain elements, avoiding reachability issues.

3. **Leverage `diamond_implies_psi_consistent`** (ModalSaturation.lean line 148) for seed consistency - this already proves the key consistency lemma.

4. **Closure via subformula bound**: For completeness of a specific formula phi, only Diamond subformulas of phi need witnesses. The subformula closure is finite, avoiding cardinality issues.

5. **BoxContent propagation is critical**: The MF axiom (Box phi -> Box(G phi)) ensures BoxContent propagates through CanonicalR, which is needed for modal coherence across families.

## References

| File | Purpose |
|------|---------|
| `Metalogic/Bundle/BFMCS.lean` | BFMCS structure definition with modal_forward/backward |
| `Metalogic/Bundle/ModalSaturation.lean` | `saturated_modal_backward`, `is_modally_saturated`, `diamond_implies_psi_consistent` |
| `Metalogic/Bundle/ChainFMCS.lean` | `MCSBoxContent`, BoxContent propagation theorems |
| `Metalogic/Bundle/CanonicalFMCS.lean` | Sorry-free temporal coherent family over all MCSes |
| `Metalogic/Bundle/WitnessSeed.lean` | Temporal witness seed patterns (analogous to modal) |
| `Metalogic/Algebraic/MultiFamilyBFMCS.lean` | Current blocked implementation |

## Next Steps

The revised plan should focus ONLY on implementation (no research needed):

**Phase 1**: Define `modal_witness_seed` and prove seed consistency using `diamond_implies_psi_consistent`.

**Phase 2**: Implement `construct_modal_witness_family` using Lindenbaum extension of the seed.

**Phase 3**: Prove BoxContent propagation for witness families (likely straightforward from seed definition).

**Phase 4**: Define `modal_saturation_closure` as the union of base bundle with all witness families. For closure-based completeness (specific formula phi), enumerate Diamond subformulas.

**Phase 5**: Prove `is_modally_saturated` for the closure using the witness construction.

**Phase 6**: Derive `modal_backward` using existing `saturated_modal_backward`.

All key lemmas have patterns in the codebase (temporal analogues, axiom 5 infrastructure). Implementation should be mechanical once the design is understood.
