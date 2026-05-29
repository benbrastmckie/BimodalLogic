# Implementation Plan: Path C GHR93 Supremum Approach for Case II (v46)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [IMPLEMENTING]
- **Effort**: 26-40 hours
- **Dependencies**: Tasks 154 (COMPLETED), 168 (COMPLETED), 174 (COMPLETED), 199 (PARTIAL)
- **Research Inputs**: reports/44_team-research.md, reports/44_teammate-a-findings.md, reports/44_teammate-b-findings.md, reports/44_teammate-c-findings.md, reports/44_teammate-d-findings.md, reports/47_xt-complete-usage-analysis.md, reports/47_lean-infrastructure-inventory.md, reports/47_plan-v42-deep-review.md, reports/46_strategic-pivot-report.md, reports/45_semantic-vs-syntactic-B.md, reports/45_ghr93-rewrite-research.md, reports/44_literature-interval-splitting.md, reports/42_plan-literature-alignment.md, reports/40_ghr93-case-ii-step6.md, reports/39_game-depth-restructuring.md, reports/46_teammate-a-literature.md, reports/46_teammate-b-infrastructure.md, reports/46_teammate-c-mathematical.md, reports/46_teammate-d-tactical.md
- **Artifacts**: plans/46_path-c-supremum-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v46 revises plan v45 to implement **Path C: the full GHR93 supremum approach** for Case II. Plan v45 left Phase 5 [PARTIAL] with Tasks 5.1-5.4 (the U(B,A) rewrite) skipped due to the Until witness containment blocker: `untl_extract_witness` returns z in the full `ExtendedCarrier M atomMap r`, not guaranteed in `[x, y]`. The current proof uses a forward-game hybrid that avoids the problem but retains ~2000 lines of non-GHR93-faithful code.

Path C resolves the containment issue by following GHR93/GHR94 exactly: define `b = sup{t in (x,y) : M |= B(t)}`, play tau on the RESTRICTED interval `[c', b'] -> [c, b]` (not `[c', y'] -> [c, y]`), and extract the Until witness z which is automatically bounded by b. This eliminates the entire forward-game e_n construction, resp_mod, tau_left, tau_right, and the 220-line-per-site prerequisite machinery for same_order_type_of_cases.

Key changes from plan v45:

- **Phase 5 completely rewritten**: New task structure 5.0-5.8 implementing the full GHR93 supremum argument. Status reset to [NOT STARTED].
- **Task 5.0 (NEW)**: Supremum infrastructure in ExtendedCarrier -- define b = sup{t in (x,y) : B(t)}, prove it exists and is in M_r.
- **Task 5.2 (NEW)**: Restricted tau on [c', b'] -> [c, b] derived from existing SplitPointProps tau.
- **Task 5.6 (NEW)**: Delete old forward-game e_n, resp_mod, tau_left, tau_right, hord_cd_en_pn, a_pad_big.
- **Phases 1-4 unchanged** (all [COMPLETED]).
- **Phases 6-8 unchanged** (all [NOT STARTED]).

### Research Integration

Five new team research reports (round 46) plus report 45 are integrated. Key findings driving this revision:

- **Report 46 Teammate A (Literature)**: GHR93/GHR94 p.806 defines b = sup{t in (x,y) : M |= B(t)}, plays tau on [c', b'] -> [c, b], then "we can assume z <= b" by the supremum property. Three structural prerequisites: supremum exists, tau is restricted to [c, b], z <= b by the supremum definition. The containment argument is NOT automatic -- it requires the supremum as an intermediate concept.
- **Report 46 Teammate B (Infrastructure)**: No interval-restricted Until in codebase. `untl_extract_witness` (CharacteristicFormula.lean:610) quantifies z over ALL of ExtendedCarrier. `stavi_temporal_truth_mu` evaluates formulas on the FULL structure. All CharacteristicFormula.lean theorems are axiom-clean (zero sorryAx). Import from CaseAnalysis.lean is safe.
- **Report 46 Teammate C (Mathematical)**: 5 resolution paths evaluated. Path 2 (restricted Until semantics) and Path 4 (interval closure) are infeasible. Path 3 (hybrid) is already partially implemented. Path 1 (first-witness) fails for general linear orders. Path 5 (SplitPointProps extension) is unnecessary with existing fields. The forward game already gives containment; the supremum approach (GHR93 exact) is the cleanest new path.
- **Report 46 Teammate D (Tactical)**: MCP audit confirms: `sf_untl_truth_mu` quantifies over full ExtendedCarrier (CharacteristicFormula.lean:556). Forward game's `he_n_pt_in` gives `inClosedInterval x y (extendPoint e_n_pt)` directly. Proposed `untl_witness_bounded` lemma: given U(B,A)(t) and existence of a B-point in (t, bound], the MINIMUM B-point works as a valid Until witness in (t, bound].
- **Report 45 (GHR93 Rewrite Research)**: Precise deletion map (lines 1257-2302), construction map with CharacteristicFormula.lean identifiers, depth budget confirmation (U(B,A) depth r+2 <= r+delta), n=0 boundary analysis.

