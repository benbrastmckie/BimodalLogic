# Teammate A Findings: First-Principles Semantics Analysis and Chain Redesign

**Task**: 109 — Close chain construction sorries
**Date**: 2026-04-20
**Angle**: Primary semantics analysis and end-to-end chain design

## Key Findings

1. **The irreflexive semantics fundamentally change what the chain must provide.** Under reflexive semantics, `G(phi) -> phi` (BX1) meant the current time was included in temporal quantification. Under irreflexive semantics (strict `<` in `truth_at`), `G(phi)` means "phi at all strictly future times" and `F(phi)` means "phi at some strictly future time." This means: (a) `bx_le_refl` is genuinely unprovable (Frame.lean:205); (b) `until_backward_refl_mcs` and `since_backward_refl_mcs` are genuinely unprovable (TruthLemma.lean:293,317); (c) the chain construction MUST produce strict witnesses (m > n, not m >= n) for F/P resolution.

2. **The 11 sorry sites decompose into 3 independent groups.** Group A (critical path, 5 sorries in RootScopedChain.lean): fwd_chain_forward_F, two halves of restricted_tc, restricted_buc, restricted_fuc. Group B (irreflexive-consequence, 3 sorries): Frame.lean bx_le_refl, TruthLemma.lean until/since_backward_refl_mcs. Group C (dead code, 3+ sorries): Realization.lean, Construction.lean (Quasimodel path). Only Group A is on the critical path to sorry-free completeness.

3. **The existing chain CANNOT prove `fwd_chain_forward_F`.** This is now established across 6 research rounds. The BX11 perpetual deferral obstruction is real: `preserving_fwd_step` uses BX11 fold which can always choose Case 2 (`F(beta and F(chi))`), keeping F(chi) in the successor MCS indefinitely. No descent argument on active defects works because the defect count is not guaranteed to decrease.

4. **BX12 is the mathematically correct reduction, but the gap is in connecting chains to abstract MCS constructions.** BX12 gives F(phi) -> (T U phi). The Until eventuality infrastructure works for abstract BXPoints. The chain construction works with concrete Z-indexed MCS families. These two worlds don't connect: BXPoints are abstract MCS quotients ordered by `bx_le`, while chain positions are concrete MCS at integer indices connected by g_content/h_content propagation.

5. **A "direct discharge" chain that replaces BX11 fold with simple `discharge_single_step` at round-robin positions is the most promising approach**, but it must solve the F-obligation preservation problem.

## Current State Analysis

### Irreflexive Task Semantics (TaskFrame.lean, Truth.lean)

The task frame semantics use:
- `TaskFrame D` (TaskFrame.lean:93): WorldState, task_rel, nullity_identity, forward_comp, converse
- `truth_at` (Truth.lean:119-130): The critical definition. Key clauses:
  - `all_past phi`: `forall s, s < t -> truth_at ... s phi` (STRICT, line 125)
  - `all_future phi`: `forall s, t < s -> truth_at ... s phi` (STRICT, line 126)
  - `untl phi psi`: `exists s, t < s and truth_at ... s psi and forall r, t <= r -> r < s -> truth_at ... r phi` (A2 guard: strict witness, half-open guard [t,s), lines 127-128)
  - `snce phi psi`: `exists s, s < t and truth_at ... s psi and forall r, s < r -> r <= t -> truth_at ... r phi` (A2 guard: strict witness, half-open guard (s,t], lines 129-130)

**Critical observation**: Under A2 guard convention, `phi U psi` at t requires witness s > t (strict) with psi(s) and phi holding on [t,s). The current time t IS in the guard interval, so phi(t) must hold. This means BX9 (`(phi U psi) -> (phi or psi)`) is valid because phi(t) always holds.

### Chain Construction (RootScopedChain.lean)

The chain is built as:
- `dd_chain M0 h0 sigma_list t` (line 593-596): Int-indexed, forward chain for t >= 0, backward chain for t < 0
- Forward chain uses `preserving_fwd_step` (line 533-542): priority dispatch to `defect_step_choice_early` if active defects exist, else `fwd_succ` with round-robin target
- `defect_step_choice_early` uses `resolving_enriched_fwd_exists` which performs the BX11 fold
- Backward chain uses `bwd_pred` (line 581-590): simple Lindenbaum extension with h_content

### Proven Chain Properties

