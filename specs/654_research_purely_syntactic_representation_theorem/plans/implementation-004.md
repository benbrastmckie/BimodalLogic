# Implementation Plan: Task #654

- **Task**: 654 - Research Purely Syntactic Representation Theorem
- **Version**: 004
- **Status**: [IMPLEMENTING]
- **Effort**: 24 hours
- **Priority**: High
- **Dependencies**: None
- **Research Inputs**:
  - specs/654_research_purely_syntactic_representation_theorem/reports/research-004.md (reflexive vs irreflexive analysis)
  - specs/654_research_purely_syntactic_representation_theorem/summaries/implementation-summary-20260121.md (design flaw analysis)
- **Artifacts**: plans/implementation-004.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan supersedes implementation-003.md with a fundamentally revised architecture based on research-004.md findings:

**Key Insight**: The same-MCS-at-all-times approach failed because it requires temporal T-axioms (`G phi -> phi`, `H phi -> phi`) that TM logic does NOT have. G/H are irreflexive operators that exclude the present moment.

**Solution**: Build a family of MCS indexed by time, where each time point has its own MCS connected to adjacent times via temporal coherence conditions (formula propagation).

### Key Changes from implementation-003.md

| Aspect | implementation-003.md | implementation-004.md |
|--------|----------------------|----------------------|
| MCS per time | Single MCS Gamma | Family mcs : D -> Set Formula |
| T-axiom required | Yes (blocked) | No (avoided by design) |
| World structure | (Gamma, t) fixed Gamma | (mcs(t), t) varying MCS |
| Task relation proof | Requires G phi -> phi | Uses coherence conditions |
| Phase 3-4 | BLOCKED | Redesigned |

### Preserved from implementation-003.md

- Phases 0-2 remain COMPLETED (archive, MCS infrastructure, CanonicalWorld structure)
- Target directory: `Bimodal/Metalogic/`
- Parametric over D with typeclasses
- G/H remain primitive irreflexive operators (user preference)

## Goals & Non-Goals

**Goals**:
- Define `IndexedMCSFamily D` structure with temporal coherence conditions
- Construct indexed families from a root MCS using Lindenbaum's lemma
- Prove coherence conditions from construction
- Refactor canonical history to use indexed family instead of single MCS
- Complete truth lemma for indexed family approach
- Prove representation theorem

**Non-Goals**:
- Switching to reflexive G'/H' as primitive (research-004 recommends against)
- Finite model property
- Strong completeness

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Indexed family construction complex | M | M | Use Choice axiom; focus on existence |
| Coherence condition proofs subtle | M | M | Leverage Temporal 4 axiom (G phi -> GG phi) |
| Truth lemma with varying MCS | H | M | Key insight: truth at t depends only on mcs(t) |
| Seed set consistency | M | M | Careful case analysis on time ordering |

## Implementation Phases

### Phase 0: Archive and Setup [COMPLETED]
*No changes - already done in implementation-003.md*

---

### Phase 1: Port Core MCS Infrastructure [COMPLETED]
*No changes - already done in implementation-003.md*

---

### Phase 2: Define Canonical World Structure [COMPLETED]
*No changes - already done in implementation-003.md*

---

### Phase 3: Define Indexed MCS Family Structure [NOT STARTED]

**Goal**: Define the structure for a family of MCS indexed by time with temporal coherence

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- [ ] Define `IndexedMCSFamily D` structure:
  ```lean
  /-- A family of MCS indexed by time, with temporal coherence -/
  structure IndexedMCSFamily (D : Type*) [AddCommGroup D] [LinearOrder D] where
    mcs : D -> Set Formula
    is_mcs : forall t, SetMaximalConsistent (mcs t)
    -- Forward G coherence: G formulas at t propagate to all future t' > t
    forward_G : forall t t' phi, t < t' -> Formula.all_future phi ∈ mcs t -> phi ∈ mcs t'
    -- Backward H coherence: H formulas at t propagate to all past t' < t
    backward_H : forall t t' phi, t' < t -> Formula.all_past phi ∈ mcs t -> phi ∈ mcs t'
    -- Looking back: H formulas at future times connect to past
    forward_H : forall t t' phi, t < t' -> Formula.all_past phi ∈ mcs t' -> phi ∈ mcs t
    -- Looking forward: G formulas at past times connect to future
    backward_G : forall t t' phi, t' < t -> Formula.all_future phi ∈ mcs t' -> phi ∈ mcs t
  ```
