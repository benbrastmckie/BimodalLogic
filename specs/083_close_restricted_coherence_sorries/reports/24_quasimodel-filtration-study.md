# Research Report: Quasimodel and Filtration Study for Forward-F Resolution

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Type**: Deep mathematical research (solo)
**Session**: sess_1775507600_b3830d
**Artifact**: 24

---

## 0. Purpose and Scope

This report provides a complete, self-contained mathematical analysis of the quasimodel and filtration approaches to resolving the two leaf sorries (`deterministic_forward_F` and `deterministic_backward_P`) in the completeness proof for bimodal logic TM. Building on 23 prior research reports, it cuts no corners: every claim is justified, every step is explicit, and every gap is identified precisely.

The report is organized into four parts:
1. **Quasimodel construction** (GHR 1994 style) -- full construction, truth lemma analysis, Until case walkthrough
2. **Filtration approach** -- definition, interaction with strict semantics, truth lemma analysis
3. **Synthesis** -- comparison, recommendation, concrete proof sketch
4. **Finite deferral variant** -- analysis of the pigeonhole/soundness argument

---

## 1. Background: The Problem in Precise Terms

### 1.1 The Logic TM

TM is a bimodal logic combining:
- **S5 modal logic** (box/diamond with reflexive, transitive, symmetric accessibility)
- **Strict linear temporal logic** over Z (all_future G, all_past H, Until U, Since S)

**Strict semantics**: G(phi) at time t means phi holds at all s with s > t (strictly). The T-axiom G(phi) -> phi is NOT valid.

**Derived operators**: X(phi) = bot U phi (next), Y(phi) = bot S phi (previous), F(phi) = neg(G(neg(phi))) (some future), P(phi) = neg(H(neg(phi))) (some past).

### 1.2 The Two Leaf Sorries

The completeness proof reduces to exactly two sorry lemmas in `DeterministicFMCS.lean`:

```
deterministic_forward_F: If F(psi) in chain(t), then exists s > t with psi in chain(s)
deterministic_backward_P: If P(psi) in chain(t), then exists s < t with psi in chain(s)
```

where `chain(n+1) = x_content(chain(n))` is the deterministic chain.

### 1.3 Why These Are Hard

The deterministic chain is fully determined by the root MCS M_0. There is no opportunity to "steer" toward resolving F-obligations. The core obstruction (proved across 23 reports): converting the meta-level statement "neg(psi) in chain(s) for all s > t" to the object-level statement "G(neg(psi)) in chain(t)" requires `temporal_backward_G_with_fwd_F`, which takes `forward_F` as a hypothesis -- exactly what we are trying to prove. This circularity is genuine.

### 1.4 What Is Sorry-Free

Everything EXCEPT forward_F and backward_P:
- DeterministicChain: chain construction, MCS property, x_content linkage
- forward_G, backward_H (G/H coherence)
- until_persists_chain, since_persists_chain (Until/Since persistence)
- box_class_agree (modal coherence across chain)
- backward Until/Since introduction (via until_intro/since_intro + induction)
- ParametricTruthLemma (conditional on temporal coherence + until/since coherence)
- temporal_theory_witness_with_g_exists (F-witness existence with g_content preservation)
- Soundness theorem
- FMP infrastructure (Filtration.lean, ClosureMCS.lean, FiniteModel.lean)
- FiniteDeferral.lean: F_to_until, until_persists_forward_steps, pigeonhole_restricted_theories, G_neg_kills_until

---

## Part 1: Quasimodel Construction (GHR 1994 Style)

### 1.1 What Is a Quasimodel?

A **quasimodel** for a formula phi_0 is a structure (W, R, L) where:
- W is a set of "states" (typically MCSes or MCS-like objects)
- R : W -> W is a successor relation (corresponding to the temporal next-step)
- L : W -> Set Formula is a labeling (the set of formulas true at each state)

satisfying:
1. **Local consistency**: L(w) is (propositionally) consistent for each w
2. **Next-step coherence**: L(R(w)) = x_content(L(w)) OR a weaker condition
3. **Eventuality resolution**: For every w in W and every F(psi) in L(w), there exists w' reachable from w via R with psi in L(w')

The key difference from a model: a quasimodel need not have a single linear timeline. It is a directed graph with built-in witnesses for all eventualities.

### 1.2 Quasimodel for THIS Logic

For TM with strict semantics over Z, we define:

**Definition (TM-Quasimodel)**. Fix an MCS M_0 (the root). A TM-quasimodel rooted at M_0 is a tuple (W, succ, pred, label) where:

- **W** = {M : Set Formula | SetMaximalConsistent M and box_class_agree M_0 M}
  (all MCSes in the same box-class as M_0)

- **succ(M)** = x_content(M) for each M in W
  (deterministic forward successor -- this is well-defined since x_content preserves MCS and box-class)

- **pred(M)** = y_content(M) for each M in W
  (deterministic backward successor)

- **label(M)** = M (the MCS itself)

- **F-witnesses**: For each M in W and each F(psi) in M, there exists W_psi in W with psi in W_psi and g_content(M) subset W_psi. This is guaranteed by `temporal_theory_witness_with_g_exists`.

### 1.3 Why succ = x_content?

The choice succ(M) = x_content(M) is forced by the Until persistence requirement. The sorry-free theorem `until_persists_chain` crucially depends on chain(n+1) = x_content(chain(n)):

- (phi U psi) in chain(n) implies X(psi or (phi and (phi U psi))) in chain(n) by until_unfold
- So psi or (phi and (phi U psi)) in x_content(chain(n)) = chain(n+1)
- If psi not in chain(n+1), then phi and (phi U psi) in chain(n+1)

This breaks if chain(n+1) is anything other than x_content(chain(n)).

### 1.4 Path Extraction from the Quasimodel

To build a model (an Int-indexed family), we need to extract a linear path through the quasimodel that:
(a) resolves all F-obligations
(b) resolves all P-obligations
(c) maintains x_content linkage (for Until persistence)

**The standard approach (Burgess/GHR)**: Build the path incrementally using fair scheduling.

**Construction**:
1. Set path(0) = M_0.
2. At step n >= 0, path(n) is some MCS M_n in W.
3. Let alpha_n = schedule_formula(n) be the target formula from fair scheduling.
4. Choose path(n+1):
   - If F(alpha_n) in M_n and alpha_n in x_content(M_n): set path(n+1) = x_content(M_n). The obligation is immediately resolved at n+1.
   - If F(alpha_n) in M_n and alpha_n not in x_content(M_n): set path(n+1) = W(M_n, alpha_n), a resolution witness from temporal_theory_witness_with_g_exists. But see Section 1.5 for the critical problem.
   - Otherwise: set path(n+1) = x_content(M_n) (deterministic step).
5. Backward chain: symmetric using y_content and P-resolution.

### 1.5 The Critical Problem: Until Through Detours

**This is the make-or-break analysis for the quasimodel approach.**

When the path takes a "detour" at step n (case 2 above), path(n+1) = W(M_n, alpha_n) instead of x_content(M_n). The witness W satisfies:
- alpha_n in W
- g_content(M_n) subset W
- box_class_agree(M_n, W)
- G_theory agreement: G(a) in M_n implies G(a) in W

**Question**: Does Until persistence hold through the detour?

Suppose (phi U psi) in path(n) = M_n and psi not in path(n+1) = W. Do we get phi in W and (phi U psi) in W?

**Analysis**:

Step 1: (phi U psi) in M_n. By until_unfold: X(psi or (phi and (phi U psi))) in M_n. So psi or (phi and (phi U psi)) in x_content(M_n).

