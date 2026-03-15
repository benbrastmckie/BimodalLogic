# Implementation Plan: Task #967 (Reflexive Semantics Refactor)

- **Task**: 967 - Reflexive Semantics Refactor to Eliminate canonicalR_irreflexive Axiom
- **Status**: [IMPLEMENTING]
- **Effort**: 40-100 hours (high variance due to cascading proof fixes)
- **Dependencies**: None
- **Research Inputs**: specs/967_change_atom_type_for_freshness/reports/research-002.md
- **Artifacts**: plans/implementation-003.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true
- **Revision**: v003 - Added Phase 0 (documentation update) per user request

## Overview

This plan implements a **fundamental semantic shift** from irreflexive to reflexive temporal semantics for the G/H operators. The change makes `G(phi)` mean "phi holds NOW AND at all future times" (using `<=` instead of `<`), enabling the T-axiom derivation required to complete the Gabbay IRR proof and eliminate the `canonicalR_irreflexive` axiom.

**Scope**: This is a deep refactor affecting core semantics, requiring cascading proof fixes throughout the metalogic. The user has explicitly requested proceeding with this approach, reversing prior ROAD_MAP.md decisions.

**Definition of Done**: `lake build` passes, `canonicalR_irreflexive` is a theorem (not axiom), zero new sorries, zero new axioms.

### Research Integration

- **research-002.md**: Comprehensive analysis confirming:
  - Reflexive semantics enables T-axiom derivation (`H(phi) -> phi`)
  - T-axiom completes Gabbay IRR Step 6: `H(neg(p)) in M' --> neg(p) in M'`
  - Density axiom does NOT trivialize under reflexive semantics
  - DensityFrameCondition.lean case analysis changes but is mathematically sound
  - Estimated 40-100 hours with medium-high risk

## Goals & Non-Goals

**Goals**:
- Update ROAD_MAP.md and code comments to reflect reflexive semantics decision
- Change Truth.lean semantic definitions from `<` to `<=` for temporal operators
- Add T-axioms (`temp_t_future`, `temp_t_past`) to Axioms.lean
- Prove T-axiom soundness in Soundness.lean
- Rewrite DensityFrameCondition.lean case analysis for reflexive semantics
- Restructure seriality axiom proofs (now trivially satisfied under reflexive semantics)
- Complete Gabbay IRR proof in CanonicalIrreflexivity.lean using T-axiom
- Replace `canonicalR_irreflexive` axiom with theorem in CanonicalIrreflexivityAxiom.lean
- Fix all cascading proof breakage throughout the codebase
- Ensure `lake build` passes with zero new sorries or axioms

