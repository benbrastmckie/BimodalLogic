# Implementation Plan: Task #257 - Completeness Proofs (Agnostic Construction)

- **Task**: 257 - Completeness Proofs for TM Bimodal Logic
- **Version**: 002
- **Created**: 2026-01-12
- **Status**: [NOT STARTED]
- **Effort**: 65-85 hours (revised from 57-76 to include Phase 5)
- **Priority**: Low
- **Dependencies**: Soundness (Complete), Deduction Theorem (Complete)
- **Research Inputs**: [research-008.md](../reports/research-008.md) (Agnostic Duration Construction), [Task 133 research-001.md](../../133_build_canonical_model_constructors_in_completeness/reports/research-001.md) (Canonical History Construction)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Implement the completeness proof for TM bimodal logic using the agnostic order-type construction from research-008.md. This approach constructs durations as equivalence classes of chain segments under order isomorphism, yielding a totally ordered commutative group that remains agnostic about temporal structure (discrete, dense, or continuous). The structure emerges from the logic's axioms rather than being imposed by the construction method.

### Revision Notes (v002)

This revision adds **Phase 5: Canonical History Construction** after Phase 4 (Canonical Frame and Model). The canonical_world_history and canonical_time elements are needed to properly evaluate temporal formulas and establish completeness, as identified in [Task 133 research-001.md](../../133_build_canonical_model_constructors_in_completeness/reports/research-001.md). The previous Phases 5-6 are renumbered to Phases 6-7.

### Research Integration

Key findings from research-008.md integrated into this plan:
1. **Order-type equivalence** replaces cardinality-based equivalence to avoid forcing discrete Z
2. **Positive durations** are order types of bounded chain segments
3. **Full duration group** via Grothendieck construction from positive duration monoid
4. **Structure-agnostic**: Same construction yields different groups depending on axioms

Key findings from Task 133 research-001.md:
1. **Canonical history construction** is essential for temporal formula evaluation
2. **WorldHistory** requires convex domain, state assignment, and task relation coherence
3. **Three approaches**: Full integer domain, singleton domain, or generated domain
4. **Recommendation**: Start with singleton domain, extend if needed for truth lemma

## Goals & Non-Goals

**Goals**:
- Implement the agnostic duration construction from research-008.md
- Complete all axiom stubs in Completeness.lean
- Construct canonical_history to enable temporal formula evaluation
- Prove truth lemma for canonical model
- Prove weak and strong completeness theorems
- Remove all `sorry` placeholders

