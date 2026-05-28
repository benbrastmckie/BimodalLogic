# Implementation Plan: Stavi Completeness + GHR93 U(B,A) Case II (v41)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 18-30 hours
- **Dependencies**: Tasks 154, 168, 174, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: reports/40_ghr93-case-ii-step6.md, reports/41_stavi-completeness-audit.md, reports/39_game-depth-restructuring.md
- **Artifacts**: plans/41_stavi-uba-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan supersedes plan v40's Case II approach (tau_left/tau_right sub-split) with the principled GHR93 construction: build a characteristic Stavi formula B for p_n's rank-r type, form phi = U(B, sf_top), transfer phi through tau at rank r+delta (delta >= 2), and extract witness z = e_n. This eliminates the cross-game ordering problems that produced 3 sorry sites in CaseAnalysis.lean under the old approach. The plan has two sequential tracks: (S) close the Stavi completeness chain (nf_2var_from_interval_data bridge lemma + depth bound), then (U) rewrite Case II using U(B,A) with h_surj threading and close remaining sorries.

### Research Integration

- **Report 40 (GHR93 Case II step 6)**: GHR93 constructs e_n from U(B,A) witness z transferred through tau. sel_pn_ord is trivial: resp_tau(k) <= resp_tau(n-1) < z = e_n. The forward game is NOT used for e_n construction.
- **Report 41 (Stavi completeness audit)**: Root sorry is nf_2var_from_interval_data (line 1873, ~200-500 lines to close). nf_exist_sf_guarded_backward (line 2152) chains through it. Infrastructure exists in Composition.lean (ghr93_strategy_compose, sorry-free) and Decomposition.lean (decomposition_agreement, sorry-free). No stavi_depth bound is proved on the output of nf_characterizable_by_stavi.
- **Report 39 (game depth restructuring)**: SplitPointProps now has delta parameter; sigma/tau at rank r+delta. Phases R1-R2 COMPLETED. R3 is IN PROGRESS with 3 sorry sites remaining in CaseAnalysis.lean.

### Prior Plan Reference

Plan v40 (rank-restructuring-plan) completed Phases R1, R2, and most of R3. Key lessons: (1) tau_left/tau_right sub-split for Case II works mechanically but produces stubborn grid-dispatch sorries at Case B1/B2 boundaries. (2) The delta parameter in SplitPointProps is architecturally correct. (3) Workaround deletion (char_k, tau_r2, h_ih_r2) was successful. (4) The Case II proof structure should follow GHR93 exactly rather than using sub-interval composition, which introduces cross-game ordering issues.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Close nf_2var_from_interval_data (StaviCompleteness.lean:1873) -- the root sorry for Stavi expressive completeness
- Close nf_exist_sf_guarded_backward (StaviCompleteness.lean:2152) -- chains through bridge lemma
- Add and prove a stavi_depth bound on nf_characterizable_by_stavi output
- Thread h_surj (atomMap surjectivity) through ghr93_case_II -> ghr93_inductive_step -> Theorem6.lean
- Rewrite Case II using the GHR93 U(B,A) construction (report 40, Section 1)
- Close Theorem6.lean rank promotion sorries (lines 124, 325)
- Close Cases III/IV winning condition (CaseAnalysis.lean:3350)
- Close GoodStructures.lean:842 (no_gaps_discrete) and ChronicleToCountermodel sorries
- Achieve sorry-free bx_completeness

