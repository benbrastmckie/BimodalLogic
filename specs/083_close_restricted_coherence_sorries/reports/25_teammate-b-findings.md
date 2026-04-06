# Teammate B Findings: Restricted Completeness via Pigeonhole Cycle

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-06
**Type**: Research (Teammate B, restricted completeness / pigeonhole focus)
**Artifact**: 25

---

## 1. Executive Summary

This report provides a thorough audit of the existing FiniteDeferral.lean and RestrictedTruthLemma.lean infrastructure, followed by a detailed analysis of the pigeonhole cycle argument for resolving `deterministic_forward_F`. The central question is whether the cycle produced by pigeonhole on restricted theories yields a contradiction purely syntactically.

**Key findings**:

1. **FiniteDeferral.lean is 95% complete**: Steps 1-4 of the deferral argument (F-to-Until conversion, Until persistence, restricted theory definition, pigeonhole) are formalized sorry-free. Only step 5 (cycle contradiction) is sorry.

2. **The cycle contradiction has a genuine gap**: The natural approach (derive G(neg(psi)) from the cycle, then use G_neg_kills_until) requires `temporal_backward_G`, which requires `forward_F` -- the theorem we are trying to prove. This circularity is confirmed by 24 prior reports.

3. **RestrictedTruthLemma.lean does NOT provide the missing piece**: It proves a DRM-to-Lindenbaum-extension equivalence for closure formulas, but does NOT prove semantic truth. Two of its auxiliary lemmas are sorry (G-propagation and H-step for DRM chains), though both are marked "dead code."

4. **The restricted completeness approach via the cycle has a fundamental obstruction**: Building a restricted model from the cycle still requires backward-G in its truth lemma, creating the same circularity.

5. **A novel observation about the cycle**: The cycle gives an omega-periodic sequence of restricted theories where (top U psi) persists and psi is absent. Combined with the until_induction axiom, we CAN derive a contradiction IF we can establish G(psi -> chi) in chain(t+1+i) for a suitable chi. The crux is that psi -> chi is NOT a theorem (merely true in the specific chain), so temporal necessitation does not apply.

---

## 2. Infrastructure Audit

### 2.1 FiniteDeferral.lean -- Detailed Inventory

**File**: `Theories/Bimodal/Metalogic/Algebraic/FiniteDeferral.lean` (383 lines)

| Theorem | Status | Lines | Description |
|---------|--------|-------|-------------|
| `F_to_until_in_mcs` | SORRY-FREE | 44-49 | F(psi) in MCS implies (top U psi) in MCS via F_until_equiv |
| `F_to_until_in_chain` | SORRY-FREE | 52-55 | Lifts F_to_until_in_mcs to deterministic chain |
| `until_persists_chain_general` | SORRY-FREE | 63-80 | If (phi U psi) in chain(n) and psi not in chain(n+1), then phi and (phi U psi) in chain(n+1). Uses until_unfold + x_content characterization. |
| `until_persists_forward_steps` | SORRY-FREE | 83-97 | (top U psi) persists for n steps if psi absent. Induction on n. |
| `restrictedTheory` | DEFN | 112-113 | `(deferralClosure root).filter (fun phi => phi in deterministic_chain M0 n)` |
| `restrictedTheory_subset` | SORRY-FREE | 117-119 | Restricted theory is subset of deferralClosure |
| `restrictedTheory_mem_powerset` | SORRY-FREE | 122-124 | Restricted theory is in powerset |
| `restricted_theory_count` | SORRY-FREE | 127-129 | Number of possible restricted theories = 2^|deferralClosure| |
| `pigeonhole_restricted_theories` | SORRY-FREE | 133-153 | Among bound+1 consecutive positions, two have same restricted theory |
| `G_neg_kills_until` | SORRY-FREE | 164-333 | If G(neg(psi)) in chain(t), then (top U psi) not in chain(t). Uses until_induction with chi=bot. **Long proof (170 lines) but completely sorry-free.** |
| `forward_F_via_deferral` | **SORRY** | 378-381 | The target: F(psi) in chain(t) implies exists s>t with psi in chain(s) |

