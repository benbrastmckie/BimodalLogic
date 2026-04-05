# Teammate B Findings: Mathematical Approach Assessment

**Task**: 83 - Close Restricted Coherence Sorries
**Date**: 2026-04-04
**Focus**: What will actually close the remaining gaps?

---

## Key Findings

1. **The sorry inventory is remarkably concentrated.** The entire completeness-over-Int pathway depends on exactly 6 sorries in `DeterministicFMCS.lean`: `deterministic_forward_F` (line 60), `deterministic_backward_P` (line 66), and 4 until/since coherence sub-goals in `usc` (lines 193-199). Everything else in the wiring (FMCS construction, BFMCS bundle, modal coherence, parametric representation) is sorry-free.

2. **Forward_F is genuinely unprovable for the bare deterministic chain.** Report 17 states this correctly. An MCS can consistently contain `{F(psi), X(neg(psi)), X(F(psi))}`, which the deterministic chain will propagate forever without resolving psi. The chain `chain(n+1) = x_content(chain(n))` is fully determined by M_0, and there exist M_0 for which F(psi) defers indefinitely.

3. **The until/since coherence sorries decompose into two independent sub-problems**: forward direction (membership implies witness) and backward direction (witness implies membership). These have different difficulty levels.

4. **The backward direction of until/since coherence is the easier part** and may be closable with current infrastructure using the until_intro axiom, independent of forward_F.

5. **For D = Int, the guard conditions in until/since coherence are vacuously true** for consecutive integers. This simplifies both directions significantly.

---

## Fundamental Mathematical Obstacle Analysis

### The Core Circularity

The obstacle is a dependency cycle between three proof obligations:

```
forward_F(psi)             : F(psi) in chain(t) -> exists s > t, psi in chain(s)
backward_G(psi)            : truth(G(psi), t) -> G(psi) in chain(t)
truth_lemma_backward(G)    : uses contrapositive: not-G(psi) in chain(t) -> F(neg(psi)) in chain(t) -> exists s, neg(psi) in chain(s) [= forward_F]
```

The parametric truth lemma sidesteps this by taking `h_tc` (temporal coherence, which includes forward_F) as a parameter. But `h_tc` must be proved for the concrete chain, and this is where the problem resurfaces.

### Why Forward_F is Unprovable for Deterministic Chains

**Theorem (Impossibility)**: There exist MCS M_0 such that the deterministic chain from M_0 never resolves a specific F-obligation.

**Proof sketch**: Consider the set of formulas `S = {F(A), neg(A), X(neg(A)), X(F(A)), X(X(neg(A))), X(X(F(A))), ...}`. This set is finitely consistent: for any finite subset, a model with A true at time N (for large enough N) satisfies it. By compactness, S extends to an MCS. The deterministic chain from this MCS has `neg(A)` at every position (since `X^k(neg(A))` is in M_0 for all k), so A never appears.

**Key insight**: The deterministic chain's successor is fully determined -- there is no freedom to "choose" a successor that resolves F-obligations. The chain faithfully propagates whatever M_0 dictates, and M_0 can dictate eternal deferral.

### What Textbook Proofs Do Differently

Published completeness proofs for temporal logic with Until (Burgess 1984, Gabbay-Hodkinson-Reynolds 1994, Reynolds 2003, Goldblatt 1992) resolve this by **constructing the chain to satisfy F-obligations**:

1. **Step-by-step construction**: At each step n, examine all unresolved F-obligations. Choose the next MCS to resolve one of them (round-robin or priority-based).

2. **Lindenbaum extension with targeted seed**: The successor is a Lindenbaum extension of `g_content(M_n) union {psi_target}`, where psi_target is the formula being resolved.

3. **Until persistence is NOT directly maintained**: These proofs typically don't use x_content. Instead, they prove Until/Since as consequences of the truth lemma + F-resolution, not as chain-level properties.

The critical difference: textbook proofs prove forward_until by:
- `(phi U psi) in chain(t)` implies `F(psi) in chain(t)` (derivable)
- `F(psi) in chain(t)` implies `psi in chain(s)` for some s > t (by the F-resolution construction)
- The guard condition `phi at all r in (t,s)` follows from the truth lemma applied to the subformula phi at intermediate positions (induction hypothesis)

