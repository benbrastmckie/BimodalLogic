# Implementation Plan: GHR93 Decomposition-Formula Path for Discrete Orders (v8)

- **Task**: 273 - Fill the EF game sorry in StaviCompleteness.lean to make {U,S,U',S'} expressively complete
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (Phases 0-1 from v3 are completed)
- **Research Inputs**:
  - specs/273_chronicle_gap_contradiction_proof/reports/06_decomposition-path-research.md
  - specs/273_chronicle_gap_contradiction_proof/.literature-alignment.md
  - specs/273_chronicle_gap_contradiction_proof/.sorry-goal-audit.md
  - specs/273_chronicle_gap_contradiction_proof/reports/05_proposition7-research.md
  - literature/Gabbay_Hodkinson_Reynolds_1993_Temporal_expressive_completeness_gaps.md
- **Artifacts**: plans/08_ghr93-decomposition-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v8 replaces v7, which diverged from GHR93 in three significant ways (documented in `.literature-alignment.md`): (1) v7 inducts on depth j instead of game round n; (2) v7 invents a 0-to-1 game promotion not in GHR93, with the `h_d_consistent` construction as a likely blocker; (3) v7 interleaves NF-to-game conversions at each depth instead of doing the game argument once at full strength.

Plan v8 follows GHR93 exactly: Theorem 6 (pp.116-119) + Proposition 7 (p.115) via decomposition formulas, restricted to discrete orders where Cases III/IV of Theorem 6 are vacuous. The plan creates three new components -- `discrete_ghr93_theorem6`, `discrete_ghr93_proposition7`, and a game-win-to-existential-transfer bridge -- then wires them into the existing sorry chain through a discrete completeness pathway.

### Research Integration

Integrated reports:
- `reports/06_decomposition-path-research.md` (NEW in v8) -- Complete GHR93 pipeline, codebase inventory, new lemma specifications, risk analysis (Sections 4-7)
- `.literature-alignment.md` (NEW in v8) -- Documents v7's three divergences from GHR93, motivates v8
- `.sorry-goal-audit.md` (NEW in v8) -- Exact sorry goal states at lines 2353/2435/2805, caller chain to `completeness_discrete`, discrete instance availability
- `reports/05_proposition7-research.md` -- GHR93 Proposition 7 analysis, existing infrastructure inventory
- `.bridge-research.md` -- Game pipeline inventory, gap analysis
- `.blocker-research.md` -- Three resolution paths, root cause of v3-v6 failures

### Prior Plan Reference

**v3 (separation bypass)**: Blocked because the separation result (GHR94 Ch 10.2) is proved for Z-carrier structures only. `eval` quantifies over `M.carrier`, and arbitrary Prior carriers may differ from Z.

**v4 (EF game completion)**: Phase 2 blocked on the interval-splitting problem. `zone_match_witness` finds u' with the same depth-k 1-var NF and correct orderings relative to x' and t', but does NOT guarantee sub-interval type matching for (x,u)/(x',u') and (u,t)/(u',t').

**v5 (strengthened zone match)**: Phase 2 blocked because `interval_nf_types` is a `Finset`, not an ordered sequence. Two linear orders can have the same set of 1-var NF types but different arrangements.

**v6 (discrete game bypass)**: Phase 2 blocked because the game at n=0 only matches ONE variable. The nested multi-variable transfer requires sub-interval games on sub-intervals created by inner variable matching. Six specific sub-approaches failed.

**v7 (iterated game transfer)**: Three divergences from GHR93 identified by literature alignment audit: (a) inducts on depth j instead of game round n, (b) invents 0-to-1 game promotion not in GHR93 with `h_d_consistent` as likely blocker, (c) interleaves NF-game conversions at each depth instead of doing the game argument once. See `.literature-alignment.md` for full analysis.

**Root cause (v3-v7)**: All NF-based approaches fail because they process variables one at a time via zone matching, losing sub-interval structure at each step. The game approach resolves this by absorbing all variable counts into game rounds (GHR93 Proposition 7), with Theorem 6 providing game inversion.

### Existing Infrastructure (Sorry-Free)

**Decomposition.lean** (315 lines, sorry-free):

| Theorem | Line | GHR93 Reference | Purpose |
|---------|------|-----------------|---------|
| `decomposition_agreement` | 62 | Def 8.8, p.112 | Semantic (n;r)-decomposition formula agreement |
| `ghr93_game_implies_decomposition` | 117 | Lemma 11 forward, p.112 | Game win -> decomposition agreement |
| `ghr93_decomposition_implies_game` | 272 | Lemma 11 backward, p.112 | Decomposition agreement -> game win |

**Composition.lean** (626 lines, sorry-free):

| Theorem | Line | GHR93 Reference | Purpose |
|---------|------|-----------------|---------|
| `ghr93_strategy_compose` | 40 | Prop 7 one-step, p.115 | Compose left+right sub-interval games at SAME (n,r) |

**CustomGame.lean** (key definitions):

| Definition | Line | Purpose |
|------------|------|---------|
| `ghr93_duplicator_wins` | 285 | Duplicator winning strategy for G_{n;r} |
| `ghr93_winning_condition` | 262 | Order type + gap/point + formula agreement |
| `ghr93_duplicator_wins_round_mono` | 441 | n' <= n -> game at n implies game at n' |

