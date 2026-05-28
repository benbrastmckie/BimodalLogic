# Deep Review: Plan v42 (GHR93-Aligned Stavi Completeness + U(B,A) Case II)

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Scope**: Phase-by-phase assessment against 12 research reports, 3 handoffs, and current codebase state
**Input**: `plans/42_ghr93-aligned-plan.md`, reports 36-46, handoffs S1/S3/case-II-ghr93

---

## Executive Summary

Plan v42 correctly identifies the GHR93 U(B,A) construction as the right approach and correctly addresses the three critical corrections from report 42 (delta=4, A != sf_top, B depth resolution). However, it has a **fatal dependency on Phase S1 (bridge lemma)** that 6+ sessions have proven is not closeable in the near term, and report 46 conclusively shows it is NOT on the critical path for `bx_completeness`. The plan's sequential S1 -> S2 -> S2.5 -> S3 -> S4 -> S5 dependency chain means the entire plan is blocked at wave 1.

**The plan needs a structural reorganization** that defers S1 and begins with the actual critical path: Theorem6.lean:325 (rank-varying IH) -> Case II rewrite -> Cases III/IV -> downstream sorries. The bridge lemma should be moved to a separate task.

---

## Phase-by-Phase Assessment

### Phase S1: Close nf_2var_from_interval_data -- REMOVE FROM PLAN

**Plan says**: Close the bridge lemma (15-25 hours, 400-600 new lines). Wave 1 (no dependencies).

**Reality**:
- 6 implementation sessions failed to close it (S1-S4 handoffs document exhaustive analysis)
- Root cause is a **semantic mismatch**: `interval_nf_types` (Finset of 1-var NFs) loses spatial arrangement information needed for the 4-var existential transfer
- Report 44 (literature-interval-splitting) confirms: GHR93 proves this by going THROUGH the EF game, not by NF induction. The Lean code attempts a shortcut that the literature never uses.
- Handoff S3 identifies the formula-level encoding fix (enriching `nf_exist_sf_guarded` with interval configs) as the only viable path, estimating 390-610 additional lines
- **Report 46 (strategic pivot)** is the definitive finding: the bridge lemma is NOT on the critical path for `bx_completeness`. CaseAnalysis.lean does NOT import StaviCompleteness.lean. The bridge lemma feeds `nf_characterizable_by_stavi`, which feeds the characteristic formula B, but the Case II construction can bypass this entirely.

**The plan marks S1 as [BLOCKED] but still places it at wave 1, blocking ALL downstream phases.** This is the plan's structural flaw.

**Recommendation**: **REMOVE** Phase S1 from plan v43. Create a separate task for the bridge lemma (StaviCompleteness sorry elimination). It is mathematically important for `stavi_expressive_completeness` but not for `bx_completeness`.

**Status**: REMOVE (defer to new task)

---

### Phase S2: Add stavi_depth bound + thread h_surj -- PARTIALLY SURVIVES

**Plan says**: (A) Prove stavi_depth bound on nf_characterizable_by_stavi output (80-150 lines). (B) Thread h_surj through ghr93_inductive_step and Theorem6.lean (40-60 lines). Depends on S1. 2-4 hours.

**Assessment by sub-task**:

**S2.1 (stavi_depth bound)**: Report 46 says bypass `nf_characterizable_by_stavi` entirely and construct X_t directly from depth-<=r StaviFormulas. If we bypass nf_characterizable_by_stavi, the stavi_depth bound on its output becomes irrelevant.

However, the bypass itself is non-trivial. Report 45 (semantic vs syntactic B) identifies the core tension: GHR93 uses B = X_{a_n} as a syntactic formula (conjunction of all rank-r formulas true at a_n), with stavi_depth exactly r. In the Lean formalization, constructing this formula requires enumerating depth-<=r StaviFormulas, which is impossible because StaviFormula is not Fintype. The only viable routes are:
1. Go through `nf_characterizable_by_stavi` (requires the bridge lemma -- circular)
2. Use `Classical.choice` on the existence of a representing formula per NF class (requires proving such a formula exists at depth <= r, which IS `nf_characterizable_by_stavi`)
3. Use `rank_type` semantically without materializing B (report 46 recommends this)

