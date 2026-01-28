# Research Report: Prove Seed Consistency (Temporal K Distribution)

**Task**: 657 - prove_seed_consistency_temporal_k_distribution
**Started**: 2026-01-26T14:30:00Z
**Completed**: 2026-01-26T15:15:00Z
**Effort**: 2 hours
**Priority**: Medium
**Dependencies**: Task 654 (completed)
**Sources/Inputs**:
- Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean
- Theories/Bimodal/ProofSystem/Axioms.lean
- Theories/Bimodal/Boneyard/Metalogic/Completeness.lean
- specs/reviews/review-20260121-task654.md
**Artifacts**: specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-001.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Lines 338 and 354 in IndexedMCSFamily.lean contain sorries for proving seed set consistency using the temporal K distribution axiom
- The temporal K distribution axiom `F(φ → ψ) → (Fφ → Fψ)` is defined as `temp_k_dist` in Axioms.lean (line 210)
- The proof strategy requires showing that if a seed set were inconsistent, it would contradict the root MCS consistency via the K distribution property
- Required infrastructure exists: `set_mcs_closed_under_derivation` (proven in Boneyard/Metalogic/Completeness.lean)
- The proof is technically complex but follows a standard modal logic pattern used for modal K distribution

## Context & Scope

This task addresses two specific sorries in the indexed MCS family construction (Task 654 infrastructure):

1. **Line 338**: `future_seed_consistent` - Proving future seed sets are consistent
2. **Line 354**: `past_seed_consistent` - Proving past seed sets are consistent (symmetric to line 338)

These proofs are prerequisites for the `construct_indexed_family` function, which builds a coherent indexed family of MCS from a root MCS at the origin. Without these proofs, the family construction relies on axiomatized consistency, limiting the constructiveness of the representation theorem.

## Findings

### The Temporal K Distribution Axiom

**Location**: `Theories/Bimodal/ProofSystem/Axioms.lean:210-211`

```lean
| temp_k_dist (φ ψ : Formula) :
    Axiom ((φ.imp ψ).all_future.imp (φ.all_future.imp ψ.all_future))
```

**Semantics**: `F(φ → ψ) → (Fφ → Fψ)` - Future distributes over implication.

**Key Property**: This axiom enables combining future formulas. If formulas `{φ₁, ..., φₙ}` all have `F φᵢ` in an MCS, and `{φ₁, ..., φₙ} ⊢ ⊥`, then we can derive `F ⊥` through repeated application of temporal K distribution.

**Why It's Needed**: The seed consistency proofs need to show that if a seed set derived from G-formulas were inconsistent, it would contradict the root MCS being consistent. The K distribution axiom provides the bridge to propagate the contradiction back through the temporal operators.

### The Seed Construction

**Future Seed (Line 280-282)**:
```lean
def future_seed (Gamma : Set Formula) (t : D) : Set Formula :=
  if (0 : D) < t then {phi | Formula.all_future phi ∈ Gamma}
  else ∅
```

The future seed at time `t > 0` collects all `φ` where `G φ ∈ Gamma`. This represents formulas that MUST be true at future times based on the root MCS.

**Past Seed (Line 289-291)**:
```lean
def past_seed (Gamma : Set Formula) (t : D) : Set Formula :=
  if t < (0 : D) then {phi | Formula.all_past phi ∈ Gamma}
  else ∅
```

Symmetric construction for past times using H-formulas.

### Proof Strategy (Documented in Lines 312-320)

**For `future_seed_consistent` (Line 338)**:

The sorry comment provides the proof outline:

```
1. Assume future_seed is inconsistent
2. Then some finite subset L derives ⊥
3. For each φ ∈ L, we have G φ ∈ Gamma
4. Use temporal K distribution to show {G φ | φ ∈ L} ⊢ G ⊥
5. Since G ⊥ → ⊥ is derivable, Gamma would be inconsistent
6. Contradiction with Gamma being an MCS
```

**The Technical Challenge**: Step 4 requires a general theorem about distributing G over derivations:

**Needed Lemma**: If `{φ₁, ..., φₙ} ⊢ ⊥`, then `{G φ₁, ..., G φₙ} ⊢ G ⊥`

This is the "temporal necessitation for contexts" theorem, which generalizes temporal necessitation from theorems to contexts using K distribution.

### Available Infrastructure

**From Boneyard/Metalogic/Completeness.lean**:

1. **`set_mcs_closed_under_derivation`** (line 577):
   ```lean
   lemma set_mcs_closed_under_derivation {S : Set Formula} {φ : Formula}
       (h_mcs : SetMaximalConsistent S)
       (L : List Formula) (h_sub : ∀ ψ ∈ L, ψ ∈ S)
       (h_deriv : DerivationTree L φ) : φ ∈ S
   ```
   **Purpose**: Shows MCS are deductively closed. Will be used to show G ⊥ ∈ Gamma.

2. **`set_mcs_all_future_all_future`** (line 1055):
   ```lean
   theorem set_mcs_all_future_all_future {S : Set Formula} {φ : Formula}
       (h_mcs : SetMaximalConsistent S)
       (h_all_future : Formula.all_future φ ∈ S) :
       (Formula.all_future φ).all_future ∈ S
   ```
   **Purpose**: Temporal 4 axiom property (G φ → GG φ). Useful for iterated G reasoning.

