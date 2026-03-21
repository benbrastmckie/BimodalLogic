# Implementation Plan: Task #812

- **Task**: 812 - Canonical Model Completeness
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 809 (archival complete), Task 810 (research complete)
- **Research Inputs**: specs/812_canonical_model_completeness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This plan establishes canonical model completeness theorems via a pragmatic approach that accepts the current FMP-based architecture as the canonical sorry-free path while documenting the theoretical limitations for general validity. The key insight from research-001.md is that the Representation approach (Metalogic_v5) has architectural sorries that CANNOT be removed without changing the semantic definition of box. Rather than revive broken approaches, we will:

1. **Accept semantic_weak_completeness as the canonical result** - This FMP-internal completeness IS completely sorry-free
2. **Prove FMP-based compactness** - Derive compactness from finite model property (different proof structure than Metalogic_v5)
3. **Document the validity bridge gap** - Clearly explain why general validity completeness is architecturally blocked
4. **Clean up and consolidate** - Ensure the completeness hierarchy is clear and navigable

### Research Integration

From research-001.md:
- Box forward truth lemma is **architecturally blocked** (S5-style semantics quantify over ALL histories)
- Temporal backward sorries require omega-rule (infinitary reasoning) but are NOT needed for completeness
- The representation_theorem only uses truth_lemma_forward, so temporal backward sorries don't block
- BUT the box FORWARD sorry blocks completeness for formulas containing box
- FMP's `semantic_weak_completeness` IS sorry-free but uses FMP-internal validity

**Critical Constraint**: Task description requires "only restore elements that can be implemented sorry-free". This means:
- DO NOT revive Representation approach for general validity (has architectural sorries)
- DO NOT create workarounds with documented sorries
- FOCUS on what CAN be proven sorry-free

## Goals & Non-Goals

**Goals**:
- Prove FMP-based compactness theorem (sorry-free)
- Document the completeness hierarchy clearly
- Ensure existing sorry-free results are properly exposed
- Explain validity bridge limitation for future reference

