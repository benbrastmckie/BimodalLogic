# Implementation Plan: Reynolds Pipeline Activation (v38 -- GHR93 Sorting + U(B,A) Witness)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phases 1-4, 3A, 6A, 6C-1/2/3 complete. Phase 3C restructured into 3C-Sort (sorting wrapper) + 3C-UBA (U(B,A) witness replacement), per GHR93 pp. 115-116 exactly.
- **Effort**: 16-32 hours remaining
- **Dependencies**: Tasks 154, 147-148, 157, 195, 168, 174, 198, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: 45 reports in `specs/155_reynolds_pipeline_activation/reports/`, including `37_sorting-approach-research.md` (new)
- **Artifacts**: plans/38_sorting-uba-plan.md (this file), plans/37_ghr93-uba-witness-plan.md (superseded)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline (Chapter 12.8). The approach follows GHR93 exactly: backward game theorem -> game composition -> temporal-FO equivalence -> classical characterization of NF existence -> gap elimination -> succ_cofinal.

**v38 correction**: Plan v37's Phase 3C was a monolithic block combining sorting, formula materialization, and U(B,A) witness construction. Research report `37_sorting-approach-research.md` clarifies the architecture: (1) sorting alone does not fix the fan problem because the current code constructs e_n from a forward game, not from U(B,A); (2) U(B,A) alone does not work because without sorted selections, the point alpha_n may not be the maximum, so U(B,A)(alpha_{n-1}) need not hold; (3) the regular tau (rank-r) suffices for U(B,A) transfer because `stavi_depth(std_untl B sf_top) <= r` from `char_k_depth` -- tau_r2/h_ih_r2 is NOT needed for this step. Phase 3C is now split into two clear sub-phases: 3C-Sort (sorting wrapper at `ghr93_inductive_step`, ~30-50 lines, low risk) and 3C-UBA (replace forward-game e_n with U(B,A) witness in `ghr93_case_II`, ~200-350 lines, medium risk).

### Research Integration

- `reports/36_char-k-threading-research.md`: Confirms no circularity in CaseAnalysis.lean -> StaviCompleteness.lean import chain. Identifies 5-function threading path for char_k parameters. Verifies all needed StaviFormula constructors are public.
- `reports/37_sorting-approach-research.md`: Confirms sorting + U(B,A) together are necessary and sufficient. Regular tau (rank-r) suffices. No changes needed to SplitPointProps, obtain_split_point_props, Theorem6.lean, or CustomGame.lean. Identifies equality case risk (Monotone gives <=, not <) and witness extraction risk (std_untl semantics in extended carrier).

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

## Sorry-Free EFGames Infrastructure

| File | Lines | Key Content | GHR93 Reference |
|------|-------|-------------|-----------------|
| Defs.lean | 559 | EF games, extended carriers M_r, `stavi_n_equiv`, `game_depth` | Defs 12.8.8, 12.8.11, 12.8.17 |
| CustomGame.lean | 1690 | G_{n,r} game, `ghr93_duplicator_wins`, `ghr93_winning_condition_perm` | Def 12.8.11 |
| Composition.lean | 626 | `ghr93_strategy_compose` -- single-pivot sub-interval composition | Prop 12.8.7 / part of 12.8.18 |
| Decomposition.lean | 315 | `ghr93_game_iff_decomposition` -- game <-> decomposition | Lemma 12.8.14 |
| TypeFormulas.lean | 1043 | `rank_type`, `interval_types`, mu-relativized truth, rank embedding | Def 12.8.13 |
| GapDetection.lean | 5057 | Gap detection for Cases III/IV, left/right formula construction | Cases III/IV infrastructure |

## Current Sorry Sites

| File | Line | Definition | Status |
|------|------|-----------|--------|
| StaviCompleteness.lean | 1873 | `nf_2var_from_interval_data` | DEAD CODE -- to be removed (Phase 6C-4) |
| StaviCompleteness.lean | 2152 | `nf_exist_sf_guarded_backward` | DEAD CODE -- to be removed (Phase 6C-4) |

