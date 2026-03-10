# Implementation Plan: Canonical Truth Lemma Pipeline

- **Task**: 956 - Construct D as translation group from syntax
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None
- **Research Inputs**: research-028.md (canonical FMCS architecture), research-027.md (BFMCS lifting)
- **Artifacts**: plans/implementation-008.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Supersedes**: implementation-007.md (product domain approach - constant-MCS histories cause temporal trivialization)

## Overview

This plan abandons the product domain approach and returns to the **canonical Int-indexed FMCS** architecture from `CanonicalConstruction.lean`. Research-028 established:

1. `canonical_truth_lemma` already proves `phi in MCS <-> truth_at` directly (sorry-free)
2. The product domain causes `G(phi) <-> phi` (temporal trivialization)
3. The single remaining blocker is `fully_saturated_bfmcs_exists_int`
4. The `bmcs_truth_at` infrastructure is redundant and should be archived

### Why This Works

The `CanonicalConstruction.lean` approach uses **non-constant** FMCS families:
- Each `FMCS Int` has `fam.mcs t` varying with time `t`
- `to_history fam` maps time `t` to world state `(fam.mcs t, proof_of_mcs)`
- G/H quantify over DIFFERENT MCS at different times
- No temporal trivialization

### Key Insight from Research-028

The existing `canonical_truth_lemma` is the correct path. The problem is NOT the truth lemma - it's constructing the BFMCS Int. Specifically:
- `fragmentChainFMCS` from `FragmentCompleteness.lean` has sorry in `forward_F/backward_P`
- The Int chain may "jump over" F-witnesses
- Resolving this enables `fully_saturated_bfmcs_exists_int`

## Changes from v007

| v007 (Product Domain) | v008 (Canonical Pipeline) |
|-----------------------|---------------------------|
| `TemporalDomain := RestrictedQuotient × Q` | `D = Int` with non-constant FMCS |
| Constant-MCS histories | Non-constant `fam.mcs t` |
| G/H collapse to identity | G/H quantify over different MCS |
| New truth lemma needed | Use existing `canonical_truth_lemma` |
| Focus on product frame | Focus on chain construction |

## Implementation Phases

### Phase 0: Boneyard Archival [NOT STARTED]

- **Dependencies:** None
- **Goal:** Remove distracting dead-end definitions

**Tasks:**
- [ ] Move `BFMCSTruth.lean` to `Boneyard/BFMCSTruth.lean`
- [ ] Move `TruthLemma.lean` to `Boneyard/TruthLemma.lean`
- [ ] Move `TemporalDomain.lean` to `Boneyard/TemporalDomain.lean`
- [ ] Update imports in `Representation.lean` (remove bmcs_truth_at dependency)
- [ ] Run `lake build` to verify nothing breaks

**Timing:** 1 hour

**Verification:** Build passes, archived files no longer imported

---

### Phase 1: Consolidate Truth Lemma Infrastructure [NOT STARTED]

- **Dependencies:** Phase 0
- **Goal:** Make `Representation.lean` use `canonical_truth_lemma` directly

**Tasks:**
- [ ] Add import of `CanonicalConstruction` to `Representation.lean`
- [ ] Remove duplicate `canonical_truth_lemma_all` from `Representation.lean` (line 269)
- [ ] Update `shifted_truth_lemma` to reference `canonical_truth_lemma`
- [ ] Verify proof still works

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Representation.lean`

**Verification:** Build passes, no duplicate truth lemmas

---

### Phase 2: Analyze Chain F-Persistence Problem [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Understand why `fragmentChainFMCS_forward_F` has sorry

**Tasks:**
- [ ] Read `FragmentCompleteness.lean` lines 414-471
- [ ] Trace through `buildFragmentChain` construction
- [ ] Identify where F-witnesses can be "jumped over"
- [ ] Document findings for Phase 3

**Timing:** 1 hour

**Files to examine:**
- `Theories/Bimodal/Metalogic/FragmentCompleteness.lean`
- `Theories/Bimodal/Metalogic/CanonicalCompleteness.lean`

**Verification:** Written analysis of the jump-over problem

---

### Phase 3: Design Refined Chain Construction [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Design chain that visits all F/P witnesses

**Design Options (from research-028):**

**Option A: Bounded Step Size**
- Ensure each step `chain(n+1)` is adjacent to `chain(n)` in fragment ordering
- No jumps means no missed witnesses
- May require omega-squared indexing

**Option B: Omega-Squared Construction**
- Use `(n, m) : Nat × Nat` instead of `n : Int`
- Process all F-obligations at level `n` before moving to `n+1`
- Guarantees every witness is visited

**Option C: Reactive Processing**
- Process F-obligations BEFORE they can be jumped
- Requires careful scheduling

**Tasks:**
- [ ] Evaluate Option A feasibility
- [ ] Evaluate Option B feasibility
- [ ] Evaluate Option C feasibility
- [ ] Select approach and document

**Timing:** 2 hours

**Verification:** Design document with selected approach

---

### Phase 4: Implement Refined Chain [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Implement chain construction that proves `forward_F/backward_P`

**Tasks:**
- [ ] Implement chosen chain construction from Phase 3
- [ ] Prove `fragmentChainFMCS_forward_F` without sorry
- [ ] Prove `fragmentChainFMCS_backward_P` without sorry
- [ ] Run `lake build`

**Timing:** 3 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/FragmentCompleteness.lean`

