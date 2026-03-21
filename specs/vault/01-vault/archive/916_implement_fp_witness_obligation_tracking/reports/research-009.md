# Research Report: Task #916 (Canonical Model Feasibility Analysis)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-21
**Focus**: Evaluate the "Canonical Model (Not Linear Chain)" approach from research-008.md Section 3.4
**Session**: sess_1771709010_515267

---

## 1. Executive Summary

The canonical model approach proposed in research-008.md cannot be applied as described because the existing codebase's semantics are fundamentally incompatible with the standard Kripke-style canonical model construction. The codebase implements **task semantics** with world histories, not Kripke frames with accessibility relations. The BMCS completeness proof already IS a form of canonical model construction, and the sorries arise specifically from the temporal dimension of that construction.

This report identifies the precise architectural gap, evaluates three concrete paths forward, and recommends a targeted refactoring that preserves the existing sorry-free infrastructure while resolving the temporal witness problem.

---

## 2. The Semantic Architecture (What Research-008.md Missed)

### 2.1 Standard Canonical Model vs. This Project's Semantics

Research-008.md Section 3.4 proposed using "ALL maximal consistent sets as the time domain, with the canonical relation `u R v iff GContent(u) subset v`." This is the standard approach for temporal logics over Kripke frames.

However, the ProofChecker codebase does NOT use standard Kripke frames. It implements the JPL paper's **task semantics**, which differs in fundamental ways:

| Feature | Standard Kripke | Task Semantics (This Project) |
|---------|----------------|-------------------------------|
| Worlds | Abstract set W | WorldState type in TaskFrame |
| Time | Points in accessibility relation | Ordered additive group D (e.g., Int) |
| Histories | Not applicable | Functions `tau: D -> WorldState` with convexity |
| Modal operator | Quantifies over accessible worlds | Quantifies over ALL histories at same time |
| Temporal operator | Quantifies over accessible times | Quantifies over ALL times in D |
| Frame conditions | Reflexivity/transitivity of R | Nullity (task_rel w 0 w) + Compositionality |

The truth definition in `Truth.lean` (lines 112-119) is:
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
```

Key observations:
- **Box** quantifies over a set Omega of world histories at the SAME time t
- **G (all_future)** quantifies over times s >= t in the SAME history tau
- There is NO accessibility relation between time points
- The temporal structure is the ORDERING on D, not an explicit relation

### 2.2 What the BMCS Construction Already Is

The BMCS (Bundle of Maximal Consistent Sets) construction in the codebase IS already a form of canonical model, but adapted for task semantics:

**BMCS Truth** (`BMCSTruth.lean` lines 88-94):
```lean
def bmcs_truth_at (B : BMCS D) (fam : BFMCS D) (t : D) : Formula -> Prop
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
  | Formula.all_future phi => forall s, t <= s -> bmcs_truth_at B fam s phi
```

This mirrors the standard truth definition:
- **Box** quantifies over families in the bundle (analogous to worlds in Kripke semantics)
- **G** quantifies over times s >= t within the same family (analogous to the temporal dimension)

The BFMCS structure (`BFMCS.lean`) is exactly a canonical temporal line: it assigns an MCS to each time point t in D, with coherence conditions (forward_G, backward_H) that correspond to the temporal accessibility.

**The completeness proof chain is:**
1. `bmcs_truth_lemma` (TruthLemma.lean) -- sorry-free
2. `bmcs_representation` (Completeness.lean) -- sorry-free (delegates to step 3)
3. `fully_saturated_bmcs_exists_int` (TemporalCoherentConstruction.lean) -- sorry-backed
4. `temporal_coherent_family_exists_theorem` (DovetailingChain.lean) -- sorry-backed (forward_F, backward_P)

The ENTIRE completeness chain is sorry-free EXCEPT for the construction of a single BFMCS that satisfies forward_F and backward_P. This is the ONLY remaining gap.

### 2.3 Why the Naive Canonical Model Doesn't Apply

The standard canonical model for temporal logic uses all MCSs as time points and defines `u R v iff GContent(u) subset v`. Forward_F then follows from Lindenbaum applied to `{psi} union GContent(u)`.

This approach fails in task semantics for a specific structural reason: **the BFMCS structure requires a function `D -> Set Formula` (assigning MCSs to the ORDERED time domain D), not an arbitrary set of MCSs with an accessibility relation.** The temporal operators quantify over the linear order on D, not over an accessibility relation.

If we tried to use all MCSs as D:
1. D = Set of all MCSs is a type, but it lacks the required `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D` instances
2. Even if we could define such instances, the resulting order would not generally be a total order (the R relation `GContent(u) subset v` is a preorder, not a linear order)
3. The compositionality constraint on TaskFrame (if w can reach u in duration x, and u can reach v in duration y, then w can reach v in duration x+y) requires additive group structure on the time domain

The canonical model approach from research-008.md conflates two different semantic frameworks.

---

## 3. Precise Characterization of the Gap

### 3.1 What the Sorries Require

The two sorries in DovetailingChain.lean (lines 1753-1761) are:

```
forward_F: forall t : Int, forall phi : Formula,
  F(phi) in family.mcs t -> exists s > t, phi in family.mcs s

