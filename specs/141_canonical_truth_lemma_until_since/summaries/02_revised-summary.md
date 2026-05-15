# Implementation Summary: Task #141 (v2) -- Revised Plan

- **Task**: 141
- **Status**: [PARTIAL]
- **Session**: sess_1778861584_e18c80
- **Plan**: plans/02_revised-plan.md

## Changes Made

### Phase 1: reflCanR_linear via BX11 [COMPLETED]

Closed the `reflCanR_linear` sorry in `Theories/Bimodal/Metalogic/WeakCanonical/ReflexiveCanonical.lean` following Burgess 1984 Section 2.2.

**Key deviation**: Theorem statement corrected from two-way `tempR_fwd y z \/ tempR_fwd z y` to three-way `tempR_fwd y z \/ y = z \/ tempR_fwd z y`. The original statement was too strong because `tempR_fwd` uses strong g_content (irreflexive temporal relation), so `tempR_fwd y y` does not generally hold (G(psi) -> psi is not a theorem of the axiom system).

**New helpers**:
- `tempR_fwd_mem_some_future`: Burgess Lemma 1.6(b) -- if `tempR_fwd x y` and `beta in y.val`, then `F(beta) in x.val`
- `not_tempR_fwd_witness_F`: Contrapositive of 1.6(b)
- `some_future_mono`: F-monotonicity -- from `|- A -> B` derive `|- F(A) -> F(B)`

**New import**: `Bimodal.Metalogic.BXCanonical.OrderedSeedConsistency` for `temp_linearity_mcs`

### Phase 2: Documentation Cleanup [COMPLETED]

Fixed stale comments in `Theories/Bimodal/Metalogic/WeakCanonical/TruthLemma.lean`:
- Updated header: box backward and H forward/backward moved from "Documented sorries" to "Proved (sorry-free)"
- Fixed truth_lemma docstring to accurately list sorry-free cases
- Replaced 3 ghost `DovetailingChain.lean` references with `BXCanonical/CanonicalChain.lean`
- Added non-critical-path architectural notes to all 6 Until/Since sorry blocks

### Phase 3: Sorry Count Correction [COMPLETED]

Updated critical-path sorry counts across documentation:
- `specs/TODO.md`: sorry_count 14 -> 6, publication_path_sorries 14 -> 6
- `specs/ROADMAP.md`: Task 141 removed from critical path, sorry summary updated
- Task 141 description updated to reflect 2 closed + 6 non-critical-path

## Verification

- `lake build` succeeds for all modified modules (1588 jobs, NormalForm.lean pre-existing error unrelated)
- `grep -c 'sorry' ReflexiveCanonical.lean` = 0
- `grep -c 'sorry' TruthLemma.lean` = 20 (6 actual sorry statements + 14 in comments)
- 6 actual sorry proof terms in TruthLemma.lean (at lines 433, 450, 485, 499, 556, 572)
- 0 sorry proof terms in ReflexiveCanonical.lean
- `grep -c 'DovetailingChain' TruthLemma.lean` = 0
- No new axioms introduced
- No vacuous definitions

## Remaining Work

- 6 TruthLemma Until/Since sorries: documented as non-critical-path, structurally impossible in current ReflCanDomain model without chronicle gap-content infrastructure (30-50h redesign with no benefit over existing chronicle pipeline)
- Task status decision deferred to orchestrator

## Plan Deviations

- **Phase 1, Task 1.1-1.2**: Altered -- used Burgess Lemma 1.6(b) approach instead of planned `neg_G_imp_F_neg` + `F_from_non_g_content`. Cleaner encoding that avoids the neg-G-to-F formula mismatch.
- **Phase 1, Task 1.3**: Added (not in plan) -- `some_future_mono` helper needed for BX11 case analysis.
- **Phase 1, Task 1.4**: Altered -- theorem statement changed to three-way disjunction due to irreflexive temporal semantics.
- **Phase 2, Task 2.4**: Altered -- non-critical-path notes condensed vs. plan template.
- **Phase 3, Task 3.5**: state.json sorry_count update skipped (field not present in state.json; sorry counts tracked in TODO.md header only).
- **Phase 3, Task 3.6**: Deferred to orchestrator.
