# Implementation Plan: Task #557

- **Task**: 557 - MCS Property Completion
- **Version**: 002
- **Status**: [COMPLETED]
- **Effort**: 2-3 hours
- **Priority**: High
- **Dependencies**: None (building on existing infrastructure in MaximalConsistent.lean)
- **Research Inputs**: specs/557_mcs_property_completion/reports/research-001.md
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task completes two critical `sorry` placeholders in `Metalogic_v2/Representation/CanonicalModel.lean`: `mcs_contains_or_neg` (line 192) and `mcs_modus_ponens` (line 209). Both theorems are essential for the Truth Lemma and the completeness proof. The proofs require bridging between set-based consistency (`SetMaximalConsistent`) and list-based derivation infrastructure (`Consistent`, `DerivationTree`). The existing lemmas in `Metalogic_v2/Core/MaximalConsistent.lean` (`derives_neg_from_inconsistent_extension`, `derives_bot_from_phi_neg_phi`, `set_mcs_finite_subset_consistent`) provide the necessary foundation.

### Research Integration

From research-001.md:
- Both proofs use the pattern: extract witness from `SetConsistent` failure, apply deduction theorem lemmas
- Key lemmas already proven: `derives_neg_from_inconsistent_extension`, `derives_bot_from_phi_neg_phi`
- Bridge needed: `SetConsistent` (set-based) to `Consistent` (list-based)
- Mathlib pattern confirms approach: `FirstOrder.Language.Theory.IsMaximal.mem_or_not_mem`

### Reference Material: Metalogic/ Directory

**IMPORTANT**: The older `Theories/Bimodal/Metalogic/` directory contains parallel development that can serve as **inspiration** for proof strategies. However:

1. **Do NOT import from Metalogic/**: The Metalogic_v2 directory must remain independent
2. **Do NOT copy code directly**: Adapt patterns to Metalogic_v2's organization and infrastructure
3. **Metalogic/ will eventually be deleted**: All new development belongs in Metalogic_v2
4. **Use as reference only**: Examine proof strategies, lemma structures, and approaches

Key reference files in `Metalogic/`:
- `Metalogic/Representation/CanonicalModel.lean` - Has same `sorry` placeholders (lines 307, 317) but may have useful partial proof structure
- `Metalogic/Core/Basic.lean` - Similar consistency definitions
- `Metalogic/DeductionTheorem.lean` - May have helper patterns

**Metalogic_v2 advantages to preserve**:
- Cleaner separation of Core/ (consistency theory) and Representation/ (canonical model)
- More complete `MaximalConsistent.lean` with `derives_neg_from_inconsistent_extension` already proven
- Independent from any eventual Metalogic/ cleanup/deletion

## Goals & Non-Goals

**Goals**:
- Prove `mcs_contains_or_neg`: For MCS S, either φ ∈ S or ¬φ ∈ S
- Prove `mcs_modus_ponens`: For MCS S, if (φ → ψ) ∈ S and φ ∈ S, then ψ ∈ S
- Eliminate both `sorry` placeholders in CanonicalModel.lean
- Unblock downstream tasks 558, 559 (semantic satisfiability bridge, strong completeness helpers)

**Non-Goals**:
- Importing or depending on Metalogic/ code
- Modifying the MaximalConsistent.lean infrastructure
- Proving additional MCS properties beyond these two
- Refactoring the canonical model definitions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Witness extraction from SetConsistent may be complex | Medium | Medium | Add explicit helper lemma if inline reasoning is unwieldy |
| Type coercion between set/list memberships | Low | Medium | Use existing membership lemmas carefully, check with lean_hover_info |
| Derivation tree construction may be intricate | Medium | Low | Use lean_multi_attempt to test tactics systematically |
| Temptation to import from Metalogic/ | High | Low | Strict discipline: only read Metalogic/ for inspiration, never import |

## Implementation Phases

### Phase 1: Analyze Goal States and Review Reference Material [COMPLETED]

**Goal**: Understand exact goal states, confirm available lemmas, and review Metalogic/ for proof patterns

**Tasks**:
- [ ] Use `lean_goal` at line 192 (mcs_contains_or_neg sorry) to capture exact goal state
- [ ] Use `lean_goal` at line 209 (mcs_modus_ponens sorry) to capture exact goal state
- [ ] Use `lean_hover_info` on `SetConsistent`, `SetMaximalConsistent`, `Consistent` to confirm types
- [ ] Verify `derives_neg_from_inconsistent_extension` and `derives_bot_from_phi_neg_phi` signatures in Metalogic_v2
- [ ] **Reference check**: Read `Metalogic/Representation/CanonicalModel.lean` lines 294-318 to see proof structure (for inspiration only)
- [ ] **Reference check**: Note any helper lemmas in Metalogic/ that might suggest patterns for Metalogic_v2

**Timing**: 25 minutes

**Files to examine**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 174-210
- `Theories/Bimodal/Metalogic_v2/Core/MaximalConsistent.lean` - helper lemmas
- `Theories/Bimodal/Metalogic/Representation/CanonicalModel.lean` - **reference only** for proof patterns

**Verification**:
- Goal states documented for both sorries
- Helper lemma signatures confirmed
- Metalogic/ patterns noted (not imported)

---

### Phase 2: Prove mcs_contains_or_neg [COMPLETED]

**Goal**: Complete the proof that MCS contains φ or its negation

**Approach**: The proof requires showing that if neither φ nor ¬φ is in S, we reach a contradiction with S being maximal consistent. The key insight from research is:

1. If φ ∉ S, then `insert φ S` is inconsistent (by maximality)
2. If ¬φ ∉ S, then `insert ¬φ S` is inconsistent (by maximality)
3. From inconsistency of `insert φ S`, extract a derivation of ¬φ from finite subset of S
4. From inconsistency of `insert ¬φ S`, extract a derivation of ¬¬φ from finite subset of S
5. Apply double negation elimination to get φ derivable from S
6. Combine φ and ¬φ derivations to get ⊥, contradicting SetConsistent S

**Tasks**:
- [ ] Understand the goal state at line 192: need to derive False from h_incons_phi, h_incons_neg, and S being maximal consistent
- [ ] The negation of `SetConsistent (insert φ S)` gives us: ∃ L, (∀ ψ ∈ L, ψ ∈ insert φ S) ∧ ¬Consistent L
- [ ] Apply `derives_neg_from_inconsistent_extension` pattern to get derivation of ¬φ from some finite context from S
- [ ] Similarly for `h_incons_neg` to get derivation of ¬¬φ from S
- [ ] Use double negation elimination (`double_negation` from Propositional.lean) to get derivation of φ
- [ ] Combine φ and ¬φ derivations using `derives_bot_from_phi_neg_phi`
- [ ] Show this contradicts `SetConsistent S` to complete proof
- [ ] Run `lean_diagnostic_messages` to verify no errors

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 174-192

**Key Infrastructure from Metalogic_v2/Core/MaximalConsistent.lean**:
```lean
-- Already proven and available:
lemma derives_neg_from_inconsistent_extension {Γ : Context} {φ : Formula}
    (h_incons : ¬Consistent (φ :: Γ)) :
    Nonempty (DerivationTree Γ (Formula.neg φ))

def derives_bot_from_phi_neg_phi {Γ : Context} {φ : Formula}
    (h_phi : DerivationTree Γ φ)
    (h_neg : DerivationTree Γ (Formula.neg φ)) :
    DerivationTree Γ Formula.bot

lemma set_mcs_finite_subset_consistent {S : Set Formula}
    (h_mcs : SetMaximalConsistent S) (L : List Formula) (h_sub : ∀ φ ∈ L, φ ∈ S) :
    Consistent L
```

**Proof Strategy**:
```
-- Goal: False (from neither φ nor neg φ in S)
-- Have: h_incons_phi : ¬SetConsistent (insert φ S)
-- Have: h_incons_neg : ¬SetConsistent (insert (neg φ) S)

-- Step 1: Unfold ¬SetConsistent to get witness
-- ¬SetConsistent (insert φ S) means:
-- ∃ L, (∀ ψ ∈ L, ψ ∈ insert φ S) ∧ ¬Consistent L

-- Step 2: From this witness, need to extract a derivation of ¬φ from elements of S
-- This is the bridge from set-based to list-based

-- Step 3: Similarly get derivation of ¬¬φ from S

-- Step 4: Apply DNE to get φ derivable

-- Step 5: Combine via derives_bot_from_phi_neg_phi

-- Step 6: This shows some finite subset of S is inconsistent, contradiction
```

**Bridge Lemma (may need to add)**:
If the above strategy requires an intermediate lemma, consider adding to CanonicalModel.lean:
```lean
lemma set_inconsistent_implies_neg_derivable {S : Set Formula} {φ : Formula}
    (h_incons : ¬SetConsistent (insert φ S)) :
    ∃ L : List Formula, (∀ ψ ∈ L, ψ ∈ S) ∧ Nonempty (DerivationTree L (Formula.neg φ))
```

**Verification**:
- `lean_diagnostic_messages` shows no errors for mcs_contains_or_neg
- `lean_goal` at line 192 shows "no goals" (proof complete)

---

### Phase 3: Prove mcs_modus_ponens [COMPLETED]

**Goal**: Complete the modus ponens closure property for MCS

**Approach**: This proof is simpler because `mcs_contains_or_neg` does the heavy lifting. The structure is:
1. Assume ψ ∉ S
2. By `mcs_contains_or_neg`, since ψ ∉ S, we have ¬ψ ∈ S
3. Now we have φ ∈ S, (φ → ψ) ∈ S, and ¬ψ ∈ S
4. Consider the finite list L = [φ, φ.imp ψ, ψ.neg]
5. Build derivation: from φ and φ → ψ get ψ; from ψ and ¬ψ get ⊥
6. This shows L is inconsistent, but all elements are in S, contradicting SetConsistent

**Tasks**:
- [ ] The proof already has `h_neg : ψ.neg ∈ S` from the case split using `mcs_contains_or_neg`
- [ ] Construct explicit finite list L = [φ, φ.imp ψ, ψ.neg] where all elements are in S
- [ ] Build derivation of ψ from L using modus ponens: assumption(φ), assumption(φ → ψ), MP
- [ ] Build derivation of ¬ψ from L using assumption
- [ ] Apply `derives_bot_from_phi_neg_phi` to derive ⊥ from L
- [ ] Show L witnesses inconsistency of S, contradicting SetMaximalConsistent
- [ ] Run `lean_diagnostic_messages` to verify no errors

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - lines 197-209

**Proof Strategy**:
```lean
-- Goal: False
-- Have: h_imp : (φ.imp ψ) ∈ S
-- Have: h_ant : φ ∈ S
-- Have: h_neg : (ψ.neg) ∈ S  -- from mcs_contains_or_neg

-- Step 1: Define L = [φ, φ.imp ψ, ψ.neg]
-- All elements are in S by hypotheses.

-- Step 2: Build derivations:
-- d1 : L ⊢ φ       (by DerivationTree.assumption, since φ ∈ L)
-- d2 : L ⊢ φ → ψ   (by DerivationTree.assumption, since imp ∈ L)
-- d3 : L ⊢ ψ       (by DerivationTree.modus_ponens d2 d1)
-- d4 : L ⊢ ¬ψ      (by DerivationTree.assumption, since neg ∈ L)
-- d5 : L ⊢ ⊥       (by derives_bot_from_phi_neg_phi d3 d4)

-- Step 3: This shows ¬Consistent L

-- Step 4: But all elements of L are in S, and S is SetMaximalConsistent,
-- so S is SetConsistent, meaning all finite subsets should be Consistent.

-- Step 5: Apply set_mcs_finite_subset_consistent to get Consistent L
-- This contradicts ¬Consistent L from Step 3.
```

**Verification**:
- `lean_diagnostic_messages` shows no errors for mcs_modus_ponens
- `lean_goal` at line 209 shows "no goals" (proof complete)

---

### Phase 4: Final Verification and Cleanup [COMPLETED]

**Goal**: Ensure both proofs are complete and no sorries remain

**Tasks**:
- [ ] Run `lean_diagnostic_messages` on entire CanonicalModel.lean
- [ ] Verify no `sorry` placeholders remain in file
- [ ] Check that downstream imports (TruthLemma.lean, etc.) have no new errors
- [ ] Run `lake build` to verify project compiles
- [ ] Document any additional lemmas added (if helper lemmas were needed)
- [ ] **Final check**: Verify no imports from Metalogic/ were added

**Timing**: 15 minutes

**Files to verify**:
- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - entire file
- `Theories/Bimodal/Metalogic_v2/TruthLemma.lean` - verify no new errors

**Verification**:
- Zero `sorry` placeholders in CanonicalModel.lean
- `lake build` succeeds without errors
- No regressions in dependent files
- No new imports from `Bimodal.Metalogic.*`

## Testing & Validation

- [ ] `lean_diagnostic_messages` on CanonicalModel.lean returns no errors
- [ ] `lean_goal` at former sorry locations shows "no goals"
- [ ] `lake build Bimodal.Metalogic_v2.Representation.CanonicalModel` succeeds
- [ ] Grep for `sorry` in CanonicalModel.lean returns zero matches
- [ ] `lake build` on full project succeeds
- [ ] Grep for `import Bimodal.Metalogic.` in CanonicalModel.lean returns zero matches

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean` - modified with complete proofs
- `specs/557_mcs_property_completion/plans/implementation-002.md` - this plan (revision)
- `specs/557_mcs_property_completion/summaries/implementation-summary-{DATE}.md` - completion summary

## Revision Notes (v002)

This revision adds explicit guidance about the relationship between Metalogic/ and Metalogic_v2/:

1. **Metalogic/ as reference**: The older directory can provide inspiration for proof strategies
2. **Independence mandate**: Metalogic_v2 must not import from Metalogic/
3. **Deletion path**: Metalogic/ will eventually be removed; all new work goes in Metalogic_v2
4. **Phase 1 expanded**: Now includes reference checks to Metalogic/ for pattern inspiration

## Rollback/Contingency

If proofs cannot be completed as designed:
1. Keep partial progress in the proof (intermediate lemmas, partial tactics)
2. Add detailed comments explaining the gap
3. If fundamentally blocked, consider adding helper lemmas to MaximalConsistent.lean
4. Worst case: document the blocking issue and mark task as BLOCKED with specific technical reason

The existing `sorry` placeholders allow the codebase to compile, so rollback simply means reverting to the original file state.