**NFGameBridge.lean** (1237 lines, sorry-free):

| Theorem | Line | Purpose |
|---------|------|---------|
| `discrete_nf_to_decomposition_agreement` | 997 | **Bridge A**: NF hypotheses -> decomp agreement at n=0, r=k/2 |
| `game_win_to_formula_agree` | 1222 | Extract formula agreement from winning condition |
| `discrete_formula_agree_from_nf` | 749 | depth-k NF agree -> StaviFormula agree at k/2 |
| `zone_match_witness` (in StaviCompleteness) | 2044 | Find u' matching u with same 1-var NF and orderings |
| `atom_agree_from_pointwise_nf` | 140 | n-var atom agree from pointwise 1-var NF + orderings |
| `nvar_nf_eq_depth_zero` | 127 | Depth-0 n-var NF from atom agreement |

**Defs.lean**:

| Definition | Line | Purpose |
|------------|------|---------|
| `game_depth` | 88 | f(n+1) = (1+3f(n))*(2k_n)+2 -- matches GHR93 Def 8.9 f |
| `game_depth_strict_mono` | 117 | f is strictly monotone |
| `game_depth_mono` | 139 | f is monotone |
| `discrete_no_gaps` | 532 | In succ-archimedean orders, `IsEmpty (Gap T)` |

## Goals & Non-Goals

**Goals**:
- Prove `discrete_ghr93_theorem6` -- GHR93 Theorem 6 for discrete orders (Cases I-II only)
- Prove `discrete_ghr93_proposition7` -- GHR93 Proposition 7 for discrete orders
- Bridge the game wins to existential transfer and wire into the sorry chain
- Make `US_expressively_complete_over_prior` sorry-free (Prior structures are discrete)
- Verify via `#print axioms completeness_discrete` that sorryAx is removed from Chain A

**Non-Goals**:
- Filling `nf_2var_existential_transfer` for arbitrary linear orders (general sorry remains)
- Proving `completeness_dense` sorry-free
- Implementing Cases III/IV of Theorem 6 (vacuous for discrete orders)
- Full GHR93 for general linear orders with gaps
- Modifying the existing `stavi_expressive_completeness` (general version retains sorry)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Theorem 6 Claims 1-2 complexity | H | M | For discrete orders, Claims 1-2 simplify: no gap constructions (d-tilde is always a point or x), and Claim 2 follows directly from restricting the forward strategy to sub-intervals. GHR93 p.116 argument applies with 200-300 lines instead of 400+. |
| Rank/depth parameter alignment | H | M | Bridge A produces decomposition_agreement at n=0, r=k/2. Proposition 7 uses growing g(n). For discrete orders, the codebase `game_depth` (Defs.lean:88) implements exactly GHR93's f function. Define `game_rank sig n = game_depth sig 0 + 4 * game_depth sig n` to match g. Verify line-up explicitly in Phase 2 Task 2.1. |
| Proposition 5 not formalized | M | M | The codebase has `ef_duplicator_wins` (Defs.lean:48-71) but no proof that EF game wins imply FO equivalence. **Bypass**: use `nf_fraisse_compression` (StaviCompleteness.lean:2006, sorry-free) directly with game-extracted existential transfers at each depth, bypassing Proposition 5 entirely. The game at n rounds gives existential transfers at each depth via zone matching within the game. |
| Case II characteristic formula B | M | L | For discrete orders, Case II handles alpha_n as a point (not a gap). B = X_{alpha_n} is the rank-type of alpha_n. The supremum b = sup{t : M models B(t)} is well-defined and is a point (no gaps). This is simpler than the general case. |
| Double induction depth (Theorem 6 induction inside Proposition 7 induction) | M | M | Lean's `termination_by` annotations handle nested inductions. Structure Proposition 7 with explicit `Nat.strongRecOn n` and call Theorem 6 as a sub-lemma (not nested induction). |
| Build time for modified files | L | M | Place Theorem 6 and Proposition 7 in a new file `DiscreteGameTransfer.lean` that imports from Decomposition.lean and CustomGame.lean. Keep StaviCompleteness.lean modifications minimal. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 4 |

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

### Phase 2: GHR93 Theorem 6 for Discrete Orders [BLOCKED]

**Goal**: Prove GHR93 Theorem 6 restricted to discrete orders: if Duplicator wins G_{1+3n; r+4n}(M, xy; N, x'y') then Duplicator wins G_{n;r}(N, x'y'; M, xy). Only Cases I and II apply (Cases III/IV are vacuous because `discrete_no_gaps` gives `IsEmpty (Gap T)`).

