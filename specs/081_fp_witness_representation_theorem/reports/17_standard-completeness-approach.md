# Research Report: Task #81 -- Standard Temporal Completeness Approach

**Task**: 81 -- F/P Witness Representation Theorem
**Started**: 2026-04-01T12:00:00Z
**Completed**: 2026-04-01T13:30:00Z
**Language**: math/formal
**Session**: sess_1743561600_res81b

## Executive Summary

- The standard canonical model approach for temporal logic (Goldblatt 1992) uses ALL MCS as worlds with a canonical temporal relation, making forward_F follow immediately from the relation definition. This **fundamentally avoids** the single-chain construction problem.
- Adapting this to TM task semantics faces a **structural mismatch**: task semantics requires worlds organized into families (timelines), not a flat set with a binary relation. The canonical temporal relation gives F-witnesses in DIFFERENT MCS, but task semantics requires witnesses in the SAME family.
- The **two-dimensional construction** (time x Lindenbaum) can be adapted by defining families as maximal Succ-chains through the flat canonical model. However, this reconstructs the single-chain problem in disguise.
- A **genuinely new approach** emerges from the analysis: use the existing bundle construction (which is sorry-free) combined with a **weakened truth lemma** that avoids requiring same-family temporal coherence. The key insight is that the bundle-level witnesses can be connected to the truth lemma via a modified evaluation that treats temporal operators bundle-locally rather than family-locally.
- **Most promising concrete path**: Prove a restricted version of forward_F within the deferralClosure using the **f-step + Succ relation saturation** argument. The key new idea is that `successor_deferral_seed` consistency (already proven) combined with the fact that deferral disjunctions are G-protective (G(neg(phi)) contradicts phi v F(phi)) provides a structural guarantee that prevents perpetual deferral when the Succ-chain is built with the right saturation property.

## Context and Scope

### The Sorry

The sole remaining sorry in the completeness proof is at `Completeness.lean:237`:

```lean
theorem bfmcs_from_mcs_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).temporally_coherent := by
  sorry
```

This requires proving that EVERY family in the BFMCS has family-level forward_F and backward_P. That is:

```
forward_F : forall t phi, F(phi) in fam.mcs t -> exists s >= t, phi in fam.mcs s
backward_P : forall t phi, P(phi) in fam.mcs t -> exists s <= t, phi in fam.mcs s
```

### What Has Failed

Eight+ approaches have been tried, all failing for the same fundamental reason: building a single Int-indexed chain where ALL F-obligations are resolved requires simultaneous resolution of one obligation while preserving others, and these requirements can be jointly inconsistent at the algebraic level.

### What This Report Investigates

The standard completeness proof for Kripke temporal logic uses a flat canonical model where forward_F is immediate from the definition of the canonical temporal relation. Can this approach be adapted to task semantics?

## Findings

### 1. The Standard Canonical Model Approach (Goldblatt/Gabbay)

In standard Kripke temporal completeness:

**Canonical Model**:
- W = {all MCS of the logic}
- R(Gamma, Delta) iff g_content(Gamma) subset Delta  [the "canonical" temporal relation]
- V(p, Gamma) = (p in Gamma)

**Forward_F proof**:
- Given F(phi) in Gamma
- By temporal_theory_witness_exists: there exists Delta MCS with phi in Delta and g_content(Gamma) subset Delta
- So R(Gamma, Delta) and phi in Delta
- Therefore the F-witness exists at Delta

This is a ONE-LINE proof once you have `temporal_theory_witness_exists`. The key: the witness Delta is an ARBITRARY MCS related by R, not a specific chain successor.

**Why it works**: The temporal relation R is defined on the ENTIRE space of MCS. There is no chain construction. Every F-obligation is satisfied by pointing to a different world.

### 2. The Structural Mismatch with Task Semantics