This approach requires forward_F to be built into the chain, not proved after the fact.

---

## Until/Since Coherence Assessment

### The Four Goals in `usc`

The `until_since_coherent` definition requires, for each family `fam`:

1. **forward_until**: `(phi U psi) in fam.mcs t -> exists s > t, psi in fam.mcs s AND forall r in (t,s), phi in fam.mcs r`
2. **backward_until**: `(exists s > t, psi in fam.mcs s AND forall r in (t,s), phi in fam.mcs r) -> (phi U psi) in fam.mcs t`
3. **forward_since**: Symmetric to forward_until for the past direction
4. **backward_since**: Symmetric to backward_until for the past direction

### Forward Until/Since (Goals 1, 3): BLOCKED by forward_F

Forward_until reduces to forward_F: `(phi U psi) -> F(psi)` is derivable via `until_implies_some_future`. The guard condition is vacuous for D = Int (no integers strictly between n and n+1 when s = n+1). So forward_until is equivalent to forward_F restricted to formulas of the form psi where `(phi U psi)` appears.

**Status**: Blocked by the same fundamental obstacle. Cannot be proved without either (a) a different chain construction that resolves F, or (b) an entirely different proof architecture.

### Backward Until/Since (Goals 2, 4): POTENTIALLY CLOSABLE

Backward_until says: given a witness s > t with psi in chain(s) and phi at all intermediate positions, prove `(phi U psi) in chain(t)`.

For D = Int, this is: given s > t with psi in chain(s) and phi in chain(r) for all t < r < s, prove `(phi U psi) in chain(t)`.

**Proof approach using until_intro**:

The axiom `until_intro` gives: `X(psi v (phi AND (phi U psi))) -> (phi U psi)`.

By backward induction from s to t+1:

- **Base (s-1)**: We have `psi in chain(s) = x_content(chain(s-1))`. So `X(psi) in chain(s-1)`. Since `psi -> psi v (phi AND (phi U psi))` is derivable, `X(psi v ...) in chain(s-1)`. By until_intro: `(phi U psi) in chain(s-1)`.

- **Step (k+1 to k, where t < k < s-1)**: We have `(phi U psi) in chain(k+1)` (IH) and `phi in chain(k+1)` (guard). So `phi AND (phi U psi) in chain(k+1)`. Therefore `psi v (phi AND (phi U psi)) in chain(k+1)` (right disjunct holds). Since `chain(k+1) = x_content(chain(k))`, we have `X(psi v ...) in chain(k)`. By until_intro: `(phi U psi) in chain(k)`.

- **Terminal (t+1 to t)**: We have `(phi U psi) in chain(t+1)` from the step above. Now there are two cases:
  - If s = t+1: then psi in chain(t+1), so `psi v (phi AND (phi U psi)) in chain(t+1)`. Since chain(t+1) = x_content(chain(t)), `X(psi v ...) in chain(t)`. By until_intro: `(phi U psi) in chain(t)`. **DONE.**
  - If s > t+1: then phi in chain(t+1) (guard) and (phi U psi) in chain(t+1) (IH). So `phi AND (phi U psi) in chain(t+1)`, hence `psi v (phi AND (phi U psi)) in chain(t+1)`. Since chain(t+1) = x_content(chain(t)), `X(psi v ...) in chain(t)`. By until_intro: `(phi U psi) in chain(t)`. **DONE.**

**This proof works!** The x_content linkage of the deterministic chain is exactly what makes it go through. The key: `alpha in chain(k+1) = x_content(chain(k))` implies `X(alpha) in chain(k)`, which is the bridge needed for until_intro.

**Confidence**: HIGH (90%). The mathematical argument is clean. The only risk is in the Lean formalization details (Int arithmetic, case splits on Nat vs negSucc, etc.).

**Backward_since** is symmetric, using `since_intro` and y_content linkage.

### Revised Sorry Count After Closing Backward Until/Since

If backward_until and backward_since are closed, the sorry inventory becomes:
- `deterministic_forward_F` (line 60)
- `deterministic_backward_P` (line 66)
- Forward_until in `usc` (line 193) -- still depends on forward_F
- Forward_since in `usc` (line 197) -- still depends on backward_P

