# Implementation Plan: Task #881 (Revised)

- **Task**: 881 - Modally Saturated BMCS Construction
- **Status**: [PARTIAL]
- **Effort**: 6-8 hours
- **Dependencies**: None (builds on existing SaturatedConstruction.lean infrastructure)
- **Research Inputs**: research-004.md, research-005.md (team research on path forward and Int safety)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This revised plan abandons the TemporalLindenbaum approach (proven flawed in task 882) and implements the recommended path forward from research-004.md. The strategy is: (1) specialize the axiom to Int for immediate simplification, (2) implement an omega-step interleaving construction that avoids Lindenbaum extension issues, (3) wire the construction to eliminate the axiom. The DovetailingChain approach is kept as fallback if interleaving proves difficult.

### Research Integration

Reports integrated: research-004.md (path forward after task 882 failure), research-005.md (Int specialization safety analysis)

Key findings:
- TemporalLindenbaum is a DEAD END - counterexample: base = {F(p), not p} is consistent but Henkin package {F(p), p} conflicts with base
- Modal saturation is SOLVED - `exists_fullySaturated_extension` in SaturatedConstruction.lean is sorry-free
- Int specialization is SAFE - no density axioms in the logic, soundness covers all frames
- Omega-step interleaving avoids known problems by building uniformly (no separate forward/backward chains)
- DovetailingChain has 4 sorries with simplest structure (fallback approach)

### Why This Plan Differs from implementation-001.md

The previous plan (phases 4-5) was blocked because it relied on TemporalLindenbaum which was proven to have fundamental flaws in task 882. This revised plan:
1. Does NOT use TemporalLindenbaum or henkinLimit
2. Specializes to Int immediately (removes unnecessary generality)
3. Uses omega-step interleaving to construct witnesses (avoids Henkin base case issue)
4. Has DovetailingChain as explicit fallback (simpler sorry structure)

## Goals & Non-Goals

**Goals**:
- Eliminate the `fully_saturated_bmcs_exists` axiom in TemporalCoherentConstruction.lean
- Specialize axiom to Int (matches all downstream usage, enables omega-step construction)
- Create InterleaveConstruction.lean implementing omega-step witness placement
- Wire constructive proof to replace axiom usage
- Zero new sorries in the construction

**Non-Goals**:
- Fixing TemporalLindenbaum.lean sorries (dead end per task 882)
- Generic D support (Int is sufficient for completeness)
- Eliminating DovetailingChain.lean sorries (only if fallback needed)
- Proving anything for dense time types (Rat, Real)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Omega-step interleaving more complex than expected | Medium | Medium | Fall back to DovetailingChain 4-sorry fix approach |
| GContent inclusion from all prior times creates consistency issues | High | Low | Use S5 axiom 5 for BoxContent invariance (proven technique from Phase 2) |
| Lindenbaum at each time point disturbs prior temporal witnesses | Medium | Low | Place ALL temporal witnesses in seed before Lindenbaum (RecursiveSeed pattern) |
| Int specialization breaks existing code | Low | Low | research-005.md confirms no density axioms; update downstream usages |

## Sorry Characterization

### Pre-existing Sorries
- 1 sorry in `fully_saturated_bmcs_exists_constructive` (SaturatedConstruction.lean) - depends on abandoned TemporalLindenbaum
- 4 sorries in DovetailingChain.lean (forward_G cross-sign, backward_H cross-sign, forward_F witness, backward_P witness)

### Expected Resolution
- Phase 2 creates new InterleaveConstruction.lean with omega-step construction
- Phase 3 wires construction, removing sorry from `fully_saturated_bmcs_exists_constructive`
- DovetailingChain sorries remain unless fallback path chosen

### New Sorries
- None expected. All temporal witnesses placed in seed before Lindenbaum extension.

### Remaining Debt
After this implementation:
- 0 sorries on axiom critical path (axiom eliminated)
- DovetailingChain.lean 4 sorries remain (alternative approach)
- TemporalLindenbaum.lean sorries remain (dead end, not on critical path)

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in TemporalCoherentConstruction.lean: `fully_saturated_bmcs_exists` (line 773)

### Expected Resolution
- Phase 1 specializes axiom to Int
- Phase 3 eliminates axiom via constructive proof from InterleaveConstruction.lean
- Structural proof approach: omega-step interleaving with explicit witness placement

### New Axioms
- None. NEVER introduce new axioms. All gaps resolved through constructive proofs.

### Remaining Debt
After this implementation:
- 0 axioms for modal saturation
- Completeness theorem axiom-free for Int-indexed canonical models

## Implementation Phases

### Phase 1: Specialize Axiom to Int [COMPLETED]

- **Dependencies:** None
- **Goal:** Replace polymorphic D with Int in axiom and downstream usages

