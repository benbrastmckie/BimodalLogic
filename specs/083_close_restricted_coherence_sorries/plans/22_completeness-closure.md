# Implementation Plan: Close Restricted Coherence Sorries (v22)

- **Task**: 83 - Close remaining sorries in the completeness proof
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None
- **Research Inputs**: reports/22_global-canonical-model.md
- **Artifacts**: plans/22_completeness-closure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The completeness proof has 12 sorries across two files: 6 in `DeterministicFMCS.lean` (2 leaf + 4 dependent) and 6 in `DovetailedChain.lean` (all architecturally blocked). Research report 22 confirmed that (1) backward Until/Since can be closed NOW using `until_intro` + backward induction without needing `forward_F`, (2) the dovetailed chain should be deprecated as architecturally blocked, (3) `deterministic_forward_F` is the single bottleneck for the remaining sorries, and (4) finite deferral via subformula closure pigeonhole is the most promising path for proving it.

### Research Integration

- **Report 22** (global canonical model): Established that all 12 sorries reduce to one lemma (`deterministic_forward_F`). Identified backward Until/Since as closable now. Recommended finite deferral/pigeonhole approach over global canonical model refactor. Confirmed dovetailed chain is architecturally blocked (X-vs-G mismatch).

## Goals & Non-Goals

**Goals**:
- Close backward Until and backward Since cases in `usc` (2 of 4 subcases)
- Deprecate `DovetailedChain.lean` with architectural limitation documentation
- Attempt finite deferral/pigeonhole proof for `deterministic_forward_F`
- Clean up dead code and update module documentation
- If forward_F proof succeeds, close all remaining sorries

**Non-Goals**:
- Refactoring the FMCS/BFMCS architecture to a graph-based global canonical model
- Building quasimodel infrastructure (GHR 1994 style)
- Proving restricted completeness as a weaker alternative (fallback only if needed)
- Modifying sorry-free infrastructure (`DeterministicChain.lean`, `ParametricTruthLemma.lean`, etc.)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Finite deferral argument proves intractable to formalize | H | M | Document as open problem, mark forward_F as research blocker |
| Pigeonhole on restricted theories does not yield contradiction | H | M | Investigate Until Induction over finite cycles as alternative |
| SubformulaClosure finiteness lemmas missing or incomplete | M | L | Extend SubformulaClosure.lean; FMP module may have reusable infrastructure |
| Backward Until/Since proof more complex than expected | L | L | Research report provides clear proof sketch using until_intro |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 1, 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Close Backward Until/Since in DeterministicFMCS [COMPLETED]

**Goal**: Close 2 of the 4 `usc` subcases (backward Until and backward Since) that do NOT depend on `deterministic_forward_F`.

**Tasks**:
- [ ] Read `TemporalCoherence.lean` to understand the `until_since_coherent` definition and its four subcases
- [ ] Read `DeterministicChain.lean` to identify `until_persists_chain`, `since_persists_chain`, and related lemmas
- [ ] Prove backward Until: given `psi in chain(s)` for `s > t` and `phi in chain(r)` for `t < r < s`, derive `(phi U psi) in chain(t)` using `until_intro` axiom and backward induction on `s - t`
- [ ] Prove backward Since: symmetric to backward Until using `since_intro` and forward induction
- [ ] Verify `lake build` passes with the new proofs

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- fill in backward Until/Since cases in `usc` theorem (lines 194-199)

**Verification**:
- `lake build` succeeds
- `usc` theorem has 2 remaining sorries (forward Until, forward Since) instead of 4
- `grep -c sorry DeterministicFMCS.lean` shows reduction from 6 to 4

---

### Phase 2: Deprecate DovetailedChain [COMPLETED]

**Goal**: Mark `DovetailedChain.lean` as architecturally blocked and document the X-vs-G mismatch limitation. Replace all 6 sorries with documented architectural limitation markers.

**Tasks**:
- [ ] Update module docstring in `DovetailedChain.lean` to explain the architectural limitation (X-vs-G mismatch: Lindenbaum seeds provide x_content-level consistency but Until persistence requires g_content-level propagation)
- [ ] Replace each `sorry` with `sorry -- DEPRECATED: architectural limitation (X-vs-G mismatch in Until persistence through Lindenbaum steps)`
- [ ] Add a `/-! ## Deprecation Notice -/` section explaining that `DeterministicFMCS.lean` supersedes this module
- [ ] Verify `lake build` passes (sorry annotations do not affect compilation)

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- update docstrings and sorry annotations at lines 621, 989, 1085, 1098, 1258, 1266

**Verification**:
- `lake build` succeeds
- All 6 sorries in DovetailedChain.lean have deprecation annotations
- Module docstring clearly states the architectural limitation

---

### Phase 3: Finite Deferral Infrastructure for forward_F [PARTIAL]

**Goal**: Build the subformula closure finiteness and pigeonhole infrastructure needed to prove `deterministic_forward_F` via the finite deferral argument.