This is still 4 sorries, but the backward coherence is halved.

---

## Alternative Mathematical Approaches

### Approach A: F-Step Deferral (from Report 17)

Instead of proving forward_F outright, use the F-step property that IS provable for the deterministic chain:

```
F(psi) in chain(n) -> psi in chain(n+1) OR F(psi) in chain(n+1)
```

This follows from `F(psi) -> X(psi v F(psi))` which is derivable from `F_until_equiv` + `until_unfold`. The disjunction lands in chain(n+1) via x_content.

**The idea**: Avoid needing forward_F as a chain property entirely. Instead, restructure the truth lemma to use the F-step property combined with an external well-foundedness argument.

**Problem**: The parametric truth lemma requires `h_tc : B.temporally_coherent` which IS forward_F for all formulas. Restructuring this would mean abandoning the parametric truth lemma and writing a custom one.

**Feasibility**: MEDIUM. Would require ~200-300 lines of new truth lemma code. The mathematical content is sound but the engineering effort is substantial.

### Approach B: Filtration / Finite Model Property

Bypass the chain construction entirely. Prove completeness via the finite model property: every satisfiable formula has a finite model. Then completeness follows from soundness + FMP.

**Status**: The codebase already has some FMP infrastructure. However, FMP for the full language with Until/Since over Int is non-trivial. Standard FMP proofs for temporal logic use filtration through subformula closure, which gives models over finite linear orders, not Z.

**Feasibility**: LOW for the full logic. The Int-indexed completeness specifically requires infinite models (G/H quantify over all future/past times).

### Approach C: Hybrid Chain with Targeted F-Resolution

Build a chain that is "mostly deterministic" (x_content) but deviates at selected steps to resolve F-obligations. The deviation uses Lindenbaum extension of a targeted seed.

**Key issue** (identified in Report 15, Section 5.1): The seed `x_content(M) union {psi}` can be inconsistent when `X(neg(psi)) in M`. So we cannot always force psi into the next step.

**Resolution attempt**: Use a round-robin schedule. At step n, if F(psi_k) is pending (where k = n mod N), try to extend x_content with psi_k. If the seed is inconsistent (i.e., neg(psi_k) in x_content), skip and defer. Since the formula closure is finite, eventually the x_content will not force neg(psi_k), and the resolution succeeds.

**Problem**: The "eventually consistent" claim is exactly the thing we cannot prove. It is equivalent to forward_F.

**Feasibility**: LOW. This approach is circular.

### Approach D: Non-Standard Truth Lemma (F-Step Based)

Write a truth lemma variant that takes `h_fstep` instead of `h_tc`:

```
h_fstep : forall fam in B.families, forall t psi,
  F(psi) in fam.mcs t -> psi in fam.mcs (t+1) OR F(psi) in fam.mcs (t+1)
```

The forward G/H cases use the existing sorry-free forward_G/backward_H from the deterministic chain. The backward G/H cases use contrapositive + the F-step property instead of forward_F:

**Backward G**: `truth(G(psi), t) -> G(psi) in chain(t)`.

By contrapositive: assume `G(psi) not in chain(t)`. Then `neg(G(psi)) = F(neg(psi)) in chain(t)`. By F-step: either `neg(psi) in chain(t+1)` or `F(neg(psi)) in chain(t+1)`. If `neg(psi) in chain(t+1)`: by IH (backward truth lemma for neg(psi)): `truth(neg(psi), t+1)`, so `not truth(psi, t+1)`, so `not truth(G(psi), t)`. DONE.

If `F(neg(psi)) in chain(t+1)`: apply F-step again. Either `neg(psi) in chain(t+2)` or `F(neg(psi)) in chain(t+2)`. The F-obligation propagates forward...

**The problem**: This gives an INFINITE sequence of F-steps. We never reach a contradiction unless psi actually fails to hold at some future time. But we're trying to prove the CONTRAPOSITIVE -- we assumed G(psi) not in chain(t) and need to show not-truth(G(psi), t). The infinite F-step chain gives us F(neg(psi)) forever, but doesn't give us an actual witness where neg(psi) holds.

