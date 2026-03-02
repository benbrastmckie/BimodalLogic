# Implementation Plan: Task #951 (Revision 7)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [NOT STARTED]
- **Effort**: 8-15 hours
- **Version**: 7 (focused revision targeting F-preserving seed consistency)
- **Dependencies**: BidirectionalReachable.lean (sorry-free fragment infrastructure), CanonicalCompleteness.lean (fragmentFMCS sorry-free), FragmentCompleteness.lean (F/P persistence lemmas)
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-024.md (team analysis: F-formula preserving chain)
- **Artifacts**: plans/implementation-007.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

| Version | Date | Key Changes | Outcome |
|---------|------|-------------|---------|
| 001-005 | 2026-02-27 to 2026-03-02 | Various approaches | SUPERSEDED: All blocked on F-persistence |
| 006 | 2026-03-02 | Histories-first approach | PARTIAL: Phase 2 blocked on F-persistence |
| 007 | 2026-03-02 | **F-Preserving Seed Consistency**: Formal proof attempt | Current plan |

## Why Revision 7 is Needed

**Plan v6 was BLOCKED at Phase 2**: The F-persistence obstacle blocks `fragmentChainFMCS_forward_F` and `fragmentChainFMCS_backward_P`. Research-024 identified the root cause and a potential resolution.

**Research-024 Key Discovery**: The F-formula preserving chain variant adds `F(psi)` (the obligation) instead of `psi` (the witness) to Lindenbaum seeds. If F-obligations are forced into EVERY seed, they cannot be lost. At step `encode(psi)`, we process `F(psi)` and place `psi`.

**Critical Conjecture**: If `w` is a fragment element, `F(phi) ∈ w.world`, and `Σ = {F(psi) | F(psi) ∈ w.world}`, then `{phi} ∪ Σ ∪ GContent(w.world)` is consistent.

**This is a FOCUSED plan**: No fallback approaches. If the conjecture is false or unprovable, this plan fails and requires user review to choose an alternative path.

## Overview

This plan pursues a **surgical attack** on the single remaining mathematical question from research-024:

**The Conjecture**: For any fragment element `w` with `F(phi) ∈ w.world`:
```
{phi} ∪ {F(psi) | F(psi) ∈ w.world} ∪ GContent(w.world)
```
is consistent.

**If proven**: We modify `fragmentChainStepForward` to include F-formula forcing, prove `forward_F` and `backward_P` sorry-free, and eliminate the DovetailingChain sorries.

### Research Integration

Key findings from research-024:
- **Section 2.2**: F-formula preserving variant is genuinely different from constant-family dead end
- **Section 2.4**: If F-obligations are forced into EVERY seed, the order doesn't matter
- **Section 2.5**: Single remaining question is preserving seed consistency
- **Section 3 (Proof Approaches)**: Syntactic, semantic, or reduction approach
- **Section 6**: Supporting lemmas already exist (`enriched_seed_consistent_from_F`, `F_persistence_in_fragment`)

## Goals & Non-Goals

**Goals**:
- Formally prove the F-preserving seed consistency conjecture in Lean
- Modify `fragmentChainStepForward` to force F-formulas into Lindenbaum seeds
- Prove `fragmentChainFMCS_forward_F` sorry-free using F-preservation
- Prove `fragmentChainFMCS_backward_P` sorry-free (symmetric P-preservation)
- Eliminate the 2 remaining sorries in FragmentCompleteness.lean

**Non-Goals**:
- Fragment-to-Int embedding (Priority 2 fallback, not this plan)
- Fragment-level completeness as milestone (Priority 3 fallback, not this plan)
- Refactoring truth_at for Preorder domains
- Any approach that doesn't directly resolve the conjecture

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Conjecture is false | Critical | Low | Research-024 provides strong informal argument; if false, BLOCKED with counterexample |
| Syntactic proof too complex | High | Medium | Try semantic or reduction approach as Phase 2 alternatives |
| Lean4 tactic limitations | Medium | Low | Use `enriched_seed_consistent_from_F` as template; MCP tools for lemma search |
| Modified chain breaks downstream | Medium | Low | Keep original construction; add F-preserving variant alongside |

## Sorry Characterization

### Pre-existing Sorries

Exactly **2 sorries** in FragmentCompleteness.lean are targeted:

| File | Line | Statement | Root Cause |
|------|------|-----------|------------|
| FragmentCompleteness.lean | ~460 | `fragmentChainFMCS_forward_F` | F-persistence through chain |
| FragmentCompleteness.lean | ~471 | `fragmentChainFMCS_backward_P` | P-persistence through chain |

### Expected Resolution

- Phase 3 resolves `fragmentChainFMCS_forward_F` via F-forcing in chain construction
- Phase 4 resolves `fragmentChainFMCS_backward_P` via symmetric P-forcing

### New Sorries

- **None.** NEVER introduce new sorries.
- If conjecture proof fails: mark phase [BLOCKED] with `requires_user_review: true`
- User decides: proceed to Priority 2 (embedding) or Priority 3 (fragment completeness)

### Remaining Debt

