# Implementation Plan: Representation Theorem via Canonical Completeness

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: Phases 1-4 of plan v11 (strict semantics refactor) COMPLETED; Phase 1,6 of plan v12 (g-content resolution) COMPLETED
- **Research Inputs**:
  - reports/13_team-research.md (sorry blocker synthesis, 4 teammates)
  - reports/13_teammate-a-findings.md (sorry inventory and dependency graph)
  - reports/13_teammate-b-findings.md (dead code and Boneyard cleanup)
  - reports/13_teammate-c-findings.md (ROADMAP and publication readiness)
  - reports/13_teammate-d-findings.md (plan critic and gap analysis)
- **Artifacts**: plans/13_representation-theorem.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Systematic closure of all sorry sites on the canonical completeness path to produce a sorry-free representation theorem: `completeness_over_Int` proving TM is complete with respect to task frames over the integers. The strict semantics refactor (plans v11-v12) established the mathematically correct foundation (strict `<` for G/H/U/S, T-axiom removed, X/Y-based Until/Since) but expanded the sorry count from 2 to ~85 (of which ~26 are on the critical completeness path). This plan addresses all 26 critical-path sorries through 6 phases ordered by the dependency graph, plus dead code cleanup and ROADMAP updates. FMP completeness (already sorry-free) is not in scope. Dense completeness (task 68) is not in scope. The goal is a publishable representation theorem characterizing TM and its dense/discrete extensions.

### Research Integration

Five research artifacts inform this plan:

- **Teammate A** (sorry inventory): Identified 10-tier sorry structure with precise dependency ordering. Root cause is T-axiom removal cascading into ~25 sites. Two theorems in SuccChainFMCS are provably FALSE (lines 2160, 2182) and must be deleted.
- **Teammate B** (dead code): Found 8 T-axiom sorry functions across 4 files for Boneyard archival, 2 ghost directories (Canonical/, Soundness/), stale documentation labeling reflexive semantics as "Current," and deprecated aliases ready for removal.
- **Teammate C** (ROADMAP): Sorry count metrics in TODO.md are stale (listed 20, actual ~85). Publication readiness scored 7.3/10. Critical path: task 83 -> 58 -> 60, with 82 in parallel.
- **Teammate D** (plan critic): Identified 5 recurring failure patterns across 12 plan versions. Three critical gaps not in plan v12: (1) X-content propagation, (2) TemporalDerived.lean foundation incomplete, (3) backward Until truth lemma unsolved after 4 attempts. Contrapositive approach for backward truth lemma is the most promising untried strategy.

## Goals & Non-Goals

**Goals**:
- Close all ~26 sorry sites on the canonical completeness critical path
- Prove `completeness_over_Int` sorry-free (lean_verify shows no sorryAx)
- Prove 4 foundational derived theorems in TemporalDerived.lean (X_bot_absurd, Y_bot_absurd, until_implies_some_future, since_implies_some_past)
- Establish X-content propagation infrastructure for Until/Since persistence through Succ chains
- Redesign successor seeds to not require `g_content(u) subset u` (use seriality-based F-deferrals instead)
- Close Until/Since truth lemma cases via contrapositive approach with Until-complexity induction
- Close WitnessSeed until/since consistency proofs
- Archive dead code to Boneyard/ and clean up ghost directories
- Update ROADMAP.md with current sorry census and milestone status
- Close frame-class soundness proofs (19 sites, independent parallel track)