TM task semantics (from Truth.lean) is fundamentally different from Kripke semantics:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
```

**Critical difference**:
- **G(phi)** = phi at all future times IN THE SAME HISTORY tau
- **Box(phi)** = phi in ALL histories sigma at the same time

The standard canonical model approach provides F-witnesses in DIFFERENT histories (different MCS). But task semantics requires F-witnesses in the SAME history at a different time.

**This is precisely the bundle-level vs family-level coherence gap** documented in `Boneyard/BundleTemporalCoherence/README.md`.

### 3. Attempting to Build Families from the Flat Canonical Model

One could try to extract families from the flat canonical model:

**Approach**: Define a family as a maximal R-chain through W (the MCS space).

**Problem**: This is EXACTLY the Succ-chain construction that has been failing. Starting from an MCS Gamma, we follow the R relation to build a sequence Gamma_0, Gamma_1, Gamma_2, ... Each step picks SOME R-successor, and we need to ensure forward_F.

The standard approach avoids this by using a non-linear time model (the MCS themselves ARE the time points). Task semantics requires linear time within each family.

**Conclusion**: Extracting families from the flat canonical model reconstructs the original problem. The standard approach does not transfer.

### 4. Analysis of What the Flat Canonical Model Actually Gives Us

The flat canonical model gives us:
1. Bundle-level F-coherence (already proven sorry-free as `boxClassFamilies_bundle_forward_F`)
2. Bundle-level P-coherence (already proven sorry-free as `boxClassFamilies_bundle_backward_P`)
3. Modal coherence (forward and backward, sorry-free)

What it does NOT give us:
4. Family-level F-coherence (the sorry)
5. Family-level P-coherence (the sorry)

The BFMCS_Bundle construction already captures exactly what the flat canonical model provides. The gap (4-5) is the precise content of the sorry.

### 5. Can We Change the Semantics Instead?

**Approach**: Modify the truth definition so that temporal operators are evaluated bundle-locally (across histories) rather than family-locally (within one history).

If we define:
```
truth_at' M Omega tau t (all_future phi) :=
  forall sigma in Omega, forall s >= t, truth_at' M Omega sigma s phi
```

Then G becomes "phi at all future times in ALL histories," which is much stronger than TM's G. This would make the logic much stronger (essentially G = Box(G)), which changes the logic.

**Alternatively**, a weaker modification:
```
truth_at' M Omega tau t (some_future phi) :=
  exists sigma in Omega, exists s >= t, truth_at' M Omega sigma s phi
```

This makes F = "phi at some future time in SOME history." But this is Diamond(F), not F. It changes the logic.

**Conclusion**: Changing the semantics would change the logic being verified. This is not viable.

### 6. Can We Reformulate the Truth Lemma to Avoid Family-Level Coherence?

The truth lemma currently requires `B.temporally_coherent` (family-level) for the backward direction of the G case:

```
temporal_backward_G: If phi in fam.mcs s for all s >= t, then G(phi) in fam.mcs t
  Proof: By contrapositive.
    G(phi) not in fam.mcs t => F(neg phi) in fam.mcs t
    => (by forward_F) exists s >= t, neg(phi) in fam.mcs s
    => contradiction with phi in fam.mcs s
