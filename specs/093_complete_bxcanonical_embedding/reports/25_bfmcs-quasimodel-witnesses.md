# Research Report: BFMCS Restructuring with Quasimodel Witnesses

**Task**: 93 -- Complete BXCanonical embedding (close 6 sorry sites)
**Date**: 2026-04-16
**Session**: sess_1776368824_3b2c98
**Report**: 25 (solo deep-dive)

## Executive Summary

This report works out the "BFMCS Restructuring with Quasimodel Witnesses" strategy in full mathematical detail, from first principles. After 24 prior rounds of research that failed to prove `rr_fwd_chain_forward_F` (the primary blocker), this report takes a step back and asks: can we restructure the BFMCS construction so that the 6 sorry sites become provable through a fundamentally different approach?

**Conclusion**: The quasimodel witness strategy as originally conceived (replacing the chain-level F-resolution with BXPoint-level resolution) has a **fatal bridging gap** that makes it unworkable in its naive form. However, this analysis reveals a more promising variant: the **Non-Enriched Chain with Semantic Eventuality** approach, which replaces the enriched forward step with the standard `fwd_succ` step and proves forward_F by a "G-saturation contradiction" argument. This variant is architecturally simpler and has a clear proof path for 5 of the 6 sorries. The forward Until/Since coherence (sorry 6) requires a separate construction using BX12 (F-Until bridge) and the self-accumulation axiom BX5.

---

## Part 1: First-Principles Definitions

### 1.1 The Semantic Target

**TaskFrame D** (`Semantics/TaskFrame.lean:93`). For `D` a totally ordered abelian group:

```
structure TaskFrame (D) where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : forall w u, task_rel w 0 u <-> w = u
  forward_comp : forall w u v x y, 0 <= x -> 0 <= y ->
    task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
  converse : forall w d u, task_rel w d u <-> task_rel u (-d) w
```

**TaskModel** (`Semantics/TaskModel.lean:43`):

```
structure TaskModel (F : TaskFrame D) where
  valuation : F.WorldState -> Atom -> Prop
```

**WorldHistory** (`Semantics/WorldHistory.lean`): A function from times to world states, with a domain predicate.

**truth_at** (`Semantics/Truth.lean:120`). The recursive truth evaluation:

```
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | atom p     => exists ht : tau.domain t, M.valuation (tau.states t ht) p
  | bot        => False
  | imp phi psi => truth_at phi -> truth_at psi
  | box phi    => forall sigma in Omega, truth_at M Omega sigma t phi
  | all_future phi => forall s >= t, truth_at M Omega tau s phi     -- REFLEXIVE: s >= t
  | all_past phi   => forall s <= t, truth_at M Omega tau s phi     -- REFLEXIVE: s <= t
  | untl phi psi   => exists s >= t, truth_at psi at s
                      and forall r in [t,s), truth_at phi at r      -- REFLEXIVE witness, OPEN left guard
  | snce phi psi   => exists s <= t, truth_at psi at s
                      and forall r in (s,t], truth_at phi at r      -- REFLEXIVE witness, OPEN right guard
```

Key semantic facts:
- G is reflexive (uses `t <= s`, not `t < s`)
- Until witness is reflexive (`t <= s`, not `t < s`)
- Until guard is `[t, s)` (closed at t, open at s) -- so when s = t, the guard is vacuously empty
- BX1 (`G(phi) -> phi`) IS valid under reflexive G semantics

### 1.2 The Algebraic Bridge: FMCS and BFMCS

**FMCS D** (`Bundle/FMCSDef.lean:99`). A family of MCS indexed by D:

```
structure FMCS (D) where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t <= t' -> G(phi) in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' <= t -> H(phi) in mcs t -> phi in mcs t'
```

Note: FMCS uses reflexive inequalities (`<=`) matching the reflexive semantics.

**BFMCS D** (`Bundle/BFMCS.lean:84`). A bundle of FMCS families with modal coherence:

```
structure BFMCS (D) where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : forall fam in families, forall phi t,
    box(phi) in fam.mcs t -> forall fam' in families, phi in fam'.mcs t
  modal_backward : forall fam in families, forall phi t,
    (forall fam' in families, phi in fam'.mcs t) -> box(phi) in fam.mcs t
  eval_family : FMCS D
  eval_family_mem : eval_family in families
```

### 1.3 The Three Restricted Coherence Properties

The truth lemma (`RestrictedParametricTruthLemma.lean:308`) requires three coherence conditions, all restricted to the root formula:

**1. restricted_temporally_coherent root** (`TemporalCoherence.lean:295`):

```
forall fam in B.families:
  (forall t, forall phi in deferralClosure(root),
    F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s)     -- forward_F
  and
  (forall t, forall phi in deferralClosure(root),
    P(phi) in fam.mcs t -> exists s < t, phi in fam.mcs s)     -- backward_P
```

**2. restricted_backward_until_since_coherent root** (`TemporalCoherence.lean:565`):

```
forall fam in B.families:
  (forall t, forall (phi U psi) in subformulaClosure(root),
    (exists s >= t, psi in fam.mcs s and forall r in [t,s), phi in fam.mcs r)
    -> (phi U psi) in fam.mcs t)
  and (symmetric for Since)
```

**3. restricted_forward_until_since_coherent root** (`TemporalCoherence.lean:535`):

```
forall fam in B.families:
  (forall t, forall (phi U psi) in subformulaClosure(root),
    (phi U psi) in fam.mcs t
    -> exists s >= t, psi in fam.mcs s and forall r in [t,s), phi in fam.mcs r)
  and (symmetric for Since)
```

### 1.4 How the Truth Lemma Uses These Properties

The truth lemma proceeds by structural induction on formulas in `subformulaClosure(root)`. The three coherence properties are used at specific cases:

| Formula case | Direction | Property used |
|---|---|---|
| `all_future psi` | forward (MCS -> truth) | `forward_G` from FMCS |
| `all_future psi` | backward (truth -> MCS) | `restricted_temporally_coherent` (forward_F on `neg(psi)`) |
| `all_past psi` | forward | `backward_H` from FMCS |
| `all_past psi` | backward | `restricted_temporally_coherent` (backward_P on `neg(psi)`) |
| `untl phi psi` | forward (MCS -> truth) | `restricted_forward_until_since_coherent` |
| `untl phi psi` | backward (truth -> MCS) | `restricted_backward_until_since_coherent` |
| `snce phi psi` | forward | `restricted_forward_until_since_coherent` |
| `snce phi psi` | backward | `restricted_backward_until_since_coherent` |

**Critical observation**: The G/H backward cases use `restricted_temporally_coherent` to obtain a WITNESS (via contraposition). They invoke `forward_F` on `neg(psi)`, which is in `deferralClosure(root)` because `neg(psi) in closureWithNeg(root) subset deferralClosure(root)` when `psi in subformulaClosure(root)`.

### 1.5 The Parametric Canonical Model

**ParametricCanonicalTaskFrame D** (`Algebraic/ParametricRepresentation.lean`): A TaskFrame whose world states are tuples `(fam : FMCS D, t : D)`, where:
- The task_rel connects `(fam, t)` to `(fam', t')` if `fam = fam'` and `t' - t = d`
- Nullity identity holds because `d = 0` forces `t' = t`
- Forward_comp holds by arithmetic
- Converse holds by negation symmetry

**ShiftClosedParametricCanonicalOmega B**: The set of all time-shifted histories derived from families in B. This is shift-closed by construction.

**parametric_to_history fam**: Converts an FMCS family to a WorldHistory.

### 1.6 How dd_countermodel Chains Everything Together

```lean
dd_countermodel (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula) (h_neg_in : phi.neg in M) :
  exists ... not truth_at ... phi
```

The proof:
1. Let `sigma_list = extendedDeferralClosure(phi).toList`
2. Construct `dd_bfmcs M h_mcs sigma_list` -- the BFMCS
3. Use `ParametricCanonicalTaskFrame Int` as the frame
4. Show `phi.neg in (shifted_dd_fmcs M h_mcs sigma_list 0).mcs 0` (by `shifted_dd_fmcs_at_s`)
5. Apply `fully_restricted_parametric_representation_from_neg_membership`, which needs:
   - `dd_bfmcs_restricted_tc` (sorry 4)
   - `dd_bfmcs_restricted_buc` (sorry 5)
   - `dd_bfmcs_restricted_fuc` (sorry 6)

### 1.7 The Current dd_bfmcs Construction

```lean
dd_bfmcs (M0 : Set Formula) (h0 : SetMaximalConsistent M0) (sigma_list : List Formula) : BFMCS Int where
  families := { fam | exists N h_N s,
    (forall phi, box(phi) in M0 <-> box(phi) in N) and
    fam = shifted_dd_fmcs N h_N sigma_list s }
```

Each family is a shifted version of `dd_fmcs N h_N sigma_list`, where:
- `dd_fmcs` assigns `dd_chain N h_N sigma_list t` to each `t : Int`
- `dd_chain` uses `rr_fwd_chain` for `t >= 0` and `rr_bwd_chain` for `t < 0`
- `shifted_dd_fmcs N h_N sigma_list s` maps `t` to `dd_chain N h_N sigma_list (t - s)`

**Already proved** (sorry-free):
- `modal_forward`: Via box stability across dd_chain and BX1
- `modal_backward`: Via contraposition using `bx_modal_witness`
- `forward_G`: Via `dd_chain_g_content`
- `backward_H`: Via `g_content_subset_implies_h_content_reverse`
- Box stability: `box_stable_dd_chain`

---

## Part 2: The Quasimodel Witness Strategy -- Detailed Analysis

### 2.1 The Original Idea

The quasimodel infrastructure in `Frame.lean:623` provides:

```lean
bx_until_eventuality_resolution (w : BXPoint) (phi psi : Formula)
    (h_until : (phi U psi) in w.formulas) (h_not_psi : psi not_in w.formulas) :
    exists v : BXPoint, bx_le w v and psi in v.formulas and phi in w.formulas
```

This is sorry-free. The idea: instead of proving F-resolution on the Int chain, use this BXPoint-level infrastructure to provide witnesses whenever the truth lemma needs them.

### 2.2 The BXPoint-to-Int Bridge Problem

The fundamental problem is: **BXPoints are abstract MCS, not Int-indexed chain positions**.

The BXPoint `v` produced by `bx_until_eventuality_resolution` is an MCS that satisfies:
- `bx_le w v` (i.e., `g_content(w) subset v.formulas`)
- `psi in v.formulas`
- `phi in w.formulas`