**Assessment**: The infrastructure is solid and well-engineered. The sorry-free components handle the hardest parts (pigeonhole combinatorics, the G_neg_kills_until derivation with complex Hilbert-style proof). The gap is precisely and only step 5.

### 2.2 SubformulaClosure.lean -- deferralClosure Definition

**File**: `Theories/Bimodal/Syntax/SubformulaClosure.lean`

The `deferralClosure(phi)` is defined as:
```
deferralClosure(phi) = closureWithNeg(phi)
                     U deferralDisjunctionSet(phi)      -- {chi v F(chi) | F(chi) in closureWithNeg}
                     U backwardDeferralSet(phi)          -- {chi v P(chi) | P(chi) in closureWithNeg}
                     U serialityFormulas                 -- F_top, P_top, neg(bot), etc.
```

Key properties (all sorry-free):
- `self_mem_deferralClosure`: phi in deferralClosure(phi)
- `neg_self_mem_deferralClosure`: neg(phi) in deferralClosure(phi)
- `closureWithNeg_subset_deferralClosure`: subformulas and negations are included
- `F_top_mem_deferralClosure`: seriality formulas always present
- `deferral_of_F_in_closure`: F-deferral disjunctions are included

**Critical observation**: `deferralClosure(psi)` includes subformulas of psi, their negations, and deferral disjunctions for F/P-formulas in the closure. It does NOT necessarily include `(top U psi)` unless Until is a subformula of the root. For the forward_F proof where the root is psi (the F-target), we need `(top U psi)` and `neg(top U psi)` to be in the closure.

**Gap identified**: If F(psi) is a subformula of the completeness target phi_0, and the pigeonhole uses deferralClosure(phi_0), then (top U psi) should be included (since F(psi) is equivalent to top U psi, and subformula closure should capture Until subformulas). However, `(neg(bot) U psi)` is syntactically different from `F(psi) = neg(G(neg(psi)))`. The formula `(neg(bot) U psi)` is NOT a subformula of `psi` -- it is a derived equivalent. This means `restrictedTheory` as currently defined may NOT track `(top U psi)`.

**Resolution**: The pigeonhole in FiniteDeferral.lean uses `deferralClosure root` where root is the parameter of `forward_F_via_deferral`. For the argument to work, the closure must include `(top U psi)`. This may require either:
(a) Using a closure that explicitly includes `(top U psi)` and related formulas, or
(b) Adjusting the root parameter to be a formula whose subformula closure includes `(top U psi)`.

### 2.3 RestrictedTruthLemma.lean -- Detailed Inventory