**Tasks**:
- [ ] Add `fully_saturated_bmcs_exists_int` theorem/axiom in TemporalCoherentConstruction.lean
- [ ] Update `construct_saturated_bmcs` to use Int-specialized version
- [ ] Update `construct_saturated_bmcs_contains_context`, `construct_saturated_bmcs_temporally_coherent`, `construct_saturated_bmcs_is_modally_saturated` signatures
- [ ] Check Completeness.lean uses - should already work with Int
- [ ] Deprecate or remove polymorphic `fully_saturated_bmcs_exists`
- [ ] Verify with `lake build`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Add Int-specialized axiom
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Verify/update usages (if needed)

**Verification**:
- `lake build` succeeds
- All completeness theorems still compile
- Polymorphic axiom deprecated or removed

---

### Phase 2: Create InterleaveConstruction.lean [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Implement omega-step interleaving construction for temporal witness placement

This is the core phase. The construction works by:
1. Enumerating all obligations: (t, G phi), (t, H phi), (t, F phi), (t, P phi) pairs
2. Building partial assignments step-by-step
3. At each step, extending to satisfy the next obligation
4. Taking limit and applying Lindenbaum to each time point

**Tasks**:
- [ ] Create `Theories/Bimodal/Metalogic/Bundle/InterleaveConstruction.lean`
- [ ] Define `Obligation` type: (time: Int, formula: Formula, kind: G|H|F|P)
- [ ] Define `enumerateObligations`: produces countable list of all (t, phi, kind) triples
- [ ] Define `PartialFamilyAssignment`: maps Int -> Option (Set Formula)
- [ ] Define `extendForObligation`: given obligation, extends partial assignment
  - For G phi at t: ensure phi is in seed for all s >= t (already assigned AND future assignments)
  - For H phi at t: ensure phi is in seed for all s <= t
  - For F phi at t: create witness at t+1 with phi (or next unassigned time > t)
  - For P phi at t: create witness at t-1 with phi (or next unassigned time < t)
- [ ] Define `interleaveLimit`: omega-step limit of extensions
- [ ] Prove `interleaveLimit_consistent`: each time point has consistent seed
- [ ] Prove `interleaveLimit_forward_G`: G phi at t implies phi at all s >= t
- [ ] Prove `interleaveLimit_backward_H`: H phi at t implies phi at all s <= t
- [ ] Prove `interleaveLimit_forward_F`: F phi at t implies witness at some s > t
- [ ] Prove `interleaveLimit_backward_P`: P phi at t implies witness at some s < t
- [ ] Apply `set_lindenbaum` to each time point seed to get MCS family
- [ ] Prove `interleave_family_temporally_coherent`: forward_F and backward_P hold after Lindenbaum
- [ ] Verify with `lake build`

**Key Design Insight (RecursiveSeed pattern)**:
All temporal witnesses are placed in the seed BEFORE Lindenbaum extension. This avoids the TemporalLindenbaum problem where Henkin packages conflict with the base.

**Key Design Insight (omega-step enumeration)**:
The dovetailing enumeration covers all (time, formula, obligation-type) triples:
```
(0, phi_0, G), (0, phi_0, H), (0, phi_0, F), (0, phi_0, P),
(1, phi_0, G), (-1, phi_0, G), (1, phi_0, H), (-1, phi_0, H), ...
(0, phi_1, G), ...
```
This ensures every obligation is eventually addressed.

**Key Design Insight (GContent inclusion)**:
For G phi at time t, the construction must include phi in ALL times (both already-assigned AND future). This is handled by:
- Adding phi to seeds of already-assigned times
- Adding phi to a "universal GContent" set that gets included in all future assignments