**This is the deepest unresolved question in the entire plan.** See Section "The B Formula Construction Problem" below.

**S2.2-S2.3 (h_surj threading)**: Still needed IF the approach uses `nf_characterizable_by_stavi`. Not needed if the approach is purely semantic. In either case, this is mechanical (~40-60 lines).

**Recommendation**: S2.1 needs rethinking based on the B formula resolution. S2.2-S2.3 can proceed independently. **MODIFY** to decouple h_surj threading from the stavi_depth bound.

**Status**: MODIFY (h_surj threading survives; stavi_depth bound depends on B construction decision)

---

### Phase S2.5: Close Theorem6.lean:325 rank-varying IH -- KEEP, PROMOTE TO WAVE 1

**Plan says**: Close the sorry at Theorem6.lean:325 (rank-varying IH succ case). 3-6 hours. Depends on S2.

**Assessment**: This phase is **correctly identified as the critical prerequisite for delta=4**. Without it, sigma/tau are at most at delta=2 (from the uniform-rank version), which is insufficient for Cases III/IV (rank r+3 formulas need tau at rank >= r+4).

Report 39 (game-depth-restructuring) provides the detailed analysis: the current code flattens ranks too early. The fix is to carry the rank offset through the induction so sigma/tau end up at rank r+4. This is architectural but localized to Theorem6.lean and SplitPoint.lean.

**However, the dependency on S2 is wrong.** Theorem6.lean:325 does not depend on the stavi_depth bound or h_surj threading. The rank-varying IH is a pure game-theoretic argument about strategy restriction from rank r+4(n+1) to rank (r+4)+4n on sub-intervals.

**Recommendation**: **KEEP** and promote to wave 1 (no dependencies). This is the true starting point of the critical path.

**Status**: KEEP (promote to wave 1, remove dependency on S2)

---

### Phase S3: Rewrite Case II using GHR93 U(B,A) construction -- MAJOR RESTRUCTURING NEEDED

**Plan says**: Build B via nf_characterizable_by_stavi at depth k_nf, form phi = U(B, sf_top), transfer through tau at rank r+4, extract witness z = e_n. 8-12 hours. Depends on S2.5.

**Assessment per sub-task**:

**S3.1 (Build B_pn)**: The plan uses `nf_characterizable_by_stavi atomMap h_surj k_nf nf_pn` to get B_pn. This requires:
- `nf_characterizable_by_stavi` to be sorry-free (blocked by S1)
- h_surj to be threaded (S2.2-S2.3)

Report 46 proposes bypassing nf_characterizable_by_stavi. But as analyzed above, the bypass has its own difficulties. The plan's fallback (working semantically via tau's formula preservation) is described in S3.5 but not fully formalized.

**S3.2 (Build phi = U(B_pn, sf_top))**: Plan v42 addresses report 42's A=sf_top criticism by using U(B, sf_top) but handling Round 2 via tau's formula preservation. This is the "semantic approach to A" (report 42 R3 option 2).

Report 45 confirms: GHR93 uses A syntactically (A = X_{(alpha_{n-1}, alpha_n)}, the interval type formula). Using sf_top instead means the Until formula provides no information about intermediate points, and Round 2 must be handled entirely through tau. This IS viable (tau at rank r+4 preserves all depth-<=r+4 formulas, which includes interval-type information), but the plan's description of HOW this works (S3.5 case (b)) is vague. The "key lemma needed" `tau_interval_type_transfer` is not formalized or even precisely stated.