**File**: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`

| Theorem | Status | Description |
|---------|--------|-------------|
| `restricted_chain_G_step` | SORRY-FREE | G(psi) in chain(n) implies psi in chain(n+1) via Succ g_persistence |
| `restricted_chain_G_propagates` | **SORRY** (dead code) | G(psi) propagation through chain. Cannot be proven for DRM: requires G(G(psi)) in deferralClosure. |
| `restricted_chain_H_step` | **SORRY** (dead code) | H(psi) in chain(n) implies psi in chain(n-1). Cannot be proven for DRM without full MCS. |
| `drm_to_mcs` | DEFN | Convert DRM to MCS via Lindenbaum |
| `restricted_chain_ext` | DEFN | Lindenbaum extension of restricted chain at position n |
| `restricted_chain_ext_is_mcs` | SORRY-FREE | Extension is MCS |
| `restricted_chain_subset_extended` | SORRY-FREE | DRM membership implies extension membership |
| `extended_chain_closure_subset` | SORRY-FREE | For closure formulas, extension membership implies DRM membership |
| `restricted_truth_lemma` | SORRY-FREE | Bidirectional: psi in DRM chain iff psi in extension, for psi in subformulaClosure(phi) |
| `restricted_truth_at_seed` | SORRY-FREE | Corollary for target formula at time 0 |

**Assessment**: The RestrictedTruthLemma proves an equivalence between DRM membership and Lindenbaum extension membership for closure formulas. This is NOT a semantic truth lemma -- it does not connect membership to truth in a model. The two sorry lemmas (G-propagation and H-step) are explicitly marked dead code: they are not used by any completeness path.

**What RestrictedTruthLemma does NOT provide**:
- No semantic model construction from the restricted chain
- No temporal coherence for the extended chain (independent Lindenbaum extensions lose successor structure)
- No forward_F or backward_P for the restricted chain

### 2.4 DeterministicChain.lean -- Key Sorry-Free Results

All sorry-free:
- `deterministic_chain_mcs`: every chain element is MCS
- `x_mem_chain_general`: phi in chain(n+1) iff X(phi) in chain(n) (for all integers)
- `y_mem_chain_general`: phi in chain(n-1) iff Y(phi) in chain(n)
- `until_persists_chain`: Until persistence (forward, Nat)
- `since_persists_chain`: Since persistence (backward, Nat)
- `forward_G_int`: G-coherence for all integer positions
- `backward_H_int`: H-coherence for all integer positions
- `backward_until_chain`: backward Until introduction via induction
- `backward_since_chain`: backward Since introduction via induction

### 2.5 DeterministicFMCS.lean -- Sorry Map

| Theorem | Status |
|---------|--------|
| `deterministic_forward_F` | **SORRY** (leaf) |
| `deterministic_backward_P` | **SORRY** (leaf) |
| `tc` (temporal coherence) | Depends on forward_F, backward_P |
| `usc` forward Until case | **SORRY** (depends on forward_F) |
| `usc` forward Since case | **SORRY** (depends on backward_P) |
| `usc` backward Until case | SORRY-FREE (uses backward_until_chain) |
| `usc` backward Since case | SORRY-FREE (uses backward_since_chain) |

### 2.6 TemporalCoherence.lean -- Restricted Infrastructure

Key definitions and results:
- `BFMCS.restricted_temporally_coherent`: forward_F and backward_P ONLY for formulas in deferralClosure(root)
- `restricted_temporal_backward_G_strict`: backward G using restricted forward_F (only needs forward_F for neg(phi) in deferralClosure)
- `temporal_backward_G_with_fwd_F`: backward G taking forward_F as explicit hypothesis

**Assessment**: The restricted coherence definition is well-designed. It quantifies forward_F/backward_P only over deferralClosure(root), which is finite. The restricted backward G theorems are sorry-free given their hypotheses. The question is whether we can PROVE restricted temporal coherence for the deterministic chain.

---

## 3. The Pigeonhole Argument in Detail

### 3.1 Setup

Assume `F(psi) in chain(t)` but `psi not in chain(s)` for all `s > t`.

Step 1: `(top U psi) in chain(t)` by `F_to_until_in_chain` (sorry-free).

Step 2: For all `n >= t`, `(top U psi) in chain(n)` by `until_persists_forward_steps` (sorry-free).

Step 3: For all `n > t`, `neg(psi) in chain(n)` by MCS negation completeness (sorry-free).

Step 4: Let `B = 2^|deferralClosure(root)|`. By `pigeonhole_restricted_theories` (sorry-free), there exist `i < j` with `j <= B` such that `restrictedTheory M0 root (t+i) = restrictedTheory M0 root (t+j)`.

### 3.2 What the Cycle Gives Us

Let `k = j - i`. The restricted theory repeats with period k starting from position `t+i`:

For all `gamma in deferralClosure(root)`:
```
gamma in chain(t+i) iff gamma in chain(t+i+k)
```

Since `chain(t+i+k) = x_content^k(chain(t+i))`, this means applying x_content k times returns the same restricted theory.

Throughout positions `[t, t+j]`:
- `(top U psi) in chain(m)` for all m in this range (if `(top U psi) in deferralClosure(root)`)
- `neg(psi) in chain(m)` for all m > t in this range

### 3.3 The Closure Containment Issue

For the pigeonhole argument to track the relevant formulas, we need `(top U psi)`, `neg(psi)`, and related formulas to be in `deferralClosure(root)`.

`(top U psi) = (neg(bot) U psi)` is an Until formula. It is NOT a subformula of psi in general. For example, if psi = atom(p), then:
- `subformulaClosure(atom(p))` = {atom(p)}
- `closureWithNeg(atom(p))` = {atom(p), neg(atom(p))}
- `deferralClosure(atom(p))` = closureWithNeg U deferralDisjunctions U serialityFormulas

The formula `neg(bot) U atom(p)` is NOT in any of these sets.

**This is a genuine issue with the current FiniteDeferral.lean implementation.** The pigeonhole is applied with `deferralClosure root` but the proof never specifies what `root` should be. For the argument to work, `root` must be chosen so that `(top U psi)` and its relevant formulas are in the closure.

**Potential fix**: Define a specialized closure for the forward_F argument:
```
forwardFClosure(psi) = deferralClosure(psi)
                     U {neg(bot) U psi, neg(neg(bot) U psi)}
                     U {psi or (neg(bot) and (neg(bot) U psi))}
                     U {neg(bot) and (neg(bot) U psi)}
                     U {neg(bot)}
