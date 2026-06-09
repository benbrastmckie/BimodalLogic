# Implementation Plan: Strengthened Zone Match for Stavi Expressive Completeness (v5)

- **Task**: 273 - Fill the EF game sorry in StaviCompleteness.lean to make {U,S,U',S'} expressively complete
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phases 0-1 from v3 are completed)
- **Research Inputs**: specs/273_chronicle_gap_contradiction_proof/reports/03_team-research.md, specs/273_chronicle_gap_contradiction_proof/.blocker-research.md, specs/273_chronicle_gap_contradiction_proof/handoffs/phase-2-handoff-20260609T010703Z.md, literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md (GHR93 Section 8), literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch9.md (GHR94 Ch 9)
- **Artifacts**: plans/05_strengthened-zone-match-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan (v5) replaces v4's blocked Phase 2 with a strengthened zone-matching approach that resolves the interval-splitting problem identified during v4 implementation. The sorry sites at `StaviCompleteness.lean:2353,2435` require 4-variable existential transfer at depth j' for 3-point matching `(u,x,t)/(u',x',t')`. The existing `zone_match_witness` finds u' with the correct 1-var NF and orderings relative to x'/t', but cannot guarantee sub-interval type matching for `(x,u)/(x',u')` and `(u,t)/(u',t')`.

**Resolution**: Prove a strengthened `zone_match_witness_with_splitting` that additionally guarantees interval-type splitting. With this, the sorry becomes a recursive call at strictly smaller depth j' < j'+1, and the recursion terminates via well-founded induction on j.

### Research Integration

Integrated reports:
- `.blocker-research.md` -- Three resolution paths evaluated; Path 1 (game-based interval splitting) recommended; strengthened zone match identified as concrete next step
- `handoffs/phase-2-handoff-20260609T010703Z.md` -- Phase 2 blocker details, sorry site goal states, five failed approaches, counterexample analysis

### Prior Plan Reference

**v3 (separation bypass)**: Blocked because the separation result (GHR94 Ch 10.2) is proved for Z-carrier structures only. `eval` quantifies over `M.carrier`, and arbitrary Prior carriers may differ from Z.

**v4 (EF game completion)**: Phase 2 blocked on the interval-splitting problem. The existing `zone_match_witness` (line 2044) finds u' with the same depth-k 1-var NF and correct orderings relative to x' and t', but does NOT guarantee: (a) correct orderings relative to ALL inner points when zone-matching subsequent variables, or (b) consistent interval-type splitting for sub-intervals `(x,u)/(x',u')` and `(u,t)/(u',t')`. A concrete counterexample confirms the gap is genuine for arbitrary linear orders at depth k.

**v5 approach**: Instead of attempting the transfer with the existing zone_match, prove a *strengthened* zone match (`zone_match_witness_with_splitting`) that chooses u' to split interval types correctly. This works because when u in (x,t) has type tau, u' in (x',t') also has type tau, and the types in (x,u) are exactly the types in (x,t) realized by points below u. If u' is chosen to split the types in the same way (types before u map to types before u', types after u map to types after u'), then sub-interval types match.

### Existing Infrastructure

The EF game infrastructure is substantial (~14,500 lines across 9 files):
- `Defs.lean`: EF game definitions, ExtendedCarrier, decomposition formulas
- `CustomGame.lean` (1703 lines): Custom GHR93 game with gap support
- `Composition.lean` (626 lines): `ghr93_strategy_compose` -- GHR93 Proposition 7
- `NFGameBridge.lean` (1237 lines): Bridge between NF framework and game framework
- `CharacteristicFormula.lean` (666 lines): Characteristic formula construction
- `GapDetection.lean` (5057 lines): Gap detection and definable gap machinery
- `TypeFormulas.lean` (1068 lines): Type formula infrastructure
- `Decomposition.lean` (315 lines): Decomposition formula infrastructure
- `StaviCompleteness.lean` (3270 lines): Main theorem with sorry sites

Key existing lemmas:
- `zone_match_witness` (line 2044): Given 2-point matching, find a zone-matched partner for a 3rd point
- `nf_fraisse_compression` (used at line 2518): Atoms + existential transfer at each depth j < k implies NF equality
- `nf_agreement_from_shared_nf`: Shared NF implies atom-level agreement
- `interval_nf_types_depth_decrease` (line 1904): depth-(k+1) interval types equal implies depth-k interval types equal
- `ghr93_strategy_compose` (Composition.lean): Duplicator strategy composes from sub-interval strategies

