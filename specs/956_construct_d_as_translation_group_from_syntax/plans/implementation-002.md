# Implementation Plan: Layered Representation Theorem Architecture

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [IN PROGRESS]
- **Effort**: 12 hours
- **Dependencies**: None (builds on existing infrastructure)
- **Research Inputs**: research-013.md (layered architecture, Archimedean dichotomy), research-014.md (parametric completeness, fragment-first architecture)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Establish the representation theorem at three layers: (1) base layer parametric over abstract D (works with existing polymorphic validity definition), (2) dense extension with DN axiom, (3) discrete extension with DF axiom (DP is derived via temporal_duality). The primary focus is the representation theorem at each layer, with completeness as a consequence. This plan uses the **fragment-first architecture** from research-014, bypassing the Int-chain obstacle by working at the BidirectionalQuotient level for the density path.

### Research Integration

- **research-013**: Layered architecture design, DN/DF axiom specifications, Archimedean dichotomy analysis
- **research-014**: Fragment-first architecture, frame completeness vs task-semantic completeness distinction, Int-chain bypass strategy

## Goals & Non-Goals

**Goals**:
- Define restricted validity notions `valid_dense` and `valid_discrete` in Validity.lean
- Add DN axiom (density) and DF axiom (discreteness) to Axioms.lean
- Derive DP from DF via temporal_duality (no new axiom needed)
- Prove soundness of DN for `valid_dense` and DF for `valid_discrete`
- Prove DenselyOrdered on BidirectionalQuotient from DN (density path)
- Apply Cantor's theorem to get T isomorphic to Q for dense completeness
- Prove completeness for TM + DN (dense layer) via representation theorem

**Non-Goals**:
- Full discrete path (TM + DF) completeness in this iteration (requires Archimedean proof, marked as extension)
- Resolving the Int-chain sorries (bypassed by density path)
- Constructing D from TM alone as a specific group (base layer is parametric)
- Adding an Archimedean axiom (not first-order definable, per research-014)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DenselyOrdered proof on quotient from DN complex | High | Medium | Clear proof sketch in research-012 Section 3.3; intermediate lemmas structure the proof |
| Cantor's theorem application type mismatch | Medium | Low | Mathlib `Order.iso_of_countable_dense` is well-documented; verify hypothesis matching |
| AddTorsor transfer from Q to quotient | Medium | Medium | Use Q itself as both D and T (addGroupIsAddTorsor); avoid complex torsor transfer |
| Soundness proofs for new axioms tedious | Low | Low | Standard frame condition proofs; DN/DF have simple semantic characterizations |
| Discrete path Archimedeanness not proven | High | N/A | Discrete path marked as extension, not blocking for this plan |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `FragmentCompleteness.lean` at lines 460, 471 (`fragmentChainFMCS_forward_F`, `fragmentChainFMCS_backward_P`)
- These are Int-chain conversion obstacles, BYPASSED by this plan (density path avoids Int-chain)

### Expected Resolution
- This plan does NOT resolve the Int-chain sorries (they remain as documented technical debt)
- The density path completeness uses BidirectionalQuotient isomorphic to Q, avoiding Int indexing

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 2 sorries remain in `FragmentCompleteness.lean` (Int-chain path, orthogonal to density path)
- New files created (DenseCompleteness.lean, etc.) will have 0 sorries

## Implementation Phases

### Phase 1: Restricted Validity Definitions [COMPLETED]

- **Dependencies:** None
- **Goal:** Define `valid_dense` and `valid_discrete` in Validity.lean

**Tasks:**
- [ ] Add `valid_dense` definition: validity quantified over `[DenselyOrdered D]`
- [ ] Add `valid_discrete` definition: validity quantified over `[SuccOrder D] [PredOrder D]`
- [ ] Add lemmas `valid_implies_valid_dense` and `valid_implies_valid_discrete`
- [ ] Add notation `⊨_dense` and `⊨_discrete` if helpful

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Semantics/Validity.lean` - Add restricted validity definitions

**Verification:**
- `lake build Bimodal.Semantics.Validity` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Semantics/Validity.lean` returns empty

---

### Phase 2: DN and DF Axiom Definitions [COMPLETED]

- **Dependencies:** None
- **Goal:** Add density (DN) and forward discreteness (DF) axioms to Axioms.lean

**Tasks:**
- [ ] Add `Axiom.density (phi : Formula)` constructor: `F(phi) -> F(F(phi))`
- [ ] Add `Axiom.discreteness_forward (phi : Formula)` constructor: `(F(top) /\ phi /\ H(phi)) -> F(H(phi))`
- [ ] Add docstrings explaining frame conditions (density for DN, SuccOrder for DF)
- [ ] Verify axiom patterns match research-013 specifications

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Add axiom constructors