**Non-Goals**:
- Optimize proof performance (focus on correctness first)
- Refactor unrelated modules not affected by semantic change
- Change non-temporal modal operators (box/diamond unchanged)
- Alternative approaches (atom freshness was attempted in implementation-001.md, now superseded)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Density proof fails | Blocking | 20% | Literature provides alternative constructions (Goldblatt Ch. 7) |
| Cascading breakage extensive | High | 70% | Feature branch, incremental verification, `lake build` after each file |
| Hidden dependencies on strict `<` | Medium | 30% | `grep -rn "s < t\|t < s" Theories/` to find all uses |
| Effort exceeds estimate | Medium | 70% | Timebox phases, accept partial completion, mark [BLOCKED] if stuck |
| T-axiom soundness complex | Low | 10% | Trivial with `le_refl`; research confirms direct proof |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalIrreflexivity.lean` (lines ~1273, ~1356) - these are in UNUSED code (module not imported)
- The `canonicalR_irreflexive` axiom in `CanonicalIrreflexivityAxiom.lean` is the ACTIVE technical debt

### Expected Resolution
- Phase 8 completes the Gabbay IRR proof using T-axiom, eliminating both sorries
- Phase 9 replaces the axiom with a theorem

### New Sorries
- None. NEVER introduce new sorries. If any proof cannot be completed:
  - Mark phase [BLOCKED] with `requires_user_review: true`
  - Document exact blocker and attempted approaches
  - User decides: revise plan, split task, or change approach

### Remaining Debt
After this implementation:
- 0 sorries expected in scope
- `canonicalR_irreflexive` becomes a theorem (zero axiom debt)
- Completeness chain becomes axiom-free for this property

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom: `canonicalR_irreflexive` in `CanonicalIrreflexivityAxiom.lean` (lines 95-96)
- This axiom asserts irreflexivity of canonical accessibility relation

### Expected Resolution
- Phase 8-9: Complete Gabbay IRR proof using T-axiom
- Structural proof: T-axiom gives `H(neg(p)) in M' --> neg(p) in M'`, completing Step 6

### New Axioms
- None. The T-axioms are SOUND (provable from semantics), not new assumptions

### Remaining Debt
After this implementation:
- 0 axioms expected in scope
- `canonicalR_irreflexive` becomes provable theorem
- Publication-ready: no axiom disclosure required for irreflexivity property

## Implementation Phases

### Phase 0: Documentation Update - ROAD_MAP.md and Code Comments [COMPLETED]

- **Dependencies:** None
- **Goal:** Update documentation to reflect the decision to use reflexive G/H semantics

**Rationale**: Before changing code, update all documentation that warns against reflexive semantics. This ensures:
1. Future readers understand the current approach is reflexive
2. No stale warnings remain after the refactor
3. The decision is properly recorded in ROAD_MAP.md

**Tasks:**
- [ ] Update ROAD_MAP.md "Dead End: Reflexive G/H Semantics Switch" (lines 626-648):
  - Change status from ABANDONED to REVISED/ADOPTED
  - Update "Why It Failed" to "Why It Was Initially Abandoned"
  - Add section explaining research-002.md findings that density does NOT trivialize
  - Add "Superseded By: Reflexive semantics adopted per task 967"
- [ ] Update ROAD_MAP.md "Decision: Irreflexive G/H Semantics" (lines 232-244):
  - Change to "Decision: Reflexive G/H Semantics (Revised)"
  - Update context to explain the reversal
  - Update consequences to reflect T-axiom validity
- [ ] Update Truth.lean module docstring (lines 10-23):
  - Change "IRREFLEXIVE" to "REFLEXIVE"
  - Change "strictly future/past" to "present and future/past"
  - Change `<` references to `<=`
- [ ] Update Truth.lean inline comments (lines 40-42, 199, 212, 415):
  - Replace "irreflexive" with "reflexive"
  - Replace "strictly past/future" with "present and past/future"
- [ ] Run `lake build Theories/Bimodal/Semantics/Truth.lean` to verify comments don't break syntax
- [ ] Commit documentation changes separately before code changes

**Timing:** 1 hour

**Files to modify:**
- `specs/ROAD_MAP.md` - 2 sections
- `Theories/Bimodal/Semantics/Truth.lean` - comments only (no code changes yet)

**Verification:**
- `grep -n "irreflexive" Truth.lean` returns empty (all replaced)
- `grep -n "ABANDONED" ROAD_MAP.md | grep -i reflexive` returns empty
- `lake build Theories/Bimodal/Semantics/Truth.lean` still compiles

---

### Phase 1: Semantic Foundation - Truth.lean [COMPLETED]

- **Dependencies:** Phase 0
- **Goal:** Change temporal operator semantics from strict (<) to reflexive (<=)

**Tasks:**
- [ ] Read Truth.lean lines 118-119 to confirm exact change locations
- [ ] Change line 118: `s < t` to `s <= t` for `Formula.all_past`
- [ ] Change line 119: `t < s` to `t <= s` for `Formula.all_future`
- [ ] Run `lake build Theories/Bimodal/Semantics/Truth.lean`
- [ ] Document any immediate compilation errors (expected in dependent modules)

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Semantics/Truth.lean` - lines 118-119

**Verification:**
- `lake build Theories/Bimodal/Semantics/Truth.lean` compiles (module-level)
- Semantic change is two characters: `<` → `<=` (twice)

