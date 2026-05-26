# Implementation Plan: Reynolds Pipeline Activation (v33 revised)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [PARTIAL] -- Phase 3 blocked (sel-vs-p_n ordering gap + tactic structural issue), requires restructure
- **Effort**: 14-26 hours remaining (Phases 1-4 complete, Phase 3 blocked, Phases 5-9 pending)
- **Dependencies**: Task 154 (COMPLETED), Tasks 147-148 (COMPLETED), Task 157 (COMPLETED), Task 195 (COMPLETED), Task 168 (COMPLETED), Task 174 (COMPLETED), Task 198 (COMPLETED)
- **Research Inputs**: reports/28_team-research.md, reports/29_literature-alignment.md, reports/30_critical-path-wiring.md, reports/30_forward-inventory.md, reports/35_phase1-blocker-prior-art.md, reports/40_literature-crossref.md, reports/30_mechanical-strategy.md, reports/30_session-audit.md, reports/29_d-consistency-architecture.md, reports/30_blocker-study-prior-art.md, reports/32_post-dependency-assessment.md, reports/33_lit-sel-pn-ordering.md, reports/33_infra-sel-pn-fix.md, reports/33_tactic-sel-pn-grid.md
- **Artifacts**: plans/33_reynolds-pipeline-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan targets sorry-free `bx_completeness` via the GHR93 expressive completeness pipeline. Phases 1-4 are complete, closing 9 sorry sites and establishing key infrastructure: K-(negD) bridge (Phase 2), d-compatible forward game with `h_d_compat_left` (Phase 3 breakthrough), and position-tracking `ghr93_rank_down_proj` (Phase 4).

Phase 3 is blocked by two compounding issues discovered through three focused research reports:

1. **Structural gap (sel-vs-p_n ordering)**: The ordering `(a_init k < extendPoint p_n <-> resp_tau k < e_n)` cannot be derived from existing sub-games because `a_init(k)` and `extendPoint p_n` are in a FAN configuration (both >= d) rather than a CHAIN. In GHR93 this ordering is trivially true because both sequences are strictly ordered by construction, but the formalization's separate game construction severs this connection. Five explicit approaches were tried and proven infeasible (Approaches A-D in the infrastructure report, plus Superseded Approach #9).

2. **Tactic gap (anonymous hypotheses)**: The `same_order_type_grid <;> first | ... | sorry` pattern generates inaccessible hypothesis names (`h_dagger`, `h_dagger1`, etc.) from `split_ifs`, preventing targeted rewrites for the Fin index mismatches. This compounds the structural gap by making even provable goals unreachable.

The revised Phase 3 addresses both issues through a two-sub-phase approach: (3A) restructure `ghr93_case_II` to use a unified forward game providing all pairwise orderings, and (3B) replace the grid tactic pattern with structured focused proofs using named hypotheses.

Seven live sorry sites remain on the critical path across 5 files: CaseAnalysis.lean (3), Theorem6.lean (1), StaviCompleteness.lean (1), GoodStructures.lean (1), ChronicleToCountermodel.lean (1+3 sub-proofs). Phase 9 (Completeness.lean wiring) is resolved by task 198 and reduced to a verification step.

**Definition of done**: `#print axioms bx_completeness` shows no `sorryAx`, `lake build` passes.

### Research Integration

Fourteen research reports and a blocker study were integrated into this plan:

| Report | Key Finding | Impact on Plan |
|--------|-------------|----------------|
| 28_team-research (5 teammates) | Formula C circularity narrower than claimed; case-split viable | Drives Approach C selection |
| 29_literature-alignment | Approach A non-circular but blocked; Approach C pragmatic | Confirms case-split path |
| 30_critical-path-wiring | EFGames sorries ORPHANED from bx_completeness | Removed Track A |
| 30_forward-inventory | 14 sorry sites on GHR93 critical path | Phase effort estimates |
| 35_phase1-blocker-prior-art | Full pipeline 40-60 hours remaining | Effort calibration |
| 40_literature-crossref | 28 total sorries mapped to GHR93 steps | Sorry-to-phase mapping |
| 30_mechanical-strategy | K-(negD) adaptation for multi-round games | Phase 1 strategy |
| 30_session-audit | 2,978 net new lines; build passes | Stable baseline |
| 29_d-consistency-architecture | d_consistency with d=a_bwd(n) UNPROVABLE | Historical context |
| 30_blocker-study-prior-art | 12 remaining sorries; d-compat breakthrough; parameter approach for S12 | Phase 3 residual scoping, Phase 5 approach change, effort recalibration |
| 32_post-dependency-assessment | File split complete (task 174), Phase 9 sorries resolved (task 198), Fin blocker unchanged | v32 revision: Updated file paths, Phase 9 reduced to verification |
| **33_lit-sel-pn-ordering** | **GHR93 sel-vs-p_n is trivially True<->True from strict ordering; formalization diverges by using separate forward game for e_n** | **This revision**: Confirms unified game approach needed |
| **33_infra-sel-pn-fix** | **Fan configuration (d below both a_init(k) and p_n) makes pivot chain impossible; Approaches A-D fail; Approach E (unified game) recommended** | **This revision**: Phase 3A restructure design |
| **33_tactic-sel-pn-grid** | **Only 2 live sorry sites; anonymous hypothesis problem from split_ifs; structured proof with named hypotheses is the solution** | **This revision**: Phase 3B tactic overhaul design |