3. **Deduction Theorem** (`deduction_theorem` in Boneyard/Metalogic/DeductionTheorem.lean):
   - Enables moving assumptions into implications
   - Critical for manipulating derivation contexts

4. **Temporal Necessitation Rule** (ProofSystem/Derivation.lean:126):
   ```lean
   | temporal_necessitation (φ : Formula)
       (d : DerivationTree [] φ) : DerivationTree [] (Formula.all_future φ)
   ```
   **Note**: Only applies to theorems (empty context). Need generalization for contexts.

### The Missing Generalized Temporal Necessitation Theorem

**What's Needed**: A theorem that lifts temporal necessitation from theorems to contexts using K distribution.

**Statement**:
```lean
theorem temporal_generalized_necessitation
    (L : List Formula) (φ : Formula)
    (h_deriv : DerivationTree L φ) :
    DerivationTree (L.map Formula.all_future) (Formula.all_future φ)
```

**Proof Strategy**: By induction on the derivation tree height, similar to the modal generalized necessitation theorem in `Bimodal.Theorems.GeneralizedNecessitation`.

**Key Steps**:
1. **Base cases** (axiom, assumption): Direct application of temporal necessitation or K distribution
2. **Modus ponens case**: Use temporal K distribution to combine G(φ → ψ) and Gφ to get Gψ
3. **Necessitation cases**: Compose temporal operators (G φ → GG φ via Temporal 4)
4. **Weakening case**: Preserve under context extension

**Reference**: The modal analog `modal_generalized_necessitation` exists in `Bimodal.Theorems.GeneralizedNecessitation` and can serve as a template.

### Proof Verification Pattern

**After proving generalized temporal necessitation**, the seed consistency proof follows this pattern:

```lean
lemma future_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (t : D) (ht : (0 : D) < t) : SetConsistent (future_seed D Gamma t) := by
  intro L hL
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- L is a list where each φ has G φ ∈ Gamma
  have h_G_list : ∀ φ ∈ L, Formula.all_future φ ∈ Gamma := by
    intro φ h_mem
    exact hL φ h_mem

  -- Apply generalized temporal necessitation to d_bot
  let L_G := L.map Formula.all_future
  have d_G_bot : DerivationTree L_G (Formula.all_future Formula.bot) :=
    temporal_generalized_necessitation L Formula.bot d_bot

  -- G ⊥ → ⊥ is derivable (vacuously, since G ⊥ means ⊥ at all future times)
  have h_G_bot_to_bot : [] ⊢ (Formula.all_future Formula.bot).imp Formula.bot := by
    -- Derive using: G ⊥ → ⊥ (temporal operator doesn't save us from contradiction)
    sorry  -- This is a simple derivation using temporal semantics

  -- Weaken and apply modus ponens to get ⊥ ∈ Gamma
  have h_L_G_sub : ∀ ψ ∈ L_G, ψ ∈ Gamma := by
    intro ψ h_mem
    simp [L_G] at h_mem
    obtain ⟨φ, h_in_L, rfl⟩ := h_mem
    exact h_G_list φ h_in_L

  have h_G_bot_in : Formula.all_future Formula.bot ∈ Gamma :=
    set_mcs_closed_under_derivation h_mcs L_G h_L_G_sub d_G_bot

  -- From G ⊥ ∈ Gamma, derive ⊥ ∈ Gamma using closure and G ⊥ → ⊥
  have d_bot_final : DerivationTree [Formula.all_future Formula.bot] Formula.bot := by
    apply DerivationTree.modus_ponens
    · apply DerivationTree.weakening [] _ _ h_G_bot_to_bot
      intro; simp
    · apply DerivationTree.assumption
      simp

  have h_bot_in : Formula.bot ∈ Gamma :=
    set_mcs_closed_under_derivation h_mcs [Formula.all_future Formula.bot]
      (by intro; simp [h_G_bot_in]) d_bot_final

  -- Contradiction: ⊥ ∈ Gamma contradicts Gamma being consistent
  have h_bot_deriv : DerivationTree [Formula.bot] Formula.bot :=
    DerivationTree.assumption _ _ (by simp)
  exact h_mcs.1 [Formula.bot] (by simp [h_bot_in]) ⟨h_bot_deriv⟩
```

### Past Seed Consistency (Line 354)

The proof is **symmetric** to `future_seed_consistent`, using:
- **Temporal H distribution** (derivable from temporal duality applied to temp_k_dist)
- **Generalized H necessitation** (derivable from temporal duality applied to generalized G necessitation)
- Same proof pattern with H operators instead of G operators

**Complexity**: Once the future case is proven, the past case follows the same structure with operator substitution.

## Decisions

1. **Proof approach**: Implement generalized temporal necessitation first, then use it for seed consistency
2. **Theorem location**: Place `temporal_generalized_necessitation` in `Bimodal.Theorems.GeneralizedNecessitation` alongside the modal analog
3. **Proof method**: Induction on derivation tree height, following the modal template
4. **Past case strategy**: Derive via temporal duality applied to future case results

