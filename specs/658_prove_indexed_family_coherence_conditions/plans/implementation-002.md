# Implementation Plan: Task #658 (Revised)

- **Task**: 658 - Prove indexed family coherence conditions
- **Version**: 002 (Complete Revision)
- **Status**: [IMPLEMENTING]
- **Effort**: 12-16 hours
- **Priority**: High (upgraded from Medium due to scope)
- **Dependencies**: None (self-contained after revision)
- **Research Inputs**:
  - specs/658_prove_indexed_family_coherence_conditions/reports/research-003.md (T axiom impact analysis)
  - specs/700_research_algebraic_representation_theorem_proof/reports/research-002.md (reflexive operator analysis)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Complete Revision**: The original plan (implementation-001.md) was blocked by a fundamental construction issue: independent Lindenbaum extensions cannot be proven coherent without the T axioms. Research-003.md confirmed that adding T axioms makes coherence trivial.

**New Approach**: Systematically switch to reflexive tense operators throughout the Bimodal/ theory by:
1. Making semantic clauses for G/H reflexive (change `<` to `≤`)
2. Adding temporal T axioms (`Gφ → φ`, `Hφ → φ`)
3. Updating soundness proofs
4. Completing coherence proofs (now trivial)

### Why This Works

With T axioms, the coherence conditions become direct consequences:
- **forward_G**: `Gφ ∈ mcs(t) → φ ∈ mcs(t')` for `t < t'`
  - By T4: `Gφ → GGφ`, so `GGφ ∈ mcs(t)`
  - `Gφ` propagates to `mcs(t')` via seed
  - By T axiom at t': `Gφ → φ`, so `φ ∈ mcs(t')`

- **backward_G**: `Gφ ∈ mcs(t') → φ ∈ mcs(t)` for `t' < t`
  - `Gφ ∈ mcs(t')` means φ at all times ≥ t'
  - Since t > t', φ ∈ mcs(t) directly by reflexive semantics

### Semantic Shift

| Operator | Before (Irreflexive) | After (Reflexive) |
|----------|---------------------|-------------------|
| G (all_future) | ∀s, t < s → φ(s) | ∀s, t ≤ s → φ(s) |
| H (all_past) | ∀s, s < t → φ(s) | ∀s, s ≤ t → φ(s) |
| Meaning | "strictly future/past" | "now and future/past" |

## Goals & Non-Goals

**Goals**:
- Add temporal T axioms for G and H
- Change semantic clauses from `<` to `≤` for temporal operators
- Update soundness proofs for new axioms
- Complete all four coherence condition proofs
- Ensure full `lake build` passes

**Non-Goals**:
- Maintaining backward compatibility with irreflexive semantics
- Changing modal operators (□, ◇ remain unchanged)
- Algebraic approach (future work per Task 700)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Existing proofs break from semantic change | Medium | High | Phase 3 dedicated to fixing soundness; small # of files affected |
| TimeShift theorems need adjustment | Medium | Medium | Review in Phase 3; changes should be minimal |
| F/P (sometime operators) become redundant | Low | Medium | Document equivalence; keep for expressivity |
| Downstream users expect irreflexive | Low | Low | Document design choice in module docstrings |

## Implementation Phases

### Phase 1: Add Temporal T Axioms [COMPLETED]

**Goal**: Add `temp_t_future` and `temp_t_past` axiom constructors

**File**: `Theories/Bimodal/ProofSystem/Axioms.lean`

**Tasks**:
- [ ] Add `temp_t_future` constructor: `Axiom ((Formula.all_future φ).imp φ)`
- [ ] Add `temp_t_past` constructor: `Axiom ((Formula.all_past φ).imp φ)`
- [ ] Update module docstring to document 15 axioms (was 13)
- [ ] Update axiom list in header comment
- [ ] Add docstrings explaining reflexive temporal semantics
- [ ] Verify `lake build Bimodal.ProofSystem.Axioms` succeeds

**New Code** (approximate):
```lean
/--
Temporal T axiom for future: `Gφ → φ` (temporal reflexivity).

If something will always be true (from now), it is true now.
This makes G reflexive: G includes the present moment.
Semantically: if φ holds at all times s ≥ t, then φ holds at t.
-/
| temp_t_future (φ : Formula) : Axiom ((Formula.all_future φ).imp φ)

/--
Temporal T axiom for past: `Hφ → φ` (temporal reflexivity).

If something has always been true (until now), it is true now.
This makes H reflexive: H includes the present moment.
Semantically: if φ holds at all times s ≤ t, then φ holds at t.
-/
| temp_t_past (φ : Formula) : Axiom ((Formula.all_past φ).imp φ)
```

**Timing**: 1 hour

**Verification**:
- `lean_diagnostic_messages` shows no errors
- `lake build` for Axioms.lean succeeds

---

### Phase 2: Update Semantic Clauses [COMPLETED]

**Goal**: Change G/H semantics from strict (`<`) to reflexive (`≤`)

**File**: `Theories/Bimodal/Semantics/Truth.lean`

**Tasks**:
- [ ] Change `all_past` clause: `s < t` → `s ≤ t`
- [ ] Change `all_future` clause: `t < s` → `t ≤ s`
- [ ] Update module docstring to document reflexive semantics
- [ ] Update `truth_at_all_past` lemma (line ~192)
- [ ] Update `truth_at_all_future` lemma (line ~204)
- [ ] Verify `lake build Bimodal.Semantics.Truth` succeeds

**Changes** (lines 109-110):
```lean
-- Before:
| Formula.all_past φ => ∀ (s : D), s < t → truth_at M τ s φ
| Formula.all_future φ => ∀ (s : D), t < s → truth_at M τ s φ

-- After:
| Formula.all_past φ => ∀ (s : D), s ≤ t → truth_at M τ s φ
| Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M τ s φ
```

**Timing**: 1 hour

**Verification**:
- `lean_diagnostic_messages` shows errors in downstream files (expected)
- Note which files need updating in Phase 3

---

### Phase 3: Fix Soundness and Dependent Proofs [COMPLETED]

**Goal**: Update all proofs broken by semantic change

**Files to Check**:
- `Theories/Bimodal/Metalogic/Soundness.lean` - Main soundness theorem
- `Theories/Bimodal/Semantics/TimeShift.lean` - Time shift preservation
- `Theories/Bimodal/Semantics/Validity.lean` - Validity definitions
- `Theories/Bimodal/Theorems/Perpetuity/*.lean` - Perpetuity theorems

**Tasks**:
- [ ] Run `lake build` to identify all broken files
- [ ] List all compilation errors
- [ ] Fix soundness proofs for existing temporal axioms (T4, TK, TA, TL)
- [ ] Add soundness proofs for new T axioms (temp_t_future, temp_t_past)
- [ ] Fix TimeShift theorems if affected
- [ ] Fix any other affected files
- [ ] Verify full `lake build Bimodal` succeeds (except known sorries)

**Key Soundness Proofs Needed**:
```lean
-- temp_t_future soundness
theorem temp_t_future_valid (φ : Formula) : ⊨ (Formula.all_future φ).imp φ := by
  intro D _ _ _ F M τ t
  intro h_all_future
  -- h_all_future : ∀ s, t ≤ s → truth_at M τ s φ
  -- Need: truth_at M τ t φ
  exact h_all_future t (le_refl t)  -- t ≤ t

-- temp_t_past soundness (symmetric)
theorem temp_t_past_valid (φ : Formula) : ⊨ (Formula.all_past φ).imp φ := by
  intro D _ _ _ F M τ t
  intro h_all_past
  exact h_all_past t (le_refl t)  -- t ≤ t
```

**Timing**: 4-6 hours (main effort phase)

**Verification**:
- `lake build` completes with only known/documented sorries
- `lean_diagnostic_messages` on modified files shows no new errors

---

### Phase 4: Complete Coherence Proofs [PARTIAL]

**Goal**: Prove the four coherence conditions (now trivial with T axioms)

**File**: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`

**Tasks**:
- [ ] Update module docstring to reflect reflexive semantics
- [ ] Prove `forward_G` (line ~550)
- [ ] Prove `backward_H` (line ~583)
- [ ] Prove `forward_H` (line ~600)
- [ ] Prove `backward_G` (line ~626)
- [ ] Remove obsolete blocking comments
- [ ] Verify all four sorries eliminated

**Proof Sketches**:

**forward_G** (`Gφ ∈ mcs(t) → φ ∈ mcs(t')` for `t < t'`):
```lean
intro t t' φ hlt hG
-- Get Gφ → GGφ from T4 axiom and apply to hG
have h_GG := mcs_closed_axiom (Axiom.temp_4 φ) hG
-- GGφ means Gφ propagates to future seeds
have h_G_at_t' := seed_propagation h_GG hlt
-- Apply T axiom: Gφ → φ at t'
exact mcs_closed_axiom (Axiom.temp_t_future φ) h_G_at_t'
```

**backward_G** (`Gφ ∈ mcs(t') → φ ∈ mcs(t)` for `t' < t`):
```lean
intro t t' φ hlt hG
-- With reflexive semantics: Gφ at t' means φ at all s ≥ t'
-- Since t > t', we need φ at t
-- Use seed propagation: Gφ at t' puts Gφ in future seed
-- Then at t, use T axiom
have h_G_at_t := seed_propagation_reverse hG hlt
exact mcs_closed_axiom (Axiom.temp_t_future φ) h_G_at_t
```

**forward_H** and **backward_H**: Symmetric using `temp_t_past`

**Timing**: 2-3 hours

**Verification**:
- All four coherence sorries replaced with complete proofs
- `lake build` for IndexedMCSFamily.lean succeeds
- `#check construct_indexed_family` compiles without sorry warnings

---

### Phase 5: Update Documentation and Module Docstrings [NOT STARTED]

**Goal**: Document the reflexive semantics design choice throughout

**Files**:
- `Theories/Bimodal/ProofSystem/Axioms.lean` - Main axiom documentation
- `Theories/Bimodal/Semantics/Truth.lean` - Semantic clause documentation
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Coherence documentation

**Tasks**:
- [ ] Update Axioms.lean header to mention reflexive temporal operators
- [ ] Update Truth.lean header to explain reflexive G/H
- [ ] Update IndexedMCSFamily.lean to remove blocking analysis comments
- [ ] Add note about algebraic benefits (ClosureOperator compatibility)
- [ ] Document equivalence: `Gφ ↔ φ ∧ G_strict φ` for readers familiar with irreflexive

**Timing**: 1-2 hours

**Verification**:
- Documentation accurately reflects implementation
- No misleading references to "irreflexive" operators remain

---

## Testing & Validation

- [ ] Phase 1: `lake build Bimodal.ProofSystem.Axioms` succeeds
- [ ] Phase 2: Semantic changes compile (downstream errors expected)
- [ ] Phase 3: Full `lake build Bimodal` succeeds
- [ ] Phase 4: All four coherence sorries eliminated
- [ ] Phase 5: Documentation consistent with implementation
- [ ] Final: `lake build` completes for entire project

## Artifacts & Outputs

- plans/implementation-002.md (this plan)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- Modified files:
  - `Theories/Bimodal/ProofSystem/Axioms.lean` - New T axioms
  - `Theories/Bimodal/Semantics/Truth.lean` - Reflexive semantics
  - `Theories/Bimodal/Metalogic/Soundness.lean` - New soundness proofs
  - `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Coherence proofs
  - Possibly others identified in Phase 3

## Rollback/Contingency

- **Git branch**: Create `feature/reflexive-temporal-operators` before starting
- **Partial progress**: Each phase can be committed independently
- **If Phase 3 has unexpected scope**:
  - Option A: Focus on critical path only (Soundness + IndexedMCSFamily)
  - Option B: Create follow-up task for non-critical fixes
- **If coherence still fails**: Review T axiom application pattern; research algebraic approach as backup

## Previous Plan Analysis

**implementation-001.md Status**: BLOCKED

**What Failed**:
- Independent Lindenbaum extensions cannot be coordinated
- No local constraint connecting `Gφ` to `φ` without T axiom
- Contrapositive approaches led to circularity

**What This Plan Changes**:
- Adds T axioms to provide local constraint
- Changes semantics to match (reflexive operators)
- Proof strategy shifts from complex case analysis to direct axiom application

**Effort Comparison**:
- Old plan: 10 hours estimated, blocked after ~3 hours
- New plan: 12-16 hours estimated, clear path to completion