**Non-Goals**:
- Implementing decidability (separate task 136-138)
- Proving finite model property
- Optimizing proof performance (can be done later)
- Supporting density/completeness axiom extensions (Task 441 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Order-type commutativity proof complexity | High | Medium | Start with simpler cardinality-based approach as fallback, then generalize |
| Set-to-list conversion in lindenbaum | Medium | High | Use `Countable Formula` instance to enumerate |
| Canonical history domain choice | High | Medium | Start with singleton domain, extend if truth lemma requires full domain |
| Truth lemma induction complexity | High | Medium | Break into separate lemmas per formula constructor |
| Grothendieck group API mismatch | Medium | Low | Study Mathlib's `Algebra.GrothendieckAddGroup` first |
| Chain segment formalization issues | Medium | Medium | Prototype in separate file before integration |

## Implementation Phases

### Phase 1: Foundation - Formula Countability and Set-List Bridge [NOT STARTED]

**Subtask**: Task 444

**Goal**: Establish the bridge between set-based and list-based consistency, fixing the `lindenbaum` sorry.

**Tasks**:
- [ ] Prove `Formula` is countable (derive `Countable Formula` instance)
- [ ] Implement enumeration function `Formula -> Nat`
- [ ] Define `setToContext : Set Formula -> Context` for countable sets
- [ ] Prove set-list consistency equivalence for countable sets
- [ ] Complete `lindenbaum` proof using enumeration
- [ ] Verify no new `sorry` introduced

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add countability, complete lindenbaum

**Verification**:
- `lindenbaum` compiles without `sorry`
- `lake build Bimodal.Metalogic.Completeness` succeeds

---

### Phase 2: Maximal Consistent Set Properties [NOT STARTED]

**Subtask**: Task 445

**Goal**: Prove the key properties of maximal consistent sets needed for canonical model construction.

**Tasks**:
- [ ] Prove `maximal_consistent_closed`: MCSs are deductively closed
- [ ] Prove `maximal_negation_complete`: MCSs contain either phi or neg phi
- [ ] Prove implication property: `(phi -> psi) in Gamma -> (phi in Gamma -> psi in Gamma)`
- [ ] Prove conjunction properties for MCSs
- [ ] Prove disjunction properties for MCSs
- [ ] Add modal saturation lemma: `Box phi in Gamma` properties
- [ ] Add temporal saturation lemmas: `F phi in Gamma`, `P phi in Gamma` properties
- [ ] Convert axiom stubs to theorems

**Timing**: 10-12 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace axiom stubs with proofs

**Verification**:
- `maximal_consistent_closed` and `maximal_negation_complete` are theorems (not axioms)
- All MCS property lemmas compile
- `lean_diagnostic_messages` shows no axiom warnings for these declarations

---

### Phase 3: Agnostic Duration Construction [NOT STARTED]

**Subtask**: Task 446

**Goal**: Implement the order-type based duration construction from research-008.md.

**Tasks**:
- [ ] Define `TemporalChain` structure (maximal linear suborder of MCSs)
- [ ] Define `ChainSegment` structure with convexity property
- [ ] Define `orderTypeEquiv` equivalence relation via order isomorphism
- [ ] Prove `orderTypeEquiv` is an equivalence relation
- [ ] Define `PositiveDuration` as quotient under `orderTypeEquiv`
- [ ] Implement `AddCommMonoid PositiveDuration` instance
  - [ ] Define zero (singleton order type)
  - [ ] Define add (order type concatenation)
  - [ ] Prove `add_zero`, `zero_add`
  - [ ] Prove `add_assoc`
  - [ ] Prove `add_comm` (key difficulty)
- [ ] Define `Duration` via `Algebra.GrothendieckAddGroup PositiveDuration`
- [ ] Implement `LinearOrder Duration` instance
- [ ] Implement `IsOrderedAddMonoid Duration` instance

**Timing**: 15-20 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - New section for duration construction
- Consider: `Theories/Bimodal/Metalogic/Duration.lean` - Extract if file becomes too large

**Verification**:
- `Duration` type compiles with `AddCommGroup` and `LinearOrder` instances
- No `sorry` in duration construction
- `lean_hover_info` on `Duration` shows correct type class instances

---

### Phase 4: Canonical Frame and Model Construction [NOT STARTED]

**Subtask**: Task 447

**Goal**: Build the canonical frame and model using the agnostic duration type.

**Tasks**:
- [ ] Refine `CanonicalWorldState` definition
- [ ] Replace `CanonicalTime` with `Duration` type from Phase 3
- [ ] Define `canonical_task_rel` properly:
  - [ ] Modal transfer: `Box phi in Gamma -> phi in Delta`
  - [ ] Temporal transfer: Future/Past relative to duration sign
- [ ] Prove nullity property: `canonical_task_rel Gamma 0 Gamma`
- [ ] Prove compositionality: `task_rel G t1 D -> task_rel D t2 S -> task_rel G (t1+t2) S`
- [ ] Implement `canonical_frame : TaskFrame Duration`
- [ ] Implement `canonical_valuation : CanonicalWorldState -> String -> Bool`
- [ ] Implement `canonical_model : TaskModel canonical_frame`
- [ ] Convert all canonical construction axioms to definitions

**Timing**: 12-15 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace axiom stubs with definitions

**Verification**:
- `canonical_frame`, `canonical_model` are definitions (not axioms)
- Frame properties (nullity, compositionality) proven
- `lake build` succeeds with no axiom warnings

---

### Phase 5: Canonical History Construction [NOT STARTED]

**Subtask**: Task 450

**Goal**: Build the canonical_history and canonical_time structures needed for temporal formula evaluation.

**Rationale**: As identified in Task 133 research-001.md, the canonical_history construction is essential for evaluating temporal formulas (F φ, P φ) in the truth lemma. The WorldHistory structure requires:
- A convex domain of times
- State assignment at each time in domain
- Coherence with the task relation

**Tasks**:
- [ ] Define `canonical_time : Duration` (initial time point, typically 0)
- [ ] Define history domain: `canonical_domain : Duration -> Prop`
  - [ ] Option 1 (MVP): Singleton domain `fun t => t = 0`
  - [ ] Option 2 (Full): Generated domain from formulas in MCS
  - [ ] Option 3 (Complete): Full integer/duration domain
- [ ] Prove convexity: `canonical_domain x -> canonical_domain z -> x ≤ y ≤ z -> canonical_domain y`
- [ ] Define `canonical_states : (t : Duration) -> canonical_domain t -> CanonicalWorldState`
  - [ ] For singleton: Return the given MCS at t = 0
  - [ ] For extended: Build MCS at each time via existence lemmas
- [ ] Prove `respects_task`: States at different times are related by canonical_task_rel
  - [ ] `∀ s t (hs : domain s) (ht : domain t), s ≤ t → canonical_task_rel (states s hs) (t - s) (states t ht)`
- [ ] Package into `canonical_history : WorldHistory canonical_frame`
- [ ] Prove existence lemma: Given MCS Γ and time direction, can extend to adjacent MCS
  - [ ] Forward extension: `∀ Γ, ∃ Δ, canonical_task_rel Γ 1 Δ` (if Γ has F-formulas)
  - [ ] Backward extension: `∀ Γ, ∃ Δ, canonical_task_rel Δ 1 Γ` (if Γ has P-formulas)

**Timing**: 6-8 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Add canonical history construction

**Verification**:
- `canonical_history` is a definition (not axiom)
- WorldHistory properties (convexity, respects_task) are proven
- Construction integrates with canonical_frame and canonical_model
- `lake build` succeeds with no axiom warnings

**Notes**:
- Start with singleton domain (Option 1) as MVP - sufficient for many completeness proofs
- If truth lemma requires temporal witnesses, extend to full domain (Option 2 or 3)
- The existence lemmas are the key technical challenge - may require additional research

---

### Phase 6: Truth Lemma [NOT STARTED]

**Subtask**: Task 448

**Goal**: Prove the truth lemma establishing correspondence between membership and truth.

**Tasks**:
- [ ] Truth lemma for atoms: `Formula.atom p in Gamma.val <-> truth_at ... (Formula.atom p)`
- [ ] Truth lemma for bottom: `Formula.bot notin Gamma.val` and `not (truth_at ... Formula.bot)`
- [ ] Truth lemma for implication: Use MCS implication property
- [ ] Truth lemma for box: Use modal saturation
- [ ] Truth lemma for past: Use temporal saturation backward (requires canonical_history)
- [ ] Truth lemma for future: Use temporal saturation forward (requires canonical_history)
- [ ] Combine cases into main `truth_lemma` theorem
- [ ] Convert axiom stub to theorem

**Timing**: 15-20 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Replace truth_lemma axiom with proof

**Verification**:
- `truth_lemma` is a theorem (not axiom)
- All formula cases covered in induction
- No remaining `sorry` in truth lemma

**Dependencies**: Phases 1-5 (especially Phase 5 for temporal cases)

---

### Phase 7: Completeness Theorems [NOT STARTED]

**Subtask**: Task 449

**Goal**: Prove weak and strong completeness using truth lemma.

**Tasks**:
- [ ] Prove `weak_completeness`: `valid phi -> DerivationTree [] phi`
  - [ ] Use contrapositive: assume not provable
  - [ ] Build canonical model with lindenbaum extension
  - [ ] Apply truth lemma to get countermodel
  - [ ] Derive contradiction
- [ ] Prove `strong_completeness`: `semantic_consequence Gamma phi -> DerivationTree Gamma phi`
  - [ ] Similar structure using `Gamma union {neg phi}`
- [ ] Complete `provable_iff_valid` proof (remove sorry)
- [ ] Convert axiom stubs to theorems
- [ ] Final cleanup: verify no axioms or sorry remain

**Timing**: 8-10 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Complete all remaining proofs

**Verification**:
- `weak_completeness` and `strong_completeness` are theorems
- `provable_iff_valid` compiles without sorry
- `#check @weak_completeness` shows theorem not axiom
- `lake build Bimodal.Metalogic.Completeness` succeeds with no warnings

---

## Subtask Summary

| Phase | Subtask | Description | Dependencies | Effort |
|-------|---------|-------------|--------------|--------|
| 1 | 444 | Formula countability and set-list bridge | - | 8-10 hours |
| 2 | 445 | Maximal consistent set properties | 444 | 10-12 hours |
| 3 | 446 | Agnostic duration construction | 445 | 15-20 hours |
| 4 | 447 | Canonical frame and model construction | 446 | 12-15 hours |
| 5 | 450 | Canonical history construction | 447 | 6-8 hours |
| 6 | 448 | Truth lemma | 450 | 15-20 hours |
| 7 | 449 | Completeness theorems | 448 | 8-10 hours |

**Total Effort**: 65-85 hours (revised from 57-76 hours)

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds
- [ ] `lake build` full project succeeds
- [ ] No `axiom` declarations remain in Completeness.lean (verify via grep)
- [ ] No `sorry` remains in Completeness.lean (verify via grep)
- [ ] `#check @weak_completeness` shows it's a theorem
- [ ] `#check @strong_completeness` shows it's a theorem
- [ ] `#check @lindenbaum` shows it's a theorem
- [ ] `#check @canonical_history` shows it's a definition

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness.lean` - Complete implementation
- `specs/257_completeness_proofs/plans/implementation-002.md` - This plan (revised)
- `specs/257_completeness_proofs/plans/implementation-001.md` - Previous version (archived)
- `specs/257_completeness_proofs/summaries/implementation-summary-YYYYMMDD.md` - Final summary

## Rollback/Contingency

If the agnostic construction proves too complex:

1. **Fallback to Int-based**: Keep the simpler `CanonicalTime := Int` approach
2. **Modularize**: Extract duration construction to separate file for isolation
3. **Phased fallback**: Complete Phases 1-2, 4-7 with Int, then replace with agnostic in later task
4. **Research iteration**: If blockers emerge, create research-009.md documenting issues

For canonical_history specifically:
1. **Singleton fallback**: If full domain is too complex, singleton domain may suffice
2. **Partial truth lemma**: Prove modal cases first, temporal cases with sorry if needed
3. **Task 133 reference**: Fall back to simpler approach from Task 133 research if needed

The existing axiom stubs serve as safe checkpoints - we can always revert to axiom-based placeholders if proofs become intractable.

## Notes

- Phase 3 (Agnostic Duration) is the novel contribution - most other phases follow standard completeness proof patterns
- Phase 5 (Canonical History) is critical for temporal cases in the truth lemma - now explicitly separated
- Consider extracting Phase 3 to a separate Duration.lean module if it becomes large
- The research-008.md approach is more abstract than typical completeness proofs - allow extra time
- Mathlib's `Algebra.GrothendieckAddGroup` should handle most group construction boilerplate
- Keep Lindenbaum (Phase 1) and MCS properties (Phase 2) as priority since they enable all later phases
- The canonical_history construction bridges Phase 4 (frame/model) and Phase 6 (truth lemma)
