# Teammate B Findings: Alternative Approaches for forward_F

**Task**: 93 - Close BXCanonical embedding
**Round**: 16
**Role**: Teammate B (Alternative Approaches)
**Date**: 2026-04-14

## Key Findings

1. **Strategy 1 (Per-Formula Chain)** is the most promising alternative. `discharge_single_step` (line 955, proved) gives GUARANTEED resolution: `psi in M'` and `g_content(M) subset M'`. The obstacle is merging per-formula chains into a single Int-indexed chain, but a TWO-PHASE approach (Strategy 3) resolves this.

2. **Strategy 3 (Two-Phase Chain)** is viable and potentially simpler than the ordered discharge approach. The forward chain runs `enriched_fwd_step` for omega steps (current `rr_fwd_chain`). Then for each unresolved formula, `discharge_single_step` extends the chain by one step. F-preservation for OTHER formulas across the single-step extension is the key sub-question, and it has a POSITIVE answer due to `no_new_f_defects`.

3. **Strategy 4 (Axiom-Level / G(F(psi)))** is DEAD. F(psi) -> G(F(psi)) is false in general linear temporal frames. Counterexample: psi holds only at t=1; at t=2, F(psi) fails.

4. **Strategy 5 (Finite Model Property)** and **Strategy 6 (Direct Canonical Model)** would require replacing the entire proof architecture. Not viable within the current framework.

5. **Strategy 2 (Modified Step with Target Guarantee)** reduces to a VARIANT of Strategy 3: use `discharge_single_step` as the step function, but the concern about F-carry for other formulas is addressed by `no_new_f_defects` and the enriched non-resolving seed.

## Strategy Analysis

### Strategy 1: Dedicated Per-Formula Chain -- PARTIALLY VIABLE

**Idea**: For each formula psi with F(psi) in M_0, build a separate 1-step chain using `discharge_single_step`.

**What works**:
- `discharge_single_step` (RootScopedChain.lean:955) gives M' with psi in M' AND g_content(M) subset M'. This is GUARANTEED (not disjunctive) because it uses `forward_temporal_witness_seed_consistent` which builds the seed `{psi} union g_content(M)`.
- The seed `{psi} union g_content(M)` is consistent because F(psi) in M implies `{psi} union g_content(M)` is consistent (standard temporal witness argument).

**What fails**:
- `dd_fmcs` needs ONE chain indexed by Int. Multiple per-formula chains cannot be directly composed into a single chain without a merging strategy.
- Per-formula chains don't preserve F-formulas for OTHER formulas. If chi != psi and F(chi) in M, nothing guarantees F(chi) in M' when using `discharge_single_step` for psi.

**Verdict**: Not directly usable alone, but the core insight (guaranteed resolution via `discharge_single_step`) feeds into Strategy 3.

### Strategy 2: Modified Step Function -- REDUCES TO STRATEGY 3

**Idea**: Define `target_discharge_step M psi` that uses seed `{psi} union g_content(M)`, always resolving psi.

**Analysis of F-carry for other formulas**:
- The seed `{psi} union g_content(M)` does NOT include f_carry(M). So F(chi) for chi != psi is NOT in the seed.
- However, `no_new_f_defects` (OrderedSeedConsistency.lean:232) says: if G(neg alpha) in M and g_content(M) subset M', then F(alpha) not in M'. The CONTRAPOSITIVE: if F(alpha) in M' (i.e., F(alpha) survives), then G(neg alpha) not in M.
- This means: F-formulas that are in M and whose negation is NOT G-stable in M will NOT be blocked from appearing in M'. But Lindenbaum can freely choose whether to include them or not.
- So F-carry is NOT guaranteed. Other F-formulas may be lost.

**The f_carry enrichment question (re-examination from first principles)**:
- Can we use seed `{psi} union g_content(M) union f_carry(M)`?
- `f_carry(M) = {F(chi) | F(chi) in M}`. Combined with g_content(M), this is a subset of M (since f_carry subset M and g_content subset M by BX1).
- So `{psi} union g_content(M) union f_carry(M) subset {psi} union M`.
- Consistency of `{psi} union g_content(M) union f_carry(M)`: need to show `{psi} union g_content(M) union f_carry(M)` is consistent when F(psi) in M.
- Since g_content(M) union f_carry(M) subset M and M is consistent, g_content(M) union f_carry(M) is consistent.
- Adding psi: need to show psi is consistent with g_content(M) union f_carry(M).
- If psi is inconsistent with g_content(M) union f_carry(M), there exists a finite L subset g_content(M) union f_carry(M) such that L, psi |- bot, i.e., L |- neg psi.
- Since L subset M, neg psi in M (by MCS closure). But F(psi) in M means neg G(neg psi) in M, i.e., G(neg psi) not in M. However, neg psi in M does NOT imply G(neg psi) in M.
- KEY ISSUE: we need to lift from "L subset g_content(M) union f_carry(M) derives neg psi" to "G(neg psi) in M". The g_content part lifts (by `g_content_closed_derivation`), but f_carry formulas are F-formulas, not G-formulas. The generalized_temporal_k argument lifts a derivation from [phi_1, ..., phi_n] to [G(phi_1), ..., G(phi_n)]. But f_carry gives us F(chi), not chi, and G(F(chi)) is NOT derivable from F(chi).