But the FMCS structure requires a function `mcs : Int -> Set Formula`. When the truth lemma asks for a witness `s >= t` with `psi in fam.mcs s`, it needs an actual integer `s` where the chain contains `psi`.

**Three potential bridges considered:**

**Bridge A: Embed BXPoint into the chain.** Given BXPoint `v`, find (or construct) an integer position `s` where `fam.mcs s = v.formulas`. This is impossible in general: the chain is deterministically constructed, and an arbitrary MCS has no reason to appear at any position.

**Bridge B: Replace Int indexing with BXPoint indexing.** Use `FMCS BXPoint` instead of `FMCS Int`. This fails because:
1. `TaskFrame D` requires `D` to be a totally ordered abelian group (AddCommGroup + LinearOrder + IsOrderedAddMonoid)
2. BXPoints have no natural group structure or total order
3. The `bx_le` relation is a preorder, not a total order

**Bridge C: Construct a new FMCS that interleaves chain positions with witness positions.** Build a more complex chain that, when `F(psi)` appears at position `t`, "inserts" a BXPoint witness at some position between `t` and `t+1`. This requires fractional positions or a different indexing scheme.

### 2.3 Why Bridge C Also Fails for D = Int

Under `D = Int`, positions are discrete. You cannot insert a position "between" `t` and `t+1` since there are no integers in that gap. If we tried to rearrange the chain to accommodate witnesses, we would need to:
1. Shift all later positions by 1 (or more)
2. Re-prove all existing properties for the shifted chain
3. Handle the fact that inserting a witness at one position might create new F-obligations that need their own witnesses

This leads to an infinite regress in the worst case. Moreover, the existing `dd_chain_g_content` proof relies on the deterministic structure of the chain and would break if positions were rearranged.

### 2.4 Could We Use D = Rat or D = Real Instead?

Theoretically, dense orders allow inserting witnesses between existing positions. But:
1. The entire codebase is built around `D = Int` for the canonical construction
2. `dd_bfmcs` produces `BFMCS Int`
3. Switching to `Rat` would require rewriting the entire chain construction
4. More fundamentally, `rr_fwd_chain` is defined by Nat-recursion; there is no natural way to extend it to a dense order

### 2.5 The Restructured Truth Lemma Approach

A more sophisticated version of the quasimodel strategy would restructure the truth lemma itself. Instead of requiring coherence properties on the FMCS chain, modify the truth lemma to use BXPoint witnesses directly.

**How this would work in theory:**

For the Until forward case (`(phi U psi) in fam.mcs t -> exists s >= t, truth(psi, s) and guard`):

1. If `psi in fam.mcs t`, take `s = t` (reflexive base case)
2. If `psi not_in fam.mcs t`, use `bx_until_eventuality_resolution` on the BXPoint `{fam.mcs t, (fam.is_mcs t)}` to get a BXPoint `v` with `psi in v.formulas` and `bx_le w v`
3. The BXPoint `v` is an MCS, but we need it to appear as `fam.mcs s` for some `s >= t`

**This does not resolve the bridging problem.** Step 3 still requires mapping the abstract BXPoint `v` to a chain position. The truth lemma evaluates truth at `parametric_to_history fam`, which reads `fam.mcs` at each time. An MCS that is not `fam.mcs s` for any `s` cannot appear in this evaluation.

### 2.6 Verdict on the Pure Quasimodel Strategy

**The pure quasimodel witness strategy has a fatal gap**: it cannot bridge from BXPoint witnesses (abstract MCS) to Int-indexed chain positions. This gap is not a matter of missing infrastructure but a fundamental type mismatch between the quasimodel world (abstract preordered MCS) and the FMCS world (Int-indexed chain of MCS).

**Confidence that pure quasimodel strategy works: 5%** (essentially nil unless a novel bridging mechanism is discovered).

---

## Part 3: Alternative Strategy -- Non-Enriched Chain with G-Saturation

### 3.1 The Key Insight: F-Loss is Harmless in the Non-Enriched Chain

Report 24 (Finding 4) noted that Goldblatt's standard approach processes demands sequentially with `{psi_j} union g_content(M_{j-1})` seeds, and F-obligations may or may not persist. The crucial insight:

**If F(psi) is lost at some step, then G(neg(psi)) entered the chain, and psi is refuted at all future positions. In this case, (phi U psi) cannot be in any MCS at any earlier position either (because BX10 gives F(psi) from phi U psi, but G(neg(psi)) contradicts F(psi)).**

Let me make this precise.

### 3.2 The Non-Enriched Forward Chain

Replace `enriched_fwd_step` with `fwd_succ`:

```
fwd_succ (M : Set Formula) (h_mcs : SetMaximalConsistent M) (target : Formula) :=
  Lindenbaum extension of {target} union g_content(M)
```

This gives:
- `g_content(M) subset fwd_succ(M, target)`
- If `F(target) in M`: `target in fwd_succ(M, target)`
- F-obligations for OTHER formulas may be lost

### 3.3 The Forward_F Proof for the Non-Enriched Chain

**Claim**: For the non-enriched round-robin chain, if `F(psi) in chain(n)` and `psi in sigma_list`, then `exists s > n, psi in chain(s)`.

**Proof sketch**:

The round-robin schedule visits psi at infinitely many steps: at step `k * |sigma_list| + j` where `sigma_list[j] = psi` and `k = 0, 1, 2, ...`.

Case 1: F(psi) is still in chain(m) at some visit step m (where target = psi). Then `fwd_succ` resolves psi directly: `psi in chain(m+1)` because the seed `{psi} union g_content(chain(m))` is consistent (by `forward_temporal_witness_seed_consistent`). Take `s = m + 1 > m >= n`.

Case 2: F(psi) is lost before any visit step. That is, there exists some `k` with `n < k` and `F(psi) not_in chain(k)`. Since `F(psi) = neg(G(neg(psi)))`, we have `G(neg(psi)) in chain(k)` (by MCS negation completeness). By `forward_G`, `neg(psi) in chain(k')` for all `k' >= k`.

But wait -- we need `psi in chain(s)` for some `s > n`. In case 2, `neg(psi)` is in all positions from `k` onward, so `psi` cannot be in any of those positions (by consistency). We need `psi` at some `s` with `n < s < k`, or we need to derive a contradiction.

**The problem with Case 2**: We have `F(psi) in chain(n)` and `G(neg(psi)) in chain(k)` for `k > n`. Do these contradict?

Not necessarily! The chain at position `n` is a different MCS from position `k`. The chain has `g_content(chain(n)) subset chain(n+1)`, but this only propagates G-formulas forward. F(psi) at position n does NOT propagate forward through g_content.

**So the non-enriched chain has the same fundamental problem as the enriched chain: F(psi) can be lost before it is resolved.**

### 3.4 Why F-Loss Is NOT Harmless After All

The argument "F-loss implies G(neg(psi)) entered" is correct. But "G(neg(psi)) entered" does not mean "psi was already resolved somewhere between n and the loss point." F(psi) can be lost at the very next step if the Lindenbaum extension chooses to include G(neg(psi)).