**S3.3 (Transfer phi through tau)**: Correct in principle. With delta=4 (from S2.5), tau at rank r+4 can transfer phi at depth <= r+2. The arithmetic works.

**S3.4 (sel_pn_ord)**: Correctly identified as trivial from the construction: resp_tau(k) <= resp_tau(n-1) < z = e_n. This is confirmed by reports 37, 40.

**S3.5 (Round 2 winning condition)**: This is the most complex and least well-specified part of the plan. The 5-way case split is correct in structure but case (b) (challenge in (resp_tau(n-1), e_n)) requires tau's interval-type preservation, which has not been formally stated. The handoff case-II-ghr93 notes a "Step 6 gap" in exactly this area.

**S3.6 (Delete old infrastructure)**: Correct. tau_left/tau_right/resp_mod/same_side are all superseded.

**S3.7 (Close Theorem6.lean:124)**: If the rank-varying version (S2.5) is the primary entry point, the uniform-rank version at line 124 can be proved as a corollary or deprecated. Low risk.

**Recommendation**: S3 needs restructuring around the B formula decision. If B requires nf_characterizable_by_stavi, S3 is blocked. If B can be constructed differently, the whole approach changes. See "The B Formula Construction Problem" below.

**Status**: MAJOR RESTRUCTURING NEEDED

---

### Phase S4: Close remaining sorries (Cases III/IV + downstream) -- KEEP, NEEDS B FORMULA TOO

**Plan says**: Close Cases III/IV (CaseAnalysis.lean:3350), no_gaps_discrete (GoodStructures.lean:842), ChronicleToCountermodel sorries. 4-8 hours. Depends on S3.

**Assessment**:

**S4.1 (Cases III/IV)**: Report 42 confirms Cases III/IV use formulas of rank up to r+3:
- Case III: left(B, D) at rank r+2, then U(left(B,D), A) at rank r+3
- Case IV: compound formula at rank r+3

With delta=4, tau at r+4 >= r+3, so transfer works. The plan correctly identifies this.

**However**, Cases III/IV also need the characteristic formula construction (B and D are Stavi formulas). The same B formula problem applies here. Additionally, the gap detection infrastructure (GapDetection.lean, 5057 lines, sorry-free) needs to interface with the Case III/IV formulas.

**S4.2 (no_gaps_discrete)**: GoodStructures.lean:842 requires `stavi_expressive_completeness`, which depends on the bridge lemma (Phase S1). **If S1 is removed, this sorry cannot be closed via the planned path.**

Wait -- let me re-examine. The plan says no_gaps_discrete requires "stavi_expressive_completeness (sorry-free after S1)". But report 41 says stavi_expressive_completeness depends on nf_characterizable_by_stavi which depends on the bridge lemma. So:

**no_gaps_discrete IS blocked by the bridge lemma (S1).**

This is a critical finding: if the bridge lemma is deferred, then no_gaps_discrete remains sorry'd. We need to check whether no_gaps_discrete is on the critical path for bx_completeness.

**S4.3 (ChronicleToCountermodel sorries)**: Lines 1285, 1441, 1508, 1885 form a chain rooted at `succ_cofinal`. The plan says "With no_gaps_discrete proved (S4.2), gap elimination may simplify succ_cofinal." If no_gaps_discrete is deferred, the ChronicleToCountermodel chain may also be deferred.

The task description says: "Replace the chronicle fallback in Transfer.lean with the full Reynolds Theorem 15 pipeline, eliminating `succ_cofinal` from `bx_completeness`." This suggests the goal is to BYPASS succ_cofinal, not close it. The Reynolds pipeline should provide a sorry-free path that avoids the chronicle construction entirely.

**Recommendation**: S4 needs re-examination based on which sorry-free path actually feeds bx_completeness. The Reynolds pipeline may bypass some of these sorries rather than closing them directly.

**Status**: KEEP with modifications; needs dependency re-examination

---

### Phase S5: Final Verification -- KEEP

