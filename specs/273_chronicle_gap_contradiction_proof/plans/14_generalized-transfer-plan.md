# Implementation Plan: Arity-Parametric Existential Transfer (v14)

- **Task**: 273 - Eliminate sorryAx from `completeness_discrete` via generalized NF transfer
- **Status**: [NOT STARTED]
- **Effort**: 8-12 hours
- **Dependencies**: None
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/07_sorry-chain-verification.md
  - specs/273_chronicle_gap_contradiction_proof/reports/08_game-pipeline-research.md
  - specs/273_chronicle_gap_contradiction_proof/plans/11_discrete-backward-plan.md (BLOCKED -- IsSuccArchimedean circularity)
  - specs/273_chronicle_gap_contradiction_proof/plans/12_generalized-transfer-plan.md (BLOCKED -- 1-var interval types insufficient)
  - specs/273_chronicle_gap_contradiction_proof/plans/13_generalized-transfer-plan.md (BLOCKED -- fixed arity insufficient)
  - specs/273_chronicle_gap_contradiction_proof/handoffs/phase-1-handoff-v13-20260609.md (blocker analysis)
  - literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md (Section 8, Proposition 7, Lemma 11)
  - literature/Gabbay_Hodkinson_Reynolds_1994_Temporal_Logic_Foundations_Vol1_ch12.md (Proposition 12.8.18, Lemma 12.8.14)
- **Artifacts**: plans/14_generalized-transfer-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plans v11, v12, and v13 each failed due to different but related issues in
proving `nf_2var_existential_transfer` (StaviCompleteness.lean, sorry sites at
lines 2353 and 2435). This plan (v14) resolves all three blockers simultaneously
by implementing GHR93 Proposition 7 / GHR94 Proposition 12.8.18 faithfully:

- **v11 blocker** (IsSuccArchimedean circularity): The proof must work for ALL
  linear orders, not just discrete ones. This plan makes no discreteness
  assumptions.
- **v12 blocker** (1-var interval types insufficient): Zone matching with 1-var
  NFs (`interval_nf_types`) cannot determine sub-interval structure when
  independently zone-matched points are in the same interval. This plan uses
  2-var interval types (`interval_2var_nf_types`, line 1847) which encode both
  the point's 1-var type AND its quantifier-level relationship to the interval
  endpoint.
- **v13 blocker** (fixed arity insufficient): Proving 3-var transfer at depth j
  requires 4-var transfer at depth j-1, which requires 5-var transfer at depth
  j-2, etc. This arity-growth recursion terminates at depth 0 (atoms suffice at
  any arity), but requires a theorem parametric in BOTH depth j AND arity n.
  Plan v13 worked at fixed arity 2; this plan universally quantifies over n.

The correct approach, following GHR93 Proposition 7, combines arity-parametric
induction (from v12's insight) with 2-var interval types (from v13's insight).
The main theorem is proved by `Nat.strongRecOn` on depth j, with arity n as a
universally quantified free variable that grows at each inductive step.

### Research Integration

Reports integrated:
- `07_sorry-chain-verification.md`: Confirmed single sorry chain, root at
  `nf_exist_sf_guarded_backward` (StaviCompleteness.lean:2805)
- `08_game-pipeline-research.md`: Verified game pipeline components sorry-free
  for discrete case; identified arity escalation as core obstacle
- Plan v11 blocker analysis: Confirmed IsSuccArchimedean circularity is fatal
- Plan v12 Phase 1 handoff: Confirmed 1-var interval types insufficient;
  identified `interval_2var_nf_types` (line 1847) as the resolution
- Plan v13 Phase 1 handoff: Confirmed fixed-arity approach fails due to
  arity growth; identified arity-parametric induction as the resolution

## Goals & Non-Goals

**Goals**:
- Prove `nf_2var_existential_transfer` (StaviCompleteness.lean:2353, 2435)
- Make `stavi_expressive_completeness` sorry-free
- Make `US_expressively_complete_over_prior` sorry-free
- Achieve sorry-free `completeness_discrete` end-to-end
- Work for ALL linear orders (no IsSuccArchimedean requirement)
- Follow GHR93 Proposition 7 proof structure faithfully
- Use arity-parametric induction on depth j, universally over n

**Non-Goals**:
- Filling dead-code sorry sites in DiscreteStaviCompleteness.lean
- Implementing a full EF game framework separately (decomposition formulas
  are encoded as 2-var NFs, not as a separate game layer)
