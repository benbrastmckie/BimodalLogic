# Teammate D Findings: Plan Critic and Gap Analysis

**Task**: 83 - Close Restricted Coherence Sorries
**Role**: Plan Critic / Gap Analyst
**Date**: 2026-04-03

## 1. Plan Evolution Timeline

| Version | Approach | Outcome | Why It Failed |
|---------|----------|---------|---------------|
| v1 | Targeted chain with round-robin scheduling | Phases 1-2 done, Phase 3 BLOCKED | Multi-target F-persistence gap: F-obligations killed by Lindenbaum extension during non-targeted steps |
| v2 | Enriched deferral seed with deferral disjunctions | Phase 1 BLOCKED | Enriched seed inconsistency: deferral disjunctions are not G-liftable, so G-lift consistency argument fails for G-formula targets |
| v3 | Filtered compatible F-formulas + topological ordering on blocking DAG | Phase 1 PARTIAL | Joint consistency of filtered F-formulas is unprovable -- concrete counterexample constructed (G(p->G(neg A) v G(neg B)) with F(p), F(A), F(B)) |
| v4 | DRM chain with bounded_witness | Phase 1 BLOCKED | bounded_witness requires full MCS (single_step_forcing needs negation from maximality); DRM-to-MCS bridge loses Succ relation due to g_content expansion |
| v6 | Burgess-Xu Until/Since enrichment (10 new axioms) | Phases 1-6 COMPLETED, Phase 7 BLOCKED | Until/Since truth lemma backward direction: getting G(phi U psi) in mcs(t) requires phi U psi at ALL j >= t, but no witnesses available past s |
| v8 (=v7) | Half-open interval semantics for Until/Since | Phases 1-3 COMPLETED, Phase 4 BLOCKED | Same backward truth lemma blocker; half-open doesn't help with extending phi U psi past the witness point s |
| v11 (=v8) | Strict semantics refactor (< instead of <=) for G/H/U/S | Phases 1-4 COMPLETED, Phase 5 BLOCKED | Removing T-axiom breaks g_content(M) subset successor(M) pattern used in ~26 sorry sites across 6 files |
| v12 | g_content blocker resolution (3-tier decomposition) | Phases 1,6 COMPLETED, Phases 2-5 incomplete | X-content propagation gap: X(alpha) = bot U alpha is neither in g_content nor f_content; Succ relation doesn't propagate it |

## 2. Recurring Failure Patterns

### Pattern A: The Seed Consistency Trap (v1, v2, v3, v4)
Every plan that tried to enrich the Lindenbaum seed with additional formulas (F-formulas, deferral disjunctions, filtered compatible formulas) ran into the same fundamental problem: proving the enriched seed is consistent requires a G-lift argument, but the additional formulas are not G-liftable. Individual compatibility does not imply joint compatibility (as the v3 counterexample proved definitively).

**Confidence**: HIGH. This pattern is mathematically settled with a concrete counterexample. No further seed-enrichment approaches should be attempted within the original reflexive axiom system.

### Pattern B: The Perpetual Deferral Problem (v1, v2, v3, v4)
In the original TM system with reflexive G/H, F(psi) and neg(psi) coexist consistently in an MCS. The Lindenbaum extension can always choose F(psi) over psi (deferring the obligation). No syntactic mechanism forces eventual resolution. This is not a bug but a fundamental limitation of the F-only axiom system.

**Confidence**: HIGH. Confirmed across 5 research rounds and 4 plan versions. The team research report 05 conclusively showed perpetual deferral IS semantically consistent in reflexive TM.

### Pattern C: The Backward Truth Lemma Wall (v6, v8)
Every approach to proving the Until/Since backward truth lemma hits the same structural blocker: to get phi U psi in mcs(t) from semantic witnesses, you need G(phi U psi) in mcs(t), which requires phi U psi at ALL j >= t, but the semantic Until witness only provides information up to time s (the witness). Beyond s, there is no way to establish phi U psi holds.

**Confidence**: HIGH. This appeared independently in v6 (Phase 7), v8 (Phase 4), and persists in v11/v12. The handoff document 08_backward-until-handoff.md lists 4 attempted approaches, all blocked.

