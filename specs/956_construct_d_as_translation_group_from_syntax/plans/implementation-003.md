# Implementation Plan: Irreflexive G/H Refactoring + Dense Completeness

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [IMPLEMENTING]
- **Effort**: 25-35 hours
- **Dependencies**: None
- **Research Inputs**: research-016.md (irreflexive feasibility), research-015.md (Phase 6 blocker analysis)
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-002.md (blocked at Phase 6 due to T-axiom obstruction)

## Overview

This plan implements a **complete refactoring from reflexive to irreflexive temporal semantics** (G/H use strict `<` instead of `<=`), followed by completion of the dense representation theorem. The previous plan (implementation-002.md) was blocked at Phase 6 because the T-axiom (`G phi -> phi`) made the combined seed `{G(psi), neg(psi)}` contradictory. With irreflexive semantics, this obstruction vanishes.

### Research Integration

- **research-016**: Comprehensive feasibility analysis of irreflexive switch. No fundamental blockers. ~35 files, 600-1000 lines affected. Detailed change catalog.
- **research-015**: Phase 6 blocker analysis. T-axiom obstruction is the root cause. Adjacency contradiction recommended for reflexive setting (now superseded by irreflexive approach).

## Goals & Non-Goals

**Goals**:
- Switch core semantics from reflexive (`<=`) to irreflexive (`<`) for temporal operators
- Remove T-axioms (`G phi -> phi`, `H phi -> phi`) from the axiom system
- Add derived reflexive operators (`G' phi := phi or G phi`)
- Adapt all soundness proofs for irreflexive semantics
- Complete the DenselyOrdered proof on BidirectionalQuotient (Phase 6 unblocked)
- Complete the dense completeness theorem for TM + DN

**Non-Goals**:
- Preserving reflexive semantics as an option (clean break)
- Full discrete path in this iteration (deferred)
- Resolving Int-chain sorries (orthogonal to density path)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cascading changes larger than estimated | Medium | Medium | Systematic tier-by-tier approach; frequent `lake build` checkpoints |
| Coherence proofs in DovetailingChain break | Medium | High | DovetailingChain is on archival path; canonical quotient approach does not depend on it |
| Density proof needs different seed strategy | Medium | Low | Standard textbook argument works; research-016 Section 4 provides proof sketch |
| JPL paper alignment concern | Low | Low | Documented deviation acceptable when it resolves blocker |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `FragmentCompleteness.lean` (Int-chain path, orthogonal)
- These remain unchanged; density path bypasses Int-chain

### Expected Resolution
- Phase 6 DenselyOrdered proof becomes achievable (T-axiom obstruction removed)
- All new code will be sorry-free

### New Sorries
- None. NEVER introduce new sorries.

## Implementation Phases

### Phase 1: Core Semantic Switch [COMPLETED]

- **Dependencies:** None
- **Goal:** Change `truth_at` from `<=` to `<` for temporal operators

**Tasks:**
- [ ] In `Theories/Bimodal/Semantics/Truth.lean`, change lines 118-119:
  - `s <= t` becomes `s < t` for `all_past`
  - `t <= s` becomes `t < s` for `all_future`
- [ ] Update `some_past` and `some_future` cases correspondingly (existential quantifiers)
- [ ] Add docstring explaining irreflexive semantics choice

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Semantics/Truth.lean`

**Verification:**
- `lake build Bimodal.Semantics.Truth` will fail (expected - cascading changes needed)
- Save checkpoint

---

### Phase 2: Remove T-Axioms [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Remove reflexivity axioms that are no longer valid

**Tasks:**
- [ ] In `Theories/Bimodal/ProofSystem/Axioms.lean`:
  - Remove `temp_t_future` constructor (`G phi -> phi`)
  - Remove `temp_t_past` constructor (`H phi -> phi`)
- [ ] Update pattern matches in all files that handle these axiom cases

**Timing:** 45 minutes

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `Theories/Bimodal/Metalogic/Soundness.lean` (remove 2 cases)
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` (remove swap cases)

**Verification:**
- `lake build Bimodal.ProofSystem.Axioms` passes
- Soundness files will have compile errors (expected)

---

### Phase 3: Add Derived Reflexive Operators [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Define G'/H' as derived operators for convenience

**Tasks:**
- [ ] In `Theories/Bimodal/Syntax/Formula.lean`, add:
  ```lean
  def weak_future (phi : Formula) : Formula := phi.or phi.all_future
  def weak_past (phi : Formula) : Formula := phi.or phi.all_past
  ```
- [ ] Update `always` definition if needed: `H phi /\ phi /\ G phi` (now genuinely tripartite)
- [ ] Add notation if helpful

**Timing:** 20 minutes

**Files to modify:**
- `Theories/Bimodal/Syntax/Formula.lean`