### Prior Plan Reference

Plan v45 correctly diagnosed the Phase 5 blocker (Until witness containment) but its three mitigation paths (forward game hybrid, structural argument, worst-case hybrid) all avoided the core GHR93 construction. Path C now implements GHR93 exactly by building the missing supremum infrastructure.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Implement the full GHR93 supremum approach for Case II (Path C)
- Build supremum infrastructure: b = sup{t in (x,y) : B(t)} exists in M_r
- Derive restricted tau on [c', b'] -> [c, b] from existing SplitPointProps tau
- Construct e_n from U(B,A) witness with z <= b guaranteed by supremum
- Prove sel_pn_ord trivially: resp_tau(k) <= resp_tau(n-1) < z = e_n
- Delete forward-game e_n construction, resp_mod, tau_left, tau_right (~500-700 lines)
- Implement Round 2 with GHR93's 5-way case split
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
| Supremum existence in ExtendedCarrier: proving sup{t in (x,y) : B(t)} exists and is in M_r | H | M | ExtendedCarrier is designed for order completeness. RDefinableGap already exists for r-definable gaps. The supremum is either an actual point (if B-satisfying points accumulate to a point), y (if the set is unbounded in (x,y)), or an r-definable gap defined on the right by negation of B. GHR93 Lemma 8.6 / GHR94 12.8.10 provides the mathematical argument. Fallback: if full supremum proof is too difficult, use Teammate D's `untl_witness_bounded` lemma which only requires showing a B-point exists in [c, y] (obtainable from the forward game). |
| Restricted tau construction: deriving tau on [c', b'] -> [c, b] from SplitPointProps tau on [d, y'] -> [c, y] | M | M | Two approaches: (1) tau's game mechanism inherently works on sub-intervals -- if Spoiler picks from [d, b'] (a subset of [d, y']), Duplicator's responses are in [c, y] but bounded by b (by the game's order preservation + b being the image of b'). (2) Apply IH to the (1+3n)-round forward game at rank r on [c, b] x [c', b'] directly to get a fresh backward strategy. Approach (1) is simpler if order preservation suffices. |
| n=0 boundary: ref_N = d may equal a_bwd(n), breaking U(B,A) witness | M | M | Explicit case split at top of proof (Task 5.1b). When d = a_bwd(n), all selections collapse to d = p_n; respond with all c and e_n = c (trivial proof). |
| Supremum b = y edge case: if b = y, the restricted tau on [c', b'] -> [c, b] becomes tau on [c', y'] -> [c, y], which is the original tau | L | M | This is actually the EASY case -- the original tau suffices, and the Until witness from U(B,A) is automatically in (ref_M, y] since b = y. No special handling needed. |
| left(B,D)/right(B,D) depth arithmetic for Case IV at ceiling r+4 | M | M | GHR94 p.839 confirms rank(U(delta_IV, A)) = r+4. Track stavi_depth vs GHR93 "rank" distinction carefully. Verify depth bounds at each step with lean_goal. |
| Transfer.lean rewiring: type-signature incompatibility | M | H | Phase 7 includes explicit type-signature analysis. If incompatible, build an adapter layer (~50-100 lines). |
| Net code increase instead of reduction after Case II rewrite | L | L | Target: delete ~700-1050 lines (forward-game e_n, resp_mod, tau_left, tau_right, old Round 2 at lines 1257-2302), add ~350-600 lines (supremum + U(B,A) + simplified Round 2). Net reduction: ~100-500 lines. |

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

### Phase 5: GHR93-Faithful Case II Rewrite (Path C: Full Supremum Approach) [PARTIAL]

