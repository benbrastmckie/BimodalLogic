# Implementation Plan: Generalized Existential Transfer (v12)

- **Task**: 273 - Eliminate sorryAx from `completeness_discrete` via generalized NF transfer
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/07_sorry-chain-verification.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_game-pipeline-research.md
  - specs/273_chronicle_gap_contradiction_proof/plans/11_discrete-backward-plan.md (BLOCKED — see lessons below)
  - literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md (Section 8, Proposition 7)
  - literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch10.md (Separation for integer time)
- **Artifacts**: plans/12_generalized-transfer-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v11 (discrete backward via game pipeline) is **BLOCKED** at two levels. This
plan (v12) takes a fundamentally different approach grounded in the literature
(GHR93 Proposition 7). Instead of trying to bypass the general sorry with a
discrete-only version, we prove the general sorry directly.

### What Failed in v11 (and why)

**Blocker 1 (Fatal — IsSuccArchimedean circularity)**: v11 proposed wiring
`discrete_stavi_expressive_completeness` into `US_expressively_complete_over_prior`
at PriorExpressiveness.lean:384. This is architecturally unsound because
`US_expressively_complete_over_prior` is used downstream for models that do NOT
have `IsSuccArchimedean`. Specifically, `gap_prior_UZ_contradiction` at
`GoodStructuresModelSurgery.lean:1266` invokes it on a model M that has
`SuccOrder + PredOrder + NoMaxOrder + NoMinOrder + semantic_prior_UZ/SZ` but
**not** `IsSuccArchimedean`. The whole purpose of that theorem is to derive a
contradiction that PROVES the model is IsSuccArchimedean. You cannot use a
discrete-only theorem to prove discreteness — this is circular.

This follows Reynolds 1994's completeness proof structure:
1. Build chronicle (countable discrete linear order with MCS labels)
2. Prove `US_expressively_complete_over_prior` for ALL Prior structures (GHR93)
3. Model surgery uses this on a model NOT YET KNOWN to be discrete
4. The contradiction establishes IsSuccArchimedean

**Blocker 2 (Bridge B blocked)**: v11's game pipeline (decomposition → game wins →
NF equality via `nf_fraisse_compression`) requires `h_transfer` (existential NF
transfer at all depths j < k), which is the very sorry we're trying to prove.
Bridge B (game wins → existential NF transfer) at NFGameBridge.lean:1198 is
explicitly documented as BLOCKED.

**Key lesson**: The literature (GHR93) does NOT use IsSuccArchimedean for
expressive completeness. The Stavi completeness theorem (GHR93 Theorem 3)
works for ALL linear orders via EF games. The codebase's architecture
(going through `stavi_expressive_completeness` → `flatten_stavi_correct_prior`)
is correct. The fix is to prove the general theorem, not route around it.

### What the Literature Says

**GHR93 Section 8** proves {U,S,U',S'} expressive completeness for all linear
time via Theorem 6 (forward→backward EF games) and Proposition 7 (game
composition from local interval games to global games).

**GHR93 Proposition 7** (p.114): Given matching interval data between
corresponding pairs of an m-tuple, Duplicator has a winning strategy for the
full n-round EF game. The proof is by induction on n (game rounds). Each round
adds one new point to both tuples. After n rounds, we have m+n points and the
game is over.

In NF terms, this translates to: given matching data for an n-var configuration
at depth k, existential extensions match at depth j < k. At j+1, the new point
increases arity by 1, but depth decreases to j. After j steps, we reach depth 0
at arity n+j, where only atoms matter (no quantifier transfer needed).

**The sorry at StaviCompleteness.lean:2353/2435** tries to do this for arity 2
only, creating an arity escalation (needs 4-var to prove 3-var). The fix is to
universally quantify over arity in the induction hypothesis.

### This Plan's Approach

Prove a **generalized existential transfer theorem** by strong induction on depth j,
universally quantified over arity n. This closes the sorry in
`nf_2var_existential_transfer`, making `nf_2var_from_interval_data` provable,
making `nf_exist_sf_guarded_backward` provable, making `stavi_expressive_completeness`
sorry-free, making `US_expressively_complete_over_prior` sorry-free, making
`completeness_discrete` sorry-free.

No IsSuccArchimedean needed anywhere. Works for all linear orders.

### Research Integration

Reports integrated:
- `07_sorry-chain-verification.md`: Confirmed single sorry chain, root at
  `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805)
- `08_game-pipeline-research.md`: Verified game pipeline components sorry-free
  for discrete case; identified arity escalation as the core obstacle
- Plan v11 blocker analysis: Confirmed IsSuccArchimedean circularity is fatal

### Roadmap Alignment

- "Sorry-free `completeness_discrete`" — this task directly advances the critical path
- "EF-game expressiveness infrastructure" — this plan completes the general theory
  (not just discrete), making ALL downstream uses sorry-free

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` (StaviCompleteness.lean:2353, 2435)
- Make `stavi_expressive_completeness` sorry-free
- Make `US_expressively_complete_over_prior` sorry-free
- Achieve sorry-free `completeness_discrete` end-to-end
- Work for ALL linear orders (no IsSuccArchimedean requirement)