### Revision History

**v28 original**: Two-track plan (Track A: OrderIso bypass, Track B: GHR93 pipeline).

**v28 revised**: Single-track (GHR93 only). Track A removed. Phases renumbered 1-9.

**v31 revised**: Post-implementation update incorporating blocker study findings. Changes:
- Phases 1-4 marked [COMPLETED] with implementation summaries
- Phase 3 revised: d-compat approach replaces U(B,A) transfer; 3 residual sorry sites scoped with exact goals and patterns
- Phase 5 revised: S12 uses parameter approach (pass IH game) instead of full Lemma 10
- Phase 9 updated: 4 Completeness.lean sorry sites identified (lines 226, 256, 281, 290)
- Effort estimates recalibrated from blocker study
- Superseded Approaches expanded to 8 entries from blocker study Appendix B

**v31 paused (2026-05-25)**: Phase 3 partially closed (3 of 6 Case A goals closed, Case B not attempted). Task paused for file splitting.

**v32 revised (2026-05-26)**: Post-dependency-task update incorporating results from tasks 168, 174, 195, 198. Changes:
- All file paths updated from `ExpressivenessGeneral.lean` to split successors under `Expressiveness/`, `EFGames/`, `IntegerModel/`
- Phase 9 reduced from 4 sorry closures to verification-only (task 198 eliminated all Completeness.lean sorry sites)
- Phase 3 effort estimate reduced (compile cycles now under 1 minute vs 3-5 minutes)
- Total effort recalibrated from 15-30 hours to 12-24 hours
- Sorry count reduced from 12 to 8 critical-path sites (4 resolved by task 198)
- Added `succ_cofinal` sub-proof sorry sites (lines 1285, 1441, 1508) to Phase 8 inventory

**v32 updated (2026-05-26)**: Phase 3 [BLOCKED] after implementation attempt exhausted 5 approaches for sel-vs-p_n ordering.

**v33 revised (2026-05-26)**: Post-research revision incorporating three targeted reports (literature, infrastructure, tactic). Changes:
- Phase 3 split into 3A (unified game restructure) and 3B (tactic overhaul) based on root cause analysis
- Approach E (unified forward game) adopted as the structural fix -- all pairwise orderings come from one game's `same_order_type`
- Structured focused proofs with named hypotheses replace `same_order_type_grid <;> first | ... | sorry` pattern
- Superseded Approaches expanded to 14 entries (5 new from infrastructure report)
- Effort recalibrated upward slightly (2-4h -> 4-6h for Phase 3) due to restructure scope
- Added concrete Lean code sketches for both 3A and 3B

## Goals & Non-Goals

**Goals**:
- Close all 7 remaining critical-path sorry sites (+ 3 sub-proofs in ChronicleToCountermodel)
- Prove `succ_cofinal` via gap elimination using `nf_characterizable_by_stavi` + `no_gaps_discrete`
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Closing TruthLemma.lean sorry sites (non-critical-path)
- Closing OrderedSum.lean sorry site (dense case only)
- Dense or mixed completeness variants
- Archiving BXCanonical dead-code sorries
- Building rank_lift infrastructure
- OrderIso bypass (Track A) -- proven infeasible
- Approach A (Fintype enumeration for StaviFormula) -- blocked by infinite atoms
- Restructuring e_n construction to U(B,A) transfer -- infeasible in current architecture (report 22, Section 5.1.1)

## Superseded Approaches

The following approaches have been tried and ruled out across 15+ sessions. Do NOT re-attempt these.

