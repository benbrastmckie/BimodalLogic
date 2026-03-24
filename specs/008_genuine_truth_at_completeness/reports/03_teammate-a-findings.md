# Research Report: Modal Saturation and Alternative Domain Approaches

**Task**: 1008 - Resolution Paths for TM Logic Completeness Blockers
**Date**: 2026-03-20
**Focus**: Modal saturation techniques and alternative domain approaches
**Agent**: math-research-agent (teammate-a)

## Executive Summary

I investigated two resolution paths for the three fundamental sorries blocking TM logic completeness:

1. **Modal Saturation Approach**: Mathematically sound but requires potentially uncountable families, making it complex to implement in Lean4. The key insight is that transfinite iteration via `Ordinal.nfpFamily` could construct the saturated bundle, but the cardinality explosion (2^aleph_0 families) creates practical challenges.

2. **Alternative Domain Approach**: The most promising path is to **keep CanonicalMCS as the domain** and relax the TaskFrame constraint. The existing `canonicalMCSBFMCS` construction is sorry-free; the issue is purely at the semantic level where `TaskFrame D` requires `[AddCommGroup D]`.

## Key Findings

### 1. Modal Saturation Approach

#### 1.1 The Mathematical Problem

For a single-family BFMCS, `modal_backward` degenerates to:
```
phi in fam.mcs t -> Box(phi) in fam.mcs t
```

This is logically false: `p -> Box(p)` is NOT a theorem of TM logic. The universal quantification over families becomes trivial with only one family.

#### 1.2 Multi-Family Bundle Construction

**Goal**: Build a bundle where "phi in ALL families at t" genuinely implies Box(phi) at t.

**Approach from ModalSaturation.lean (lines 62-76)**:
```lean
def is_modally_saturated (B : BFMCS D) : Prop :=
  forall fam in B.families, forall t : D, forall psi : Formula,
    psi.diamond in fam.mcs t -> exists fam' in B.families, psi in fam'.mcs t
```

When satisfied, `saturated_modal_backward` (line 328) proves modal_backward via contraposition:
1. If phi in ALL families but Box(phi) NOT in fam.mcs t
2. Then neg(Box(phi)) = Diamond(neg phi) is in fam.mcs t (MCS negation completeness)
3. By saturation: exists fam' where neg(phi) is in fam'.mcs t
4. But phi is in ALL families including fam' -- contradiction

#### 1.3 Transfinite Iteration for Saturation

Mathlib provides transfinite fixed-point tools:

| Tool | Purpose |
|------|---------|
| `Ordinal.nfp` | Normal function fixed point |
| `Ordinal.nfpFamily` | Multi-function family fixed point |
| `transfiniteIterate` | Generic transfinite iteration |

**Construction Sketch**:
1. Start with single family F_0
2. For each Diamond(psi) lacking witness, add witness family
3. Iterate transfinitely until closure (fixed point)

**Cardinality Issue**: The set of all MCSes has cardinality 2^aleph_0 (uncountable). The saturation process could require uncountably many families, one for each potential Diamond witness.

**Reference**: `Ordinal.IsNormal.nfp_fp` guarantees fixed point for normal functions:
```lean
theorem Ordinal.IsNormal.nfp_fp : Order.IsNormal f -> f (Ordinal.nfp f a) = Ordinal.nfp f a
```

#### 1.4 Confidence Assessment

**Confidence**: Medium

**Pros**:
- Mathematically sound approach used in standard completeness proofs
- Mathlib has the transfinite iteration infrastructure
- `saturated_modal_backward` is already proven in ModalSaturation.lean

**Cons**:
- Potentially uncountable families create implementation complexity
- Maintaining temporal coherence (forward_F, backward_P) across all families is non-trivial
- Each new witness family must itself be temporally coherent

### 2. Alternative Domain Approach

#### 2.1 The Core Tension

| Construction | Domain | Status | Problem |
|--------------|--------|--------|---------|
| `canonicalMCSBFMCS` | `CanonicalMCS` | Sorry-free | No group structure |
| `intFMCS_basic` | `Int` | Has sorries | F/P witnesses missing |

