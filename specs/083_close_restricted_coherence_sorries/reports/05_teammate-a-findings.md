# Teammate A Findings: First-Principles Rethinking via Task Semantics

**Task**: 83 (Close Restricted Coherence Sorries)
**Date**: 2026-04-02
**Angle**: First-principles rethinking of the canonical model construction

## Key Findings

### 1. The Chain Construction Is Categorically Wrong for Task Semantics (HIGH confidence)

The current construction builds a single Z-indexed chain of MCSes (via `succ_chain_fam`) and hopes that F-obligations are eventually resolved within that chain. This is a **Kripke-style** construction transplanted into Task Semantics, and the persistent failure is not accidental -- it reflects a fundamental mismatch.

**Task Semantics key distinction**: Truth at `(M, tau, t)` depends on the *history* `tau`, not just the world state at time `t`. The temporal operators G and H quantify over times *along the same history*. The box operator quantifies over *all admissible histories* at the same time.

In the canonical model:
- Each FMCS family `fam : D -> Set Formula` corresponds to a single history `tau`
- `truth_at M Omega tau t phi` depends on which history `tau` is being evaluated
- The truth lemma says: `phi in fam.mcs t <-> truth_at ... (to_history fam) t phi`

The chain construction tries to make a single history resolve all F-obligations. But **the F-kill problem** (Lindenbaum adding `G(neg psi)` which kills `F(psi)`) is exactly the statement that a single history cannot be forced to satisfy all future-existential properties simultaneously via a step-by-step construction.

**What Task Semantics tells us**: The box operator provides the escape. Different histories can resolve different F-obligations. The key question is not "how do we build one history that resolves everything?" but "how do we build a *bundle of histories* where each history is internally coherent?"

### 2. The Bundle Already Solves forward_F -- The Problem Is Lifting Bundle-Level to Family-Level (HIGH confidence)

Reading the architecture carefully:

- `BundleTemporallyCoherent` (proven sorry-free) says: if `F(phi) in fam.mcs t`, then there exists *some* family `fam'` in the bundle and `s > t` with `phi in fam'.mcs s`
- `BFMCS.temporally_coherent` (the requirement) says: if `F(phi) in fam.mcs t`, then there exists `s >= t` with `phi in fam.mcs s` -- witness in the SAME family

The gap: bundle-level gives a witness in a *different* family. Family-level requires a witness in the *same* family. The truth lemma evaluates along a single history, so it needs the same-family witness.

**This is precisely the representation-theoretic content of the problem**: Can every family in the bundle be made temporally self-coherent?

### 3. Task Frame Algebraic Structure Suggests a Different Construction (MEDIUM-HIGH confidence)

The Task Frame axioms provide structure that the chain construction ignores:

1. **Nullity identity**: `task_rel w 0 u <-> w = u` -- zero duration is identity
2. **Forward compositionality**: tasks compose for non-negative durations
3. **Converse**: `task_rel w d u <-> task_rel u (-d) w` -- temporal symmetry

In the canonical model (`ParametricCanonicalTaskFrame`), the task relation is:
```
task_rel (fam1.mcs t) d (fam2.mcs (t + d))
```
where `fam1` and `fam2` are in the same BFMCS and share the same box-class at their respective times.

**Key insight**: The converse axiom means that if we can go from state A to state B in time d, we can go from B to A in time -d. This is automatically satisfied by the parametric canonical frame because the BFMCS is symmetric in time direction. But it also means that the **temporal structure is not merely a chain -- it is a group action** of D on world states.

The algebraic structure of D (totally ordered abelian group) should be exploited to construct families that are *group-equivariant* -- i.e., where the family assignment `fam.mcs` respects the group action of D.

### 4. The Correct Construction: History Selection via Maximal Consistent Theories of Histories (MEDIUM confidence)

Instead of building families bottom-up (chain construction), consider the top-down approach:

**Define a "history theory"**: For a given base MCS M0, a history theory is a set of pairs `{(phi, t) | phi should be true at time t along this history}` such that:
- At each time t, the set `{phi | (phi, t) in T}` is an MCS
- G-coherence: if `(G(phi), t) in T` then `(phi, s) in T` for all `s >= t`
- H-coherence: if `(H(phi), t) in T` then `(phi, s) in T` for all `s <= t`
- F-coherence: if `(F(phi), t) in T` then `(phi, s) in T` for some `s >= t`
- P-coherence: if `(P(phi), t) in T` then `(phi, s) in T` for some `s <= t`

This is a "complete temporal theory" -- it specifies the full content of a history.

**Claim**: Such history theories exist and can be constructed via Zorn's lemma on the partial order of "partial history theories" (sets satisfying G/H coherence, closed under derivation at each time, with F/P obligations tracked).

**Why this avoids the F-kill problem**: In the chain construction, we build one MCS at a time, and the Lindenbaum extension at step n+1 is unaware of obligations at step n. In the history theory approach, we extend the *entire history simultaneously*, and Zorn's lemma guarantees that the maximal extension satisfies all obligations (because any unsatisfied F-obligation could be used to extend the theory further).

**Formal argument sketch**:
- Start with a "seed" history theory: `{(phi, 0) | phi in M0}`
- A partial history theory P is *consistent* if no finite subset of it derives a contradiction at any time
- Order partial history theories by inclusion
- By Zorn's lemma, there exists a maximal consistent history theory T
- T satisfies F-coherence: if `(F(phi), t) in T` but no `(phi, s) in T` for `s >= t`, then we could extend T with `(phi, t+1)` (or appropriate s) without contradiction, violating maximality

