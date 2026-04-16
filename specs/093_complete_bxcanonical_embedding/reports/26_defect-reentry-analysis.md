# Report 26: Defect Re-Entry Analysis for BXCanonical Forward_F

## Executive Summary

This report provides a complete first-principles analysis of the "Defect Re-Entry Cannot Happen" strategy for proving `rr_fwd_chain_forward_F`. The central finding is:

**Defect re-entry CAN happen in the existing chain construction, and perpetual deferral of a specific formula IS semantically consistent.** The existing `rr_fwd_chain` using `enriched_fwd_step` cannot prove `forward_F` as-is. The chain construction must be modified.

The analysis identifies the exact obstruction (the BX11 ordering can perpetually favor other formulas over the target), provides a concrete 2-formula counterexample scenario, and proposes a concrete fix: replace `enriched_fwd_step` with a **demand-driven step** that uses `discharge_single_step` for the target while embedding the enriched fold for F-obligation preservation within an iterated sub-chain.

---

## 1. Definitions from First Principles

### 1.1 Task Semantics

The system uses **reflexive** temporal operators on a linearly ordered time domain D:

| Operator | Semantic Definition | Reflexivity |
|----------|-------------------|-------------|
| G(phi) at t | forall s >= t, phi at s | Reflexive (>=) |
| H(phi) at t | forall s <= t, phi at s | Reflexive (<=) |
| F(phi) at t | exists s >= t, phi at s | Reflexive (>=) |
| P(phi) at t | exists s <= t, phi at s | Reflexive (<=) |
| phi U psi at t | exists s >= t, psi at s and forall r in [t,s), phi at r | Reflexive witness, open guard |
| phi S psi at t | exists s <= t, psi at s and forall r in (s,t], phi at r | Reflexive witness, open guard |

The BX axiom system includes:
- BX1: G(phi) -> phi (T-axiom, valid for reflexive G)
- BX11: F(A) ^ F(B) -> F(A^B) v F(A^F(B)) v F(F(A)^B) (temporal linearity)
- temp_4: G(phi) -> G(G(phi)) (4-axiom)

### 1.2 Chain Construction (Existing Code)

**FMCS** (Family of MCS, `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`):
```
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> G(phi) in mcs(t) -> phi in mcs(t')
  backward_H : forall t t' phi, t' <= t -> H(phi) in mcs(t) -> phi in mcs(t')
```

**g_content** (`TemporalContent.lean`):
```
g_content(M) = {phi | G(phi) in M}
```

**f_carry** (`CanonicalModel.lean`):
```
f_carry(M) = {phi in M | exists chi, phi = F(chi)}
```

**forward_temporal_witness_seed** (`WitnessSeed.lean`):
```
forward_temporal_witness_seed(M, psi) = {psi} union g_content(M)
```
Consistent when F(psi) in MCS M (proved sorry-free).

**enriched_fwd_step** (`RootScopedChain.lean`, line 583):
```
enriched_fwd_step(M, target, sigma_list) =
  if F(target) in M:
    let others = sigma_list.filter(chi => F(chi) in M)
    resolving_enriched_fwd_exists(M, target, others).choose
  else:
    fwd_succ(M, target)  -- non-resolving: g_content(M) union f_carry(M)
```

**rr_fwd_chain** (`RootScopedChain.lean`, line 659):
```
rr_fwd_chain(M0, sigma_list, 0) = M0
rr_fwd_chain(M0, sigma_list, n+1) =
  enriched_fwd_step(chain(n), rrSchedule(sigma_list, n), sigma_list)
```

### 1.3 Key Proven Properties

| Property | Statement | Status |
|----------|-----------|--------|
| `enriched_fwd_step_g_content` | g_content(chain(n)) subset chain(n+1) | Proved |
| `enriched_fwd_step_preserves` | F(chi) in chain(n) => chi in chain(n+1) OR F(chi) in chain(n+1) (chi in sigma_list) | Proved |
| `enriched_fwd_step_resolves_one` | At resolving step: exists w in sigma_list, F(w) in chain(n), w in chain(n+1) | Proved |
| `rr_fwd_chain_F_obligation_persists` | F(psi) in chain(n) => F(psi) in chain(n+1) (psi in sigma_list) | Proved |
| `rr_fwd_chain_F_obligation_absent` | F(psi) NOT in chain(n) => F(psi) NOT in chain(n+1) (any psi) | Proved |
| `no_new_f_defects` | G(neg alpha) in M, g_content(M) subset M' => F(alpha) NOT in M' | Proved |
| `phi_in_mcs_imp_F_phi` | phi in M => F(phi) in M (any MCS M) | Proved |
| `FF_imp_F_mcs` | F(F(psi)) in M => F(psi) in M | Proved |
| `bx11_earlier_total` | For F-defects psi1, psi2: bx11_earlier(M,psi1,psi2) OR bx11_earlier(M,psi2,psi1) | Proved |
| `target_resolving_fwd_exists_strong` | When target bx11-earliest: exists M' with target in M' AND F(chi) in M' for all others | Proved |

### 1.4 Sorry Sites (6 total in RootScopedChain.lean)

| # | Theorem | Line | Dependency |
|---|---------|------|------------|
| 1 | `rr_fwd_chain_forward_F` | 1321 | Core sorry |
| 2 | `dd_fmcs_forward_F` (t < 0 case) | 1352 | Depends on #1 |
| 3 | `dd_fmcs_backward_P` | 1359 | Symmetric to #1 |
| 4 | `dd_bfmcs_restricted_tc` | 1412 | Depends on #1, #3 |
| 5 | `dd_bfmcs_restricted_buc` | 1417 | Independent (Until/Since coherence) |
| 6 | `dd_bfmcs_restricted_fuc` | 1422 | Independent (Until/Since coherence) |