- Proving Cases III/IV of general Theorem 6 (CaseAnalysis.lean)
- Modifying the Reynolds model surgery pipeline
- Changing the signature of `nf_2var_from_interval_data` or
  `nf_exist_sf_guarded_backward` (the new theorem is self-contained and
  plugs into the existing sorry sites directly)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `IsMatchedConfig` predicate too complex for Lean type-checker at variable arity n | M | M | Keep the predicate simple: quantify over all pairs (i,j) for ordering and all "adjacent" pairs for interval data. Use `Fin n` throughout. Avoid dependent types beyond `Fin n -> carrier`. |
| Zone matching at variable arity harder than at fixed arity | M | L | The zone matching itself is identical to the existing `zone_match_witness` -- only the bookkeeping of which intervals to update changes. The 5-zone case analysis is the same. |
| Sub-interval 2-var type derivation from 2-var NF agreement is non-trivial | M | M | The 2-var NF at (u, endpoint) at depth K encodes which NFs are realized in (u, endpoint). By equality, the same NFs are realized in (u', endpoint'). This is a direct Finset equality argument. |
| `Nat.strongRecOn` universe/type issues with variable arity | L | L | Use `Nat.strongRecOn j (fun j => ...)` where the statement is universally quantified over n. The arity n does not appear in the recursion variable. |
| Existing `nf_fraisse_compression` at variable arity n requires matching env representations | M | M | The existing `nf_fraisse_compression` already takes `n : Nat` as parameter. The environments `Fin n -> carrier` compose naturally with `Fin.cons`. |
| Performance with large Fin.cons chains at high arity | L | M | All definitions are noncomputable. Avoid unfolding Fin.cons in proofs; work with membership/evaluation lemmas instead. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Matched Configuration Predicate and 2-var Zone Matching [BLOCKED]

**Goal**: Define the `IsMatchedConfig` predicate parametric in arity n and data
depth K, and build the 2-var zone matching infrastructure that produces a
matched point with sub-interval data.

**Literature basis**: GHR93 Proposition 7 / GHR94 Proposition 12.8.18 --
the game position (m-tuple with interval strategies) is our matched
configuration. The decomposition formula matching (GHR93 Lemma 11 / GHR94
Lemma 12.8.14) is encoded by `interval_2var_nf_types` equality.

**BLOCKER** (Phase 1):
- **What failed**: The sorry sites at lines 2405 and 2487 of StaviCompleteness.lean
  require 4-var existential transfer at depth j' for the 3-point config (u,x,t)/(u',x',t').
  This is the arity escalation problem: proving n-var transfer at depth j requires (n+1)-var
  transfer at depth j-1, which requires (n+2)-var transfer at depth j-2, etc.
- **What was tried**: Multiple approaches analyzed in depth:
  1. Direct zone matching with 1-var interval data for the extended config -- FAILS because
     we lack interval_nf_types for new pairs (u,x), (u,t) created by zone matching u into
     the (x,t) interval.
  2. Deriving interval data for new pairs from pairwise NF agreement -- FAILS because pairwise
     1-var NFs at endpoints do not determine interval structure (fundamental limitation of
     1-var NFs identified in plan v12).
  3. Using nf_fraisse_compression alone (without zone matching) -- FAILS due to off-by-one:
     nf_fraisse_compression at depth j gives NF equality at depth j but needs transfer at
     depth j-1, creating a chicken-and-egg dependency.
  4. Strong induction on depth without interval data -- FAILS because zone matching is required
     at each recursive level to bridge the off-by-one, and zone matching requires interval data.
  5. Using the outer IH (3-var transfer for (x,t)) to derive 4-var transfer for (u,x,t) --
     FAILS because 3-var transfer and 4-var transfer are structurally different.
- **Why it's stuck**: The fundamental issue is a circularity between three requirements:
  (A) Zone matching a new point requires interval data for the pair containing it
  (B) Interval data for new pairs (created by zone matching) requires 2-var NF equality
  (C) 2-var NF equality requires the existential transfer theorem being proved
  Breaking this circularity requires the 2-var interval type approach from GHR93 Lemma 11,
  where zone matching with `interval_2var_nf_types` automatically provides sub-interval
  2-var type data (at depth D-1 from data at depth D). This depth budget approach is
  well-founded because the transfer depth j decreases to 0 simultaneously.