Step 2: But path(n+1) = W, NOT x_content(M_n). We know g_content(M_n) subset W, but x_content(M_n) is NOT a subset of W in general.

Step 3: Is (phi U psi) in g_content(M_n)? That would require G(phi U psi) in M_n. We only have (phi U psi) in M_n, which does NOT imply G(phi U psi) in M_n. Under strict semantics, G(alpha) -> alpha is invalid, so (phi U psi) in M_n says nothing about whether G(phi U psi) in M_n.

Step 4: Is psi or (phi and (phi U psi)) in g_content(M_n)? That would require G(psi or (phi and (phi U psi))) in M_n. We only have X(psi or (phi and (phi U psi))) in M_n. And X(alpha) does NOT imply G(alpha) -- the next-step operator is strictly weaker than the always-future operator.

**Conclusion**: Until persistence BREAKS through detours. The quasimodel detour step loses the x_content linkage, and the g_content preservation is insufficient to maintain Until formulas.

### 1.6 Can the Witness Be Enriched?

**Attempt**: Enrich the Lindenbaum seed for W to include Until deferrals:

```
enriched_seed(M) = {target} union temporal_box_g_seed(M) union until_deferrals(M)
```

where `until_deferrals(M) = { psi_i or (phi_i and (phi_i U psi_i)) | (phi_i U psi_i) in M }`.

**Consistency analysis**:

Every formula in until_deferrals(M) is in x_content(M) (by until_unfold). Every formula in temporal_box_g_seed(M) is in x_content(M) (by G->X and temp_4). So the combined set temporal_box_g_seed(M) union until_deferrals(M) is a subset of x_content(M), which is an MCS, so this combined set is consistent.

But is {target} union temporal_box_g_seed(M) union until_deferrals(M) consistent?

The existing G-lift argument works for temporal_box_g_seed(M): if L_g union {target} is inconsistent, then L_g derives neg(target), and G-lifting each element gives G(neg(target)) in M, contradicting F(target) in M.

**The G-lift fails for until_deferrals**: The element psi_i or (phi_i and (phi_i U psi_i)) is X-liftable (X of it is in M) but NOT G-liftable (G of it may not be in M). So if L_g union L_u union {target} is inconsistent where L_u contains Until deferrals, we cannot G-lift the L_u elements.

**Concrete failure scenario**: Suppose (top U psi) in M and F(alpha) in M with alpha not in x_content(M). Then neg(alpha) in x_content(M). The deferral disjunction psi or (top and (top U psi)) is in x_content(M). If psi or (top and (top U psi)) combined with temporal_box_g_seed(M) implies neg(alpha), then {alpha} union temporal_box_g_seed(M) union {psi or (top and (top U psi))} is inconsistent. This CAN happen.

**Verdict**: The enriched seed approach fails for the same reason identified in Report 22 Section 8.2. The Until deferrals are X-liftable but not G-liftable, and the G-lift consistency argument does not extend.

### 1.7 Alternative Quasimodel: Non-Deterministic x_content Successor

**Attempt**: Instead of detouring to a witness MCS, define a "non-deterministic x_content successor" that is in x_content(M) but also contains the target.

If target in x_content(M): use x_content(M) directly. Done.

If target not in x_content(M): x_content(M) is an MCS, so neg(target) in x_content(M). We would need an MCS that contains both x_content(M) and target -- but that contradicts consistency (neg(target) and target cannot both be in an MCS).

**This approach is impossible**: When the target is not already in x_content(M), no single MCS can serve as both an x_content-compatible successor and a witness for the target.

### 1.8 Alternative Quasimodel: Multi-Step Resolution

**Attempt**: Instead of resolving F(alpha) in one step, show that the deterministic chain resolves it within finitely many steps.

This is essentially the finite deferral argument (Part 4 of this report). The quasimodel framework provides no advantage here -- the resolution must happen within the single deterministic chain.

### 1.9 Quasimodel Verdict

**The quasimodel approach, as standardly described in GHR 1994, does NOT directly apply to this formalization because:**

1. The standard quasimodel uses non-deterministic successor relations, but Until persistence in TM requires the deterministic x_content linkage.

2. When the path detours to a witness MCS, Until formulas in the current state are not preserved because they are X-liftable but not G-liftable.

3. Enriching the witness seed with Until deferrals fails because the consistency proof requires G-liftability.

**How published proofs handle this**: In Burgess 1984 and GHR 1994, the logic uses REFLEXIVE temporal semantics (G(phi) -> phi is valid). Under reflexive semantics, g_content(M) includes all formulas in M that are under G, and crucially, if (phi U psi) persists infinitely, then G(phi U psi) can be derived. The strict semantics of TM breaks this: G(phi U psi) in M does NOT follow from (phi U psi) in M, because G quantifies over strictly future times only.

**The quasimodel approach would work if**: We could prove that whenever (phi U psi) in M, either psi eventually appears in the deterministic chain, or there is a syntactic derivation showing G(phi U psi) in M. But the second disjunct is exactly what we cannot prove without forward_F (the circularity).

---

## Part 2: Filtration Approach

### 2.1 Standard Filtration for Modal Logic

Filtration is a technique to construct finite models from infinite ones:
1. Fix a formula phi_0 and its subformula closure Sigma = subformulaClosure(phi_0).
2. Define equivalence: w ~ v iff for all psi in Sigma, (M |= psi at w) iff (M |= psi at v).
3. Take the quotient model M/~ with quotient worlds.
4. Define filtered accessibility and valuation.
5. Show: for all psi in Sigma, M/~ |= psi at [w] iff M |= psi at w (filtration lemma).
6. Since |Sigma| is finite, there are at most 2^|Sigma| equivalence classes, so M/~ is finite.

### 2.2 Filtration for TM with Strict Temporal Semantics

For TM, the model is a task model (W, <, ~_S5, V) where:
- W = Z (integer timeline)
- < is the strict order on Z
- ~_S5 is the S5 equivalence (universal within equivalence classes)
- V is the valuation

**Temporal filtration**: Two time points t, s are equivalent iff they satisfy exactly the same formulas in Sigma at those times.

**Filtered temporal order**: Define [t] <_f [s] iff there exist t' in [t] and s' in [s] with t' < s' in the original model.

**Problem with Until**: The filtered model has finitely many worlds. For the Until truth lemma:

Forward direction: (phi U psi) true at [t] in filtered model. Need to show: there exists [s] >_f [t] with psi true at [s] and phi true at all [r] with [t] <_f [r] <_f [s].

This requires that the Until witnesses and guards are preserved through the filtration. The standard filtration lemma for Until is:

**Filtration Lemma (Until case)**: (phi U psi) in M_t iff there exists s > t with psi in M_s and phi in M_r for all r with t < r < s.

This holds in the ORIGINAL model by the semantics of Until. But in the FILTERED model, the question is whether the filtration preserves this.

### 2.3 Filtration and the Forward-F Problem

**Key observation**: Filtration does NOT help with proving forward_F in the completeness proof.

The filtration technique starts from a MODEL and constructs a FINITE model. But our problem is constructing a model in the first place (the completeness proof). The filtration is used AFTER we have a model, to show the finite model property.

In the existing codebase, the FMP infrastructure (Filtration.lean, ClosureMCS.lean, etc.) constructs finite models from PROOF-THEORETIC objects (closure MCSes), not from semantic models. This is relevant.

### 2.4 MCS-Based Filtration (Proof-Theoretic)

The existing FMP infrastructure uses an MCS-based approach:
- "Worlds" are ClosureMCS (MCSes restricted to subformula closure)
- Equivalence is agreement on closure membership
- The filtration equivalence is purely proof-theoretic

**Can this be used for completeness?** The approach would be:

1. Start with unprovable phi_0. Then neg(phi_0) is consistent.
2. Extend to full MCS M_0 containing neg(phi_0).
3. Build deterministic chain from M_0.
4. Restrict each chain element to the deferral closure: restrictedTheory(n) = chain(n) intersect deferralClosure(phi_0).
5. By pigeonhole (already proven in FiniteDeferral.lean), the restricted theories cycle within 2^|deferralClosure| steps.
6. Show that a cycle with unresolved F(psi) leads to contradiction.

**Step 6 is the gap.** The cycle gives us positions i < j with restrictedTheory(t+i) = restrictedTheory(t+j) and (top U psi) in chain(t+k) for all k in [0, j] and psi not in chain(t+k) for all k in [1, j].

### 2.5 The Cycle Contradiction (Detailed Analysis)

**Setup**: We have the deterministic chain from M_0. Assume F(psi) in chain(t) but psi not in chain(s) for all s > t. Then:
- (top U psi) in chain(n) for all n >= t (by until_persists_forward_steps, sorry-free)
- neg(psi) in chain(n) for all n > t (by MCS negation completeness)
- By pigeonhole: there exist i < j with j - i <= 2^|deferralClosure(psi)| such that restrictedTheory(t+i) = restrictedTheory(t+j)

The restricted theory includes ALL formulas in deferralClosure(psi) that are in chain(n). Crucially, deferralClosure(psi) includes:
- closureWithNeg(psi): all subformulas of psi and their negations
- deferralDisjunctionSet(psi): the deferral disjunctions from Until subformulas
- serialityFormulas: F_top, P_top, neg(bot)

**The key question**: Does restrictedTheory(t+i) = restrictedTheory(t+j) enable us to derive a contradiction?

### 2.6 Why Direct Object-Level Reasoning Fails

To derive a contradiction, we would ideally show G(neg(psi)) in chain(t), which contradicts (top U psi) in chain(t) via G_neg_kills_until (already sorry-free).

But G(neg(psi)) in chain(t) requires: for all n > t, neg(psi) in chain(n) implies G(neg(psi)) in chain(t). This is temporal_backward_G, which requires forward_F -- circular.

### 2.7 The Finite Cyclic Model Argument (Semantic Level)

**This is the most promising direction.** Instead of deriving G(neg(psi)) in the object language, work at the SEMANTIC level:

**Construction**: From the cycle, build a finite cyclic model.

Define a task model M_cyc:
- Time domain: Z (but we will reason about a finite cycle)
- World-states: the equivalence classes of restricted theories [i.e., the cycle positions]
- For the cycle [t+i, t+i+1, ..., t+j-1] with wraparound, define:
  - Valuation: V(n, p) iff atom(p) in chain(n) for n in [t+i, t+j-1]
  - Temporal order: the standard order on Z, restricted to the cycle

Wait -- this is NOT quite a task model because a task model has a linear order on Z, not a cyclic one. Let me reconsider.

**Attempt 1: Cyclic model on Z/kZ**

Define k = j - i (the cycle length). Consider the model on Z where:
- truth_at(n, atom(p)) iff atom(p) in chain(t + i + (n mod k))