---

### Phase 2: Add T-Axioms - Axioms.lean [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Add temporal T-axioms to the TM logic axiom set

**Tasks:**
- [ ] Add `temp_t_future` constructor: `Axiom ((Formula.all_future phi).imp phi)`
- [ ] Add `temp_t_past` constructor: `Axiom ((Formula.all_past phi).imp phi)`
- [ ] Add docstrings explaining T-axiom semantics
- [ ] Update `Axiom.isDenseCompatible`, `Axiom.isDiscreteCompatible`, `Axiom.isBase` predicates to include T-axioms
- [ ] Run `lake build Theories/Bimodal/ProofSystem/Axioms.lean`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Axioms.lean` - add 2 constructors + predicates

**Verification:**
- `lake build Theories/Bimodal/ProofSystem/Axioms.lean` passes
- T-axioms correctly typed

---

### Phase 3: T-Axiom Soundness - Soundness.lean [COMPLETED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Prove T-axioms are valid under reflexive semantics

**Tasks:**
- [ ] Add `temp_t_future_valid` theorem proving `valid ((Formula.all_future phi).imp phi)`
- [ ] Add `temp_t_past_valid` theorem proving `valid ((Formula.all_past phi).imp phi)`
- [ ] Proof strategy: use `le_refl t` to get witness for reflexive condition
- [ ] Update `axiom_base_valid`, `axiom_valid_dense`, `axiom_valid_discrete` to include T-axiom cases
- [ ] Run `lake build Theories/Bimodal/Metalogic/Soundness.lean`

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Soundness.lean` - add soundness proofs and case handlers

**Verification:**
- `lake build Theories/Bimodal/Metalogic/Soundness.lean` passes
- `lean_goal` shows "no goals" at end of each T-axiom proof

---

### Phase 4: Core Soundness Cascade - Fix Build Errors [COMPLETED]

**Note**: Phase 4 was effectively completed as part of Phase 3. All soundness cascade fixes were applied during the T-axiom soundness work, and the full `lake build` passes (743 jobs).

---

### Phase 5: DensityFrameCondition.lean Rewrite [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Fix immediate compilation errors in soundness-related modules

**Tasks:**
- [ ] Run `lake build` to identify all affected modules
- [ ] Fix `temp_4_valid`: transitivity proof changes (`lt_trans` to `le_trans`)
- [ ] Fix `density_valid`: adjust case analysis for reflexive `F(phi)`
- [ ] Fix `seriality_future_valid` / `seriality_past_valid`: now trivially true (witness = current time)
- [ ] Fix any `TimeShift.time_shift_preserves_truth` usages affected by `<=`
- [ ] Run `lake build Theories/Bimodal/Metalogic/` to verify metalogic modules

**Timing:** 2-4 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Soundness.lean` - multiple theorems
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` - if affected
- `Theories/Bimodal/Semantics/Truth.lean` - TimeShift module if needed

**Verification:**
- `lake build Theories/Bimodal/Metalogic/` passes
- All soundness theorems complete without sorry

---

### Phase 5: DensityFrameCondition.lean Rewrite [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Rewrite density frame condition proofs for reflexive semantics

**Critical Analysis** (from research-002.md):
Under reflexive semantics with T-axiom:
- Case B (`G(delta) in M, delta not in M`) becomes problematic
- T-axiom implies `G(delta) in M --> delta in M` for any MCS respecting T-axiom
- Case analysis structure must change: Case B essentially disappears for well-formed MCSs