**Plan says**: Full build, sorry audit, axiom check. 0.5-1 hour. Depends on S4.

**Assessment**: Correct as written. The verification targets (bx_completeness no sorryAx, zero build errors) are the right ones.

**Status**: KEEP (no changes needed)

---

## The B Formula Construction Problem

This is the single most important unresolved question. Every approach has tradeoffs:

### Option 1: Through nf_characterizable_by_stavi (plan v42's approach)

- Requires the bridge lemma (S1) to be sorry-free
- Produces B with stavi_depth ~ 2*k_nf, not r
- Plan v42 argues k_nf-depth agreement suffices because "the backward game has k_nf rounds" (Overview lines 45-56)
- Report 38 challenges this: the winning condition requires rank-r agreement, not just k_nf-depth agreement
- **Verdict**: Blocked by S1 and has the depth-agreement gap

### Option 2: Direct X_t from depth-<=r StaviFormulas (report 46's recommendation)

- Bypass nf_characterizable_by_stavi
- Enumerate NormalForm sig r 1 (Fintype) -> for each NF, need a StaviFormula of depth <= r characterizing it
- Proving existence of such a formula at depth <= r IS nf_characterizable_by_stavi (circular)
- **Verdict**: Same blocker as Option 1, just repackaged

### Option 3: Semantic approach (avoid materializing B entirely)

- Report 46 Section 4 "Phase 2" and plan v42 Section "Key Design Decisions" #3
- Use tau's formula preservation at rank r+4 directly
- For any depth-<=r formula phi: phi holds at a_init(n-1) in N iff phi holds at resp_tau(n-1) in M
- In particular: U(phi, psi) for depth-<=r phi and psi transfers through tau
- The "B" is not a specific formula but the predicate "has the same rank-r type as p_n"
- Can we express "exists z > resp_tau(n-1) with the same rank-r type as p_n" semantically?
- YES: for each depth-<=r formula phi true at p_n, U(phi, sf_top) holds at a_init(n-1) (witnessed by p_n). Transfer through tau: U(phi, sf_top) holds at resp_tau(n-1). So there exists z_phi > resp_tau(n-1) with phi(z_phi). But different phi's may give different z_phi's!
- Need ALL formulas to hold at a SINGLE point z. This requires the conjunction X_t, bringing us back to the formula construction problem.
- **Verdict**: Does not fully escape the materialization requirement

### Option 4: Use the forward game directly (current code's approach)

- CaseAnalysis.lean currently constructs e_n via the d-compatible forward game (lines 1240-1550)
- This produces a witness with rank-r formula agreement from the game's winning condition
- sel_pn_ord is the blocker (the "fan problem" -- two independent game responses whose relationship is unproven)
- Report 37 shows sorting alone doesn't fix sel_pn_ord
- Report 40 confirms GHR93 does NOT use this approach
- **Verdict**: Known to be architecturally wrong; accumulated 600+ lines of unsuccessful workarounds

### Option 5: Axiomatize the characteristic formula existence

- Add an axiom or sorry: "for each NF at depth k, there exists a StaviFormula of depth <= 2*k characterizing it"
- This is nf_characterizable_by_stavi with sorry, which already exists in the codebase
- Use the sorry'd version to construct B
- **Verdict**: Violates zero-debt policy but IS the current state of the code. If the task goal is "bx_completeness has no sorryAx," then a sorry in StaviCompleteness that doesn't feed into bx_completeness is acceptable.

### Recommended Resolution

**Option 5 is the pragmatic answer.** The key question from the task description is: does `nf_characterizable_by_stavi` (with its sorry) appear in the axiom chain of `bx_completeness`?

Report 41 Section 7 states: "CaseAnalysis.lean does NOT import StaviCompleteness.lean." Report 41 Section 8: "The current Case II implementation does NOT use nf_characterizable_by_stavi and does NOT need it."