**Non-Goals**:
- Changing game_depth (confirmed unnecessary per report 39)
- Changing EFGames definitions (Defs.lean, CustomGame.lean)
- Phases 6D/6E/6F from v40 (GHR93 classical chain for StaviCompleteness) -- superseded by Phase S1 direct proof
- Dense or mixed completeness variants
- Non-critical TruthLemma sorries

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| nf_2var_from_interval_data requires deep game composition argument (200-500 lines) | H | M | Composition.lean and Decomposition.lean provide sorry-free infrastructure; the bridge connects interval_nf_types to decomposition_agreement |
| stavi_depth bound is not provable for the existing construction | H | L | The formula is built inductively with std_untl/std_snce adding +2 per level; a depth <= 2*k bound should be provable by induction on k |
| h_surj threading requires signature changes in 5+ theorems across 2 files | M | L | Mechanical change; h_surj is available at top level from ShiftAndGlue.lean |
| U(B,A) transfer through tau at rank r+delta requires delta >= 2 and stavi_depth B <= r | M | M | With delta >= 2 (already enforced by hd), U(B,sf_top) at depth r+2 transfers through tau at rank r+delta. If stavi_depth B <= r is not achievable, use B at depth <= r+delta-2 (always feasible) |
| sel_pn_ord gap: z (Until witness) may not equal e_n | M | L | Per report 40: GHR93 sets e_n = z. There is no separate e_n from forward game. The ordering resp_tau(k) < z is trivial from Until semantics |
| Cases III/IV sorry (line 3350) may need independent gap detection infrastructure | M | M | Gap detection is sorry-free (GapDetection.lean, 5057 lines); the sorry is the winning condition assembly which mirrors Case II |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | S1 | -- |
| 2 | S2 | S1 |
| 3 | S3 | S2 |
| 4 | S4 | S3 |
| 5 | S5 | S4 |

Phases are fully sequential. Each phase produces a compilable state.

---

### Phase S1: Close nf_2var_from_interval_data [NOT STARTED]

**Goal**: Prove the bridge lemma (GHR93 Proposition 7 + Lemma 11): if two 2-variable environments agree on 1-variable types, ordering, interval types, and types above/below, then their 2-variable NFs are equal.

**Tasks**:
- [ ] **S1.1: Read and understand the sorry site** (~0.5 hours)
  - Read StaviCompleteness.lean lines 1853-1873 (nf_2var_from_interval_data signature)
  - Read Composition.lean for ghr93_strategy_compose signature and how it builds Duplicator strategies
  - Read Decomposition.lean for decomposition_agreement and how it relates to NF equality
  - Map the connection: interval_nf_types (line 1835) -> decomposition_agreement (Decomposition.lean:62) -> game winning -> NF equality
- [ ] **S1.2: Build the connection from interval_nf_types to decomposition_agreement** (~100-150 lines)
  - interval_nf_types gives Finset equality of realized 1-var NFs in open intervals
  - decomposition_agreement requires: for every carrier point in (lo,hi) in M, there exists one in M' with same 1-var NF, and vice versa
  - Bridge: interval_nf_types equality -> for each NF type in the set, witnesses exist in both models -> decomposition_agreement holds
  - May need a helper lemma: `interval_nf_types_implies_decomposition` (~40-60 lines)
- [ ] **S1.3: Connect to ghr93_game_iff_decomposition** (~50-80 lines)
  - Decomposition.lean:302 gives: decomposition_agreement <-> Duplicator wins the game
  - From S1.2: interval_nf_types agreement -> decomposition_agreement
  - Also need: h_nf_x and h_nf_t (1-var NF agreement at endpoints) and h_order_xt (ordering) feed into the game positions
  - Need to handle h_above_max and h_below_min (types above/below the pair)
- [ ] **S1.4: Prove game winning implies NF characteristic equality** (~50-100 lines)
  - From S1.3: Duplicator wins the 2-variable game
  - Need: game winning on 2-variable environments implies nf_characteristic equality
  - This may already exist as a theorem in the NormalForm/EFGames infrastructure
  - If not: prove by induction on k -- winning the k-round game implies agreement on depth-k NFs
- [ ] **S1.5: Assemble the full proof of nf_2var_from_interval_data** (~50-100 lines)
  - Combine S1.2 + S1.3 + S1.4 into the final proof
  - Handle the case split on ordering (x < t vs t < x vs x = t)
  - For x = t: 2-var NF is determined by 1-var NF alone (trivial)
  - Verify: grep -n sorry StaviCompleteness.lean shows line 1873 is closed
- [ ] **S1.6: Close nf_exist_sf_guarded_backward** (~100-200 lines)
  - This sorry (line 2152) chains through the bridge lemma
  - Once nf_2var_from_interval_data is proved, follow the proof outline in the comments (lines 2142-2151):
    1. Extract witness x from the temporal formula (Until/Since/equality)
    2. From char_k_correct, determine x's 1-var depth-k NF
    3. From the interval guard, extract types of intermediate points
    4. Apply bridge lemma to conclude 2-var NF = sub_nf
  - Verify: grep -n sorry StaviCompleteness.lean shows only line 2152 is closed