**Unless** we can extract a witness from the persistent F-obligation. In the semantic model being constructed, `F(neg(psi)) in chain(n)` for all n > t would mean `truth(F(neg(psi)), n)` for all n > t (by the forward truth lemma direction). But `truth(F(neg(psi)), n)` means there exists some m > n with `truth(neg(psi), m)`. So neg(psi) is true at infinitely many times. In particular, there exists s > t with not-truth(psi, s), hence not-truth(G(psi), t).

**Wait -- this works if we have the forward truth lemma for F(neg(psi))!**

The forward direction for F: `F(neg(psi)) in chain(n) -> truth(F(neg(psi)), n)`. But F(neg(psi)) = neg(G(neg(neg(psi)))) = neg(G(psi)) (modulo double negation in MCS). The forward truth lemma for negation uses backward truth lemma... which is what we're trying to prove.

**Circularity reasserts.** The F-step approach doesn't break the cycle because extracting semantic content from the persistent F requires the truth lemma we're trying to prove.

**Feasibility**: LOW. Same circularity in a different guise.

### Approach E: Prove Forward_F for a Restricted Formula Set

Instead of proving forward_F for ALL formulas, prove it only for formulas in `deferralClosure(root)`. Use `restricted_temporally_coherent` instead of `temporally_coherent`.

**The restricted truth lemma** at `CanonicalConstruction.lean:814` takes `h_tc : B.restricted_temporally_coherent root` -- only needing forward_F for formulas in deferralClosure.

**Why this might work**: deferralClosure(root) is finite. The F-nesting depth within the closure is bounded. If we can show that the deterministic chain eventually resolves F-obligations for formulas of bounded F-depth...

**Problem**: The deterministic chain from a "bad" M_0 can defer F(psi) forever regardless of whether psi is in deferralClosure. The finiteness of deferralClosure doesn't help because the chain's behavior depends on the full MCS, not just the closure.

**Feasibility**: LOW unless combined with a different chain construction.

---

## Published Proof Comparison

### Burgess (1984) -- "Basic Tense Logic"

Burgess proves completeness for Kt (basic tense logic without Until) using canonical frames where the accessibility relation is the successor relation. F-resolution is implicit: the canonical frame has ALL MCS as worlds, so for F(psi) in w, the witness is any world v accessible from w with psi in v. The Lindenbaum argument ensures such v exists.

**Key difference from our setting**: Burgess's worlds are not arranged in a single linear chain. Each world has potentially many accessible successors. The linear chain requirement is what causes our problem.

### Gabbay-Hodkinson-Reynolds (1994) -- Temporal Logic Vol. 1

GHR prove completeness for Until/Since logics using a **quasimodel construction** followed by **unwinding** into a linear model. The quasimodel is a finite graph of "atoms" (maximally consistent sets of subformulas). The unwinding process creates an omega-chain by traversing the graph, resolving F-obligations by revisiting atoms that satisfy the target formula.

**Key technique**: The graph has finitely many nodes (bounded by subformula closure). F-obligations are resolved by fairness: every reachable atom is visited infinitely often in the omega-chain. This guarantees F-resolution because:
1. F(psi) in an atom means psi is satisfied by some reachable atom
2. That atom is visited infinitely often
3. Therefore psi appears at some future position

**Relevance**: This approach sidesteps forward_F entirely by working with finite quasimodels first, then unwinding. The unwinding is constructive and F-resolution is automatic.

**Adaptation to our setting**: Would require building a quasimodel from the subformula closure of root, then unwinding it. This is a significant departure from the current chain-based approach but is mathematically well-established. Estimated effort: 40-60 hours.

### Goldblatt (1992) -- Logics of Time and Computation

Goldblatt uses a direct canonical model construction with the "existence lemma" playing the role of forward_F. The existence lemma states: if `F(psi) in w` then there exists a maximal consistent set `v` with `psi in v` and `g_content(w) subset v`. This is proved by Lindenbaum extension of `g_content(w) union {psi}`.

**Key difference**: Goldblatt doesn't require v to be the NEXT step in a specific chain. v is ANY MCS accessible from w. For a linear model, a separate argument arranges these MCS into a chain.

**Our situation**: We have `canonical_forward_F` (sorry-free) which is exactly Goldblatt's existence lemma. The gap is going from "there exists an accessible MCS with psi" to "there exists a CHAIN POSITION with psi".