**Therefore**: If Case II is rewritten to use `nf_characterizable_by_stavi` (as plan v42 proposes), it WOULD put the sorry on the critical path, creating a new blocker. This is counterproductive.

**The correct approach**: Keep Case II independent of StaviCompleteness.lean. Use the forward game for e_n construction (Option 4), but fix the ordering problem by:
1. Adding sorting (report 37) to ensure a_bwd(n) is the maximum
2. Restructuring the proof to use tau at rank r+4 (delta=4 from S2.5) for formula transfer
3. Using the forward game at rank r+4(n+1) (which the rank-varying IH provides) to construct e_n with rank-(r+4) formula agreement with p_n
4. Since e_n has rank-(r+4) agreement with p_n (from the forward game) and tau preserves rank-(r+4) formulas, ALL ordering and agreement properties follow from the game infrastructure alone

Wait -- this brings us back to the forward game approach, which was the original architecture. The question is whether the fan problem (sel_pn_ord) can be solved with delta=4.

With delta=4 and sorted selections:
- tau at rank r+4 gives resp_tau(k) responses
- The forward game at rank r+4(n+1) gives e_n with rank-(r+4) agreement with p_n
- BUT: e_n comes from the forward game, resp_tau(k) from tau. These are independent game responses.
- sel_pn_ord requires: resp_tau(k) < e_n iff a_init(k) < p_n
- With sorted selections: a_init(k) < p_n for all k < n (from monotonicity)
- So we need: resp_tau(k) < e_n for all k < n

The GHR93 approach gives this by CONSTRUCTION (e_n is the Until witness above resp_tau(n-1)). The forward-game approach does NOT give this by construction -- e_n comes from a different game than resp_tau.

**Final verdict**: The GHR93 U(B,A) approach IS the correct architecture. The question is how to materialize B. There are exactly two viable paths:

**Path A (GHR93-faithful, requires StaviCompleteness sorry)**: Use `nf_characterizable_by_stavi` (with its sorry) to construct B. This puts sorryAx in the chain. But if `nf_characterizable_by_stavi` is on the import path of bx_completeness's theorem chain, this creates a new sorryAx.

**Path B (Semantic B via game infrastructure)**: Instead of materializing B as a single formula, prove the EXISTENCE of e_n directly from the game. Specifically:
- tau at rank r+4 preserves all depth-<=r+4 formulas
- For EACH individual depth-<=r formula phi true at p_n: U(phi, sf_top) holds at a_init(n-1), transfers through tau, giving z_phi > resp_tau(n-1) with phi(z_phi)
- By compactness/finiteness: since NormalForm sig r 1 is Fintype, there are finitely many distinct rank-r types. The set of formulas defining p_n's type is finite (one per NF class). Take z to be the MINIMUM of the z_phi witnesses (or use the finite intersection property).
- Actually, the correct argument is simpler: the conjunction of finitely many U(phi_i, sf_top) formulas can be rewritten as a SINGLE formula that implies the existence of a point satisfying ALL phi_i. This uses the fact that in a dense linear order... but the order may not be dense.

In a discrete order, the argument is different. The conjunction of U(phi_1, sf_top), ..., U(phi_N, sf_top) does NOT imply the existence of a single point satisfying all phi_i. Each Until gives a different witness, and these witnesses may be at different positions.

**This means Option 3 (semantic) genuinely fails in the discrete case.** We need a SINGLE formula B, not individual phi's.

**Therefore, we must materialize B.** The question is: can we avoid the StaviCompleteness sorry?

**The answer is in TypeFormulas.lean.** The `rank_type` construction already provides the semantic content. What we need is to convert this to a syntactic formula. Since `NormalForm sig r 1` is Fintype, we can enumerate all depth-r 1-var NFs. For each NF `nf`, `nf_characterizable_by_stavi atomMap h_surj r nf` gives a StaviFormula. Even though this has a sorry (from the bridge lemma), the sorry is in StaviCompleteness.lean, not in CaseAnalysis.lean.