---

## 2. Analysis: F-Obligation Constancy

**Theorem (FO Constancy)**: The set FO = {chi in sigma_list | F(chi) in chain(n)} is the SAME for all n >= 0.

**Proof**:
- Non-decreasing: `rr_fwd_chain_F_obligation_persists` (requires chi in sigma_list).
- Non-increasing: `rr_fwd_chain_F_obligation_absent` (works for any formula, via contrapositive).

Both directions are proved in the codebase. This means:

```
FO(0) = FO(1) = FO(2) = ... = FO
```

This is already proved as `rr_fwd_chain_F_obligation_forward` (forward direction) and `rr_fwd_chain_F_obligation_backward` (backward direction).

---

## 3. The Defect Set and Re-Entry

**Definition**: The defect set at step n is:
```
D(n) = {chi in FO | chi NOT in chain(n)}
```

**Question**: Is D(n) monotonically non-increasing?

**Answer**: NO. Defect re-entry CAN happen.

### 3.1 Mechanism of Defect Re-Entry

Step-by-step trace:

1. **Step k**: chi in chain(k) (chi was resolved). Since chi in chain(k), F(chi) in chain(k) (by `phi_in_mcs_imp_F_phi`). chi NOT in D(k).

2. **Step k+1**: chain(k+1) = enriched_fwd_step(chain(k), target_k, sigma_list). The seed for chain(k+1) contains g_content(chain(k)) and the BX11 fold compound. By `enriched_fwd_step_preserves`: chi in chain(k+1) OR F(chi) in chain(k+1).

3. **If chi NOT in chain(k+1)**: Then F(chi) in chain(k+1) (from preserves). chi IS in D(k+1). **Defect re-entry has occurred.**

The enriched step gives only a DISJUNCTIVE guarantee. The Lindenbaum extension is non-constructive and may place chi outside the MCS while keeping F(chi).

### 3.2 Why g_content Does Not Prevent Re-Entry

chi in chain(k) does NOT imply G(chi) in chain(k). The g_content of chain(k) is {phi | G(phi) in chain(k)}, and chi might not have its G-version in chain(k). So chi does not propagate through g_content.

For chi to be in g_content(chain(k)), we would need G(chi) in chain(k), which requires chi to be a "globally true" formula -- not the general case.

---

## 4. Perpetual Deferral: A Concrete Counterexample Scenario

### 4.1 Setup

Consider FO = {psi, chi} (two F-defects). Assume:
- F(psi) in chain(m) and F(chi) in chain(m) for all m (FO constant).
- The BX11 compounds stabilize as follows:
  - F(chi ^ F(psi)) in chain(m) for all m (stable).
  - F(psi ^ chi) NOT in chain(m) for any m.
  - F(psi ^ F(chi)) NOT in chain(m) for any m.
  - F(F(psi) ^ chi) in chain(m) for all m (= F(chi ^ F(psi)) by F-conjunction-commutativity).

### 4.2 BX11 Ordering

From these compounds:
- bx11_earlier(chain(m), chi, psi) holds: F(chi ^ psi) NOT in M, but F(chi ^ F(psi)) in M. So the second disjunct gives bx11_earlier.
- bx11_earlier(chain(m), psi, chi) does NOT hold: F(psi ^ chi) NOT in M (= F(chi ^ psi) by commutativity, absent). F(psi ^ F(chi)) NOT in M. Both disjuncts fail.

So chi is **strictly bx11-earlier** than psi in every chain state.

### 4.3 What Happens at Each Step

**At psi's target step** (target = psi):
- The fold starts: beta = psi. Fold in chi.
- BX11(psi, chi): F(psi ^ chi) absent, F(psi ^ F(chi)) absent. Only option: F(F(psi) ^ chi) in M. This is case 3.
- Case 3: beta becomes F(psi) ^ chi. Witness changes from psi to chi.
- Result: chi in M' (resolved), F(psi) in M' (F-wrapped). **psi NOT resolved.**

**At chi's target step** (target = chi):
- The fold starts: beta = chi. Fold in psi.
- BX11(chi, psi): F(chi ^ psi) absent, F(chi ^ F(psi)) in M. This is case 2.
- Case 2: beta becomes chi ^ F(psi). Witness stays chi.
- Result: chi in M' (resolved), F(psi) in M' (preserved). **psi NOT resolved.**

### 4.4 Semantic Consistency

This scenario is semantically consistent. Consider a linear time model:
- Time points: t0 < t1 < t2 < t3 < ...
- chi holds at t1, t3, t5, ... (odd times).
- psi holds at t2, t4, t6, ... (even times > 0).

At any time t:
- F(chi ^ F(psi)): chi will hold at next odd time, and F(psi) holds there (psi at next even time). TRUE.
- F(chi ^ psi): chi and psi never hold simultaneously. FALSE.

So this ordering pattern is consistent with the BX axioms.

### 4.5 Conclusion

In this scenario, psi is perpetually deferred: at every step of the round-robin chain, the BX11 fold resolves chi (or preserves it as F-wrapped) but NEVER directly places psi in the successor MCS. The enriched step's `enriched_fwd_step_resolves_one` resolves chi at every step but never psi.

**Therefore: the existing `rr_fwd_chain` construction CANNOT prove `rr_fwd_chain_forward_F`.**

---