After implementation:
- 0 sorries in FragmentCompleteness.lean
- DovetailingChain.lean sorries bypassed (forward_F/backward_P proven at fragment level)
- `fully_saturated_bfmcs_exists_int` follows from fragment-level proof

## Implementation Phases

### Phase 1: Analyze Existing Seed Consistency Infrastructure [NOT STARTED]

- **Dependencies:** None
- **Goal:** Understand the existing `enriched_seed_consistent_from_F` lemma and identify gaps to F-preserving seed

**Tasks:**
- [ ] **Task 1.1:** Read `CanonicalCompleteness.lean` and locate `enriched_seed_consistent_from_F`
- [ ] **Task 1.2:** Extract the proof structure: what are the hypotheses and how is consistency shown?
- [ ] **Task 1.3:** Identify the gap: current lemma proves `{phi} ∪ GContent(w.world)` consistent; we need `{phi} ∪ Σ ∪ GContent(w.world)` where `Σ = {F(psi) | F(psi) ∈ w.world}`
- [ ] **Task 1.4:** Analyze whether `Σ ⊆ w.world` (F-formulas are in the MCS)
- [ ] **Task 1.5:** Check if `Σ ∪ GContent(w.world)` is consistent on its own (trivially, as subset of MCS)
- [ ] **Task 1.6:** Document the precise extension needed: from `{phi}` to `{phi} ∪ Σ`

**Timing:** 1-2 hours

**Files to examine:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean`
- `Theories/Bimodal/Metalogic/Bundle/MCS.lean`

**Verification:**
- Clear documentation of `enriched_seed_consistent_from_F` structure
- Identification of the exact gap to prove
- Assessment of proof difficulty (syntactic vs semantic approach)

---

### Phase 2: Prove F-Preserving Seed Consistency Conjecture [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove that `{phi} ∪ {F(psi) | F(psi) ∈ w.world} ∪ GContent(w.world)` is consistent when `F(phi) ∈ w.world`

**Tasks:**
- [ ] **Task 2.1:** Define helper `FContent : Set Formula → Set Formula := {F(psi) | F(psi) ∈ S}`
- [ ] **Task 2.2:** Prove `FContent_subset_of_mcs`: if `S` is an MCS, then `FContent(S) ⊆ S`
- [ ] **Task 2.3:** Prove `FContent_GContent_consistent`: `FContent(w.world) ∪ GContent(w.world)` is consistent (subset of MCS)
- [ ] **Task 2.4:** Attempt syntactic proof: show no TM derivation produces `¬phi` from `{F(psi_1), ..., F(psi_k)} ∪ GContent(w.world)`
  - Use the fact that F-formulas carry "future existence" information
  - The only rules that consume F are the forward temporal rules
  - GContent blocks derivation of ¬G(...) formulas
- [ ] **Task 2.5:** If syntactic fails, attempt semantic proof: construct model where all seed formulas hold
  - The fragment rooted at w provides a witness for each F(psi) eventually
- [ ] **Task 2.6:** If semantic fails, attempt reduction proof: show F-formulas add no derivational power beyond GContent
  - Key insight: `F(psi)` ∈ MCS implies there exists future where psi holds
  - This doesn't add propositional content to seed
- [ ] **Task 2.7:** Prove main theorem:
  ```lean
  theorem preserving_seed_consistent
    (w : BidirectionalFragment M0 h_mcs0)
    (phi : Formula)
    (h_F : F(phi) ∈ w.val.world) :
    Consistent ({phi} ∪ FContent(w.val.world) ∪ GContent(w.val.world))
  ```

**Timing:** 4-8 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/PreservingSeedConsistency.lean` (new module)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" PreservingSeedConsistency.lean` returns empty
- `preserving_seed_consistent` proven without sorry
- `lean_verify` confirms no suspicious axioms

**BLOCKER PROTOCOL:**
If all three approaches (syntactic, semantic, reduction) fail:
- Mark phase [BLOCKED] with `requires_user_review: true`
- Document which approaches were tried and why they failed
- Include any counterexample or structural obstacle found
- User chooses: revise conjecture, try Priority 2 (embedding), or Priority 3 (fragment completeness)

---

### Phase 3: Implement F-Preserving Chain Step [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Modify `fragmentChainStepForward` to force F-formulas into Lindenbaum seeds

**Tasks:**
- [ ] **Task 3.1:** Define `preservingForwardSeed (w : FragmentElement) (phi : Formula) : Set Formula`:
  ```lean
  preservingForwardSeed w phi := {phi} ∪ FContent(w.world) ∪ GContent(w.world)
  ```
- [ ] **Task 3.2:** Define `fragmentChainStepForward_preserving` using `lindenbaumMCS_set` with `preservingForwardSeed`
- [ ] **Task 3.3:** Prove `fragmentChainStepForward_preserving_witness_placed`: the scheduled formula phi is in the result
- [ ] **Task 3.4:** Prove `fragmentChainStepForward_preserving_F_preserved`:
  ```lean
  theorem fragmentChainStepForward_preserving_F_preserved
    (w : FragmentElement) (phi psi : Formula)
    (h_F : F(psi) ∈ w.world) :
    F(psi) ∈ (fragmentChainStepForward_preserving w phi).world
  ```