- **What is needed**: Implementation of the full 2-var interval type machinery:
  (1) `interval_2var_nf_types_depth_decrease`: derive depth-k from depth-(k+1) agreement
  (2) `zone_match_witness_2var`: zone matching using 2-var interval types
  (3) `sub_interval_2var_from_nf_match`: derive sub-interval 2-var types from 2-var NF match
      (the key lemma, corresponding to GHR93 Lemma 11)
  (4) `multi_arity_transfer`: arity-parametric transfer by Nat.strongRecOn, using (1)-(3)
  (5) Bridge from existing 1-var hypotheses to 2-var matched config at depth 0 (base case)
  Estimated: 300-500 lines. The main difficulty is lemma (3), which requires showing that the
  depth-k 2-var NF of (u, hi) determines interval_2var_nf_types at depth k-1 for (u, hi).
  This in turn requires proving that the depth-(k-1) 3-var NF of (w, u, hi) determines
  the depth-(k-1) 2-var NF of (w, hi) -- a "NF projection" lemma.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

**Tasks**:
- [ ] **Task 1.1**: Define `IsMatchedConfig` -- the matched configuration
  predicate, parametric in n (arity) and K (data depth).
  ```
  def IsMatchedConfig (sig : MonadicSignature) (n K : Nat)
      (M : OrderedMonadicStructure sig) (env_M : Fin n -> M.carrier)
      (M' : OrderedMonadicStructure sig) (env_M' : Fin n -> M'.carrier) : Prop :=
    -- (a) Pointwise 1-var NF agreement at depth K
    (forall i : Fin n, nf_characteristic M K 1 (fun _ => env_M i) =
                       nf_characteristic M' K 1 (fun _ => env_M' i)) /\
    -- (b) Pairwise ordering agreement
    (forall i j : Fin n, env_M i < env_M j <-> env_M' i < env_M' j) /\
    -- (c) Interval 2-var NF type agreement for all adjacent pairs
    --     "adjacent" = no point of the config lies between them
    (forall i j : Fin n, env_M i < env_M j ->
      (forall l : Fin n, not (env_M i < env_M l /\ env_M l < env_M j)) ->
      interval_2var_nf_types M K (env_M i) (env_M j) =
      interval_2var_nf_types M' K (env_M' i) (env_M' j))
  ```
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - **Location**: After `atom_agree_from_pointwise` (line ~2238), before
    `nf_2var_existential_transfer` (line ~2266)
  - **Estimated size**: 30-50 lines
  - **Literature ref**: GHR93 Prop 7 hypothesis -- "Exists has winning strategies
    for G_{f(n),g(n)}(M, x_i x_{i+1}; N, y_i y_{i+1}) for all 0 <= i <= m"
    The interval game strategy IS the `interval_2var_nf_types` equality
    (by GHR93 Lemma 11 / GHR94 Lemma 12.8.14).

- [ ] **Task 1.2**: Prove `interval_2var_nf_types_imply_1var` -- 2-var interval
  type agreement implies 1-var interval type agreement. The 1-var NF of u is
  extractable from the 2-var NF of (u, endpoint) by projection.
  ```
  theorem interval_2var_nf_types_imply_1var :
      interval_2var_nf_types M K lo hi = interval_2var_nf_types M' K lo' hi' ->
      interval_nf_types M K lo hi = interval_nf_types M' K lo' hi'
  ```
  - **Approach**: For each 1-var NF tau realized in (lo, hi) by witness u,
    the 2-var NF of (u, hi) is in `interval_2var_nf_types M K lo hi`. By
    hypothesis, it is in `interval_2var_nf_types M' K lo' hi'`, so there
    exists u' in (lo', hi') with the same 2-var NF. The 2-var NF determines
    the 1-var NF (depth-K agreement at arity 2 implies depth-K agreement at
    arity 1 by `nf_agreement_monotone` or by extracting the pred atoms).
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 30-50 lines
  - **Literature ref**: Immediate from the definitions -- 2-var type is a
    refinement of 1-var type.

- [ ] **Task 1.3**: Prove `zone_match_witness_2var` -- given a point u in
  interval (lo, hi) of M, and `interval_2var_nf_types` agreement between
  (lo, hi) and (lo', hi'), find u' in (lo', hi') with:
  (a) Same 2-var NF at depth K relative to the upper endpoint hi/hi':
      `nf_characteristic M K 2 (Fin.cons u (fun _ => hi)) =
       nf_characteristic M' K 2 (Fin.cons u' (fun _ => hi'))`
  (b) Orderings preserved: `lo < u iff lo' < u'`, `u < hi iff u' < hi'`
  - **Approach**: The 2-var NF of (u, hi) at depth K is in
    `interval_2var_nf_types M K lo hi`. By hypothesis equality, it is in
    `interval_2var_nf_types M' K lo' hi'`. Extract the witness u' from the
    Finset membership proof. Ordering preservation follows from the interval
    membership (u' in (lo', hi') gives lo' < u' < hi').
  - **Note**: This is analogous to the existing `zone_match_witness` but
    matches 2-var NFs instead of 1-var NFs. The existing zone_match_witness
    handles 5 zones (below min, = x, between, = t, above max). This lemma
    handles only the "between" zone for adjacent pairs; the outer theorem
    composes this with the existing infrastructure.
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 40-60 lines
  - **Literature ref**: GHR93 Prop 7 -- "She now applies her winning strategy
    for G_{f(n+1),r}(M, x_i x_{i+1}; N, y_i y_{i+1}). Let e be the point
    she chooses corresponding to a."

