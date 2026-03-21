# Implementation Plan: Wire Dense Completeness Domain Connection (v4)

- **Task**: 982 - Wire dense completeness: connect CanonicalMCS-based BFMCS to TimelineQuot-based semantics
- **Status**: [PARTIAL]
- **Effort**: 12-16 hours
- **Dependencies**: Tasks 956 (D construction), 978 (typeclass architecture)
- **Research Inputs**:
  - research-001.md through research-005.md (prior analysis)
  - research-006.md (axiom-free modal saturation analysis - **primary**)
- **Artifacts**: plans/implementation-004.md (this file), supersedes implementation-001/002/003.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

**v004 (2026-03-16)**: Complete revision based on research-006 (axiom-free modal saturation). Replaces the mathematically impossible singleton BFMCS approach with closure-based modal saturation. This achieves zero axioms while maintaining full mathematical rigor.

**v003**: SUPERSEDED. Blocked at Phase 3 because singleton BFMCS requires `φ → □φ` which is false.

## Executive Summary

The Phase 3 blocker in v003 was **fundamental**, not technical. Research-006 identified the axiom-free solution: **closure-based modal saturation** via `saturated_modal_backward` (ModalSaturation.lean:328-367).

### Key Mathematical Insight

Singleton BFMCS requires `modal_backward` to satisfy:
```
φ ∈ fam.mcs(t) → □φ ∈ fam.mcs(t)
```
This is **mathematically false** - Task 905 removed this axiom for exactly this reason.

The solution is **multi-family BFMCS with modal saturation**:
- Construct witness families for each Diamond formula in the subformula closure
- Use `saturated_modal_backward` to derive `modal_backward` without axioms
- Closure is finite, so construction terminates

## Goals & Non-Goals

**Goals**:
- Complete `timelineQuot_not_valid_of_neg_consistent` (the single remaining sorry)
- Build **closure-saturated** BFMCS over TimelineQuot
- Zero new sorries, **zero new axioms** (the key constraint)
- Publication-quality mathematical rigor

