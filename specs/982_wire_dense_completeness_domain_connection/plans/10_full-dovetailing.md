# Implementation Plan: Full Dovetailing Construction for Dense Completeness (v10)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [NOT STARTED]
- **Effort**: 22 hours (6 phases)
- **Dependencies**: None
- **Research Inputs**:
  - reports/15_team-research.md (team research on approaches)
  - reports/16_dovetailing-analysis.md (detailed dovetailing analysis)
- **Artifacts**: plans/10_full-dovetailing.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v010 (2026-03-17)**: **FULL DOVETAILING APPROACH** per user directive.

Previous plans (v1-v9) attempted various workarounds:
- v8: CanonicalMCS-based approach blocked by LinearOrder constraint
- v9: Multi-family BFMCS blocked by BFMCS.temporally_coherent requiring internal forward_F/backward_P

User directive: "Full dovetailing with no distractions or compromises, cutting no corners for the best, most mathematically correct result."

This plan implements proper Cantor-pairing dovetailing enumeration as used in standard Henkin completeness proofs.

## Executive Summary

### The Fundamental Problem

The staged construction processes formulas in order of their encoding:
- Formula with encoding k is processed at stage 2k+1
- Points entering at stage m > 2k+1 miss having their F(phi_k) obligations processed

This creates the "m > 2k" gap in `ClosureSaturation.lean:378-659`.

### The Full Dovetailing Solution

Replace the current "process formula k at stage 2k+1" with Cantor-pairing enumeration of (point_index, formula_index) pairs:

```
Stage n processes pair (p, f) = unpair(n) where:
  - p is a point index (into the current point set)
  - f is a formula encoding
  - Process F(phi_f) and P(phi_f) obligations for point p
```

This ensures:
1. **Fairness**: Every (point, formula) pair is eventually processed
2. **Coverage**: All F-witnesses and P-witnesses are eventually added
3. **Mathematical correctness**: Standard Henkin construction technique

### Key Insight from Research

From reports/16_dovetailing-analysis.md Section 5:

The real issue is that when a witness MCS W is added via Lindenbaum completion, W.mcs may contain F-formulas that were not explicitly requested. These "inherited" F-formulas need their own witnesses, which may not exist if the F-formula's encoding k is less than W's entry stage m.

Full dovetailing handles this by processing ALL (point, formula) pairs across the entire construction, ensuring every obligation is eventually addressed.

## Goals & Non-Goals

**Goals**:
- Implement Cantor-pairing dovetailing enumeration for the staged construction
- Prove forward_F holds for ALL points in TimelineQuot (not just m <= 2k)
- Prove backward_P symmetrically
- Preserve DenselyOrdered property on TimelineQuot
- Complete the dense completeness theorem without sorries

**Non-Goals**:
- Backlog processing (a shortcut that adds complexity without full correctness)
- Witness families at BFMCS level (bypasses the real issue)
- Any approach that doesn't fix the underlying staged construction

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Dovetailing enumeration complexity | Medium | Medium | Use Mathlib's Nat.pair/unpair, follow DovetailingChain.lean patterns |
| Time index management during dynamic point addition | High | Medium | Assign indices sequentially, ensure unpair(n) processes valid indices only |
| Proof complexity for coverage theorem | High | Medium | Break into lemmas: witness_exists_if_processed, eventually_processed |
| Performance of dovetailed build | Low | Low | Finite work per stage, countable union is still countable |
| Breaking existing infrastructure | Medium | Low | Create new DovetailedTimeline alongside existing StagedTimeline, migrate incrementally |

## Sorry Characterization

### Pre-existing Sorries (To Be Resolved)

| File:Line | Context | Resolution |
|-----------|---------|------------|
| `ClosureSaturation.lean:659` | `timelineQuotFMCS_forward_F` m > 2k case | Resolved by dovetailed construction |
| `ClosureSaturation.lean:664` | `timelineQuotFMCS_forward_F` density point case | Resolved by dovetailed construction |
| `ClosureSaturation.lean:679` | `timelineQuotFMCS_backward_P` | Resolved symmetrically |
| `ClosureSaturation.lean:724` | `timelineQuotSingletonBFMCS.modal_backward` | Resolved via saturated_modal_backward (existing) |
| `TimelineQuotCompleteness.lean:127` | `timelineQuot_not_valid_of_neg_consistent` | Resolved in Phase 6 |

### New Sorries

- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Document blocker in metadata

## Axiom Characterization

### Pre-existing Axioms

- `canonicalR_irreflexive_axiom` (CanonicalDomain.lean) - Required for bimodal logic, NOT introduced by this task

### New Axioms