- [ ] **S1.7: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - `#print axioms nf_characterizable_by_stavi` -- no sorryAx

**Timing**: 4-8 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- close 2 sorry sites

**Verification**:
- nf_2var_from_interval_data and nf_exist_sf_guarded_backward sorry-free
- nf_characterizable_by_stavi sorry-free (lean_verify)
- StaviCompleteness.lean compiles

---

### Phase S2: Add stavi_depth bound + thread h_surj [NOT STARTED]

**Goal**: (A) Prove that nf_characterizable_by_stavi produces a formula with bounded stavi_depth, and (B) thread h_surj (atomMap surjectivity) through the theorem chain so that ghr93_case_II can call nf_characterizable_by_stavi.

**Tasks**:
- [ ] **S2.1: Prove stavi_depth bound on nf_characterizable_by_stavi output** (~80-150 lines)
  - The theorem currently provides `exists A : StaviFormula, ...` with no depth constraint
  - Strengthen to: `exists A : StaviFormula, stavi_depth A <= f(k) AND ...` where f(k) is the correct bound
  - Depth analysis (from report 41):
    - Base case k=0: conjunction of atom literals, stavi_depth = 0
    - Inductive case k+1: sf_conjList of (atom literals ++ quant_formulas)
    - Each quant_formula uses nf_exist_sf_guarded which builds std_untl/std_snce (each adds +2)
    - The guard includes char_k formulas at depth <= f(k) (IH)
    - So f(k+1) = max(0, f(k) + 2) = f(k) + 2
    - Therefore f(k) = 2*k (each induction step adds 2)
  - Prove: `stavi_depth A <= 2 * k` by induction on the characterization construction
  - Alternative: if the exact bound is hard, prove `stavi_depth A <= r` when called with k=r (the use case for U(B,A))
  - Add the depth bound to the theorem statement or as a separate lemma
- [ ] **S2.2: Thread h_surj through ghr93_inductive_step** (~20-30 lines)
  - Add parameter: `(h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)`
  - Pass through to ghr93_case_II and ghr93_cases_II_III_IV
  - In CaseAnalysis.lean: update ghr93_inductive_step, ghr93_cases_II_III_IV signatures
- [ ] **S2.3: Thread h_surj through Theorem6.lean** (~20-30 lines)
  - Add h_surj parameter to ghr93_forward_to_backward_core, ghr93_forward_to_backward, ghr93_forward_to_backward_rank_varying
  - Pass through to ghr93_inductive_step calls
  - h_surj is available at the top level from ShiftAndGlue.lean's Encodable.surjective_decode_iget