**Key insight**: If CaseAnalysis.lean imports StaviCompleteness.lean and uses `nf_characterizable_by_stavi`, the sorry propagates into the axiom chain of bx_completeness. If CaseAnalysis.lean does NOT import StaviCompleteness.lean, the sorry stays isolated.

The architecture decision is: **should CaseAnalysis.lean import StaviCompleteness.lean?**

Currently it does not. Adding the import would put the sorry on the critical path. But the MATHEMATICAL content is correct -- the sorry is in a genuine theorem that WILL eventually be proved.

**Pragmatic recommendation**: Accept the sorry propagation temporarily. The bridge lemma sorry in StaviCompleteness is genuine mathematics (not a bug), and the U(B,A) approach is the correct architecture. Mark this as a KNOWN dependency with a clear plan to resolve (separate task for bridge lemma). This is preferable to maintaining the current broken architecture (forward-game e_n with unsolvable sel_pn_ord).

---

## The "A" Formula Question

Plan v42 uses A = sf_top and handles Round 2 via tau's formula preservation. Reports 42 and 45 say this is incorrect -- GHR93 uses A = X_{(alpha_{n-1}, alpha_n)} syntactically.

**Assessment**: The sf_top approach IS viable but makes the Round 2 proof harder. With A = sf_top, the Until witness z satisfies B(z) but we have no information about points between resp_tau(n-1) and z. Round 2 for challenges in this interval must come entirely from tau's formula preservation.

With tau at rank r+4 and the interval (a_init(n-1), p_n) in N corresponding to (resp_tau(n-1), e_n) in M via tau's isomorphism at rank r+4, ALL depth-<=(r+4) formula agreements are preserved. This includes interval-type information.

**The plan's description (S3.5 case (b)) is correct in principle but lacks a concrete proof strategy.** The "key lemma needed" (`tau_interval_type_transfer`) needs to be precisely stated: "For any depth-<=r formula phi, if phi is satisfied by some point in (a_init(n-1), p_n) in N, then phi is satisfied by some point in (resp_tau(n-1), e_n) in M." This follows from: take the MINIMUM point t in (a_init(n-1), p_n) satisfying phi. Consider the formula "exists s in (a_init(n-1), ?) with phi(s)" -- this is expressible as U(phi, sf_top) relativized to the interval, with depth <= r+2 <= r+4, transferable through tau.

**Recommendation**: Keep the sf_top approach (it avoids materializing A), but add a concrete proof sketch for `tau_interval_type_transfer` in plan v43.

---

## Missing Elements

### n=0 Boundary Case
Plan v42 addresses this explicitly in S3.2 and S3.4. The handling is correct: when n=0, a_init has no (n-1)-th element; use x' (= d_bar) as the reference point; sel_pn_ord is vacuously true. This was raised by report 42 R4 and is resolved.

### Sorting Wrapper
Report 37 analyzes the sorting approach in detail. The wrapper (sort at ghr93_inductive_step, transfer back via ghr93_winning_condition_perm) is still needed to ensure a_bwd(n) is the maximum. Plan v42 does not explicitly mention sorting, presumably because the U(B,A) approach makes sel_pn_ord trivial regardless. But the U(B,A) approach DOES require p_n > a_init(n-1), which needs sorted selections.

**Recommendation**: Add sorting wrapper to plan v43 as a prerequisite for Case II (inside S3 or as a preliminary step).

### h_surj Threading
Still needed if using `nf_characterizable_by_stavi`. The handoff case-II-ghr93 identifies the exact functions requiring changes (ghr93_case_II, ghr93_cases_II_III_IV, ghr93_inductive_step, ghr93_forward_to_backward_core, ghr93_forward_to_backward). Estimated 30 lines of mechanical changes.