**Verification:**
- `lake build Bimodal.ProofSystem.Axioms` passes
- New axioms match definitions in research-013

---

### Phase 3: Derive DP from DF via temporal_duality [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Prove DP is derivable from DF using the temporal_duality inference rule

**Tasks:**
- [ ] Create `Theories/Bimodal/Theorems/Discreteness.lean`
- [ ] Prove `discreteness_past : [] ⊢ ((P(top) /\ phi /\ G(phi)) -> P(G(phi)))`
- [ ] Proof: instantiate DF at `swap(phi)`, apply temporal_duality, simplify
- [ ] Add docstring explaining this derivation

**Timing:** 45 minutes

**Files to create:**
- `Theories/Bimodal/Theorems/Discreteness.lean` - DP derivation

**Verification:**
- `lake build Bimodal.Theorems.Discreteness` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Theorems/Discreteness.lean` returns empty
- Derived theorem type matches DP specification from research-013

---

### Phase 4: Soundness of DN for valid_dense [COMPLETED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove DN is sound for the dense validity notion

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/DenseSoundness.lean`
- [ ] Prove `density_sound_dense : Axiom.density phi -> valid_dense (F(phi) -> F(F(phi)))`
- [ ] Proof sketch: In a densely ordered D, if `t < s` with `phi` at `s`, exists `u` with `t < u < s`, giving `F(phi)` at `u`
- [ ] Import and use `DenselyOrdered` typeclass instance

**Timing:** 1 hour

**Files to create:**
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` - DN soundness

**Verification:**
- `lake build Bimodal.Metalogic.DenseSoundness` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/DenseSoundness.lean` returns empty

---

### Phase 5: Soundness of DF for valid_discrete [COMPLETED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove DF is sound for the discrete validity notion

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/DiscreteSoundness.lean`
- [ ] Prove `discreteness_forward_sound_discrete : Axiom.discreteness_forward phi -> valid_discrete ((F(top) /\ phi /\ H(phi)) -> F(H(phi)))`
- [ ] Proof sketch: In a discrete order with SuccOrder, use `succ` for the F-witness; H(phi) holds at succ because predecessor is current
- [ ] Import and use `SuccOrder` typeclass instance

**Timing:** 1 hour

**Files to create:**
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - DF soundness

**Verification:**
- `lake build Bimodal.Metalogic.DiscreteSoundness` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/DiscreteSoundness.lean` returns empty

---

### Phase 6: DenselyOrdered on BidirectionalQuotient from DN [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Prove the canonical quotient is densely ordered when DN is an axiom

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean`
- [ ] Define extended MCS notion that includes DN as an axiom
- [ ] Prove `quotient_denselyOrdered_of_DN`: If DN is in the axiom set, then `DenselyOrdered (BidirectionalQuotient M0 h_mcs0)`
- [ ] Proof sketch: Given q1 < q2, there exist representatives w1, w2 with CanonicalR w1 w2 and not CanonicalR w2 w1. From FMCS, exists phi with F(phi) in w1 and phi in w2. By DN, F(F(phi)) in w1, giving intermediate witness w3 with F(phi) in w3. Quotient of w3 is strictly between q1 and q2.
- [ ] This is the KEY technical lemma for the density path

**Timing:** 2.5 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` - DenselyOrdered proof

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.DenseQuotient` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` returns empty
- `DenselyOrdered` instance compiles for BidirectionalQuotient with DN

---

### Phase 7: Cantor's Theorem Application [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Apply Cantor's theorem to get quotient isomorphic to Q

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean`
- [ ] Prove `quotient_countable`: BidirectionalQuotient is countable (fragment is countable, quotient of countable is countable)
- [ ] Prove `quotient_noMinOrder` and `quotient_noMaxOrder`: quotient has no endpoints (use mcs_has_F_top, mcs_has_P_top)
- [ ] Apply `Order.iso_of_countable_dense` to get `Nonempty (BidirectionalQuotient M0 h_mcs0 ≃o Rat)`
- [ ] The isomorphism provides the representation: T is order-isomorphic to Q

**Timing:** 1.5 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean` - T isomorphic to Q

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.QuotientIsomorphism` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean` returns empty
- `Nonempty (... ≃o Rat)` compiles

---

### Phase 8: Dense Completeness via Representation [NOT STARTED]

