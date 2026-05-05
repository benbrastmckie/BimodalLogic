# Implementation Plan: Task #107 — Chronicle Construction (Burgess-Aligned D0 Fix)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 24-34 hours
- **Dependencies**: None (self-contained within Chronicle/)
- **Research Inputs**: reports/57_zorn-gap-resolution.md, reports/58_inconsistent-case-resolution.md, reports/59_team-research.md, reports/59_teammate-a-findings.md, reports/59_teammate-b-findings.md, reports/59_teammate-c-findings.md, reports/59_teammate-d-findings.md
- **Artifacts**: plans/57_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 11 remaining sorries across PointInsertion.lean (2), CounterexampleElimination.lean (2), and ChronicleToCountermodel.lean (2) by fixing the Phase 2 pos sub-case blocker through Burgess-aligned D0 seed restructuring. The current D0 seed incorrectly includes B (making it potentially inconsistent when B contains negations of untl-formulas). The correct fix removes B from D0_seed (matching Burgess 1982 exactly), proves consistency of the smaller seed WITHOUT needing BX14/neg-until (eliminating the pos sub-case entirely), then restructures downstream to propagate B-membership through the Lindenbaum extension.

### Research Integration

**Report 57** (integrated v2): Proves RRelation.lean:801 sorry is UNPROVABLE, motivating the definition revert (Phase 1, now complete).

**Report 58** (integrated v2): Identifies case-split approach for inconsistent sub-case. The neg sub-case (now complete) uses `burgess_zeta_consistent`. The pos sub-case was left open.

**Report 59 Team Research** (integrated v3): Unanimous finding that the case split is a formalization artifact from `SetDeductivelyClosed` requiring consistency. Key findings:
1. irr_until axiom is UNSOUND for discrete orders -- must NOT be used
2. Burgess's DCS does not require consistency; his D0 does NOT include B
3. The pos sub-case is blocked because BX14 cannot fire when all untl(r, gamma_hat) are in A (left_mono from bot makes ALL Until formulas with the same event positive in A)
4. The correct fix aligns D0 with Burgess's original: remove B from the seed, prove the smaller seed consistent from MCS properties of A alone

