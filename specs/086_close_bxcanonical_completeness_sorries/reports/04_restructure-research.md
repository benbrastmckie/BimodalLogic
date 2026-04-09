# Research Report: Restructured Proof Architecture for usf_completeness

**Task**: 86 -- Close BXCanonical completeness sorries
**Date**: 2026-04-08
**Session**: sess_1775712248_0c5948
**Focus**: Detailed restructure of `usf_completeness` imp Case B

## 1. Exact Goal State at the Sorry

File: `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean:409`

```lean
case neg
psi chi : Formula
ih_psi : untilSinceFree psi -> valid psi -> Nonempty (DerivationTree [] psi)
ih_chi : untilSinceFree chi -> valid chi -> Nonempty (DerivationTree [] chi)
h_usf : untilSinceFree (psi.imp chi)
h_valid : valid (psi.imp chi)
h_psi_valid : not (valid psi)
h_not_deriv : not (Nonempty (DerivationTree [] (psi.imp chi)))
h_cons : SetConsistent {(psi.imp chi).neg}
M : Set Formula
hM_sup : {(psi.imp chi).neg} <= M
hM_mcs : SetMaximalConsistent M
h_not_in : psi.imp chi not-in M
w : BXPoint := { formulas := M, is_mcs := hM_mcs }
h_psi_in : psi in w.formulas
h_chi_not : chi not-in w.formulas
|- False
```

### Available Hypotheses

- `w : BXPoint` -- an MCS with `psi in w`, `chi not-in w`, `(psi -> chi) not-in w`
- `h_valid : valid (psi.imp chi)` -- psi -> chi is valid (true in ALL models)
- `h_psi_valid : not (valid psi)` -- psi is NOT universally valid
- `ih_psi`, `ih_chi` -- structural induction hypotheses (UNUSABLE in Case B)
- `h_usf : untilSinceFree (psi.imp chi)` -- both psi and chi are Until/Since-free

### Why Current Approach Fails

To derive `False`, we must build a model where `truth_at ... (psi.imp chi)` is false, contradicting `h_valid`. This requires:
1. `truth_at ... psi` (forward bridge: psi in w -> truth)
2. `not (truth_at ... chi)` (backward countermodel: chi not-in w -> falsity)

On constant histories, the backward direction fails for G/H sub-formulas because `truth_at G(alpha)` on a constant history through w collapses to `truth_at alpha` at w, giving only `alpha in w` (not `G(alpha) in w`).

## 2. The Standard Contrapositive Architecture

### Core Insight

Instead of validity reduction (current approach), use the standard textbook contrapositive:

```
not derivable phi
  -> {neg phi} consistent
  -> extend to MCS w with phi not-in w
  -> build model where phi is false at w
  -> phi not valid (contradiction)
```

The imp case becomes the SIMPLEST case:
- `(psi -> chi) not-in w` gives `psi in w` and `chi not-in w`
- Forward: `psi in w -> truth_at psi` (by induction on psi)
- Backward countermodel: `chi not-in w -> not (truth_at chi)` (by induction on chi)
- Therefore `truth_at (psi -> chi) = (truth_at psi -> truth_at chi) = (True -> False) = False`

### What We Need: Two One-Directional Lemmas

**Lemma A (Forward Truth)**: For any MCS w and USF formula phi:
```
phi in w.formulas -> truth_at canonical_valuation Omega sigma 0 phi
```
where sigma is a history centered at w.

**Lemma B (Backward Countermodel)**: For any MCS w and USF formula phi:
```
phi not-in w.formulas -> not (truth_at canonical_valuation Omega sigma 0 phi)
```
where sigma is a history built to witness the falsity of phi.

These are ONE-DIRECTIONAL. We do NOT need a bidirectional iff. This is strictly weaker than a full truth lemma.

## 3. Component A: Chain History Builder

### Data Structure