### Pattern D: The T-Axiom Dependency Web (v11, v12)
Removing the T-axiom (G(phi) -> phi) to fix the perpetual deferral problem (Patterns A/B) creates a cascade of ~67 broken call sites. The T-axiom was used pervasively throughout the algebraic layer, chain infrastructure, and truth lemma. Replacing it requires finding alternative derivation routes for each usage pattern. The g_content(M) subset successor(M) property, which was trivially true under reflexive semantics, now requires a non-trivial proof-theoretic detour.

**Confidence**: HIGH. This is an observed empirical fact of the codebase.

### Pattern E: Scope Creep Through Semantic Redesign (v6 onward)
Starting with v6, the plans shifted from "close 2 sorry sites" to "redesign the temporal logic system." The Until/Since enrichment (v6) added 2 formula constructors and 10 axioms. The strict semantics refactor (v11) changed every temporal quantification from <= to <. These are legitimate mathematical improvements, but they transformed a proof completion task into a foundational refactor, multiplying the sorry count from 2 to ~76 (242 grep hits including comments).

**Confidence**: HIGH. Observable from artifact numbers: the sorry count has increased, not decreased.

## 3. Current Plan (v12) Gap Analysis

### Phase 1: Derived Theorems G(a)->X(a) and H(a)->Y(a) [COMPLETED]

Status: Done but with 4 sorry in TemporalDerived.lean (X_bot_absurd, Y_bot_absurd, until_implies_some_future, since_implies_some_past). These are supposed to be the foundational derived theorems but they themselves have sorry.

**Gap**: The v12 summary states these are "sorry-guarded derived theorems." If the foundation has sorry, the entire tier 2 fix strategy (which depends on G(a)->X(a)) is built on sand. The research report 12 provided a convincing derivation sketch, but the Lean implementation was not completed.

**Risk**: MEDIUM. The derivation sketch appears mathematically sound (the prop_s + until_induction argument is elegant), but Teammate D's objections in report 12 raised legitimate questions about circularity. The actual Lean implementation may reveal additional gaps.

### Phase 2: Seed Enrichment with g_content [IN PROGRESS]

**Gap**: The plan says "enrich temporal_box_seed to include g_content(M)" but the summary reports this is incomplete. The consistency proof via G-lift argument is sketched but not implemented.

**Critical dependency**: All Tier 1 fixes depend on this phase. If the enriched seed consistency proof fails, 11 sorry sites remain open.

**Risk**: LOW-MEDIUM. The G-lift argument for seed enrichment is standard and well-understood. The main concern is whether the current axiom shapes (G-quantified until_induction premises) create complications in WitnessSeed.lean.

### Phase 3: Tier 1 Sorry Sites [PARTIAL]

**Gap**: Some Tier 1 sites were fixed but the plan acknowledges an audit is needed for "self-g_content vs parent-g_content" in SuccChainFMCS. This audit has not been completed.

### Phase 4: Tier 2 Sorry Sites [NOT STARTED]

**Gap**: This phase depends entirely on Phase 1's G(a)->X(a) derived theorem being sorry-free. Currently it is not.

**Additional gap**: The plan says "change >= to > in theorem statements" but does not address what happens to call sites that relied on the >= version. Each call site needs to provide a strict inequality proof, which may require restructuring the surrounding proof.

### Phase 5: Tier 3 Sorry Sites [PARTIAL]

**Gap**: R_G/R_H deletion was done but the plan acknowledges some sites may need to remain sorry "on the algebraic path." The number of accepted sorries is not bounded.

**Risk**: The algebraic layer (TenseS5Algebra, InteriorOperators) is used by the modal completeness infrastructure. If these sorries are on the completeness path, they block the goal.

### Phase 6: Cascade Fixes [COMPLETED]

**Gap**: The summary says "build now succeeds with 0 errors" but also reports ~15 sorry on the critical completeness path and ~61 on non-critical paths. The "cascade fixes" were achieved by inserting sorry, not by actually fixing the underlying proofs.

### Critical Cross-Phase Dependency

The plan does NOT account for the X-content propagation gap identified in the v12 summary:

> X(alpha) = bot U alpha is not a G-formula (not in g_content), not an F-formula (not in f_content). The Succ relation only propagates g_content and f_content.