**Non-Goals**:
- FMP completeness (already sorry-free; task 82 handles residual TruthPreservation sorries)
- Dense completeness via Rat canonical model (task 68, separate track)
- Algebraic path sorry sites not on the completeness critical path
- Example/pedagogical sorry sites (intentional exercises)
- File splitting for large files (SuccChainFMCS, UltrafilterChain) -- separate maintenance task
- Changes to the axiom system itself (33 axioms are frozen)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| X_bot_absurd derivation tree has unexpected circularity in Lean | H | L | Multiple derivation strategies available (until_induction with chi=bot, chi=neg bot); research report 12 provides two independent sketches |
| Seed redesign (F-deferrals instead of g_content subset) breaks downstream proofs | H | L | The seriality argument (G(chi)->F(chi)) is standard; seed only changes WHAT is included, not the consistency proof pattern |
| X-content propagation through Succ is harder than deriving X(a)->F(a) | M | M | Two independent strategies: (a) extend Succ with x_step, (b) derive F(a) from X(a) and use existing F-propagation. Try (b) first as it requires no structural changes |
| Contrapositive backward truth lemma has a subtle gap in Until-complexity induction | H | M | The forward direction (mcs membership implies semantic truth) is standard and well-understood. The backward direction via MCS maximality (truth implies membership) is logically forced. The risk is the induction metric; if Until-complexity fails, try Fischer-Ladner closure size |
| Soundness audit reveals genuinely unsound axioms under current semantics | H | L | Teammate D flagged this; conduct audit in Phase 6 before investing in soundness proofs. Known unsound axioms (until/since_connectedness) are already not on completeness path |
| SuccChainFMCS self-g_content vs parent-g_content issue is deeper than expected | M | M | Audit in Phase 2; if self-g_content is needed, restructure via successor chain propagation |
| Sorry count increases rather than decreases during implementation | M | L | Strict discipline: every phase must have fewer sorries at end than beginning; no inserting sorry as placeholder |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 6 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Dead Code Cleanup, Boneyard Archival, and ROADMAP Update [COMPLETED]

**Goal**: Remove dead code that obscures the critical path, archive T-axiom-dependent sorry functions to Boneyard, delete ghost directories, update stale documentation, and bring ROADMAP.md current. This housekeeping phase ensures subsequent phases work on a clean codebase with accurate metrics.

**Tasks**:
- [ ] Create `Theories/Bimodal/Boneyard/TAxiomDependentCode/` directory
- [ ] Archive T-axiom sorry functions from TargetedChain.lean (lines 255, 359, 491, 525) to Boneyard -- 4 functions that used `temp_t_future`/`temp_t_past` and have no downstream consumers
- [ ] Archive T-axiom sorry functions from SuccChainFMCS.lean (lines 1244, 4009, 4276, 4419) to Boneyard -- 4 functions on deprecated code path
- [ ] Archive deprecated `forward_G`/`backward_H` from CanonicalConstruction.lean (lines 1015-1058) to Boneyard -- abandoned FMCS extension path
- [ ] Archive deprecated `mcs_all_future_closure`/`mcs_all_past_closure` from TruthPreservation.lean (lines 250-281) to Boneyard -- explicitly marked DEPRECATED
- [ ] Delete 2 FALSE theorems in SuccChainFMCS.lean (lines 2160, 2182) -- documented counterexamples exist
- [ ] Delete ghost directory `Metalogic/Canonical/` (contains only stale README, no .lean files)
- [ ] Delete ghost directory `Metalogic/Soundness/` (contains only README; actual soundness is in Soundness.lean)
- [ ] Remove deprecated aliases `CanonicalR` and `CanonicalR_past` from CanonicalFrame.lean (deprecated since 2026-03-24, 10+ days)
- [ ] Clean up tombstone comments in UltrafilterChain.lean (lines 84-87, 242: "R_G_refl: DELETED")
- [ ] Update stale comments referencing reflexive semantics in FrameConditions/FrameClass.lean (line 93-95), FrameConditions/Soundness.lean (line 176-178), TemporalCoherence.lean (line 217), SuccChainFMCS.lean (line 1196-1203)
- [ ] Mark typst/chapters/06-notes.typ section (lines 104-340) with `// TODO: Rewrite for strict semantics -- reflexive labels are stale` (conservative: mark, do not rewrite)
- [ ] Mark Soundness/README.md with archival notice (conservative: mark, do not delete content)
- [ ] Write `Theories/Bimodal/Boneyard/TAxiomDependentCode/README.md` explaining archival reason and date
- [ ] Update ROADMAP.md: revise sorry census table (was 33, now ~85), update critical path description to reflect strict semantics, update "What Closing the Gap Means" to describe the 3-blocker structure, update priority ordering to reflect current state, add Task 81 strict-semantics achievements
- [ ] Run `lake build` to verify no breakage from cleanup
- [ ] Grep for remaining `temp_t_future|temp_t_past` references in Theories/ (should be zero outside Boneyard and comments)