## Recommendations

### Phase 1: Prove Generalized Temporal Necessitation (Priority 1)

**Goal**: Prove `temporal_generalized_necessitation : Γ ⊢ φ → (G Γ) ⊢ G φ`

**Location**: `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`

**Effort**: 4-6 hours

**Steps**:
1. Define the theorem statement
2. Set up induction on derivation tree height (using `DerivationTree.height`)
3. Prove base cases (axiom, assumption)
4. Prove modus ponens case using temporal K distribution
5. Prove necessitation cases using Temporal 4 axiom
6. Prove weakening case
7. Verify with `lake build`

**Verification**: Test on simple examples like `[p] ⊢ q → (G p) ⊢ G q`

### Phase 2: Prove Future Seed Consistency (Priority 2)

**Goal**: Complete the sorry at line 338 in IndexedMCSFamily.lean

**Effort**: 3-4 hours

**Steps**:
1. Apply generalized temporal necessitation to the inconsistency derivation
2. Derive `G ⊥ → ⊥` (should be straightforward)
3. Use `set_mcs_closed_under_derivation` to show contradiction
4. Clean up and document the proof

**Dependencies**: Phase 1 must be complete

### Phase 3: Prove Past Seed Consistency (Priority 3)

**Goal**: Complete the sorry at line 354 in IndexedMCSFamily.lean

**Effort**: 2-3 hours

**Steps**:
1. Derive generalized H necessitation from temporal duality of Phase 1 result
2. Apply same proof pattern as Phase 2 with H operators
3. Verify symmetry with future case

**Dependencies**: Phase 2 should be complete for reference

### Phase 4: Integration and Testing (Priority 4)

**Goal**: Verify the full construction compiles and coherence properties hold

**Effort**: 1-2 hours

**Steps**:
1. Run `lake build` on IndexedMCSFamily.lean
2. Verify no new errors introduced
3. Check that `construct_indexed_family` compiles cleanly
4. Run any existing tests for the representation theorem

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generalized necessitation proof is harder than expected | High - blocks all phases | Medium | Follow modal template closely; consult Bimodal.Theorems.GeneralizedNecessitation for guidance |
| Temporal K distribution properties insufficient | High - may need additional axioms | Low | temp_k_dist is standard; should be sufficient. If not, review Axioms.lean for missing properties |
| Interaction with Temporal 4 axiom complex | Medium - may need helper lemmas | Medium | Use `set_mcs_all_future_all_future` from Completeness.lean as established infrastructure |
| Past case has subtle differences from future | Low - proof should be symmetric | Low | Document any asymmetries carefully; may need dual versions of helper lemmas |

## Appendix

### Related Theorems and Infrastructure

**Theorem**: `modal_generalized_necessitation` in Bimodal.Theorems.GeneralizedNecessitation
- **Purpose**: Template for temporal analog
- **Structure**: Induction on derivation tree with K distribution in modus ponens case

**Axiom**: `temp_4` (Temporal 4: G φ → GG φ) in Axioms.lean:218
- **Purpose**: Handle nested G operators in necessitation cases

**Theorem**: `set_mcs_all_future_all_future` in Completeness.lean:1055
- **Purpose**: MCS closure under Temporal 4
- **Usage**: Shows that GG φ ∈ S when G φ ∈ S

**Function**: `usedFormulas` in Completeness.lean:184
- **Purpose**: Extract formulas actually used in a derivation
- **Usage**: May be useful for constructing L_G from L

### Search Queries Used

- Local searches for `set_mcs_closed_under_derivation`, `set_mcs_all_future`, `distribution` (found relevant infrastructure)
- File patterns: `temp_k_dist`, `temporal K`, `Axiom.temp_k_dist` (found axiom definition)
- Reviewed Axioms.lean, Derivation.lean, Completeness.lean for infrastructure

### Estimated Total Effort

**Total**: 10-15 hours across 4 phases
- Phase 1 (Generalized Necessitation): 4-6 hours
- Phase 2 (Future Seed): 3-4 hours
- Phase 3 (Past Seed): 2-3 hours
- Phase 4 (Integration): 1-2 hours

**Complexity**: Medium-High. The proof requires:
- Deep understanding of modal logic K distribution
- Induction on derivation trees with well-founded recursion
- Careful manipulation of temporal operators
- Integration with existing MCS infrastructure

**Confidence**: High that this approach will work. The temporal K distribution axiom is specifically designed for this purpose, and the modal analog provides a proven template.

## References

- **Modal Logic Textbook**: Blackburn et al., "Modal Logic" - Chapter on K axiom and necessitation
- **Task 654 Review**: specs/reviews/review-20260121-task654.md - Context on indexed MCS approach
- **Axioms Documentation**: Theories/Bimodal/ProofSystem/Axioms.lean - TM axiom system
- **Completeness Infrastructure**: Theories/Bimodal/Boneyard/Metalogic/Completeness.lean - MCS properties
- **Generalized Necessitation**: Theories/Bimodal/Theorems/GeneralizedNecessitation.lean - Modal template