This means that even if G(a)->X(a) is proved and g_content is in the seed, getting from X(alpha) in mcs(t) to alpha in mcs(t+1) requires extending the Succ relation. This is a structural change to the FMCS infrastructure that is NOT covered in any phase of the v12 plan.

## 4. Mathematical Soundness Assessment

### Is the strict semantics approach mathematically sound?

**YES, with caveats.** (Confidence: HIGH)

Strict temporal semantics for G/H/U/S over discrete linear orders (Z) is a well-studied system in temporal logic. The Burgess-Xu axiomatization with strict quantification is known to be sound and complete. Removing the T-axiom is mathematically correct -- under strict semantics, G(phi) does NOT imply phi at the current time.

**Caveats**:
1. The specific axiom formulations (G-quantified premises for until_induction) need careful verification. The v11 summary noted that 2 axioms were unsound in their original form and had to be fixed (until_induction needed G() wrapping, until_linearity needed a third disjunct).
2. The half-open interval change for Until/Since (v8) makes until_unfold and until_induction UNSOUND. This was noted in the v8 summary. The strict semantics approach (v11) uses X/Y-based Until/Since which avoids this issue.

### Does removing the T-axiom break expected properties?

**YES, it breaks g_content(M) subset M** (the T-axiom pattern). (Confidence: HIGH)

This is the entire content of the v12 plan -- resolving this breakage. The property is replaced by: g_content(M) subset successor(M) in the canonical chain, which is semantically valid but proof-theoretically harder.

### Is restricted completeness over integers a valid substitute for full completeness?

**YES.** (Confidence: HIGH)

Completeness over Z (the integers) is the standard target for discrete linear temporal logic. The restriction to deferralClosure formulas for temporal coherence is a standard technique in canonical model constructions. Full temporal coherence (for all formulas) would give completeness over all discrete linear frames, but the restricted version over Z is the mathematical standard.

### Published references

The key references are:
- Burgess (1982): Axiomatization of linear temporal logic with Until
- Xu (1988): Completeness of Until-enriched tense logic
- Reynolds (2003): Axiomatization and completeness results for Until logic

The project's approach aligns with the Burgess-Xu system. The strict semantics is the standard formulation in modern temporal logic (Gabbay-Hodkinson-Reynolds 1994).

## 5. Specific Gap Inventory

### Gap 1: X-Content Propagation (FUNDAMENTAL)
- **What**: X(alpha) in mcs(t) does not imply alpha in mcs(t+1) under current infrastructure
- **Why unaddressed**: Identified only in the v12 implementation summary, after the plan was written
- **Type**: Engineering challenge (requires Succ relation extension)
- **Resolution**: Extend Succ with x_step: X(alpha) in u implies alpha in v. This is semantically valid (X means "next time") and should be provable from the chain construction. Alternatively, derive F(alpha) from X(alpha) (since X(alpha) -> F(alpha) on discrete frames) and use existing F-propagation.

### Gap 2: TemporalDerived.lean sorry (BLOCKING)
- **What**: 4 sorry in the supposedly "derived" theorems G->X and H->Y
- **Why unaddressed**: Implementation complexity -- the derivation trees are 12+ steps long
- **Type**: Engineering challenge (the math is settled)
- **Resolution**: Implement the derivation tree step by step following the research report 12 sketch

### Gap 3: Backward Until Truth Lemma (FUNDAMENTAL)
- **What**: Semantic Until witnesses do not extend past the witness point s
- **Why unaddressed**: 4 plan versions have tried to solve this; all failed
- **Type**: Fundamental mathematical obstacle
- **Resolution options**:
  1. **Contrapositive approach** (from v11 plan Phase 8): Assume neg(phi U psi) in mcs(t), use forward truth lemma to get semantic contradiction. This was proposed but never implemented.
  2. **Fischer-Ladner closure induction**: Restructure the truth lemma to induct over the Fischer-Ladner closure instead of formula structure, breaking the circularity.
  3. **Direct chain construction**: Build the canonical chain so that phi U psi persists by construction (encode Until persistence directly into the Succ relation, which already has u_step).

### Gap 4: WitnessSeed Axiom Shape Mismatch (BLOCKING)
- **What**: until_induction/since_induction now have G/H-quantified premises; WitnessSeed proofs that use these axioms are broken
- **Why unaddressed**: Identified in v12 plan but Phase 6 "fixed" it by inserting sorry
- **Type**: Engineering challenge
- **Resolution**: Reconstruct WitnessSeed proofs using temporal necessitation + K-distribution pattern