The critical step is: **why can we extend T with `(phi, s)` without contradiction?** This is where the G-wrapping argument succeeds, because we are not constrained to a single MCS -- we are working with the full history theory. If adding `(phi, s)` to T creates a contradiction, then `(neg(phi), s) in T` (by maximality, since T is maximal). But `(F(phi), t) in T` and `(neg(phi), s) in T` for all `s >= t` would imply `(G(neg(phi)), t) in T` (by the backward direction -- which is what we're trying to prove!). So we'd have both `F(phi)` and `G(neg(phi))` at time t, contradicting consistency at time t.

**Wait -- this is circular!** The backward G direction is exactly what needs forward_F. So the Zorn argument ALSO needs the backward direction to close.

### 5. Breaking the Circularity: The Finitary Witness Argument (MEDIUM confidence)

The circularity in Finding 4 can be broken by observing that the failure to extend must involve a **finite** derivation. Specifically:

If `(F(phi), t) in T` and T is maximal but `(phi, s) not in T` for all `s >= t`, then for each `s >= t`, there exists a finite `L_s subset T` at time s such that `L_s, phi |- bot`.

By compactness at time s: `L_s |- neg(phi)`. Since `L_s subset T`, we have `(neg(phi), s) in T` for each `s >= t`.

Now, `(neg(phi), s) in T` for all `s >= t` does NOT directly give `(G(neg(phi)), t) in T`. That's the backward G step which requires forward_F (circular).

**However**: We can use the **temporal axioms directly**. If `neg(phi)` is in the MCS at every time `s >= t`, and the MCS at time t contains `F(phi)`, we can derive a contradiction WITHOUT backward G:

- `F(phi) = neg(G(neg(phi)))` at time t
- If `neg(phi)` is in every MCS at `s >= t`, then by the forward G step (which IS available): `G(neg(phi))` propagates forward
- But we need `G(neg(phi))` at time t specifically
- By the T-axiom `G(phi) -> phi`: if `G(neg(phi))` were at time t, then `neg(phi)` at time t, which may or may not contradict anything
- The issue: we have `neg(phi)` at all `s >= t` but need to conclude `G(neg(phi))` at t

This is precisely the backward G step. The circularity seems inescapable at this level.

### 6. The Real Solution: Construct Families with Explicit F-Resolution Scheduling (HIGH confidence)

After exhaustive analysis, the mathematically correct approach is to **abandon the generic Lindenbaum extension** and construct each MCS in the chain with explicit control over F-obligation resolution.

The key insight from Task Semantics: The task frame's forward compositionality means that if we can reach state B from state A in time d1, and state C from state B in time d2, then we can reach C from A in time d1+d2. This means **the chain of MCSes must compose consistently**.

**Concrete proposal -- The Dovetailed Resolution Chain**:

For a given MCS M0 with F-obligations `{F(psi_1), F(psi_2), ...}`:

1. Enumerate all formulas `phi` such that `F(phi) in M0` (or more precisely, in `deferralClosure(root)`)
2. Schedule resolution: at step 2k+1, resolve `psi_k` (using Nat.unpair for fair interleaving)
3. At each "resolution step" for `psi_k`: build the successor MCS as `Lindenbaum({psi_k} union g_content(current))` -- this is the standard `forward_temporal_witness_seed_consistent` argument
4. At each "propagation step": build the successor MCS as `Lindenbaum(g_content(current))` -- standard successor
5. **Key property**: After step 2k+1, `psi_k in chain(2k+1)` is guaranteed by construction

**Why this works**: Each F-obligation `F(psi_k) in M0` propagates forward through the chain via f_step (either resolved or deferred). At step 2k+1, we FORCE resolution of psi_k by putting it in the seed. The question is: does `F(psi_k)` still exist at step 2k+1?

**Potential problem**: `F(psi_k)` might have been killed at an earlier step by the Lindenbaum extension adding `G(neg(psi_k))`. This is the F-kill problem again.

**But**: If `G(neg(psi_k))` is added at step j < 2k+1, then `neg(psi_k)` is in all subsequent MCSes (by G-propagation). At step 2k+1, we try to seed with `{psi_k} union g_content(chain(2k))`. If `G(neg(psi_k)) in chain(2k)`, then `neg(psi_k) in g_content(chain(2k))`, making the seed `{psi_k, neg(psi_k), ...}` inconsistent. So the construction fails.

**This means**: We cannot independently schedule resolution -- the resolutions interact. This confirms that the problem is fundamentally about **joint consistency of multiple F-obligation resolutions**.

### 7. The Algebraic Solution: Quotient by the Box-Equivalence and Use Canonical Frame Directly (HIGH confidence)

The cleanest mathematical approach, which fully exploits Task Semantics, is:

**Observation**: In the canonical frame (CanonicalFrame.lean), `forward_F` is TRIVIALLY TRUE. Each `F(psi) in M` gets its own witness MCS W via Lindenbaum, with `psi in W` and `g_content(M) subset W`. There is no F-kill problem because each obligation is resolved independently.

The difficulty is that the canonical frame gives a *branching* model (each MCS can see multiple successor MCSes), not a linear one. Task Semantics requires linear histories.

**Solution**: Extract linear histories from the canonical frame.

Given the canonical frame with worlds = all MCSes, define:
- A **canonical history through M0** is a function `sigma : D -> Set Formula` (i.e., `D -> MCS`) such that:
  - `sigma(0) = M0`
  - For all t, `g_content(sigma(t)) subset sigma(t+1)` (ExistsTask/forward relation)
  - For all t, `h_content(sigma(t+1)) subset sigma(t)` (backward relation)
  - F-resolution: for each `F(phi) in sigma(t)`, there exists `s >= t` with `phi in sigma(s)`
  - P-resolution: for each `P(phi) in sigma(t)`, there exists `s <= t` with `phi in sigma(s)`

**Claim**: Such histories exist, and can be constructed by transfinite/Zorn argument or by the dovetailed chain with careful scheduling.

**Why the dovetailed chain works HERE but not for succ_chain_fam**: In the canonical frame, each MCS M has canonical_forward_F: for each `F(psi) in M`, there exists an MCS W with `psi in W` and `ExistsTask M W`. The dovetailed chain resolves `psi_k` at step 2k+1 by using `W_k` (the canonical witness for `psi_k`). The key difference from the succ_chain_fam approach is that **we use different witness MCSes for different obligations**.

But we still need the chain to be a single linear history. The MCS at step 2k+1 must serve as both:
(a) the resolution of `psi_k` (containing `psi_k`)
(b) a valid successor of the MCS at step 2k (containing `g_content(chain(2k))`)

This is exactly the seed `{psi_k} union g_content(chain(2k))`, which is consistent by `forward_temporal_witness_seed_consistent`. So the Lindenbaum extension gives us an MCS satisfying both (a) and (b).

**The F-kill concern**: At step 2k+1, `F(psi_k)` might not be in `chain(2k)` anymore (it may have been killed). But **we don't need F(psi_k) to still be alive**. We only need the SEED to be consistent. The seed is `{psi_k} union g_content(chain(2k))`. This is consistent as long as `F(psi_k)` was in `M0` (which it was) -- wait, that's not quite right either. The consistency proof for the seed uses `F(psi_k) in chain(2k)`.

**Correction**: `forward_temporal_witness_seed_consistent` proves: if `F(psi) in M` then `{psi} union g_content(M)` is consistent. We need `F(psi_k) in chain(2k)`. If F(psi_k) has been killed, we can't use this.

**But**: The f_step property guarantees `f_content(chain(n)) subset chain(n+1) union f_content(chain(n+1))`. So `F(psi_k) in chain(0)` implies that at each step, either `psi_k in chain(n)` (resolved!) or `F(psi_k) in chain(n)` (deferred). If `psi_k` was resolved at some earlier step j, then we already have our witness. If it was perpetually deferred, then `F(psi_k) in chain(2k)` and the seed is consistent.

**Wait -- this is exactly the claim of `succ_chain_restricted_forward_F`!** The f_step property gives us: `psi_k` is either resolved at some step, or `F(psi_k)` persists forever. We need to show that perpetual deferral is impossible.

### 8. Why Perpetual Deferral IS Impossible in deferralClosure (MEDIUM confidence)

For formulas in `deferralClosure(root)`, the F-nesting depth is bounded. Let me reconsider.

`deferralClosure(root)` contains all subformulas of root and their negations. For `F(psi)` with `psi in deferralClosure(root)`, the f_step gives either `psi` or `F(psi)`. If `F(psi) in chain(n)` for all n, can we derive a contradiction?

Key: `F(psi) in chain(n)` for all n means `G(neg(psi)) not in chain(n)` for all n (since `F(psi) = neg(G(neg(psi)))`). But the chain has `g_content(chain(n)) subset chain(n+1)`, so if `G(neg(psi))` ever enters, it persists forever and kills `F(psi)` -- contradiction with perpetual `F(psi)`. So `G(neg(psi))` NEVER enters the chain.

Now, `neg(psi) in chain(n)` for some n does NOT imply `G(neg(psi)) in chain(n)`. The T-axiom goes the other way: `G(neg(psi)) -> neg(psi)`.

So perpetual deferral means: `F(psi) in chain(n)` for all n, but `psi not in chain(n)` for all n. By MCS negation completeness, `neg(psi) in chain(n)` for all n. Now we have `neg(psi)` at ALL times, but `G(neg(psi))` at NO time. Is this consistent?

Yes! In the chain, `G(neg(psi)) in chain(n)` iff `neg(psi) in g_content(chain(n))` iff `G(neg(psi)) in chain(n)`. That's circular. The real question: can an MCS contain `neg(psi)` and `F(psi)` but not `G(neg(psi))`? YES: `neg(psi)` says psi is false now, `F(psi)` says psi will be true eventually, `not G(neg(psi))` is consistent with both.

**So perpetual deferral IS semantically consistent**. The chain construction cannot rule it out by logical means alone. The issue is that the chain is built step-by-step and at no step is there a mechanism to force resolution.

### 9. The Only Viable Approach: Modify the Chain Construction to Force Resolution (HIGH confidence)

Given that perpetual deferral is logically consistent within a single chain step, the only way to ensure F-resolution is to **build it into the construction**.

The approach that works:

**For each F-obligation in deferralClosure(root), schedule a dedicated resolution step.**

At the scheduled step n_k for obligation F(psi_k):
- Check: is `F(psi_k) in chain(n_k - 1)`? (Is the obligation still alive?)
- If YES: build `chain(n_k) = Lindenbaum({psi_k} union g_content(chain(n_k - 1)))` -- forces resolution
- If NO: `psi_k` was already resolved at some earlier step, so `chain(n_k)` can be a standard successor

The key lemma: if `F(psi_k) in chain(n_k - 1)`, then `{psi_k} union g_content(chain(n_k - 1))` is consistent. This IS `forward_temporal_witness_seed_consistent`.

**After step n_k**: `psi_k in chain(n_k)` by construction (it's in the seed, hence in the Lindenbaum extension).

**Does the Succ property hold?** We need `Succ(chain(n_k - 1), chain(n_k))`:
- g_persistence: `g_content(chain(n_k - 1)) subset chain(n_k)` -- YES, by seed construction
- f_step: `f_content(chain(n_k - 1)) subset chain(n_k) union f_content(chain(n_k))` -- this requires that for each `F(chi) in chain(n_k - 1)`, either `chi in chain(n_k)` or `F(chi) in chain(n_k)`. Since `chain(n_k)` is an MCS containing `g_content(chain(n_k - 1))`, and the only forced element is `psi_k`, the Lindenbaum extension may or may not include `chi` or `F(chi)` for other obligations. By MCS negation completeness, either `chi in chain(n_k)` or `neg(chi) in chain(n_k)`, and either `F(chi) in chain(n_k)` or `G(neg(chi)) in chain(n_k)`.

If `F(chi) not in chain(n_k)` and `chi not in chain(n_k)`, then `G(neg(chi)) in chain(n_k)` and `neg(chi) in chain(n_k)`. But `F(chi) in chain(n_k - 1)` and `f_step` would require `chi in chain(n_k)` or `F(chi) in chain(n_k)` -- but f_step is a PROPERTY of the Succ relation, not something the Lindenbaum extension automatically satisfies!

**The Lindenbaum extension does NOT automatically satisfy f_step.** The seed `{psi_k} union g_content(M)` does not include `f_content(M)`. So the resulting MCS may violate f_step.

**This is the core problem**: the targeted resolution seed ensures psi_k is resolved but does NOT ensure f_step for other obligations. The standard `constrained_successor_from_seed` includes f_step by construction (via deferral disjunctions), but the targeted seed does not.

### 10. Synthesis: Combine Targeted Resolution with F-Deferral Disjunctions (HIGH confidence)

The solution is to use a seed that combines:
1. `{psi_k}` -- the target to resolve
2. `g_content(M)` -- G-persistence
3. For each `chi in f_content(M)` with `chi != psi_k`: `chi or F(chi)` -- f_step deferral disjunctions

This is essentially the `constrained_successor_from_seed` construction with the additional constraint that `psi_k` is forced to be in the result.

**Seed**: `{psi_k} union g_content(M) union {chi_or_F_chi | F(chi) in M, chi != psi_k}`
where `chi_or_F_chi` is the disjunction `chi or F(chi)`.

**Consistency**: `g_content(M) union {deferral disjunctions}` is already consistent (this is proven in `constrained_successor_from_seed`). Adding `psi_k` to this: the question is whether `{psi_k}` is consistent with the rest.

Since `F(psi_k) in M`, and `{psi_k} union g_content(M)` is consistent (by `forward_temporal_witness_seed_consistent`), the remaining question is whether adding the deferral disjunctions preserves consistency.

**Each deferral disjunction `chi or F(chi)` is in M** (because `F(chi) in M` implies `chi or F(chi) in M` by the T-axiom for F: `F(chi) -> chi or F(chi)` -- wait, that's not an axiom. Actually, from `F(chi) in M`, we know `F(chi) in M`, and since `chi -> chi or F(chi)` is a tautology and `F(chi) -> chi or F(chi)` is also a tautology, we get `chi or F(chi) in M` from either `chi in M` or `F(chi) in M`.

Actually, `F(chi) in M` directly implies `chi or F(chi) in M` since `F(chi) -> (chi or F(chi))` is provable (weaker conclusion). So the deferral disjunctions are all in M.

So the seed is: `{psi_k} union (subset of M)`. By the same argument as `forward_temporal_witness_seed_consistent`: any finite inconsistent subset L must contain psi_k (else L subset M, contradicting M's consistency). Then L \ {psi_k} subset M and L \ {psi_k} |- neg(psi_k). By MCS closure, neg(psi_k) in M. But F(psi_k) in M and neg(psi_k) in M are compatible (F says "eventually", neg says "not now"). So we don't get a contradiction directly.

The G-wrapping argument: L \ {psi_k} subset g_content(M) union {disjunctions}. Elements in g_content(M) can be G-wrapped. Disjunctions cannot. **Same blocker as before.**

**However**: If we restrict to deferralClosure(root), the number of F-obligations is finite. We can resolve them ONE AT A TIME, and at each resolution step, the only non-G-wrappable element in the seed is the target psi_k (all deferral disjunctions are in M, hence wrappable -- wait, they are in M but not necessarily G-wrappable).

Hmm. The deferral disjunctions `chi or F(chi)` are in M, but `G(chi or F(chi))` may not be in M. The G-wrapping technique requires `G(x) in M` for all x in the seed, which holds for `g_content(M)` elements but not for disjunctions.

**Revised approach**: Use the FULL constrained successor seed (which already handles f_step), but additionally include psi_k.

The `constrained_successor_from_seed` already builds a seed that is proven consistent. The question is: can we add `psi_k` to it?

The constrained successor seed is: `g_content(M) union {deferral disjunctions for all F-obligations}`. This is proven consistent. Adding `psi_k` where `F(psi_k) in M`: we need `{psi_k} union constrained_seed` to be consistent.

Since `psi_k or F(psi_k)` is already in the constrained seed (as a deferral disjunction), and we're adding `psi_k` (which entails the disjunction), the new seed is: constrained_seed with the disjunction `psi_k or F(psi_k)` strengthened to `psi_k`.

**Claim**: Replacing `psi_k or F(psi_k)` with `psi_k` in a consistent seed preserves consistency. This follows if `psi_k` is consistent with the rest of the seed minus the disjunction. If it were inconsistent, then the rest of the seed implies `neg(psi_k)`. Combined with the disjunction `psi_k or F(psi_k)`, we'd get `F(psi_k)` from the original seed. But `F(psi_k)` is consistent with the original seed (since it IS in the original seed -- it's one of the disjuncts). So the original seed does not become inconsistent.

**Formal argument**: Let S = constrained_seed. S is consistent. Let S' = (S \ {psi_k or F(psi_k)}) union {psi_k}.

If S' is inconsistent, then S' |- bot. Since the only change is replacing `psi_k or F(psi_k)` with the stronger `psi_k`, and S' |- bot, then... actually this direction of reasoning is wrong. `S'` has a stronger element, so it could be inconsistent even though S is consistent.

**Actually**: Consider any derivation from S' yielding bot. Each use of `psi_k` in the derivation can be replaced by `psi_k or F(psi_k)` combined with a case analysis. In the `psi_k` case, the original derivation applies. In the `F(psi_k)` case, we need a separate argument. So this doesn't directly work.

**Final assessment**: The constrained successor with forced resolution is the right approach, but proving consistency of the augmented seed requires a new argument that is not a straightforward extension of existing lemmas. The G-wrapping technique is the proven method for seed consistency, and it only works when all non-target elements are in g_content. The deferral disjunctions break this.

## Recommended Approach

### Primary: Iterative Single-Target Resolution with Inductive Coherence

Rather than trying to resolve all F-obligations in a single chain, use the following strategy:

1. **Start with the existing `constrained_successor_from_seed` chain** (sorry-free, satisfies Succ)
2. **For each F-obligation `F(psi_k)` in `deferralClosure(root)` (finitely many)**:
   - If `psi_k` is already resolved (exists n with `psi_k in chain(n)`), done
   - If `F(psi_k)` persists forever: REPLACE the entire chain from step n_k onward with a new chain rooted at a targeted successor MCS containing `psi_k`
3. **Prove**: the replacement preserves all previously resolved obligations (by g_content propagation) and resolves one more obligation
4. **By induction on the finite number of unresolved obligations**: after finitely many replacements, all obligations are resolved

**Why this might work**: At each replacement step, we only need `{psi_k} union g_content(current)` to be consistent (proven). The replacement chain from step n_k onward satisfies Succ by construction. Previously resolved obligations `psi_j` (j < k) are in `chain(n_j)` for `n_j < n_k`, which is BEFORE the replacement point, so they are unaffected.

**Why this might NOT work**: After replacing the chain from n_k onward, previously DEFERRED obligations `F(psi_j)` for j > k might be affected. The new chain might not preserve `F(psi_j)` -- it might kill it. Then `psi_j` is neither resolved nor deferred, which violates f_step.

**Mitigation**: Process obligations in topological order of the blocking relation (Finding from round 3 research). Unblocked obligations are resolved first; blocked obligations are resolved after their blockers.

### Fallback: Weaken the Requirement

If no chain-based approach works, consider:

1. **Change the truth lemma to use bundle-level witnesses**: Instead of requiring `phi in fam.mcs s` (same family), allow `phi in fam'.mcs s` (any family). This requires changing the semantics to evaluate G along "branching histories" rather than linear ones. Task Semantics may actually support this via the task relation's non-determinism.

2. **Use the canonical frame directly**: The canonical frame (all MCSes as worlds) trivially satisfies forward_F. Build a task frame from it directly, with histories as paths through the ExistsTask relation. This requires showing that the canonical frame IS a task frame (nullity, compositionality, converse).

## Confidence Levels

| Finding | Confidence |
|---------|-----------|
| 1. Chain construction wrong for Task Semantics | HIGH |
| 2. Bundle solves F but family needs same-family | HIGH |
| 3. Algebraic structure suggests different construction | MEDIUM-HIGH |
| 4. History theory via Zorn | MEDIUM (circularity issue) |
| 5. Breaking circularity with finitary argument | MEDIUM (doesn't close) |
| 6. Perpetual deferral impossible claim | LOW (actually possible) |
| 7. Canonical frame direct approach | HIGH |
| 8. Perpetual deferral IS consistent | HIGH |
| 9. Must force resolution in construction | HIGH |
| 10. Constrained seed + target consistency | MEDIUM (G-wrapping blocker) |

## Critical Observation

The fundamental tension is:
- **Bundle-level forward_F is trivially true** (each obligation gets its own witness MCS)
- **Family-level forward_F requires all obligations resolved along one history**
- **The Lindenbaum extension is non-constructive and can kill any F-obligation**
- **No proof-theoretic mechanism prevents perpetual deferral in the chain**

The most promising path is to **prove that the existing `constrained_successor_from_seed` chain already satisfies forward_F for `deferralClosure` formulas**, possibly by leveraging the finiteness of `deferralClosure` combined with the TM linearity axiom to show that perpetual deferral of a formula in `deferralClosure` leads to a contradiction with some other axiom.

Alternatively, **bypass the chain entirely** and construct the BFMCS families as paths through the canonical frame, where forward_F is trivial. This requires new infrastructure but avoids the F-kill problem entirely.
