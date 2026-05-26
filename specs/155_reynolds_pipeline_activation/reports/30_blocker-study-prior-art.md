# Blocker Study: Phase 3 Cross-Boundary Ordering + Prior Art Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-25
**Focus**: Comprehensive analysis of remaining blockers, handoff pattern analysis, GHR93 literature alignment, and resolution strategies

---

## 1. Plan vs Implementation Gap Analysis

### Phase Status Summary

| Phase | Plan Description | Actual Status | Sorries Planned | Sorries Remaining |
|-------|-----------------|---------------|-----------------|-------------------|
| 1 | Mechanical S3+S5 | COMPLETED | 2 | 0 |
| 2 | Pigeonhole K-(negD) bridge (S1/S2) | COMPLETED | 2 | 0 |
| 3 | Case II e_n construction (S8/S9/S10) | BLOCKED | 3 | 3 (lines 8521, 8609, 8662) |
| 4 | Position-tracking S6+S7 | COMPLETED | 2 | 0 |
| 5 | Cases III/IV + Lemma 10 (S11, S12) | NOT STARTED | 2 | 2 (lines 9580, 9942) |
| 6 | NF characterization (S13) | NOT STARTED | 1 | 1 (EFGames:10086) |
| 7 | no_gaps_discrete (S14) | NOT STARTED | 1 | 1 (IntegerModel:863) |
| 8 | succ_cofinal | NOT STARTED | 1 | 1 (ChronicleToCountermodel:1885) |
| 9 | Final wiring | NOT STARTED | 1 | ~4 (Completeness:226,256,281,290) |

**Total remaining sorry sites on critical path**: 5 (ExpressivenessGeneral) + 1 (EFGames) + 1 (IntegerModel) + 1 (ChronicleToCountermodel) + 4 (Completeness) = 12.

### Phase 3: What the Plan Says vs What Happened

**Plan says**: "Restructure ghr93_case_II to construct e_n via U(B,A) transfer per GHR93, not from forward game response."

**What actually happened**: The implementation did NOT restructure e_n construction. Instead, it:
1. Added `h_d_compat_left` field to `SplitPointProps` (a d-compatible (1+3n+1)-round forward strategy)
2. Used this to derive `hord_cd_en_pn : (c < e_n <-> d < p_n)` -- the cross-boundary ordering
3. Derived `hc_le_en : c <= e_n` from `hord_cd_en_pn` + `hd_le_pn`
4. Added pivot_chain_order branches for cross-boundary goals in Case A

**Current state**: The d-compat breakthrough solved the fundamental mathematical gap (deriving c <= e_n), but the Case A sorry at line 8521 still has residual goals falling through the `first` tactic, and Case B (lines 8609, 8662) has not been updated to use the new infrastructure.

### Phase 3 Gap: What Remains

The gap between "d-compat breakthrough" and "Phase 3 complete" is:

1. **Case A sorry (line 8521)**: 6 goals fall through the `first` tactic. Per the latest handoff, 4 of 6 have specific pivot_chain_order patterns identified. Goals 1 and 3 may be falling through due to `extendPoint` vs raw carrier type mismatches or Fin index conversion issues rather than mathematical gaps.

2. **Case B sorry (line 8609)**: Needs sigma-game instantiation to extract `(x' < d <-> x < c)`, then cross-boundary pivots identical to Case A. The dead code at lines 8610-8669 contains the tau ordering extractions but the sorry at 8662 is inside this dead code block.

3. **Case B sorry (line 8662)**: Inside the dead code block. Needs the same sigma extraction plus `hord_cd_en_pn` which is already available from the d-compat forward game.

### Phases 5-9: Plan vs Reality

**Phase 5 (S11/S12)**: Plan says these depend on Phases 3 and 4. Phase 4 is COMPLETED, but Phase 3 is BLOCKED. However:
- S11 (`ghr93_cases_III_IV`, line 9580) appears to be a full theorem body sorry with the entire backward game response construction needed. The `left_formula_gap_detection` and `right_formula_gap_detection` infrastructure IS sorry-free in EFGames.lean. The plan estimates 100-150 lines.
- S12 (`ghr93_forward_to_backward_rank_varying`, line 9942) requires Lemma 10 strategy restriction. The goal state shows it needs to derive a game on arbitrary sub-intervals `[x1,y1] x [x1',y1']` from a game on `[x,y] x [x',y']`. This is a substantial mathematical argument.