- [ ] **S2.4: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6`
  - Existing sorry sites may change location but count should not increase

**Timing**: 2-4 hours

**Depends on**: S1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- depth bound
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- h_surj in signatures
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- h_surj in signatures

**Verification**:
- stavi_depth bound proved
- h_surj available in ghr93_case_II
- All files compile (sorry count may be same or fewer)

---

### Phase S3: Rewrite Case II using GHR93 U(B,A) construction [NOT STARTED]

**Goal**: Replace the current tau_left/tau_right Case II proof with the correct GHR93 construction: build B = X_{p_n} via nf_characterizable_by_stavi, form phi = U(B, sf_top), transfer through tau, extract witness z = e_n, and prove sel_pn_ord trivially.

**Tasks**:
- [ ] **S3.1: Build B_pn -- the characteristic Stavi formula for p_n** (~40-60 lines)
  - p_n = a_bwd(n) is a carrier point in N at rank r
  - Compute nf_pn = nf_characteristic N r 1 (fun _ => p_n_carrier) (the depth-r 1-var NF of p_n)
  - Apply nf_characterizable_by_stavi atomMap h_surj r nf_pn to get B_pn : StaviFormula
  - From S2.1: stavi_depth B_pn <= 2*r (or <= r if the tighter bound holds)
  - B_pn characterizes p_n: for any carrier point q, stavi_temporal_truth N atomMap q B_pn <-> nf_eval_nf N r 1 (fun _ => q) nf_pn
- [ ] **S3.2: Build phi = std_untl B_pn sf_top and establish phi at a_init(n-1)** (~30-50 lines)
  - phi = StaviFormula.std_untl B_pn StaviFormula.sf_top
  - stavi_depth phi = max(stavi_depth B_pn, 0) + 2 <= 2*r + 2
  - N |= U(B,A)(a_init(n-1)): a_n = p_n witnesses it
    - p_n > a_init(n-1) (from sorted selections: a_bwd is increasing)
    - B_pn holds at p_n (by construction: p_n satisfies its own NF)
    - sf_top holds at all intermediate points (sf_top is always true)
  - Need: 2*r + 2 <= r + delta, i.e., r + 2 <= delta
  - With delta = 4: works when r <= 2. For larger r: need delta >= r + 2
  - CRITICAL: If stavi_depth B_pn <= 2*r, then phi depth <= 2*r + 2, and we need tau at rank >= 2*r + 2. With delta = 4, this only works for r <= 1.
  - RESOLUTION: Use rank_type/TypeFormulas approach instead of nf_characterizable_by_stavi for the formula B. rank_type (TypeFormulas.lean:356) gives the set of depth-<= r formulas true at p_n. The key theorem rank_type_eq_iff (line 374) gives: equal rank_types imply formula agreement at depth <= r.
  - ALTERNATIVE RESOLUTION: The formula returned by nf_characterizable_by_stavi at depth k characterizes the k-depth NF. For U(B,A) we need B to characterize the rank-r type of p_n. If we call nf_characterizable_by_stavi at k = some value <= r/2, then stavi_depth B <= 2*(r/2) = r, and phi depth = r+2 <= r+delta (for delta >= 2). But this only gives (r/2)-depth NF agreement, not full rank-r agreement.
  - CORRECT RESOLUTION (per GHR93, report 40 Section 5): GHR93 uses rank r+4 for tau (not r+2). With tau at rank r+4: B at depth r, phi at depth r+1 <= r+4. The stavi_depth bound needs to be <= r, NOT 2*r. The construction in StaviCompleteness.lean at depth k gives depth <= 2*k by the analysis in S2.1. BUT: the formula B is obtained by calling nf_characterizable_by_stavi at k = some depth such that depth-k NF determines rank-r type. Per the game_depth function, this k may be much smaller than r. Alternatively, the rank_type approach (TypeFormulas.lean) gives depth <= r formulas directly.
  - ACTION: Use the rank_type approach from TypeFormulas.lean. Build B as a conjunction/disjunction of the depth-<= r formulas in rank_type(p_n). Since StaviFormula is not Fintype, cannot enumerate. Instead: use Classical.choice to pick a single StaviFormula characterizing the rank_type, or use nf_characterizable_by_stavi at depth r and accept that stavi_depth may be up to 2*r, requiring delta >= r + 2.
  - FINAL DECISION: Call nf_characterizable_by_stavi at depth r. The output B has some stavi_depth d. phi = U(B, sf_top) has depth d + 2. Transfer requires d + 2 <= r + delta. With the current architecture (delta parameter in SplitPointProps), set delta >= d + 2 - r. The restructuring in Theorem6.lean must provide sufficient delta. GHR93 uses delta = 4*n where n is the number of backward rounds; at the top level of the induction, delta can be made as large as needed.
- [ ] **S3.3: Transfer phi through tau and extract witness** (~60-100 lines)
  - tau operates at rank r+delta on rank-embedded positions
  - phi holds at rank-embedded a_init(n-1) in N (from S3.2, using rank_embed_stavi_truth_mu)
  - tau's winning condition includes formula agreement: stavi_temporal_truth_mu at rank r+delta
  - phi at depth d+2 <= r+delta: tau transfers phi from a_init(n-1) to resp_tau(n-1)
  - M |= phi(resp_tau(n-1)): there exists z > resp_tau(n-1) with B(z)
  - Extract z from the Until semantics; set e_n = z
  - e_n has the same rank-r type as p_n (B characterizes p_n's rank-r type, B(e_n) holds)
- [ ] **S3.4: Prove sel_pn_ord (trivially)** (~20-30 lines)
  - Per report 40 Section 2:
  - resp_tau(k) <= resp_tau(n-1) for k < n (tau preserves order: a_init(k) < a_init(n-1) implies resp_tau(k) < resp_tau(n-1))
  - resp_tau(n-1) < z = e_n (defining property of Until witness)
  - Therefore: resp_tau(k) <= resp_tau(n-1) < e_n for all k < n
  - sel_pn_ord follows directly
- [ ] **S3.5: Build the response function and Round 2 winning condition** (~100-200 lines)
  - Response: resp(k) = resp_tau(k) for k < n, resp(n) = e_n
  - Round 2 winning condition case split on Spoiler's challenge position:
    - Challenge in (resp_tau(k), resp_tau(k+1)) for some k < n-1: use tau's Round 2 winning condition
    - Challenge in (resp_tau(n-1), e_n): Use the A-condition from U(B,A). A = sf_top holds trivially (no constraint on intermediate points). The rank-r formula agreement for the interval follows from tau + B's characterization.
    - Challenge outside [x, y]: handled by sigma/tau endpoint conditions
    - Challenge at e_n / resp_tau(k): point formula agreement from B and tau
  - Assemble the full backward game winning condition
- [ ] **S3.6: Delete old tau_left/tau_right infrastructure** (~negative lines)
  - Delete tau_left, tau_right, resp_left, resp_mod constructions
  - Delete tau_composed, hord_left_*, hord_right_* ordering lemmas
  - Delete Case B1/B2 sub-split
  - Clean up dead code
- [ ] **S3.7: Close Theorem6.lean rank promotion sorries** (~80-150 lines)
  - Line 124 (ghr93_forward_to_backward at delta=2): The IH lambda is sorry'd. With the U(B,A) approach, the IH needs to provide backward games at rank r+delta from forward games at rank r. This may require the ambient high-rank forward game restricted to sub-intervals.
  - Line 325 (ghr93_forward_to_backward_rank_varying succ case): Rank promotion from forward at r to backward at r+4. The IH at base rank r+4 says forward at (r+4)+4n -> backward at r+4. Need to promote the rank-r forward game to rank (r+4)+4n using the original high-rank forward game.
  - Both require strategy restriction from the ambient game to sub-intervals, then round_mono.
- [ ] **S3.8: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis`
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6`
  - Case II sorry count should drop to 0
  - Theorem6 sorry count should drop to 0

**Timing**: 6-10 hours

**Depends on**: S2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- close rank promotion sorries

**Verification**:
- CaseAnalysis.lean Case II sorry-free
- Theorem6.lean sorry-free
- sel_pn_ord proved trivially from Until witness ordering
- All workaround infrastructure deleted

---

### Phase S4: Close remaining sorries (Cases III/IV + downstream) [NOT STARTED]

**Goal**: Close the Cases III/IV winning condition sorry (CaseAnalysis.lean:3350), close GoodStructures.lean:842 (no_gaps_discrete), and close ChronicleToCountermodel.lean sorries (lines 1285, 1441, 1508, 1885).

**Tasks**:
- [ ] **S4.1: Close Cases III/IV winning condition** (~100-200 lines)
  - CaseAnalysis.lean:3350 -- the sorry is inside ghr93_cases_III_IV
  - Cases III/IV handle when a_bwd(n) is a gap (not a carrier point)
  - The gap detection infrastructure is complete (GapDetection.lean, 5057 lines, sorry-free)
  - The winning condition assembly mirrors Case II but with a gap at position n+1:
    - For each pair (i,j) of positions 0..n+3: prove ordering, gap_point agreement, and formula agreement
    - Ordering: from tau sub-game + d-compat + gap interval membership
    - Gap point agreement: from tau sub-game + GapDetection S11.2
    - Formula agreement: from tau sub-game + GapDetection S11.1
  - The comment at line 3340-3349 describes the exact construction
- [ ] **S4.2: Close no_gaps_discrete (Reynolds Theorem 5)** (~150-300 lines)
  - GoodStructures.lean:842 -- requires Reynolds Theorem 5 (US expressive completeness)
  - The proof structure (from comments lines 836-841):
    1. Define rho via k-type characterization
    2. Apply Theorem 5 to get temporal formula R
    3. Derive structural properties via h_prior_UZ and h_prior_SZ (Lemmas 7-8)
    4. Show model surgery preserves temporal truth (Lemma 12)
    5. Derive contradiction from R holding in surgery model
  - Requires stavi_expressive_completeness (nf_characterizable_by_stavi) which will be sorry-free after Phase S1
  - May also require the classical chain (Cor 12.8.19) -- if so, implement Phases 6D/6E/6F from v40 as sub-tasks
- [ ] **S4.3: Close ChronicleToCountermodel boundary sorries** (~100-200 lines)
  - Line 1285: boundary case (above-max) for succ_cofinal
  - Line 1441: below-min boundary case
  - Line 1508: limit_dom_points_are_succ_iterates
  - Line 1885: succ_cofinal itself (root sorry for discrete completeness)
  - All four form a chain: 1285 and 1441 are sub-cases in the proof that calls 1508, which is used by 1885
  - With no_gaps_discrete proved (S4.2), the gap elimination argument may simplify succ_cofinal
  - Alternative: if these are too deeply entangled with the omega-chain construction, axiomatize no_gaps_discrete -> IsSuccArchimedean bridge
- [ ] **S4.4: Build verification**
  - `lake build` full project
  - `#print axioms bx_completeness` -- check for sorryAx