**Non-Goals**:
- Filling dead-code sorry sites in DiscreteStaviCompleteness.lean
- Implementing the full EF game framework separately
- Proving Cases III/IV of general Theorem 6 (CaseAnalysis.lean)
- Modifying the Reynolds model surgery pipeline

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generalizing `zone_match_witness` to n-var is harder than expected | M | M | Start with n=3 concretely, then generalize. The 5-zone case analysis is identical at each arity — only the bookkeeping grows. |
| `matching_data` predicate for n-var is complex to state correctly | M | L | Follow GHR93 Proposition 7's hypotheses exactly: matching decomposition formulas for each adjacent pair in the tuple. |
| Lean's dependent type system makes arity-polymorphic proofs awkward | H | M | Use `(n : Nat)` as explicit parameter, not a typeclass. All NF machinery already takes `n` explicitly. Fallback: prove at n=2,3,4 concretely if polymorphic version is too painful. |
| Strong induction on j with universal quantification on n may confuse the elaborator | M | L | Use `Nat.strongRecOn` or well-founded recursion. The induction is standard — depth decreases at each step. |
| nf_fraisse_compression at higher arity needs matching_data construction | M | M | At each recursive call, the new configuration (u::env) satisfies matching_data because zone_match_witness provides the matching point with correct NFs, ordering, and interval types. Factor into a lemma: `zone_match_preserves_matching`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

---

### Phase 1: Generalized Zone Match and Matching Data [BLOCKED]

**Goal**: Generalize `zone_match_witness` from 2-var to n-var, and define
`matching_data` predicate for n-var configurations.

**Mathematical content (GHR93 Proposition 7 hypotheses)**: Two n-tuples
env_M and env_M' "match at depth k" when:
1. Each point has the same 1-var depth-k NF as its counterpart
2. The orderings between all pairs agree
3. The interval NF types between each pair of adjacent points agree
4. The NF types above the maximum and below the minimum agree

Given matching data, `zone_match_witness_general` finds for any new point u in M
a corresponding u' in M' with matching 1-var NF and correct orderings relative
to all points in the tuple.

**BLOCKER** (Phase 1):
- **What failed**: The zone matching extension property (Task 1.3) requires proving that when a zone-matched point w/w' is added to an n-point configuration, the interval NF types for the new sub-intervals (env_M(i), w)/(env_M'(i), w') match between M and M'. This is the "interval splitting" property from GHR93.
- **What was tried**:
  1. Direct approach using `zone_match_witness` relative to original (x,t) pair -- gives orderings relative to x',t' but NOT relative to other zone-matched points in the extended config.
  2. Strong induction on depth j with universal quantification over arity n -- the zone matching hypothesis for extended configs requires orderings relative to ALL env points including newly added ones. A proof skeleton was tested (compiles with sorries at the zone matching extension points).
  3. Derivation of sub-interval types from containing interval's types via `interval_nf_types_depth_decrease` -- only gives depth decrease for the SAME interval, not for sub-intervals.
  4. Using depth-k 1-var NF agreement to derive sub-interval structure -- the 1-var NF of a point encodes its neighbors' structure but NOT the sub-interval types relative to specific reference points (the sub-interval constraint requires positional information not in the 1-var NF).
- **Why it's stuck**: The fundamental obstacle is that zone matching relative to a 2-point reference (x,t) does NOT determine orderings between independently zone-matched points in the same zone. Following GHR93 Proposition 12.8.18, the correct proof uses decomposition formula matching (Lemma 12.8.14) to convert containing-interval game strategies into sub-interval game strategies. In NF terms, this requires either: (a) using `interval_2var_nf_types` (2-var interval types) instead of `interval_nf_types` (1-var) to encode the spatial arrangement within intervals, or (b) proving that the existing 1-var interval types at depth k, combined with the NF recursion structure, DO determine the 2-var NF -- but this proof itself requires the existential transfer at lower depth, creating a circular dependency that must be broken by a simultaneous induction.
- **What is needed**: The implementation requires one of these approaches:
  (A) **Strengthen matching_data to use `interval_2var_nf_types`**: Define zone matching that finds w' with the same 2-var NF (w,b)/(w',b') relative to the adjacent endpoint b. This automatically provides interval splitting because the 2-var NF encodes the quantifier structure. The extension lemma then derives new sub-interval data from the 2-var NF quant part. Estimated ~400-600 lines.
  (B) **Simultaneous induction on depth k**: Prove `nf_2var_from_interval_data` by induction on k (the depth parameter), where at step k+1, the IH at depth k provides 2-var NF equality at depth k, from which existential transfer at depth k-1 is extracted. This avoids needing zone matching at the full depth k but requires restructuring the proof chain. Estimated ~300-500 lines.
  (C) **Game-theoretic formulation**: Define EF game positions and strategies explicitly, following GHR93 Section 8. Prove Proposition 7 (game composition) and Theorem 6 (forward-backward conversion) in the game framework, then bridge to NFs. Most faithful to the literature but largest implementation. Estimated ~800-1200 lines.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [ ] **Task 1.1**: Define `matching_data k n M env_M M' env_M'` predicate
  encoding the four conditions above for sorted n-tuples.
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - **Estimated size**: 30-50 lines (structure definition + basic accessors)