## 5. Compound F-Formula Monotonicity

### 5.1 Statement

For ANY formula alpha (not just sigma_list members):
```
F(alpha) NOT in chain(n) => F(alpha) NOT in chain(m) for all m > n
```

This is `rr_fwd_chain_F_obligation_absent`, which applies to ALL formulas via `no_new_f_defects`.

For COMPOUND F-formulas like F(A ^ B), F(A ^ F(B)), etc., this means:
- Once a compound disappears from the chain, it never returns.
- The set of compounds present is monotonically non-increasing.

### 5.2 What This Does NOT Give Us

The monotonicity applies to disappearance. But compound F-formulas can PERSIST indefinitely. In the perpetual deferral scenario, F(chi ^ F(psi)) persists forever, maintaining the unfavorable BX11 ordering.

The persistence is NOT a consequence of `enriched_fwd_step_preserves` (which requires membership in sigma_list). Instead, compound F-formulas persist because:
1. BX11 is applied at each MCS (it's an axiom schema).
2. F(chi) and F(psi) are always present (FO constant).
3. BX11 gives at least one compound. If only F(chi ^ F(psi)) was ever present, it persists.

More precisely: at each chain step, the new MCS is obtained by Lindenbaum extension. The MCS decides which BX11 disjunct holds. The non-constructive choice might always pick the same disjunct.

### 5.3 Stabilization

Since compound F-formulas can only disappear (not appear), the set of present compounds stabilizes after finitely many steps. After stabilization, the BX11 ordering is fixed.

This stabilization does NOT help prove forward_F, because the stabilized ordering can perpetually defer psi (as shown in Section 4).

---

## 6. Proposed Fix: Demand-Driven Chain Construction

### 6.1 The Core Idea

Replace the enriched step with a **two-phase construction** that guarantees the round-robin target is eventually resolved:

**Phase A (Target Resolution)**: Use `discharge_single_step` to build M'_A with:
- target in M'_A
- g_content(chain(n)) subset M'_A

**Phase B (F-Obligation Recovery)**: For each chi in FO \ {target} where F(chi) NOT in M'_A, use `discharge_single_step` again from M'_A to recover F(chi):
- Build M'_B extending g_content(M'_A) with chi in M'_B (from the original F(chi) in chain(n), which gives F(chi) in M'_A via... wait, F(chi) might NOT be in M'_A).

The problem: Phase A uses `forward_temporal_witness_seed` which gives {target} union g_content(M). This does NOT include f_carry. So F(chi) for other chi might NOT be in M'_A.

### 6.2 The Correct Fix: Persistent-Carry Step

Modify the forward step seed to:
```
{target} union g_content(M) union f_carry(M)
```

If this seed is CONSISTENT, then the Lindenbaum extension M' has:
- target in M' (resolved)
- g_content(M) subset M' (G-propagation)
- f_carry(M) subset M' (all F-formulas preserved)

With this step, forward_F follows immediately: at psi's round-robin visit, F(psi) in chain(m) (by FO constancy), so the persistent-carry step gives psi in chain(m+1).

### 6.3 The Consistency Challenge

The seed {target} union g_content(M) union f_carry(M) must be proved consistent when F(target) in M.

We know:
- {target} union g_content(M) is consistent (by `forward_temporal_witness_seed_consistent`).
- g_content(M) union f_carry(M) is consistent (by `enriched_seed_consistent`; both subsets of M).

But the UNION of these three might be inconsistent. The issue: g_content(M) contains formulas G(phi) stripped to phi, and f_carry(M) contains F(chi) formulas directly. Could {target, phi1, phi2, ..., F(chi1), F(chi2), ...} be inconsistent?

**All three components are subsets of M**:
- target: F(target) in M, but target itself might NOT be in M.
- g_content(M) subset M (by BX1: G(phi) -> phi, i.e., `g_content_subset_self`).
- f_carry(M) subset M (by definition: f_carry selects formulas that are in M).

So g_content(M) union f_carry(M) subset M. But {target} union g_content(M) union f_carry(M) might NOT be a subset of M (target might not be in M).

The consistency proof from `forward_temporal_witness_seed_consistent` handles {target} union g_content(M) by using the generalized temporal K argument. Can this be extended to include f_carry(M)?

**Key insight**: {target} union g_content(M) union f_carry(M) = {target} union (g_content(M) union f_carry(M)). Since g_content(M) union f_carry(M) subset M, and M is consistent, g_content(M) union f_carry(M) is consistent. And target is consistent with g_content(M) (by forward_temporal_witness_seed_consistent).

But is target consistent with f_carry(M)? I.e., is {target} union f_carry(M) consistent?

If target is consistent with g_content(M), and f_carry(M) subset M, and g_content(M) subset M, then:
- Suppose {target} union g_content(M) union f_carry(M) is inconsistent.
- Then there exist L subset {target} union g_content(M) union f_carry(M) with L |- bot.
- Case: target NOT in L. Then L subset g_content(M) union f_carry(M) subset M. But M is consistent. Contradiction.
- Case: target in L. Then L = {target} union L', where L' subset g_content(M) union f_carry(M) subset M. We need L' union {target} |- bot.
- By deduction: L' |- neg(target).
- Since L' subset M and M is consistent: neg(target) in M (by MCS closure).
- So target NOT in M (by MCS consistency).
- Now: F(target) in M and neg(target) in M. Is this consistent? YES -- F(target) says target holds at some FUTURE time, not at the current time. neg(target) says target does not hold NOW. This is consistent (target will hold later but not now).

