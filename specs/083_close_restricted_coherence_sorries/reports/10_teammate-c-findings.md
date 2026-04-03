# Teammate C (Critic) Findings: Root Cause Re-Analysis Under Fully Strict + Since/Until

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-03
**Role**: CRITIC -- challenge the previous round's conclusion that Boneyard failures are independent of semantics choice, now that Since/Until and fully strict semantics are on the table

---

## Preamble: What I Am Challenging

The previous critic (report 09, Teammate C) argued:

> "None of the Boneyard failures were CAUSED by reflexive semantics. They were caused by deeper issues in canonical model construction. Switching to strict semantics would NOT fix any of these problems, and would ADD new ones."

That conclusion was drawn **before** Since/Until were in the picture as first-class operators, and **before** the recognition that `X phi = bot U phi` under fully strict semantics gives a definable next-step operator. My job is to determine whether this new information shifts the root cause analysis.

---

## Boneyard Failure Re-Analysis

### Methodology

For each Boneyard failure, I answer four questions:
- (a) What was the specific root cause?
- (b) Does Since/Until (especially definable X = bot U phi, Y = bot S phi) change the root cause?
- (c) Does strict semantics (no T-axiom, irreflexive canonical frame) change the root cause?
- (d) Does the COMBINATION resolve, worsen, or leave unchanged the root cause?

### Failure 1: CoherentZChain