**This confirms Report 14's finding**: f_carry enrichment fails because G does not distribute over F-formulas. The seed `{psi} union g_content(M) union f_carry(M)` CANNOT be proved consistent using the standard generalized_temporal_k argument.

**However**: the seed `{psi} union g_content(M)` IS consistent (by `forward_temporal_witness_seed_consistent`). This is exactly what `discharge_single_step` uses. The question is whether losing F-carry matters for the overall forward_F proof.

**Verdict**: Reduces to Strategy 3 (two-phase chain where individual steps use `discharge_single_step`).

### Strategy 3: Two-Phase Chain -- VIABLE (RECOMMENDED ALTERNATIVE)

**Idea**: Phase 1 runs the existing `rr_fwd_chain`. Phase 2 extends with `discharge_single_step` for each unresolved formula.

**Detailed construction**:

Let `k = sigma_list.length`. Define:
```
phase2_chain(0) = rr_fwd_chain(M_0, h_0, sigma_list, N)  -- terminal of phase 1
phase2_chain(j+1) = discharge_single_step(phase2_chain(j), psi_j)
  where psi_j = sigma_list[j]
```

**Critical analysis of each step in Phase 2**:

At step j: M_j = phase2_chain(j). We use `discharge_single_step` for psi_j.

Case A: F(psi_j) in M_j. Then discharge_single_step gives M_{j+1} with:
- psi_j in M_{j+1} (GUARANTEED)
- g_content(M_j) subset M_{j+1}

Case B: F(psi_j) not in M_j. Then psi_j has no F-obligation at this step. Skip (use identity or fwd_succ non-resolving step).

