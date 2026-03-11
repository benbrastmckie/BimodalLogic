# Implementation Plan: Task #957 - Density Frame Condition Under Irreflexive Temporal Semantics (v2)

- **Task**: 957 - density_frame_condition_irreflexive_temporal
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: Task 956 Phase 5 (BLOCKED, this task unblocks it)
- **Research Inputs**: research-001.md (original), research-002.md (Case B analysis)
- **Artifacts**: plans/implementation-002.md (this file), implementation-001.md (prior, superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

**Revised strategy based on research-002 findings:**

Research-002 proved definitively that:
1. **Case A formulas do NOT always exist** under irreflexive semantics
2. **The seed {neg(delta)} ∪ GContent(M) is INCONSISTENT in Case B** because delta ∈ GContent(M) (from G(delta) ∈ M)
3. No formula transformation produces the required neg(delta) witness for temporal linearity

**New approach: Option C (Staged Construction Case A Guarantee)**

Instead of proving the general density frame condition for arbitrary MCS pairs, we prove:
1. The staged construction only produces MCS pairs where Case A holds
2. Use the existing `density_frame_condition_caseA` (proven in implementation-001) for these pairs
3. The sorry in `density_frame_condition` remains, but task 956 uses the staged construction path which bypasses it

This is the most efficient resolution (100-200 lines estimated) vs selective Lindenbaum (400-600 lines).

### Prior Work (From implementation-001)

- **Phase 1-2 COMPLETED**: `density_frame_condition_caseA` handles Case A with double-density trick
- **Phase 3 BLOCKED**: `density_frame_condition` has sorry in Case B (research-002 proved this is not resolvable via Case A reduction)
- **File**: `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean`

## Goals & Non-Goals

**Goals**:
- Prove `staged_density_always_caseA`: In the staged construction, between any two adjacent MCS, a Case A distinguishing formula exists
- Integrate with StagedExecution.lean to use `density_frame_condition_caseA` for staged density
- Unblock task 956 Phase 5 (`staged_timeline_densely_ordered`)
- Zero sorries in the staged construction path

**Non-Goals**:
- Resolving the sorry in general `density_frame_condition` (Case B is mathematically genuine)
- Proving selective Lindenbaum infrastructure (Option A - too heavy)
- Using lexicographic product (forbidden per task description)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Staged construction can produce Case B pairs | HIGH | LOW | Analyze odd-stage insertion strategy; the construction explicitly controls distinguishing formulas |
| Integration with StagedExecution.lean is complex | MEDIUM | MEDIUM | Read existing density_witness_exists and staged patterns first |
| Proof structure differs from expected | MEDIUM | MEDIUM | May need to add intermediate lemmas about staged construction invariants |

## Sorry Characterization

### Pre-existing Sorries
- `density_frame_condition` (Case B branch) - 1 sorry in DensityFrameCondition.lean

### Expected Resolution
- **NOT resolving**: The `density_frame_condition` sorry remains (Case B is mathematically irreducible)
- **NEW APPROACH**: Staged construction bypass - prove density via Case A guarantee

### New Sorries
- None. The staged path will be sorry-free. If staged Case A guarantee cannot be proven:
  - Mark phase [BLOCKED] with requires_user_review: true
  - Fall back to Option B (constructive density during staged construction)

### Remaining Debt
After this implementation:
- 1 sorry in general `density_frame_condition` (acceptable - not used by staged path)
- 0 sorries in staged construction density path
- Task 956 Phase 5 unblocked

## Implementation Phases

### Phase 1: Analyze Staged Construction [COMPLETED]

- **Dependencies:** None
- **Goal:** Understand how the staged construction creates MCS pairs and identify Case A guarantee

**Tasks**:
- [ ] Read `StagedExecution.lean` to understand odd/even stage structure
- [ ] Read `density_witness_exists` and related lemmas
- [ ] Identify where distinguishing formulas are chosen in the construction
- [ ] Document the invariant: why staged pairs always have Case A formulas

**Timing**: 0.5 hours

**Files to read**:
- `Theories/Bimodal/Metalogic/StagedConstruction/StagedExecution.lean`
- `Theories/Bimodal/Metalogic/StagedConstruction/WitnessSeedWrapper.lean`
- `Theories/Bimodal/Metalogic/ConstructiveFragment.lean`

**Verification**:
- Document findings in Progress section
- Identify exact location where Case A guarantee proof will hook in

---

### Phase 2: Prove Staged Case A Lemma [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Prove that staged construction pairs always have Case A distinguishing formulas

**Tasks**:
- [ ] Add lemma `staged_pair_has_caseA_formula`: For MCS pairs (M, M') produced by staged construction, exists delta with G(delta) ∈ M', delta ∉ M, G(delta) ∉ M
- [ ] Key insight: The staged construction uses explicit F-obligations to create forward witnesses; these F-obligations come from formulas with G(phi) NOT in the source MCS
- [ ] Alternative formulation: Show that odd-stage insertion uses a seed derived from Case A conditions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add staged Case A lemma

**Verification**:
- `lean_goal` shows "no goals" at end of proof
- `lake build` passes

---

### Phase 3: Integrate with density_frame_condition_caseA [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Wire staged Case A guarantee to existing caseA theorem

**Tasks**:
- [ ] Add `staged_density_intermediate`: For staged pairs, use `staged_pair_has_caseA_formula` + `density_frame_condition_caseA` to produce intermediate W
- [ ] Verify the theorem signature matches what StagedExecution.lean needs for `staged_timeline_densely_ordered`
- [ ] Add any adapter lemmas if signatures differ slightly

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add integration theorem

**Verification**:
- `lean_goal` shows "no goals"
- `lake build` passes
- Theorem usable for task 956 Phase 5

---

### Phase 4: Verification and Unblock Task 956 [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Verify zero-debt staged path and prepare for task 956

**Tasks**:
- [ ] Run `lake build` on full project
- [ ] Verify staged path has no sorries: check `density_frame_condition_caseA` and `staged_density_intermediate`
- [ ] Document that general `density_frame_condition` sorry remains (Case B is mathematically genuine)
- [ ] Verify theorem signature enables task 956 Phase 5 to proceed
- [ ] Update task 956 blocked_reason if needed

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - add docstrings
- `specs/state.json` - update task 956 blocked_reason if resolved

**Verification**:
- `lake build` passes with only the expected `density_frame_condition` Case B sorry warning
- Staged density path is sorry-free
- Task 956 Phase 5 requirements satisfied

## Progress

**Prior session (implementation-001):**
- Completed: Phases 1-2 (Case A double-density trick, `density_frame_condition_caseA`)
- Blocked: Phases 3-4 (Case B sorry, research-002 proved Case A reduction impossible)

**This revision:**
- New approach: Option C (staged construction Case A guarantee)
- Abandons attempt to resolve general Case B
- Uses existing `density_frame_condition_caseA` via staged path

**Session: 2026-03-10, sess_1773180949_938468**

Phase 1 COMPLETED - Exhaustive analysis of Option C viability:

- Analyzed: StagedExecution.lean (976 lines) - odd/even stage structure, density witness insertion
- Analyzed: WitnessSeedWrapper.lean (241 lines) - forward/backward witness seeds, density_witness_exists
- Analyzed: SeparationLemma.lean (227 lines) - distinguishing_formula_exists, not_G_implies_F_neg
- Analyzed: CantorPrereqs.lean (423 lines) - encoding sufficiency, NoMaxOrder/NoMinOrder
- Analyzed: StagedTimeline.lean (255 lines) - StagedPoint ordering, union type

Key findings from analysis:

1. **Option C (staged Case A guarantee) is NOT provable.** The staged construction uses
   standard Lindenbaum extensions (via Zorn's lemma / classical choice) which give no
   control over which G-formulas appear in the extension. A forward witness W from parent p
   can contain G(delta) for arbitrary formulas delta, including ones where G(delta) is also
   in p (making it Case B). The counterexample from research-002 Finding 1 applies equally
   to staged construction pairs.

2. **The core obstruction**: For CanonicalR(M, W) AND CanonicalR(W, M'), the seed GContent(M)
   forces G-formulas into W. These G-formulas contribute to GContent(W). If GContent(M)
   contains G(psi) (i.e., G(G(psi)) in M) and psi is NOT in M' (possible under irreflexive
   semantics where G(psi) in M' does not imply psi in M'), then GContent(W) contains psi
   but M' does not, so CanonicalR(W, M') fails.

3. **Controlled Lindenbaum (Option B simplified) also fails**: Attempting to prevent G(psi)
   with psi not in M' from entering W is inconsistent with the seed when G(psi) is already
   in GContent(M). The seed GContent(M) can contain G(psi) elements whose stripped versions
   psi are not in M' (because G(G(psi)) in M and G(psi) in M' but psi not in M' is
   consistent under irreflexive semantics).

4. **The density frame condition Case B appears to require the Gabbay IRR rule or equivalent
   infinite axiom schemas** (as identified by Di Maio/Zanardo 1998, research-002 Finding 19).
   The current axiom system (temp_a, temp_4, density, temp_linearity, seriality) is
   insufficient for proving the general density frame condition under irreflexive semantics.

5. **Alternative paths forward**:
   a. Use `density_frame_condition` with the sorry (accept debt in staged construction)
   b. Add the Gabbay IRR rule to the proof system
   c. Use lexicographic product T x Q for density (forbidden per task description)
   d. Full selective Lindenbaum with enumeration control (400-600 lines, high complexity)
   e. Prove density frame condition is UNNECESSARY for the D-from-syntax construction
      by using a different Cantor application that doesn't require DenselyOrdered

Phase 2 BLOCKED - Option C is not provable, mathematical obstruction confirmed

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes
- [ ] Staged density path is sorry-free (grep specific theorems)
- [ ] General `density_frame_condition` sorry acknowledged in docstring
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Staged density theorem signature matches task 956 Phase 5 requirements
- [ ] Proof uses only temporal axioms (no external Q or dense order imports)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DensityFrameCondition.lean` - staged Case A theorems
- `specs/957_density_frame_condition_irreflexive_temporal/plans/implementation-002.md` - this revised plan
- `specs/957_density_frame_condition_irreflexive_temporal/summaries/implementation-summary-YYYYMMDD.md` - on completion

## Rollback/Contingency

If staged Case A guarantee cannot be proven:
1. **Option B**: Constructive density during staged construction (200-400 lines)
   - Build W explicitly during the staged process rather than via Lindenbaum
   - More control over GContent(W)
2. **Option A**: Full selective Lindenbaum (400-600 lines)
   - Last resort, heavy infrastructure

If mathematically blocked:
1. Mark [BLOCKED] with requires_user_review: true
2. Document the specific obstruction
3. User decides next steps
