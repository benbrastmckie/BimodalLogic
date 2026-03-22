# Implementation Plan: Task #29 (v4 - Substitution Lemma Approach)

- **Task**: 29 - switch_to_reflexive_gh_semantics
- **Status**: [IN PROGRESS]
- **Effort**: 8-12 hours (remaining work for Phases 5-6)
- **Dependencies**: None (self-contained refactoring)
- **Research Inputs**:
  - specs/029_switch_to_reflexive_gh_semantics/reports/09_team-research.md (substitution lemma identified)
  - specs/029_switch_to_reflexive_gh_semantics/reports/08_team-research.md (CanonicalTask-centric blocker resolution)
  - specs/025_rename_canonicalr_to_existstask/reports/05_team-research.md (Task 25 overlap analysis)
- **Supersedes**: plans/03_fresh-g-atom-approach.md (v3)
- **Artifacts**: plans/04_substitution-lemma-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

This is plan v4, incorporating the **derivation substitution lemma** identified in report 09 as the key missing infrastructure. The fresh G-atom approach requires proving that formulas derived from a context are invariant under substitution of fresh atoms. Without this lemma, the "fresh atom adds no constraints" argument cannot close.

**Key insight from report 09**: The 2-3 sorries in `CanonicalIrreflexivity.lean` all require the same underlying lemma: if atom q does not appear in any formula of a context, then replacing q with any other atom preserves derivability.

Phases 0-4 and 7-8 are already COMPLETED from prior implementation runs. This plan focuses on completing Phases 5-6 using the substitution lemma as prerequisite infrastructure.

### Research Integration (v4 Key Findings)

From report 09_team-research.md:

| Finding | Implication |
|---------|-------------|
| Substitution lemma is the key missing piece | Add Phase 5.0 before fresh G-atom work |
| Phase 5 correctly framed at ExistsTask level | No reframing needed |
| 2 sorries in `exists_strict_fresh_atom` + 1 in `fresh_Gp_seed_consistent` | All 3 closed by substitution lemma |
| DenselyOrdered needs compound seed | Budget for two g_content sets + fresh atom |

From report 05 (Task 25 overlap):

| Task 25 Phase | Task 29 Phase | Resolution |
|---------------|---------------|------------|
| Phase 1-2: Fresh G-atom proofs | Phase 5: Same work | Task 29 does this work |
| Phase 3-4: Retire Gabbay + rename | Depends on Phase 5 | Task 25 waits for Task 29 |

**Dependency**: Task 25 should wait for Task 29 Phase 5 completion before proceeding.

## Goals & Non-Goals

**Goals**:
- Complete Phase 5.0: Prove derivation substitution lemma for bimodal calculus
- Complete Phase 5.1-5.5 using substitution lemma to close all sorries
- Prove `canonicalR_strict_successor` and `canonicalR_strict_predecessor`
- Remove `canonicalR_irreflexive_axiom`
- Complete Phase 6: prove `discreteImmediateSuccSeed_consistent_axiom` via T-axiom

**Non-Goals**:
- Proving universal `canonicalR_antisymmetric` (research confirms this is FALSE)
- Modifying already-completed phases (0-4, 7-8)
- Task 25 work (deferred until this task completes)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Substitution lemma complexity | H | M | Standard proof theory; induction on derivation structure |
| DenselyOrdered compound seed consistency | M | M | May need two fresh atoms; budget 2h for this case |
| atoms_of_set Finset implementation | M | L | Use existing Formula.atoms; extend to sets |
| NoMinOrder H-atom dual case | M | L | Symmetric to G-atom; h_content substitution |

## Implementation Phases

### Phase 0-4: Core Semantic Changes [COMPLETED]

**Status**: All completed in prior implementation runs.

- Phase 0: Enumeration and pattern catalog
- Phase 1: Core semantic change (Truth.lean `<=` instead of `<`)
- Phase 2: FMCS structure update
- Phase 3: Soundness proof repairs
- Phase 4: Truth lemma adjustment

---

### Phase 5.0: Derivation Substitution Lemma [NOT STARTED]

**Goal**: Prove the core lemma that enables all fresh G-atom arguments

This is the **prerequisite infrastructure** identified in report 09. Without this lemma, the fresh atom proofs cannot close.