So from L' |- neg(target) we get neg(target) in M. Now we need to derive a contradiction.

We have F(target) in M and neg(target) in M. Can we derive bot from these?

F(target) = neg(G(neg(target))). And neg(target) in M. From temp_t: G(neg(target)) -> neg(target). But we have neg(target), not G(neg(target)). G(neg(target)) would mean neg(target) holds at all future times. F(target) says target holds at some future time. These are contradictory.

But we have neg(target) in M, which is weaker than G(neg(target)) in M.

So the generalized temporal K argument from forward_temporal_witness_seed_consistent does NOT directly extend. The issue: L' contains formulas from f_carry(M) that are NOT in g_content(M). The generalized temporal K lifts derivations in L' to G-derivations, but this only works when L' subset g_content(M) (so each formula has a G-version in M).

For f_carry formulas F(chi): we would need G(F(chi)) in M to lift them. G(F(chi)) means "at all future times, F(chi) holds". This follows from F(chi) in M if we can show G(F(chi)) from F(chi). But:
- F(chi) = neg(G(neg(chi))).
- G(F(chi)) = G(neg(G(neg(chi)))).
- From temp_4: G(neg(chi)) -> G(G(neg(chi))). Contrapositive: neg(G(G(neg(chi)))) -> neg(G(neg(chi))). I.e., F(G(neg(chi))) -> F(chi). This gives F(chi) from F(G(neg(chi))), not the other way.
- We need: F(chi) -> G(F(chi)). I.e., neg(G(neg(chi))) -> G(neg(G(neg(chi)))). This is NOT derivable in general!

So **G(F(chi)) does NOT follow from F(chi)**. This is the fundamental obstacle: we cannot lift f_carry formulas through the generalized temporal K argument.

### 6.4 Alternative: The Enriched-Persistent Seed

Instead of {target} union g_content(M) union f_carry(M), use the BX11 fold to produce a compound beta with F(beta) in M such that from beta in M': target in M' AND F(chi) in M' for all chi in FO.

This is exactly what `target_resolving_fwd_exists_strong` provides -- but ONLY when target is bx11-earliest.

**When target is NOT bx11-earliest**: We cannot guarantee target in M' directly.

### 6.5 The Actual Fix: Rebuild the Chain with Ordered Resolution

The correct approach is to **change the chain construction** to not use the round-robin schedule for the enriched step, but instead:

1. **Demand-driven scheduling**: When forward_F is needed for a specific psi at step n, build a custom sub-chain from chain(n) that resolves psi.