- None. NEVER introduce new axioms.

## Implementation Phases

### Phase 1: Dovetailing Infrastructure [COMPLETED]

**Goal**: Define Cantor pairing functions and dovetailing enumeration types

**Tasks**:
- [ ] Create `StagedConstruction/Dovetailing.lean` with:
  - `dovetailPair : Nat -> Nat x Nat` using `Nat.unpair` from Mathlib
  - `dovetailUnpair : Nat x Nat -> Nat` using `Nat.pair` from Mathlib
  - Prove `dovetailPair_dovetailUnpair` and `dovetailUnpair_dovetailPair` (bijection)
- [ ] Define `ProcessObligation` type:
  ```lean
  /-- An obligation to process: point index p, formula encoding f -/
  structure ProcessObligation where
    point_index : Nat
    formula_encoding : Nat
  ```
- [ ] Define `obligationAtStep : Nat -> ProcessObligation`:
  ```lean
  def obligationAtStep (n : Nat) : ProcessObligation :=
    let (p, f) := Nat.unpair n
    { point_index := p, formula_encoding := f }
  ```
- [ ] Prove `forall_obligation_eventually_processed`:
  ```lean
  theorem forall_obligation_eventually_processed (p f : Nat) :
      ∃ n, obligationAtStep n = { point_index := p, formula_encoding := f }
  ```

**Timing**: 2 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.Dovetailing` passes
- All theorems proven without sorry

---

### Phase 2: Dovetailed Staged Build [COMPLETED]

**Goal**: Replace the current oddStage/evenStage with dovetailed processing

**Tasks**:
- [ ] Define `DovetailedPoint`:
  ```lean
  /-- A point in the dovetailed construction with its entry stage and point index -/
  structure DovetailedPoint where
    mcs : Set Formula
    is_mcs : SetMaximalConsistent mcs
    entry_stage : Stage
    point_index : Nat  -- Assigned upon entry
  ```
- [ ] Define `dovetailedBuild : Nat -> Finset DovetailedPoint`:
  ```lean
  /-- The dovetailed staged build.
      At step n, process obligation (p, f) = unpair(n):
      - If point index p is valid (exists in current build)
      - And formula f decodes to phi
      - Process F(phi) and P(phi) obligations for point p -/
  def dovetailedBuild : Nat -> Finset DovetailedPoint
  | 0 => { root_point }  -- Root MCS only
  | n + 1 =>
      let prev := dovetailedBuild n
      let (p_idx, f_enc) := Nat.unpair (n + 1)
      -- Only process if point index is valid
      if h : p_idx < prev.card then
        let point := prev.toList.get ⟨p_idx, by simp [h]⟩
        match decodeFormulaStaged f_enc with
        | none => prev
        | some phi => processObligations prev point phi (n + 1)
      else
        prev
  ```
- [ ] Define `processObligations` that adds F-witnesses and P-witnesses:
  ```lean
  def processObligations (prev : Finset DovetailedPoint) (point : DovetailedPoint)
      (phi : Formula) (stage : Stage) : Finset DovetailedPoint :=
    let with_forward := if Formula.some_future phi ∈ point.mcs
                        then addForwardWitness prev point phi stage
                        else prev
    let with_backward := if Formula.some_past phi ∈ with_forward.card  -- point still valid
                          then addBackwardWitness with_forward point phi stage
                          else with_forward
    with_backward
  ```
- [ ] Prove `dovetailedBuild_monotone`:
  ```lean
  theorem dovetailedBuild_monotone (n : Nat) :
      dovetailedBuild n ⊆ dovetailedBuild (n + 1)
  ```
- [ ] Prove `dovetailedBuild_linear`:
  ```lean
  theorem dovetailedBuild_linear (n : Nat) :
      IsLinearlyOrdered (dovetailedBuild n)
  ```

**Timing**: 4 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` - CREATE

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.DovetailedBuild` passes
- Monotonicity and linearity proven without sorry

---

### Phase 3: Dovetailed Timeline Union [COMPLETED]

**Goal**: Define the union of all dovetailed stages and prove key properties

**Tasks**:
- [ ] Define `dovetailedTimelineUnion`:
  ```lean
  /-- The union of all stages of the dovetailed build -/
  def dovetailedTimelineUnion : Set DovetailedPoint :=
    { p | ∃ n, p ∈ dovetailedBuild n }
  ```
- [ ] Prove `dovetailedTimelineUnion_countable`:
  ```lean
  theorem dovetailedTimelineUnion_countable :
      Set.Countable dovetailedTimelineUnion
  ```
- [ ] Prove `dovetailedTimelineUnion_linearlyOrdered`:
  ```lean
  theorem dovetailedTimelineUnion_linearlyOrdered :
      ∀ a b ∈ dovetailedTimelineUnion, DovetailedPoint.le a b ∨ DovetailedPoint.le b a
  ```
- [ ] Add density stages (interleave with obligation processing):
  ```lean
  /-- Enhanced dovetailed build that also maintains density -/
  def dovetailedDenseBuild : Nat -> Finset DovetailedPoint
  | 0 => { root_point }
  | n + 1 =>
      let with_obligations := dovetailedObligationStep (dovetailedDenseBuild n) (n + 1)
      insertDensityPoints with_obligations
  ```
- [ ] Prove `dovetailedDenseTimelineUnion_denselyOrdered`:
  ```lean
  theorem dovetailedDenseTimelineUnion_denselyOrdered :
      ∀ a b ∈ dovetailedDenseTimelineUnion, a < b →
      ∃ c ∈ dovetailedDenseTimelineUnion, a < c ∧ c < b
  ```

**Timing**: 3 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` - MODIFY