- [ ] **Task 1.4**: Prove `interval_2var_nf_types_from_2var_nf` -- given
  2-var NF equality at (u, hi)/(u', hi') at depth K, derive sub-interval
  2-var type agreement at depth K between (u, hi) and (u', hi'):
  ```
  theorem interval_2var_nf_types_from_2var_nf :
      nf_characteristic M K 2 (Fin.cons u (fun _ => hi)) =
      nf_characteristic M' K 2 (Fin.cons u' (fun _ => hi')) ->
      interval_2var_nf_types M K u hi = interval_2var_nf_types M' K u' hi'
  ```
  - **Approach**: The set `interval_2var_nf_types M K u hi` consists of all
    depth-K 2-var NFs realized by points in (u, hi). Each such point w gives
    a 3-var environment (w, u, hi). The 2-var NF of (u, hi) at depth K
    encodes (via the quant component) which 3-var depth-(K-1) NFs are
    realized. From 2-var NF equality, the same 3-var NFs at depth K-1 are
    realized. For the 2-var sub-NF of (w, hi), extract from the 3-var
    data by projection.
  - **Alternative approach**: The 2-var NF of (u, hi) encodes interval
    data directly. The `interval_2var_nf_types` is a Finset of NFs; show
    membership is preserved by the equality. Since the 2-var NF determines
    which 2-var NFs of (w, hi) are satisfiable for w in (u, hi), and
    equality gives the same satisfiability, the Finsets are equal.
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 40-80 lines
  - **Literature ref**: GHR93 Prop 7 step (3) -- "By Lemma 11, Exists has
    a winning strategy for G_{1+3f(n),r}(M, x_i a; N, y_i e)". The
    sub-interval game strategy comes from the matched decomposition
    formulas of the response point e.

- [ ] **Task 1.5**: Prove `zone_match_preserves_matching` -- given a matched
  n-config at depth K and a point w in interval (env_M i, env_M j) (where
  i,j are adjacent), find w' such that the (n+1)-config (with w/w' inserted)
  is matched at depth K (using 2-var NF agreement at depth K for the two new
  sub-intervals).
  ```
  theorem zone_match_preserves_matching :
      IsMatchedConfig sig n K M env_M M' env_M' ->
      env_M i < w /\ w < env_M j ->
      (forall l : Fin n, not (env_M i < env_M l /\ env_M l < env_M j)) ->
      exists w' : M'.carrier,
        IsMatchedConfig sig (n+1) K M (insert_env env_M i w)
                                      M' (insert_env env_M' i w')
  ```
  - **Approach**: Apply `zone_match_witness_2var` (Task 1.3) to find w' in
    (env_M' i, env_M' j) with 2-var NF match at (w, env_M j)/(w', env_M' j).
    The (n+1)-config matching requires:
    - (a) 1-var NF agreement: w has same 1-var NF as w' (extracted from
      2-var NF via projection).
    - (b) Orderings: w' is between env_M' i and env_M' j, and orderings
      with all other points follow from the original matched config
      orderings (since w is in the interval (env_M i, env_M j) and all
      other points are outside this interval by adjacency).
    - (c) 2-var interval types: The two new adjacent pairs are (env_M i, w)
      and (w, env_M j). For the upper sub-interval (w, env_M j), apply
      `interval_2var_nf_types_from_2var_nf` (Task 1.4). For the lower
      sub-interval (env_M i, w), use the same argument with the lower
      endpoint. Both use the 2-var NF match from zone matching.
  - **Note**: The "insert_env" helper inserts w into the Fin n -> carrier
    environment at the correct sorted position. Define this as a utility.
  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 80-120 lines (including insert_env helper)
  - **Literature ref**: GHR93 Prop 7 -- "By the induction hypothesis, Exists
    has a winning strategy for G^n((M, x bar a), (N, y bar e))." The
    (m+1)-tuple (x bar, a)/(y bar, e) is our extended matched config.