### Reynolds (2003) -- Axiomatization of CTL

Reynolds's completeness proof for the full branching time logic uses a tableau-based approach with systematic F-resolution. Not directly applicable to linear time but confirms that F-resolution is universally handled by construction, not after-the-fact proof.

---

## Recommended Path Forward

### Tier 1: Close Backward Until/Since (HIGH confidence, 8-12 hours)

Close the backward_until and backward_since sorries in `usc` using the proof outlined above (backward induction from witness using until_intro/since_intro + x_content/y_content linkage). This halves the sorry count and is mathematically clean.

**Concrete steps**:
1. Prove a lemma: if `(phi U psi) in chain(k+1)` and `psi v (phi AND (phi U psi)) in chain(k+1)`, then `(phi U psi) in chain(k)` (via x_content + until_intro)
2. Prove backward_until by Nat.rec from s-1 down to t
3. Handle the Int case splits (Nat vs negSucc, boundary crossing)
4. Prove backward_since symmetrically

### Tier 2: Restructure to Avoid Forward_F (MEDIUM confidence, 20-30 hours)

The most promising mathematical path is to restructure the completeness proof to not require forward_F as a chain property. Two sub-options:

**Option 2a: Quasimodel approach (GHR-style)**

Build a finite quasimodel from the subformula closure, then unwind into a linear chain that automatically resolves F-obligations. This is the standard approach in the literature.

- Pro: Well-established mathematics, resolves ALL sorries at once
- Con: Major new development, does not reuse existing chain infrastructure
- Effort: 40-60 hours

**Option 2b: Modified chain with F-resolution built in**

Build a chain where at each step, the successor is chosen from a finite set of "candidate MCS" that includes both x_content(current) and F-resolution targets. Use a priority/round-robin schedule to ensure fairness.

The seed is `g_content(M_n) union {psi_target}` (not x_content), with Until persistence proved separately using the truth lemma itself (mutual induction).

- Pro: Reuses existing Lindenbaum and canonical_forward_F infrastructure
- Con: Until persistence must be proved differently (not via x_content)
- Effort: 25-40 hours

**Option 2c: Conditional completeness (pragmatic)**

Accept that forward_F cannot be proved for the deterministic chain. Instead, state completeness conditional on a chain construction that provides forward_F. The current `parametric_algebraic_representation_conditional` already does this -- it takes `construct_bfmcs` as a callback. The sorry is isolated in the callback provider (`construct_bfmcs_callback` in DeterministicFMCS.lean).

Document the remaining sorries as "requires chain with F-resolution property" and focus effort elsewhere.

- Pro: Zero additional effort, clearly documents the gap
- Con: Does not achieve sorry-free completeness

### Tier 3: Investigate Whether the Until Persistence Can Help (LOW confidence, speculative)

The deterministic chain has sorry-free Until persistence: `F(psi) = top U psi` persists via `until_persists_chain`. So `F(psi) in chain(n)` implies either `psi in chain(n+1)` or `F(psi) in chain(n+1)` (with `top in chain(n+1)`, vacuously).

Could we prove that this deferral CANNOT continue forever, using properties of the specific MCS M_0 we start from?

**The answer is no** in general (as shown above), but for the COMPLETENESS APPLICATION, M_0 is specifically constructed as a Lindenbaum extension of `{neg(root)}`. Could properties of this specific M_0 help?

Unlikely. The Lindenbaum extension is arbitrary (depends on the enumeration of formulas), so we cannot assume special properties of M_0 beyond it being an MCS containing neg(root).

---

## Confidence Level

**Overall**: MEDIUM

- Backward until/since closure: HIGH confidence (90%) -- clean mathematical argument, well-suited to existing infrastructure
- Forward_F resolution for deterministic chain: NO PATH -- genuinely unprovable
- Alternative chain construction to resolve forward_F: MEDIUM confidence (60%) -- mathematically sound approaches exist (quasimodel, targeted chain) but require substantial implementation effort
- Complete sorry-free completeness within reasonable effort: LOW confidence (30%) -- the quasimodel approach would work but is 40-60 hours of new development

The most impactful immediate action is closing backward_until/since (Tier 1), which is achievable and demonstrates progress. Forward_F requires a fundamentally different chain construction.
