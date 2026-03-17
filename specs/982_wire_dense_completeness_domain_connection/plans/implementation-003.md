# Implementation Plan: Wire Dense Completeness Domain Connection (v3)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [NOT STARTED]
- **Effort**: 8-10 hours
- **Dependencies**: Tasks 956 (D construction), 978 (typeclass architecture)
- **Research Inputs**:
  - research-001.md (domain gap analysis)
  - research-002.md (blocker analysis)
  - research-003.md (domain emergence)
  - research-004.md (box_persistent analysis)
  - research-005.md (rigorous mathematical analysis - **primary**)
- **Artifacts**: plans/implementation-003.md (this file), supersedes implementation-001/002.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v003 (2026-03-16)**: Complete revision based on research-005 (rigorous mathematical analysis). Rejects the "Collapse variant" (D = WorldState) as mathematically unsound. Adopts standard Henkin-style canonical model construction with proper separation of D (time domain) and WorldState (MCS space).

## Overview

The goal is to prove dense completeness: if φ is valid over all dense TaskFrames, then φ is provable. The contrapositive: if φ is not provable, construct a countermodel over TimelineQuot where φ fails.

**Mathematical Principle**: D must emerge from syntax, not be imported externally. TimelineQuot is the syntactically-derived dense linear order that the logic's axioms force into existence. Using it as D while maintaining proper separation from WorldState is the mathematically rigorous approach.

### Key Insight from Research-005

The Collapse variant (D = WorldState = TimelineQuot) is **mathematically unsound** because:
- It conflates time domain with world-state space
- Box then quantifies over ALL MCSs at ALL times (not histories at the same time)
- This makes Box equivalent to G∧H, destroying the modal/temporal distinction

The correct structure (following Goldblatt, Blackburn et al., Gabbay):
```
D = TimelineQuot           (syntactically-derived time domain)
WorldState = CanonicalWorldState  (space of MCSs as subtypes)
FMCS : D → Set Formula     (assigns MCS to each time)
BFMCS : Set (FMCS D)       (bundle with modal coherence)
```

## Goals & Non-Goals

**Goals**:
- Complete `timelineQuot_not_valid_of_neg_consistent` (the single remaining sorry)
- Build FMCS/BFMCS over TimelineQuot with proper D/WorldState separation
- Prove truth lemma following Henkin-style canonical model construction
- Zero new sorries, zero new axioms
- Publication-quality mathematical rigor

**Non-Goals**:
- Discrete completeness (separate task)
- Removing `canonicalR_irreflexive` axiom (separate task)
- Shortcuts that compromise mathematical soundness

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| forward_G/backward_H proofs complex | Medium | Low | Existing CanonicalFMCS provides template |
| Modal coherence construction | Medium | Low | Single-family BFMCS simplifies significantly |
| Type unification issues | Medium | Medium | Careful coercion and subtype handling |
| timelineQuot_lt_implies_canonicalR proof | High | Medium | Core linking lemma; proof sketch in research-005 |

## Sorry Characterization

### Current Sorries
- 1 sorry in `TimelineQuotCompleteness.lean:127` (`timelineQuot_not_valid_of_neg_consistent`)

### Expected Resolution
- Phase 5 completes the sorry using the truth lemma from Phase 4

### Remaining Debt
After this implementation:
- 0 sorries in dense completeness pipeline
- 1 axiom: `canonicalR_irreflexive` (documented, out of scope)

## Implementation Phases

### Phase 1: Core Linking Lemma [NOT STARTED]

- **Dependencies**: None
- **Goal**: Prove timelineQuot_lt_implies_canonicalR

**The Key Lemma**:
```lean
theorem timelineQuot_lt_implies_canonicalR (t t' : TimelineQuot) (h : t < t') :
    CanonicalR (timelineQuotMCS t).val (timelineQuotMCS t').val
```

**Proof Sketch** (from research-005 Section 6.2):
- t < t' in TimelineQuot means representatives p, q with StagedPoint.le p q and not StagedPoint.le q p
- StagedPoint.le p q means: p.mcs = q.mcs or CanonicalR p.mcs q.mcs
- The equality case is excluded by strict inequality
- Therefore CanonicalR p.mcs q.mcs

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- [ ] Prove `timelineQuot_lt_implies_canonicalR`
- [ ] Prove converse for completeness: `canonicalR_implies_timelineQuot_le`

**Timing**: 1 hour

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - NEW

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" TimelineQuotCanonical.lean` returns empty

