# Teammate B Findings: Alternative Constructions and What the Blockers Reveal

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-02
**Focus**: Diagnostic analysis of the G/F asymmetry, literature survey of alternative constructions, language enrichment options, and concrete proposal

## Key Findings

### 1. The G/F Asymmetry is a Universal/Existential Witness Problem (Confidence: HIGH)

The fundamental reason g_content propagates but F-obligations don't is the mathematical difference between universal and existential quantification in the canonical model construction:

- **G(phi)** = "phi at all future times" (universal). `g_content(M) = {phi | G(phi) in M}`. The key invariant `g_content(M) subset W` propagates because: G(phi) in M implies G(G(phi)) in M (by temp_4), so G(phi) in g_content(M), so G(phi) in W, so phi in g_content(W). The universal quantifier is "closed under successors" -- once true, always true.

- **F(phi)** = "phi at some future time" (existential). F(phi) in M does NOT imply G(F(phi)) in M. The formula `F(phi) -> G(F(phi))` says "if phi holds sometime, then at all future times phi still holds sometime" -- this is valid over Z (if phi holds at time t, then from any t' >= now, phi still holds at t which is >= now but may not be >= t'). Actually `F(phi) -> G(F(phi))` is NOT valid over Z: if phi holds at time 5 and we're at time 3, then F(phi) holds at time 3, but at time 7, F(phi) need not hold (phi might only be true at time 5, and 5 < 7).

This is the crux: G-formulas self-propagate via temp_4 (`G(phi) -> G(G(phi))`), creating a "ratchet" effect. F-formulas have no such ratchet. The Lindenbaum extension can freely add G(neg(phi)) to the successor, permanently killing the F-obligation. This is not a bug in the construction -- it reflects a genuine semantic distinction.

**Diagnostic value**: Any successful construction must either (a) explicitly control which formulas the Lindenbaum extension adds, (b) work at a level where the universal/existential distinction is already resolved, or (c) enrich the language so that F-obligations can be G-wrapped.

### 2. Standard Kt Completeness Uses Tree-Then-Unravel, Not Direct Chain (Confidence: HIGH)

The standard completeness proof for basic tense logic Kt (Goldblatt 1992, Venema 1993, Burgess 1982) does NOT build a linear chain directly. The method is:

**Phase 1: Canonical Frame** -- Build the full canonical frame where worlds = all MCS, and the temporal accessibility relation R is defined by g_content inclusion. In this frame, F-witnesses exist trivially (each F(phi) in M gets its own witness W via Lindenbaum({phi} union g_content(M)), exactly as in `canonical_forward_F` in the codebase).

**Phase 2: Point Generation** -- For the specific MCS M0 containing neg(phi), build a TREE of MCS rooted at M0 by repeatedly spawning witnesses for all F and P obligations. This tree has branching because different F-obligations get different witnesses.

**Phase 3: Linearization** -- For linear time, the tree must be "unraveled" into a linear order. This is where the hard work happens. For Kt over arbitrary linear orders, Burgess (1982) and Xu (1988) use the constructive method: the MCS at each point is built step-by-step, incorporating constraints from already-placed points. For Z specifically, de Jongh/Veltman/Verbrugge's "completeness by construction" method places points incrementally, choosing "maximal" extensions (containing as many G-formulas as possible) at each stage.

**Key insight**: The standard approach never tries to prove that a SINGLE chain construction resolves all F-obligations. Instead, it builds the canonical frame (where resolution is trivial) and then EXTRACTS a linear structure. The codebase's approach of trying to construct the chain directly and then prove resolution is working at the wrong level of abstraction.

### 3. The Linearity Axiom Provides a Key Structural Constraint (Confidence: HIGH)

The linearity axiom `F(a) /\ F(b) -> F(a /\ b) \/ F(a /\ F(b)) \/ F(F(a) /\ b)` combined with temp_4 and the T-axiom gives TM enough power to reason about the temporal ordering of witnesses. As established in prior research (teammate A, round 3), the blocking relation is acyclic, which is proven using the linearity axiom.

But the linearity axiom provides something MORE: it constrains how F-obligations interact at the SEED level. For two F-obligations F(psi) and F(chi) both in M, the linearity axiom forces one of three structural relationships. This means the canonical model's temporal accessibility is already constrained to be linear-like, even before we attempt to extract a Z-chain.

**Diagnostic value**: The linearity axiom is not just about preventing branching -- it constrains the set of consistent successors enough that a carefully chosen Lindenbaum extension MUST preserve certain F-obligations.