2. **Sub-chain construction**: From chain(n) with F(psi) in chain(n):
   - Step 1: Use `discharge_single_step` to get M' with psi in M' and g_content(chain(n)) subset M'.
   - This resolves psi (psi in M'). But F-obligations for other chi might be lost.
   - Step 2: From M', use `fwd_succ` with each remaining chi to recover F-obligations.

3. **The witness is just M'**: We don't need to maintain the chain structure. We only need to show EXISTS s > n with psi in chain(s). If we can show psi in chain(n+1) for the right definition of chain(n+1), we're done.

But we can't change chain(n+1) -- it's already defined by `rr_fwd_chain`.

### 6.6 The Non-Constructive Escape

Actually, re-reading the sorry carefully:

```lean
theorem rr_fwd_chain_forward_F (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀)
    (sigma_list : List Formula) (h_nonempty : sigma_list.length > 0)
    (n : Nat) (ψ : Formula)
    (hψ : ψ ∈ sigma_list)
    (h_F : Formula.some_future ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list n).val) :
    ∃ s : Nat, n < s ∧ ψ ∈ (rr_fwd_chain M₀ h₀ sigma_list s).val := by
  sorry
```

The chain is ALREADY built (non-constructively). We need to show that the non-constructive choice at each step MUST eventually include psi. We don't get to CHOOSE the chain -- we need to prove a property of the existing one.

The key question: does the BX axiom system force psi into some chain(s)?

From `rr_fwd_chain_F_propagate` (proved):
```
For all m >= n: either exists s in (n, m+1] with psi in chain(s), or F(psi) in chain(m+1).
```

So either psi appears at some point, or F(psi) persists forever. We need to rule out the "F(psi) persists forever" case.

**Suppose for contradiction that psi NOT in chain(s) for ALL s > n.**

Then for all m >= n: F(psi) in chain(m+1) (from F_propagate).
And for all m >= n: psi NOT in chain(m+1).
So G(neg(psi))... wait, psi NOT in chain(m+1) does NOT mean neg(psi) in chain(m+1). It means psi is not in the MCS. By MCS maximality, neg(psi) IS in chain(m+1) (since the MCS is maximal: for any formula, either it or its negation is in the MCS).

So: neg(psi) in chain(m) for all m > n. And F(psi) in chain(m) for all m >= n. Both neg(psi) and F(psi) are in chain(m) for all m > n.

Now, F(psi) = neg(G(neg(psi))). So we have neg(G(neg(psi))) and neg(psi) both in every chain(m) for m > n.

This is NOT a contradiction by itself. neg(psi) says psi doesn't hold NOW, and F(psi) = neg(G(neg(psi))) says it's not the case that neg(psi) holds at ALL future times. These are compatible: psi might hold at some future time not yet in the chain.

But the chain is INFINITE. For ALL m > n, neg(psi) is in chain(m). So psi NEVER holds in the chain. But F(psi) says psi WILL hold at some future time. In the chain model, "future" means a later index. So F(psi) in chain(m) means there should exist s > m with psi in chain(s). But psi is never in chain(s).

This would make the model UNSOUND for F(psi). The truth lemma would fail: F(psi) in the MCS at time m, but there's no future time where psi is true.

**But we haven't proved the truth lemma yet -- the truth lemma itself depends on forward_F!**

So the argument is CIRCULAR. We can't use the truth lemma to derive a contradiction, because the truth lemma requires forward_F as a hypothesis.

### 6.7 Can the Axiom System Help?

Is there an axiom-level argument (without the truth lemma) that derives a contradiction from "neg(psi) in chain(m) for all m > n" and "F(psi) in chain(m) for all m >= n"?

Key observations:
1. neg(psi) in chain(m) for all m > n. By the chain's g_content propagation: G(neg(psi)) in chain(n+1)? NO -- g_content propagation goes from chain(n) to chain(n+1), not the reverse. We'd need "neg(psi) in chain(m) for all m >= n+1" to conclude G(neg(psi)) in chain(n+1) via a backward G argument. But backward G requires forward_F!

2. Actually, `restricted_temporal_backward_G_strict` (TemporalCoherence.lean, line 376) says:
   ```
   If phi in fam.mcs(s) for all s > t, and forward_F is available, then G(phi) in fam.mcs(t).
   ```
   But this REQUIRES forward_F as a hypothesis. Circular.

3. Without forward_F, can we derive G(neg(psi)) in chain(n) from neg(psi) in chain(m) for all m > n?
   - The chain has g_content(chain(m)) subset chain(m+1) for all m.
   - If G(neg(psi)) in chain(m), then neg(psi) in g_content(chain(m)) subset chain(m+1). This propagates neg(psi) forward.
   - But we need G(neg(psi)) in chain(m) in the first place. Where does it come from?
   - G(neg(psi)) in chain(m) means neg(psi) in g_content(chain(m)), i.e., G(neg(psi)) in chain(m).
   - This is just restating the hypothesis.

4. The chain does NOT have a "backward G" property without forward_F. So we CANNOT derive G(neg(psi)) from "neg(psi) in all future chain states".

**Conclusion**: There is NO purely axiom-level argument within the EXISTING chain structure that can derive forward_F. The chain construction MUST be modified.

---

## 7. The Required Modification

### 7.1 Option A: Persistent-Carry Seed Consistency

Prove that {target} union g_content(M) union f_carry(M) is consistent when F(target) in MCS M.

**Approach**: Extend the generalized temporal K argument.

The standard argument (from `forward_temporal_witness_seed_consistent`): assume L subset {target} union g_content(M) with L |- bot. Partition L into {target} and L_g subset g_content(M). By deduction: L_g |- neg(target). By generalized temporal K: G(L_g) |- G(neg(target)). Since G(chi) in M for all chi in L_g, by MCS closure: G(neg(target)) in M. But F(target) = neg(G(neg(target))) in M. Contradiction.

For the extended seed: L subset {target} union g_content(M) union f_carry(M) with L |- bot. Partition into {target}, L_g subset g_content(M), L_f subset f_carry(M).

By deduction: L_g union L_f |- neg(target). We need to lift this to a G-derivation. But L_f contains F-formulas, not G-formulas. We cannot apply generalized temporal K to L_f.

**Possible workaround**: Use the fact that f_carry(M) subset M. So L_g union L_f subset g_content(M) union M = M (since g_content(M) subset M by BX1). By MCS closure: neg(target) in M. Combined with F(target) in M:

Actually wait. L |- bot with L = {target} union L_g union L_f. By deduction: L_g union L_f |- neg(target). Since L_g union L_f subset M and M is MCS: neg(target) in M. But we also have F(target) in M. F(target) and neg(target) are NOT contradictory (as discussed in Section 6.6).

So this approach FAILS. The seed {target} union g_content(M) union f_carry(M) is NOT provably consistent from F(target) in M alone.

**However**, it IS consistent -- because g_content(M) union f_carry(M) subset M, and {target} union g_content(M) is consistent (proved). The issue is that {target} might be inconsistent with f_carry(M). But f_carry(M) subset M, and the only way {target} is inconsistent with a subset of M is if neg(target) follows from that subset. And since f_carry(M) subset M, neg(target) would be in M. But F(target) in M and neg(target) in M are compatible. So we CAN'T derive bot.

Wait, actually that argument IS sound! Let me redo it.

Suppose {target} union g_content(M) union f_carry(M) is inconsistent. Then there exist L = {target} union L' with L' subset g_content(M) union f_carry(M) subset M, and L |- bot.

By deduction: L' |- neg(target). Since L' subset M and M is MCS: neg(target) in M.

Also F(target) in M. We need a contradiction. We have neg(target) in M and F(target) = neg(G(neg(target))) in M.

neg(G(neg(target))) and neg(target) in M. Is this contradictory? neg(G(neg(target))) means NOT(G(neg(target))), i.e., G(neg(target)) is NOT in M (since neg(G(neg(target))) and G(neg(target)) cannot both be in an MCS).

So G(neg(target)) NOT in M. And neg(target) IN M. These are compatible: neg(target) holds now, but G(neg(target)) doesn't hold (so neg(target) might not hold at all future times).

No contradiction. So we CANNOT prove the extended seed is consistent using this approach.

**But wait**: let me reconsider. The argument above shows that if the seed is inconsistent, then neg(target) in M. But the standard argument from `forward_temporal_witness_seed_consistent` shows that {target} union g_content(M) being inconsistent leads to G(neg(target)) in M, which contradicts F(target). The STRONGER conclusion G(neg(target)) comes from the generalized temporal K applied to the g_content part.

In the extended case: L = {target} union L_g union L_f with L_g subset g_content(M) and L_f subset f_carry(M). By deduction: L_g union L_f |- neg(target).

We CANNOT apply generalized temporal K to the whole thing (L_f is not from g_content). But can we separate the argument?

From L_g union L_f |- neg(target), we want to derive G(neg(target)) in M.

If L_f is empty: standard argument gives G(neg(target)) in M, contradiction with F(target).

If L_f is non-empty: we have some F-formulas in the derivation. Can we "push them outside"?

Each formula in L_f is of the form F(chi_i) for some chi_i. We have L_g union {F(chi_1), ..., F(chi_k)} |- neg(target).

We want: G(L_g) union {G(F(chi_1)), ..., G(F(chi_k))} |- G(neg(target)).

By generalized temporal K: if L |- phi, then G(L) |- G(phi). So G(L_g union L_f) |- G(neg(target)).

G(L_g union L_f) = {G(phi) | phi in L_g} union {G(F(chi_i)) | i}.

For phi in L_g: G(phi) in M (since phi in g_content(M)).

For F(chi_i) in L_f: G(F(chi_i)) in M? This requires G(F(chi_i)) to be in M. As discussed, G(F(chi)) does NOT follow from F(chi) in M in general.

**So this approach is STUCK on G(F(chi)) not being derivable from F(chi).**

### 7.2 Option B: Demand-Driven Custom Chain

Instead of modifying the forward step, change the chain definition entirely.

Define a new chain where at each step, the target is GUARANTEED to be resolved:

```
custom_chain(M0, sigma_list, 0) = M0
custom_chain(M0, sigma_list, n+1) =
  let target = rrSchedule(sigma_list, n)
  if F(target) in chain(n):
    discharge_single_step(chain(n), target).choose
  else:
    fwd_succ(chain(n), target)
```

This uses `discharge_single_step` which gives {target} union g_content(chain(n)). The target IS resolved (target in chain(n+1)). But F-obligations for other formulas are NOT preserved.

With this chain: forward_F is trivial (psi is resolved at its next visit step).

But F-obligation constancy FAILS. F(chi) might disappear from the chain. This means FO is NOT constant, and `no_new_f_defects` gives monotonic non-increase, but not stability.

Actually, does this matter? Let's trace through what we need.

For `restricted_temporally_coherent`: for each phi in deferralClosure(root), if F(phi) in fam.mcs(t), then exists s > t with phi in fam.mcs(s).

With the custom chain: if F(phi) in chain(n), then at phi's next visit step m > n, the chain resolves phi IF F(phi) is still in chain(m). But F(phi) might have disappeared between n and m!

So we'd need F-obligation persistence, which we DON'T have with `discharge_single_step`.

### 7.3 Option C: Hybrid Chain (Most Promising)

Use `enriched_fwd_step` normally (preserving F-obligations), but MODIFY the resolving step to use a combination that guarantees the target is resolved.

**Key idea**: At the resolving step for target, instead of using the BX11 fold that gives disjunctive control, use `target_resolving_fwd_exists_strong` with the bx11-earliest formula as the actual target, then use an ADDITIONAL step to resolve the round-robin target.

Or more simply: **use multiple sub-steps to resolve each defect in bx11 order**.

**Multi-step resolution block**: Given FO at step n, iterate through FO in bx11 order:
1. Let d1 be the bx11-earliest defect. Use `target_resolving_fwd_exists_strong` to get M' with d1 in M' and F(chi) in M' for all chi in FO \ {d1}.
2. In M', the defect set has changed: d1 is resolved. The remaining defects are FO \ {d1} (since F(chi) in M' for each).
3. Let d2 be the bx11-earliest among the remaining defects in M'. Use `target_resolving_fwd_exists_strong` again.
4. Repeat until all defects are resolved.