**Timing**: 2 hours
**Depends on:** none

**Verification**:
- `lake build` succeeds with zero errors
- No T-axiom sorry functions remain outside Boneyard
- Ghost directories deleted
- ROADMAP.md reflects current state
- Grep for `temp_t_future|temp_t_past` in active code returns empty

---

### Phase 2: Foundational Derived Theorems (TemporalDerived.lean) [COMPLETED]

**Goal**: Close the 4 sorry sites in TemporalDerived.lean that all downstream phases depend on. These are proof-theoretic derivations in the axiom system -- the semantics is clear (X(bot) is absurd because bot is never true; Until implies Some_future by definition). The challenge is constructing the syntactic derivation trees.

**Tasks**:
- [ ] Prove `X_bot_absurd`: `DerivationTree ctx ((Formula.bot.untl Formula.bot).imp Formula.bot)`
  - Strategy: Use `until_induction` with chi = bot. Premises: `G(bot -> bot)` (trivially G(top), a theorem) and `G((bot AND X(bot)) -> bot)` (trivially G(bot_and_anything_imp_bot), a theorem). Conclusion: `(bot U bot) -> X(bot)`. But this gives X(bot)->X(bot), which is circular. Alternative: use until_induction with chi = neg(bot) = top: both G-premises are theorems, giving `(bot U bot) -> X(top)`. Then use a separate argument: if X(bot) in MCS, then by until_unfold, X(bot OR (bot AND X(bot))) = X(bot) in MCS (no progress). Instead, derive directly: X(bot) = bot U bot. By until_intro: (bot AND X(bot)) -> (bot U bot). Contrapositive with X_bot gives absurdity via seriality. The key insight from report 12: use `until_induction` with chi such that X(chi) is provably equivalent to top or bot, then chain with seriality. Implement step by step, verifying each derivation tree node compiles.
- [ ] Prove `Y_bot_absurd`: `DerivationTree ctx ((Formula.bot.snce Formula.bot).imp Formula.bot)` -- symmetric dual using since_induction, seriality_past
- [ ] Prove `until_implies_some_future`: `DerivationTree ctx ((phi.untl psi).imp psi.some_future)` -- use until_induction with chi = psi: G(psi -> psi) is trivial, G((phi AND X(psi)) -> psi) follows from X(psi) -> F(psi) (from disc_next on discrete frames) and propositional reasoning. Alternatively: simpler direct route via until_unfold giving (phi U psi) -> (psi OR (phi AND X(phi U psi))), then induct on Until nesting depth.
- [ ] Prove `since_implies_some_past`: symmetric dual
- [ ] Run `lean_verify` on all 4 theorems to confirm no sorryAx
- [ ] Run `lake build` to confirm no regressions

**Timing**: 3 hours
**Depends on:** none

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- close 4 sorry sites

**Verification**:
- All 4 sorry sites in TemporalDerived.lean closed
- `lean_verify` confirms no sorryAx for all 4 theorems
- `lake build` passes

---

### Phase 3: Seed Redesign and g_content Resolution (14 sorry closures) [BLOCKED]

**Goal**: Redesign successor/predecessor seeds to not rely on the invalid `g_content(u) subset u` property. Under strict semantics, `G(chi) in MCS` does NOT imply `chi in MCS`. The correct approach: replace `g_content(u)` in seeds with `{F(chi) | G(chi) in u}`. Since `G(phi) -> F(phi)` (seriality axiom), each F(chi) is in u when G(chi) is. This gives `seed subset u`, restoring consistency. Also close the T-axiom ghost sorry sites that remain on the active path via the same seed restructuring.