- [ ] Add derived lemmas for transitivity (using Temporal 4: G phi -> GG phi)
- [ ] Prove key properties about indexed families

**Timing**: 3 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Verification**:
- `IndexedMCSFamily D` compiles
- All coherence condition types correct
- `lean_diagnostic_messages` shows no errors

---

### Phase 4: Construct Indexed Family from Root MCS [NOT STARTED]

**Goal**: Given an MCS at origin, construct a coherent family for all times

**Tasks**:
- [ ] Define seed set construction for future times:
  ```lean
  def future_seed (Gamma : Set Formula) (t : D) : Set Formula :=
    {phi | ∃ s, s < t ∧ Formula.all_future phi ∈ Gamma_at_s}
  ```
- [ ] Define seed set construction for past times (symmetric)
- [ ] Prove seed sets are consistent (requires case analysis)
- [ ] Apply Lindenbaum's lemma to extend seeds to MCS
- [ ] Define `construct_indexed_family`:
  ```lean
  noncomputable def construct_indexed_family
      (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma) (origin : D) :
      IndexedMCSFamily D
  ```
- [ ] Prove `forward_G` coherence condition
- [ ] Prove `backward_H` coherence condition
- [ ] Prove `forward_H` coherence condition
- [ ] Prove `backward_G` coherence condition