**Non-Goals**:
- Revive Representation approach with sorries
- Achieve general validity completeness (architecturally blocked)
- Modify box semantics (out of scope, would be a separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| FMP compactness requires different proof structure | Medium | High | Research FMP-based compactness proofs before implementing |
| Validity bridge cannot be closed | High | Confirmed | Document as architectural limitation, not implementation gap |
| Scope creep into semantics changes | High | Medium | Strict adherence to "sorry-free only" constraint |

## Implementation Phases

### Phase 1: FMP-Based Compactness Theorem [NOT STARTED]

**Goal**: Prove compactness using the finite model property rather than infinitary strong completeness

**Tasks**:
- [ ] Research FMP-based compactness proof structure (different from Representation approach)
- [ ] Create `Theories/Bimodal/Metalogic/Compactness/FMPCompactness.lean`
- [ ] Prove: if every finite subset is satisfiable in FMP sense, the whole set is satisfiable
- [ ] Verify theorem compiles without sorry

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Compactness/FMPCompactness.lean`

**Key insight**: FMP-based compactness has a different proof structure:
- Traditional: InfinitaryStrongCompleteness -> Compactness
- FMP: FiniteModelProperty -> Compactness (via finitary witness)

The FMP approach shows: if phi is FMP-unsatisfiable, there's a finite derivation of bot. The contrapositive gives compactness.

**Verification**:
- `lake build Bimodal.Metalogic.Compactness.FMPCompactness` succeeds
- No `sorry` in the file

---

### Phase 2: Weak Completeness Bridge Analysis [NOT STARTED]

**Goal**: Document and potentially fix the validity bridge in FiniteStrongCompleteness

**Tasks**:
- [ ] Analyze the single sorry in `weak_completeness` theorem
- [ ] Determine if this sorry can be removed (likely NOT without changing semantics)
- [ ] If removable: implement the fix
- [ ] If not removable: document as architectural limitation with clear explanation

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/FiniteStrongCompleteness.lean`

**Expected outcome**: Either:
1. Remove the sorry (unlikely based on research)
2. Document clearly that general validity completeness requires semantics changes, and that `semantic_weak_completeness` is the canonical sorry-free result

**Verification**:
- Clear documentation in the file explaining the limitation
- If fixed: `lake build` with no sorries
- If not fixed: sorry remains but is properly documented as architectural

---

### Phase 3: Completeness Module Consolidation [NOT STARTED]

**Goal**: Clean up and consolidate the completeness hierarchy documentation

**Tasks**:
- [ ] Update `Theories/Bimodal/Metalogic/Completeness/Completeness.lean` with clear hierarchy
- [ ] Update `Theories/Bimodal/Metalogic/Compactness/README.md` to reflect new FMP compactness
- [ ] Create `Theories/Bimodal/Metalogic/Completeness/README.md` summarizing available results
- [ ] Update `Theories/Bimodal/Metalogic/Metalogic.lean` to export new theorems

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness/Completeness.lean`
- `Theories/Bimodal/Metalogic/Compactness/README.md`
- `Theories/Bimodal/Metalogic/Metalogic.lean`

**Files to create**:
- `Theories/Bimodal/Metalogic/Completeness/README.md`

**Verification**:
- All READMEs are accurate
- Module hierarchy is clear
- `lake build` succeeds

---

### Phase 4: ConsistentSatisfiable Cleanup [NOT STARTED]

**Goal**: Document or remove the sorries in ConsistentSatisfiable.lean

**Tasks**:
- [ ] Analyze the 6 sorries in `mcs_world_truth_correspondence`
- [ ] Determine if any can be proven (likely NOT for modal/temporal cases)
- [ ] Document each sorry with clear explanation of why it's architectural
- [ ] Consider if the file should be archived if it's not used by any sorry-free path

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/FMP/ConsistentSatisfiable.lean`

**Expected outcome**: Either document the sorries clearly or archive the file if it's not needed for any sorry-free completeness path.

**Verification**:
- Each sorry has clear documentation explaining the architectural limitation
- Or file is archived if not needed

---

### Phase 5: Final Verification and Summary [NOT STARTED]

**Goal**: Verify all changes compile and create implementation summary

**Tasks**:
- [ ] Run `lake build` on entire Metalogic module
- [ ] Verify sorry count is documented (not increased unexpectedly)
- [ ] Create implementation summary documenting:
  - What IS sorry-free: semantic_weak_completeness, FMP compactness
  - What has documented sorries: validity bridge, truth correspondence
  - What is archived: Representation approach
- [ ] Update specs/state.json with completion status

**Timing**: 0.5 hours

**Files to create**:
- `specs/812_canonical_model_completeness/summaries/implementation-summary-YYYYMMDD.md`

**Verification**:
- `lake build Bimodal.Metalogic` succeeds
- Summary accurately reflects codebase state

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic` compiles successfully
- [ ] `semantic_weak_completeness` remains sorry-free
- [ ] New FMP compactness theorem is sorry-free
- [ ] All documented sorries have architectural justification
- [ ] No new sorries introduced without documentation

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Compactness/FMPCompactness.lean` - New FMP-based compactness
- `Theories/Bimodal/Metalogic/Completeness/README.md` - Completeness hierarchy docs
- `specs/812_canonical_model_completeness/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If FMP compactness proves more complex than anticipated:
1. Preserve existing sorry-free results (semantic_weak_completeness)
2. Document why compactness requires the infinitary approach
3. Ensure Metalogic builds cleanly

If validity bridge cannot be closed:
1. Keep the sorry with clear documentation
2. Emphasize that `semantic_weak_completeness` IS the canonical sorry-free result
3. Document that general validity completeness is a future research direction requiring semantics changes

## Notes on Architectural Limitations

### Why General Validity Completeness is Blocked

The box semantics define:
```lean
truth_at M tau t (box psi) = forall sigma : WorldHistory F, truth_at M sigma t psi
```

This quantifies over ALL world histories, but canonical model construction only provides canonical histories built from MCS families. An arbitrary history sigma can have an arbitrary world state at time t, and that world state may not be MCS-derived.

**Possible future solutions** (out of scope for this task):
1. Change box semantics to use modal accessibility relation (Kripke-style)
2. Restrict quantification to "legitimate" histories
3. Add modal accessibility predicate relating histories

### What IS Achievable Sorry-Free

1. **semantic_weak_completeness**: FMP-internal validity implies derivability
2. **finite_strong_completeness** (with validity bridge sorry): Context-based derivability
3. **FMP-based compactness** (to be implemented): Compactness via FMP
4. **soundness**: Already sorry-free

The FMP approach provides a complete metatheory for the logic, just with a different semantic notion (FMP-internal validity vs general TaskModel validity).