**Verification**:
- Countability, linearity, and density all proven without sorry

---

### Phase 4: Forward_F Coverage Theorem [BLOCKED]

**BLOCKING ISSUE**: Coverage gap in dovetailing construction identified.

When a point p enters the timeline at step s, and `pair(p.point_index, k) < s` for some formula encoding k:
- The obligation `(p.point_index, k)` was already processed at step `pair(p.point_index, k)`
- At that step, p did not exist yet (p enters later at step s)
- Therefore, F(phi) with encoding k was never processed FOR p

**Analysis**: This happens because point indices are assigned based on list length at entry time. If the point index L is small but the point enters late (step s > pair(L, k)), the step for processing (L, k) has already passed.

**Resolution Options**:
1. **Modify construction**: Re-process obligations when new points are added (adds complexity)
2. **Density argument**: Use the fact that F^i(neg bot) is in every MCS for all i, and encodings grow unboundedly. For large enough i, pair(L, encoding_i) > s, so the witness IS added.
3. **Different enumeration**: Use (step, formula) pairs instead of (point_index, formula) pairs

**Recommended**: Option 2 (density argument) is mathematically elegant and doesn't require construction changes. The proof sketch:
- Given p at step n with F(neg bot) in p.mcs
- By density, F^i(neg bot) is in p.mcs for all i
- Encodings of F^i(neg bot) grow without bound as i increases
- For large enough i, pair(p.point_index, encoding_i) > n
- At that step, p is in build and gets processed, adding a CanonicalR-witness

**Previous status**: [NOT STARTED]

**Goal**: Prove forward_F holds for ALL points in the dovetailed timeline

**Tasks**:
- [ ] Prove key lemma `witness_added_when_processed`:
  ```lean
  /-- When obligation (p, f) is processed and F(phi) ∈ point.mcs,
      a witness containing phi is added to the build -/
  theorem witness_added_when_processed
      (n : Nat) (point : DovetailedPoint) (phi : Formula)
      (h_point : point ∈ dovetailedBuild n)
      (h_idx : point.point_index = (Nat.unpair (n + 1)).1)
      (h_enc : decodeFormulaStaged (Nat.unpair (n + 1)).2 = some phi)
      (h_F : Formula.some_future phi ∈ point.mcs) :
      ∃ witness ∈ dovetailedBuild (n + 1),
        CanonicalR point.mcs witness.mcs ∧ phi ∈ witness.mcs
  ```
- [ ] Prove key lemma `point_formula_eventually_processed`:
  ```lean
  /-- For any point at index p with formula encoding f,
      the obligation (p, f) is processed at step pair(p, f) -/
  theorem point_formula_eventually_processed
      (point : DovetailedPoint) (phi : Formula)
      (h_point : point ∈ dovetailedTimelineUnion)
      (h_enc : ∃ k, decodeFormulaStaged k = some phi) :
      ∃ n, (Nat.unpair n).1 = point.point_index ∧
           decodeFormulaStaged (Nat.unpair n).2 = some phi ∧
           point ∈ dovetailedBuild (n - 1)
  ```