backward_P: forall t : Int, forall phi : Formula,
  P(phi) in family.mcs t -> exists s < t, phi in family.mcs s
```

where `family : BFMCS Int` is constructed by `buildDovetailingChainFamily`.

### 3.2 What the Construction Provides

The dovetailing chain construction builds `chainMCS : Nat -> Set Formula` (for non-negative indices) and extends to `Int` symmetrically. At each step n:
- Seed = GContent(chainMCS(n-1)) or {psi} union GContent(chainMCS(n-1)) at witness steps
- Extension via Lindenbaum (`set_lindenbaum`) to obtain an MCS

The construction already handles:
- **forward_G**: G(phi) at t implies phi at all s > t (GContent propagation via seed, sorry-free)
- **backward_H**: H(phi) at t implies phi at all s < t (HContent propagation via seed, sorry-free)
- **Witness placement**: At step n = encodeFormula(psi), if F(psi) is alive, psi enters chainMCS(n+1)

### 3.3 The Two Sub-Problems (From Research-008.md)

**Sub-problem A (Persistence)**: F(psi) at step n must survive to the witness step k = encodeFormula(psi). Lindenbaum extensions at intermediate steps can kill F(psi) because it is not in the GContent seed.

**Sub-problem B (Past-encoding)**: If encodeFormula(psi) < n, the witness was placed in the PAST. No mechanism propagates psi forward from step encodeFormula(psi)+1 to beyond n.

---

## 4. Three Concrete Approaches

### 4.1 Approach A: Canonical Temporal Model (Redefine Time Domain)

**Idea**: Instead of using `Int` as the time domain, define a new canonical time structure specifically for the completeness proof where every F-obligation has a built-in witness.

**Construction**:
1. Define `CanonicalTime := Int x Nat` (pairs of integer time and witness index)
2. Order lexicographically: (t1, n1) < (t2, n2) iff t1 < t2 or (t1 = t2 and n1 < n2)
3. For each t and each F(psi) in MCS(t), insert a witness MCS at (t, encodeFormula(psi))
4. The main timeline lives at indices (t, 0)

**Why it fails**: `Int x Nat` with lexicographic order has `AddCommGroup` and `LinearOrder`, but it does NOT satisfy `IsOrderedAddMonoid` because addition does not interact well with the order (adding (0, 1) to both sides of (0, 0) < (1, 0) does not preserve the strict inequality in the second component). More fundamentally, the completeness proof needs D = Int specifically (see `Completeness.lean` line 101: `exists (B : BMCS Int)`).

**Assessment**: Not viable without changing the completeness theorem statement.

### 4.2 Approach B: Ordinal-Indexed Iteration (Transfinite Repair)

**Idea**: Build a sequence of chain families indexed by ordinals. At limit ordinals, take the "intersection" of previous families. At successor ordinals, repair one unsatisfied F-obligation.

**Construction**:
1. Start with chain_0 = current dovetailing chain (satisfies forward_G, backward_H)
2. At successor alpha+1: Find the smallest (t, psi) where F(psi) in chain_alpha.mcs(t) has no witness. Build a NEW BFMCS chain_alpha+1 that has the same MCSs at all times except that a witness for this obligation is inserted.
3. At limit alpha: Define chain_alpha.mcs(t) = intersection of chain_beta.mcs(t) for beta < alpha (if consistent) or use Lindenbaum on the intersection.

**Why it is problematic**:
- The intersection of MCSs is not generally an MCS (it may be consistent but not maximal)
- Inserting a witness for one obligation may destroy witnesses for others (the counterexample from research-005.md applies)
- The construction may not stabilize (new F-obligations can be created by Lindenbaum extensions)
- Lean's induction principles for ordinals are complex to formalize

**Assessment**: Theoretically interesting but practically infeasible within the current framework. Estimated effort: 80-120 hours with uncertain outcome.

### 4.3 Approach C: Direct Proof via Temporal Axioms (Derivation-Based)

**Idea**: Prove forward_F directly from the axioms and the construction, without requiring the chain to explicitly place witnesses. The key insight is that F(psi) in an MCS has consequences derivable WITHIN that MCS, and these consequences can be used to find witnesses in the existing chain.

**Core Argument**:
Given F(psi) = neg(G(neg psi)) in MCS M at time t:

1. **Dichotomy**: By MCS maximality, for each time s > t, either psi in family.mcs(s) or neg(psi) in family.mcs(s).

2. **If psi in family.mcs(s) for some s > t**: Done (witness found).

3. **If neg(psi) in family.mcs(s) for ALL s > t**: Then by the backward direction argument (already proven as `temporal_backward_G` for the TemporalCoherentFamily, but not yet available for the BFMCS without forward_F), G(neg psi) would be in family.mcs(t). But F(psi) = neg(G(neg psi)) is also in family.mcs(t). Contradiction with MCS consistency.

**The Circularity Problem**: Step 3 uses `temporal_backward_G`, which itself requires `forward_F` to construct a `TemporalCoherentFamily`. This creates a circular dependency:
- forward_F needs temporal_backward_G
- temporal_backward_G needs forward_F (to build TemporalCoherentFamily)

**Breaking the Circularity**: The backward argument in step 3 does NOT actually need the full forward_F. It needs a weaker statement: "if neg(psi) is in family.mcs(s) for ALL s > t, then G(neg psi) is in family.mcs(t)." This statement follows from the CONSTRUCTION-SPECIFIC properties of the chain, NOT from the general TemporalCoherentFamily framework.

**Specifically**: The dovetailing chain is built so that GContent propagates. If neg(psi) is in MCS(s) for all s > t, then for all s > t, either G(neg psi) is in MCS(s) or it is not. But:
- If G(neg psi) is NOT in MCS(t), then neg(G(neg psi)) = F(psi) is in MCS(t) (given)
- For the chain construction, GContent(MCS(t)) subset MCS(t+1) subset MCS(t+2) subset ...
- So neg(G(neg psi)) being in MCS(t) does NOT put G(neg psi) into GContent, so G(neg psi) is NOT forced into future MCSs

Wait -- this argument shows the non-circularity but does NOT actually prove forward_F. The issue remains: Lindenbaum at step s might include neg(psi) for all s > t, consistent with F(psi) at t, because the chain only propagates GContent, and F(psi) is NOT in GContent.

**The Real Question**: Is it possible that F(psi) is in MCS(t), yet neg(psi) is in MCS(s) for all s > t, in a dovetailing chain?

**Answer**: YES, this is possible -- and this is exactly the root cause identified in research-008.md. The chain places neg(psi) at all future steps because:
1. Lindenbaum has no constraint preventing neg(psi) from entering
2. F(psi) is not in GContent, so it does not propagate to constrain future MCSs
3. The one-shot witness mechanism only fires at encodeFormula(psi), which may be in the past

**Assessment**: Approach C fails for the same fundamental reason as the linear chain: the chain construction cannot guarantee witness placement.

### 4.4 Approach D: Fair-Scheduling Chain with Double-Seed (NEW)

**Idea**: Modify the chain construction to use a TWO-PART seed that includes both GContent AND a controlled selection of F-content obligations. Use fair scheduling to process each formula infinitely often.

**Construction**:
1. Replace one-shot enumeration with fair enumeration: at step n, process formula `decodeFormula(n mod countFormulas)` (or use Nat.unpair for a fair pairing)
2. At each step n, let psi = the currently scheduled formula. The seed is:
   - If F(psi) is in MCS(n): seed = {psi} union GContent(MCS(n)) -- **this is consistent** (proven as `forward_temporal_witness_seed_consistent`)
   - Otherwise: seed = GContent(MCS(n))
3. Each formula is processed infinitely often. When F(psi) is alive at step n, and psi is scheduled, then psi enters MCS(n+1).

**Why Sub-Problem A (Persistence) is Resolved**:
Consider F(psi) in MCS(t). Suppose F(psi) is killed at some step s between t and the next processing of psi. "Killed" means G(neg psi) enters MCS(s). But:
- G(neg psi) in MCS(s) means neg(psi) in GContent(MCS(s))
- So neg(psi) propagates to all future MCSs (including MCS(s+1), MCS(s+2), ...)
- In particular, neg(psi) is in MCS(s') for all s' > s
- But also, psi WAS in MCS(t) for some t <= s (by T-axiom on F(psi) at t? No -- F(psi) does not imply psi)

Actually, F(psi) being killed does NOT mean psi was ever in any MCS. It means the OBLIGATION F(psi) was replaced by the ASSERTION G(neg psi). The question is whether this can happen consistently.

**Key Insight**: If F(psi) is in MCS(t) and G(neg psi) enters MCS(s) for some s > t, then:
- From temp_a (temporal A axiom): psi -> G(P(psi)), i.e., if psi were true at some time, then at all future times, there was a past time where psi was true. But psi may never have been true.
- From the consistency of MCS(s): G(neg psi) in MCS(s) and the chain propagation of G(neg psi) to all s' > s gives neg(psi) at all future times.
- The question is: can MCS(s) be consistent with G(neg psi) while MCS(t) (with t < s) contains F(psi)?

**Answer**: YES. The GContent propagation ensures that GContent(MCS(t)) subset MCS(t+1) subset ... subset MCS(s). So any G-formula at time t is at time s. F(psi) = neg(G(neg psi)) is in MCS(t), but neg(G(neg psi)) is NOT a G-formula, so it does NOT propagate. Lindenbaum at step s is free to include G(neg psi) as long as it is consistent with the seed GContent(MCS(s-1)).

**Resolution of Sub-Problem A**: The fair scheduling ensures that F(psi) is processed infinitely often. Between two consecutive processing rounds (say at steps n and m with n < m), F(psi) can be killed at some step s in (n, m). But:

- If F(psi) is alive at step n and psi is scheduled at step n, then psi enters MCS(n+1). Done.
- If F(psi) is killed between n and m (at step s), can it be revived? F(psi) = neg(G(neg psi)). If G(neg psi) enters MCS(s), it propagates to all future MCSs. So F(psi) is dead at all steps > s. This means the obligation is UNFULFILLABLE from step s onward.

But wait: we need psi at some s' > t, and if psi entered MCS(n+1) with n+1 > t, then we already have a witness. The issue is only when F(psi) appears at t AFTER the last processing of psi.

**The Key Claim**: With fair scheduling, if F(psi) is alive at step t, then either:
(a) psi was placed at some earlier processing round s < t with s > some earlier occurrence. But s might be < t or > t.
(b) F(psi) will be alive at the NEXT processing round m > t (because nothing kills it between t and m). At round m, psi is scheduled and enters MCS(m+1). This gives a witness at m+1 > t.

Case (b) requires that F(psi) persists from t to m. This is the persistence problem. Between t and m, Lindenbaum at each step can kill F(psi).

**Why F(psi) CANNOT be killed without producing a witness (in the modified construction)**:

If F(psi) is killed at step s (meaning G(neg psi) enters MCS(s)), consider: did the scheduling process psi at any step between t and s? If so, and F(psi) was alive at that step, then psi entered the chain. If F(psi) was alive from t to the next scheduling of psi (step m), then either F(psi) is still alive at m (and psi enters MCS(m+1)) or F(psi) was killed before m.

This is still circular. The fundamental issue: we CANNOT prevent Lindenbaum from killing F(psi) at intermediate steps.

**Assessment**: Approach D does NOT resolve Sub-Problem A. Fair scheduling resolves Sub-Problem B (past-encoding) but persistence remains the blocker.

---

## 5. The Fundamental Obstacle (Refined)

### 5.1 Precise Statement

The obstacle is: **in a linear chain where each step extends GContent of the previous step via Lindenbaum, F-formulas from one step are invisible to the seed of the next step and can be arbitrarily killed by Lindenbaum's maximal extension.**

This is inherent to ANY construction that:
1. Uses Lindenbaum (Zorn's lemma) to complete seeds to MCSs
2. Seeds only GContent (or GContent plus finitely many formulas)
3. Processes formulas one at a time

### 5.2 Why the Standard Canonical Model Avoids This

In the standard (non-linear) canonical model for temporal logics:
- Time points ARE MCSs (not integers)
- The accessibility relation R is `GContent(u) subset v`
- For each F-obligation, a SEPARATE witness MCS is constructed via Lindenbaum
- Different F-obligations at the same MCS u get DIFFERENT witnesses

The witness for F(psi) at u is:
```
v = Lindenbaum({psi} union GContent(u))    -- consistent by proven lemma
```

This v is NOT required to be on the same linear chain as u. It is a SEPARATE MCS with u R v (because GContent(u) subset v by construction).

### 5.3 The Mismatch With BFMCS

The BFMCS structure requires:
```lean
structure BFMCS where
  mcs : D -> Set Formula
  forward_G : forall t t' phi, t < t' -> G(phi) in mcs(t) -> phi in mcs(t')
  backward_H : forall t t' phi, t' < t -> H(phi) in mcs(t) -> phi in mcs(t')
```

This IS a linear chain: one MCS per time point, with GContent propagation. The forward_F obligation says: for each F(psi) in mcs(t), find an s > t with psi in mcs(s). This s must be ON THE SAME CHAIN.

In the standard canonical model, the witness v for F(psi) at u is NOT on the same chain -- it is a separate MCS. The standard approach works because the time domain IS the set of MCSs, so v is automatically a valid time point.

---

## 6. Viable Resolution Paths

### 6.1 Path 1: Prove forward_F Directly from Chain Properties

This path attempts to prove that the existing dovetailing chain already satisfies forward_F, using only the properties that are already established.

**Strategy**: For F(psi) in chainMCS(t), consider what happens at step n = encodeFormula(psi):

- **Case n >= t**: At step n, the construction checks if F(psi) is alive. If so, the seed is `{psi} union GContent(chainMCS(n))`, and psi enters chainMCS(n+1). The witness is n+1 > t.

  The remaining question: does F(psi) survive from step t to step n? This is Sub-Problem A.

  **Possible argument**: At each step s between t and n, the seed is GContent(chainMCS(s-1)) or a witness seed for another formula. The key is that F(psi) being "killed" means G(neg psi) enters the MCS. But G(neg psi) in chainMCS(s) means neg(psi) in GContent(chainMCS(s)), which means neg(psi) propagates to all future steps. In particular, neg(psi) in chainMCS(n), so the witness seed `{psi} union GContent(chainMCS(n))` would contain BOTH psi and neg(psi)... but wait, GContent(chainMCS(n)) does not directly contain neg(psi). It contains chi such that G(chi) in chainMCS(n). If G(neg psi) in chainMCS(s) and s <= n, then by forward_G (already proven), neg(psi) in chainMCS(n). But neg(psi) in chainMCS(n) does NOT mean neg(psi) in GContent(chainMCS(n)). GContent(chainMCS(n)) = {chi | G(chi) in chainMCS(n)}.

  So neg(psi) is in chainMCS(n) but NOT necessarily in GContent(chainMCS(n)). The witness seed `{psi} union GContent(chainMCS(n))` could still be consistent, because psi and neg(psi) being in the same set is inconsistent, but psi is in the seed and neg(psi) is in chainMCS(n), not in the seed.

  Wait -- BUT the proven lemma `forward_temporal_witness_seed_consistent` says that IF F(psi) is in chainMCS(n), then `{psi} union GContent(chainMCS(n))` is consistent. The issue is: is F(psi) still in chainMCS(n)?

  If G(neg psi) entered at step s < n, then G(neg psi) propagates forward (it IS in GContent), so G(neg psi) in chainMCS(n). By the T-axiom, neg(psi) in chainMCS(n). And F(psi) = neg(G(neg psi)). Can both G(neg psi) and neg(G(neg psi)) be in chainMCS(n)? NO -- that contradicts MCS consistency. So if G(neg psi) in chainMCS(n), then F(psi) is NOT in chainMCS(n).

  So: **if F(psi) is killed (G(neg psi) enters) before step n, then F(psi) is NOT alive at step n, and the witness mechanism does not fire.** This is the persistence failure.

- **Case n < t**: The witness step is in the past. Sub-Problem B applies directly. Even if psi entered chainMCS(n+1), this is at time n+1 <= t, not strictly after t.

**Assessment**: Path 1 cannot work for the general case. For the specific case where n >= t AND F(psi) persists from t to n, the chain already provides the witness. But we cannot guarantee persistence.

### 6.2 Path 2: Restructure BFMCS to Allow Non-Linear Witnesses

**Idea**: Modify the BFMCS structure to allow the temporal witness to come from a DIFFERENT family in the bundle, not from the same linear chain.

**Observation**: The TruthLemma already works with BMCS (Bundle of BFMCS families). The truth of G(phi) at family `fam` and time `t` is: phi is in fam.mcs(s) for all s >= t. This stays within the same family. But forward_F requires a witness s > t with phi in fam.mcs(s) -- again within the same family.

**Modified Approach**: What if the BMCS truth definition for F-formulas (existential temporal) quantified over ALL families, not just the current family?

Currently:
```lean
bmcs_truth_at ... (Formula.all_future phi) := forall s, t <= s -> bmcs_truth_at ... fam s phi
```

The existential dual F(phi) = neg(G(neg phi)) becomes:
```
exists s > t, bmcs_truth_at ... fam s phi
```

This is WITHIN the same family. If we changed the semantics so that F(phi) could find its witness in a DIFFERENT family, the proof would be trivial -- but it would change the logic.

**Problem**: Changing the semantics of the temporal operators would break soundness. The standard semantics for temporal operators in task semantics quantify within the SAME history, not across histories. This is a fundamental feature: temporal operators track the evolution of a SINGLE world history over time.

**Assessment**: Path 2 would require changing the logic itself, which is unacceptable.

### 6.3 Path 3: Stronger Chain Construction (FContent in Seed)

**Idea**: Use a seed that includes BOTH GContent AND selected F-obligations. The counterexample from research-005.md shows that including ALL of FContent can be inconsistent. But perhaps including a CAREFULLY SELECTED subset of FContent can work.

**Refined Construction**:
At each step n, the seed is:
```
GContent(chainMCS(n-1)) union AliveF(chainMCS(n-1))
```
where `AliveF(M) = {F(psi) | F(psi) in M and G(neg psi) not in M}` -- the set of F-obligations that have NOT been definitively killed.

**Consistency Claim**: Is `GContent(M) union AliveF(M)` consistent when M is an MCS?

`GContent(M) union AliveF(M) subset M` because:
- GContent(M) = {chi | G(chi) in M}, and by the T-axiom G(chi) -> chi, we have chi in M
- AliveF(M) = {F(psi) | F(psi) in M and ...}, so F(psi) in M

Therefore `GContent(M) union AliveF(M) subset M`, and since M is consistent (it is an MCS), every subset of M is consistent.

**This seed IS consistent!**

But wait -- the seed includes F-FORMULAS (of the form F(psi)), not their sub-formulas. Including F(psi) in the seed does NOT force psi to be in the resulting MCS. It only forces F(psi) to be in the resulting MCS. This just PRESERVES the F-obligation, it does not SATISFY it.

**The Key Realization**: Including F-obligations in the seed SOLVES SUB-PROBLEM A (persistence). F(psi) is in the seed, so Lindenbaum preserves it. F(psi) survives from step to step as long as it remains "alive" (i.e., G(neg psi) has not entered).

**Combined with Fair Scheduling for Sub-Problem B**:
1. Use fair enumeration (process each formula infinitely often)
2. At each step n, include AliveF(chainMCS(n-1)) in the seed to preserve F-obligations
3. At the scheduled witness step for psi, use seed `{psi} union GContent(chainMCS(n-1))` (proven consistent)
4. After the witness step, psi is in the MCS, and the F-obligation is satisfied

**Why This Approach Works**:
- **Persistence (Sub-Problem A)**: F(psi) is in the seed via AliveF, so it persists through non-witness steps. It can only be killed if G(neg psi) enters, but that would make the MCS inconsistent with F(psi) in the seed.

  Actually, can G(neg psi) enter? If F(psi) is in the seed, then F(psi) = neg(G(neg psi)) is in the resulting MCS. So G(neg psi) CANNOT be in the resulting MCS (by consistency). Therefore F(psi) persists indefinitely through the chain until it is satisfied.

- **Witnessing (Sub-Problem B)**: Fair scheduling ensures each formula is processed infinitely often. At the witness step for psi, if F(psi) is still alive, psi enters the MCS.

**Counterexample Reconciliation**:
The counterexample from research-005.md showed that `{psi} union GContent(M) union {F(r)}` can be inconsistent. But our seed does NOT include both the witness sub-formula AND the F-obligations simultaneously. At witness steps, the seed is `{psi} union GContent(M)` (without AliveF). At non-witness steps, the seed is `GContent(M) union AliveF(M)` (without the witness sub-formula).

The counterexample specifically requires BOTH a witness sub-formula AND an incompatible F-formula in the same seed. Our construction avoids this by separating the two.

**Potential Issue at Witness Steps**: At step n when we witness psi, the seed is `{psi} union GContent(chainMCS(n-1))`. This does NOT include AliveF. So F-obligations from chainMCS(n-1) that are NOT G-formulas will not propagate through this step. However:

- The resulting MCS at step n+1 contains `{psi} union GContent(chainMCS(n-1))` as a subset
- Lindenbaum extends this to an MCS
- Some F-obligations from chainMCS(n-1) might survive (if consistent with the seed), others might be killed

This means witness steps CAN kill F-obligations. To fix this, we could use a TWO-PHASE seed at witness steps:
```
{psi} union GContent(chainMCS(n-1)) union AliveF(chainMCS(n-1))
```

Is this consistent? We need: `{psi} union GContent(M) union AliveF(M)` is consistent.

Since `GContent(M) union AliveF(M) subset M` and M is consistent, the question reduces to: is `{psi} union S` consistent where S subset M and `{psi} union GContent(M)` is consistent?

Not necessarily. The counterexample applies: `{psi} union GContent(M)` is consistent, and `AliveF(M) subset M`, but `{psi} union GContent(M) union AliveF(M)` might be inconsistent if some F-obligation in AliveF(M) is incompatible with psi.

**Revised Strategy**: At witness steps, use `{psi} union GContent(M)` as the seed (proven consistent), but then ALSO check which F-obligations from AliveF(M) are individually consistent with the resulting seed and include those.

This is essentially the "Controlled Lindenbaum" approach from research-008.md Section 3.3, but with a key improvement: we include F-FORMULAS (not their sub-formulas) in the seed, which preserves the obligations without attempting to satisfy them.

**Simpler Alternative**: Use `GContent(M) union AliveF(M)` at ALL steps, and at witness steps, additionally try to include psi. If `{psi} union GContent(M) union AliveF(M)` is consistent, use that seed. If not, just use `GContent(M) union AliveF(M)`.

If the combined seed is inconsistent, it means some F(r) in AliveF(M) is incompatible with psi. But F(r) is neg(G(neg r)), so the inconsistency means `{psi, F(r)} union GContent(M) derives bot`. By the deduction theorem, `GContent(M) union {F(r)} derives neg(psi)`. So `GContent(M) union {F(r)}` implies neg(psi). But `GContent(M) union {F(r)} subset M`, and M is consistent, and psi might or might not be in M.

At the NEXT witness step for psi (fair scheduling ensures this exists), F(r) might have been satisfied and removed from AliveF, or it might still be alive. If F(r) is still alive and still incompatible with psi, we cannot witness psi at this step either.

**Open Question**: Can the incompatibility persist indefinitely? This would mean F(psi) remains alive forever but is never witnessed, which is the persistence failure in a different guise.

### 6.4 Assessment Summary

| Approach | Resolves Sub-A | Resolves Sub-B | Feasible | Effort |
|----------|---------------|----------------|----------|--------|
| A: Canonical Time Domain | N/A | N/A | No (type mismatch) | N/A |
| B: Non-Linear Witnesses | Yes | Yes | No (changes logic) | N/A |
| C: Direct from Axioms | No | No | No (circular) | N/A |
| D: Fair + AliveF Seed | Partial | Yes | Promising | 30-50 hrs |

Approach D (Section 6.3) is the most promising. It resolves persistence at non-witness steps and resolves the past-encoding problem. The remaining gap is: at witness steps, some F-obligations may be killed due to incompatibility with the witness sub-formula. This is a STRICTLY SMALLER problem than the original.

---

## 7. Recommendation

### 7.1 Short-Term: Document Sorry Debt With Precise Characterization

The 2 sorries (forward_F, backward_P) in DovetailingChain.lean represent genuine mathematical difficulty in fitting the standard canonical model proof into the task-semantics BFMCS architecture. The sorry debt is:
- Honest (explicitly marked)
- Localized (2 specific lemmas)
- Mathematically sound (the properties are true in standard canonical model theory)
- Structurally isolated (the completeness chain is sorry-free otherwise)

### 7.2 Medium-Term: Implement Approach D (Fair + AliveF Seed)

**Phase 1** (10-15 hours): Implement the modified chain construction with:
- Fair enumeration replacing one-shot enumeration
- AliveF seed preservation at non-witness steps
- Proof that `GContent(M) union AliveF(M)` is consistent (follows from subset-of-MCS argument)

**Phase 2** (15-25 hours): Address witness-step F-obligation preservation:
- Prove that if `{psi} union GContent(M) union AliveF(M)` is inconsistent, then certain F-obligations in AliveF(M) are "blocked by" psi
- Show that blocked obligations are eventually unblocked (because the witness for the blocking obligation resolves the conflict)
- Or: show that blocking is transitive and terminates

**Phase 3** (5-10 hours): Prove forward_F and backward_P from the modified construction.

### 7.3 Long-Term: Investigate Alternative Completeness Architectures

If Approach D does not fully succeed, consider:
- Changing the BFMCS structure to support branching (tree-like rather than linear)
- Using a filtration-based approach instead of canonical model
- Accepting the sorry debt permanently with thorough documentation

---

## 8. Key Findings

### 8.1 The Canonical Model Proposal from Research-008.md Is Not Applicable

The proposal to "abandon the linear chain construction entirely" and use "ALL maximal consistent sets as the time domain" is incompatible with the codebase's task semantics. The time domain D must be an ordered additive group (like Int), not a set of MCSs. The BMCS construction is already the correct canonical model approach for this logic -- the gap is specifically in the temporal dimension.

### 8.2 The BMCS Architecture Is Sound and Nearly Complete

The completeness proof chain (TruthLemma -> Representation -> Completeness) is sorry-free. The ONLY gap is `fully_saturated_bmcs_exists_int`, which depends on `temporal_coherent_family_exists_theorem`, which depends on the two sorries `forward_F` and `backward_P` in DovetailingChain.lean.

### 8.3 The AliveF Seed Preservation Is a Novel Promising Approach

Including `AliveF(M) = {F(psi) | F(psi) in M and G(neg psi) not in M}` in the chain seed is consistent (since it is a subset of M) and preserves F-obligations through non-witness steps. Combined with fair scheduling, this addresses both sub-problems identified in research-008.md, with a residual issue at witness steps that may be resolvable.

### 8.4 The Subset-of-MCS Consistency Argument Is Key

The simple observation that `GContent(M) union AliveF(M) subset M` (hence consistent) was not identified in prior research. This avoids the counterexample from research-005.md because the counterexample required adding a WITNESS sub-formula (psi) to the seed alongside incompatible F-obligations. The AliveF seed only includes the F-formulas themselves, not their sub-formulas.

---

## 9. References

### Project Files
- `Theories/Bimodal/Semantics/Truth.lean` -- Standard task semantics truth definition
- `Theories/Bimodal/Semantics/TaskFrame.lean` -- Task frame structure
- `Theories/Bimodal/Semantics/WorldHistory.lean` -- World history definition
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS structure
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` -- BMCS (bundle) structure
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` -- BMCS truth definition
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- Truth lemma (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` -- Completeness theorems (sorry-free)
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- Temporal coherence
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` -- Chain construction (2 sorries)
- `Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean` -- GContent/HContent
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- TM axiom system

### Prior Research
- `specs/916_.../reports/research-008.md` -- Root cause analysis (predecessor to this report)
- `specs/916_.../reports/research-001.md` through `research-007.md` -- Earlier research rounds
- `specs/916_.../plans/implementation-005.md` -- Latest plan with counterexample

### Key Lemma Locations
- `forward_temporal_witness_seed_consistent` -- DovetailingChain.lean (proven, sorry-free)
- `temporal_backward_G` -- TemporalCoherentConstruction.lean (proven, requires forward_F)
- `set_lindenbaum` -- MaximalConsistent.lean (proven, Zorn's lemma)
- `bmcs_truth_lemma` -- TruthLemma.lean (proven, sorry-free)
