# Implementation Plan: Task #83 — Close Restricted Coherence Sorries

- **Task**: 83 - close_restricted_coherence_sorries
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None
- **Research Inputs**: reports/18_team-research.md
- **Artifacts**: plans/18_completeness-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the achievable sorries blocking `completeness_over_Int` and establish honest documentation for the remaining gap. The research confirms that forward_F is genuinely unprovable for deterministic/dovetailed chains (compactness impossibility), but backward Until/Since coherence IS closable with 90% confidence using backward induction on the deterministic chain's x_content/y_content linkage. This plan focuses on: (1) closing backward Until/Since in DeterministicFMCS, (2) fixing misleading "sorry-free" docstrings, (3) cleaning up the CanonicalConstruction sorry annotations, and (4) documenting the forward_F architectural gap honestly. The DovetailedChain path is NOT addressed for closure because it suffers from the same x_content propagation gap as forward_F; instead, the DeterministicFMCS path is the focus since its deterministic construction provides the exact x_content/y_content linkage needed for backward Until/Since.

### Research Integration

Integrated from `reports/18_team-research.md` (Round 18, 3-teammate synthesis):
- Teammate A: Exhaustive 76-sorry inventory, 4 direct + 4 transitive blocking completeness_over_Int
- Teammate B: Forward_F impossibility proof (compactness), backward Until/Since closure path with 90% confidence
- Teammate C: Axiom audit (clean), ParametricRepresentation verified, publication readiness 6/10

## Goals & Non-Goals

**Goals**:
- Close the 4 Until/Since coherence sorries in `DeterministicFMCS.usc` using backward induction + until_intro/since_intro + x_content/y_content linkage
- Fix all misleading "sorry-free" docstrings in Completeness.lean, DeterministicFMCS.lean, and DovetailedChain.lean
- Add honest documentation of the forward_F impossibility and what would be required to resolve it
- Ensure `lake build` succeeds after all changes

**Non-Goals**:
- Closing forward_F/backward_P sorries (confirmed unprovable for current chain constructions)
- Closing the 28 soundness sorries (separate concern)
- Building a new chain construction with F-resolution built in (Tier 2 effort, 25-40 hours)
- Closing the DovetailedChain Until/Since persistence sorries (different chain structure, lacks x_content linkage)
- Closing the Bundle/CanonicalConstruction restricted_shifted_truth_lemma sorries (depend on forward_F)
- Dense completeness infrastructure

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Backward Until/Since proof fails in Lean despite mathematical outline | H | L (10%) | The DeterministicChain has x_content linkage by construction; the proof outline from research is detailed and mechanically checkable. Fall back to documenting the gap honestly. |
| `until_intro` or `since_intro` axiom not available as MCS-level lemma | M | M (30%) | Check for `until_intro_in_mcs` / `since_intro_in_mcs` early; if missing, prove them from axiom constructors + MCS closure. |
| x_content membership lemma (`X(phi) in M implies phi in x_content(M)`) missing | M | L (15%) | This is the core property of x_content; should already exist in TemporalContent.lean. Verify early. |
| DovetailedChain sorries cannot be addressed by DeterministicFMCS closure | L | H (95%) | Expected. The DovetailedChain uses Lindenbaum extensions (not x_content), so its sorries remain. Plan focuses only on DeterministicFMCS path. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Audit Prerequisites and Infrastructure [NOT STARTED]

**Goal**: Verify that all needed lemmas exist before attempting the backward Until/Since proof. Identify any gaps that must be filled first.

**Tasks**:
- [ ] Verify `until_intro_in_mcs` exists (or equivalent: `phi U psi` follows from `X(psi v (phi /\ (phi U psi)))` in an MCS)
- [ ] Verify `since_intro_in_mcs` exists (symmetric for Since)
- [ ] Verify `x_content_mem` or equivalent: `X(alpha) in M implies alpha in x_content(M)`
- [ ] Verify `y_content_mem` or equivalent: `Y(alpha) in M implies alpha in y_content(M)`
- [ ] Verify `deterministic_chain_mcs` (each chain position is MCS) -- confirmed in research
- [ ] Verify `x_content_mcs` and `y_content_mcs` exist (MCS preservation) -- confirmed in research
- [ ] Document any missing lemmas that must be proven first

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- (read-only audit of) `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
- (read-only audit of) `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean`
- (read-only audit of) `Theories/Bimodal/ProofSystem/` (axiom constructors)

**Verification**:
- List of all prerequisite lemmas with their exact names and file locations
- Identification of any missing lemmas that Phase 2 must prove

---

### Phase 2: Close Backward Until/Since in DeterministicFMCS [NOT STARTED]

**Goal**: Prove the 4 Until/Since coherence cases in `DeterministicFMCS.usc`, closing 4 of the 6 sorries in that file.

**Tasks**:
- [ ] Prove any missing prerequisite lemmas identified in Phase 1 (e.g., `until_intro_in_mcs`, `since_intro_in_mcs`)
- [ ] Prove forward Until coherence: `phi U psi in mcs(t) implies exists s > t, psi in mcs(s) and forall r in (t,s), phi in mcs(r)` -- this uses forward_F for the witness, then backward induction for guard
- [ ] Prove backward Until coherence: given witness `psi in mcs(s)` and guard `phi in mcs(r)` for all `r in (t,s)`, prove `phi U psi in mcs(t)` using backward induction from s to t via `until_intro` + x_content linkage
- [ ] Prove forward Since coherence: symmetric to backward Until using `since_intro` + y_content
- [ ] Prove backward Since coherence: symmetric to forward Until using backward_P for witness
- [ ] Run `lake build` to verify no regressions

**Timing**: 5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- close 4 sorry cases in `usc`
- Possibly `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean` -- helper lemmas if needed
- Possibly `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- if prerequisite lemmas missing

