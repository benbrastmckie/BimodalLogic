# Implementation Plan: Task #657

- **Task**: 657 - Prove seed consistency (temporal K distribution)
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Priority**: Medium
- **Dependencies**: Task 654 (completed)
- **Research Inputs**: specs/657_prove_seed_consistency_temporal_k_distribution/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes two sorry proofs in `IndexedMCSFamily.lean` (lines 339 and 355) that establish seed set consistency using the temporal K distribution axiom. The proofs require showing that if a seed set were inconsistent, the root MCS would be inconsistent via propagation through temporal operators. The key insight is that `generalized_temporal_k` (already proven in `GeneralizedNecessitation.lean`) provides the necessary theorem `Gamma |- phi implies (G Gamma) |- G phi`, and temporal duality allows deriving the past case from the future case.

### Research Integration

The research report identified:
- `generalized_temporal_k` in `Bimodal.Theorems.GeneralizedNecessitation` is already proven
- `set_mcs_closed_under_derivation` provides MCS deductive closure
- `temporal_duality` rule enables deriving H-variants from G-variants
- No separate `past_k_dist` axiom exists; past proofs use temporal duality

## Goals & Non-Goals

**Goals**:
- Complete `future_seed_consistent` proof at line 339
- Complete `past_seed_consistent` proof at line 355
- Verify full IndexedMCSFamily.lean compiles without errors
- Document proof strategy in code comments

**Non-Goals**:
- Adding new axioms to the proof system (temporal duality suffices)
- Modifying the seed construction definitions
- Proving properties beyond what the sorries require

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Import issues with GeneralizedNecessitation | High | Medium | Verify import compiles first; may need to add import statement |
| Type mismatches between List/Set contexts | Medium | Medium | Carefully bridge List-based DerivationTree with Set-based MCS membership |
| Temporal duality application complexity for past case | Medium | Low | The swap_temporal function is well-defined; follow the involution property |
| G bot -> bot derivation complexity | Low | Low | This is straightforward from axiom temp_t or semantic reasoning |

## Implementation Phases

### Phase 1: Verify Infrastructure and Add Import [NOT STARTED]

**Goal**: Ensure all required infrastructure is accessible in IndexedMCSFamily.lean

**Tasks**:
- [ ] Add import for `Bimodal.Theorems.GeneralizedNecessitation`
- [ ] Verify `generalized_temporal_k` is accessible
- [ ] Check that `set_mcs_closed_under_derivation` signature matches expected usage
- [ ] Run `lake build` to verify imports compile

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - add import

**Verification**:
- `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` succeeds
- `#check generalized_temporal_k` works in the file

---

### Phase 2: Prove Helper Lemma for G bot Contradiction [NOT STARTED]

**Goal**: Establish that `G bot` in an MCS leads to contradiction

**Tasks**:
- [ ] Prove or find lemma: `G bot -> bot` is derivable (should follow from semantic considerations or be straightforward)
- [ ] Alternatively, show that `G bot in Gamma` contradicts Gamma being consistent
- [ ] If needed, add helper lemma to a local section

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - add helper lemma if needed

**Verification**:
- Helper lemma compiles without errors
- Lean goal states show expected types

---

### Phase 3: Complete future_seed_consistent Proof [NOT STARTED]

**Goal**: Replace sorry at line 339 with complete proof

**Tasks**:
- [ ] Extract list L of formulas from inconsistency assumption
- [ ] Construct mapped list L_G = L.map Formula.all_future
- [ ] Apply `generalized_temporal_k` to get derivation of G bot from L_G
- [ ] Show all elements of L_G are in Gamma (via seed definition and hL)
- [ ] Use `set_mcs_closed_under_derivation` to show G bot in Gamma
- [ ] Derive contradiction using MCS consistency

**Timing**: 3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - lines 323-339

**Proof outline**:
```lean
-- Given: d_bot : DerivationTree L Formula.bot where L ⊆ future_seed
-- Step 1: Apply generalized_temporal_k to d_bot
let L_G := L.map Formula.all_future
have d_G_bot : L_G ⊢ Formula.all_future Formula.bot :=
  generalized_temporal_k L Formula.bot d_bot
-- Step 2: Show L_G ⊆ Gamma (each G phi in Gamma by seed definition)
-- Step 3: By MCS closure, Formula.all_future Formula.bot ∈ Gamma
-- Step 4: G bot implies inconsistency, contradiction with h_mcs
```

**Verification**:
- Line 339 no longer has sorry
- `lean_diagnostic_messages` shows no errors at that location

---

### Phase 4: Complete past_seed_consistent Proof [NOT STARTED]

**Goal**: Replace sorry at line 355 with complete proof

**Tasks**:
- [ ] Leverage temporal duality to derive H-analog of generalized_temporal_k
- [ ] Alternatively, prove directly following the same pattern as future case
- [ ] Extract list L and construct L_H = L.map Formula.all_past
- [ ] Show all elements of L_H are in Gamma
- [ ] Use MCS closure to derive H bot in Gamma
- [ ] Derive contradiction

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - lines 346-355

**Approach options**:
1. **Direct proof**: Mirror future_seed_consistent proof structure, but need to verify that generalized_temporal_k can be adapted for H (may need to derive `generalized_temporal_h` via temporal duality)
2. **Via temporal duality**: Show that the past seed proof reduces to the future seed proof via swap_temporal involution

**Verification**:
- Line 355 no longer has sorry
- `lean_diagnostic_messages` shows no errors at that location

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Ensure full file and dependent files compile cleanly

**Tasks**:
- [ ] Run full `lake build` on the project
- [ ] Verify `IndexedMCSFamily.lean` has no remaining sorries
- [ ] Check that `time_seed_consistent` (which calls both lemmas) compiles
- [ ] Verify `construct_indexed_family` compiles cleanly
- [ ] Add/update docstrings on proven lemmas
- [ ] Remove any temporary helper comments

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - cleanup and documentation

**Verification**:
- `lake build` succeeds with no errors
- `#check construct_indexed_family` shows no sorry-dependent warnings
- `grep -n "sorry" IndexedMCSFamily.lean` returns only expected sorries (if any remain elsewhere)

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` succeeds
- [ ] `lean_diagnostic_messages` shows no errors at lines 339 and 355
- [ ] Full project `lake build` completes without errors
- [ ] The lemmas `future_seed_consistent` and `past_seed_consistent` can be `#check`ed
- [ ] `time_seed_consistent` (which depends on both) compiles without sorry

## Artifacts & Outputs

- `specs/657_prove_seed_consistency_temporal_k_distribution/plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- `specs/657_prove_seed_consistency_temporal_k_distribution/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If proofs become unexpectedly complex:
1. Preserve working partial proofs with `sorry` only in final steps
2. Document exactly what infrastructure is missing
3. If `generalized_temporal_h` is needed but complex, create a separate task for it
4. If G bot -> bot is hard to derive, check if there's an existing theorem or axiom

The current approach (using existing `generalized_temporal_k`) should minimize risk since the key theorem is already proven. The main complexity is in correctly bridging the List/Set contexts and applying MCS closure.