## Goals & Non-Goals

**Goals**:
- Prove `zone_match_witness_with_splitting` with sub-interval type guarantees
- Restructure `nf_2var_existential_transfer` to use the strengthened zone match with strong induction on j
- Fill the sorry at `StaviCompleteness.lean:2353` (forward 4-var existential transfer)
- Fill the sorry at `StaviCompleteness.lean:2435` (backward 4-var existential transfer)
- Make `stavi_expressive_completeness` sorry-free
- Thereby make `US_expressively_complete_over_prior` sorry-free (Chain A eliminated)
- Verify via `#print axioms completeness_discrete` that sorryAx is removed from Chain A

**Non-Goals**:
- Fixing `chronicle_gap_contradiction` (Chain B, separate concern)
- Modifying `PriorExpressiveness.lean` or downstream consumers
- Refactoring the existing EF game infrastructure beyond what is needed for the fix
- Proving completeness_dense sorry-free
- Generalizing to arbitrary n-point configurations (the 3-point case suffices)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Strengthened zone match is not provable for arbitrary linear orders -- i.e., no choice of u' in (x',t') splits interval types to match (x,u)/(x',u') | H | M | The blocker research identified this as the crux. The proof idea: when `interval_nf_types M k x t = interval_nf_types M' k x' t'` and u has a specific depth-k 1-var NF tau that appears in interval_nf_types(x,t), then there exists u' with the same tau in (x',t'). The key lemma is that the depth-k 1-var NF of u determines how it partitions the interval types of (x,t) into "before u" and "after u" types. If this fails, fall back to: prove only for discrete Prior structures (where the interval structure is simpler). |
| **Counterexample concern**: The v4 analysis constructed a counterexample where interval types match as SETS but type ARRANGEMENTS differ, defeating naive zone matching | H | L (for the strengthened version) | The counterexample exploits the gap between "same set of types" and "same arrangement of types." The strengthened zone match avoids this by selecting u' that not only has the correct 1-var NF but also partitions the interval consistently. The counterexample does not defeat this approach because it targets the original `zone_match_witness` which only guarantees set-level matching. |
| Lean's termination checker rejects the strong induction on j inside `nf_2var_existential_transfer` | M | M | Use `Nat.strongRecOn` or explicit well-founded recursion. The decreasing measure is j (depth), which strictly decreases at each recursive call. |
| `interval_nf_types` equality for sub-intervals requires additional lemmas not present in the codebase | M | H | The key missing lemma: `interval_nf_types_partition` -- if u in (x,t) and tau = nf_characteristic k 1 u, then `interval_nf_types M k x t` can be decomposed into types realized in (x,u), the type of u itself, and types realized in (u,t). Budget 100-150 lines for this and related sub-interval reasoning. |
| Build time exceeds heartbeat timeout for the large StaviCompleteness.lean file | M | H | Place the strengthened zone match and supporting lemmas in a new file (`StaviZoneMatch.lean` or `GeneralExistentialTransfer.lean`) and import it. Keep StaviCompleteness.lean modifications minimal (replacing sorry with theorem applications). |
| The 3-point case (u,x,t) requires handling all zone configurations (u < x, x < u < t, t < u) and each may need different sub-interval reasoning | M | L | The existing `zone_match_witness` already handles all zone cases (below-min, in-interval, above-max). The strengthened version adds interval-type guarantees only for the in-interval case (x < u < t); the other cases are simpler because sub-intervals are trivial. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |

Phase 0 (axiom audit) and Phase 1 (SemanticBridge) from v3 are already [COMPLETED].

---

### Phase 0: Axiom Audit and Sorry State Verification [COMPLETED]

(From v3 plan -- already completed.)

- **Completed**: 2026-06-08

---

### Phase 1: SemanticBridge Infrastructure [COMPLETED]

(From v3 plan -- already completed.)

- **Completed**: 2026-06-08

---

### Phase 2: Strengthened Zone Match with Interval Splitting [BLOCKED]

**Goal**: Prove `zone_match_witness_with_splitting` -- a strengthened version of `zone_match_witness` that additionally guarantees sub-interval type matching when the new point u falls inside the interval (x,t). Then restructure `nf_2var_existential_transfer` to use it with strong induction on depth j.

**Mathematical approach**:

The core insight from the blocker research: the existing `zone_match_witness` guarantees that u' has the same depth-k 1-var NF as u and correct orderings relative to x' and t'. The strengthened version additionally ensures:

```
x < u < t  AND  x' < u' < t'  IMPLIES
  interval_nf_types M k x u = interval_nf_types M' k x' u'
  AND interval_nf_types M k u t = interval_nf_types M' k u' t'