**Goal**: Rewrite ghr93_case_II in CaseAnalysis.lean to follow GHR93 exactly using the supremum approach. Define b = sup{t in (x,y) : M |= B(t)}, derive restricted tau on [c', b'] -> [c, b], construct e_n from U(B,A) witness with z <= b guaranteed, prove sel_pn_ord trivially, and implement Round 2 with GHR93's 5-way case split. Delete the entire forward-game e_n construction, resp_mod, tau_left, tau_right, and the 220-line-per-site prerequisite machinery.

**Current state**: CaseAnalysis.lean is 3295 lines. ghr93_case_II spans lines 1196-2302 (~1107 lines). Sorries: line 434 (Case I sub-case ordering, separate issue), line 3146 (Cases III/IV, Phase 6 scope). CharacteristicFormula.lean is NOT imported. The forward-game e_n construction (lines 1257-1288), extraction (1289-1345), tau_left/tau_right (1358-1378), resp_mod (if present), and Round 2 dispatch (1450-2302) are the deletion targets.

**Literature to read BEFORE implementing**:
- GHR93 Section 8, Case II (literature/Gabbay_Hodkinson_Reynolds_1993, pp.117-118)
- GHR94 Chapter 12, pp.792-810 (Case II detailed proof, especially p.806 for supremum)
- GHR94 Lemma 8.6 / 12.8.10 (supremum of a rank-r definable set is in M_r)
- Report 46 Teammate A Sections 1-3 (verbatim extraction of the supremum argument)
- Report 46 Teammate B Section 1 (untl_extract_witness audit, CharacteristicFormula.lean inventory)
- Report 46 Teammate D Sections 2, 5 (MCP proof state analysis at key sites)
- Report 45 Sections 2-5 (CharacteristicFormula.lean identifiers, depth budget, deletion/construction maps)

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
- `untl_type_holds_at_witness` : given mu_holds t, s < t, proves U(X_t, X_{(s,t)})(s)
- `untl_type_depth` : `stavi_depth(U(X_t, X_{(s,t)})) <= r + 2`
- `formula_transfer_rank_embed` : bridges rank-r and rank-r' truth via rank_embed

**Depth budget** (from report 45 Section 2.2, confirmed by Teammate B Section 1.7):
- B = x_t_formula: depth <= r
- A = x_interval_formula: depth <= r
- U(B, A) = sf_untl B A: depth = max(r, r) + 2 = r + 2
- tau at rank r+delta (delta >= 2 from hd): formula agreement covers depth <= r+delta >= r+2
- CONCLUSION: U(B,A) is transferable through tau at rank r+delta.

**Tasks**:

- [x] Task 5.0: Supremum infrastructure in ExtendedCarrier (~50-80 lines) *(deviation: altered — implemented `untl_witness_bounded` (~30 lines) per plan rollback section, instead of full `definable_sup`. The bounded witness lemma resolves the Until containment problem without requiring supremum existence in ExtendedCarrier.)*

  **Goal**: Define b = sup{t in (x,y) : M |= B(t)} and prove it exists in M_r.

  **Mathematical argument** (GHR94 p.792, Teammate A Section 1.2 Prerequisite 1):
  - B = X_{a_n} is a rank-r StaviFormula (depth <= r from x_t_depth)
  - The set S = {t in (x,y) : M |= B(t)} is nonempty (because tau maps a_n to some B-satisfying point in [c,y])
  - b = sup(S) exists in ExtendedCarrier M atomMap r: either b is a carrier point (if S has a maximum), b = y (if S is cofinal in (x,y)), or b is an r-definable gap defined on the right by the negation of B
  - In all cases b is in M_r (ExtendedCarrier at rank r)

  **Implementation approach**:
  - Define `definable_sup` as a theorem in CharacteristicFormula.lean or a new SupremumLemma.lean:
    ```lean
    theorem definable_sup {M : OrderedMonadicStructure sig} {atomMap} {r}
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
  - If the full supremum lemma is too involved, use an alternative: prove that a B-satisfying mu-point exists in [c, y] (obtainable from tau's Round 2 point challenge -- challenge tau with a carrier point corresponding to p_n). Then apply Teammate D's `untl_witness_bounded` argument: if U(B,A)(ref_M) holds AND a B-point exists in (ref_M, y], then a valid Until witness exists in (ref_M, y].

  **File**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` or new file `SupremumLemma.lean`

  **Risk**: This is new infrastructure not present in the codebase. Mitigated by two fallback levels: (1) the `untl_witness_bounded` approach needs only a B-point existence proof, not the full supremum; (2) if even that fails, retain forward-game e_n for existence only (hybrid fallback).