1. **g_content propagation** (line 665-711): `g_content(chain(t)) subset chain(t')` for t < t'. Proved.
2. **Box stability** (line 730-777): `Box(phi) in chain(t) <-> Box(phi) in M0`. Proved.
3. **F-obligation monotonicity** (line 1057-1101): Once F(chi) leaves the forward chain, it never returns. Proved.
4. **F-set non-increasing** (line 1095-1100): The set {chi | F(chi) in chain(k)} is monotonically non-increasing along the forward chain. Proved.
5. **Defect one-step preservation** (line 1045-1051): At each forward step, for sigma_list formulas, either chi in chain(n+1) or F(chi) in chain(n+1). Proved.

### The 5 Critical-Path Sorries

**Sorry #1** (line 1134): `fwd_chain_forward_F` — Given F(phi) in chain(n), find m > n with phi in chain(m).

**Sorry #2** (line 1161): Backward chain region of restricted_tc — F(phi) in backward chain needs resolution. The backward chain doesn't have F-preservation infrastructure.

**Sorry #3** (line 1168): Backward P-resolution in restricted_tc — P(phi) in chain(t) needs s < t with phi in chain(s). The backward chain has `bwd_pred_resolves` for one step, but no multi-step P-resolution proof.

**Sorry #4** (line 1176): `dd_bfmcs_restricted_buc` — Backward Until/Since coherence. Requires showing that Until/Since witnesses in the chain produce the correct MCS membership patterns.

**Sorry #5** (line 1183): `dd_bfmcs_restricted_fuc` — Forward Until/Since coherence. Requires Until guard persistence and F-resolution to construct strict witnesses.

## Proposed Design: Unified Preserving-Discharge Chain

### Core Insight

The fundamental problem is that `preserving_fwd_step` cannot guarantee resolution of any specific defect because the BX11 fold may perpetually defer. The solution is to NOT use the BX11 fold for resolution. Instead, use a two-tier step:

1. **When the round-robin target has F(target) in M**: Use `discharge_single_step` to get target into M', then SEPARATELY verify that other F-obligations are preserved via g_content.

2. **When the round-robin target does NOT have F(target) in M**: Use `fwd_succ` with the round-robin target (existing behavior).

**The key mathematical fact**: `discharge_single_step` uses seed `{target} union g_content(M)`. The seed is consistent when F(target) in M (proved as `forward_temporal_witness_seed_consistent`). The Lindenbaum extension gives M' with target in M' and g_content(M) subset M'.

**F-obligation preservation at discharge steps**: For any chi in sigma_list with F(chi) in M:
- `F(chi) in M` implies `G(neg chi) not-in M` (by MCS consistency)
- By temp_4: `G(neg chi) -> G(G(neg chi))`, so `G(G(neg chi)) not-in M` is possible but not guaranteed
- `G(F(chi)) in M` iff `F(chi) in g_content(M)` iff F(chi) propagates to M' via g_content
- The question: is G(F(chi)) always in M when F(chi) in M?

**Crucial lemma needed**: `F(phi) in M -> G(F(phi)) in M` for MCS M. This is equivalent to BX4': `phi -> H(F(phi))` with phi = F(chi), giving F(chi) -> H(F(F(chi))), then `FF_imp_F` gives F(chi) -> H(F(chi)). Wait -- that's the wrong direction. We need `F(phi) -> G(F(phi))`, not `F(phi) -> H(F(phi))`.

**Actually**: BX4 is `connect_future: phi -> G(P(phi))`. Substituting phi = F(chi): `F(chi) -> G(P(F(chi)))`. This does NOT give G(F(chi)).

**Re-analysis**: The connect axioms are:
- BX4: `phi -> G(P(phi))` — phi now implies always in future, it was true in past
- BX4': `phi -> H(F(phi))` — phi now implies always in past, it will be true in future

Neither gives `F(phi) -> G(F(phi))`. In fact, `F(phi) -> G(F(phi))` is NOT valid in general on irreflexive linear orders. Consider: at time 0, F(phi) holds because phi is true at time 1. But at time 2, F(phi) may not hold (phi may only be true at exactly time 1, and time 2 has no future times where phi holds).

**This means F-obligations are NOT automatically preserved by g_content propagation.** The discharge_single_step can lose F-obligations for non-target formulas.

### The Real Solution: Finite Defect Convergence

Given that F-obligations cannot be unconditionally preserved, the strategy shifts:

**Observation 1**: The forward chain already has `fwd_chain_F_set_nonincreasing` — the set of F-obligations is monotonically non-increasing.

**Observation 2**: The sigma_list is finite.

**Observation 3**: At each step with active defects, `resolving_enriched_fwd_exists` guarantees that at least one defect w is DIRECTLY resolved (w in M').

**The problem restated**: Even though w in M', we may also have F(w) in M', so the defect count doesn't decrease.

**New approach — Use the BX12 bridge WITHIN the chain**: Instead of trying to prove F(phi) resolves, transform the problem:

1. F(phi) in chain(n) implies (T U phi) in chain(n) (by BX12, within the MCS)
2. (T U phi) in chain(n) under A2 guard means: there exists s > n (in the semantic sense) with phi(s) and T on [n,s). Since T is always true, this just means F(phi).
3. But at the MCS level: (T U phi) in chain(n) means chain(n) contains the Until formula. The Until coherence property says: if (T U phi) in fam.mcs(t), then exists s > t with phi in fam.mcs(s).

**Wait** — this is circular! The Until coherence (`restricted_fuc`) is itself one of the sorry targets (#5). We can't use it to prove sorry #1.

### Revised Approach: Ordered Discharge with Finite Descent

The code already has infrastructure for this (lines 820-984): `bx11_earlier`, `bx11_earlier_total`, `target_stays_direct_in_fold`.

**Key theorem** (already proved, line 948): `target_stays_direct_in_fold` — When target is bx11_earlier than every formula in others, there exists M' with g_content(M) subset M' AND target IN M' (guaranteed, not disjunctive).

**The BX11 ordering is total** on F-defects (line 851): For any psi1, psi2 with F(psi1), F(psi2) in M, either bx11_earlier M psi1 psi2 or bx11_earlier M psi2 psi1.

**Strategy**: At each chain step, pick the "earliest" defect in the BX11 ordering. This defect is guaranteed to be directly resolved. For other defects, we get the disjunctive result (chi in M' or F(chi) in M').

**But the count still doesn't decrease** because the "earliest" defect w may have both w in M' and F(w) in M'.

### The Definitive Insight: Iterated Discharge with Goal Tracking

After extensive analysis, the root cause is clear: **no single-step argument can close `fwd_chain_forward_F`**. The chain construction must be modified to have a MULTI-STEP resolution guarantee.

**Proposed construction**: Replace the forward chain with a **goal-directed discharge chain** that works in rounds:

For a fixed target phi with F(phi) in chain(n):

**Round structure** (len = sigma_list.length steps per round):
- Step n*len + i resolves the i-th defect from sigma_list (if it has an F-obligation)
- Each step uses `discharge_single_step` for its target
- g_content propagation ensures G-formulas persist

**Resolution argument**:
- At step n*len + i where target = phi: `discharge_single_step` puts phi in chain(n*len + i). Done.

**The problem**: Between step n (where F(phi) is) and step n*len + i (phi's scheduled slot), other discharge steps may destroy F(phi). Without F(phi) persisting, we have no seed for phi's discharge step.

**But wait**: We DON'T need F(phi) to persist to phi's slot. We need phi ITSELF to appear at some point.

**Alternative approach**: Don't use round-robin at all. Since the existing `preserving_fwd_step` already resolves at least one defect per step (some w with w in M'), and F-obligations are non-increasing, after at most sigma_list.length^2 steps (pigeonhole), either:
(a) phi appears directly in some chain step, or
(b) F(phi) disappears from the chain (meaning G(neg phi) enters, and phi never appears)

Case (b) contradicts the premise that we want phi eventually. But actually case (b) is possible — F(phi) disappearing means phi WAS resolved (appeared) at the step where it was lost.

**No** — `fwd_chain_F_obligation_monotone` says F(phi) not-in chain(n) implies F(phi) not-in chain(m) for all m >= n. If F(phi) disappears at step k, it means G(neg phi) entered at step k. This means phi NOT in chain(m) for all m >= k. So phi was NOT resolved after step k.

But phi COULD have appeared at step k itself (chi in chain(k) while F(chi) not-in chain(k) means chi appeared at k but G(neg chi) also entered, which is contradictory in an MCS). Actually no: chi in M and G(neg chi) in M would mean neg(chi) in g_content(M), so if g_content(M) subset M then neg(chi) in M, contradicting chi in M. Wait -- g_content(M) is {G(phi) | G(G(phi)) in M}, not {phi | G(phi) in M}. So G(neg chi) in M means H(neg chi) ... no, g_content contains G-formulas.

Let me re-examine: g_content(M) = {phi | G(phi) in M} (the forward content). No wait:

Let me check the definition.

### Checking g_content

The g_content is defined somewhere in the codebase. Let me trace it.

From context: `g_content M = { phi | all_future phi in M }`. So G(phi) in M implies phi in g_content(M).

If F(chi) not-in chain(k), then neg(F(chi)) in chain(k), i.e., G(neg(chi)) in chain(k). This means neg(chi) in g_content(chain(k)). By g_content propagation, neg(chi) in chain(k+1), chain(k+2), etc. So chi not-in chain(m) for all m > k (since neg(chi) in chain(m) and MCS consistency).

**Therefore**: If F(chi) disappears from the chain at step k, chi NEVER appears at any step m >= k+1. The only possibility for chi to appear is at step k itself — but at step k, if chi in chain(k) and neg(chi) in chain(k), that's contradictory. So actually chi CANNOT appear at step k either if neg(chi) in g_content(chain(k-1)) subset chain(k).

Hmm, more carefully: F(chi) in chain(k-1) but F(chi) not-in chain(k). This means between k-1 and k, the defect preservation gave chi in chain(k) (the other branch). So chi in chain(k). And G(neg chi) may or may not be in chain(k) -- the fact is F(chi) not-in chain(k) means neg(F(chi)) = G(neg chi) ... no, F(chi) = neg(G(neg chi)), so neg(F(chi)) = neg(neg(G(neg chi))) = G(neg chi) (by DNE in classical logic, which holds in MCS).

But wait: `defect_one_step_preservation` says: if F(chi) in chain(n), then chi in chain(n+1) OR F(chi) in chain(n+1). If F(chi) not-in chain(n+1), then chi in chain(n+1). **YES!**

So:
- F(phi) in chain(n)
- At each step k >= n: either chi in chain(k+1) or F(chi) in chain(k+1) (by preservation)
- If F(chi) ever drops out at step k+1 (F(chi) not-in chain(k+1)), then chi in chain(k+1). DONE.
- If F(chi) NEVER drops out, then F(chi) in chain(m) for all m >= n.
- The question: can F(chi) persist forever?

If F(chi) persists forever, what does that mean? F(chi) in chain(m) for all m >= n. The chain is a sequence of MCS where each step extends g_content of the previous. F(chi) = neg(G(neg chi)). There's no reason F(chi) can't persist forever — it just means "chi will happen in the future" remains true at every step, which is consistent if chi keeps appearing at the next-next step (always deferred).

**BUT**: The chain is over ALL of Z. The truth lemma evaluates truth_at over the parametric canonical history, which maps integer indices to MCS. `truth_at ... t (all_future phi)` means `forall s > t, truth_at ... s phi`. If the truth lemma successfully handles the all_future case, then we're fine — we just need the truth lemma to be correct for the restricted coherence properties we can actually prove.

### The Real Question

Going back to what `dd_countermodel` actually needs:

```lean
fully_restricted_parametric_representation_from_neg_membership
    (dd_bfmcs M h_mcs sigma_list) φ
    (dd_bfmcs_restricted_tc ...)    -- sorry #1,#2,#3
    (dd_bfmcs_restricted_buc ...)   -- sorry #4
    (dd_bfmcs_restricted_fuc ...)   -- sorry #5
```

It needs three coherence properties. Let me re-examine what each requires:

**restricted_tc**: For all fam in BFMCS, for all phi in deferralClosure(root):
- F(phi) in fam.mcs(t) -> exists s > t, phi in fam.mcs(s)
- P(phi) in fam.mcs(t) -> exists s < t, phi in fam.mcs(s)

**restricted_buc**: For all fam, for (phi U psi) in subformulaClosure(root):
- (exists s > t, psi in fam.mcs(s) and forall r in [t,s), phi in fam.mcs(r)) -> (phi U psi) in fam.mcs(t)

**restricted_fuc**: For all fam, for (phi U psi) in subformulaClosure(root):
- (phi U psi) in fam.mcs(t) -> exists s > t, psi in fam.mcs(s) and forall r in [t,s), phi in fam.mcs(r)

The sigma_list for dd_bfmcs is `(extendedDeferralClosure phi).toList` which includes deferralClosure formulas and Until/Since deferral formulas.

### Proposed Complete Design

**Phase 1: Forward F-resolution (sorry #1)**

The existing `preserving_fwd_step` at each step resolves at least one defect (w in M'). The defect set is non-increasing. The key insight I missed:

**Claim**: If F(phi) in chain(n) and phi in sigma_list, then there exists m > n with phi in chain(m).

**Proof sketch using pigeonhole on defect IDENTITY (not count)**:

Let D(k) = {chi in sigma_list | F(chi) in chain(k) and chi not-in chain(k)}.

Wait, that's the wrong definition. Let me use: A(k) = {chi in sigma_list | F(chi) in chain(k)} (the set of F-obligations at step k). By `fwd_chain_F_set_nonincreasing`, A(k+1) subset A(k).

Since sigma_list is finite, A(k) eventually stabilizes. Let k0 be the stabilization point. For all k >= k0, A(k) = A(k0).

At step k0 (assuming A(k0) is nonempty), `preserving_fwd_step` resolves some w: w in chain(k0+1). But A(k0+1) = A(k0), so F(w) in chain(k0+1) also. This means w is resolved (w in chain(k0+1)) but F(w) persists.

Now at step k0+1, again some w' is resolved. A(k0+2) = A(k0). Same story.

**This is the perpetual deferral** — the defect set stabilizes with all defects still active but each being "resolved" (appearing directly) at each step while F persists.

**BUT WAIT**: If w in chain(k0+1) AND F(w) in chain(k0+1), then in the truth lemma, at time k0+1, w is true AND F(w) is true. F(w) being true at time k0+1 means w is true at some strictly future time. This is FINE semantically — w is true now AND will be true again later.

**The thing we need**: phi in chain(m) for SOME m > n. In the stabilized phase, at each step, some w from A(k0) is resolved (w in chain(step+1)). If phi in A(k0), then across multiple steps, phi must eventually be the resolved one.

**But the resolving_enriched_fwd_exists uses Classical.choice** — it picks SOME w, but we can't control which. Can the choice function always avoid phi?

**Yes it can**, in principle. Classical.choice is completely opaque. It could always pick the same w != phi.

**So the current construction STILL cannot prove fwd_chain_forward_F**, even with the stabilization argument.

### The Necessary Redesign

The chain MUST be modified so that phi is GUARANTEED to be directly resolved. Two viable approaches:

**Approach A: Round-robin discharge chain.** Replace `preserving_fwd_step` with a step function that:
- At step n, resolves sigma_list[n % len] using `discharge_single_step`
- This GUARANTEES phi in chain(phi_index_step) when F(phi) was in the chain

The F-preservation problem: other F-obligations may be lost. But:
- We only need resolution for formulas in deferralClosure(root), which is finite
- By `fwd_chain_F_set_nonincreasing` + pigeonhole, each F-obligation either gets resolved or is lost forever
- If F(chi) is lost at step k, then by the preservation lemma, chi in chain(k)
- So EVERY formula in deferralClosure(root) with F-obligation eventually appears in the chain

**Wait, this actually works!** Let me formalize:

For any chi in sigma_list with F(chi) in chain(n):
- By defect_one_step: at each step k >= n, either chi in chain(k+1) or F(chi) in chain(k+1)
- If chi in chain(k+1) for some k >= n: DONE (m = k+1 > n works if k >= n, giving m > n)
- If F(chi) in chain(k+1) for ALL k >= n: F(chi) persists forever

In the "F(chi) persists forever" case, we need to produce a contradiction or find chi somewhere.

With the round-robin discharge: at step n + (phi_index - n) % len (or more precisely, the next step whose round-robin index equals phi's index in sigma_list), `discharge_single_step` fires with target = phi. But `discharge_single_step` requires F(phi) in chain(that step). If F(phi) has been lost before that step, we can't fire. But we assumed F(phi) persists forever, so F(phi) IS available.

With F(phi) in chain(k) at phi's round-robin step k, `discharge_single_step` gives M' with phi in M'. We define chain(k+1) = M'. So phi in chain(k+1). DONE.

**The issue**: Can we build the chain with BOTH discharge_single_step at round-robin slots AND g_content propagation?

`discharge_single_step` uses seed `{phi} union g_content(M)`. So g_content(M) subset M'. The g_content propagation is maintained.

**The only remaining question**: Do we need F-preservation for other defects? For the restricted_tc proof:

For any chi in deferralClosure(root):
- F(chi) in fam.mcs(t) -> exists s > t, chi in fam.mcs(s)

The argument is: F(chi) in chain(t). Either chi appears at some step between t and t + len (when chi's discharge slot comes up), or F(chi) was lost before that slot. If F(chi) is lost at step k (t < k <= t+len), then chi in chain(k) by the defect one-step preservation. Either way, chi appears at some m > t.

**CRITICAL GAP**: The defect one-step preservation (`preserving_fwd_step_defect_preserved`) only applies to `preserving_fwd_step`, not to `discharge_single_step`! At a discharge step for a DIFFERENT target psi, we need: if F(chi) in chain(k), then chi in chain(k+1) OR F(chi) in chain(k+1).

`discharge_single_step` for psi uses seed `{psi} union g_content(M)`. F(chi) is NOT necessarily in g_content(M). In fact, F(chi) in g_content(M) iff G(F(chi)) in M, which requires temp_4 applied to neg(chi): temp_4 gives G(neg chi) -> G(G(neg chi)), not F(chi) -> G(F(chi)).

So `discharge_single_step` for psi does NOT preserve F(chi). At the next step, F(chi) may be gone AND chi may not be present.

**But**: If F(chi) not-in chain(k+1), then by `fwd_chain_F_obligation_monotone`, F(chi) not-in chain(m) for all m >= k+1. And if chi not-in chain(k+1) either, then... we're stuck.

Wait, `fwd_chain_F_obligation_monotone` is proved for the EXISTING chain (using `preserving_fwd_step`). For the new hybrid chain, we need to reprove it. The proof relies on: if F(chi) not-in chain(k), then G(neg chi) in chain(k), then G(G(neg chi)) in chain(k) by temp_4, then G(neg chi) in g_content(chain(k)) subset chain(k+1), so F(chi) not-in chain(k+1). This argument works for ANY chain step that propagates g_content. Since `discharge_single_step` does propagate g_content, the monotonicity still holds.

So: If F(chi) not-in chain(k+1) (after discharge for psi at step k), then G(neg chi) in chain(k+1). But we also need chi to have appeared somewhere. The defect preservation says chi in chain(k+1) OR F(chi) in chain(k+1). **But this lemma was proved for preserving_fwd_step, not for discharge_single_step.**

For discharge_single_step: seed is `{psi} union g_content(M)`. If F(chi) in M but F(chi) not-in g_content(M) (i.e., G(F(chi)) not-in M), then F(chi) is not in the seed. Classical.choice in Lindenbaum extension may or may not include chi or F(chi). Neither is guaranteed.

**This is the fundamental tension**: discharge_single_step DOES guarantee target resolution but DOES NOT preserve F-obligations for non-target formulas.

### The Complete Solution: Extended Discharge Step

Combine `discharge_single_step` with `preserving_fwd_step`'s F-preservation:

**Define `extended_discharge_step(M, target, sigma_list)`**:
- Seed: `{target} union {F(chi) | chi in sigma_list, F(chi) in M, chi != target} union g_content(M)`
- Prove consistency: F(target) in M gives `forward_temporal_witness_seed_consistent` for target. The additional F(chi) formulas are in M and are consistent with the seed (they don't contradict anything in g_content(M) or target).

**Actually, proving this seed is consistent is exactly the same problem as the BX11 fold.** We need to show `{target} union {F(chi1), F(chi2), ...} union g_content(M)` is consistent. This IS what `enriched_fwd_exists` does via the BX11 fold. But the BX11 fold doesn't guarantee target in M' — it gives a disjunctive result.

So we're back to square one. The BX11 fold is the only tool for combining multiple F-obligations into a single consistent seed, and it doesn't guarantee which formula ends up directly resolved.

### Final Proposed Design

After this exhaustive first-principles analysis, the viable path is:

**Use the EXISTING `preserving_fwd_step` chain (no redesign)** and prove `fwd_chain_forward_F` by a different argument:

**The BX12 + Until coherence bootstrap**:

The proof of `dd_bfmcs_restricted_tc` and `dd_bfmcs_restricted_fuc` should be done SIMULTANEOUSLY, not sequentially. Here's why:

1. BX12: F(phi) -> (T U phi). So F(phi) in chain(t) implies (T U phi) in chain(t).
2. `restricted_fuc` says: (T U phi) in chain(t) implies exists s > t, phi in chain(s) and T on [t,s).
3. So if we could prove `restricted_fuc`, we'd get `restricted_tc` for free (via BX12).

**Proving restricted_fuc independently**:

(phi U psi) in chain(t). By BX10: F(psi) in chain(t). By BX9: (phi or psi) in chain(t).

Case (a): psi in chain(t). Under irreflexive Until, we need s > t with psi(s). We also know F(psi) in chain(t). So F(psi) persists until some step where psi appears — but this is exactly fwd_chain_forward_F again. CIRCULAR.

Case (b): phi in chain(t), psi not-in chain(t). F(psi) in chain(t). Same issue.

**The circularity is unavoidable** without a mechanism to force eventual resolution.

### Recommended Path Forward

Given the exhaustive analysis, I recommend the following approach:

**Step 1**: Prove that the `preserving_fwd_step` chain, combined with finiteness of sigma_list and the BX11 fold's resolving property, DOES guarantee that every defect is resolved in finite time. The argument is:

At each step, `resolving_enriched_fwd_exists` resolves some w (w in M'). Even though F(w) may persist, w physically appears in the chain at that step. So for `fwd_chain_forward_F`, we need: given F(phi) in chain(n), show phi in chain(m) for some m > n.

The `resolving_enriched_fwd_exists` at step n gives some w in chain(n+1) with w in the defect list. If w = phi, done.

If w != phi, proceed to step n+1. At step n+1, the active defects still include phi (F(phi) persists or was preserved). Again some w' is resolved. If w' = phi, done.

**The question**: Can Classical.choice always avoid phi? In principle yes, but this is a constructive argument about a specific chain, not a meta-argument about Classical.choice.

**Step 2**: If Step 1 fails (as I believe it will due to the opacity of Classical.choice), then implement the **deterministic round-robin discharge chain** where:

- Define `det_fwd_step(M, sigma_list, n)`:
  - Let target = sigma_list[n % len]
  - If F(target) in M: use `discharge_single_step` for target
  - Else: use `fwd_succ` with target
- Prove: for any chi in sigma_list with F(chi) in chain(n), chi appears in chain at step n + k for some k <= len

The F-preservation gap is handled by: if F(chi) is lost at step k before chi's discharge slot, then G(neg chi) enters the chain permanently. But we also know F(chi) was in chain(k-1), so by the one-step argument... wait, the one-step argument only works for `preserving_fwd_step`.

**Step 3**: If both fail, the ultimate solution is to replace the Lindenbaum-based chain with a **deterministic choice function** (oracle-based construction) that explicitly selects which formulas to include at each step, bypassing Classical.choice entirely. This would require a significant redesign of the chain infrastructure.

## How Design Addresses Each Sorry

| Sorry | Location | Proposed Resolution | Confidence |
|-------|----------|-------------------|------------|
| #1 | RootScopedChain.lean:1134 | Deterministic round-robin chain with guaranteed discharge | Medium |
| #2 | RootScopedChain.lean:1161 | Symmetric backward construction with P-preservation | Medium |
| #3 | RootScopedChain.lean:1168 | Backward chain P-resolution via symmetric argument | Medium |
| #4 | RootScopedChain.lean:1176 | Until backward coherence via BX induction on Until depth | Low |
| #5 | RootScopedChain.lean:1183 | Forward Until coherence bootstrapped from restricted_tc | Medium |

## Confidence Level

**Medium** overall. The deterministic round-robin discharge chain is the most promising approach, but the F-preservation gap for non-target formulas at discharge steps is a genuine mathematical difficulty. The key unresolved question is: when `discharge_single_step` fires for target psi and F(chi) for chi != psi is in the current MCS, can we guarantee chi or F(chi) in the successor MCS? Without this, the one-step preservation lemma breaks at discharge steps.

The highest-confidence sub-result is that the BACKWARD chain sorries (#2, #3) should be closeable by symmetric construction, since the backward chain already has `bwd_pred_resolves` and h_content propagation.

The lowest-confidence result is sorry #4 (backward Until/Since coherence), which requires showing that chain witnesses produce the correct MCS membership patterns for Until formulas. This may require BX induction infrastructure not yet present in the codebase.