**GHR93 Reference**: Theorem 6, pp.114-119 (lines 1244-1612 in OCR). Statement at p.114 line 1244. Proof structure:
- Base case n=0 (p.117, line 1361): Trivial -- Duplicator uses forward strategy directly for Round 2.
- Inductive step n -> n+1 (p.117, line 1366): Fix r, assume forward strategy for G_{4+3n; r+4(n+1)}.
  - **Claim 1** (p.116, line 1392): Define c = inf{t in [x,y] : M models C(u) for all u in (t,y)}, where C = X_{alpha_n} /\ not-U(not-X_{alpha_n-1,alpha_n}, truth) and A = X_{alpha_{n-1},alpha_n}. The canonical pivot c has the property that in any play of G_{m;r'}(M,xy;N,x'y') where Duplicator uses a winning strategy and Spoiler includes c, Duplicator's response is always d-tilde (unique). For discrete orders: c is always a point (no gaps), and the infimum is realized.
  - **Claim 2** (p.116, line 1404): Duplicator has winning strategies for G_{1+3n; r+4(n+1)}(M, x c; N, x' d-tilde) and G_{1+3n; r+4(n+1)}(M, c y; N, d-tilde y'). Proof: restrict the forward strategy to sub-intervals, adding c to Spoiler's choices and using Claim 1 to ensure d-tilde is the response.
  - **Case I** (p.117, line 1435): alpha_0 < d-tilde. Both (x',d-tilde) and (d-tilde,y') contain at most n points from {alpha_0,...,alpha_n}. Use backward sub-interval strategies sigma, tau from Claim 2 + (*)_n to choose points in M.
  - **Case II** (p.117, line 1443): All alpha_0,...,alpha_n lie in (d-tilde, y'), and alpha_n is a point (not a gap -- this is the ONLY case for discrete orders besides Case I). Define B = X_{alpha_n}, b = sup{t in (x,y) : M models B(t)}. For discrete orders, b is always a point. Use the backward strategy tau for G_{n;r+4}(N, d-tilde b'; M, c b) and sigma for G_{n;r+4}(N, x' d-tilde; M, x c). The U(B,A) transfer at rank r+1 gives e_n matching alpha_n's rank-r type.

**Tasks**:

- [ ] **Task 2.1**: Define the rank function g and verify alignment with `game_depth`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (NEW)
  - **Content**: Define `game_rank sig n := 4 * game_depth sig n` to match GHR93's g(n). Prove `game_rank_mono` and that `game_rank sig (n+1) > game_rank sig n + 4 * game_depth sig n`.
  - **GHR93 Reference**: Definition 8.9, p.114, line 1290: g(0) = 0, g(n+1) > g(n) + 4f(n).
  - **Verification**: The codebase `game_depth` (Defs.lean:88) implements f(n+1) = (1+3f(n))*(2k_n)+2 which matches GHR93's f(n+1) > (1+3f(n))*(2k_n)+1. The `game_rank` definition is a convenience for g.
  - **Estimated size**: 20-40 lines

- [ ] **Task 2.2**: Prove the base case `discrete_ghr93_theorem6_zero`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Exact type signature**:
    ```lean
    theorem discrete_ghr93_theorem6_zero {sig : MonadicSignature}
        {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        {r : Nat}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        {x y : ExtendedCarrier M atomMap r}
        {x' y' : ExtendedCarrier N atomMap r}
        (h : ghr93_duplicator_wins M N atomMap 1 r x y x' y') :
        ghr93_duplicator_wins N M atomMap 0 r x' y' x y
    ```
  - **Proof strategy**: GHR93 p.117 line 1361. n=0, so G_{0;r} has empty Round 1. For Round 2: Spoiler picks alpha in (x,y) which is a point (discrete, no gaps). Apply the forward strategy sigma for G_{1;r}(M,xy;N,x'y') with empty selection, Spoiler challenges with alpha. Duplicator responds with e. The winning condition at e gives formula agreement at rank r. This response e works as Duplicator's answer in the backward game.
  - **GHR93 Reference**: p.117 lines 1361-1365.
  - **Induction**: None (base case).
  - **Estimated size**: 30-50 lines

- [ ] **Task 2.3**: Prove Claims 1 and 2 for discrete orders
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Content**: Prove two helper lemmas:
    1. `discrete_claim1` -- In any play of G_{m;r'}(M,xy;N,x'y') where Duplicator uses a winning strategy and Spoiler includes c (the canonical pivot), Duplicator's response to c is always d-tilde. For discrete orders, c is a point in M (no gaps), so c is in M.carrier and the infimum is realized.
    2. `discrete_claim2` -- From a forward strategy for G_{4+3n; r+4(n+1)}(M, xy; N, x'y'), derive forward strategies for G_{1+3n; r+4(n+1)}(M, x c; N, x' d) and G_{1+3n; r+4(n+1)}(M, c y; N, d y'). This follows by restricting the forward strategy to sub-intervals: add c to Spoiler's choices, use Claim 1 to ensure d is the response, then restrict (Lemma 10).
  - **GHR93 Reference**: Claims 1-2, p.116, lines 1392-1421.
  - **Key insight for discrete**: Since c is always a point (not a gap), the infimum construction simplifies. The formula C = X_{alpha_n} /\ not-U(not-A, truth) where A = X_{(alpha_{n-1}, alpha_n)} defines a rank-(r+1) formula. c = inf{t in [x,y] : M models C(u) for all u in (t,y)} is an actual point in discrete M.
  - **Existing infrastructure**: `ghr93_duplicator_wins_round_mono` (CustomGame.lean:441) for step-down from (4+3n) to (1+3n).
  - **Estimated size**: 100-150 lines

- [ ] **Task 2.4**: Prove Case I and Case II for discrete orders
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Content**: Prove the two discrete cases of the inductive step:
    1. `discrete_theorem6_caseI` -- alpha_0 < d-tilde. Both sub-intervals contain at most n alpha-points. Use backward strategies from (*)_n (IH) applied to the sub-interval forward strategies from Claim 2. Compose via Lemma 10 / `ghr93_strategy_compose`.
    2. `discrete_theorem6_caseII` -- All alpha_0,...,alpha_n in (d-tilde, y'), alpha_n is a point. Define B = X_{alpha_n}, b = sup{t : M models B(t)}. For discrete orders b is a point. Use tau for G_{n;r+4}(N, d' b'; M, c b), sigma for G_{n;r+4}(N, x' d'; M, x c). Transfer U(B,A) at rank r+1 to find e_n matching alpha_n. Complete the game response.
  - **GHR93 Reference**: Case I pp.117 lines 1435-1442, Case II pp.117-118 lines 1443-1504.
  - **Induction**: These use the inductive hypothesis (*)_n which gives backward games at (n, r+4) from forward games at (1+3n, r+4(n+1)). The call to (*)_n is on the sub-interval forward strategies from Claim 2.
  - **Existing infrastructure**: `ghr93_strategy_compose` (Composition.lean:40), `ghr93_game_implies_decomposition` (Decomposition.lean:117), `ghr93_decomposition_implies_game` (Decomposition.lean:272).
  - **Estimated size**: 150-200 lines

- [ ] **Task 2.5**: Assemble `discrete_ghr93_theorem6`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Exact type signature**:
    ```lean
    theorem discrete_ghr93_theorem6 {sig : MonadicSignature}
        {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        (n r : Nat)
        (x y : ExtendedCarrier M atomMap (r + 4 * n))
        (x' y' : ExtendedCarrier N atomMap (r + 4 * n))
        (h : ghr93_duplicator_wins M N atomMap (1 + 3 * n) (r + 4 * n)
          x y x' y') :
        ghr93_duplicator_wins N M atomMap n r
          (rank_cast x) (rank_cast y) (rank_cast x') (rank_cast y')
    ```
  - **Proof strategy**: Induction on n using `Nat.rec`. Base case: Task 2.2 (`discrete_ghr93_theorem6_zero`). Inductive step: combine Tasks 2.3 (Claims 1-2) and 2.4 (Cases I-II) with a case split on whether alpha_0 < d-tilde.
  - **GHR93 Reference**: Full Theorem 6, pp.114-119.
  - **Induction**: On n (game round count). **What decreases**: n. **Base case**: n=0. **Inductive step**: n -> n+1, assuming (*)_n.
  - **Note on rank parameter**: The rank changes from (r + 4n) in the hypothesis to r in the conclusion. This is handled by `rank_cast` or `ghr93_duplicator_wins_rank_cast`. If the ExtendedCarrier types differ, use `discrete_no_gaps` to show both are isomorphic to M.carrier / N.carrier.
  - **Estimated size**: 30-50 lines (assembly of sub-lemmas)

- [ ] **Task 2.6**: Build verification for Phase 2
  - Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer`
  - Verify no sorry in new file: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - Verify `lean_verify discrete_ghr93_theorem6` shows no sorryAx

**Timing**: 3 hours

**Depends on**: Phases 0, 1 (completed)

**Files to create/modify**:
- Created: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (300-500 new lines)

**Verification**:
- `lake build Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer` succeeds
- No sorry in DiscreteGameTransfer.lean
- `discrete_ghr93_theorem6` type signature verified

---

**BLOCKER** (Phase 2):
- **What failed**: The inductive step of `discrete_ghr93_theorem6` (DiscreteGameTransfer.lean:630). The backward game G_{n+1; r}(N, x'y'; M, xy) cannot be directly constructed from the forward game G_{4+3n; r+4+4n}(M, xy; N, x'y') without the sub-interval Claims 1-2.
- **What was tried**: (1) Direct forward game usage -- fails because Round 1 selections are from M not N. (2) Round monotonicity to reduce round count -- doesn't help with direction reversal. (3) Trivial selections -- Round 2 only handles one point at a time. (4) Diagonal approach -- cannot combine n+1 Round 2 responses. (5) Strong induction on k for discrete bridge lemma -- circular: needs interval types for sub-intervals, which need the bridge for sub-intervals. (6) Direct induction on j for multi-var transfer -- fails when zone-matched points are in the same zone (ordering not determined).
- **Why it's stuck**: The game inversion (forward-to-backward) fundamentally requires the GHR93 Claims 1-2 sub-interval argument with a canonical pivot construction. For discrete orders, the pivot c is always a point (not a gap), but the proof still requires showing Duplicator's response to c is unique (Claim 1) and that restricting the forward strategy to sub-intervals yields sub-interval forward strategies (Claim 2). This is ~150-200 lines of non-trivial Lean proof involving game position manipulation.
- **What is needed**: Formal implementation of GHR93 Claims 1-2 for discrete orders. Specifically: (a) Define the canonical pivot c as the infimum of {t in [x,y] : M models C(u) for all u in (t,y)}. For discrete orders, c is always a carrier point. (b) Prove Claim 1: in any play where Spoiler includes c, Duplicator's response is determined. (c) Prove Claim 2: restrict the forward strategy to sub-intervals [x,c] and [c,y].
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder

### Phase 3: GHR93 Proposition 7 for Discrete Orders [NOT STARTED]

**Goal**: Prove GHR93 Proposition 7 for discrete orders: from sub-interval game wins at strength (f(n), g(n)), derive a standard EF game win at n rounds. This is the main composition theorem that converts sub-interval games into a full back-and-forth EF game.

**GHR93 Reference**: Proposition 7, p.115, lines 1293-1340.

**Statement** (GHR93 p.115): For all n < omega: Let M, N be linear temporal structures with increasing m-tuples x_1 < ... < x_m in M, y_1 < ... < y_m in N. Define x_0 = -inf, x_{m+1} = +inf, y_0, y_{m+1} similarly. Suppose Duplicator has winning strategies for G_{f(n);g(n)}(M, x_i x_{i+1}; N, y_i y_{i+1}) and G_{f(n);g(n)}(N, y_i y_{i+1}; M, x_i x_{i+1}) for all 0 <= i <= m. Then Duplicator wins the standard EF game G_n((M,x),(N,y)).

**Proof structure** (by induction on n, GHR93 pp.115-116):
- **n=0**: Trivial.
- **n -> n+1**: Let r = g(n) + 4f(n) < g(n+1). Spoiler picks alpha in M. Let i be such that x_i < alpha < x_{i+1}.
  1. List all (1+3f(n));r-decomposition formulas phi satisfied by (x_i, alpha) and psi satisfied by (alpha, x_{i+1}). At most n' = (1+3f(n))*(j+k)+1 <= f(n+1) witnesses needed.
  2. Apply the winning strategy for G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}). Let e be the response to alpha.
  3. By Lemma 11 (forward): N models phi_s(y_i, e) for all s and N models psi_s(e, y_{i+1}) for all s.
  4. By Lemma 11 (backward): Duplicator wins G_{1+3f(n);r}(M, x_i alpha; N, y_i e) and G_{1+3f(n);r}(M, alpha x_{i+1}; N, e y_{i+1}).
  5. **By Theorem 6**: Duplicator wins G_{f(n);g(n)}(N, y_i e; M, x_i alpha) and G_{f(n);g(n)}(N, e y_{i+1}; M, alpha x_{i+1}).
  6. By induction hypothesis: Duplicator wins G_n((M, x concat alpha), (N, y concat e)).

**Tasks**:

- [ ] **Task 3.1**: Prove the Proposition 7 induction step for discrete orders
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Exact type signature**:
    ```lean
    theorem discrete_ghr93_proposition7 {sig : MonadicSignature}
        {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
        [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
        [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
        [SuccOrder N.carrier] [PredOrder N.carrier] [NoMaxOrder N.carrier]
        [NoMinOrder N.carrier] [IsSuccArchimedean N.carrier]
        (n : Nat) (m : Nat)
        (xs : Fin (m + 2) -> ExtendedCarrier M atomMap (game_rank sig n))
        (ys : Fin (m + 2) -> ExtendedCarrier N atomMap (game_rank sig n))
        (h_mono_x : StrictMono xs) (h_mono_y : StrictMono ys)
        (h_fwd : forall (i : Fin (m + 1)),
          ghr93_duplicator_wins M N atomMap
            (game_depth sig n) (game_rank sig n)
            (xs i.castSucc) (xs i.succ)
            (ys i.castSucc) (ys i.succ))
        (h_bwd : forall (i : Fin (m + 1)),
          ghr93_duplicator_wins N M atomMap
            (game_depth sig n) (game_rank sig n)
            (ys i.castSucc) (ys i.succ)
            (xs i.castSucc) (xs i.succ)) :
        standard_ef_duplicator_wins M N atomMap n xs ys
    ```
  - **Proof strategy**: Induction on n.
    - **Base case n=0**: Trivial (no moves to make).
    - **Inductive step n -> n+1**: When Spoiler picks alpha in interval (x_i, x_{i+1}):
      1. Enumerate decomposition formulas at (1+3f(n));r (finite by `Fintype` instance on `NormalForm`).
      2. Apply the f(n+1)-game to select witnesses plus alpha. Use the winning strategy for G_{f(n+1);r}(M, x_i x_{i+1}; N, y_i y_{i+1}). Let e be the response to alpha.
      3. Apply `ghr93_game_implies_decomposition` (Decomposition.lean:117) to get decomposition agreement on sub-intervals.
      4. Apply `ghr93_decomposition_implies_game` (Decomposition.lean:272) to convert back to game wins on sub-intervals at (1+3f(n), r).
      5. Apply `discrete_ghr93_theorem6` (Phase 2) to invert to backward sub-interval games at (f(n), g(n)).
      6. Apply IH for G_n on the extended tuple.
  - **GHR93 Reference**: Proposition 7, p.115, lines 1293-1340.
  - **Induction**: On n. **What decreases**: n. **Base case**: n=0. **Inductive step**: n -> n+1.
  - **Existing infrastructure used**: `ghr93_game_implies_decomposition` (Decomposition.lean:117), `ghr93_decomposition_implies_game` (Decomposition.lean:272), `ghr93_strategy_compose` (Composition.lean:40), `discrete_ghr93_theorem6` (Phase 2).
  - **Estimated size**: 200-350 lines

- [ ] **Task 3.2**: Define `standard_ef_duplicator_wins` if not already present
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - **Content**: If needed, define the standard (non-parametric) EF game notion:
    ```lean
    def standard_ef_duplicator_wins {sig : MonadicSignature}
        (M N : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
        (n : Nat) (xs : Fin m -> M.carrier) (ys : Fin m -> N.carrier) : Prop := ...
    ```
    This should state that for n rounds of back-and-forth, Duplicator can maintain rank-r agreement for all formulas. Alternatively, express this in terms of `ghr93_duplicator_wins` on the full interval [-inf, +inf] with the matched tuple as inner selections.
  - **Note**: The codebase may already have this via `ef_duplicator_wins` (Defs.lean). Check and reuse if possible.
  - **Estimated size**: 10-30 lines (definition only, or 0 lines if reusing existing)

- [ ] **Task 3.3**: Build verification for Phase 3
  - Run `lake build Bimodal.Metalogic.WeakCanonical.EFGames.DiscreteGameTransfer`
  - Verify no sorry: `grep -n "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean`
  - Verify `lean_verify discrete_ghr93_proposition7` shows no sorryAx

**Timing**: 2.5 hours

**Depends on**: Phase 2

**Files to create/modify**:
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (200-400 new lines)

**Verification**:
- `lake build` succeeds for DiscreteGameTransfer
- No sorry in Proposition 7 proof
- Type signature matches GHR93 statement exactly

---

### Phase 4: Game Win to Existential Transfer Bridge and Sorry Wiring [NOT STARTED]

**Goal**: Convert the EF game wins from Proposition 7 into existential NF transfers that fill the sorry sites at StaviCompleteness.lean:2353, 2435, 2805. Create the discrete completeness chain: `discrete_nf_2var_existential_transfer` -> `discrete_nf_2var_from_interval_data` -> `discrete_nf_exist_sf_guarded_backward` -> `discrete_nf_2var_exist_sf_classical` -> `discrete_nf_2var_existence_characterizable` -> `discrete_nf_characterizable_by_stavi` -> `discrete_stavi_expressive_completeness`.

**The non-circular pipeline** (from decomp-path research Section 4.2, verified against GHR93):

```
Bridge A hypotheses (1-var NF agreement + interval types at depth k)
  -> decomposition_agreement at n=0, r=k/2 (via discrete_nf_to_decomposition_agreement)
  -> ghr93_duplicator_wins at n=0, r=k/2 (via ghr93_decomposition_implies_game)
  -> [Proposition 7 + Theorem 6: induction on n]
  -> Standard EF game win at sufficient rounds
  -> FO equivalence at depth k for 2-var environments
    (via nf_fraisse_compression with game-extracted existential transfers)
  -> Existential transfer for 3 vars at depth j < k
```

The key insight: the game at sufficient rounds gives existential transfers at EACH depth level (because at each round, Duplicator can zone-match a new point and the winning condition gives formula agreement, hence NF agreement). This feeds directly into `nf_fraisse_compression` which needs exactly those depth-by-depth existential transfers. This is NOT circular because the game argument works at the game level (rounds), not the NF level (depths).

**Tasks**:

- [ ] **Task 4.1**: Prove `discrete_nf_2var_existential_transfer`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after `nf_2var_existential_transfer`, around line 2440)
  - **Exact type signature**: Same as `nf_2var_existential_transfer` (line 2214) plus 10 discrete instances.
  - **Proof strategy**:
    1. From Bridge A hypotheses, derive `decomposition_agreement` at n=0, r=k/2 (via `discrete_nf_to_decomposition_agreement`, NFGameBridge.lean:997).
    2. Convert to game wins at n=0 (via `ghr93_decomposition_implies_game`, Decomposition.lean:272). Get both forward and backward games.
    3. Build sub-interval games for all m+1 intervals of the 2-point tuple (x,t) using the n=0 game.
    4. Apply `discrete_ghr93_proposition7` (Phase 3) to get standard EF game wins at n rounds for sufficient n.
    5. From the n-round EF game: for each depth j < k, Duplicator can match a new point u -> u' with formula agreement at rank g(n). By `discrete_formula_agree_from_nf`, this gives 1-var NF agreement at sufficient depth. Combined with the ordering data from the game, this provides the existential transfer at depth j.
    6. Feed these depth-by-depth existential transfers into `nf_fraisse_compression` (StaviCompleteness.lean:2006, sorry-free) to get 2-var NF equality at depth k.
    7. From 2-var NF equality at depth k, derive the existential transfers at depth j < k for 3 vars (this is a direct consequence: existential over the 3rd variable at depth j < k is determined by the 2-var NF at depth k).
  - **GHR93 Reference**: Corollary 5, p.115, lines 1341-1346 + Propositions 5-7.
  - **Existing lemmas called**: `discrete_nf_to_decomposition_agreement` (NFGameBridge.lean:997), `ghr93_decomposition_implies_game` (Decomposition.lean:272), `discrete_ghr93_proposition7` (Phase 3), `discrete_ghr93_theorem6` (Phase 2), `nf_fraisse_compression` (StaviCompleteness.lean:2006), `zone_match_witness` (StaviCompleteness.lean:2044), `game_win_to_formula_agree` (NFGameBridge.lean:1222), `discrete_formula_agree_from_nf` (NFGameBridge.lean:749).
  - **Estimated size**: 50-100 lines

- [ ] **Task 4.2**: Prove `discrete_nf_2var_from_interval_data`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after Task 4.1)
  - **Type signature**: Same as `nf_2var_from_interval_data` (line 2448) plus discrete instances.
  - **Proof**: Identical to `nf_2var_from_interval_data` but calls `discrete_nf_2var_existential_transfer` instead of `nf_2var_existential_transfer`.
  - **Estimated size**: 20-40 lines

- [ ] **Task 4.3**: Prove `discrete_nf_exist_sf_guarded_backward`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after Task 4.2)
  - **Type signature**: Same as `nf_exist_sf_guarded_backward` (line 2778) plus discrete instances.
  - **Proof**: Mirror the structure of the sorry'd version, replacing `nf_2var_from_interval_data` with `discrete_nf_2var_from_interval_data`.
  - **Estimated size**: 20-40 lines

- [ ] **Task 4.4**: Prove `discrete_nf_2var_exist_sf_classical`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (after Task 4.3)
  - **Type signature**: Same as `nf_2var_exist_sf_classical` (line 2810) plus discrete instances.
  - **Proof**: Mirror the original, using `discrete_nf_exist_sf_guarded_backward` for the backward direction.
  - **Estimated size**: 20-30 lines

- [ ] **Task 4.5**: Prove `discrete_nf_2var_existence_characterizable`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - **Type signature**: Same as `nf_2var_existence_characterizable` (line 2847) plus discrete instances.
  - **Proof**: Mirror the original, using `discrete_nf_2var_exist_sf_classical`.
  - **Estimated size**: 20-30 lines

- [ ] **Task 4.6**: Prove `discrete_nf_characterizable_by_stavi`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`
  - **Type signature**: Same as `nf_characterizable_by_stavi` (line 3078) plus discrete instances.
  - **Proof**: Induction on k. The formula `char_k` produced is the SAME as in the general version -- the forward direction works for ALL structures (sorry-free). Only the backward direction needs discrete instances. At step k+1:
    - Forward: use existing `nf_exist_sf_guarded_forward` (sorry-free, works for all M).
    - Backward: use `discrete_nf_exist_sf_guarded_backward` (Task 4.3, requires discrete M).
  - **Key architectural insight** (from sorry audit Section 5): The formula is identical regardless. Only the backward correctness proof differs.
  - **Estimated size**: 40-80 lines

- [ ] **Task 4.7**: Prove `discrete_stavi_expressive_completeness`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (near end of file)
  - **Exact type signature**:
    ```lean
    noncomputable def discrete_stavi_expressive_completeness
        (sig : MonadicSignature) (atomMap : Formula -> sig.preds)
        (h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)
        (psi : MonadicFormula sig 1) :
        { A : StaviFormula //
          forall (M : OrderedMonadicStructure sig)
            [SuccOrder M.carrier] [PredOrder M.carrier] [NoMaxOrder M.carrier]
            [NoMinOrder M.carrier] [IsSuccArchimedean M.carrier]
            (t : M.carrier),
            stavi_temporal_truth M atomMap t A <->
            eval M (fun _ => t) psi }
    ```
  - **Proof**: Use `discrete_nf_characterizable_by_stavi` (Task 4.6) to build the StaviFormula. The correctness proof restricts to discrete M and uses the discrete backward direction.
  - **Estimated size**: 30-60 lines

- [ ] **Task 4.8**: Modify `US_expressively_complete_over_prior` in PriorExpressiveness.lean
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean`
  - **Change**: Replace the call to `stavi_expressive_completeness` at line 384 with `discrete_stavi_expressive_completeness`. Prior structures satisfy all 5 discrete instances (verified in sorry audit Section 4: `SuccOrder`, `PredOrder`, `NoMaxOrder`, `NoMinOrder`, `IsSuccArchimedean` on `ChronicleAsPriorModel`).
  - **Estimated size**: 5-15 lines

- [ ] **Task 4.9**: Build verification for Phase 4
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - `lake build Bimodal.Metalogic.WeakCanonical.PriorExpressiveness`
  - `lean_verify US_expressively_complete_over_prior` -- no sorryAx
  - `lean_verify gap_prior_UZ_contradiction` -- no sorryAx

**Timing**: 1.5 hours

**Depends on**: Phase 3

**Files to create/modify**:
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 modified lines)

**Verification**:
- `US_expressively_complete_over_prior` has no sorryAx
- `gap_prior_UZ_contradiction` has no sorryAx
- `gap_prior_SZ_contradiction` has no sorryAx
- `lake build` succeeds for the modified modules

---

### Phase 5: Full Build Verification and Axiom Audit [NOT STARTED]

**Goal**: Run full project build, verify `completeness_discrete` sorry state, and confirm Chain A is eliminated end-to-end.

**Tasks**:
- [ ] Run `lake build` for the full project
- [ ] Run `#print axioms completeness_discrete` and compare against Phase 0 baseline:
  - If `sorryAx` is gone: Chain A is fully eliminated, task is complete
  - If `sorryAx` remains: identify which chain (should be Chain B only, already bypassed by task 281)
- [ ] Verify the full Chain A sorry chain is eliminated:
  - `stavi_expressive_completeness` -- general version still has sorry (expected, non-discrete)
  - `discrete_stavi_expressive_completeness` -- sorry-free
  - `US_expressively_complete_over_prior` -- sorry-free
  - `gap_prior_UZ_contradiction` -- sorry-free
  - `gap_prior_SZ_contradiction` -- sorry-free
  - `no_gaps_discrete_model_surgery` -- sorry-free
  - `limitdom_is_good` -- sorry-free
  - `countermodel_discrete_reynolds_v2` -- sorry-free
- [ ] Verify no new `sorry` introduced: `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/EFGames/ --include="*.lean"` shows only the 3 existing sorry sites in the general (non-discrete) `nf_2var_existential_transfer` / `nf_exist_sf_guarded_backward`
- [ ] Run existing tests: `lake build BimodalTest`

**Timing**: 1 hour

**Depends on**: Phase 4

**Files to modify**: None (verification only)

**Verification**:
- `lake build` succeeds for the full project
- `#print axioms completeness_discrete` result documented
- `grep` finds only the expected sorry sites (general non-discrete versions)
- Existing tests pass

## Testing & Validation

- [ ] `lake build` completes without errors for the full project
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.discrete_stavi_expressive_completeness` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.US_expressively_complete_over_prior` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.WeakCanonical.IntegerModel.gap_prior_UZ_contradiction` does not include `sorryAx`
- [ ] `#print axioms Bimodal.Metalogic.BXCanonical.completeness_discrete` -- either no `sorryAx` or only through Chain B (documented)
- [ ] `GoodStructuresModelSurgery.lean` compiles without changes
- [ ] The general `stavi_expressive_completeness` retains its sorry (expected, not on discrete path)
- [ ] No new `sorry` introduced in `EFGames/` directory beyond existing ones
- [ ] No import cycles (verified by successful `lake build`)
- [ ] Existing `Tests/BimodalTest/` tests pass

## Artifacts & Outputs

- `specs/273_chronicle_gap_contradiction_proof/plans/08_ghr93-decomposition-plan.md` (this file, v8)
- Existing (Phase 0 complete): Axiom audit results
- Existing (Phase 1 complete): `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SemanticBridge.lean`
- Created (Phase 2-3): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/DiscreteGameTransfer.lean` (500-900 new lines)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` (200-400 new lines)
- Modified (Phase 4): `Theories/Bimodal/Metalogic/WeakCanonical/PriorExpressiveness.lean` (5-15 modified lines)
- `specs/273_chronicle_gap_contradiction_proof/summaries/08_ghr93-decomposition-summary.md`

## Rollback/Contingency

- **If the rank parameter alignment fails** (game_depth/game_rank do not match GHR93's f/g well enough to close the gap between r and r+4n): Redefine `game_rank` to use `game_depth sig n + 4 * game_depth sig n` directly matching GHR93 Definition 8.9. The codebase `game_depth` already satisfies f(n+1) > (1+3f(n))*(2k_n)+1, so g(n) = sum_{i<n} 4*f(i) satisfies g(n+1) > g(n) + 4f(n). If `game_rank` and `game_depth` mismatch, define them from scratch in DiscreteGameTransfer.lean.

- **If Claim 1's canonical pivot construction fails in Lean** (the infimum construction requires showing c is in M_r, which needs r-definability): For discrete orders, c is always a point (no gaps), so c is in M.carrier and `extendPoint c` is in M_r for any r. The formula C has rank r+1, so c = inf{t : M models C(u) for all u in (t,y)} is either x or a point where C transitions from false to true. Use `discrete_no_gaps` to avoid gap-related complications entirely.

- **If Proposition 7 is too large** (>400 lines): Factor the decomposition formula enumeration into a separate lemma `discrete_decomp_formula_finite` that counts the number of decomposition formulas. This reduces Proposition 7 to a cleaner induction.

- **If the Proposition 5 gap cannot be bypassed** (game wins do not feed into `nf_fraisse_compression` cleanly): Formalize a restricted Proposition 5 for discrete orders (~100 lines) that states: if Duplicator wins the n-round standard EF game G_n((M,x),(N,y)), then M and N agree on all FO formulas of quantifier depth <= n with free variables among x, y. This is the standard Ehrenfeucht-Fraisse theorem and is well-known.

- **If DiscreteGameTransfer.lean build time exceeds heartbeat**: Split into two files: `DiscreteGameTransfer/Theorem6.lean` (Theorem 6 + Claims) and `DiscreteGameTransfer/Proposition7.lean` (Proposition 7).

- **Git revert** to the commit before implementation if any phase introduces regressions.
