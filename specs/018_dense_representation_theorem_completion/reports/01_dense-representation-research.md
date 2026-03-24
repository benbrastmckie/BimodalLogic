# Dense Representation Theorem Completion: Research Report

**Date**: 2026-03-21
**Task**: 18 - dense_representation_theorem_completion
**Session**: sess_1774112752_a2a584
**Status**: Research Report

---

## 1. Executive Summary

This research report analyzes the complete wiring strategy for the unconditional dense representation theorem: `valid_dense phi -> provable_dense phi`. The infrastructure from Tasks 16 (DenseTask relation) and 17 (TimelineQuotBFMCS) provides the key components, but a truth lemma gap remains.

### Key Findings

1. **DenseTaskFrame**: Complete and sorry-free in `DenseTaskRelation.lean`
2. **TimelineQuotBFMCS**: Modal coherence complete, temporal coherence via CanonicalMCS
3. **timelineQuot_instantiate_dense**: Available for validity instantiation
4. **Truth Lemma Gap**: The blocking issue - proven for `D=Int`, needed for `D=TimelineQuot`
5. **Resolution Path**: Build BFMCS directly indexed by TimelineQuot with linked truth lemma

---

## 2. Existing Infrastructure Analysis

### 2.1 DenseTask and DenseTaskFrame (Task 16)

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean`

The `DenseTask` relation defines `u + q = v` using the transferred group structure on TimelineQuot:

```lean
def DenseTask (u q v : TimelineQuot root_mcs root_mcs_proof) : Prop :=
  @HAdd.hAdd _ _ _ ... u q = v
```

**Key Theorems (all sorry-free)**:
- `DenseTask_zero`: Zero duration iff identity
- `DenseTask_add`: Composition of consecutive tasks
- `DenseTask_neg`: Task reversal via negation
- `density_interpolation`: Arbitrary rational subdivision

**Note**: The `DenseTaskFrame` structure definition appears incomplete - it defines a TaskFrame but the actual instance construction is present in the file. The key property is that TaskFrame axioms are proven from group properties.

### 2.2 TimelineQuotBFMCS (Task 17)

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`

Provides a BFMCS with modal saturation via ClosedFlags:

```lean
noncomputable def timelineQuotClosedFlags : Set (Flag CanonicalMCS) :=
  closedFlags (timelineQuotRootCanonicalMCS root_mcs root_mcs_proof)
```

**Modal Coherence (sorry-free)**:
- `timelineQuotBFMCS_modal_forward`: Box phi implies phi via T-axiom
- `timelineQuotBFMCS_modal_backward`: phi in all accessible implies Box phi
- `timelineQuotDenseBFMCS_modal_saturation`: Full modal saturation property

**Temporal Coherence**:
- `canonicalMCSBFMCS_forward_F`: F(phi) witness exists in CanonicalMCS
- `canonicalMCSBFMCS_backward_P`: P(phi) witness exists in CanonicalMCS
- `closedFlags_forward_F_witness`: Weaker form for closed flags

**Key Insight**: The BFMCS is built over **CanonicalMCS** (modal domain), not TimelineQuot. TimelineQuot provides temporal ordering via `timelineQuot_lt_implies_canonicalR`.