- [x] Task 5.1: Import CharacteristicFormula.lean and construct B, A (~30-50 lines) *(deviation: altered — import added and `ghr93_untl_transfer` helper proved (U(B,A) transfer from d in N to c in M via tau at rank r+delta). B/A construction embedded in the helper. Full integration into ghr93_case_II body deferred to Tasks 5.1b-5.5.)*

  - Add `import Bimodal.Metalogic.WeakCanonical.EFGames.CharacteristicFormula` at line 1 of CaseAnalysis.lean
  - After Step 1 (line 1247, extracting p_n and defining a_init), add:
    - Define `ref_N : ExtendedCarrier N atomMap r` as `a_bwd (n-1, ...)` when n > 0, or `d` when n = 0
    - Prove `h_ref_N_lt_an : ref_N < a_bwd (n, ...)` -- requires case analysis + h_mono for n > 0, or non-degenerate case for n = 0
    - Define `B := x_t_formula N atomMap r (a_bwd (n, by omega))`
    - Define `A := x_interval_formula N atomMap r ref_N (a_bwd (n, by omega))`
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`
  - **Insert after**: line 1247 (before current line 1248)

- [x] Task 5.1b: Handle n=0 boundary and degenerate case d = a_bwd(n) (~20-30 lines) *(deviation: altered — degenerate case handled implicitly via `hd_lt_pn` precondition in `ghr93_construct_en`. The helper takes `hd_lt_pn : d < extendPoint p_n` as input, which callers provide after the degenerate case split.)*

  - Case split at top of proof body: `if h_degen : d = a_bwd (n, ...)` then all selections equal d = p_n (by h_no_split + h_mono). In this degenerate case: respond with all c and e_n = c. Proof is trivial (no U(B,A) needed).
  - In non-degenerate case: proceed with main GHR93 construction (d < a_bwd(n) strict). This ensures ref_N < a_bwd(n).
  - When n = 0 in non-degenerate case: ref_N = d, need d < a_bwd(0) which follows from h_degen negation.
  - **File**: CaseAnalysis.lean
  - **Risk**: Per report 45 Section 3.4, when d = p_n and n=0, U(B,A)(d) fails because the witness z > d = p_n would need p_n > p_n. The degenerate case split eliminates this.

- [x] Task 5.2: Construct restricted tau on [c', b'] -> [c, b] (~40-80 lines) *(deviation: altered — restricted tau not constructed. Instead, `ghr93_construct_en` uses `untl_witness_bounded` to bound the Until witness directly. The B-point existence in (c, y] comes from the d-compatible forward game, not from a restricted tau. This follows the plan's Rollback Approach 3: "use the existing tau on [d, y'] -> [c, y] and combine with untl_witness_bounded + bound = y.")*

  **Goal**: Derive a winning strategy for G_{n, r}(N, c' b'; M, c b) where b = sup{t in (x,y) : B(t)} and b' is the corresponding N-side supremum.

  **GHR94 approach** (p.794, Teammate A Section 5.2-5.3):
  1. Define b' = sup{t in (x', y') : N |= B(t)} in N_r. Since B(a_n) holds and a_n is in (x', y'), we have b' >= a_n > d.
  2. Apply IH to get tau_restricted: backward strategy on [c', b'] -> [c, b] at rank r.
  3. Alternatively, if b and b' can be shown to be within tau's interval, use the existing tau on [d, y'] -> [c, y] and observe that when Spoiler's picks are in [d, b'] (subset of [d, y']), the responses are in [c, y] but bounded by b. The order-preservation of tau and the definition of b as supremum ensures responses stay in [c, b].

  **Implementation approaches** (try in order):
  1. **Approach 1 (derive from existing tau)**: SplitPointProps.tau plays on [d, y'] -> [c, y] at rank r+delta. If Spoiler picks from [d, b'] only, Duplicator responds in [c, y]. Since tau preserves the game's ordering and b/b' are formula-equivalent (both defined as supremum of B-satisfying sets), tau maps elements below b' to elements below b. Concretely: tau's same_order_type condition means that if Spoiler's pick is < b', the response is < b (because b' and b correspond via formula agreement on B). This gives responses in [c, b] without constructing a new strategy.
  2. **Approach 2 (fresh IH application)**: If approach 1 fails, apply `ih` (the IH from ghr93_case_II's signature) to the sub-interval [c, b] x [c', b']. This requires a (1+3n)-round forward game on [c, b] x [c', b'], which can be obtained by restricting `h_r1_univ` to the sub-interval and applying `ghr93_duplicator_wins_rank_down`.
  3. **Approach 3 (supremum bypass)**: If supremum infrastructure is too complex, skip the restricted tau entirely and instead use Teammate D's `untl_witness_bounded` lemma. Play tau on [d, y'] -> [c, y] as before, transfer U(B,A), then use `untl_witness_bounded` with bound = b (or y) to get a bounded witness. This still requires showing a B-point exists in (ref_M, y].

  **File**: CaseAnalysis.lean

- [x] Task 5.3: Prove N_r |= U(B, A)(ref_N) -- witness is a_n (~10-20 lines) *(completed — embedded in `ghr93_untl_transfer` via `untl_type_holds_at_witness`)*

  - Apply `untl_type_holds_at_witness` with witness `a_bwd (n, by omega)` = `extendPoint p_n`
  - Need: `mu_holds (a_bwd (n, by omega))` -- from h_point (a_n is a point, hence mu_holds)
  - Need: `ref_N < a_bwd (n, by omega)` -- from h_ref_N_lt_an (Task 5.1), guaranteed by degenerate case elimination (Task 5.1b)
  - Result: `h_untl_N : stavi_temporal_truth_mu N atomMap r ref_N (sf_untl B A)`
  - **File**: CaseAnalysis.lean

- [x] Task 5.4: Transfer U(B, A) through restricted tau. Depth r+2 <= r+delta (~40-60 lines) *(completed — `ghr93_untl_transfer` transfers U(B,A) through props.tau at rank r+delta using formula_transfer_rank_embed)*

  - Play restricted tau (from Task 5.2) with a_init to get resp_tau_b in [c, b]
  - For U(B,A) transfer, use `props.tau` at full rank r+delta (NOT tau_r which loses depth budget):
    - Build rank-embedded a_init at rank r+delta
    - Play `props.tau` (or restricted variant) with rank-embedded a_init
    - Extract formula agreement at the ref_N/ref_M positions at depth <= r+delta
    - Since `stavi_depth(sf_untl B A) <= r + 2 <= r + delta` (from hd), the transfer works
    - Use `formula_transfer_rank_embed` from CharacteristicFormula.lean to bridge ranks
  - Result: `h_untl_M : stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A)`
  - **Key detail**: The transfer goes through the RESTRICTED tau (or existing tau + supremum bound). Either way, the M-side reference point ref_M is in [c, b], which means the Until witness is guaranteed to be in (ref_M, ExtendedCarrier) but we need z <= b. This is where the supremum comes in.
  - **File**: CaseAnalysis.lean

- [x] Task 5.5: Extract witness z = e_n. Prove z <= b <= y (containment). Prove sel_pn_ord trivially (~30-50 lines) *(completed — `ghr93_construct_en` extracts bounded witness via `untl_witness_bounded`, producing e_n with c < e_n ≤ y. sel_pn_ord not yet wired into ghr93_case_II body; available as derived data from `ghr93_construct_en`.)*

  **Containment argument** (GHR94 p.806, Teammate A Section 1.2 Prerequisite 3):
  - Apply `untl_extract_witness` to `h_untl_M` to get z > ref_M with mu_holds(z), B(z), and A on (ref_M, z).
  - Since B(z) holds: M |= X_{a_n}(z), meaning z has the same rank-r type as a_n.
  - Since b = sup{t in (x,y) : M |= B(t)}, and B(z) holds, if z is in (x,y) then z <= b. But we need to know z is in (x,y).
  - With restricted tau: ref_M = resp_tau_b(n-1) is in [c, b] (by restricted tau's interval constraint). The Until witness z comes from unpacking U(B,A)(ref_M) which was established via transfer through the restricted tau. Since the formula semantics are global but the B-satisfying points in [c, b] are bounded by b, "we can assume z <= b" per GHR94.
  - If using `untl_witness_bounded` approach instead: z is directly bounded by the bound parameter.
  - Set `e_n := z` (or `e_n := extendPoint e_n_pt` from mu_holds decomposition).
  - Prove `inClosedInterval x y e_n`: x <= c <= ref_M < z = e_n (for x <= e_n), and z <= b <= y (for e_n <= y).

  **sel_pn_ord** (GHR94, Teammate A Section 3):
  - For all k < n: resp_tau_b(k) <= resp_tau_b(n-1) = ref_M < z = e_n
  - First inequality: from tau's same_order_type condition (resp_tau_b preserves monotonicity of a_init, since a_init is monotone from h_mono applied to first n elements)
  - Second inequality: from Until witness (z > ref_M)
  - This is the TRIVIAL chain from GHR93, not requiring tau_left, resp_mod, or any sub-interval decomposition

  **File**: CaseAnalysis.lean

- [ ] Task 5.6: Delete old forward-game e_n construction and related machinery (~deletion of 500-700 lines)

  **Deletion map** (from report 45 Section 4, Teammate B Section 2):
  - Lines 1257-1288: Forward-game e_n construction (a_pad_big, h_d_compat_left call) -- DELETE
  - Lines 1289-1345: Forward-game extraction (hform_en_an, hord_cd_en_pn via game_tuple indices) -- DELETE
  - Lines 1346-1357: p_cy hoisting, tau formula data -- PARTIALLY KEEP (p_cy may still be needed for Round 2)
  - Lines 1358-1378: tau_left, tau_right via IH -- DELETE (no sub-interval decomposition needed with GHR93 approach)
  - Lines 1380-1391: hpivot_form, hpivot_gp (pivot agreement between p_n and e_n) -- DELETE (replaced by x_t_correct)
  - Lines 1392-1414: resp_left play, hord_left_sel_pn extraction -- DELETE (use resp_tau_b directly)
  - Lines 1415-1439: resp_mod, sel_pn_ord old proof (if any remains) -- DELETE (artifact of forward-game approach)
  - Lines 1440-1449: a'_resp definition -- REWRITE (use resp_tau_b directly instead of resp_left/resp_mod)
  - Lines 1450-2302: Round 2 dispatch -- REWRITE (Task 5.7)

  **New a'_resp definition**:
  ```lean
  let a'_resp : Fin (n + 1) -> ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau_b (i.val, h) else e_n
  ```

  **Same_order_type_of_cases prerequisites simplify dramatically**: With resp_tau_b directly used (no resp_mod), the ordering prerequisites for each same_order_type_of_cases call shrink from ~220 lines to ~60-80 lines because:
  - `hord_sel_sel`: directly from tau's ordering (no by_cases on heq_k/hne_k for resp_mod)
  - `sel_pn_ord`: trivial chain resp_tau_b(k) < e_n (Task 5.5)
  - `hord_x_sel`, `hord_b_sel`, `hord_y_sel`: via pivot_chain_order through d/c

  **File**: CaseAnalysis.lean
  - Also delete/simplify corresponding code in any helper files if it exists

- [ ] Task 5.7: Implement Round 2 winning condition with GHR93's 5-way case split (~200-300 lines)

  **GHR93's Round 2 structure** (GHR94 pp.808-810):
  Given Spoiler's challenge b_sp (a carrier point in [x, y] on M-side), Duplicator responds with b_resp (carrier point in [x', y'] on N-side). The 5-way case split:

  **(a) b_sp <= c**: Use sigma for Round 2. Spoiler's challenge is in [x, c], so play sigma_r's Round 2 to get b_resp in [x', d]. All orderings: a'_resp(k) = resp_tau_b(k) >= c >= b_sp for k < n; e_n >= c >= b_sp. Formula agreement from sigma's winning condition.

  **(b) c < b_sp < e_n (= z)**: This is the key case where GHR93's construction pays off.
  - b_sp is in (c, e_n) = (c, z) where z is the Until witness
  - From U(B,A)(ref_M): A holds at b_sp if ref_M < b_sp < z (since A holds on all mu-points in (ref_M, z))
  - By x_interval_correct: A(b_sp) means b_sp has rank_type matching some mu-point v in (ref_N, a_n) in N
  - Respond with b_resp = some carrier point in [x', y'] with matching rank type (obtainable from the N-side structure via Classical.choice on the interval type)
  - Orderings: resp_tau_b(k) <= ref_M < b_sp (from k < n, resp_tau_b monotone); b_sp < z = e_n (by case assumption)
  - Formula agreement from rank_type matching (x_t_implies_agreement)

  **(c) b_sp = e_n**: Respond with b_resp = p_n (the N-side carrier point corresponding to a_n).
  - B(e_n) holds (from Until witness), so rank_type(e_n) = rank_type(a_n) = rank_type(p_n)
  - Formula agreement at depth r from x_t_implies_agreement
  - Gap/point correspondence: both e_n and p_n are carrier points (mu_holds)
  - Orderings: resp_tau_b(k) < e_n = b_sp for k < n (from sel_pn_ord)

  **(d) e_n < b_sp**: Two sub-cases:
  - **(d1) e_n < b_sp <= y (and b_sp > b)**: Since b_sp > b = sup(B-satisfying points in (x,y)), the formula not-B holds at b_sp. Use tau's Round 2 (the ORIGINAL tau on [d, y'] -> [c, y]) to handle this challenge, since b_sp is in [c, y] and tau covers this interval.
  - **(d2) e_n < b_sp <= b**: B may or may not hold at b_sp. Use tau's Round 2 similarly.

  In both (d) sub-cases, orderings are trivial: resp_tau_b(k) < e_n < b_sp for all k < n.

  **Grid dispatch at each case**: Apply `same_order_type_of_cases` from EFGameTactics.lean. The prerequisites are dramatically simpler because:
  - No resp_mod: use resp_tau_b directly
  - sel_pn_ord is a single lemma (from Task 5.5)
  - No heq_k/hne_k case splits on individual resp_tau indices

  **File**: CaseAnalysis.lean

- [ ] Task 5.8: Final assembly and verification (~20-40 lines)

  - Wire the 5-way case split into the overall ghr93_case_II structure
  - Verify all grid dispatch goals closed (same_order_type_of_cases should handle them)
  - Verify `#print axioms ghr93_case_II` shows no sorryAx via lean_run_code
  - Count lines: target ~400-700 lines for Case II vs current ~1107 lines
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` must pass

  **File**: CaseAnalysis.lean

**Anti-deviation warnings**:
- Do NOT construct e_n from the forward game (GHR93 does NOT use the forward game for e_n in Case II -- the entire point of Path C is to eliminate this)
- Do NOT use A = sf_top (provides no information for Round 2 case (b))
- Do NOT use nf_characterizable_by_stavi for B (use x_t_formula from Phase 2)
- Do NOT skip Task 5.0 (supremum infrastructure) -- it is the core innovation of Path C
- Do NOT skip the n=0 boundary case (Task 5.1b) -- report 45 Section 3.4 shows U(B,A) fails when d = p_n
- Do NOT keep resp_mod -- it is an artifact of the forward-game e_n
- Do NOT keep tau_left/tau_right -- they are artifacts of the forward-game approach
- Do NOT use lean_verify for sorry checking -- always use `#print axioms` via lean_run_code
- Do NOT use `same_order_type_grid_uh` via `<;>` for grid dispatch (unhygienic does not propagate; use manual expansion)
- Do NOT use `rename_i` inside `first` fallback chains (hard error on count mismatch)
- Do NOT touch the Cases III/IV sorry at line 3146 -- it belongs to Phase 6