```

**Proof strategy for the strengthened zone match**:

Given: `interval_nf_types M k x t = interval_nf_types M' k x' t'`, u in (x,t) with `nf_characteristic M k 1 u = tau`.

1. Since tau appears in `interval_nf_types M k x t`, and the sets are equal, there exists u' in (x',t') with `nf_characteristic M' k 1 u' = tau`.
2. The interval (x,t) decomposes into (x,u) U {u} U (u,t). Every point v in (x,u) contributes its 1-var NF to `interval_nf_types M k x t`, and specifically to the "left of u" partition.
3. **Key lemma** (`interval_nf_types_partition`): For u in (x,t), the interval types of (x,t) are the union of interval types of (x,u), {tau}, and interval types of (u,t). Moreover, if two points u and u' have the same 1-var NF tau, and the ambient interval types agree, then the left/right partitions agree when u' is chosen appropriately.
4. The choice of u' uses the fact that interval types form a multiset (with multiplicity), and choosing u' with the same position in the ordering of types forces the left/right splits to agree.

**Tasks**:
- [ ] **Task 2.1**: Prove `interval_nf_types_partition` -- given x < u < t, relate `interval_nf_types M k x t` to `interval_nf_types M k x u` and `interval_nf_types M k u t`. Specifically: `interval_nf_types M k x u` is a subset of `interval_nf_types M k x t`, and similarly for (u,t). The union recovers the full set. *(deviation: skipped -- subset proved but union equality is not useful since interval types are Finsets without arrangement info)*
- [ ] **Task 2.2**: Prove `zone_match_witness_with_splitting` -- given the hypotheses of `zone_match_witness` plus `interval_nf_types M k x t = interval_nf_types M' k x' t'`, produce u' satisfying all original conclusions PLUS the sub-interval type equalities. The proof selects u' from (x',t') by choosing a point that partitions the interval types of (x',t') in the same way u partitions those of (x,t). *(deviation: blocked -- the strengthened zone match is unprovable for arbitrary linear orders; see BLOCKER below)*
- [ ] **Task 2.3**: Restructure `nf_2var_existential_transfer` to use strong induction on depth j (via `Nat.strongRecOn` or `WellFoundedRelation`). At depth j'+1, the existential transfer step zone-matches u to u' using the strengthened lemma, then applies the induction hypothesis at depth j' with the guaranteed sub-interval types. The recursive call is well-founded because j' < j'+1. *(deviation: blocked -- depends on Task 2.2)*
- [ ] **Task 2.4**: Verify the restructured theorem compiles and has the correct type signature to plug into the sorry sites at lines 2353 and 2435. *(deviation: blocked -- depends on Task 2.3)*

**BLOCKER** (Phase 2):
- **What failed**: The strengthened zone match (`zone_match_witness_with_splitting`) is unprovable for arbitrary linear orders. The sorry at `nf_2var_existential_transfer` lines 2353/2435 requires 4-variable existential transfer at depth j' for a 3-point configuration (u,x,t)/(u',x',t'). This requires sub-interval type data for pairs (x,u)/(x',u') and (u,t)/(u',t') that cannot be derived from the available hypotheses.
- **What was tried**:
  1. Strengthened zone match (plan v5 approach): Unprovable because `interval_nf_types` is a `Finset` (set membership only), not a multiset or sequence. Two linear orders can have the same set of 1-var NF types in an interval but different arrangements, so no single choice of u' can guarantee the sub-interval type sets match. Concrete counterexample at depth 0: M with types A,B arranged as A-left-B-right, M' with B-left-A-right; interval type Finsets are both {A,B} but sub-interval splits differ regardless of where u' is placed.
  2. Strong induction on j (quantifier depth): The base case (depth-0 4-var atom transfer) requires finding w' in the correct sub-interval (x',u') with the right predicates. Zone matching relative to (x,t) gives w' in (x',t') but cannot guarantee the ordering relative to u'. This IS the sub-interval problem, just at the base level.
  3. Induction on k (outer NF depth): Attempted deriving sub-interval data from depth-(k+1) to depth-k via `interval_nf_types_depth_decrease`. This gives depth-k interval types for (x,t)/(x',t') but NOT for sub-intervals (x,u)/(x',u').
  4. Using depth-k NF of u to extract witnesses in (x',u'): The depth-(k+1) NF of u encodes "there exists v < u with matching depth-k 2-var NF." This gives v' < u' with matching predicates, but cannot guarantee v' > x'. The NF encodes type-level information, not point-level position relative to specific other points.
  5. Using both u's and x's depth-k NF: From u's NF get w_u < u'; from x's NF get w_x > x'. But w_u might be below x' and w_x might be above u'. Cannot guarantee any point with w's predicates exists in (x',u').
  6. `nf_fraisse_compression` for 3-var NF at depth j'+1: Requires 4-var transfer at all depths below j'+1 including depth 0, which has the same sub-interval problem.
  7. Counterexample analysis at depth k >= 2: The depth-k NFs at higher depth encode enough neighborhood structure that the "wrong arrangement" counterexample is prevented (the depth-k interval types would differ). This suggests `nf_2var_from_interval_data` IS true, but the proof technique cannot handle the arrangement preservation.