```

This is still finite (adds O(1) formulas), so the pigeonhole bound remains 2^|forwardFClosure(psi)|.

Alternatively, use `root = (top U psi)` as the pigeonhole parameter. Then `(top U psi) in subformulaClosure(top U psi)` and its subformulas (including psi, neg(bot)) are included.

### 3.4 Can We Derive a Contradiction from the Cycle?

Assuming the closure issue is resolved, we have positions `t+i < t+j` with:
- The same restricted theory on `forwardFClosure(psi)`
- `(top U psi)` in both
- `neg(psi)` in both (and in all positions in between)

**Approach 1: until_induction with G(neg(psi))**

The `G_neg_kills_until` theorem (sorry-free) shows: if `G(neg(psi)) in chain(t)`, then `(top U psi) not in chain(t)`. If we could establish `G(neg(psi)) in chain(t+i)`, we would have a contradiction.

To derive `G(neg(psi)) in chain(t+i)` from "neg(psi) in chain(m) for all m > t", we need `temporal_backward_G`, which requires `forward_F` for `neg(neg(psi))` (= psi after double negation elimination). This is **circular**.

**Approach 2: until_induction with a cycle-specific chi**

The `until_induction` axiom:
```
G(psi -> chi) & G((top & X(chi)) -> chi) -> ((top U psi) -> X(chi))
```

We need chi such that:
1. `G(psi -> chi)` is in chain(t+i) -- requires psi -> chi at all future times, needs backward G
2. `G((top & X(chi)) -> chi)` is in chain(t+i) -- requires the step formula at all future times
3. `X(chi) not in chain(t+i)` -- to get contradiction

**Problem with condition 1**: Even though neg(psi) is in every chain element in the cycle (making psi -> chi vacuously true at each position), deriving `G(psi -> chi)` requires the meta-to-object-level conversion (backward G). This is exactly the circularity.

**Attempt with chi such that psi -> chi is a THEOREM**: If psi -> chi is provable from the axioms, then G(psi -> chi) is also provable (temporal necessitation). But then chi is derivable from psi, and X(chi) would typically be provable too, making condition 3 fail.

**Attempt with chi = bot**:
- G(psi -> bot) = G(neg(psi)) -- requires backward G, circular
- G((top & X(bot)) -> bot) = G(theorem) -- provable, since X(bot) = bot U bot and X_bot_absurd shows (bot U bot) -> bot
- X(bot) not in chain(t+i) -- true, since X(bot) = bot U bot and chains are consistent

This reduces to showing G(neg(psi)) in chain(t+i), which is circular.

**Approach 3: Direct semantic argument via periodic model**

Construct a periodic model from the cycle. As analyzed in Report 24 (Sections 2.7-2.12), this requires a truth lemma connecting MCS membership to semantic truth, which has the same circularity.

**Approach 4: Use the cycle to establish a BOUNDED form of G(neg(psi))**

The cycle gives us: neg(psi) in chain(t+i+1), ..., chain(t+j). This is neg(psi) at the next k positions. But there is no "bounded G" operator in the object language. G quantifies over ALL strictly future times.

However, consider the Until Induction axiom more carefully with a different instantiation. Since neg(psi) holds at exactly k consecutive positions and then the restricted theory repeats, we could try to encode the "k-step negation" using iterated X operators:

X(neg(psi)) in chain(t+i) (since neg(psi) in chain(t+i+1))
X(X(neg(psi))) in chain(t+i) (since neg(psi) in chain(t+i+2))
...
X^k(neg(psi)) in chain(t+i) (since neg(psi) in chain(t+i+k))

But X^(k+1)(neg(psi)) in chain(t+i) iff neg(psi) in chain(t+i+k+1). By the cycle (restricted theory repeats), if neg(psi) in deferralClosure and neg(psi) in chain(t+i+1), then neg(psi) in chain(t+i+k+1). So this continues indefinitely -- we have X^m(neg(psi)) in chain(t+i) for all m >= 1.

**But X^m(neg(psi)) is not G(neg(psi))**. G(neg(psi)) means neg(psi) at ALL strictly future times, not just the next m. We have an infinite sequence of X^m facts but cannot combine them into G.

### 3.5 The Fundamental Obstruction

The cycle gives us:
- **Meta-level fact**: for all n > t, neg(psi) in chain(n)
- **Need**: G(neg(psi)) in chain(t) (object-level)
- **Gap**: converting infinitely many "neg(psi) in chain(n)" facts into the single formula G(neg(psi)) in an MCS

This gap IS the backward-G problem. It cannot be resolved by the cycle alone because:

1. The cycle only gives RESTRICTED theory repetition, not full theory repetition.
2. Even full theory repetition would not help: knowing the restricted theory at ALL future positions is a meta-level statement about infinitely many chain elements.
3. The backward-G lemma requires forward_F as its mechanism for the meta-to-object conversion.

---

## 4. Analysis of restricted_temporally_coherent

### 4.1 What It Requires

From TemporalCoherence.lean (line 295):
```lean
def BFMCS.restricted_temporally_coherent (B : BFMCS D) (root : Formula) : Prop :=
  forall fam in B.families,
    (forall t phi, phi in deferralClosure root ->
      F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s) &
    (forall t phi, phi in deferralClosure root ->
      P(phi) in fam.mcs t -> exists s < t, phi in fam.mcs s)
