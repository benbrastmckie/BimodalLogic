# Implementation Plan: Task #951 (Revision 6)

- **Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
- **Status**: [IMPLEMENTING]
- **Effort**: 20-30 hours
- **Version**: 6 (supersedes implementation-001.md through -005.md)
- **Dependencies**: BidirectionalReachable.lean (sorry-free fragment infrastructure), CanonicalCompleteness.lean (fragmentFMCS sorry-free)
- **Research Inputs**:
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-022.md (histories-first analysis)
  - specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-021.md (synthesis)
- **Artifacts**: plans/implementation-006.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision History

| Version | Date | Key Changes | Outcome |
|---------|------|-------------|---------|
| 001 | 2026-02-27 | Z-indexed dovetailing chain | SUPERSEDED: F-persistence through GContent impossible |
| 002 | 2026-02-27 | Bidirectional Reachable Fragment | SUPERSEDED: Phases A-D completed; LinearOrder proven |
| 003 | 2026-03-01 | OrderIso via SuccOrder/PredOrder | SUPERSEDED: coverness fails mathematically |
| 004 | 2026-03-01 | Grothendieck construction | SUPERSEDED: quotientSucc_pred_inverse semantically invalid |
| 005 | 2026-03-02 | Fragment-level + Int embedding | SUPERSEDED: Phase 2 BLOCKED (witnessAt families don't satisfy forward_G) |
| 006 | 2026-03-02 | **Histories-First: BidirectionalFragment IS the history** | Current plan |

## Why Revision 6 is Needed

**Plan v5 was BLOCKED at Phase 2**: The witnessAt-based witness families don't satisfy forward_G because witness MCSes at different points are unrelated by CanonicalR.

**Research-022 Key Insight**: The `BidirectionalFragment` IS already the history. No Flag extension is needed. The fragment has:
- `forward_F_stays_in_fragment` (sorry-free)
- `backward_P_stays_in_fragment` (sorry-free)
- `fragmentFMCS_temporally_coherent` (sorry-free)
- Total ordering via `bidirectional_totally_ordered`

**Critical Finding from research-022 Section 1.2**: The user-proposed bidirectional relation `R(u,v) iff GContent(u) subseteq v AND HContent(v) subseteq u` is EXACTLY `canonical_task_rel` (already in codebase). The duality theorem `GContent_subset_implies_HContent_reverse` makes the second condition automatic for MCSes.

**Architectural Shift**: Instead of building an Int-indexed chain (which fails on F-persistence), we:
1. Work entirely at the Fragment level where everything is sorry-free
2. Check whether `truth_at` requires AddCommGroup or just Preorder
3. If just Preorder: prove completeness at Fragment level directly
4. If AddCommGroup required: embed Fragment into Int as a modular isolated step

## Overview

This plan pursues the **histories-first** approach from research-022:

The BidirectionalFragment rooted at an MCS M0 IS the canonical history. It already has:
- Totality (linear order within the fragment)
- Forward_F and backward_P (sorry-free)
- Temporal coherence (sorry-free)

**Phase 1**: Investigate what `truth_at` actually requires (AddCommGroup vs Preorder)
**Phase 2**: Build fragment-level BFMCS using fragmentFMCS as eval_family (sorry-free)
**Phase 3**: Prove fragment-level truth lemma
**Phase 4**: Prove fragment-level completeness (sorry-free)
**Phase 5**: Int embedding (only if needed, isolated module)

### Research Integration

Key findings from research-022:
- **Section 1.2**: R = CanonicalR for MCSes (duality theorem makes bidirectional condition automatic)
- **Section 3.6**: "The BidirectionalFragment IS the history, and Flags are unnecessary"
- **Section 4.2**: Histories-first has forward_F/backward_P sorry-free at fragment level
- **Section 6.1**: Recommended path with Fragment-level completeness + modular embedding

## Goals & Non-Goals

**Goals**:
- Investigate `truth_at` requirements (AddCommGroup vs Preorder)
- Prove completeness at the BidirectionalFragment level using sorry-free infrastructure
- Achieve sorry-free `fragment_completeness_theorem`
- If needed: embed Fragment into Int as isolated modular step
- Eliminate dependency on DovetailingChain sorries (bypass, not resolve)

**Non-Goals**:
- Proving SuccOrder coverness (mathematically blocked)
- Using quotientSucc/quotientPred inverse (semantically blocked)
- Changing `valid` definition (breaks soundness)
- Building explicit Int-indexed chain with F-persistence (root cause of all prior failures)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| truth_at requires AddCommGroup | High | Medium | Phase 1 investigation; if required, adapt truth_at definition for Preorder |
| WorldHistory requires AddCommGroup | Medium | Medium | Define fragment-level history using Preorder structure |
| Fragment enumeration into Int is non-trivial | Medium | Low | Only needed if AddCommGroup required; use well-ordering on countable linear order |
| Modal saturation witness families | Medium | Medium | Each witness is a separate BidirectionalFragment rooted at witness MCS |

## Sorry Characterization

### Pre-existing Sorries

Exactly **3 sorries** remain in active codebase:

| File | Line | Statement | Root Cause |
|------|------|-----------|------------|
| DovetailingChain.lean | 1869 | `buildDovetailingChainFamily_forward_F` | F-formulas don't persist through GContent seeds |
| DovetailingChain.lean | 1881 | `buildDovetailingChainFamily_backward_P` | P-formulas don't persist through HContent seeds |
| TemporalCoherentConstruction.lean | 600 | `fully_saturated_bfmcs_exists_int` | Combines temporal coherence + modal saturation |

### Expected Resolution

- DovetailingChain sorries are BYPASSED (not resolved) by working at fragment level
- `fully_saturated_bfmcs_exists_int` either:
  - Becomes unnecessary (if completeness proven at fragment level directly), or
  - Is resolved via fragment enumeration into Int (Phase 5)

### New Sorries

- **None.** NEVER introduce new sorries.
- If proof cannot be completed: mark phase [BLOCKED] with `requires_user_review: true`
- User decides: revise plan, split task, or change approach

### Remaining Debt

After implementation:
- 0 new sorries introduced
- Fragment-level completeness is sorry-free
- DovetailingChain.lean can be deprecated (sorries bypassed)
- If Int embedding needed: sorries isolated in that single module

## Implementation Phases

### Phase 1: truth_at Requirements Investigation [COMPLETED]

- **Dependencies:** None
- **Goal:** Determine exactly what algebraic structure `truth_at` requires

**Tasks:**
- [ ] **Task 1.1:** Read `Theories/Bimodal/Semantics/Truth.lean` and identify all type class constraints on domain D in `truth_at` definition
- [ ] **Task 1.2:** Check if `WorldHistory` requires AddCommGroup or just Preorder/LinearOrder
- [ ] **Task 1.3:** Check `task_rel` definition and whether it requires duration arithmetic
- [ ] **Task 1.4:** Document findings: which constraints are essential vs incidental
- [ ] **Task 1.5:** If AddCommGroup is NOT essential: plan direct Fragment-level instantiation
- [ ] **Task 1.6:** If AddCommGroup IS essential: plan either (a) refactor truth_at, or (b) embedding approach

**Timing:** 2-3 hours

**Files to examine:**
- `Theories/Bimodal/Semantics/Truth.lean`
- `Theories/Bimodal/Semantics/TaskFrame.lean`
- `Theories/Bimodal/Semantics/WorldHistory.lean`

**Verification:**
- Clear documentation of truth_at's algebraic requirements
- Decision on Phase 2+ approach (direct vs embedding)

**Progress:**

**Session: 2026-03-02, sess_1740934800_951impl**
- Completed: All 6 tasks (1.1-1.6) - full analysis of type class requirements
- Finding (Task 1.1): `truth_at` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- Finding (Task 1.2): `WorldHistory` requires same - `time_shift` uses `z + Delta`, `-Delta`, `neg_add_cancel`
- Finding (Task 1.3): `TaskFrame.task_rel` uses `0` (nullity), `x + y` (compositionality), `t - s` (respects_task)
- Finding (Task 1.4): AddCommGroup IS deeply essential, NOT incidental:
  - `time_shift_preserves_truth` uses `y - x`, `neg_sub`, `add_sub_cancel_left`
  - `valid` definition quantifies over all D with `AddCommGroup + LinearOrder + IsOrderedAddMonoid`
  - `satisfiable` definition requires same constraints
  - ShiftClosed uses `WorldHistory.time_shift` which requires `z + Delta`
- Decision (Task 1.6): AddCommGroup IS essential. Cannot define truth_at on BidirectionalFragment.
  - **Approach**: Prove `fully_saturated_bfmcs_exists_int` sorry-free
  - The existing `standard_weak_completeness` is ALREADY sorry-free modulo this one sorry
  - Strategy: Build BFMCS Int with temporally coherent families using fragment-level infrastructure
  - Fragment -> Int mapping: enumerate countable linear order into Int (Phase 5)
  - OR: construct FMCS Int directly using fragmentFMCS as guide
  - Key insight: `fragmentFMCS` is sorry-free for forward_F/backward_P
  - Remaining challenge: convert FMCS Fragment -> FMCS Int with modal saturation

---

### Phase 2: Fragment-Level BFMCS Construction [IN PROGRESS]

- **Dependencies:** Phase 1
- **Goal:** Construct `BFMCS (BidirectionalFragment M0 h_mcs0)` with sorry-free temporal coherence

**Tasks:**
- [ ] **Task 2.1:** Define `fragmentEvalFamily` wrapping `fragmentFMCS` as the evaluation family
- [ ] **Task 2.2:** Prove `fragmentEvalFamily_forward_F` using `forward_F_stays_in_fragment`
- [ ] **Task 2.3:** Prove `fragmentEvalFamily_backward_P` using `backward_P_stays_in_fragment`
- [ ] **Task 2.4:** Prove `fragmentEvalFamily_temporally_coherent` using `fragmentFMCS_temporally_coherent`
- [ ] **Task 2.5:** Define `fragmentBFMCS_initial : BFMCS (BidirectionalFragment M0 h_mcs0)` with single eval_family
- [ ] **Task 2.6:** Verify context preservation: `Gamma subseteq fragmentBFMCS_initial.eval_family.mcs origin`

**Timing:** 3-5 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (new)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- All proofs verified with `lean_goal` showing "no goals"

---

### Phase 3: Fragment-Level Truth Lemma [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove truth lemma at the Fragment level

**Tasks:**
- [ ] **Task 3.1:** Define `fragmentTruthAt` (Fragment-compatible truth definition if needed)
- [ ] **Task 3.2:** Define `fragmentWorldHistory` using BidirectionalFragment structure
- [ ] **Task 3.3:** Define `fragmentTaskModel` with trivial task_rel (follows from CanonicalR)
- [ ] **Task 3.4:** Define `fragmentOmega` (function assignment for world histories)
- [ ] **Task 3.5:** Prove atom case: `p in fam.mcs w <-> fragmentTruthAt ... p`
- [ ] **Task 3.6:** Prove bot case: trivial (bot never in MCS)
- [ ] **Task 3.7:** Prove imp case: follows from MCS closure
- [ ] **Task 3.8:** Prove box case: uses `canonical_box_truth_lemma` pattern
- [ ] **Task 3.9:** Prove all_future (G) case: uses fragment's forward_G property
- [ ] **Task 3.10:** Prove all_past (H) case: uses fragment's backward_H property
- [ ] **Task 3.11:** Prove `fragment_truth_lemma`: phi in fam.mcs w <-> fragmentTruthAt ... phi

**Timing:** 5-8 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (extend)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- All 6 formula cases proven

---

### Phase 4: Fragment-Level Completeness [NOT STARTED]

- **Dependencies:** Phase 2, Phase 3
- **Goal:** Prove completeness at Fragment level (consistent -> satisfiable)

**Tasks:**
- [ ] **Task 4.1:** Define witness family construction for Diamond obligations using `diamondWitnessMCS`
- [ ] **Task 4.2:** Each witness starts a new BidirectionalFragment; apply `fragmentFMCS` to get FMCS
- [ ] **Task 4.3:** Prove witness families satisfy temporal coherence (by `fragmentFMCS_temporally_coherent`)
- [ ] **Task 4.4:** Define `fragmentBFMCS_saturate` adding witness families iteratively
- [ ] **Task 4.5:** Apply Zorn's lemma to get fully saturated fragment BFMCS
- [ ] **Task 4.6:** Prove `fragment_completeness_theorem`:
  ```lean
  theorem fragment_completeness (phi : Formula) (h_cons : ContextConsistent [phi]) :
      exists (B : BFMCS (BidirectionalFragment M0 h_mcs0)) (w : BidirectionalFragment M0 h_mcs0),
        fragmentTruthAt B.model B.omega (fragmentHistory B w) w phi
  ```
- [ ] **Task 4.7:** Verify the theorem is sorry-free with `lean_verify`

**Timing:** 6-10 hours

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (extend)

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns empty
- `fragment_completeness_theorem` proven sorry-free

---

### Phase 5: Int Embedding (If Required) [NOT STARTED]

- **Dependencies:** Phase 1 (determines if needed), Phase 4
- **Goal:** If AddCommGroup required for standard completeness statement, embed Fragment into Int

**Tasks:**
- [ ] **Task 5.1:** Prove `bidirectionalFragment_countable`: fragment is countable
- [ ] **Task 5.2:** Define `fragmentToInt : BidirectionalFragment M0 h_mcs0 -> Int` via enumeration of countable linear order
- [ ] **Task 5.3:** Prove `fragmentToInt_monotone`: preserves order
- [ ] **Task 5.4:** Define pullback `pullbackFMCS : FMCS Fragment -> FMCS Int`
- [ ] **Task 5.5:** Prove pullback preserves temporal coherence
- [ ] **Task 5.6:** Prove `fully_saturated_bfmcs_exists_int` using fragment completeness + pullback
- [ ] **Task 5.7:** Connect to `standard_weak_completeness`

**Timing:** 4-6 hours (only if needed)

**Files to create/modify:**
- `Theories/Bimodal/Metalogic/Bundle/FragmentToInt.lean` (new, only if needed)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` (remove sorry if embedding used)

**Verification:**
- `lake build` passes
- If Phase 5 executed: `grep -n "\bsorry\b" FragmentToInt.lean` returns empty
- `standard_weak_completeness` is sorry-free

---

### Phase 6: Cleanup and Documentation [NOT STARTED]

- **Dependencies:** Phase 4 (or Phase 5 if executed)
- **Goal:** Document completeness proof, deprecate obsolete modules

**Tasks:**
- [ ] **Task 6.1:** Add module docstrings to FragmentCompleteness.lean
- [ ] **Task 6.2:** Mark DovetailingChain.lean as deprecated (sorries bypassed)
- [ ] **Task 6.3:** Update TODO.md with completion status
- [ ] **Task 6.4:** Create implementation summary `summaries/implementation-summary-YYYYMMDD.md`
- [ ] **Task 6.5:** Final `lake build` verification
- [ ] **Task 6.6:** Zero-debt verification: `grep -rn "\bsorry\b" FragmentCompleteness.lean` returns empty
- [ ] **Task 6.7:** Git commit with complete changelog

**Timing:** 2-3 hours

**Files to modify:**
- FragmentCompleteness.lean (docstrings)
- DovetailingChain.lean (deprecation notice)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md` (new)

**Verification:**
- All files documented
- Implementation summary created
- Zero sorries in completeness chain

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors throughout all phases
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` returns empty
- [ ] `grep -n "^axiom " FragmentCompleteness.lean` shows no new axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"
- [ ] `fragment_completeness_theorem` is sorry-free

### Regression Tests
- [ ] Soundness theorems still compile
- [ ] Existing BFMCS Int infrastructure unchanged
- [ ] No new imports break existing modules

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/FragmentCompleteness.lean` (new, ~500-800 lines)
- `Theories/Bimodal/Metalogic/Bundle/FragmentToInt.lean` (new, only if Phase 5 needed, ~200-300 lines)
- `specs/951_implement_sorry_free_completeness_canonicalmcs/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

**If Phase 1 finds AddCommGroup is deeply required:**
- Pursue embedding path (Phase 5)
- Fragment-level completeness (Phase 4) is still valuable intermediate result

**If Phase 3 (truth lemma) fails:**
- May need to adapt truth_at definition
- Fragment infrastructure is isolated; no regression to existing code

**If Phase 4 (modal saturation) fails:**
- Each witness family is a separate fragment
- Document which part of saturation fails
- May need alternative witness construction

**Hard Blocker Escape:**
If proof stuck at any phase with no path forward:
- Mark phase [BLOCKED] with `requires_user_review: true`
- Document the mathematical obstacle clearly
- User decides next steps
