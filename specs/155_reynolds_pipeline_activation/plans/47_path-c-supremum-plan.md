# Implementation Plan: Path C Full Supremum Approach for Case II (v47)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IMPLEMENTING]
- **Effort**: 26-40 hours
- **Dependencies**: Tasks 154 (COMPLETED), 168 (COMPLETED), 174 (COMPLETED), 199 (PARTIAL)
- **Research Inputs**: reports/44_team-research.md, reports/44_teammate-a-findings.md, reports/44_teammate-b-findings.md, reports/44_teammate-c-findings.md, reports/44_teammate-d-findings.md, reports/47_xt-complete-usage-analysis.md, reports/47_lean-infrastructure-inventory.md, reports/47_plan-v42-deep-review.md, reports/46_strategic-pivot-report.md, reports/45_semantic-vs-syntactic-B.md, reports/45_ghr93-rewrite-research.md, reports/44_literature-interval-splitting.md, reports/42_plan-literature-alignment.md, reports/40_ghr93-case-ii-step6.md, reports/39_game-depth-restructuring.md, reports/46_teammate-a-literature.md, reports/46_teammate-b-infrastructure.md, reports/46_teammate-c-mathematical.md, reports/46_teammate-d-tactical.md, reports/47_sorting-biconditional-research.md, reports/47_ghr93-round2-structure.md, reports/47_same-order-type-analysis.md
- **Artifacts**: plans/47_path-c-supremum-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v47 revises plan v46 with a fully revised Phase 5 that implements the COMPLETE Path C: supremum b + restricted tau, eliminating tau_left/tau_right entirely from ghr93_case_II. Plan v46 left Phase 5 [PARTIAL] because Tasks 5.6-5.7 (delete tau_left/tau_right, rewrite Round 2) were blocked: the existing tau_r on [d, y'] -> [c, y] cannot provide biconditional orderings relative to p_n/e_n, which are interior points. Seven research reports (round 47) confirmed that tau_left/tau_right are mathematically necessary IF tau plays on the full interval -- but also identified the root cause: the supremum serves a DUAL role that v46 only partially exploited.

**The dual role of supremum b = sup{t in (x,y) : M |= B(t)}**:
1. **Containment** (z <= b): Already addressed by `untl_witness_bounded` in Tasks 5.0-5.5.
2. **Interval shrinking**: Restricting tau from [d, y'] -> [c, y] to [d, b'] -> [c, b] makes p_n and e_n boundary-adjacent points (p_n <= b', e_n <= b), so the SINGLE restricted tau's winning condition directly provides biconditional orderings relative to p_n/e_n. This is why GHR93 uses no sub-games.

The v46 plan built the containment infrastructure (role 1) but did not build the restricted tau (role 2), leaving tau_left/tau_right necessary. This revision adds the restricted tau via fresh IH application on [d, b'] -> [c, b], which replaces BOTH tau_left AND tau_right with a single game.

Key changes from plan v46:
- **Phase 5 completely rewritten**: New task structure 5.0-5.8 implementing BOTH roles of the supremum. All tasks reset to [NOT STARTED].
- **Task 5.0 (REVISED)**: Supremum infrastructure -- define b/b', prove existence, prove p_n <= b' and e_n <= b.
- **Task 5.2 (REVISED)**: Restricted tau via fresh IH on [d, b'] -> [c, b] (the critical missing piece from v46).
- **Task 5.4 (NEW)**: sel_pn_ord from restricted tau monotonicity + biconditional orderings directly.
- **Task 5.5 (NEW)**: Delete tau_left, tau_right, forward-game e_n, resp_left, and all associated machinery.
- **Task 5.6 (REVISED)**: Rewrite Round 2 with GHR93's 5-way case split using single restricted tau.
- **Phases 1-4 unchanged** (all [COMPLETED]).
- **Phases 6-8 unchanged** (all [NOT STARTED]).

### Research Integration

Seven new research reports (round 47) plus the phase-5 handoff are integrated. Key findings driving this revision:

- **Report 47 (Sorting-Biconditional)**: Sorting invariant (`Monotone a_bwd`) gives WEAK monotonicity (a_init(k) <= p_n, not strict). tau_left provides the response function, biconditional orderings, gap/point agreement, formula agreement, d-vs-sel ordering, sel-vs-sel ordering, and Case B1 Round 2 dispatch -- 7 independent categories, 65+ usage sites. tau_left CANNOT be eliminated without restricted tau.
- **Report 47 (GHR93 Round 2 Structure)**: CRITICAL discovery: GHR93's supremum serves DUAL role -- (1) containment AND (2) shrinking tau's interval so p_n/e_n become boundary-adjacent. Without restricted tau, tau_left/tau_right compensate for tau playing on the wrong (too-large) interval. With restricted tau on [c, b], a single game covers everything.
- **Report 47 (same_order_type Analysis)**: `same_order_type` requires biconditional orderings for ALL pairs. `same_order_type_of_cases` needs 7 biconditional ordering arguments. These are irreducible -- no bypass exists. But the single restricted tau provides all of them directly because p_n <= b' and e_n <= b are within its interval.
- **Handoff (Phase 5 Task 5.6 Analysis)**: Confirmed tau_left necessity under current architecture. Recommended enhancing with supremum infrastructure or restructuring `same_order_type_of_cases`.
- **Report 46 Teammate A (Literature)**: GHR93/GHR94 p.806 exact argument: b = sup, tau on [c', b'] -> [c, b], e_n = z <= b. Single tau, no sub-games.
- **Report 46 Teammate B (Infrastructure)**: No interval-restricted Until in codebase. All CharacteristicFormula.lean theorems axiom-clean.
- **Report 46 Teammate C (Mathematical)**: 5 resolution paths evaluated. Fresh IH for restricted tau is the cleanest path matching GHR93.

### Prior Plan Reference

Plan v46 correctly built the containment infrastructure (Tasks 5.0-5.5) but left the interval-shrinking role unaddressed, causing Tasks 5.6-5.7 to be blocked. This revision completes Path C by adding the restricted tau.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Implement the FULL GHR93 supremum approach for Case II (Path C with both dual roles)
- Build supremum infrastructure: b = sup{t in (x,y) : B(t)} exists in M_r, b' similarly in N_r
- Derive restricted tau on [d, b'] -> [c, b] via fresh IH application (the critical missing piece)
- Construct e_n from U(B,A) witness with z <= b guaranteed by supremum
- Prove sel_pn_ord and all biconditional orderings from the single restricted tau
- Delete tau_left, tau_right, forward-game e_n, resp_left, and all associated machinery (~500-700 lines)
- Implement Round 2 with GHR93's 5-way case split using single restricted tau
- Complete Cases III/IV gap handling (Phase 6)
- Wire Transfer.lean to game pipeline (Phase 7)
- Achieve sorry-free bx_completeness (Phase 8)

**Non-Goals**:
- Closing the bridge lemma (nf_2var_from_interval_data in StaviCompleteness.lean)
- Changing game_depth definition (confirmed unnecessary per report 39)
- Changing EFGames core definitions (CustomGame, Decomposition, Composition are sorry-free)
- Dense or mixed completeness variants
- Non-critical TruthLemma sorries (6 sorries in TruthLemma.lean, documented non-critical)
- BXCanonical/Bundle/Algebraic sorry closure (20 sorries in independent subsystems)
- Proving succ_cofinal directly (bypassed by Reynolds pipeline)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Supremum existence in ExtendedCarrier: proving b = sup{t : B(t)} exists in M_r | H | M | ExtendedCarrier includes all r-definable gaps. B = X_{a_n} is rank-r definable, so {t : B(t)} is a rank-r definable set. Its supremum is either a carrier point (if B has a maximum), y (if cofinal), or an r-definable gap. GHR93 Lemma 8.6 / GHR94 12.8.10 provides the argument. Fallback: targeted existence lemma for "sup of B-satisfying points in an interval" rather than general definable_sup. |
| Restricted tau derivation via fresh IH: applying IH to [d, b'] -> [c, b] requires a forward game on [c, b] x [d, b'] | H | M | Forward game on [c, b] x [d, b'] obtainable from h_r1_univ (universal forward game) applied to the sub-interval with rank-down. Requires showing b and b' are both in [x, y] and [x', y'] respectively (true since b <= y and b' <= y'). If fresh IH is too complex, fallback: restrict existing tau by proving that when Spoiler picks from [d, b'], Duplicator's responses stay in [c, b] by order-preservation and supremum properties. |
| b' definition and b'/b correspondence: need b' on N-side to match b on M-side | M | M | b' = sup{t in (x', y') : N |= B(t)}. Since B(a_n) holds and a_n = p_n is in (x', y'), b' >= a_n. b and b' correspond via formula agreement on B at rank r. Fresh IH requires a forward game on [c, b] x [d, b'] at rank r, obtainable from h_r1_univ. |
| n=0 boundary: ref_N = d may equal a_bwd(n), breaking U(B,A) witness | M | M | Already handled in v46 Tasks 5.1b: explicit case split at top. When d = a_bwd(n), all selections collapse to d = p_n; respond with all c and e_n = c. |
| Supremum b = y edge case: restricted tau becomes original tau | L | M | Easy case -- original tau suffices, Until witness in (ref_M, y] automatically. No special handling needed. |
| Net code increase instead of reduction after rewrite | L | L | Target: delete ~500-700 lines (tau_left, tau_right, resp_left, forward-game e_n, resp_mod, old Round 2 at 3 sites), add ~300-500 lines (supremum + restricted tau + simplified Round 2). Net reduction: ~100-300 lines. |
| left(B,D)/right(B,D) depth arithmetic for Case IV at ceiling r+4 | M | M | GHR94 p.839 confirms rank(U(delta_IV, A)) = r+4. Track stavi_depth vs GHR93 "rank" carefully. Verify depth bounds at each step with lean_goal. |
| Transfer.lean rewiring: type-signature incompatibility | M | H | Phase 7 includes explicit type-signature analysis. If incompatible, build adapter layer (~50-100 lines). |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 0 | 1, 2 | -- (already COMPLETED) |
| 1 | 3, 4 | -- (already COMPLETED) |
| 2 | 5 | 3, 4 |
| 3 | 6 | 3, 4 |
| 4 | 7 | 5, 6 |
| 5 | 8 | 7 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Theorem6.lean Rank-Varying IH (delta=4 Foundation) [COMPLETED]

**Goal**: Close the sorry at Theorem6.lean:325, enabling sigma/tau at rank r+4 throughout the proof.

**Status**: Fully completed. Theorem6.lean is sorry-free. Used rank-varying IH with delta=4, h_r1_univ at r'=r+4n+2, added rank_embed_trans and rank_embed_comp_heq helper lemmas, used ghr93_duplicator_wins_rank_cast for dependent type transport.

**Tasks**:
- [x] Task 1.1: Understand the existing `ih_delta4` lambda structure at line 308-316
- [x] Task 1.2: Implement the rank promotion via h_r1_univ at r'=r+4n+2
- [x] Task 1.3: Apply the IH at base rank r+4 with rank-embedded positions
- [x] Task 1.4: Verify backward game at rank r+4 has correct type

**Timing**: 3-5 hours (actual: completed)

**Depends on**: none

**Completed**: 2026-05-28

---

### Phase 2: Independent X_t Construction (Characteristic Formula Machinery) [COMPLETED]

**Goal**: Build the machinery to construct X_t = B = X_{a_n} as a SINGLE StaviFormula of depth at most r for each NormalForm equivalence class, AND build A = X_{(a_{n-1}, a_n)} as the interval type formula. Created CharacteristicFormula.lean (~310 lines) with sorry-free API except 2 existence sorries.

**Status**: Fully completed. Core API is sorry-free: sf_disj, sf_disjList, sf_conjList with depth bounds; rank_type_separator (sorry-free); x_t_formula, x_t_depth, x_t_correct, x_t_self, x_t_implies_agreement; x_interval_formula, x_interval_depth, x_interval_correct, x_interval_self; sf_untl, sf_snce constructors with depth bounds and truth semantics; untl_extract_witness, untl_type_holds_at_witness, untl_type_depth_le_r_plus_4.

Two existence sorries remained: x_t_formula_exists (line 221) and x_interval_formula_exists (line 285), addressed in Phase 3.

**Tasks**:
- [x] Task 2.1: Create CharacteristicFormula.lean in EFGames/ (~310 lines)
- [x] Task 2.2: Define x_t_formula via Classical.choose on x_t_formula_exists
- [x] Task 2.3: Define x_interval_formula via Classical.choose on x_interval_formula_exists
- [x] Task 2.4: Define Until/Since formula constructors sf_untl and sf_snce

**Timing**: 4-6 hours (actual: completed)

**Depends on**: Phase 1

**Completed**: 2026-05-28

---

### Phase 3: Close CharacteristicFormula Existence Sorries [COMPLETED]

**Goal**: Close the two existence sorries in CharacteristicFormula.lean that gate the entire U(B,A) approach. Without these, B and A cannot be constructed for Case II, and left(B,D)/right(B,D) cannot be used for Cases III/IV.

**Status**: Fully completed. Used nf_profile on extendedStructureWithMu at depth 2*r instead of rank_type quotient Fintype; proved nf_profile_determines_rank_type as the key bridge.

**Tasks**:
- [x] Task 3.1: Prove rank_type quotient finiteness (~80-120 lines)
- [x] Task 3.2: Close x_t_formula_exists (~60-100 lines)
- [x] Task 3.3: Close x_interval_formula_exists (~50-80 lines)
- [x] Task 3.4: Verify sorry-free status of CharacteristicFormula.lean (~10 lines)

**Timing**: 3-5 hours (actual: completed)

**Depends on**: none (Phase 2 completed, this closes its remaining sorries)

**Completed**: 2026-05-28

---

### Phase 4: Tactic Infrastructure (Grid Dispatch Prerequisites) [COMPLETED]

**Goal**: Build general-purpose tactic infrastructure that will be used by the Case II rewrite (Phase 5), Cases III/IV (Phase 6), and any remaining grid dispatch goals. This phase can execute in parallel with Phase 3.

**Status**: Fully completed. `order_reverse` helper and `same_order_type_grid_uh` macro added to EFGameTactics.lean. Task 4.3 (sel_dispatch helper) deferred as unnecessary.

**Tasks**:
- [x] Task 4.1: Add `order_reverse` theorem to EFGameTactics.lean (~25 lines)
- [x] Task 4.2: Add `same_order_type_grid_uh` macro to EFGameTactics.lean (~5 lines)
- [ ] Task 4.3: (Optional) Create sel_dispatch helper tactic (~30-50 lines) -- deferred

**Timing**: 2-3 hours (actual: completed)

**Depends on**: none (parallel with Phase 3)

**Completed**: 2026-05-28

---

### Phase 5: GHR93-Faithful Case II Rewrite (Path C: Full Supremum + Restricted Tau) [BLOCKED]

**Goal**: Rewrite ghr93_case_II in CaseAnalysis.lean to follow GHR93 exactly. The FULL Path C requires TWO pieces of infrastructure that together eliminate tau_left/tau_right: (1) supremum b = sup{t in (x,y) : B(t)} for Until witness containment (z <= b), and (2) restricted tau on [d, b'] -> [c, b] via fresh IH for biconditional orderings relative to p_n/e_n. A single restricted tau replaces BOTH tau_left AND tau_right because p_n <= b' and e_n <= b are within the restricted interval's endpoints.

**Current state**: CaseAnalysis.lean is 3467 lines. ghr93_case_II spans lines 1368-2136 (~769 lines, already sorry-free). Infrastructure from v46 Tasks 5.0-5.5 exists: `untl_witness_bounded` (CharacteristicFormula.lean), `ghr93_untl_transfer` (CaseAnalysis.lean:1191-1250), `ghr93_construct_en` (CaseAnalysis.lean:1268-1357). CharacteristicFormula.lean IS imported (added in v46). The forward-game e_n construction (lines 1440-1517), tau_left/tau_right (lines 1539-1550), resp_left play (lines 1564-1586), and Round 2 dispatch (lines 1607-2136) are the deletion/rewrite targets.

**Why v46 failed and v47 succeeds**: v46 built containment (role 1 of supremum) but not interval-shrinking (role 2). Without restricted tau, tau_r on [d, y'] -> [c, y] gives no orderings relative to p_n/e_n (interior points). Research confirmed tau_left compensates for this by making p_n/e_n into endpoints of a sub-game. The fix is NOT to eliminate tau_left within the current architecture, but to CHANGE the architecture: restrict tau's interval to [d, b'] -> [c, b] (matching GHR93), making p_n and e_n boundary-adjacent in the SINGLE game.

**Literature to read BEFORE implementing**:
- GHR93 Section 8, Case II (literature/Gabbay_Hodkinson_Reynolds_1993, pp.117-118)
- GHR94 Chapter 12, pp.792-810 (Case II detailed proof, especially p.806 for supremum and p.808-810 for Round 2)
- GHR94 Lemma 8.6 / 12.8.10 (supremum of a rank-r definable set is in M_r)
- Report 47 (GHR93 Round 2 Structure): Sections 5.1-5.3 (dual role of supremum, why restricted tau eliminates sub-games)
- Report 47 (same_order_type Analysis): Sections 1-5 (exact definitions, biconditional requirements, tau_left dependency chain)
- Report 47 (Sorting-Biconditional): Sections 2-4 (7 categories of tau_left usage, why resp_tau cannot replace resp_left)
- Report 46 Teammate A: Sections 1-3 (verbatim extraction of the supremum argument)
- Report 45: Sections 2-5 (CharacteristicFormula.lean identifiers, depth budget, deletion/construction maps)

**CharacteristicFormula.lean identifiers to use** (all sorry-free):
- `x_t_formula N atomMap r t` : `StaviFormula` -- characteristic formula for rank_type of t
- `x_t_depth` : `stavi_depth (x_t_formula ...) <= r`
- `x_t_correct u` : truth at u iff rank_type u = rank_type t
- `x_t_self` : x_t_formula holds at t itself
- `x_t_implies_agreement` : given X_t holds at u, agreement on all depth-r formulas
- `x_interval_formula N atomMap r t u` : `StaviFormula` -- interval type formula
- `x_interval_depth` : `stavi_depth (x_interval_formula ...) <= r`
- `x_interval_correct w` : truth at w iff exists v with matching rank_type in (t, u)
- `x_interval_self` : interval formula holds for any mu-point in the interval
- `sf_untl B A` : Until formula constructor, `stavi_depth = max(depth B)(depth A) + 2`
- `untl_extract_witness h` : extracts witness from Until truth proof
- `untl_witness_bounded` : bounded Until witness (z in (t, bound])
- `untl_type_holds_at_witness` : given mu_holds t, s < t, proves U(X_t, X_{(s,t)})(s)
- `untl_type_depth` : `stavi_depth(U(X_t, X_{(s,t)})) <= r + 2`
- `formula_transfer_rank_embed` : bridges rank-r and rank-r' truth via rank_embed
- `ghr93_untl_transfer` : transfers U(B,A) from N to M through tau (CaseAnalysis.lean:1191)
- `ghr93_construct_en` : end-to-end e_n construction via U(B,A) + bounded witness (CaseAnalysis.lean:1268)

**Depth budget** (from report 45 Section 2.2, confirmed by Teammate B Section 1.7):
- B = x_t_formula: depth <= r
- A = x_interval_formula: depth <= r
- U(B, A) = sf_untl B A: depth = max(r, r) + 2 = r + 2
- Restricted tau at rank r+delta (delta >= 2 from hd): formula agreement covers depth <= r+delta >= r+2
- CONCLUSION: U(B,A) is transferable through restricted tau at rank r+delta.

**Tasks**:

- [ ] Task 5.0: Supremum infrastructure in ExtendedCarrier (~80-120 lines) *(deviation: blocked -- supremum does not help with finite-position game orderings; see BLOCKER above)*

  **Goal**: Define b_sup = sup{t in ExtendedCarrier : x < t < y AND B(t)} where B = x_t_formula(a_n). Define b'_sup similarly in N. Prove existence, bounding properties, and that a_n <= b'_sup and e_n <= b_sup (once e_n is constructed).

  **Mathematical argument** (GHR94 p.792, Teammate A Section 1.2 Prerequisite 1):
  - B = X_{a_n} is a rank-r StaviFormula (depth <= r from x_t_depth)
  - The set S = {t in (x,y) : M |= B(t)} is nonempty (B-satisfying points exist from tau's responses)
  - b = sup(S) exists in ExtendedCarrier M atomMap r: either b is a carrier point (if S has a maximum), b = y (if S is cofinal in (x,y)), or b is an r-definable gap defined on the right by the negation of B
  - In all cases b is in M_r (ExtendedCarrier at rank r)
  - Similarly b' = sup{t in (x',y') : N |= B(t)} exists in N_r, with b' >= a_n since B(a_n) holds

  **Implementation approach**:
  - If building a general `definable_sup` is too heavy, prove a targeted lemma:
    ```lean
    theorem definable_sup_exists {M : OrderedMonadicStructure sig} {atomMap} {r}
        {x y : ExtendedCarrier M atomMap r} (hxy : x < y)
        {B : StaviFormula} (hB_depth : stavi_depth B <= r)
        (h_nonempty : exists t, x < t /\ t < y /\ mu_holds t /\
          stavi_temporal_truth_mu M atomMap r t B) :
        exists b : ExtendedCarrier M atomMap r, x < b /\ b <= y /\
          (forall t, x < t /\ t <= b /\ mu_holds t /\
            stavi_temporal_truth_mu M atomMap r t B -> t <= b) /\
          (forall t, b < t /\ t < y /\ mu_holds t ->
            not (stavi_temporal_truth_mu M atomMap r t B))
    ```
  - The existence proof uses GHR93 Lemma 8.6: the supremum of a rank-r definable set is either a point, an endpoint, or an r-definable gap. Since ExtendedCarrier includes all r-definable gaps, the supremum exists in M_r.
  - Key lemmas needed: `b_sup_le_y`, `an_le_b'_sup` (since B(a_n) holds), `b_sup_in_interval` (x < b <= y)

  **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` or new file `SupremumLemma.lean`

  **Risk**: This is new infrastructure. Mitigated by two fallback levels: (1) if full definable_sup is too complex, prove only the specific properties needed (nonempty B-set has an upper bound b with no B-points above b in (x,y)); (2) if even that fails, use b = y as a trivial upper bound (the restricted tau then degenerates to the original tau, and the proof reduces to the current architecture -- no improvement but no regression).

- [ ] Task 5.1: B, A construction and n=0 boundary handling (~30-50 lines)

  - Define B := x_t_formula N atomMap r (a_bwd (n, by omega)) -- characteristic formula for a_n's rank type
  - Define A := x_interval_formula N atomMap r ref_N (a_bwd (n, by omega)) -- interval type formula for (ref_N, a_n)
  - Case split at top: `if h_degen : d = a_bwd (n, ...)` then degenerate case (all selections = d = p_n; respond with all c and e_n = c, trivial proof). In non-degenerate case proceed with main construction.
  - Define ref_N as d (when n = 0) or a_bwd(n-1) (when n > 0)
  - Prove h_ref_N_lt_an: ref_N < a_bwd(n) from degenerate case elimination + h_mono
  - Existing `ghr93_untl_transfer` and `ghr93_construct_en` already handle B/A construction internally; this task exposes them at the ghr93_case_II level
  - **File**: CaseAnalysis.lean

- [ ] Task 5.2: Restricted tau on [d, b'] -> [c, b] via fresh IH (~100-150 lines, NEW -- the critical missing piece from v46) *(deviation: blocked -- restricted tau with b >= e_n provides weaker orderings than tau_left with b = e_n; see BLOCKER above)*

  **Goal**: Derive a backward strategy for G_{n, r}(N, d b'; M, c b) where b = sup{t in (x,y) : B(t)} and b' = sup{t in (x',y') : N |= B(t)}.

  **Why this is the key to eliminating tau_left/tau_right** (from report 47 GHR93 Round 2 Structure, Section 5):
  - Current architecture: tau_r on [d, y'] -> [c, y]. p_n and e_n are interior points -- no orderings relative to them.
  - Restricted tau on [d, b'] -> [c, b]. Since p_n <= b' and e_n <= b, these are boundary-adjacent. The restricted tau's winning condition gives orderings for ALL positions within [d, b'] and [c, b], including orderings relative to any point in the interval.
  - Specifically, when restricted tau responds to a_init (selections in [d, b']), it gives `same_order_type` for the game tuple. Because p_n is in [d, b'] and e_n is in [c, b], the biconditional `(a_init(k) < p_n iff resp(k) < e_n)` is available from the restricted tau's Round 2 (challenging with p_n on N-side, getting response near e_n on M-side).

  **Implementation approach** (try in order):
  1. **Approach 1 (fresh IH application -- GHR93-faithful)**: Apply `ih` (the IH from ghr93_case_II's signature) to the sub-interval [c, b] x [d, b'] at rank r. This requires:
     - A (1+3n)-round forward game on [c, b] x [d, b']: obtainable from `h_r1_univ` applied to [c, b] x [d, b'] at some rank r'. Need to show b and b' are in [x, y] and [x', y'] respectively (true since b <= y and b' <= y'), then restrict via `inClosedInterval` sub-interval containment.
     - Proof that b and b' are in the correct intervals
     - Apply `ghr93_duplicator_wins_rank_down` to project to rank r if the forward game is at higher rank
  2. **Approach 2 (restrict existing tau)**: If the fresh IH is too complex, prove that when Spoiler picks from [d, b'] (subset of [d, y']), existing tau's responses stay in [c, b]. This requires showing tau's order-preservation + B-satisfying set properties force responses below b. This is harder to prove formally but avoids a second IH application.

  **File**: CaseAnalysis.lean

  **Risk**: Fresh IH application requires constructing a forward game on [c, b] x [d, b']. Mitigated by h_r1_univ which provides forward games at any rank on any sub-interval. The main complexity is type-wrangling to fit the sub-interval into h_r1_univ's signature.

- [ ] Task 5.3: U(B,A) truth and Until witness from restricted tau (~40-60 lines)

  - Transfer U(B,A) from N to M through the RESTRICTED tau (not the full tau_r)
  - The restricted tau at rank r+delta gives formula agreement at depth <= r+delta >= r+2
  - Since stavi_depth(sf_untl B A) <= r+2, the transfer works
  - Existing `ghr93_untl_transfer` can be adapted to use restricted tau instead of props.tau
  - Extract witness z = e_n via `untl_witness_bounded` with bound = b
  - Since b = sup of B-satisfying points and the Until semantics require B(z), we get z <= b directly from the supremum property
  - The restricted tau guarantees ref_M = resp_restricted(n-1) is in [c, b], so the Until witness z > ref_M is automatically in the right region
  - Set e_n := z. Prove inClosedInterval x y e_n: x <= c <= ref_M < z = e_n (for x <= e_n), and z <= b <= y (for e_n <= y)
  - **File**: CaseAnalysis.lean

- [ ] Task 5.4: sel_pn_ord and biconditional orderings from restricted tau (~30-50 lines)

  **Goal**: Prove the biconditional orderings that `same_order_type_of_cases` requires, using the single restricted tau instead of tau_left.

  **Why this now works** (from report 47 same_order_type Analysis, Section 3.3):
  - Restricted tau plays on [d, b'] -> [c, b]
  - a_init(k) is in [d, b'] for all k (since a_init(k) <= p_n <= b' from h_mono + B(a_n))
  - resp_restricted(k) is in [c, b] for all k (from restricted tau's interval constraint)
  - p_n is in [d, b'] (since B(a_n) holds, a_n = p_n, so p_n <= b')
  - e_n is in [c, b] (since B(e_n) holds and e_n <= b from supremum)
  - The restricted tau's `same_order_type` gives biconditional orderings for ALL pairs of positions within the game, including orderings relative to p_n and e_n
  - Specifically: when we play restricted tau's Round 2 challenged with p_n, we get b_resp with orderings relative to all selections. This gives `(a_init(k) < p_n iff resp_restricted(k) < b_resp_to_pn)`. If b_resp_to_pn is near e_n (by formula matching B(e_n) = B(p_n)), this gives the needed biconditional.

  **sel_pn_ord** (trivial chain from GHR93):
  - For all k < n: resp_restricted(k) <= resp_restricted(n-1) = ref_M < z = e_n
  - First inequality: from restricted tau's order preservation (a_init is monotone from h_mono, so responses are monotone)
  - Second inequality: from Until witness (z > ref_M)

  **Full biconditional orderings for same_order_type_of_cases**:
  - `hord_sel_sel`: directly from restricted tau's `same_order_type` at game indices
  - `hord_left_sel_pn` equivalent: from restricted tau, since p_n is within [d, b'] and e_n within [c, b], the orderings `(a_init(k) < p_n iff resp_restricted(k) < e_n)` come from the game's order-type condition applied to the pair (k, challenge_index_for_pn)

  **File**: CaseAnalysis.lean

- [ ] Task 5.5: Delete old machinery (~-500 to -700 lines deletion) *(deviation: blocked -- cannot delete tau_left/tau_right without working replacement)*

  **Deletion map** (from report 45 Section 4, updated with current line numbers):
  - Lines 1440-1517: Forward-game e_n construction (a_pad_big, h_d_compat_left call, forward game extraction) -- DELETE entirely
  - Lines 1518-1538: p_cy hoisting, tau formula data extraction -- KEEP (may still be needed for Round 2; evaluate during implementation)
  - Lines 1539-1550: tau_left and tau_right construction via IH -- DELETE (replaced by single restricted tau from Task 5.2)
  - Lines 1551-1563: tau_left/tau_right prerequisite proofs (ha_init_sub etc.) -- DELETE or REWRITE for restricted tau
  - Lines 1564-1586: Play tau_left with a_init, extract hord_left_sel_pn -- DELETE (replaced by restricted tau orderings from Task 5.4)
  - Lines 1587-1606: resp_left response function construction, a'_resp definition -- REWRITE (use resp_restricted directly)
  - Lines 1607-2136: Round 2 dispatch (Case A, B1, B2) -- REWRITE (Task 5.6 below)

  **New a'_resp definition** (replacing the tau_left-based version):
  ```lean
  let a'_resp : Fin (n + 1) -> ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_restricted (i.val, h) else e_n
  ```

  **File**: CaseAnalysis.lean
  - Also delete `ghr93_construct_en` helper (lines 1268-1357) if no longer called, OR keep as reusable infrastructure

- [ ] Task 5.6: Rewrite Round 2 with GHR93's 5-way case split (~200-300 lines) *(deviation: blocked -- depends on restricted tau orderings which are unavailable)*

  **GHR93's Round 2 structure** (GHR94 pp.808-810, report 47 Section 1.2):
  Given Spoiler's challenge b_sp (carrier point in [x, y] on M-side), respond with b_resp (carrier point in [x', y'] on N-side). The 5-way case split:

  **(a) b_sp <= c**: Use sigma for Round 2. Spoiler's challenge is in [x, c], so play sigma_r's Round 2 to get b_resp in [x', d]. All orderings: a'_resp(k) = resp_restricted(k) >= c >= b_sp for k < n; e_n >= c >= b_sp. Formula agreement from sigma's winning condition. Grid dispatch via `same_order_type_of_cases`.

  **(b) c < b_sp, b_sp between restricted tau responses for k < n**: b_sp is in (c, b), within restricted tau's interval. Play restricted tau's Round 2 with b_sp as challenge. Tau provides b_resp in [d, b']. All orderings from restricted tau's winning condition. This covers GHR93 cases where b_sp falls among the e_0, ..., e_{n-1} responses.

  **(c) b_sp in (resp_restricted(n-1), e_n)**: A holds at b_sp (from U(B,A)(ref_M) and e_{n-1} = ref_M < b_sp < e_n = z). By x_interval_correct, A(b_sp) means b_sp has rank_type matching some mu-point v in (ref_N, a_n) in N. Respond with b_resp = carrier point with matching rank type. Formula agreement from x_t_implies_agreement.

  **(d) b_sp = e_n**: Respond with b_resp = p_n. B(e_n) holds (Until witness), so rank_type(e_n) = rank_type(a_n) = rank_type(p_n). Formula agreement at depth r from x_t_implies_agreement. Orderings: resp_restricted(k) < e_n = b_sp for k < n (from sel_pn_ord).

  **(e) b_sp > e_n, b_sp in (e_n, b]**: b_sp is in (e_n, b], within restricted tau's interval. Play restricted tau's Round 2. Tau provides b_resp in [d, b']. All orderings from restricted tau plus the fact that resp_restricted(k) < e_n < b_sp for all k. If b_sp > b: the supremum property guarantees no B-satisfying points exist above b, so this is handled by the continuation structure.

  **Grid dispatch at each case**: Apply `same_order_type_of_cases` from EFGameTactics.lean. The prerequisites are dramatically simpler than the tau_left/tau_right architecture because:
  - No resp_mod: use resp_restricted directly
  - sel_pn_ord is a single lemma (from Task 5.4)
  - No by_cases hk/hne_k case splits on individual resp_tau indices
  - All ordering data comes from ONE game (restricted tau) instead of three (tau_r, tau_left, tau_right)

  **File**: CaseAnalysis.lean

- [ ] Task 5.7: Grid dispatch assembly (~50-100 lines) *(deviation: blocked -- depends on restricted tau)*

  - Wire `same_order_type_of_cases` at each of the 5 Round 2 cases
  - The restricted tau directly provides all 7 ordering categories that previously required tau_left:
    1. Response function: resp_restricted(k) replaces resp_left(k)
    2. Biconditional ordering: from restricted tau's same_order_type
    3. Gap/point agreement: from restricted tau's gap_point_agreement
    4. Formula agreement: from restricted tau's formula_agreement
    5. d-vs-sel ordering: from restricted tau (d is an endpoint)
    6. sel-vs-sel ordering: from restricted tau's same_order_type
    7. Round 2 challenges in [c, b]: from restricted tau's Round 2
  - The `same_order_type_of_cases` helper from EFGameTactics.lean can be reused unchanged
  - **File**: CaseAnalysis.lean

- [ ] Task 5.8: Final assembly and verification (~20-40 lines) *(deviation: blocked -- depends on preceding tasks)*

  - Wire the 5-way case split into the overall ghr93_case_II structure
  - Verify all grid dispatch goals closed
  - Verify `#print axioms ghr93_case_II` shows no sorryAx via lean_run_code
  - Count lines: target ~400-600 lines for Case II vs current ~769 lines
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` must pass
  - Verify that `ghr93_untl_transfer` and `ghr93_construct_en` are either used by the new proof or documented as reusable infrastructure
  - **File**: CaseAnalysis.lean

**Anti-deviation warnings**:
- Do NOT retain tau_left or tau_right -- the ENTIRE point of this revision is to eliminate them via restricted tau
- Do NOT retain the forward-game e_n construction (a_pad_big, h_d_compat_left) -- e_n comes from U(B,A) witness
- Do NOT use resp_left or resp_mod -- use resp_restricted directly
- Do NOT construct e_n from the forward game (GHR93 does NOT use the forward game for e_n in Case II)
- Do NOT use A = sf_top (provides no information for Round 2 case (c))
- Do NOT use nf_characterizable_by_stavi for B (use x_t_formula from Phase 2)
- Do NOT skip Task 5.0 (supremum infrastructure) -- it enables BOTH containment AND interval shrinking
- Do NOT skip Task 5.2 (restricted tau) -- this is the critical new piece that v46 lacked
- Do NOT skip the n=0 boundary case (Task 5.1) -- report 45 Section 3.4 shows U(B,A) fails when d = p_n
- Do NOT use lean_verify for sorry checking -- always use `#print axioms` via lean_run_code
- Do NOT use `same_order_type_grid_uh` via `<;>` for grid dispatch (unhygienic does not propagate; use manual expansion)
- Do NOT use `rename_i` inside `first` fallback chains (hard error on count mismatch)
- Do NOT touch the Cases III/IV sorry at line 3318 -- it belongs to Phase 6
- Do NOT attempt a "partial" Path C that keeps tau_left -- either build the full restricted tau or fall back to the contingency plan

**BLOCKER** (Phase 5):
- **What failed**: The restricted tau on [d, b'] -> [c, b] (with b = sup of B-satisfying points, b >= e_n) does NOT provide biconditional orderings relative to p_n and e_n. The game's `same_order_type` provides orderings only between the game's FIXED positions (endpoints d/b'/c/b, selections a_init(k)/resp(k), Round 2 pair). Since p_n and e_n are INTERIOR points of [d, b'] and [c, b] (not endpoints or selections), no orderings relative to them are available from the restricted tau's winning condition.
- **What was tried**:
  1. Restricted tau on [d, b'] -> [c, b] with b' >= p_n, b >= e_n: The orderings at position (1+k, n+2) give `(a_init(k) < b' iff resp(k) < b)`, NOT `(a_init(k) < p_n iff resp(k) < e_n)`. When b > e_n or b' > p_n, these orderings are WEAKER than what tau_left provides.
  2. Restricted tau challenged with e_n_pt in Round 2: Gives `(a_init(k) < b_resp iff resp(k) < e_n)` where b_resp is Duplicator's response (some carrier point in [d, b'] with same rank-r type as p_n). But b_resp is not necessarily p_n, so this does not yield `(a_init(k) < p_n iff resp(k) < e_n)`.
  3. Using resp_tau (from tau_r on [d, y'] -> [c, y]) as a'_resp: resp_tau(k) is in [c, y], not necessarily in [c, e_n]. The biconditional `(a_init(k) < p_n iff resp_tau(k) < e_n)` is not available because p_n/e_n are interior points of tau_r's interval.
  4. Playing tau_r with n+1 selections (including p_n): Not possible because tau_r is an n-round game, limited to n selections.
  5. Connecting forward game orderings to backward game: Forward game gives orderings between a'_big(k) and p_n, but a'_big(k) != a_init(k), so these cannot be substituted.
  6. Restricted tau with b = e_n, b' = p_n: This is exactly tau_left, which is the current architecture. No simplification achieved.
- **Why it's stuck**: The Lean formalization uses a FINITE-POSITION game where `same_order_type` applies to n+3 positions. GHR93's argument assumes order-type preservation over ALL points in the interval (a continuous/dense property), which their single tau naturally provides. In the Lean formalization, orderings at specific points (p_n, e_n) require those points to be POSITIONS in the game. The only way to make p_n/e_n into positions is to make them endpoints of a sub-game -- which is exactly what tau_left/tau_right do. The supremum does not help because making b >= e_n makes the endpoints FARTHER from p_n/e_n, providing WEAKER orderings.
- **What is needed**: One of:
  (a) Reformulate `same_order_type_of_cases` to accept one-directional orderings (`resp(k) <= e_n` for all k < n) instead of biconditional orderings. This would require proving that monotone selections + monotone responses + one-directional bound implies the full biconditional.
  (b) Extend the game definition to support orderings at arbitrary interior points (not just game positions). This would be a fundamental change to CustomGame.lean.
  (c) Accept that the Lean formalization necessarily uses tau_left/tau_right to bridge the gap between finite-position games and GHR93's continuous order-type preservation. This is the current (working, sorry-free) architecture.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 12-18 hours (increased from v46's 10-15 to account for restricted tau construction)

**Depends on**: Phase 3 (CharacteristicFormula sorries closed), Phase 4 (tactic infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` -- add supremum infrastructure (~80-120 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II (delete ~500-700 lines, add ~300-500 lines; net reduction ~100-300 lines)

**Verification**:
- All grid dispatch sorries closed
- `#print axioms` on ghr93_case_II shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes
- tau_left, tau_right, resp_left, resp_mod, forward-game e_n fully deleted
- Net code reduction: target ~400-600 lines for Case II vs current ~769 lines

---

### Phase 6: Cases III/IV Gap Handling (General Linear Orders) [IN PROGRESS]

**Goal**: Implement left(B, D) and right(B, D) per GHR93 Definition 8.5 / Lemma 9, then use them to complete Cases III/IV, closing the sorry at CaseAnalysis.lean:3318. This phase targets the FULL GENERAL RESULT for arbitrary linear orders -- no vacuous discharge, no discrete-only shortcut.

**Literature to read BEFORE implementing**:
- GHR93 Definition 8.5 / GHR94 Definition 12.8.6 (left/right formulas, structural induction on A)
- GHR93 Lemma 9 / GHR94 Lemma 12.8.7 (correctness of left/right)
- GHR93 Section 8, Cases III and IV (pp.118-119)
- GHR94 Chapter 12, pp.812-850 (Cases III/IV detailed proof)
- Report 47 (X_t usage analysis): Sections 2.5-2.6 (Cases III/IV formulas), Section 4 (left/right definitions)

**The mathematical argument**:

Case III (a_n is a gap defined on the left by D of rank <= r):
1. delta_III = left_formula(B, D) where B = x_t_formula(a_n). stavi_depth(delta_III) <= max(r, r) + 2 = r+2.
2. N_r |= U(delta_III, A)(a_{n-1}): By Lemma 9, left(B,D)(t) means there exists a D-left-gap above t with B^mu true at it. a_n IS such a gap.
3. Transfer U(delta_III, A) through tau at rank r+4: stavi_depth = max(r+2, r) + 2 = r+4. EXACTLY at the ceiling.
4. Extract gap witness e_n in M via Lemma 9 correctness. e_n is a gap in M defined on the left by D with the same rank-r type as a_n.
5. Round 2: mirrors Case II structure with gap-formula-aware responses.

Case IV (a_n is a gap NOT defined on the left):
1. a_n must be definable on the right by some D of rank <= r (by GHR93's exhaustive analysis of gap types).
2. delta_IV = sf_conj(A, sf_conj(sf_neg(D), sf_untl(right_formula(B, D), A))). stavi_depth(delta_IV) must be tracked carefully -- target: stavi_depth(delta_IV) <= r+2 so that U(delta_IV, A) has stavi_depth <= r+4.
3. Transfer through tau at rank r+4: MUST verify depth fits.
4. Extract gap witness in M via right_formula correctness.
5. Round 2: similar structure to Case III.

**DEPTH ARITHMETIC WARNING**: Case IV's depth is at the absolute ceiling (r+4). Implementation MUST verify exact stavi_depth bounds at each step using lean_goal.

**Tasks**:
- [ ] Task 6.1: Create GapFormulas.lean with left_formula and right_formula (~150-200 lines)
- [ ] Task 6.2: Prove Lemma 9 correctness for left_formula (~100-150 lines)
- [ ] Task 6.3: Prove Lemma 9 correctness for right_formula (~100-150 lines)
- [ ] Task 6.4: Complete Case III implementation in CaseAnalysis.lean (~100-150 lines)
- [ ] Task 6.5: Complete Case IV implementation in CaseAnalysis.lean (~100-150 lines)
- [ ] Task 6.6: Close winning condition assembly sorry at CaseAnalysis.lean:3318 (~50-100 lines)

**Anti-deviation warnings**:
- Do NOT simplify Cases III/IV for discrete orders -- the plan targets GENERAL linear orders per user directive
- Do NOT use vacuous discharge -- Cases III/IV MUST have real proofs
- Do NOT skip Lemma 9 correctness (it bridges gap formulas to gap-existence statements)
- Do NOT assume stavi_depth(left(A,D)) = GHR93_rank(left(A,D)) -- track the +2 vs +1 distinction
- Do NOT attempt Cases III/IV without Phase 3's existence sorries being closed

**Timing**: 5-8 hours

**Depends on**: Phase 3 (CharacteristicFormula), Phase 4 (tactic infrastructure)

**Files to modify/create**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` -- NEW (~350-500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add import
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- update ghr93_cases_III_IV (~200-350 lines)

**Verification**:
- Sorry at CaseAnalysis.lean:3318 closed
- `#print axioms` on left_formula, right_formula, left_correct, right_correct shows no sorryAx (via lean_run_code)
- `#print axioms` on ghr93_cases_III_IV shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes

---

### Phase 7: Transfer.lean Rewiring and Downstream Sorry Closure [BLOCKED]

**Goal**: Wire Transfer.lean to use the game-theoretic pipeline (Theorem6 + CaseAnalysis) instead of the chronicle fallback (dd_countermodel_chronicle_discrete). This is the step that actually activates the Reynolds pipeline and eliminates succ_cofinal from the bx_completeness axiom chain. Also close any remaining mechanical sorries exposed by Phases 5-6.

**Current architecture** (what must change):
```
completeness_discrete (Completeness.lean:308)
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> dd_countermodel_chronicle_discrete  -- CHRONICLE PIPELINE (has succ_cofinal sorry)
```

**Target architecture** (after rewiring):
```
completeness_discrete (Completeness.lean:308)
  -> countermodel_discrete_enriched (Completeness.lean:222)
    -> reynolds_countermodel_discrete  -- GAME PIPELINE (sorry-free after Phases 5-6)
         -> ghr93_forward_to_backward (Theorem6.lean) -- sorry-free (Phase 1)
         -> ghr93_inductive_step (CaseAnalysis.lean) -- sorry-free (Phases 5-6)
```

**Tasks**:
- [x] Task 7.1: Analyze type-signature compatibility (~1-2 hours, no code changes) *(completed -- identified that EF-game-to-k-equiv bridge is missing infrastructure)*
- [x] Task 7.2: Add game pipeline imports to Transfer.lean (~5 lines) *(completed -- added Theorem6 and Mathlib.Data.Int.SuccPred imports)*
- [x] Task 7.3: Implement reynolds_countermodel_discrete (~50-150 lines) *(deviation: altered -- implemented discrete-specific game pipeline (no_gaps_int, ghr93_inductive_step_discrete, ghr93_forward_to_backward_discrete) instead of full countermodel rewiring. ~250 lines of sorry-free infrastructure added. Full countermodel rewiring requires backward-game-to-k-equiv bridge.)*
- [ ] Task 7.4: Rewire countermodel_discrete to use game pipeline (~20-30 lines) *(deviation: deferred -- requires backward-game-to-k-equiv bridge theorem not yet available)*
- [ ] Task 7.5: Thread h_surj if needed (~30-60 lines) *(deviation: deferred -- depends on Task 7.4)*
- [ ] Task 7.6: Close any remaining mechanical sorries (~30-50 lines) *(deviation: deferred -- depends on Task 7.4)*

**Anti-deviation warnings**:
- Do NOT modify Completeness.lean unless absolutely necessary (prefer adapter in Transfer.lean)
- Do NOT close ChronicleToCountermodel.lean sorries (succ_cofinal chain) -- the Reynolds pipeline BYPASSES these
- Do NOT close GoodStructures.lean:842 (no_gaps_discrete) -- it depends on bridge lemma, not on critical path
- Do NOT bypass Transfer.lean by modifying Completeness.lean directly
- Always verify with `#print axioms` via lean_run_code

**Timing**: 3-5 hours

**Depends on**: Phase 5 (Case II sorry-free), Phase 6 (Cases III/IV sorry-free)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` -- rewiring (~100-200 lines)
- Possibly: `DConsistencyTransport.lean`, `GapDetection.lean` (mechanical adjustments)

**Verification**:
- Transfer.lean compiles without sorry on the critical path
- `#print axioms` on countermodel_discrete shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical` passes

---

### Phase 8: Final Verification (Sorry-Free bx_completeness) [NOT STARTED]

**Goal**: Full project build, axiom audit, and verification that bx_completeness has zero sorryAx. This is the definition-of-done for task 155.

**Tasks**:
- [ ] Task 8.1: Full lake build
- [ ] Task 8.2: Axiom audit on bx_completeness and completeness_discrete
- [ ] Task 8.3: Sorry audit on critical path files
- [ ] Task 8.4: Document remaining sorries in WeakCanonical/ tree

**Timing**: 1-2 hours

**Depends on**: Phase 7

**Files to modify**: None (read-only verification), unless sorries are found

**Verification**:
- `lake build` passes
- `#print axioms bx_completeness` shows no sorryAx
- `#print axioms completeness_discrete` shows no sorryAx
- `#print axioms completeness` shows no sorryAx
- `grep -rn sorry` on critical-path files reports zero hits

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `#print axioms` (via lean_run_code, NOT lean_verify) on all key theorems after each phase
- [ ] Phase 5: ghr93_case_II zero sorryAx, net code reduction (~400-600 lines from ~769 lines)
- [ ] Phase 5: supremum infrastructure compiles without sorry
- [ ] Phase 5: restricted tau derived from fresh IH on [d, b'] -> [c, b]
- [ ] Phase 5: sel_pn_ord proved via trivial chain (resp_restricted(k) <= ref_M < z = e_n)
- [ ] Phase 5: tau_left, tau_right, resp_left, resp_mod, forward-game e_n fully deleted
- [ ] Phase 5: single restricted tau provides all 7 ordering categories
- [ ] Phase 6: ghr93_cases_III_IV zero sorryAx, gap formula proofs complete (not vacuous)
- [ ] Phase 7: countermodel_discrete zero sorryAx
- [ ] Phase 8: bx_completeness zero sorryAx, completeness_discrete zero sorryAx

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/47_path-c-supremum-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (modified, Phase 5: supremum infrastructure)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean` (modified, Phase 4: already done)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` (NEW, Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (rewritten, Phases 5-6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` (rewired, Phase 7)

## Rollback/Contingency

**If supremum existence (Task 5.0) proves infeasible**:
- Fall back to using b = y as a trivial upper bound. The restricted tau then degenerates to the original tau on [d, y'] -> [c, y], and we are back to the current architecture. No regression, but no improvement -- tau_left/tau_right remain necessary.
- This is an explicit "abort Path C, accept current proof" contingency.

**If restricted tau (Task 5.2) proves infeasible despite supremum existence**:
- The forward game from h_r1_univ may not fit the [c, b] x [d, b'] sub-interval due to type constraints.
- Fallback: apply IH directly to [c, b] x [d, b'] if the types align, or build an adapter that converts h_r1_univ's output to the required form.
- If even that fails: accept current proof as is (it is sorry-free and axiom-clean).

**If restricted tau works but Round 2 rewrite (Task 5.6) exceeds 2x estimate**:
- The 5-way case split may have unexpected edge cases in Lean formalization.
- Fallback: implement the 3-way split from the current code (A/B1/B2) using restricted tau instead of tau_left/tau_right. This still eliminates sub-games but uses the simpler case structure.

**If any phase exceeds 2x time estimate**:
- Write handoff document with current state, blockers, and recommended next steps.
- Mark phase as [PARTIAL] and return for user review.

**If Phase 6 (Cases III/IV) exceeds 2x time estimate**:
- Close Case II first (Phase 5), wire for discrete case only (Phase 7).
- Cases III/IV are vacuous on Z (no gaps), so sorry-free completeness_discrete is achievable without them.
- Defer full general linear order support to a follow-up task.
- NOTE: This contradicts the user directive for full general result. Only use as emergency fallback with user approval.

**If Phase 7 (Transfer.lean rewiring) has type-signature incompatibilities**:
- Build adapter layer (~50-100 lines) converting game pipeline output to expected form.

**Git safety**: All changes are on existing files in the WeakCanonical/ tree plus one new file (GapFormulas.lean). No destructive operations. Rollback via `git checkout` on individual files.