**Timing**: 3-4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/InterleaveConstruction.lean`

**Files to modify**:
- `Theories/Bimodal.lean` - Add import

**Verification**:
- `lake build` succeeds
- No sorries in InterleaveConstruction.lean (or documented with clear remediation)
- `interleave_family_temporally_coherent` theorem compiles

**Blocking Issue (Task 881 Session sess_1771024479_16a793)**:
The core problem is that combining temporal coherence with modal saturation is non-trivial:
1. **Temporal coherence** (from DovetailingChain) gives us a single temporally-coherent family
2. **Modal saturation** (from exists_fullySaturated_extension) adds witness families via Zorn
3. **The new witness families** are constant (same MCS at all times)
4. **Constant families need temporally-saturated MCS** (F psi -> psi, P psi -> psi in MCS)
5. **Temporally-saturated MCS requires Henkin-style construction** which is proven flawed

The InterleaveConstruction approach would build ALL families together uniformly, avoiding
the need to combine separate temporal and modal constructions. However, this requires
significant new infrastructure not covered by existing codebase.

**Alternative Approach Identified**: Restructure truth lemma to only require temporal
coherence for eval_family (not all families). This would allow the existing constructions
to be combined without the Henkin requirement.

---

### Phase 3: Wire Construction to Replace Axiom [BLOCKED]

- **Dependencies:** Phase 2
- **Goal:** Replace `fully_saturated_bmcs_exists_int` axiom with constructive proof

**Tasks**:
- [ ] Import InterleaveConstruction.lean in TemporalCoherentConstruction.lean
- [ ] Create `fully_saturated_bmcs_exists_int_constructive` theorem:
  - Use `interleave_family` for temporal coherence
  - Use `exists_fullySaturated_extension` for modal saturation (already sorry-free)
  - Combine to produce BMCS with all required properties
- [ ] Verify BMCS properties:
  - Context preserved at eval_family.mcs 0
  - temporally_coherent (forward_F, backward_P)
  - is_modally_saturated (witness families exist)
- [ ] Replace axiom usage in `construct_saturated_bmcs` with theorem
- [ ] Remove or deprecate `fully_saturated_bmcs_exists_int` axiom
- [ ] Update module docstrings
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Wire construction, remove axiom
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Update summary docstrings

**Verification**:
- `lake build` succeeds
- `grep -r "axiom fully_saturated_bmcs_exists"` returns 0 matches (or shows deprecated)
- Completeness theorems still compile
- `construct_saturated_bmcs` is sorry-free and axiom-free

---

### Phase 4: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify full build, count technical debt, document completion

**Tasks**:
- [ ] Run full `lake build` to verify no regressions
- [ ] Count remaining sorries in Bundle module:
  - Should be: DovetailingChain (4), TemporalLindenbaum (5+), ZornFamily (deprecated)
  - Should NOT be: SaturatedConstruction.lean, InterleaveConstruction.lean, TemporalCoherentConstruction.lean
- [ ] Count remaining axioms in Bundle module:
  - Should be: 0 on critical path (all deprecated axioms removed)
- [ ] Update module docstrings with axiom elimination status
- [ ] Create implementation summary
- [ ] Update state.json with completion_summary

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/*.lean` - Docstring updates
- `specs/881_modally_saturated_bmcs_construction/summaries/implementation-summary-YYYYMMDD.md` - Create

**Verification**:
- `lake build` succeeds
- Axiom count on critical path = 0
- Completeness theorem (`bmcs_strong_completeness`) is axiom-free

---

## Fallback: Fix DovetailingChain Instead of InterleaveConstruction

If Phase 2 (InterleaveConstruction) proves difficult, the fallback is to fix DovetailingChain.lean's 4 sorries instead.

### Fallback Phase 2-Alt: Fix DovetailingChain Sorries [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Fix the 4 sorries in DovetailingChain.lean

**Tasks**:
- [ ] Fix `forward_G` cross-sign (line 606):
  - When t < 0, G phi at t means phi holds at all s >= t
  - The backward chain at t includes G phi, so the forward chain at s >= 0 should include phi
  - Solution: Include GContent from all assigned times (both forward and backward chains)
- [ ] Fix `backward_H` cross-sign (line 617):
  - Symmetric to forward_G
- [ ] Fix `forward_F` witness (line 633):
  - F phi at t means phi holds at some s > t
  - Solution: Enumerate (formula, time) witness pairs and place them explicitly
  - Use dovetailing: place witness for F phi_n at time t at step (n, t)
- [ ] Fix `backward_P` witness (line 640):
  - Symmetric to forward_F
- [ ] Verify with `lake build`

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`

**Verification**:
- All 4 sorries eliminated
- `temporal_coherent_family_exists_theorem` is sorry-free

Then continue with Phase 3 using DovetailingChain instead of InterleaveConstruction.

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -r "axiom fully_saturated_bmcs_exists"` returns 0 matches after Phase 3
- [ ] `grep -r "sorry" InterleaveConstruction.lean` returns 0 matches after Phase 2
- [ ] Completeness.lean theorems remain valid and compile
- [ ] TruthLemma.lean continues to compile without changes

## Artifacts & Outputs

- `plans/implementation-002.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- New Lean file:
  - `Theories/Bimodal/Metalogic/Bundle/InterleaveConstruction.lean`
- Modified Lean files:
  - `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean`
  - `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` (docstrings)
  - `Theories/Bimodal.lean` (imports)

## Rollback/Contingency

If implementation fails:
1. Git revert to pre-implementation commit
2. Restore polymorphic axiom if Int specialization caused issues
3. Document blocking issues in error report
4. Consider DovetailingChain fallback path

If InterleaveConstruction proves infeasible:
1. Use fallback Phase 2-Alt to fix DovetailingChain sorries instead
2. Wire DovetailingChain to axiom elimination
3. Document why InterleaveConstruction approach failed