- [ ] **Task 3.5:** Prove `fragmentChainStepForward_preserving_in_fragment`: result is in the fragment
- [ ] **Task 3.6:** Prove `fragmentChainStepForward_preserving_ge`: result is ≥ w in fragment order

**Timing:** 2-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean`

**Verification:**
- `lake build` passes
- All preservation lemmas proven
- Original chain construction unchanged (preserving variant added alongside)

---

### Phase 4: Prove forward_F and backward_P Sorry-Free [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Eliminate the 2 sorries in FragmentCompleteness.lean using F-preserving chain

**Tasks:**
- [ ] **Task 4.1:** Rebuild `buildFragmentChain` using `fragmentChainStepForward_preserving` instead of original
- [ ] **Task 4.2:** Prove `buildFragmentChain_preserving_F_persistence`:
  ```lean
  theorem buildFragmentChain_preserving_F_persistence
    (n m : Nat) (psi : Formula)
    (h_F : F(psi) ∈ (buildFragmentChain n).world)
    (h_le : n ≤ m) :
    F(psi) ∈ (buildFragmentChain m).world
  ```
- [ ] **Task 4.3:** Prove `fragmentChainFMCS_forward_F` using F-persistence + dovetail scheduling:
  - At step `encode(psi)`, `F(psi)` is in chain element (by F-persistence from any earlier element containing it)
  - Processing at that step places psi in successor
- [ ] **Task 4.4:** Implement symmetric P-preserving backward step `fragmentChainStepBackward_preserving`
- [ ] **Task 4.5:** Prove `fragmentChainFMCS_backward_P` using P-persistence + dovetail scheduling
- [ ] **Task 4.6:** Remove sorries from FragmentCompleteness.lean

**Timing:** 3-5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- Both `fragmentChainFMCS_forward_F` and `fragmentChainFMCS_backward_P` proven
- `lean_verify` on both theorems confirms no suspicious axioms

---

### Phase 5: Integration and Cleanup [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Connect fragment-level proofs to `fully_saturated_bfmcs_exists_int` and verify zero-debt

**Tasks:**
- [ ] **Task 5.1:** Check if `fully_saturated_bfmcs_exists_int` in TemporalCoherentConstruction.lean can now be proven
  - It depends on forward_F/backward_P which are now sorry-free at fragment level
  - May need Int embedding (if so, document but don't implement in this plan)
- [ ] **Task 5.2:** If Int embedding still needed: document the gap and recommend Priority 2 as follow-up
- [ ] **Task 5.3:** Update module docstrings in PreservingSeedConsistency.lean and FragmentCompleteness.lean
- [ ] **Task 5.4:** Add deprecation notice to DovetailingChain.lean (sorries bypassed)
- [ ] **Task 5.5:** Final `lake build` verification
- [ ] **Task 5.6:** Zero-debt verification:
  - `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/PreservingSeedConsistency.lean` returns empty
  - `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` returns empty
- [ ] **Task 5.7:** Create implementation summary

**Timing:** 1-2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/PreservingSeedConsistency.lean` (docstrings)
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (docstrings)
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` (deprecation)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` (new)

**Verification:**
- All modified files documented
- Zero sorries in PreservingSeedConsistency.lean
- Zero sorries in FragmentCompleteness.lean
- Implementation summary created

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors throughout all phases
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/PreservingSeedConsistency.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` returns empty
- [ ] `grep -n "^axiom " PreservingSeedConsistency.lean` shows no new axioms
- [ ] `grep -n "^axiom " FragmentCompleteness.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"
- [ ] `lean_verify` on `preserving_seed_consistent`, `fragmentChainFMCS_forward_F`, `fragmentChainFMCS_backward_P`

### Regression Tests
- [ ] Soundness theorems still compile
- [ ] Existing BFMCS Int infrastructure unchanged
- [ ] Original `fragmentChainStepForward` preserved (preserving variant added alongside)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/PreservingSeedConsistency.lean` (new, ~150-250 lines)
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (modified, sorries eliminated)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

**This is a focused plan with no fallbacks built in.**

**If Phase 2 (conjecture proof) fails:**
- Mark [BLOCKED] with `requires_user_review: true`
- Document: which approaches were tried (syntactic, semantic, reduction)
- Document: any counterexample or structural obstacle found
- User decision: proceed to Priority 2 (Fragment-to-Int embedding) or Priority 3 (fragment-level completeness as milestone)

**If Phase 3 or 4 fails (unexpected):**
- The conjecture proof from Phase 2 should guarantee these succeed
- If they fail anyway: likely a Lean tactic/typing issue, not mathematical
- Mark [BLOCKED] with detailed error and Lean goal state

**Hard Blocker Escape:**
If proof stuck at any phase with no path forward:
- Mark phase [BLOCKED] with `requires_user_review: true`
- Document the mathematical obstacle clearly
- Include all attempted approaches and their failure modes
- User decides next steps (different plan version or different Priority path)