**Verification:**
- `lake build Bimodal.Syntax.Formula` passes

---

### Phase 4: Fix Soundness Proofs [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Adapt all soundness proofs for irreflexive semantics

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/Soundness.lean`:
  - Delete `temp_t_future_valid` proof
  - Delete `temp_t_past_valid` proof
  - Adapt `temp_4_valid`: use `lt_trans` instead of `le_trans`
  - Adapt `temp_a_valid`: adjust for strict past quantifier
  - Adapt `temp_l_valid`: adjust for strict quantifiers
  - Adapt `temp_linearity_valid`: adjust inequalities
  - Update `axiom_valid` case list
- [ ] In `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`:
  - Remove T-axiom cases from `axiom_swap_valid`
  - Adapt temporal duality soundness

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Soundness.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Soundness` passes
- `grep -n "\bsorry\b"` returns empty for both files

---

### Phase 5: Fix Time-Shift Preservation [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Adapt time-shift lemmas for strict inequalities

**Tasks:**
- [ ] In `Theories/Bimodal/Semantics/Truth.lean` (TimeShift section):
  - Update `time_shift_preserves_truth` temporal cases
  - Use `sub_lt_sub_right` instead of `sub_le_sub_right`
  - Use `lt_of_add_lt_add_right` instead of `le_of_add_le_add_right`

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Semantics/Truth.lean`

**Verification:**
- `lake build Bimodal.Semantics.Truth` passes
- Time-shift lemmas compile

---

### Phase 6: Fix Canonical Frame [PARTIAL]

- **Dependencies:** Phase 4
- **Goal:** Remove reflexivity theorems from canonical model construction

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`:
  - Delete `canonicalR_reflexive` theorem (no longer holds)
  - Delete `canonicalR_past_reflexive` theorem
  - Keep `canonicalR_transitive` (uses temp_4, still valid)
  - Update any downstream usage
- [ ] Identify and fix files that import/use deleted theorems

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- Files using `canonicalR_reflexive` (search and fix)

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.CanonicalFrame` passes

---

### Phase 7: Fix Bidirectional Fragment [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Adapt BidirectionalReachable for irreflexive canonical relation

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`:
  - Adapt fragment membership proofs
  - Adapt totality proofs
  - The Antisymmetrization quotient may become simpler (irreflexive relation is closer to antisymmetric)
- [ ] Verify fragment still has NoMinOrder, NoMaxOrder

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.BidirectionalReachable` passes

---

### Phase 8: Rewrite DenseQuotient (Phase 6 Blocker Resolution) [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Complete the DenselyOrdered proof now that T-axiom obstruction is removed

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean`:
  - The combined seed `{G(psi), neg(psi)}` is NOW CONSISTENT (no T-axiom to derive psi from G(psi))
  - Rewrite density proof using the standard textbook argument:
    1. Extract psi from a < b witness
    2. Build seed `{G(psi), neg(psi)} union GContent(a) union HContent(b)`
    3. Prove seed consistent via Lindenbaum
    4. Extend to intermediate MCS c
    5. Show a < c < b
  - The F-witness extraction may use different strategy (see research-016 Section 4)
- [ ] Prove `DenselyOrdered (BidirectionalQuotient M0 h_mcs0)` with DN hypothesis

**Timing:** 4 hours (key phase)

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.DenseQuotient` passes
- `grep -n "\bsorry\b"` returns empty
- `DenselyOrdered` instance compiles

---

### Phase 9: Cantor's Theorem Application [NOT STARTED]

- **Dependencies:** Phase 8
- **Goal:** Apply Cantor's theorem to get quotient isomorphic to Q

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean`:
  - Prove `quotient_countable`
  - Prove `quotient_noMinOrder`, `quotient_noMaxOrder`
  - Apply `Order.iso_of_countable_dense` to get `Nonempty (BidirectionalQuotient ≃o Rat)`

**Timing:** 2 hours

**Files to modify/create:**
- `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean`

**Verification:**
- `lake build` passes
- `Nonempty (... ≃o Rat)` theorem compiles

---

### Phase 10: Dense Completeness Theorem [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Prove completeness for TM + DN

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/DenseCompleteness.lean`:
  - Define `TM_DN_provable`
  - Prove `dense_representation_theorem`: consistent formula has dense task frame model
  - Prove `dense_completeness : valid_dense phi -> TM_DN_provable phi`
  - Use D = Q via isomorphism, `addGroupIsAddTorsor` for torsor structure

**Timing:** 3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean`

**Verification:**
- `lake build Bimodal.Metalogic.DenseCompleteness` passes
- `grep -n "\bsorry\b"` returns empty
- `dense_completeness` theorem compiles with correct type

---

### Phase 11: Fix Remaining Metalogic Files [NOT STARTED]

