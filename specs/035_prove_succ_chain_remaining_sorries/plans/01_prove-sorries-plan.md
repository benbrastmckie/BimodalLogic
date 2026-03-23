# Implementation Plan: Task #35

- **Task**: 35 - prove_succ_chain_remaining_sorries
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: Task 997 (Succ-chain base completeness) - COMPLETED
- **Research Inputs**: specs/035_prove_succ_chain_remaining_sorries/reports/01_team-research.md
- **Artifacts**: plans/01_prove-sorries-plan.md (this file)
- **Standards**:
  - .claude/context/core/standards/plan.md
  - .claude/context/core/standards/status-markers.md
  - .claude/context/core/system/artifact-management.md
  - .claude/context/core/standards/tasks.md
- **Type**: lean4

## Overview

This task proves 4 remaining items in the Succ-chain completeness pipeline: one structural sorry (contraction), two P-direction sorries (single_step_forcing_past, backward_witness), and one axiom (succ_chain_fam_p_step). The research identified clear proof strategies for each: contraction uses `derivation_exchange`, single_step_forcing_past adds an explicit p_step parameter, backward_witness mirrors bounded_witness, and succ_chain_fam_p_step uses existing `backward_chain_p_step` for negative cases while requiring a new lemma for positive cases.

**Exclusions** (moved to separate tasks): Box backward (task 38), f_nesting_boundary (task 36), p_nesting_boundary (task 37).

### Research Integration

Key findings from team research:
- `succ_propagates_P_not` is already proven; the actual sorry is in `single_step_forcing_past` at SuccRelation.lean:497
- Contraction rated LOW difficulty - `derivation_exchange` provides direct path
- `single_step_forcing_past` needs explicit `h_p_step` parameter (call sites already have this data)
- `backward_witness` depends on fixing `single_step_forcing_past`; mirrors `bounded_witness` template
- `succ_chain_fam_p_step` backward cases use existing `backward_chain_p_step`; forward case needs new `successor_satisfies_p_step`

## Goals & Non-Goals

**Goals**:
- Prove structural contraction sorry in SuccChainCompleteness.lean:109
- Prove `single_step_forcing_past` sorry in SuccRelation.lean:497 with explicit p_step parameter
- Prove `backward_witness` sorry in CanonicalTaskRelation.lean:785 using bounded_witness template
- Convert `succ_chain_fam_p_step` axiom to theorem in SuccChainFMCS.lean:335

**Non-Goals**:
- Box backward direction (SuccChainTruth.lean:254) - separate task 38
- `f_nesting_boundary` axiom - separate task 36
- `p_nesting_boundary` axiom - separate task 37
- Fischer-Ladner closure infrastructure
- Changing the abstract `Succ` definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `successor_satisfies_p_step` harder than expected | M | M | Can leave forward case of succ_chain_fam_p_step as axiom with semantic justification |
| Type mismatches in p_step parameter threading | L | M | Verify call sites have required data via lean_goal before modifying signatures |
| backward_witness induction direction wrong | M | L | Use tail_inv approach from research if primary approach fails |
| derivation_exchange insufficient for contraction | L | L | Research confirmed contextAsSet collapses duplicates |

## Implementation Phases

### Phase 1: Contraction via derivation_exchange [COMPLETED]

**Goal**: Prove the structural contraction sorry at SuccChainCompleteness.lean:109