**Tasks**:
- [ ] Survey existing `SubformulaClosure.lean` for finiteness lemmas (`subformulaClosure_finite` or similar)
- [ ] Survey `Metalogic/Decidability/FMP/` for reusable infrastructure (filtration, restricted theories, cycle detection)
- [ ] Define `deferralClosure` for a formula psi: the set of formulas relevant to tracking F(psi) resolution along a deterministic chain (includes psi, F(psi), top U psi, and their subformulas/temporal variants)
- [ ] Prove `deferralClosure_finite`: the deferral closure of any formula is finite
- [ ] Define `restricted_chain_theory(n, psi)`: the restriction of `deterministic_chain M_0 n` to `deferralClosure psi`
- [ ] Prove pigeonhole: if F(psi) persists unresolved for more than `2^|deferralClosure psi|` steps, two chain positions have identical restricted theories
- [ ] Investigate whether a cycle in restricted theories with unresolved F(psi) yields a contradiction via Until Induction axiom

**Timing**: 4 hours

**Depends on**: 1 (need working DeterministicFMCS context)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/FiniteDeferral.lean` (new file) -- deferral closure definition, finiteness, pigeonhole lemma
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- extend with finiteness lemmas if missing

**Verification**:
- `lake build` succeeds with new file
- Pigeonhole lemma compiles (may have sorry for the cycle contradiction step)
- Clear documentation of what remains for the full forward_F proof

---

### Phase 4: Close forward_F and Remaining Sorries [NOT STARTED]

**Goal**: If Phase 3 succeeds in establishing the cycle contradiction, close `deterministic_forward_F` and `deterministic_backward_P`, which automatically closes all remaining sorries (forward Until, forward Since, tc, usc).

**Tasks**:
- [ ] Prove `deterministic_forward_F` using the finite deferral pigeonhole argument from Phase 3
- [ ] Prove `deterministic_backward_P` symmetrically (or by time-reversal duality)
- [ ] Close forward Until case in `usc`: use `until_persists_chain` + `deterministic_forward_F` to find the witness
- [ ] Close forward Since case in `usc`: symmetric
- [ ] Verify `tc` theorem becomes sorry-free (it directly wires through forward_F/backward_P)
- [ ] Verify the complete pipeline: `DeterministicFMCS` -> `construct_bfmcs_callback` -> `deterministic_representation` is sorry-free
- [ ] Run `lake build` and confirm zero sorries in `DeterministicFMCS.lean`

**Timing**: 2 hours (conditional on Phase 3 success)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- close all remaining sorries

**Verification**:
- `grep -c sorry DeterministicFMCS.lean` returns 0
- `lake build` succeeds
- `deterministic_representation` compiles without sorry

**Fallback**: If the cycle contradiction in Phase 3 proves intractable:
- Document `deterministic_forward_F` as an open formalization problem
- Keep the two leaf sorries with detailed comments explaining the mathematical argument (semantically true, syntactically circular without global model refactor)
- Consider filing a follow-up task for the quasimodel approach (GHR 1994)

---

### Phase 5: Cleanup and Documentation [NOT STARTED]

**Goal**: Clean up dead code references, update module documentation, and ensure the sorry inventory is accurate.

**Tasks**:
- [ ] Update the sorry inventory docstring in `DeterministicFMCS.lean` to reflect current state
- [ ] Update any imports that reference `DovetailedChain` as the primary completeness path
- [ ] Check if any other files import `DovetailedChain` and add deprecation notes
- [ ] Update `Theories/Bimodal/Metalogic/Algebraic/` README or module doc if it exists
- [ ] Run full `lake build` to confirm no regressions

**Timing**: 1 hour

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` -- update docstrings
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- final deprecation cleanup
- Any files importing DovetailedChain -- add deprecation warnings

**Verification**:
- `lake build` succeeds
- Sorry inventory in docstrings matches actual sorry count
- No files reference DovetailedChain as the active completeness path

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Algebraic/DeterministicFMCS.lean` shows expected count at each phase
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` shows 6 annotated sorries
- [ ] Backward Until/Since proofs do not use sorry
- [ ] If Phase 4 succeeds: `deterministic_representation` compiles sorry-free

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/22_completeness-closure.md` (this plan)
- Modified `DeterministicFMCS.lean` with closed backward Until/Since and potentially all sorries
- Deprecated `DovetailedChain.lean` with architectural documentation
- New `FiniteDeferral.lean` with pigeonhole infrastructure (if Phase 3 reached)

## Rollback/Contingency

- **Phase 1-2 rollback**: `git checkout` the modified files; these are independent low-risk changes
- **Phase 3-4 rollback**: Delete `FiniteDeferral.lean`; DeterministicFMCS retains its original sorries for forward_F/backward_P
- **If Phase 3 proves intractable**: The plan degrades gracefully -- Phases 1, 2, and 5 are still valuable (reducing sorry count from 12 to 8 total, with clear documentation of what remains and why)
- **Full rollback**: `git stash` all changes; no sorry-free infrastructure is modified by this plan