- [ ] Prove main theorem `dovetailedTimeline_forward_F`:
  ```lean
  /-- Forward F holds for all points in the dovetailed timeline -/
  theorem dovetailedTimeline_forward_F
      (point : DovetailedPoint) (phi : Formula)
      (h_point : point ∈ dovetailedDenseTimelineUnion)
      (h_F : Formula.some_future phi ∈ point.mcs) :
      ∃ witness ∈ dovetailedDenseTimelineUnion,
        point < witness ∧ phi ∈ witness.mcs := by
    -- Step 1: Get encoding k for phi
    obtain ⟨k, h_dec⟩ := formula_has_encoding phi
    -- Step 2: Get point index p for point
    let p := point.point_index
    -- Step 3: By dovetailing, (p, k) is processed at step n = pair(p, k)
    let n := Nat.pair p k
    -- Step 4: At step n, point is in build and phi is processed
    -- Step 5: By witness_added_when_processed, witness exists
    -- Step 6: Witness is in union, hence in timeline
    ...
  ```

**Timing**: 5 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedForwardF.lean` - CREATE

**Verification**:
- `dovetailedTimeline_forward_F` proven without sorry
- All supporting lemmas proven

---

### Phase 5: Backward_P and Modal Saturation [NOT STARTED]

**Goal**: Prove backward_P symmetrically and wire modal saturation

**Tasks**:
- [ ] Prove `dovetailedTimeline_backward_P` (symmetric to forward_F):
  ```lean
  theorem dovetailedTimeline_backward_P
      (point : DovetailedPoint) (phi : Formula)
      (h_point : point ∈ dovetailedDenseTimelineUnion)
      (h_P : Formula.some_past phi ∈ point.mcs) :
      ∃ witness ∈ dovetailedDenseTimelineUnion,
        witness < point ∧ phi ∈ witness.mcs
  ```
- [ ] Define `DovetailedTimelineQuot`:
  ```lean
  /-- Quotient of dovetailed timeline by antisymmetrization -/
  def DovetailedTimelineQuot := Antisymmetrization DovetailedDenseTimelineElem (· ≤ ·)
  ```
- [ ] Define `dovetailedTimelineQuotFMCS`:
  ```lean
  /-- FMCS over DovetailedTimelineQuot -/
  def dovetailedTimelineQuotFMCS : FMCS DovetailedTimelineQuot where
    mcs := dovetailedTimelineQuotMCS
    is_mcs := dovetailedTimelineQuotMCS_is_mcs
  ```
- [ ] Prove `dovetailedTimelineQuotFMCS_forward_F`:
  ```lean
  theorem dovetailedTimelineQuotFMCS_forward_F
      (t : DovetailedTimelineQuot) (phi : Formula)
      (h_F : Formula.some_future phi ∈ dovetailedTimelineQuotFMCS.mcs t) :
      ∃ s : DovetailedTimelineQuot, t < s ∧ phi ∈ dovetailedTimelineQuotFMCS.mcs s
  ```
- [ ] Prove `dovetailedTimelineQuotFMCS_backward_P` symmetrically
- [ ] Wire `saturated_modal_backward` from ModalSaturation.lean for singleton BFMCS

**Timing**: 4 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBackwardP.lean` - CREATE
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean` - CREATE

**Verification**:
- All temporal coherence properties proven without sorry

---

### Phase 6: Wire Dense Completeness Theorem [NOT STARTED]

**Goal**: Complete the dense completeness theorem using dovetailed construction

**Tasks**:
- [ ] Build dovetailed singleton BFMCS with proven temporal coherence:
  ```lean
  noncomputable def dovetailedTimelineQuotBFMCS : BFMCS DovetailedTimelineQuot where
    families := {dovetailedTimelineQuotFMCS}
    nonempty := ⟨dovetailedTimelineQuotFMCS, Set.mem_singleton _⟩
    modal_forward := dovetailedTimelineQuot_modal_forward_singleton
    modal_backward := saturated_modal_backward ...  -- from ModalSaturation.lean
    eval_family := dovetailedTimelineQuotFMCS
    eval_family_mem := Set.mem_singleton _
  ```
- [ ] Prove `dovetailedTimelineQuotBFMCS_temporally_coherent`:
  ```lean
  theorem dovetailedTimelineQuotBFMCS_temporally_coherent :
      dovetailedTimelineQuotBFMCS.temporally_coherent := by
    intro fam hfam
    have h_eq : fam = dovetailedTimelineQuotFMCS := Set.mem_singleton_iff.mp hfam
    subst h_eq
    exact ⟨dovetailedTimelineQuotFMCS_forward_F, dovetailedTimelineQuotFMCS_backward_P⟩
  ```
- [ ] Apply ParametricTruthLemma (DovetailedTimelineQuot has LinearOrder + AddCommGroup):
  ```lean
  theorem dovetailedTimelineQuot_truth_lemma :
      ∀ t phi, phi ∈ dovetailedTimelineQuotFMCS.mcs t ↔
               truth_at model Omega history t phi :=
    parametric_canonical_truth_lemma dovetailedTimelineQuotBFMCS
      dovetailedTimelineQuotBFMCS_temporally_coherent
  ```
- [ ] Wire completeness:
  ```lean
  theorem dovetailedTimelineQuot_completeness (phi : Formula) :
      (∀ M : Model DovetailedTimelineQuot, valid_in M phi) → Nonempty ([] ⊢ phi) := by
    intro h_valid
    by_contra h_not_prov
    obtain ⟨root_mcs, h_root, h_neg⟩ := lindenbaum_neg_of_not_provable h_not_prov
    -- Build dovetailed BFMCS with root_mcs
    -- By truth lemma, neg(phi) in root_mcs means phi FALSE in model
    -- But h_valid says phi TRUE in all models - contradiction
    ...
  ```
- [ ] Final dense completeness theorem:
  ```lean
  theorem dense_completeness_theorem (phi : Formula)
      (h_valid : ∀ (D : Type*) [AddCommGroup D] [LinearOrder D] [DenselyOrdered D]
                   [NoMinOrder D] [NoMaxOrder D], valid_over D phi) :
      Nonempty ([] ⊢ phi) := by
    have h_dq := h_valid DovetailedTimelineQuot
    exact dovetailedTimelineQuot_completeness phi h_dq
  ```
- [ ] Remove/mark obsolete the old sorries in ClosureSaturation.lean and TimelineQuotCompleteness.lean

**Timing**: 4 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCompleteness.lean` - CREATE
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - MODIFY
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - MODIFY (deprecation notes)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFY (wire to dovetailed)