**Tasks**:
- [ ] Read SuccChainCompleteness.lean lines 90-115 to understand the proof context
- [ ] Find `derivation_exchange` definition and signature in MCSProperties.lean
- [ ] Apply contraction: if L ⊢ ⊥ and all elements of L equal φ.neg, then [φ.neg] ⊢ ⊥
- [ ] The key insight: `contextAsSet L = contextAsSet [φ.neg]` when all L elements are φ.neg
- [ ] Run `lake build` to verify no errors

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Replace sorry with proof

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Completeness.SuccChainCompleteness` compiles without sorry

---

### Phase 2: single_step_forcing_past with explicit p_step [COMPLETED]

**Goal**: Prove the sorry at SuccRelation.lean:497 by adding an explicit p_step hypothesis

**Tasks**:
- [ ] Read single_step_forcing_past full context (lines 354-497) to understand existing proof state
- [ ] Add `h_p_step : p_content v ⊆ u ∪ p_content u` as an explicit parameter
- [ ] Complete proof: from h_phi_in_p_content_v and h_p_step, derive phi ∈ u ∨ phi ∈ p_content u
- [ ] From h_P_not_u, conclude phi ∉ p_content u, therefore phi ∈ u
- [ ] Locate all call sites of single_step_forcing_past (expected: CanonicalTask_backward_MCS_P)
- [ ] Update call sites to provide h_p_step argument
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - Add p_step parameter, complete proof
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - Update call sites

**Verification**:
- No sorry at SuccRelation.lean:497
- All call sites compile successfully

---

### Phase 3: backward_witness mirroring bounded_witness [COMPLETED]

**Goal**: Prove the sorry at CanonicalTaskRelation.lean:785 using bounded_witness as template

**Tasks**:
- [ ] Study bounded_witness proof (CanonicalTaskRelation.lean:541-569) for structure
- [ ] Read backward_witness full context (around line 785)
- [ ] Implement induction on n, mirroring bounded_witness:
  - Base case (n = 0): P^0(φ) = φ ∈ v, and v = u by chain structure
  - Inductive case: use single_step_forcing_past (with p_step from Phase 2)
  - Use succ_propagates_P_not for P^(k+1)(φ) ∉ w
- [ ] Ensure CanonicalTask_backward_MCS_P provides p_step requirement
- [ ] Run `lake build` to verify

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - Replace sorry with proof

**Verification**:
- No sorry at CanonicalTaskRelation.lean:785
- `lake build` succeeds

---

### Phase 4: succ_chain_fam_p_step theorem [IN PROGRESS]

**Goal**: Convert axiom succ_chain_fam_p_step (SuccChainFMCS.lean:335) to theorem

**Tasks**:
- [ ] Analyze cases by Int index structure:
  - Case n = Int.ofNat k (k ≥ 0): Forward chain
  - Case n = Int.negSucc 0 (n = -1): Boundary from forward to backward
  - Case n = Int.negSucc (k+1) (n ≤ -2): Backward chain
- [ ] For backward cases (n ≤ -1): Apply existing `backward_chain_p_step` theorem
- [ ] For forward case (n ≥ 0): Need new `successor_satisfies_p_step` lemma
- [ ] Create `successor_satisfies_p_step` in SuccExistence.lean:
  - Goal: `p_content(successor_from_deferral_seed u ...) ⊆ u ∪ p_content u`
  - Use temporal duality argument: φ → G(P(φ)) (temp_a)
  - If P(φ) ∈ successor, then P(φ) must have come from g_content(u) or deferral seed
- [ ] If `successor_satisfies_p_step` proves too complex, leave forward case as partial axiom with documentation
- [ ] Change axiom to theorem (or opaque def if partial)
- [ ] Run `lake build` to verify

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - Add successor_satisfies_p_step lemma
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - Convert axiom to theorem

**Verification**:
- No axiom at SuccChainFMCS.lean:335 (or documented partial axiom)
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/` shows no new sorries (only existing documented ones)
- [ ] `grep -r "axiom" Theories/Bimodal/Metalogic/Bundle/` shows reduced axiom count
- [ ] `lean_verify` on modified theorems confirms no unexpected axiom dependencies

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` - Contraction proof
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` - single_step_forcing_past proof
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` - backward_witness proof
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` - successor_satisfies_p_step lemma
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` - succ_chain_fam_p_step theorem
- `specs/035_prove_succ_chain_remaining_sorries/summaries/01_implementation-summary.md` - Summary

## Rollback/Contingency

If implementation fails:
1. Phase 4 (forward p_step): Can be left as axiom with enhanced semantic justification comment
2. Phase 3 (backward_witness): If single_step_forcing_past approach fails, try tail_inv alternative
3. Phase 2 (single_step_forcing_past): Keep sorry with improved documentation if p_step threading proves too invasive
4. Phase 1 (contraction): Most likely to succeed; if not, document limitation

Git commits after each phase allow partial rollback if later phases introduce issues.