Given MCS `w : BXPoint` and formula `phi` with `phi not-in w`, build:
- A function `chain : Int -> BXPoint` (the history's state assignment)
- A set `Omega` of histories (shift-closed)
- Proof that `phi` is false at `(sigma, Omega, 0)` where `sigma` uses `chain`

### Recursive Construction

The chain is built by structural induction on `phi`:

**Case `atom p not-in w`**:
- `chain t = w` for all t (constant history)
- `Omega = modal_omega w` (already defined)
- Falsity: `truth_at (atom p) = exists ht, valuation (chain 0) p = (atom p in w)`, which is false

**Case `bot not-in w`**:
- Impossible: `bot not-in w` is always true (bot_not_in_mcs)
- This case never arises

**Case `(psi -> chi) not-in w`**:
- By `imp_iff_mcs`: `psi in w` and `chi not-in w`
- Recursively build chain for `chi not-in w` (call it `chain_chi`)
- Use `chain_chi` as the chain (it makes chi false)
- Forward truth lemma gives `truth_at psi` (since `psi in w`)
- Therefore `truth_at (psi -> chi) = False`

**Case `box psi not-in w`**:
- By `bx_modal_witness` on the diamond: exists `v ~ w` with `psi not-in v`
- `chain t = v` for all t (constant history through v)
- `Omega = modal_omega w` (contains `constant_history v` since `v ~ w`)
- Falsity: `truth_at (box psi) = forall sigma in Omega, truth_at psi at sigma`
- `constant_history v in Omega`, and `truth_at psi` at `v` is false (by recursive countermodel at v)
- Wait -- but `truth_at (box psi)` evaluates box at the tau history, not at v's history
- Actually: `truth_at (box psi) Omega tau 0 = forall sigma in Omega, truth_at psi Omega sigma 0`
- So we need `exists sigma in Omega` where `truth_at psi Omega sigma 0` is false
- Take `sigma = constant_history v`. Then by backward countermodel for psi at v, done.

**Case `G(psi) not-in w`**:
- By `bx_G_backward`: exists `v >= w` (bx_le w v) with `psi not-in v`
- Build chain: `chain 0 = w`, `chain t = v` for `t >= 1`, `chain t = w` for `t < 0`
  (Or simpler: `chain t = if t >= 1 then v else w`)
- Falsity: `truth_at G(psi) Omega tau 0 = forall s >= 0, truth_at psi Omega tau s`
- At `s = 1`: `tau.states 1 = v`, and `psi not-in v -> not (truth_at psi)` by backward countermodel
- Therefore `truth_at G(psi) = False`

**Case `H(psi) not-in w`**:
- Mirror: by `bx_H_backward`, exists `v <= w` with `psi not-in v`
- `chain t = if t <= -1 then v else w`
- At `s = -1`: `tau.states (-1) = v`, and `psi not-in v -> not (truth_at psi)` by backward countermodel

### The Key Subtlety: Recursion Depth

For `(psi -> chi) not-in w`, we recurse on `chi not-in w`. For `G(chi) not-in w`, we recurse on `chi not-in v` (a DIFFERENT MCS). For `box chi not-in w`, we recurse on `chi not-in v` (a different MCS). The recursion is well-founded on formula complexity since `chi` is structurally smaller than `G(chi)`, `box chi`, or `psi -> chi`.

### Concrete Lean Type

```lean
noncomputable def countermodel_chain (w : BXPoint) (phi : Formula)
    (h_usf : untilSinceFree phi) (h_not : phi not-in w.formulas) :
    { chain : Int -> BXPoint //
      -- chain 0 is bx_le-related to w in appropriate direction
      -- chain is monotone in bx_le
      -- phi is false on the induced history
      ... }
```

Actually, it is cleaner to directly prove the backward countermodel lemma by induction:

```lean
noncomputable def backward_countermodel (w : BXPoint) (phi : Formula)
    (h_usf : untilSinceFree phi) (h_not : phi not-in w.formulas) :
    exists (Omega : Set (WorldHistory canonical_task_frame))
           (tau : WorldHistory canonical_task_frame) (t : Int),
      tau in Omega /\
      ShiftClosed Omega /\
      not (truth_at canonical_valuation Omega tau t phi)
```

But this has a problem: the model (Omega, tau) must ALSO make the FORWARD truth lemma work for other formulas. The forward truth lemma and backward countermodel must share the SAME model.

### Resolution: Formula-Specific Single Model

For the sorry, we need a SINGLE model where:
1. `truth_at psi` is true (forward, from `psi in w`)
2. `truth_at chi` is false (backward, from `chi not-in w`)

Both must hold at the same `(Omega, tau, t)`. The solution: build the model for chi's falsity, then prove the forward direction for psi on that same model.

## 4. Component B: Forward Truth Lemma

### Statement

For any MCS `w : BXPoint` and USF formula `phi`:
```
phi in w.formulas ->
truth_at canonical_valuation Omega (chain_history w) 0 phi
```

where `chain_history w` is a history whose state at time 0 is w, and Omega is shift-closed.

### Case-by-Case Analysis

**Case `atom p in w`**:
- `truth_at (atom p) = exists ht, valuation (tau.states 0 ht) p`
- `tau.states 0 = w` (by chain construction at time 0)
- `valuation w p = (atom p in w)` (by canonical_valuation definition)
- Need: `tau.domain 0` -- TRUE if chain has full domain
- Done.

**Case `bot in w`**:
- Impossible (bot_not_in_mcs). Vacuously true.

**Case `(psi -> chi) in w`**:
- `truth_at (psi -> chi) = truth_at psi -> truth_at chi`
- Assume `truth_at psi`. Need `truth_at chi`.
- From `(psi -> chi) in w`: by `imp_iff_mcs`, if `psi in w` then `chi in w`
- But wait: we only know `truth_at psi`, not `psi in w`. We need the BACKWARD direction for psi.
- **THIS IS THE CATCH**: The forward truth lemma for imp needs the backward direction for sub-formulas.

This means we actually need a BIDIRECTIONAL truth lemma, not just forward. Alternatively, we need a more careful argument.

### Critical Re-Analysis: What Actually Suffices

For the sorry, we do NOT need a general forward truth lemma. We need:
1. `truth_at psi` at (Omega, tau, 0) -- specifically for `psi in w`
2. `not (truth_at chi)` at (Omega, tau, 0) -- specifically for `chi not-in w`

For (1), the existing `fragment_truth_iff` already handles temporal-free psi on constant histories with modal_omega. For psi containing G/H, the constant history collapses G to its body, and the forward direction works:
- `G(alpha) in w -> alpha in w` (BX1) -> `truth_at alpha` on constant history -> `truth_at G(alpha)` (since all times map to w, all future times give `truth_at alpha`)

So the FORWARD direction on constant histories works for all USF formulas. Let me verify this carefully.

### Forward Direction on Constant Histories: Complete Proof

History: `tau = constant_history w` (all times map to w)
Omega: `modal_omega w` (constant histories through modal-equivalents of w)
Time: `t = 0`

By induction on phi:

**atom p**: `atom p in w -> truth_at (atom p)` -- by definition of canonical_valuation. Domain is trivial (constant_history has `domain = fun _ => True`). Done.

**bot**: Vacuous.

**imp psi chi**: `(psi -> chi) in w`. Assume `truth_at psi`. Need `truth_at chi`.
- Issue: We need `psi in w` from `truth_at psi`. This is the BACKWARD direction.
- On constant_history w with modal_omega w, `fragment_truth_iff` gives the iff for TEMPORAL-FREE formulas.
- For psi containing G/H, we need: `truth_at psi on constant_history w -> psi in w`.

Let me check: `truth_at G(alpha) on constant_history w at time 0`:
```
truth_at G(alpha) = forall s >= 0, truth_at alpha at (constant_history w, s)
```
Since `constant_history w` maps all times to `w`, this equals:
```
forall s >= 0, truth_at alpha at (constant_history w, s)
```
By induction, if alpha is temporal-free, `truth_at alpha at (constant_history w, s) <-> alpha in w` for any s.

But if alpha itself contains G/H, we recurse. Consider `truth_at G(G(beta))`:
```
truth_at G(G(beta)) at 0 = forall s1 >= 0, forall s2 >= s1, truth_at beta at s2
```
On constant history, `truth_at beta at s2 <-> beta in w` (by IH on beta).
So `truth_at G(G(beta)) <-> forall s1 >= 0, forall s2 >= s1, beta in w <-> beta in w`.

For the backward direction: `truth_at G(alpha) on constant_history w -> G(alpha) in w`:
- `truth_at G(alpha)` gives `truth_at alpha at s = 0` (since 0 >= 0)
- By IH backward: `truth_at alpha -> alpha in w`
- But we need `G(alpha) in w`, not just `alpha in w`
- `G(alpha) in w <-> forall v, bx_le w v -> alpha in v` (G_iff_mcs)
- We only have `alpha in w`, not `alpha in v` for all `v >= w`

**THE BACKWARD DIRECTION FAILS FOR G ON CONSTANT HISTORIES.** This is the known problem.

### What This Means

The forward direction `phi in w -> truth_at phi on constant_history w` DOES work. But the backward direction does NOT work for G/H on constant histories. For the imp case of the forward truth lemma, we need the backward direction of sub-formulas. So the imp case of the forward truth lemma ALSO fails on constant histories when sub-formulas contain G/H.

This confirms the team research finding: constant histories are insufficient.

## 5. Component C: The Real Solution -- Non-Constant Chain History

### The Two-Direction Bootstrap

We need BOTH directions to work simultaneously:
- Forward: `phi in w -> truth_at phi`
- Backward: `truth_at phi -> phi in w`

The key insight: on the RIGHT kind of history, both directions hold for all USF formulas.

### Definition: BX-Chain History

Given `w : BXPoint`, define a history where:
- Time 0 maps to w
- The history visits "enough" BXPoints to make the bidirectional truth lemma work for G/H

**Construction**: Define `bx_chain : BXPoint -> WorldHistory canonical_task_frame` as:

```lean
noncomputable def bx_chain (w : BXPoint) : WorldHistory canonical_task_frame where
  domain := fun _ => True          -- full domain
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => w           -- constant at w (!!!)
  respects_task := ...
```

Wait, this is just constant_history again. The problem is that for the backward G direction, we need the history to visit ALL bx_le-successors of w.

But BXPoint may have uncountably many bx_le-successors, and the history maps `Int -> BXPoint`. We cannot visit all of them.

### Key Realization: We Don't Need Full Backward G

For the specific sorry, we need:
1. Forward: `psi in w -> truth_at psi` on the model
2. `not (truth_at chi)` on the model (from `chi not-in w`)

For (1), the forward direction on constant_history w WORKS for all formulas (including G/H inside psi). The issue is only when the BACKWARD direction is needed, which happens in the imp case of the forward truth lemma.

But in the sorry, we are not proving a general truth lemma. We are proving one specific instance:
- `truth_at (psi -> chi) = (truth_at psi -> truth_at chi)`
- We need `truth_at psi` and `not (truth_at chi)` separately
- We do NOT need the general forward truth lemma for `psi -> chi`

So the question reduces to: Can we find a SINGLE model (Omega, tau, t) where:
1. `truth_at psi` holds (for specific `psi in w`)
2. `not (truth_at chi)` holds (for specific `chi not-in w`)

### Strategy: Use h_valid to Derive Contradiction

We have `h_valid : valid (psi.imp chi)`. This means: in EVERY model, `truth_at psi -> truth_at chi`. If we can find ANY model where `truth_at psi` holds and `truth_at chi` does not hold, we contradict `h_valid`.

So we need to construct:
- A TaskFrame F, TaskModel M, Omega (shift-closed), tau in Omega, time t
- Such that `truth_at M Omega tau t psi` and `not (truth_at M Omega tau t chi)`

These can be in SEPARATE models with DIFFERENT construction strategies, as long as they share the same (F, M, Omega, tau, t).

Actually no -- they must be the SAME model. `h_valid` says for ALL models, the implication holds. To contradict it, we need ONE model where the antecedent is true and consequent is false.

### Strategy Revised: Build Model Around chi's Failure

1. Build a chain history that makes `chi` false (the backward countermodel for chi)
2. Prove that `psi` is true on this SAME chain history (the forward direction for psi)

For (1), we use the recursive chain construction from Section 3.
For (2), we need to prove that `psi in w` implies `truth_at psi` on the chain built for chi.

The chain built for chi has `chain 0 = w` (or something bx_le-related to w). The forward direction for psi at time 0 needs to evaluate `truth_at psi` at `chain 0`.

If `chain 0 = w`, and psi is evaluated at time 0, then `truth_at psi` at `(tau, 0)` where `tau.states 0 = w`.

### The Forward Direction for psi on chi's Chain

Let's trace through the forward direction for psi at time 0 on a chain where `chain t = w` for `t <= 0` and `chain t = v` for `t >= 1` (built for `G(alpha) not-in w`):

**Case psi = atom p**: `truth_at (atom p)` at (tau, 0) needs `tau.domain 0` (True) and `valuation (tau.states 0) p = (atom p in w.formulas)`. Since `atom p in w`, this is True.

**Case psi = (alpha -> beta)**: Need `truth_at alpha -> truth_at beta`. If `alpha in w -> beta in w` (from `(alpha -> beta) in w` via imp_iff_mcs), then by IH forward for alpha and beta at time 0 at chain point w, we get the result. But IH forward for alpha needs: `alpha in w -> truth_at alpha at (tau, 0)`. Since `tau.states 0 = w`, the evaluation at time 0 only depends on `w`, which is fine by IH.

Wait, this is circular -- the imp case of the forward truth lemma requires the backward direction for the antecedent. Let me be more precise.

Forward for `(alpha -> beta) in w` at `(tau, 0)`:
- `truth_at (alpha -> beta) = truth_at alpha -> truth_at beta`
- Suppose `truth_at alpha`. Need `truth_at beta`.
- From `(alpha -> beta) in w`: if `alpha in w` then `beta in w`.
- We need: `truth_at alpha -> alpha in w` (backward for alpha at (tau, 0)).

**THIS REQUIRES THE BACKWARD DIRECTION FOR alpha.** On a non-constant history, the backward direction for alpha at time 0 depends on the chain values at other times (for G/H sub-formulas of alpha).

### The Fundamental Issue Restated

The imp case of ANY truth lemma (forward or backward) requires BOTH directions for sub-formulas. This is why a one-directional approach is insufficient and why the standard textbook proof uses a bidirectional iff.

## 6. Component D: The Viable Path -- Restricted Bidirectional Truth Lemma

### Key Observation: Constant History Gives Bidirectional Iff Modulo Flattening

On `constant_history w` with `modal_omega w`:

Define `flatten : Formula -> Formula`:
```
flatten (atom p) = atom p
flatten bot = bot
flatten (psi -> chi) = flatten psi -> flatten chi
flatten (box psi) = box (flatten psi)
flatten (G psi) = flatten psi        -- G collapses on constant history
flatten (H psi) = flatten psi        -- H collapses on constant history
```

Then on constant_history w: `truth_at phi <-> flatten(phi) in w`.

This is a TRUE bidirectional iff. The problem is that `flatten(phi) in w` is not the same as `phi in w` when phi contains G or H.

### Using Flatten for the Sorry

For the sorry, we have `psi in w`, `chi not-in w`, `(psi -> chi) not-in w`, `h_valid`.

On constant_history w with modal_omega w at time 0:
- `truth_at (psi -> chi) <-> (truth_at psi -> truth_at chi) <-> (flatten(psi) in w -> flatten(chi) in w)`

From `h_valid`, instantiate with (canonical_task_frame, canonical_valuation, modal_omega w, constant_history w, 0):
- `truth_at (psi -> chi)` is true
- Therefore `flatten(psi) in w -> flatten(chi) in w`

If we could show `flatten(psi) in w` (from `psi in w`) AND `flatten(chi) not-in w` (from `chi not-in w`), we'd have a contradiction.

**Forward flatten**: `psi in w -> flatten(psi) in w`:
- `G(alpha) in w -> alpha in w` (BX1: temp_t_future) -> by IH `flatten(alpha) in w`
- `H(alpha) in w -> alpha in w` (BX1': temp_t_past) -> by IH `flatten(alpha) in w`
- Imp case: `(alpha -> beta) in w -> (flatten(alpha) -> flatten(beta)) in w`?
  - If `alpha in w` then `beta in w`, then by IH `flatten(beta) in w`, then `(flatten(alpha) -> flatten(beta)) in w` by prop_s
  - If `alpha not-in w` then `neg alpha in w`. We need `(flatten(alpha) -> flatten(beta)) in w` vacuously.
    - If `flatten(alpha) not-in w`: then `(flatten(alpha) -> flatten(beta)) in w` by imp_iff_mcs
    - But do we have `alpha not-in w -> flatten(alpha) not-in w`? NO! `alpha not-in w` does NOT imply `flatten(alpha) not-in w`.
    - Counterexample: `alpha = G(p)`, `G(p) not-in w` but `flatten(G(p)) = p` and `p` might be in w.

So the forward flatten direction FAILS for the imp case.

**Backward flatten**: `chi not-in w -> flatten(chi) not-in w`:
- `G(alpha) not-in w -> flatten(alpha) not-in w`?
  - `G(alpha) not-in w` means there exists `v >= w` with `alpha not-in v`.
  - `flatten(G(alpha)) = flatten(alpha)`. Need `flatten(alpha) not-in w`.
  - But `alpha not-in v` does not give `flatten(alpha) not-in w`.

The backward flatten direction ALSO fails.

**CONCLUSION: The flatten approach is a dead end.** This confirms team research finding 6.

## 7. Component E: The Correct Architecture

### The Standard Canonical Model Construction

The standard approach (Burgess 1984, Goldblatt 1992) uses:

1. **Worlds**: All MCS (BXPoints)
2. **Temporal order**: bx_le (already defined)
3. **Modal equivalence**: bx_modal_equiv (already defined)
4. **Embedding into TaskFrame**: A SINGLE TaskModel where:
   - World states = BXPoint
   - Histories assign BXPoints to times
   - For each MCS w, there exists a history tau_w with tau_w(0) = w
   - Omega contains all "admissible" histories
5. **Bidirectional truth lemma**: `phi in w <-> truth_at M Omega tau_w 0 phi` for all phi, w

The imp case is then trivial:
```
(psi -> chi) in w
  <-> (psi in w -> chi in w)           [imp_iff_mcs]
  <-> (truth_at psi -> truth_at chi)   [by IH on psi and chi]
  <-> truth_at (psi -> chi)            [by definition]
```

### What Makes This Work

The bidirectional truth lemma for G requires:
- Forward: `G(alpha) in w -> forall s >= 0, truth_at alpha at (tau_w, s)`
  - Need: `tau_w(s)` is bx_le-above w for s >= 0, so `G(alpha) in w -> alpha in tau_w(s)` -> by IH `truth_at alpha at (tau_w, s)`
- Backward: `(forall s >= 0, truth_at alpha at (tau_w, s)) -> G(alpha) in w`
  - By IH backward: `truth_at alpha at (tau_w, s) -> alpha in tau_w(s)` for each s
  - Need: for every `v` with `bx_le w v`, there exists some `s >= 0` with `tau_w(s) = v`
  - **THIS IS THE SURJECTIVITY REQUIREMENT**: the history must visit ALL bx_le-successors

Since BXPoint may have uncountably many bx_le-successors but Int is countable, surjectivity is impossible in general.

### Resolving the Surjectivity Problem

**Option 1: Weaken the backward G direction**

Instead of proving `G(alpha) in w` from truth at all times, use a different formulation. The standard textbook proof does NOT require surjectivity onto all BXPoints. It requires surjectivity onto a COUNTABLE set of witnesses.

Specifically, for the backward direction of G at w:
- Suppose `G(alpha) not-in w`.
- By `bx_G_backward`: exists `v >= w` with `alpha not-in v`.
- We need this `v` to appear in the history.

So the requirement is: for every formula `alpha` with `G(alpha) not-in w`, the specific witness `v` from `bx_G_backward` must appear in the history. Since there are only countably many formulas, there are only countably many witnesses needed.

**Option 2: Use the specific formulation for usf_completeness**

For the sorry, we only need to refute ONE formula `psi -> chi`. We do NOT need a universal truth lemma. We can build a model tailored to this specific formula.

### Option 2 Elaborated: Per-Formula Countermodel

Given `w : BXPoint` and `phi : Formula` with `phi not-in w` and `untilSinceFree phi`:

**Theorem (Per-formula countermodel)**:
```
exists D F M Omega tau t, ShiftClosed Omega /\ tau in Omega /\
  not (truth_at M Omega tau t phi)
```

Proof by induction on phi:

**atom p not-in w**:
- Use constant_history w, modal_omega w, time 0
- `truth_at (atom p) = (atom p in w)` = False

**bot not-in w**: Impossible.

**(psi -> chi) not-in w**:
- `psi in w`, `chi not-in w`
- By IH on chi: exists model where `not (truth_at chi)`
- Need: in that SAME model, `truth_at psi`
- **PROBLEM**: The model built for chi's falsity may not make psi true

This is the circular problem. The per-formula countermodel for the imp case needs both properties simultaneously.

### Breaking the Circularity: Merged Construction

The circularity can be broken by building a SINGLE model that simultaneously:
1. Makes all formulas in w true (forward truth)
2. Makes all formulas not in w false (backward truth)

This is exactly the full bidirectional truth lemma. There is no shortcut.

## 8. The Achievable Architecture: Countable Chain History

### Construction

Given `w : BXPoint`, enumerate all USF formulas as `phi_0, phi_1, phi_2, ...` (Formula is Denumerable).

Build a history `tau_w` inductively:
- `tau_w(0) = w`
- For each `n >= 1`:
  - Consider formula `phi_{n-1}`.
  - If `G(phi_{n-1}) not-in tau_w(n-1).formulas`:
    By `bx_G_backward` at `tau_w(n-1)`: exists `v >= tau_w(n-1)` with `phi_{n-1} not-in v`
    Set `tau_w(n) = v`
  - Else:
    Set `tau_w(n) = tau_w(n-1)`
- Mirror for negative times (H direction)

This history visits a countable collection of witnesses. The key properties:

1. **Monotonicity**: `tau_w(n) >= tau_w(m)` for `n >= m >= 0` (bx_le chain)
2. **G-backward**: For any formula `alpha`, if `G(alpha) not-in w`, then there exists `s >= 0` with `alpha not-in tau_w(s)`
3. **G-forward**: For any formula `alpha`, if `G(alpha) in w`, then `alpha in tau_w(s)` for all `s >= 0` (because `bx_le w tau_w(s)` and `bx_G_forward`)

### Bidirectional Truth Lemma on Countable Chain

**Theorem**: For all USF formulas alpha and all times s:
```
alpha in tau_w(s).formulas <-> truth_at canonical_valuation Omega tau_w s alpha
```

Proof by induction on alpha:

**atom**: By definition of canonical_valuation and constant domain.

**bot**: Trivial.

**imp (psi chi)**:
- Forward: `(psi -> chi) in tau_w(s)` means `psi in tau_w(s) -> chi in tau_w(s)`. Suppose `truth_at psi`. By IH backward, `psi in tau_w(s)`. Then `chi in tau_w(s)`. By IH forward, `truth_at chi`.
- Backward: `truth_at (psi -> chi)` means `truth_at psi -> truth_at chi`. Suppose `psi in tau_w(s)`. By IH forward, `truth_at psi`. Then `truth_at chi`. By IH backward, `chi in tau_w(s)`. So `psi in tau_w(s) -> chi in tau_w(s)`, hence `(psi -> chi) in tau_w(s)`.

**box psi**:
- Forward: `box psi in tau_w(s)` -> for all `sigma in Omega`, need `truth_at psi at (sigma, s)`.
  - If `Omega = shifts-of-chain`, then each `sigma in Omega` is `time_shift(tau_w, Delta)`.
  - `truth_at psi at (time_shift(tau_w, Delta), s) <-> truth_at psi at (tau_w, s + Delta)` (by shift preservation)
  - By IH: `<-> psi in tau_w(s + Delta).formulas`
  - From `box psi in tau_w(s)`: by temp_future axiom, `box psi in tau_w(s')` for all `s' >= s`. By modal_t, `psi in tau_w(s')` for `s' >= s`.
  - For `s' < s`: by ... we need `psi in tau_w(s')` for ALL s'.
  - **PROBLEM**: `box psi in tau_w(s)` does NOT imply `psi in tau_w(s')` for `s' < s`.

This reveals a FUNDAMENTAL issue: the shifts-of-chain Omega does NOT correctly model box semantics. Box requires truth at all histories in Omega, but shifts-of-chain only contains time-shifted versions of the same chain, not histories through different modal-equivalents.

### Omega Must Include Modal Equivalents

For box to work, Omega must contain histories through all modal-equivalents of every chain point. Two options:

**Option A: Omega = modal_omega(w)**
- Contains constant histories through all v ~ w
- Shift-closed (constant histories are shift-invariant)
- Box works: `truth_at (box psi) at (tau, s) = forall sigma in modal_omega(w), truth_at psi at (sigma, s)`
- For constant histories: `truth_at psi at (constant_history v, s) <-> psi in v` (IF the IH gives the iff on constant histories through modal-equivalents)
- But the IH only gives the iff for the CHAIN history tau_w, not for constant histories through other points

**Option B: Omega = union of chain-shifts through all modal-equivalents**
- For each `v ~ w`, build a chain history `tau_v`
- Omega = union of all shifts of all `tau_v`
- This is complicated and may not be shift-closed in a simple way

**Option C: Hybrid -- modal_omega for box, chain for G/H**
- Use two DIFFERENT Omegas? Not possible -- one model has one Omega.

### The Standard Solution: Product Construction

The standard canonical model for S5 + tense logic uses:
- A single world = a "coherent tuple" of MCS indexed by (modal class, time)
- The accessibility relation between tuples encodes both modal and temporal structure

This is significantly more complex than what we have.

## 9. Pragmatic Assessment: What Can Be Done

### What We Have (Fully Proved)

1. `fragment_truth_iff`: Bidirectional truth lemma for temporal-free formulas on constant histories with modal_omega -- **COMPLETE**
2. `fragment_completeness`: Completeness for temporal-free fragment -- **COMPLETE**
3. All MCS-level truth lemmas: `imp_iff_mcs`, `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` -- **COMPLETE**
4. All witness constructions: `bx_G_backward`, `bx_H_backward`, `bx_modal_witness` -- **COMPLETE**
5. `canonical_task_frame`, `constant_history`, `modal_omega`, `canonical_valuation` -- **COMPLETE**
6. Outer cases of `usf_completeness`: atom, bot, box, G, H -- **COMPLETE** (via reduction)

### What We Need

One sorry: the imp Case B of `usf_completeness`, which requires building a countermodel for `(psi -> chi)` when `psi in w`, `chi not-in w`.

### Minimal Sufficient Approach

**Approach: Mutual Induction on Forward + Backward**

Define two mutually recursive functions:
```
forward_truth (w : BXPoint) (phi : Formula) (h_usf : untilSinceFree phi)
    (h_in : phi in w.formulas) :
    truth_at canonical_valuation (modal_omega w) (constant_history w) 0 phi

backward_truth (w : BXPoint) (phi : Formula) (h_usf : untilSinceFree phi)
    (h_truth : truth_at canonical_valuation (modal_omega w) (constant_history w) 0 phi) :
    phi in w.formulas
```

On constant_history w with modal_omega w at time 0:

**forward_truth for G(alpha) in w**:
- `truth_at G(alpha) = forall s >= 0, truth_at alpha at (constant_history w, s)`
- On constant history, all times map to w. So truth at any time s is the same as truth at time 0.
- `G(alpha) in w -> alpha in w` (BX1) -> by IH forward, `truth_at alpha` at any time s.

**backward_truth for G(alpha)**: `truth_at G(alpha) on constant_history w at 0`
- `= forall s >= 0, truth_at alpha at (constant_history w, s)`
- At s = 0: `truth_at alpha at (constant_history w, 0)`
- By IH backward: `alpha in w`
- But we need `G(alpha) in w`, which requires `alpha in v` for ALL `v >= w`.
- We only have `alpha in w`. **FAILS.**

So backward_truth for G FAILS on constant histories. This is the known problem.

### The Critical Question: Can We Avoid the Backward G Direction?

For the sorry, we need `truth_at psi` and `not (truth_at chi)` at the same model.

If we use `(constant_history w, modal_omega w, 0)`:
- `truth_at psi`: Need forward truth for all of psi's sub-formulas. The forward direction works.
- `not (truth_at chi)`: Need to show chi is false.

For `not (truth_at chi)` on constant_history w:
- If chi = atom p: `atom p not-in w -> not (truth_at (atom p))`. TRUE (by definition).
- If chi = G(alpha): `truth_at G(alpha) = forall s >= 0, truth_at alpha at s`. On constant history, this equals `truth_at alpha at 0`. So `not (truth_at G(alpha)) = not (truth_at alpha at 0)`.
  - `G(alpha) not-in w`. Does this give `not (truth_at alpha)`?
  - `G(alpha) not-in w` means exists `v >= w` with `alpha not-in v`. But `alpha` might still be in `w`.
  - Example: `G(p) not-in w` but `p in w`. Then `truth_at p on constant_history w = True`. So `truth_at G(p) = True`. But `G(p) not-in w`. **MISMATCH.**

This confirms: constant histories are insufficient for the backward direction of G.

### Revised Minimal Approach: Two-Point History

For `G(alpha) not-in w`, by `bx_G_backward` get `v >= w` with `alpha not-in v`.

Build a two-point history:
```
tau.states t = if t >= 1 then v else w
```

Then `truth_at G(alpha) at (tau, 0) = forall s >= 0, truth_at alpha at (tau, s)`.
At s = 1: `truth_at alpha at (tau, 1)` where `tau.states 1 = v`.

If we can show `alpha not-in v -> not (truth_at alpha at (tau, 1))`, we're done.

But `truth_at alpha at (tau, 1)` depends on the entire tau, not just `tau.states 1 = v`. For example, if alpha contains H, then `truth_at H(beta) at (tau, 1) = forall r <= 1, truth_at beta at (tau, r)`. At r = 0, `tau.states 0 = w`. So `truth_at H(beta)` at `(tau, 1)` involves `w`, not just `v`.

The two-point history approach requires proving that `alpha not-in v` implies `not (truth_at alpha)` on the two-point history at time 1. This requires analyzing alpha's structure and may fail for formulas mixing G/H.

### The Recursion Works for USF

For USF formulas (no Until/Since), the two-point (or multi-point) construction can be made to work by recursion on formula complexity:

For `chi not-in w`, build model making chi false:
- chi = atom p: constant history, trivial
- chi = (alpha -> beta): alpha in w, beta not-in w. Build model for beta not-in w. Show alpha true on that model.
- chi = box alpha: modal witness v ~ w, alpha not-in v. Build model where some sigma in Omega has alpha false.
- chi = G(alpha): witness v >= w, alpha not-in v. Need model where truth_at G(alpha) is false, i.e., exists s >= 0 with truth_at alpha false at time s.
- chi = H(alpha): mirror

For each case, the formula we recurse on is STRUCTURALLY SMALLER (alpha < G(alpha), beta < (alpha -> beta), etc.). The recursion terminates.

**The imp sub-case** (chi = alpha -> beta, with alpha in w, beta not-in w):
- Build model for `beta not-in w` by IH. Call it `(F_beta, M_beta, Omega_beta, tau_beta, t_beta)`.
- Need `truth_at alpha` on this same model.
- `alpha in w` and the model is built around w... but the model may not evaluate alpha correctly at w because it was built for beta's falsity.

THIS is where the mutual induction is needed. The model must simultaneously make all formulas in w true and all formulas not in w false.

## 10. Final Recommended Architecture

### Approach: Dovetailed Chain with Full Bidirectional Truth Lemma

This is the only approach that correctly handles all interactions:

**Step 1**: Build the dovetailed chain history.

Given `w : BXPoint`, since Formula is Denumerable, enumerate all formulas. Build `tau_w : Int -> BXPoint` by dovetailing G-backward and H-backward witnesses:

```
tau_w(0) = w
tau_w(2k+1) = G-backward witness for phi_k at tau_w(2k) (if G(phi_k) not-in tau_w(2k))
            = tau_w(2k) otherwise
tau_w(2k+2) = tau_w(2k+1)  (stabilize)
```

Similarly for negative times using H-backward.

Properties:
- `bx_le tau_w(m) tau_w(n)` for `0 <= m <= n` (monotone chain)
- For any alpha, if `G(alpha) not-in w`, then exists `s >= 0` with `alpha not-in tau_w(s)`
- For any alpha, if `G(alpha) in w`, then `alpha in tau_w(s)` for all `s >= 0` (by bx_G_forward + chain monotonicity)

**Step 2**: Define Omega.

```
Omega = { sigma | exists v ~ w, sigma = constant_history v }
      union
      { time_shift(tau_w, Delta) | Delta in Int }
```

Wait -- this union may not be shift-closed because `time_shift(constant_history v, Delta) = constant_history v`, so the constant histories are shift-closed. And time_shift of chain shifts is another chain shift. So Omega IS shift-closed.

But then box semantics quantifies over ALL sigma in Omega, including the chain shifts. For `truth_at (box psi)` to work, we need `truth_at psi` at every chain shift. This requires the truth lemma at every chain point, not just at w.

**Step 3**: Prove bidirectional truth lemma.

For all `s : Int`:
```
alpha in tau_w(s).formulas <-> truth_at canonical_valuation Omega tau_w s alpha
```

The box case needs:
- Forward: `box alpha in tau_w(s) -> forall sigma in Omega, truth_at alpha at (sigma, s)`
  - For constant_history v (v ~ tau_w(s)): by IH at v, need `alpha in v` -- follows from `box alpha in tau_w(s)` and `v ~ tau_w(s)`
  - But wait: is `v ~ tau_w(s)` the right condition? Omega contains `v ~ w`, not `v ~ tau_w(s)`.
  - `tau_w(s)` may not be modally equivalent to w. So `constant_history v` with `v ~ w` may not relate to `tau_w(s)`.

**PROBLEM**: Modal equivalence is relative to w, but the chain visits different MCS. At time s, the chain is at `tau_w(s)`, which may not be modally equivalent to w. The modal_omega is defined relative to w, but box semantics at time s evaluates relative to `tau_w(s)`.

### The Deep Problem

In a TaskModel, `truth_at (box psi) Omega tau s = forall sigma in Omega, truth_at psi Omega sigma s`. The box quantifies over ALL histories in Omega. This means at time s, box sees truth at ALL histories in Omega evaluated at time s. But each history in Omega may evaluate to a different BXPoint at time s.

For the truth lemma to work at `tau_w(s)`, we need:
```
box alpha in tau_w(s) <-> forall sigma in Omega, truth_at alpha Omega sigma s
```

The forward direction: `box alpha in tau_w(s)` and `sigma in Omega`. We need `truth_at alpha at (sigma, s)`.
- If `sigma = constant_history v` with `v ~ w`: `truth_at alpha at (constant_history v, s) <-> alpha in v` (by IH? only if the IH works at v)
- But `v` might not be bx_le-related to `tau_w(s)`. And `box alpha in tau_w(s)` gives `alpha in u` for `u ~ tau_w(s)`, not for `u ~ w`.

Unless `bx_modal_equiv tau_w(s) w` -- i.e., modal equivalence is preserved along the chain.

**Is bx_modal_equiv preserved by bx_le?** `bx_modal_equiv w v <-> forall phi, box phi in w <-> box phi in v`. From `bx_le w v` (g_content w <= v): `G(phi) in w -> phi in v`. But `box phi in w` does NOT imply `box phi in v` via bx_le. Modal equivalence and temporal ordering are independent.

However, the axiom `temp_future : box phi -> G(box phi)` gives: `box phi in w -> G(box phi) in w -> box phi in v` for `v >= w`. And `modal_future : box phi -> box(G phi)` helps propagate box to future modal-equivalents.

From `temp_future`: `box phi in w -> G(box phi) in w`. Since `bx_le w v`: `box phi in v`. And by `temp_t_past` combined with converse: from `bx_le w v` and `G(box phi) in w`, we get `box phi in v`.

Wait, more directly: `temp_future` gives `box phi in w -> G(box phi) in w`. Since `bx_le w v`, `G(box phi) in w -> box phi in v`. So `box phi in w -> box phi in v` for all `v >= w`.

Similarly for the reverse: if `v >= w` and `box phi in v`, do we get `box phi in w`? Not necessarily. But from `temp_future` at v: `box phi in v -> G(box phi) in v`. This doesn't help for w < v.

Let me check: is `H(box phi)` in v from `box phi in v`? We'd need an axiom like `box phi -> H(box phi)`. The temporal duality of `temp_future` would be `box(swap phi) -> H(box(swap phi))`. Applying temporal_duality to `temp_future`:
- `temp_future phi`: `box phi -> G(box phi)`
- `swap_temporal`: `box(swap phi) -> H(box(swap phi))`

This doesn't directly give `box phi -> H(box phi)`.

Actually, let me think about this differently. In S5, we have `box phi -> box(box phi)` (modal_4). And `box(box phi) -> G(box(box phi))` (by temp_future applied to `box phi`). And by modal_t, `box(box phi) -> box phi`. So `G(box phi)` propagates forward. For backward, we need `box phi -> H(box phi)`.

From the axioms: there is no `modal_past` axiom, but we can derive it. `box phi in w -> box(box phi) in w` (modal_4). `box(box phi) in w -> G(box(box phi)) in w` (temp_future). By BX4 (connect_future): `phi -> G(P(phi))`. Apply this at the MCS level: `box phi in w -> G(P(box phi)) in w`. Hmm, that gives `P(box phi)` in all future points, not `H(box phi)` in w.

Actually, there may be a simpler argument. By BX4' (connect_past): `phi -> H(F(phi))`. So `box phi -> H(F(box phi))`. And `F(box phi) = neg(G(neg(box phi)))`. This gives `H(F(box phi))` in w, which means at all past times v, `F(box phi) in v`. But that's `F(box phi)`, not `box phi`.

Let me try the S5 route. In S5: `box phi -> box(box phi)` (4). And `neg(box phi) -> box(neg(box phi))` (negative introspection / 5). So `box phi` is a "stable" formula: either `box phi in v` for ALL v, or `neg(box phi) in v` for ALL v (within a modal equivalence class). But modal equivalence and temporal ordering are different -- different MCS in a bx_le chain may not be modally equivalent.

HOWEVER, the key insight from `temp_future`: `box phi in w -> G(box phi) in w`. This means if `box phi in w`, then `box phi in v` for all `v >= w` (by bx_G_forward). So box formulas PROPAGATE FORWARD along bx_le chains.

For backward: suppose `box phi in v` for some `v >= w`. Does `box phi in w`? Not necessarily -- `box phi` does not propagate backward. Example: `box phi not-in w` but `box phi in v` for some `v >= w`.

So modal equivalence is NOT preserved along bx_le chains in general. But box formulas propagate FORWARD.

### Implication for Omega Design

For the truth lemma at chain point `tau_w(s)` with `s >= 0`:
- `box alpha in tau_w(s)` (forward from `box alpha in w` via temp_future + bx_G_forward)
- Need: `truth_at alpha at (sigma, s)` for all `sigma in Omega`

If Omega only contains histories through points that are modally equivalent to `tau_w(s)`, this works. But `tau_w(s)` changes with s, and Omega is fixed.

### Simplification: Modal_omega at w WITH Box Propagation

If `Omega = modal_omega w`:
- At time s, for `sigma = constant_history v` with `v ~ w`:
  - `truth_at alpha at (constant_history v, s)` -- on constant history, time doesn't matter
  - By IH at v: `<-> alpha in v`
- Forward box at `tau_w(s)`: `box alpha in tau_w(s) -> forall v ~ w, alpha in v`
  - From `box alpha in tau_w(s)`: `alpha in u` for all `u ~ tau_w(s)`.
  - But `v ~ w`, not `v ~ tau_w(s)`. These may differ!
  - UNLESS `tau_w(s) ~ w` for all s. But this is NOT guaranteed.

So this approach only works if modal equivalence is preserved along the chain.

### Key Lemma Needed

**Lemma (Box propagation along bx_le)**:
If `bx_le w v`, then for all `phi`: `box phi in w <-> box phi in v`.

Proof:
- Forward: `box phi in w -> G(box phi) in w` (temp_future) -> `box phi in v` (bx_G_forward)
- Backward: `box phi in v`. Need `box phi in w`.
  - `bx_le w v` means `g_content(w) <= v`.
  - From `box phi in v` and `temp_future at v`: `G(box phi) in v`.
  - From BX4' (connect_past) at v: ... this doesn't directly help.

Let me try: Suppose `box phi not-in w`. By negative introspection (S5): `box(neg(box phi)) in w`. By temp_future: `G(box(neg(box phi))) in w`. Since `bx_le w v`: `box(neg(box phi)) in v`. By modal_t: `neg(box phi) in v`. But we assumed `box phi in v`. Contradiction.

**Proof of backward direction**: Suppose `box phi in v` and `bx_le w v`. Suppose for contradiction `box phi not-in w`. Then `neg(box phi) in w` (negation completeness). By S5 negative introspection: `box(neg(box phi)) in w`. By `temp_future`: `G(box(neg(box phi))) in w`. By `bx_G_forward` with `bx_le w v`: `box(neg(box phi)) in v`. By `modal_t`: `neg(box phi) in v`. But `box phi in v` and `neg(box phi) in v` contradicts consistency of v.

**QED.** Box formulas are preserved in BOTH directions along bx_le chains!

This means `bx_modal_equiv w v` holds for all `v` with `bx_le w v` (and by symmetry, for all v in the chain). Actually, `bx_modal_equiv w v <-> forall phi, box phi in w <-> box phi in v`. The lemma above shows this holds when `bx_le w v`.

### Consequence: Modal Omega at w Works for All Chain Points

Since `bx_modal_equiv tau_w(s) w` for all s >= 0 (from bx_le chain + the lemma above), and by mirror for s < 0:

`modal_omega w = modal_omega tau_w(s)` for all s.

This means the same Omega works at every chain point!

## 11. Complete Proof Blueprint

### Phase 1: New Lemma -- Box Preservation Along bx_le

```lean
theorem box_preserved_along_bx_le {w v : BXPoint} (h_le : bx_le w v) (phi : Formula) :
    Formula.box phi in w.formulas <-> Formula.box phi in v.formulas := by
  constructor
  . -- Forward: box phi in w -> G(box phi) in w -> box phi in v
    intro h_box
    have h_temp_future := theorem_in_mcs w.is_mcs
      (DerivationTree.axiom [] _ (Axiom.temp_future phi))
    have h_G_box := SetMaximalConsistent.implication_property w.is_mcs h_temp_future h_box
    exact bx_G_forward h_le h_G_box
  . -- Backward: box phi in v, bx_le w v -> box phi in w (by S5 negative introspection)
    intro h_box_v
    by_contra h_not_box
    have h_neg_box := (SetMaximalConsistent.negation_complete w.is_mcs (Formula.box phi)).elim
      (fun h => absurd h h_not_box) id
    -- S5 negative introspection: neg(box phi) -> box(neg(box phi))
    -- (already proved in bx_modal_witness's h_equiv backward direction)
    have h_neg_intro := ... -- neg(box phi) -> box(neg(box phi))
    have h_box_neg_box := SetMaximalConsistent.implication_property w.is_mcs
      (theorem_in_mcs w.is_mcs h_neg_intro) h_neg_box
    have h_temp := theorem_in_mcs w.is_mcs
      (DerivationTree.axiom [] _ (Axiom.temp_future (Formula.box phi).neg))
    have h_G_box_neg := SetMaximalConsistent.implication_property w.is_mcs h_temp h_box_neg_box
    have h_box_neg_v := bx_G_forward h_le h_G_box_neg
    have h_neg_box_v := SetMaximalConsistent.implication_property v.is_mcs
      (theorem_in_mcs v.is_mcs (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box phi).neg)))
      h_box_neg_v
    exact set_consistent_not_both v.is_mcs.1 (Formula.box phi) h_box_v h_neg_box_v
```

### Phase 2: Modal Equivalence Preserved Along bx_le

```lean
theorem bx_modal_equiv_of_bx_le {w v : BXPoint} (h_le : bx_le w v) :
    bx_modal_equiv w v :=
  fun phi => box_preserved_along_bx_le h_le phi
```

Consequence: `modal_omega w = modal_omega v` for `bx_le w v`.

### Phase 3: Dovetailed Chain History

```lean
noncomputable def dovetail_chain (w : BXPoint) : Int -> BXPoint := ...
```

With properties:
- `dovetail_chain w 0 = w`
- `bx_le (dovetail_chain w m) (dovetail_chain w n)` for `0 <= m <= n`
- `bx_le (dovetail_chain w n) (dovetail_chain w m)` for `m <= n <= 0`
- For every formula alpha: if `G(alpha) not-in w`, exists `s >= 1` with `alpha not-in dovetail_chain w s`
- For every formula alpha: if `H(alpha) not-in w`, exists `s <= -1` with `alpha not-in dovetail_chain w s`

### Phase 4: Dovetail History as WorldHistory

```lean
noncomputable def dovetail_history (w : BXPoint) : WorldHistory canonical_task_frame where
  domain := fun _ => True
  convex := ...
  states := fun t _ => dovetail_chain w t
  respects_task := ...  -- uses canonical_task_frame's permissive task_rel
```

### Phase 5: Omega = modal_omega w

Use `modal_omega w` (already defined). It is shift-closed (already proved: `modal_omega_shift_closed`). The dovetail_history may not be in modal_omega w (it's not a constant history). So we need either:

(a) `Omega = modal_omega w union {time_shift(dovetail_history w, Delta) | Delta}`
(b) Just use `modal_omega w` and accept that `dovetail_history w not-in Omega`

Wait -- for `truth_at` to make sense, we evaluate at `(M, Omega, tau, t)`. The tau does NOT need to be in Omega for most connectives. But for validity, `h_valid` gives truth at `(M, Omega, tau, t)` for tau IN Omega.

To use h_valid, we need `tau in Omega`. So the dovetail_history must be in Omega.

**Solution**: `Omega = modal_omega w union {time_shift(dovetail_history w, Delta) | Delta}`.

Shift-closure: `modal_omega w` is shift-closed. Shifts of `time_shift(dovetail_history w, Delta)` give `time_shift(dovetail_history w, Delta + Delta')`, which is in the second component. So the union is shift-closed.

Need `dovetail_history w in Omega`: `dovetail_history w = time_shift(dovetail_history w, 0)`, so yes.

### Phase 6: Bidirectional Truth Lemma

```lean
theorem chain_truth_iff (w : BXPoint) (phi : Formula) (h_usf : untilSinceFree phi) (s : Int) :
    phi in (dovetail_chain w s).formulas <->
    truth_at canonical_valuation
      (modal_omega w union dovetail_shifts w)
      (dovetail_history w) s phi
```

Cases:

**atom p**: `atom p in dovetail_chain w s <-> exists ht, valuation (dovetail_chain w s) p <-> atom p in dovetail_chain w s`. Tautological.

**bot**: Both sides False.

**imp psi chi**:
- `(psi -> chi) in chain(s) <-> (psi in chain(s) -> chi in chain(s))` (imp_iff_mcs)
- `truth_at (psi -> chi) = truth_at psi -> truth_at chi`
- By IH on psi and chi: `psi in chain(s) <-> truth_at psi` and `chi in chain(s) <-> truth_at chi`
- Composing: `(psi in chain(s) -> chi in chain(s)) <-> (truth_at psi -> truth_at chi)`. QED.

**box psi**:
- Forward: `box psi in chain(s) -> forall sigma in Omega, truth_at psi at (sigma, s)`
  - For `sigma = constant_history v` with `v ~ w`:
    - By Phase 2: `bx_modal_equiv chain(s) w` (since `bx_le w chain(s)` or vice versa)
    - So `box psi in chain(s) <-> box psi in w` -> `box psi in w`
    - From `box_iff_mcs w psi`: `psi in v`
    - On constant_history v at time s: `truth_at psi at (constant_history v, s)`.
    - Need IH on psi at v for constant histories. Since v ~ w ~ chain(s'), the IH at v needs the truth lemma at v.
    - **ISSUE**: The IH is for the dovetail_history, not for constant histories.

This reveals another subtlety: the truth lemma is for the dovetail history, but Omega also contains constant histories. We need the truth lemma for ALL histories in Omega, not just the dovetail.

### Resolving: Truth on Constant Histories

For `sigma = constant_history v` with `v ~ w`, we need:
```
truth_at psi at (constant_history v, s) <-> psi in v
```

But this is exactly `fragment_truth_iff` for temporal-free psi. For psi containing G/H:

On `constant_history v` at time s:
- `truth_at G(alpha) = forall r >= s, truth_at alpha at (constant_history v, r)`
- On constant history, truth_at alpha at any time r gives the same result.
- So `truth_at G(alpha) <-> truth_at alpha at (constant_history v, s)` on constant history.
- By IH: `truth_at alpha at (constant_history v, s) <-> alpha in v`
- Therefore: `truth_at G(alpha) on constant_history v <-> alpha in v`

But `G(alpha) in v <-> forall u >= v, alpha in u` (G_iff_mcs). And `alpha in v` does NOT imply `G(alpha) in v`.

So the bidirectional truth lemma for G FAILS on constant histories through arbitrary v. This means constant histories through modal-equivalents do NOT satisfy the truth lemma for G.

### The Fundamental Obstacle

Every history in Omega must satisfy the truth lemma. Constant histories through non-w points do NOT satisfy the truth lemma for G. Therefore, Omega cannot contain constant histories through non-w points (unless they happen to satisfy the G truth lemma).

### Revised Omega: Only Dovetail Shifts

**Omega = {time_shift(dovetail_history w, Delta) | Delta in Int}**

This is shift-closed by construction. The dovetail_history is in Omega (Delta = 0).

Box case: `truth_at (box psi) at (dovetail_history w, s) = forall sigma in Omega, truth_at psi at (sigma, s)`.
- Each `sigma = time_shift(dovetail_history w, Delta)`.
- `truth_at psi at (time_shift(dovetail_history w, Delta), s)` -- by shift preservation -- `<-> truth_at psi at (dovetail_history w, s + Delta)`.
- By IH: `<-> psi in dovetail_chain w (s + Delta)`.
- Forward: `box psi in chain(s) -> psi in chain(s + Delta)` for all Delta.
  - For Delta >= 0: `bx_le chain(s) chain(s + Delta)` (monotone chain). By `box_preserved_along_bx_le`: `box psi in chain(s + Delta)`. By modal_t: `psi in chain(s + Delta)`.
  - For Delta < 0: `bx_le chain(s + Delta) chain(s)` (monotone). By box_preserved: `box psi in chain(s + Delta)`. By modal_t: `psi in chain(s + Delta)`.
  - **WORKS!**
- Backward: `(forall Delta, psi in chain(s + Delta)) -> box psi in chain(s)`.
  - By box_iff_mcs: need `forall v ~ chain(s), psi in v`.
  - We have `psi in chain(s')` for all `s'`.
  - But `v ~ chain(s)` does NOT mean `v = chain(s')` for some `s'`. There may be modal-equivalents not on the chain.
  - **BACKWARD BOX FAILS** with shifts-only Omega.

### Summary of Attempts

| Omega | Forward Box | Backward Box | Forward G | Backward G |
|-------|-------------|--------------|-----------|------------|
| modal_omega w | OK | OK | OK | FAILS (surjectivity) |
| dovetail shifts | OK | FAILS (not all modal-equivs) | OK | OK (by chain construction) |
| union | OK | Partial (only for v in chain) | OK | OK |

Neither Omega choice gives a full bidirectional truth lemma.

### The Solution: Weaken Box Backward

We don't need the full backward box truth lemma. We need the backward truth lemma for the specific formula chi (where `chi not-in w`).

If `chi = box alpha`, then `box alpha not-in w`. We need `not (truth_at (box alpha))` on the dovetail model. With Omega = dovetail shifts:
```
truth_at (box alpha) = forall sigma in Omega, truth_at alpha at (sigma, 0)
                     = forall Delta, truth_at alpha at (dovetail_history w, Delta)
                     = forall Delta, alpha in dovetail_chain w Delta  [by IH]
```

From `box alpha not-in w`: by `bx_modal_witness`, exists `v ~ w` with `alpha not-in v`. But `v` may not be on the dovetail chain. So `not (forall Delta, alpha in chain(Delta))` is NOT guaranteed.

**THIS IS THE REMAINING PROBLEM FOR BOX.**

### Resolution for Box: Add Modal Witness to Chain

When building the dovetail chain, also dovetail modal witnesses:

For `box alpha not-in w`: by `bx_modal_witness`, get `v ~ w` with `alpha not-in v`. Place `v` at some time on the chain.

But wait: `v ~ w` means `bx_modal_equiv w v`. By Phase 2, `bx_modal_equiv` is preserved along bx_le. But `v` may not be bx_le-related to w at all! Modal equivalence is NOT the same as bx_le.

Actually, `bx_modal_equiv_of_bx_le` says bx_le implies modal equivalence. But the converse is false. `v ~ w` does NOT imply `bx_le w v` or `bx_le v w`.

So we CANNOT place a modal witness on the bx_le chain. The chain must be monotone in bx_le, but modal witnesses are not bx_le-related.

### The True Solution: Separate Modal and Temporal Dimensions

The standard canonical model for S5 + tense logic uses a TWO-DIMENSIONAL structure:
- One dimension for modal accessibility (equivalence classes)
- One dimension for temporal ordering (bx_le chains within each equivalence class)

In the TaskModel framework:
- Different histories represent different modal possibilities
- Time within a history represents the temporal dimension

So the correct construction is:
- For each modal-equivalent v ~ w, build a dovetail chain `chain_v`
- `Omega = {time_shift(history_v, Delta) | v ~ w, Delta in Int}`
- Each `history_v` visits enough BXPoints for the G/H truth lemma
- Box quantifies over all `history_v` (different v ~ w)

### Detailed Two-Dimensional Construction

**Step 1**: For each `v : BXPoint` with `bx_modal_equiv w v`:
- Build `dovetail_chain_v : Int -> BXPoint` starting at v
- `dovetail_chain_v 0 = v`
- Monotone: `bx_le chain_v(m) chain_v(n)` for `0 <= m <= n`
- Visits G-backward witnesses for v
- Visits H-backward witnesses for v (negative times)

**Step 2**: Define histories:
```lean
noncomputable def dovetail_history_v (v : BXPoint) : WorldHistory canonical_task_frame where
  domain := fun _ => True
  states := fun t _ => dovetail_chain_v t
  ...
```

**Step 3**: Define Omega:
```
Omega = {time_shift(dovetail_history_v, Delta) | bx_modal_equiv w v, Delta in Int}
```

**Step 4**: Shift-closure: shifting `time_shift(history_v, Delta)` by `Delta'` gives `time_shift(history_v, Delta + Delta')`, still in Omega.

**Step 5**: Bidirectional truth lemma for all `v ~ w` and all `s`:
```
phi in dovetail_chain_v(s).formulas <-> truth_at canonical_valuation Omega (dovetail_history_v) s phi
```

**Box forward at chain_v(s)**: `box phi in chain_v(s) -> forall sigma in Omega, truth_at phi at (sigma, s)`.
- Each sigma is `time_shift(history_u, Delta)` for some `u ~ w`.
- `truth_at phi at (time_shift(history_u, Delta), s) <-> truth_at phi at (history_u, s + Delta) <-> phi in chain_u(s + Delta)` (by IH at u).
- `box phi in chain_v(s)`. By box_preserved_along_bx_le: `box phi in v` (since bx_le v chain_v(s) or vice versa). By bx_modal_equiv v w: `box phi in w`. By bx_modal_equiv w u: `box phi in u`. By box_preserved: `box phi in chain_u(s + Delta)`. By modal_t: `phi in chain_u(s + Delta)`.
- Wait: `bx_modal_equiv chain_v(s) w`? We showed bx_le implies bx_modal_equiv. `bx_le v chain_v(s)` (from chain monotonicity). So `bx_modal_equiv v chain_v(s)`. And `bx_modal_equiv w v`. So `bx_modal_equiv w chain_v(s)` by transitivity. Similarly `bx_modal_equiv w u` -> `bx_modal_equiv chain_v(s) u`. So `box phi in chain_v(s) -> box phi in u` (by the equivalence). Then `box phi in u -> box phi in chain_u(s')` for any s' (by box_preserved + bx_le). Then modal_t: `phi in chain_u(s')`. **WORKS!**

**Box backward at chain_v(s)**: `(forall sigma in Omega, truth_at phi at (sigma, s)) -> box phi in chain_v(s)`.
- By IH backward at each u: `truth_at phi at (history_u, s + Delta) -> phi in chain_u(s + Delta)`.
- We have `phi in chain_u(s')` for all u ~ w and all s'.
- Need: `box phi in chain_v(s)`.
- By box_iff_mcs at chain_v(s): need `forall u' ~ chain_v(s), phi in u'`.
- Take any `u' ~ chain_v(s)`. Since `bx_modal_equiv w chain_v(s)` (proved above), `u' ~ w`. So `u'` is one of the modal-equivalents of w.
- For this `u'`, build `chain_{u'}`. Then `phi in chain_{u'}(0) = phi in u'`. But we only have `phi in chain_u(s')` for u's that have THEIR OWN chain built. The Omega includes histories for ALL u ~ w.
- We need: `phi in chain_{u'}(s')` for SOME s'. In particular, `phi in chain_{u'}(0) = phi in u'`.
- From the hypothesis: `truth_at phi at (history_{u'}, s)`. By IH backward at u': `phi in chain_{u'}(s)`.
- Actually we want `phi in u'`. Since `chain_{u'}(0) = u'` and `bx_le u' chain_{u'}(s)` for s >= 0, and `box phi in chain_{u'}(s)` might not hold...
- Wait. We have `phi in chain_{u'}(s + 0)` (take Delta = 0 in the sigma ranging). Actually, for the sigma = `history_{u'}` (Delta = 0), we get `truth_at phi at (history_{u'}, s)`, giving `phi in chain_{u'}(s)` by IH.
- But we need `phi in u' = chain_{u'}(0)`, not `phi in chain_{u'}(s)`.
- For s >= 0: `bx_le u' chain_{u'}(s)`. From `phi in chain_{u'}(s)`, does `phi in u'` follow? NOT in general -- G(phi) in u' gives phi in chain_{u'}(s), but phi in chain_{u'}(s) does not imply phi in u'.
- However, we can take Delta = -s: sigma = `time_shift(history_{u'}, -s)`. Then `truth_at phi at (time_shift(history_{u'}, -s), s) <-> truth_at phi at (history_{u'}, 0) <-> phi in chain_{u'}(0) = phi in u'`.
- From the universal quantifier over Omega, this sigma IS in Omega. So `phi in u'`. **WORKS!**

**G forward at chain_v(s)**: `G(phi) in chain_v(s) -> forall r >= s, truth_at phi at (history_v, r)`.
- `bx_le chain_v(s) chain_v(r)` for `r >= s`. By bx_G_forward: `phi in chain_v(r)`. By IH forward: `truth_at phi`.
- **WORKS!**

**G backward at chain_v(s)**: `(forall r >= s, truth_at phi at (history_v, r)) -> G(phi) in chain_v(s)`.
- By IH backward: `phi in chain_v(r)` for all `r >= s`.
- Need: `G(phi) in chain_v(s)`.
- By G_iff_mcs: need `forall u >= chain_v(s), phi in u`.
- Take any `u` with `bx_le chain_v(s) u`. Is `u = chain_v(r)` for some `r >= s`? NOT necessarily -- u could be any BXPoint above chain_v(s).
- **HOWEVER**: by the dovetail construction, for any formula alpha, if `G(alpha) not-in chain_v(s)`, then there exists `r >= s` on the chain with `alpha not-in chain_v(r)`.
- Contrapositive: if `alpha in chain_v(r)` for all `r >= s`, then `G(alpha) in chain_v(s)`.
- But this contrapositive is what we need! If for all r >= s, phi in chain_v(r), does G(phi) in chain_v(s) follow?
- By the dovetail: if G(phi) not-in chain_v(s), then exists r >= s with phi not-in chain_v(r). Contrapositive: if forall r >= s, phi in chain_v(r), then G(phi) in chain_v(s). **WORKS!**

**H forward/backward**: Mirror of G. **WORKS!**

### THIS IS THE CORRECT ARCHITECTURE

## 12. Summary of Required Components

### New Lemmas (in order of dependency)

1. **box_preserved_along_bx_le** (Frame.lean): `bx_le w v -> (box phi in w <-> box phi in v)`
   - ~30 lines, using S5 negative introspection (already derived in bx_modal_witness)
   - DEFINITELY achievable

2. **bx_modal_equiv_of_bx_le** (Frame.lean): `bx_le w v -> bx_modal_equiv w v`
   - Immediate corollary of (1)
   - DEFINITELY achievable

3. **modal_omega_eq_along_chain** (CanonicalEmbedding.lean): `bx_le w v -> modal_omega w = modal_omega v`
   - Follows from (2) + existing `modal_omega_eq_of_equiv`
   - DEFINITELY achievable

4. **dovetail_chain** (new file or CanonicalEmbedding.lean): `BXPoint -> Int -> BXPoint`
   - Uses Denumerable Formula to enumerate all formulas
   - At each step, uses bx_G_backward or bx_H_backward for witness
   - ~60-80 lines
   - ACHIEVABLE but requires careful recursive definition

5. **dovetail_chain_properties** (same file):
   - Monotonicity: `bx_le chain(m) chain(n)` for `0 <= m <= n`
   - G-completeness: `G(alpha) not-in chain(s) -> exists r >= s, alpha not-in chain(r)`
   - G-contrapositive: `(forall r >= s, alpha in chain(r)) -> G(alpha) in chain(s)`
   - H mirrors
   - ~40-60 lines
   - ACHIEVABLE

6. **dovetail_history** (same file): WorldHistory from chain
   - ~20 lines, using canonical_task_frame's permissive task_rel
   - DEFINITELY achievable

7. **dovetail_omega** (same file): Set of histories through all modal-equivalents
   - `{time_shift(dovetail_history_v, Delta) | v ~ w, Delta in Int}`
   - Shift-closure proof: ~15 lines
   - Membership proof (dovetail_history_v in Omega): trivial
   - DEFINITELY achievable

8. **chain_truth_iff** (same file): Bidirectional truth lemma
   - By induction on phi, cases: atom, bot, imp, box, G, H
   - Each case ~15-30 lines
   - Total ~120-180 lines
   - ACHIEVABLE, the hardest part but all sub-cases verified above

9. **usf_completeness** restructured (CanonicalEmbedding.lean): Replace current proof
   - By contrapositive: not derivable -> MCS w with phi not-in w -> countermodel
   - Use chain_truth_iff backward: phi not-in w -> not (truth_at phi)
   - Contradicts h_valid
   - ~20-30 lines
   - DEFINITELY achievable once (8) is proved

### Total Estimated Size

| Component | Lines | Status |
|-----------|-------|--------|
| box_preserved_along_bx_le | 30 | New |
| bx_modal_equiv_of_bx_le | 5 | New |
| modal_omega_eq_along_chain | 5 | New |
| dovetail_chain definition | 70 | New |
| dovetail_chain properties | 50 | New |
| dovetail_history + omega | 40 | New |
| chain_truth_iff | 150 | New |
| usf_completeness restructured | 25 | Replace existing |
| **Total** | **~375** | |

### Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Dovetail chain definition complexity | Medium | Medium | Can use noncomputable + Classical.choice |
| G-contrapositive from dovetail | Low | High | This is the core property; design chain to ensure it |
| Box backward on dovetail Omega | Low | High | Verified in Section 11 using Delta = -s trick |
| respects_task for dovetail history | Low | Low | canonical_task_frame has permissive task_rel (d != 0 or w = u) |
| Interaction between box and G in truth lemma | Medium | Medium | Verified each case in Section 11 |

### Blockers and Unknowns

**DEFINITELY achievable**:
- Lemmas 1-3 (box preservation, modal equiv along bx_le)
- Lemma 6 (dovetail history as WorldHistory)
- Lemma 9 (restructured usf_completeness)

**ACHIEVABLE with care**:
- Lemma 4 (dovetail chain): needs well-founded recursion or explicit construction using Denumerable
- Lemma 5 (chain properties): needs careful proofs about the dovetail enumeration
- Lemma 8 (truth lemma): largest component, but each case is verified

**UNKNOWN / needs investigation**:
- Whether `Denumerable.ofNat` and `Denumerable.encode` are ergonomic enough for the dovetail
- Whether the dovetail chain can be defined via `Nat.rec` or needs `WellFounded.fix`
- Whether `noncomputable` suffices or if computability issues arise

### Zero-Debt Assessment

The architecture described above achieves zero sorries for the USF fragment. No sorry deferral, no new axioms, no placeholders. Every case of the truth lemma is verified in this report. The Until/Since cases remain separate sorries (in Frame.lean) and are explicitly out of scope for this task.
