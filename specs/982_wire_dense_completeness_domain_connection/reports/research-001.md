# Research Report: Wire Dense Completeness Domain Connection

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Started**: 2026-03-16T12:00:00Z
- **Completed**: 2026-03-16T14:30:00Z
- **Effort**: 2.5 hours
- **Dependencies**: Tasks 956 (D construction), 978 (typeclass architecture)
- **Sources/Inputs**:
  - `Theories/Bimodal/Metalogic/StagedConstruction/Completeness.lean`
  - `Theories/Bimodal/FrameConditions/Completeness.lean`
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`
  - `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
  - `Theories/Bimodal/Metalogic/StagedConstruction/DFromCantor.lean`
  - `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
  - `Theories/Bimodal/Metalogic/DenseCompleteness.lean`
- **Artifacts**: This report
- **Standards**: report-format.md, artifact-formats.md, proof-debt-policy.md

## Project Context

- **Upstream Dependencies**:
  - `temporal_coherent_family_exists_CanonicalMCS` (sorry-free)
  - `canonical_truth_lemma` / `shifted_truth_lemma` (sorry-free, D = Int)
  - `cantor_iso : TimelineQuot ≃o Rat` (sorry-free)
- **Downstream Dependents**:
  - `dense_completeness_fc` (currently sorried in FrameConditions/Completeness.lean)
  - `DenseCompletenessStatement` wiring
- **Alternative Paths**: Direct TimelineQuot FMCS vs. Transfer Theorem vs. Semantic Quotient
- **Potential Extensions**: Enables publication-ready dense completeness theorem

## Executive Summary

- **Gap Identified**: The BFMCS truth lemma uses `D = Int` (or CanonicalMCS with Preorder), while the dense completeness statement quantifies over all `D` with `DenselyOrdered D`. TimelineQuot is the canonical dense domain (≃o Q) but lacks FMCS infrastructure.
- **Root Cause**: Two separate domain constructions were developed:
  1. CanonicalMCS: All MCSs with reflexive-closure Preorder (truth lemma works here)
  2. TimelineQuot: Antisymmetrization of DenseTimelineElem (has DenselyOrdered instance)
- **Recommended Resolution**: Build FMCS directly over TimelineQuot by embedding DenseTimelineElem MCSs
- **Estimated Effort**: 3-4 hours for Option A (direct construction)
- **Current Sorries**: 1 in `dense_completeness_fc` (wiring), not in any component

## Context and Scope

### The Domain Mismatch Problem

The dense completeness pipeline has two domain types that do not directly connect:

1. **CanonicalMCS** (in `Bundle/CanonicalFMCS.lean`):
   - Type: Structure wrapping `{world : Set Formula, is_mcs : SetMaximalConsistent world}`
   - Order: Preorder via reflexive closure of CanonicalR
   - Properties: NOT total, NOT DenselyOrdered
   - Truth Lemma: PROVEN sorry-free

2. **TimelineQuot** (in `StagedConstruction/CantorApplication.lean`):
   - Type: `Antisymmetrization DenseTimelineElem (· ≤ ·)`
   - Order: LinearOrder from Antisymmetrization + IsTotal
   - Properties: Countable, NoMaxOrder, NoMinOrder, DenselyOrdered, ≃o Rat
   - Truth Lemma: NOT built

### The Completeness Statement

The `DenseCompletenessStatement` in `FrameConditions/Completeness.lean` requires:
```lean
def DenseCompletenessStatement (φ : Formula) : Prop :=
  (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
     [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
     [DenseTemporalFrame D], valid_over D φ) →
  Nonempty ([] ⊢ φ)
```

The proof needs a canonical model over some domain satisfying `DenselyOrdered D`. TimelineQuot satisfies this, but:
- TimelineQuot depends on a root MCS (`root_mcs : Set Formula`)
- The completeness proof needs to construct this root from the unprovable formula
- The truth lemma infrastructure expects `BFMCS Int` (or CanonicalMCS), not TimelineQuot

## Findings

### Finding 1: CanonicalMCS and TimelineQuot Are Structurally Different

| Property | CanonicalMCS | TimelineQuot |
|----------|--------------|--------------|
| Definition | All MCSs as a type | Quotient of DenseTimelineElem |
| Elements | Any MCS | Equivalence classes of staged MCSs |
| Order | Preorder (non-total) | LinearOrder |
| DenselyOrdered | No | Yes |
| AddCommGroup | No | No |
| Root dependency | None | Requires root_mcs parameter |

**Key Insight**: TimelineQuot elements are equivalence classes `[p]` where `p : DenseTimelineElem = { p : StagedPoint // p ∈ denseTimelineUnion }`. Each `p` has `p.val.mcs : Set Formula` and `p.val.is_mcs : SetMaximalConsistent p.val.mcs`.

### Finding 2: DenseTimelineElem Contains the MCS Information

Looking at `DenseTimeline.lean`:
```lean
def DenseTimelineElem : Type :=
  { p : StagedPoint // p ∈ denseTimelineUnion root_mcs root_mcs_proof }
```

And `StagedPoint` contains:
```lean
structure StagedPoint where
  mcs : Set Formula
  is_mcs : SetMaximalConsistent mcs
  introduced_at : Stage
```

So every `t : DenseTimelineElem` has an associated MCS `t.val.mcs`. This is the key to bridging the gap.

### Finding 3: The Truth Lemma Structure

The `canonical_truth_lemma` in `CanonicalConstruction.lean` proves:
```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (phi : Formula) :
    phi ∈ fam.mcs t ↔ truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi
```

The key requirements are:
1. An `FMCS D` with `mcs : D → Set Formula`
2. `forward_G` and `backward_H` coherence
3. A `BFMCS D` with `modal_forward` and `modal_backward`
4. `temporally_coherent`: F and P witnesses exist

### Finding 4: TimelineQuot Has No AddCommGroup

The completeness statement requires `AddCommGroup D`. TimelineQuot is `Antisymmetrization DenseTimelineElem (· ≤ ·)` which is just an ordered type, NOT an additive group.

However, examining `CanonicalConstruction.lean` more carefully:
- `CanonicalTaskFrame` uses `D = Int` and requires `canonical_task_rel` using durations
- The task relation definition uses `d > 0`, `d = 0`, `d < 0` cases

**Critical Insight**: The `AddCommGroup` constraint on D in `DenseCompletenessStatement` comes from the `TaskFrame` definition, NOT from the truth lemma core logic.

### Finding 5: Resolution Options Analysis

**Option A: Build FMCS over TimelineQuot directly**

Approach:
1. Define `FMCS (TimelineQuot root_mcs root_mcs_proof)`
2. `mcs t` := the MCS of some representative of `t` (well-defined since equivalent points have equivalent MCSs)
3. `forward_G`: follows from CanonicalR transitivity + quotient structure
4. `backward_H`: follows from g_content/h_content duality

Challenges:
- TimelineQuot lacks AddCommGroup (no `+` operation)
- Would need to bypass TaskFrame structure or modify it

Estimated Effort: 3-4 hours (requires TaskFrame refactoring)

**Option B: Use CanonicalMCS with Quotient Transfer**

Approach:
1. Keep truth lemma over CanonicalMCS
2. Prove that CanonicalMCS truth implies TimelineQuot truth via quotient map
3. Show the quotient map preserves semantic evaluation

Challenges:
- CanonicalMCS includes ALL MCSs, while TimelineQuot is a specific staged subset
- The quotient map is complex (CanonicalMCS → TimelineQuot is not natural)
- Would need to show dense timeline points cover all relevant MCSs

Estimated Effort: 5-6 hours (complex quotient reasoning)

**Option C: Bypass TimelineQuot, Use CanonicalMCS Directly**

Approach:
1. Note that DenselyOrdered is not intrinsic to the completeness proof
2. The completeness proof only needs: existence of a model where neg φ is true
3. Use CanonicalMCS (which has the truth lemma) directly
4. Show DenselyOrdered is not actually needed for the canonical model argument

Challenges:
- The statement `DenseCompletenessStatement` explicitly requires `DenselyOrdered D`
- Would need to reformulate completeness differently

Estimated Effort: 2 hours (but changes the statement)

**Option D: Unified Domain Construction (Recommended)**

Approach:
1. Recognize that TimelineQuot elements ARE MCSs (via quotient projection)
2. Build FMCS over TimelineQuot using `ofAntisymmetrization` to extract representatives
3. Use the fact that all representatives of a quotient class have equivalent MCSs (by mutual CanonicalR)
4. Prove coherence conditions hold on the quotient

Key Observations:
- `toAntisymmetrization` and `ofAntisymmetrization` form a quotient interface
- The MCS at a quotient element is well-defined up to equivalence
- CanonicalR transitivity gives forward_G; duality gives backward_H
- The temporal coherent family exists by staged construction

Estimated Effort: 3-4 hours (clean construction)

## Decisions

1. **Recommended Approach**: Option D - Unified Domain Construction
2. **Key Technical Step**: Define `FMCS (TimelineQuot root_mcs root_mcs_proof)` where `mcs t` uses a representative MCS
3. **Truth Lemma Strategy**: Adapt `canonical_truth_lemma` proof pattern for TimelineQuot domain

## Recommendations

### Priority 1: Define TimelineQuot-based FMCS (2 hours)

Create a new file `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotFMCS.lean`:

```lean
-- Sketch
def timelineQuotMCS (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (t : TimelineQuot root_mcs root_mcs_proof) : Set Formula :=
  (ofAntisymmetrization (· ≤ ·) t).val.mcs

theorem timelineQuotMCS_is_mcs (t : TimelineQuot root_mcs root_mcs_proof) :
    SetMaximalConsistent (timelineQuotMCS root_mcs root_mcs_proof t) :=
  (ofAntisymmetrization (· ≤ ·) t).val.is_mcs

-- FMCS over TimelineQuot
noncomputable def timelineQuotFMCS : FMCS (TimelineQuot root_mcs root_mcs_proof) where
  mcs := timelineQuotMCS root_mcs root_mcs_proof
  is_mcs := timelineQuotMCS_is_mcs root_mcs root_mcs_proof
  forward_G := ... -- Uses quotient < and CanonicalR
  backward_H := ... -- Uses duality
```

### Priority 2: Address AddCommGroup Constraint (1 hour)

The `DenseCompletenessStatement` requires `AddCommGroup D`. TimelineQuot is NOT an AddCommGroup.

Options:
- Remove AddCommGroup from validity definition (requires TaskFrame redesign)
- Use Rat (which is AddCommGroup) via the isomorphism TimelineQuot ≃o Rat
- Reformulate completeness to not require group structure

**Recommended**: Use the Cantor isomorphism `TimelineQuot ≃o Rat`. Since Rat is an AddCommGroup and DenselyOrdered, transport the truth lemma through the isomorphism.

### Priority 3: Wire Final Completeness Theorem (1 hour)

Once FMCS over TimelineQuot (or Rat) is established:
1. Build BFMCS using the temporal coherent family construction
2. Apply truth lemma
3. Derive contradiction from validity + satisfiability

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| `ofAntisymmetrization` choice issues | Medium | High | Prove MCS equivalence is preserved under representative choice |
| AddCommGroup constraint blocks wiring | High | High | Use Rat via Cantor isomorphism |
| TaskFrame structure incompatible | Medium | Medium | May need TaskFrame refactoring for non-group domains |
| Coherence proofs complex | Low | Medium | Leverage existing CanonicalFMCS patterns |

## Sorry Characterization

### Current State
- 1 sorry in `Theories/Bimodal/FrameConditions/Completeness.lean` line 127 (`dense_completeness_fc`)
- 2 additional sorries for discrete completeness (task 979 debt, out of scope)

### Transitive Impact
- `dense_completeness_fc` is the top-level dense completeness theorem
- No downstream dependents yet

### Remediation Path
- Implement Option D (unified domain construction) as described above
- Estimated 3-4 hours

### Publication Status
The sorry in `dense_completeness_fc` blocks publication of dense completeness. Remediation priority: high.

## Axiom Characterization

### Current State
- 1 axiom: `canonicalR_irreflexive` in `Canonical/CanonicalIrreflexivityAxiom.lean`

### Transitive Impact
- TimelineQuot density properties depend on this axiom
- Dense completeness inherits this axiom dependency

### Remediation Path
- The axiom documentation states it can be proved with a different atom type supporting freshness
- Current atom type `String` blocks the proof
- Resolution: Change atom type or accept as disclosed assumption

### Publication Status
Publication requires either axiom elimination (via atom type change) or explicit disclosure.

## Appendix

### Key Type Definitions

```lean
-- From CanonicalFMCS.lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

-- From CantorApplication.lean
def TimelineQuot : Type :=
  Antisymmetrization (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·)

-- From DenseTimeline.lean
def DenseTimelineElem : Type :=
  { p : StagedPoint // p ∈ denseTimelineUnion root_mcs root_mcs_proof }
```

### Relevant Mathlib Results

- `Order.iso_of_countable_dense`: Cantor's theorem for countable dense linear orders
- `toAntisymmetrization_lt_toAntisymmetrization_iff`: Quotient ordering characterization
- `Antisymmetrization`: Standard quotient construction for preorders

### File Locations

| Component | File |
|-----------|------|
| CanonicalMCS | `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean` |
| TimelineQuot | `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` |
| Truth Lemma | `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` |
| Dense Completeness Gap | `Theories/Bimodal/FrameConditions/Completeness.lean` |
| DenseTimeline | `Theories/Bimodal/Metalogic/StagedConstruction/DenseTimeline.lean` |