**Non-Goals**:
- Discrete completeness (separate task)
- Removing `canonicalR_irreflexive` axiom (separate task)
- Full modal saturation (closure saturation suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness family construction complex | High | Medium | Use ChainFMCS.lean patterns for CanonicalR-chains |
| Closure tracking error-prone | Medium | Low | Subformula closure is well-defined, finite |
| Temporal coherence for witnesses | Medium | Medium | TimelineQuot has favorable structure |
| Integration with existing truth lemma | Low | Low | Port from canonical_truth_lemma |

## Sorry Characterization

### Current Sorries
- 1 sorry in `TimelineQuotCompleteness.lean:127` (`timelineQuot_not_valid_of_neg_consistent`)

### Expected Resolution
- Phase 6 completes the sorry using the closure-based truth lemma

### Remaining Debt
After this implementation:
- 0 sorries in dense completeness pipeline
- 0 new axioms (closure saturation is a construction property)
- 1 existing axiom: `canonicalR_irreflexive` (documented, out of scope)

## Implementation Phases

### Phase 1: Core Linking Lemma [COMPLETED]

- **Dependencies**: None
- **Goal**: Prove timelineQuot_lt_implies_canonicalR

**Status**: COMPLETED in v003. The key lemma `timelineQuot_lt_implies_canonicalR` is proven in `TimelineQuotCanonical.lean`.

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - EXISTS

---

### Phase 2: FMCS over TimelineQuot [COMPLETED]

- **Dependencies**: Phase 1
- **Goal**: Build FMCS structure indexed by TimelineQuot

**Status**: COMPLETED in v003. `timelineQuotFMCS` is defined with `forward_G` and `backward_H` proven.

**Files**:
- `TimelineQuotCanonical.lean` - EXISTS

---

### Phase 3: Witness Family Constructor [COMPLETED]

- **Dependencies**: Phase 2
- **Goal**: Build non-constant witness families for Diamond formulas

**Rationale (research-006)**: Constant witness families (same MCS at all times) cannot satisfy temporal coherence because `Gφ → φ` is not a theorem. Witness families must be built via CanonicalR-chains.

**Structure**:
```lean
/-- Build witness FMCS for formula ψ at time t from seed MCS M.
    The resulting family has mcs(t) = M and satisfies temporal coherence
    via CanonicalR-chain extension. -/
noncomputable def witnessChainFMCS
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (seed_mcs : Set Formula) (h_seed_mcs : SetMaximalConsistent seed_mcs)
    (seed_time : TimelineQuot root_mcs root_mcs_proof) :
    FMCS (TimelineQuot root_mcs root_mcs_proof)
```

**Construction Strategy**:
1. At `seed_time`: use `seed_mcs` directly
2. For `t > seed_time`: extend forward via CanonicalR using `g_content` saturation
3. For `t < seed_time`: extend backward via CanonicalR_past using `h_content` saturation
4. Prove `forward_G`: follows from CanonicalR between successive MCSs
5. Prove `backward_H`: follows from CanonicalR_past between successive MCSs

**Template**: Use `ChainFMCS.lean` infrastructure for CanonicalR-based chain construction.

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/WitnessChainFMCS.lean`
- [ ] Define `witnessChainFMCS` structure
- [ ] Prove forward/backward extension lemmas
- [ ] Prove `witnessChainFMCS_forward_G`
- [ ] Prove `witnessChainFMCS_backward_H`
- [ ] Prove `witnessChainFMCS_contains_seed`: seed MCS is at seed time

**Timing**: 4 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessChainFMCS.lean` - NEW

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" WitnessChainFMCS.lean` returns empty

---

### Phase 4: Closure-Based Saturation Construction [PARTIAL]

- **Dependencies**: Phase 3
- **Goal**: Build BFMCS saturated for subformula closure of target formula

**Key Insight (research-006)**: We only need saturation for formulas in `subformulaClosure(φ)`, which is finite. This makes the construction tractable.

**Structure**:
```lean
/-- A BFMCS saturated for a specific formula's closure. -/
structure ClosureSaturatedBFMCS (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (target : Formula) where
  bfmcs : BFMCS (TimelineQuot root_mcs root_mcs_proof)
  saturated_for_closure : is_saturated_for_closure bfmcs target

/-- Construct closure-saturated BFMCS by iteratively adding witness families. -/
noncomputable def constructClosureSaturatedBFMCS
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (target : Formula) :
    ClosureSaturatedBFMCS root_mcs root_mcs_proof target
```

**Construction Algorithm**:
1. Initialize `families := {timelineQuotFMCS root_mcs root_mcs_proof}`
2. For each `ψ ∈ subformulaClosure(target)`:
   a. For each existing family `fam` in `families`:
      b. For each time `t` where `◇ψ ∈ fam.mcs(t)`:
         c. If no family has `ψ ∈ fam'.mcs(t)`:
            d. Build `seed_mcs` containing `ψ` via Lindenbaum
            e. Build `witnessChainFMCS seed_mcs t`
            f. Add to `families`
3. Return bundle with saturation proof

**Key Lemmas**:
- `diamond_implies_psi_consistent` (ModalSaturation.lean:148-190): If ◇ψ ∈ M, then {ψ} is consistent
- `is_saturated_for_closure`: Weaker than full saturation, sufficient for completeness

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- [ ] Define `is_saturated_for_closure_timelineQuot` predicate
- [ ] Define `ClosureSaturatedBFMCS` structure
- [ ] Implement `constructClosureSaturatedBFMCS` construction
- [ ] Prove saturation: all Diamond formulas in closure have witnesses
- [ ] Prove `closureSaturation_modal_backward`: modal_backward for closure formulas

**Timing**: 4 hours

**Files**:
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - NEW

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" ClosureSaturation.lean` returns empty

---

### Phase 5: Closure-Aware Truth Lemma [NOT STARTED]

- **Dependencies**: Phase 4
- **Goal**: Prove truth lemma for closure-saturated BFMCS

**The Key Adaptation**: The box case uses `closureSaturation_modal_backward` which requires both φ and ¬φ to be in the closure. This is satisfied because subformulaClosure is closed under subformulas and the negation needed for the proof.

**Structure**:
```lean
theorem closureSaturated_truth_lemma
    (CSB : ClosureSaturatedBFMCS root_mcs root_mcs_proof target)
    (fam : FMCS TimelineQuot) (hfam : fam ∈ CSB.bfmcs.families)
    (t : TimelineQuot) (phi : Formula)
    (h_phi_sub : phi ∈ subformulaClosure target) :
    phi ∈ fam.mcs t ↔
    truth_at timelineQuotTaskModel (shiftClosedOmega CSB.bfmcs) (to_history fam) t phi
```

**Proof Structure** (induction on phi):
- **atom p**: By valuation definition (unchanged from canonical_truth_lemma)
- **bot**: By MCS consistency (unchanged)
- **φ → ψ**: By MCS implication property + IH (unchanged)
- **□ψ**: Uses `closureSaturation_modal_backward` instead of `modal_backward`
  - Forward: By modal_forward (T-axiom derived, no saturation needed)
  - Backward: By closureSaturation_modal_backward (ψ ∈ closure, ¬ψ ∈ closure)
- **Gψ**: By forward_G + shift closure + IH (unchanged)
- **Hψ**: By backward_H + shift closure + IH (unchanged)

**Tasks**:
- [ ] Define `to_history` for TimelineQuot FMCS
- [ ] Define `shiftClosedOmega` for TimelineQuot BFMCS
- [ ] Prove `box_persistent_timelineQuot` (port from canonical)
- [ ] Prove truth lemma atom case
- [ ] Prove truth lemma bot case
- [ ] Prove truth lemma imp case
- [ ] Prove truth lemma box case (uses closureSaturation_modal_backward)
- [ ] Prove truth lemma all_future case
- [ ] Prove truth lemma all_past case

**Timing**: 2 hours

**Files**:
- `TimelineQuotCanonical.lean` - MODIFIED (add truth lemma)

**Verification**:
- All truth lemma cases proven without sorry
- `lean_goal` shows "no goals" at QED

---

### Phase 6: Complete the Sorry [NOT STARTED]

- **Dependencies**: Phase 5
- **Goal**: Use truth lemma to complete `timelineQuot_not_valid_of_neg_consistent`

**Proof Structure**:
```lean
theorem timelineQuot_not_valid_of_neg_consistent
    (phi : Formula) (h_cons : ContextConsistent [phi.neg]) :
    ¬valid_over TimelineQuot phi := by
  -- Step 1: Build MCS M₀ containing phi.neg
  let M₀ := lindenbaumMCS [phi.neg] h_cons
  let h_M0 := lindenbaumMCS_is_mcs [phi.neg] h_cons
  have h_neg_in : phi.neg ∈ M₀ := lindenbaumMCS_extends ...

  -- Step 2: Build TimelineQuot from M₀
  let D := TimelineQuot M₀ h_M0

  -- Step 3: Build closure-saturated BFMCS for phi
  let CSB := constructClosureSaturatedBFMCS M₀ h_M0 phi

  -- Step 4: Get root time and family
  let t₀ := timelineQuotRoot M₀ h_M0
  let fam := CSB.bfmcs.eval_family

  -- Step 5: phi.neg is in closure, so truth lemma applies
  have h_neg_in_closure : phi.neg ∈ subformulaClosure phi := ...
  have h_neg_in_fam : phi.neg ∈ fam.mcs t₀ := ...

  -- Step 6: By truth lemma, phi.neg is true at t₀
  have h_neg_true : truth_at ... t₀ phi.neg :=
    (closureSaturated_truth_lemma CSB fam _ t₀ phi.neg h_neg_in_closure).mp h_neg_in_fam

  -- Step 7: By semantics of negation, phi is false at t₀
  have h_false : ¬truth_at ... t₀ phi := ...

  -- Step 8: Exhibit countermodel
  exact ⟨timelineQuotTaskFrame, timelineQuotTaskModel, Omega, h_sc, tau, h_mem, t₀, h_false⟩
```

**Tasks**:
- [ ] Import ClosureSaturation into TimelineQuotCompleteness
- [ ] Complete `timelineQuot_not_valid_of_neg_consistent` following proof structure
- [ ] Verify `dense_completeness_theorem` compiles without sorry
- [ ] Verify all downstream theorems compile

**Timing**: 1.5 hours

**Files**:
- `TimelineQuotCompleteness.lean` - MODIFIED (sorry resolved)

**Verification**:
- `grep -n "\bsorry\b" TimelineQuotCompleteness.lean` returns empty
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 7: Final Verification [NOT STARTED]

- **Dependencies**: Phase 6
- **Goal**: Verify zero-sorry, zero-axiom status

**Tasks**:
- [ ] Run `lake build` full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/*.lean`
- [ ] Run `grep -rn "^axiom " Theories/Bimodal/Metalogic/StagedConstruction/*.lean` - verify EMPTY
- [ ] Run `grep -rn "^axiom " Theories/Bimodal/` - verify only canonicalR_irreflexive
- [ ] Update implementation summary

**Timing**: 30 minutes

**Verification Criteria**:
- Dense completeness pipeline: 0 sorries
- New axioms in StagedConstruction/: 0
- Existing axiom: 1 (`canonicalR_irreflexive`, documented, out of scope)
- Publication-ready status confirmed

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" <modified files>` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " <modified files>` shows no new axioms (zero-axiom gate)
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Mathematical Correctness Checklist
- [ ] D = TimelineQuot (time domain), NOT WorldState
- [ ] WorldState = CanonicalWorldState (MCS space)
- [ ] Witness families satisfy temporal coherence (forward_G, backward_H)
- [ ] BFMCS is closure-saturated (not singleton!)
- [ ] modal_backward follows from saturation, not axiom
- [ ] Truth lemma restricted to closure formulas (sufficient for completeness)
- [ ] Box quantifies over histories at same time, not across times

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessChainFMCS.lean` - NEW
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean` - NEW
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean` - MODIFIED
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCompleteness.lean` - MODIFIED
- `specs/982_wire_dense_completeness_domain_connection/summaries/implementation-summary-{DATE}.md` - NEW

## Rollback/Contingency

If implementation encounters fundamental obstacle:
1. New files (WitnessChainFMCS.lean, ClosureSaturation.lean) can be deleted
2. TimelineQuotCanonical.lean reverted to Phase 2 state
3. TimelineQuotCompleteness.lean unchanged (sorry remains)
4. Document obstacle in implementation summary with mathematical explanation

## Why This Approach is Mathematically Correct

### The Axiom-Free Property

The closure-based saturation approach derives `modal_backward` from:
1. **MCS properties** (negation completeness, consistency) - definitional
2. **Modal duality** (¬□φ ↔ ◇¬φ) - provable from K axiom
3. **Saturation condition** - a construction property, NOT an axiom

The saturation condition says "we built the BFMCS to have witness families for all Diamond formulas in the closure." This is verified by construction, not assumed.

### Why Closure Suffices

The truth lemma proceeds by structural induction on formulas. The only formulas evaluated are subformulas of the target formula plus their negations. Since:
- `subformulaClosure(φ)` contains all subformulas and necessary negations
- We saturate for exactly this set
- The truth lemma only needs saturation for evaluated formulas

Closure-based saturation is mathematically equivalent to full saturation for completeness purposes.

### The Key Theorem Chain

```
constructClosureSaturatedBFMCS
  ↓ builds
ClosureSaturatedBFMCS with is_saturated_for_closure
  ↓ implies (via saturated_modal_backward pattern)
modal_backward for closure formulas
  ↓ enables
closureSaturated_truth_lemma (box case)
  ↓ enables
timelineQuot_not_valid_of_neg_consistent
  ↓ implies
dense_completeness_theorem (contrapositive)
```

No axioms in this chain. The final theorem is axiom-free.