- **Dependencies:** Phase 10
- **Goal:** Adapt remaining metalogic files that use T-axiom or reflexive semantics

**Tasks:**
- [ ] Fix `CanonicalCompleteness.lean` if needed
- [ ] Fix `BFMCSTruth.lean` truth lemma temporal cases
- [ ] Fix `CanonicalChain.lean` if still used
- [ ] Fix `CanonicalConstruction.lean` if still used
- [ ] Fix `CanonicalFMCS.lean` if still used
- [ ] Mark DovetailingChain.lean for archival (coherence proofs depended on T-axiom)

**Timing:** 3 hours

**Files to modify:**
- Various `Bundle/*.lean` files

**Verification:**
- `lake build` passes for all metalogic files

---

### Phase 12: Fix Decidability and Algebraic [NOT STARTED]

- **Dependencies:** Phase 11
- **Goal:** Adapt decidability tableau and algebraic metalogic

**Tasks:**
- [ ] In `Theories/Bimodal/Metalogic/Decidability/`:
  - Update tableau rules for `<` instead of `<=`
  - Update saturation conditions
  - Update countermodel extraction
- [ ] In `Theories/Bimodal/Metalogic/Algebraic/`:
  - Remove interior operator properties that depended on T-axiom
  - Adapt remaining algebraic proofs

**Timing:** 2.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Decidability/*.lean` (7 files)
- `Theories/Bimodal/Metalogic/Algebraic/*.lean` (5 files)

**Verification:**
- `lake build` passes for all decidability and algebraic files

---

### Phase 13: Fix Theorems and Examples [NOT STARTED]

- **Dependencies:** Phase 12
- **Goal:** Adapt theorem files and examples

**Tasks:**
- [ ] Fix `Theories/Bimodal/Theorems/*.lean`:
  - Adapt Perpetuity.lean
  - Adapt Combinators.lean if uses T-axiom
  - ModalS4, ModalS5 unchanged (modal axioms unaffected)
- [ ] Fix `Theories/Bimodal/Examples/*.lean`:
  - Update example proofs
- [ ] Update docstrings throughout

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Theorems/*.lean`
- `Theories/Bimodal/Examples/*.lean`

**Verification:**
- Full `lake build` passes

---

### Phase 14: Final Verification and Summary [NOT STARTED]

- **Dependencies:** Phase 13
- **Goal:** Full verification, sorry audit, and documentation

**Tasks:**
- [ ] Run full `lake build`
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/`
- [ ] Verify no NEW sorries (pre-existing Int-chain sorries are expected)
- [ ] Verify no new axioms: `grep -n "^axiom " Theories/Bimodal/`
- [ ] Create implementation summary
- [ ] Update module documentation with irreflexive semantics note

**Timing:** 1 hour

**Files to create:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

**Verification:**
- `lake build` passes
- Sorry count unchanged (only pre-existing Int-chain sorries)
- Summary complete

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] New files have 0 sorries
- [ ] No new axioms introduced
- [ ] `dense_completeness` theorem has correct type signature
- [ ] DN soundness now genuinely depends on DenselyOrdered (not vacuously true)

### Semantic Validation
- [ ] G/H use strict `<` semantics
- [ ] T-axioms removed from axiom type
- [ ] Derived G'/H' operators defined
- [ ] Phase 6 DenselyOrdered proof complete without T-axiom obstruction

## Artifacts & Outputs

**Modified Files (Tier 1 - Core):**
- `Theories/Bimodal/Semantics/Truth.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `Theories/Bimodal/Syntax/Formula.lean`
- `Theories/Bimodal/Metalogic/Soundness.lean`
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean`

**Modified Files (Tier 2 - Canonical Model):**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean`
- `Theories/Bimodal/Metalogic/Bundle/DenseQuotient.lean`
- `Theories/Bimodal/Metalogic/Bundle/QuotientIsomorphism.lean`
- `Theories/Bimodal/Metalogic/DenseCompleteness.lean`
- Plus ~25 additional files

**Summary:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. Each phase has independent commits; use `git revert` for specific phase
2. If density proof still blocked after irreflexive switch:
   - Document the NEW blocker
   - Consider direct Q-embedding approach (research-016 Section 4 alternative)
3. The reflexive codebase can be recovered via git history

## Comparison with implementation-002.md

| Aspect | implementation-002.md | implementation-003.md |
|--------|----------------------|----------------------|
| Semantic basis | Reflexive (<=) | Irreflexive (<) |
| T-axiom | Present | Removed |
| Phase 6 DenselyOrdered | BLOCKED | Unblocked (T-axiom obstruction removed) |
| DN/DF soundness | Trivially valid (vacuous) | Non-trivially valid (mathematically correct) |
| Estimated effort | 12 hours | 25-35 hours |
| Risk level | High (blocked) | Medium (large refactor, but unblocked) |