- **Dependencies:** Phase 4, Phase 6, Phase 7
- **Goal:** Prove completeness for TM + DN: valid_dense phi implies TM+DN proves phi

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/DenseCompleteness.lean`
- [ ] Define `TM_DN_provable` (derivability in TM extended with DN axiom)
- [ ] Prove `dense_representation_theorem`: For phi consistent with TM+DN, exists task frame with D=Q where phi is satisfied
- [ ] Prove `dense_completeness : valid_dense phi -> TM_DN_provable phi` (contrapositive: consistent implies satisfiable in dense frame)
- [ ] Proof uses: fragment FMCS (sorry-free), DenselyOrdered on quotient (Phase 6), isomorphism to Q (Phase 7), D=Q gives TaskFrame
- [ ] Set D = Q, use `addGroupIsAddTorsor` for torsor structure

**Timing:** 2.5 hours

**Files to create:**
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Dense completeness theorem

**Verification:**
- `lake build Bimodal.Metalogic.DenseCompleteness` passes
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/DenseCompleteness.lean` returns empty
- `dense_completeness` theorem statement compiles with correct type

---

### Phase 9: Documentation and Module Organization [NOT STARTED]

- **Dependencies:** Phase 8
- **Goal:** Document the layered architecture and organize module structure

**Tasks:**
- [ ] Create `Theories/Bimodal/Metalogic/Representation.lean` aggregating representation modules
- [ ] Update `Theories/Bimodal.lean` to export new modules
- [ ] Add comprehensive docstrings explaining the three-layer architecture
- [ ] Document the density path as the primary completeness route (bypasses Int-chain)
- [ ] Note discrete path as extension (requires Archimedeanness proof)

**Timing:** 45 minutes

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Representation.lean` - Aggregation module
- `Theories/Bimodal.lean` - Update exports

**Verification:**
- `lake build` (full project) passes
- Documentation clearly explains layered architecture

---

### Phase 10: Verification and Summary [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Full verification, sorry audit, and implementation summary

**Tasks:**
- [ ] Run `lake build` for full project
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` and verify only pre-existing Int-chain sorries
- [ ] Verify no new axioms introduced: `grep -n "^axiom " Theories/Bimodal/`
- [ ] Create implementation summary at `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`
- [ ] Update specs/state.json with completion status

**Timing:** 45 minutes

**Files to create:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

**Verification:**
- `lake build` passes with no errors
- Sorry count in new files = 0
- Summary accurately reflects completed work

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/DenseCompleteness.lean` returns empty (zero-debt gate)
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### Semantic Validation
- [ ] `dense_completeness` theorem has correct type signature
- [ ] DN axiom matches `F(phi) -> F(F(phi))` pattern
- [ ] DF axiom matches `(F(top) /\ phi /\ H(phi)) -> F(H(phi))` pattern
- [ ] DP is derived (not axiom): appears in Theorems, not Axioms

## Artifacts & Outputs

**New Files:**
- `Theories/Bimodal/Semantics/Validity.lean` (modified) - `valid_dense`, `valid_discrete`
- `Theories/Bimodal/ProofSystem/Axioms.lean` (modified) - DN, DF axioms
- `Theories/Bimodal/Theorems/Discreteness.lean` - DP derivation
- `Theories/Bimodal/Metalogic/DenseSoundness.lean` - DN soundness
- `Theories/Bimodal/Metalogic/DiscreteSoundness.lean` - DF soundness
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean` - DenselyOrdered proof
- `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean` - T isomorphic to Q
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean` - Dense completeness
- `Theories/Bimodal/Metalogic/Representation.lean` - Aggregation

**Summary:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails or produces incorrect results:
1. `git stash` or `git checkout .` to revert uncommitted changes
2. Each phase has its own commit; use `git revert` for specific phase rollback
3. If DenselyOrdered proof blocked (Phase 6):
   - Mark phase `[BLOCKED]` with `requires_user_review: true`
   - Document specific obstacle in phase progress
   - Alternative: prove frame completeness only (without TaskFrame construction)
4. If Cantor's theorem application fails (Phase 7):
   - Verify `Countable`, `DenselyOrdered`, `NoMinOrder`, `NoMaxOrder` instances
   - Check Mathlib `Order.iso_of_countable_dense` signature for exact requirements

## Extension: Discrete Path (Future Work)

The discrete path (TM + DF) completeness requires:
1. Prove `SuccOrder` on BidirectionalQuotient from DF
2. Derive `PredOrder` from DP (via temporal_duality)
3. Prove `IsSuccArchimedean` on the quotient (from bidirectional construction)
4. Apply `orderIsoIntOfLinearSuccPredArch` to get T isomorphic to Z
5. Set D = Z, construct TaskFrame, prove completeness

This is marked as future work because the Archimedeanness proof (step 3) is more complex. The density path provides a working completeness result without this requirement.