**Tasks:**
- [ ] Analyze current proof structure (lines 198-239)
- [ ] Understand how T-axiom affects Case B1 and B2
- [ ] Rewrite `density_frame_condition` theorem for reflexive MCS handling
- [ ] Update helper lemmas: `caseB_M_not_reflexive`, `caseB_G_neg_not_in_M`
- [ ] Rewrite `density_frame_condition_caseA` if witnessing logic changes
- [ ] Update strict density theorems: `density_frame_condition_caseA_strict`, `density_frame_condition_reflexive_source`
- [ ] Run `lake build Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

**Timing:** 8-20 hours (HIGH VARIANCE - this is the hardest phase)

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - major rewrite

**Verification:**
- `lake build` for module passes
- `grep -n "sorry" DensityFrameCondition.lean` returns empty
- Theorem statements unchanged (only proof internals change)

---

### Phase 6: Seriality and Timeline Restructuring [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Restructure seriality axiom handling for reflexive semantics

**Analysis**:
Under reflexive semantics:
- `F(neg bot)` becomes trivially true: witness s = t satisfies `t <= s` and `neg bot` is always true
- Similarly for `P(neg bot)`
- NoMaxOrder/NoMinOrder derivations need different justification

**Tasks:**
- [ ] Update CantorPrereqs.lean seriality proofs
- [ ] Update DenseTimeline.lean NoMaxOrder/NoMinOrder proofs
- [ ] Update DiscreteTimeline.lean if affected
- [ ] Fix any StagedExecution.lean proofs using strict ordering assumptions
- [ ] Run `lake build Theories/Bimodal/Metalogic/StagedConstruction/`
- [ ] Run `lake build Theories/Bimodal/Metalogic/Domain/`

**Timing:** 4-8 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorPrereqs.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`
- `Theories/Bimodal/Metalogic/Domain/DenseTimeline.lean`
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`

**Verification:**
- `lake build` for all modified modules passes
- No new sorries introduced

---

### Phase 7: Fix CanonicalIrreflexivity.lean Type Errors [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Fix pre-existing String/Atom type mismatches before completing proof

**Context** (from implementation-summary-20260315.md):
The file `CanonicalIrreflexivity.lean` has pre-existing type errors:
- Formula.lean was updated to use Atom type
- CanonicalIrreflexivity.lean still uses `(p : String)` in places
- This causes `Formula.atom p` type errors

**Tasks:**
- [ ] Read CanonicalIrreflexivity.lean to identify all String -> Atom mismatches
- [ ] Fix type signatures: `atomFreeSubset`, `namingSet`, helper theorems
- [ ] Use `Atom.mk` constructor where needed
- [ ] Run `lake build Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- [ ] File should compile with the 2 existing sorries (not new errors)

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - type fixes only

**Verification:**
- Module compiles (may have sorries, but no type errors)
- `grep -c "String" CanonicalIrreflexivity.lean` in signature positions returns 0

---

### Phase 8: Complete Gabbay IRR Proof [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Complete the Gabbay IRR proof using T-axiom

**Key Insight** (from research-002.md):
With T-axiom, Step 6 of Gabbay IRR becomes:
```
H(neg(p)) in M' --[T-axiom: H(phi)->phi]--> neg(p) in M'
```
This is exactly what was blocked without T-axiom.

**Tasks:**
- [ ] Locate the 2 sorries (around lines 1273, 1356)
- [ ] Apply T-axiom to derive `neg(p) in M'` from `H(neg(p)) in M'`
- [ ] Complete both sorry proofs
- [ ] Verify `canonicalR_irreflexive` theorem is now fully proven
- [ ] Run `lake build Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Timing:** 5-10 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - complete 2 sorries

**Verification:**
- `grep -n "sorry" CanonicalIrreflexivity.lean` returns empty
- Module compiles without errors

---

### Phase 9: Replace Axiom with Theorem [NOT STARTED]

- **Dependencies:** Phase 8
- **Goal:** Convert `canonicalR_irreflexive` from axiom to theorem

**Tasks:**
- [ ] Read CanonicalIrreflexivityAxiom.lean (lines 82-96)
- [ ] Import CanonicalIrreflexivity.lean (where theorem is now proven)
- [ ] Replace `axiom canonicalR_irreflexive` with `theorem canonicalR_irreflexive := ...`
- [ ] Update module docstring to reflect resolved status
- [ ] Remove references to "axiom debt" and "resolution path"
- [ ] Run `lake build Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Timing:** 30 minutes

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - axiom -> theorem

