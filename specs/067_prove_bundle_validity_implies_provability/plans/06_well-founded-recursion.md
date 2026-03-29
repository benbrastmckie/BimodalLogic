# Implementation Plan: Task 67 - Well-Founded Recursion with Fair Scheduling Backup

- **Task**: 67 - prove_bundle_validity_implies_provability
- **Status**: [NOT STARTED]
- **Effort**: 10-16 hours
- **Dependencies**: Phases 1-5 of Plan 05 (COMPLETED)
- **Research Inputs**: specs/067_prove_bundle_validity_implies_provability/reports/20_team-research.md
- **Artifacts**: plans/06_well-founded-recursion.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true
- **Previous Plans**: 05_extend-deferral-closure.md (Phases 1-5 complete, Phase 6 blocked on fuel exhaustion)

## Overview

This plan replaces the fuel-based termination in `restricted_bounded_witness_fueled` with proper well-founded recursion, eliminating the sorry in the fuel=0 branch. The approach uses a lexicographic measure on (F-nesting depth, position) that provably decreases at each recursive call.

If well-founded restructuring proves intractable, the backup approach is fair scheduling (dovetailing) which resolves ALL F-obligations round-robin, providing full family-level temporal coherence.

### Research Integration

From report 20_team-research.md:
- **Actual blocker**: The sorry in `restricted_bounded_witness_fueled` (SuccChainFMCS.lean:~2797) in the fuel=0 branch
- **Approach 2** (Primary): Well-founded recursion with lexicographic measure (most elegant)
- **Approach 3** (Backup): Fair scheduling / dovetailing (most mathematically correct)
- **Key insight**: `restricted_forward_chain_forward_F` is sorry-free and may already provide the infrastructure

## Goals & Non-Goals

**Goals**:
- Eliminate the sorry in `restricted_bounded_witness_fueled` via well-founded recursion
- Use lexicographic measure: `(closure_F_bound phi - f_nesting_depth theta, steps_taken)`
- Prove this measure strictly decreases at each recursive call
- Complete `bfmcs_from_mcs_temporally_coherent` using the sorry-free witness theorem
- Eliminate sorry in `bundle_validity_implies_provability`