**Timing**: 4-5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_goal` confirms all new definitions are well-typed
- `lean_verify IsMatchedConfig` -- no sorry
- `lean_verify zone_match_witness_2var` -- no sorryAx
- `lean_verify interval_2var_nf_types_from_2var_nf` -- no sorryAx
- `lean_verify zone_match_preserves_matching` -- no sorryAx

---

### Phase 2: Arity-Parametric Existential Transfer Theorem [NOT STARTED]

**Goal**: Prove the main arity-parametric transfer theorem by `Nat.strongRecOn`
on depth j, universally quantified over arity n. This is the core of GHR93
Proposition 7 in NF terms.

**Literature basis**: GHR93 Proposition 7 / GHR94 Proposition 12.8.18 --
induction on n (game rounds = depth j). At round n+1: Duplicator finds e
matching decomposition formulas, IH at round n applies to extended tuple.
In NF terms: at depth j+1, zone-match to extend the config, apply IH at
depth j for the extended (n+1)-config.

**Tasks**:
- [ ] **Task 2.1**: State and prove `matched_config_transfer` -- the main
  arity-parametric theorem:
  ```
  theorem matched_config_transfer (sig : MonadicSignature)
      (n : Nat) (hn : n >= 2) (K : Nat)
      (M : OrderedMonadicStructure sig) (env_M : Fin n -> M.carrier)
      (M' : OrderedMonadicStructure sig) (env_M' : Fin n -> M'.carrier)
      (h_matched : IsMatchedConfig sig n K M env_M M' env_M') :
      forall j, j <= K ->
        forall chi : NormalForm sig j (n + 1),
          (exists w, nf_eval_nf M j (n + 1) (Fin.cons w env_M) chi) <->
          (exists w', nf_eval_nf M' j (n + 1) (Fin.cons w' env_M') chi)
  ```
  - **Proof structure**: `Nat.strongRecOn` on j:
    - **Base j = 0**: Zone-match w to w' using zone_match_witness (1-var,
      using the `interval_2var_nf_types_imply_1var` to get 1-var interval
      data from the matched config's 2-var data). At depth 0, only atoms
      matter. Atom agreement at arity n+1 follows from pairwise 1-var NF
      agreement + ordering agreement (using `atom_agree_from_pointwise`).
    - **Step j = j'+1**: Zone-match w to w' using zone_match_preserves_matching
      (Phase 1, Task 1.5). This gives a matched (n+1)-config at depth K.
      Apply `nf_fraisse_compression` at arity n+1:
      - `h_atoms`: atom agreement at n+1 vars from pairwise 1-var NF
        agreement + ordering agreement (from matched config).
      - `h_transfer` at depth j' < j'+1: Apply the IH (strongRecOn gives
        IH at depth j' for ALL arities, including n+1). The matched
        (n+1)-config at depth K satisfies the IH preconditions because
        K >= j'+1 > j' and the matching is at depth K.
      The Fraisse compression gives depth-(j'+1) (n+1)-var NF equality
      between (w :: env_M) and (w' :: env_M'). This implies chi
      satisfaction transfer.
  - **Key insight**: The IH at depth j' applies to arity n+1 (the extended
    config). The arity GROWS at each step (n -> n+1 -> n+2 -> ...) but the
    depth DECREASES (j'+1 -> j' -> ... -> 0). Well-foundedness follows from
    depth decrease. This is exactly GHR93's "induction on n" where n counts
    game rounds.
  - **File**: `StaviCompleteness.lean`
  - **Location**: After the Phase 1 definitions, before `nf_2var_existential_transfer`
  - **Estimated size**: 80-120 lines
  - **Literature ref**: GHR93 Prop 7 proof, induction step

- [ ] **Task 2.2**: Prove that the existing `nf_2var_existential_transfer`
  hypotheses (1-var NFs, orderings, `interval_nf_types`, above_max,
  below_min) suffice to construct an `IsMatchedConfig` at n=2.
  ```
  theorem bridge_to_matched_config :
      -- Existing hypotheses of nf_2var_existential_transfer --
      h_nf_x : ... -> h_nf_t : ... -> h_order_xt : ... ->
      h_interval_above : ... -> h_interval_below : ... ->
      h_above_max : ... -> h_below_min : ... ->
      -- Conclusion: matched config at arity 2
      IsMatchedConfig sig 2 K M (Fin.cons x (fun _ => t))
                                M' (Fin.cons x' (fun _ => t'))
  ```
  - **Approach**: The IsMatchedConfig conditions are:
    - (a) 1-var NF agreement: directly from h_nf_x and h_nf_t
    - (b) Ordering agreement: from h_order_xt
    - (c) 2-var interval types: This is the KEY STEP. The existing
      hypotheses provide `interval_nf_types` (1-var) agreement, NOT
      `interval_2var_nf_types` (2-var) agreement. We need to DERIVE
      2-var interval type agreement from 1-var interval type agreement
      plus the NF data.

      **Resolution**: The 2-var interval type of (u, hi) is determined by
      the 1-var NF of u (which is in the 1-var interval types) PLUS
      the 2-var NF of (u, hi). The 2-var NF of (u, hi) is in turn
      determined by the 1-var NFs + orderings + sub-interval types
      (by `nf_2var_from_interval_data`). But wait -- this is circular:
      we need `nf_2var_from_interval_data` to derive interval_2var_nf_types,
      but `nf_2var_from_interval_data` calls `nf_2var_existential_transfer`
      which is what we are trying to prove.

      **Break the circularity**: Use depth induction. At depth 0, the 2-var
      NF is purely atomic (predicates + orderings), determined by the 1-var
      NFs + orderings. So `interval_2var_nf_types` at depth 0 can be derived
      from `interval_nf_types` at any depth. At depth K, we use
      `interval_nf_types` at depth K which implies `interval_nf_types` at
      ALL depths <= K (by `interval_nf_types_depth_decrease`), and at
      depth 0 the 2-var types follow. Then inductively, if we have 2-var
      interval types at depth d, we can build them at depth d+1 using
      the already-proved transfer at depth d.

      **Alternatively**: Fold this into the main induction. Instead of
      a separate bridge lemma, prove `matched_config_transfer` with a
      WEAKER precondition that uses 1-var interval types + above/below,
      and derive the 2-var matching internally by induction on depth.
      This is cleaner and avoids the separate bridge step.

  - **Decision**: Use the "internal derivation" approach. Modify
    `matched_config_transfer` (Task 2.1) to accept EITHER an
    `IsMatchedConfig` (which has 2-var interval types) OR a weaker
    precondition with 1-var interval types + above/below data. The weaker
    precondition builds the 2-var matching as part of the depth induction.

    Concretely, define a weaker predicate `IsWeakMatchedConfig` that uses
    `interval_nf_types` (1-var) instead of `interval_2var_nf_types` (2-var),
    plus above_max and below_min data. Prove that `IsWeakMatchedConfig` at
    depth K implies `IsMatchedConfig` at depth K by a sub-induction on
    depth that uses `nf_fraisse_compression` to derive 2-var NFs from 1-var
    NFs + transfer.

  - **File**: `StaviCompleteness.lean`
  - **Estimated size**: 40-80 lines
  - **Literature ref**: GHR93 Prop 7 + Prop 5/6 (the hypotheses at the
    "first round" use 1-var type data from temporal formulas; subsequent
    rounds use the richer game strategies internally)

- [ ] **Task 2.3**: Fill the sorry at line 2353 (forward direction of
  `nf_2var_existential_transfer`). Construct the IsMatchedConfig or
  IsWeakMatchedConfig at n=2 from the existing hypotheses (Task 2.2), then
  apply `matched_config_transfer` at n=2, j=j':
  ```
  -- At the sorry site (line 2353):
  -- We need: (exists w, nf_eval M' j' 4 (w::u'::x'::t') sub_nf) <->
  --          (exists w, nf_eval M j' 4 (w::u::x::t) sub_nf)
  -- This is matched_config_transfer at n=3, j=j' for config (u,x,t)/(u',x',t')
  -- with matching data derived from zone matching + existing hypotheses.
  ```
  - **Approach**: After zone matching produces u' with 1-var NF agreement
    and ordering agreement, we have a 3-point configuration (u,x,t)/(u',x',t')
    with:
    - Pairwise 1-var NF agreement (h_nf_u, h_nf_x, h_nf_t)
    - Pairwise ordering agreement (h_ux, h_xu, h_ut, h_tu, h_order_xt)
    - 1-var interval type data for (x,t)/(x',t') from the outer hypotheses
    - Need to derive interval data for sub-intervals (u,x), (x,t), (u,t)

    Apply `matched_config_transfer` at arity n=3, depth j=j'. The IH from
    the outer `Nat.strongRecOn` at depth j' < j'+1 gives the transfer at
    depth j' for matched configs at any arity >= 2. Since j' < k (from
    j'+1 < k), and the matched config has data at depth K >= k > j', the
    preconditions hold.
  - **File**: `StaviCompleteness.lean` (modify at line ~2405)
  - **Estimated size**: 30-50 lines

- [ ] **Task 2.4**: Fill the sorry at line 2435 (backward direction of
  `nf_2var_existential_transfer`). Symmetric to Task 2.3, with M and M'
  swapped.
  - **File**: `StaviCompleteness.lean` (modify at line ~2487)
  - **Estimated size**: 30-50 lines

**Timing**: 3-4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_verify matched_config_transfer` -- no sorryAx
- `lean_verify nf_2var_existential_transfer` -- no sorryAx
- `lean_goal` at former sorry sites (lines 2353, 2435) shows no remaining goals

---

### Phase 3: Prove `nf_exist_sf_guarded_backward` and Verify Stavi Chain [NOT STARTED]

**Goal**: With `nf_2var_existential_transfer` now sorry-free,
`nf_2var_from_interval_data` becomes sorry-free (it calls
`nf_fraisse_compression` with `nf_2var_existential_transfer`). Prove
`nf_exist_sf_guarded_backward` (line 2857) which calls
`nf_2var_from_interval_data`, and verify the full Stavi completeness chain.

**Literature basis**: GHR93 Section 8 -- temporal formulas encode interval
structure. The guarded formula construction already encodes 1-var interval
types. The backward direction extracts witness x from the temporal formula
and applies the bridge lemma.

**Tasks**:
- [ ] **Task 3.1**: Analyze `nf_exist_sf_guarded_backward` (line 2830) to
  determine what data the backward proof can extract from the temporal formula.
  The proof needs to:
  1. Extract witness x from the temporal formula (Until/Since/equality)
  2. Determine x's 1-var depth-k NF (from `char_k_correct`)
  3. Extract interval type data from the interval guard
  4. Apply `nf_2var_from_interval_data` to conclude 2-var NF equality
  - The key question is whether the interval guard (`interval_guard_sf`)
    provides sufficient interval type data. Read the guard construction
    (lines ~2550-2800) to verify.
  - **File**: `StaviCompleteness.lean` (read lines ~2613-2829)
  - **Estimated size**: Analysis only

- [ ] **Task 3.2**: Prove `nf_exist_sf_guarded_backward` (line 2857).
  The proof structure:
  1. Extract witness x from the temporal formula structure
  2. From `char_k_correct`, x satisfies some depth-k NF type
  3. From the interval guard truth, all points between x and t have their
     1-var NFs in the guard's constraint set
  4. Construct `interval_nf_types` agreement from the guard data
  5. Construct above_max and below_min data (from the temporal formula
     structure -- S/U quantify over points beyond x)
  6. Apply `nf_2var_from_interval_data` with this data
  - **Contingency**: If `interval_guard_sf` provides only 1-var types and
    the backward proof needs 2-var interval types, then either:
    (a) The bridge lemma `nf_2var_from_interval_data` uses 1-var types
        (which it currently does -- it takes `interval_nf_types` hypotheses,
        not `interval_2var_nf_types`), so the guard suffices. OR
    (b) We need to change the guard. But option (a) is the current design.
  - **File**: `StaviCompleteness.lean` (replace sorry at line 2857)
  - **Estimated size**: 80-150 lines

- [ ] **Task 3.3**: Verify the Stavi completeness chain is sorry-free:
  - `lean_verify nf_2var_existential_transfer` -- no sorryAx
  - `lean_verify nf_2var_from_interval_data` -- no sorryAx
  - `lean_verify nf_exist_sf_guarded_backward` -- no sorryAx
  - `lean_verify nf_2var_exist_sf_classical` -- no sorryAx
  - `lean_verify nf_characterizable_by_stavi` -- no sorryAx
  - `lean_verify stavi_expressive_completeness` -- no sorryAx

**Timing**: 2-3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- `lean_verify stavi_expressive_completeness` -- no sorryAx (primary success criterion)
- Zero sorry sites in `nf_exist_sf_guarded_backward`

---

### Phase 4: Full Chain Verification [NOT STARTED]

**Goal**: Verify the entire sorry chain from `completeness_discrete` is resolved.

**Tasks**:
- [ ] **Task 4.1**: Verify `US_expressively_complete_over_prior`:
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx

- [ ] **Task 4.2**: Verify model surgery chain:
  - `lean_verify gap_prior_UZ_contradiction` -- no sorryAx
  - `lean_verify no_gaps_discrete_model_surgery` -- no sorryAx

- [ ] **Task 4.3**: Verify `completeness_discrete`:
  - `lean_verify completeness_discrete` -- no sorryAx (or sorryAx only through
    non-273 chains like chronicle construction)

- [ ] **Task 4.4**: Full build verification:
  - `lake build` passes without errors
  - No new sorry introduced anywhere
  - No import cycles introduced

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**: None (verification only)

**Verification**:
- `lean_verify completeness_discrete` -- no sorryAx from this chain
- `lake build` passes

---

## Testing & Validation

- [ ] `lean_verify IsMatchedConfig` -- no sorry (if defined as a def/structure)
- [ ] `lean_verify zone_match_witness_2var` -- no sorryAx
- [ ] `lean_verify interval_2var_nf_types_from_2var_nf` -- no sorryAx
- [ ] `lean_verify zone_match_preserves_matching` -- no sorryAx
- [ ] `lean_verify matched_config_transfer` -- no sorryAx
- [ ] `lean_verify nf_2var_existential_transfer` -- no sorryAx
- [ ] `lean_verify nf_2var_from_interval_data` -- no sorryAx
- [ ] `lean_verify nf_exist_sf_guarded_backward` -- no sorryAx
- [ ] `lean_verify stavi_expressive_completeness` -- no sorryAx
- [ ] `lean_verify US_expressively_complete_over_prior` -- no sorryAx
- [ ] `lean_verify completeness_discrete` -- no sorryAx from this chain
- [ ] `lake build` passes without errors
- [ ] No new sorry introduced anywhere

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/14_generalized-transfer-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (~260-400 new lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/14_generalized-transfer-summary.md`

## Rollback/Contingency

- **If `IsMatchedConfig` adjacency predicate is too complex**: Simplify by
  quantifying over ALL pairs (not just adjacent ones). This over-constrains
  the predicate (requiring interval data for non-adjacent pairs, which
  overlap intermediate config points) but makes the definition simpler. The
  trade-off is that constructing the predicate for the base case (n=2) may
  require more work, but the inductive step simplifies. Alternatively, use
  a formulation where the environment is required to be sorted, which makes
  adjacency a simple index comparison (i+1 = j).

- **If deriving `interval_2var_nf_types` from `interval_nf_types` is
  infeasible (Task 2.2)**: Change the approach: instead of bridging from
  the existing weak hypotheses, change `nf_2var_existential_transfer` to
  take `interval_2var_nf_types` hypotheses directly (Approach A from v13).
  Then propagate the change to `nf_2var_from_interval_data` and
  `nf_exist_sf_guarded_backward`. This requires strengthening the interval
  guard to encode 2-var types, adding ~100-150 lines.

- **If `Nat.strongRecOn` type-checking is slow at high arity**: Use
  `WellFoundedRelation.wf.recursion` or `Nat.rec` with an explicit
  decreasing witness instead. The key is that j decreases and n is free.

- **If the sub-interval 2-var type derivation (Task 1.4) fails**: The 2-var
  NF at depth K of (u, hi) should encode which 2-var NFs of (w, hi) are
  realized for w in (u, hi). If this encoding is at depth K-1 rather than
  depth K, then the interval types at the extended config would be at depth
  K-1 instead of K. This is acceptable: the matched config at depth K
  extends to depth K-1, which still satisfies K-1 >= j for j < K.

- **Git revert** to current commit if any phase introduces regressions.

## Lessons Learned from v11, v12, and v13

1. **IsSuccArchimedean circularity (v11)**: Cannot use discrete-only theorems
   to prove discreteness. The proof must work for all linear orders. This plan
   makes no discreteness assumptions anywhere.

2. **1-var interval types insufficient (v12)**: Zone matching with 1-var NFs
   (`interval_nf_types`) does not determine orderings between independently
   zone-matched points in the same interval. The literature uses decomposition
   formula matching (= 2-var NF matching) to resolve this.
   `interval_2var_nf_types` is already defined in the codebase (line 1847) but
   was not used. This plan uses it as the matching criterion in `IsMatchedConfig`.

3. **Fixed arity insufficient (v13)**: Proving 3-var transfer at depth j
   requires 4-var transfer at depth j-1, which requires 5-var at j-2, etc.
   This arity-growth recursion is well-founded because depth strictly decreases,
   bottoming out at depth 0 where atoms at any arity suffice. Plan v13 attempted
   to work at fixed arity 2 (with some infrastructure for 2-var matching), but
   the quant step at arity 2 needs arity 3, which needs arity 4, etc. The
   correct approach is a theorem universally quantified over arity n, proved by
   induction on depth j. This is exactly GHR93 Proposition 7's structure.

4. **Follow the literature**: GHR93/GHR94 already solved all three problems.
   The resolution is: (a) no discreteness assumptions, (b) 2-var NF matching
   for decomposition formula content, (c) arity as a free variable with
   induction on game rounds (depth). Three prior failures resulted from
   incomplete adoption of the literature's approach. This plan implements the
   full GHR93 Proposition 7 structure faithfully.
