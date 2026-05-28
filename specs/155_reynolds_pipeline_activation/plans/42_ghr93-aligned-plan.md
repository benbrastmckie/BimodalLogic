# Implementation Plan: GHR93-Aligned Stavi Completeness + U(B,A) Case II (v42)

- **Task**: 155 - reynolds_pipeline_activation
- **Status**: [NOT STARTED]
- **Effort**: 20-35 hours
- **Dependencies**: Tasks 154, 168, 174, 199 (all COMPLETED or PARTIAL)
- **Research Inputs**: reports/40_ghr93-case-ii-step6.md, reports/41_stavi-completeness-audit.md, reports/39_game-depth-restructuring.md, reports/42_plan-literature-alignment.md
- **Artifacts**: plans/42_ghr93-aligned-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan supersedes v41 by incorporating three critical corrections from the literature-alignment review (report 42). The corrections address: (1) delta must be 4, not 2, because Cases III/IV use formulas of rank r+3; (2) A in U(B,A) is the interval type formula, not sf_top -- sf_top provides no information for Round 2 challenges; (3) B must have depth at most r, matching GHR93's X_{alpha_n}, which requires resolving the tension between nf_characterizable_by_stavi's ~2k depth output and GHR93's depth-r requirement.

The plan retains v41's two-track structure (Stavi completeness chain, then Case II rewrite) but inserts a new Phase S2.5 that closes the Theorem6.lean rank-varying IH sorry (line 325) as a prerequisite for the delta=4 architecture. Phase S3 is substantially rewritten to specify exact formulas, handle A correctly via tau's formula preservation, handle the B depth resolution via the outer-induction depth argument, and address the n=0 boundary case.

### Research Integration

- **Report 40 (GHR93 Case II step 6)**: e_n = z (Until witness), sel_pn_ord trivial, forward game NOT used for e_n.
- **Report 41 (Stavi completeness audit)**: Root sorry is nf_2var_from_interval_data. nf_characterizable_by_stavi has no stavi_depth bound. stavi_depth of output is approximately 2k.
- **Report 39 (game depth restructuring)**: SplitPointProps has delta parameter. sigma/tau at rank r+delta. Minimal delta-bump approach viable.
- **Report 42 (plan-literature alignment)**: Three critical corrections (delta=4, A=interval type, B depth resolution). Six recommendations R1-R6 all addressed in this plan.

### Prior Plan Reference

Plan v41 correctly identified the GHR93 U(B,A) approach and that e_n comes from the Until witness. However, it left three critical issues unresolved: the delta=2 vs delta=4 question, the A=sf_top error, and the B depth-agreement gap. This plan resolves all three definitively.

### Key Design Decisions (v42)

1. **delta=4 throughout** (R1, R5): The rank-varying version `ghr93_forward_to_backward_rank_varying` is the primary entry point. Theorem6.lean:325 must be closed BEFORE S3, not during it.

2. **B construction: nf_characterizable_by_stavi at depth k_nf** (R2): In the completeness proof context, the outer induction runs at depth k_nf, and r = game_depth(sig, k_nf+1) >> 2*k_nf. So nf_characterizable_by_stavi at depth k_nf gives B with stavi_depth at most 2*k_nf. Then U(B, A) has depth at most 2*k_nf + 2. Since r >> 2*k_nf, we get 2*k_nf + 2 << r + 4, and transfer through tau at rank r+4 is assured.

3. **A formula: semantic approach via tau's formula preservation** (R3, option 2): Rather than materializing A = X_{(alpha_{n-1}, alpha_n)} as a single StaviFormula (which faces the same Fintype obstacle as B), we use U(B, sf_top) as the transferred formula (which correctly gives us the witness z with B(z)), then handle Round 2 for t in (e_{n-1}, e_n) SEPARATELY using tau's formula preservation at rank r+4. Since tau preserves all depth-at-most-(r+4) formulas and r+4 >> r, tau's winning condition includes interval-type preservation for the sub-interval. This avoids constructing A as a formula while achieving the same proof-theoretic effect.

4. **n=0 boundary**: Explicitly handled. When n=0, alpha_{-1} = d_bar and e_{-1} = c. U(B, sf_top) is evaluated at d_bar (N-side), witness above c (M-side).

### Depth-Agreement Resolution

The critical tension between nf_characterizable_by_stavi's ~2k depth output and GHR93's depth-r requirement is resolved as follows.

**Context**: In the completeness proof, we work at an outer induction depth k_nf. The game rank r is defined by r = game_depth(sig, k_nf + 1). The game_depth function grows much faster than 2k (it involves Fintype.card of NormalForm sig prev 1, which grows exponentially). Therefore r >> 2*k_nf for all k_nf >= 0.

