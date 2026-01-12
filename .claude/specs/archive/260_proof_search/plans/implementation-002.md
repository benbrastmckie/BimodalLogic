# Implementation Plan: Task #260 (REVISED)

**Task**: Proof Search with Proof Term Construction (Direct Refactor Approach)
**Version**: 002
**Created**: 2026-01-12
**Language**: lean
**Supersedes**: implementation-001.md (AxiomWitness pattern - abandoned)

## Overview

This revised plan implements automated proof search with proof term construction for TM logic using the **Direct Refactor** approach recommended in research-004.md. The key insight is that changing `Axiom` from `Prop` to `Type` enables proof term construction with:
- **Zero risk**: No code in the codebase relies on proof irrelevance for Axiom
- **Maximum simplicity**: Single source of truth, no parallel types
- **No maintenance burden**: Unlike the AxiomWitness pattern, no parallel type to synchronize

### Approach Summary

1. **Phase 1: Axiom Refactor** - Change `inductive Axiom : Formula -> Prop` to `inductive Axiom : Formula -> Type`
2. **Phase 2: Proof Term Construction** - Implement `matchAxiom` and update `bounded_search` to return `DerivationTree`
3. **Phase 3: Tactic Integration** (Optional) - Create `modal_search` tactic wrapper
4. **Phase 4: BFS Variant** (Optional) - Implement queue-based BFS with proof terms
5. **Phase 5: Testing** - Verify all existing proofs compile, add proof term tests

### Key Research References

- **research-004.md (DEFINITIVE)**: Balanced analysis recommending Direct Refactor
- **research-003.md**: Prior AxiomWitness recommendation (superseded)
- **research-001.md**: Original proof search infrastructure analysis
- **research-002.md**: AxiomWitness pattern analysis

### User Values Alignment

Per research-004.md, this plan prioritizes:
- **SIMPLICITY**: Single `Axiom` type for all purposes
- **CONSISTENCY**: Same type in proofs and automation
- **DATA RICHNESS**: Type enables `deriving Repr, DecidableEq`
- **Computability**: All functions remain computable

---

## Phases

### Phase 1: Axiom Refactor (Prop to Type)

**Estimated effort**: 1 hour
**Status**: [NOT STARTED]
**Risk Level**: Low (research-004 verified no code uses proof irrelevance)

**Objectives**:
1. Change Axiom from Prop to Type
2. Add deriving clauses for Repr, DecidableEq
3. Verify all downstream files compile unchanged

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Change inductive definition

**Steps**:

1. **Modify Axiom definition** (line 66 of Axioms.lean):
   ```lean
   -- FROM:
   inductive Axiom : Formula -> Prop where

   -- TO:
   inductive Axiom : Formula -> Type where
     | prop_k (φ ψ χ : Formula) :
         Axiom ((φ.imp (ψ.imp χ)).imp ((φ.imp ψ).imp (φ.imp χ)))
     | prop_s (φ ψ : Formula) : Axiom (φ.imp (ψ.imp φ))
     | modal_t (φ : Formula) : Axiom (Formula.box φ |>.imp φ)
     | modal_4 (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.box φ)))
     | modal_b (φ : Formula) : Axiom (φ.imp (Formula.box φ.diamond))
     | modal_5_collapse (φ : Formula) : Axiom (φ.box.diamond.imp φ.box)
     | ex_falso (φ : Formula) : Axiom (Formula.bot.imp φ)
     | peirce (φ ψ : Formula) : Axiom (((φ.imp ψ).imp φ).imp φ)
     | modal_k_dist (φ ψ : Formula) :
         Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
     | temp_k_dist (φ ψ : Formula) :
         Axiom ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))
     | temp_4 (φ : Formula) :
         Axiom ((Formula.all_future φ).imp (Formula.all_future (Formula.all_future φ)))
     | temp_a (φ : Formula) : Axiom (φ.imp (Formula.all_future φ.sometime_past))
     | temp_l (φ : Formula) : Axiom (φ.always.imp (Formula.all_future (Formula.all_past φ)))
     | modal_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.box (Formula.all_future φ)))
     | temp_future (φ : Formula) : Axiom ((Formula.box φ).imp (Formula.all_future (Formula.box φ)))
     deriving Repr, DecidableEq
   ```