The actual target: `nf_2var_existence_characterizable` (succ k' case), which the dead code was supposed to close.

## GHR93 Formalization Status

| GHR93 Result | Status | Location |
|---|---|---|
| Def 12.8.8 (EF games) | DONE | Defs.lean |
| Def 12.8.11 (G_{n,r} game) | DONE | CustomGame.lean |
| Def 12.8.13 (rank_type, interval_types) | DONE | TypeFormulas.lean |
| Lemma 12.8.14 (game <-> decomposition) | DONE | Decomposition.lean |
| Def 12.8.17 (game_depth f(n)) | DONE | Defs.lean |
| Prop 12.8.7-style (single-pivot composition) | DONE | Composition.lean |
| **Theorem 12.8.15 (backward game)** | **PARTIAL** | CaseAnalysis.lean -- sel_pn_ord + winning condition sorries |
| **Prop 12.8.9 (standard EF <-> FO)** | **NOT STARTED** | -- |
| **Prop 12.8.16 (temporal rank -> game)** | **NOT STARTED** | -- |
| **Prop 12.8.18 (full m-tuple composition)** | **NOT STARTED** | Single-pivot only |
| **Cor 12.8.19 (temporal -> FO equivalence)** | **NOT STARTED** | -- |

## Goals & Non-Goals

**Goals**:
- Close all critical-path sorry sites following GHR93 exactly
- Prove the GHR93 classical chain: Theorem 12.8.15 -> Props 12.8.16/18 -> Cor 12.8.19
- Derive `nf_2var_existence_characterizable` classically from Cor 12.8.19
- Prove `succ_cofinal` via gap elimination
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- TruthLemma.lean sorry sites (non-critical-path)
- OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- OrderIso bypass (Track A) -- proven infeasible
- Changing d from inf(S_C) to min(selections) -- would break Claim 1 infrastructure
- Single-game restructuring of Case II -- infeasible (1-round budget deficit)

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Equality case: `Tuple.monotone_sort` gives `<=` not `<`, so a_init(k) = p_n is possible | With U(B,A) construction, sel_pn_ord is eliminated entirely. The winning condition assembly handles the equality case through formula agreement: if a_init(k) = p_n, then resp_tau(k) and e_n agree on rank-r formulas (both satisfy B), and the biconditional reduces to a tautology. |
| `std_untl` witness extraction in extended carrier may involve gaps | Extract the existential witness z from `stavi_temporal_truth_mu` for `std_untl`. If z is a gap, use the fact that `std_untl B sf_top` requires B(z) -- and B = char_k(nf_pn) characterizes a point type, so z must be a point. |
| Winning condition 5-way case assembly is verbose (~100-200 lines) | Cases 1-2 (b_sp < c, c < b_sp < resp_tau(n-1)) are already handled. Case 4 (b_sp = e_n, respond with p_n) uses B-agreement directly. Cases 3 and 5 use tau's formula agreement for interval types. Follow GHR93 round-2 case analysis exactly. |
| Removing old forward-game e_n construction may break downstream code | Keep h_d_compat_left temporarily if used by hord_cd_en_pn. Remove only after confirming U(B,A) approach does not depend on it. |
| stavi_temporal_truth vs stavi_temporal_truth_mu bridge | `stavi_truth_mu_at_point` already exists in GapDetection.lean:417. No new code needed (confirmed in v37 sub-task 3C.2). |
| Breaking existing sorry-free code in Cases III/IV | Cases III/IV do not use char_k. The h_mono parameter added to ghr93_case_II is only consumed in Case II. |
| Full Prop 12.8.18 (m-tuple) significantly larger than single-pivot | Iterate single-pivot composition; Composition.lean already handles the hard case. |
| Classical characterization in 6C-4 requires connecting Cor 12.8.19 to NF types | NormalForm is Fintype; classical enumeration is well-defined. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by | Notes |
|------|--------|------------|-------|
| 1 | 1, 2, 3A, 4, 6A, 6C-1/2/3 | -- | ALL COMPLETED |
| 2 | 3C-Sort | -- | Low risk, enables 3C-UBA |
| 3 | 3C-UBA | 3C-Sort | Medium risk, eliminates fan problem |
| 4 | 3B, 5 | 3C-UBA | sel_pn_ord + b_resp from 3C-UBA |
| 5 | 6D | -- | Independent of backward game completion |
| 6 | 6E | 6D | |
| 7 | 6F | 6E | |
| 8 | 6C-4 | 6F | Classical characterization via Cor 12.8.19 |
| 9 | 6C-5 | 6C-4 | Verification |
| 10 | 7 | 6C-5 | no_gaps_discrete |
| 11 | 8 | 7 | succ_cofinal |
| 12 | 9 | 8 | Final verification |

Phases within the same wave can execute in parallel. Waves 2-4 (backward game) and Waves 5-7 (GHR93 chain) are independent parallel tracks.

---

### Phase 1: Mechanical Sorry Closure S3 + S5 [COMPLETED]

Closed S3 (`h_cont_transfer_mr`) and S5 (`h_mr_resp_ge_d` gap case) via `game_tuple` simplification and gap proof mirroring. ~345 lines added to ExpressivenessGeneral.lean (now split into Expressiveness/ submodules).

---

### Phase 2: Pigeonhole + K-(negD) Bridge [COMPLETED]

Closed S1/S2 (Claim 1 cluster) using K-(negD) bridge, complement_no_min witnesses. Also closed S4 (multi-round K-(negD)) and S7-right. Key finding: K-(negD) bridge is necessary scaffolding.

---

### Phase 3A: sel_pn_ord Sorry'd Field [COMPLETED]

Added sorry'd `have sel_pn_ord` and `pn_sel_ord` at both Case A and Case B sites in CaseAnalysis.lean. The sorry is at the usage sites -- concentrated, ready for Phase 3C closure.

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]