**Tasks**:
- [ ] Redesign `constrained_successor_seed` in SuccExistence.lean: replace `g_content(u)` with `f_deferral_of_g_content(u) = {F(chi) | G(chi) in u}`
- [ ] Prove `f_deferral_of_g_content(u) subset u`: for each `F(chi)` in the set, `G(chi) in u` by construction, and `G(chi) -> F(chi)` by seriality_future axiom, so `F(chi) in u` by MCS closure
- [ ] Update `constrained_successor_seed_consistent` (SuccExistence.lean line 473): the seed is now a subset of u, so consistency follows from u being consistent (MCS)
- [ ] Update `successor_deferral_seed_consistent_axiom` (SuccExistence.lean line 788): same pattern
- [ ] Update `predecessor_deferral_seed_consistent_axiom` (SuccExistence.lean line 873): use `p_deferral_of_h_content(u) = {P(chi) | H(chi) in u}` with seriality_past
- [ ] Fix SuccChainFMCS.lean remaining active-path sorry sites that used T-axiom for g_content/h_content subset: route through f_deferral_of_g_content membership instead
- [ ] Audit SuccChainFMCS for self-g_content vs parent-g_content: determine whether downstream proofs need `g_content(current_mcs) subset current_mcs` (impossible under strict semantics) or `g_content(parent_mcs) subset successor_seed` (achievable via f_deferral construction)
- [ ] Fix TargetedChain.lean active-path sites (if any remain after Phase 1 archival): use strict-inequality propagation instead of T-axiom pattern
- [ ] Update coherence theorems to use strict inequality (`m > n`, not `m >= n`): the base case `m = n+1` uses `G(a) -> X(a)` (from Phase 1 of plan v12, already completed) plus successor resolution; inductive step uses temp_4
- [ ] Update all call sites that referenced old `>=` versions to provide strict `>` proofs
- [ ] Run `lake build` on all modified files