### Gap 5: SuccChainFMCS T-Axiom Sites (BLOCKING)
- **What**: 4 sorry sites where temp_t_future/temp_t_past was directly used
- **Why unaddressed**: Phase 5 was supposed to handle this but is incomplete
- **Type**: Engineering challenge (each site needs individual analysis)
- **Resolution**: Case-by-case replacement using G(a)->X(a) or seed membership

### Gap 6: Soundness Proofs for Temporal Axioms (NON-BLOCKING for completeness, but concerning)
- **What**: 20 sorry in Soundness.lean for temporal axiom soundness
- **Why unaddressed**: Marked as non-blocking since completeness path doesn't need them
- **Type**: Mixed -- some are genuinely unsound under the CURRENT semantics (half-open artifacts from v8 that were not fully reverted)
- **Resolution**: Need semantic audit to determine which axioms are sound under the current (strict + half-open?) semantics

## 6. Risk Matrix for Current Plan (v12)

| Risk | Impact | Likelihood | Current Mitigation | Assessment |
|------|--------|------------|-------------------|------------|
| X-content propagation not resolved | CRITICAL | HIGH | None (gap not in plan) | Plan amendment needed |
| G(a)->X(a) derivation has Lean implementation gap | HIGH | MEDIUM | Derivation sketch exists | Needs focused engineering effort |
| Backward Until truth lemma remains unsolvable | CRITICAL | MEDIUM | Contrapositive approach proposed but untried | Highest mathematical risk |
| Soundness inconsistencies from mixed semantics | HIGH | MEDIUM | Deferred to separate task | Debt accumulation risk |
| Sorry count continues to grow, not shrink | HIGH | HIGH | None | Architectural concern |
| Algebraic layer sorries block completeness path | MEDIUM | LOW | Plan accepts some on "non-critical path" | Needs audit |
| Until/Since connectedness axioms are unsound | LOW | CONFIRMED | Marked sorry, not on completeness path | Acceptable for now |

## 7. Recommended Plan Amendments

### Amendment 1: Add X-Content Propagation Phase (Priority: CRITICAL)
Insert a phase between Phase 2 and Phase 3 that:
1. Extends the Succ relation with x_step and y_step
2. Proves X(alpha) in u implies alpha in v for Succ u v
3. Updates SuccExistence and successor construction to maintain x_step
4. Alternatively: proves X(a) -> F(a) as a derived theorem and routes through existing F-propagation

### Amendment 2: Complete TemporalDerived.lean Before Other Phases (Priority: HIGH)
Phase 1 must be FULLY completed (zero sorry) before Phase 4 can begin. The current state (4 sorry in the foundation) means all downstream phases are building on unverified assumptions.

### Amendment 3: Resolve the Backward Truth Lemma Explicitly (Priority: CRITICAL)
The current plan does not have a specific phase for the backward Until truth lemma (Gap 3). This is the longest-standing blocker (since v6). The plan should include an explicit phase with a concrete strategy. The contrapositive approach (v11 Phase 8) is the most promising:
- Forward truth lemma gives: phi U psi in mcs(t) implies truth(phi U psi, t)
- Contrapositive: neg truth(phi U psi, t) implies phi U psi not in mcs(t)
- By MCS maximality: truth(phi U psi, t) implies neg(phi U psi) not in mcs(t) implies phi U psi in mcs(t)

This requires that the forward truth lemma is already proved for neg(phi U psi), which has SMALLER Until complexity (the Until is under a negation, which is a subformula). This breaks the circularity IF the induction metric is chosen correctly.

### Amendment 4: Semantic Consistency Audit (Priority: MEDIUM)
Conduct an audit to determine the exact current semantics:
- Are Until/Since using half-open (from v8) or strict (from v11)?
- Which axioms are sound under the current semantics?
- Are there any axioms marked as valid that are actually unsound?
The soundness file has 20 sorry -- some may indicate genuine unsoundness, not just incomplete proofs.

## 8. Alternative Approaches Not Yet Tried