### resp_mod Equality Case Fix
Report 38 analyzes the equality case (a_init(k) = p_n when Spoiler picks duplicates). With sorted selections using Tuple.monotone_sort (which gives Monotone, not StrictMono), duplicate selections are possible. With the U(B,A) approach:
- If a_init(k) = p_n: resp_tau(k) and e_n may or may not be equal
- sel_pn_ord becomes: False <-> (resp_tau(k) < e_n), which needs resp_tau(k) >= e_n
- Since resp_tau(k) corresponds to a_init(k) = p_n, and e_n is the Until witness above resp_tau(n-1), we have resp_tau(k) may be >= resp_tau(n-1), so resp_tau(k) could be > e_n or < e_n depending on the specific game.

This is an edge case but needs handling. The simplest fix: modify the response function so that when a_init(k) = p_n, respond with e_n instead of resp_tau(k). This makes the biconditional hold trivially (True <-> True or False <-> False).

**Recommendation**: Add explicit equality-case handling to plan v43.

### no_gaps_discrete Dependency Chain
As analyzed above, no_gaps_discrete (GoodStructures.lean:842) depends on stavi_expressive_completeness, which depends on the bridge lemma. If the bridge lemma is deferred, this sorry persists. The task description says the goal is to eliminate succ_cofinal from bx_completeness. We need to determine whether no_gaps_discrete is an alternative path to eliminating succ_cofinal or whether it's a separate dependency.

**Recommendation**: Trace the exact axiom dependency from bx_completeness backward to determine whether no_gaps_discrete is on the critical path.

---

## Critical Path Analysis

### What is Actually on the bx_completeness Critical Path?

Based on the sorry inventory and import analysis:

**Theorem6.lean sorries (lines 124 and 325)**: These are the rank-promotion arguments. The rank-varying version (line 325) is the primary entry point. If closed, it provides delta=4 for sigma/tau.

**CaseAnalysis.lean sorries (lines 1668, 1669, 2026, 2107, 3350)**: These are the game proof body. Lines 1668/1669/2026/2107 are Case II ordering dispatch; line 3350 is Cases III/IV.

**GoodStructures.lean:842 (no_gaps_discrete)**: Needs stavi_expressive_completeness. May or may not be on the critical path.

**ChronicleToCountermodel.lean (lines 1285, 1441, 1508, 1885)**: The succ_cofinal chain. The task description explicitly targets eliminating this from bx_completeness.

The MINIMUM set of changes for sorry-free bx_completeness:
1. Close Theorem6.lean:325 (rank-varying IH) -- enables delta=4
2. Rewrite Case II (close lines 1668/1669/2026/2107 in CaseAnalysis.lean) -- the core GHR93 argument
3. Close Cases III/IV (CaseAnalysis.lean:3350) -- uses delta=4
4. Close or bypass no_gaps_discrete and ChronicleToCountermodel sorries -- the downstream chain
5. Verify bx_completeness has no sorryAx

Step 4 is the biggest unknown. If the Reynolds pipeline bypasses the chronicle construction, the ChronicleToCountermodel sorries become irrelevant. If no_gaps_discrete is needed by the Reynolds pipeline, it's on the critical path.

---

## Concrete Recommendations for Plan v43

### Structural Changes

1. **Remove Phase S1** from the plan. Create a separate task for bridge lemma closure.

2. **Make S2.5 (Theorem6.lean:325) the new Phase 1** (wave 1, no dependencies). This is the gate for delta=4.

3. **Move h_surj threading to Phase 2** (depends on Phase 1 only if the approach uses nf_characterizable_by_stavi; otherwise parallel).

4. **Make Case II rewrite Phase 3** (depends on Phase 1). Include:
   - Sorting wrapper at ghr93_inductive_step
   - B construction (decision needed: Option 5 with sorry propagation, or alternative)
   - U(B, sf_top) transfer through tau at r+4
   - Witness extraction
   - sel_pn_ord (trivial from construction)
   - Round 2 via tau's formula preservation (with concrete proof sketch)
   - Equality case handling
   - Delete old tau_left/tau_right infrastructure