**Verification**:
- `grep -c sorry DeterministicFMCS.lean` shows 2 (only forward_F and backward_P remain)
- `lake build` succeeds
- The 4 `usc` cases compile without sorry

**Important note**: The forward Until and forward Since cases depend on `deterministic_forward_F` and `deterministic_backward_P` respectively for the existence witness. These remain sorry. The backward Until and backward Since cases are the ones that can be proven sorry-free using backward induction. The `usc` function bundles all 4 cases, so closing only backward Until/Since still reduces the sorry count but does not eliminate sorry from `usc` entirely.

---

### Phase 3: Fix Misleading Docstrings [NOT STARTED]

**Goal**: Correct all docstrings that falsely claim "sorry-free" status for completeness-related theorems.

**Tasks**:
- [ ] Fix `completeness_over_Int` docstring in `Completeness.lean` line 470: change `**Sorry-free**` to accurate status noting dependency on DovetailedFMCS forward_F/backward_P sorries
- [ ] Fix `discrete_completeness_fc` docstring in `Completeness.lean` line 488-489: update note about sorry dependency
- [ ] Audit and fix any misleading comments in `DovetailedChain.lean` documentation sections
- [ ] Audit and fix DeterministicFMCS.lean docstring at line 218 (claims "sorry-free" but depends on sorry-bearing `tc`/`usc`)
- [ ] Update the Completeness Status documentation block (Completeness.lean line 500+) to reflect actual sorry status
- [ ] Run `lake build` to verify docstring changes compile

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- lines 470, 488-489, 500+
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- documentation sections
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- line 218

**Verification**:
- `grep -n "sorry-free\|Sorry-free\|sorry free" Completeness.lean` shows no misleading claims
- `lake build` succeeds

---

### Phase 4: Document Forward_F Impossibility [NOT STARTED]

**Goal**: Add a structured documentation section in the completeness files explaining WHY forward_F is unprovable for deterministic/dovetailed chains and what alternative construction would be required.

**Tasks**:
- [ ] Add a `/-! ## Forward_F Impossibility -/` documentation section to `DeterministicFMCS.lean` near the forward_F sorry, documenting the compactness impossibility argument
- [ ] Add a matching documentation section to `DovetailedChain.lean` near `DovetailedFMCS_forward_F`
- [ ] Add a "Completeness Gap Analysis" section to `Completeness.lean` documenting: (a) which sorries remain, (b) why forward_F is impossible for current chains, (c) what published approaches (Burgess, GHR, Goldblatt, Reynolds) do differently, (d) estimated effort for resolution
- [ ] Reference the key insight: published proofs build F-resolution INTO chain construction, not prove it after the fact

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- new documentation section
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- new documentation section
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- gap analysis section

**Verification**:
- Each file has a clear, honest documentation section about the forward_F gap
- `lake build` succeeds
- Documentation references the compactness impossibility and published alternatives

---

### Phase 5: Build Verification and Sorry Accounting [NOT STARTED]

**Goal**: Final verification that the build succeeds and produce an accurate sorry count for the completeness critical path.

**Tasks**:
- [ ] Run full `lake build` and verify no errors
- [ ] Count remaining sorries on the completeness_over_Int critical path (expected: forward_F + backward_P in DeterministicFMCS = 2, plus DovetailedChain sorries = 6, plus CanonicalConstruction = 2)
- [ ] Count total sorry reduction achieved (expected: 4 sorries closed in DeterministicFMCS.usc, if backward cases proven)
- [ ] Update the sorry inventory table in DeterministicFMCS.lean header to reflect current state
- [ ] Verify that `DeterministicChain.lean` remains zero-sorry (as confirmed by research)

**Timing**: 1.5 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- update header sorry table

**Verification**:
- `lake build` succeeds with zero errors
- Sorry count on DeterministicFMCS critical path documented
- All docstrings accurate

## Testing & Validation

- [ ] `lake build` passes with no errors after all phases
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` shows exactly 2 sorries (forward_F, backward_P) -- or 6 if backward Until/Since cannot be closed
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean` shows 0 sorries
- [ ] No false "sorry-free" claims in any docstring related to completeness
- [ ] Forward_F impossibility documented with mathematical argument in all relevant files

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/18_completeness-closure.md` (this plan)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean`
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean`
- Possibly modified: `Theories/Bimodal/Metalogic/Algebraic/DeterministicChain.lean`
- Possibly modified: `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`

## Rollback/Contingency

If backward Until/Since proofs fail in Lean despite the mathematical outline:
1. Revert DeterministicFMCS.lean to pre-change state via `git checkout`
2. Keep the docstring fixes and documentation improvements (Phases 3-4) as standalone value
3. Document the specific Lean-level obstacle in a new research report
4. Consider whether the obstacle reveals a deeper mathematical issue or just a Lean encoding challenge

If `lake build` fails for unrelated reasons:
1. Use `git stash` to preserve changes
2. Diagnose and fix the build issue separately
3. Reapply changes and verify