**TaskFrame.lean (lines 93-97)**:
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
```

The constraint `[AddCommGroup D]` blocks using `CanonicalMCS` directly.

#### 2.2 Quotient Group Construction Analysis

**Question**: Can we define an `AddCommGroup` structure on CanonicalMCS or a quotient?

**Finding**: The archived `CanonicalQuotient` approach (Boneyard) used Antisymmetrization to get a `LinearOrder`, but this does NOT provide group structure.

**Mathematical Obstacle**: MCSes form a set, not naturally a group. There is no canonical addition operation on maximal consistent sets.

**Mathlib Quotient Tools**:
- `QuotientAddGroup.Quotient.addGroup` - requires underlying `AddGroup` to start with
- `AddCon.addGroup` - requires additive congruence on existing group

Neither applies because `CanonicalMCS` doesn't start as a group.

#### 2.3 Group Action Approach

**Idea**: Use a group action on CanonicalMCS to induce structure.

**From Mathlib**:
- `MulAction.orbitRel.Quotient` - quotient by orbit equivalence
- `MulAction.orbitEquivQuotientStabilizer` - orbit ~ G/stabilizer

**Problem**: We need to define a meaningful group action first. The natural "temporal shift" would require:
```
shift_by_n : CanonicalMCS -> CanonicalMCS  -- for each n : Int
```
But MCSes don't have a natural temporal shift operation that forms a group action.

#### 2.4 Recommended Alternative: Relax TaskFrame Constraint

**Key Insight from CanonicalFMCS.lean (lines 43-46)**:
> The FMCS and TemporalCoherentFamily only require `[Preorder D]`, not totality.
> The completeness chain (TruthLemma, Completeness) does NOT use totality, IsTotal,
> or LinearOrder.

**Question**: Does `TaskFrame` actually require `AddCommGroup` semantically?

**Analysis of TaskFrame Axioms**:
| Axiom | Uses Group Structure? |
|-------|----------------------|
| `nullity_identity` | Uses `0` (zero element) |
| `forward_comp` | Uses `+` and `<=` |
| `converse` | Uses `-` (negation) |

The group structure is used for:
1. Expressing "zero duration" identity
2. Composing durations additively
3. Expressing converse via negation

**Alternative**: Define a weaker `PreorderTaskFrame` that uses:
- A distinguished "zero" element instead of additive zero
- A composition operation (not necessarily group addition)
- A converse operation (not necessarily additive inverse)

The `CanonicalMCS` preorder already has:
- Root MCS as "zero" via `CanonicalMCS.instZero`
- CanonicalR as temporal ordering

### 3. Codebase Evidence

#### 3.1 CanonicalFMCS Working Construction

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`

**Key theorems (sorry-free)**:
- `canonicalMCS_forward_F` (line 222-228) - F witness existence
- `canonicalMCS_backward_P` (line 240-251) - P witness existence
- `temporal_coherent_family_exists_CanonicalMCS` (line 293-311) - Full temporal coherence

**Why it works**: Every MCS is in the domain, so witnesses from `canonical_forward_F` / `canonical_backward_P` are automatically domain elements.

#### 3.2 Modal Saturation Infrastructure

**File**: `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean`

**Available**:
- `is_modally_saturated` predicate (line 73)
- `saturated_modal_backward` theorem (line 328)
- `SaturatedBFMCS` structure (line 380)
- `axiom_5_negative_introspection` (line 425)

**Missing**: Actual construction of a saturated BFMCS (marked as removed in lines 193-209).

#### 3.3 IntBFMCS Blockers

**File**: `Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean`

**Lines 1157-1174 explain the fundamental blocker**:
> Linear chain constructions cannot satisfy forward_F because F-formulas
> don't persist through generic Lindenbaum extensions. When we build position
> n+1 from position n, the Lindenbaum extension can introduce G(~phi), which
> kills F(phi) = ~G(~phi).

This is not a proof gap but a **fundamental mathematical limitation** of linear chains.

## Recommended Approach

### Primary Recommendation: Generalized Semantic Domain

**Confidence**: High

Instead of forcing `D = Int`, generalize the completeness theorem to work with `D = CanonicalMCS`:

1. **Define `PreorderTaskFrame D` structure** that weakens `[AddCommGroup D]` to `[Preorder D] [Zero D]`
2. **Prove completeness for CanonicalMCS domain** using the existing sorry-free construction
3. **Instantiate for Int as corollary** (if needed) via embedding/transfer

**Justification**:
- The `canonicalMCSBFMCS` construction is already sorry-free
- The TruthLemma doesn't actually use group operations, only ordering
- This avoids the impossible cardinality mismatch (2^aleph_0 vs aleph_0)

### Secondary Recommendation: Modal Saturation (If Group Domain Required)

If `TaskFrame D` with `[AddCommGroup D]` is truly required:

1. **Implement transfinite modal saturation** using `Ordinal.nfpFamily`
2. **Maintain temporal coherence** by ensuring each witness family is built from temporally coherent chains
3. **Accept potentially uncountable families** as the mathematical reality

**Risk**: This approach is mathematically sound but implementation-heavy.

## Open Questions

1. **Why does TaskFrame require AddCommGroup?** If purely for semantic convenience, relaxing to Preorder may be acceptable.

2. **Can task_rel be reformulated?** Perhaps using relations on `CanonicalMCS` directly rather than durations.

3. **Is finite model property relevant?** If TM has FMP, finite chains might suffice, avoiding Lindenbaum issues.

4. **Multi-sorted semantics?** Could we have one sort (CanonicalMCS) for completeness proof and another (Int) for "practical" semantics?

## References

### Codebase Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` - Sorry-free construction
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Saturation infrastructure
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/IntBFMCS.lean` - Linear chain blockers
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame definition

### Mathlib Theorems
- `Ordinal.nfp` - Transfinite fixed point
- `Ordinal.nfpFamily` - Multi-function fixed point
- `Ordinal.IsNormal.nfp_fp` - Fixed point property
- `QuotientAddGroup.Quotient.addGroup` - Quotient group structure

### External Literature
- [Completeness in Modal Logic](https://math.uchicago.edu/~may/REU2020/REUPapers/Hebert.pdf) - Canonical model construction
- [A Henkin-Style Completeness Proof for S5](https://www.researchgate.net/publication/355273367_A_Henkin-Style_Completeness_Proof_for_the_Modal_Logic_S5) - Multi-family approaches
- [Canonical Models for Normal Logics](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf) - Standard techniques