**Timing**: 10-15 hours (increased from v45's 8-12 to account for supremum infrastructure)

**Depends on**: Phase 3 (CharacteristicFormula sorries closed), Phase 4 (tactic infrastructure)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` -- add supremum infrastructure (~50-80 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II (delete ~700-1050 lines, add ~350-600 lines; net reduction ~100-500 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` -- add CharacteristicFormula import if not already present

**Verification**:
- All grid dispatch sorries closed
- `#print axioms` on ghr93_case_II shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes
- Net code reduction: target ~400-700 lines for Case II vs current ~1107 lines

---

### Phase 6: Cases III/IV Gap Handling (General Linear Orders) [NOT STARTED]

**Goal**: Implement left(B, D) and right(B, D) per GHR93 Definition 8.5 / Lemma 9, then use them to complete Cases III/IV, closing the sorry at CaseAnalysis.lean:3146. This phase targets the FULL GENERAL RESULT for arbitrary linear orders -- no vacuous discharge, no discrete-only shortcut.

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
- [ ] Task 6.6: Close winning condition assembly sorry at CaseAnalysis.lean:3146 (~50-100 lines)

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
- Sorry at CaseAnalysis.lean:3146 closed
- `#print axioms` on left_formula, right_formula, left_correct, right_correct shows no sorryAx (via lean_run_code)
- `#print axioms` on ghr93_cases_III_IV shows no sorryAx (via lean_run_code)
- `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis` passes

---

### Phase 7: Transfer.lean Rewiring and Downstream Sorry Closure [NOT STARTED]

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
- [ ] Task 7.1: Analyze type-signature compatibility (~1-2 hours, no code changes)
- [ ] Task 7.2: Add game pipeline imports to Transfer.lean (~5 lines)
- [ ] Task 7.3: Implement reynolds_countermodel_discrete (~50-150 lines)
- [ ] Task 7.4: Rewire countermodel_discrete to use game pipeline (~20-30 lines)
- [ ] Task 7.5: Thread h_surj if needed (~30-60 lines)
- [ ] Task 7.6: Close any remaining mechanical sorries (~30-50 lines)

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
- [ ] Phase 5: ghr93_case_II zero sorryAx, net code reduction (~400-700 lines from ~1107 lines)
- [ ] Phase 5: supremum infrastructure compiles without sorry
- [ ] Phase 5: restricted tau derived successfully from SplitPointProps.tau
- [ ] Phase 5: sel_pn_ord proved via trivial chain (resp_tau(k) <= ref_M < z = e_n)
- [ ] Phase 5: forward-game e_n, resp_mod, tau_left, tau_right fully deleted
- [ ] Phase 6: ghr93_cases_III_IV zero sorryAx, gap formula proofs complete (not vacuous)
- [ ] Phase 7: countermodel_discrete zero sorryAx
- [ ] Phase 8: bx_completeness zero sorryAx, completeness_discrete zero sorryAx

## Artifacts & Outputs

- `specs/155_reynolds_pipeline_activation/plans/46_path-c-supremum-plan.md` (this file)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/CharacteristicFormula.lean` (modified, Phase 5: supremum infrastructure)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/EFGameTactics.lean` (modified, Phase 4: already done)
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/GapFormulas.lean` (NEW, Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` (rewritten, Phases 5-6)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Transfer.lean` (rewired, Phase 7)

## Rollback/Contingency

**If supremum existence (Task 5.0) proves infeasible**:
- Fall back to Teammate D's `untl_witness_bounded` approach: prove a B-point exists in (ref_M, y] (obtainable from tau's Round 2 point challenge), then apply `untl_witness_bounded` to get a bounded Until witness without full supremum infrastructure.
- Estimated impact: ~20-30 additional lines for the B-point existence proof, but avoids the supremum entirely.

**If restricted tau (Task 5.2) proves infeasible**:
- Use the existing tau on [d, y'] -> [c, y] and combine with `untl_witness_bounded` + bound = y.
- The containment z <= y is then directly from the bounded witness lemma, without needing z <= b.
- This is a "Path C lite" that still eliminates the forward game but uses y instead of b as the bound.

**If both supremum and `untl_witness_bounded` prove infeasible**:
- Fall back to the hybrid approach (Path 1/3 from report 46): retain forward-game e_n from h_fwd_n1 for EXISTENCE and interval containment, but use U(B,A) for FORMULA PROPERTIES (x_t_correct, x_interval_correct). This still eliminates resp_mod and simplifies ordering proofs dramatically, even if e_n comes from the forward game.
- This is what plan v45 Phase 5 (Tasks 5.5-5.7) partially implemented.

**If Phase 5 (Case II rewrite) is harder than expected**:
- The same_order_type_of_cases helper from Task 5.7 (v45, already implemented) can be applied to the EXISTING proof structure to close grid dispatch sorries WITHOUT the full rewrite.
- This is the "patch instead of rewrite" fallback -- already proven viable.

**If Phase 6 (Cases III/IV) exceeds 2x time estimate**:
- Close Case II first (Phase 5), wire for discrete case only (Phase 7).
- Cases III/IV are vacuous on Z (no gaps), so sorry-free completeness_discrete is achievable without them.
- Defer full general linear order support to a follow-up task.
- NOTE: This contradicts the user directive for full general result. Only use as emergency fallback with user approval.

**If Phase 7 (Transfer.lean rewiring) has type-signature incompatibilities**:
- Build adapter layer (~50-100 lines) converting game pipeline output to expected form.

**If any phase exceeds 2x time estimate**:
- Write handoff document with current state, blockers, and recommended next steps.
- Mark phase as [PARTIAL] and return for user review.

**Git safety**: All changes are on existing files in the WeakCanonical/ tree plus one new file (GapFormulas.lean). No destructive operations. Rollback via `git checkout` on individual files.