- **Why it's stuck**: The fundamental issue is a mismatch between the NF-based proof technique (which processes variables one at a time via zone matching) and the EF game proof technique (which places all variables simultaneously via strategy composition). The zone match adds one point but loses information about its position relative to previously matched inner points. The GHR93 paper handles this via decomposition formulas and multi-point Duplicator strategy (Proposition 7), but the formalized infrastructure uses NFs rather than decomposition formulas, and the NF-to-game bridge does not exist.
- **What is needed**: One of the following approaches:
  1. **NF-to-Game Bridge** (~400-700 lines): Connect the NF hypotheses (`nf_2var_from_interval_data` hypotheses) to the existing game framework (`ghr93_strategy_compose` in Composition.lean). Show that matching 1-var NFs + orderings + interval types implies Duplicator wins the GHR93 custom game, then show the game win implies NF equality. This requires bridging between `nf_eval_nf`/`NormalForm` and `stavi_temporal_truth_mu`/`ExtendedCarrier`.
  2. **Multi-point zone match** (~300-500 lines): Instead of zone matching one point at a time, prove a version of Proposition 7 that matches an entire tuple simultaneously, maintaining interval data for all pairs. This is essentially reimplementing the game strategy at the NF level.
  3. **Strengthened interval invariant** (~200-400 lines): Change `interval_nf_types` from a `Finset` of 1-var NFs to a richer invariant (e.g., using `interval_2var_nf_types` or an ordered sequence of types) that captures arrangement information. This would make the strengthened zone match provable but requires modifying the theorem statements and the temporal formula construction (`nf_exist_sf_guarded`).
  4. **Accept sorry with axiom** (smallest change): Add `nf_2var_existential_transfer` as an axiom. The theorem IS mathematically true (confirmed by counterexample analysis showing depth-k NFs prevent arrangement problems for k >= 2), but the current proof architecture cannot express the proof. This is unsatisfying but unblocks Chain A.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder
- **Additional analysis (GHR93 Proposition 7 study)**: The GHR93 proof handles the sub-interval problem by having Duplicator play MULTIPLE points simultaneously (witnesses for all decomposition formulas), not one at a time. The NF-based approach processes one variable at a time via zone matching, losing sub-interval information at each step. The fix requires either (a) implementing multi-point zone matching at the NF level (Option 2 above), or (b) bridging to the game framework which already handles multi-point matching (Option 1). The coordinator suggests following the GHR93 prior art closely, which points toward Option 1 or Option 2.

**Timing**: 4 hours (original estimate; actual analysis time ~4 hours with no code changes)

**Depends on**: Phases 0, 1 (completed)