Added `ghr93_rank_down_proj` (233 lines) for position-tracking variant of rank_down. S6 closed directly. S7-right expanded with K-(negD) closure.

---

### Phase 6A: GHR93 Proposition 7 -- Strategy Composition [COMPLETED]

`ghr93_strategy_compose` in new Composition.lean (626 lines, sorry-free). Combines Duplicator winning strategies on sub-intervals [x,c] and [c,y] into full interval [x,y]. Includes degenerate sub-interval compatibility hypotheses.

---

### Phase 6B: EFGames-Internal Case Analysis [SUPERSEDED]

Superseded by Phase 6C formula construction approach.

---

### Phase 6C-1: k=0 Base Case [COMPLETED]

Proved `nf_2var_existence_characterizable` for k=0 (~160 lines). At depth 0, atoms+order determine the 2-var NF. Backward direction uses case analysis on AtomKind sig 2, extracting pred/order info from the Until/Since formula.

---

### Phase 6C-2: Interval Guard Formula [COMPLETED]

Defined `interval_guard_sf` (disjunction of all `char_k` formulas -- always satisfiable) and `nf_exist_sf_guarded` (replaces `sf_top` with `interval_guard_sf` in Until/Since guard). Also proved `interval_guard_sf_true`.

---

### Phase 6C-3: Forward Direction [COMPLETED]

Proved `nf_exist_sf_guarded_forward` sorry-free. Guard obligation at intermediate points discharged via `nf_characteristic_satisfies` + `char_k_correct` (IH).

---

### Phase 3C-Sort: Sorting Preprocessing Wrapper [COMPLETED]

**Goal**: Add a sorting preprocessing step at the `ghr93_inductive_step` level so that all downstream proofs (Case II, Cases III/IV) see sorted selections where a_bwd(n) is the maximum element.

**GHR93 justification (p. 115)**: GHR93 assumes WLOG that Spoiler's choices are sorted: x' < alpha_0 < ... < alpha_n < y'. The winning condition `ghr93_winning_condition` is permutation-invariant (proved as `ghr93_winning_condition_perm` in CustomGame.lean:1591), so sorting is sound.

**Tasks**:

- [x] **3C-Sort.1: Sort a_bwd at ghr93_inductive_step entry** (~15-20 lines) *(completed)*
  - **File**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`, inside `ghr93_inductive_step` proof body (line ~4378)
  - After `unfold ghr93_duplicator_wins; intro a_bwd ha_bwd`, insert:
    ```
    let sigma := Tuple.sort a_bwd
    let a_sorted : Fin (n+1) -> ExtendedCarrier N atomMap r := a_bwd ∘ sigma
    have ha_sorted : forall i, inClosedInterval x' y' (a_sorted i) :=
      fun i => ha_bwd (sigma i)
    have h_mono : Monotone a_sorted := Tuple.monotone_sort a_bwd
    ```
  - Pass `a_sorted` and `ha_sorted` to `obtain_split_point_props` and case dispatch (replacing `a_bwd` and `ha_bwd`)
  - **Infrastructure**: `Tuple.sort` from `Mathlib.Data.Fin.Tuple.Sort` (already imported in CaseAnalysis.lean), `LinearOrder (ExtendedCarrier M atomMap r)` (Defs.lean:358)

- [x] **3C-Sort.2: Transfer winning condition back to unsorted** (~10-20 lines) *(completed)*
  - After case dispatch produces `a'_resp_sorted` and a winning condition for `a_sorted`, transfer back:
    ```
    have h_unsort : a_sorted ∘ sigma.symm = a_bwd := by
      ext i; simp [a_sorted, Function.comp, Equiv.Perm.apply_symm_apply]
    ```
  - Use `ghr93_winning_condition_perm` with `sigma.symm` to transform:
    - N-side: `a_sorted ∘ sigma.symm = a_bwd` (original unsorted selections)
    - M-side: `a'_resp_sorted ∘ sigma.symm` (Duplicator's response permuted back)
  - **Infrastructure**: `ghr93_winning_condition_perm` (CustomGame.lean:1591, already proved)

- [x] **3C-Sort.3: Thread h_mono to ghr93_case_II** (~5-10 lines) *(completed)*
  - Add `(h_mono : Monotone a_bwd)` parameter to `ghr93_case_II` signature (CaseAnalysis.lean:1188)
  - Thread through `ghr93_cases_II_III_IV` (CaseAnalysis.lean:4269) -- Cases III/IV ignore it
  - Supply `h_mono` at the call site in `ghr93_inductive_step`
  - **No changes needed**: SplitPointProps, obtain_split_point_props, Theorem6.lean, CustomGame.lean

- [x] **3C-Sort.4: Build verification** -- `lake build` passes, existing sorries unchanged *(completed)*

**Timing**: 1-2 hours

**Depends on**: 3A (COMPLETED)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 3C-UBA: U(B,A) Witness Construction in ghr93_case_II [NOT STARTED]

**Goal**: Replace the forward-game e_n construction (lines ~1241-1597 of CaseAnalysis.lean) with U(B,A) witness extraction per GHR93 pp. 115-116. This eliminates sel_pn_ord, b_resp, and the fan problem entirely.

**GHR93 construction**: B = X_{alpha_n} (rank-r type formula for p_n). phi = std_untl B sf_top ("B-point above"). phi holds at a_init(n-1) in N (witnessed by p_n, since a_init(n-1) < p_n from sorting). tau transfers phi to M at resp_tau(n-1) (stavi_depth(phi) <= r, so rank-r tau suffices). Extract M-side witness z > resp_tau(n-1) with B(z). Set e_n = z. Ordering resp_tau(k) < e_n holds BY CONSTRUCTION.

**Key insight from research**: Regular tau (rank-r) suffices because `stavi_depth(std_untl B sf_top) = stavi_depth(char_k nf) + 2 <= r` from `char_k_depth`. No need for tau_r2 or h_ih_r2 for this specific transfer.

**Tasks**:

- [ ] **3C-UBA.1: Materialize B = char_k(nf_type(p_n))** (~40-60 lines)
  - **File**: CaseAnalysis.lean, inside `ghr93_case_II` proof body
  - Given p_n from `h_point`, determine nf_pn via `nf_exists_unique` on the extended carrier
  - Construct B := char_k nf_pn (using the threaded char_k parameter from sub-task 3C.1, already completed in v37)
  - Prove: `stavi_temporal_truth_mu N atomMap r (extendPoint p_n) B` (from `char_k_correct` + NF evaluation at p_n)
  - Prove: `stavi_depth B <= r - 2` (from `char_k_depth` properties)
  - **Infrastructure**: `char_k` already threaded through the 5-function call chain (completed in v37 sub-task 3C.1), `stavi_truth_mu_at_point` exists (GapDetection.lean:417, verified in v37 sub-task 3C.2)

- [ ] **3C-UBA.2: Construct phi = std_untl B sf_top and prove truth in N** (~40-60 lines)
  - Define `phi := StaviFormula.std_untl B (.base Formula.top)`
  - Prove `stavi_depth phi <= r` (from `stavi_depth B <= r - 2`, since `stavi_depth(std_untl B sf_top) = stavi_depth B + 2`)
  - Prove phi holds at a_init(k) for all k < n where a_init(k) < p_n:
    - p_n is a carrier point (IsPoint) satisfying B by construction
    - a_init(k) < extendPoint p_n (from h_mono, since k < n and a_sorted(n) = extendPoint p_n)
    - sf_top guard trivially satisfied at all intermediate points
    - Therefore N |= std_untl B sf_top at a_init(k) at rank r
  - Specifically prove for k = n-1: phi holds at a_init(n-1)
  - Handle equality case: if a_init(k) = extendPoint p_n, the U(B,A) construction sidesteps this entirely -- we only need phi at a_init(n-1), and monotonicity gives a_init(n-1) <= p_n

- [ ] **3C-UBA.3: Transfer phi via tau to M-side** (~30-40 lines)
  - tau from `props.tau` gives `ghr93_duplicator_wins N M atomMap n r d y' c y`
  - tau's formula agreement preserves rank-r formulas
  - `stavi_depth phi <= r`, so transfer is valid at rank r
  - Instantiate tau with N-selections including a_init(n-1)
  - Get M-responses including resp_tau(n-1) in M_r
  - Conclude: M |= std_untl B sf_top at resp_tau(n-1) at rank r
  - **Key**: This uses the REGULAR tau, not tau_r2. The h_ih_r2 infrastructure from v37 is not needed for this step.

- [ ] **3C-UBA.4: Extract witness z and define e_n** (~30-50 lines)
  - Unfold `stavi_temporal_truth_mu` for `std_untl` at resp_tau(n-1)
  - Extract existential witness z: exists z > resp_tau(n-1) with B(z) in M_r
  - Verify z is a point (not a gap): B = char_k(nf_pn) characterizes a point's NF type, so B(z) implies z is a point or has point-like properties
  - If z is in the extended carrier, project to a point if needed
  - Define e_n := z (or extendPoint z if projection needed)
  - Prove: e_n > resp_tau(n-1)
  - Prove: B(e_n) -- e_n satisfies the same rank-r formulas as p_n

- [ ] **3C-UBA.5: Delete old forward-game e_n construction** (~negative 300-400 lines)
  - Remove lines ~1241-1597: the `a_M`, `a_pad_big`, `h_d_compat_left` forward-game infrastructure for constructing e_n
  - Keep any code that is still needed for other purposes (check downstream references before deleting)
  - If `h_d_compat_left` is needed for `hord_cd_en_pn`, reprove from the new e_n construction

- [ ] **3C-UBA.6: Rebuild winning condition assembly** (~100-200 lines)
  - The round-2 case analysis follows GHR93 exactly (5 cases for Spoiler's b_sp):
    1. **b_sp < c**: Use sigma's strategy (forward game on [x',d])
    2. **c <= b_sp <= resp_tau(n-1)**: Use tau's strategy (backward game on [d,y'] / [c,y])
    3. **resp_tau(n-1) < b_sp < e_n**: Interval type matching via tau's rank-r formula agreement
    4. **b_sp = e_n**: Respond with p_n (B-agreement: both e_n and p_n satisfy B = char_k(nf_pn))
    5. **b_sp > e_n**: Continuation formula C-agreement
  - Cases 1-2 reuse existing infrastructure
  - Case 4 is direct from B-agreement (~10-20 lines)
  - Cases 3 and 5 require showing interval type agreement between M-side and N-side sub-intervals