**Tasks**:
- [ ] Define `atoms : Formula -> Finset Atom` (recursive enumeration)
- [ ] Define `atoms_of_set : Set Formula -> Set Atom`
- [ ] Define `Formula.subst : Atom -> Atom -> Formula -> Formula` (atom substitution)
- [ ] Define `Set.image_subst : Atom -> Atom -> Set Formula -> Set Formula`
- [ ] Prove `derivation_atom_substitution`:
  ```lean
  theorem derivation_atom_substitution (Gamma : Set Formula) (phi : Formula)
      (q r : Atom) (h_fresh : q ∉ atoms_of_set Gamma)
      (h_deriv : Gamma ⊢ phi) : (Gamma.image (Formula.subst q r)) ⊢ (phi.subst q r)
  ```
  - Proof by induction on derivation structure
  - Cases: axiom, modus ponens, necessitation (G-nec, H-nec)
  - Key: substitution commutes with all inference rules
- [ ] Prove corollary `derivation_fresh_irrelevant`:
  ```lean
  -- If q is fresh for Gamma, then Gamma ⊢ phi implies Gamma ⊢ phi[r/q]
  theorem derivation_fresh_irrelevant (Gamma : Set Formula) (phi : Formula)
      (q r : Atom) (h_fresh_Gamma : q ∉ atoms_of_set Gamma)
      (h_fresh_phi : q ∉ phi.atoms)
      (h_deriv : Gamma ⊢ phi) : Gamma ⊢ phi
  ```
  - Trivial: if q is fresh for phi, then phi[r/q] = phi

**Timing**: 2-3 hours

**Files to create/modify**:
- `Theories/Bimodal/ProofSystem/Substitution.lean` (new file)
- `Theories/Bimodal/Syntax/Formula.lean` (add `atoms`, `subst` if not present)

**Verification**:
- `lake build Bimodal.ProofSystem.Substitution` succeeds
- `derivation_atom_substitution` is a proven theorem (no sorry)

---

### Phase 5.1: Fresh Atom Seed Consistency [NOT STARTED]

**Goal**: Use substitution lemma to prove fresh G-atom seeds are consistent

**Tasks**:
- [ ] Define `fresh_for : Atom -> Set Formula -> Prop` as `p ∉ atoms_of_set S`
- [ ] Prove `fresh_atom_exists`:
  ```lean
  theorem fresh_atom_exists (M : MCS) : ∃ p : Atom, fresh_for p M.formulas
  ```
  - Argument: MCS is countable; atoms are countably infinite; pigeon hole