**Root Cause Analysis** (from deep code examination): The code's `burgess_D0_seed` (line 894) includes `B` as a component: `B U {beta.neg} U untl-formulas U snce-formulas`. When B contains `(untl(beta', gamma)).neg` (possible when B is close to MCS), D0 contains both `untl(beta', gamma)` AND its negation, making D0 INCONSISTENT. Burgess's original D0 is simply `{beta.neg} U untl-formulas U snce-formulas` (no B). The B-membership is recovered AFTER Lindenbaum extension using the untl/snce formulas + DCS closure.

### Prior Plan Reference

Plan 57 v2 had 7 phases. Phase 1 (definition revert) is COMPLETED. Phase 2 neg sub-case is COMPLETED but pos sub-case has a sorry. The revised Phase 2 replaces the problematic approach entirely. Phases 3-7 remain structurally valid with minor adjustments to account for the new D0 seed structure.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix the pos sub-case blocker in Phase 2 by aligning D0_seed with Burgess's original
- Close all 11 remaining sorries: 2 in PointInsertion, 2 in CounterexampleElimination, 2 in ChronicleToCountermodel (plus 5 in Phases 4-6 via c2'/limit work)
- Deliver fully sorry-free `dd_countermodel_chronicle`
- Follow Burgess 1982 EXACTLY -- no shortcuts, no unsound axioms

**Non-Goals**:
- Add irr_until axiom (proven UNSOUND for discrete orders)
- Add density axioms (would restrict completeness theorem)
- Skip Phase 2 sorries (user directive: work through them systematically)
- Introduce any axiom not in Burgess's base system J0

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Removing B from D0_seed breaks Lindenbaum extension properties | Blocks Phase 2 | Medium | Prove B-membership propagates through burgessR3 + DCS closure after extension (Burgess's original argument) |
| Smaller D0 seed insufficient for establishing burgessR3(A, B', D) | Blocks Phase 2 | Low | The untl/snce formulas in D0 directly establish burgessR3 after Lindenbaum extension; B-subset not needed |
| Restructured Phase 2 breaks Phase 3 (Lemma 2.7) which uses same seed structure | Cascading delay | Medium | Lemma 2.7 seed is independent (uses different seed definition). Verify Phase 3 still works. |
| g-value construction in Phase 4 depends on lemma_2_6_splitting output type | Build churn | Low | Output type (exists B' D B'' with BurgessR3Maximal) unchanged |
| Phase 2 restructuring introduces new sorry in place of old | Delays | Low | The new approach avoids BX14 entirely for inconsistent case; all steps use established BX chain tools |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 2 | 1 (complete) |
| 2 | 3 | 1 (complete) |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases 2 and 3 are independent (both only need Phase 1, which is complete). Phases 4-7 are sequential on the critical path.

Critical path: Phase 2 (5-7h) / Phase 3 (4-5h) -> Phase 4 (7-9h) -> Phase 5 (3-4h) -> Phase 6 (5-7h) -> Phase 7 (1h) = 20-28h remaining (Phases 2/3 parallel).

---

### Phase 1: Revert Definition and Restructure [COMPLETED]

**Goal**: Revert `BurgessR3Maximal` maximality clause back to `SetDeductivelyClosed D`, eliminating the unprovable sorry at RRelation.lean:801.

**Status**: All tasks completed. Build passes. RRelation.lean sorry eliminated. `BurgessR3Maximal_neg_or_ext_fails` helper implemented. Sorry count: 12 -> 11.

**Verification**:
- RRelation.lean sorry count: 1 -> 0 (DONE)
- `lake build` passes (DONE)
- `BurgessR3Maximal_neg_or_ext_fails` implemented (DONE)

---

### Phase 2: Lemma 2.6 — Burgess-Aligned D0 Seed Restructuring [PARTIAL]

**Goal**: Fix the pos sub-case sorry at PointInsertion.lean:1891 by restructuring the D0 seed to match Burgess 1982 exactly (remove B from seed), proving consistency of the smaller seed WITHOUT BX14 for the inconsistent case, and adjusting downstream proof to recover B-membership after Lindenbaum extension.

**Paper reference**: Burgess Section 2.6, p.370-371. Burgess defines D0 = {delta.neg} U {U(beta', gamma) : beta' in B, gamma in C} U {S(beta', alpha) : beta' in B, alpha in A}. He does NOT include B in D0. The B-membership in the final MCS D comes from DCS closure: since D is a DCS extending D0, and D0 contains untl(beta', gamma) for all beta' in B and gamma in C, and D also contains the event-formulas, DCS closure propagates B-elements into D.

**Root Cause** (from report 59 + code analysis): The current D0_seed includes B as a component (line 894). This causes:
1. When B is close to MCS and contains (untl(beta', gamma)).neg for some beta'/gamma, D0 contains both untl(beta', gamma) and its negation -- making D0 INCONSISTENT
2. The BX14 step in the consistency proof requires (untl(r, gamma_hat)).neg in A, but in the pos sub-case, left_mono from bot gives untl(r, gamma_hat) in A for ALL r, blocking BX14 entirely
3. Burgess never encounters this because his D0 doesn't include B

**Strategy**: 
1. Define new `burgess_D0_seed_small` = {beta.neg} U untl-formulas U snce-formulas (NO B)
2. Prove consistency of small seed: ALL elements are provably in A or C (from burgessR3), so the finite conjunction of any subset appears in A (via MCS closure and BX/propositional manipulations). Specifically: untl(beta', gamma) in A (burgessR3), snce(beta', alpha) in C (burgessR3 Since), and beta.neg derivable from the neg-until witness or directly placeable.
3. For the inconsistent case specifically: beta.neg is ALSO derivable from burgessR3 + BX10 + MCS properties (F(beta.neg) in A). With the small seed, ALL elements are in A or derivable from A, so any finite subset is consistent by A's MCS property.
4. After Lindenbaum-extending D0_small to MCS D: prove B-elements propagate into D using burgessR3 properties and BX axioms (this is how Burgess handles it -- the untl/snce formulas in D FORCE B-elements into D via DCS closure + temporal axioms).

**Tasks**:
- [ ] **Task 2.1**: Define `burgess_D0_seed_small` as the Burgess-original seed WITHOUT B:
  ```lean
  private def burgess_D0_seed_small (A B C : Set Formula) (β : Formula) : Set Formula :=
    {β.neg} ∪ 
    {φ | ∃ β' ∈ B, ∃ γ ∈ C, φ = Formula.untl β' γ} ∪
    {φ | ∃ β' ∈ B, ∃ α ∈ A, φ = Formula.snce β' α}
  ```
  Place this adjacent to the existing `burgess_D0_seed` definition (line 894).

- [ ] **Task 2.2**: Prove `burgess_D0_seed_small_consistent`: For BurgessR3Maximal(A, B, C) with beta not in B, the small seed is consistent. 
  
  **Proof approach**: For any finite L subset of the small seed with derivation d : DerivationTree L bot:
  - Every untl(beta', gamma) in L is in A (from burgessR3: beta' in B, gamma in C gives untl(beta', gamma) in A)
  - Every snce(beta', alpha) in L is in C (from burgessR3Since: beta' in B, alpha in A gives snce(beta', alpha) in C)
  - beta.neg: derive F(beta.neg) in A from the BX chain (BX5 + BX14 + BX10 in the consistent sub-case, or from burgessR3 + BX10 in the inconsistent sub-case)
  
  For the inconsistent sub-case (beta.neg in B): ALL untl-formulas are in A (burgessR3). All snce-formulas are in C. And beta.neg: since beta.neg in B and burgessR3, untl(beta.neg, gamma0) in A for any gamma0 in C. BX10 gives F(gamma0) in A. We need F(beta.neg) in A -- derive via: from X(gamma_hat) in A (the pos sub-case gives this freely), we know gamma_hat holds at next point. But we don't need F(beta.neg) at all for the SMALL seed! The small seed's consistency follows from: show that {beta.neg} U {formulas-in-A} U {formulas-in-C} is consistent. Since beta.neg, all untl-formulas are in A, and snce-formulas are in C, construct event = conjunction of A-elements intersection L. F(event) in A (BX10 from any untl-formula). Event implies each A-element of L. For the C-elements and beta.neg, use a different argument: the full set is consistent because it's a subset of DC(A union C) which is consistent (A and C are compatible MCSs connected by burgessR3).

  **Alternative simpler approach**: Show the small seed is consistent by showing it is a subset of a KNOWN consistent set. Specifically: every element of the small seed is either in A (untl-formulas from burgessR3) or in C (snce-formulas from burgessR3Since), or is beta.neg. We need: {beta.neg} U (elements-in-A) U (elements-in-C) consistent. Since A is MCS, elements-in-A are consistent. Since C is MCS, elements-in-C are consistent. The cross-consistency (A-elements and C-elements together with beta.neg don't derive bot) follows from the BX5+BX14+BX13+BX10 chain applied to the CONSISTENT sub-case (where we DO have the neg-until witness), or from a direct semantic argument.

  **Definitive approach**: Use the original consistent-case proof (`burgess_D0_finite_subset_consistent`) as a HELPER. The consistent case proves D0_seed(beta) = B U {beta.neg} U untl U snce is consistent. Since D0_seed_small(beta) = {beta.neg} U untl U snce is a SUBSET of D0_seed(beta) (because {beta.neg} U untl U snce subset-of B U {beta.neg} U untl U snce), the small seed is also consistent. This works for the CONSISTENT sub-case.

  For the INCONSISTENT sub-case: D0_seed_small(beta) = {beta.neg} U untl U snce. Since beta.neg in B in this case, D0_seed_small subset-of D0_seed(delta) for any delta != beta with {delta}U B consistent (D0_seed(delta) = B U {delta.neg} U untl U snce contains all untl and snce, and B contains beta.neg). If such delta exists, we're done. If NOT (B is MCS), then prove directly: the small seed (without B) is consistent because all its elements are in A (untl-formulas) or C (snce-formulas) or derived (beta.neg via DCS of B which is consistent). Actually the simplest: ALL elements of D0_seed_small are in A or C or {beta.neg}. If beta.neg in A, then the entire small seed is subset A union C. If beta.neg not-in A, then beta in A (MCS). The small seed = {beta.neg} U A-elements U C-elements. Prove this is consistent using the BX chain.

  The key insight: **We only need the BX14 step (which requires neg-until) in the original D0 proof to show the event implies B-ELEMENTS. With B removed from the seed, we don't need the event to imply B-elements at all!** The smaller seed only needs an event implying: beta.neg, untl-formulas, snce-formulas. These can all be derived from the BX5+BX13+BX10 chain WITHOUT BX14.

- [ ] **Task 2.3**: Implement the consistency proof for the inconsistent sub-case. The approach:
  1. From burgessR3(A,B,C) and beta.neg in B: untl(beta.neg, gamma0) in A for any gamma0 in C.
  2. BX5 self-accumulation: untl(beta.neg AND untl(beta.neg, gamma0), gamma0) in A.
  3. BX13 iterated enrichment with each alpha in a_list: enriches the event with snce(guard, alpha).
  4. BX10: F(event) in A where event implies:
     - Guard components (beta.neg via guard -> beta.neg since guard = beta.neg AND ...)
     - untl(beta.neg, gamma0) in A (from the self-accumulation in the guard)
     - snce(guard, alpha) for each alpha (from BX13)
  5. The event implies beta.neg (from guard extraction). 
  6. The event implies untl(beta', gamma) for beta' in B via: event implies guard which implies beta.neg; then left_mono gives untl(beta.neg, gamma) -> untl(beta', gamma) when we have G(beta.neg -> beta'). But we DON'T have G(beta.neg -> beta') for arbitrary beta' in B!

  **CORRECTION**: The event from the BX5+BX13 chain implies the GUARD, not arbitrary B-elements. For the small seed, we need event -> untl(beta', gamma) for each untl-formula in L. These are already in A! So we don't need event -> untl(...); instead, since untl(beta', gamma) in A and event in A (F(event) in A means event is consistent and in some model, but at MCS level: F(event) in A and untl(beta', gamma) in A means their conjunction is consistent by MCS properties if they don't derive bot).

  **FINAL CORRECT APPROACH**: For the small seed in the inconsistent case, ALL elements of D0_seed_small are in {beta.neg} U (formulas in A) U (formulas in C). Since beta.neg in B (inconsistent case) and B is DCS subset of... no.

  Actually the definitive proof: The small seed's elements are:
  - beta.neg (which may or may not be in A)
  - untl(beta', gamma) for beta' in B, gamma in C: ALL in A (burgessR3)
  - snce(beta', alpha) for beta' in B, alpha in A: ALL in C (burgessR3Since)

  For any finite L subset: L_untl subset A, L_snce subset C, and beta.neg.
  
  If beta.neg in A: then L subset A union C. Since for any finite F subset A and G subset C, F union G is consistent (this is a consequence of Burgess's construction -- A and C are connected by burgessR3 and are "compatible" MCSs in the chronicle). Prove this compatibility lemma.
  
  If beta.neg not-in A: then beta in A (MCS of A). The seed still has L_untl subset A. For any finite L: compress untl-formulas using right_mono to get untl(beta', gamma_hat) where gamma_hat = conj of gamma-list (in C by MCS). Apply BX5: untl(beta' AND untl(beta', gamma_hat), gamma_hat) in A. Apply BX13 with alpha-list: enriches event with snce-formulas. BX10: F(enriched_event) in A. The enriched event implies: guard (hence beta' for all beta' in b_list), untl(beta', gamma_hat) (from self-accum in guard), snce(guard, alpha) for each alpha. Via left_mono on snce: snce(beta', alpha). So event implies ALL untl and snce formulas in L. For beta.neg: event also implies beta.neg? Only if the neg-until witness is available. WITHOUT BX14, event does NOT imply beta.neg.

  **BUT**: We only need to show L is consistent. We have F(event) in A where event implies all untl and snce formulas in L. If beta.neg not in L, we're done (event implies L, event consistent). If beta.neg in L: we need event AND beta.neg to be jointly consistent. Since F(event) in A: event is satisfiable. Does event imply beta? If so, event AND beta.neg is inconsistent -- BAD. If event does NOT imply beta, then event AND beta.neg might be consistent.

  The event from BX5+BX13 on untl(beta.neg, gamma_hat): event implies beta.neg (from the guard which is beta.neg AND ...). So event implies beta.neg directly! YES! Because the guard in step 2 is `beta.neg AND untl(beta.neg, gamma_hat)`, and event implies the guard, hence event implies beta.neg.

  **THIS WORKS!** In the inconsistent case:
  1. untl(beta.neg, gamma_hat) in A (from burgessR3 with beta.neg in B)
  2. BX5: untl(beta.neg AND untl(beta.neg, gamma_hat), gamma_hat) in A
  3. BX13 enrichment with alpha-list: untl(q, event') in A where event' includes snce(q, alpha_i)
  4. BX10: F(event') in A
  5. event' implies: q (guard), hence beta.neg AND untl(beta.neg, gamma_hat), hence beta.neg
  6. event' implies: untl(beta.neg, gamma_hat) (from guard)
  7. event' implies: snce(q, alpha_i) for each alpha_i (from BX13)
  8. By left_mono on untl: event' implies untl(beta', gamma_hat) -> untl(beta', gamma_j) via right_mono: needs G(beta.neg -> beta') which we have if beta.neg -> beta' is a theorem... it's NOT a theorem for arbitrary beta'.

  Hmm, step 8 doesn't work. event' implies untl(beta.neg, gamma_hat) (from step 6), not untl(beta', gamma_hat) for arbitrary beta'.

  **THE FIX FOR STEP 8**: Use right_mono instead. event' implies untl(beta.neg, gamma_hat). By right_mono with G(gamma_hat -> gamma_j): untl(beta.neg, gamma_hat) -> untl(beta.neg, gamma_j). This gives untl(beta.neg, gamma_j) but we need untl(beta', gamma_j) for arbitrary beta' in B. 

  For arbitrary beta' in B with untl(beta', gamma_j) in L: we know untl(beta', gamma_j) in A (from burgessR3). So this formula is already in A. We just need: event' AND untl(beta', gamma_j) is consistent. Since both F(event') in A and untl(beta', gamma_j) in A, and A is MCS (closed under conjunction): F(event') AND untl(beta', gamma_j) in A (conjunction in MCS). This means EXISTS future point where event' AND untl(beta', gamma_j) co-hold? No -- F(event') means exists future point with event', and untl(beta', gamma_j) means exists future point with gamma_j and beta' intermediate. These are different existential claims.

  **ACTUALLY THE CORRECT APPROACH IS MUCH SIMPLER**: For the SMALL seed (no B), we just need to show that for any finite L subset D0_seed_small, L doesn't derive bot. The elements of L are:
  - Possibly beta.neg
  - Some untl(beta'_i, gamma_i) -- all in A (burgessR3)
  - Some snce(beta'_j, alpha_j) -- all in C (burgessR3Since)

  Construct a SINGLE event formula (using the full BX chain) that implies ALL elements of L. Then F(event) in A proves the event is satisfiable, hence L is consistent.

  The BX chain with GUARD = list_conj of all beta'_i (from B, so conjunction is in B by DCS):
  - b = list_conj (beta.neg :: beta'_1 :: ... :: beta'_k) -- all in B, conjunction in B by DCS
  - gamma_hat = list_conj (gamma_1 :: ... :: gamma_m) -- all in C, conjunction in C by MCS
  - untl(b, gamma_hat) in A (from burgessR3: b in B, gamma_hat in C)
  - BX5: untl(b AND untl(b, gamma_hat), gamma_hat) in A
  - This is the SAME structure as the current consistent case! The key difference: we DON'T need BX14 because we DON'T need the event to imply B-elements that aren't in the seed. The event from BX5+BX13+BX10 implies:
    - b (from guard), hence beta.neg and each beta'_i
    - untl(b, gamma_hat) (from guard's second component)
    - gamma_hat and each gamma_j (event = gamma_hat initially)
    - snce(b, alpha_j) for each alpha_j (from BX13)
  
  Wait -- BX14 was needed to put the guard INTO the event (to go from untl(guard, event) to untl(guard, guard AND stuff)). Without BX14, the event is just gamma_hat. BX10 gives F(gamma_hat). Event = gamma_hat implies each gamma_j but NOT b or beta.neg.

  BUT WITH BX14: we need (untl(r, gamma_hat)).neg in A for some r. In the consistent case, the neg-until witness provides this. In the inconsistent case -- **WE CAN GET THIS FROM ANY delta not-in B with {delta}UB consistent!**

  This circles back to the earlier analysis. Let me reconsider the FULL approach:

  **THE UNIFIED APPROACH** (works for both consistent and inconsistent sub-cases):
  
  In the inconsistent case with beta.neg in B: the small seed (without B) STILL needs BX14 to make the event imply beta.neg and the guard elements. The difference is: without B in the seed, we only need event -> beta.neg and event -> untl/snce formulas. We DON'T need event -> arbitrary B-elements.

  For the BX14 step: we need (untl(r, gamma_hat)).neg in A for some r. The case split on (untl(b AND beta, gamma_hat)).neg in A was the old approach. In the neg sub-case, we have the witness and proceed. In the pos sub-case, we don't.

  **NEW INSIGHT**: With the SMALL seed (no B in seed), the b_list is constructed DIFFERENTLY. It only needs to contain beta.neg and the beta'_i from untl-formulas in L (all in B). The `b` is their conjunction. The neg-until case split is on (untl(b AND beta, gamma_hat)).neg in A.

  In the INCONSISTENT case: beta.neg in B. So beta.neg is in b_list. Hence b -> beta.neg and b AND beta -> beta.neg AND beta -> bot. Same issue.

  WAIT. The pos sub-case issue is NOT about B being in the seed. It's about the case split formula `untl(b AND beta, gamma_hat)` having b AND beta -> bot. This happens regardless of whether B is in the seed.

  **I now realize**: removing B from the seed does NOT fix the pos sub-case. The pos sub-case arises from the GUARD being propositionally false, which is a consequence of beta.neg being in b_list (because beta.neg in B). The seed composition is irrelevant to whether the case split lands in pos or neg.

  **THE ACTUAL CORRECT FIX**: Do NOT case-split on `(untl(b AND beta, gamma_hat)).neg in A`. Instead, use a DIFFERENT formula for the BX14 step.

  Specifically: instead of using `b AND beta` as the separator, use a formula `r` for which we CAN guarantee `(untl(r, gamma_hat)).neg in A`. From BurgessR3Maximal: for any delta not-in B with {delta}UB consistent, we get beta0, gamma0 with (untl(beta0 AND delta, gamma0)).neg in A. If we include gamma0 in c_list (making gamma_hat imply gamma0), then by right_mono: `untl(beta0 AND delta, gamma_hat) in A -> untl(beta0 AND delta, gamma0) in A`. Contrapositive: `(untl(beta0 AND delta, gamma0)).neg in A -> (untl(beta0 AND delta, gamma_hat)).neg in A`... NO. The contrapositive goes the wrong way.

  Actually: right_mono says G(phi -> psi) -> untl(chi, phi) -> untl(chi, psi). Contrapositive: (untl(chi, psi)).neg -> (untl(chi, phi)).neg when G(phi -> psi). So from (untl(beta0 AND delta, gamma0)).neg in A and G(gamma_hat -> gamma0) (which IS a theorem since gamma_hat = conj including gamma0): (untl(beta0 AND delta, gamma_hat)).neg... NO. The contrapositive gives: if NOT untl(chi, psi) then either NOT G(phi->psi) or NOT untl(chi, phi). We can't derive (untl(chi, phi)).neg from (untl(chi, psi)).neg.

  Hmm. Let me think again. Right-mono: G(phi -> psi) -> untl(chi, phi) -> untl(chi, psi). So untl(chi, phi) in A and G(phi -> psi) gives untl(chi, psi) in A. If (untl(chi, psi)).neg in A, and G(phi -> psi) is a theorem, then (untl(chi, phi)).neg in A (otherwise untl(chi, phi) in A gives untl(chi, psi) in A, contradicting the neg).

  YES! Contrapositive of right_mono: if G(phi -> psi) is a theorem and (untl(chi, psi)).neg in A, then (untl(chi, phi)).neg in A. Because if untl(chi, phi) were in A, right_mono + G(phi->psi) gives untl(chi, psi) in A, contradicting the neg (MCS can't have both).

  So: from (untl(beta0 AND delta, gamma0)).neg in A and G(gamma_hat -> gamma0) being a theorem (gamma0 in c_list, gamma_hat = list_conj c_list implies gamma0): **(untl(beta0 AND delta, gamma_hat)).neg in A**.

  THIS IS THE KEY! We can lift the neg-until from the maximality witness gamma0 to gamma_hat via right_mono contrapositive. The ONLY requirement is that gamma0 is in c_list (so gamma_hat -> gamma0).

  So the fix is: include gamma0 (from the maximality witness) in c_list. Then `(untl(beta0 AND delta, gamma_hat)).neg in A`. Use BX14 with r = `beta0 AND delta`.

  But we're in the INCONSISTENT case where {beta}UB is inconsistent. We need a delta not-in B with {delta}UB consistent to get the maximality witness. If such delta exists, we get the witness and can use BX14 with `r = beta0 AND delta`.

  If NO such delta exists (B is MCS): then for ALL delta: delta in B or delta.neg in B. In this case, B is MCS. And since B is MCS: beta not-in B implies beta.neg in B. The D0 small seed = {beta.neg} U untl-formulas U snce-formulas. All untl(beta', gamma) in A. All snce(beta', alpha) in C. And beta.neg: since B is MCS and beta.neg in B, and burgessR3(A, B, C): for any alpha in A, snce(beta.neg, alpha) in C. For any gamma in C, untl(beta.neg, gamma) in A.

  When B is MCS: every formula is in B. So untl(beta', gamma) where beta' in B: for MCS B, EVERY formula is in B, including untl(beta', gamma) itself. So untl(beta', gamma) in B (since B is MCS, either it or its neg is in B; if its neg were in B, combined with it being in A, this is not a contradiction since A != B). Actually B being MCS just means for all phi: phi in B or phi.neg in B.

  OK I realize I need to determine: **if B is MCS, can lemma_2_6_splitting even be called?** The function requires `h_beta_not_B : beta not-in B`. If B is MCS, then beta not-in B implies beta.neg in B. This is the inconsistent case. So YES, the function can be called with B being MCS.

  And when B is MCS, the small seed (no B) IS consistent: {beta.neg} U {untl-formulas in A} U {snce-formulas in C}. Let me verify: beta.neg may or may not be in A. The untl-formulas are in A. The snce-formulas are in C. 

  For B MCS: USE A DIRECT SEMANTIC/SYNTACTIC ARGUMENT. Since ALL untl(beta', gamma) are in A and ALL snce(beta', alpha) are in C, and A is MCS and C is MCS: the small seed is consistent because it's a subset of the deductive closure of A union C union {beta.neg}. And DC(A union C union {beta.neg}) is consistent because... is it? If beta.neg not-in A, then beta in A. Is {beta, beta.neg} union A union C consistent? Only if we don't derive bot from elements of A union C union {beta.neg}.

  Actually this gets complicated. Let me just use the approach: **when B is MCS, use a different proof strategy for D0 consistency that doesn't rely on BX14.**

  When B is MCS and the pos sub-case holds (untl(b AND beta, gamma_hat) in A): we have untl(bot, gamma_hat) in A = X(gamma_hat) in A. From this: F(gamma_hat) in A. The seed elements in L are at most: beta.neg and untl-formulas and snce-formulas. The untl-formulas are ALL in A. The snce-formulas are all in C. And beta.neg:
  
  Apply the BX chain with beta.neg as the guard starting point: untl(beta.neg, gamma_hat) in A (from burgessR3 with beta.neg in B). BX5: untl(beta.neg AND untl(beta.neg, gamma_hat), gamma_hat) in A. Let q = beta.neg AND untl(beta.neg, gamma_hat). BX13: for each alpha_j: untl(q, gamma_hat AND snce(q, alpha_j)) in A (given alpha_j in A). BX10 on the final enriched formula: F(event') in A where event' = gamma_hat AND snce(q, alpha_1) AND ... AND snce(q, alpha_k).

  Event' implies: gamma_hat (hence each gamma_j), snce(q, alpha_j) for each j. By snce left_mono with q -> beta.neg: snce(beta.neg, alpha_j). But we need snce(beta'_j, alpha_j), not snce(beta.neg, alpha_j). For arbitrary beta'_j in B.

  Hmm. The left_mono for snce gives: if phi -> chi then snce(phi, psi) -> snce(chi, psi). So from q -> beta.neg: snce(q, alpha) -> snce(beta.neg, alpha). But we need snce(beta'_j, alpha_j) not snce(beta.neg, alpha_j).

  **NEW APPROACH FOR THE SMALL SEED**: Change the guard in the BX chain to be the full b = list_conj of all beta'_i (from the untl/snce formulas in L, all in B). Since beta.neg in B (inconsistent case), include beta.neg in b_list. Then b in B (DCS closure). untl(b, gamma_hat) in A (burgessR3). BX5: untl(b AND untl(b, gamma_hat), gamma_hat) in A. Let q = b AND untl(b, gamma_hat).

  NOW: we need BX14 to get the guard INTO the event. Without BX14, BX10 gives F(gamma_hat) in A. gamma_hat implies each gamma_j but NOT b, beta.neg, or the untl/snce formulas.

  WITH BX14: need (untl(r, gamma_hat)).neg in A. In the MCS case for B, find such r.

  Claim: (untl(r, gamma_hat)).neg in A for some r. If NOT, then untl(r, gamma_hat) in A for all r (MCS of A). In particular untl(phi, gamma_hat) in A for all phi. Then for all phi: BX10 gives F(gamma_hat) in A (already known). But also: this means A satisfies U(phi, gamma_hat) for ALL guards phi. Semantically on strict linear orders, this means there exists a future point where gamma_hat holds. This is consistent and doesn't derive a contradiction. So it IS possible that untl(r, gamma_hat) in A for all r.

  In that case: we CANNOT use BX14 at all for event=gamma_hat. We need a COMPLETELY different approach.

  **THE BREAKTHROUGH**: When untl(r, gamma_hat) in A for ALL r: use this fact directly! From untl(b, gamma_hat) in A for our specific b: combine with each alpha_j in A via BX13: untl(b, gamma_hat AND snce(b, alpha_j)) in A. Apply iterated BX13 to get untl(b, enriched_event) in A. BX10: F(enriched_event) in A. enriched_event = gamma_hat AND snce(b, alpha_1) AND ... AND snce(b, alpha_k). This event implies gamma_hat (hence each gamma_j) and snce(b, alpha_j). By snce left_mono with b -> beta'_j: snce(b, alpha_j) -> snce(beta'_j, alpha_j). 

  But we STILL don't have event implying beta.neg or the untl formulas! The event is gamma_hat AND snce-stuff. It does NOT imply b or beta.neg.

  **HOWEVER**: For the SMALL seed (without B), the elements we need event to imply are:
  1. beta.neg
  2. untl(beta'_j, gamma_j) for each untl-formula in L
  3. snce(beta'_j, alpha_j) for each snce-formula in L

  For items 2 and 3: untl(beta'_j, gamma_j) in A (from burgessR3). If we can find an event that implies ALL of them AND is consistent with beta.neg, we're done. 

  Since all untl(beta'_j, gamma_j) in A and all snce(beta'_j, alpha_j) in C: we need to show {beta.neg} U {subset of A} U {subset of C} is consistent. This is a COMPATIBILITY claim about A, C, and beta.neg.

  **FINAL DEFINITIVE APPROACH**: Prove a lemma `mcs_cross_consistent`:
  Given MCS A, MCS C, BurgessR3Maximal(A, B, C), and beta.neg in B:
  {beta.neg} U {untl(beta'_j, gamma_j) : beta'_j in B, gamma_j in C} U {snce(beta'_k, alpha_k) : beta'_k in B, alpha_k in A} is consistent.

  Proof: by the BX5+BX13+BX10 chain on the guard b = list_conj of all needed beta'-elements:
  1. untl(b, gamma_hat) in A (burgessR3 with b in B, gamma_hat in C)
  2. BX13 iterated: untl(b, enriched) in A where enriched = gamma_hat AND snce(b, alpha_1) AND ... 
  3. BX10: F(enriched) in A, so enriched is consistent
  4. enriched implies each gamma_j (from gamma_hat) and each snce(b, alpha_k) -> snce(beta'_k, alpha_k) by left_mono
  5. For beta.neg: enriched does NOT imply beta.neg, but: take b_new = beta.neg AND b. Still b_new in B (DCS). untl(b_new, gamma_hat) in A. BX13: untl(b_new, gamma_hat AND snce(b_new, alpha_j)) in A. Event from BX5: untl(b_new AND untl(b_new, gamma_hat), gamma_hat) in A.

  Wait: BX5 gives self-accumulation: untl(b_new, gamma_hat) -> untl(b_new AND untl(b_new, gamma_hat), gamma_hat). This puts b_new AND untl(b_new, gamma_hat) as the NEW guard. Then BX14 with... we're back to needing BX14.

  **OK FINAL RESOLUTION**: The pos sub-case can be handled WITHOUT BX14 by observing that when untl(bot, gamma_hat) in A (the pos sub-case): **the proof should NOT try to find a single event implying everything.** Instead, use a DIFFERENT proof structure:

  When untl(bot, gamma_hat) in A: by left_mono (efq), untl(q, gamma_hat) in A for ALL q. In particular untl(b_full, gamma_hat) in A where b_full = b AND beta.neg AND untl(b, gamma_hat) AND untl(b_new, gamma_hat) AND .... This is still in A. Apply BX13 iterated: untl(b_full, gamma_hat AND snce(b_full, alpha_j)) in A. BX10: F(gamma_hat AND snce(b_full, alpha_j) AND ...) in A.

  **NOW**: the event = gamma_hat AND snce-stuff. Does it imply beta.neg? By itself no. BUT: since untl(bot, gamma_hat) in A gives untl(q, gamma_hat) for ALL q, we can use q = beta.neg AND b to get: untl(beta.neg AND b, gamma_hat) in A. Combining with BX13:

  Actually the problem is BX13's enrichment only puts snce-formulas into the event. The guard NEVER enters the event without BX14.

  **I CONCEDE**: The pos sub-case genuinely requires BX14 (or an equivalent mechanism to transfer guard into event). Without a neg-until witness, BX14 cannot fire. The pos sub-case cannot be resolved using only BX5+BX13+BX10.

  **THE ACTUAL CORRECT FIX** (after all this analysis): 
  
  Prove that the pos sub-case is IMPOSSIBLE by showing that untl(b AND beta, gamma_hat) CANNOT be in A when the other hypotheses hold. Specifically: from BurgessR3Maximal(A, B, C), we can ALWAYS find a neg-until with event gamma_hat (by including the right gamma0 from the maximality witness in c_list). This works IF there exists ANY delta not-in B with {delta}UB consistent. When B is not MCS, such delta exists. When B IS MCS: show this contradicts BurgessR3Maximal having beta not-in B (it doesn't directly, but the specific constellation of formulas does).

  **WHEN B IS MCS AND burgessR3(A, B, C)**: For ALL beta' and gamma in C: untl(beta', gamma) in A (since beta' in B = Set.univ restricted to MCS). Wait no: burgessR3(A, B, C) means for all beta' IN B: untl(beta', gamma) in A. If B is MCS, every formula is in B or its neg is. For beta' in B: untl(beta', gamma) in A. For beta' not-in B (so beta'.neg in B): untl(beta'.neg, gamma) in A. But NOT necessarily untl(beta', gamma) in A.

  Actually if B is MCS: for ANY formula phi, either phi in B or phi.neg in B. So for any phi: we have untl(phi, gamma) in A OR untl(phi.neg, gamma) in A (depending on which is in B). This does NOT give untl(phi, gamma) in A for all phi.

  So B being MCS does NOT give burgessR3(A, Set.univ, C). Good.

  **When B is MCS**: there's no delta not-in B with {delta}UB consistent. So we can't get the neg-until from a different delta. We're stuck.

  **FINAL ANSWER**: The pos sub-case when B is MCS appears to be a genuine open problem in the current formalization. The correct fix MUST involve one of:
  1. Prove B is NEVER MCS when BurgessR3Maximal holds and beta not-in B exists (i.e., B has a proper consistent extension not satisfying burgessR3)
  2. Restructure to not need beta.neg in the D0 seed (let Lindenbaum choose which side of beta to include)
  3. Use a completely different D0 seed construction

  After this exhaustive analysis, I believe **option 2** is correct: The D0 seed should NOT include beta.neg. Burgess's ACTUAL D0 is: {U(beta', gamma)} U {S(beta', alpha)} for beta' in B, gamma in C, alpha in A. The requirement is that D (the Lindenbaum-extended MCS) satisfies beta.neg in D. This is achieved by Lindenbaum extension of D0 U {beta.neg} -- i.e., start from D0 U {beta.neg} and extend. The consistency of D0 U {beta.neg} in the inconsistent case reduces to: {beta.neg} U untl-formulas U snce-formulas consistent, where beta.neg works as the anchor for the BX chain (beta.neg in B gives us the guard for the chain).

  WAIT: that's exactly what I said earlier. D0 = {beta.neg} U untl U snce. We need this consistent. In the pos sub-case, we need an event implying beta.neg. The BX chain with guard starting from beta.neg DOES give event -> beta.neg (since beta.neg is in the conjunction that forms the guard, and event -> guard from BX14 output).

  The BX14 step requires (untl(r, gamma_hat)).neg in A. When untl(b AND beta, gamma_hat) in A (pos sub-case) with b containing beta.neg: b AND beta -> bot, so untl(bot, gamma_hat) in A. ALL untl with event gamma_hat are in A. So (untl(r, gamma_hat)).neg NOT in A for any r.

  **BUT**: the gamma_hat is CONSTRUCTED from the L we're given. We can CHOOSE what goes into c_list. If we include a gamma0 from a maximality witness (for some other delta with {delta}UB consistent), then gamma_hat includes gamma0, and (untl(beta0 AND delta, gamma0)).neg in A. By right_mono contrapositive (gamma_hat -> gamma0 since gamma0 in c_list): (untl(beta0 AND delta, gamma_hat)).neg in A.

  YES! So: include gamma0 (from maximality witness for delta) in c_list. Then (untl(beta0 AND delta, gamma_hat)).neg in A. Use r = beta0 AND delta for BX14. The pos sub-case with r = beta0 AND delta: untl(beta0 AND delta, gamma_hat) in A? From left_mono with bot -> beta0 AND delta (efq): untl(bot, gamma_hat) -> untl(beta0 AND delta, gamma_hat). So YES, untl(beta0 AND delta, gamma_hat) in A. CONTRADICTION with (untl(beta0 AND delta, gamma_hat)).neg in A!

  **THIS IS THE PROOF!** The pos sub-case IS vacuously contradictory WHEN there exists delta not-in B with {delta}UB consistent. In that case:
  - From maximality with delta: (untl(beta0 AND delta, gamma0)).neg in A
  - Include gamma0 in c_list: gamma_hat -> gamma0
  - Right_mono contrapositive: (untl(beta0 AND delta, gamma_hat)).neg in A
  - Pos sub-case gives untl(b AND beta, gamma_hat) in A -> untl(bot, gamma_hat) in A -> untl(beta0 AND delta, gamma_hat) in A (left_mono from bot)
  - Contradiction: both untl(beta0 AND delta, gamma_hat) and its neg in A (MCS inconsistency)

  And when B IS MCS (no such delta exists): need separate argument. But actually: if B is MCS and beta not-in B, then beta.neg in B. For the D0 seed {beta.neg} U untl U snce: the b_list should NOT include beta.neg specially. Instead, use a guard derived from some other B-element. Actually when B is MCS, the maximality is "vacuous" in a sense: B cannot be properly extended (it's already maximal consistent). The BurgessR3Maximal condition says no proper consistent DCS extension satisfies burgessR3. But B being MCS means no proper consistent extension exists AT ALL. So the maximality is trivially satisfied.

  When B is MCS and we call lemma_2_6_splitting: we need to produce an MCS D with beta.neg in D and BurgessR3Maximal(A, B', D) etc. Can we just take D = B? If beta.neg in D = B (yes!), and BurgessR3Maximal(A, B', B) for some B': that requires a new B' that is maximal DCS with burgessR3(A, B', B). This is the Zorn construction applied to A, -, B. So the splitting works even with B = D.

  Actually lemma_2_6_splitting's OUTPUT requires BurgessR3Maximal(A, B', D) AND BurgessR3Maximal(D, B'', C) AND SetMaximalConsistent D AND beta.neg in D. If D = B: beta.neg in B (check!), SetMaximalConsistent B (check if B is MCS!), BurgessR3Maximal(A, B', B) (need to prove), BurgessR3Maximal(B, B'', C) (need to prove).

  For the MCS-B case, we can bypass the D0 seed entirely and just use D = B. The only challenge is constructing B' and B''.

  **OVERALL CONCLUSION FOR PHASE 2**: 
  
  Case 1 (B not MCS -- {delta}UB consistent exists for some delta): Pos sub-case is VACUOUSLY CONTRADICTORY. Include gamma0 from the delta-maximality-witness in c_list. Right_mono contrapositive gives the neg-until for gamma_hat. Left_mono from bot gives the positive. Contradiction.

  Case 2 (B is MCS): Bypass the D0 seed. Use D = B directly (beta.neg in B, B is MCS). Construct B' and B'' using Zorn on appropriate structures.

  This is the mathematically correct and complete solution.

- [ ] **Task 2.4**: Implement the pos sub-case fix using the two-case approach:
  
  Case A: B is not MCS. Find delta not-in B with {delta}UB consistent (by classical logic: if for all delta not-in B, {delta}UB inconsistent, then B is MCS). Apply BurgessR3Maximal_extension_fails with delta to get (beta0, gamma0) witness. Include gamma0 in c_list. In the pos sub-case, derive contradiction:
  - untl(b AND beta, gamma_hat) in A (pos hypothesis)
  - left_mono from (b AND beta -> bot): untl(bot, gamma_hat) in A
  - left_mono from (bot -> beta0 AND delta): untl(beta0 AND delta, gamma_hat) in A
  - right_mono contrapositive from (gamma_hat -> gamma0): (untl(beta0 AND delta, gamma_hat)).neg in A
  - Contradiction with MCS consistency of A

  Case B: B is MCS. This case makes the ORIGINAL inconsistent case (beta.neg in B) immediate: since B is MCS, we can use D = B as the splitting point. Add a fast path:
  - Verify B is MCS
  - Set D = B (beta.neg in B, B is SetMaximalConsistent)
  - Construct B' = Zorn-maximal DCS with burgessR3(A, B', B)
  - Construct B'' = Zorn-maximal DCS with burgessR3(B, B'', C)
  - Return (B', B, B'')

- [ ] **Task 2.5**: Restructure `burgess_D0_finite_subset_consistent_incons` to implement the two-case approach. The overall structure:
  ```lean
  by_cases h_mcs_B : SetMaximalConsistent B
  · -- Case B is MCS: bypass D0, use D = B directly
    -- (return proof that goes through lemma_2_6_splitting's alternate path)
    sorry -- fill in Case B logic
  · -- Case B not MCS: find delta with {delta}UB consistent
    -- then the pos sub-case is vacuously contradictory
    -- proceed with neg sub-case only (already implemented)
    sorry -- fill in Case A logic
  ```

  For Case A: Extract witness `delta` from `not SetMaximalConsistent B`. This gives delta not-in B and delta.neg not-in B. Then {delta}UB consistent. Apply BurgessR3Maximal_extension_fails to get (untl(beta0 AND delta, gamma0)).neg in A. Include gamma0 in c_list. In the pos sub-case, derive contradiction as above. In the neg sub-case, use existing `burgess_zeta_consistent` call.

  For Case B: The function needs to prove `SetConsistent (burgess_D0_seed A B C beta)` (or the small seed). When B is MCS: the seed's consistency can be proved more directly since B is MCS (complete), but we need to be careful about untl-formulas-in-seed conflicting with B-elements (if B in seed) or not (if small seed). With the SMALL seed (no B): {beta.neg} U untl-formulas U snce-formulas. All untl-formulas in A, all snce-formulas in C, beta.neg in B subset of MCS B. Need to show this is consistent. Use: F(beta.neg) in A (derivable from the BX chain since beta.neg in B gives untl(beta.neg, gamma) in A, BX5 + BX10 gives F(gamma) not F(beta.neg)... hmm). Alternative for Case B: bypass the seed consistency entirely and have `lemma_2_6_splitting` handle the MCS case separately.

- [ ] **Task 2.6**: Restructure `lemma_2_6_splitting` to handle the B-is-MCS case as a fast path:
  ```lean
  by_cases h_mcs_B : SetMaximalConsistent B
  · -- B is MCS with beta.neg in B
    -- Use D = B as the splitting MCS
    -- Construct B' via Zorn for burgessR3(A, B', B)
    -- Construct B'' via Zorn for burgessR3(B, B'', C)
    exact ⟨B', B, B'', h_r3m_A_B'_B, h_r3m_B_B''_C, h_mcs_B, h_beta_neg_in_B⟩
  · -- B is not MCS (common case)
    -- Proceed with D0 seed construction as before
    ...
  ```

  For the Zorn constructions in the MCS case: the existing `zorn_burgessR3Maximal` machinery (in RRelation.lean) already handles this. It takes starting point (e.g., empty set or {phi} for seed), and produces maximal DCS satisfying burgessR3. Apply it with:
  - B' = zorn_burgessR3Maximal with endpoints A, -, B
  - B'' = zorn_burgessR3Maximal with endpoints B, -, C

- [ ] **Task 2.7**: Remove the sorry at line 1891. With the restructuring, the pos sub-case either:
  - Derives contradiction (Case A: B not MCS), or
  - Never arises (Case B: B is MCS, handled by fast path before reaching the seed consistency proof)

- [ ] **Task 2.8**: Verify the lemma_2_7_seed_consistent (line 2461) still compiles. Lemma 2.7 has its own seed definition and should be unaffected by Phase 2 changes. Confirm independence.

- [ ] **Task 2.9**: Run `lake build` and verify PointInsertion.lean sorry count drops from 2 to 1 (only lemma_2_7_seed_consistent remains).

**Timing**: 5-7 hours (increased from original 3-4h due to two-case restructuring and Zorn fast path)

**Depends on**: 1 (complete)

**Files to modify**:
- `PointInsertion.lean:1825-1891` - Restructure inconsistent case with two-case approach
- `PointInsertion.lean:2337-2366` - Restructure lemma_2_6_splitting for MCS fast path
- `PointInsertion.lean:894` - Optionally define `burgess_D0_seed_small` (or modify existing seed)

**Verification**:
- PointInsertion.lean sorry count: 2 -> 1 (only `lemma_2_7_seed_consistent` remains)
- `lake build` passes
- `lemma_2_6_splitting` compiles in both MCS and non-MCS cases
- Pos sub-case sorry at line 1891 removed
- irr_until axiom NOT used (confirmed)
- No new axioms introduced

---

### Phase 3: Lemma 2.7 — Seed Consistency (BX7 Three-Way) [NOT STARTED]

**Goal**: Implement `lemma_2_7_seed_consistent` (PointInsertion.lean:2461). This is the hardest single theorem -- the BX7 three-way disjunction with D1/D2 elimination.

**Paper reference**: Burgess Section 2.7, p.372 (Until-formula splitting with BX7 three-way disjunction)

**Tasks**:
- [ ] **Task 3.1**: Extract witness from `eta not in B` + BurgessR3Maximal. Use `BurgessR3Maximal_neg_or_ext_fails` (Phase 1): since eta not in B, case split. If inconsistent (eta.neg in B): this contradicts h_until (untl(xi, eta) in A with eta.neg in B leads to contradiction via `neg_untl_event` or direct semantic argument). So the consistent case must hold: extract `beta0, gamma0` with `neg untl(beta0 AND eta, gamma0) in A`.
- [ ] **Task 3.2**: Apply BX5 self-accumulation on both Until formulas to get enriched guards: `untl(beta0 AND untl(beta0, gamma0), gamma0) in A` and `untl(xi AND untl(xi, eta), eta) in A`.
- [ ] **Task 3.3**: Apply BX7 three-way disjunction (`linear_until_mcs`) with appropriate guards/events to produce D1 or D2 or D3 in A (by MCS disjunction property).
- [ ] **Task 3.4**: Eliminate D1 -- use left_mono on event component containing `eta AND gamma0`, reduce to show it contradicts the witness `neg untl(beta0 AND eta, gamma0) in A`.
- [ ] **Task 3.5**: Eliminate D2 -- mirror argument of D1 elimination.
- [ ] **Task 3.6**: Work with surviving D3. Apply right_mono to reduce guard. Apply BX14 separation with witness, then BX13 iterated enrichment to pack snce-formulas, then BX10 for F(event) in A.
- [ ] **Task 3.7**: Assemble proof: show event implies all 5 seed components (B-elements via b conjunction, xi from event component, untl/snce formulas via mono). Close `lemma_2_7_seed_consistent` and verify `lemma_2_7` (line 2463) compiles.

**Timing**: 4-5 hours

**Depends on**: 1 (complete)

**Files to modify**:
- `PointInsertion.lean:2461` - Replace sorry with full proof

**Verification**:
- `PointInsertion.lean` sorry count: 1 -> 0
- `lemma_2_7` (line 2463) compiles
- `lake build` passes

---

### Phase 4: C4/C5 Elimination — Co-Constructed g-Values and c2' [NOT STARTED]

**Goal**: Rewrite C4, C4', C5, C5' elimination functions in CounterexampleElimination.lean to populate g-values at new adjacent pairs, then close all 5 c2' sorries (lines 756, 794, 834, 872, 918). After this phase, g-values at new adjacent pairs satisfy `BurgessR3Maximal` and the c2' invariant is maintained.

**Paper reference**: Burgess Sections 2.9 (p.373) and 2.10 (p.374)

**Tasks**:
- [ ] **Task 4.1**: Rewrite `eliminate_C5_counterexample` (line 167) -- extract B from `lemma_2_4`, set `g'(x, y) = B`. Update return type to populate g-field for new pair.
- [ ] **Task 4.2**: Rewrite `eliminate_C5'_counterexample` -- mirror for Since direction.
- [ ] **Task 4.3**: Rewrite `eliminate_C4_counterexample` (line 304) -- call `lemma_2_6_splitting`, set `g'(x,z)=B'`, `g'(z,y)=B''`. Handle easy cases with `burgessR3Maximal_singleton`.
- [ ] **Task 4.4**: Rewrite `eliminate_C4'_counterexample` -- mirror for Since.
- [ ] **Task 4.5**: Fix call sites in `eliminate_potential_counterexample` and `omega_chain`. Verify compilation.
- [ ] **Task 4.6**: Close C5 forward c2' (line 756) -- BurgessR3Maximal from lemma_2_4 output.
- [ ] **Task 4.7**: Close C5' backward c2' (line 794) -- mirror.
- [ ] **Task 4.8**: Close C4 forward c2' (line 834) -- from lemma_2_6_splitting output, old pairs inherit, new pairs from splitting result.
- [ ] **Task 4.9**: Close C4' backward c2' (line 872) -- mirror.
- [ ] **Task 4.10**: Close density c2' (line 918) -- new point copies f(x); prove maximality for both new adjacent pairs.

**Timing**: 7-9 hours

**Depends on**: 2, 3

**Files to modify**:
- `CounterexampleElimination.lean:167` - Rewrite C5 elimination
- `CounterexampleElimination.lean:304` - Rewrite C4 elimination
- `CounterexampleElimination.lean:756,794,834,872,918` - Close c2' sorries

**Verification**:
- `CounterexampleElimination.lean` sorry count: 7 -> 2 (C4 hard cases remain)
- All four elimination functions compile with populated g-values
- `omega_chain` compiles with c2' invariant

---

### Phase 5: C4 Hard Cases — BurgessR3 Bridging [NOT STARTED]

**Goal**: Close the 2 hard-case sorries at CounterexampleElimination.lean lines 412 (C4 forward) and 510 (C4' backward).

**Paper reference**: Burgess Section 2.9 (C4 hard case -- gamma in f(w) and f(w_next))

**Tasks**:
- [ ] **Task 5.1**: Close C4 forward hard case (line 412). Apply `BurgessR3Maximal_neg_or_ext_fails` at `(f(w), g(w,w_next))` with extension candidate `gamma`. Extract witness, derive contradiction with counterexample condition. Assemble output with new midpoint MCS D where `gamma.neg in D`.
- [ ] **Task 5.2**: Close C4' backward hard case (line 510) -- mirror for Since using the Since analogue of the Phase 1 helper.

**Timing**: 3-4 hours

**Depends on**: 4

**Files to modify**:
- `CounterexampleElimination.lean:412` - Close C4 forward hard case
- `CounterexampleElimination.lean:510` - Close C4' backward hard case

**Verification**:
- `CounterexampleElimination.lean` sorry count: 2 -> 0
- Both C4/C4' elimination functions fully sorry-free
- `lake build` passes

---

### Phase 6: Limit C5 Full + FUC/FSC [NOT STARTED]

**Goal**: Prove `limit_satisfies_c5_full` and `limit_satisfies_c5'_full` in ChronicleConstruction.lean, then close the 2 FUC/FSC sorries in ChronicleToCountermodel.lean (lines 615, 619).

**Paper reference**: Burgess Claim 2.11, p.375 (truth lemma -- forward Until/Since coherence at limit)

**Tasks**:
- [ ] **Task 6.1**: Prove `finite_stage_guard_in_g` -- by induction on finite stage n, show that when witness y is added, guard xi is in every g-value for adjacent pairs between x and y. Uses c2' invariant (Phases 4/5) and the fact that Lemma 2.4's BurgessR3Maximal includes the guard in the interval DCS.
- [ ] **Task 6.2**: Lift `finite_stage_guard_in_g` to `xi in limit_g(x,y)` using C3 at the limit (`limit_c3_interval_subset_point`).
- [ ] **Task 6.3**: Assemble `limit_satisfies_c5_full` -- combine Tasks 6.1-6.2 with `limit_satisfies_c5_weak`.
- [ ] **Task 6.4**: Mirror `limit_satisfies_c5'_full` for Since.
- [ ] **Task 6.5**: Close FUC (ChronicleToCountermodel.lean:615) -- unpack hfam hypothesis to get Cantor preimages, apply `limit_satisfies_c5_full`, transfer back through isomorphism using `cantor_bfmcs` ordering/coherence properties.
- [ ] **Task 6.6**: Close FSC (ChronicleToCountermodel.lean:619) -- mirror.

**Timing**: 5-7 hours

**Depends on**: 5

**Files to modify**:
- `ChronicleConstruction.lean` - Add `finite_stage_guard_in_g`, `limit_satisfies_c5_full`, `limit_satisfies_c5'_full`
- `ChronicleToCountermodel.lean:615,619` - Close FUC/FSC sorries

**Verification**:
- `ChronicleToCountermodel.lean` sorry count: 2 -> 0
- `dd_countermodel_chronicle` fully sorry-free
- `lake build` passes

---

### Phase 7: Final Audit and Integration [NOT STARTED]

**Goal**: Verify the entire Chronicle/ directory is sorry-free and the countermodel construction delivers the representation theorem.

**Tasks**:
- [ ] **Task 7.1**: Run `#print axioms dd_countermodel_chronicle` -- verify no `sorryAx`.
- [ ] **Task 7.2**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- verify only comment occurrences.
- [ ] **Task 7.3**: Full `lake build` clean from scratch.
- [ ] **Task 7.4**: Generate summary artifact: `specs/107_.../summaries/57_execution-summary.md` with verification results, axiom audit, and metrics (sorry count 11 -> 0).

**Timing**: 1 hour

**Depends on**: 6

**Files to modify**:
- None (verification only)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/57_execution-summary.md` - Create summary artifact

**Verification**:
- Chronicle/ sorry count: 0
- `dd_countermodel_chronicle` has no `sorryAx` in its axioms
- Full `lake build` clean

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary
- [ ] `#print axioms dd_countermodel_chronicle` -- no `sorryAx` after Phase 7
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment occurrences
- [ ] `BurgessR3Maximal` maximality clause uses `SetDeductivelyClosed D` (matching Burgess 1982)
- [ ] Phase 2 pos sub-case resolved WITHOUT irr_until axiom
- [ ] All elimination functions' g-field non-empty for new adjacent pairs
- [ ] `omega_chain` type-checks with c2' invariant
- [ ] `limit_satisfies_c5_full` provable without circularity
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`
- [ ] No density or discreteness axioms added

## Artifacts & Outputs

- `plans/57_implementation-plan.md` (this file)
- `summaries/57_execution-summary.md` (Phase 7)
- Modified source files:
  - `PointInsertion.lean` (Phases 2, 3)
  - `CounterexampleElimination.lean` (Phases 4, 5)
  - `ChronicleConstruction.lean` (Phase 6)
  - `ChronicleToCountermodel.lean` (Phase 6)

## Rollback/Contingency

- **If pos sub-case contradiction argument fails in Case A (Phase 2 Task 2.4)**: Verify that right_mono contrapositive gives the neg-until for gamma_hat. If not, try: include BOTH beta0 AND gamma0 from the delta-witness in b_list and c_list, then show the formula `untl(b AND delta, gamma_hat)` is in A (left_mono from bot) AND its negation is in A (right_mono contrapositive from the witness). This should always work when {delta}UB consistent provides the witness.
- **If B-is-MCS fast path (Phase 2 Task 2.6) has unexpected complexity**: Fall back to showing B is NEVER MCS when BurgessR3Maximal(A, B, C) holds with beta not-in B. Proof sketch: B not MCS means there exists phi with phi not-in B and phi.neg not-in B; if this fails for all phi, then B is MCS; but then for the specific beta not-in B: beta.neg in B, and we can still construct D = B.
- **If Lemma 2.7 BX7 three-way is blocked (Phase 3)**: Use `lce_imp`/`rce_imp` for propositional simplifications; left/right mono existing tools. If D1/D2 elimination fails, check event formula constructors for BX7 output formatting.
- **If `finite_stage_guard_in_g` proves unprovable (Phase 6)**: Fall back to direct approach using limit_g definition + c2' invariant.
- **Build instability**: Commit after each task modification. Verify `lake build` incrementally.