- [ ] **3C-UBA.7: Close sel_pn_ord and pn_sel_ord sorry sites** (~20-40 lines)
  - With the new e_n from U(B,A), sel_pn_ord becomes trivially true:
    - For all k < n: a_init(k) < extendPoint p_n (from h_mono + sorting)
    - For all k < n: resp_tau(k) < e_n (from tau ordering + e_n > resp_tau(n-1) >= resp_tau(k))
    - The biconditional `a_init(k) < p_n <-> resp_tau(k) < e_n` reduces to True <-> True
  - Close sorry at Case A site (~line 1585 in current code)
  - Close sorry at Case B site (~line 1965 in current code)
  - For pn_sel_ord (= direction): similarly trivial since both sides are False (a_init(k) < p_n strictly, so a_init(k) != p_n)

- [ ] **3C-UBA.8: Close b_resp sorry sites** (~40-60 lines)
  - Close b_resp sorry at Case B (~line 2180)
  - Close b_resp sorry at Case B (~line 2233)
  - These depend on e_n properties established in 3C-UBA.4 and the winning condition assembly from 3C-UBA.6

- [ ] **3C-UBA.9: Build verification** -- `lake build` passes with strictly fewer sorries

**Timing**: 6-12 hours

**Depends on**: 3C-Sort

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 3B: Structured Proof Tactic Overhaul [IN PROGRESS -- 2 goals deferred to 3C-UBA]

**Goal**: Close remaining Case B grid dispatch goals using ordering proofs from Phase 3C-UBA.

**Status**:
- [x] Case A (S8): Sorry-free, all ~25 grid goals close
- [x] Case B impossible-direction goals (3 of 6): Closed by task 199
- [x] Case B Goal 3 sel(i) vs p_n (both variants): Closed via rename_i + hab_eq + sel_pn_ord
- [ ] Case B Goals 1-2: b_resp vs p_n (deferred to Phase 3C-UBA -- same fan problem root cause)
- [ ] Remove dead code after Phase 3C-UBA resolves remaining goals

**Timing**: 1-2 hours after Phase 3C-UBA

**Depends on**: 3C-UBA

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 5: Cases III/IV Winning Condition Assembly [PARTIAL]

**Goal**: Close S11 winning condition assembly in Cases III/IV.

**Status**:
- [x] S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`): Closed via parameter approach
- [x] Gap detection infrastructure: Complete (left/right formula, gap_detection_unique)
- [x] Interval bounds (lines ~3328, ~3639): Closed (degenerate boundary + non-degenerate contradiction)
- [ ] Winning condition assembly (line ~4100): ~200 lines, needs sel_pn_ord from Phase 3C-UBA

**Timing**: 2-4 hours after Phase 3C-UBA

**Depends on**: 3C-UBA (sel_pn_ord for grid dispatch)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean`

---

### Phase 6D: Proposition 12.8.16 -- Temporal Type -> Game Strategy [NOT STARTED]

**Goal**: If x in M and y in N satisfy the same temporal formulas of rank r+4n+1, then Duplicator has winning strategies for G_{n,r}(M, -inf x; N, -inf y) and G_{n,r}(M, x inf; N, y inf).

**Tasks**:
- [ ] State proposition using `stavi_n_equiv`, `rank_type`, `ghr93_duplicator_wins`
- [ ] Prove base case n=0 (trivial)
- [ ] Prove inductive step: construct response using formula C_0 from GHR93 proof sketch
- [ ] Handle gap case (r-definable gaps as endpoints)
- [ ] Run `lake build`

**Timing**: 2-4 hours

**Depends on**: none (uses only sorry-free EFGames infrastructure)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend StaviCompleteness.lean)

---

### Phase 6E: Full Proposition 12.8.18 -- m-Tuple Game Composition [NOT STARTED]

**Goal**: Extend single-pivot `ghr93_strategy_compose` to full m-tuple composition: given winning strategies on all sub-intervals, compose into a winning strategy for G^{n+1}((M, x_bar), (N, y_bar)).

**Tasks**:
- [ ] State full m-tuple composition using EF game types
- [ ] Define partition of Spoiler's choice into sub-intervals
- [ ] Apply single-pivot composition iteratively (induction on m)
- [ ] Prove cross-sub-interval order preservation
- [ ] Connect to `ef_duplicator_wins`
- [ ] Run `lake build`