- [ ] **Task 1.2**: Prove `zone_match_witness_general` — given `matching_data`
  and a point `u : M.carrier`, produce `u' : M'.carrier` with:
  (a) same 1-var depth-k NF
  (b) same ordering relative to every point in env_M'/env_M
  - **Approach**: Determine which "zone" u falls in relative to the sorted tuple.
    For u equal to some env_M(i), return env_M'(i). For u between env_M(i) and
    env_M(i+1), use interval_nf_types matching. For u above/below all, use
    above_max/below_min matching. This is the same 5-zone case analysis as
    `zone_match_witness` but generalized to n zones (between each adjacent pair).
  - **File**: `StaviCompleteness.lean` (near existing `zone_match_witness`)
  - **Estimated size**: 100-200 lines

- [ ] **Task 1.3**: Prove `zone_match_extends_matching_data` — if env_M/env_M'
  have `matching_data k n` and u/u' are the matched pair from Task 1.2, then
  (u::env_M)/(u'::env_M') have `matching_data k (n+1)` (with the appropriate
  sorting). This is the key inductive step: adding a matched point preserves
  the matching invariant.
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 80-150 lines

**Timing**: 3-4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_goal` confirms matching_data is well-typed
- `lean_verify zone_match_witness_general` — no sorryAx
- `lean_verify zone_match_extends_matching_data` — no sorryAx

---

### Phase 2: Generalized Existential Transfer [NOT STARTED]

**Goal**: Prove the generalized existential transfer theorem by strong induction
on depth j, universally quantified over arity n.

**Mathematical content (GHR93 Proposition 7 in NF terms)**: For all j ≤ k,
for all n ≥ 2, given `matching_data k n M env_M M' env_M'`, for all
chi : NormalForm sig j (n+1):

```
(∃ u, nf_eval_nf M j (n+1) (Fin.cons u env_M) chi) ↔
(∃ u', nf_eval_nf M' j (n+1) (Fin.cons u' env_M') chi)
```

**Proof by strong induction on j**:

*Base case j = 0*: Given u, use `zone_match_witness_general` to find u'. At depth
0, only atoms matter. Atom agreement follows from zone_match (same 1-var NF +
correct ordering). The ↔ holds by symmetry.

*Inductive step j = j'+1*: Given u, use `zone_match_witness_general` to find u'.
By Task 1.3, (u::env_M)/(u'::env_M') have `matching_data k (n+1)`.

Apply `nf_fraisse_compression` at arity n+1 and depth j'+1. This requires:
- `h_atoms`: atom agreement at arity n+1 ✓ (from zone_match)
- `h_transfer` at arity n+2 for depths j'' < j'+1: by the IH at depth j'' < j
  with arity n+1 (which quantifies universally over arity), this holds.

The result is: `nf_characteristic M (j'+1) (n+1) (u::env_M) = nf_characteristic M' (j'+1) (n+1) (u'::env_M')`. This gives `nf_eval_nf` transfer.

**Why this terminates**: Each recursive call decreases j by 1. Arity increases
(n → n+1 → n+2 → ...), but this is fine — the induction is purely on j. After j
steps, we reach j=0 at arity n+j, where atom agreement suffices. The number of
NormalForm types at each arity is finite (Fintype instance), so all quantifiers
are decidable.

**Tasks**:
- [ ] **Task 2.1**: State and prove `generalized_existential_transfer` — the
  main theorem. Use `Nat.strongRecOn` or equivalent for strong induction on j.
  - **File**: `StaviCompleteness.lean` (new section after `nf_2var_existential_transfer`)
  - **Estimated size**: 100-200 lines

- [ ] **Task 2.2**: Specialize to n=2 to close the sorry at
  `nf_2var_existential_transfer` (lines 2353, 2435). The specialization
  constructs `matching_data k 2` from the existing hypotheses (h_nf_x, h_nf_t,
  h_order_xt, h_interval_above, h_interval_below, h_above_max, h_below_min)
  and then applies the generalized theorem.
  - **File**: `StaviCompleteness.lean` (replace sorry at lines 2353, 2435)
  - **Estimated size**: 40-80 lines

**Timing**: 3-4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_verify generalized_existential_transfer` — no sorryAx
- `lean_verify nf_2var_existential_transfer` — no sorryAx (was sorry'd)
- `lean_verify nf_2var_from_interval_data` — no sorryAx (was sorry'd via transfer)

---

### Phase 3: Close nf_exist_sf_guarded_backward [NOT STARTED]

**Goal**: With `nf_2var_from_interval_data` now sorry-free (via Phase 2), prove
`nf_exist_sf_guarded_backward` at StaviCompleteness.lean:2805.

**Mathematical content**: Given that the guarded StaviFormula holds at t:
1. Extract witness x from the temporal formula (U gives x > t, S gives x < t,
   equality gives x = t)
2. From char_k_correct, determine x's 1-var depth-k NF type
3. From the interval guard, extract the types of intermediate points
4. Construct a reference model M_ref where sub_nf is realized (using
   Classical.choice on the NF realizability from `nf_characteristic_satisfies`)
5. Apply `nf_2var_from_interval_data` to conclude 2-var NF equality

**Tasks**:
- [ ] **Task 3.1**: Prove `nf_exist_sf_guarded_backward` — fill the sorry at
  line 2805 following the 5-step outline above.
  - **File**: `StaviCompleteness.lean` (replace sorry at line 2805)
  - **Estimated size**: 100-200 lines

- [ ] **Task 3.2**: Verify the full Stavi completeness chain is sorry-free:
  - `lean_verify nf_exist_sf_guarded_backward` — no sorryAx
  - `lean_verify nf_2var_exist_sf_classical` — no sorryAx
  - `lean_verify nf_characterizable_by_stavi` — no sorryAx
  - `lean_verify stavi_expressive_completeness` — no sorryAx

**Timing**: 2-3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_verify stavi_expressive_completeness` — no sorryAx (primary success criterion)
- Zero sorry sites in `nf_exist_sf_guarded_backward`

---

### Phase 4: Full Chain Verification [NOT STARTED]

**Goal**: Verify the entire sorry chain from `completeness_discrete` is resolved.

**Tasks**:
- [ ] **Task 4.1**: Verify `US_expressively_complete_over_prior`:
  - `lean_verify US_expressively_complete_over_prior` — no sorryAx

- [ ] **Task 4.2**: Verify model surgery chain:
  - `lean_verify gap_prior_UZ_contradiction` — no sorryAx
  - `lean_verify no_gaps_discrete_model_surgery` — no sorryAx

- [ ] **Task 4.3**: Verify `completeness_discrete`:
  - `lean_verify completeness_discrete` — no sorryAx (or sorryAx only through
    non-273 chains like chronicle construction)

- [ ] **Task 4.4**: Full build verification:
  - `lake build` passes without errors
  - No new sorry introduced anywhere
  - No import cycles introduced

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**: None (verification only)

**Verification**:
- `lean_verify completeness_discrete` — no sorryAx from this chain
- `lake build` passes

---

## Testing & Validation

- [ ] `lean_verify generalized_existential_transfer` — no sorryAx
- [ ] `lean_verify nf_2var_existential_transfer` — no sorryAx
- [ ] `lean_verify nf_2var_from_interval_data` — no sorryAx
- [ ] `lean_verify nf_exist_sf_guarded_backward` — no sorryAx
- [ ] `lean_verify stavi_expressive_completeness` — no sorryAx
- [ ] `lean_verify US_expressively_complete_over_prior` — no sorryAx
- [ ] `lean_verify completeness_discrete` — no sorryAx from this chain
- [ ] `lake build` passes without errors
- [ ] No new sorry introduced anywhere

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/12_generalized-transfer-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (~400-700 new lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/08_generalized-transfer-summary.md`

## Rollback/Contingency

- **If n-var zone_match is too complex**: Prove at concrete arities n=2,3,4
  instead of polymorphically. The sorry only needs arity 2, which recurses to
  arity 3, then 4, then 5... but the recursion bottoms out at depth 0 after at
  most k steps. So proving at arities 2 through k+2 suffices. In practice, k is
  bounded by the formula's quantifier depth.

- **If matching_data predicate is awkward for sorted tuples**: Work with
  unsorted tuples and carry ordering hypotheses explicitly (as the existing
  `zone_match_witness` does for n=2). The matching conditions can be stated
  as: for all i,j in Fin n, env_M(i) < env_M(j) ↔ env_M'(i) < env_M'(j).

- **If strong induction elaboration is painful**: Use `WellFoundedRelation` on
  `(j, n)` pairs with lexicographic ordering (j decreases is primary). Or
  use `Nat.rec` with an auxiliary function carrying the universal statement.

- **Git revert** to current commit if any phase introduces regressions.