---

### Phase 2: FMCS over TimelineQuot [NOT STARTED]

- **Dependencies**: Phase 1
- **Goal**: Build FMCS structure indexed by TimelineQuot

**Structure**:
```lean
def timelineQuotFMCS (root_mcs : Set Formula) (h_mcs : SetMaximalConsistent root_mcs) :
    FMCS TimelineQuot where
  mcs t := timelineQuotMCS root_mcs h_mcs t
  is_mcs t := timelineQuotMCS_is_mcs root_mcs h_mcs t
  forward_G := timelineQuot_forward_G
  backward_H := timelineQuot_backward_H
```

**Tasks**:
- [ ] Define `timelineQuotFMCS` structure
- [ ] Prove `timelineQuot_forward_G`:
  - G φ ∈ mcs(t), t < t' implies φ ∈ mcs(t')
  - Use timelineQuot_lt_implies_canonicalR + g_content
- [ ] Prove `timelineQuot_backward_H`:
  - H φ ∈ mcs(t), t' < t implies φ ∈ mcs(t')
  - Use timelineQuot_lt_implies_canonicalR + h_content

**Timing**: 1.5 hours

**Files**:
- `TimelineQuotCanonical.lean` - continue

**Verification**:
- FMCS structure builds without sorry
- forward_G and backward_H proven

---

### Phase 3: BFMCS and TaskFrame [NOT STARTED]

- **Dependencies**: Phase 2
- **Goal**: Build BFMCS bundle and TaskFrame with proper D/WorldState separation

**BFMCS Structure** (singleton variant):
```lean
def timelineQuotBFMCS (root_mcs : Set Formula) (h_mcs : SetMaximalConsistent root_mcs) :
    BFMCS TimelineQuot where
  families := {timelineQuotFMCS root_mcs h_mcs}
  context_contained := ...
  modal_forward := timelineQuot_modal_forward  -- from T-axiom
  modal_backward := timelineQuot_modal_backward  -- trivial for singleton
```

**TaskFrame Structure**:
```lean
def timelineQuotTaskFrame : TaskFrame TimelineQuot where
  WorldState := CanonicalWorldState  -- MCS subtype, NOT TimelineQuot
  task_rel := canonical_task_rel
  task_rel_functional := ...
```

**Tasks**:
- [ ] Define `timelineQuotBFMCS` with singleton family
- [ ] Prove `timelineQuot_modal_forward`: Box φ ∈ mcs t → φ ∈ mcs t (T-axiom)
- [ ] Prove `timelineQuot_modal_backward`: (∀ fam', φ ∈ fam'.mcs t) → Box φ ∈ fam.mcs t
- [ ] Define `timelineQuotTaskFrame` with WorldState = CanonicalWorldState
- [ ] Define `timelineQuotTaskModel` with valuation from MCS membership

**Timing**: 1.5 hours

**Files**:
- `TimelineQuotCanonical.lean` - continue

**Verification**:
- BFMCS and TaskFrame build without sorry
- WorldState is properly separated from D

---

### Phase 4: Truth Lemma [NOT STARTED]

- **Dependencies**: Phase 3
- **Goal**: Prove truth lemma connecting MCS membership to semantic truth

**The Main Theorem**:
```lean
theorem timelineQuot_truth_lemma
    (B : BFMCS TimelineQuot) (h_tc : B.temporally_coherent)
    (fam : FMCS TimelineQuot) (hfam : fam ∈ B.families)
    (t : TimelineQuot) (phi : Formula) :
    phi ∈ fam.mcs t ↔
    truth_at timelineQuotTaskModel (shiftClosedOmega B) (to_history fam) t phi
```

**Proof by structural induction on φ**:

| Case | Argument |
|------|----------|
| atom p | By valuation definition |
| bot | By MCS consistency |
| φ → ψ | By MCS implication property + IH |
| □ψ | By modal_forward/backward + box_persistent + IH |
| Gψ | By forward_G + shift closure + IH |
| Hψ | By backward_H + shift closure + IH |

**Tasks**:
- [ ] Define `to_history` for TimelineQuot FMCS
- [ ] Define `shiftClosedOmega` for TimelineQuot BFMCS
- [ ] Prove `box_persistent_timelineQuot`: Box φ ∈ mcs t → Box φ ∈ mcs s for all s
- [ ] Prove truth lemma atom case
- [ ] Prove truth lemma bot case
- [ ] Prove truth lemma imp case
- [ ] Prove truth lemma box case (uses box_persistent + modal coherence)
- [ ] Prove truth lemma all_future case (uses forward_G + shift closure)
- [ ] Prove truth lemma all_past case (uses backward_H + shift closure)