**Timing**: 3-6 hours

**Depends on**: 6D

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/Composition.lean`

---

### Phase 6F: Corollary 12.8.19 -- Temporal -> FO Equivalence [NOT STARTED]

**Goal**: If x in M and y in N satisfy the same temporal formulas of rank g(n+1)+1, then for all monadic FO formulas phi of QD <= n, M |= phi(x) iff N |= phi(y).

**Tasks**:
- [ ] Prove or import Prop 12.8.9 (standard EF <-> FO agreement)
- [ ] Combine 12.8.9 + 12.8.16 (Phase 6D) + 12.8.18 (Phase 6E) into Cor 12.8.19
- [ ] State in terms of `stavi_n_equiv` and `nf_eval_nf` for StaviCompleteness integration
- [ ] Run `lake build`

**Timing**: 2-4 hours

**Depends on**: 6E

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/` (new file or extend existing)

---

### Phase 6C-4: Classical Characterization via Cor 12.8.19 [BLOCKED on 6F]

**Goal**: Close `nf_2var_existence_characterizable` (succ k' case) using the GHR93 classical argument. Remove dead code from the failed Approach A (interval guard bridge).

**Dead code to remove** (~150 lines):
- `interval_nf_types` (line 1835)
- `nf_2var_from_interval_data` (line 1853, sorry'd bridge lemma)
- `nf_2var_transfer` (line 1877)
- `nf_exist_sf_guarded_backward` (line 2125, sorry'd)
- `nf_2var_exist_sf_classical` (line 2157)

**Keep**: `interval_guard_sf`, `interval_guard_sf_true`, `nf_exist_sf_guarded`, `nf_exist_sf_guarded_forward`

**Classical argument**:
P(t) = "exists x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) sub_nf" is a monadic FO property of QD <= k+1. By Cor 12.8.19 (Phase 6F), P is determined by the temporal type at rank g(k+2)+1. The characterizing StaviFormula is the disjunction of NF types consistent with P.

**Tasks**:
- [ ] Remove dead code listed above
- [ ] Implement classical characterization using Cor 12.8.19
- [ ] Close `nf_2var_existence_characterizable` sorry
- [ ] Run `lake build`

**Timing**: 2-4 hours

**Depends on**: 6F (Corollary 12.8.19)

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

---

### Phase 6C-5: Verify EFGames Build [NOT STARTED]

**Tasks**:
- [ ] `#print axioms nf_characterizable_by_stavi` -- no `sorryAx`
- [ ] `#print axioms stavi_expressive_completeness` -- no `sorryAx`
- [ ] Verify zero sorry warnings in EFGames/
- [ ] `lake build` passes

**Timing**: 0.5 hours

**Depends on**: 6C-4

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in GoodStructures.lean:842). The integer model has no gaps because every NF is characterizable by a StaviFormula (Phase 6C), and StaviFormulas are determined by their truth at integer points.

**Tasks**:
- [ ] Read current state of `no_gaps_discrete`
- [ ] Implement gap elimination argument
- [ ] `#print axioms no_gaps_discrete` -- no `sorryAx`
- [ ] `lake build` passes

**Timing**: 2-4 hours

**Depends on**: 6C-5

**Files**: `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean`

---

### Phase 8: Close succ_cofinal via Gap Elimination [NOT STARTED]

**Goal**: Prove `succ_cofinal` (ChronicleToCountermodel.lean:1885). Also close sub-proof sorries at lines 1285, 1441, 1508.

**Tasks**:
- [ ] Close sub-proof sorry at line 1285 (boundary case)
- [ ] Close sub-proof sorry at line 1441 (below-min case)
- [ ] Close sorry at line 1508 (`limit_dom_points_are_succ_iterates`)
- [ ] Wire `no_gaps_discrete` to prove `IsSuccArchimedean` for `LimitDomSubtype`
- [ ] `#print axioms dd_countermodel_chronicle_discrete` -- no `sorryAx`
- [ ] `lake build` passes

**Timing**: 2-4 hours

**Depends on**: 7

**Files**: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`

---

### Phase 9: Final Verification [NOT STARTED]

**Tasks**:
- [ ] `#print axioms bx_completeness` -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Verify `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)
- [ ] `lake build` -- zero errors

**Timing**: 0.5 hours

**Depends on**: 8

---

## Superseded Approaches

The following 28 approaches have been tried and ruled out. Do NOT re-attempt.

| # | Approach | Where Tried | Why It Failed |
|---|----------|-------------|---------------|
| 1 | **Track A: OrderIso bypass** | Phase A1 (v28) | `chronicle_is_good` requires `ChronicleAsPriorModel` which fills `domain_succ_archimedean := limitDomSubtype_isSuccArchimedean` using `succ_cofinal`. Every path from Burgess chronicle to countermodel on Int goes through `IsSuccArchimedean`. No bypass exists. |
| 2 | **Approach A: Fintype StaviFormula enumeration** | Phase B2 (v28) | `StaviFormula` has `Formula` atoms (infinite type). `Fintype { A : StaviFormula // stavi_depth A <= r }` is not constructible. |
| 3 | **Approach B: NormalForm -> StaviFormula inversion** | reports 38-39 | CIRCULAR: converting NF back to StaviFormula IS the expressive completeness theorem being proved. |
| 4 | **h_d_unique (uniqueness from rank-r type)** | Lines 2755-2859 | MATHEMATICALLY FALSE: K-(negD) has depth r+2, two points can share rank-r type but differ at r+2. |
| 5 | **h_fwd_n1_d at (n+1) rounds** | Phase 3 sessions | game_tuple dite reduction blocked by Fin arithmetic. The (1+3n+1)-round d-compat approach avoids this entirely. |
| 6 | **d = a_bwd(n) with rank-(r+1)** | Several sessions | d_consistency literally false when d is not d-bar. |
| 7 | **Gap equivalence lemma** | report 37 | FALSE in general: adjacent points and gaps disagree on atoms. |
| 8 | **pivot_chain_order without c <= e_n** | Multiple sessions | Requires c <= e_n as input, which is exactly what needs proving. |
| 9 | **Deriving sel-vs-p_n ordering from existing games** | Phase 3 impl v2 | 5 approaches tried, all fail. Fork geometry, not chain. Counterexample: d=0, b_en=1, p_n=2, y'=3. |
| 10 | **Extract sel_pn_ord from hord_big directly** | Approach A | a'_big(k) != a_init(k); same-side-of-d != same-side-of-p_n. |
| 11 | **sel_pn_ord as SplitPointProps field** | Approach B | p_n only defined inside ghr93_case_II, not at construction time. |
| 12 | **Play tau with e_n, pivot through b_tau_en** | Approach D | Fan problem: d <= a_init(k) and d <= b_tau_en gives no chain. |
| 13 | **Restructure big game N-side** | Approach C | Forward game has M selecting -- cannot force N-side = a_init. |
| 14 | **same_order_type_grid with convert/congr** | Phase 3 (5 variants) | Anonymous hypotheses from split_ifs prevent targeted Fin rewrites. |
| 15 | **Unified forward game (Approach E)** | Phase 3A + report 34 | Game play produces new N-side responses != a_init. Counterexample blocks all 6 sub-approaches. |
| 16 | **Two-phase tau construction** | report 34 | Produces b_fwd != e_n and a'_fwd(k) != a_init(k). |
| 17 | **fan_order abstract lemma** | Task 199 | PROVABLY FALSE: counterexample p=0, a=1, b=2, q=0, a'=2, b'=1. |
| 18 | **grid_order_tac macro** | Task 199 | Blocked by fan_order invalidity. |
| 19 | **Sorting + Lemma 10 alone** | Report 41 | Sorting resolves N-side only. M-side fan persists. |
| 20 | **Changing d from inf(S_C)** | Report 41 | Breaks continuation set + Claim 1 infrastructure. |
| 21 | **Direct formula without nf_characterizable_by_stavi** | Report 42b | Building interval type formulas AS StaviFormulas IS nf_characterizable_by_stavi. No shortcut. |
| 22 | **Single-game architecture for Case II** | Report 42c | All 6 variants infeasible. 1-round budget deficit is structural. |
| 23 | **nf_exist_sf backward with sf_top (k>0)** | Phase 6C | sf_top allows any intermediate type. 2-var NF at k>0 needs 3-var realizability info. |
| 24 | **"Good NF" disjunction** | Phase 6C | P has QD k+1, char_k gives only depth-k. Two depth-k-equivalent points can disagree on P. |
| 25 | **NF finiteness + definability** | Phase 6C | CIRCULAR: showing P is NF-invariant IS expressive completeness. |
| 26 | **Reduction to stavi_expressive_completeness** | Phase 6C | CIRCULAR: stavi_expressive_completeness depends on nf_characterizable_by_stavi at depth k+1. |
| 27 | **Interval guard bridge lemma** | Phase 6C-4 (4 cycles) | `nf_2var_from_interval_data` needs outside-interval hypotheses (`h_above_max`, `h_below_min`) that CANNOT be extracted from Until/Since. Structurally unusable for k>=1. |
| 28 | **Phase 3C depending on Phase 6C** | Plan v35 | Circular: 6C needs 12.8.15, which needs 3C, which needed 6C. Fix: U(B,A) uses char_k IH. |

## Settled Questions

- **Infimum redefinition IS necessary** (reports 29, 35). Do not revisit.
- **Track A (OrderIso bypass) is NOT FEASIBLE**. Do not revisit.
- **Fintype enumeration BLOCKED** by infinite atoms. Do not revisit.
- **Fan ordering is provably false** (task 199 counterexample). Do NOT attempt abstract fan_order lemmas.
- **The M-side fan problem persists even with sorting** (report 41). Only U(B,A) transfer resolves it.
- **d must remain inf(S_C)** (report 41 Section 7). Fix targets e_n construction, not d.
- **Proposition 7 (composition) is required** (report 38). Now complete in Composition.lean.
- **No circular dependency EFGames/ <-> Expressiveness/** (report 42a). Unidirectional: Expressiveness -> EFGames.
- **Formula materialization IS nf_characterizable_by_stavi** (report 42b). No shortcut.
- **Single-game architecture INFEASIBLE** (report 42c). 1-round budget deficit is structural.
- **U(B,A) has depth r+2, tau preserves <= r** (report 42b). Use h_ih_r2 for rank r+2 backward game.
- **sf_top guard insufficient for backward direction** (reports 36, 37, 43). Do NOT attempt sf_top-based backward proofs.
- **Approaches 23-26 all circular or insufficient** (report 36). Do NOT re-attempt.
- **Outside-interval issue makes Approach A structurally unusable for k>=1**. Not a difficulty issue -- structural impossibility.
- **char_k (IH) suffices for U(B,A) materialization**. Game rank r <= f(k), char_k covers this. Breaks circular dependency.
- **GHR93's backward game (12.8.15) is self-contained**. Does not depend on NF characterization.
- **Correct resolution: Corollary 12.8.19**. Classical disjunction of temporal types consistent with the property.
- **No circularity from CaseAnalysis.lean importing StaviCompleteness.lean** (report 36). Import DAG is unidirectional.
- **All needed StaviFormula constructors are public** (report 36). No need to make private definitions public.
- **same_side lemma is unprovable** (28 approaches tried). U(B,A) witness construction eliminates the need entirely.
- **Sorting ALONE does not fix the problem** (report 37). Current code constructs e_n from forward game, not U(B,A). Both sorting AND U(B,A) are required.
- **Regular tau (rank-r) suffices for U(B,A) transfer** (report 37). stavi_depth(std_untl B sf_top) <= r from char_k_depth. No need for tau_r2.
- **No changes needed to SplitPointProps, obtain_split_point_props, Theorem6.lean, or CustomGame.lean** (report 37).

## Testing & Validation

- [ ] Phase 3C-Sort: a_bwd sorted at ghr93_inductive_step entry, h_mono threaded to ghr93_case_II
- [ ] Phase 3C-UBA: e_n constructed from U(B,A) transfer, sel_pn_ord + b_resp sorries closed
- [ ] Phase 3B: Case B grid dispatch complete
- [ ] Phase 5: S11 winning condition closed
- [ ] Phase 6D: Prop 12.8.16 sorry-free
- [ ] Phase 6E: Full Prop 12.8.18 sorry-free
- [ ] Phase 6F: Cor 12.8.19 sorry-free
- [ ] Phase 6C-4: `nf_2var_existence_characterizable` sorry closed, dead code removed
- [ ] Phase 6C-5: `#print axioms nf_characterizable_by_stavi` -- no `sorryAx`
- [ ] Phase 7: `#print axioms no_gaps_discrete` -- no `sorryAx`
- [ ] Phase 8: `succ_cofinal` sorry closed
- [ ] Phase 9: `#print axioms bx_completeness` -- only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `EFGames/Composition.lean` -- ghr93_strategy_compose (Phase 6A, COMPLETED)
- `EFGames/StaviCompleteness.lean` -- NF characterization (Phases 6C-1/2/3 COMPLETED, 6C-4/5 pending)
- `EFGames/` -- new files for Props 12.8.16/18, Cor 12.8.19 (Phases 6D/6E/6F)
- `Expressiveness/CaseAnalysis.lean` -- Phases 3C-Sort, 3C-UBA, 3B, 5
- `Expressiveness/Theorem6.lean` -- Phase 3C (char_k threading, COMPLETED)
- `IntegerModel/GoodStructures.lean` -- Phase 7
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- Phase 8

## Rollback/Contingency

**Phase 3C-Sort**: If `Tuple.sort` API is incompatible with `ExtendedCarrier`'s LinearOrder instance, implement a manual sort via `Fin.sort` or a custom insertion sort on the tuple. The permutation invariance (`ghr93_winning_condition_perm`) is already proved and does not depend on the sorting mechanism.

**Phase 3C-UBA**: If `std_untl` witness extraction is blocked by extended carrier complexity, consider: (a) working with a specialized `until_witness` lemma that directly extracts the point from `stavi_temporal_truth_mu`; (b) temporarily keeping the old forward-game e_n for Cases III/IV while proving Case II with U(B,A).

**Phases 6D/6E/6F**: If full GHR93 chain too complex, consider axiomatizing Cor 12.8.19 with clear documentation. All S1-S12 closures remain valuable regardless.

**Phase 8**: If succ_cofinal blocked, recommend Task 129 (Henkin canonical model) as alternative path.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