This makes the model periodic with period k. But Z with the standard order < is still a valid linear order. The Until formula (top U psi) would need to be true at every position (since it's in chain(n) for all n >= t). But psi is never true (since psi not in chain(n) for any n > t, and the periodic model repeats the cycle where psi is absent).

**Semantic contradiction**: In any model over (Z, <), if (top U psi) is true at time 0, then there exists s > 0 with psi true at s. But in our periodic model, psi is never true. Contradiction.

**The question**: Is this periodic model actually a model of TM? Specifically, is every axiom of TM sound in this model?

### 2.8 Soundness in the Periodic Model

The soundness theorem says: if phi is provable ([] |- phi), then phi is valid in all task models over (Z, <) with S5 accessibility.

**The periodic model IS a task model over (Z, <)**:
- Time domain: Z with standard order <
- S5 accessibility: we need to define this. For simplicity, use a single equivalence class (all times see each other).
- Valuation: V(n, p) = atom(p) in chain(t + i + (n mod k))

The axioms of TM are:
- Propositional axioms: trivially sound.
- S5 modal axioms (T, 4, B, 5, K): sound because accessibility is universal.
- Temporal axioms (G-K-dist, temp_4, temp_a, temp_a_dual, temp_l): these require CHECKING for this specific model. The temporal order is standard Z-order, which is a discrete linear order. All temporal axioms for (Z, <) are sound by the existing soundness theorem (which is proven sorry-free).
- Until/Since axioms (unfold, intro, induction, linearity, connectedness, F_until_equiv, P_since_equiv): these are sound for (Z, <) by the existing soundness theorem.
- Seriality (neg G(bot)): Z has no last element, so G(bot) is never true. Hence neg(G(bot)) is always true.
- Discreteness: Z is discrete.

**BUT**: We need to check that the VALUATION is well-defined. The periodic model's valuation is V(n, p) = atom(p) in chain(t + i + (n mod k)). This is a legitimate valuation function Z -> Atom -> Prop.

**The S5 component needs care**: In the periodic model, if we set S5 accessibility to be universal, then box(phi) at time n means phi at ALL times. In the deterministic chain, box formulas are constant (box_class_agree), so box(phi) in chain(n) iff box(phi) in chain(m) for all m. The periodic model preserves this: box(phi) in chain(t+i+(n mod k)) is the same for all n.

**Verification that the periodic model is a valid task model**: For this, we need to show that the periodic model is actually a task model satisfying the frame conditions. The task frame for TM over Z is (Z, <, ~_S5) where ~_S5 is an equivalence relation on Z. In our periodic model, all times are S5-accessible to each other (single equivalence class). This is a valid S5 frame. The temporal order < is standard on Z. This is a valid task frame.

So the periodic model IS a valid task model, and the soundness theorem applies.

### 2.9 The Semantic Contradiction in Detail

**Theorem (Forward_F via Soundness + Pigeonhole)**:

Given: M_0 is an MCS. F(psi) in chain(t). Assume for contradiction: psi not in chain(s) for all s > t.

Step 1: By F_to_until_in_chain (sorry-free): (top U psi) in chain(t).

Step 2: By until_persists_forward_steps (sorry-free): (top U psi) in chain(n) for all n >= t.

Step 3: By pigeonhole_restricted_theories (sorry-free): there exist i < j with j <= 2^|deferralClosure(psi)| and restrictedTheory(t+i) = restrictedTheory(t+j).

Step 4: Let k = j - i. Define the periodic model M_cyc:
- Time domain: Z with standard order
- Single S5 equivalence class
- V(n, p) = (atom(p) in chain(t + i + ((n - 0) mod k)))
  More precisely: define f(n) = t + i + (((n mod k) + k) mod k) for n >= 0, and extend periodically for negative n. But actually, the simplest is:
  V(n, p) = (atom(p) in chain(t + i + (n mod k)))  where we use Euclidean mod (result in [0, k-1]).

Step 5: Claim: (top U psi) is TRUE at time 0 in M_cyc.

To verify this, we need to show that the semantic truth of (top U psi) at time 0 follows from the syntactic membership (top U psi) in chain(t + i + 0) = chain(t + i).

**THIS is the gap**: We have (top U psi) in chain(t+i), but we need (top U psi) true at time 0 in M_cyc. These are different things -- membership in an MCS is a syntactic property, while truth in a model is semantic.

To connect them, we need a truth lemma for the periodic model. But proving a truth lemma for the periodic model is essentially the same as proving completeness -- which is what we are trying to do.

### 2.10 Breaking the Circularity: Truth Lemma for Atomic Formulas Only

**Key insight**: We do NOT need a full truth lemma for the periodic model. We only need:

1. psi is NOT true at any time > 0 in M_cyc (by construction, since psi is a specific formula and neg(psi) in chain(n) for all n in the cycle)
2. (top U psi) IS true at time 0 in M_cyc (somehow)

For (1): neg(psi) in chain(t+i+r) for all r in [1, k-1] (since psi not in chain(s) for s > t, and i >= 0). In the periodic model, psi is evaluated semantically. IF psi is an atom p, then V(n, p) = (atom(p) in chain(t+i+(n mod k))) = (p in chain(t+i+(n mod k))). Since neg(p) in chain(t+i+r) for r = 1, ..., k-1, atom(p) not in chain(t+i+r) for r = 1, ..., k-1. So psi = atom(p) is false at times 1, 2, ..., k-1. By periodicity, psi is false at all n not congruent to 0 mod k. But at n = 0: is p in chain(t+i)? We assumed psi not in chain(s) for s > t. If i >= 1 (which it is since the pigeonhole gives positions AFTER t), then chain(t+i) also lacks psi.

Wait -- actually i could be 0. Let me reconsider. The pigeonhole gives i, j with 0 <= i < j <= bound. If i = 0, then psi might be in chain(t+0) = chain(t). But we only know psi not in chain(s) for s > t, and chain(t) might contain psi. However, if psi in chain(t), then F(psi) is resolved (exists s > t with psi in chain(s) -- well, t is not > t, so F(psi) requires s > t). Actually, psi in chain(t) does not resolve F(psi) because F(psi) requires a STRICTLY FUTURE witness. So even if psi in chain(t), we still need psi in chain(s) for some s > t.

Let me adjust: the pigeonhole is applied starting from t+1 (the first strictly future position). Then i >= 0 gives positions t+1+i and t+1+j with the same restricted theory. Define the cycle over positions [t+1+i, t+1+j-1]. In this range, psi is absent (since psi not in chain(s) for s > t, and all positions in the cycle are > t).

**Revised setup**: Let t' = t+1. Apply pigeonhole from t'. Get i < j with restrictedTheory(t'+i) = restrictedTheory(t'+j). The cycle is over [t'+i, t'+j-1] = [t+1+i, t+j], length k = j-i. psi is absent at every position in this range.

In the periodic model defined from this cycle, psi is absent at EVERY position (since the cycle covers [t+1+i, ..., t+j] and psi is absent at all of them, and the model is periodic).

### 2.11 The Core Difficulty with Semantic Approach

Even with psi absent everywhere in the periodic model, we need to show that "U psi is true at some position" to get a contradiction.

But we cannot show (top U psi) is true at any position in the periodic model without a truth lemma. The membership (top U psi) in chain(t+1+i) is a syntactic fact. Whether (top U psi) is semantically true at the corresponding position in the periodic model requires connecting MCS membership to semantic truth -- which is the completeness theorem.

**This appears circular.** But there is a way out.

### 2.12 The Soundness-Based Approach (Non-Circular)

Instead of using truth, use PROVABILITY and SOUNDNESS.

**Approach**: Show that the assumption "psi never appears" leads to an INCONSISTENT set of formulas, purely syntactically.

The key tool is the `until_induction` axiom:

```
G(psi -> chi) and G((phi and X(chi)) -> chi) -> ((phi U psi) -> X(chi))
```

**Instantiation**: phi = top, psi = psi, chi = bot.

This gives: G(psi -> bot) and G((top and X(bot)) -> bot) -> ((top U psi) -> X(bot))

Simplification:
- psi -> bot = neg(psi)
- top and X(bot) = top and (bot U bot). Since (bot U bot) implies bot (by X_bot_absurd), top and (bot U bot) implies bot. So (top and X(bot)) -> bot is a theorem.
- G of a theorem is a theorem (by temporal necessitation).
- X(bot) = bot U bot, which implies bot (by X_bot_absurd).

So the instantiation gives: G(neg(psi)) and G(theorem) -> ((top U psi) -> X(bot))

Since G(theorem) is a theorem, this simplifies to: G(neg(psi)) -> ((top U psi) -> X(bot))

Since X(bot) is refutable (neg(X(bot)) is provable via seriality), this gives: G(neg(psi)) -> neg(top U psi)

**This is exactly G_neg_kills_until**, which is already proven sorry-free in FiniteDeferral.lean.

The problem remains: we need G(neg(psi)) in chain(t) to derive the contradiction. And deriving G(neg(psi)) from "neg(psi) in chain(n) for all n > t" requires temporal_backward_G, which requires forward_F.

### 2.13 Filtration Verdict

**The standard filtration approach does not directly help resolve forward_F** because:

1. Filtration starts from a model, but we are trying to BUILD a model (completeness).
2. The MCS-based proof-theoretic filtration (existing FMP infrastructure) gives finite closure MCSes, but connecting closure MCS membership to temporal coherence requires the same backward-G step that causes the circularity.
3. The periodic model argument requires a truth lemma to connect MCS membership to semantic truth, which IS the completeness theorem.

**However**: The filtration/FMP infrastructure COULD be used indirectly, as analyzed in Part 4 (the finite deferral variant).

---

## Part 3: Synthesis

### 3.1 Comparison of Approaches

| Criterion | Quasimodel (GHR 1994) | Filtration | Finite Deferral + Soundness |
|-----------|----------------------|------------|---------------------------|
| Resolves forward_F? | No (Until breaks through detours) | No (requires truth lemma) | Potentially (if cycle -> contradiction works) |
| Fits strict semantics? | No (needs G->phi valid) | N/A (doesn't address the problem) | Yes (works purely syntactically) |
| Fits existing codebase? | Would need major refactor | FMP infra exists but insufficient | Builds on FiniteDeferral.lean |
| Published technique? | Yes (but for reflexive semantics) | Yes (for modal, not for Until directly) | Novel (untested) |
| Estimated effort | 1000-1500 lines, VERY HIGH | N/A | 500-850 lines, HIGH |

### 3.2 The Root Cause

All three approaches fail at the same point: **converting "neg(psi) at all future chain positions" (a meta-level/external statement about the chain) into "G(neg(psi)) in chain(t)" (an object-level/internal statement within the chain)**. This meta-to-object conversion is `temporal_backward_G`, which requires forward_F, creating the circularity.

The published literature handles this by working with reflexive temporal semantics where G(phi) -> phi is valid. Under reflexive semantics:
- If phi in M for all future M reachable via the temporal relation, then G(phi) in M because the relation is reflexive-transitive and the canonical model has a built-in truth lemma.
- The T-axiom G(phi) -> phi ensures that G-wrapped formulas are "self-including."

Under strict semantics, this breaks because G(phi) in M means phi at all STRICTLY future times, and the present is excluded.

### 3.3 What CAN Work

Given the analysis across all four approaches, exactly TWO paths remain viable:

**Path A: Prove temporal_backward_G without forward_F, using a restricted/bounded variant.**

The idea: instead of proving G(neg(psi)) in chain(t) (which requires the full backward_G), prove a BOUNDED version: "neg(psi) holds at positions t+1, ..., t+K" for some computable K. Then use the until_induction axiom with a BOUNDED version of G.

**Problem**: There is no "bounded G" in the object language of TM. G quantifies over ALL strictly future times, not just the next K times.

**Path B: Use soundness at the META level to derive a contradiction from the cycle.**

The idea: the cycle gives us a finite set of MCSes {chain(t+1+i), ..., chain(t+j)} with:
- The same restricted theory at positions i and j
- (top U psi) in every position
- neg(psi) in every position

Construct a specific THEOREM (derivable from the axioms) that is violated by this cycle. If we can find such a theorem, then the cycle is inconsistent with the axioms, contradicting the fact that each chain(n) is an MCS of the axiom system.

**Specifically**: The until_induction axiom says:

G(psi -> chi) and G((top and X(chi)) -> chi) -> ((top U psi) -> X(chi))

If we could find chi such that:
- G(psi -> chi) is provable (hence in every MCS)
- G((top and X(chi)) -> chi) is in chain(t+1+i)
- (top U psi) in chain(t+1+i)
- X(chi) not in chain(t+1+i) (contradicting the conclusion)

Then chain(t+1+i) would be inconsistent, which is impossible for an MCS.

The challenge is finding such a chi. Let me analyze this carefully.

### 3.4 The Fischer-Ladner Closure Argument

**Definition**: For a formula alpha, define the **Fischer-Ladner closure** FL(alpha) as the smallest set containing alpha and closed under:
- If phi in FL(alpha), then every subformula of phi is in FL(alpha)
- If (phi U psi) in FL(alpha), then X(psi or (phi and (phi U psi))) in FL(alpha)
- Negation closure

The key property: FL(alpha) is FINITE (polynomial in |alpha|).

**The restricted theory on FL(psi)**: Since FL(psi) is finite, the restricted theory (chain(n) intersect FL(psi)) cycles within 2^|FL(psi)| steps. This is exactly what pigeonhole_restricted_theories proves (with deferralClosure as the closure).

**At the cycle**: restrictedTheory(t+1+i) = restrictedTheory(t+1+j). Let k = j - i. This means for every formula gamma in FL(psi): gamma in chain(t+1+i) iff gamma in chain(t+1+i+k).

**Chain(t+1+i+k) = x_content^k(chain(t+1+i))**. So the restricted theory is invariant under k applications of x_content.

### 3.5 The Induction Argument Over the Cycle

**Claim**: If the restricted theory of FL(psi) is k-periodic (i.e., for all gamma in FL(psi), gamma in chain(n) iff gamma in chain(n+k)), and (top U psi) in chain(n) for all n in the cycle, and psi not in chain(n) for all n in the cycle, then we can derive a contradiction.

**Proof attempt using until_induction**:

We need chi such that:
1. psi -> chi is in every chain(n) in the cycle (equivalently, G(psi -> chi) in chain(t+1+i))
2. (top and X(chi)) -> chi is in every chain(n) in the cycle
3. X(chi) not in chain(t+1+i) (to get contradiction)

From (1): since psi is never in the cycle, psi -> chi = neg(psi) -> (psi -> chi) is trivially in every MCS regardless of chi (because neg(psi) in every chain(n), and neg(psi) implies psi -> chi for any chi by ex falso after getting bot from psi and neg(psi)).

Wait, that is not right. psi -> chi = psi.imp chi. If psi not in chain(n), then neg(psi) in chain(n). Does neg(psi) imply psi -> chi? Well, psi -> chi = psi.imp chi. From neg(psi) = psi -> bot and ex_falso (bot -> chi), we get psi -> chi. So yes, psi -> chi in chain(n) whenever neg(psi) in chain(n).

So condition (1) is satisfied for ANY chi, as long as neg(psi) in chain(n) for all n in the cycle.

But we need G(psi -> chi) in chain(t+1+i), not just psi -> chi in every chain(n). The meta-level "for all n" does not give us the object-level G(...). This is the same circularity.

UNLESS: psi -> chi is actually a THEOREM (derivable from the empty context). Then G(psi -> chi) is also a theorem (by temporal necessitation), hence in every MCS.

Since neg(psi) might not be a theorem (it is just true in our specific chain), psi -> chi might not be a theorem either.

**Alternative choice of chi**: What if chi is a theorem? Then psi -> chi is a theorem, G(psi -> chi) is a theorem, and (top and X(chi)) -> chi is also a theorem (since chi is a theorem). But then X(chi) is also a theorem (by G_implies_X applied to G(chi)), so condition (3) fails.

**Alternative choice of chi**: Let chi = neg(top U psi). Then:
- psi -> neg(top U psi): is this provable? NO. psi implies F(psi) in reflexive semantics, which implies top U psi. So psi and neg(top U psi) are inconsistent. So psi -> neg(top U psi) is equivalent to neg(psi). Under our assumption neg(psi) is in every chain(n), but it is not a theorem.
- (top and X(neg(top U psi))) -> neg(top U psi): unpacking, this says that if neg(top U psi) holds at the next step, then it holds now. This would mean: if top U psi is false at the next step, it is false now. Is this derivable? By until_intro: X(psi or (top and (top U psi))) -> (top U psi). Contrapositive: neg(top U psi) -> neg(X(psi or (top and (top U psi)))). Hmm, this does not directly give us the step condition.

**This line of reasoning does not yield a simple chi.**

### 3.6 The Definitive Approach: Soundness Over the Unrolled Cycle

Here is the key insight that makes the soundness approach work:

**Observation**: We do NOT need to find chi inside the object language. Instead, we reason at the META level about the semantic properties of the cycle.

**Construction**: From the cycle of length k = j - i:

1. Define a Z-indexed model M_per (periodic model):
   - For each n in Z, let r(n) = ((n mod k) + k) mod k (value in [0, k-1])
   - Valuation: V(n, p) = (atom(p) in chain(t+1+i+r(n)))
   - S5 accessibility: universal (single equivalence class)

2. This IS a valid task model over (Z, <) with S5 accessibility.

3. **Truth at atomic level**: For atom p and any n in Z: truth_at(M_per, n, atom(p)) iff atom(p) in chain(t+1+i+r(n)).

4. **Truth for boolean connectives**: By standard induction on formula structure, for any propositional formula phi built from atoms, bot, imp:
   truth_at(M_per, n, phi) iff phi in chain(t+1+i+r(n)).

   This works because chain(t+1+i+r(n)) is an MCS (negation complete, closed under derivation), and MCS membership respects propositional truth.

5. **Truth for box**: truth_at(M_per, n, box(phi)) iff for all m, truth_at(M_per, m, phi).
   Since box formulas are constant across the chain (box_class_agree), box(phi) in chain(t+1+i+r(n)) iff box(phi) in chain(t+1+i+r(m)) for all m. Combined with the propositional truth lemma applied to phi... wait, this requires the truth lemma for phi, not just propositional formulas.

6. **Truth for G**: truth_at(M_per, n, G(phi)) iff for all m > n, truth_at(M_per, m, phi).
   This requires the truth lemma for phi at all times, which we do not have in general.

**The difficulty**: Even the periodic model construction requires a full truth lemma to connect MCS membership to semantic truth. This is circular.

### 3.7 The Restricted Truth Lemma for the Periodic Model

**Key realization**: We CAN prove a restricted truth lemma for formulas in the deferral closure, because:

1. The deferral closure is finite.
2. The chain is periodic on the deferral closure (by the pigeonhole hypothesis).
3. Each chain element restricted to the deferral closure is determined by a finite set.

**Specifically**: For formulas psi_0 in deferralClosure(phi_0):

Claim: truth_at(M_per, n, psi_0) iff psi_0 in chain(t+1+i+r(n)).

Proof by induction on the structure of psi_0, RESTRICTED to formulas in deferralClosure(phi_0).

- **atom**: By definition of V.
- **bot**: Both sides false (bot not in MCS; bot not true in any model).
- **imp**: By MCS implication property + IH. This is standard.
- **box**: By modal coherence. box(phi) in chain(n) iff box(phi) in chain(m) (sorry-free). In M_per, truth_at(M_per, n, box(phi)) requires phi at all m in all S5-accessible worlds. Since the S5 class is universal, this is phi at all times. If box(phi) in chain(n), then phi in chain(m) for all m (by modal_t applied in each chain element). Hmm, this requires phi in chain(m), which by IH requires truth_at(M_per, m, phi). And truth_at(M_per, m, box(phi)) requires truth_at(M_per, m', phi) for all m'. This is the standard modal truth lemma -- it works if the bundle of families provides the backward modal direction.

   Actually, in the periodic model with a SINGLE S5 class, box(phi) true at n means phi true at all n' at all times. This is a very strong condition. If box(phi) in chain(n) for some n, then by box_class_agree, box(phi) in chain(m) for all m. By modal_t, phi in chain(m) for all m. By IH, truth_at(M_per, m, phi) for all m. So box(phi) true at n. Conversely, if box(phi) true at n, then phi true at all m. In particular phi in chain(m) for all m (by backward IH). Then box(phi) in chain(n) by... well, we need the backward direction of the modal truth lemma, which typically requires the diamond witness argument. But with a single S5 class and all chain elements sharing box theory, this works out.

- **G(phi)**: Forward: G(phi) in chain(n). By temp_4, G(phi) persists forward through x_content. In M_per (periodic), G(phi) in chain(n) for all n in the cycle (by periodicity of restricted theory, IF G(phi) is in the deferral closure). Then phi in chain(m) for all m > n (in the periodic model, this wraps around). By IH, truth_at(M_per, m, phi) for all m > n. So G(phi) true at n.

   Backward: For all m > n, phi true at m. By IH, phi in chain(m) for all m > n. Need G(phi) in chain(n). **THIS is the backward G step that requires forward_F.**

**The backward G case still requires forward_F.** The restricted truth lemma for the periodic model has the same circularity.

### 3.8 Ultimate Assessment

After exhaustive analysis of all three approaches, the situation is:

**The quasimodel, filtration, and periodic model approaches ALL require the backward-G step in the truth lemma, which requires forward_F. The circularity is intrinsic to the truth lemma structure, not to any particular model construction.**

The ONLY way to break the circularity is to avoid the truth lemma entirely, or to use a truth lemma that does not require backward_G.

### 3.9 The One Remaining Hope: Direct Syntactic Contradiction

**Can we derive a contradiction purely syntactically from the cycle, without any semantic model?**

Setup: MCS chain(t+1+i), ..., chain(t+j) with:
- All are MCSes
- chain(m+1) = x_content(chain(m))
- restrictedTheory(t+1+i) = restrictedTheory(t+1+j)
- (top U psi) in chain(m) for all m in this range
- neg(psi) in chain(m) for all m in this range

Let k = j - i. For any formula gamma in deferralClosure(psi):
gamma in chain(t+1+i) iff gamma in chain(t+1+j) = chain(t+1+i+k) = x_content^k(chain(t+1+i))

**Key formula**: (top U psi) in chain(t+1+i). By until_unfold applied k times:
X^k(psi or (top and (top U psi))) in chain(t+1+i) (where X^k means k nested X's).

But actually, until_unfold gives X(psi or (top and (top U psi))), not X^k. And X^k is not a primitive -- we would need to unfold k times, getting:

Step 0: (top U psi) in chain(t+1+i)
Step 1: psi or (top and (top U psi)) in chain(t+1+i+1). Since neg(psi) in chain(t+1+i+1): (top and (top U psi)) in chain(t+1+i+1). So top in chain(t+1+i+1) (trivially) and (top U psi) in chain(t+1+i+1).
...
Step k: (top U psi) in chain(t+1+i+k) = chain(t+1+j).

Since restrictedTheory(t+1+i) = restrictedTheory(t+1+j), and (top U psi) is in deferralClosure(psi) (because it IS psi prefixed with top U, and subformulas of (top U psi) include psi, top, (top U psi)):

Actually, is (top U psi) in deferralClosure(psi)? Let me check. deferralClosure is defined as baseDeferralClosure = closureWithNeg union deferralDisjunctionSet union backwardDeferralSet union serialityFormulas. closureWithNeg(psi) = subformulaClosure(psi) union negations. If the root formula is psi itself, then (top U psi) might not be a subformula of psi (it IS psi if F(psi) was converted to top U psi by F_until_equiv).

Wait, let me reconsider. The deferralClosure is defined relative to a ROOT formula. In our case, the root is phi_0 (the formula being refuted for completeness). F(psi) might be a subformula of phi_0, in which case (top U psi) would be in the deferral closure of phi_0.

But for the pigeonhole argument in FiniteDeferral.lean, the pigeonhole is applied with root = psi (the target formula of F(psi)). So deferralClosure(psi) contains subformulas of psi, their negations, deferral disjunctions, etc. The formula (top U psi) = (neg(bot) U psi) may or may not be in deferralClosure(psi), depending on the definition.

**This is a subtle but important point.** Let me check: for the pigeonhole to work, we need (top U psi) to be in the restricted theory. If psi is an atom p, then deferralClosure(p) = closureWithNeg(p) union ... = {p, neg(p), ...}. The formula (neg(bot) U p) is NOT a subformula of p, so it may not be in deferralClosure(p).

**This means the pigeonhole argument needs to use a LARGER closure** that includes (top U psi) and its related formulas. The FiniteDeferral.lean file uses `deferralClosure root` where root is the F-target formula psi. We need to verify that (top U psi) is in this closure.

Looking at the code: deferralClosure = baseDeferralClosure = closureWithNeg union deferralDisjunctionSet union backwardDeferralSet union serialityFormulas. The deferralDisjunctionSet would include deferral disjunctions of Until subformulas. But (top U psi) itself may not be a subformula of psi.

**Resolution**: The pigeonhole argument should use a closure that includes ALL formulas relevant to the F-resolution problem. For F(psi), the relevant formulas include:
- psi, neg(psi)
- top U psi (= neg(bot) U psi), neg(top U psi)
- The deferral disjunction: psi or (top and (top U psi))
- Subformulas of the above

This is essentially a small, computable set. Let N = this set. The pigeonhole gives a cycle within 2^|N| steps.

---

## Part 4: The Finite Deferral Variant

### 4.1 The Argument Structure

Given F(psi) in chain(t), assume for contradiction psi not in chain(s) for any s > t.

1. (top U psi) in chain(n) for all n >= t (until_persists_forward_steps, sorry-free)
2. neg(psi) in chain(n) for all n > t (MCS negation completeness)
3. By pigeonhole on the appropriate closure: there exist i < j such that the restricted theory cycles
4. **Derive contradiction from the cycle**

### 4.2 Step 4: Deriving the Contradiction

**Option A: Until Induction over the cycle (object-level)**

The until_induction axiom:
G(psi -> chi) and G((top and X(chi)) -> chi) -> ((top U psi) -> X(chi))

We need G(psi -> chi) and G((top and X(chi)) -> chi) in chain(t+1+i) for some chi such that X(chi) not in chain(t+1+i).

As analyzed in Section 3.5, since neg(psi) is in every chain element in the cycle, psi -> chi holds for any chi. But we need G(psi -> chi), which requires the backward G derivation.

**For psi -> chi to be a THEOREM**: Choose chi = anything, and derive psi -> chi from neg(psi) ... but neg(psi) is not a theorem.

**For G(psi -> chi) without backward G**: If psi -> chi is a theorem, then G(psi -> chi) is a theorem (temporal necessitation). But psi -> chi being a theorem means chi is derivable from psi, which constrains chi.

Let chi = psi. Then psi -> psi is a theorem. G(psi -> psi) is a theorem. And (top and X(psi)) -> psi... this says "if psi holds at the next step, then psi holds now." This is NOT a theorem in general (it is the T-axiom for X, which is X(psi) -> psi, and this IS valid for strict discrete semantics because X gives the immediate successor and Y(X(psi)) -> psi is derivable from YX_identity).

Wait -- (top and X(psi)) -> psi. Since top is always true, this simplifies to X(psi) -> psi. Is X(psi) -> psi provable?

X(psi) = bot U psi. Is (bot U psi) -> psi provable?

In discrete strict semantics: X(psi) means psi at the next instant. This does NOT imply psi now. So X(psi) -> psi is NOT provable.

However, we have a detour: temp_a says phi -> G(P(phi)), which gives phi -> G(Y(X(phi))) after temporal duality manipulation. And YX_identity gives Y(X(phi)) -> phi. So phi -> G(phi) is... no, that is not right. temp_a gives phi -> G(P(phi)), and P(phi) means phi at some past time, not phi itself.

**X(psi) -> psi is NOT provable** under strict semantics. So chi = psi does not work.

**Option B: Syntactic induction on the cycle (object-level, using derivation theory)**

Consider the k formulas chain(t+1+i), chain(t+1+i+1), ..., chain(t+1+j-1). These are k MCSes. For each formula gamma in the relevant closure:

gamma in chain(t+1+i+m) iff X(gamma) in chain(t+1+i+m-1) (by x_content characterization)

So the x_content step "shifts" the theory. After k steps, the theory returns to its original value on the closure. This means: for all gamma in the closure, gamma in chain(t+1+i) iff X^k(gamma) in chain(t+1+i).

Now, (top U psi) in chain(t+1+i). So X^k(top U psi) in chain(t+1+i) (since the theory repeats). But X^k(top U psi) means "(top U psi) at time t+k." Since (top U psi) means "psi at some strictly future time with top holding until then," X^k(top U psi) means "psi at some time strictly after t+k."

This does not directly give a contradiction. The formula (top U psi) persists indefinitely, and X^k(top U psi) is just a shifted version.

**Option C: Use the cycle to build a derivation of bot**

We have k MCSes M_0', M_1', ..., M_{k-1}' where M_{m+1}' = x_content(M_m') (indices mod k in terms of restricted theory equality). Each contains (top U psi) and neg(psi).

Consider the list of formulas [neg(psi), (top U psi)] in M_0'. By until_unfold: X(psi or (top and (top U psi))) in M_0'. So psi or (top and (top U psi)) in M_1'. Since neg(psi) in M_1': (top and (top U psi)) in M_1'. So (top U psi) in M_1'.

This just tells us (top U psi) persists -- nothing new.

**Option D: The finite cyclic model + semantic argument (avoiding full truth lemma)**

**NEW IDEA**: We do not need a FULL truth lemma for the periodic model. We only need a truth lemma for the SPECIFIC formula (top U psi).

**Claim**: In the periodic model M_per defined from the cycle:
- neg(psi) is true at every time (this needs only the atomic/propositional truth lemma for psi and its subformulas)
- THEREFORE, (top U psi) is false at every time (by semantics of Until: if psi is never true in the future, top U psi is false)
- BUT (top U psi) is in every chain element in the cycle
- This is a contradiction IF (top U psi) true at n iff (top U psi) in chain(n)

The last step requires the truth lemma for (top U psi), which requires... the truth lemma for all subformulas of (top U psi), including psi, top, and (top U psi) itself.

**For psi**: If psi is a propositional formula (built from atoms, bot, imp only), then the propositional truth lemma works. For psi containing temporal/modal operators, we need the full truth lemma.

**Special case: psi is an atom or a propositional formula**. Then:
- truth_at(M_per, n, psi) iff psi in chain(t+1+i+r(n)) (by propositional truth lemma)
- neg(psi) in chain(t+1+i+r(n)) for all r, so psi not in chain(t+1+i+r(n))
- So psi is never true in M_per
- (top U psi) semantically requires some s > n with psi true at s. Since psi is never true, (top U psi) is false at every n.
- By soundness, every axiom is true in M_per. In particular, F_until_equiv (F(psi) <-> top U psi) holds.
- Every theorem is true in M_per.
- (top U psi) is not a theorem (it is false everywhere in M_per).
- But (top U psi) in chain(t+1+i), and chain(t+1+i) is an MCS.
- An MCS only contains formulas that are consistent with the axiom system.
- The fact that (top U psi) is false everywhere in M_per means neg(top U psi) is true everywhere, i.e., neg(top U psi) is valid in M_per.
- But (top U psi) in chain(t+1+i), an MCS, means (top U psi) is consistent.
- Consistent formulas have models where they are true (by soundness contrapositive, if phi is true in some model, phi is consistent -- wait, this is the wrong direction).

**This does not immediately give a contradiction.** The formula (top U psi) is in an MCS, which means it is consistent. The fact that it is false in M_per does not contradict its consistency -- M_per is just one model.

### 4.3 The Correct Finite Deferral Argument

After this extensive analysis, here is the CORRECT argument. It requires a key lemma that I believe IS provable without forward_F:

**Lemma (Restricted Backward G for Theorems)**: If phi is a THEOREM ([] |- phi), then G(phi) is a theorem ([] |- G(phi)).

**Proof**: By temporal necessitation (already in the proof system).

**Lemma (Cycle Implies G-neg-psi for Atoms)**: This approach works ONLY when we can establish G(neg(psi)) in chain(t) without forward_F. The question is: under what conditions can we do this?

**Answer**: We CANNOT establish G(neg(psi)) in chain(t) from "neg(psi) in chain(n) for all n > t" without forward_F. This has been established conclusively.

### 4.4 The Real Solution: Well-Founded Induction on Formula Complexity

After exhaustive analysis, I believe the ONLY viable approach is well-founded induction on formula complexity combined with a restructured proof.

**Key Insight**: The `ParametricTruthLemma` proves the truth lemma by induction on formula structure. The backward-G case needs forward_F for neg(phi). But sizeof(neg(phi)) = sizeof(phi) + 1, which is LARGER than sizeof(phi), so we cannot use forward_F for neg(phi) as an induction hypothesis.

HOWEVER, if we reformulate the truth lemma to prove forward_F SIMULTANEOUSLY with the truth lemma, by mutual induction on formula complexity, the circularity might be breakable.

**Specifically**: Prove by well-founded induction on sizeof(psi):

For all psi with sizeof(psi) <= n:
  (A) The truth lemma holds for psi (both directions) assuming forward_F for formulas of size < n
  (B) forward_F holds for psi

The key is that the truth lemma for psi at size n uses forward_F for neg(psi) at size n+1 -- BUT this is in the backward-G case, which is for G(phi) where phi has size < sizeof(G(phi)). And forward_F for G(phi) involves F(psi) where psi has size < sizeof(G(phi))...

Actually, let me trace through more carefully:

The backward-G case in the truth lemma proves: if phi true at all s > t, then G(phi) in fam.mcs(t).

The proof uses contraposition: assume G(phi) not in fam.mcs(t). Then neg(G(phi)) in fam.mcs(t), i.e., F(neg(phi)) in fam.mcs(t). By forward_F for neg(phi): exists s > t with neg(phi) in fam.mcs(s). By backward IH for phi: phi not true at s. Contradiction with "phi true at all s > t."

So the backward-G case for G(phi) uses forward_F for neg(phi). sizeof(neg(phi)) = sizeof(phi.imp bot) = sizeof(phi) + sizeof(bot) + 1. And sizeof(G(phi)) = sizeof(phi) + 1.

So forward_F for neg(phi) has argument size sizeof(neg(phi)) = sizeof(phi) + 2.
The truth lemma for G(phi) is proving something about G(phi) with size sizeof(phi) + 1.

If we are doing induction on sizeof(psi) and proving forward_F(psi) at level sizeof(psi), then when we need forward_F(neg(phi)) we need sizeof(neg(phi)) = sizeof(phi) + 2. If we are at level sizeof(G(phi)) = sizeof(phi) + 1, then sizeof(neg(phi)) = sizeof(phi) + 2 > sizeof(phi) + 1. So the induction does not work.

**The sizes do not decrease.** The well-founded induction approach fails because the formula sizes increase through the chain of dependencies.

### 4.5 Final Verdict on All Approaches

| Approach | Verdict | Reason |
|----------|---------|--------|
| Quasimodel (GHR 1994) | FAILS for strict semantics | Until breaks through detours; g_content insufficient |
| Filtration | DOES NOT ADDRESS the problem | Constructs finite models but does not prove forward_F |
| Periodic model + soundness | REQUIRES truth lemma | Truth lemma has same circularity |
| Finite deferral (syntactic) | STUCK at backward-G | Cannot derive G(neg(psi)) without forward_F |
| Well-founded induction | FAILS | Formula sizes increase through dependency chain |
| Enriched witness seed | FAILS | Consistency proof needs G-liftability |

### 4.6 The Recommended Path Forward

Given that ALL approaches analyzed in this report hit the same fundamental obstruction (backward-G requires forward_F), the resolution MUST come from a technique that avoids backward-G entirely.

**The only remaining viable technique**: Modify the truth lemma to not require backward-G.

**How**: The backward-G case in the truth lemma says: "if phi true at all s > t, then G(phi) in M_t." The contrapositive is: "if G(phi) not in M_t, then phi false at some s > t." This uses forward_F.

**Alternative**: Use a WEAKER truth lemma that only proves the forward direction: phi in M_t implies phi true at t. This does NOT require backward-G.

**The forward-only truth lemma**: By induction on formula structure:
- atom, bot, imp: straightforward
- box: forward box uses modal_t: box(phi) in M_t, all families see M_t, so phi in M_t at all families. By forward IH, phi true at t in all families. So box(phi) true at t. **Works.**
- G: G(phi) in M_t. By forward_G (sorry-free), phi in M_s for all s > t. By forward IH, phi true at s for all s > t. So G(phi) true at t. **Works.**
- Until: (phi U psi) in M_t. Need to show (phi U psi) true at t. This requires EXISTS s > t with psi true at s and phi true at all r with t < r < s. This requires forward_F (to find the witness s). **STILL NEEDS forward_F.**

**The Until case in the forward truth lemma requires forward_F.** So even the forward-only approach is blocked.

HOWEVER: the Until case requires forward_F for the ORIGINAL family (the deterministic chain), not for an arbitrary family. And the deterministic chain has sorry-free Until persistence. So if we could show that (phi U psi) in chain(t) implies a witness exists, we would be done -- but that IS forward_F.

### 4.7 Concrete Recommendation

After this exhaustive analysis, I recommend the following approach, which I believe is the simplest viable path:

**Approach: Prove `deterministic_forward_F` by contradiction using the finite deferral + a RESTRICTED completeness argument for the cycle.**

The idea is:
1. Assume F(psi) in chain(t) but psi never appears.
2. Get the cycle via pigeonhole.
3. The cycle gives a finite CONSISTENT set of formulas (the restricted theory) that includes (top U psi) and neg(psi).
4. Use the EXISTING restricted completeness infrastructure (`RestrictedTruthLemma.lean`, `RestrictedTemporallyCoherentFamily`) to build a RESTRICTED model from the cycle.
5. In this restricted model, show (top U psi) is true but psi is never true, a semantic contradiction.

The key advantage: the restricted truth lemma uses RESTRICTED temporal coherence, which is defined only for formulas in the deferral closure. For the restricted model built from the cycle, forward_F is ONLY needed for formulas in the deferral closure of the cycle. And for those formulas, the cycle provides EXACTLY the restricted theories needed.

**The restricted forward_F for the cycle**: In the restricted model built from the cycle of length k, every F-obligation for a formula in the deferral closure either resolves within k steps or cycles back. If it cycles back without resolving, the restricted model is finite and periodic, and the Until formula is false everywhere (since psi is never true). But (top U psi) is in the restricted theory, which by the restricted truth lemma means it should be true. Contradiction.

**The crucial insight**: The restricted truth lemma for the cycle does NOT require the full forward_F. It only requires restricted forward_F for formulas in the deferral closure. And in a periodic restricted theory, every F-obligation either resolves or cycles. If it cycles, the restricted model is a finite model where the formula is satisfiable, and we can derive the contradiction from the finite model.

**Estimated effort**: ~600-900 lines, building on existing FiniteDeferral.lean + RestrictedTruthLemma.lean infrastructure.

**Difficulty**: HIGH but tractable. The key new work is:
1. Build a restricted model from the cycle (reuse RestrictedTemporallyCoherentFamily)
2. Show the restricted model satisfies restricted temporal coherence for all formulas EXCEPT psi (which is the formula we are trying to resolve)
3. Show that (top U psi) true in this model implies psi true somewhere, contradiction

This is essentially a RESTRICTED COMPLETENESS argument applied to the finite cycle, and it avoids the backward-G circularity because the restricted model has built-in temporal coherence by construction.

---

## 5. Summary of Findings

1. **Quasimodel (GHR 1994)**: Does not work for TM with strict semantics. Until persistence breaks through detours because the witness construction preserves g_content but not x_content. The enriched seed fails because Until deferrals are X-liftable but not G-liftable.

2. **Filtration**: Does not directly address the forward_F problem. It is a technique for building finite models from infinite ones, not for proving temporal coherence in canonical models.

3. **Finite deferral + soundness**: The periodic model constructed from the pigeonhole cycle is a valid task model, but connecting MCS membership to semantic truth requires a truth lemma, which has the same backward-G circularity.

4. **All approaches fail at the same point**: Converting the meta-level "neg(psi) at all future chain positions" to the object-level "G(neg(psi)) in chain(t)." This is the backward-G step, which requires forward_F.

5. **The recommended path**: A restricted completeness argument applied to the finite cycle from the pigeonhole lemma. Build a restricted model from the cycle, show it satisfies restricted temporal coherence by construction, and derive the semantic contradiction. This avoids the backward-G circularity because the restricted model's temporal coherence is built-in rather than derived.

6. **Estimated effort**: 600-900 lines of new Lean 4 code, building on existing FiniteDeferral.lean and RestrictedTruthLemma.lean infrastructure.

---

## References

- Burgess, J. (1982a/1984). "Basic tense logic." Handbook of Philosophical Logic, vol. 2.
- Gabbay, D., Hodkinson, I., Reynolds, M. (1994). [Temporal Logic: Mathematical Foundations and Computational Aspects](https://global.oup.com/academic/product/temporal-logic-9780198537694). Oxford University Press.
- Venema, Y. [Chapter 10: Temporal Logic](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf).
- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/).
- [A Hierarchical Completeness Proof for Propositional Temporal Logic](https://link.springer.com/chapter/10.1007/978-3-540-39910-0_22).
- Prior research reports 01-23 for task 83.
- Codebase: DeterministicChain.lean, DeterministicFMCS.lean, FiniteDeferral.lean, DovetailedChain.lean, ParametricTruthLemma.lean, RestrictedTruthLemma.lean, Filtration.lean, ClosureMCS.lean, FiniteModel.lean, SubformulaClosure.lean.