**What failed**: "Forward chain preserves G but not H; backward preserves H but not G." The attempt to build a Z-indexed chain from an MCS M0 by extending forward and backward simultaneously hit a fundamental impossibility: forward extension via `temporal_theory_witness_exists` preserves G-content (g_content(M) subset M') but not H-content, and backward extension preserves H-content but not G-content. Cross-direction coherence required circular reasoning.

**(a) Root cause**: The one-step MCS extension lemma (`temporal_theory_witness_exists`) only propagates content in one temporal direction. There is no general principle "if G(phi) in M, then G(phi) in succ(M)" -- actually this IS provable from temp_4 (G -> GG). The real issue is **cross-direction**: having H(phi) persist through forward steps, or G(phi) persist through backward steps. Forward steps add g_content but can kill H-content; backward steps add h_content but can kill G-content.

**(b) Since/Until impact**: Having X = bot U phi does NOT help with cross-direction coherence. The problem is about preserving G-obligations through backward steps and H-obligations through forward steps. X gives you a one-step operator, but the issue is that Lindenbaum extension in the "wrong" direction can introduce inconsistencies with the "right" direction's obligations. **No change.**

**(c) Strict semantics impact**: Under strict semantics, G(phi) in M does NOT imply phi in M (no T-axiom). This actually makes the problem SLIGHTLY DIFFERENT but not easier. In the reflexive case, G(phi) in M implies phi in M, which means the base MCS already satisfies the G-content. Under strict, it doesn't. This means forward steps need to carry more obligations (phi itself, not just G(phi)). However, the core cross-direction problem remains. **No change or slightly worse.**

**(d) Combination**: **UNCHANGED.** The CoherentZChain failure stems from the fundamental tension between forward and backward Lindenbaum extension, not from the semantics of G/H or the availability of X.

### Failure 2: F-Preserving Seed (Proved FALSE by Task 69)

**What failed**: The attempt to include unresolved F-obligations in the Lindenbaum seed to prevent their negation from being added during extension. Task 69 produced a counterexample showing that `box_F_seed_chain` produces non-F-preserving chains.

**(a) Root cause**: The key insight from the FPreservingSeed.lean documentation (lines 26-38) is illuminating. The approach assumed that adding F(psi) to the seed would prevent G(neg psi) from being added by Lindenbaum. This is true IF F(psi) and G(neg psi) are jointly inconsistent with the seed, which they are (since F(psi) = neg G(neg psi)). BUT the problem is that the seed also includes G_theory and box_theory, and the interaction between these theories and the F-obligations can force Lindenbaum to include formulas that are incompatible with F-preservation through the CHAIN (not just at a single step). Task 69's counterexample showed this happens in practice.

**(b) Since/Until impact**: The F-preserving seed problem is about the non-constructive nature of Lindenbaum extension, not about the expressiveness of the formula language. Having Since/Until as first-class operators does NOT change the fact that Lindenbaum can add formulas that kill F-obligations in multi-step chains. **No change.**

However, there is a subtle point: if X is definable, then F(phi) becomes `top U phi`, and the witness obligation is "phi at SOME strictly future time." Under strict semantics, one might hope to use X-step-at-a-time witness construction instead of F-preservation through the entire chain. But this is precisely what the dovetailed chain already does (fair scheduling of F-obligations). The F-preserving seed was trying to avoid dovetailing. **Still no change to the root cause, but the WORKAROUND (dovetailed chain) is already in place.**

**(c) Strict semantics impact**: The FPreservingSeed.lean code (line 69) uses `Axiom.temp_t_future` in `G_disjunction_in_mcs_elim`, meaning the proof depends on the T-axiom. Under strict semantics, this specific proof would break. But the approach is already proved FALSE, so breaking it further is irrelevant. **No change (already dead).**

**(d) Combination**: **UNCHANGED.** The failure is about Lindenbaum extension properties, orthogonal to semantics choice.

### Failure 3: Bidirectional Seed

**What failed**: "H(a) -> G(H(a)) is NOT derivable in TM." The approach tried to propagate temporal consistency bidirectionally using this principle.

**(a) Root cause**: The formula H(a) -> G(H(a)) asserts that if a held at all past times, then at all future times, a held at all past times. This IS semantically valid on linear orders (if phi held at all s < t, then for any s' > t, phi held at all s'' < s' that are also < t; and for s'' in [t, s'), we'd need additional info). Actually, let me reconsider. Under reflexive semantics: H(a) at t means a at all s <= t. G(H(a)) at t means for all s >= t, H(a)(s), i.e., for all s >= t, a at all u <= s. This requires a at ALL times u <= s for every s >= t, which means a at all times. This is NOT implied by just H(a) at t (which only gives a at times <= t). So the formula is genuinely invalid.

Under STRICT semantics: H(a) at t means a at all s < t. G(H(a)) at t means for all s > t, H(a)(s), i.e., for all s > t, a at all u < s. For u < t, we have a(u) from H(a) at t. For u = t, we need a(t), which is NOT given by H(a) under strict semantics. For u in (t, s), we need a(u), which is not given.

**(b) Since/Until impact**: **No change.** The non-derivability of H(a) -> G(H(a)) is a fundamental property of TM logic (the formula requires a at times the antecedent says nothing about). Having X or Until doesn't change this.

**(c) Strict semantics impact**: Makes the formula even MORE obviously invalid, since H(a) under strict semantics doesn't even give a at the current time. **Slightly worse, but irrelevant since the failure was already terminal.**

**(d) Combination**: **UNCHANGED.** The bidirectional seed failure is logic-theoretic, independent of semantics.

### Failure 4: Bundle-Level Temporal Coherence

**What failed**: G/H operators quantify over times within the SAME world history, but bundle-level coherence allows witnesses in DIFFERENT histories. The truth lemma for G(phi) at (fam, t) requires phi at (fam, s) for all s > t within the SAME family, but bundle coherence only guarantees phi at (fam', s) for some possibly different fam'.

**(a) Root cause**: The distinction between single-history and multi-history quantification. TM semantics: G(phi) at tau, t = phi at tau, s for all s >= t (SAME history). Bundle coherence: for all s >= t, EXISTS sigma in bundle with phi at sigma, s. These differ when phi involves atoms whose truth depends on the specific history.

**(b) Since/Until impact**: Since/Until have the SAME single-history requirement as G/H. `phi U psi` at tau, t requires psi at tau, s for some s (same tau). So adding Since/Until does not change the bundle-level coherence problem at all. **No change.**

**(c) Strict semantics impact**: Whether G uses t < s or t <= s, the single-vs-multi-history distinction remains the same. **No change.**

**(d) Combination**: **UNCHANGED.** This is a structural semantic issue about the meaning of world histories, completely orthogonal to strict/reflexive and to Since/Until.

### Failure 5: Omega F-Persistence

**What failed**: "Lindenbaum extension can add G(neg psi) when F(psi) was present." After constructing an omega chain, F-obligations can be killed at later steps because the non-constructive Lindenbaum extension at step n+1 may add G(neg psi), which contradicts F(psi) at step n (since G(neg psi) propagates backward through the chain via the g_content relation).

**(a) Root cause**: The non-constructive nature of Lindenbaum's lemma. When extending M_n to M_{n+1}, Lindenbaum freely adds formulas consistent with the seed. If G(neg psi) is consistent with the seed, it gets added, even though F(psi) was in M_n.

**(b) Since/Until impact**: This is where I need to think carefully. Under fully strict semantics with X = bot U phi:

The dovetailed chain ALREADY solves this problem by fair-scheduling F-obligations. At step n targeting F(psi), the witness phi is explicitly included in the seed, forcing psi into M_{n+1}. Once psi is in M_{n+1}, G(neg psi) cannot be in M_{n+1} (consistency). And from psi in M_{n+1}, we get P(psi) in M_n (by h_content duality), which gives the existential witness.

Does X simplify this? The dovetailed chain resolves F(psi) by finding a witness at SOME future step. With X, you could instead try to resolve each F-obligation at the NEXT step (since F(psi) implies X(psi) or X(F(psi)) in discrete orders). But this doesn't fundamentally change the construction -- you still need to interleave obligations.

**Marginal improvement at best.** The dovetailed chain already handles this correctly. X might slightly simplify the scheduling argument (resolve at next step instead of arbitrary future step), but the core technique remains the same.

**(c) Strict semantics impact**: The lack of T-axiom means G(neg psi) in M_n does NOT imply neg psi in M_n, so there is slightly more room for F(psi) and G(neg psi) to coexist... wait, no. F(psi) = neg G(neg psi) under both reflexive and strict semantics (it's a definition). So F(psi) and G(neg psi) are ALWAYS contradictory in an MCS. **No change.**

**(d) Combination**: **UNCHANGED.** The dovetailed chain is the correct solution, and it works under both semantics.

### Failure 6: True Dovetailed Vanishing ("F(phi) vanishes case unfixable")

**What failed**: In an earlier version of the dovetailed chain, the "true" dovetailing attempted to resolve ALL F-obligations simultaneously by interleaving them into a single forward chain. The issue was that F(phi) could "vanish" -- at step n, F(phi) is in M_n, but after the dovetailed extension to M_{n+1}, M_{n+2}, ..., the obligation is never satisfied because the targeted formula changes at each step and the obligation is never revisited.

**(a) Root cause**: Unfair scheduling. The "true" dovetailed chain didn't guarantee that every (position, formula) pair would eventually be targeted.

**(b) Since/Until impact**: X = bot U phi on discrete orders means F(phi) -> phi or X(F(phi)), i.e., either the obligation is satisfied now or it persists to the next step. This gives a DISCRETE unfold of F:

`F(phi) <-> phi or X(F(phi))`

This means F-obligations have a clean step-by-step persistence property. However, the vanishing problem was about SCHEDULING, not about the logical behavior of F. Fair scheduling (via Nat.unpair) solves it regardless of whether X is available. **No change to root cause, but X gives a cleaner THEORETICAL framework for understanding why the fixed dovetailed chain works.**

**(c) Strict semantics impact**: Under strict semantics, F(phi) at t means phi at some s > t (strictly future). The vanishing issue is scheduling-related, not semantics-related. **No change.**

**(d) Combination**: **UNCHANGED in practice.** The current dovetailed chain with fair scheduling already works.

### Summary Table

| Failure | Root Cause | S/U Impact | Strict Impact | Combined | Verdict |
|---------|-----------|------------|---------------|----------|---------|
| CoherentZChain | Cross-direction Lindenbaum kills | None | None/Worse | **UNCHANGED** | Not fixed |
| F-Preserving Seed | Multi-step Lindenbaum non-constructive | None | N/A (dead) | **UNCHANGED** | Not fixed |
| Bidirectional Seed | H(a)->G(H(a)) not derivable | None | Worse | **UNCHANGED** | Not fixed |
| Bundle Coherence | Single-history vs multi-history | None | None | **UNCHANGED** | Not fixed |
| Omega F-Persistence | Lindenbaum adds negations | Marginal | None | **UNCHANGED** | Solved by dovetailed chain |
| True Dovetailed | Unfair scheduling | Cleaner theory | None | **UNCHANGED** | Solved by fair scheduling |

**The previous critic was RIGHT.** None of the six Boneyard failures shift under strict + Since/Until. The root causes are all in canonical model construction techniques (Lindenbaum properties, cross-direction coherence, single-history semantics) that are orthogonal to the strict/reflexive choice and to the availability of X/Y operators.

**Confidence**: HIGH

---

## X/Y Impact on Completeness Strategy

This is the core question: does X = bot U phi fundamentally simplify the canonical model construction? Here I must be more careful than the previous critic.

### The Backward Truth Lemma Problem

The plan v7 Phase 4 analysis (plans/08_half-open-semantics.md, lines 124-268) contains an extraordinary 15-page stream-of-consciousness attempt to prove the backward direction of the Until truth lemma. The conclusion: **the proof is blocked because `until_intro` uses G (all future) instead of X (next step)**. The key passage:

> "THE REAL STANDARD APPROACH: In Burgess-Xu for discrete, the SEMANTICS of Until already uses the half-open interval, and the COMPLETENESS proof for the backward direction uses the U-Induction axiom, not step-by-step backward induction."

And later:

> "The fix is: in a discrete setting, F(X) = X or X(next)... And until_intro with G = reflexive-all-future gives phi ^ G(phi U psi) -> phi U psi, where G(phi U psi) means phi U psi at t AND phi U psi at t+1 AND .... This is impossibly strong for backward induction."

### Does X Actually Help?

Under fully strict semantics with definable X:

**The discrete unfold axiom** `phi U psi <-> psi or (phi ^ X(phi U psi))` reduces to: either psi holds now, or phi holds now and phi-until-psi holds at the NEXT step.

For the backward truth lemma, this means: given semantic witnesses (psi at s, phi at all r in guard), to prove `phi U psi in mcs(t)`:
- Base case (s = t under half-open, or s = t+1 under fully strict): direct.
- Inductive case: have `phi U psi in mcs(t+1)` by strong IH (smaller witness distance). Have `phi in mcs(t)` from semantic guard. Need `X(phi U psi) in mcs(t)`. Under strict semantics, X(phi U psi) = bot U (phi U psi), and `X(chi) in mcs(t)` iff `chi in mcs(t+1)` (by the canonical frame's one-step relation).

**WAIT.** This is the crux. Does X(chi) in mcs(t) imply chi in mcs(t+1) in the canonical model? For this to work, you need:
1. `X(chi) in mcs(t)` (syntactic: the formula X(chi) is a member of the MCS at position t)
2. This implies `chi in mcs(t+1)` where mcs(t+1) is the next MCS in the chain.

This is the **X-step truth lemma**: X(chi) is true at (fam, t) iff chi is true at (fam, t+1). Under fully strict semantics:
- Forward: X(chi) in mcs(t) means (bot U chi) in mcs(t). Semantically, this means chi at t+1 (on discrete Z). By the truth lemma for bot U chi: chi true at t+1. By IH on chi (a subformula): chi in mcs(t+1). THIS WORKS if chi is a subformula and the truth lemma is proved by induction on formula structure. But phi U psi is NOT a subformula of X(phi U psi) = bot U (phi U psi). Actually, phi U psi IS a subformula of bot U (phi U psi) -- it's the second argument.

Hmm, but the truth lemma induction is on the FORMULA we're proving the truth lemma for. When we're trying to prove the truth lemma for `phi U psi`, we can use IH for phi and psi (subformulas of phi U psi). But `bot U (phi U psi)` is a BIGGER formula than `phi U psi`. So we CANNOT use the truth lemma for `X(phi U psi)` as an IH when proving the truth lemma for `phi U psi`.

**This is a fundamental problem that X does NOT solve.** The discrete unfold axiom `phi U psi <-> psi or (phi ^ X(phi U psi))` contains `X(phi U psi)` which is STRUCTURALLY LARGER than `phi U psi`. You cannot use the truth lemma for `X(phi U psi)` when proving the truth lemma for `phi U psi` by structural induction.

### How the Standard Literature Handles This

The standard approach (Goldblatt, Blackburn et al.) does NOT prove the truth lemma for Until by reducing it to X. Instead, they use one of:

1. **Filtration + finite model property**: Avoid the truth lemma entirely for Until by using a filtered model where temporal coherence is built in by construction.

2. **Step-by-step canonical construction**: Build the canonical model as a Z-indexed chain where each step satisfies the Succ relation, and prove the truth lemma for X FIRST (as a base case), then derive the Until truth lemma using the U-Induction axiom.

3. **Direct proof via U-Induction**: Use the U-Induction axiom with a carefully chosen chi to derive the backward Until truth lemma without going through X.

Approach (2) is what Teammate B in report 09 envisioned. BUT it requires that the truth lemma for X(chi) is provable INDEPENDENTLY of the truth lemma for chi U psi when chi U psi appears inside X. This works if the truth lemma is proved not by structural induction on formulas, but by induction on the DEPTH of the temporal nesting -- or by a different induction scheme.

In the standard Henkin-style completeness proof for discrete temporal logic:
- The canonical model is Z-indexed.
- The truth lemma is proved for ALL formulas simultaneously (not by structural induction).
- The key property is: chi in MCS_n iff chi true at world n.
- For Until: phi U psi in MCS_n iff exists k > n with psi in MCS_k and phi in MCS_j for all n < j < k.
- The backward direction uses: assume the semantic witness exists. By the chain construction, psi in MCS_k (from the truth lemma for psi, by IH on subformulas). Then by backward induction from k to n, using the discrete unfold, build phi U psi in each MCS.

The backward induction step is: at position j (with n <= j < k), we have:
- phi in MCS_j (from guard + truth lemma for phi)
- phi U psi in MCS_{j+1} (from previous induction step)
- Need: phi U psi in MCS_j

Using `until_intro`: need `psi in MCS_j` or `phi in MCS_j ^ G(phi U psi) in MCS_j`. The G version is too strong. Using the X-based version: need `psi in MCS_j` or `phi in MCS_j ^ X(phi U psi) in MCS_j`. We have phi in MCS_j. We need X(phi U psi) in MCS_j, which by the X truth lemma means phi U psi in MCS_{j+1}. And we HAVE phi U psi in MCS_{j+1} by induction hypothesis.

**THE KEY STEP**: The X truth lemma: `X(chi) in MCS_j iff chi in MCS_{j+1}`. This is provable from the Succ relation (g_content(MCS_j) subset MCS_{j+1}) **plus the converse** (some form of "backward step" property). Specifically:
- Forward: X(chi) in MCS_j means (by Succ) chi in MCS_{j+1}. Actually, X(chi) = bot U chi. G-content includes formulas phi where G(phi) in M. So G(bot U chi) in MCS_j would give bot U chi in MCS_{j+1}. But we need bot U chi in MCS_j to give chi in MCS_{j+1}. The Succ relation says g_content(MCS_j) subset MCS_{j+1}, where g_content(M) = {phi : G(phi) in M}. So G(chi) in MCS_j implies chi in MCS_{j+1}. But X(chi) = bot U chi, and G(bot U chi) is NOT the same as bot U chi.

**STOP.** This is the exact same problem. The Succ relation propagates G-content: if G(alpha) in MCS_j then alpha in MCS_{j+1}. The X truth lemma would need: if X(chi) in MCS_j then chi in MCS_{j+1}. But X(chi) = bot U chi, and there is no axiom that gives G(chi) from X(chi). In fact, X(chi) is WEAKER than G(chi) (X only asserts chi at the next step, G asserts it at all future steps).

So **getting chi in MCS_{j+1} from X(chi) in MCS_j is NOT directly available through the g_content Succ relation**. You would need a different Succ relation that propagates X-content, or you need an axiom linking X to the chain construction.

### The Real Resolution

The standard literature resolves this by constructing the canonical model DIFFERENTLY from how this codebase does it. In the standard approach for discrete temporal logic:

1. The canonical model has worlds = MCS's of the logic.
2. The accessibility relation is defined as: MCS_1 R MCS_2 iff for all phi, if G(phi) in MCS_1 then phi in MCS_2 AND if P(phi) in MCS_2 then phi in MCS_1. (This is the standard temporal canonical relation.)
3. On DISCRETE linear orders, this relation has the property that R is the successor relation: MCS_1 R MCS_2 iff for all chi, X(chi) in MCS_1 iff chi in MCS_2.

The equivalence (3) is PROVABLE from the Burgess-Xu axioms on discrete linear orders. Specifically, from the discreteness axioms (`F top -> bot U top`, etc.), you can show that the canonical relation is a successor relation, meaning X(chi) in MCS implies chi in the unique R-successor.

**This is the key insight**: under fully strict semantics with discrete axioms, the canonical accessibility relation can be shown to be a DISCRETE SUCCESSOR relation, and the X truth lemma follows from this. Under reflexive semantics without X, you only have the G-content relation, which is weaker.

### Verdict on X/Y Impact

X/Y fundamentally changes the completeness strategy, but **NOT by simplifying the existing approach**. Instead, it enables a DIFFERENT canonical model construction:

1. **Current approach** (reflexive, no X): Succ chain with g_content/h_content. Backward truth lemma for Until requires G(phi U psi), which is impossibly strong.

2. **Strict + X approach**: Canonical frame as discrete successor relation. X truth lemma follows from the frame being a successor. Until backward truth lemma reduces to step-by-step backward induction using X.

The transition from (1) to (2) is NOT incremental. It requires rebuilding the canonical frame construction from scratch. The dovetailed chain (which builds the Z-indexed family) would be replaced by a direct canonical construction where the frame IS the set of all MCS's with the canonical successor relation.

**The irony**: the dovetailed chain was invented to solve the F-witness problem (ensuring every F-obligation is eventually satisfied). Under the standard canonical model construction for discrete temporal logic, F-witnesses are handled by a simpler argument: if F(phi) in MCS_n, then by seriality and discreteness, X^k(phi) is derivable for some k, which means phi appears in MCS_{n+k}. This is essentially what the dovetailed chain does, but packaged differently.

**Confidence**: HIGH for the analysis, MEDIUM for the claim that the standard canonical construction works cleanly in the bimodal S5+temporal setting (the S5 modal interaction complicates things).

---

## The Real Hardest Problem

Having analyzed all the failures and the potential of X/Y, here is my assessment of the genuine mathematical difficulties in a fully strict + Since/Until refactor:

### Problem 1: The Canonical Frame Successor Property (HARDEST)

Under strict semantics with discrete axioms, the canonical frame must be a DISCRETE SUCCESSOR frame. This means: for every MCS M, there exists a unique MCS M' (the "successor") such that X(chi) in M iff chi in M'. Proving existence and uniqueness of the successor is non-trivial.

**Existence** is relatively straightforward: from seriality (F top) and discreteness (F top -> bot U top), you get X(top) in every MCS, which gives a successor MCS via Lindenbaum.

**Uniqueness** is harder. Two MCS's M' and M'' that both satisfy "for all chi, if X(chi) in M then chi in M'/M''" could still differ on formulas that are NOT of the form X(chi). In a SERIAL DISCRETE LINEAR ORDER, uniqueness follows from the fact that X(chi) and X(neg chi) are complementary in M (exactly one is in M), so the successor is fully determined. This is provable from the Burgess-Xu axioms.

**The S5 modal interaction**: In the bimodal setting, the canonical model must also satisfy S5 properties for Box. The canonical successor MCS M' must agree with M on Box-content (Box(phi) in M iff Box(phi) in M' -- this follows from the modal-temporal interaction axioms). This is already handled by the current codebase's box_class_agree property, so it should transfer.

**Difficulty level**: MEDIUM-HIGH. The arguments are well-understood in the literature but require careful formalization, especially in the bimodal setting.

### Problem 2: The Irreflexivity of the Canonical Frame (HISTORICALLY HARD)

Under strict semantics, the canonical temporal relation must be IRREFLEXIVE (no MCS is its own successor). The codebase documents (Truth.lean:16-18, typst/chapters/06-notes.typ:187) that this was the original reason for abandoning strict semantics: "irreflexivity is not modally definable."

However, in the canonical model for DISCRETE temporal logic, irreflexivity follows from the successor property. If X(phi) in M iff phi in succ(M), and M = succ(M), then X(phi) iff phi for all phi in M. But X(phi) = bot U phi, and the unfold of bot U phi gives phi or (bot and X(bot U phi)), which simplifies to phi. So X(phi) <-> phi is a theorem of the logic... wait, is it? Under strict semantics: X(phi) at t means phi at t+1. X(phi) <-> phi means phi(t+1) <-> phi(t) for all t, which is NOT a theorem. So M = succ(M) would require phi in M iff phi in M, which is trivially true -- and NOT contradictory.

**This is a real problem.** On a single MCS (which represents a single time-point), the successor could in principle loop back to itself. You need the temporal order to be a LINEAR ORDER with no fixed points, which requires proving that the canonical relation generates a linear order isomorphic to Z (or at least a discrete linear order without endpoints).

**Difficulty level**: HIGH. This is the core technical challenge that the project historically couldn't solve.

### Problem 3: The Truth Lemma for G/H Under Strict Semantics

Under reflexive semantics, the truth lemma for G has a trivial base case: G(phi) in MCS(t) implies phi in MCS(t) by the T-axiom, so the t=s case is immediate. Under strict semantics, there is no base case to handle s=t; you only need to prove: for all s > t, phi in MCS(s). This follows from the successor chain by induction: G(phi) in MCS(t) implies phi in MCS(t+1) (by X truth lemma? No -- G is not X. G(phi) implies phi at ALL strictly future times, not just the next one).

Actually, the truth lemma for G under strict semantics is: G(phi) in MCS(t) iff for all s > t, phi true at s. The forward direction: G(phi) in MCS(t) -> by G-content propagation through the chain -> phi in MCS(s) for all s > t. This uses the standard argument: G(phi) in MCS(t) -> G(phi) in MCS(t+1) (by temp_4: G -> GG) -> phi in MCS(t+1) (by... what?). Under strict semantics, we need: G(phi) in MCS(t) -> phi in MCS(t+1). This follows from: G(phi) -> X(phi) (which is: all strictly future -> next step, derivable from G + seriality on discrete orders: G(phi) -> F(phi) -> X(phi) using discreteness).

So: G(phi) -> X(phi) is derivable. And X(phi) in MCS(t) -> phi in MCS(t+1) by the successor property. Then by temp_4 (G -> GG) and induction: G(phi) in MCS(t) -> phi in MCS(s) for all s > t.

The backward direction: for all s > t, phi true at s -> for all s > t, phi in MCS(s) (by IH) -> G(phi) in MCS(t). This last step is: if phi in MCS(s) for all s > t, then G(phi) in MCS(t). By contradiction: if neg G(phi) = F(neg phi) in MCS(t), then exists s > t with neg phi in MCS(s), contradicting phi in MCS(s).

**This works.** The truth lemma for G under strict semantics is provable, given the successor property and the restricted forward_F.

**Difficulty level**: MEDIUM. Standard arguments apply.

### Problem 4: Modal-Temporal Interaction Under Strict Semantics

The S5 modal layer uses `Box phi -> phi` (reflexive). The temporal layer uses strict G/H (no T-axiom). The interaction axioms are:
- `Box phi -> Box F phi` (modal_future): necessary truths persist into the future
- `Box phi -> F Box phi` (temporal_future): necessary truths will continue to be necessary

Under strict semantics, F means strictly future. Box phi -> Box F phi: if phi is necessary (all histories), then for all histories, phi holds at some strictly future time. This requires that the model has no endpoints (seriality) AND that Box-content propagates through the successor relation. This is the same as the current axiom, so it should remain valid.

The more subtle question: does the COMPLETENESS PROOF for the modal-temporal interaction work? The current proof uses box_phi_all_times (CanonicalConstruction.lean:411-439), which shows Box phi propagates to all times using forward_G and backward_H with <=. Under strict semantics, this becomes: Box phi propagates to all STRICTLY future and STRICTLY past times. But we need Box phi at the CURRENT time too (which is trivially from the assumption). So: Box phi at t -> Box phi at s for all s != t. Combined with Box phi at t itself: Box phi at all times. This works.

**Difficulty level**: LOW-MEDIUM. The arguments transfer with minor modifications.

### Ranking

1. **Canonical frame successor property + irreflexivity** (Problems 1+2): This is the GENUINE mathematical difficulty. It requires rebuilding the canonical frame from scratch and proving it generates a discrete linear order. **HARDEST.**

2. **Truth lemma for Until backward direction** (the current blocker): Under strict semantics with X, this reduces to step-by-step backward induction, which is MUCH easier than the current G-based approach. **EASIER than current approach.**

3. **Everything else**: Truth lemma for G/H, modal-temporal interaction, soundness proofs -- these are tedious but straightforward. **MEDIUM effort, LOW risk.**

**Confidence**: HIGH for the ranking, MEDIUM for the specific difficulty estimates.

---

## Remaining Assumptions Challenged

### Challenge 1: Is fully strict Until (witness s > t, guard (t,s)) sound for Burgess-Xu axioms?

**Analysis**: The Burgess-Xu axioms were originally stated for REFLEXIVE Since/Until. The `until_intro` axiom `psi or (phi ^ G(phi U psi)) -> phi U psi` assumes that psi can serve as an immediate witness (the s = t case). Under fully strict Until (s > t), there IS no s = t case. So:

- `psi or (phi ^ G(phi U psi)) -> phi U psi` under fully strict Until and strict G: the first disjunct `psi -> phi U psi` is UNSOUND (psi at t does not give a STRICTLY future witness for phi U psi at t).

**This is critical.** The until_intro axiom as currently stated is UNSOUND under fully strict Until. You would need to replace it with:
- `X(psi) or (phi ^ X(phi U psi)) -> phi U psi` (using next-step instead of present)
- Or: `psi or (phi ^ G(phi U psi)) -> phi U psi` but with phi U psi using HALF-OPEN semantics (s >= t, guard [t,s)) -- this is Teammate B's "mixed strict" design.

**Verdict**: Fully strict Until REQUIRES changing the axiom system. The Burgess-Xu axioms as stated are for reflexive Until; adapting them to fully strict requires care. The half-open design (strict G/H + reflexive Until witness) is the safest adaptation.

**Confidence**: HIGH

### Challenge 2: Does F = top U equivalence under strict semantics create issues with modal interaction axioms?

**Analysis**: Under fully strict semantics: F phi = neg G neg phi = neg(forall s > t, neg phi(s)) = exists s > t, phi(s). And top U phi = exists s > t, phi(s) and top at all u in (t,s). Since top is always true, the guard is vacuous. So F phi = top U phi. Clean.

The modal interaction axioms:
- Box phi -> Box F phi: Box phi at t -> for all histories sigma, F phi at t -> exists s > t, phi at s for sigma. This is: for all sigma in Omega, exists s > t, phi at sigma, s. Under the canonical model, this follows from seriality + the Box-persistence property.
- Box phi -> F Box phi: Box phi at t -> exists s > t, Box phi at s. This requires Box-persistence through the chain, which follows from the G-content propagation of box_theory.

**No issues.** The F = top U equivalence is clean under fully strict semantics and doesn't interact problematically with the modal axioms.

**Confidence**: HIGH

### Challenge 3: Are there hidden dependencies on reflexive semantics in the S5 layer?

**Analysis**: The S5 layer uses Box with the T-axiom (Box phi -> phi), which is reflexive. This is a MODAL reflexivity, not temporal. Under the canonical model construction, Box phi at (fam, t) means phi at (fam', t) for all fam' in Omega. The T-axiom for Box gives phi at (fam, t) from Box phi at (fam, t), using fam in Omega (which holds by construction).

This is COMPLETELY INDEPENDENT of temporal semantics. The S5 Box T-axiom is about the modal accessibility relation (which is an equivalence relation), not the temporal order. Changing temporal semantics from reflexive to strict does NOT affect the S5 layer at all.

**However**, there is one subtle point: the `box_phi_all_times` lemma (CanonicalConstruction.lean) shows that Box phi at one time implies Box phi at ALL times. The proof uses temporal propagation. Under strict semantics, this would need: Box phi at t -> Box phi at s for all s != t. The proof goes: Box phi at t -> G(Box phi) at t (by modal_future + necessitation) -> Box phi at s for all s > t. And Box phi at t -> H(Box phi) at t (by symmetric argument) -> Box phi at s for all s < t. Combined with Box phi at t itself: Box phi at all times.

But wait: under strict semantics, G(Box phi) at t means Box phi at all s > t, which does NOT include t. And H(Box phi) at t means Box phi at all s < t. Together with Box phi at t: Box phi at all times. This works fine.

**No hidden dependencies.**

**Confidence**: HIGH

---

## Does Strict + Since/Until Actually Help?

### What It Helps

1. **The backward truth lemma for Until**: This is the current blocker (plan v7 Phase 4). Under strict semantics with X-based discrete unfold, backward induction becomes step-by-step: from `phi U psi in mcs(t+1)` and `phi in mcs(t)`, derive `phi U psi in mcs(t)`. This is DRAMATICALLY simpler than the current approach, which requires `G(phi U psi) in mcs(t)` (all future times) from just one step ahead.

2. **Clean operator coordination**: F = top U, X = bot U, with X giving a definable next-step operator. The discrete axioms have cleaner forms.

3. **Expressiveness**: Kamp-complete over (Z, <), definable X/Y operators.

### What It Does NOT Help

1. **None of the six Boneyard failures**: All root causes are orthogonal to semantics choice.

2. **The dovetailed chain construction**: Already works under reflexive semantics. Would need to be replaced (not just modified) under the standard canonical construction approach.

3. **The S5 modal interaction**: Unchanged by temporal semantics choice.

### What It HURTS

1. **Canonical frame irreflexivity**: The historically abandoned problem returns. Under strict semantics, the canonical frame must be irreflexive, which requires proving that no MCS is its own successor in the discrete canonical frame. This is provable but technically challenging.

2. **Massive engineering cost**: 67+ direct T-axiom usage sites, FMCS structure redefinition, canonical frame reconstruction. The previous critic's estimate of 80-120 hours is reasonable.

3. **Risk of new blockers**: The project has a history of 7+ failed approaches. Rebuilding the canonical model is the highest-risk operation possible.

### The Honest Assessment

**Strict + Since/Until genuinely helps with the specific problem that is currently blocking progress** (the backward truth lemma for Until). The previous critic was wrong to say the switch "solves a problem that doesn't exist" -- it solves exactly the problem in plan v7 Phase 4 that has produced 15 pages of failed attempts.

**However**, the previous critic was RIGHT that the cure may be worse than the disease. The backward truth lemma blocker is ONE sorry in ONE lemma. Switching to strict semantics introduces a wholesale reconstruction of the canonical model, with all the risks that entails.

**The critical question is whether plan v7 Phase 4 CAN be solved under reflexive semantics.** If the U-Induction approach (with the right chi instantiation) works, then the switch to strict semantics is unnecessary despite its theoretical elegance. If Phase 4 is genuinely stuck (all approaches fail under reflexive semantics), then strict semantics becomes a necessary architectural change, not just a nice-to-have.

### My Recommendation

1. **Exhaust the U-Induction approach first.** Try chi = "neg(phi U psi) -> F(neg psi)" or chi = "F(psi) or psi" or other instantiations. The standard completeness proof for Burgess-Xu uses U-Induction, and it was designed for reflexive semantics. There should be a chi that works.

2. **If U-Induction fails**, then strict semantics with X-based backward induction is the correct path. But approach it as a major architectural task, not an incremental fix.

3. **Do not do a partial switch** (e.g., strict Until with reflexive G). This creates inconsistencies in the operator coordination (F = top U no longer clean) and doesn't give the X operator.

---

## Confidence Levels

| Section | Confidence |
|---------|-----------|
| Boneyard Failure Re-Analysis | HIGH (all six failures analyzed, root causes verified against code) |
| X/Y Impact on Completeness Strategy | HIGH (analysis) / MEDIUM (specific implementation details) |
| The Real Hardest Problem | HIGH (ranking) / MEDIUM (difficulty estimates) |
| Remaining Assumptions Challenged | HIGH |
| Does Strict + Since/Until Actually Help? | HIGH |
| Recommendation | MEDIUM (U-Induction approach is untested; may or may not work) |
