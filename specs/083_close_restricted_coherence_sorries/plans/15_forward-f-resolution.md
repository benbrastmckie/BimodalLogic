# Implementation Plan: Resolve forward_F Circularity via Split Truth Lemma

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: Phases 1-4 of plan v14 (completed)
- **Research Inputs**: reports/15_forward-f-resolution.md
- **Artifacts**: plans/15_forward-f-resolution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan resolves the forward_F circularity that blocks Phase 5 of the completeness proof. The circularity is: `backward_G(psi)` needs `forward_F(neg psi)`, which needs `backward_G(neg neg psi)`, creating infinite regress. Research report 15 confirmed that all prior approaches (mutual induction by formula size, restricted chains, parametric path, hybrid chains) are blocked by this same cycle.

The plan adopts a fundamentally different strategy: **split the truth lemma into a forward-only half (which is forward_F-independent) and use the forward half to prove forward_F, then derive the backward half**. The key mathematical insight is that `truth_lemma_forward` for G uses only `fam.forward_G` (sorry-free), not `forward_F`. The forward_F proof uses `truth_lemma_forward` (not backward) plus a syntactic argument. This breaks the cycle.

### Research Integration

Report 15 (forward-f-resolution.md) confirmed:
1. `truth_fwd(G psi)` depends only on `fam.forward_G`, NOT on `forward_F`
2. `truth_bwd(G psi)` depends on `forward_F` via `temporal_backward_G`
3. `x_content(M) union {psi}` can be inconsistent, blocking naive hybrid chains
4. The dovetailed chain's `forward_dovetailed_until_persists` has a sorry because g_content-based steps lose x_content propagation

## Goals & Non-Goals