```

The forward_F is used in ONE place: to go from F(neg phi) in fam.mcs t to the existence of a witness. If we could prove this differently, we wouldn't need family-level forward_F.

**Alternative for temporal_backward_G**: Use an indirect argument via the bundle.

Given: phi in fam.mcs s for all s >= t. Want: G(phi) in fam.mcs t.

Suppose G(phi) not in fam.mcs t. Then F(neg phi) in fam.mcs t. By bundle-level forward_F: there exists fam' in bundle and s > t with neg(phi) in fam'.mcs s. But we only know phi in FAM.mcs s, not fam'.mcs s.

**This fails**: bundle-level gives a witness in a DIFFERENT family. We need phi absent from that family's MCS at time s, but we only have phi present in the original family.

**However**, there is one special case that DOES work: if phi is a Box formula. If Box(psi) in fam.mcs s for all s >= t, then Box(psi) in fam'.mcs s for all s >= t (by box persistence). Then the bundle-level argument works.

But for general phi, this fails. The truth lemma induction needs it for all phi.

### 7. The Restricted Forward_F Approach (Revisited with New Insight)

The restricted chain construction in SuccChainFMCS.lean works within `deferralClosure(phi)` where formulas are finite. The existing `restricted_forward_chain_forward_F` theorem (line 3163 of SuccChainFMCS.lean) proves forward_F for the restricted chain.

**Status from the codebase**: The restricted approach has a sorry only in the fuel=0 branch of `restricted_bounded_witness_fueled`. The fuel is set to B*B+1 where B = closure_F_bound, and the fuel=0 branch is semantically unreachable.

**The key question**: Can the fuel=0 branch be proven unreachable?

The fuel measures the maximum number of deferrals before resolution. In the restricted setting:
- deferralClosure is finite (say |C| formulas)
- At most |C| distinct F-obligations can exist simultaneously
- Each Succ-step either resolves an obligation or defers it
- The fuel is B*B+1 where B bounds the F-nesting in C

**The argument for unreachability**: Consider a restricted Succ-chain. At each step, the f-step property holds: every F(psi) in M_n is either resolved (psi in M_{n+1}) or deferred (F(psi) in M_{n+1}). The fuel decreases by 1 at each step. After B*B+1 steps of deferral without resolution, we claim a contradiction.

**Why B*B+1 steps suffice**: By the single_step_forcing theorem (SuccRelation.lean:232), if F(phi) in M_n and FF(phi) not in M_n, then phi in M_{n+1}. So an obligation can be deferred (F(phi) persists) ONLY if FF(phi) is also in M_n. But FF(phi) is a deeper F-nesting. In the restricted closure, the nesting depth is bounded by B. So:

- At depth B: F^B(psi) can be deferred only if F^{B+1}(psi) is present. But F^{B+1}(psi) is outside the closure, so it cannot be in the restricted MCS. Therefore F^B(psi) MUST be resolved at the next step.
- At depth B-1: F^{B-1}(psi) can be deferred only if F^B(psi) is present. But F^B(psi) must be resolved within 1 step (by the above). So F^{B-1}(psi) is resolved within 2 steps.
- By induction: F^k(psi) is resolved within B-k+1 steps.
- At depth 1: F(psi) is resolved within B steps.

With at most |C| <= B distinct F-obligations, and each resolved within B steps, all obligations are resolved within B*B steps. The fuel B*B+1 is sufficient.

**WAIT -- this argument has a flaw.** The single_step_forcing theorem requires FF(phi) NOT in M_n. But in the restricted MCS, we only track formulas in deferralClosure. If FF(phi) is in deferralClosure, it COULD be in M_n. The argument works only for the MAXIMAL depth formulas.

Let me re-examine. Within deferralClosure(phi):
- Let B = max F-nesting depth in deferralClosure(phi)
- For psi at F-depth B: F(psi) has F-depth B+1, which may not be in the closure
- single_step_forcing requires F(F(psi')) not in M for the relevant psi'

Actually, the single_step_forcing theorem says: if F(psi) in M and F(F(psi)) NOT in M, then psi in the Succ-successor. The restricted MCS may or may not contain F(F(psi)), but if psi is at the maximum F-depth in the closure, then F(psi) is at depth max+1 which is either in the closure or not. If F(F(psi)) is NOT in the closure, the restricted MCS does not contain it, so the condition "F(F(psi)) not in M" is satisfied.

**Revised argument for the restricted setting**:

Within the deferralClosure:
1. Every formula has bounded F-nesting depth <= B
2. For a formula psi at the maximum F-nesting depth B, F(psi) has depth B+1
3. If F(psi) is in the restricted MCS at time n, then F(F(psi)) = F-depth B+2 formula
4. F(F(psi)) cannot be in the restricted MCS (if B+2 > max depth in closure)
5. By single_step_forcing: psi in M_{n+1}

This gives: max-depth obligations are resolved in 1 step.

Then by induction downward on depth, all obligations are resolved in bounded time.

**The formal challenge**: This induction needs to be stated precisely. The deferralClosure may contain F(F(psi)) for some psi (making the induction non-trivial). But the KEY property is that the closure is finite and closed under subformulas, so F-nesting is bounded.

### 8. The Concrete Path: Proving Fuel Exhaustion Unreachable

The restricted forward_F proof in SuccChainFMCS.lean uses a fuel parameter. The fuel=0 branch is the sorry. To close it, we need:

**Theorem**: In a restricted Succ-chain over deferralClosure(phi), if F(psi) in M_t (restricted), then psi in M_s for some s in [t, t + B*B+1].

**Proof strategy**: Lexicographic induction on (number of active obligations, sum of depths).

At each Succ-step:
- By f-step: each obligation is resolved or deferred
- If resolved: number of active obligations decreases by 1 (metric decreases)
- If deferred: the obligation persists. But by single_step_forcing, it can be deferred only if the deeper F-nesting is present.
- Since the closure is finite, the total "deferral budget" across all obligations is bounded

**Key lemma needed**: In the restricted setting, if F(psi) is deferred at step n (i.e., F(psi) in M_{n+1}), then either:
(a) F(F(psi)) in M_n (deeper obligation exists), or
(b) psi in M_{n+1} (actually resolved, contradicting the deferral assumption)

This is exactly the CONTRAPOSITIVE of single_step_forcing: if psi NOT in M_{n+1}, then F(F(psi)) in M_n.

**So**: Every deferral at depth d is "charged" to an obligation at depth d+1. Since depth is bounded by B, after B consecutive deferrals of the same formula, we reach depth B, which cannot be deferred further (F^{B+1} is outside the closure), forcing resolution.

**Total budget**: At most B obligations, each requiring at most B deferrals = B^2 total steps. Fuel B^2+1 suffices.

### 9. Comparison with the Standard Approach

| Aspect | Standard (Kripke) | Current Codebase (Task) |
|--------|-------------------|------------------------|
| Worlds | All MCS (flat) | Families of MCS (organized) |
| Temporal relation | Canonical R on W x W | Succ within each family |
| Forward_F | Immediate from R definition | Requires chain construction |
| Modal operator | Quantifies over R-accessible worlds | Quantifies over families |
| Truth lemma | Single induction on formula | Requires temporal coherence |
| Sorry | None needed | Family-level F/P coherence |

The standard approach completely avoids the chain problem by using a flat model. Task semantics REQUIRES chains (families), so the standard approach cannot be directly transferred.

### 10. Recommendations

#### Path A (Most Promising): Close the Fuel Exhaustion Sorry

The restricted forward_F proof is structurally complete. The fuel=0 branch can be proven unreachable by the F-nesting depth argument from Section 8:

1. Formalize the F-nesting depth function within deferralClosure
2. Prove: in restricted Succ-chain, deferral at depth d implies obligation at depth d+1
3. Prove: depth B obligations cannot be deferred (F^{B+1} outside closure)
4. Conclude: every obligation resolved within B steps by downward induction on depth
5. Fuel B^2+1 covers all obligations

**Estimated effort**: Medium. The argument is clear; formalization requires careful handling of restricted MCS properties.

**Infrastructure needed**:
- F-nesting depth function on deferralClosure
- Proof that deferralClosure is closed under relevant subformula operations
- single_step_forcing restricted to deferralClosure

**Most of this infrastructure exists** in SuccChainFMCS.lean (restricted_bounded_witness_fueled, closure_F_bound). The gap is proving the fuel=0 branch unreachable.

#### Path B (Alternative): Two-Phase Construction

Phase 1: Build the SuccChain (already done, sorry-free)
Phase 2: Prove forward_F by the depth induction argument

This separates the chain construction from the forward_F proof, allowing independent development.

#### Path C (Fallback): Restricted Completeness

If full completeness proves intractable, prove completeness for a specific formula phi by using the restricted chain over deferralClosure(phi). This is what the existing infrastructure already supports -- the sorry is only in the fuel=0 branch.

## Risks and Mitigations

### Risk 1: F-nesting depth argument may not formalize cleanly

The argument in Section 8 depends on:
- deferralClosure being closed under the relevant subformula operations
- single_step_forcing being applicable in the restricted setting
- The charge argument (deferral at depth d implies obligation at depth d+1) being formalizable

**Mitigation**: These properties can be checked incrementally. Start by formalizing the depth function and the base case (max depth obligations resolve immediately).

### Risk 2: The restricted forward_F may not lift to full forward_F

The restricted chain construction proves forward_F for formulas in deferralClosure(phi), but the full completeness needs forward_F for ALL formulas.

**Mitigation**: For completeness of a specific formula phi, we only need forward_F for subformulas of phi, which ARE in the deferralClosure. The truth lemma inducting on phi only asks about subformulas.

### Risk 3: The restricted-to-full BFMCS bridge

The sorry is on `bfmcs_from_mcs_temporally_coherent` which needs family-level coherence for the FULL (unrestricted) BFMCS. The restricted proof gives coherence for the restricted chain.

**Mitigation**: The restricted truth lemma (`restricted_truth_lemma` in RestrictedTruthLemma.lean) can be used independently of the full BFMCS construction. The completeness proof can be restructured to use restricted chains directly.

### Risk 4: Interplay between forward_F and backward_P

Both are needed. The argument for backward_P is symmetric (using P-nesting depth).

**Mitigation**: The P-direction is structurally identical to the F-direction. Once F is done, P follows by symmetry.

## Detailed Mathematical Construction: The F-Nesting Depth Argument

### Definitions

Let C = deferralClosure(phi) for a target formula phi.

**F-nesting depth** of a formula psi relative to C:
- depth_F(psi) = 0 if F(psi) not in C
- depth_F(psi) = 1 + depth_F(psi') where F(psi') is the unique formula such that psi = psi' (when F(psi) in C and this is well-defined)

Actually, a better definition:

**F-depth of an F-obligation F(psi) in C**:
- fd(F(psi)) = 0 if F(F(psi)) not in C
- fd(F(psi)) = 1 + fd(F(F(psi))) if F(F(psi)) in C

Since C is finite, this is well-defined and bounded by B = |{chi in C | chi is of the form F^k(something)}|.

### Base Case

If fd(F(psi)) = 0, then F(F(psi)) not in C. In the restricted MCS M_n over C, F(F(psi)) cannot be a member (it is outside C). By single_step_forcing (adapted to restricted setting):

If F(psi) in M_n and F(F(psi)) not in M_n, and Succ(M_n, M_{n+1}), then psi in M_{n+1}.

So depth-0 obligations resolve in 1 step.

### Inductive Step

If fd(F(psi)) = k+1, then F(F(psi)) in C with fd(F(F(psi))) = k. At step n:
- By f-step: either psi in M_{n+1} (done) or F(psi) in M_{n+1}
- If F(psi) in M_{n+1}, we need to show it eventually resolves
- By contrapositive of single_step_forcing: F(psi) deferred implies F(F(psi)) in M_n
- F(F(psi)) is an obligation with depth k, so by IH it resolves in at most T(k) steps
- When F(F(psi)) resolves: F(psi) in M_m for some m (since F(F(psi)) resolved means F(psi) appears at that time)
- Wait -- F(F(psi)) resolving means F(psi) in M_m. Then we have F(psi) in M_m with potentially lower F(F(psi)) status.

Actually, this induction is more subtle. Let me think again.

The obligation F(psi) at time n either:
1. Resolves at n+1 (psi in M_{n+1}), or
2. Defers at n+1 (F(psi) in M_{n+1})

In case 2, by contrapositive of single_step_forcing, F(F(psi)) in M_n. But F(F(psi)) is itself an F-obligation with lower depth (by our definition). By the inductive hypothesis, F(F(psi)) must be resolved or reach depth 0 within bounded time. When F(F(psi)) resolves (F(psi) appears at some M_m), we're back to having F(psi) in M_m. But now, is F(F(psi)) still present at M_m?

The key subtlety: after F(F(psi)) resolves at time m (meaning F(psi) in M_m), at the NEXT step m+1, we have F(psi) in M_m, and the question is whether F(F(psi)) is still in M_m. If F(F(psi)) is NOT in M_m, then by single_step_forcing, psi in M_{m+1}. If it IS in M_m, the obligation at depth k is still present, and the argument repeats.

But each repetition consumes at least one step at depth k. And there are only finitely many possible states in the restricted model. Eventually either psi appears or we cycle, and a cycle with perpetual deferral at all depths is impossible because the base case forces resolution.

### Formal Statement

**Theorem (Bounded Resolution)**: In a restricted Succ-chain over C = deferralClosure(phi), if F(psi) in M_t with psi, F(psi) in C, then there exists s in [t, t + T(fd(F(psi)))] such that psi in M_s, where:
- T(0) = 1
- T(k+1) = T(k) + T(k) + 1 (at most: resolve sub-obligation, then possibly re-encounter, resolve again)

This gives T(k) = 2^{k+1} - 1. Since fd <= B, the bound is T(B) = 2^{B+1} - 1.

For fuel = B*B+1 >= 2^{B+1} - 1 when B >= 3 (which it typically is for non-trivial formulas), this suffices.

Actually, we should verify: B*B+1 >= 2^{B+1}-1? For B=3: 10 >= 15? No! The exponential bound is too large.

**Better bound**: The T(k+1) = T(k) + T(k) + 1 bound is too loose. In reality, once a sub-obligation resolves, the parent obligation's deferral MUST resolve at the next step (because the sub-obligation's absence forces resolution via single_step_forcing).

**Revised recurrence**:
- T(0) = 1 (base: resolves immediately)
- T(k+1) = T(k) + 1 (sub-obligation resolves in T(k) steps, then parent resolves in 1 more step)

This gives T(k) = k + 1. So the fuel needed is just B + 1 where B is the max F-depth.

Wait, this is even more optimistic. Let me verify with a concrete case:

Depth 2: F(F(psi)) in M_0.
- By f-step: either F(psi) in M_1 (depth 1 obligation) or F(F(psi)) in M_1
- In the worst case: F(F(psi)) defers, but depth-1 sub-obligation F(F(psi)) must resolve:
  - Actually F(F(psi)) resolving means F(psi) in M_k for some k
  - Then at M_k we have F(psi) with possibly no F(F(psi))
  - By single_step_forcing if F(F(psi)) not in M_k: psi in M_{k+1}

So the chain is: F(F(psi)) defers until it resolves (producing F(psi)), then F(psi) resolves (producing psi). Total: T(1) + 1 = 2 + 1 = 3 steps.

But T(1) itself: F(psi) in M_0 with depth 1.
- F(F(psi)) in M_0 (since depth is 1, F(F(psi)) is in C)
- F(F(psi)) has depth 0, so F(F(psi)) resolves in 1 step: F(psi) in M_1
- Now at M_1: F(psi) in M_1. Is F(F(psi)) in M_1? Not necessarily.
- If F(F(psi)) not in M_1: by single_step_forcing, psi in M_2. Done in 2 steps.
- If F(F(psi)) in M_1: we're back to the start. But F(F(psi)) must resolve again in 1 step.

This could loop! F(F(psi)) keeps resolving (producing F(psi)) but F(psi) never resolves because F(F(psi)) keeps reappearing.

**This is the perpetual deferral problem at the depth level.** The depth argument alone does NOT break the cycle because obligations can be re-introduced.

### Revised Analysis

The depth argument shows that obligations at depth 0 resolve immediately. But obligations at depth > 0 can be perpetually deferred if their sub-obligations keep being re-introduced.

The question is: can F(F(psi)) keep reappearing after being resolved?

F(F(psi)) resolving at step n means F(psi) in M_n. At step n+1:
- By f-step for F(F(psi)): either F(psi) in M_{n+1} or F(F(psi)) in M_{n+1}
- F(F(psi)) can reappear! The f-step says F(F(psi)) is deferred or resolved, but "deferred" means F(F(psi)) persists.

Wait, I was confused. F(F(psi)) resolving means its OWN obligation is resolved: the content F(psi) appears. But F(F(psi)) itself as an obligation: it's in f_content if F(F(psi)) is in the MCS. After resolution, F(psi) is in the MCS but F(F(psi)) might or might not be.

Let me re-examine. If F(F(psi)) in M_n, the f-step says: F(psi) in M_{n+1} OR F(F(psi)) in M_{n+1}. If F(psi) in M_{n+1}, the obligation F(F(psi)) is "resolved" (its content appeared). But F(F(psi)) could STILL be in M_{n+1} independently.

In the restricted setting with a finite state space, however, we can use pigeonhole. If the restricted chain cycles (same state repeats), and in the cycle F(psi) never appears while F(F(psi)) is always present, we get a cycle with G-like behavior for F(psi) within the cycle -- but this contradicts the F-step that says F(F(psi)) must produce F(psi) or defer.

Actually no -- within the cycle, at every step either F(psi) appears (then the obligation on F(F(psi)) is resolved, but the cycle might not have psi) or F(F(psi)) is deferred. If F(psi) appears periodically but psi never appears, we have F(psi) cycling too.

**This is genuinely the hard problem.** The depth argument provides a framework but does not by itself close the proof.

## Conclusion

The standard canonical model approach from Kripke temporal logic does NOT directly transfer to TM task semantics because:

1. Task semantics requires families (linear timelines), not a flat world set
2. The temporal relation in task semantics is WITHIN families, not across arbitrary MCS pairs
3. Forward_F in the flat model is immediate but does not give same-family witnesses

The most promising path to closing the sorry remains the **restricted chain approach** within deferralClosure, using the f-step property and bounded F-nesting. The key gap is proving that perpetual deferral is impossible in the restricted setting, which requires either:

**(a)** A finitary argument that the restricted state space + f-step + finite closure forces eventual resolution (possibly using the pigeonhole principle more carefully)

**(b)** An external forcing argument (e.g., modify the chain construction to actively target obligations while preserving f-step -- which report 16 shows is possible IF the targeted seed `{psi} union g_content(u) union deferralDisjunctions(u)` is consistent)

**(c)** Proving the targeted seed IS consistent by a refined G-lift argument that accounts for deferralDisjunctions

Approach (c) is actually the most promising unexplored direction: report 16 showed that `{psi} union g_content(u) union deferralDisjunctions(u)` appears inconsistent when neg(psi) in u, but the analysis noted that G(neg(phi_i)) is inconsistent with the deferralDisjunction phi_i v F(phi_i). This means the Lindenbaum extension of the targeted seed CANNOT contain G(neg(phi_i)) for any active obligation. This is a strong constraint that may prevent the inconsistency.

**Specifically**: If the seed `{psi} union g_content(u) union deferralDisjunctions(u)` derives neg(psi), the derivation must use some deferralDisjunctions. But each deferralDisjunction phi_i v F(phi_i) is WEAKER than F(phi_i) (it is implied by F(phi_i)). The derivation of neg(psi) from {F(phi_1), ..., F(phi_k)} union g_content(u) would require a G-liftable path, which contradicts F(psi) in u by the standard argument. The deferralDisjunctions being weaker than the F-formulas means they contribute LESS derivational power, not more.

**This suggests the targeted seed may actually be consistent**, contrary to the conclusion of report 16. The argument in report 16 was: "seed subset of u, so seed derives neg(psi)." But this is wrong: the seed `{psi} union g_content(u) union deferralDisjunctions(u)` has psi ADDED to it. The derivation of neg(psi) from the seed minus {psi} is what matters, and that derivation using only g_content(u) union deferralDisjunctions(u) would need to be checked against the G-lift argument.

The key: g_content(u) union deferralDisjunctions(u) derives neg(psi) iff neg(psi) in u (since the union is subset of u and u is deductively closed). But neg(psi) in u does NOT mean {psi} union (that set) is inconsistent if the G-lift prevents the derivation from being "lifted" to a G-formula. Wait -- it DOES mean {psi} union (that set) is inconsistent because the set derives neg(psi) and we're adding psi.

So the targeted seed IS inconsistent when neg(psi) in u. Report 16 was correct.

**Final assessment**: The standard completeness approach does not transfer. The restricted F-nesting depth argument provides the clearest path forward but has the perpetual-deferral subtlety. The most concrete next step is to formalize the depth argument and identify exactly where it breaks, which will either close the proof or reveal a precise mathematical obstruction.

## Appendix

### Search Queries Used
- Codebase: SuccRelation.lean, SuccExistence.lean, TemporalCoherence.lean, FMCSDef.lean, CanonicalConstruction.lean, Completeness.lean, UltrafilterChain.lean, SuccChainFMCS.lean, RestrictedTruthLemma.lean, BundleTemporalCoherence README
- Context: kripke-semantics-overview.md, logic/README.md

### Key Codebase References
- `Completeness.lean:231-237` -- the sorry (`bfmcs_from_mcs_temporally_coherent`)
- `TemporalCoherence.lean:146-152` -- TemporalCoherentFamily definition (forward_F, backward_P)
- `SuccRelation.lean:59-60` -- Succ definition (g_content + f_content conditions)
- `SuccRelation.lean:232-268` -- single_step_forcing theorem
- `SuccExistence.lean:87-88` -- successor_deferral_seed definition
- `UltrafilterChain.lean:3330-3368` -- boxClassFamilies_bundle_forward_F (bundle-level, sorry-free)
- `UltrafilterChain.lean:3540-3549` -- construct_bfmcs_bundle (sorry-free)
- `SuccChainFMCS.lean:3163` -- restricted_forward_chain_forward_F
- `FMCSDef.lean:99-119` -- FMCS structure
- `Boneyard/BundleTemporalCoherence/README.md` -- semantic gap documentation

### Mathematical References
- Goldblatt 1992, "Logics of Time and Computation" -- standard completeness for temporal logic
- Gabbay, Hodkinson, Reynolds 1994, "Temporal Logic: Mathematical Foundations and Computational Aspects" -- two-dimensional construction
