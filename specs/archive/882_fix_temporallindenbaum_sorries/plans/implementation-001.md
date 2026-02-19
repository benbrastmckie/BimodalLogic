# Implementation Plan: Task #882

- **Task**: 882 - Fix TemporalLindenbaum sorries
- **Status**: [BLOCKED]
- **Effort**: 4 hours (analysis complete, implementation blocked)
- **Dependencies**: None
- **Research Inputs**: specs/882_fix_temporallindenbaum_sorries/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task fixes 5 sorries across two files (TemporalLindenbaum.lean and TemporalCoherentConstruction.lean) that block task 881's axiom elimination effort. The sorries fall into three categories: (1) Henkin base cases requiring the Encodable.encodek pattern, (2) temporal maximality cases requiring proof-by-contradiction using witness consistency, and (3) a generic temporal coherent family existence theorem.

### Research Integration

Research report (research-001.md) identified:
- Henkin base case sorries (lines 444, 485) need the Encodable encode/decode pattern to show that temporal packages are eventually added
- Maximality sorries (lines 655, 662) may need proof restructuring or a new witness consistency lemma
- The sorry at line 636 is in TemporalCoherentConstruction.lean, not TemporalLindenbaum.lean

## Goals & Non-Goals

**Goals**:
- Resolve all 5 sorries blocking task 881
- Establish the Encodable.encodek pattern for Henkin base cases
- Prove or restructure the temporal maximality cases
- Complete the temporal_coherent_family_exists theorem

**Non-Goals**:
- Refactoring the Henkin construction beyond what is needed for the proofs
- Generalizing the construction to arbitrary domain types D
- Optimizing proof performance

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Maximality proof requires restructuring | H | M | Try witness consistency lemma first; restructure only if needed |
| temporal_witness_seed_consistent unavailable | M | M | Check existing lemmas; adapt or create if needed |
| Package consistency proof complex | M | L | Use existing consistency lemmas in TemporalCoherentConstruction.lean |
| Sorries interdependent | M | L | Prioritize base case sorries (1-2) before maximality (3-4), family (5) last |

## Sorry Characterization

### Pre-existing Sorries
- 4 sorries in `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`:
  - Line 444: henkinLimit_forward_saturated base case
  - Line 485: henkinLimit_backward_saturated base case
  - Line 655: maximal_tcs_is_mcs F-formula case
  - Line 662: maximal_tcs_is_mcs P-formula case
- 1 sorry in `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`:
  - Line 636: temporal_coherent_family_exists

### Expected Resolution
- Phase 1 resolves lines 444, 485 via Encodable.encodek pattern
- Phase 2 resolves lines 655, 662 via witness consistency proof or restructure
- Phase 3 resolves line 636 via constant family construction

### New Sorries
- None expected. If proof complexity requires temporary sorry, will document with remediation timeline.

### Remaining Debt
After this implementation:
- 0 sorries expected in TemporalLindenbaum.lean
- 0 sorries expected in temporal_coherent_family_exists theorem
- Task 881 (axiom elimination) will be unblocked

## Implementation Phases

### Phase 1: Fix Henkin Base Case Sorries [BLOCKED]

- **Dependencies:** None
- **Goal:** Resolve sorries at lines 444 and 485 using the Encodable.encodek pattern
- **Status:** BLOCKED - Fundamental issue with proof strategy

**Analysis Findings**:

The sorries at lines 444 and 485 represent a fundamental gap in the proof strategy that cannot be filled without restructuring:

1. **The Problem**: When `F(psi) in base`, the Henkin construction processes `F(psi)` at step `n = encode(F(psi))` and tries to add `temporalPackage(F(psi)) = {F(psi), psi, ...}`. However, this package may be REJECTED if inconsistent with the chain at that step.