**Key insight for coherence proofs**:
- If G phi ∈ mcs(t), then phi is in the seed for mcs(t') where t' > t
- Lindenbaum preserves the seed, so phi ∈ mcs(t')
- Transitivity uses Temporal 4: G phi -> GG phi ensures G phi also propagates

**Timing**: 6 hours

**Files to modify**:
- Extend: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Verification**:
- `construct_indexed_family` compiles
- All coherence conditions proven without sorry
- `lake build` succeeds

---

### Phase 5: Refactor Canonical History for Indexed Family [NOT STARTED]

**Goal**: Redefine canonical history using indexed family instead of single MCS

**Tasks**:
- [ ] Update `CanonicalHistory.lean` to use `IndexedMCSFamily`
- [ ] Redefine `canonical_history`:
  ```lean
  def canonical_history (family : IndexedMCSFamily D) :
      WorldHistory (UniversalCanonicalFrame D) where
    domain := fun _ => True  -- full domain
    convex := trivial
    states := fun t _ => { mcs := family.mcs t, time := t, is_mcs := family.is_mcs t }
    respects_task := canonical_history_respects family
  ```
- [ ] Prove `canonical_history_respects` using family coherence:
  - When d > 0: forward_G gives G phi propagation, forward_H gives H phi back-propagation
  - When d < 0: symmetric using backward_G and backward_H
  - When d = 0: trivial (nullity)
- [ ] Remove or archive the old single-MCS construction
- [ ] Verify compositionality now follows from coherence transitivity

**Timing**: 4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean`

**Verification**:
- `canonical_history` compiles without sorry
- `respects_task` proof complete
- All sorries from implementation-003 Phase 4 resolved

---

### Phase 6: Prove Truth Lemma for Indexed Family [NOT STARTED]

**Goal**: Connect MCS membership at time t to semantic truth at time t

**Tasks**:
- [ ] Create or update `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`
- [ ] Define truth lemma for indexed family:
  ```lean
  theorem truth_lemma (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi ∈ family.mcs t ↔ truth_at (canonical_model family) (canonical_history family) t phi
  ```
- [ ] Prove base cases:
  - Atom: by valuation construction (phi ∈ mcs t iff valuation says so)
  - Bot: trivial (MCS is consistent)
- [ ] Prove imp case: using MCS deductive closure
- [ ] Prove box case: quantify over all histories (existential direction needs Lindenbaum)
- [ ] Prove all_future (G) case:
  - Forward: G phi ∈ mcs(t) -> by forward_G, phi ∈ mcs(t') for all t' > t -> by IH, truth_at t' phi
  - Backward: (∀ t' > t, truth_at t' phi) -> by contrapositive + MCS negation-completeness
- [ ] Prove all_past (H) case: symmetric to G case

**Key insight for temporal backward directions**:
- If (∀ t' > t, truth_at t' phi), need G phi ∈ mcs(t)
- By MCS negation-completeness: either G phi ∈ mcs(t) or ¬(G phi) ∈ mcs(t)
- If ¬(G phi) ∈ mcs(t), then F(¬phi) ∈ mcs(t) (definition of G)
- This implies existence of t' > t with ¬phi ∈ mcs(t') by existential witness construction
- Contradiction with hypothesis

**Timing**: 8 hours

**Files to create/modify**:
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean`

**Verification**:
- All formula cases closed
- No sorry in truth_lemma
- Induction structure clear

---

### Phase 7: Complete Representation Theorem [NOT STARTED]

**Goal**: Package everything and prove the main theorem

**Tasks**:
- [ ] Update `UniversalCanonicalModel.lean` if needed
- [ ] Define `canonical_model`:
  ```lean
  def canonical_model (family : IndexedMCSFamily D) : TaskModel (UniversalCanonicalFrame D) where
    valuation := fun w p => (Formula.atom p) ∈ w.mcs
  ```
- [ ] Prove representation theorem:
  ```lean
  theorem representation_theorem (phi : Formula) (h_cons : Consistent {phi}) :
    ∃ (family : IndexedMCSFamily D) (t : D),
      phi ∈ family.mcs t ∧
      truth_at (canonical_model family) (canonical_history family) t phi
  ```
- [ ] Proof outline:
  1. Extend {phi} to MCS Gamma using Lindenbaum
  2. Construct indexed family with Gamma at origin 0
  3. By construction, phi ∈ family.mcs 0
  4. By truth lemma, truth_at ... 0 phi
- [ ] Update module exports
- [ ] Final verification with `lake build`

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Representation.lean`
- `Theories/Bimodal/Metalogic.lean`

**Verification**:
- Representation theorem proven without sorry
- All Metalogic/ files compile
- `lake build` succeeds
- Integration with existing Semantics/ verified

---

## Testing & Validation

- [ ] All new files compile without errors
- [ ] `lake build` succeeds for entire project
- [ ] No sorry remaining in Metalogic/ files (except documented acceptable ones)
- [ ] `IndexedMCSFamily D` coherence conditions all proven
- [ ] Truth lemma covers all formula cases
- [ ] Representation theorem uses TaskModel structure
- [ ] Parametric construction works for D = Int, D = Rat

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` (NEW)
- `Theories/Bimodal/Metalogic/Representation/CanonicalHistory.lean` (REFACTORED)
- `Theories/Bimodal/Metalogic/Representation/TruthLemma.lean` (NEW/UPDATED)
- `Theories/Bimodal/Metalogic/Representation/UniversalCanonicalModel.lean` (UPDATED)
- `specs/654_.../summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If indexed family approach proves intractable:

1. **Semantic fallback**: Use existing SemanticCanonicalModel from Boneyard
   - Fixed to Int time type
   - Compositionality has documented sorry for unbounded durations
   - Practically sufficient for decidability

2. **Partial victory**: Accept sorries for edge cases
   - Mark as documented limitations
   - Compositionality for "most" cases sufficient for practical use

3. **Preserve progress**: Each phase commits independently

## Summary of Key Differences

| Phase | v003 (blocked) | v004 (this plan) |
|-------|----------------|------------------|
| 3 | Single MCS task_rel | IndexedMCSFamily structure |
| 4 | Same MCS at all times | Construct family from root |
| 5 | Truth lemma (blocked) | Refactor history for family |
| 6 | TaskFrame/Model | Truth lemma for family |
| 7 | (was Phase 6) | Representation theorem |

**Total estimated effort**: 24 hours (down from 38 hours in v003 due to phases 0-2 already complete)