2. **Verify build succeeds**:
   ```bash
   lake build Bimodal.ProofSystem.Axioms
   lake build Bimodal.Metalogic.Soundness
   lake build Bimodal.Metalogic.SoundnessLemmas
   ```

**Verification**:
- [ ] `lake build` succeeds with no errors
- [ ] Soundness.lean compiles unchanged
- [ ] SoundnessLemmas.lean compiles unchanged
- [ ] DerivationTree.lean compiles unchanged
- [ ] All `cases h_axiom` patterns still work (Type supports same pattern matching)

**Why this is safe** (from research-004):
- The soundness proofs use `cases h_axiom` which produces `Prop` values (validity)
- The pattern match result is a Prop, not the Axiom witness itself
- No equality comparisons between Axiom witnesses exist in the codebase

---

### Phase 2: Proof Term Construction

**Estimated effort**: 6-8 hours
**Status**: [NOT STARTED]
**Dependencies**: Phase 1 complete

**Objectives**:
1. Implement `matchAxiom : Formula -> Option (Sigma Axiom)` function
2. Create `SearchResultWithProof` type alias
3. Update `bounded_search` to construct `DerivationTree`
4. Update `iddfs_search` and `bestFirst_search` similarly
5. Preserve existing `Bool`-returning functions for backward compatibility

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch.lean` - Add matchAxiom and proof term construction

**Steps**:

1. **Add matchAxiom function** (after line 339 in ProofSearch.lean):
   ```lean
   /--
   Match a formula against axiom patterns, returning witness if matched.

   This function enables proof term construction by returning the actual
   Axiom constructor that matches the formula pattern.

   **Returns**: `some ⟨φ, witness⟩` if φ matches an axiom schema, `none` otherwise
   -/
   def matchAxiom (φ : Formula) : Option (Sigma Axiom) :=
     let imp? : Formula → Option (Formula × Formula)
       | .imp α β => some (α, β)
       | _ => none
     match imp? φ with
     | none => none
     | some (lhs, rhs) =>
       -- Check prop_k pattern: (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
       match lhs, rhs with
       | .imp a (.imp b c), .imp (.imp a' b') (.imp a'' c') =>
           if a = a' ∧ a' = a'' ∧ b = b' ∧ c = c' then
             some ⟨_, Axiom.prop_k a b c⟩
           else none
       | _, _ =>
         -- Check prop_s pattern: φ → (ψ → φ)
         match lhs, rhs with
         | phi, .imp _ phi' =>
             if phi = phi' then some ⟨_, Axiom.prop_s phi (match rhs with | .imp psi _ => psi | _ => .bot)⟩
             else checkOtherPatterns lhs rhs
         | _, _ => checkOtherPatterns lhs rhs
   where
     checkOtherPatterns (lhs rhs : Formula) : Option (Sigma Axiom) :=
       -- ex_falso: ⊥ → φ
       (if lhs = .bot then some ⟨_, Axiom.ex_falso rhs⟩ else none)
       -- peirce: ((φ → ψ) → φ) → φ
       <|> (match lhs, rhs with
            | .imp (.imp phi psi) phi', phi'' =>
                if phi = phi' ∧ phi' = phi'' then some ⟨_, Axiom.peirce phi psi⟩ else none
            | _, _ => none)
       -- modal_t: □φ → φ
       <|> (match lhs, rhs with
            | .box phi, phi' => if phi = phi' then some ⟨_, Axiom.modal_t phi⟩ else none
            | _, _ => none)
       -- modal_4: □φ → □□φ
       <|> (match lhs, rhs with
            | .box phi, .box (.box phi') =>
                if phi = phi' then some ⟨_, Axiom.modal_4 phi⟩ else none
            | _, _ => none)
       -- modal_b: φ → □◇φ
       <|> (match lhs, rhs with
            | phi, .box (.diamond phi') =>
                if phi = phi' then some ⟨_, Axiom.modal_b phi⟩ else none
            | _, _ => none)
       -- modal_5_collapse: ◇□φ → □φ
       <|> (match lhs, rhs with
            | .diamond (.box phi), .box phi' =>
                if phi = phi' then some ⟨_, Axiom.modal_5_collapse phi⟩ else none
            | _, _ => none)
       -- modal_k_dist: □(φ → ψ) → (□φ → □ψ)
       <|> (match lhs, rhs with
            | .box (.imp phi psi), .imp (.box phi') (.box psi') =>
                if phi = phi' ∧ psi = psi' then some ⟨_, Axiom.modal_k_dist phi psi⟩ else none
            | _, _ => none)
       -- temp_k_dist: F(φ → ψ) → (Fφ → Fψ)
       <|> (match lhs, rhs with
            | .all_future (.imp phi psi), .imp (.all_future phi') (.all_future psi') =>
                if phi = phi' ∧ psi = psi' then some ⟨_, Axiom.temp_k_dist phi psi⟩ else none
            | _, _ => none)
       -- temp_4: Fφ → FFφ
       <|> (match lhs, rhs with
            | .all_future phi, .all_future (.all_future phi') =>
                if phi = phi' then some ⟨_, Axiom.temp_4 phi⟩ else none
            | _, _ => none)
       -- temp_a: φ → F(Pφ)
       <|> (match lhs, rhs with
            | phi, .all_future (.some_past phi') =>
                if phi = phi' then some ⟨_, Axiom.temp_a phi⟩ else none
            | _, _ => none)
       -- temp_l: △φ → F(Pφ) where △φ = Hφ ∧ φ ∧ Gφ
       <|> (match lhs, rhs with
            | .and (.all_past phi1) (.and phi2 (.all_future phi3)), .all_future (.all_past phi') =>
                if phi1 = phi2 ∧ phi2 = phi3 ∧ phi3 = phi' then some ⟨_, Axiom.temp_l phi1⟩ else none
            | _, _ => none)
       -- modal_future: □φ → □Fφ
       <|> (match lhs, rhs with
            | .box phi, .box (.all_future phi') =>
                if phi = phi' then some ⟨_, Axiom.modal_future phi⟩ else none
            | _, _ => none)
       -- temp_future: □φ → F□φ
       <|> (match lhs, rhs with
            | .box phi, .all_future (.box phi') =>
                if phi = phi' then some ⟨_, Axiom.temp_future phi⟩ else none
            | _, _ => none)
       -- No match
       <|> none
   ```

2. **Add proof-returning search type** (after SearchResult):
   ```lean
   /--
   Proof search result with actual derivation tree.
   Returns `Option (DerivationTree Γ φ)` where `some d` means proof found.
   -/
   abbrev SearchResultWithProof (Γ : Context) (φ : Formula) :=
     Option (DerivationTree Γ φ)
   ```

3. **Implement bounded_search_with_proof**:
   ```lean
   /--
   Bounded depth-first search returning proof term if successful.

   This is the proof-constructing variant of `bounded_search`.
   -/
   def bounded_search_with_proof (Γ : Context) (φ : Formula) (depth : Nat)
       (visited : Visited := Visited.empty)
       (visits : Nat := 0)
       (visitLimit : Nat := 500)
       (weights : HeuristicWeights := {})
       : Option (DerivationTree Γ φ) × Visited × Nat :=
     if depth = 0 then
       (none, visited, visits)
     else if visits ≥ visitLimit then
       (none, visited, visits)
     else
       let visits := visits + 1
       let key : CacheKey := (Γ, φ)
       if visited.contains key then
         (none, visited, visits)
       else
         let visited := visited.insert key
         -- Try axiom match first
         match matchAxiom φ with
         | some ⟨_, witness⟩ =>
             (some (DerivationTree.axiom Γ φ witness), visited, visits)
         | none =>
           -- Try assumption
           if h : φ ∈ Γ then
             (some (DerivationTree.assumption Γ φ h), visited, visits)
           else
             -- Try modus ponens
             let implications := find_implications_to Γ φ
             let orderedTargets := orderSubgoalsByScore weights Γ implications
             let rec tryAntecedents (targets : List Formula) (visited : Visited) (visits : Nat)
                 : Option (DerivationTree Γ φ) × Visited × Nat :=
               match targets with
               | [] =>
                 -- Try modal/temporal rules
                 match φ with
                 | .box ψ =>
                   let (result, visited', visits') :=
                     bounded_search_with_proof (box_context Γ) ψ (depth - 1) visited visits visitLimit weights
                   -- Note: Cannot directly construct modal K here without generalized necessitation
                   -- This requires the proof that Γ.map box ⊢ ψ implies Γ ⊢ □ψ
                   (none, visited', visits')  -- TODO: Needs modal K derivation
                 | .all_future ψ =>
                   let (result, visited', visits') :=
                     bounded_search_with_proof (future_context Γ) ψ (depth - 1) visited visits visitLimit weights
                   (none, visited', visits')  -- TODO: Needs temporal K derivation
                 | _ => (none, visited, visits)
               | antecedent :: rest =>
                 -- Find the implication in context
                 if h_imp : (antecedent.imp φ) ∈ Γ then
                   let (antResult, visited', visits') :=
                     bounded_search_with_proof Γ antecedent (depth - 1) visited visits visitLimit weights
                   match antResult with
                   | some antProof =>
                     let impProof := DerivationTree.assumption Γ (antecedent.imp φ) h_imp
                     (some (DerivationTree.modus_ponens Γ antecedent φ impProof antProof), visited', visits')
                   | none => tryAntecedents rest visited' visits'
                 else
                   tryAntecedents rest visited visits
             termination_by targets.length
             tryAntecedents orderedTargets visited visits
   termination_by depth
   ```

4. **Update search statistics and results to track proofs**

**Verification**:
- [ ] `matchAxiom` correctly identifies all 14 axiom patterns
- [ ] `bounded_search_with_proof` constructs valid `DerivationTree` for axioms
- [ ] `bounded_search_with_proof` constructs valid `DerivationTree` for assumptions
- [ ] `bounded_search_with_proof` constructs valid `DerivationTree` for modus ponens
- [ ] Existing `bounded_search` (Bool version) still works unchanged
- [ ] `lake build` succeeds

---

### Phase 3: Tactic Integration (Optional)

**Estimated effort**: 4-6 hours
**Status**: [NOT STARTED]
**Dependencies**: Phase 2 complete
**Priority**: Medium (can be deferred)

**Objectives**:
1. Create `modal_search` tactic that invokes proof search
2. Add syntax for depth configuration
3. Integrate with Aesop rule system

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearchTactics.lean` (new file)

**Steps**:

1. **Create tactic wrapper**:
   ```lean
   import Lean.Elab.Tactic
   import Bimodal.Automation.ProofSearch

   namespace Bimodal.Automation.Tactics

   open Lean Elab Tactic

   /-- Proof search tactic for modal/temporal logic formulas. -/
   elab "modal_search" depth:optional(num) : tactic => do
     let depth := depth.map (·.getNat) |>.getD 10
     -- Extract goal
     -- Run bounded_search_with_proof
     -- Apply resulting DerivationTree to goal
     sorry
   ```

2. **Add Aesop integration**

**Verification**:
- [ ] `by modal_search` works on axiom goals
- [ ] `by modal_search (depth := 5)` respects depth parameter
- [ ] Tactic produces valid proof terms

---

### Phase 4: BFS Variant with Proof Terms (Optional)

**Estimated effort**: 3-4 hours
**Status**: [NOT STARTED]
**Dependencies**: Phase 2 complete
**Priority**: Low (can be deferred)

**Objectives**:
1. Update `bestFirst_search` to construct proof terms
2. Verify BFS finds same proofs as DFS

**Files to modify**:
- `Theories/Bimodal/Automation/ProofSearch.lean` - Update bestFirst_search

**Steps**:

1. **Add proof construction to SearchNode**
2. **Update bestFirst_search to track partial proofs**

**Verification**:
- [ ] BFS produces valid `DerivationTree`
- [ ] BFS finds proofs that DFS finds

---

### Phase 5: Testing and Validation

**Estimated effort**: 2-3 hours
**Status**: [NOT STARTED]
**Dependencies**: Phase 2 complete

**Objectives**:
1. Verify all existing metalogic proofs compile
2. Add tests for matchAxiom
3. Add tests for proof term construction
4. Add tests verifying proof term validity

**Files to modify**:
- `Theories/Bimodal/Test/ProofSearchTest.lean` - Add proof term tests

**Steps**:

1. **Verify existing files compile**:
   ```bash
   lake build Bimodal.Metalogic.Soundness
   lake build Bimodal.Metalogic.SoundnessLemmas
   lake build Bimodal.Metalogic.Completeness
   lake build Bimodal.Metalogic.DeductionTheorem
   ```

2. **Add matchAxiom tests**:
   ```lean
   -- Test all 14 axiom patterns
   #check matchAxiom ((Formula.atom "p").box.imp (Formula.atom "p"))  -- Should match modal_t
   ```

3. **Add proof term validity tests**:
   ```lean
   -- Test that constructed proofs type-check
   example : ∃ d : ⊢ (Formula.atom "p").box.imp (Formula.atom "p"), True := by
     let (result, _, _) := bounded_search_with_proof [] _ 5
     exact ⟨result.get!, trivial⟩
   ```

**Verification**:
- [ ] All existing metalogic files compile unchanged
- [ ] matchAxiom tests pass for all 14 patterns
- [ ] Proof term construction tests pass
- [ ] No regressions in existing test suite

---

## Dependencies

- **Phase 1**: None (foundational change)
- **Phase 2**: Phase 1 must complete first
- **Phase 3**: Phase 2 must complete first (optional phase)
- **Phase 4**: Phase 2 must complete first (optional phase)
- **Phase 5**: Phase 2 must complete first

## Risks and Mitigations

| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| Axiom : Type breaks downstream | High | Very Low (<5%) | Research-004 verified no code uses proof irrelevance |
| matchAxiom pattern coverage incomplete | Medium | Low | Test all 14 patterns systematically |
| Proof term construction for modal/temporal K | Medium | Medium | May need helper lemmas from DeductionTheorem |
| Termination proofs for recursive search | Medium | Low | Use existing depth-based termination |

### Rollback Strategy

If Phase 1 causes unexpected issues:
1. Revert Axiom back to `Prop`
2. Fall back to implementation-001.md (AxiomWitness pattern)
3. Document specific issue that required rollback

## Success Criteria

**Minimum Viable Success** (Phases 1-2):
- [ ] Axiom changed from Prop to Type
- [ ] `deriving Repr, DecidableEq` works for Axiom
- [ ] matchAxiom function implemented and tested
- [ ] bounded_search_with_proof returns valid DerivationTree for axioms
- [ ] All existing metalogic proofs (Soundness, SoundnessLemmas) compile unchanged
- [ ] `lake build` succeeds with no errors

**Full Success** (All Phases):
- [ ] All minimum criteria met
- [ ] Proof term construction works for modus ponens chains
- [ ] modal_search tactic works interactively
- [ ] BFS variant produces proof terms
- [ ] Comprehensive test coverage

## Estimated Total Effort

| Phase | Hours | Priority | Cumulative |
|-------|-------|----------|------------|
| Phase 1: Axiom Refactor | 1 | Required | 1 |
| Phase 2: Proof Terms | 6-8 | Required | 7-9 |
| Phase 3: Tactics | 4-6 | Optional | 11-15 |
| Phase 4: BFS | 3-4 | Optional | 14-19 |
| Phase 5: Testing | 2-3 | Required | 16-22 |

**Minimum viable: 9-12 hours** (Phases 1, 2, 5)
**Full implementation: 16-22 hours** (All phases)

This is significantly less than the 76 hours estimated in implementation-001.md because:
1. Direct Refactor eliminates AxiomWitness parallel type (~400 lines saved)
2. No toAxiom conversion function needed
3. No synchronization overhead between parallel types
4. Simpler matchAxiom (returns actual Axiom, not AxiomWitness)

## References

- research-004.md: Definitive balanced analysis (Direct Refactor recommendation)
- research-001.md: Original proof search research
- Theories/Bimodal/ProofSystem/Axioms.lean: Current Axiom definition
- Theories/Bimodal/ProofSystem/Derivation.lean: DerivationTree definition
- Theories/Bimodal/Automation/ProofSearch.lean: Current search implementation
- Theories/Bimodal/Metalogic/Soundness.lean: Must compile unchanged
- Theories/Bimodal/Metalogic/SoundnessLemmas.lean: Must compile unchanged