5. **Make Cases III/IV Phase 4** (depends on Phase 3).

6. **Downstream sorries Phase 5** (depends on Phase 4). Include dependency trace analysis.

7. **Final verification Phase 6**.

### The B Formula Decision

Plan v43 MUST make a definitive choice between:

**(A) Use nf_characterizable_by_stavi (with sorry)**: Add import of StaviCompleteness.lean to CaseAnalysis.lean. Accept that bx_completeness will temporarily have sorryAx from the bridge lemma. Track this as a known debt with a clear resolution path (separate task).

**(B) Build B without nf_characterizable_by_stavi**: This requires proving that for each NormalForm sig r 1, there exists a StaviFormula of depth <= r characterizing it, WITHOUT going through the bridge lemma. This might be possible by a different construction (direct from stavi_n_equiv + game_depth relationship), but has not been attempted.

**(C) Hybrid**: Use `nf_characterizable_by_stavi` for the EXISTENCE of B (accepting the sorry), but prove the depth bound separately. If stavi_depth of the output is 2*k_nf, and plan v42's argument that k_nf-depth agreement suffices is correct, then the sorry doesn't block the math -- only the axiom audit.

**My recommendation**: Option (A) for now, with the understanding that closing the bridge lemma (separate task) will eliminate the sorry later. The alternative -- spending more sessions trying to construct B without nf_characterizable_by_stavi -- risks another 6-session cycle with no progress. The bridge lemma IS genuine mathematics; the sorry is not hiding a bug.

### Revised Dependency Graph

```
Phase 1: Theorem6.lean:325 (rank-varying IH)     [no deps]
Phase 2: h_surj threading + StaviCompleteness import  [parallel with Phase 1]
Phase 3: Case II rewrite                          [depends on 1, 2]
Phase 4: Cases III/IV                             [depends on 3]
Phase 5: Downstream sorries                       [depends on 4]
Phase 6: Final verification                       [depends on 5]
```

Estimated total: 12-20 hours (down from plan v42's 20-35 hours, because S1 is removed).

---

## Estimated Remaining Effort

| Phase | Hours | Lines | Risk |
|-------|-------|-------|------|
| 1. Theorem6.lean:325 | 3-6 | 80-150 | MEDIUM |
| 2. h_surj + import | 1-2 | 40-60 | LOW |
| 3. Case II rewrite | 6-10 | 300-500 | HIGH |
| 4. Cases III/IV | 3-5 | 100-200 | MEDIUM |
| 5. Downstream | 2-4 | 100-300 | MEDIUM-HIGH (unknown deps) |
| 6. Verification | 0.5-1 | 0 | LOW |
| **Total** | **15.5-28** | **620-1210** | |

The highest risk is Phase 3 (Case II rewrite), particularly the B formula construction and Round 2 proof. The second highest risk is Phase 5 (downstream), because the dependency chain from bx_completeness through the Reynolds pipeline to the EF game results has not been fully traced.

---

## Summary Verdict

Plan v42 correctly identifies the target architecture (GHR93 U(B,A) with delta=4) but is structurally blocked by placing the bridge lemma (S1) at wave 1. The plan should be restructured to:

1. **Remove S1** (defer to separate task)
2. **Promote S2.5** to wave 1 (the true starting point)
3. **Resolve the B formula question** definitively (recommend: accept nf_characterizable_by_stavi sorry temporarily)
4. **Add sorting wrapper** as a prerequisite for Case II
5. **Flesh out Round 2 proof** with concrete tau_interval_type_transfer lemma
6. **Trace downstream dependencies** to determine minimum sorry set for bx_completeness
7. **Handle the equality case** (duplicate Spoiler selections)