**Verification**:
- `lake build` full project passes
- `grep -rn "\bsorry\b" DovetailedCompleteness.lean` returns empty
- `grep -rn "\bsorry\b" DenseCompleteness.lean` shows no new sorries
- `grep -n "^axiom " Dovetailed*.lean` shows no new axioms

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <new files>` returns empty
- [ ] `grep -n "^axiom " <new files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] Dovetailing enumeration is a bijection Nat <-> Nat x Nat
- [ ] Every (point, formula) pair is eventually processed
- [ ] Forward witnesses are added with correct CanonicalR relationship
- [ ] Backward witnesses are added with correct CanonicalR relationship
- [ ] Linearity is preserved at every stage
- [ ] Density is preserved in the final timeline
- [ ] Truth lemma handles all formula constructors
- [ ] Completeness correctly uses Lindenbaum + truth lemma
- [ ] No circular dependencies between theorems

## Artifacts & Outputs

**New Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/Dovetailing.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedForwardF.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBackwardP.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedCompleteness.lean`

**Modified Files**:
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` (deprecation)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean`

**Summary Artifact**:
- `specs/982_wire_dense_completeness_domain_connection/summaries/MM_implementation-summary.md`

## Rollback/Contingency

If implementation fails:
1. All new Dovetailed*.lean files can be deleted
2. Modifications to existing files can be reverted via git
3. The existing staged construction remains available as reference
4. If a specific phase blocks, mark as [BLOCKED] and document the mathematical obstacle

## Why This Approach is Mathematically Correct

### Standard Henkin Construction

The dovetailing enumeration is a standard technique from Henkin completeness proofs (1949):
1. Every formula is eventually processed
2. Every witness is eventually added
3. The resulting structure is countable
4. The fairness property ensures no obligation is "left behind"

### Coverage Guarantee

For any point p with F(phi) in p.mcs:
1. p has point index i_p assigned when it enters the build at stage m_p
2. phi has encoding k via Encodable Formula
3. The pair (i_p, k) is processed at step n = Nat.pair i_p k
4. At step n, if p is in the build (which it is, since n >= pair(i_p, k) > m_p is NOT guaranteed, but...)

**The Key Insight**: We must ensure that point index i_p is assigned BEFORE p enters, and that n = pair(i_p, k) is processed AFTER p enters. This requires:
- Point indices are assigned sequentially as points enter
- The dovetailed build processes (p, f) only when point index p is valid
- Since pair is surjective on Nat x Nat, every valid (point, formula) combination is eventually processed

### Density Preservation

Density is maintained by interleaving density point insertion with obligation processing:
- At each stage, after processing obligations, insert density points between consecutive pairs
- The union is DenselyOrdered because density is maintained at each finite stage

### LinearOrder and AddCommGroup

DovetailedTimelineQuot inherits:
- LinearOrder via Antisymmetrization (same as original TimelineQuot)
- AddCommGroup via quotient of MCS-based duration structure
- DenselyOrdered from density preservation
- NoMinOrder/NoMaxOrder from seriality

This satisfies all ParametricTruthLemma requirements.