**The argument**:
- nf_characterizable_by_stavi called at depth k_nf produces B with stavi_depth(B) <= 2*k_nf (proved in Phase S2)
- phi = U(B, sf_top) has stavi_depth = stavi_depth(B) + 2 <= 2*k_nf + 2
- Transfer through tau at rank r+4 requires: stavi_depth(phi) <= r + 4
- Since r = game_depth(sig, k_nf+1) and game_depth(sig, 1) >= 2, we have r >= 2 for all k_nf >= 0
- More precisely, r >= (1 + 3*0) * (2*1) + 2 = 4 when k_nf = 0, and grows exponentially
- The inequality 2*k_nf + 2 <= r + 4 holds with massive slack for all k_nf

**What does k_nf-depth agreement buy us?** The witness z satisfies B(z), which means z has the same depth-k_nf NF as p_n. In the completeness proof context, this is sufficient because the game being played at rank r uses NormalForm at depth k_nf (via the game_depth construction), and agreement at depth k_nf implies agreement on all the formulas that matter for the backward game at rank r. This is precisely what the NormalForm/EF-game equivalence (Fraisse's theorem for US-logic) establishes: depth-k_nf NF equality implies winning Duplicator strategies for the k_nf-round game, which is the game being played.

**Documenting the gap**: Full rank-r type agreement (agreement on all depth-at-most-r formulas) is stronger than what we get. But the completeness proof only needs depth-k_nf agreement for the witness, because the backward game has k_nf rounds (not r rounds -- r is the formula depth, k_nf is the game round count). The backward game's winning condition checks agreement at depth k_nf, not depth r. This is the crucial observation that makes k_nf-depth agreement sufficient.

## Goals & Non-Goals

**Goals**:
- Close nf_2var_from_interval_data (StaviCompleteness.lean:1873)
- Close nf_exist_sf_guarded_backward (StaviCompleteness.lean:2152)
- Prove stavi_depth bound on nf_characterizable_by_stavi output
- Thread h_surj through ghr93_case_II -> ghr93_inductive_step -> Theorem6.lean
- Close Theorem6.lean:325 (rank-varying IH) -- PREREQUISITE for delta=4
- Rewrite Case II using GHR93 U(B, sf_top) construction with delta=4
- Handle Round 2 via tau's formula preservation (not via A formula)
- Handle n=0 boundary case explicitly
- Close Cases III/IV (using delta=4 for rank r+3 formula transfer)
- Close GoodStructures.lean:842 (no_gaps_discrete) and ChronicleToCountermodel sorries
- Achieve sorry-free bx_completeness

**Non-Goals**:
- Changing game_depth (confirmed unnecessary per report 39)
- Changing EFGames definitions
- Materializing A = X_{(alpha_{n-1}, alpha_n)} as a single StaviFormula (use tau's formula preservation instead)
- Dense or mixed completeness variants
- Non-critical TruthLemma sorries

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| nf_2var_from_interval_data requires 200-500 lines of game composition | H | M | Composition.lean and Decomposition.lean provide sorry-free infrastructure |
| stavi_depth bound is not provable at exactly 2*k | M | L | Any polynomial bound suffices; 2*k is the estimate, actual bound may be 2*k+1 or similar |
| Theorem6.lean:325 (rank-varying IH) is deeply entangled | H | M | This is the single most critical prerequisite; if blocked, fall back to delta=2 with tau_left/tau_right |
| h_surj threading requires signature changes in 5+ files | M | L | Mechanical change; h_surj available from ShiftAndGlue.lean |
| Round 2 semantic approach (tau formula preservation instead of A formula) requires careful game_tuple bookkeeping | M | M | tau's winning condition already includes formula agreement at all positions; the challenge is extracting interval-specific agreement |
| k_nf-depth agreement insufficient for backward game | H | L | The backward game has k_nf rounds by construction; depth-k_nf NF agreement is exactly what the k_nf-round game checks |
| Cases III/IV use formulas at rank r+3, needing delta >= 4 | H | H (certain) | delta=4 handles this; Phase S2.5 ensures delta=4 is available |
| n=0 boundary case requires separate proof branch | M | M | Explicit handling in S3; when n=0, the Until is evaluated at the left boundary d_bar/c |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | S1 | -- |
| 2 | S2 | S1 |
| 3 | S2.5 | S2 |
| 4 | S3 | S2.5 |
| 5 | S4 | S3 |
| 6 | S5 | S4 |

Phases are fully sequential. Each phase produces a compilable state.

---

### Phase S1: Close nf_2var_from_interval_data [IN PROGRESS]

**Goal**: Prove the bridge lemma (GHR93 Proposition 7 + Lemma 11): if two 2-variable environments agree on 1-variable types, ordering, interval types, and types above/below, then their 2-variable NFs are equal.

**Tasks**:
- [x] **S1.1: Read and understand the sorry site** (~0.5 hours) *(completed)*
  - Read StaviCompleteness.lean lines 1853-1873 (nf_2var_from_interval_data signature)
  - Read Composition.lean for ghr93_strategy_compose signature
  - Read Decomposition.lean for decomposition_agreement
  - Map: interval_nf_types -> decomposition_agreement -> game winning -> NF equality
- [x] **S1.1b: Build depth-decrease infrastructure** (~150 lines, NEW)
  - nf_char_depth_decrease: depth-(k+1) 1-var NF => depth-k 1-var NF
  - nf_depth_k_from_shared_succ: shared depth-(k+1) NF => depth-k agreement
  - interval_nf_types_depth_decrease: depth-(k+1) interval types => depth-k
  - above_max_depth_decrease: depth-(k+1) above-max => depth-k
  - below_min_depth_decrease: depth-(k+1) below-min => depth-k
  - All sorry-free, verified via lean_verify
- [x] **S1.1c: Prove bridge lemma atom agreement + base case** (~70 lines, NEW)
  - h_atom_agree: predicate agreement via nf_agreement_from_shared_nf
  - Order agreement via h_order_xt + Fin.cases
  - Base case k=0: direct transfer via h_atom_agree
  - Inductive step atoms: derived from depth-k hypotheses via depth_decrease
- [ ] **S1.2: Build the connection from interval_nf_types to decomposition_agreement** (~100-150 lines) *(deviation: altered -- replaced by depth-decrease approach; ExtendedCarrier bridging no longer needed)*
  - interval_nf_types gives Finset equality of realized 1-var NFs in open intervals
  - decomposition_agreement requires: for every carrier point in (lo,hi) in M, exists one in M' with same 1-var NF, and vice versa
  - Bridge: interval_nf_types equality -> for each NF type in the set, witnesses exist in both models -> decomposition_agreement
  - May need helper: `interval_nf_types_implies_decomposition` (~40-60 lines)
- [ ] **S1.3: Connect to ghr93_game_iff_decomposition** (~50-80 lines) *(deviation: blocked -- depends on S1.2)*
  - Decomposition.lean:302 gives: decomposition_agreement <-> Duplicator wins
  - Handle h_nf_x, h_nf_t, h_order_xt, h_above_max, h_below_min
- [ ] **S1.4: Prove game winning implies NF characteristic equality** (~50-100 lines) *(deviation: blocked -- this is the key missing theorem; no Fraisse-type result exists in the codebase connecting game winning to nf_characteristic equality)*
  - Game winning on 2-variable environments implies nf_characteristic equality
  - May exist in NormalForm/EFGames infrastructure; if not, prove by induction on k
- [ ] **S1.5: Assemble the full proof** (~50-100 lines) *(deviation: blocked -- depends on S1.2-S1.4)*
  - Combine S1.2 + S1.3 + S1.4
  - Handle case split on ordering (x < t vs t < x vs x = t)
  - Verify: line 1873 sorry is closed
- [ ] **S1.6: Close nf_exist_sf_guarded_backward** (~100-200 lines) *(deviation: blocked -- depends on bridge lemma; additionally, the formula nf_exist_sf_guarded may need restructuring to encode interval type data for the backward direction to be provable)*
  - Chains through bridge lemma (line 2152)
  - Extract witness, determine type, apply bridge lemma
- [ ] **S1.7: Build verification** *(deviation: blocked -- depends on S1.5-S1.6)*
  - `lake build Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness`
  - `#print axioms nf_characterizable_by_stavi` -- no sorryAx

**BLOCKER** (Phase S1):
- **What failed**: nf_2var_from_interval_data (line 1873) cannot be proved by simple induction on k. The inductive step at depth k+1 requires showing depth-k 3-variable NF agreement between (u,x,t) and (u',x',t'), which in turn requires interval type data for ALL sub-intervals including pairs involving the new witness points u/u'. The hypotheses only provide interval type data for the original pair (x,t).
- **What was tried**:
  1. Direct induction on k with `suffices nf_eval_nf M' k 2 env' (nf_char M k 2 env)`: base case (k=0) works (atoms determined by 1-var NFs + orderings). Inductive step fails because the quantifier transfer at depth k requires depth-k 3-var NF agreement, which needs interval data for (x,u), (u,t) sub-intervals at depth k -- data not available from the hypotheses.
  2. Generalized induction on k for all n: same blocking issue -- sub-interval types for pairs involving new witness points cannot be derived from the original interval data.
  3. Analysis of using game infrastructure from Decomposition.lean: the game world uses ExtendedCarrier/rank_type while the bridge lemma uses nf_characteristic/nf_eval_nf -- different type universes that would require substantial bridging code.
  4. Analysis of `nf_agreement_monotone` technique: this uses depth-k NF agreement as hypothesis (which gives existential transfer), but we're trying to PROVE the agreement, so it's circular.
- **Why it's stuck**: The proof requires a *game-theoretic back-and-forth argument* where Duplicator's strategy uses the original interval data to match witnesses at each round, and the winning condition is only checked at depth 0 (after k rounds of quantifier expansion). This fundamentally differs from a standard induction on k because intermediate states don't satisfy the bridge lemma's invariant -- only the FINAL state (depth 0, where only atoms matter) needs to be checked. Formalizing this requires either: (a) building EF-game infrastructure for the nf_characteristic/nf_eval_nf world (connecting to the existing game definitions in CustomGame.lean/Decomposition.lean which use ExtendedCarrier), or (b) a well-founded induction on (k, n_vars) where the induction peels off one quantifier round at a time, but this requires showing sub-interval type data can be derived at each step.
- **Secondary issue**: `nf_exist_sf_guarded_backward` (line 2152) may also require changes to the formula `nf_exist_sf_guarded` itself. The current formula only encodes 1-var NF type and ordering direction of the witness, but NOT the interval type sets. For k >= 1, this makes the backward direction (formula truth -> nf_eval) unprovable without additional constraints. The formula should enumerate over all valid configurations (nf_x, ordering, interval_type_set) as described in the GHR93 proof, not just (nf_x, ordering). This is an additional ~100-200 line change to the formula construction.
- **What is needed**:
  1. **Option A (recommended)**: Build a "simple EF game" framework for the NF world that connects nf_characteristic equality with a k-round back-and-forth strategy. The key theorem needed: "If Duplicator has a winning strategy for the k-round game on n-variable environments, then nf_characteristic M k n envM = nf_characteristic M' k n envN." The strategy construction from the bridge lemma hypotheses is then straightforward. Estimated: 300-500 lines of game infrastructure + 100-200 lines for the bridge lemma proof.
  2. **Option B**: Strengthen the bridge lemma's hypotheses to include interval types for ALL sub-intervals (not just the main pair). Then prove by induction on k, generalizing to all n. At each step, derive sub-interval data for new pairs from the strengthened hypotheses. Then show the original 2-variable hypotheses imply the strengthened ones for n=2 (trivially, since there's only one pair). Estimated: 200-400 lines.
  3. **Option C**: Rewrite `nf_exist_sf_guarded` to encode the full configuration (including interval types in the guard), making the backward direction provable by direct extraction. This changes the formula but avoids the bridge lemma for the backward direction. However, the bridge lemma is still needed for downstream uses.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Timing**: 4-8 hours (original estimate); revised to 15-25 hours given blocker analysis

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean`

**Verification**:
- nf_2var_from_interval_data and nf_exist_sf_guarded_backward sorry-free
- nf_characterizable_by_stavi sorry-free (lean_verify)
- StaviCompleteness.lean compiles

---

### Phase S2: Add stavi_depth bound + thread h_surj [NOT STARTED]

**Goal**: (A) Prove that nf_characterizable_by_stavi at depth k produces a formula with stavi_depth at most 2*k. (B) Thread h_surj through the theorem chain.

**Tasks**:
- [ ] **S2.1: Prove stavi_depth bound** (~80-150 lines)
  - Strengthen nf_characterizable_by_stavi (or add separate lemma):
    `exists A : StaviFormula, stavi_depth A <= 2 * k AND ...`
  - Depth analysis:
    - Base k=0: conjunction of atom literals, stavi_depth = 0 <= 0 = 2*0
    - Inductive k+1: sf_conjList of (atom_lits ++ quant_formulas)
    - Each quant_formula uses std_untl/std_snce (each adds +2)
    - Guard includes char_k formulas at depth <= f(k) (IH)
    - f(k+1) = f(k) + 2, f(0) = 0, so f(k) = 2*k
  - Prove by induction on the characterization construction
  - If exact bound 2*k is hard, any bound of the form c*k + c' suffices (the slack r >> k makes any polynomial bound work)
- [ ] **S2.2: Thread h_surj through ghr93_inductive_step** (~20-30 lines)
  - Add parameter: `(h_surj : forall p : sig.preds, exists a : Atom, atomMap (.atom a) = p)`
  - Pass through to ghr93_case_II and ghr93_cases_II_III_IV in CaseAnalysis.lean
- [ ] **S2.3: Thread h_surj through Theorem6.lean** (~20-30 lines)
  - Add h_surj to ghr93_forward_to_backward_core, ghr93_forward_to_backward, ghr93_forward_to_backward_rank_varying
  - h_surj available from ShiftAndGlue.lean's Encodable.surjective_decode_iget
- [ ] **S2.4: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6`
  - Sorry sites may shift but count should not increase

**Timing**: 2-4 hours

**Depends on**: S1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames/StaviCompleteness.lean` -- depth bound
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- h_surj in signatures
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- h_surj in signatures

**Verification**:
- stavi_depth bound proved
- h_surj available in ghr93_case_II
- All files compile

---

### Phase S2.5: Close Theorem6.lean:325 rank-varying IH [NOT STARTED]

**Goal**: Close the sorry at Theorem6.lean:325 (`ghr93_forward_to_backward_rank_varying` succ case), establishing the rank-varying induction that provides delta=4 for sigma/tau. This is the PREREQUISITE for Phase S3 -- without it, tau is at rank r+2 (insufficient for Cases III/IV).

**Tasks**:
- [ ] **S2.5.1: Analyze the sorry site** (~0.5 hours)
  - Read Theorem6.lean lines 300-370 (rank-varying version)
  - The sorry is at the succ case of the induction on n
  - The goal: given forward game at rank r+4(n+1), produce backward game at rank r
  - The IH says: forward at r+4n -> backward at r (for smaller n)
  - Need: restrict the rank-r+4(n+1) forward game to sub-intervals at rank (r+4)+4n, apply IH at base rank r+4 to get backward at r+4, then use those as sigma/tau
- [ ] **S2.5.2: Build the rank peeling argument** (~80-150 lines)
  - The forward game at rank r+4(n+1) = (r+4) + 4n on the full interval gives:
  - Sub-interval forward games at rank (r+4) + 4n via Claim 2 / SplitPointProps
  - Apply the IH at base rank r+4: forward at (r+4)+4n -> backward at r+4
  - This gives sigma at rank r+4 and tau at rank r+4
  - Key: the IH must be invoked at the right rank. The recurrence is:
    `(**)_{n+1}(r)` uses `(**)_n(r+4)` where `(**)_n(s)` = forward at s+4n -> backward at s
  - In Lean: the induction variable is n, and the rank parameter r appears in the statement
  - The succ case must show: forward at r+4(n+1) -> backward at r
  - Using IH: forward at (r+4)+4n -> backward at (r+4)
  - So we need to extract sub-interval forward games at rank r+4(n+1) = (r+4)+4n and apply IH
- [ ] **S2.5.3: Connect to SplitPointProps at delta=4** (~50-80 lines)
  - SplitPointProps already has the delta parameter
  - With the IH producing backward games at rank r+4, set delta=4 in SplitPointProps
  - sigma/tau at rank r+4 (not r+2)
  - This may require updating obtain_split_point_props to accept the higher-rank IH
- [ ] **S2.5.4: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6`
  - Line 325 sorry should be closed
  - Remaining sorry: possibly line 124 (the uniform-rank version) -- may be deferred since the rank-varying version is the primary entry point

**Timing**: 3-6 hours

**Depends on**: S2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- close rank-varying IH
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/SplitPoint.lean` -- possibly update obtain_split_point_props

**Verification**:
- Theorem6.lean:325 sorry closed
- ghr93_forward_to_backward_rank_varying fully proved (no sorryAx)
- sigma/tau demonstrably at rank r+4 in the downstream usage

---

### Phase S3: Rewrite Case II using GHR93 U(B,A) construction [NOT STARTED]

**Goal**: Replace the current tau_left/tau_right Case II proof with the GHR93 construction: build B via nf_characterizable_by_stavi at depth k_nf, form phi = U(B, sf_top), transfer through tau at rank r+4, extract witness z = e_n, and prove the winning condition using tau's formula preservation for Round 2.

**Design**: This phase uses U(B, sf_top) rather than U(B, A) where A = X_{(alpha_{n-1}, alpha_n)}, because materializing A as a single StaviFormula faces the same non-Fintype obstacle as a depth-r flat conjunction. The sf_top simplification is compensated by handling Round 2 directly from tau's formula preservation at rank r+4 (which preserves all depth-at-most-(r+4) formulas, including all depth-at-most-r type formulas that encode interval-type information).

**Tasks**:
- [ ] **S3.1: Build B_pn via nf_characterizable_by_stavi** (~40-60 lines)
  - p_n = a_bwd(n) is a carrier point in N
  - Compute nf_pn = nf_characteristic N k_nf 1 (fun _ => p_n_carrier)
  - Apply nf_characterizable_by_stavi atomMap h_surj k_nf nf_pn to get B_pn : StaviFormula
  - From S2.1: stavi_depth B_pn <= 2*k_nf
  - B_pn characterizes p_n's depth-k_nf NF: for any q, stavi_temporal_truth N atomMap q B_pn <-> nf_eval_nf N k_nf 1 (fun _ => q) nf_pn
  - **Depth check**: stavi_depth(B_pn) <= 2*k_nf. phi = U(B_pn, sf_top) has depth 2*k_nf + 2. Need 2*k_nf + 2 <= r + 4. Since r = game_depth(sig, k_nf+1) >= 4 for k_nf=0 and grows exponentially, this holds with massive slack.
- [ ] **S3.2: Build phi = U(B_pn, sf_top) and establish phi at a_init(n-1)** (~30-50 lines)
  - phi = StaviFormula.std_untl B_pn StaviFormula.sf_top
  - stavi_depth phi = max(stavi_depth B_pn, 0) + 2 <= 2*k_nf + 2
  - N |= U(B, sf_top)(a_init(n-1)):
    - p_n = a_bwd(n) > a_init(n-1) (from sorted selections and SplitPointProps structure)
    - B_pn holds at p_n (by construction)
    - sf_top holds at all intermediate points trivially
  - **n=0 boundary**: When n=0, a_init has no (n-1)-th element. Use the left boundary d_bar (in N) as the reference point. In the Lean code, this corresponds to the `x'` parameter of SplitPointProps. Specifically:
    - If n=0: phi is U(B_p0, sf_top), evaluated at x' (= d_bar in GHR93)
    - p_0 = a_bwd(0) > x' (from SplitPointProps ordering)
    - Transfer target: resp_tau maps x' to x, so U(B_p0, sf_top) holds at x in M
  - **n>0 boundary**: Standard case. a_init(n-1) maps through tau to resp_tau(n-1) = e_{n-1}.
- [ ] **S3.3: Transfer phi through tau and extract witness** (~60-100 lines)
  - tau operates at rank r+4 (guaranteed by S2.5) on rank-embedded positions
  - phi at depth 2*k_nf + 2. Since r+4 >= 2*k_nf + 2 (from depth analysis), phi is within tau's formula preservation range
  - Transfer: phi holds at a_init(n-1) in N -> phi holds at resp_tau(n-1) in M
  - For n=0: phi holds at x' in N -> phi holds at x in M (x = resp_tau applied to x')
  - Unpack Until: exists z > resp_tau(n-1) [or z > x for n=0] with B_pn(z) in M, and sf_top at all intermediate points
  - Extract z; set e_n = z
  - e_n has the same depth-k_nf NF as p_n (from B_pn(z))
- [ ] **S3.4: Prove sel_pn_ord trivially** (~20-30 lines)
  - For all k < n: resp_tau(k) <= resp_tau(n-1) (tau preserves order since a_init(k) < a_init(n-1))
  - resp_tau(n-1) < z = e_n (defining property of Until witness)
  - Chain: resp_tau(k) <= resp_tau(n-1) < e_n
  - For n=0: there are no k < 0, so sel_pn_ord is vacuously true
- [ ] **S3.5: Build the response function and Round 2 winning condition** (~150-250 lines)
  - **Response function**: resp(k) = resp_tau(k) for k < n, resp(n) = e_n
  - **Round 2 winning condition** -- case split on Spoiler's challenge position t:
    - **(a) t in (resp_tau(k), resp_tau(k+1)) for some k < n-1**: Use tau's Round 2 winning condition directly. tau already provides Duplicator's response for this sub-interval.
    - **(b) t in (resp_tau(n-1), e_n)** [key sub-case, replaces A formula]:
      - Use tau's formula preservation at rank r+4: tau preserves all depth-at-most-(r+4) formulas.
      - The depth-k_nf type of t is a formula of depth at most 2*k_nf <= r+4.
      - Since tau's winning condition gives formula agreement at rank r+4 for the entire interval (d_bar, y') in N vs (c, y) in M, and both resp_tau(n-1) and e_n are in (c, y), the interval (resp_tau(n-1), e_n) in M has the same realized depth-k_nf types as some sub-interval of (d_bar, y') in N.
      - More precisely: resp_tau(n-1) corresponds to a_init(n-1) in N, and e_n is below some point in (a_init(n-1), y'). The interval (a_init(n-1), a_bwd(n)) in N provides witnesses.
      - For any t in (resp_tau(n-1), e_n) with M |= phi(t) for some depth-at-most-k_nf formula phi: find t' in (a_init(n-1), a_bwd(n)) in N with the same k_nf-type. This follows from tau's interval-type preservation (which preserves all depth-at-most-(r+4) formulas, hence all depth-at-most-k_nf formulas).
      - **Key lemma needed**: `tau_interval_type_transfer` -- from tau's winning condition, derive that realized k_nf-types in (resp_tau(n-1), resp_tau(n-1) + epsilon) in M agree with realized k_nf-types in (a_init(n-1), a_init(n-1) + epsilon) in N. This is a consequence of tau's formula agreement at rank r+4.
    - **(c) t > e_n**: Use tau's winning condition for the remaining interval (e_n, y) in M vs (a_bwd(n), y') in N. tau's formula preservation covers this region.
    - **(d) t at e_n / resp_tau(k)**: Point formula agreement from B_pn (for e_n) and tau (for resp_tau(k)).
    - **(e) t outside [x, y]**: Handled by sigma/tau endpoint conditions.
  - **Assemble** the full backward game winning condition from (a)-(e).
- [ ] **S3.6: Delete old tau_left/tau_right infrastructure** (~negative lines)
  - Delete tau_left, tau_right, resp_left, resp_mod constructions
  - Delete tau_composed, hord_left_*, hord_right_* ordering lemmas
  - Delete Case B1/B2 sub-split
  - Clean up dead code
- [ ] **S3.7: Close Theorem6.lean:124 (uniform-rank version)** (~40-80 lines)
  - With the rank-varying version fully proved (S2.5), the uniform-rank version at delta=2 may be dispensable.
  - If it is still referenced: prove it as a corollary of the rank-varying version by specializing delta=0 and using rank_down.
  - If unreferenced: mark as deprecated or remove.
- [ ] **S3.8: Build verification**
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.CaseAnalysis`
  - `lake build Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6`
  - Case II sorry count should drop to 0
  - Theorem6 sorry count should drop to 0

**Timing**: 8-12 hours

**Depends on**: S2.5

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/CaseAnalysis.lean` -- rewrite ghr93_case_II
- `Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/Theorem6.lean` -- close line 124

**Verification**:
- CaseAnalysis.lean Case II sorry-free
- Theorem6.lean sorry-free
- sel_pn_ord proved trivially
- tau_left/tau_right infrastructure deleted

---

### Phase S4: Close remaining sorries (Cases III/IV + downstream) [NOT STARTED]

**Goal**: Close Cases III/IV winning condition (CaseAnalysis.lean:3350), close GoodStructures.lean:842 (no_gaps_discrete), and close ChronicleToCountermodel.lean sorries.

**Design note (R6 addressed)**: Cases III/IV use formulas of rank up to r+3:
- Case III: left(B, D) at rank r+2, then U(left(B,D), A) at rank r+3
- Case IV: compound formula at rank r+3

With tau at rank r+4 (from S2.5), transfer of rank-(r+3) formulas succeeds: r+3 <= r+4. This was impossible with delta=2.

**Tasks**:
- [ ] **S4.1: Close Cases III/IV winning condition** (~100-200 lines)
  - CaseAnalysis.lean:3350 -- inside ghr93_cases_III_IV
  - Cases III/IV handle when a_bwd(n) is a gap (not a carrier point)
  - Gap detection infrastructure is complete (GapDetection.lean, 5057 lines, sorry-free)
  - With delta=4: left(B,D) at depth r+2 and U(left(B,D), A) at depth r+3 transfer through tau at rank r+4
  - The winning condition assembly mirrors Case II:
    - Ordering: from tau + d-compat + gap interval membership
    - Gap point agreement: from tau + GapDetection S11.2
    - Formula agreement: from tau + GapDetection S11.1
  - Case IV uses right(B, D) and a compound formula at rank r+3, same transfer argument
- [ ] **S4.2: Close no_gaps_discrete (Reynolds Theorem 5)** (~150-300 lines)
  - GoodStructures.lean:842 -- requires stavi_expressive_completeness (sorry-free after S1)
  - Proof structure from comments:
    1. Define rho via k-type characterization
    2. Apply Theorem 5 to get temporal formula R
    3. Derive structural properties via h_prior_UZ and h_prior_SZ
    4. Show model surgery preserves temporal truth
    5. Derive contradiction
  - May require the classical chain (Cor 12.8.19) -- if so, add as sub-tasks
- [ ] **S4.3: Close ChronicleToCountermodel boundary sorries** (~100-200 lines)
  - Line 1285: boundary above-max for succ_cofinal
  - Line 1441: below-min boundary
  - Line 1508: limit_dom_points_are_succ_iterates
  - Line 1885: succ_cofinal (root sorry for discrete completeness)
  - All four form a chain: 1285/1441 are sub-cases, 1508 uses them, 1885 is the root
  - With no_gaps_discrete proved (S4.2), gap elimination may simplify succ_cofinal
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

**Goal**: Full build, sorry audit, axiom check.

**Tasks**:
- [ ] **S5.1: Full lake build**
  - `lake build` passes with zero errors
- [ ] **S5.2: Axiom audit**
  - `#print axioms bx_completeness` -- only propext, Classical.choice, Quot.sound
  - `#print axioms nf_characterizable_by_stavi` -- no sorryAx
  - `#print axioms stavi_expressive_completeness` -- no sorryAx
- [ ] **S5.3: Sorry audit**
  - `grep -rn sorry Theories/Bimodal/Metalogic/WeakCanonical/`
  - `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`
  - Classify: critical-path, non-critical, dead-code
- [ ] **S5.4: Clean up workaround remnants**
  - `grep -rn 'char_k\|tau_r2\|h_ih_r2\|resp_mod\|tau_left\|resp_left' Theories/Bimodal/Metalogic/WeakCanonical/Expressiveness/` -- should return empty
  - Confirm all workaround code deleted

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
| Theorem6.lean | 325 | Rank promotion succ case | Strategy restriction | S2.5 |
| CaseAnalysis.lean | 2026 | Case B1 grid edge | Ordering dispatch | S3 (replaced) |
| CaseAnalysis.lean | 2107 | Case B2 ordering | Grid dispatch | S3 (replaced) |
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

## Literature Alignment Verification (report 42 recommendations)

| Rec | Description | Status in v42 |
|-----|-------------|---------------|
| R1 | Commit to delta=4 | ADDRESSED: Phase S2.5 closes Theorem6.lean:325 as prerequisite; delta=4 throughout |
| R2 | Resolve B-formula construction | ADDRESSED: Use nf_characterizable_by_stavi at depth k_nf (not r); depth-agreement resolution documented in Overview |
| R3 | Fix A=sf_top to A=interval type | ADDRESSED: Use U(B, sf_top) but handle Round 2 via tau's formula preservation (semantic approach, R3 option 2) |
| R4 | Address n=0 boundary | ADDRESSED: Explicit handling in S3.2 and S3.4 |
| R5 | Reorder Theorem6.lean:325 | ADDRESSED: New Phase S2.5, prerequisite for S3 |
| R6 | Verify Cases III/IV rank requirements | ADDRESSED: S4.1 explicitly notes rank r+3 formulas transfer through tau at r+4 |

## Testing & Validation

- [ ] Phase S1: nf_characterizable_by_stavi sorry-free
- [ ] Phase S2: stavi_depth bound proved, h_surj threaded
- [ ] Phase S2.5: Theorem6.lean:325 closed, rank-varying version proved
- [ ] Phase S3: Case II sorry-free, Theorem6 sorry-free, workarounds deleted
- [ ] Phase S4: Cases III/IV sorry-free, no_gaps_discrete sorry-free, succ_cofinal chain resolved
- [ ] Phase S5: bx_completeness no sorryAx, zero build errors

## Artifacts & Outputs

- `EFGames/StaviCompleteness.lean` -- sorry-free bridge lemma and backward direction (S1)
- `EFGames/StaviCompleteness.lean` -- stavi_depth bound (S2)
- `Expressiveness/Theorem6.lean` -- sorry-free rank-varying IH (S2.5)
- `Expressiveness/CaseAnalysis.lean` -- GHR93-faithful Case II with U(B,sf_top) + semantic Round 2 (S3)
- `Expressiveness/Theorem6.lean` -- fully sorry-free (S3)
- `Expressiveness/CaseAnalysis.lean` -- Cases III/IV sorry closed (S4)
- `IntegerModel/GoodStructures.lean` -- no_gaps_discrete proved (S4)
- `BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- succ_cofinal chain resolved (S4)

## Rollback/Contingency

**Phase S1 (bridge lemma)**: If closing nf_2var_from_interval_data exceeds 500 lines:
- Fallback 1: Axiomatize the bridge lemma and close downstream sorries.
- Fallback 2: GHR93 classical chain (Cor 12.8.19).

**Phase S2.5 (rank-varying IH)**: If Theorem6.lean:325 is deeply blocked:
- Fallback: Accept delta=2, use tau_left/tau_right for Case II (plan v40 approach), close grid dispatch sorries via task 199. This produces a working but non-GHR93-faithful proof.

**Phase S3 (U(B,A) Case II)**: If Round 2 via tau's formula preservation is harder than expected:
- Fallback 1: Materialize A using Classical.choice on the existence of a conjunction (mathematically justified by finite equivalence classes).
- Fallback 2: Revert to tau_left/tau_right (plan v40).

**Phase S4 (downstream)**: If succ_cofinal is deeply blocked:
- Fallback: Task 129 (Henkin canonical model) provides an alternative path.

**General**: All changes committed after each phase. Git history enables rollback to any phase boundary.