**Verification:**
- `lake build` passes
- `grep -n "\bsorry\b" FragmentCompleteness.lean` returns only unrelated sorries

---

### Phase 5: Construct BFMCS Int [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Prove `fully_saturated_bfmcs_exists_int` without sorry

**Tasks:**
- [ ] Use `fragmentChainFMCS` as eval family
- [ ] For each diamond obligation, construct witness `fragmentChainFMCS` rooted at diamond witness MCS
- [ ] Prove temporal coherence for all families (from Phase 4)
- [ ] Prove modal saturation
- [ ] Complete `fully_saturated_bfmcs_exists_int`

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/TemporalCoherentConstruction.lean`

**Verification:**
- `grep -n "fully_saturated_bfmcs_exists_int" | grep sorry` returns empty
- `lake build` passes

---

### Phase 6: Verify Standard Completeness [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Confirm completeness theorem is sorry-free

**Tasks:**
- [ ] Verify `standard_weak_completeness` in Representation.lean
- [ ] Verify `standard_strong_completeness` in Representation.lean
- [ ] Run `lake build` on full project
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/` for audit

**Timing:** 30 minutes

**Verification:**
- Completeness theorems have no sorry dependencies
- Full build passes

---

### Phase 7: Final Documentation [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Create implementation summary

**Tasks:**
- [ ] Write implementation summary
- [ ] Update ROAD_MAP.md if needed
- [ ] Create commit with final state

**Timing:** 30 minutes

**Files to create:**
- `specs/956_construct_d_as_translation_group_from_syntax/summaries/implementation-summary-{DATE}.md`

---

## Testing & Validation

- [ ] `lake build` passes at each phase
- [ ] No new sorries introduced
- [ ] `fully_saturated_bfmcs_exists_int` resolved
- [ ] Completeness theorems sorry-free
- [ ] Archived files in Boneyard/

## Risk Assessment

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Chain F-persistence unprovable | HIGH | MEDIUM | Try all three design options; may need compactness |
| Archive breaks downstream | MEDIUM | LOW | Phase 0 verifies build before continuing |
| Omega-squared too complex | MEDIUM | LOW | Can fall back to bounded step size |

## Estimated Total

| Phase | Hours |
|-------|-------|
| Phase 0 | 1 |
| Phase 1 | 1.5 |
| Phase 2 | 1 |
| Phase 3 | 2 |
| Phase 4 | 3 |
| Phase 5 | 2 |
| Phase 6 | 0.5 |
| Phase 7 | 0.5 |
| **Total** | **11.5** |

## Appendix: Key Files

**Use directly:**
- `CanonicalConstruction.lean` - `canonical_truth_lemma` (sorry-free)
- `CanonicalFMCS.lean` - `temporal_coherent_family_exists_CanonicalMCS` (sorry-free)
- `CanonicalCompleteness.lean` - Fragment FMCS, diamond witness infrastructure

**Modify:**
- `FragmentCompleteness.lean` - Chain construction, `forward_F/backward_P`
- `TemporalCoherentConstruction.lean` - `fully_saturated_bfmcs_exists_int`
- `Representation.lean` - Remove bmcs_truth_at dependency

**Archive to Boneyard:**
- `BFMCSTruth.lean` - `bmcs_truth_at` predicate
- `TruthLemma.lean` - `bmcs_truth_lemma`
- `TemporalDomain.lean` - Product domain (constant-MCS)