### Alternative A: Proof by Contradiction at the Meta Level
Instead of proving the backward truth lemma directly, prove that if completeness fails, there exists a formula phi such that phi is valid but not provable. Then show this leads to a contradiction using the canonical model construction. This avoids needing the backward truth lemma for Until as a standalone lemma -- instead, the entire completeness argument is a single proof by contradiction.

**Feasibility**: MEDIUM. Standard in textbook presentations but harder to formalize in Lean because the canonical model construction must be done inside the contradiction context.

### Alternative B: Quotient Model Construction
Instead of building the canonical model from MCS chains, build it from equivalence classes of formulas modulo provable equivalence. The truth lemma then becomes a structural property of the quotient, not a chain-level property. Until/Since semantics follow from the algebraic structure.

**Feasibility**: LOW. Requires significant new infrastructure (TenseS5Algebra already exists but lacks Until/Since support).

### Alternative C: Step Back to Reflexive Semantics and Accept Restricted Completeness
Revert the strict semantics change (v11) and the Until/Since extension (v6). Accept that the original 2 sorry sites (succ_chain_restricted_forward_F/backward_P) are unprovable in the original system. Instead, prove a WEAKER completeness theorem: completeness for the G/H-free fragment, or completeness for formulas with bounded temporal nesting depth. This avoids the entire perpetual deferral problem.

**Feasibility**: MEDIUM. Would undo ~100 hours of work but would give a clean, sorry-free (partial) result.

### Alternative D: Focused Fix of Just the 2 Original Sorries via Resolving Chain
The ResolvingChain.lean (created in v3, sorry-free) provides DRM chains with f_step and Succ. The v4 plan's DRM bounded_witness approach was blocked by the MCS requirement. But: instead of adapting bounded_witness, prove a NEW theorem specifically for DRM chains. The DRM has maximality for deferralClosure formulas, which suffices for single_step_forcing when all involved formulas are in deferralClosure. This avoids the entire strict semantics detour.

**Feasibility**: MEDIUM-HIGH. This was the v4 approach; the specific blocker (DRM maximality vs MCS maximality) might be solvable with a careful DRM-specific bounded_witness variant. No one has actually tried implementing this variant.

## 9. Honest Assessment: Is This Task Achievable?

### With the current approach (strict semantics + Until/Since + v12 plan)?

**UNCERTAIN.** (Confidence: MEDIUM)

The strict semantics direction is mathematically sound, and the plan has made genuine progress (Phases 1 and 6 complete, foundational infrastructure built). However:

1. **The sorry count has gone UP, not down.** From 2 original sorries, we now have ~76 (15 on critical path). This is moving in the wrong direction.
2. **The backward truth lemma is unsolved after 4 attempts.** This is the hardest mathematical problem and no plan version has cracked it.
3. **The X-content propagation gap was discovered during implementation, not during planning.** This suggests the plan is not fully anticipating the challenges.
4. **The plan is now at v12.** The iteration count itself is a warning signal.

### With Alternative D (DRM bounded_witness variant)?

**MORE LIKELY.** (Confidence: MEDIUM)

This approach avoids the entire strict semantics refactor and stays within the original system. The key insight is that DRM maximality for deferralClosure formulas should suffice for bounded_witness. This has never been actually tried -- the v4 plan identified the blocker but never attempted to work around it. The DRM variant of single_step_forcing needs: "if F^{n+1}(psi) not in DRM(t), then neg(F^{n+1}(psi)) in DRM(t)." This holds when F^{n+1}(psi) is in deferralClosure, which is guaranteed when psi is in deferralClosure and n+1 is within the closure's F-nesting bound.

### Bottom line

The task is achievable, but the current approach has accumulated significant technical debt through 12 plan versions. The most promising path forward is either:

1. **Finish the strict semantics path** by resolving the 3 critical gaps (X-content propagation, TemporalDerived sorry, backward truth lemma) -- estimated 15-25 more hours with HIGH uncertainty.
2. **Pivot to Alternative D** (DRM bounded_witness on the original reflexive system) -- estimated 8-12 hours with MEDIUM uncertainty, but requires reverting or branching from the strict semantics work.

The choice depends on whether the strict semantics refactor is valued as a permanent architectural improvement (beyond just closing the 2 sorries) or whether the goal is purely to achieve sorry-free completeness with minimal changes.