**Timing**: 3 hours
**Depends on:** 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` -- seed redesign (3 sorry closures)
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- T-axiom ghost sites on active path (~4 sorry closures)
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- strict-inequality coherence (remaining active sites)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- coherence with strict inequality
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- propagation proofs

**Verification**:
- All `g_content(u) subset u` sorry sites closed via f_deferral_of_g_content pattern
- Coherence theorems state `m > n` (strict inequality)
- `lake build` passes
- No T-axiom pattern `G(a) in M -> a in M` remains on active path

---

### Phase 4: X-Content Propagation and Until/Since Persistence [NOT STARTED]

**Goal**: Establish the infrastructure for X-content propagation through Succ chains, which is the critical gap identified in plan v12 but never addressed. `X(alpha) = bot U alpha` is neither g_content nor f_content, so the Succ relation does not propagate it. This phase provides the mechanism: derive `X(a) -> F(a)` as a theorem (or extend Succ with x_step), then prove Until persistence through Succ and WitnessSeed consistency.

**Tasks**:
- [ ] Prove `X_implies_F`: `DerivationTree ctx (Formula.next a --> a.some_future)` -- from `X(a) = bot U a`, apply `until_implies_some_future` (from Phase 2) to get `F(a)`. This is a one-line application of Phase 2 results.
- [ ] Prove `Y_implies_P`: symmetric dual using `since_implies_some_past`
- [ ] Prove `X_content_resolution`: Given `X(alpha) in u` and `Succ(u, v)`, show `alpha in v`. Strategy: `X(alpha) in u` implies `F(alpha) in u` by X_implies_F. Then `F(alpha) in u` gives `alpha in f_content(u)`. By Succ relation's f_step property: `f_content(u) subset v union f_content(v)`. On discrete frames with X-based Until semantics, the next-step obligation resolves at the immediate successor, giving `alpha in v`. The precise argument uses: `X(alpha) -> (alpha OR (bot AND X(alpha)))` by until_unfold, which simplifies to `X(alpha) -> alpha` at the successor (since the `bot AND ...` branch is absurd).
- [ ] Prove `until_persists_through_succ` (SuccRelation.lean line 551): Given `(phi U psi) in u` with `neg(psi) in u` and `Succ(u, v)`, show `(phi U psi) in v`. Strategy: by until_unfold, `(phi U psi) -> X(psi OR (phi AND (phi U psi)))`. By X_content_resolution at successor: `psi OR (phi AND (phi U psi)) in v`. Case split: if `psi in v`, done (until_intro gives phi U psi). If `phi AND (phi U psi) in v`, then `(phi U psi) in v` directly.
- [ ] Prove `since_persists_through_pred`: symmetric dual
- [ ] Close DovetailedChain.lean Until/Since persistence sorries (lines 608, 974, 1070, 1083): use until_persists_through_succ
- [ ] Close DovetailedFMCS_forward_F (DovetailedChain.lean line 1240): strict witness resolution. Given `F(psi) in mcs(t)`, need `exists s > t, psi in mcs(s)`. The f_step property gives `psi in f_content(mcs(t)) subset mcs(t+1) union f_content(mcs(t+1))`. If `psi in mcs(t+1)`, done with `s = t+1 > t`. If `psi in f_content(mcs(t+1))`, i.e., `F(psi) in mcs(t+1)`, induct. Termination: deferralClosure is finite, so F-nesting is bounded; the bounded witness argument with fuel = B*B+1 (where B is deferralClosure size) applies.
- [ ] Close DovetailedFMCS_backward_P (DovetailedChain.lean line 1247): symmetric
- [ ] Close WitnessSeed `until_witness_seed_consistent` (line 469): the proof assembles `G(neg(psi)) AND G((phi AND X(bot)) -> bot)` with `phi U psi` in M. Apply until_induction to get `(phi U psi) -> X(bot)`. Then X_bot_absurd (from Phase 2) gives bot in M, contradicting MCS.
- [ ] Close WitnessSeed `since_witness_seed_consistent` (line 577): symmetric
- [ ] Run `lake build` on all modified files

**Timing**: 3.5 hours
**Depends on:** 2, 3

**Files to modify**:
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- X_implies_F, Y_implies_P (or new file)
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` -- until_persists_through_succ, X_content_resolution
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- persistence sorries, forward_F, backward_P
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` -- seed consistency proofs

**Verification**:
- X_content_resolution, until_persists_through_succ proven sorry-free
- All DovetailedChain sorry sites on critical path closed
- WitnessSeed consistency proofs closed
- `lean_verify` on X_content_resolution and until_persists_through_succ shows no sorryAx
- `lake build` passes

---

### Phase 5: Until/Since Truth Lemma and Completeness Integration [NOT STARTED]

**Goal**: Close the 8 Until/Since truth lemma sorry sites across CanonicalConstruction.lean and ParametricTruthLemma.lean, then verify `completeness_over_Int` is sorry-free. This is the phase that has blocked 4 previous plan versions. The approach: use the CONTRAPOSITIVE strategy (never tried before) with induction on Until-complexity.

**Tasks**:
- [ ] Prove forward direction of Until truth lemma: `(phi U psi) in mcs(t) => truth_at(phi U psi, t)`. Strategy: (1) `until_implies_some_future` gives `F(psi) in mcs(t)`. (2) Forward_F (from Phase 4) gives witness `s > t` with `psi in mcs(s)`. (3) Take minimal such s (well-ordering on Int, or induction on chain distance). (4) For intermediate r in (t, s): `(phi U psi) in mcs(t)` persists through Succ chain via until_persists_through_succ (Phase 4), giving `(phi U psi) in mcs(r)` for all r in (t, s). (5) At each r, since `neg(psi) in mcs(r)` (by minimality of s) and `(phi U psi) in mcs(r)`, until_unfold gives `phi in mcs(r)`. (6) By induction hypothesis on subformulas phi and psi (smaller Until-complexity), `truth_at(phi, r)` and `truth_at(psi, s)`. (7) This gives `truth_at(phi U psi, t)` by semantic Until definition.
- [ ] Prove backward direction of Until truth lemma: `truth_at(phi U psi, t) => (phi U psi) in mcs(t)`. CONTRAPOSITIVE APPROACH: Assume `neg(phi U psi) in mcs(t)` (by MCS maximality, equivalent to `(phi U psi) not in mcs(t)`). By forward truth lemma on `neg(phi U psi)` (which has strictly LOWER Until-complexity than `phi U psi`): `truth_at(neg(phi U psi), t)`. This means `NOT truth_at(phi U psi, t)`. Contrapositive: `truth_at(phi U psi, t) => (phi U psi) in mcs(t)`.
  - KEY INSIGHT: `neg(phi U psi)` has Until-complexity 0 (it is a negation of an Until formula, not itself an Until formula). The forward truth lemma for negation reduces to: `neg(alpha) in mcs(t) <=> NOT truth_at(alpha, t)`. For the `alpha = phi U psi` case, this requires the FORWARD direction of the Until truth lemma (already proven above). So the backward direction follows from the forward direction plus MCS maximality. No circular dependency exists.
- [ ] Close CanonicalConstruction.lean Until truth lemma sorry (line 631): apply forward + backward
- [ ] Close CanonicalConstruction.lean Since truth lemma sorry (line 632): symmetric
- [ ] Close CanonicalConstruction.lean restricted Until truth lemma sorry (line 940): same approach, restricted to deferralClosure formulas
- [ ] Close CanonicalConstruction.lean restricted Since truth lemma sorry (line 943): symmetric
- [ ] Close ParametricTruthLemma.lean Until/Since sorries (lines 358, 361, 514, 517): same approach applied to parametric setting
- [ ] Close restricted_forward_F and restricted_backward_P in UltrafilterChain.lean (lines 3928, 3938): these are the ORIGINAL 2 sorry sites from task 83. Given the restricted truth lemma is now sorry-free, temporal coherence for deferralClosure formulas follows from the chain construction properties.
- [ ] Run full `lake build`
- [ ] Run `lean_verify` on `completeness_over_Int` -- must show NO sorryAx
- [ ] Run `lean_verify` on `discrete_completeness_fc` -- should also be clean
- [ ] Grep for `sorry` in the completeness critical path files (CanonicalConstruction, DovetailedChain, UltrafilterChain, SuccChainFMCS, SuccExistence, WitnessSeed, SuccRelation, Completeness.lean) -- should return zero on active path

**Timing**: 3.5 hours
**Depends on:** 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` -- 4 Until/Since truth lemma sorries
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean` -- 4 Until/Since sorries
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- 2 restricted forward_F/backward_P sorries

**Verification**:
- `lean_verify completeness_over_Int` shows NO sorryAx (only propext, Classical.choice, Quot.sound)
- `lean_verify discrete_completeness_fc` shows NO sorryAx
- All 8 Until/Since truth lemma sorries closed
- Original 2 task-83 sorries (succ_chain_restricted_forward_F/backward_P) closed
- Zero sorry on canonical completeness path

---

### Phase 6: Soundness Frame-Class Proofs and Final Polish [IN PROGRESS]

**Goal**: Close the 19 frame-class-restricted soundness sorry sites in Soundness.lean. These are independent of completeness and represent routine semantic validity proofs. Also conduct a semantic consistency audit (flagged by Teammate D) to verify all axioms are sound under current strict semantics before investing in proofs.

**Tasks**:
- [ ] Conduct semantic consistency audit: verify each of the 19 axioms is semantically valid under strict `<` semantics with the appropriate frame class constraints. Flag any that are NOT valid (Teammate D noted until/since_connectedness may be unsound).
- [ ] For each VALID axiom, prove soundness:
  - [ ] `density`: Requires `DenselyOrdered D` -- standard dense frame argument
  - [ ] `discreteness_forward`, `discreteness_backward`: Require `SuccOrder D` -- use successor/predecessor properties
  - [ ] `seriality_future`, `seriality_past`: Require `NoMaxOrder D`, `NoMinOrder D` -- existential witness from unboundedness
  - [ ] `disc_next`, `disc_prev`: Require `SuccOrder D`, `PredOrder D` -- next/prev characterization
  - [ ] `until_unfold`, `until_intro`, `until_induction`, `until_linearity`: Require discrete frame + Until semantics -- standard Until semantic arguments
  - [ ] `since_unfold`, `since_intro`, `since_induction`, `since_linearity`: Symmetric
  - [ ] `until_connectedness`, `since_connectedness`: Audit first -- if unsound under current semantics, document and skip
  - [ ] `F_until_equiv`, `P_since_equiv`: F/P equivalence with Until/Since
  - [ ] `temporal_duality`: Frame-class restricted duality
- [ ] For any axiom found to be UNSOUND under current semantics: document the issue, mark the sorry with an explanation, and create a follow-up task if needed
- [ ] Update Soundness.lean module docstring to reflect frame-class separation architecture
- [ ] Run `lean_verify` on `soundness` theorem
- [ ] Run final full `lake build`
- [ ] Final sorry census: grep all Theories/ for sorry, categorize, update ROADMAP.md with final counts

**Timing**: 3 hours
**Depends on:** 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Soundness.lean` -- 19 frame-class soundness proofs
- `ROADMAP.md` -- final sorry census update