**Phase 6 (S13)**: The keystone sorry at EFGames:10086. This is `nf_characterizable_by_stavi` -- the inductive step showing every NormalForm at depth k+1 is characterizable. The plan estimates 200-400 lines. This requires ALL of S1-S12 closed because the four-case analysis (Cases I-IV) is the inductive step's core.

**Phases 7-9**: These are downstream wiring. Each is architecturally straightforward given the upstream theorems, but requires substantial effort (100-300 lines each).

---

## 2. Handoff Pattern Analysis

### Methodology

Analyzed 20+ handoffs across 15+ sessions spanning May 16-25, 2026.

### Recurring Theme 1: Cross-Boundary Ordering (7 handoffs)

The `(d < p_n <-> c < e_n)` / `c <= e_n` blocker appears in:
- `phase3-s8-handoff.md` (May 24): First identification of root cause
- `phase-3-handoff-20260524T224500Z.md`: Exhaustive analysis confirming no derivation possible
- `phase-3-handoff-20260524T233000Z.md`: Confirmed BLOCKED status
- `phase-3-handoff-20260525T003000Z.md`: S4 Case A closed, S4 Case B and S7-right remain
- `phase-3-handoff-20260525T020000Z.md`: S4 Case B and S7-right closed (2 sorries eliminated)
- `phase-3-handoff-20260525T010000Z.md`: Proposed h_fwd_n1_d approach, blocked by game_tuple dite
- `phase-3-handoff-20260525T043000Z.md`: D-COMPAT BREAKTHROUGH -- h_d_compat_left avoids round reduction

**Pattern**: The cross-boundary ordering was correctly identified as the core blocker early (May 24), but multiple approaches were attempted and abandoned before the d-compat solution was found. Each approach was well-motivated but ran into Lean-specific implementation barriers (game_tuple dite nesting, Fin arithmetic, heartbeat limits).

### Recurring Theme 2: h_d_unique Falsehood (4 handoffs)

The claim that "any element sharing d's rank-r type must equal d" was:
- Introduced as a key lemma
- Proved mathematically false across multiple sessions
- Removed and replaced with `h_interior_d` parameter pattern
- Required d_consistency restructure (completed)

**Pattern**: A mathematical error was introduced, persisted through multiple sessions, and was finally removed. This cost at least 3 sessions of wasted effort.

### Recurring Theme 3: Formula Materialization Circularity (5+ reports)

Reports 28-39 extensively analyzed whether GHR93's formula C can be materialized:
- Approach A (direct StaviFormula enumeration): BLOCKED by infinite atoms
- Approach B (NormalForm -> StaviFormula inversion): CIRCULAR
- Approach C (case-split): ADOPTED as the viable path

**Pattern**: This was the dominant research question for weeks but is now considered resolved. The K-(negD) bridge approach (Phase 2) successfully replaced the need for formula C materialization in the Claim 1 cluster.

### Recurring Theme 4: game_tuple Arithmetic Barriers (3 handoffs)

Multiple handoffs report struggles with `game_tuple` index proofs:
- Nested `dite` expressions causing heartbeat exhaustion
- Fin arithmetic opacity after `simp only [game_tuple]`
- The `show k = expr from by omega` pattern as the working solution

**Pattern**: This is a persistent Lean engineering challenge, not a mathematical one. Each new context requires rediscovering the same game_tuple simplification patterns.

### What Keeps Failing and Why

1. **Approaches that assume formula C is available**: The formalization does not have C as a concrete formula. Every approach that assumes "evaluate C at point t" fails because `cont_holds` is a predicate, not a formula truth value.

2. **game_tuple unfold + simp strategies**: The `game_tuple` definition uses nested `dite` that creates exponential blowup after unfolding. Only targeted `simp only [game_tuple_zero_eq, game_tuple_sel_eq, ...]` works.

3. **Attempts to derive ordering from formula agreement alone**: Two points can share the same rank-r type but have different positions. This fact was rediscovered at least 3 times across different sessions.