```

This is forward_F/backward_P restricted to formulas in deferralClosure(root).

### 4.2 Can We Prove It Without Global forward_F?

For the deterministic chain, `restricted_temporally_coherent` for root=phi requires: for every `chi in deferralClosure(phi)`, if `F(chi) in chain(t)`, then exists `s > t` with `chi in chain(s)`.

This is `deterministic_forward_F` restricted to `chi in deferralClosure(phi)`. It is a WEAKER statement than the full forward_F, but it still requires the same backward-G argument for the contradiction.

The restriction to deferralClosure does NOT help break the circularity because:
- We still need G(neg(chi)) in chain(t) to contradict F(chi) in chain(t)
- Getting G(neg(chi)) still requires temporal_backward_G
- temporal_backward_G still requires forward_F (even restricted forward_F)

**The circularity persists at the restricted level.** Restricted temporal coherence is strictly weaker to USE but equally hard to PROVE.

### 4.3 The RestrictedTemporallyCoherentFamily Structure

From SuccChainFMCS.lean (referenced in RestrictedTruthLemma.lean), the `RestrictedTemporallyCoherentFamily` is a structure with:
- A seed (initial DeferralRestrictedMCS)
- A chain built by Succ relation steps
- Forward F coherence for formulas in deferralClosure
- Backward P coherence for formulas in deferralClosure

This structure ASSUMES restricted temporal coherence as part of its definition. It does not PROVE it. The RestrictedTruthLemma then proves that membership in this chain equals membership in the Lindenbaum extension, given a RestrictedTemporallyCoherentFamily.

**So the chain of dependencies is**:
```
RestrictedTemporallyCoherentFamily (assumes restricted F/P coherence)
  -> RestrictedTruthLemma (proves DRM <-> extension equivalence)
    -> Completeness (phi not provable -> phi has countermodel)