| # | Approach | Where Tried | Why It Failed |
|---|----------|-------------|---------------|
| 1 | **Track A: OrderIso bypass** | Phase A1 (v28) | `chronicle_is_good` requires `ChronicleAsPriorModel` which fills `domain_succ_archimedean := limitDomSubtype_isSuccArchimedean` using `succ_cofinal`. Every path from Burgess chronicle to countermodel on Int goes through `IsSuccArchimedean`. No bypass exists. |
| 2 | **Approach A: Fintype StaviFormula enumeration** | Phase B2 (v28) | `StaviFormula` has `Formula` atoms (infinite type). `Fintype { A : StaviFormula // stavi_depth A <= r }` is not constructible. |
| 3 | **Approach B: NormalForm -> StaviFormula inversion** | reports 38-39 | CIRCULAR: converting NF back to StaviFormula IS the expressive completeness theorem being proved. |
| 4 | **h_d_unique (uniqueness from rank-r type)** | Lines 2755-2859 | MATHEMATICALLY FALSE: K-(negD) has depth r+2, two points can share rank-r type but differ at r+2. |
| 5 | **h_fwd_n1_d at (n+1) rounds** | Phase 3 sessions | game_tuple dite reduction blocked by Fin arithmetic. The (1+3n+1)-round d-compat approach avoids this entirely. |
| 6 | **d = a_bwd(n) with rank-(r+1)** | Several sessions | d_consistency literally false when d is not d-bar. |
| 7 | **Gap equivalence lemma** | report 37 | FALSE in general: adjacent points and gaps disagree on atoms. |
| 8 | **pivot_chain_order without c <= e_n** | Multiple sessions | Requires c <= e_n as input, which is exactly what needs proving. Resolved by d-compat forward game providing `hc_le_en`. |
| 9 | **Deriving sel-vs-p_n ordering from existing games** | Phase 3 impl v2 (2026-05-26) | 5 approaches tried: (a) pivot_chain_order through d/c -- fork geometry, not chain; (b) extract from hord_big -- gives a'_big positions, not a_init; (c) instantiate tau with e_n_pt -- gives b_en != p_n; (d) prove b_en = p_n from ordering equivalences -- impossible when both strictly between d and y'; (e) fork ordering from common bounds -- mathematically impossible on general linear orders (counterexample: d=0, b_en=1, p_n=2, y'=3). |
| 10 | **Extract sel_pn_ord from hord_big directly** | 33_infra-sel-pn-fix (Approach A) | a'_big(k) from the big game is NOT a_init(k); same-side-of-d does NOT imply same-side-of-p_n (counterexample in Section 2.2). |
| 11 | **Add sel_pn_ord as SplitPointProps field** | 33_infra-sel-pn-fix (Approach B) | p_n is only defined inside ghr93_case_II (from h_point hypothesis), not at SplitPointProps construction time. The mathematical gap persists at the population site. |
| 12 | **Play tau with e_n and pivot through b_tau_en** | 33_infra-sel-pn-fix (Approach D) | Fan problem persists: d <= a_init(k) and d <= b_tau_en, but no chain exists between a_init(k) and b_tau_en. Pivot_chain_order' requires a CHAIN, not a fan. |
| 13 | **Restructure big game N-side to force a'_big(k) = a_init(k)** | 33_infra-sel-pn-fix (Approach C) | d-compatible forward game has M selecting, N responding -- cannot force N-side response to equal a_init(k). Using h_fwd_n1 with resp_tau as M-side selections gives NEW N-side points, not a_init. |
| 14 | **same_order_type_grid <;> first | ... | sorry with convert/congr** | Phase 3 impl (5 variants) | Anonymous hypotheses from split_ifs prevent targeted Fin rewrites. change, convert...using, rw, pre-derived helpers, show...from all fail on inaccessible variables. |

**Key settled questions**:
- Infimum redefinition IS necessary (reports 29, 35). Do not revisit.
- Track A (OrderIso bypass) is NOT FEASIBLE. Do not revisit.
- Approach A (Fintype enumeration) is BLOCKED by infinite atoms. Do not revisit.
- D-compatible forward game is the correct approach for cross-boundary orderings. Do not regress to h_fwd_n1 or h_fwd_n1_d.
- Sel-vs-p_n ordering CANNOT be derived from existing separate games. The fan configuration (d below both a_init(k) and p_n) makes pivot_chain_order' inapplicable. A unified game that includes all positions simultaneously is required.
- The `same_order_type_grid <;> first | ... | sorry` pattern is structurally inadequate for goals requiring named hypotheses. Structured focused proofs with bullet notation are the correct replacement.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Unified game response ordering differs from resp_tau ordering | H | M | Play h_fwd_n1 with carefully padded M-side selections; verify game_tuple indices match. Fallback: prove order-equivalence between unified and tau responses. |
| Structured proof verbosity exceeds expectations (>300 lines per case) | M | M | Start with Case A (fewer goals); reuse exact terms from existing `first` chain where they work; factor shared tactic sequences into local `have` lemmas. |
| Unified game's h_fwd_n1 doesn't provide enough rounds | M | L | h_fwd_n1 is (n+1)-round; need n+1 positions (n selections + 1 p_n). Should be sufficient. If not, use h_d_compat_left's (1+3n+1) rounds with modified padding. |
| S11 gap detection assembly has unexpected mathematical gap | H | M | left/right_formula_gap_detection proved sorry-free; risk is in assembly only |
| S12 parameter approach requires deep IH structure changes | M | M | IH already universally quantifies over intervals; should be straightforward |
| S13 inductive step requires infrastructure beyond Phases 3-5 | H | H | Defer to Phase 6; all prior phases provide infrastructure. If blocked, document what remains. |
| Build regression after wiring changes | M | L | Run `lake build` after every phase; commit working states |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4 | -- (COMPLETED) |
| 2 | 3A | 2 (COMPLETED) |
| 3 | 3B | 3A |
| 4 | 5 | 3B, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 8 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Mechanical Sorry Closure S3 + S5 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Closed S3 (line 4412, `h_cont_transfer_mr`) and S5 (line 4468, `h_mr_resp_ge_d` gap case). S3 used `game_tuple` simplification with `show k=n_sel+j` pattern (~90 lines). S5 mirrored existing gap proof using `ha'_mr_in` bound (~255 lines). Build passes; sorry count reduced by 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now split into `Expressiveness/` submodules by task 174)

---