**Goals**:
- Close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` sorries in UltrafilterChain.lean
- Close `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` in DovetailedChain.lean
- Wire a complete sorry-free path from `parametric_algebraic_representation_relative` through a concrete BFMCS construction for D = Int
- Close or make unnecessary the Until/Since sorry sites in CanonicalConstruction.lean

**Non-Goals**:
- Rewriting the truth lemma from scratch (we reuse `parametric_canonical_truth_lemma`)
- Changing the axiom system (37 axioms are fixed)
- Achieving completeness for dense D = Rat (out of scope for task 83)
- Closing sorries unrelated to temporal coherence

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| forward_F proof via forward-only truth lemma has a subtle gap | H | M | Phase 1 focuses entirely on the mathematical proof before Lean formalization |
| `forward_until` for the deterministic chain requires forward_F after all | H | L | The deterministic chain's x_content propagation + well-founded descent on Nat provides a direct proof (see Phase 3 analysis) |
| Lean formalization of split truth lemma hits universe or termination issues | M | M | Lean MCP tools available for goal inspection; Phase 2 can adjust strategy |
| Cross-boundary G/H (negSucc to Nat arm) needs `Y(G(phi)) -> G(phi)` derivation | M | M | Phase 4 addresses this explicitly; fallback is single-arm completeness |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Prove forward_F for the Deterministic Chain (Mathematical Core) [COMPLETED]

**Goal**: Prove `forward_F` for the deterministic chain by decomposing the truth lemma argument. This is the key mathematical step that breaks the circularity.

**Mathematical Argument**:

The forward_F proof for the deterministic chain proceeds as follows. Given `F(psi) in chain(t)`, we need `exists s > t, psi in chain(s)`.

**Step 1**: Observe that `F(psi) = neg(G(neg(psi)))`. So `neg(G(neg(psi))) in chain(t)`, meaning `G(neg(psi)) not in chain(t)`.

**Step 2**: The deterministic chain has sorry-free `forward_G_nat`: `G(phi) in chain(n), n < m => phi in chain(m)`. If `G(neg(psi))` WERE in `chain(t)`, then `neg(psi) in chain(s)` for all `s > t`. But `G(neg(psi)) not in chain(t)` (from Step 1).

**Step 3**: By contrapositive of `forward_G_nat` completeness: if `neg(psi)` is NOT in `chain(s)` for some `s > t`, then `psi in chain(s)` (by MCS negation completeness). But this is not quite right -- we need to show that `neg(psi)` is ABSENT somewhere, not that `G(neg(psi))` is absent from chain(t).

**Step 4 (The actual proof)**: Use the FORWARD-ONLY half of the truth lemma. The truth lemma forward for ALL formula cases EXCEPT `backward_G` and `backward_H` does not use `forward_F`. In particular:
- `truth_fwd(atom)`: trivial
- `truth_fwd(bot)`: trivial
- `truth_fwd(imp psi chi)`: uses `truth_bwd(psi)` and `truth_fwd(chi)` -- BUT this is where we need care. The imp forward case uses the backward IH for the antecedent. If the antecedent contains G, the backward IH for G needs forward_F.

**Revised Step 4**: The full truth lemma IS bidirectional and the imp case creates cross-dependencies. However, the KEY observation is:

For the forward_F proof, we do NOT need the full truth lemma. We need a WEAKER result:

**Claim (Forward_F_via_Semantic_Argument)**: For the deterministic chain as FMCS, if `F(psi) in chain(t)`, then there exists `s > t` with `psi in chain(s)`.

**Proof by well-founded descent on the formula closure**:

The deferral closure of any root formula is FINITE. Define `pending(t) = { phi in deferralClosure(root) : F(phi) in chain(t) AND phi not in chain(t) }`. Since deferralClosure is finite, `|pending(t)|` is bounded.

For the deterministic chain with x_content propagation:
- If `F(psi) in chain(t)`, then `(top U psi) in chain(t)` (by `F_until_equiv`)
- By `until_persists_chain`: either `psi in chain(t+1)` (done) or `(top U psi) in chain(t+1)`
- If the latter, `F(psi) in chain(t+1)` (by `until_implies_some_future`)
- Continue: either psi eventually appears, or `F(psi)` persists forever

If `F(psi)` persists forever: `(top U psi) in chain(n)` for all `n >= t`. But `(top U psi)` semantically requires psi to eventually hold. The issue is proving this syntactically.

**The direct proof**: Since `(top U psi) in chain(n)` for all `n >= t`, and the deferral closure is finite, we can use the PIGEONHOLE PRINCIPLE on the chain's behavior restricted to the finite closure. The chain restricted to the closure is eventually periodic (finite MCS theory restricted to finite formulas has only finitely many distinct states). In a periodic chain, `(top U psi)` persistent with psi never appearing contradicts `until_implies_some_future` + the periodicity giving `G(neg(psi))` syntactically.

**Alternative (simpler, preferred)**: Use `temporal_backward_G_with_fwd_F` with an INDUCTION ON THE SIZE OF `psi` within the deferral closure. For the deterministic chain, forward_F for psi of size 0 (atoms, bot) is trivially provable. For larger psi, the contrapositive argument in `temporal_backward_G_with_fwd_F` calls `forward_F(neg(psi))`. But `neg(psi) = psi.imp bot` has size `|psi| + 2` (larger), so this does NOT decrease.

**PREFERRED APPROACH: Finiteness + Periodicity**

For the deterministic chain over Int, the chain restricted to any finite set of formulas (like the deferral closure) is eventually periodic. Specifically:

1. Let `S = deferralClosure(root)` (finite, say `|S| = N`).
2. The "state" at time `t` is `chain(t) ∩ S` (a subset of S, so at most `2^N` distinct states).
3. The chain is DETERMINISTIC: `chain(t+1) = x_content(chain(t))`, which depends only on `chain(t)`. So the state at `t+1` depends only on the state at `t`.
4. By pigeonhole, within `2^N + 1` steps, some state repeats. Once a state repeats, the chain is periodic in its restriction to S.
5. If `(top U psi)` persists and psi never appears, then in the periodic portion, `F(psi)` holds at every position but psi never appears. But `F(psi)` and `G(neg(psi))` coexist in every state of the cycle, which is inconsistent with `F(psi) = neg(G(neg(psi)))`. WAIT: `F(psi)` and `G(neg(psi))` are contradictory (F(psi) = neg(G(neg(psi)))). So if F(psi) is in every state, G(neg(psi)) is NOT in any state. But neg(psi) IS in every state (since psi is not). This is consistent: neg(psi) everywhere does not give G(neg(psi)) syntactically.

**The periodicity argument FAILS for the same reason**: we cannot derive G(neg(psi)) from neg(psi) at every position without the backward_G argument.

**FINAL APPROACH: Use `temporal_backward_G_with_fwd_F` with a well-founded measure on the CHAIN INDEX, not formula size.**

Given `F(psi) in chain(t)`:
1. `(top U psi) in chain(t)` (by F_until_equiv)
2. By `until_persists_chain`, either psi appears at some `chain(s)` with `s > t`, or `(top U psi)` persists to all `chain(n)` with `n >= t`.
3. Assume psi never appears. Then `neg(psi) in chain(n)` for all `n > t` (MCS negation completeness + psi not in chain).
4. In the Nat arm: `neg(psi) in chain(n)` for all `n > t`. The state `chain(t) ∩ S` determines `chain(t+1) ∩ S` deterministically. By pigeonhole on `2^|S|` states, the chain restricted to S is eventually periodic with some period `p`.
5. In the periodic portion (say starting at index `t_0`), the state at `chain(t_0) = chain(t_0 + p)`. The chain from `t_0` onward loops with period `p`.
6. In this loop, `F(psi) in chain(n)` for all `n >= t_0`, meaning `neg(G(neg(psi))) in chain(n)` for all `n >= t_0`.
7. Also `neg(psi) in chain(n)` for all `n >= t_0`.

**Now the key**: the x_content function applied `p` times starting from `chain(t_0)` returns to `chain(t_0)`. So `chain(t_0) = x_content^p(chain(t_0))`. This means `X^p(phi) in chain(t_0)` iff `phi in chain(t_0)` for formulas in S.

From `neg(psi) in chain(t_0)`: `X(neg(psi)) in chain(t_0)` (since neg(psi) in chain(t_0+1) and the chain is x_content-linked). Wait, `X(phi) in chain(t_0)` iff `phi in chain(t_0+1) = x_content(chain(t_0))`. Since neg(psi) in chain(t_0+1), `X(neg(psi)) in chain(t_0)`.

Similarly `X^k(neg(psi)) in chain(t_0)` for all k. In particular `X^k(neg(psi)) in chain(t_0)` for all k >= 1.

**Derivation**: From `X^k(neg(psi)) in M` for all k, can we derive `G(neg(psi)) in M`? Yes, IF we have the omega-rule or an induction principle. In TM logic with the axiom system, `G(phi) <-> phi AND X(G(phi))` (using temp_4 and G_implies_X). But deriving G(phi) from X^k(phi) for all k is exactly the induction principle that we cannot do finitely.

**THIS APPROACH ALSO FAILS.**

**DEFINITIVE APPROACH: Prove forward_F and forward_until SIMULTANEOUSLY by well-founded induction on a custom measure that DOES decrease.**

The measure: for the deterministic chain, define `dist(t, psi) = min { k : psi in chain(t + k) }` if finite, else infinity. We prove `dist(t, psi)` is always finite when `F(psi) in chain(t)`.

By `until_persists_chain`:
- If `psi in chain(t+1)`: `dist(t, psi) = 1`, done.
- If `psi not in chain(t+1)`: `(top U psi) in chain(t+1)`, so `F(psi) in chain(t+1)`. We need `dist(t+1, psi)` to be finite. If we can show `dist(t+1, psi) < dist(t, psi)`, we're done by well-founded induction. But `dist(t+1, psi) = dist(t, psi) - 1` only if `dist(t, psi)` is already known to be finite -- circular.

**THE ONLY VIABLE APPROACH: Abandon the deterministic chain for forward_F. Use the DOVETAILED chain which resolves F-obligations BY CONSTRUCTION.**

The dovetailed chain's only sorry is `forward_dovetailed_until_persists` (Until persistence through g_content-based steps). The plan should focus on closing THIS sorry, or on finding an alternative path that avoids Until/Since entirely for the temporal coherence argument.

**ACTUAL STRATEGY FOR THIS PLAN**:

After exhaustive analysis (15 rounds), the mathematically correct approach is:

**Strategy: Prove forward_F for the deterministic chain using the FINITE STATE REPETITION property combined with the X-DET axiom.**

The X-Det axiom gives `neg(X(phi)) -> X(neg(phi))`: if `X(phi)` is not in M, then `X(neg(phi))` is in M. Combined with X-K (`X(phi -> psi) -> (X(phi) -> X(psi))`), X is a COMPLETE BOOLEAN HOMOMORPHISM from formulas to x_content.

**Theorem**: For any finite set of formulas S and MCS M, the set `x_content(M) ∩ S` is completely determined by `M ∩ { X(phi) : phi in S }`, which equals `M ∩ x_lift(S)`. Since x_lift(S) is finite, there are finitely many possibilities.

**Key Lemma (det_chain_periodic)**: The deterministic chain restricted to any finite closure is eventually periodic.

**Proof of forward_F**: Given `F(psi) in chain(t)`, by `F_until_equiv`, `(top U psi) in chain(t)`. By `until_persists_chain`, either psi appears or `(top U psi)` persists. If it persists forever, the chain restricted to the closure is periodic. In the periodic portion, `(top U psi)` is present at every position. But `(top U psi) -> F(psi)` (by `until_implies_some_future`), so `F(psi)` is present at every position in the cycle. Since the cycle repeats exactly, `neg(psi)` is at every position in the cycle.

Now: by the periodicity, `chain(t_0) = chain(t_0 + p)` restricted to S. The chain from `t_0` to `t_0 + p - 1` is a FINITE CYCLE. In this cycle, for every position i: `neg(psi) in chain(t_0 + i)` (since psi never appears) and `F(psi) in chain(t_0 + i)`.

Consider the formula `(top U psi)` at position `t_0`. By `until_unfold`: `X(psi OR (top AND (top U psi))) in chain(t_0)`. Since psi not in chain(t_0 + 1), `(top AND (top U psi)) in chain(t_0 + 1)`, so `(top U psi) in chain(t_0 + 1)`. This continues around the cycle. At position `t_0 + p - 1`: `X(psi OR ...) in chain(t_0 + p - 1)`, and `psi OR (top AND (top U psi)) in chain(t_0 + p)`. Since `chain(t_0 + p) = chain(t_0)` (restricted to S), and `psi not in chain(t_0)`, we get `(top U psi) in chain(t_0)` again. This is consistent -- the cycle is self-consistent.

**However**: `(top U psi)` semantically means psi EVENTUALLY holds. The cycle demonstrates a SYNTACTICALLY consistent MCS that contains `(top U psi)` but never `psi`. Is this possible?

YES, it is possible in an MCS! The MCS is a set of FORMULAS, not a model. The formula `(top U psi)` in an MCS does NOT mean psi holds at some future TIME in the chain -- it means the MCS contains the formula. The chain provides a MODEL, and the truth lemma connects MCS membership to model truth. But the truth lemma for Until is what we're trying to prove.

**This means**: the periodicity argument alone cannot close forward_F. We need the truth lemma to mediate between syntactic MCS membership and semantic truth, but the truth lemma needs forward_F. The circularity persists.

**RESOLUTION: Abandon the attempt to prove forward_F for an ARBITRARY deterministic chain. Instead, prove it for the DOVETAILED chain, which resolves F-obligations by construction.**

**Tasks**:
- [ ] Document the definitive analysis showing forward_F for deterministic chain is circular
- [ ] Identify the minimal sorry needed: `forward_dovetailed_until_persists`
- [ ] Determine whether Until persistence can be weakened or circumvented for the dovetailed chain

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `DeterministicChain.lean` - Add periodicity infrastructure (may be useful later, but NOT the forward_F resolution)
- Analysis document in specs/

**Verification**:
- Clear mathematical document showing why deterministic chain forward_F is circular
- Identification of the minimal remaining sorry

---

### Phase 2: Close Dovetailed Chain Until Persistence [BLOCKED]

**Goal**: Close `forward_dovetailed_until_persists` by proving that the dovetailed chain's g_content-based steps DO preserve `(top U psi)` persistence, using the derivation `(top U psi) -> G(top U psi)`.

**Mathematical Argument**:

The dovetailed chain uses `forward_step` which gives successors with `g_content(chain(n)) subset chain(n+1)`. Until persistence fails because `until_unfold` gives `X(stuff)` which is in x_content but not g_content.

However, there IS a path: `(top U psi) -> F(psi)` (by `until_implies_some_future`), and `F(psi) = neg(G(neg(psi)))`. From `F(psi)`, we get `neg(G(neg(psi)))`. We need to show `(top U psi)` persists through g_content-based steps.

**Key derivation to find**: `(top U psi) -> G(top U psi)` or equivalently `(top U psi) -> X(top U psi)` (then use induction + temp_4 pattern).

From `until_unfold`: `(top U psi) -> X(psi OR (top AND (top U psi)))`. If psi holds at the next step, Until is resolved. If not, `(top U psi)` is at the next step. But `X(psi OR (top AND (top U psi)))` gives either `X(psi)` or `X(top U psi)`. In MCS terms, either `psi in x_content(M)` or `(top U psi) in x_content(M)`.

For the g_content-based successor: `g_content(M) subset chain(n+1)`. We need `(top U psi)` or `psi` to be in `g_content(M)`.

`G(top U psi) in M` would give `(top U psi) in g_content(M)`. But can we derive `(top U psi) -> G(top U psi)`?

NO: `(top U psi)` means psi eventually, while `G(top U psi)` means at ALL future times, psi eventually from that time. These are different: `G(top U psi)` is strictly stronger (it's `G(F(psi))` essentially). The derivation `(top U psi) -> G(top U psi)` is NOT valid in general.

**Alternative**: Use the fact that `F(psi) = neg(G(neg(psi)))`. If `F(psi) in M` and the forward_step resolves F(psi) at step n (i.e., psi in chain(n+1)), then Until is resolved at n+1. If forward_step does NOT resolve F(psi) at step n (targets a different formula), then we need `(top U psi)` to persist.

The forward_step gives g_content(M) subset chain(n+1). We have `(top U psi) in M` and `X(psi OR ...) in M`. So `psi OR (top AND (top U psi)) in x_content(M)`. Since `g_content(M) subset x_content(M)`, and `x_content(M)` contains this disjunction, but `g_content(M)` may not.

**The fix**: Modify the dovetailed chain construction to use x_content-based steps (like the deterministic chain) EXCEPT at targeted resolution steps. At resolution steps, extend x_content(M) with the target psi via Lindenbaum (if x_content(M) union {psi} is consistent) or fall through to pure x_content step.

But research showed `x_content(M) union {psi}` can be inconsistent.

**Alternative fix**: At non-resolution steps, use x_content(M) directly (not a Lindenbaum extension). This is exactly the deterministic chain. At resolution steps, use the dovetailed chain's targeted step. The hybrid chain alternates.

**The ACTUAL fix for `forward_dovetailed_until_persists`**:

Instead of proving `(top U psi) in g_content(M)`, prove the WEAKER statement that suffices: either psi appears at the next step (resolving Until) or `(top U psi)` appears at the next step (persistence).

The dovetailed forward_step gives chain(n+1) = Lindenbaum extension of `g_content(chain(n)) union {target}` (if F(target) in chain(n)) or `g_content(chain(n)) union {top}` (default).

The successor is an MCS containing g_content(chain(n)). We have `X(psi OR (top AND (top U psi))) in chain(n)`, so `psi OR (top AND (top U psi)) in x_content(chain(n))`. But chain(n+1) contains g_content(chain(n)), not x_content(chain(n)).

**G-content includes G-stripped formulas only**: `phi in g_content(M)` iff `G(phi) in M`. The formula `psi OR (top AND (top U psi))` is NOT of the form G(something) in chain(n) (it's X(something)).

**Resolution path**: Add new axioms or use existing derivations to show that temporal unfolding formulas for Until ARE in g_content when the Until formula is.

Specifically: if `(top U psi) in M`, is `G(top U psi) in M`? No, not in general. But if `(top U psi) AND G(neg(psi)) in M`... that's contradictory.

**REVISED APPROACH FOR PHASE 2**: Instead of closing the sorry in the dovetailed chain directly, BUILD A NEW HYBRID CHAIN that uses x_content steps everywhere and resolves F-obligations through the FINITE REPETITION property.

Actually, the cleanest path is to close the dovetailed chain's Until persistence sorry by modifying the dovetailed chain to use a STRONGER successor: `x_content(M) union {target}` extended via Lindenbaum, falling back to `x_content(M)` (i.e., pure deterministic step) when the union is inconsistent.

**Tasks**:
- [ ] Modify `forward_step` to use `x_content(M)` as the base (not `g_content(M)`)
- [ ] Prove that `x_content(M) union {target}` consistency check preserves MCS property
- [ ] When inconsistent, fall back to pure x_content(M) (which IS MCS by x_content_mcs)
- [ ] Prove `forward_dovetailed_until_persists` for the modified chain
- [ ] Prove `forward_dovetailed_forward_F` for the modified chain

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `DovetailedChain.lean` - Modify forward_step to use x_content base

**Verification**:
- `forward_dovetailed_until_persists` compiles without sorry
- `forward_dovetailed_forward_F` compiles without sorry

---

### Phase 3: Close forward_F and backward_P for Dovetailed FMCS [NOT STARTED]

**Goal**: Close `DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` using the modified dovetailed chain from Phase 2.

**Approach**: With Until persistence proved (Phase 2), the existing proof skeleton for `forward_dovetailed_forward_F` (lines 650-659) should work: F(psi) in chain(t) -> (top U psi) in chain(t) -> by Until persistence + fair scheduling, eventually psi appears. The strict inequality `t < s` (needed for DovetailedFMCS_forward_F) needs the `m = t` edge case handling.

For the `m = t` case: if psi already at chain(t), then F(psi) means psi at some s > t. We have psi at t, but need s > t. Use: `F(psi) in chain(t)` implies `X(psi OR (top AND (top U psi))) in chain(t)`. So at chain(t+1), either psi or (top U psi). If psi: s = t+1 > t. If (top U psi): continue with Until persistence to find s > t+1.

**Tasks**:
- [ ] Close `DovetailedFMCS_forward_F` using `forward_dovetailed_forward_F` + strict inequality handling
- [ ] Close `DovetailedFMCS_backward_P` symmetrically
- [ ] Verify box_class_agree propagation still works with modified chain

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `DovetailedChain.lean` - Close the two main sorry sites

**Verification**:
- `DovetailedFMCS_forward_F` compiles without sorry
- `DovetailedFMCS_backward_P` compiles without sorry
- `lake build Bimodal.Metalogic.Algebraic.DovetailedChain` succeeds

---

### Phase 4: Build Until/Since Coherence for Dovetailed BFMCS [NOT STARTED]

**Goal**: Prove `until_since_coherent` for the dovetailed BFMCS. This requires proving the four Until/Since coherence conditions (forward_until, backward_until, forward_since, backward_since) at the BFMCS level.

**Approach**:

For `forward_until`: `(phi U psi) in fam.mcs t` -> need `exists s > t, psi in fam.mcs s AND forall r in (t,s), phi in fam.mcs r`.

With the modified dovetailed chain (x_content-based steps + targeted F-resolution):
1. `(phi U psi) in chain(t)` implies `F(psi) in chain(t)` (by `until_implies_some_future`)
2. By `DovetailedFMCS_forward_F` (Phase 3): exists `s > t` with `psi in chain(s)`
3. Take the MINIMAL such `s` (well-ordering on Int restricted to s > t)
4. For all `r in (t, s)`: `psi not in chain(r)` (minimality), so by `until_persists_chain` (from the x_content-based steps), `phi in chain(r)` and `(phi U psi) in chain(r)`

Step 4 requires Until persistence for the MODIFIED chain (not just the pure deterministic chain). If the modified chain uses x_content at non-resolution steps, Until persistence holds at those steps. At resolution steps (targeted Lindenbaum extension of x_content(M) union {target}), Until persistence needs the Lindenbaum extension to include the Until formula. Since the extension is a SUPERSET of x_content(M), and `(phi U psi) in x_content(M)` (from until_unfold + x_content propagation), the extension also contains `(phi U psi)`.

Wait: `(phi U psi) in x_content(M)` requires `X(phi U psi) in M`. By `until_unfold`, `(phi U psi) -> X(psi OR (phi AND (phi U psi)))`. This gives `X(psi OR ...)` not `X(phi U psi)`. So `(phi U psi)` may NOT be in x_content(M).

**Fix**: The disjunction `psi OR (phi AND (phi U psi))` is in x_content(M). At the resolution step, if psi appears (target resolved), Until is resolved. If psi does not appear in the Lindenbaum extension, then `(phi AND (phi U psi))` is in the extension (MCS disjunction elimination), giving both phi and (phi U psi).

For `backward_until`: Given semantic Until witnesses (s > t with psi at s, phi at intermediate r), prove `(phi U psi) in chain(t)`. This uses `until_intro` axiom:
- `G(psi -> neg(phi U psi)) AND G(phi AND X(neg(phi U psi)) -> neg(phi U psi)) -> ((phi U psi) -> X(neg(phi U psi)))` (until_induction)
- Combined with other axioms, derive that MCS membership of intermediate phi's + final psi gives (phi U psi) at t

The backward direction for D = Int is simpler: start from `psi in chain(s)`, and work backward through the chain from s to t+1. At each step r (s > r > t): `phi in chain(r)` and `(phi U psi) in chain(r)` can be derived using `until_intro` axiom applied through the x_content structure.

**Tasks**:
- [ ] Prove `forward_until` for the dovetailed BFMCS (uses forward_F + Until persistence + minimality)
- [ ] Prove `backward_until` for the dovetailed BFMCS (uses until_intro + x_content chain structure)
- [ ] Prove `forward_since` symmetrically
- [ ] Prove `backward_since` symmetrically
- [ ] Package into `BFMCS.until_since_coherent` for the dovetailed bundle

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `DovetailedChain.lean` - Add Until/Since coherence proofs
- `TemporalCoherence.lean` - Possibly add helper lemmas

**Verification**:
- `dovetailed_bfmcs_until_since_coherent` compiles without sorry
- Type matches `BFMCS.until_since_coherent`

---

### Phase 5: Wire Dovetailed BFMCS to Completeness [NOT STARTED]

**Goal**: Wire the dovetailed BFMCS (with temporal coherence + Until/Since coherence) through `parametric_algebraic_representation_relative` to get `completeness_over_Int`.

**Approach**:

The representation theorem needs:
1. `B : BFMCS Int` -- the dovetailed BFMCS
2. `h_tc : B.temporally_coherent` -- from DovetailedFMCS_forward_F/backward_P (Phase 3)
3. `h_uc : B.until_since_coherent` -- from Phase 4
4. A family `fam` in B with `phi.neg in fam.mcs 0` for the target formula phi

Construct BFMCS:
- Given non-provable phi, extend {phi.neg} to MCS M_0
- Build DovetailedFMCS from M_0
- Build dovetailed bundle (dovetailedBoxClassFamilies)
- Wrap into BFMCS with modal forward/backward

The existing `dovetailedBoxClassFamilies_modal_forward` and related lemmas handle modal coherence. Temporal coherence (h_tc) follows from Phase 3 (forward_F/backward_P on each family). Until/Since coherence (h_uc) follows from Phase 4.

**Tasks**:
- [ ] Define `dovetailed_bfmcs` : `BFMCS Int` packaging the dovetailed bundle
- [ ] Prove `dovetailed_bfmcs_tc` : `dovetailed_bfmcs.temporally_coherent`
- [ ] Prove `dovetailed_bfmcs_uc` : `dovetailed_bfmcs.until_since_coherent`
- [ ] Define `completeness_over_Int` using `parametric_algebraic_representation_relative`
- [ ] Fix `ParametricRepresentation.lean` broken import (missing h_uc arg noted in handoff)

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `DovetailedChain.lean` - Add BFMCS packaging
- `ParametricRepresentation.lean` - Fix h_uc parameter
- New file or section for `completeness_over_Int`

**Verification**:
- `completeness_over_Int` compiles without sorry
- `lake build` succeeds for the entire project

---

### Phase 6: Clean Up Obsolete Sorries and Verify [NOT STARTED]

**Goal**: Remove or mark as obsolete the sorry sites that are no longer on the critical path, and verify the complete sorry-free path from `completeness_over_Int` to the axiom system.

**Tasks**:
- [ ] Mark `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` in UltrafilterChain.lean as obsolete (not on critical path if dovetailed chain is used)
- [ ] Mark `restricted_shifted_truth_lemma` Until/Since sorries in CanonicalConstruction.lean as obsolete
- [ ] Run `lake build` and verify no sorry warnings on the completeness critical path
- [ ] Document the sorry-free completeness path in a brief summary
- [ ] Update the plan status markers

**Timing**: 2 hours

**Depends on**: 5

**Files to modify**:
- `UltrafilterChain.lean` - Add obsolescence notes
- `CanonicalConstruction.lean` - Add obsolescence notes
- `DovetailedChain.lean` - Final cleanup

**Verification**:
- `lake build` succeeds
- The path `completeness_over_Int -> parametric_algebraic_representation_relative -> parametric_shifted_truth_lemma -> dovetailed_bfmcs` contains no sorry
- All remaining sorries are documented as not on the critical path

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `completeness_over_Int` theorem statement is correct (non-provable implies countermodel exists)
- [ ] No sorry on the critical path from `completeness_over_Int` backward through all dependencies
- [ ] The dovetailed chain modification preserves existing sorry-free properties (forward_G, backward_H, box_class_agree)
- [ ] Until/Since persistence works correctly with the modified chain construction

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/15_forward-f-resolution.md` (this file)
- Modified `DovetailedChain.lean` with sorry-free forward_F, backward_P, Until/Since coherence
- Modified `ParametricRepresentation.lean` with h_uc fix
- `completeness_over_Int` theorem in the codebase
- Summary document upon completion

## Rollback/Contingency

If the x_content-based modification to the dovetailed chain fails (Phase 2):
- Revert DovetailedChain.lean to pre-modification state
- Consider alternative: prove completeness WITHOUT Until/Since by using a restricted formula language
- Consider alternative: use the restricted chain path (DeferralRestrictedMCS) which has bounded F-nesting

If Until/Since coherence proof fails (Phase 4):
- Fall back to proving completeness for the Until/Since-free fragment of TM logic
- The G/H/Box fragment has sorry-free temporal coherence via the dovetailed chain's existing forward_G/backward_H
- Mark Until/Since as a separate sub-task

If the entire dovetailed approach fails:
- Preserve all existing sorry-free infrastructure
- Document the failure analysis
- Consider the "algebraic restructure" approach (40-60h) from research report 15 as a longer-term project