```

The missing link: constructing a `RestrictedTemporallyCoherentFamily` for a given root formula. This construction REQUIRES proving restricted forward_F and backward_P.

---

## 5. Concrete Proof Sketch: What Would Be Needed

### 5.1 If the Approach Works (Hypothetical)

Suppose we could somehow prove `restricted_forward_F` for the deterministic chain. The completeness proof would be:

1. phi is not provable, so neg(phi) is consistent.
2. Extend neg(phi) to MCS M0.
3. Build deterministic chain from M0.
4. For restricted_temporally_coherent with root = phi:
   - For each chi in deferralClosure(phi) with F(chi) in chain(t):
   - **Prove**: exists s > t with chi in chain(s). [THIS IS THE GAP]
5. Package into RestrictedTemporallyCoherentFamily.
6. Apply RestrictedTruthLemma: phi in chain(0) iff phi in ext(0).
7. Since neg(phi) in chain(0) = M0, neg(phi) in ext(0).
8. ext(0) is MCS, so phi not in ext(0).
9. Build canonical model from ext(0) via existing parametric machinery.
10. phi is false in the canonical model, so phi is not valid.

### 5.2 Where the Gap Cannot Be Closed (Current Analysis)

Step 4 requires restricted_forward_F. All approaches to proving this hit the backward-G circularity:

```
restricted_forward_F(chi)
  <- contradiction: G(neg(chi)) kills (top U chi) via G_neg_kills_until
    <- G(neg(chi)) in chain(t) via temporal_backward_G
      <- forward_F(neg(chi)) -- CIRCULAR