**Timing**: 3 hours

**Files**:
- `TimelineQuotCanonical.lean` - continue

**Verification**:
- All truth lemma cases proven without sorry
- `lean_goal` shows "no goals" at QED

---

### Phase 5: Complete the Sorry [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Use truth lemma to complete `timelineQuot_not_valid_of_neg_consistent`

**Proof Structure**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    ¬valid_over TimelineQuot phi := by
  -- Step 1: Build MCS M_0 containing phi.neg
  let M_0 := lindenbaumMCS [phi.neg] h_cons
  let h_M0 := lindenbaumMCS_is_mcs [phi.neg] h_cons
  have h_neg_in : phi.neg ∈ M_0 := lindenbaumMCS_contains_context ...

  -- Step 2: Build TimelineQuot from M_0
  let D := TimelineQuot M_0 h_M0

  -- Step 3: Build BFMCS
  let B := timelineQuotBFMCS M_0 h_M0

  -- Step 4: Get root time
  let t_0 := timelineQuotRoot M_0 h_M0

  -- Step 5: By truth lemma, phi.neg is true at t_0
  have h_neg_true : truth_at ... t_0 phi.neg :=
    (timelineQuot_truth_lemma B _ _ _ t_0 phi.neg).mp h_neg_in

  -- Step 6: By MCS consistency, phi is false at t_0
  have h_false : ¬truth_at ... t_0 phi := by
    simp [Formula.neg, truth_at] at h_neg_true
    exact h_neg_true

  -- Step 7: Exhibit countermodel
  exact ⟨timelineQuotTaskFrame, timelineQuotTaskModel, Omega, h_sc, tau, h_mem, t_0, h_false⟩
```

**Tasks**:
- [ ] Import TimelineQuotCanonical into TimelineQuotCompleteness
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` following proof structure
- [ ] Verify `dense_completeness_theorem` compiles without sorry
- [ ] Verify `dense_completeness_fc` compiles without sorry

**Timing**: 1 hour

**Files**:
- `TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)

**Verification**:
- `grep -n "\bsorry\b" TimelineQuotCompleteness.lean` returns empty
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 6: Final Verification [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Verify zero-sorry status and publication readiness

**Tasks**:
- [ ] Run `lake build` full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuot*.lean`
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/FrameConditions/Completeness.lean`
- [ ] Run `grep -n "^axiom " Theories/Bimodal/` - verify only canonicalR_irreflexive
- [ ] Update implementation summary

**Timing**: 30 minutes

**Verification**:
- Dense completeness pipeline: 0 sorries, 1 disclosed axiom
- Publication-ready status confirmed

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] D = TimelineQuot (time domain), NOT WorldState
- [ ] WorldState = CanonicalWorldState (MCS space)
- [ ] FMCS assigns MCSs to times via timelineQuotMCS
- [ ] BFMCS provides modal coherence (even singleton)
- [ ] Truth lemma connects MCS membership to semantic truth
- [ ] Box quantifies over histories at same time, not across times

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - NEW (FMCS, BFMCS, TaskFrame, truth lemma)
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - UPDATED

## Rollback/Contingency

If implementation encounters fundamental obstacle:
1. TimelineQuotCanonical.lean can be deleted
2. TimelineQuotCompleteness.lean reverted via git
3. Document obstacle in implementation summary with mathematical explanation

## Notes

**Why This Is Correct**: This approach follows the standard Henkin-style canonical model construction from modal logic literature (Goldblatt, Blackburn et al., Gabbay). The key is maintaining the proper separation:
- D (TimelineQuot) is the time domain
- WorldState (CanonicalWorldState) is the space of possible worlds (MCSs)
- Histories are functions D → WorldState
- Box quantifies over histories at the same time

**Why Singleton BFMCS Suffices**: We only need ONE countermodel to refute validity. A singleton BFMCS where modal_forward becomes the T-axiom is mathematically valid for this purpose. We are not claiming this is the only model of the logic, just one sufficient countermodel.

**The Key Linking Lemma**: `timelineQuot_lt_implies_canonicalR` bridges the syntactically-derived TimelineQuot ordering with the CanonicalR accessibility relation on MCSs. This is the mathematical heart of the construction.