After |FO| sub-steps, every formula in FO is resolved (in the final sub-step's MCS).

**Problem**: The sub-steps are not part of the `rr_fwd_chain`. We'd need to define a new chain.

**But**: `target_resolving_fwd_exists_strong` requires the target to be bx11-earliest among ALL others (in the current MCS). After resolving d1, the new MCS M' might have a different bx11 ordering. And the "others" in M' are the formulas with F-obligation in M', which is FO \ {d1}... wait, no. F(d1) is in M' (since d1 in M' gives F(d1) in M'). So d1 is still in the F-obligation set. It's just not a DEFECT anymore (d1 is in M').

Actually: after resolving d1, we have d1 in M' AND F(d1) in M'. For the remaining defects, we have F(chi) in M' (guaranteed by `target_resolving_fwd_exists_strong`). Now, at step 2: the target is d2 (bx11-earliest among defects D' = D \ {d1}). We need d2 to be bx11-earliest among ALL F-defects in M', which includes d1 (since F(d1) in M'). But d1 is NOT a defect (d1 in M'). The "others" for `target_resolving_fwd_exists_strong` includes all formulas with F-obligation in M' EXCEPT d2. This includes d1.

`target_resolving_fwd_exists_strong` requires d2 to be bx11_earlier than ALL others (including d1). Is this guaranteed?

Not necessarily. d1 might be bx11-earlier than d2 in M'. Then we can't use `target_resolving_fwd_exists_strong` with d2 as target.

**Fix**: At step 2, use the bx11-earliest among ALL F-defects in M' (not just the remaining defects). If d1 is no longer a defect but still has F-obligation, it might still be bx11-earliest. In that case, resolve d1 again (it's already resolved, so this is a no-op in terms of defects, but the fold gives M'' with d1 in M'' and others F-protected).