```

### 5.3 Could Well-Founded Induction Work?

Attempt: prove restricted_forward_F by well-founded induction on sizeof(chi).

For the backward-G step, we need forward_F for neg(chi). sizeof(neg(chi)) = sizeof(chi) + sizeof(bot) + 1 = sizeof(chi) + 2. This is LARGER than sizeof(chi), so we cannot use the induction hypothesis.

**Alternative**: Induction on a measure that makes neg(chi) "smaller" than chi. No such natural measure exists for the formula type.

**Alternative**: Mutual induction proving (A) restricted_forward_F(chi) and (B) restricted_backward_G(chi) simultaneously. But (A) for chi requires (B) for neg(chi), and (B) for neg(chi) requires (A) for neg(neg(chi)) = chi (after DNE). This gives a cycle of length 2, not a well-founded descent.

---

## 6. Effort Estimate

### 6.1 If the Cycle Contradiction Could Be Resolved

If a syntactic contradiction from the pigeonhole cycle were found (which current analysis says is not possible without additional proof-system infrastructure), the formalization would require:

- **deferralClosure adjustment**: ~50 lines (extend closure to include `top U psi` and related formulas)
- **Cycle contradiction lemma**: ~200-300 lines (derive inconsistency from cyclic restricted theory)
- **Wiring to forward_F_via_deferral**: ~50 lines (combine with existing infrastructure)
- **backward_P by symmetry**: ~100 lines (mirror argument for Since)

**Total**: ~400-500 new lines. Difficulty: MEDIUM (if the math works).

### 6.2 If the Approach Cannot Be Made to Work

The finite deferral approach appears blocked by the same meta-to-object gap that blocks all other approaches. The remaining viable paths identified across 25 reports are:

1. **Modify the proof system**: Add an omega-rule or infinitary inference rule that directly converts "phi at all future positions" to G(phi). This changes the logic.

2. **Change the semantics to reflexive**: Make G(phi) -> phi valid. This resolves all circularity but changes the system fundamentally.

3. **Quasimodel with explicit Until tracking** (very complex): Build a non-deterministic model where each state carries explicit annotations for which Until formulas are active, and use these annotations to prove coherence without backward-G. Estimated 1500+ lines.

4. **Accept the sorry**: Document that the forward_F/backward_P sorries are genuine open formalization problems for strict discrete temporal logic with Until.

---

## 7. Key Observations and Novel Insights

### 7.1 The X^m Tower

The cycle gives us, for every m >= 1:
```
X^m(neg(psi)) in chain(t+i)
```

This infinite tower of X-prefixed formulas is a SYNTACTIC artifact of the cycle. Each X^m(neg(psi)) is a distinct formula with distinct structure. Their conjunction would give "neg(psi) at the next m steps," but:
- There is no formula expressing their infinite conjunction.
- G(neg(psi)) is their "semantic limit" but not derivable from finitely many of them.

### 7.2 The Closure Size Problem

For the pigeonhole argument, deferralClosure must include (top U psi). But it also must include ALL formulas that the chain might cycle on. If we add (top U psi), we should also add X(psi or (top and (top U psi))) (the until_unfold result), which is already in x_content-related formulas. The extended closure remains finite, so the pigeonhole still works, but with a larger bound.

### 7.3 The Existing restricted_temporally_coherent Is the Right Abstraction

The definition of `BFMCS.restricted_temporally_coherent` in TemporalCoherence.lean is precisely what the truth lemma needs. The problem is not in the abstraction but in the construction: no known construction of the deterministic chain satisfies this predicate without forward_F.

### 7.4 Connection to the "Forward-Only Truth Lemma" (Report 24, Section 4.6)

Report 24 observed that a forward-only truth lemma (membership implies truth) avoids backward-G for all cases EXCEPT Until. The Until case requires showing (phi U psi) true implies a witness exists, which IS forward_F. So even the weakest useful truth lemma requires forward_F.

### 7.5 The Strict vs Reflexive Semantics Gap

Under reflexive semantics (G(phi) -> phi valid), the cycle argument DOES work:
- neg(psi) in chain(n) for all n > t
- By reflexive semantics: neg(psi) in chain(t) also (since G(neg(psi)) -> neg(psi) and we could derive G(neg(psi)))
- Wait, this still needs backward-G...

Actually, the key difference under reflexive semantics: g_content(M) includes ALL formulas in M (since G(phi) in M implies phi in M). So x_content(M) contains g_content(M) = M. This means x_content(M) is a SUPERSET of M (restricted to the appropriate formulas). The Until unfold + x_content property then gives stronger guarantees.

Under strict semantics, g_content(M) is a strict SUBSET of M. The formula (top U psi) might be in M but NOT in g_content(M) (because G(top U psi) might not be in M). This is why the detour construction breaks.

---

## 8. Recommendations

1. **The pigeonhole cycle approach does not yield a syntactic contradiction** within the current proof system for strict temporal semantics. The backward-G gap is fundamental, not an artifact of the proof strategy.

2. **The existing FiniteDeferral.lean infrastructure should be preserved** -- it is well-engineered and would become useful if the backward-G gap is resolved by other means.

3. **The RestrictedTruthLemma.lean provides value** as a DRM-extension equivalence but does not contribute to resolving forward_F.

4. **For closing the sorries**, the team should investigate approaches that avoid the truth lemma entirely or that restructure the completeness argument to not need backward-G. The most promising direction from the literature appears to be a quasimodel construction adapted for strict semantics with explicit Until tracking annotations.

5. **The deferralClosure needs extension** to include `(top U psi)` if the pigeonhole argument is to be used. This is a straightforward 50-line addition.