### 2.3 TimelineQuotCanonical Infrastructure

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`

Core linking between TimelineQuot and MCS structure:

```lean
theorem timelineQuot_lt_implies_canonicalR (t t' : TimelineQuot root_mcs root_mcs_proof)
    (h : t < t') :
    CanonicalR (timelineQuotMCS root_mcs root_mcs_proof t)
               (timelineQuotMCS root_mcs root_mcs_proof t')
```

**Key Constructions**:
- `timelineQuotMCS`: Extract MCS from TimelineQuot element
- `timelineQuotFMCS`: FMCS structure over TimelineQuot (sorry-free)
- `timelineQuotParametricTaskFrame`: W/D-separated TaskFrame
- `rootTime`: Time in TimelineQuot corresponding to root MCS
- `timelineQuotMCS_root_time_eq`: Root time MCS equals root_mcs (proven)

### 2.4 timelineQuot_instantiate_dense

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean`

```lean
theorem timelineQuot_instantiate_dense {P : Type -> Prop}
    (h : forall (D : Type)
      [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
      [DenseTemporalFrame D], P D) :
    P (TimelineQuot root_mcs root_mcs_proof)
```

This theorem enables instantiating any property that holds for all dense temporal domains at `D = TimelineQuot` specifically. This is the mechanism for connecting `valid_dense` to the concrete countermodel.

### 2.5 Existing Truth Lemma Infrastructure

**Location**: `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`

```lean
theorem canonical_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam in B.families)
    (t : Int) (phi : Formula) :
    phi in fam.mcs t <-> truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t phi

theorem shifted_truth_lemma (B : BFMCS Int)
    (h_tc : B.temporally_coherent) (phi : Formula)
    (fam : FMCS Int) (hfam : fam in B.families) (t : Int) :
    phi in fam.mcs t <->
    truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B) (to_history fam) t phi
```

**The Problem**: These are proven for `D = Int`. The dense completeness requires `D = TimelineQuot` which has `DenselyOrdered` but is NOT Int.

---

## 3. The Gap: Truth Lemma over TimelineQuot

### 3.1 Current Status in TimelineQuotCompleteness.lean

**Location**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    ...
    NOT valid_over D phi := by
  ...
  sorry  -- BLOCKING SORRY
```

This is the key gap lemma. It requires constructing a countermodel over TimelineQuot where phi.neg is true.

### 3.2 Why the Gap Exists

The domain mismatch has three aspects:

1. **BFMCS Indexing**: The proven BFMCS uses `CanonicalMCS` as its indexing type because F/P witness construction is trivial there (Lindenbaum extension).

2. **TaskFrame Domain**: `valid_dense` quantifies over `D` with `DenselyOrdered D`. TimelineQuot satisfies this, but the truth lemma is proven for `D = Int`.

3. **Truth Lemma Dependency**: The truth lemma (`canonical_truth_lemma`, `shifted_truth_lemma`) depends on:
   - `B.temporally_coherent` which provides forward_F and backward_P
   - These are proven for FMCS over Int or CanonicalMCS
   - Need analogous construction for FMCS over TimelineQuot

---

## 4. Resolution Strategy

### 4.1 Primary Approach: TimelineQuot-Native BFMCS

Build BFMCS directly indexed by TimelineQuot using the existing components:

**Step 1**: Use `timelineQuotFMCS` as the base family
- Already defined in TimelineQuotCanonical.lean
- Has `forward_G` and `backward_H` (sorry-free)

**Step 2**: Prove temporal coherence for timelineQuotFMCS
- `forward_F`: F(phi) at t implies exists s > t with phi at s
- `backward_P`: P(phi) at t implies exists s < t with phi at s

**Challenge**: These require Lindenbaum witness construction that places witnesses at specific TimelineQuot positions. The key insight from research reports 18-19 is:

```
Fφ ∈ mcs(t) → ∃ v q, q > 0 ∧ DenseTask(t, q, v) ∧ φ ∈ v
```

The witness v from `canonical_forward_F` is an MCS with `CanonicalR(mcs(t), v)`. By the linking lemma (`canonicalR_implies_timelineQuot_le`), this MCS corresponds to some timeline position `s > t`.

**Step 3**: Build singleton BFMCS from timelineQuotFMCS
- The singleton approach avoids `modal_backward` issues
- Modal forward via T-axiom is already proven

**Step 4**: Prove truth lemma for D = TimelineQuot
- Structure mirrors existing `canonical_truth_lemma`
- Uses `timelineQuotFMCS` and TimelineQuot-indexed history
- Temporal cases use `forward_G`, `backward_H` which are proven

### 4.2 Alternative: Transfer Theorem

Prove equivalence between Int-based truth and TimelineQuot-based truth:

```lean
theorem truth_transfer
    (phi : Formula)
    (h_int_truth : truth_at CanonicalTaskModel_Int Omega_Int tau_int t phi) :
    truth_at CanonicalTaskModel_TQ Omega_TQ tau_tq t' phi
```

This approach is more complex as it requires:
- Bijection between Int and TimelineQuot positions
- Preservation of MCS membership across the bijection
- Omega correspondence

The primary approach (native BFMCS) is preferred.

---

## 5. Implementation Components Required

### 5.1 New Definitions Needed

1. **timelineQuotTemporalCoherentFMCS**
   ```lean
   structure TimelineQuotTemporalCoherentFMCS where
     toFMCS : FMCS (TimelineQuot root_mcs root_mcs_proof)
     forward_F : ...
     backward_P : ...
   ```

2. **timelineQuotSingletonBFMCS**
   ```lean
   def timelineQuotSingletonBFMCS : BFMCS (TimelineQuot root_mcs root_mcs_proof)
   ```

3. **timelineQuotCanonicalTaskModel**
   ```lean
   def timelineQuotCanonicalTaskModel : TaskModel timelineQuotTaskFrame
   ```

4. **timelineQuotCanonicalOmega**
   ```lean
   def timelineQuotCanonicalOmega : Set (WorldHistory timelineQuotTaskFrame)
   ```

### 5.2 Key Theorems Needed

1. **forward_F for TimelineQuot FMCS**
   ```lean
   theorem timelineQuotFMCS_forward_F
       (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
       (h_F : Formula.some_future phi ∈ timelineQuotFMCS.mcs t) :
       ∃ s, t < s ∧ phi ∈ timelineQuotFMCS.mcs s
   ```

2. **backward_P for TimelineQuot FMCS**
   ```lean
   theorem timelineQuotFMCS_backward_P
       (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula)
       (h_P : Formula.some_past phi ∈ timelineQuotFMCS.mcs t) :
       ∃ s, s < t ∧ phi ∈ timelineQuotFMCS.mcs s
   ```

3. **Truth Lemma for TimelineQuot**
   ```lean
   theorem timelineQuot_truth_lemma
       (fam : FMCS (TimelineQuot root_mcs root_mcs_proof))
       (t : TimelineQuot root_mcs root_mcs_proof) (phi : Formula) :
       phi ∈ fam.mcs t ↔
       truth_at timelineQuotCanonicalTaskModel timelineQuotCanonicalOmega
                (to_history fam) t phi
   ```

4. **Main Completeness Theorem**
   ```lean
   theorem dense_completeness (phi : Formula) :
       valid_dense phi → Nonempty ([] ⊢ phi)
   ```

### 5.3 Proof Dependencies

```
timelineQuotFMCS_forward_F
    └── canonical_forward_F (CanonicalFMCS.lean)
    └── timelineQuot_lt_implies_canonicalR (TimelineQuotCanonical.lean)
    └── linking: CanonicalR -> TimelineQuot lt

timelineQuotFMCS_backward_P
    └── canonical_backward_P (CanonicalFMCS.lean)
    └── timelineQuot_lt_implies_canonicalR (TimelineQuotCanonical.lean)

timelineQuot_truth_lemma
    └── timelineQuotFMCS_forward_F
    └── timelineQuotFMCS_backward_P
    └── induction on phi (follows canonical_truth_lemma structure)

dense_completeness
    └── timelineQuot_instantiate_dense
    └── timelineQuot_truth_lemma
    └── contradiction: valid_dense + neg consistent
```

---

## 6. Risk Assessment

### 6.1 Low Risk Components

- **DenseTask infrastructure**: Complete, proven
- **TimelineQuot algebraic structure**: Complete, proven
- **Modal coherence**: Complete, proven
- **timelineQuotFMCS basic properties**: Complete, proven

### 6.2 Medium Risk Components

- **forward_F/backward_P for TimelineQuot FMCS**: Requires careful construction to place Lindenbaum witnesses at correct TimelineQuot positions. The linking lemma provides the bridge but the direction (CanonicalR -> TimelineQuot position) needs verification.

### 6.3 High Risk Components

- **Singleton BFMCS modal_backward**: The existing TimelineQuotBFMCS uses closedFlags for modal saturation. A singleton BFMCS cannot satisfy `modal_backward` in general. However, for the forward direction of the truth lemma (MCS membership -> semantic truth), we only need `modal_forward`.

**Mitigation**: Use forward-only truth lemma for countermodel construction. The backward direction is only needed for the (unused) completeness direction from truth to MCS.

---

## 7. Estimated Implementation Effort

### Phase 1: Temporal Coherence (2-3 hours)
- Prove `timelineQuotFMCS_forward_F`
- Prove `timelineQuotFMCS_backward_P`
- These follow from existing `canonical_forward_F/P` + linking lemma

### Phase 2: Model Construction (1-2 hours)
- Define `timelineQuotCanonicalTaskModel`
- Define `timelineQuotCanonicalOmega` with shift-closure
- Define history construction from timelineQuotFMCS

### Phase 3: Truth Lemma (3-4 hours)
- Port `canonical_truth_lemma` structure to TimelineQuot
- Handle all formula cases (atom, bot, imp, box, G, H)
- The box case may need special handling for singleton BFMCS

### Phase 4: Final Wiring (1-2 hours)
- Wire `timelineQuot_instantiate_dense` with truth lemma
- Complete `timelineQuot_not_valid_of_neg_consistent`
- Complete `dense_completeness_theorem`

**Total Estimated Effort**: 7-11 hours

---

## 8. Conclusion

The dense representation theorem completion is achievable with the existing infrastructure. The key gap is the truth lemma over TimelineQuot, which can be resolved by:

1. Proving temporal coherence (forward_F, backward_P) for timelineQuotFMCS
2. Building the TimelineQuot canonical model
3. Porting the truth lemma proof structure

All blocking sorries can be eliminated using the proven components from Tasks 16 and 17, combined with the linking lemma infrastructure in TimelineQuotCanonical.lean.

---

## 9. References

### Primary Sources (Lean Files)
- `Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotBFMCS.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean`
- `Theories/Bimodal/Semantics/Validity.lean`

### Prior Research (Task 6)
- `specs/006_canonical_taskframe_completeness/reports/18_dense-three-place-task-relation.md`
- `specs/006_canonical_taskframe_completeness/reports/19_role-in-representation-theorems.md`