**Non-Goals**:
- Redesigning the entire chain construction (we build on existing infrastructure)
- Implementing full dovetailing unless well-founded approach fails
- Dense completeness (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Well-founded termination proof complex | High | Medium | Backup: switch to fair scheduling |
| Lean's termination checker rejects measure | Medium | Low | Use `decreasing_by` with explicit proof |
| Existing lemmas don't compose cleanly | Medium | Medium | May need intermediate bridge lemmas |
| Fair scheduling requires major refactoring | High | Medium (if needed) | Only pursue if well-founded fails |

## Implementation Phases

### Phase 1: Analyze Current Recursion Structure [NOT STARTED]

**Goal**: Understand exactly how `restricted_bounded_witness_fueled` recurses and what measure would work

**Tasks**:
- [ ] Read `restricted_bounded_witness_fueled` (SuccChainFMCS.lean:2782-2867)
- [ ] Map out recursive call patterns:
  - Case 1: theta ∈ chain(k+1) → witness found (base case)
  - Case 2: F(iter_F n theta) ∈ chain(k+1) for some n → resolve at depth d' + (n-1)
  - Case 3: iter_F n theta ∉ chain(k+1) for all n ≤ B → F obligation deferred
- [ ] Identify the decreasing measure at each recursive call:
  - Case 2: d decreases (resolved obligation reduces nesting)
  - Case 3: k increases but d might stay same → need lexicographic ordering
- [ ] Document why fuel=0 is semantically unreachable (for backup proof)

**Files to read**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 2780-2870)
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` (`f_nesting_depth`, `closure_F_bound`)

**Timing**: 1-2 hours

**Verification**:
- Recursion structure documented
- Measure strategy identified

---

### Phase 2: Define Well-Founded Measure [NOT STARTED]

**Goal**: Create a well-founded relation on (depth, position) pairs

**Tasks**:
- [ ] Define the measure type:
  ```lean
  -- Lexicographic ordering on (remaining_depth, steps_remaining)
  def witnessSearchMeasure (phi : Formula) (theta : Formula) (k : Nat) : Nat × Nat :=
    (closure_F_bound phi - f_nesting_depth theta, closure_F_bound phi * closure_F_bound phi - k)
  ```
- [ ] Prove the measure is well-founded (uses `Prod.Lex` with `Nat.lt_wfRel`)
- [ ] Alternative: Use fuel as explicit measure parameter with proof it suffices:
  ```lean
  theorem fuel_suffices (phi theta : Formula) (k : Nat) :
    ∀ d ≤ f_nesting_depth (iter_F d theta),
    ∃ fuel, restricted_bounded_witness_fueled phi M0 k theta d fuel = witness
  ```

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 2-3 hours

**Verification**:
- Measure definition compiles
- Well-foundedness proof passes

---

### Phase 3: Restructure with WellFoundedRecursion [NOT STARTED]

**Goal**: Replace `restricted_bounded_witness_fueled` with well-founded recursive version

**Tasks**:
- [ ] Define new function using `WellFoundedRelation`:
  ```lean
  def restricted_bounded_witness_wf (phi : Formula)
      (M0 : DeferralRestrictedSerialMCS phi) (k : Nat) (theta : Formula) (d : Nat)
      (h_d_ge : d ≥ 1)
      (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
      (h_iter_not : iter_F d theta ∉ restricted_forward_chain phi M0 (k + 1)) :
      { m : Nat // m > k ∧ theta ∈ restricted_forward_chain phi M0 m } :=
    -- Recursive definition using witnessSearchMeasure
    ...
  termination_by witnessSearchMeasure phi theta k
  decreasing_by
    -- Explicit proof that measure decreases
    ...
  ```
- [ ] Prove `decreasing_by` for each recursive call:
  - Case 2 (resolved): f_nesting_depth decreases → first component decreases
  - Case 3 (deferred): k increases → second component decreases (first stays same)
- [ ] The key lemma needed:
  ```lean
  lemma resolved_depth_decreases (theta : Formula) (n d : Nat) (h : n > 0) :
    f_nesting_depth theta < f_nesting_depth (iter_F n theta)
  ```
- [ ] Update `restricted_bounded_witness` to call the new version

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Timing**: 4-5 hours

**Verification**:
- `restricted_bounded_witness_wf` compiles without sorry
- `lake build Bimodal.Metalogic.Bundle.SuccChainFMCS` passes

---

### Phase 4: Complete bfmcs_from_mcs_temporally_coherent [NOT STARTED]

**Goal**: Use sorry-free witness theorem to prove family-level coherence

**Tasks**:
- [ ] Locate `bfmcs_from_mcs_temporally_coherent` (Completeness.lean)
- [ ] The theorem needs to prove `forward_F`:
  ```lean
  ∀ k : Nat, ∀ psi : Formula,
    F(psi) ∈ fam.mcs(k) → ∃ k' > k, psi ∈ fam.mcs(k')
  ```
- [ ] Wire `restricted_forward_chain_forward_F` (sorry-free) to this requirement:
  - `restricted_forward_chain_forward_F` already proves F-witness existence
  - May need bridge lemma to connect `restricted_forward_chain` to `fam.mcs`
- [ ] Similarly complete `backward_P` using symmetric infrastructure
- [ ] Remove sorry from `bfmcs_from_mcs_temporally_coherent`

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Timing**: 2-3 hours

**Verification**:
- `bfmcs_from_mcs_temporally_coherent` compiles without sorry
- `lake build Bimodal.FrameConditions.Completeness` passes

---

### Phase 5: Complete bundle_validity_implies_provability [NOT STARTED]

**Goal**: Wire sorry-free family coherence into main completeness theorem

**Tasks**:
- [ ] With `bfmcs_from_mcs_temporally_coherent` sorry-free, the proof structure from Plan 05 Phase 6 should complete:
  1. not_provable_implies_neg_consistent (sorry-free)
  2. neg_consistent_gives_mcs_without_phi (sorry-free)
  3. construct_bfmcs_bundle + bundle_to_bfmcs (sorry-free)
  4. bfmcs_from_mcs_temporally_coherent (NOW sorry-free)
  5. construct_bfmcs_bundle_eval_at_zero (sorry-free)
  6. Truth lemma and contradiction (sorry-free)
- [ ] Remove sorry from `bundle_validity_implies_provability`
- [ ] Verify `#print axioms bundle_validity_implies_provability` shows no sorryAx

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Timing**: 1-2 hours

**Verification**:
- `bundle_validity_implies_provability` compiles without sorry
- `#print axioms bundle_validity_implies_provability` shows no sorryAx

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Full build verification and documentation

**Tasks**:
- [ ] Run `lake build` for complete build
- [ ] Verify sorry elimination:
  ```bash
  grep -r "sorry" Theories/Bimodal/FrameConditions/Completeness.lean
  # Should only show dense_completeness_fc (separate concern)
  ```
- [ ] Run axiom check: `#print axioms completeness_over_Int`
- [ ] Update docstrings explaining the well-founded measure
- [ ] Remove deprecated fuel-based version if not used elsewhere
- [ ] Create implementation summary

**Files to modify**:
- Documentation updates across modified files

**Timing**: 1 hour

**Verification**:
- Full `lake build` passes
- Axiom check shows no sorryAx in completeness theorems

---

## Backup Plan: Fair Scheduling (Phases B1-B3)

If Phases 2-3 prove intractable (well-founded termination proof too complex), switch to fair scheduling.

### Phase B1: Define Fair Scheduling Enumeration [CONTINGENCY]

**Goal**: Create round-robin enumeration of F-obligations

**Tasks**:
- [ ] Define obligation enumeration using `Nat.pair`/`Nat.unpair`:
  ```lean
  def enumerateObligations (M0 : SetMaximalConsistent) : Nat → Option Formula
    -- Returns the n-th F-obligation from M0's F-formulas (using Finset.toList ordering)
  ```
- [ ] Define `resolvedSet : Nat → Finset Formula` tracking resolved obligations
- [ ] At step n: resolve `enumerateObligations M0 n` if not already resolved

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 3-4 hours

---

### Phase B2: Replace omega_chain_forward with Dovetailing [CONTINGENCY]

**Goal**: New chain construction that resolves ALL obligations fairly

**Tasks**:
- [ ] Define `omega_chain_dovetailed`:
  ```lean
  def omega_chain_dovetailed (M0 : SetMaximalConsistent) : Nat → Set Formula
    | 0 => M0
    | n + 1 =>
        let current := omega_chain_dovetailed M0 n
        let obligation := enumerateObligations M0 n
        -- Resolve obligation if present, otherwise extend via F_top
  ```
- [ ] Prove G-theory and box-class preservation
- [ ] Prove every F-obligation eventually resolved (fairness)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`

**Timing**: 4-6 hours

---

### Phase B3: Wire Dovetailed Chain to Completeness [CONTINGENCY]

**Goal**: Replace restricted chain with dovetailed version

**Tasks**:
- [ ] Update `Z_chain_forward_F` to use dovetailed construction
- [ ] Prove `forward_F` for dovetailed chain (follows from fairness)
- [ ] Wire to `bfmcs_from_mcs_temporally_coherent`

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Timing**: 2-3 hours

---

## Decision Points

| Checkpoint | Condition | Action |
|------------|-----------|--------|
| After Phase 2 | Measure well-founded proof > 4 hours | Consider switching to backup |
| After Phase 3 | Lean rejects termination proof | Switch to backup (Phases B1-B3) |
| Phase 3 complete | Well-founded version works | Continue with Phases 4-6 |

## Testing & Validation

- [ ] Phase 1: Recursion structure fully documented
- [ ] Phase 2: Measure definition compiles, well-foundedness proved
- [ ] Phase 3: `restricted_bounded_witness_wf` sorry-free
- [ ] Phase 4: `bfmcs_from_mcs_temporally_coherent` sorry-free
- [ ] Phase 5: `bundle_validity_implies_provability` sorry-free
- [ ] Phase 6: Full build passes, no sorryAx in completeness

## Artifacts & Outputs

- `plans/06_well-founded-recursion.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- `summaries/06_completeness-final-summary.md` (post-implementation)

## Technical Notes

### Well-Founded Recursion in Lean 4

Lean 4's `termination_by` and `decreasing_by` provide two approaches:
1. **Implicit termination**: Specify a measure; Lean proves it decreases
2. **Explicit termination**: Provide `decreasing_by` tactic block with explicit proof

For complex lexicographic measures, explicit termination is often needed:
```lean
termination_by (B - d, B * B - k)
decreasing_by
  -- Must prove: new measure < old measure in Prod.Lex ordering
  simp_wf
  left; omega  -- First component decreases
  -- OR
  right; constructor; rfl; omega  -- First same, second decreases
```

### Why Fair Scheduling Works

The key invariant: at step n, the obligation with index < n has been resolved OR was not present.

By induction on F-obligation indices:
- Obligation i is enumerated at some step n where `Nat.unpair n = (_, i)`
- At step n, either obligation i was already resolved, or we resolve it now
- Therefore every F(psi) in M0 eventually gets a witness in the chain

This is Segerberg's "bulldozing" technique (1970) adapted to our setting.

### Comparison with Plan 05

| Plan 05 Status | Plan 06 Approach |
|----------------|------------------|
| Phases 1-5: COMPLETED | Builds on this foundation |
| Phase 6: BLOCKED (fuel exhaustion) | Phase 3: Replace with well-founded |
| fuel=0 sorry | Eliminated by proper measure |
| Design: fuel parameter | Design: lexicographic measure |