**Verification**:
- All valid axiom soundness proofs closed
- Any unsound axioms documented with explanation
- `lean_verify soundness` shows status (may still have sorryAx if any axioms are genuinely frame-incompatible)
- Final sorry census in ROADMAP.md is accurate
- `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with zero errors after every phase
- [ ] `lean_verify completeness_over_Int` shows NO sorryAx after Phase 5
- [ ] `lean_verify discrete_completeness_fc` shows NO sorryAx after Phase 5
- [ ] `lean_verify soundness_dense` confirms still sorry-free (regression check)
- [ ] `lean_verify fmp_completeness` confirms still sorry-free (regression check)
- [ ] `lean_verify X_bot_absurd` shows NO sorryAx after Phase 2
- [ ] `lean_verify until_implies_some_future` shows NO sorryAx after Phase 2
- [ ] Grep for `sorry` in completeness critical path returns zero after Phase 5
- [ ] Grep for `temp_t_future|temp_t_past` in active code returns zero after Phase 1
- [ ] ROADMAP.md sorry census matches actual grep counts
- [ ] No FALSE theorems remain in active code (deleted in Phase 1)

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/13_representation-theorem.md` (this file)
- `Theories/Bimodal/Boneyard/TAxiomDependentCode/` -- archived dead code with README
- `ROADMAP.md` -- updated with current sorry census and milestone status
- Modified Lean files across `Theories/Bimodal/` (~15 files on critical path)
- `specs/083_close_restricted_coherence_sorries/summaries/13_representation-theorem-summary.md` (post-implementation)

## Rollback/Contingency

- All changes are on the `until` branch; main branch is unaffected
- Git history preserves all prior plan versions (v1-v12) and implementation progress
- **Phase 2 fallback**: If X_bot_absurd derivation proves intractable, try the alternative derivation via seriality + until_linearity decomposition. If all derivation strategies fail, the completeness theorem can still be stated with X_bot_absurd as an explicit hypothesis (provable but not yet proved).
- **Phase 3 fallback**: If seed redesign breaks too many downstream proofs, keep the old seed definition and add f_deferral_of_g_content as a SEPARATE lemma used only where g_content(u) subset u was needed.
- **Phase 4 fallback**: If X-content propagation via F-derivation (option b) is insufficient, fall back to extending Succ with x_step (option a, structural change).
- **Phase 5 fallback**: If the contrapositive approach for the backward truth lemma fails, try Fischer-Ladner closure induction as the alternative induction metric. If that also fails, the FORWARD truth lemma alone suffices for weak completeness (valid implies consistent), and the backward direction can be left as a noted limitation with a clear mathematical explanation.
- **Phase 6 is independent**: Soundness proofs can be deferred entirely without affecting completeness.
- Partial progress can be committed at each phase boundary and phases resumed independently.