2. **Counterexample**: Consider `base = {F(p), neg p}`. This is consistent (F(p) talks about future, neg p talks about now). At step `encode(F(p))`, the package `{F(p), p}` is inconsistent with the chain (which contains `neg p`), so it's rejected. At step `encode(p)`, the singleton `{p}` is also inconsistent. Thus `p` never enters the limit, making `henkinLimit` NOT forward-saturated despite `F(p)` being in it.

3. **Why Encodable.encodek is Insufficient**: The pattern `Encodable.encodek` correctly identifies when a formula is processed, but does NOT guarantee the package is accepted. The acceptance depends on consistency, which is not guaranteed for arbitrary consistent bases.

4. **Required Fix**: Either:
   - Modify the construction to ALWAYS add witnesses (risking inconsistency)
   - Add constraints on the base (breaking compatibility with arbitrary contexts)
   - Use a fundamentally different approach (e.g., build indexed family directly)

**Tasks**:
- [x] Read TemporalLindenbaum.lean lines 430-500 to understand context
- [x] Verify Encodable.encodek exists in Mathlib (confirmed)
- [x] Identify existing temporal_witness_seed_consistent (requires MCS, not applicable)
- [ ] ~~Implement proof for line 444 sorry~~ - BLOCKED
- [ ] ~~Implement proof for line 485 sorry~~ - BLOCKED
- [x] Document findings

**Files to modify**:
- None (blocked)

---

### Phase 2: Fix Maximality Temporal Case Sorries [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Resolve sorries at lines 655 and 662 in maximal_tcs_is_mcs theorem
- **Status:** BLOCKED - Related fundamental issue with proof strategy

**Analysis Findings**:

The sorries at lines 655 and 662 represent a circularity in the proof structure:

1. **The Goal**: Prove `psi in insert phi M` given `phi = F(psi)`, `phi not in M`, and `insert phi M` is consistent.

2. **The Circularity**:
   - To derive a contradiction from `phi not in M`, we need to show `insert phi M in TCS`
   - To show `insert phi M in TCS`, we need temporal saturation
   - Temporal saturation requires `psi in insert phi M` (since `F(psi) = phi in insert phi M`)
   - But `psi in insert phi M` is exactly what we're trying to prove!

3. **Why Neither Option Works**:
   - **Option A (witness consistency)**: Requires showing `psi in M`, but forward saturation only gives `F(psi) in M -> psi in M`, and we have `F(psi) NOT in M`.
   - **Option B (extend with package)**: Changes the proof structure fundamentally, requiring a different approach to MCS construction.

4. **Model-Theoretic Insight**: The property "F(psi) in M implies psi in M" (temporal saturation at a single point) is extremely strong. It essentially requires all temporal witnesses to exist within the same set, which is only possible in degenerate models or with strong structural constraints.

**Tasks**:
- [x] Read maximal_tcs_is_mcs theorem context (lines 640-670)
- [x] Analyze the goal state for lines 655 and 662
- [x] Determine if proof-by-contradiction or restructuring is needed - CONCLUSION: Neither works
- [ ] ~~Implement chosen approach for line 655~~ - BLOCKED
- [ ] ~~Implement chosen approach for line 662~~ - BLOCKED
- [x] Document findings

**Files to modify**:
- None (blocked)

---

### Phase 3: Fix temporal_coherent_family_exists Sorry [BLOCKED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Resolve sorry at line 636 in TemporalCoherentConstruction.lean
- **Status:** BLOCKED - Depends on Phases 1-2 which are blocked

**Analysis Findings**:

1. **Dependency on Phases 1-2**: The plan was to use `temporalLindenbaumMCS` (which depends on Phases 1-2) to build a constant family. Since Phases 1-2 are blocked, this approach is not viable.

2. **Alternative Approaches Examined**:
   - `temporal_coherent_family_exists_Int`: Delegates to DovetailingChain which has 4 sorries
   - `temporal_coherent_family_exists_zorn` (ZornFamily): Has sorries
   - `temporal_coherent_family_exists_unified` (UnifiedChain): Has 9 sorries