### 4. The Two-Phase Construction (Canonical Frame + Path Extraction) is the Right Approach (Confidence: HIGH)

Based on the literature survey and codebase analysis, the correct architecture is:

**Step 1**: Use the existing canonical frame (CanonicalFrame.lean) where F-witnesses exist trivially via `canonical_forward_F`.

**Step 2**: From a given MCS M0, extract a Z-indexed path through the canonical frame that:
- Is a valid FMCS (forward_G, backward_H -- via g_content inclusion along the path)
- Satisfies forward_F and backward_P (via the frame's existing witnesses)

The existing `TargetedFMCS` in `TargetedChain.lean` is essentially doing Step 2 but with a defect: it builds the path by choosing ONE target per step (round-robin), and this targeted step can lose other F-obligations.

**The fix**: Instead of round-robin targeting, use an **exhaustive resolution strategy**:
- At each step n, resolve ALL pending F-obligations from chain(n) simultaneously
- This requires building the successor to satisfy ALL F-obligations at once
- The key question: can we build a single MCS that resolves all pending F-obligations while maintaining g_content?

### 5. Simultaneous F-Resolution via Finitely Many Obligations (Confidence: MEDIUM-HIGH)

The deferralClosure(root) is finite. At any step, the number of pending F-obligations is bounded by |deferralClosure(root)|. Call these F(psi_1), ..., F(psi_k) where each F(psi_i) in chain(n).

**Claim**: `{psi_1, ..., psi_k} union g_content(M)` is consistent when all F(psi_i) in M.

**Proof sketch**: By contradiction. Suppose L subset {psi_1, ..., psi_k} union g_content(M) derives bot. If no psi_i in L: L subset M (g_content subset M by T-axiom), contradicts M consistent. So some psi_i in L. By deduction: L \ {psi_i} derives neg(psi_i). All of L \ {psi_i} is in M (g_content by T-axiom, other psi_j by... wait, psi_j may not be in M).

**Problem**: psi_j may NOT be in M. We have F(psi_j) in M, meaning psi_j.neg.all_future.neg in M, which means G(neg(psi_j)) not in M. But psi_j itself could be in M or not. If neg(psi_j) in M, then psi_j is not in M.

So `{psi_1, ..., psi_k} union g_content(M)` is NOT guaranteed to be a subset of M. The G-wrapping argument from `forward_temporal_witness_seed_consistent` only works for a SINGLE target. With multiple targets, the G-wrapping step fails because you cannot G-wrap the other targets.

**However**: Consider the seed `{psi_1} union g_content(M)`. This is consistent (proven by `forward_temporal_witness_seed_consistent`). The Lindenbaum extension W_1 satisfies psi_1 in W_1 and g_content(M) subset W_1.

Now: does F(psi_2) survive in W_1? We need F(psi_2) in W_1, i.e., G(neg(psi_2)) not in W_1. Since W_1 is a maximal consistent extension of `{psi_1} union g_content(M)`, we need to know whether G(neg(psi_2)) is consistent with this seed. This is exactly the blocking question: psi_1 blocks psi_2 iff `{psi_1} union g_content(M) |- G(neg(psi_2))`.

If psi_1 does NOT block psi_2, then G(neg(psi_2)) is NOT derivable from the seed -- but the Lindenbaum extension CAN still include it (it only needs consistency, not derivability). This is the perpetual-deferral problem restated.

### 6. The "Controlled Lindenbaum" Approach: Seed Enrichment with F-Preservation (Confidence: MEDIUM)

The key insight from the prior research (reports 02, 04) is that adding `F(psi_j)` formulas to the seed PREVENTS their G-negation from entering the extension:

Seed = `{target} union g_content(M) union {F(psi_j) | F(psi_j) in M, psi_j in DC, psi_j != target}`

Since F(psi_j) = neg(G(neg(psi_j))), having F(psi_j) in the seed forces G(neg(psi_j)) OUT of any consistent extension. This is the "controlled Lindenbaum" idea.

**Consistency of this seed**: All non-target elements are in M (g_content by T-axiom, F(psi_j) by hypothesis). So the seed equals `{target} union S` where `S subset M`. Suppose L subset seed, L derives bot.

- If target not in L: L subset S subset M, contradicts M consistent.
- If target in L: L' = L \ {target} subset S subset M. L' derives neg(target). By MCS closure, neg(target) in M. This is fine -- F(target) in M and neg(target) in M are compatible (target false now, true eventually).

But does this give a contradiction? No! The fact that L', a subset of M, derives neg(target) does not violate M's consistency. We just showed neg(target) in M. And {target, neg(target)} is inconsistent, but the question is whether the FULL L (with target) can derive bot.

Yes, it can: L' derives neg(target), so L' union {target} derives bot. But this is exactly what we're TRYING to show is impossible.

**The argument MUST use the temporal structure.** The standard `forward_temporal_witness_seed_consistent` proves `{target} union g_content(M)` is consistent by: suppose it's inconsistent, then g_content(M) derives neg(target). By G-wrapping (all elements of g_content have G-versions in M), G(neg(target)) in M. But F(target) = neg(G(neg(target))) in M, contradicting M's consistency.

For the enriched seed, the G-wrapping step fails because F(psi_j) does not have a G-version in M. BUT: the G-wrapping is only needed for the target's negation. The F(psi_j) formulas are already in M, so they cannot cause inconsistency WITH M. The only potential inconsistency is between target and the rest.

**Refined argument**: Suppose `{target} union g_content(M) union {F(psi_j)_j} |- bot`. Since `g_content(M) union {F(psi_j)_j} subset M`, we need `target` in the derivation. So `g_content(M) union {F(psi_j)_j} |- neg(target)`. But this means `neg(target) in M` (by MCS closure). ALSO `G(neg(target)) not in M` (because F(target) in M). So `neg(target) in M` but `G(neg(target)) not in M`.

Now consider: ALL elements of `g_content(M) union {F(psi_j)_j}` are in M, and their conjunction derives neg(target) which is also in M. There's no contradiction yet. The seed `{target} union stuff_in_M` is inconsistent iff `stuff_in_M |- neg(target)`. Since neg(target) in M and stuff_in_M subset M, clearly `stuff_in_M |- neg(target)` is possible (just put neg(target) in stuff_in_M -- but neg(target) might not be in g_content or in the F-set).

**Actually**: neg(target) is NOT necessarily in g_content(M) (that would require G(neg(target)) in M, but F(target) in M prevents this). And neg(target) is not an F-formula. So neg(target) is NOT in the seed. The derivation `g_content(M) union {F(psi_j)_j} |- neg(target)` must combine elements from the seed to derive neg(target) without having neg(target) directly.

**Can this happen?** It requires a finite subset of g_content(M) union {F(psi_j)} that, combined with the TM axioms, derives neg(target). Each g_content element phi_i has G(phi_i) in M. Each F(psi_j) is in M. By G-wrapping only the g_content part: G(phi_1 /\ ... /\ phi_n -> F(psi_j1) -> ... -> F(psi_jm) -> neg(target)) in M (by temp_k on the phi_i part, but we cannot G-wrap the F parts).

This is exactly the same blocker identified in report 04. The enriched seed consistency cannot be proven by G-wrapping alone when F-formulas are present.

### 7. The Correct Construction: Replace the Chain with TargetedFMCS + Inductive F-Resolution (Confidence: MEDIUM-HIGH)

Given the analysis above, here is the recommended approach:

**Core Idea**: Don't try to build a single chain that resolves all F-obligations. Instead, REPLACE `succ_chain_fam` (and its sorries) with a different chain that PROVABLY resolves F-obligations. The TargetedFMCS already does this for individual obligations. The missing piece is composing individual resolutions.

**Construction** (forward direction, for psi in deferralClosure(root)):

Given F(psi) in chain(t), we need to find s >= t with psi in chain(s).

The TargetedFMCS with targets = [psi] would resolve psi at step t+1 (if F(psi) in chain(t)). The problem is that using TargetedFMCS changes the chain globally.

**Alternative: Direct argument from the FMCS structure**:

The TargetedFMCS already has:
- `targeted_forward_chain_resolves_scheduled`: if F(schedule(n)) in chain(n), then schedule(n) in chain(n+1)
- Round-robin scheduling over targets

For forward_F of psi where psi is the k-th target: psi is scheduled at steps k, k + |targets|, k + 2*|targets|, .... At each scheduled step n_i:
- If F(psi) in chain(n_i), then psi in chain(n_i + 1) -- DONE.
- If F(psi) NOT in chain(n_i), then G(neg(psi)) in chain(n_i) (by negation completeness and F = neg G neg). By forward_G, neg(psi) in chain(m) for all m >= n_i. In particular, psi NOT in chain(m) for any m >= n_i.

But wait -- we also have F(psi) in chain(t) with t <= n_i. Does F(psi) persist from t to n_i? This is the key question.

**F-persistence via negation completeness**: At each intermediate step s between t and n_i, either F(psi) in chain(s) or G(neg(psi)) in chain(s). If G(neg(psi)) enters chain(s) for some s in [t, n_i], then by forward_G, neg(psi) in chain(s') for all s' >= s >= t. But F(psi) in chain(t), and by the T-axiom F(psi) -> psi (NO! F is not reflexive in TM! Actually, in TM with reflexive semantics, F(psi) = neg(G(neg(psi))). G(neg(psi)) -> neg(psi) by temp_t. So neg(G(neg(psi))) does NOT imply psi. F(psi) means "psi at some future time >= now", which includes now. So F(psi) -> psi? No: F(psi) = neg(G(neg(psi))). G(neg(psi)) = neg(psi) at all t' >= t. neg(G(neg(psi))) = not(neg(psi) at all t' >= t) = psi at some t' >= t. This includes t' = t. So F(psi) is consistent with both psi and neg(psi) at the current time.

Hmm. So we cannot derive psi from F(psi) directly. But if G(neg(psi)) enters at step s > t while F(psi) was at step t, is this consistent? At step t: F(psi) in chain(t), meaning psi at some time >= t. At step s: G(neg(psi)) in chain(s), meaning neg(psi) at all times >= s. If s > t, the psi-witness could be at some time in [t, s-1]. But in the TargetedFMCS, chain(s) is the "world at time s". If the TargetedFMCS is supposed to model time, then "psi at some time >= t" means psi in chain(s') for some s' >= t. And "neg(psi) at all times >= s" means neg(psi) in chain(s') for all s' >= s. So psi must be in chain(s') for some s' in [t, s-1].

But we're TRYING to prove that such an s' exists! This is circular.

**The circularity**: To prove forward_F (F(psi) in chain(t) implies psi in chain(s) for some s >= t), we need F(psi) to persist until its scheduled resolution step. To prove F-persistence, we need to rule out G(neg(psi)) entering the chain between t and the resolution step. To rule out G(neg(psi)), we need to argue about what the Lindenbaum extension can or cannot include. But the Lindenbaum extension is unconstrained beyond the seed.

### 8. Language Enrichment: Until/Since as F-Decomposition (Confidence: MEDIUM)

The user notes: "If need be, further expressive resources can be included in the language in order to establish completeness."

**Until operator**: phi U psi = "phi holds until psi holds". F(psi) = true U psi. With Until, the completeness proof for LTL uses automata-theoretic methods (Vardi-Wolper) or the Fischer-Ladner closure. The key advantage: Until provides a WITNESSING MECHANISM that decomposes F(psi) into immediate resolution (psi now) or one-step deferral with a promise (phi now AND phi U psi next step). This is the "unfolding" property: phi U psi <-> psi \/ (phi /\ X(phi U psi)) where X is "next step".

For TM over Z (no next-step operator), Until would be: phi U psi <-> psi \/ (phi /\ G(phi U psi) would be wrong...). Actually, over dense or non-discrete time, Until has the semantics: phi U psi iff there exists s >= t with psi at s, and phi at all s' in [t,s). Over Z with reflexive G/H, the right decomposition would use the linearity of the order.

**Would Until resolve the blocker?** The completeness proof for Since/Until logic (Burgess 1982, Xu 1988) over linear orders IS known to be complete. The proof uses the constructive step-by-step method, which builds MCS incrementally. The key insight: with Until/Since, the Fischer-Ladner closure provides a finite set of formulas that is "locally testable" -- each successor needs to satisfy constraints determinable from the current state. This finiteness makes the perpetual deferral impossible because the Until operator FORCES either immediate resolution or structured deferral.

**Cost**: Adding Until/Since to TM would require:
- Extending the formula type with Until/Since constructors
- Adding axioms (e.g., phi U psi <-> psi \/ (phi /\ F(phi U psi)))
- Rewriting the proof system and soundness
- The completeness proof would follow standard methods

This is a substantial refactoring but would provide a mathematically clean solution.

**Fixed-point operators (mu-calculus)**: F(psi) = mu X. (psi \/ F(X)), expressing F as a least fixed point. The modal mu-calculus has well-established completeness results (Kozen-Walukiewicz). Adding fixed-point operators would make completeness provable via parity games or automata. However, this is an even heavier extension than Until/Since and is likely overkill.

**Nominals (hybrid logic)**: Adding named states would allow directly referencing the F-witness point, but this changes the logic fundamentally and is probably not worth the cost.

**Recommendation**: If language enrichment is chosen, Until/Since is the natural choice. It resolves the F-witness problem structurally and has well-understood completeness proofs in the literature.

### 9. A Concrete Proposal: The Maximal-G Successor Selection (Confidence: MEDIUM)

Based on the de Jongh/Veltman/Verbrugge "completeness by construction" method and the diagnostic analysis above, here is a concrete modified construction:

**Idea**: Instead of arbitrary Lindenbaum extension, choose successors that are "maximal" in the G-formulas they contain and "minimal" in the G-formulas they negate. Specifically:

Given MCS M at step n, define the successor seed as `g_content(M)` (as usual). Then among ALL MCS extending this seed, choose one that:
1. Contains target psi_n (if F(psi_n) in M -- the round-robin target)
2. Subject to (1), contains as FEW G(neg(chi)) formulas as possible (where chi ranges over deferralClosure)

This "minimal blocker" selection prevents gratuitous F-obligation killing. The Lindenbaum extension would only include G(neg(chi)) if it's FORCED by the seed and target.

**Formalization challenge**: This requires showing that such a "minimal" MCS exists. This is a non-constructive selection from the set of all valid extensions, which in Lean would use Classical.choose on a filtered set. The key technical lemma: among all MCS W with {target} union g_content(M) subset W, there exists one that minimizes |{chi in DC | G(neg(chi)) in W}|. This follows from DC being finite and the set of qualifying MCS being nonempty.

**Does this prevent perpetual deferral?** Not obviously. Even a minimal-blocker successor CAN include G(neg(chi)) if it's forced by consistency with the target and g_content. The question is whether such forced blocking is transient.

### 10. The Most Viable Path: Bypass succ_chain_fam, Wire TargetedFMCS Directly (Confidence: HIGH)

Rather than proving the sorries about `succ_chain_fam`, the most viable approach is to:

1. **Replace `succ_chain_fam`** in the completeness proof with `TargetedFMCS` (from TargetedChain.lean), parameterized by targets = `deferralClosure(root).toList`.

2. **Prove forward_F for TargetedFMCS** directly. The TargetedFMCS already has:
   - Sorry-free forward_G and backward_H
   - One-step resolution: F(psi) in chain(n) with psi scheduled at n implies psi in chain(n+1)
   - G-persistence at each step

3. **The missing proof**: F(psi) in chain(t) implies F(psi) persists until some scheduled step. Equivalently: G(neg(psi)) does not enter the chain between t and the next scheduled step for psi.

4. **Approach to the missing proof**: Use a CONTRADICTION argument. Suppose F(psi) in chain(t) but psi NOT in chain(s) for any s >= t. Then for all scheduled steps n_i >= t where psi is scheduled:
   - F(psi) NOT in chain(n_i) (otherwise psi in chain(n_i+1))
   - So G(neg(psi)) in chain(n_i)
   - By forward_G: neg(psi) in chain(m) for all m >= n_i

   Let n_0 be the first scheduled step >= t. Then G(neg(psi)) in chain(n_0). By forward_G, neg(psi) in chain(m) for all m >= n_0. Also, G(neg(psi)) in chain(n_0) implies G(G(neg(psi))) in chain(n_0) by temp_4, so G(neg(psi)) in chain(m) for all m >= n_0 (propagated by g_step). So F(psi) NOT in chain(m) for any m >= n_0.

   But F(psi) in chain(t) with t <= n_0. What about chain(t+1), ..., chain(n_0-1)?

   At step t: F(psi) in chain(t). Step t+1 is a targeted step for schedule(t). The successor has g_content(chain(t)) subset chain(t+1). If G(neg(psi)) in chain(t+1), then neg(psi) in g_content(chain(t+1)). Is G(neg(psi)) in g_content(chain(t))? That would require G(G(neg(psi))) in chain(t), hence G(neg(psi)) in chain(t), hence F(psi) NOT in chain(t) -- contradiction with hypothesis.

   So G(neg(psi)) NOT in g_content(chain(t)). But chain(t+1) is a Lindenbaum extension of `{schedule(t)} union g_content(chain(t))`. Even though G(neg(psi)) is not in the seed, the extension CAN include it.

**This is the fundamental blocker, restated yet again.**

## Recommended Approach

Given the comprehensive analysis across 5 rounds of research, I recommend a **two-track strategy**:

### Track A: Replace succ_chain_fam with TargetedFMCS (Surgical Fix)

1. Wire `TargetedFMCS` (parameterized by deferralClosure(root).toList) into the completeness proof instead of `succ_chain_fam`.
2. The forward_G and backward_H are already sorry-free.
3. For forward_F: attempt the enriched-seed approach where the Lindenbaum seed at each step includes `{F(chi) | F(chi) in chain(n), chi in DC}` alongside the target and g_content. The consistency argument needs careful work but is the most promising angle.
4. If the enriched seed consistency can be proven (resolving the G-wrapping-with-F-formulas issue), this gives a complete sorry-free proof.

### Track B: Language Enrichment with Until/Since (Clean Solution)

If Track A remains blocked after implementation attempts:
1. Add Until (U) and Since (S) operators to the Formula type.
2. Define F(phi) := top U phi and P(phi) := top S phi.
3. Add appropriate axioms for Until/Since.
4. The completeness proof follows the established Burgess/Xu methodology.
5. This is a larger refactoring but has well-understood mathematics behind it.

### Track C: Weaken the Sorry to an Axiom (Pragmatic)

If both Track A and Track B are too costly:
1. Add `succ_chain_restricted_forward_F` as an axiom (explicitly marking it as an assumption).
2. Document this as a known limitation corresponding to a standard result in temporal logic.
3. The rest of the completeness proof remains sorry-free.
4. This is mathematically honest -- the property IS true, the formalization gap is in the chain construction technique.

## Evidence/Examples

### The G-wrapping argument (why it works for single target, fails for multiple)

**Single target**: `{psi} union g_content(M)` is consistent. Proof: if L |- bot with L subset seed, then g_content(M) |- neg(psi). By G-wrapping each phi in g_content(M) to G(phi) in M, and applying temporal K: G(neg(psi)) in M. But F(psi) = neg(G(neg(psi))) in M. Contradiction.

**Multiple targets**: `{psi, chi} union g_content(M)` -- if L |- bot, we might have L = {psi, phi_1, chi} where phi_1 in g_content. Then {phi_1, chi} |- neg(psi). We can G-wrap phi_1 but NOT chi (chi is not in g_content). So we cannot derive G(neg(psi)) from M.

### The enriched seed alternative

Seed = `{target} union g_content(M) union {F(chi) | F(chi) in M, chi in DC}`. All non-target elements are in M. If L |- bot with target in L: L' = L \ {target} subset M, so L' |- neg(target), so neg(target) in M. This is consistent with F(target) in M. **The derivation of bot from L does not give us a contradiction with M's consistency because neg(target) in M is allowed.**

The enriched seed approach would work IF we could show that `g_content(M) union {F(chi_i)} NOT |- neg(target)` when the F(chi_i) are individually compatible. This requires showing that adding F-formulas (which are in M) to g_content(M) (also in M) cannot create new derivability that contradicts F(target) in M. Since all these formulas are in M together with F(target), and M is consistent, the conjunction `phi_1 /\ ... /\ F(chi_1) /\ ... /\ neg(target)` is in M. Wait -- neg(target) might also be in M. So `g_content(M) union {F(chi_i)} union {neg(target)} subset M` is consistent. But `g_content(M) union {F(chi_i)} union {target}` -- is this consistent? It contains target which might NOT be in M.

This IS the question, and G-wrapping cannot answer it for the F-formulas.

## Confidence Levels Summary

| Finding | Confidence |
|---------|------------|
| G/F asymmetry = universal/existential witness problem | HIGH |
| Standard Kt completeness uses tree-then-unravel, not direct chain | HIGH |
| Linearity axiom constrains but does not solve F-persistence | HIGH |
| Two-phase construction (canonical frame + path extraction) is correct | HIGH |
| Simultaneous F-resolution blocked by G-wrapping limitation | HIGH |
| Controlled Lindenbaum with F-formulas in seed -- blocked | MEDIUM-HIGH |
| TargetedFMCS + inductive argument -- most viable implementation | MEDIUM-HIGH |
| Until/Since enrichment would resolve the blocker | MEDIUM |
| Maximal-G successor selection -- uncertain | MEDIUM |
| Direct proof of succ_chain_fam forward_F -- impossible | HIGH |