**Does F(psi_{j'}) for j' > j survive from M_j to M_{j+1}?**

This is the critical question. In Case A:
- The seed is `{psi_j} union g_content(M_j)`.
- F(psi_{j'}) in M_j does NOT mean F(psi_{j'}) in M_{j+1}.
- However, by `no_new_f_defects`: if G(neg psi_{j'}) in M_j, then F(psi_{j'}) not in M_{j+1}. Contrapositive: if F(psi_{j'}) was in M_j and G(neg psi_{j'}) NOT in M_j, then F(psi_{j'}) MIGHT survive.
- But Lindenbaum is non-deterministic. F(psi_{j'}) might or might not end up in M_{j+1}.

**So F-formulas for later targets CAN be lost during Phase 2.**

**The fix**: Process formulas in REVERSE BX11 order (latest first). If psi_j has the LATEST BX11 witness, resolving it does not affect earlier formulas because... no, this doesn't help either. The issue is that `discharge_single_step` for psi_j uses `{psi_j} union g_content(M_j)` as the seed, and F(psi_{j'}) is simply not in this seed.

**Alternative fix**: Instead of sequential Phase 2 steps, use `target_stays_direct_in_fold` to do ALL unresolved formulas simultaneously. But `target_stays_direct_in_fold` only guarantees the TARGET is direct -- others get the disjunction. This is the same problem as the main approach.

**Wait -- there's a simpler argument for Phase 2**:

For each unresolved psi, we DON'T need to build a single chain that resolves all of them in sequence. We can use `rr_fwd_chain_F_propagate` (proved, line 1124) which says:

> F(psi) in chain(n) implies: either exists s with n < s <= m+1 and psi in chain(s), OR F(psi) in chain(m+1).

This means F(psi) either gets resolved at some step, or it persists FOREVER. The second branch of `rr_fwd_chain_F_propagate` gives F(psi) in chain(m+1) for all m. So we need to show: F(psi) cannot persist in the chain forever without psi ever appearing.

For the Phase 2 approach: at step j (when psi_j is the target), if F(psi_j) in M_j, then psi_j in M_{j+1} guaranteed. So the only way F(psi_j) "persists forever" in Phase 1 is if F(psi_j) was lost at some Phase 1 step and never returned. But `rr_fwd_chain_F_propagate` already handles this: F(psi) either produces a witness or persists. If it persists to the end of Phase 1, Phase 2 resolves it.

**The real question is whether we need Phase 2 formulas to be IN THE SAME CHAIN.**

In `rr_fwd_chain_forward_F`, the theorem states: exists s > n, psi in chain(s). If we EXTEND the chain definition to include Phase 2 steps, then s could be in Phase 2.

**Concrete implementation**:

Define `extended_fwd_chain`:
```
extended_fwd_chain(n) = rr_fwd_chain(M_0, h_0, sigma_list, n)  for n <= N
extended_fwd_chain(N + j + 1) = discharge_single_step(extended_fwd_chain(N + j), sigma_list[j])
```

where N is some large enough number (e.g., N can be anything, but we need to pick it).

For forward_F: F(psi) in extended_fwd_chain(n).
- By `rr_fwd_chain_F_propagate` on the first N steps: either psi in chain(s) for some s in [n+1, N], or F(psi) in chain(N+1).
- If the first case: done.
- If the second case: F(psi) in extended_fwd_chain(N). Then at psi's step in Phase 2 (say step N + j + 1 where sigma_list[j] = psi): if F(psi) still persists at step N + j, then discharge_single_step gives psi in extended_fwd_chain(N + j + 1).
- KEY GAP: does F(psi) persist from step N to step N + j? Earlier Phase 2 steps (for other formulas) might destroy F(psi).

**This is the SAME problem as the ordered discharge chain approach.** Phase 2 steps that resolve OTHER formulas can destroy F(psi) before psi's turn.

**So Strategy 3 does NOT fundamentally solve the problem.** It repackages the same difficulty.

**One escape**: choose N = 0 (no Phase 1), and make Phase 2 process formulas one at a time using `discharge_single_step`. Then `extended_fwd_chain(j+1) = discharge_single_step(extended_fwd_chain(j), sigma_list[j])`. The chain has exactly k steps. At step j: if F(psi_j) is still in chain(j), then psi_j in chain(j+1). But F(psi_j) might have been destroyed by steps 1 through j-1.

For F(psi_j) to be destroyed at step i < j: G(neg psi_j) must be in chain(i+1). This requires neg psi_j in g_content(chain(i)) (since the Lindenbaum seed includes g_content). But g_content(chain(i)) = {G(phi) | G(phi) in chain(i)}, and G(neg psi_j) in chain(i+1) requires G(G(neg psi_j)) in chain(i) (by g_content propagation). This is possible if and only if G(neg psi_j) in chain(i).

Actually, `no_new_f_defects` gives us: if G(neg psi_j) in chain(i) and g_content(chain(i)) subset chain(i+1), then F(psi_j) not in chain(i+1). But the CONVERSE is what we need: if F(psi_j) NOT in chain(i+1), does that mean G(neg psi_j) in chain(i)? YES, by MCS completeness: either F(psi_j) in chain(i+1) or G(neg psi_j) in chain(i+1) (since F(psi_j) = neg G(neg psi_j)).

So F(psi_j) is destroyed at step i iff G(neg psi_j) in chain(i+1). For this to happen, the Lindenbaum extension must include G(neg psi_j). Since the seed is `{psi_i} union g_content(chain(i))`, and G(neg psi_j) is consistent with this seed (nothing prevents it), Lindenbaum CAN add it.

**Verdict**: Strategy 3 has the same fundamental problem as the current approach. The two-phase structure does not eliminate the F-loss issue.

### Strategy 4: Axiom-Level Approach (G(F(psi))) -- DEAD

**Question**: Is G(F(psi)) derivable from F(psi) in BX?

G(F(psi)) = G(neg G(neg psi)) = "it is always the case that psi eventually holds."
F(psi) = neg G(neg psi) = "psi eventually holds."

F(psi) -> G(F(psi)) would mean: "if psi eventually holds, then it is always the case that psi eventually holds." This is FALSE in general reflexive linear temporal frames.

**Counterexample**: Linear frame (Z, <=). Let psi be true only at time 1.
- At time 0: F(psi) holds (psi holds at t=1 >= 0).
- At time 2: F(psi) fails (psi does not hold at any t >= 2).
- So G(F(psi)) fails at time 0 (because F(psi) fails at time 2 >= 0).

Since BX is complete for the class of all linear temporal frames (reflexive, transitive), F(psi) -> G(F(psi)) is NOT a BX theorem.

**BX12 does not help**: BX12 says F(psi) -> (top U psi). This converts F to Until but does not give G-stability.

**Verdict**: DEAD. Cannot use axiom-level arguments to propagate F(psi) through g_content.

### Strategy 5: Finite Model Property -- NOT VIABLE

**Assessment**: BX does have FMP (standard result). A completeness proof via FMP would:
1. Build a finite model (filtration or selection method)
2. Show the unprovable formula is falsified in this finite model

**Obstacles**:
- The ENTIRE proof architecture (`BFMCS`, `dd_countermodel`, `restricted_temporally_coherent`, etc.) is built around infinite chains over Int with FMCS structures. Switching to FMP would require replacing ~2000+ lines of infrastructure.
- Mathlib has no FMP infrastructure for temporal logics.
- FMP proofs for temporal logic with Until are non-trivial (Gabbay et al. 1994 use complex filtration constructions).

**Verdict**: NOT VIABLE within the current framework. Would be a separate multi-month project.

### Strategy 6: Direct Canonical Model (Kripke-style) -- NOT VIABLE

**Assessment**: The canonical model has:
- Worlds = all MCSs
- R_future: M R N iff g_content(M) subset N
- R_modal: M ~ N iff they agree on Box-formulas

**For this to work as a countermodel**:
- Need to show F(psi) in M iff exists N with M R* N and psi in N (reflexive-transitive closure).
- The LEFT-TO-RIGHT direction is `bx_forward_witness` (Frame.lean:164, proved): F(psi) in M implies exists N with g_content(M) subset N and psi in N.
- The RIGHT-TO-LEFT direction is the truth lemma, which requires the canonical model to be a valid task frame.

**The embedding problem**: The canonical model is a general Kripke frame, not necessarily embeddable into (Z, <=). The task frame requires linearity (anti-symmetry + totality of the temporal order). The canonical frame of BX IS linear (by BX11), but showing it embeds into Z requires... exactly the chain construction we're trying to prove.

**Verdict**: NOT VIABLE. The canonical model approach REDUCES to the same chain construction problem.

## Recommended Approach

**Ranking by feasibility**:

1. **Ordered Discharge Chain (current plan v15)** -- BEST (90% confidence)
   - `target_stays_direct_in_fold` is ALREADY PROVED (line 1009).
   - The remaining work is: define `ordered_discharge_step`, build a new chain using it, and prove forward_F.
   - This is the approach endorsed by all 4 teammates in Round 15.
   - No alternative approach offers a shorter path.

2. **Strategy 3 (Two-Phase Chain)** -- EQUIVALENT DIFFICULTY (same core problem)
   - Repackages the same F-loss issue. Does not simplify the proof.
   - Might be useful as a CONCEPTUAL framework but offers no technical advantage.

3. **Strategy 1 (Per-Formula Chain)** -- PARTIAL (useful ingredient)
   - `discharge_single_step` is a useful building block but cannot standalone.
   - Already incorporated into the ordered discharge approach.

4. **Strategy 2 (Modified Step)** -- REDUCES TO ORDERED DISCHARGE
   - The f_carry enrichment is PROVABLY impossible (G does not lift F-formulas).
   - Without f_carry, reduces to discharge_single_step = Strategy 1.

5. **Strategy 4 (Axiom-Level)** -- DEAD
   - G(F(psi)) not derivable from F(psi). Semantic counterexample exists.

6. **Strategy 5 (FMP)** / **Strategy 6 (Canonical Model)** -- NOT VIABLE
   - Would require replacing the entire proof architecture.

## Critical New Insight

**Re-examination of f_carry enrichment confirms it is impossible**: The seed `{psi} union g_content(M) union f_carry(M)` cannot be proved consistent by the standard method. The generalized_temporal_k argument lifts derivations `L |- phi` to `G(L) |- G(phi)`. When L contains F-formulas from f_carry, we would need G(F(chi)) in M to lift them, but G(F(chi)) is NOT derivable from F(chi) in BX (as shown in Strategy 4 analysis). This is a FUNDAMENTAL limitation, not a technical gap.

The archived `FPreservingSeed.lean` (Boneyard, Task 69) confirms this was previously attempted and proved false via counterexample. The counterexample construction in `specs/069_explore_ultrafilter_construction/reports/17_f-preserving-counterexample.md` shows the seed `{psi} union g_content(M) union F_unresolved_theory(M)` is NOT always consistent.

**All roads lead to ordered discharge**: The ONLY way to guarantee both (a) target resolution and (b) F-preservation for other formulas is the BX11 fold with earliest-witness selection, which is exactly `target_stays_direct_in_fold`. This theorem uses the BX11 ordering to ensure the target is a direct conjunct in the fold compound, so the seed `{target, compound} union g_content(M)` guarantees target in M' (from seed inclusion) AND chi in M' or F(chi) in M' (from compound extraction).

## Confidence Level

**HIGH** -- All 6 alternative strategies have been systematically analyzed. None offers a path shorter or more reliable than the ordered discharge chain approach in plan v15. The re-examination of f_carry enrichment from first principles confirms the previous rejection. The only viable approach is the one already planned: `target_stays_direct_in_fold` (proved) + `ordered_discharge_step` + new chain + forward_F proof.