**Verification:**
- `grep -n "^axiom " CanonicalIrreflexivityAxiom.lean` returns empty
- Module compiles with theorem reference

---

### Phase 10: Cascading Proof Fixes [NOT STARTED]

- **Dependencies:** Phase 9
- **Goal:** Fix all remaining compilation errors throughout codebase

**Strategy**:
1. Run `lake build` to get full error list
2. Group errors by module
3. Fix in dependency order (leaf modules first)
4. Commit after each module group

**Tasks:**
- [ ] Run `lake build 2>&1 | head -100` to sample errors
- [ ] Create list of affected modules
- [ ] Fix each module in order:
  - [ ] Theorems/*.lean files
  - [ ] Metalogic/Core/*.lean files
  - [ ] Metalogic/Bundle/*.lean files
  - [ ] Metalogic/Canonical/*.lean files
  - [ ] Metalogic/StagedConstruction/*.lean files
  - [ ] Metalogic/Domain/*.lean files
  - [ ] ConservativeExtension/*.lean files (if affected)
- [ ] Run `lake build` after each module group

**Timing:** 20-40 hours (HIGH VARIANCE - depends on cascade extent)

**Files to modify:**
- Multiple files throughout `Theories/Bimodal/` - determined by build errors

**Verification:**
- `lake build` passes with no errors
- `grep -rn "sorry" Theories/Bimodal/` shows no new sorries

---

### Phase 11: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 10
- **Goal:** Final verification that all goals are met

**Tasks:**
- [ ] Run `lake clean && lake build` for full rebuild
- [ ] Verify `grep -rn "\bsorry\b" Theories/Bimodal/` shows no new sorries
- [ ] Verify `grep -rn "^axiom " Theories/Bimodal/Metalogic/Canonical/` shows only expected axioms
- [ ] Verify `canonicalR_irreflexive` is a theorem, not axiom
- [ ] Verify ROAD_MAP.md accurately reflects completed refactor
- [ ] Create implementation summary

**Timing:** 2 hours

**Files to modify:**
- `specs/ROAD_MAP.md` - final updates if needed
- `docs/` - if needed for documentation updates

**Verification:**
- `lake build` passes
- All task goals verified
- Documentation accurate

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/` returns no new sorries
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` shows no axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"
- [ ] T-axiom soundness proven (not assumed)

### Semantic Correctness
- [ ] `G(phi)` now means "phi at t AND all s >= t"
- [ ] `H(phi)` now means "phi at t AND all s <= t"
- [ ] T-axioms `G(phi)->phi` and `H(phi)->phi` are valid

### No Regressions
- [ ] All existing theorems still hold
- [ ] Completeness chain unbroken
- [ ] No new technical debt introduced

## Artifacts & Outputs

- `specs/967_change_atom_type_for_freshness/plans/implementation-003.md` (this file)
- `specs/967_change_atom_type_for_freshness/summaries/implementation-summary-YYYYMMDD.md` (on completion)
- Modified Lean files throughout `Theories/Bimodal/`

## Rollback/Contingency

**If implementation fails:**
1. All changes are on feature branch; main is unaffected
2. Can `git checkout main` to restore original state
3. `canonicalR_irreflexive` axiom remains in place (status quo)
4. Document failure reason in research report for future reference

**If partial completion:**
1. Mark incomplete phases as [BLOCKED] with blockers documented
2. Commit partial progress
3. May accept partial result if axiom is still unused in active completeness chain

**Escape Valves:**
- If any phase is stuck >4 hours without progress: mark [BLOCKED], request user review
- If total effort exceeds 100 hours: evaluate whether to continue or accept axiom-based approach
- If density proof fundamentally fails: research alternative constructions (Goldblatt Ch. 7)

## Revision History

| Version | Date | Changes |
|---------|------|---------|
| v001 | 2026-03-15 | Initial plan (atom freshness approach) - BLOCKED |
| v002 | 2026-03-15 | Revised for reflexive semantics refactor |
| v003 | 2026-03-15 | Added Phase 0 (documentation update before code changes) |