### What Has Worked

1. **K-(negD) bridge** (Phase 2): Replaced formula C materialization for Claim 1 direction.
2. **D-compatible forward game** (Phase 3 breakthrough): Using larger game at (1+3n+1) rounds to get d at position 1+3n avoids round-position reduction.
3. **Formula agreement composition**: Composing multi-round and 1-round formula agreements for K-(negD) proofs.
4. **game_tuple simplification lemmas**: Using `game_tuple_zero_eq`, `game_tuple_sel_eq`, `game_tuple_b_eq`, `game_tuple_y_eq` instead of unfolding the definition.

---

## 3. Literature Alignment

### GHR93 Section 8 vs Lean Formalization

| GHR93 Concept | GHR93 Treatment | Lean Formalization | Alignment |
|--------------|-----------------|-------------------|-----------|
| Formula C = X_{(a_n, y')} | Concrete rank-r StaviFormula | `cont_holds` predicate (not a formula) | DIVERGED -- resolved via K-(negD) bridge |
| Claim 1 (d = inf S_C) | 5-line proof using C as formula | ~1000 lines using K-(negD) pigeonhole | DIVERGED but functionally equivalent |
| Case I | Uses sigma+tau strategies on sub-intervals | Implemented (sorry-free) | ALIGNED |
| Case II e_n construction | U(B,A) transfer via tau | Forward game response | DIVERGED -- e_n comes from forward game, not Until witness |
| Case II c <= e_n | Trivial: e_n > resp_tau(n-1) >= c | Requires d-compat forward game | DIVERGED -- resolved via h_d_compat_left |
| Case II ordering assembly | Composition of sigma+tau orderings | same_order_type_grid + pivot_chain_order | PARTIALLY ALIGNED -- cross-boundary goals still open |
| Cases III/IV | Gap detection via left_formula/right_formula | Infrastructure exists, theorem body sorry'd | INFRASTRUCTURE READY, proof missing |
| Lemma 10 (rank_down) | Strategy restriction to sub-intervals | Proved as ghr93_duplicator_wins_rank_down | ALIGNED |
| Lemma 10 (strategy restriction) | Sub-interval game derivation from IH | NOT IMPLEMENTED (S12 sorry) | MISSING |
| Theorem 6 inductive step | Four-case analysis (I, II, III, IV) | Dispatcher exists, cases I and II partially done | PARTIALLY ALIGNED |

### Key Architectural Divergence: e_n Construction

GHR93 (p.117-118) constructs e_n as follows:
1. Apply tau to a_0,...,a_{n-1}, getting e_0,...,e_{n-1} in (c,b)_r (via Lemma 10)
2. Observe N |= U(B,A)(a_{n-1}) where B = X_{a_n}
3. Transfer via tau: M |= U(B,A)(e_{n-1})
4. Find z > e_{n-1} with M |= B(z) and M |= A(t) for all t in (e_{n-1}, z)
5. Set e_n = z. Then c < e_n trivially (e_n > e_{n-1} >= c).

The formalization instead:
1. Builds `a_M` from resp_tau + c
2. Plays the (n+1)-round forward game: `props.h_fwd_n1 a_M ha_M` gets `a_N, e_n`
3. e_n comes from the forward game's response to p_n -- NO ordering guarantee relative to c

This divergence is the root cause of the Phase 3 blocker. The d-compat breakthrough partially fixes it by establishing c <= e_n from a larger game, but it does NOT reconstruct e_n as a U(B,A) witness.

**Assessment**: The d-compat approach is a valid workaround that avoids restructuring the e_n construction entirely. It is mathematically sound (the larger game preserves all necessary properties) and avoids the U(B,A) transfer machinery which would require the Until semantics for `cont_holds` -- exactly the formula materialization problem that Approach C sidesteps.

### GHR93 Lemma 9 (Gap Detection)

The formalization has `left_formula_gap_detection` and `right_formula_gap_detection` proved sorry-free in EFGames.lean. These are the key infrastructure needed for Cases III/IV. The remaining gap is in `ghr93_cases_III_IV` itself (S11), which needs to use these detection lemmas to construct the backward game response when a_n is a gap.

### GHR93 Lemma 10 (Strategy Restriction)

Two separate concerns:
1. **Rank downward transport** (`ghr93_duplicator_wins_rank_down`): PROVED. Reduces rank from r' to r using gap characterization formula.
2. **Sub-interval strategy restriction**: NOT PROVED. This is S12 -- deriving a game on `[x1,y1]` from a game on `[x,y]` where `[x1,y1] subset [x,y]`. GHR93 handles this via "the method of Lemma 10" which involves applying sub-interval strategies from the IH. The Lean formalization needs this for `ghr93_forward_to_backward_rank_varying`.

---

## 4. Blocker Resolution Strategies

### Blocker 1: Phase 3 Case A Residual Goals (line 8521)

**Nature**: 6 goals from `same_order_type_grid` fall through the `first` tactic. All required mathematical data (`hord_cd_en_pn`, `hc_le_en`, `hd_le_pn`) is in scope.

**Root Cause**: Pattern-matching failure in the `first` tactic. The existing pivot_chain_order branches (lines 8509-8519) cover 4 of the 6 cross-boundary cases, but 2 goals (Goals 1 and 3 from the latest handoff) fall through despite having branches for them at lines 8479-8488 and earlier in the tactic block.

**Resolution Strategy**:
1. Examine whether Goals 1 and 3 are actually the "both False" goals (b_resp < x' and y' < a_bwd). If so, they should be closeable with `exact <False.elim_pair, ...>` patterns.
2. Check for `extendPoint` wrapping issues -- the goal may expect `extendPoint b_resp < x'` but the hypothesis provides `b_resp >= x'` without the `extendPoint` wrapper.
3. Add explicit pattern arms after the existing `first` block with `| sorry` replaced by explicit case analysis on the remaining goals.

**Estimated Effort**: 1-2 hours (mechanical pattern matching)
**Difficulty**: Low -- all mathematical content is available, this is Lean engineering

### Blocker 2: Phase 3 Case B (lines 8609, 8662)

**Nature**: The tau sub-case of same_order_type needs sigma extraction for `(x' < d <-> x < c)` and cross-boundary pivot branches.

**Root Cause**: Case B was not updated with the d-compat infrastructure. The sorry at 8609 covers the entire `same_order_type (n+1)` goal. The dead code at 8610-8669 contains tau ordering extractions that are structurally correct but:
- Missing sigma instantiation for `(x' < d <-> x < c)`
- Missing cross-boundary pivots using `hord_cd_en_pn`
- The `sorry` at 8662 is within the dead code's attempt at closing goals

**Resolution Strategy**:
1. Uncomment and fix the dead code at lines 8610-8669 (tau ordering extractions are correct)
2. Add sigma instantiation before the ordering assembly (pattern from the latest handoff at 8342-8344 in Case A)
3. Add cross-boundary pivot branches using `hord_cd_en_pn` (identical to Case A lines 8509-8519)
4. Handle `(x' < d <-> x < c)` via sigma extraction with `fun _ => d` selection

**Estimated Effort**: 2-3 hours
**Difficulty**: Moderate -- requires sigma extraction + ordering assembly, but all patterns exist in Case A

### Blocker 3: S11 -- Cases III/IV (line 9580)

**Nature**: Full theorem body sorry. Must construct backward game response when a_n is a gap.

**Root Cause**: Requires implementing the gap case analysis from GHR93 (Cases III and IV), using `left_formula_gap_detection` and `right_formula_gap_detection` to find matching gaps in M.

**Resolution Strategy**:
1. Case-split on whether a_bwd(n) is left-defined or right-defined (or both)
2. Use `left_formula_gap_detection` / `right_formula_gap_detection` to find a gap in M with matching detection formula
3. Use `gap_detection_unique` to show the matching gap has the right properties
4. Construct the response sequence using tau (for init positions) + the matching gap (for position n)
5. Assemble the winning condition from tau + gap detection properties

**Dependencies**: Requires Phase 3 to be complete (Case II) for the inductive step dispatcher, but the theorem itself is structurally independent.

**Estimated Effort**: 3-5 hours (substantial new proof)
**Difficulty**: High -- requires new mathematical argument, not just pattern adaptation

### Blocker 4: S12 -- Lemma 10 Strategy Restriction (line 9942)

**Nature**: Must derive `ghr93_duplicator_wins M N atomMap (1+3*(n+1)) (r+2) (rank_embed x1) ... (rank_embed y1')` on arbitrary sub-intervals from the game on the original interval.

**Root Cause**: The proof needs GHR93 Lemma 10's strategy restriction argument: if Duplicator wins on [x,y], she wins on any sub-interval [x1,y1] by restricting her strategy. This is not a simple sub-game -- it requires showing that moves outside [x1,y1] can be "absorbed" by the strategy.

**Resolution Strategy**:
Two approaches:
1. **Parameter approach**: Modify `ghr93_forward_to_backward_rank_varying` to take `h_r1_univ` as a parameter from the main induction, rather than deriving it. The IH provides games on all sub-intervals via universal quantification.
2. **Full Lemma 10**: Implement strategy restriction as a separate theorem. This would be useful for the general pipeline but is more work.

**Recommended**: Approach 1 (parameter approach). The IH already has universal quantification over intervals. Passing it down avoids reimplementing Lemma 10.

**Estimated Effort**: 2-4 hours
**Difficulty**: Moderate-High -- requires understanding the induction structure deeply

### Blocker 5: S13 -- NF Characterization (EFGames:10086)

**Nature**: Keystone sorry. Must prove every NormalForm at depth k+1 is characterizable by a StaviFormula.

**Root Cause**: This IS the main theorem of the GHR93 formalization. The inductive step requires the complete four-case analysis (Cases I-IV), which in turn requires all of S1-S12 to be closed.

**Dependency**: Requires Phases 1-5 complete. Currently blocked on Phase 3.

**Resolution Strategy**: Once Phases 1-5 close all S1-S12, the inductive step becomes:
1. For the base case (k=0): already proved via `nf_base_sf` (sorry-free)
2. For k+1: the 2-variable NF quantifier part requires the four-case game analysis
3. The game analysis decomposes into the four cases, each using the infrastructure from Phases 1-5
4. The conclusion assembles the StaviFormula from the case analysis results

**Estimated Effort**: 4-8 hours (after all prerequisites)
**Difficulty**: Very High -- central mathematical argument

### Summary: Critical Path

```
Phase 3 (S8/S9/S10 sorry closure)  ----\
                                         +--> Phase 5 (S11/S12) --> Phase 6 (S13) --> Phase 7 (S14) --> Phase 8 --> Phase 9
                                        /
Phase 4 (COMPLETED) ------------------/
```

The critical path bottleneck is **Phase 3**. Once the 3 sorry sites at lines 8521, 8609, 8662 are closed, Phases 5-9 become unblocked in sequence.

---

## 5. Pipeline Health Assessment

### Overall Viability: VIABLE WITH SIGNIFICANT EFFORT

The Reynolds pipeline is architecturally sound. The major structural decisions are settled:
- K-(negD) bridge successfully replaces formula C materialization
- D-compatible forward game provides cross-boundary orderings
- Gap detection infrastructure is sorry-free
- Rank downward transport is proved

### Effort Estimate

| Phase | Status | Remaining Effort |
|-------|--------|------------------|
| 3 | BLOCKED (3 sorries) | 3-5 hours |
| 5 | NOT STARTED (2 sorries) | 5-9 hours |
| 6 | NOT STARTED (1 sorry) | 4-8 hours |
| 7 | NOT STARTED (1 sorry) | 2-4 hours |
| 8 | NOT STARTED (1 sorry) | 2-4 hours |
| 9 | NOT STARTED (4 sorries) | 1-2 hours |
| **Total** | | **17-32 hours** |

### Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Phase 3 Case B pivot_chain_order pattern fails | Low | Medium | Fall back to manual `same_order_type` proof (~100 lines) |
| S11 gap detection argument has unexpected mathematical gap | Medium | High | left/right_formula_gap_detection are proved; main risk is in the ASSEMBLY |
| S12 Lemma 10 strategy restriction harder than expected | Medium | High | Use parameter approach (pass IH game) to avoid full Lemma 10 |
| S13 inductive step requires infrastructure beyond Phases 1-5 | Medium | Very High | This is the highest-risk phase; partial progress still valuable |
| succ_cofinal proof via gap elimination has additional gaps | Medium | High | Task 129 (Henkin approach) as contingency |

### Recommendation

1. **Immediate priority**: Close Phase 3 sorry sites (lines 8521, 8609, 8662). The d-compat breakthrough has provided all necessary mathematical data; remaining work is Lean engineering (pattern matching, sigma extraction, pivot assembly).

2. **Second priority**: Phase 5 S12 (strategy restriction). Consider the parameter approach to avoid full Lemma 10 implementation.

3. **Third priority**: Phase 5 S11 (Cases III/IV gap case). This requires new mathematical argument using gap detection infrastructure.

4. **Deferred**: Phases 6-9 depend sequentially on earlier phases and should not be started until prerequisites are met.

### Key Insight for Accelerating Progress

The single most impactful intervention would be to **factor out the same_order_type assembly pattern** used in Case A into a reusable tactic or lemma. The exact same ordering assembly (tau orderings + sigma extraction + forward game orderings + cross-boundary pivots) is needed in Case A, Case B, and potentially Cases III/IV. A general-purpose `assemble_winning_condition` helper that takes the component game data and produces the composed winning condition would eliminate the per-case engineering overhead.

---

## Appendix A: Sorry Site Inventory (Current as of 2026-05-25)

### ExpressivenessGeneral.lean (5 sorries)

| Line | Theorem | Goal | Blocker | Phase |
|------|---------|------|---------|-------|
| 8521 | ghr93_case_II | same_order_type (n+1) [Case A fallthrough] | Pattern matching in `first` tactic | 3 |
| 8609 | ghr93_case_II | same_order_type (n+1) [Case B tau] | Sigma extraction + cross-boundary pivots | 3 |
| 8662 | ghr93_case_II | [Case B dead code sorry] | Same as 8609 | 3 |
| 9580 | ghr93_cases_III_IV | Full backward game response (gap case) | Gap detection assembly | 5 |
| 9942 | ghr93_forward_to_backward_rank_varying | Sub-interval game derivation | Strategy restriction / IH parameter | 5 |

### EFGames.lean (1 sorry)

| Line | Theorem | Goal | Blocker | Phase |
|------|---------|------|---------|-------|
| 10086 | nf_characterizable_by_stavi | Inductive step: NF -> StaviFormula | All S1-S12 must close first | 6 |

### IntegerModel.lean (1 sorry)

| Line | Theorem | Goal | Blocker | Phase |
|------|---------|------|---------|-------|
| 863 | no_gaps_discrete | Gap elimination for discrete Prior structures | Requires nf_characterizable_by_stavi | 7 |

### ChronicleToCountermodel.lean (1 sorry on critical path)

| Line | Theorem | Goal | Blocker | Phase |
|------|---------|------|---------|-------|
| 1885 | succ_cofinal | IsSuccArchimedean for LimitDomSubtype | Requires no_gaps_discrete | 8 |

### Completeness.lean (4 sorries)

| Line | Theorem | Goal | Blocker | Phase |
|------|---------|------|---------|-------|
| 227 | countermodel_discrete_enriched | Wire to countermodel_discrete | Upstream sorries | 9 |
| 256 | (related) | Type adaptation | Upstream sorries | 9 |
| 281 | (related) | Type adaptation | Upstream sorries | 9 |
| 290 | (related) | Type adaptation | Upstream sorries | 9 |

## Appendix B: Superseded Approaches (DO NOT RETRY)

1. **Track A: OrderIso bypass** -- requires IsSuccArchimedean, which IS succ_cofinal
2. **Approach A: Fintype StaviFormula** -- infinite atoms block Fintype instance
3. **Approach B: NormalForm -> StaviFormula inversion** -- circular
4. **h_d_unique** -- mathematically false (removed)
5. **h_fwd_n1_d at (n+1) rounds** -- game_tuple dite reduction blocked
6. **d = a_bwd(n) with rank-(r+1)** -- d_consistency literally false
7. **Gap equivalence lemma** -- gaps and adjacent points disagree on atoms
8. **pivot_chain_order without c <= e_n** -- requires c <= e_n as input