**Files to create/modify**:
- New file: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviZoneMatch.lean` (Tasks 2.1-2.2, estimated 300-500 lines)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (Task 2.3, restructure nf_2var_existential_transfer)

**Verification**:
- New file compiles with `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviZoneMatch`
- No sorry in the new file
- `nf_2var_existential_transfer` compiles without sorry after restructuring
- Type signatures match what the sorry sites need

---

### Phase 3: Fill Sorry Sites in StaviCompleteness.lean [NOT STARTED]

**Goal**: Replace the sorry at lines 2353 and 2435 with calls to the restructured `nf_2var_existential_transfer` from Phase 2. Then verify the full sorry chain is eliminated.

**Tasks**:
- [ ] Import StaviZoneMatch.lean in StaviCompleteness.lean (if the strengthened lemma is in a separate file)
- [ ] At line 2353 (forward direction, depth j'+1): construct the 3-point matching conditions for (u,x,t)/(u',x',t') from the existing zone_match output and apply the restructured `nf_2var_existential_transfer` with the guaranteed sub-interval types
- [ ] At line 2435 (backward direction, depth j'+1): symmetric case, construct matching conditions for (u',x',t')/(u,x,t) and apply the transfer theorem
- [ ] Fill the sorry at line 2805 (`nf_exist_sf_guarded_backward`) which depends on `nf_2var_from_interval_data` -- this should become sorry-free once the transfer theorem is proved
- [ ] Verify `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds with no sorry
- [ ] Run `lean_verify` on `stavi_expressive_completeness` to confirm no sorryAx
- [ ] Run `lean_verify` on `US_expressively_complete_over_prior` to confirm no sorryAx

**Timing**: 2 hours

**Depends on**: Phase 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- replace sorry at lines 2353, 2435, 2805

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness` succeeds
- `#print axioms stavi_expressive_completeness` shows no sorryAx
- `#print axioms US_expressively_complete_over_prior` shows no sorryAx
- `#print axioms gap_prior_UZ_contradiction` shows no sorryAx

---

### Phase 4: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Run full project build, verify `completeness_discrete` sorry state, and confirm Chain A is eliminated end-to-end.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Run `#print axioms completeness_discrete` and compare against Phase 0 baseline:
  - If `sorryAx` is gone: Chain A is fully eliminated, task is complete
  - If `sorryAx` remains: identify which chain (should be Chain B via `chronicle_gap_contradiction`)
- [ ] Verify the full Chain A sorry chain is eliminated:
  - `stavi_expressive_completeness` -- sorry-free
  - `US_expressively_complete_over_prior` -- sorry-free
  - `gap_prior_UZ_contradiction` -- sorry-free
  - `gap_prior_SZ_contradiction` -- sorry-free
  - `no_gaps_discrete_model_surgery` -- sorry-free
  - `limitdom_is_good` -- sorry-free
  - `countermodel_discrete_reynolds_v2` -- sorry-free (from Chain A perspective)
- [ ] Verify no new `sorry` introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows no results (excluding comments)
- [ ] Run existing tests: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: Phase 3

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` result documented
- `grep` finds no unexpected sorry in EFGames/ directory
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors for the full project
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.stavi_expressive_completeness` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.gap_prior_UZ_contradiction` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` -- either no `sorryAx` or only through Chain B (documented)
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes
- [ ] No new `sorry` introduced in `EFGames/` directory
- [ ] No import cycles (verified by successful `lake build`)
- [ ] Existing `Tests/BimodalTest/` tests pass

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/05_strengthened-zone-match-plan.md` (this file, v5)
- Existing (Phase 0 complete): Axiom audit results
- Existing (Phase 1 complete): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- New (Phase 2): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviZoneMatch.lean`
- Modified (Phase 2-3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
- `specs/273_chronicle_gap_contradiction_proof/summaries/05_strengthened-zone-match-summary.md`

## Rollback/Contingency

- **If the strengthened zone match cannot be proved for arbitrary linear orders**: Restrict to discrete Prior structures (Z). In the discrete case, interval types have a natural enumeration and the splitting is simpler because the ordering is isomorphic to a subset of Z. This may require a separate `zone_match_witness_discrete` and would only eliminate Chain A for `completeness_discrete` (not `completeness_dense`), which is the actual goal.
- **If the interval_nf_types_partition lemma reveals the decomposition is more complex than expected**: Use a counting argument -- since `interval_nf_types` returns a `Finset`, the sub-interval types are finite subsets whose union equals the total, and an injective pairing argument guarantees the partition is preserved under zone matching.
- **If the strong induction structure doesn't work cleanly in Lean's termination checker**: Use `Nat.strongRecOn` or `WellFoundedRelation` explicitly, packaging the decreasing depth j as the well-founded measure.
- **If build time exceeds heartbeat**: Split StaviZoneMatch.lean into sub-modules, or increase heartbeat for that file.
- **Git revert** to the commit before implementation if any phase introduces regressions.