### Phase 2: Pigeonhole + K-(negD) Bridge (S1/S2 Claim 1 Resolution) [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Closed S1 and S2 (the Claim 1 sorry cluster) using K-(negD) bridge. S1 (boundary case): K-(negD_M) pigeonhole argument (+200 lines). S2 (gap case): gap_point_agreement + K-(negD_M) (+131 lines). Also closed S1 sub-sorry (gap density) and S2 sub-sorry (gap-gap case) via complement_no_min witnesses. Key finding: K-(negD) bridge is necessary scaffolding (unavoidable before S13, replaceable after). Also closed S4 (multi-round K-(negD)) and S7-right (right-direction K-(negD)) in subsequent sessions.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now `Expressiveness/Claim1.lean` and `Expressiveness/SplitPoint.lean`)

---

### Phase 3A: Unified Game Restructure for sel-vs-p_n [BLOCKED]

**Goal**: Restructure `ghr93_case_II` to derive all pairwise orderings (including sel-vs-p_n) from a single game's `same_order_type`, eliminating the fan configuration that blocks the current multi-game assembly.

**Root cause (from research)**:
- The current approach derives orderings from THREE separate games: tau (gives sel-sel, d-sel, sel-y'), d-compatible big game (gives d/c-e_n/p_n, x-e_n, e_n-y), and sigma (gives x-b, b-d on the sigma side).
- The sel-vs-p_n ordering `(a_init(k) < extendPoint p_n <-> resp_tau(k) < e_n)` falls between games: `a_init(k)` is a tau input, `e_n` is a big game output. The fan configuration (d <= a_init(k) AND d <= p_n) prevents pivot_chain_order' from connecting them.
- In GHR93, this is trivially true because both sequences are strictly ordered by construction (GHR93 p.116-118). The formalization's separate game construction severs this connection.

**Strategy (Approach E from infrastructure report)**: Play `h_fwd_n1` (the (n+1)-round forward game from SplitPointProps) with M-side selections `resp_tau(0), ..., resp_tau(n-1), e_n` and challenge with a carrier point. The resulting `same_order_type` gives orderings between ALL position pairs in a single extraction, including `resp_tau(k)` vs `e_n`. Combined with the tau game's `same_order_type` (which gives `a_init(k)` vs `a_init(k')` iff `resp_tau(k)` vs `resp_tau(k')`), this provides all needed orderings.

**BLOCKER** (Phase 3A):
- **What failed**: Approach E (unified forward game) cannot derive `(a_init(k) < extendPoint p_n ↔ resp_tau(k) < e_n)` because ANY game play produces NEW N-side responses `a'(k)` that are NOT `a_init(k)`, and the order-isomorphism between `a_init` and `a'` relative to `d` and `y'` does NOT extend to their order relative to `p_n` (counterexample: `d=0, a_init=1, a'=2, p_n=1.5` -- same ordering relative to 0 and 3, but different sides of 1.5).
- **What was tried**:
  1. Playing `h_fwd_n1` with M-side selections `resp_tau(0),...,resp_tau(n-1), e_n` -- gives N-side responses `a'_fwd(k)` that are NOT `a_init(k)`. Cannot connect `a'_fwd(k) < p_n` to `a_init(k) < p_n`.
  2. Extracting from `hord_big` at `(1+k, b-pos)` -- gives `(resp_tau(k) < e_n ↔ a'_big(k) < p_n)` but `a'_big(k) != a_init(k)`.
  3. Playing tau with `e_n_pt` as challenge -- gives `(a_init(k) < b_tau ↔ resp_tau(k) < e_n)` but `b_tau != p_n` (fan problem with d).
  4. Trichotomy argument using tau_d_sel + hord_cd_en_pn -- only covers the case `d = a_init(k)` or `d = p_n`; the hard case `d < a_init(k)` AND `d < p_n` remains stuck.
  5. Order-isomorphism extension -- FALSE in general: order-isomorphic sequences can differ relative to points between their shared bounds.
  6. Pivot through alternative points (y', x', a_init(k')) -- all fail because no point serves as an intermediate in a chain between a_init(k) and p_n with known orderings on both legs.
- **Why it's stuck**: The formalization constructs `e_n` from a DIFFERENT game than `resp_tau`, severing the ordering connection between the tau sub-game and the p_n/e_n position. In GHR93, this ordering is trivially `True ↔ True` because Spoiler's selections are assumed distinct and ordered (via Lemma 10 strategy restriction). The formalization does NOT assume Spoiler's selections are ordered, so the biconditional is genuinely unprovable from the current sub-game assembly.
- **What is needed**: One of: (a) Implement Lemma 10 (strategy restriction) to reduce to distinct-ordered Spoiler selections, making both sides True; (b) Play a SINGLE (n+1)-round backward game on [d,y']/[c,y] that includes ALL n+1 positions (currently only n-round tau exists); (c) Restructure `obtain_split_point_props` to derive `h_d_compat_left` with the constraint that `a'_big(k) = a_init(k)` (requires changing the game construction).
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder. Do NOT add the ordering as an unproved axiom.

**Goal 1 progress**: The y' vs sel goal (Fin mismatch) IS closable with `convert ⟨(tau_sel_y ...).1.symm, (tau_sel_y ...).2.symm⟩ using 3 <;> (congr 1; exact Fin.ext (by omega))`. Only Goals 2-3 (sel vs p_n, p_n vs sel) are blocked.

**Tasks**:

- [ ] **Verify h_fwd_n1 game structure**: *(deviation: skipped -- Approach E proven infeasible after thorough analysis; h_fwd_n1 produces N-side responses that are NOT a_init)* Read `SplitPointProps.h_fwd_n1` signature and confirm it provides `ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'` (M selects, N responds). Verify (n+1) rounds are sufficient for n tau-selections + 1 e_n position.

- [ ] **Play the unified forward game**: *(deviation: skipped -- Approach E produces a'_fwd(k) != a_init(k), cannot bridge ordering gap)* In `ghr93_case_II`, after obtaining `resp_tau` and `e_n`, play `h_fwd_n1` with M-side selections:
  ```lean
  -- Unified M-side selections: tau responses + e_n
  let a_unified : Fin (n+1) -> ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩
    else e_n  -- position n = e_n
  -- All must be in [x, y]: resp_tau ∈ [c,y] ⊆ [x,y], e_n ∈ [x,y]
  have ha_unified_in : forall i, inClosedInterval x y (a_unified i) := by ...

  -- Play the forward game
  obtain ⟨b_fwd, hb_fwd_in, hord_unified, hgp_unified, hform_unified⟩ :=
    props.h_fwd_n1 a_unified ha_unified_in ...
  ```

- [ ] **Extract sel-vs-e_n ordering from unified game**: *(deviation: skipped -- depends on Play task above)* From `hord_unified` at positions `(1+k, 1+n)` where k < n:
  ```lean
  -- hord_unified gives same_order_type for game_tuple x' y' a'_unified b_fwd
  -- Position 1+k = a'_unified(k), Position 1+n = a'_unified(n) = ?
  -- M-side: resp_tau(k) vs e_n
  -- N-side: a'_unified(k) vs a'_unified(n)
  have unified_sel_en : forall k : Fin n,
      (resp_tau k < e_n <-> a'_unified ⟨k.val, by omega⟩ < a'_unified ⟨n, by omega⟩) ∧
      (resp_tau k = e_n <-> a'_unified ⟨k.val, by omega⟩ = a'_unified ⟨n, by omega⟩) := by
    intro k
    have h := hord_unified ⟨1 + k.val, by omega⟩ ⟨1 + n, by omega⟩
    simp only [game_tuple, a_unified] at h
    simp only [show (1 + k.val - 1 : Nat) = k.val by omega,
               show k.val < n from k.isLt,
               show ¬(n < n) from Nat.lt_irrefl n] at h
    exact h
  ```

- [ ] **Connect unified N-side responses to a_init**: *(deviation: skipped -- this step was identified as the fundamental gap; order-isomorphism does NOT extend to ordering relative to p_n)* The unified game's N-side responses `a'_unified(k)` are NOT `a_init(k)`. However, we can establish their order relationship to `a_init(k)`:
  - From tau game: `(a_init k < a_init k' <-> resp_tau k < resp_tau k')` -- tau_sel_sel
  - From unified game: `(resp_tau k < resp_tau k' <-> a'_unified(k) < a'_unified(k'))` -- at (1+k, 1+k')
  - Combined: `(a_init k < a_init k' <-> a'_unified(k) < a'_unified(k'))` -- a_init and a'_unified are order-isomorphic
  - From unified game at (1+k, 1+n): `(resp_tau k < e_n <-> a'_unified(k) < a'_unified(n))`
  - **Key question**: Can we show `(a_init k < p_n <-> a'_unified(k) < a'_unified(n))`? This requires connecting a_init to a'_unified and p_n to a'_unified(n). If the unified game's winning condition + tau's winning condition together imply these order-equivalences, the proof closes.

- [ ] **Alternative if direct connection fails**: *(deviation: skipped -- alternatives were explored and also fail; see BLOCKER documentation)* If a'_unified cannot be connected to a_init, use a DIFFERENT strategy: play h_fwd_n1 with `a_init(0), ..., a_init(n-1), extendPoint p_n` as N-side selections. Wait -- h_fwd_n1 has M selecting. Instead, use the BACKWARD direction: the fact that we are CONSTRUCTING a backward winning strategy means we get to CHOOSE the M-side responses. We can define:
  ```lean
  -- Instead of assembling same_order_type from parts, define the full
  -- response array directly and prove same_order_type in one shot
  let full_resp : Fin (n+1) -> ExtendedCarrier M atomMap r := fun i =>
    if h : i.val < n then resp_tau ⟨i.val, h⟩ else e_n
  ```
  Then prove `same_order_type` of the full `(n+1)` array + b-response against `a_bwd` by using ALL available ordering lemmas together. The sel-vs-p_n case uses the unified forward game, while other cases use tau/sigma/big as before.

- [ ] **Verify the approach works for both Case A and Case B**: *(deviation: skipped -- depends on earlier blocked tasks)*

- [ ] Run `lake build` to confirm no regressions after restructure *(deviation: skipped -- no code changes made)*

**Timing**: 2-4 hours

**Depends on**: 2 (COMPLETED)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- restructure ghr93_case_II game assembly (lines ~1175-1300)
- Possibly `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- if unified game needs additional SplitPointProps infrastructure

**Verification**:
- The unified game is played and orderings extracted
- sel-vs-p_n ordering is derivable from the new infrastructure
- `lake build` passes (sorry fallbacks still present in grid proof)

---

### Phase 3B: Structured Proof Tactic Overhaul (S8/S9 Closure) [NOT STARTED]

**Goal**: Replace the `same_order_type_grid <;> first | ... | sorry` pattern in both Case A and Case B with structured focused proofs using named hypotheses, closing S8 and S9.

**Root cause (from tactic report)**:
- The `same_order_type_grid` macro expands to `intro i j; simp only [game_tuple]; split_ifs` which produces inaccessible hypothesis names (`h_dagger`, `h_dagger1`).
- The subsequent `first | tac1 | ... | sorry` chain cannot reference these hypotheses by name, causing Fin index rewrites to fail.
- Goal count: Case A has ~25 goals (3 fall through), Case B has ~25 goals (~8 fall through).
- The Case I proof (lines 478-650) provides a complete working template using `split_ifs with` named hypotheses.

**Strategy**: Replace the grid macro with inline `intro i j; simp only [game_tuple]; split_ifs with <names>`, then handle each goal with bullet notation. For sel-vs-p_n goals specifically, use the unified game orderings from Phase 3A.

**Tasks**:

- [ ] **Case A (S8 at line ~1594)**: Replace the `same_order_type_grid <;> first | ... | sorry` block with structured proof:
  ```lean
  -- Replace:
  --   same_order_type_grid <;>
  --     first | order_refl | ... | sorry
  -- With:
  intro i j; simp only [game_tuple]; split_ifs with hi hj
  -- For each goal, use bullet notation:
  -- x vs x: · exact ⟨Iff.rfl, Iff.rfl⟩
  -- x vs sel(k): · exact ⟨hord_sig_x_sel k, ...⟩  (or tau equivalent)
  -- x vs p_n: · exact ⟨hord_fwd_x_en.1.symm, hord_fwd_x_en.2.symm⟩
  -- sel(i) vs sel(j): · exact tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩
  -- sel(i) vs p_n (THE KEY CASE):
  --   · -- i-1 < n, so a_bwd(i-1) = a_init(i-1)
  --     -- Use unified game ordering from Phase 3A
  --     rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
  --       by congr 1; exact Fin.ext (by omega), hab_n]
  --     exact unified_sel_pn ⟨i.val - 1, hin⟩
  ```
  Estimated: ~200 lines replacing ~170 lines of `first | ... | sorry` chain.

- [ ] **Case B (S9 at line ~1866)**: Same structured proof approach. The dead-code block (lines 1924-2021) provides a near-complete template. Adapt to current context:
  - Replace `hord_fwd` references with extracted `fwd_*` hypotheses
  - Replace `hd_le_an` with `h_no_split` or equivalent
  - Add sel-vs-p_n cases using unified game orderings from Phase 3A
  Estimated: ~200 lines.

- [ ] **Remove dead code block**: Once Case B structured proof is complete, remove the commented-out reference code at lines ~1924-2021. It has served its purpose as a template.

- [ ] **Verify maxErrors is no longer an issue**: The structured proof eliminates the `first | ...` chain, so the error multiplication problem vanishes. Remove any `set_option maxErrors` workarounds if present.

- [ ] Run `lake build` to confirm both sorry sites are closed

**Timing**: 2-4 hours

**Depends on**: 3A

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S8 at line ~1594, S9 at line ~1866

**Key tactic patterns** (from the tactic report survey):

| Goal Pattern | Tactic | Source |
|------|--------|--------|
| sel(i) vs sel(j) | `tau_sel_sel ⟨_, hin⟩ ⟨_, hjn⟩` | tau game |
| sel(i) vs p_n | unified game ordering (Phase 3A) | unified forward game |
| p_n vs sel(j) | unified game ordering (reverse) | unified forward game |
| y' vs sel | `⟨(tau_sel_y ⟨_, hin⟩).1.symm, ...⟩` | tau game |
| b_resp vs p_n | `pivot_chain_order'` through d/c | interval bounds |
| x vs p_n | `⟨hord_fwd_x_en.1.symm, ...⟩` | forward game |
| diagonal | `⟨Iff.rfl, Iff.rfl⟩` | reflexivity |

**Critical Fin rewrite pattern** (for p_n cases where j-1 = n):
```lean
rw [show a_bwd ⟨j.val - 1, _⟩ = a_bwd ⟨n, by omega⟩ from
  by congr 1; exact Fin.ext (by omega), hab_n]
```
This converts `a_bwd ⟨j-1, bound_proof⟩` to `extendPoint p_n` when `not (j-1 < n)` implies `j-1 = n`.

**Verification**:
- Sorry sites S8 (line ~1594) and S9 (line ~1866) are closed
- `lake build` passes
- Sorry count in CaseAnalysis.lean reduced from 3 live to 1 (S11 at line ~2619 remains for Phase 5)

---

### Phase 4: Position-Tracking Fix S6 + S7 [COMPLETED]
- **Completed**: 2026-05-24

**Summary**: Added `ghr93_rank_down_proj` lemma (233 lines) for position-tracking variant of rank_down. S6 closed directly using rank_down_proj. S7 right-case expanded (~160 lines) with h_cont_transfer_mr and h_mr_resp_ge_d fully proved. S7-right K-(negD) sorry subsequently closed via shared approach from Phase 2.

**Files modified**: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (now `Expressiveness/SplitPoint.lean`)

---

### Phase 5: Cases III/IV + Strategy Restriction (S11, S12) [NOT STARTED]

**Goal**: Close S11 (Cases III/IV gap detection, CaseAnalysis.lean:2619) and S12 (strategy restriction for rank-varying forward-to-backward, Theorem6.lean:307).

**Tasks**:

- [ ] **Close S11 (CaseAnalysis.lean:2619, `ghr93_cases_III_IV`)**: Full theorem body sorry. Construct backward game response when a_n is a gap.
  1. Case-split on whether a_bwd(n) is left-defined or right-defined (or both)
  2. Use `left_formula_gap_detection` / `right_formula_gap_detection` (proved sorry-free in `EFGames/GapDetection.lean`) to find a matching gap in M
  3. Use `gap_detection_unique` to show the matching gap has correct properties
  4. Construct response sequence: tau (for init positions) + matching gap (for position n)
  5. Assemble winning condition from tau + gap detection properties
  - Estimated: 150-300 lines (substantial new proof using existing infrastructure)

- [ ] **Close S12 (Theorem6.lean:307, `ghr93_forward_to_backward_rank_varying`)**: Sub-interval strategy restriction.
  - **Approach**: Parameter approach -- modify `ghr93_forward_to_backward_rank_varying` to take the IH game (`h_r1_univ`) as a parameter from the main induction, rather than deriving it internally. The IH already provides games on all sub-intervals via universal quantification.
  - Do NOT implement full Lemma 10 strategy restriction theorem -- the parameter approach is simpler and sufficient.
  - Estimated: 100-200 lines (signature change + threading IH through)

- [ ] Run `lake build` to confirm no regressions

**Timing**: 4-8 hours

**Depends on**: 3B, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- S11 at line 2619
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- S12 at line 307

**Verification**:
- Sorry sites at CaseAnalysis.lean:2619 and Theorem6.lean:307 are closed
- `lake build` passes
- Sorry count in Expressiveness/ reduced to 0

---

### Phase 6: Keystone Sorry -- NF Characterization (S13) [NOT STARTED]

**Goal**: Close the keystone sorry at StaviCompleteness.lean:1567 -- the inductive step of `nf_characterizable_by_stavi`. Every NormalForm at depth k+1 must be characterizable by a StaviFormula.

**Tasks**:
- [ ] Read the current structure of `nf_characterizable_by_stavi` and the inductive step
- [ ] Base case (k=0) is proved via `nf_base_sf` (sorry-free) -- no action needed
- [ ] Inductive step for k+1 NFs requires handling 2-variable NFs (`NormalForm sig k 2`) using Until/Since connectives
- [ ] Implement using the game-theoretic argument from GHR93 Theorem 6/Proposition 7, invoking the four-case analysis (Cases I-IV) proved in Phases 2-5
- [ ] This requires all S1-S12 closed (the four-case analysis is the inductive step's core)
- [ ] Run `lake build` to confirm no regressions

**Timing**: 4-8 hours (highest-risk phase)

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step at line 1567 (~200-400 lines)

**Verification**:
- Sorry site S13 (StaviCompleteness.lean:1567) is closed
- `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- `lake build` passes

---

### Phase 7: Reynolds Theorem 5 -- no_gaps_discrete (S14) [NOT STARTED]

**Goal**: Close S14 (`no_gaps_discrete` in GoodStructures.lean:842) -- Reynolds Theorem 5 showing the integer model has no gaps.

**Tasks**:
- [ ] Read the current state of `no_gaps_discrete` in GoodStructures.lean
- [ ] Implement the gap elimination argument: since every NF is characterizable by a StaviFormula (Phase 6), and StaviFormulas are determined by their truth at integer points, gaps in the integer model would require a type not characterizable by any StaviFormula -- contradiction
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete at line 842 (~100-200 lines)

**Verification**:
- Sorry site S14 is closed
- `#print axioms no_gaps_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Close succ_cofinal via Gap Elimination [NOT STARTED]

**Goal**: Prove `succ_cofinal` (ChronicleToCountermodel.lean:1885) -- the root sorry blocking `bx_completeness`. Also close 3 sub-proof sorry sites at lines 1285, 1441, and 1508.

**Tasks**:
- [ ] Read the current state of `succ_cofinal` and `limitDomSubtype_isSuccArchimedean`
- [ ] Close sub-proof sorry at line 1285 (boundary case)
- [ ] Close sub-proof sorry at line 1441 (below-min case)
- [ ] Close sorry at line 1508 (`limit_dom_points_are_succ_iterates`)
- [ ] Wire `no_gaps_discrete` + `nf_characterizable_by_stavi` to prove `IsSuccArchimedean` for `LimitDomSubtype`
- [ ] Argument: if there existed a point x in `LimitDomSubtype` with no successor, the interval (x, ...) would contain a gap. But `no_gaps_discrete` (via the chronicle's OrderIso) shows no such gap exists. Therefore every point has a successor.
- [ ] Close `succ_cofinal` -- makes `succ_embed_surjective`, `cantor_bfmcs_discrete_restricted_tc`, and `cantor_bfmcs_discrete_restricted_fuc` all sorry-free
- [ ] Verify `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- [ ] Run `lake build` to confirm no regressions

**Timing**: 2-4 hours

**Depends on**: 6, 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal at line 1885, sub-proofs at lines 1285, 1441, 1508 (~100-300 lines)

**Verification**:
- `succ_cofinal` sorry is closed
- Sub-proof sorries at lines 1285, 1441, 1508 are closed
- `#print axioms dd_countermodel_chronicle_discrete` shows no `sorryAx`
- `#print axioms countermodel_discrete` shows no `sorryAx`
- `lake build` passes

---

### Phase 9: Final Verification [NOT STARTED]

**Goal**: Verify `bx_completeness` is sorry-free after Phases 3-8. No sorry closures needed -- task 198 resolved all Completeness.lean sorry sites (`completeness_dense` and `completeness_discrete` are now sorry-free).

**Tasks**:
- [ ] Run `#print axioms completeness_dense` and confirm no `sorryAx`
- [ ] Run `#print axioms completeness_discrete` and confirm no `sorryAx`
- [ ] Run `#print axioms bx_completeness` (or `completeness`)
- [ ] Confirm output shows only `propext`, `Classical.choice`, `Quot.sound` (standard Lean axioms)
- [ ] Verify no `sorryAx` appears anywhere in the output
- [ ] Run `lake build` -- confirm zero errors
- [ ] Verify `doets_countermodel_discrete` uses the Reynolds pipeline path, not the chronicle fallback

**Timing**: 0.5-1 hour (verification only, no code changes expected)

**Depends on**: 8

**Files to modify**:
- None expected. If `sorryAx` persists, investigate and close any remaining sorry sites.
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only if unexpected sorries found

**Verification**:
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes with zero errors
- Definition of done is met

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] All 7 remaining critical-path sorry sites closed (+ 3 sub-proofs)
- [ ] Phase 3A: unified game played and orderings extracted (sel-vs-p_n derivable)
- [ ] Phase 3B: structured focused proofs replace `first | ... | sorry` pattern in both Case A and Case B
- [ ] `#print axioms nf_characterizable_by_stavi` shows no `sorryAx`
- [ ] `#print axioms no_gaps_discrete` shows no `sorryAx`
- [ ] `succ_cofinal` sorry is closed (root sorry for bx_completeness)
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No `sorryAx` in the axiom output for `bx_completeness`
- [ ] `doets_countermodel_discrete` uses Reynolds pipeline (no chronicle fallback)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Phases 3A, 3B (S8, S9 closure) + Phase 5 S11
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- Phase 3A (possibly, if unified game infrastructure needed)
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- Phase 5 S12
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- NF characterization inductive step (Phase 6)
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete (Phase 7)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal + sub-proofs (Phase 8)
- `specs/155_reynolds_pipeline_activation/plans/33_reynolds-pipeline-plan.md` -- this plan

## Rollback/Contingency

**Phase 3A (unified game restructure) is blocked**:
1. If h_fwd_n1 does not provide sufficient rounds, try h_d_compat_left's (1+3n+1)-round game with modified padding that includes all relevant positions.
2. If unified game's N-side responses cannot be connected to a_init, try proving that the ordering relationship `(a_init k < p_n <-> resp_tau k < e_n)` holds as a consequence of tau's winning condition + the unified game's winning condition JOINTLY, even though neither alone suffices. This is a "two-game triangle" argument.
3. If all game-based approaches fail, consider adding a strict ordering hypothesis on a_bwd (mimicking GHR93's "we may assume distinct" step via Lemma 10 strategy restriction). This would require implementing Lemma 10 first.
4. Last resort: Axiomatize the sel-vs-p_n ordering as a hypothesis (sorry-with-comment) and proceed with Phases 5-9, treating Phase 3A as a standalone research blocker.

**Phase 3B (tactic overhaul) contingency**:
1. If structured proof is too verbose (>500 lines per case), factor common tactic patterns into local `have` lemmas or a helper tactic.
2. If hypothesis naming from `split_ifs with` is unreliable across Lean versions, use `rename_i` as a post-hoc fix for each goal.

**Phase 5 S12 (parameter approach) contingency**:
1. Fall back to implementing full Lemma 10 strategy restriction as a separate theorem (~300-400 lines).

**Phase 6 (NF characterization, S13) contingency**:
1. Highest-risk phase. If the inductive step requires infrastructure beyond Phases 3-5, document what is missing.
2. S1-S12 closures remain valuable as standalone GHR93 formalization progress.
3. A dedicated research round on the 2-variable NF characterization may be needed.

**Phase 8 (succ_cofinal via gap elimination) contingency**:
1. Document the precise gap.
2. Recommend Task 129 (Henkin canonical model approach) as alternative path to sorry-free `bx_completeness`.
3. All S1-S14 closures remain valuable.

**General rollback**: All changes committed after each phase. Git history enables rollback to any phase boundary.