This doesn't help -- we'd keep resolving d1 and never get to d2.

### 7.4 Option D: The Right Fix -- LMCS Chain with Persistent Resolution

The correct approach, used in the standard literature (e.g., Goldblatt 1992, Reynolds 2003), is to build the chain so that **once a formula enters the chain, it stays in all subsequent states** (within its temporal scope).

This requires using a "dovetailing" or "step-by-step construction" where the seed at step n includes ALL formulas from step n-1 that should persist, plus the newly resolved formula.

In our setting: define chain(n+1) as a Lindenbaum extension of:
```
chain(n) union {target}
```
when F(target) in chain(n). This is equivalent to chain(n) itself (since we're extending an MCS -- adding target to an MCS either is already in it or is inconsistent with it).

**This doesn't work** because MCS is already maximal. We can't "add" formulas to an MCS.

The correct approach in the literature is to build a **sequence of APPROXIMATIONS** (finite consistent sets) that converge to an MCS, rather than building a sequence of MCSs. At each step, add one formula to the approximation.

But this is a major restructuring of the chain construction.

---

## 8. Recommended Strategy

### 8.1 Immediate Fix: Replace rr_fwd_chain with target-guaranteed chain

Replace the `enriched_fwd_step` with a new step function that:

1. Uses `discharge_single_step` for the target (guarantees target in M').
2. Uses `enriched_fwd_step` (with BX11 fold) for a SECOND step from M' to recover F-obligations.

**New 2-step chain**: At each round-robin step n:
```
M_half = discharge_single_step(chain(n), target).choose
  -- target in M_half, g_content(chain(n)) subset M_half
chain(n+1) = enriched_fwd_step(M_half, target, sigma_list)
  -- F-obligations from M_half preserved
```

But: does F(chi) survive from chain(n) to M_half to chain(n+1)?

chain(n) has F(chi). M_half extends g_content(chain(n)). Does F(chi) survive to M_half?

Not necessarily. `discharge_single_step` only guarantees g_content(chain(n)) subset M_half. F(chi) is not in g_content(chain(n)) (g_content strips to the formula inside G, not F).

So F(chi) might NOT be in M_half. Then `enriched_fwd_step` from M_half won't have F(chi) to preserve.

**This approach fails** for the same reason: F-obligations don't propagate through g_content.

### 8.2 The Correct Fix: Prove Persistent-Carry Seed Consistency

The entire problem reduces to one mathematical question:

**Is {target} union g_content(M) union f_carry(M) consistent when F(target) in MCS M?**

If YES: replace the chain step to use this seed, and forward_F follows trivially.
If NO: the chain construction fundamentally cannot prove forward_F, and a different approach is needed.

**Conjecture: YES, it IS consistent.**

**Proof sketch**: Suppose L subset {target} union g_content(M) union f_carry(M) with L |- bot.

Partition: L = L_t union L_g union L_f where L_t subset {target}, L_g subset g_content(M), L_f subset f_carry(M).

Case 1: target NOT in L. Then L = L_g union L_f subset M. M is consistent. Contradiction.

Case 2: target in L. By deduction: L_g union L_f |- neg(target).

Each chi in L_f is of the form F(chi_i) for some chi_i. So L_f = {F(chi_1), ..., F(chi_k)}.

From L_g union L_f |- neg(target), and L_g union L_f subset M, we get neg(target) in M.

Now: F(target) in M and neg(target) in M. We need to derive a contradiction.

**Key**: We ALSO have F(chi_1), ..., F(chi_k) in M. And the derivation L_g union L_f |- neg(target) "uses" these F-formulas.

Consider: L_g union {F(chi_1), ..., F(chi_k)} |- neg(target). By generalized temporal K: G(L_g) union {G(F(chi_1)), ..., G(F(chi_k))} |- G(neg(target)).

We need G(F(chi_i)) in M. This is the CRUX.

F(chi) in M. Does G(F(chi)) follow?

G(F(chi)) = G(neg(G(neg(chi)))). In S5+linear time, G(F(chi)) is derivable from F(chi)?

In S5 modal logic alone, Box(Diamond(p)) follows from Diamond(p). But our G is temporal, not modal.

In linear temporal logic: G(F(p)) means "always eventually p". F(p) means "eventually p". G(F(p)) does NOT follow from F(p). F(p) says p holds at some future time; G(F(p)) says at every future time, p holds at some still later time.

So **G(F(chi)) does NOT follow from F(chi)**. The generalized temporal K approach cannot be completed.

### 8.3 Alternative Consistency Proof

Is there another way to prove {target} union g_content(M) union f_carry(M) consistent?

**Approach via BX11 fold**:

F(target) in M and F(chi_i) in M for each i. By iterated BX11 (the fold from `enriched_fwd_fold`), produce F(beta) in M where beta encodes target and all chi_i.

The fold gives: from beta in M', for each formula either direct or F-protected. The DIRECT witness is one specific formula (the bx11-earliest, or the last case-3 formula).

If target is the direct witness: beta in M' gives target in M'. And from beta in M', all chi_i are either direct or F-protected. In particular, F(chi_i) in M' for each i (either directly from chi_i in M' via phi_imp_F_phi, or from F(chi_i) in M' directly).

So from beta in M': target in M' and F(chi_i) in M' for all i.

Now: {beta} union g_content(M) is consistent (by `forward_temporal_witness_seed_consistent` with F(beta) in M).

Lindenbaum extend to M'. M' has beta, so target in M' and F(chi_i) in M'. M' also has g_content(M).

So {target} union g_content(M) union f_carry(M) subset M' (since f_carry(M) = {F(chi_i)} subset M').

M' is consistent, so {target} union g_content(M) union f_carry(M) is consistent!

**But this only works when target IS the direct witness of the fold!** If target is NOT the direct witness (e.g., case 3 fired during the fold, changing the witness to some chi_j), then target is only F-protected in M', not directly present.

From `target_stays_direct_in_fold`: when target is bx11_earlier than all others, target IS the direct witness. This is proved and sorry-free.

So: **{target} union g_content(M) union f_carry(M) is consistent when target is bx11-earliest among all F-defects.**

When target is NOT bx11-earliest: the consistency is NOT established.

### 8.4 The Missing Piece

The problem reduces to: for each psi in FO, we need to find SOME chain state where psi is the bx11-earliest (or where the BX11 fold resolves psi directly).

As shown in Section 4, the bx11 ordering can be fixed: chi might ALWAYS be bx11-earlier than psi in every chain state. In that case, psi is never bx11-earliest, and we cannot use `target_resolving_fwd_exists_strong`.

### 8.5 Final Recommendation: Restructure the Chain with Ordered Resolution Blocks

The correct fix requires defining a NEW chain type:

**Ordered-Resolution Block Chain**: Instead of a simple round-robin, use BLOCKS of |FO| steps:

1. At the start of each block (step n), let D = list of current defects sorted by bx11 ordering.
2. Resolve D[0] (bx11-earliest) using `target_resolving_fwd_exists_strong`. Get M' with D[0] in M' and F(chi) in M' for all other chi.
3. From M', the defect set changes. Resolve the next bx11-earliest.
4. Continue for |FO| steps.

After each block, some defects have been resolved (and some might have re-entered).

**Key insight**: After resolving D[0], D[0] is no longer a defect. Even if D[0] re-enters the defect set later, the TOTAL number of resolution events grows. Since FO is finite and the bx11 ordering stabilizes (compound F-formulas are monotonically non-increasing), eventually every formula gets resolved.

**Formal measure**: Let S(n) be the multiset of "last resolution step" for each formula in FO:
```
S(n) = {(chi, last_step(chi, n)) | chi in FO}
where last_step(chi, n) = max{m <= n | chi in chain(m)} (or 0 if never resolved)
```

At each resolving step, S strictly increases (in some component). Since S is bounded by the step index, this would give termination.

But this is NOT a well-founded measure on Nat (because re-entry means S can decrease in some components while increasing in others).

---

## 9. Assessment

### 9.1 The Core Obstruction

The BX11 fold provides only **disjunctive** control: for each formula, either it is directly resolved or F-protected. The choice of which formula is directly resolved depends on the non-deterministic BX11 ordering, which can perpetually favor one formula over another.

### 9.2 Effort Estimates

| Approach | Description | Estimated Effort | Likelihood |
|----------|-------------|-----------------|------------|
| **Persistent-carry consistency** | Prove {target} union g_content(M) union f_carry(M) consistent | 10-20h | LOW (G(F(chi)) obstruction) |
| **Ordered resolution chain** | New chain with bx11-ordered resolution blocks | 30-50h | MEDIUM (complex chain definition) |
| **Literature chain** | Follow Goldblatt/Reynolds approximation construction | 40-60h | HIGH (well-established, but major restructuring) |
| **Direct axiom-level argument** | Find an axiom-level proof that psi must enter the chain | 5-10h pen-and-paper | MEDIUM (if it exists, simplest fix) |

### 9.3 Blocking Status

All 6 sorries remain blocked by the same fundamental issue. Sorry 5 (backward Until/Since coherence) and Sorry 6 (forward Until/Since coherence) might have independent issues related to Until/Since resolution, but they also depend on the temporal coherence infrastructure.

### 9.4 Immediate Next Steps

1. **Pen-and-paper exploration** (highest priority, 5-10h): Investigate whether there is a purely syntactic argument using the BX axioms that, given F(psi) in all chain states and neg(psi) in all chain states, derives a contradiction WITHOUT using forward_F or the truth lemma. Look at BX9/BX10 (Until induction) and BX11 (linearity) for inspiration.

2. **Persistent-carry consistency** (second priority): Despite the G(F(chi)) obstruction in the generalized temporal K approach, investigate whether a DIFFERENT consistency proof technique works. For example, using BX11 fold directly (as in Section 8.3) to establish consistency when target is bx11-earliest, then using the round-robin to cycle through all possible "earliest" formulas.

3. **If both fail**: Restructure the chain using the literature construction (approximation-based), which is known to work but requires significant code changes.

---

## 10. Summary of Findings

1. **FO constancy is proved**: The set of F-obligations is constant along the chain. This is already in the codebase.

2. **Defect re-entry CAN happen**: A formula can be resolved at step k and re-enter the defect set at step k+1. The enriched step provides only disjunctive guarantees.

3. **Perpetual deferral IS semantically consistent**: The BX11 ordering can perpetually favor one formula, preventing another from ever being resolved. A concrete 2-formula scenario demonstrates this.

4. **The existing chain cannot prove forward_F**: The `rr_fwd_chain` with `enriched_fwd_step` does not provide sufficient guarantees.

5. **The fundamental obstruction is G(F(chi)) not following from F(chi)**: This prevents the generalized temporal K argument from extending to seeds containing F-formulas.

6. **The chain construction must be modified**: Either the seed, the scheduling strategy, or the entire chain structure must change.