3. **Generic D vs Int**: The theorem requires generic `D : Type*` with `AddCommGroup D` and `LinearOrder D`. Only Int is used downstream, but the existing constructions (DovetailingChain, RecursiveSeed) are hardcoded for Int.

4. **Technical Debt Note**: Per comments in TemporalCoherentConstruction.lean (lines 615-627), this sorry represents known technical debt requiring either:
   - Generalizing RecursiveSeed to generic D (major refactor)
   - Implementing witness enumeration for Lindenbaum-added F/P formulas

**Tasks**:
- [x] Read temporal_coherent_family_exists theorem and context
- [x] Analyze dependency on Phases 1-2 (blocked)
- [x] Examine alternative approaches (all have sorries)
- [ ] ~~Implement proof using constant family~~ - BLOCKED (depends on temporalLindenbaumMCS)
- [x] Document findings

**Files to modify**:
- None (blocked)

---

## Testing & Validation

- [ ] All 5 sorries resolved (verify with grep -n "sorry" in both files)
- [ ] TemporalLindenbaum.lean compiles without errors
- [ ] TemporalCoherentConstruction.lean compiles without errors
- [ ] `lake build` succeeds for the Bundle module
- [ ] No new axioms introduced (verify with grep for "axiom")

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-20260213.md (upon completion)
- Modified files:
  - `Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`

## Rollback/Contingency

If implementation fails:
- Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Bundle/TemporalLindenbaum.lean`
- Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
- Keep sorries in place; task 881 remains blocked
- Document blocking issues in error report

---

## Implementation Analysis Summary (2026-02-13)

### Overall Finding: BLOCKED

All 5 sorries represent fundamental gaps in the proof strategy that cannot be filled without restructuring the approach. The issues are interconnected:

### Core Problem: Temporal Saturation at a Single Point

The `temporalLindenbaumMCS` theorem attempts to build a single MCS M that is "temporally saturated" - meaning if F(psi) is in M, then psi is also in M. This is an extremely strong property that essentially requires all temporal witnesses to exist within the same set.

**Why This Is Problematic**:

In temporal logic semantics, a formula F(psi) at state s means "psi holds at some future state t > s". The witness psi is naturally at a DIFFERENT state, not the same state. Requiring psi to be in the same MCS as F(psi) conflates the distinction between time points.

**Counterexample for Henkin Base Case**:
- Base = {F(p), neg p} is consistent (F(p) talks about future, neg p talks about now)
- At step encode(F(p)), package {F(p), p} is inconsistent with chain (contains neg p)
- At step encode(p), singleton {p} is also inconsistent
- Result: henkinLimit contains F(p) but not p, violating forward saturation

**Circularity in Maximality Case**:
- To show insert phi M is in TCS, need temporal saturation
- Temporal saturation requires psi in insert phi M (since F(psi) = phi is in it)
- But psi in insert phi M is what we're trying to prove

### Recommended Path Forward

1. **Abandon Single-MCS Approach**: The `temporalLindenbaumMCS` approach of building one temporally saturated MCS is fundamentally flawed.

2. **Use Indexed Family Construction**: Build an IndexedMCSFamily where temporal witnesses can be at different time indices. This is what DovetailingChain, RecursiveSeed, and UnifiedChain attempt.

3. **Focus on Int Case**: Since only Int is used downstream (in Completeness.lean), focus on making `temporal_coherent_family_exists_Int` sorry-free rather than the generic D version.

4. **Fix DovetailingChain/RecursiveSeed**: The 4 sorries in DovetailingChain (or equivalent issues in RecursiveSeed) are the real blockers. Fixing those would provide a working construction.

### Impact on Task 881

Task 881 (axiom elimination) depends on these sorries. Since they cannot be fixed with the current approach, task 881 remains blocked. The recommended path is to:
1. Abandon TemporalLindenbaum.lean approach
2. Fix DovetailingChain or RecursiveSeed constructions
3. Use `temporal_coherent_family_exists_Int` for the completeness proof