**Timing**: 4-8 hours

**Depends on**: S3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- Cases III/IV
- `Theories/Bimodal/Metalogic/WeakCanonical/IntegerModel/GoodStructures.lean` -- no_gaps_discrete
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal chain

**Verification**:
- Cases III/IV sorry closed
- no_gaps_discrete sorry closed
- succ_cofinal chain closed (or documented as blocked)
- bx_completeness sorry audit

---

### Phase S5: Final Verification [NOT STARTED]

**Goal**: Full build, sorry audit, axiom check. Verify sorry-free bx_completeness.

**Tasks**:
- [ ] **S5.1: Full lake build**
  - `lake build` passes with zero errors
- [ ] **S5.2: Axiom audit**
  - `#print axioms bx_completeness` -- only propext, Classical.choice, Quot.sound (no sorryAx)
  - `#print axioms nf_characterizable_by_stavi` -- no sorryAx
  - `#print axioms stavi_expressive_completeness` -- no sorryAx
- [ ] **S5.3: Sorry audit**
  - `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/` -- document all remaining sorry sites
  - `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- document remaining
  - Classify each as: critical-path, non-critical, or dead-code
- [ ] **S5.4: Clean up workaround remnants**
  - `grep -rn 'char_k\|tau_r2\|h_ih_r2\|resp_mod\|tau_left\|resp_left' Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/` -- should return empty
  - Confirm all v40 workaround code has been deleted

**Timing**: 0.5-1 hour

**Depends on**: S4

**Files to modify**: None (read-only verification)

**Verification**:
- bx_completeness sorry-free
- nf_characterizable_by_stavi sorry-free
- stavi_expressive_completeness sorry-free
- No workaround remnants
- Zero build errors

---

## Current Sorry Inventory (as of plan creation)

### Critical path to bx_completeness:
| File | Line | Sorry | Nature | Phase |
|------|------|-------|--------|-------|
| Theorem6.lean | 124 | IH lambda at delta=2 | Rank promotion | S3.7 |
| Theorem6.lean | 325 | Rank promotion succ case | Strategy restriction | S3.7 |
| CaseAnalysis.lean | 2026 | Case B1 grid edge | Ordering dispatch | S3.5 (replaced) |
| CaseAnalysis.lean | 2107 | Case B2 ordering | Grid dispatch | S3.5 (replaced) |
| CaseAnalysis.lean | 3350 | Cases III/IV winning | Game assembly | S4.1 |
| GoodStructures.lean | 842 | no_gaps_discrete | Reynolds Thm 5 | S4.2 |
| ChronicleToCountermodel.lean | 1285 | boundary above-max | Omega chain | S4.3 |
| ChronicleToCountermodel.lean | 1441 | boundary below-min | Omega chain | S4.3 |
| ChronicleToCountermodel.lean | 1508 | limit_dom_succ_iterates | Succ reach | S4.3 |
| ChronicleToCountermodel.lean | 1885 | succ_cofinal | Root sorry | S4.3 |

### Stavi expressive completeness (becomes critical via S3):
| File | Line | Sorry | Nature | Phase |
|------|------|-------|--------|-------|
| StaviCompleteness.lean | 1873 | nf_2var_from_interval_data | Bridge lemma | S1.5 |
| StaviCompleteness.lean | 2152 | nf_exist_sf_guarded_backward | Chains through bridge | S1.6 |

## Depth-Agreement Analysis

The critical question for S3 is whether the characteristic formula B produced by nf_characterizable_by_stavi has sufficiently small stavi_depth to transfer through tau.

**Scenario analysis**:
- If stavi_depth B <= r: phi = U(B, sf_top) has depth r+2. Transfer via tau at rank r+delta needs r+2 <= r+delta, i.e., delta >= 2. Current architecture (hd : 2 <= delta) suffices.
- If stavi_depth B = 2*r: phi has depth 2*r+2. Transfer needs 2*r+2 <= r+delta, i.e., delta >= r+2. Current delta=4 fails for r >= 3. Would need to restructure Theorem6.lean to provide larger delta.
- If stavi_depth B is unbounded: cannot transfer through tau at any fixed delta. Would need a different formula construction.

**Resolution strategy**: Phase S2.1 will establish the exact bound. If the bound is too large (> r), Phase S3.2 will use the rank_type approach from TypeFormulas.lean (which gives depth <= r by construction) instead of nf_characterizable_by_stavi. The rank_type approach requires converting a SET of formulas to a SINGLE formula, which may require Classical.choice.

**Fallback**: If neither approach yields a transferable formula, revert to the tau_left/tau_right sub-split (plan v40 R3.2 deviation) and close the 3 remaining grid dispatch sorries mechanically via task 199's grid_order_tac.

## Testing & Validation

- [ ] Phase S1: nf_characterizable_by_stavi sorry-free
- [ ] Phase S2: stavi_depth bound proved, h_surj threaded
- [ ] Phase S3: Case II sorry-free, Theorem6 sorry-free, workarounds deleted
- [ ] Phase S4: Cases III/IV sorry-free, no_gaps_discrete sorry-free, succ_cofinal chain resolved
- [ ] Phase S5: bx_completeness no sorryAx, zero build errors

## Artifacts & Outputs

- `EFGames/StaviCompleteness.lean` -- sorry-free bridge lemma and backward direction (Phase S1)
- `EFGames/StaviCompleteness.lean` -- stavi_depth bound (Phase S2)
- `Expressiveness/CaseAnalysis.lean` -- GHR93-faithful Case II with U(B,A) (Phase S3)
- `Expressiveness/Theorem6.lean` -- sorry-free rank promotion (Phase S3)
- `Expressiveness/CaseAnalysis.lean` -- Cases III/IV sorry closed (Phase S4)
- `IntegerModel/GoodStructures.lean` -- no_gaps_discrete proved (Phase S4)
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal chain resolved (Phase S4)

## Rollback/Contingency

**Phase S1 (bridge lemma)**: If closing nf_2var_from_interval_data proves harder than estimated (>500 lines), consider:
- Fallback 1: Axiomatize the bridge lemma with extensive documentation and close downstream sorries. Return to prove bridge lemma as a separate task.
- Fallback 2: Implement the GHR93 classical chain (Phases 6D/6E/6F from v40) which proves nf_characterizable_by_stavi via Cor 12.8.19 instead of direct game composition.

**Phase S3 (U(B,A) Case II)**: If the depth-agreement gap makes U(B,A) infeasible:
- Fallback: Revert to tau_left/tau_right sub-split (plan v40 R3.2) and close the 3 grid dispatch sorries via task 199's grid_order_tac. This approach works mechanically but is not GHR93-faithful.

**Phase S4 (downstream)**: If succ_cofinal is deeply blocked by omega-chain construction:
- Fallback: Task 129 (Henkin canonical model) provides an alternative path that avoids the gap entirely.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