- [ ] Prove `fresh_Gp_seed_consistent` using substitution lemma:
  ```lean
  theorem fresh_Gp_seed_consistent (M : MCS) (p : Atom) (h_fresh : fresh_for p M.formulas) :
      Consistent (g_content M ∪ {G (Atom.toFormula p)})
  ```
  - Proof sketch (closing sorry at line 1405):
    - Suppose for contradiction: `L ⊆ g_content(M) ∪ {G(p)}` and `L ⊢ ⊥`
    - Case 1: `G(p) ∈ L`
      - Let `L' = L \ {G(p)} ⊆ g_content(M)`
      - Then `L' ⊢ G(p) -> ⊥`, i.e., `L' ⊢ ¬G(p)`
      - By substitution lemma: `L' ⊢ ¬G(r)` for any atom r (since p is fresh for L')
      - This means `¬G(r) ∈ Cn(L') ⊆ Cn(M)` for all r
      - But `G(⊤) ∈ M` by T-axiom, contradiction
    - Case 2: `G(p) ∉ L` - then `L ⊆ g_content(M) ⊆ M`, contradicting MCS consistency
- [ ] Prove `fresh_Hp_seed_consistent` (symmetric for H-content):
  ```lean
  theorem fresh_Hp_seed_consistent (M : MCS) (p : Atom) (h_fresh : fresh_for p M.formulas) :
      Consistent (h_content M ∪ {H (Atom.toFormula p)})
  ```

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Canonical/FreshAtom.lean` (new file)
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` (update existing sorries)

**Verification**:
- `lake build Bimodal.Metalogic.Canonical.FreshAtom` succeeds
- `fresh_Gp_seed_consistent` is proven (no sorry)

---

### Phase 5.2: Strict Witness Theorems [NOT STARTED]

**Goal**: Prove per-witness strictness using fresh G-atom construction

**Tasks**:
- [ ] Prove `exists_strict_fresh_atom` (closing sorries at lines 1283, 1294):
  ```lean
  theorem exists_strict_fresh_atom (M : MCS) :
      ∃ q : Atom, ¬(Atom.toFormula q) ∈ M ∧ G (¬(Atom.toFormula q)) ∉ M
  ```
  - Proof using substitution lemma:
    - Choose p fresh for M
    - p ∉ M (since fresh means p not mentioned anywhere)
    - Suppose G(¬p) ∈ M. By MCS maximality, since p ∉ M, we have ¬p ∈ M.
    - But ¬p ∈ M means p appears in M, contradicting freshness.
    - Therefore G(¬p) ∉ M. QED.
- [ ] Prove `existsTask_strict_fresh_atom`:
  ```lean
  theorem existsTask_strict_fresh_atom (M : MCS) (hM : M.consistent) :
      ∃ W : MCS, ExistsTask M W ∧ ¬ExistsTask W M
  ```
  - Construction: extend `g_content(M) ∪ {G(p)}` to MCS W
  - Forward: `g_content(M) ⊆ W` implies `ExistsTask M W`
  - Backward: `G(p) ∈ W` implies `p ∈ g_content(W)`, but `p ∉ M`, so `g_content(W) ⊄ M`
- [ ] Prove `canonicalR_strict_successor`:
  ```lean
  theorem canonicalR_strict_successor (M : MCS) :
      ∃ W : MCS, CanonicalR M W ∧ ¬CanonicalR W M
  ```
  - Direct wrapper around `existsTask_strict_fresh_atom`
- [ ] Prove `canonicalR_strict_predecessor`:
  ```lean
  theorem canonicalR_strict_predecessor (M : MCS) :
      ∃ W : MCS, CanonicalR W M ∧ ¬CanonicalR M W
  ```
  - Symmetric using H(p) and h_content
- [ ] Prove `canonicalR_reflexive`:
  ```lean
  theorem canonicalR_reflexive (M : MCS) : CanonicalR M M
  ```
  - Trivial from T-axiom: `g_content M ⊆ M`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification**:
- `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` succeeds
- All `sorry` in file removed

---

### Phase 5.3: Update Quotient Order Proofs [NOT STARTED]

**Goal**: Replace irreflexivity-based proofs with fresh-atom proofs in CantorApplication.lean

**Tasks**:
- [ ] Update `NoMaxOrder` proof:
  - Old: used `canonicalR_irreflexive` for contradiction
  - New: use `canonicalR_strict_successor` to get W with `CanonicalR M W ∧ ¬CanonicalR W M`
  - The strict witness provides the required `<` directly
- [ ] Update `NoMinOrder` proof:
  - Use `canonicalR_strict_predecessor` symmetrically
- [ ] Update `DenselyOrdered` proof:
  - Given M < N (i.e., `CanonicalR M N ∧ ¬CanonicalR N M`)
  - Construct intermediate W using compound seed:
    - Seed = `g_content(M) ∪ g_content(N) ∪ {G(p)}` where p is fresh for M ∪ N
  - Prove seed consistency (may need two fresh atoms if single fails)
  - Prove M < W: `ExistsTask M W` from seed, `¬ExistsTask W M` from G(p)
  - Prove W < N: `ExistsTask W N` from g_content(N), `¬ExistsTask N W` (requires careful argument)

**Timing**: 3-4 hours (budget extra for DenselyOrdered complexity)

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

**Verification**:
- `lake build Bimodal.Metalogic.StagedConstruction.CantorApplication` succeeds

---

### Phase 5.4: Update Remaining Call Sites [NOT STARTED]

**Goal**: Fix all remaining call sites using fresh-atom pattern

**Tasks**:
- [ ] Fix `FMCSTransfer.lean`:
  - `lt_of_canonicalR` needs redesign: require `a ≠ b` hypothesis
  - OR handle `a = b` case separately in callers
- [ ] Fix `DovetailedTimelineQuot.lean` (~12 sites):
  - Pattern: replace `canonicalR_irreflexive M hM h_R` with fresh-atom-based contradiction
  - For `inl` (MCS equality) cases: use per-construction distinctness
- [ ] Fix `SaturatedChain.lean` (~6 sites):
  - Use `canonicalR_strict_successor/predecessor` where applicable
- [ ] Fix remaining files:
  - `ClosureSaturation.lean` (2 sites)
  - `IncrementalTimeline.lean` (1 site)
  - `TimelineQuotCanonical.lean` (1 site)
  - `DiscreteTimeline.lean` (2 sites)
  - `CanonicalSerialFrameInstance.lean` (2 sites)
- [ ] Run `lake build` to find and fix any remaining breakages

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedTimelineQuot.lean`
- `Theories/Bimodal/Metalogic/Algebraic/SaturatedChain.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/ClosureSaturation.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/IncrementalTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotCanonical.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalSerialFrameInstance.lean`

**Verification**:
- `grep -r "canonicalR_irreflexive" Theories/` returns no results (except comments)
- `lake build` succeeds

---

### Phase 5.5: Remove Axiom [NOT STARTED]

**Goal**: Delete the now-proven axiom

**Tasks**:
- [ ] Delete `axiom canonicalR_irreflexive_axiom` from CanonicalIrreflexivity.lean
- [ ] Update `CanonicalIrreflexivityAxiom.lean` wrapper to export new theorems
- [ ] Verify `lake build` passes
- [ ] Grep to confirm no remaining references

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Verification**:
- `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results
- `lake build` succeeds

---

### Phase 6: T-Axiom Simplification for discreteImmediateSuccSeed [NOT STARTED]

**Goal**: Prove `discreteImmediateSuccSeed_consistent_axiom` using T-axiom

This phase is independent of Phase 5 and can be attempted in parallel.

**Tasks**:
- [ ] Analyze Case 2 in `discreteImmediateSuccSeed_consistent`:
  - Under reflexive semantics: `g_content(M) ⊆ M` holds (T-axiom)
  - Blocking formula `¬ψ ∨ ¬G(ψ)` is derivable from `¬G(ψ) ∈ M`
  - Show seed consistency using MCS closure properties
- [ ] Remove `axiom discreteImmediateSuccSeed_consistent_axiom` from DiscreteSuccSeed.lean
- [ ] Complete the proof in `discreteImmediateSuccSeed_consistent`
- [ ] Assess `discreteImmediateSucc_covers_axiom`: attempt proof via T-axiom
- [ ] Assess `successor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Assess `predecessor_deferral_seed_consistent_axiom`: attempt proof via T-axiom
- [ ] Document remaining axioms as semantics-independent in code comments
- [ ] Run `lake build Bimodal.Metalogic.StagedConstruction.DiscreteSuccSeed` to verify

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` (assessment/documentation)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (documentation)

**Verification**:
- `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results
- `discreteImmediateSuccSeed_consistent` is a proven theorem

---

### Phase 7-8: Documentation and Verification [COMPLETED]

**Status**: All completed in prior implementation runs.

- Phase 7: Frame class documentation update
- Phase 8: Documentation and final verification

---

## Testing & Validation

- [ ] Full `lake build` passes after each Phase 5 step
- [ ] Phase 5.0: `derivation_atom_substitution` is proven (no sorry)
- [ ] Phase 5.1: `fresh_Gp_seed_consistent` is proven (no sorry)
- [ ] Phase 5.2: All sorries in CanonicalIrreflexivity.lean removed
- [ ] Phase 5.5: `grep -r "canonicalR_irreflexive_axiom" Theories/` returns no results
- [ ] Phase 6: `grep -r "discreteImmediateSuccSeed_consistent_axiom" Theories/` returns no results
- [ ] `canonicalR_strict_successor` and `canonicalR_strict_predecessor` are proven theorems
- [ ] `canonicalR_reflexive` is a proven theorem
- [ ] No new `sorry` introduced (verify via `grep -r "sorry" Theories/`)

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/Substitution.lean` (new file - substitution lemma)
- `Theories/Bimodal/Metalogic/Canonical/FreshAtom.lean` (new file - fresh atom infrastructure)
- Updated `CanonicalIrreflexivity.lean` with fresh-atom theorems
- Updated `CantorApplication.lean` with fresh-atom proofs
- Updated all downstream files using fresh-atom pattern
- Proven `discreteImmediateSuccSeed_consistent` theorem
- Implementation summary at `specs/029_switch_to_reflexive_gh_semantics/summaries/01_reflexive-semantics-summary.md`

## Cross-Task Dependencies

**Task 25 Dependency**:
- Task 25 (Rename CanonicalR to ExistsTask) Phases 1-2 overlap 100% with Task 29 Phase 5
- Task 25 should wait for Task 29 Phase 5 completion
- After Task 29 Phase 5: Task 25 can proceed with Phases 3-4 (retire Gabbay, rename)

## Rollback/Contingency

If substitution lemma encounters unexpected complexity:

1. **Induction on derivation fails**: Consider:
   - Using proof-irrelevance to avoid full induction
   - Axiomatizing the substitution lemma temporarily

2. **DenselyOrdered compound seed fails**: May need:
   - Two separate fresh atoms (one for M-W, one for W-N)
   - Budget additional 2h for this case

3. **Git revert fallback**: If Phase 5 exceeds 15 hours total, consider:
   - Keeping `canonicalR_irreflexive_axiom` as permanent axiom
   - Documenting the reflexivity exception in comments

The core semantic change (Phases 1-4) is stable and completed. Phase 5 failures would not affect the already-working reflexive semantics foundation.