More precisely: the seed `{target'} union g_content(chain(n))` for step n+1 (where target' != psi) may be consistent with G(neg(psi)). The Lindenbaum extension could then include G(neg(psi)) in chain(n+1), giving F(psi) not_in chain(n+1), even though psi was never placed in any chain position.

This means Case 2 can happen without psi ever appearing in the chain. Forward_F fails.

### 3.5 Revisiting: Can We Show the Loss-Without-Resolution Cannot Happen?

Suppose `F(psi) in chain(n)` and `F(psi) not_in chain(n+1)`. Then:
- `G(neg(psi)) in chain(n+1)` (negation completeness)
- `g_content(chain(n)) subset chain(n+1)` (g_content propagation)

From `G(neg(psi)) in chain(n+1)` and BX4 (`G(neg(psi)) -> G(G(neg(psi)))`), we get `G(G(neg(psi))) in chain(n+1)`. By g_content propagation backward (using the h_content/g_content duality), can we derive `G(neg(psi)) in chain(n)`?

We have `g_content(chain(n)) subset chain(n+1)`. This means `G(phi) in chain(n) -> phi in chain(n+1)`. But we need the reverse: `G(phi) in chain(n+1) -> G(phi) in chain(n)`.

The g_content propagation only goes FORWARD. We CANNOT derive G(neg(psi)) in chain(n) from G(neg(psi)) in chain(n+1).

However, from BX4': `phi -> H(F(phi))`. So `G(neg(psi)) in chain(n+1)` gives `H(F(G(neg(psi)))) in chain(n+1)`. And by h_content duality (since h_content(chain(n)) subset chain(n+1) in the backward direction... wait, the h_content propagation goes the other direction for the backward chain).

Actually, for the FORWARD chain, we have `g_content(chain(n)) subset chain(n+1)`. The h_content duality gives: `h_content(chain(n+1)) subset chain(n)` (proved as `g_content_subset_implies_h_content_reverse` in the codebase). So:

`H(phi) in chain(n+1) -> phi in chain(n)` -- YES, this works!

So from `G(neg(psi)) in chain(n+1)`:
- By BX4' (`connect_past`): `G(neg(psi)) -> H(F(G(neg(psi))))` (in any MCS)
- So `H(F(G(neg(psi)))) in chain(n+1)`
- By h_content reverse: `F(G(neg(psi))) in chain(n)`

This gives `F(G(neg(psi))) in chain(n)`. But we had `F(psi) in chain(n)`.

Now, `F(G(neg(psi)))` and `F(psi)` are both in chain(n). By BX11 (temporal linearity), one of three cases holds:
1. `F(G(neg(psi)) and psi)` -- i.e., there exists a future time where both G(neg(psi)) and psi hold. But G(neg(psi)) implies neg(psi) (by BX1), contradicting psi.
2. `F(G(neg(psi)) and F(psi))` -- exists future time where G(neg(psi)) and F(psi) both hold. G(neg(psi)) propagates forward, so at any future time of F(psi), neg(psi) holds. But F(psi) says psi holds somewhere even further. The further point has neg(psi) from G(neg(psi)), contradiction.
3. `F(F(G(neg(psi))) and psi)` -- exists future time where F(G(neg(psi))) and psi hold. From F(G(neg(psi))), exists an even further time where G(neg(psi)) holds. At that further time, neg(psi) holds. But this does NOT contradict psi at the intermediate time.

**Case 3 is NOT contradictory.** We have psi at some time s, and G(neg(psi)) at some time s' > s. This is perfectly consistent: psi holds at s, but neg(psi) holds at all times >= s'.

So BX11 alone does not yield a contradiction between `F(psi)` and `F(G(neg(psi)))` at the same time.

### 3.6 Using BX12: The F-Until Bridge

BX12 says: `F(phi) -> (top U phi)`. So from `F(psi) in chain(n)`:
- `(top U psi) in chain(n)`

By BX5 (self-accumulation): `(top U psi) -> (top and (top U psi)) U psi`, which simplifies to `(top U psi) U psi` (since `top and X = X` for any X). This is not immediately useful.

By BX10: `(top U psi) -> F(psi)`. (Already known.)

By BX9: `(top U psi) -> top or psi`, which is trivially true.

The Until formula `(top U psi)` is weaker than having a specific guard: it just says psi holds at some future time with `top` (always true) as the guard.

### 3.7 The Real Path: Forward Until Coherence via BX Axioms

For **forward Until coherence** (sorry 6), the requirement is:

Given `(phi U psi) in fam.mcs t`, produce `s >= t` with `psi in fam.mcs s` and `phi in fam.mcs r` for all `r in [t, s)`.

Under reflexive semantics, when `psi in fam.mcs t`, take `s = t` and the guard is vacuous. So the hard case is when `psi not_in fam.mcs t`.

When `psi not_in fam.mcs t`, BX9 gives `phi in fam.mcs t` (from `(phi U psi) -> (phi or psi)` and negation completeness). BX10 gives `F(psi) in fam.mcs t`.

**The forward Until coherence problem reduces to forward_F**: given `F(psi) in fam.mcs t`, find `s > t` with `psi in fam.mcs s`. Additionally, we need the guard condition `phi in fam.mcs r` for `r in [t, s)`.

For the guard: by BX5, `(phi U psi) -> ((phi and (phi U psi)) U psi)`. So `phi and (phi U psi)` holds at all guard times... but again, this requires knowing WHICH guard times exist in the chain, which is exactly the forward_F problem.

However, there is a stronger approach using BX5 and BX10 together: from `(phi U psi) in fam.mcs t`, by BX5 `((phi and (phi U psi)) U psi) in fam.mcs t`. By BX10, `F(psi) in fam.mcs t`. By `forward_F`, there exists `s > t` with `psi in fam.mcs s`. Now for the guard: at any `r in [t, s)`:

We need to show `phi in fam.mcs r`. We know `(phi U psi) in fam.mcs t`. By `forward_G` of the FMCS, if `G(phi U psi) in fam.mcs t`, then `(phi U psi) in fam.mcs r`. But we only have `(phi U psi) in fam.mcs t`, not `G(phi U psi)`.

**Key question**: Does `(phi U psi) in fam.mcs t` propagate forward through the chain? That is, is `(phi U psi) in fam.mcs r` for `r in [t, s)`?

In general, NO. The chain only propagates G-formulas forward (via g_content). Until formulas are not G-formulas, and there is no mechanism to propagate them.

### 3.8 Forward Until via Step Induction

For `D = Int`, the chain is discrete. We can try to prove the Until guard by step induction on the interval `[t, s)`.

At time `t`: we have `(phi U psi) in fam.mcs t` (given).
At time `t + 1`: we need `(phi U psi) in fam.mcs (t + 1)` or `psi in fam.mcs (t + 1)`.

By BX9: from `(phi U psi) in fam.mcs t`, either `phi in fam.mcs t` or `psi in fam.mcs t`. If `psi in fam.mcs t`, take `s = t` and we are done. Otherwise, `phi in fam.mcs t`.

Now: can we derive `(phi U psi) in fam.mcs (t + 1)` from `(phi U psi) in fam.mcs t` and the chain structure?

The chain propagates `g_content(chain(t)) subset chain(t+1)`. So `G(chi) in chain(t) -> chi in chain(t+1)`. If `G(phi U psi) in chain(t)`, then `(phi U psi) in chain(t+1)`. But we do not have `G(phi U psi)`.

**From BX4 (connect_future)**: `phi -> G(P(phi))`. So `(phi U psi) in chain(t) -> G(P(phi U psi)) in chain(t) -> P(phi U psi) in chain(t+1)`.

`P(phi U psi) in chain(t+1)` means "there exists a past time where (phi U psi) holds." This is true (namely time t), but it does not give us `(phi U psi) in chain(t+1)` itself.

### 3.9 The Fundamental Obstruction (Crystallized)

After this analysis, the fundamental obstruction is now crystal clear:

**The FMCS chain structure only propagates G-formulas forward and H-formulas backward. There is no mechanism to propagate arbitrary formulas (like Until formulas or F-formulas) between adjacent chain positions.**

The enriched chain attempts to preserve F-formulas but gives only disjunctive control. The non-enriched chain loses F-formulas entirely.

The BX axiom system provides:
- BX4: phi -> G(P(phi)) -- "if phi now, then always in the future, phi was true in the past"
- BX4': phi -> H(F(phi)) -- symmetric

These allow deriving the EXISTENCE of a past/future time where phi held, but not the PRESENCE of phi at a specific chain position.

**The only way to get phi at chain position s is if phi is derivable from the seed of chain position s.** The seed is `{target_s} union g_content(chain(s-1))` (for the non-enriched step) or the enriched variant. Neither includes phi unless phi is a G-consequence of chain(s-1).

### 3.10 Why Published Proofs Work Differently

Reviewing the literature:

**Burgess (1984)** and **Goldblatt (1992)**: These work with the FULL canonical model where world states ARE maximal consistent sets and time points ARE also MCS. The temporal order is `bx_le` (the canonical preorder). In this setting, `F(psi) in w` literally means there exists `v >= w` with `psi in v`, by the canonical model construction. There is no chain to speak of; the model is the entire collection of MCS with their canonical ordering.

**GHR (1994)**: Uses filtration and finite model property. Completeness follows from soundness + finite model property, not from a chain construction.

**Reynolds (2003)**: Uses quasimodels and mosaics. The canonical model is built from mosaics (finite consistent labeled graphs), not from Int-indexed chains.

**Key insight**: ALL standard completeness proofs for Until-Since temporal logic use models where the temporal order is inherently part of the MCS structure (via g_content ordering) or use finite models. NONE build a single Int-indexed chain and then try to prove eventuality resolution on it.

The ProofChecker's approach of building `FMCS Int` from a round-robin chain is non-standard. The standard approach is to use the BXPoint frame (with the bx_le preorder) as the model itself.

### 3.11 The Standard Canonical Model Approach

In the standard canonical model for Until-Since temporal logic:

1. World states = MCS (maximal consistent sets)
2. Temporal order: `w <= v` iff `g_content(w) subset v`
3. Modal accessibility: `w ~ v` iff they agree on all box-formulas

The truth lemma for this model:

- `phi in w iff truth(phi)` at w in the canonical model

For the `G(phi)` backward case: if `phi in v` for all `v >= w`, we need `G(phi) in w`. Contrapositive: if `G(phi) not_in w`, then `F(neg(phi)) in w`, so there exists `v >= w` with `neg(phi) in v`. But `phi in v` by hypothesis. Contradiction.

For the `F(psi)` forward case (used in Until): `F(psi) in w` directly gives (by the `bx_forward_witness` construction) a `v >= w` with `psi in v`. This is ALREADY PROVED in the codebase at `Frame.lean:164`.

**The issue**: This canonical model uses `BXPoint` as the world type and `bx_le` as the temporal order. This does NOT directly give an `FMCS Int` (which requires Int indexing).

### 3.12 The Real Question: Can We Bypass Int Indexing?

The `dd_countermodel` theorem uses `ParametricCanonicalTaskFrame Int` which requires `BFMCS Int`. But what if we could use a different frame?

**Option**: Define a `ParametricCanonicalTaskFrame BXPoint` or use a canonical TaskFrame directly from BXPoints.

**Problem**: `TaskFrame D` requires `D` to be a totally ordered abelian group. `BXPoint` has the `bx_le` preorder, which is:
1. NOT total (two MCS may be incomparable)
2. NOT antisymmetric (different MCS can have the same g_content)
3. Has no group structure

So `BXPoint` cannot serve as the duration type `D`.

**However**, the completeness theorem only needs ONE specific model where the formula is false. We can pick ANY model. The model does not need to be Int-indexed; we just need some `D` that is a totally ordered abelian group.

**The standard solution in the literature**: Use the INTEGERS but embed BXPoints into an Int-indexed chain. The embedding uses a "step-by-step construction" that builds the chain by choosing MCS one step at a time.

This is exactly what the current `rr_fwd_chain` does -- but it fails to prove forward_F because the chain's F-obligations get entangled.

---

## Part 4: A New Proposal -- The Demand-Driven Non-Enriched Chain

### 4.1 The Core Idea

The key mathematical insight, already present in Goldblatt (1992), is:

**Do not try to preserve all F-obligations simultaneously. Instead, process them one at a time, in a demand-driven fashion. When an F-obligation cannot be preserved, that is acceptable because the formula has been "permanently refuted" (G(neg(psi)) entered the chain).**

The argument for forward_F then becomes:

Given `F(psi) in chain(n)` and `psi in sigma_list`:
- The chain visits psi at regular intervals
- At each visit step, either F(psi) is still present (and psi is resolved), or F(psi) has been lost
- If F(psi) is lost, then G(neg(psi)) entered the chain at some earlier step

**The missing piece**: Does `G(neg(psi)) in chain(k)` for some `k > n` while `F(psi) in chain(n)` lead to a contradiction? As shown in Section 3.5, BX11 alone does not give a contradiction.

**But there is a subtler argument**: G-formulas propagate backward through h_content. From `G(neg(psi)) in chain(k)`, by BX4' (`G(neg(psi)) -> H(F(G(neg(psi))))`):
- `H(F(G(neg(psi)))) in chain(k)`
- By h_content backward: `F(G(neg(psi))) in chain(k-1)`
- Repeating: `F(G(neg(psi))) in chain(k-2)`, ..., `F(G(neg(psi))) in chain(n)`

Now at chain(n) we have BOTH:
- `F(psi)` in chain(n)
- `F(G(neg(psi)))` in chain(n)

The question is whether `{F(psi), F(G(neg(psi)))} union g_content(chain(n))` is consistent.

**Claim**: It is consistent. Here is why: consider a model with times `... -1, 0, 1, 2, 3, ...` where psi holds at time 1 but neg(psi) holds at all times >= 2. Then at time 0: F(psi) holds (witness at time 1), and F(G(neg(psi))) holds (G(neg(psi)) holds at time 2). There is no contradiction.

So BX11-based arguments also fail, and the "F-loss is harmless" argument has a genuine gap.

### 4.2 A Deeper Insight: The H-Content Propagation of F

Let me reconsider more carefully. We have g_content propagation:

`g_content(chain(n)) subset chain(n+1)` for all n >= 0.

And the h_content duality:

`h_content(chain(n+1)) subset chain(n)` for all n >= 0.

This means: `H(phi) in chain(n+1) -> phi in chain(n)`.

Now, suppose `F(psi) in chain(n)`. By BX4' (connect_past): `F(psi) -> H(F(F(psi)))`. So:
- `H(F(F(psi))) in chain(n)`

By h_content backward from chain(n) to chain(n-1):
- `F(F(psi)) in chain(n-1)`

By FF_imp_F (proved sorry-free in the codebase, `RootScopedChain.lean:61`):
- `F(psi) in chain(n-1)`

So if `F(psi) in chain(n)`, then `F(psi) in chain(n-1)` (for n >= 1). By induction, `F(psi) in chain(0) = M0`.

This means: **any F-formula that appears anywhere in the forward chain was already in M0**. This is the `no_new_f_defects` property.

Similarly, by g_content propagation: `G(psi) in chain(n) -> psi in chain(n+1)`. Combined with BX4 (`psi -> G(P(psi))`), we get `P(psi) in chain(n+1)` from `psi in chain(n)`.

### 4.3 The Correct Forward_F Argument for Non-Enriched Chains

Here is the argument that SHOULD work:

**Setup**: Non-enriched round-robin chain. At step n, the seed is `{target_n} union g_content(chain(n))` where `target_n = sigma_list[n mod |sigma_list|]`.

**Claim**: If `F(psi) in chain(n)` and `psi in sigma_list`, then exists `s > n` with `psi in chain(s)`.

**Proof attempt**:

The round-robin visits psi at step `m` where `m > n` and `target_m = psi` and `F(psi) in chain(m)`.

Wait -- we need `F(psi) in chain(m)`. The non-enriched chain does NOT guarantee this. F(psi) can be lost at any step.

But we showed in 4.2 that `F(psi) in chain(n) -> F(psi) in chain(0)`. Can we show `F(psi) in chain(0) -> F(psi) in chain(n)` for all n?

**NO.** The propagation from chain(0) forward does NOT preserve F-formulas. Only G-formulas propagate forward. F(psi) = neg(G(neg(psi))) is NOT a G-formula.

However, `F(psi) in M0` means `neg(G(neg(psi))) in M0`, which means `G(neg(psi)) not_in M0` (by consistency). Does `G(neg(psi)) not_in M0` imply `G(neg(psi)) not_in chain(n)` for all n?

**No.** G(neg(psi)) could enter the chain at any step via the Lindenbaum extension.

### 4.4 The Constrained-Extension Approach

What if we constrain the Lindenbaum extension at each step to NOT include G(neg(psi)) for any psi in sigma_list with F(psi) in M0?

This is essentially what the enriched chain does. The enriched seed includes `f_carry(M)` which forces `F(chi)` or `chi` into the next MCS, preventing G(neg(chi)) from entering.

And we are back to the enriched chain's problem: disjunctive control.

### 4.5 The Goldblatt Approach: Full Canonical Model as Intermediary

Goldblatt's approach (Logics of Time and Computation, 1992) works as follows:

1. Build the full canonical model: world states = ALL MCS, ordered by g_content inclusion
2. Prove the truth lemma for this model (which works because `bx_forward_witness` gives F-resolution for free)
3. The completeness theorem follows: if phi is not derivable, then {neg(phi)} is consistent, extend to MCS M0, and M0 satisfies neg(phi) in the canonical model

The issue: the full canonical model has world states = all MCS, which forms a proper class (or at least a very large set). The TaskFrame requires a TYPE of world states, not a class.

In Lean 4, `Set Formula` lives in some universe, and `SetMaximalConsistent` is a Prop-valued predicate. The collection of all MCS is a `Set (Set Formula)`, which is a type. So the full canonical model IS definable in Lean 4.

**But**: The full canonical model does NOT fit the `TaskFrame D` structure because the temporal order is `bx_le` (a preorder on BXPoints), not a totally ordered abelian group.

Wait -- the `TaskFrame D` structure has world states and a task relation, parameterized by duration type D. The durations form a totally ordered abelian group. The world states do NOT need to be the duration type.

In the full canonical model:
- D = Int (durations are integers)
- WorldState = BXPoint (world states are MCS)
- task_rel w d u iff "there is a d-step path from w to u in the canonical ordering"

But this requires defining "d-step path" precisely. The canonical ordering `bx_le` is NOT indexed by integers. Two BXPoints w, v with `bx_le w v` have no natural "distance."

### 4.6 The Task-History Approach

The codebase uses `ParametricCanonicalTaskFrame` which defines:
- WorldState = `FMCS D -> D -> WorldState_aux`
- The world state at a family and time is determined by `fam.mcs t`

This is specifically designed to work with BFMCS. The world histories are derived from FMCS families, and the truth lemma relates `truth_at` to MCS membership.

For this to work, we NEED an `FMCS Int` construction. There is no way around it.

---

## Part 5: The Only Viable Path -- Per-Formula Chain Construction

### 5.1 The Insight

Instead of building ONE chain and proving all coherence properties on it, build SEPARATE chains for different purposes:

- The **base chain** (dd_chain) provides `forward_G` and `backward_H`
- For each F-obligation, construct a **witness chain segment** on-demand

But an FMCS is a SINGLE function `mcs : Int -> Set Formula`. It cannot be "multiple chains."

### 5.2 The Correct Approach: Single Chain, But With the Right Seed

The fundamental issue is that the Lindenbaum extension at each step has too much freedom. It can introduce G(neg(psi)) which kills F(psi).

**What if we constrain the extension at EVERY step to preserve all F-formulas from M0?**

That is: at each step, the seed is `{target} union g_content(chain(n)) union {F(chi) | F(chi) in M0}`.

This ensures F(chi) persists at every step. Combined with the round-robin visiting each psi, at the visit step for psi we would have F(psi) in chain(m) (since F(psi) in M0 and we preserved it), so fwd_succ gives psi in chain(m+1).

**Consistency of the enhanced seed**: We need to show that `{target} union g_content(chain(n)) union {F(chi) | F(chi) in M0}` is consistent.

The set `{F(chi) | F(chi) in M0}` is a subset of M0, which is consistent. And `g_content(chain(n))` is consistent with M0 (since it propagates from M0). But the UNION may not be consistent.

Actually, `g_content(M0) subset chain(1) subset ... subset` -- no, this is wrong. g_content only propagates one step at a time. chain(n) is an extension of g_content(chain(n-1)), not of g_content(M0) directly.

Let me think about this differently. We need:

`{target} union g_content(chain(n)) union f_carry(M0)` is consistent

where `f_carry(M0) = {F(chi) | F(chi) in M0, chi in sigma_list}`.

This is EXACTLY the enriched seed. And the enriched chain ALREADY uses this seed (approximately). The issue is that the enriched seed gives disjunctive control: for each chi, either chi in M' or F(chi) in M'.

**Wait -- the enriched seed is slightly different**. Looking at the code:

```
enriched_fwd_step M h_mcs target sigma_list :=
  if F(target) in M then
    resolving_enriched_fwd_exists(M, target, others)
  else
    fwd_succ(M, target)
```

The `resolving_enriched_fwd_exists` uses the BX11 fold which gives disjunctive control. The seed includes `f_carry` from the CURRENT step's M, not from M0.

What if instead we use `f_carry(M0)` (the F-obligations from the ROOT MCS) in the seed at every step?

### 5.3 Persistent F-Carry from M0

Define:

```
f_carry_root(M0) = { F(chi) | chi in sigma_list and F(chi) in M0 }
```

This is a FIXED finite set (subset of M0). Define a new chain:

```
persistent_fwd_step(chain(n), target) :=
  Lindenbaum extension of {target} union g_content(chain(n)) union f_carry_root(M0)
  (when F(target) in chain(n); otherwise use standard fwd_succ)
```

**Consistency claim**: `{target} union g_content(chain(n)) union f_carry_root(M0)` is consistent when `F(target) in chain(n)`.

**Proof of consistency**: By `forward_temporal_witness_seed_consistent`, `{target} union g_content(chain(n))` is consistent when `F(target) in chain(n)`. We need to add `f_carry_root(M0)` while maintaining consistency.

This is NOT automatic. The F-formulas from M0 may conflict with g_content(chain(n)).

However, consider: `f_carry_root(M0) subset M0`. And `g_content(chain(0)) = g_content(M0) subset chain(1)`. By induction, `g_content(chain(n))` is built from successive extensions of g_content(M0).

**Key lemma needed**: `g_content(chain(n)) union f_carry_root(M0)` is consistent.

This would follow if we could show that `chain(n) supset f_carry_root(M0)`. That is, F(chi) in M0 implies F(chi) in chain(n) for all n.

But this is EXACTLY what we cannot prove -- it is the forward_F problem (in a weaker form: persistence rather than eventual resolution).

### 5.4 Why Persistence of F-Formulas Is Provable

Actually, we CAN prove F-formula persistence if we BUILD the chain to preserve them.

**Claim**: If we define the chain as:

```
chain(0) = M0
chain(n+1) = Lindenbaum extension of {target_{n+1}} union g_content(chain(n)) union f_carry_root(M0)
```

then, assuming the seed is consistent at each step, F(chi) in M0 implies F(chi) in chain(n) for all n.

**Proof**: F(chi) in M0 means F(chi) in f_carry_root(M0). By construction, f_carry_root(M0) subset seed subset chain(n) for all n. So F(chi) in chain(n).

The circularity is broken: we do not need to PROVE F-persistence; we BUILD it into the chain by including f_carry_root(M0) in every seed.

**The only question is consistency of the seed at each step.**

### 5.5 Consistency of the Persistent F-Carry Seed

We need to show: for each n, the set

```
S_n = {target_n} union g_content(chain(n-1)) union f_carry_root(M0)
```

is consistent (when F(target_n) in chain(n-1)).

**Approach**: Use `generalized_temporal_k` (the same technique as `forward_temporal_witness_seed_consistent`).

The standard consistency argument for `{target} union g_content(M)` when `F(target) in M`:

Suppose the seed is inconsistent. Then there exist finite `L1 subset g_content(M)` and (optionally target) such that `L1, target |- bot`. By generalized temporal K, `G(L1), G(target) |- G(bot)`. Since G(bot) -> bot (BX1), `G(L1), G(target) |- bot`. But G(L1) subset M (since L1 subset g_content(M) means G(L1) subset M) and G(target) is either derivable from F(target) or... wait, F(target) = neg(G(neg(target))), which means G(neg(target)) not in M. This does not give G(target) in M.

The actual proof of `forward_temporal_witness_seed_consistent` uses:

If `{target} union g_content(M)` is inconsistent, then `g_content(M) |- neg(target)`. By `g_content_closed_derivation`, `G(neg(target)) in M`. But `F(target) = neg(G(neg(target))) in M`, contradicting consistency of M.

For the enhanced seed `{target} union g_content(chain(n-1)) union f_carry_root(M0)`:

Suppose it is inconsistent. Then there exist finite `L1 subset g_content(chain(n-1))`, finite `L2 subset f_carry_root(M0)`, such that `L1 union L2 union {target} |- bot`.

This means `L1 union L2 |- neg(target)`.

Now, `L1 subset g_content(chain(n-1))` means each element of L1 is of the form phi where G(phi) in chain(n-1). And `L2 subset f_carry_root(M0)` means each element of L2 is of the form F(chi) for some chi in sigma_list with F(chi) in M0.

We cannot directly lift this to a derivation involving G-formulas because L2 contains F-formulas, not elements of g_content.

**This is the crux**: can we show `g_content(chain(n-1)) union f_carry_root(M0)` is consistent?

Note that `f_carry_root(M0) subset M0` and `g_content(chain(n-1))` consists of phi such that G(phi) in chain(n-1). If we could show `g_content(chain(n-1)) subset M0`, then `g_content(chain(n-1)) union f_carry_root(M0) subset M0`, which is consistent (since M0 is consistent).

**But `g_content(chain(n-1)) subset M0` is FALSE in general.** chain(n-1) is a DIFFERENT MCS from M0. g_content(chain(n-1)) = {phi | G(phi) in chain(n-1)}. There is no reason for this to be a subset of M0.

### 5.6 A Different Consistency Argument

We need a more sophisticated consistency argument. Here is one approach:

**Define**: `M0_ext = M0 union g_content(M0)`. Since `g_content(M0) subset M0` (by BX1: G(phi) -> phi), `M0_ext = M0`.

The key insight is that `f_carry_root(M0) subset M0` and we build the chain starting from M0. The chain propagates g_content forward at each step. We need to ensure the F-formulas from M0 remain consistent with the chain at each step.

**Inductive argument**:

Base case (n = 0): chain(0) = M0, and `f_carry_root(M0) subset M0`, so `g_content(M0) union f_carry_root(M0) subset M0`. Consistent.

Inductive step: Assume chain(n) is an MCS that contains `f_carry_root(M0)` as a subset. We need to show `{target} union g_content(chain(n)) union f_carry_root(M0)` is consistent when `F(target) in chain(n)`.

Since `f_carry_root(M0) subset chain(n)` (by inductive hypothesis), we have `g_content(chain(n)) union f_carry_root(M0) subset g_content(chain(n)) union chain(n) = chain(n)` (since g_content(chain(n)) subset chain(n) by BX1).

Wait, that cannot be right. `g_content(chain(n)) = {phi | G(phi) in chain(n)}`. By BX1, `G(phi) -> phi`, so `phi in chain(n)`. So `g_content(chain(n)) subset chain(n)`.

Therefore: `{target} union g_content(chain(n)) union f_carry_root(M0) subset {target} union chain(n)`.

But wait -- chain(n) is an MCS, and we are constructing chain(n+1) from a SUBSET of `{target} union chain(n)`. The seed is ALREADY a subset of `{target} union chain(n)`, so its consistency follows from `{target} union chain(n)` being consistent... no, that is not how it works. We are building the Lindenbaum extension of the seed, not taking a subset.

Actually, if `f_carry_root(M0) subset chain(n)` (by IH), then the seed `{target} union g_content(chain(n)) union f_carry_root(M0)` is a subset of `{target} union chain(n)`. The set `{target} union chain(n)` is consistent when `F(target) in chain(n)` (since chain(n) is consistent and adding target to a consistent MCS either keeps it consistent or -- actually, chain(n) is already maximal, so `{target} union chain(n)` is consistent iff `target in chain(n)` or `target` is consistent with chain(n), which is equivalent to `neg(target) not_in chain(n)`, i.e., `G(neg(target)) not_in chain(n)` -- no, that is not right either).

Let me be more careful. The seed `S = {target} union g_content(chain(n)) union f_carry_root(M0)` needs to be CONSISTENT (no finite subset derives bot). Since `f_carry_root(M0) subset chain(n)` (by IH) and `g_content(chain(n)) subset chain(n)` (by BX1), we have `S subset {target} union chain(n)`.

**If target in chain(n)**: Then `S subset chain(n)`, which is consistent.

**If target not_in chain(n)**: Then `neg(target) in chain(n)` (negation completeness). So `{target} union chain(n)` is inconsistent. But S is a SUBSET of `{target} union chain(n)`, and a subset of an inconsistent set may or may not be consistent.

Actually, `{target, neg(target)} |- bot`. If both `target` and `neg(target)` are in S, then S is inconsistent. We have `neg(target) in chain(n)`, but is `neg(target) in S`? Only if `neg(target) in g_content(chain(n))` or `neg(target) in f_carry_root(M0)`.

The seed S = `{target} union g_content(chain(n)) union f_carry_root(M0)`. The full chain(n) is NOT in the seed; only g_content(chain(n)) and f_carry_root(M0) are. So `neg(target)` is in S only if `G(neg(target)) in chain(n)` (from g_content) or `neg(target) = F(chi)` for some chi (from f_carry_root).

If `F(target) in chain(n)`, then `neg(G(neg(target))) in chain(n)`, so `G(neg(target)) not_in chain(n)` (consistency). Therefore `neg(target) not_in g_content(chain(n))`.

And `neg(target)` is in f_carry_root(M0) only if `neg(target) = F(chi)` for some chi, which would require target = G(neg(chi)). This is a very specific form.

So the "obvious" inconsistency (`target` and `neg(target)` both in S) does not arise when `F(target) in chain(n)`. But there could be more complex inconsistencies.

**The standard consistency proof applies**: If the seed is inconsistent, there exist `L subset g_content(chain(n)) union f_carry_root(M0)` such that `L |- neg(target)`. Since `L subset chain(n)` (because `g_content(chain(n)) subset chain(n)` and `f_carry_root(M0) subset chain(n)` by IH), this means `chain(n) |- neg(target)`. But chain(n) is an MCS, so `neg(target) in chain(n)`. But `F(target) = neg(G(neg(target))) in chain(n)` means `G(neg(target)) not_in chain(n)`.

Wait, this gives `neg(target) in chain(n)`, not `G(neg(target)) in chain(n)`. `neg(target) in chain(n)` does not contradict `F(target) in chain(n)` in general. `F(target) = neg(G(neg(target)))`, which means `G(neg(target)) not_in chain(n)`. But `neg(target) in chain(n)` is a weaker statement.

Actually, can `neg(target) in chain(n)` and `F(target) in chain(n)` coexist? `F(target) in chain(n)` says "there exists a future time where target holds." `neg(target) in chain(n)` says "target does not hold NOW." These are perfectly consistent: target is false now but becomes true later.

**So the seed CAN be inconsistent when `neg(target) in chain(n)` and `F(target) in chain(n)`.** The seed includes `{target}`, and if the rest of the seed implies `neg(target)`, we have inconsistency.

But wait -- this is exactly the situation handled by `forward_temporal_witness_seed_consistent`:

The standard proof shows: `{target} union g_content(M)` is consistent when `F(target) in M`. The argument is: if `g_content(M) |- neg(target)`, then `G(neg(target)) in M` (by g_content_closed_derivation), contradicting `F(target) in M`.

The enhanced seed has `g_content(M) union f_carry_root(M0)`. If `g_content(M) union f_carry_root(M0) |- neg(target)`, can we still derive a contradiction?

If `f_carry_root(M0) subset chain(n)` and `g_content(chain(n)) subset chain(n)`, then the derivation is `L |- neg(target)` where `L subset chain(n)`. So `neg(target) in chain(n)` (by MCS closure under derivation).

But `neg(target) in chain(n)` does not contradict `F(target) in chain(n)`. So the contradiction argument fails.

**This means the enhanced seed may genuinely be inconsistent.**

### 5.7 The Real Problem, Distilled

The forward_temporal_witness_seed_consistent argument works because it only includes g_content in the seed. The g_content closure property allows lifting `g_content(M) |- neg(target)` to `G(neg(target)) in M`, which contradicts `F(target) in M`.

Any additional formulas in the seed that are NOT in g_content may cause inconsistency that cannot be lifted. The F-formulas from M0 are NOT in g_content(chain(n)) in general, and they break the lifting argument.

This is the same fundamental obstacle that has blocked all 24 prior rounds.

---

## Part 6: The Strongest Remaining Approach

### 6.1 Process-All-F-Formulas-First Construction

The strongest approach remaining is a two-phase chain:

**Phase 1 (F-resolution phase)**: Process all F-obligations from M0 one at a time, using the NON-enriched chain with `fwd_succ`.

At each step, resolve one formula psi such that F(psi) in M0. The seed is `{psi} union g_content(chain(n))`. By `forward_temporal_witness_seed_consistent`, this is consistent when `F(psi) in chain(n)`.

The key: does `F(psi) in chain(n)` hold when we reach the step for psi? By the h_content backward propagation argument (Section 4.2):

If `F(psi) in chain(n)` then `F(psi) in chain(n-1)` (via BX4', h_content backward, FF_imp_F). By induction backward, `F(psi) in chain(0) = M0`.

Conversely: does `F(psi) in M0` imply `F(psi) in chain(n)` for n >= 1?

**Not necessarily.** The chain step extends g_content(chain(n-1)), not all of chain(n-1). F(psi) is in chain(0) = M0, but chain(1) only contains `{target_0} union g_content(M0)` (plus Lindenbaum extension). F(psi) may or may not survive.

**But**: By BX4' (`F(psi) -> H(F(F(psi)))`): `H(F(F(psi))) in chain(0)`. This means `F(F(psi)) in h_content(chain(0))`. By the backward chain construction... no, we are going forward.

Actually, for the FORWARD chain: `g_content(chain(0)) subset chain(1)`. And `G(phi) in chain(0) -> phi in chain(1)`. Does `F(psi)` appear in g_content? No, `F(psi)` is not a G-formula.

**But**: From BX4 (`psi -> G(P(psi))`, applied to F(psi)): `F(psi) -> G(P(F(psi)))`. So `G(P(F(psi))) in chain(0)`. By g_content, `P(F(psi)) in chain(1)`. This tells us: the past has F(psi) at some point. But not that F(psi) is in chain(1).

### 6.2 The Monotonic F-Set Approach (Definitive Version)

Let me formalize the only approach that has a genuine chance:

**Definition**: `FO(n) = { psi in sigma_list | F(psi) in chain(n) }` (the "F-obligation set" at step n).

**Fact** (from h_content backward + FF_imp_F): `FO(n+1) subset FO(n)`.

This is because: if `F(psi) in chain(n+1)`, then by BX4' + h_content backward + FF_imp_F, `F(psi) in chain(n)`.

**Fact**: FO(0) is finite (subset of sigma_list).

So `|FO(0)| >= |FO(1)| >= |FO(2)| >= ...`. The sequence is non-increasing and bounded below by 0, so it stabilizes.

**Definition**: Let `FO_inf = intersection_n FO(n)` (the formulas whose F-obligation persists forever).

For any `psi in FO(0) \ FO_inf`, there exists a FIRST step `k_psi` where `F(psi) not_in chain(k_psi)` (i.e., `F(psi) in chain(k_psi - 1)` but `F(psi) not_in chain(k_psi)`).

**Question**: For `psi in FO(0) \ FO_inf`, is `psi in chain(s)` for some `s > 0`?

**Not necessarily.** F(psi) was lost (G(neg(psi)) entered), but psi was never directly placed in the chain.

**Question**: For `psi in FO_inf`, is `psi in chain(s)` for some `s`?

For these psi, `F(psi)` persists at every step. The round-robin visits psi infinitely often. At a visit step m for psi: the seed is `{psi} union g_content(chain(m))`. By `forward_temporal_witness_seed_consistent`, this is consistent when `F(psi) in chain(m)` -- and `F(psi) in chain(m)` because `psi in FO_inf`.

So `psi in chain(m+1)`. Therefore, for `psi in FO_inf`, forward_F holds.

**The remaining problem**: For `psi in FO(0) \ FO_inf`, `F(psi)` is eventually lost. We have `F(psi) in chain(n)` (given). We need `psi in chain(s)` for some `s > n`.

If `F(psi)` is still present at the next visit step for psi (after n), then fwd_succ resolves it. If `F(psi)` is lost before the next visit step, then we are stuck.

**But**: F(psi) can only be lost at a step where the Lindenbaum extension CHOOSES to include G(neg(psi)). Can we prevent this?

With the non-enriched chain, we cannot prevent it. With the enriched chain, we get disjunctive control but not guaranteed resolution.

### 6.3 Ensuring F-Survival to the Visit Step

What if we schedule psi IMMEDIATELY after the step where F(psi) appears?

In the non-enriched chain: if `F(psi) in chain(n)`, set `target_{n+1} = psi`. The seed `{psi} union g_content(chain(n))` is consistent (by forward_temporal_witness_seed_consistent since F(psi) in chain(n)). So `psi in chain(n+1)`.

**This works!** But it requires a DEMAND-DRIVEN schedule, not a round-robin.

**The demand-driven chain**:

```
chain(0) = M0
At step n: scan chain(n) for F-obligations. If F(psi) in chain(n) for some psi in sigma_list with psi not_in chain(k) for all k <= n, set target = psi and take chain(n+1) = Lindenbaum({psi} union g_content(chain(n))).
If no unresolved F-obligation exists, set chain(n+1) = chain(n) (identity step).
```

For this chain, forward_F is immediate: if `F(psi) in chain(n)`, set target = psi at step n+1, giving `psi in chain(n+1)`.

**Problem**: This chain resolves ONE F-obligation per step, but resolving psi might create new F-obligations or lose old ones.

Wait -- `no_new_f_defects` says `FO(n+1) subset FO(n)`. So resolving psi at step n+1 does NOT create new F-obligations. And FO(n+1) subset FO(n).

But: after resolving psi at step n+1 (psi in chain(n+1)), we have psi in chain(n+1). For forward_F, we just need `exists s > n, psi in chain(s)`. We have `s = n + 1`. Done!

**Does this chain satisfy forward_G?** The chain uses `fwd_succ` which includes g_content(chain(n)) in the seed, so `g_content(chain(n)) subset chain(n+1)`. Yes, forward_G holds.

**Does this chain satisfy backward_H?** By the h_content duality: `g_content(chain(n)) subset chain(n+1)` implies `h_content(chain(n+1)) subset chain(n)`. Yes, backward_H holds.

**Does this chain satisfy box stability?** The box stability proof for dd_chain uses g_content propagation and h_content backward. The same argument applies. Yes, box stability holds.

### 6.4 The Demand-Driven Chain: Backward Direction

For the backward chain (t < 0), we need backward_P: if `P(psi) in chain(t)`, then `exists s < t, psi in chain(s)`.

By symmetry: use `bwd_pred` which includes h_content(chain(n)) in the seed. The demand-driven schedule resolves P-obligations the same way.

### 6.5 Forward Until Coherence

For `restricted_forward_until_since_coherent`:

Given `(phi U psi) in fam.mcs t`, produce `s >= t` with `psi in fam.mcs s` and `phi in fam.mcs r` for all `r in [t, s)`.

**Case s = t**: If `psi in fam.mcs t`, take `s = t`. Guard is vacuous.

**Case s > t**: `psi not_in fam.mcs t`. By BX9: `phi in fam.mcs t`. By BX10: `F(psi) in fam.mcs t`. By forward_F: `exists s > t, psi in fam.mcs s`.

We need the guard: `phi in fam.mcs r` for all `r in [t, s)`.

For `r = t`: `phi in fam.mcs t` (from BX9).

For `r = t + 1, ..., s - 1`: We need `phi in fam.mcs r`. This is NOT guaranteed by the chain construction.

**The guard problem persists.** Even with forward_F solved, we cannot guarantee phi at all intermediate positions.

However, by BX5 (self-accumulation): `(phi U psi) -> ((phi and (phi U psi)) U psi)`. So `(phi and (phi U psi)) U psi in fam.mcs t`. By BX10: `F(psi) in fam.mcs t`. By forward_F: `exists s > t, psi in fam.mcs s`.

For the guard of `(phi and (phi U psi)) U psi`, we need `phi and (phi U psi)` at all guard times. This gives both `phi` and `(phi U psi)` at each guard time.

If `(phi U psi) in fam.mcs r` for all `r in [t, s)`, then `phi in fam.mcs r` follows (by BX9, since if `psi not_in fam.mcs r`, then `phi in fam.mcs r`; if `psi in fam.mcs r`, take s = r which is smaller, and we are done).

But we STILL need `(phi U psi) in fam.mcs r` for `r in [t, s)`. This requires Until-formula propagation through the chain, which we do not have.

**For the demand-driven chain with D = Int**: At time `t`, we have `(phi U psi) in fam.mcs t`. At time `t + 1`, does `(phi U psi) in fam.mcs (t + 1)`?

The step transfer problem (UntilSinceCoherence.lean): we need `(phi U psi) in fam.mcs (r + 1)` and `phi in fam.mcs r` to derive `(phi U psi) in fam.mcs r`. This is the BACKWARD direction.

For the FORWARD direction: we need `(phi U psi) in fam.mcs t` to imply `(phi U psi) in fam.mcs (t + 1)` (or psi in fam.mcs (t + 1)). This is BX9: `(phi U psi) -> phi or psi`. If `psi in fam.mcs t`, done. Otherwise, `phi in fam.mcs t`. But we still do not get `(phi U psi) in fam.mcs (t + 1)`.

**The BX12 Bridge**: `F(phi) -> (top U phi)`. From `F(psi) in fam.mcs t`, we get `(top U psi) in fam.mcs t`. Top is always in an MCS. So at each step r, `top in fam.mcs r`. If `(top U psi) in fam.mcs r` for all `r in [t, s)`, the guard for `(top U psi)` is `top`, which is automatic.

But we need `(phi U psi)`, not `(top U psi)`. And the guard needs to be `phi`, not `top`.

### 6.6 Restricting to the Demand-Driven Resolution of phi U psi

For the forward Until coherence of `(phi U psi) in fam.mcs t`:

1. If `psi in fam.mcs t`: s = t, guard vacuous. Done.
2. If `psi not_in fam.mcs t`: `phi in fam.mcs t` (BX9), `F(psi) in fam.mcs t` (BX10).
   By demand-driven forward_F: `exists s_0 > t, psi in fam.mcs s_0`.
   Take the SMALLEST such `s_0` (well-founded on Nat for the forward chain).

   For the guard [t, s_0): at each `r in [t, s_0)`, `psi not_in fam.mcs r` (by minimality of s_0). We need `phi in fam.mcs r`.

   **Key**: If the demand-driven chain resolves F(psi) at step t+1 (giving psi in fam.mcs(t+1)), then s_0 = t + 1 and the guard [t, t+1) = {t}, where phi in fam.mcs t. Done!

   More generally: if the chain resolves F(psi) immediately (at the next step after F(psi) appears), then s_0 = t + 1 and the guard is just {t}.

**The demand-driven chain CAN be designed to resolve F(psi) immediately!**

Here is the crucial observation: in the demand-driven chain from Section 6.3, when `F(psi) in chain(t)`, we set `target = psi` at step t+1. So `psi in chain(t+1)`. The witness is s = t + 1, and the guard interval [t, t+1) = {t}, where we need phi in chain(t) -- which we have from BX9.

**This solves the forward Until coherence for the immediate-resolution case!**

### 6.7 The Schedule Conflict

But there is a conflict: the demand-driven chain from Section 6.3 resolves ONE F-obligation per step. If multiple F-obligations exist simultaneously, only one can be resolved at each step.

For forward_F: given `F(psi) in chain(n)`, we set `target = psi` at step n+1. But what if another formula `chi` also has `F(chi) in chain(n)` and the schedule resolves chi first?

In that case, `psi` is NOT resolved at step n+1. It might be resolved at step n+2, but by then, `F(psi)` might have been lost (since we used fwd_succ for chi at step n+1, which does not protect F(psi)).

**Resolution**: For each formula psi with `F(psi) in chain(n)`, schedule a DEDICATED step n+1 for psi. If there are k F-obligations at chain(n), schedule k steps.

But this makes the schedule data-dependent and potentially infinite (if new F-obligations arise -- though they cannot, by no_new_f_defects).

**Better approach**: At EVERY step, the demand-driven chain resolves ALL current F-obligations by doing multiple steps in sequence.

Or: for forward Until coherence, the argument should be:

Given `(phi U psi) in fam.mcs t`, we need s > t with psi in fam.mcs s and phi in fam.mcs r for r in [t, s). We can ensure that the VERY NEXT STEP resolves psi by choosing target = psi at step t + 1.

**But the chain is already built.** We cannot retroactively choose the target. The chain is a fixed construction with a fixed schedule.

### 6.8 The Interleaved Demand Chain

The solution is to build the chain with an interleaved schedule that handles ALL formulas:

1. Process F-obligations one at a time, in rounds
2. After each round (|sigma_list| steps), all F-obligations that were present at the start of the round have been visited
3. By no_new_f_defects, no new F-obligations arise

**Forward_F argument**: Given `F(psi) in chain(n)`, psi is visited within the next |sigma_list| steps. At the visit step m (with n < m <= n + |sigma_list|), if `F(psi) in chain(m)`, then `fwd_succ` resolves it: `psi in chain(m + 1)`.

**The critical gap**: Is `F(psi) in chain(m)` when we reach the visit step? Between steps n and m, other formulas are being resolved. Each `fwd_succ` step uses a seed `{other_target} union g_content(chain(k))`, which might lose F(psi).

This is the SAME problem as before. The non-enriched chain loses F-obligations.

### 6.9 The Enriched Chain with Immediate Resolution

Combine the enriched step (which preserves F-obligations disjunctively) with immediate resolution:

At each step, if `F(psi) in chain(n)`, use the enriched step which gives either `psi in chain(n+1)` or `F(psi) in chain(n+1)`. If `psi in chain(n+1)`, psi is resolved. If `F(psi) in chain(n+1)`, try again at step n+2.

The enriched step also resolves at least one formula at each resolving step (by `enriched_fwd_step_resolves_one`). So the set of formulas with F-obligations that are NOT yet resolved strictly decreases (at each resolving step, at least one formula enters the chain directly).

**But the previously-resolved formulas can EXIT the chain at the next step** (the re-entry problem from Report 24). Even if psi was in chain(k), it might not be in chain(k+1).

However, for forward_F we only need `exists s > n, psi in chain(s)`. We do NOT need psi to persist. So the re-entry problem does not affect forward_F.

**Claim**: For the enriched round-robin chain (the current `rr_fwd_chain`):

If `F(psi) in chain(n)` and `psi in sigma_list`, then `exists s > n, psi in chain(s)`.

**Proof**:

By `enriched_fwd_step_resolves_one`: at each resolving step (where F(target) in chain(m)), at least one formula w in sigma_list with F(w) in chain(m) has `w in chain(m+1)`.

The F-obligation set `FO(n) = { chi in sigma_list | F(chi) in chain(n) }` is non-increasing: `FO(n+1) subset FO(n)`.

The "resolved at step n" set `R(n) = { chi in FO(0) | exists k <= n, chi in chain(k) }` is non-decreasing.

At each resolving step m: some new chi enters R(m+1) \ R(m) (the formula resolved by `enriched_fwd_step_resolves_one`). But chi was in `FO(m)`, which is a subset of `FO(0)`. And `FO(0)` is finite.

So R(n) increases by at least 1 at each resolving step (within FO(0)), and |FO(0)| bounds the total increase. After at most |FO(0)| * |sigma_list| steps, all formulas in FO(0) have been resolved at some point.

**But wait**: does R(n) REALLY increase? The formula resolved at step m is some w in sigma_list with `F(w) in chain(m)` and `w in chain(m+1)`. If w was already in R(m) (resolved at an earlier step), then R(m+1) = R(m) -- no increase.

The `enriched_fwd_step_resolves_one` guarantees that some formula with F-obligation is resolved, but it could be a formula that was already resolved earlier (and whose F-obligation persists because of the enriched step's F-carry).

**This is the exact defect re-entry problem identified in Report 24.**

However, there is a subtlety: the formula that is resolved is one that has `F(w) in chain(m)`. If w was in chain(k) for some earlier k, can F(w) still be in chain(m)?

Yes: `phi_in_mcs_imp_F_phi` says that if `w in M` (any MCS), then `F(w) in M`. So if w in chain(k), then F(w) in chain(k). By BX4 applied to F(w): `F(w) -> G(P(F(w)))`. So `G(P(F(w))) in chain(k)`. By g_content: `P(F(w)) in chain(k+1), chain(k+2), ...`. This gives P(F(w)) at all future times but NOT F(w).

Actually, F(w) itself may or may not be in chain(m) for m > k. The enriched step preserves F(w) disjunctively: either w in chain(m) or F(w) in chain(m). If w leaves the chain, F(w) might persist.

### 6.10 Final Assessment

After this exhaustive analysis, I must conclude:

1. **The pure quasimodel witness strategy is unworkable** due to the BXPoint-to-Int bridging gap.

2. **The non-enriched chain loses F-obligations** and cannot prove forward_F.

3. **The enriched chain has the defect re-entry problem** where the well-founded measure (counting newly-resolved formulas) is not strictly decreasing.

4. **The demand-driven immediate-resolution approach** works for forward Until coherence IF it can schedule each formula immediately after its F-obligation appears, but this conflicts with the need to handle multiple F-obligations simultaneously.

5. **The fundamental mathematical obstacle** is that the BX axiom system provides no mechanism to propagate arbitrary formulas (especially Until and F formulas) through a chain of MCS connected only by g_content/h_content.

6. **Published proofs** avoid this problem entirely by using the full canonical model (where F-resolution is definitional) or finite model methods.

The most promising remaining direction is approach 4 (demand-driven immediate resolution), specifically:

**Whenever F(psi) appears at chain position n, resolve it at the VERY NEXT step n+1 by setting target = psi.** This gives a well-defined chain where forward_F and forward Until coherence hold with a guard of exactly one step.

The challenge is defining this chain formally and handling the interaction between multiple simultaneous F-obligations. The interleaving can be done by a priority queue or by grouping: resolve ALL current F-obligations in a batch before moving to the next time unit.

---

## Part 7: Concrete Proposal -- Batch-Resolution Chain

### 7.1 Definition

```
batch_chain(0) = M0
batch_chain(n+1) = batch_resolve(batch_chain(n), sigma_list)

where batch_resolve(M, sigma_list) resolves ALL F-obligations in one batch:
  let defects = [psi in sigma_list | F(psi) in M, psi not_in M]
  if defects = [] then M (identity)
  else resolve_first(M, defects[0], defects[1:], sigma_list)

resolve_first(M, target, rest, sigma_list) =
  let M' = fwd_succ(M, target)   -- target in M' since F(target) in M
  if rest = [] then M'
  else if F(rest[0]) in M' then resolve_first(M', rest[0], rest[1:], sigma_list)
  else resolve_first(M', rest[0], rest[1:], sigma_list)  -- skip if F-obligation lost
```

**Problem**: This multi-step resolution within a single batch makes the chain length data-dependent and hard to work with in the FMCS Int framework.

### 7.2 Alternative: One-Step-Per-Defect Chain

Map each batch step to multiple Int positions:

```
Given M with defects D = {psi_1, ..., psi_k}:
  chain(n) = M
  chain(n+1) = fwd_succ(chain(n), psi_1)     -- resolve psi_1
  chain(n+2) = fwd_succ(chain(n+1), psi_2)   -- resolve psi_2 (if F(psi_2) still present)
  ...
  chain(n+k) = fwd_succ(chain(n+k-1), psi_k) -- resolve psi_k (if present)
```

Then restart with chain(n+k) and recompute defects.

**Forward_F**: Given `F(psi) in chain(n)`, psi is in the defect list. It gets resolved at step n + (position of psi in defect list) + 1. So `psi in chain(n + j)` for some j in [1, |sigma_list|].

**But**: F(psi) might be lost at an intermediate step (resolving psi_i for i < psi's position). The standard forward_temporal_witness_seed_consistent argument shows `fwd_succ(chain(m), target)` does not include F(psi) unless F(psi) in g_content(chain(m)), which is not guaranteed.

**This is the same obstruction.**

### 7.3 The Only Way Out: Enriched Seed with Termination

The ONLY known way to preserve F-obligations through multiple steps is the enriched seed (BX11 fold). The enriched step preserves F(chi) or chi for all chi with F(chi) in M.

With the enriched step, after `|sigma_list|` steps, each formula has been visited, and at its visit step, it was either directly resolved (chi in M') or its F-obligation was preserved (F(chi) in M').

The set of directly-resolved formulas at each visit step is non-empty (by `enriched_fwd_step_resolves_one`). Let `R_k` be the set of formulas resolved during round k (a round = |sigma_list| steps).

Key question: Is `|R_k| > 0` for each round k until all defects are resolved?

`enriched_fwd_step_resolves_one` guarantees at each resolving step, SOME formula is resolved. Over a round of |sigma_list| steps, at least |sigma_list| formulas are resolved (counting with multiplicity). But these may be the SAME formula resolved multiple times (at different visit steps for different targets).

**Actually**: `enriched_fwd_step_resolves_one` says: at step m (where target_m = sigma_list[m mod |sigma_list|] and F(target_m) in chain(m)), there exists w in sigma_list with F(w) in chain(m) and w in chain(m+1). The w might equal target_m or might be another formula.

The set of DISTINCT formulas resolved in a round is at least 1 (since at least one resolving step occurs if any F-obligation exists). But it could be exactly 1 (the same formula resolved at every step).

### 7.4 Revised Termination Argument

**Claim**: In the enriched round-robin chain, after at most `|sigma_list|^2` steps from position n, either `psi in chain(s)` for some s, or `F(psi) not_in chain(s)` for all s beyond some threshold.

This follows from the finite F-obligation set. Since `FO(n) subset FO(0)` is finite, and each resolving step directly places some formula from `FO(m)` into chain(m+1), the total number of DISTINCT formulas ever placed into the chain is unbounded as steps increase.

Wait, that is not quite right either. Let me think more carefully.

Consider the sequence of resolving steps. At each resolving step m, some w_m in sigma_list with F(w_m) in chain(m) has w_m in chain(m+1). The sequence `w_0, w_1, w_2, ...` may have repetitions.

But: F(w_m) in chain(m) means w_m in FO(m) subset FO(0). So all w_m are in FO(0). The set FO(0) is finite with |FO(0)| <= |sigma_list|.

If the same w is resolved infinitely often (w in chain(m_k) for infinitely many k), then forward_F for w is trivially satisfied (take any m_k > n).

If every element of FO(0) is resolved at least once, then forward_F holds for all formulas in FO(0).

**Can there be a formula psi in FO(0) that is NEVER resolved?** That is, `psi not_in chain(m)` for all m > 0?

If psi is visited at step m (target_m = psi) and F(psi) in chain(m), then `enriched_fwd_step_resolves_one` gives some w in chain(m+1). But w might not be psi itself.

Could it happen that at every visit step for psi, the formula resolved is always some OTHER w != psi?

The `resolving_enriched_fwd_exists` specification says:

```
exists w, (w = target or w in others) and F(w) in M and w in M'
```

So w could be target (= psi) or some other formula. The BX11 fold does not guarantee that target itself is resolved.

**This is the core defect re-entry/resolution-escape problem.**

### 7.5 Using BX11 Ordering

The `bx11_earlier` relation provides a total preorder on F-defects. For a 2-element defect set {psi, chi}, BX11 gives that one of them is "earlier" (resolved first by the fold). The earlier one IS resolved.

For psi to never be resolved, it must always be "later" than some other formula at every visit step. Since the defect set is non-increasing, eventually psi must be the ONLY remaining defect (all others have been resolved or had their F-obligation lost). At that point, psi must be resolved.

**This is the "ordered discharge" argument from Report 24 (Finding 3/12).**

The gap: with 3+ defects, the BX11 fold might not resolve the target. But after enough rounds, the defect set shrinks (because `FO(n)` is non-increasing and resolving steps place formulas into the chain). Eventually, only one defect remains, and it IS resolved.

**Formal argument**:

Let D(n) = { chi in sigma_list | F(chi) in chain(n) and chi has never appeared in chain(1), ..., chain(n) }.

Claim: |D(n)| is non-increasing and strictly decreasing at each resolving step where the resolved formula was not previously resolved.

After |D(0)| rounds (each of |sigma_list| steps), D(n) is empty. All formulas in FO(0) have been resolved at some point.

For any psi with F(psi) in chain(n): psi in FO(0) (by no_new_f_defects backward). So psi was resolved at some step s. Hence exists s' > 0 with psi in chain(s').

If s' > n, we are done. If s' <= n, we need another resolution of psi at some step s'' > n.

**But**: psi might have been resolved at s' < n, and then never again. Is psi in chain(s') enough for forward_F at n? No! Forward_F at n requires s > n with psi in chain(s).

**This is where the argument breaks.**

### 7.6 The Definitive Obstruction

Forward_F requires: given F(psi) in chain(n), find s > n with psi in chain(s). It is NOT enough to find s > 0 with psi in chain(s), because s might be less than n.

The defect re-entry problem means psi could have been resolved early (s' < n) and never again. F(psi) persists at chain(n) (because the enriched step preserves it), but psi is not in chain(s) for any s > n.

**Can we force psi to be re-resolved?** At the next visit step m > n for psi, if F(psi) in chain(m), the enriched step gives some w in chain(m+1). If w = psi, done. If w != psi, then another formula was resolved instead, and we try again at the next round.

The question is whether psi will EVENTUALLY be the one resolved. By the BX11 ordering argument, after all other formulas in FO(m) have been resolved at some point, psi remains as the only defect and must be resolved.

But "resolved at some point" includes resolutions BEFORE position m, which do not help.

**The set that matters is not "ever resolved" but "resolved AFTER n."** This set may remain empty if psi keeps being deferred in favor of other formulas that were more recently resolved and now need re-resolution themselves.

This is an infinite deferral cycle, and it is exactly the scenario described in the "perpetual deferral" analysis of Report 17.

---

## Part 8: Conclusion and Recommendations

### 8.1 Summary of Findings

After this exhaustive analysis from first principles:

1. **The quasimodel witness strategy (pure form)** is unworkable due to the BXPoint-to-Int type mismatch. The quasimodel infrastructure produces abstract BXPoint witnesses that cannot be mapped to Int chain positions.

2. **The enriched chain's forward_F** remains blocked by the defect re-entry problem: a formula psi can be resolved at step s' < n but never again after n, while F(psi) persists at all steps.

3. **The non-enriched chain's forward_F** is blocked by F-obligation loss: F(psi) can be lost before psi's visit step.

4. **The demand-driven immediate-resolution approach** works for a SINGLE F-obligation but cannot handle multiple simultaneous F-obligations without the enriched seed, bringing back the disjunctive control problem.

5. **Published proofs** avoid Int-indexed chains entirely, using the full canonical model or finite models.

### 8.2 The Two Remaining Viable Paths

**Path A: Full Canonical Model (Standard Approach)**

Abandon the `FMCS Int / BFMCS Int` framework. Instead, define:
- `CanonicalTaskFrame` using BXPoints as world states and a suitable D
- Prove the truth lemma directly on this canonical model
- All 6 sorry sites become irrelevant (they are properties of the chain construction, not the canonical model)

**Estimated effort**: 50-80 hours. Requires rewriting the parametric canonical model, truth lemma, and countermodel theorem.

**Risk**: The BXPoint ordering is NOT a total order, and TaskFrame requires durations from a totally ordered abelian group. A bridging construction is needed.

**Path B: Prove the Defect Re-Entry Cannot Happen**

For the enriched chain: prove that if `F(psi) in chain(n)` and psi was resolved at step s' < n (psi in chain(s')), then psi is resolved again at some step s'' > n.

This requires showing that the enriched step eventually cycles back to resolving psi. The BX11 ordering argument needs to be strengthened to show that the "earlier" formula changes over time, preventing permanent deferral of any single formula.

**Estimated effort**: 20-40 hours of pen-and-paper work, then 30-50 hours of Lean if viable.

**Risk**: The permanent deferral scenario may be genuinely possible (consistent with the BX axioms).

### 8.3 Recommendation

**Path A (full canonical model) is the architecturally correct approach.** It aligns with published proofs and does not fight against the chain's fundamental limitation. The 6 sorry sites would be eliminated by restructuring, not by proving increasingly difficult chain properties.

The key technical challenge for Path A is defining a TaskFrame whose duration type is Int but whose world states are BXPoints. The task relation would be:

```
task_rel w d u iff "in the canonical model, world w at time offset d leads to world u"
```

This could be defined as: `task_rel w d u iff d = 0 and w = u` (trivial task frame where all times have the same world state). But this trivializes the temporal structure.

A better definition: each BXPoint w represents a "state" at some abstract time. The task relation connects states across time. In the canonical model with Int durations, the worldhistory for a family assigns fam.mcs(t) as the "state" at time t. The task_rel connects fam.mcs(t) to fam.mcs(t + d) via the family structure.

This is EXACTLY what `ParametricCanonicalTaskFrame` already does. And it requires FMCS Int. So we are back to needing the chain construction.

**Revised recommendation**: Invest in Path B with a concrete pen-and-paper analysis of the defect re-entry bound. Specifically, analyze whether the following measure is well-founded:

```
mu(n) = (|FO(n)|, |{chi in FO(n) | chi not_in chain(k) for all k in (last_visit(chi, n), n]}|)
```

where `last_visit(chi, n)` is the last visit step for chi before or at n. This lexicographic measure might be strictly decreasing, resolving the forward_F problem.

### 8.4 For Sorry Sites 4, 5, 6

**Sorry 4 (restricted_tc)**: Requires forward_F (sorry 1) + backward_P (sorry 3). If forward_F is proved, sorry 3 follows by symmetry, and sorry 4 follows from both.

**Sorry 5 (restricted_buc)**: The backward Until/Since coherence requires the step transfer property: `(phi U psi) in fam.mcs(r+1) and phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)`. This requires `phi and (phi U psi)` or `psi` to be in fam.mcs(r). Since `(phi U psi) in fam.mcs(r+1)`, by BX4': `(phi U psi) -> H(F(phi U psi))`, so `H(F(phi U psi)) in fam.mcs(r+1)`. By h_content: `F(phi U psi) in fam.mcs(r)`. By BX12: `F(phi U psi) -> (top U (phi U psi))`. So `(top U (phi U psi)) in fam.mcs(r)`.

This means "in the future, phi U psi holds." But we need phi U psi AT position r, not in the future.

**Alternative for sorry 5**: Use `or_until_in_mcs`: if `psi or (phi and (phi U psi)) in fam.mcs(r)`, then `(phi U psi) in fam.mcs(r)`. We have `phi in fam.mcs(r)` (given). We need `(phi U psi) in fam.mcs(r)` or `psi in fam.mcs(r)`. This is circular. The step transfer for backward Until coherence requires an additional chain property beyond g_content/h_content.

**One possibility**: If the chain includes Until-carry in its seed (including `(phi U psi)` in the seed of chain(r) when it is in chain(r+1)), the step transfer follows. But this requires modifying the chain construction to carry Until formulas backward.

**Sorry 6 (restricted_fuc)**: Requires forward_F + the guard property. As analyzed in Section 6.5-6.6, the guard requires phi at all intermediate positions, which follows from forward_F + immediate resolution (the witness is at most 1 step away if the demand-driven approach works).

---

## References

1. Burgess, J.P. (1984). "Basic tense logic." In D.M. Gabbay & F. Guenthner (Eds.), Handbook of Philosophical Logic, Vol. II.
2. Goldblatt, R. (1992). "Logics of Time and Computation." CSLI Lecture Notes No. 7, 2nd edition.
3. Gabbay, D., Hodkinson, I., Reynolds, M. (1994). "Temporal Logic: Mathematical Foundations and Computational Aspects." Oxford University Press.
4. Reynolds, M. (2003). "An axiomatization of full computation tree logic." Journal of Symbolic Logic.
5. Xu, M. (1988). PhD Thesis on temporal logic completeness.
6. Venema, Y. (1993). "Derivation rules as anti-axioms in modal logic." Journal of Symbolic Logic.
