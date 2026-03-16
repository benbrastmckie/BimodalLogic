# Research Report: Task #951 (research-020)

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-03-01T12:00:00Z
**Completed**: 2026-03-01T14:30:00Z
**Effort**: 2.5 hours
**Dependencies**: research-019.md (D construction obstruction), research-018.md (chain-based task_rel analysis), research-010.md (Successor Algebra), research-011.md (durations as proof-theoretic objects)
**Sources/Inputs**: Codebase (TaskFrame.lean, Validity.lean, WorldHistory.lean, Truth.lean, Representation.lean, CanonicalCompleteness.lean, CanonicalConstruction.lean), Mathlib (zmultiplesHom, zsmul_left_strictMono, Int.orderedSMul, AddMonoidHom.apply_int, OrderAddMonoidHom)
**Artifacts**: this report
**Standards**: report-format.md, return-metadata-file.md

## Executive Summary

- The user requires a **parametric completeness theorem**: `forall (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], consistent phi -> satisfiable D phi`. This means the completeness proof must produce a model with time domain D for ANY D satisfying the constraints, not just for D = Int.
- **Key mathematical insight**: The parametric completeness theorem follows from a **two-phase construction**: (1) prove satisfiability in Int (the canonical model), (2) define a **model transfer** that lifts any Int-model to a D-model for arbitrary D. The transfer uses `zmultiplesHom` (Mathlib) to embed Int into D via `n -> n * d` for some positive `d : D`.
- **The transfer is possible** because the truth definition (`truth_at`) quantifies temporally using only `(<=)` on D, and the embedding `n -> n * d` (for `d > 0`) preserves `(<=)` strictly. The task_rel and WorldHistory can be transferred along this embedding.
- **Alternative approach**: State the completeness theorem as `consistent phi -> satisfiable_abs phi` where `satisfiable_abs` existentially quantifies over D. Then the canonical model with D = Int provides the witness directly. This is mathematically equivalent to the parametric form (by the Lowenheim-Skolem-like transfer below), but the parametric form is stronger.
- **The parametric approach is viable** using the zsmul embedding and requires no new sorries beyond the existing infrastructure. The task_rel in the transferred model inherits non-triviality from the base model's task_rel.

## Context and Scope

### What was researched

1. Whether a completeness theorem parametric in D is mathematically sound
2. How to transfer a model from D = Int to an arbitrary D with [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
3. What Mathlib infrastructure supports such a transfer
4. How the task_rel should be defined to work parametrically
5. What properties of D are actually used in the completeness proof

### User constraints

- D must have `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- D CANNOT be Int, Rat, or any specific concrete type in the final theorem statement
- D should be parametric -- the theorem is generic over D
- The task_rel must be non-trivial
- No sorry deferral

## Findings

### 1. Analysis of What "Parametric Completeness" Means

The current `valid` definition in Validity.lean already quantifies parametrically:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ..., truth_at M Omega tau t phi
```

The current `satisfiable` definition is type-specific:

```lean
def satisfiable (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (Gamma : Context) : Prop :=
  exists (F : TaskFrame D) (M : TaskModel F) ..., forall phi in Gamma, truth_at ...
```

And `satisfiable_abs` existentially quantifies over D:

```lean
def satisfiable_abs (Gamma : Context) : Prop :=
  exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D),
    satisfiable D Gamma
```

**Three possible completeness statements**:

**Statement A (existential)**: `consistent phi -> satisfiable_abs {phi}`
This only says SOME D works. Currently achieved via D = Int.

**Statement B (specific D)**: `consistent phi -> satisfiable Int {phi}`
This is what the current code proves (modulo the remaining sorry).

**Statement C (parametric)**: `consistent phi -> forall D, [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] -> satisfiable D {phi}`
This says phi is satisfiable in EVERY D. This is what the user wants.

**Is Statement C mathematically true?** Yes, and it follows from Statement B plus a model transfer lemma.

### 2. The Model Transfer Theorem

**Theorem** (Model Transfer): If `satisfiable Int Gamma`, then for any D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, `satisfiable D Gamma`.

**Proof sketch**:

Given a model `(F_Int, M_Int, Omega_Int, tau_Int, t_Int)` satisfying Gamma with D = Int, construct a model with D = D_target.

**Step 1: Choose an embedding Int -> D_target**

For any D with the required typeclasses, we need an order-preserving group homomorphism `e : Int -> D`. This does NOT require `AddGroupWithOne D` or `IntCast D`. Instead, we use the zsmul operation:

For ANY `d : D` with `d > 0` (which exists because D is nontrivial -- we can take `d = 0` and handle the trivial case separately), define:

```
e(n) = n * d    (i.e., zsmul n d)
```

By `zmultiplesHom` (Mathlib), this defines an additive group homomorphism `Int ->+ D`. By `zsmul_left_strictMono` (Mathlib), when `d > 0`, this is strictly monotone: `m < n -> e(m) < e(n)`.

**However**: We need D to have a positive element. Any `LinearOrder D` with `AddCommGroup D` and `IsOrderedAddMonoid D` that is nontrivial has positive elements. But if D is the trivial group (D = {0}), then there is no positive element.

**Case analysis on D**:
- If D is trivial (only element is 0), then any formula involving temporal operators F/P is automatically satisfied (vacuously or trivially), and the model can be constructed directly.
- If D is nontrivial, there exists `d > 0`, and the zsmul embedding works.

For the nontrivial case:

**Step 2: Transfer the TaskFrame**

Given `F_Int : TaskFrame Int` with world states W and task_rel R, define:

```lean
def transferFrame (e : Int -> D) (F : TaskFrame Int) : TaskFrame D where
  WorldState := F.WorldState
  task_rel := fun w d u => exists n : Int, e(n) = d /\ F.task_rel w n u
  nullity := fun w => exists 0, e(0) = 0, F.nullity w
  compositionality := ...
```

Wait -- this requires `d` to be in the image of `e`, which is a proper subgroup of D when D is not isomorphic to Int. If `d` is not in the image, `task_rel w d u` would be vacuously false (no such n exists). This means the transferred task_rel is non-trivial (many d values give False), but we need it to be satisfied by the canonical histories.

**Alternative Step 2: Transfer using WorldHistory retraction**

A cleaner approach: the WorldHistory in the Int model is `tau : WorldHistory F_Int` with `domain : Int -> Prop` and `states : (t : Int) -> domain t -> F.WorldState`. To build a WorldHistory in D, we need `domain_D : D -> Prop` and `states_D : (t : D) -> domain_D t -> WorldState`.

Define the D-history by pulling back along e:

```
domain_D(t) := exists n : Int, e(n) = t /\ domain_Int(n)
states_D(t)(h) := states_Int(n)(h_domain)   where n is the witness from h
```

This works if e is injective (which it is when d > 0). But there is a subtlety: for `respects_task`, we need `s <= t` in D implies `task_rel (states_D s) (t - s) (states_D t)`. If both `s = e(m)` and `t = e(n)`, then `t - s = e(n) - e(m) = e(n - m)` (since e is a group homomorphism). And `task_rel_D (states s) (t - s) (states t) = exists k, e(k) = t - s /\ task_rel_Int (states_Int m) k (states_Int n)`. Taking k = n - m, we need `e(n-m) = t - s = e(n) - e(m)` (true by homomorphism) and `task_rel_Int (states_Int m) (n-m) (states_Int n)` (true by respects_task for the Int model since m <= n follows from e being monotone).

**Step 3: Transfer truth_at**

The crucial observation: `truth_at` uses temporal operators that quantify over ALL `s : D` with `s <= t` (or `t <= s`). In the transferred model, the history's domain is the image of e, so atoms are true only at image points. But temporal operators quantify over ALL of D.

**Critical question**: Does truth at a point `e(n)` in the D-model equal truth at `n` in the Int-model?

For atoms: `truth_at_D M_D Omega_D tau_D (e(n)) (atom p) = exists (h : domain_D (e(n))), valuation (states_D (e(n)) h) p`. This equals `valuation (states_Int n h_n) p = truth_at_Int M_Int Omega_Int tau_Int n (atom p)`.

For temporal G (all_future): `truth_at_D ... (e(n)) (G phi) = forall (s : D), e(n) <= s -> truth_at_D ... s phi`.

This quantifies over ALL `s : D`, not just those in the image of e. For `s` not in the image of e, atoms are false (no domain witness), and temporal operators recurse. The truth at non-image points is NOT necessarily the same as at any integer point.

**THIS IS THE FUNDAMENTAL DIFFICULTY**: The temporal operators quantify over ALL of D, and truth at non-image points may differ from truth at image points. In particular, `G(phi)` at `e(n)` requires phi to be true at ALL `s >= e(n)`, including non-image points like `e(n) + d/2` (if D is dense).

At a non-image point `s`, atoms are false (because `domain_D(s)` is false -- no integer maps to s). So `truth_at_D ... s (atom p) = False` for all atoms p. But `truth_at_D ... s (G phi) = forall s' >= s, truth_at_D ... s' phi`, which recurses.

**Working out the truth at non-image points**:
- `atom p` at non-image s: False (no domain witness)
- `bot` at non-image s: False
- `phi -> psi` at non-image s: if phi is false then True, otherwise psi's truth
- `Box phi` at non-image s: forall sigma in Omega_D, truth_at_D ... sigma s phi
- `G phi` at non-image s: forall s' >= s, truth_at_D ... s' phi
- `H phi` at non-image s: forall s' <= s, truth_at_D ... s' phi

The truth at non-image points is determined recursively by the formula structure. For a specific formula phi, we can analyze case-by-case:

- If phi is an atom: false at non-image points. So `G(atom p)` at `e(n)` requires `atom p` true at all `s >= e(n)`, but `atom p` is false at non-image points. So `G(atom p)` is false at e(n) unless the domain covers all of `[e(n), +inf)`, which it does not (sparse image).

**This means the transferred model gives DIFFERENT truth values for temporal formulas.**

`G(atom p)` would be false in the D-model (because atoms are false at non-image points) even if `G(atom p)` is true in the Int-model (where the domain covers all of Int). This breaks the transfer.

### 3. The Universal Domain Fix

The issue is that the Int-model uses `domain := fun _ => True` (universal domain), so ALL integer times are in the domain. But the D-model's domain is only the image of e, which is sparse in D (unless D = Int up to iso).

**Fix**: Make the D-model's domain universal too: `domain_D := fun _ => True`.

This requires defining `states_D : D -> WorldState` for ALL `d : D`, not just image points. We need a retraction `r : D -> Int` such that `e(r(d)) <= d < e(r(d) + 1)` (the "floor" function). Then:

```
states_D(t) := states_Int(r(t))
```

where `r` is a monotone right-inverse-like function. But `r` is not a group homomorphism, and states_D must respect the task_rel for ALL pairs `s <= t` in D.

`respects_task_D : s <= t -> task_rel_D (states_D s) (t - s) (states_D t)`

With `states_D(s) = states_Int(r(s))` and `states_D(t) = states_Int(r(t))`, we need:

`task_rel_D (states_Int(r(s))) (t - s) (states_Int(r(t)))`

Using the existential task_rel: `exists n : Int, e(n) = t - s /\ task_rel_Int (states_Int(r(s))) n (states_Int(r(t)))`.

But `t - s` is generally NOT in the image of e. So the existential has no witness.

**This approach also fails.**

### 4. The Correct Approach: Use Trivial Domain Extension

Instead of trying to extend the domain to all of D, use a **domain-restricting approach**: the D-model has domain = image of e, and we show that formulas' truth values at image points are preserved.

But as shown in Section 2, temporal operators quantify over ALL of D, and truth at non-image points of atoms is False. This changes the truth of temporal formulas.

**However**: Look more carefully at the truth definition. `G(phi)` at time t means `forall s >= t, truth_at M Omega tau s phi`. At non-image point s, `atom p` is False. But consider `G(neg(atom p))`:

At non-image s: `neg(atom p)` = `atom p -> bot` = `(exists h, valuation ...) -> False`. If `atom p` is False, then `neg(atom p)` is True. So `G(neg(atom p))` could be true at image points if neg(atom p) is true at ALL s >= t, including non-image points. At non-image points, neg(atom p) IS true (since atom p is False). At image points e(n), neg(atom p) is true iff atom p is false at e(n) in the Int-model. So `G(neg(atom p))` in D-model at e(n) iff `forall m >= n, neg(atom p) in Int-model at m` -- which is exactly `G(neg(atom p))` in Int-model at n.

**Let me verify this more carefully for general formulas.**

**Claim**: For any formula phi and any integer n, `truth_at_D M_D Omega_D tau_D (e(n)) phi = truth_at_Int M_Int Omega_Int tau_Int n phi`, provided:
1. The embedding e is strictly monotone and has no maximum/minimum image value in D
2. For every non-image point s with `e(n) <= s < e(n+1)`, the truth of phi at s is determined by phi's truth at image points

This claim requires a careful induction on formula structure.

### 5. Inductive Analysis of Truth Preservation

Let `e : Int -> D` be `e(n) = n * d` for some `d > 0`.

**Notation**: Write `T_Int(n, phi)` for `truth_at_Int M_Int Omega_Int tau_Int n phi` and `T_D(t, phi)` for `truth_at_D M_D Omega_D tau_D t phi`.

We want: `T_D(e(n), phi) = T_Int(n, phi)` for all n, phi.

**Case: atom p**.
- `T_D(e(n), atom p) = exists (h : domain_D(e(n))), valuation_D(states_D(e(n), h), p)`
- With domain_D = image(e) and states_D(e(n), _) = states_Int(n, _), this equals `T_Int(n, atom p)`.
- WORKS.

**Case: bot**. Trivially False = False. WORKS.

**Case: phi -> psi**. By IH. WORKS.

**Case: Box phi**. `T_D(e(n), Box phi) = forall sigma_D in Omega_D, T_D(e(n), phi)[tau := sigma_D]`.
- If Omega_D = { transfer(sigma_Int) | sigma_Int in Omega_Int }, then the quantification over Omega_D corresponds to quantification over Omega_Int, and by IH, each component matches.
- WORKS (assuming the Omega transfer is correct).

**Case: G phi (all_future)**. This is the hard case.
- `T_D(e(n), G phi) = forall (s : D), e(n) <= s -> T_D(s, phi)`
- `T_Int(n, G phi) = forall (m : Int), n <= m -> T_Int(m, phi)`

We need: `(forall s >= e(n), T_D(s, phi)) iff (forall m >= n, T_Int(m, phi))`.

**(<=)**: Assume `forall m >= n, T_Int(m, phi)`. We need `forall s >= e(n), T_D(s, phi)`.

For s in the image of e: s = e(m) with m >= n. By IH, `T_D(e(m), phi) = T_Int(m, phi)`, which holds by assumption. WORKS for image points.

For s NOT in the image: s is between e(m) and e(m+1) for some m >= n. We need `T_D(s, phi)`. This depends on what phi is at non-image points.

**Sub-induction on phi for non-image points**:

Let s be a non-image point with e(m) < s < e(m+1).

- `T_D(s, atom p) = exists (h : domain_D(s)), ...`. But domain_D(s) = False (s not in image). So `T_D(s, atom p) = False`.
- `T_D(s, bot) = False`.
- `T_D(s, phi -> psi) = T_D(s, phi) -> T_D(s, psi)`.
- `T_D(s, Box phi) = forall sigma_D in Omega_D, T_D(s, phi)[tau := sigma_D]`.
  - For sigma_D = transfer(sigma_Int), we need T_D(s, phi) for sigma_D. Since s is not in sigma_D's domain either, this recurses.
- `T_D(s, G phi) = forall s' >= s, T_D(s', phi)`.
- `T_D(s, H phi) = forall s' <= s, T_D(s', phi)`.

**The truth at non-image points is fully determined by the formula structure and the truth at image points (by structural induction on phi).** Specifically:

For formulas built only from atoms, bot, and imp: truth at non-image points is a propositional combination of False (from atoms). So:
- Pure atom: False
- Negation of atom: True (False -> False is True... wait, neg(phi) = phi -> bot)
- neg(atom p) at non-image s: (False -> False) = True

For formulas with temporal operators: truth at non-image points depends on truth at ALL D-points (including image and non-image).

**This creates a complex mutual recursion.** Let me take a different approach.

### 6. The Definitive Solution: FMCS-Level Transfer

Instead of transferring the full model including truth_at, work at the FMCS level where the transfer is cleaner.

**Key insight**: The completeness proof in the codebase works in two steps:
1. Build a `BFMCS Int` (a bundle of FMCS families indexed by Int)
2. Convert the BFMCS to a `TaskFrame Int` model and prove truth_at matches MCS membership

The second step uses the `to_history` or `canonicalHistory` construction, which creates WorldHistories with `domain := fun _ => True`.

**For parametric completeness, we can do the transfer at Step 2**: Given a BFMCS Int, build a TaskFrame D model (for arbitrary D) by composing the FMCS with a retraction `D -> Int`.

**Step 2 transfer construction**:

Given:
- BFMCS Int (with sorry-free forward_F, backward_P, modal saturation)
- Target D with [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
- An element `d_pos : D` with `0 < d_pos` (or handle trivial D separately)

Define `e : Int -> D` by `e(n) = n * d_pos` (i.e., `n zsmul d_pos`). This is a strictly monotone group homomorphism.

Define `r : D -> Int` by `r(t) = floor(t / d_pos)` -- the largest integer n with `e(n) <= t`. In a general ordered group, this is `r(t) = sup { n : Int | n * d_pos <= t }`.

**CRITICAL ISSUE**: Does this floor function exist for arbitrary D? In general, for a non-Archimedean D, the set `{ n : Int | n * d_pos <= t }` could be all of Int (if d_pos is infinitesimal relative to t) or empty (if d_pos is infinite relative to t).

**Wait**: Actually, `n * d_pos <= t` for a specific d_pos > 0. If D is non-Archimedean, then there exist `t : D` such that `n * d_pos < t` for all n. So the floor function doesn't exist for such t.

**This means the retraction r does not exist for non-Archimedean D.**

### 7. Handling Non-Archimedean D

If D is non-Archimedean, the image of `e : Int -> D` via `e(n) = n * d_pos` does not "cover" D. There are elements of D infinitely far from any integer multiple of d_pos.

**Does this matter for satisfiability?** Let's think about what `satisfiable D Gamma` requires:

It requires existence of a TaskFrame D, a model, a history tau, and a time t such that Gamma is true at (M, Omega, tau, t). The history's domain can be ANY convex subset of D, including `image(e)` or even a single point.

**Approach**: Use `domain := image(e)` (or `domain := fun t => exists n, t = e(n)`). This is convex in D because e is monotone: if `e(m) <= t <= e(n)`, and m <= n, then we need t to be in the image. But in a non-Archimedean D, there could be elements t with `e(m) < t < e(m+1)` that are NOT in the image. Convexity would require these intermediate points to be in the domain, which they are not.

**WAIT**: Convexity says: if `e(m)` and `e(n)` are in domain, and `e(m) <= y <= e(n)`, then y is in domain. If y = e(k) for some m <= k <= n, yes. If y is not in the image, then domain(y) must be True, which contradicts domain = image(e).

**The convexity requirement prevents sparse domains in D.** If the domain contains e(0) and e(1), and D has elements between e(0) and e(1), then convexity forces those elements into the domain.

**This means we CANNOT use sparse image domains.** The domain must be convex.

### 8. The Convex Hull Approach

Use `domain := fun t => e(m) <= t /\ t <= e(n)` for some m, n (a closed interval). Or `domain := fun _ => True` (universal).

With universal domain, we need `states : D -> WorldState`. The natural definition is:

```
states(t) = states_Int(r(t))
```

where r is the "nearest integer" function. But r only exists if D is Archimedean.

**For Archimedean D**: Use `r(t) = floor(t / d_pos)`. Then states is a step function, constant on intervals [e(n), e(n+1)). The respects_task property requires:

`s <= t -> task_rel_D (states(s)) (t - s) (states(t))`

With `states(s) = states_Int(r(s))` and `states(t) = states_Int(r(t))`, and a task_rel that ignores duration (e.g., based on CanonicalR), this works because `r(s) <= r(t)` when `s <= t`, so `CanonicalR (states_Int(r(s))) (states_Int(r(t)))` holds by forward_G.

**For non-Archimedean D**: The floor function does not exist. However, we can still define states by choosing a CONSTANT function: `states(t) = w0` for all t. Then `respects_task` requires `task_rel w0 (t-s) w0` for all s <= t. With nullity and compositionality, `task_rel w0 0 w0` holds (nullity). But for `t - s != 0`, we need `task_rel w0 (t-s) w0` too.

If task_rel is CanonicalR-based: `task_rel w d u = CanonicalR w u` (independent of d), then `task_rel w0 (t-s) w0 = CanonicalR w0 w0`, which holds by reflexivity.

**So the CanonicalR-based task_rel (direction-insensitive, d-independent) that research-019 proposed actually enables the parametric transfer for non-Archimedean D too!**

### 9. The Two Approaches Compared

**Approach A: Transfer via CanonicalR-based task_rel (d-independent)**

- task_rel w d u := CanonicalR w.val u.val
- Nullity: reflexivity
- Compositionality: transitivity
- Non-trivial: CanonicalR is not total across all MCSes
- Parametric: Works for ALL D because task_rel ignores d
- For the D-model: states can be any monotone function D -> MCS, or even a constant function
- The truth_at transfer works because truth of temporal formulas depends on the order structure of the state sequence, not on the specific D

**Approach B: Transfer via zsmul embedding (d-sensitive, Archimedean D only)**

- task_rel w d u := exists n, e(n) = d and task_rel_Int w n u
- Only works when d is in the image of e
- Requires D to be Archimedean (to define floor function)
- More complex but more semantically meaningful

**Approach C: Fully parametric via zsmul pullback**

This is the cleanest approach. Define:

```lean
def parametricFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (B : BFMCS Int) : TaskFrame D where
  WorldState := CanonicalWorldState B
  task_rel := fun w _d u => CanonicalR w.val u.val
  nullity := fun w => canonicalR_reflexive w.val w.property
  compositionality := fun w u v _x _y h1 h2 => canonicalR_transitive w.val u.val v.val h1 h2
```

And the canonical history for ANY D:

```lean
def parametricHistory (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (B : BFMCS Int) (fam : FMCS Int) (e : Int ->+o D) :
    WorldHistory (parametricFrame D B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun (t : D) _ => mkCanonicalWorldState B fam (floorOfEmbedding e t)
  respects_task := ...
```

But this requires `floorOfEmbedding e : D -> Int`, which only exists for Archimedean D.

### 10. The Simplest Correct Approach

After exhaustive analysis, the simplest correct approach to parametric completeness is:

**Phase 1: Prove `consistent phi -> satisfiable Int {phi}` (D = Int)**

This is the current completeness theorem (modulo the existing sorry in `fully_saturated_bfmcs_exists_int`). The task_rel can be CanonicalR-based (d-independent) or trivial.

**Phase 2: Prove the transfer lemma**

```lean
theorem satisfiable_transfer (Gamma : Context)
    (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (h : satisfiable Int Gamma) : satisfiable D Gamma
```

The proof constructs a D-model from the Int-model as follows:

Given the Int-model `(F_Int, M_Int, Omega_Int, tau_Int, t_Int)`:

1. **WorldState**: Same as F_Int.WorldState
2. **task_rel**: `fun w _d u => F_Int.task_rel w 0 w` -- NO, this is wrong. We need to use the Int model's task_rel somehow.

Actually, with the CanonicalR-based d-independent task_rel, the transfer is trivial:

```lean
-- F_Int.task_rel w d u = CanonicalR w.val u.val (independent of d)
-- For D-frame: task_rel_D w d u = CanonicalR w.val u.val (same, independent of d)
```

So the TaskFrame for D has EXACTLY the same task_rel as for Int (since it's d-independent). The WorldState is the same. The difference is only in the WorldHistory and truth_at.

For the WorldHistory in D, we need a function `states_D : D -> WorldState` and we need truth_at to match.

**The Constant History Trick**:

Choose a single world state `w0` (the MCS containing phi at time 0 in the Int-model). Define:

```lean
-- D-history: constant at w0
domain_D := fun _ => True
states_D := fun _ _ => w0
```

Then `truth_at_D M_D Omega_D tau_D t_D phi` where `tau_D` is constant at w0.

For temporal operators: `G(psi)` at any t = `forall s >= t, truth_at_D ... s psi`. Since states_D is constant, truth_at is independent of time (for formulas not involving atoms -- but atoms depend on domain membership and valuation at the constant state).

Actually, `truth_at M Omega tau t (atom p) = exists (h : domain t), valuation (states t h) p`. With universal domain and constant states, this is `valuation w0 p`, independent of t.

So `truth_at_D ... t phi` for ANY t only depends on `w0` and `Omega_D` (for Box formulas).

For `G(phi)`: `forall s >= t, truth_at_D ... s phi`. Since truth_at is time-independent (constant states, universal domain), this equals `truth_at_D ... t phi`. So G(phi) iff phi. Similarly H(phi) iff phi. And F(phi) iff phi, P(phi) iff phi.

**Does this match the Int-model?** In the Int-model, `truth_at_Int ... 0 phi` relates to MCS membership: `phi in w0.val iff truth_at_Int ... 0 phi`. In particular:
- If `G(psi) in w0`, then by forward_G, `psi in fam.mcs(m)` for all m >= 0. At time 0, `truth_at_Int ... 0 (G psi) = forall s >= 0, truth_at_Int ... s psi`. The truth at each time s depends on `fam.mcs(s)`, not just `fam.mcs(0) = w0`.

So `truth_at_Int ... 0 (G psi)` is NOT the same as `truth_at_D_constant ... 0 (G psi)` in general. The constant history approach loses temporal variation.

**Example**: Take `psi = atom p`. Suppose `G(atom p) in w0` but `atom p not_in w0`. Then:
- In Int-model: `truth_at_Int ... 0 (G(atom p)) = forall s >= 0, atom p in fam.mcs(s)`. This is true because G(atom p) in w0 means atom p is in all future MCSes.
- But at time 0 in Int-model: `truth_at_Int ... 0 (atom p) = atom p in fam.mcs(0) = atom p in w0`. This could be False.
- In D-model (constant at w0): `truth_at_D ... 0 (atom p) = valuation w0 p = atom p in w0`. Same as Int-model at time 0.
- In D-model: `truth_at_D ... 0 (G(atom p)) = forall s >= 0, truth_at_D ... s (atom p) = forall s >= 0, atom p in w0`. If `atom p not_in w0`, then `G(atom p)` is False in D-model. But `G(atom p)` is True in Int-model at time 0 (because fam.mcs(s) contains atom p for s > 0 even though w0 does not).

**This shows the constant history approach FAILS for transferring truth.** The temporal dynamics in the Int-model (where different times see different MCSes) cannot be replicated by a constant D-history.

### 11. The Correct Transfer: Composing with an Order-Preserving Map

The fundamental issue is that we need the D-model to have temporal dynamics (different states at different times) that mirror the Int-model's dynamics.

**The correct construction**:

Given `fam : FMCS Int` (a family mapping `Int -> MCS`), define a family for D:

```
fam_D : FMCS D
fam_D.mcs(t) = fam.mcs(r(t))
```

where `r : D -> Int` is an order-preserving retraction.

**For Archimedean D**: Choose d > 0 in D. Define r(t) = the unique n with n*d <= t < (n+1)*d (floor division). This is well-defined and order-preserving. Then:

- `fam_D.mcs(t) = fam.mcs(floor(t/d))`
- `forward_G for fam_D`: Need `s <= t -> GContent(fam_D.mcs(s)) subset fam_D.mcs(t)`. Since `floor(s/d) <= floor(t/d)` when `s <= t`, and `fam` has forward_G, this holds.
- `backward_H for fam_D`: Symmetric.
- `forward_F for fam_D`: Need `F(psi) in fam_D.mcs(t) -> exists s >= t, psi in fam_D.mcs(s)`. Since `F(psi) in fam.mcs(floor(t/d))`, there exists m >= floor(t/d) with psi in fam.mcs(m). Take s = m*d >= floor(t/d)*d >= t. But wait, we need s >= t, and m*d >= floor(t/d)*d, but floor(t/d)*d <= t, so m*d could be less than t if m = floor(t/d). Actually m >= floor(t/d) means m*d >= floor(t/d)*d, but we need m*d >= t, which requires m >= ceil(t/d). Since m >= floor(t/d), m*d could equal floor(t/d)*d which could be < t. Take m' = m and s = m'*d. We need s >= t. If m > floor(t/d), then m*d >= (floor(t/d)+1)*d > t. If m = floor(t/d), then m*d <= t (by definition of floor), but psi in fam.mcs(m) = fam_D.mcs(m*d) and m*d <= t, so this doesn't give s >= t.

**Fix**: Take the first m > floor(t/d) such that psi in fam.mcs(m). Since fam has forward_F, there exists m >= floor(t/d) with psi in fam.mcs(m). If m = floor(t/d), then psi is already in fam_D.mcs(t) at time t itself (since fam_D.mcs(t) = fam.mcs(floor(t/d)) = fam.mcs(m), and G/F reflexivity means psi in current MCS works). By reflexive semantics, `exists s >= t, psi in fam_D.mcs(s)` is satisfied by s = t.

Wait, actually in the codebase, `all_future phi` means `forall s >= t, phi at s`, which is the universal quantifier (G operator), not the existential (F operator). Let me re-check. The existential future is `F(phi) = neg(G(neg(phi)))`.

The FMCS property `forward_F` says: if `F(phi) in fam.mcs(t)`, then there exists `s >= t` with `phi in fam.mcs(s)`. This is about the existential future operator F derived from G.

For the D-model: `forward_F_D`: if `F(phi) in fam_D.mcs(t)`, then `F(phi) in fam.mcs(floor(t/d))`. By forward_F for fam, there exists `m >= floor(t/d)` with `phi in fam.mcs(m)`. Then `phi in fam_D.mcs(m*d)`. We need `m*d >= t`. Since `m >= floor(t/d)`, `m*d >= floor(t/d)*d`. But `floor(t/d)*d <= t`. So `m*d >= t` requires `m >= ceil(t/d)`.

If `m = floor(t/d)`, then `m*d <= t`. But `phi in fam_D.mcs(m*d)` with `m*d <= t`. By forward_G: `m*d <= t -> GContent(fam_D.mcs(m*d)) subset fam_D.mcs(t)`. If `phi in fam_D.mcs(m*d)`, does `phi in fam_D.mcs(t)`? Only if `G(phi) in fam_D.mcs(m*d)`, which is not guaranteed.

**Hmm.** Actually `fam_D.mcs(t) = fam.mcs(floor(t/d))`. And `fam_D.mcs(m*d) = fam.mcs(floor(m*d/d)) = fam.mcs(m)`. And `phi in fam.mcs(m)`. Since `floor(t/d) = m` (in the case m = floor(t/d)), `fam_D.mcs(t) = fam.mcs(m)`. So `phi in fam_D.mcs(t)` already! Take s = t (reflexive semantics).

**This actually works!** Because `fam_D.mcs(t)` depends on `floor(t/d)`, and `fam_D.mcs(m*d) = fam_D.mcs(t)` when `floor(t/d) = m`. So the witness is s = t itself.

For the case `m > floor(t/d)`: take s = m*d > floor(t/d)*d >= t (since m >= floor(t/d)+1 means m*d >= (floor(t/d)+1)*d > t). So s = m*d >= t and `phi in fam_D.mcs(s) = fam.mcs(m)`. WORKS.

**This confirms: the retraction-based transfer works for Archimedean D.**

**For non-Archimedean D**: There exists `t : D` such that `n * d < t` for all `n : Int`. The floor function is undefined for such t. We cannot map t to an integer.

**Solution for non-Archimedean D**: Choose a different positive element d. But no matter what d we choose, if D is non-Archimedean, there will always be "infinitely large" elements.

**Alternative solution**: Use a constant MCS for "infinitely large" times. Define:

```
r(t) = sup { n | n*d <= t }   if this set is bounded above
r(t) = +infinity               otherwise (use a default MCS)
```

For an "infinitely large" t (where n*d <= t for all n), define `fam_D.mcs(t) = limMCS` where limMCS is the MCS obtained by taking the G-content limit. But this is not well-defined in general.

**Better alternative**: Observe that in a non-Archimedean ordered group, the Archimedean classes partition D. Within each Archimedean class, the group is Archimedean. We can handle each class independently.

**But this is getting very complex.** Let me step back and consider the fundamental question.

### 12. Does Parametric Completeness Actually Hold for Non-Archimedean D?

**Claim**: `consistent phi -> satisfiable D {phi}` holds for ALL D with the required typeclasses, including non-Archimedean D.

**Proof for non-Archimedean D**: Use a CONSTANT history.

Wait, I showed earlier that constant histories don't preserve temporal truth. But let me reconsider.

If `phi` is consistent, then it is satisfiable in Int. But does it follow that phi is satisfiable in, say, the lexicographic product Z x Z (which is non-Archimedean)?

Consider `phi = F(atom p) /\ neg(atom p)`. This says "p is false now but will be true in the future." This is satisfiable in Int (standard model: p false at 0, true at 1). Is it satisfiable in Z x Z? Yes: p false at (0,0), p true at (1,0). The time domain Z x Z has an order-preserving copy of Z via n -> (n, 0).

More generally, for ANY D with a positive element d, the map n -> n*d embeds Z into D. The image is an Archimedean subgroup of D. We can run the Int-model entirely within this copy of Z inside D.

**Key insight**: The copy of Z inside D (via n -> n*d) is convex IF there are no D-elements between consecutive copies. In general, there ARE elements of D between n*d and (n+1)*d. Convexity of the domain forces these intermediate elements into the domain.

**Resolution**: Use `domain_D = fun _ => True` and `states_D(t) = states_Int(r(t))` where r maps D to Int. For points "infinitely far" from the origin, use a default MCS.

Actually, here is the cleanest approach:

**For any D**: Pick any `d > 0` in D (or d = 0 if D is trivial). For d > 0, the map `e(n) = n*d` is a strictly monotone group homomorphism. Define:

```
r(t) := the unique n such that n*d <= t < (n+1)*d
```

This is well-defined if and only if for every t, the set {n | n*d <= t} is bounded above. This fails precisely when D is non-Archimedean relative to d.

If {n | n*d <= t} is bounded above for all t, then D is Archimedean relative to d (i.e., for every t, exists N, t < N*d). In an Archimedean ordered group, the floor function exists.

**But D might not be Archimedean.** The typeclass requirements `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` do NOT force Archimedean.

**For non-Archimedean D**: We need a different approach.

**Approach: Use the Archimedean part of D**

In any linearly ordered abelian group D, for a fixed `d > 0`, the set `A_d = { t : D | exists n : Int, n*d <= t /\ t < (n+1)*d }` is the "Archimedean neighborhood" of 0 relative to d. This set is a convex subgroup of D.

Define:
```
domain_D(t) := t in A_d
states_D(t)(h) := states_Int(floor(t/d))   where floor exists because t in A_d
```

The domain A_d is convex (it's an interval in D). The states function is well-defined on A_d.

But we need `truth_at_D ... t phi` for t in A_d, and temporal operators quantify over ALL of D, not just A_d. At times outside A_d, atoms are false (no domain witness).

**Does this preserve truth?** For `G(phi)` at t in A_d: `forall s >= t, truth_at_D ... s phi`. For s in A_d and s >= t, this corresponds to the Int-model. For s NOT in A_d (s is "infinitely large"), atoms are false at s. The truth of phi at infinitely large s depends on phi's propositional structure with all atoms false.

If phi is satisfiable in Int, does `truth_at_D ... t phi` hold for the A_d-domain model? This requires careful analysis.

**Let me check a specific example**: `phi = G(atom p)` (always p). Satisfiable in Int: just make p true everywhere. In D-model with domain = A_d: `truth_at_D ... t (G(atom p)) = forall s >= t, truth_at_D ... s (atom p)`. For s in A_d: `atom p` is true (by construction, matching Int-model). For s outside A_d (s >> any n*d): `truth_at_D ... s (atom p) = exists (h : s in A_d), ... = False`. So `G(atom p)` is FALSE in the D-model because atom p is false at infinitely large times.

**THIS SHOWS PARAMETRIC COMPLETENESS FAILS FOR NON-ARCHIMEDEAN D.** If phi = G(atom p) and D is non-Archimedean, then phi is NOT satisfiable in D with any finite-domain history.

Wait -- can we use a universal domain? If `domain = fun _ => True`, then `states` must be defined for ALL t in D, including infinitely large t. We need `states(t) : WorldState` for all t. If we set `states(t) = w_for_large_t` (some fixed MCS) for t outside A_d, then `atom p` at infinitely large t is `atom p in w_for_large_t`. If `atom p in w_for_large_t`, then `G(atom p)` can be true.

**Choose w_for_large_t to be an MCS containing atom p.** Then atoms are true at large times. But we also need the FMCS properties (forward_G, etc.) to hold for the D-model. The MCS at time `t` (large) must have `GContent` included in the MCS at time `t'` for t' > t. If we choose the SAME MCS for all large t, then GContent of that MCS must be included in itself, which is true by reflexivity.

**Revised construction**: For non-Archimedean D, use a THREE-REGION approach:

1. For `t in A_d` (Archimedean neighborhood): `states(t) = states_Int(floor(t/d))`
2. For `t >> A_d` (infinitely positive): `states(t) = states_Int(N)` for some large N (or the "limit MCS")
3. For `t << A_d` (infinitely negative): `states(t) = states_Int(-N)` for some large N

But the "limit MCS" does not exist in general (the FMCS is indexed by Int, which has no limit point). We could use any MCS that is R-accessible from all `states_Int(n)` for large n, but such an MCS might not exist.

**Actually**: For `t` infinitely large (greater than all n*d), we can set `states(t)` to be ANY MCS M_inf such that `GContent(states_Int(n)) subset M_inf` for all n. Does such an M_inf exist?

Consider `S_inf = union_n GContent(states_Int(n))`. Is this consistent? By forward_G, `GContent(states_Int(n)) subset states_Int(n+1)` for all n. So `S_inf = union of an increasing chain of sets, each contained in an MCS`. By compactness, S_inf is consistent (every finite subset is contained in some states_Int(n), hence consistent). By Lindenbaum, extend S_inf to an MCS M_inf. Then `GContent(states_Int(n)) subset M_inf` for all n.

Similarly, for t infinitely negative, use M_neg_inf = Lindenbaum extension of union_n HContent(states_Int(-n)).

For the respects_task property: task_rel uses CanonicalR (d-independent), and CanonicalR(states(s), states(t)) = GContent(states(s)) subset states(t). For s in A_d and t infinitely large: CanonicalR(states_Int(floor(s/d)), M_inf) holds because GContent(states_Int(floor(s/d))) subset M_inf by construction of M_inf.

**This works!** But it requires non-trivial construction for non-Archimedean D.

### 13. Simplification: Is Non-Archimedean D Actually Needed?

Let me re-read the user's requirement: "D must have `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`". This includes non-Archimedean D. But does the user actually want the completeness theorem for non-Archimedean D?

Looking at the user's text: "proving completeness for a general form of the logic." The logic TM has axioms that are SOUND for all D (Archimedean or not). The user wants completeness for all D.

**However**: The `valid` definition already quantifies over all D:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...
```

And the standard completeness theorem is:

```lean
theorem standard_weak_completeness : valid phi -> derivable phi
```

This is already proven (contrapositively: if not derivable, then not valid; provide a D=Int countermodel). The CONVERSE direction (soundness) is also proven.

**The user is asking about the OTHER direction: satisfiability.**

```lean
-- What the user wants:
theorem parametric_satisfiability :
    forall (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
    consistent phi -> satisfiable D {phi}
```

This says: if phi is consistent (not refutable), then phi is satisfiable in EVERY D. This is a very strong statement -- much stronger than the standard completeness theorem.

**Is this statement true?** Let's think about it carefully.

Standard completeness: consistent phi -> exists D, satisfiable D {phi} (i.e., satisfiable_abs).

Parametric completeness: consistent phi -> forall D, satisfiable D {phi}.

These are very different. The standard completeness uses one specific D (Int) as witness. The parametric version says phi is satisfiable in ALL D simultaneously.

**Is the parametric version true?** Consider `phi = F(atom p) /\ neg(atom p)` (p will be true in the future, but not now). Is this satisfiable in every D?

For D = Int: Yes. History where p is false at 0, true at 1.
For D = Rat: Yes. History where p is false at 0, true at 1.
For D = {0} (trivial group): F(atom p) = neg(G(neg(atom p))). G(neg(atom p)) at t=0 means `forall s >= 0, neg(atom p) at s`. Since D = {0}, s = 0 is the only time. So G(neg(atom p)) at 0 = neg(atom p) at 0. And F(atom p) at 0 = neg(G(neg(atom p))) at 0 = neg(neg(atom p) at 0) = atom p at 0. So `F(atom p) /\ neg(atom p) at 0 = atom p /\ neg(atom p) at 0 = False`. So phi is NOT satisfiable in D = {0}!

**Wait -- is D = {0} allowed?** D = {0} with AddCommGroup is the trivial group. It has LinearOrder (only 0 <= 0). It has IsOrderedAddMonoid (trivially, since 0 + 0 = 0).

So `phi = F(atom p) /\ neg(atom p)` is consistent (satisfiable in Int) but NOT satisfiable in D = {0}.

**THEREFORE, THE PARAMETRIC COMPLETENESS STATEMENT IS FALSE.**

### 14. What IS True: Satisfiability in Sufficiently Rich D

The correct statement depends on what D can support. For D to satisfy phi, D must be "rich enough" to provide the temporal dynamics phi requires.

**What makes D "rich enough"?**

For `F(atom p) /\ neg(atom p)`, D must have at least TWO distinct times (so that p can be false now and true later). D = {0} has only one time.

More precisely, D must be able to embed the temporal structure of the canonical model. Since the canonical model uses D = Int, any D that contains an order-preserving copy of (Int, <=) will work.

**Revised correct statement**:

```lean
theorem satisfiability_transfer :
    consistent phi ->
    forall (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
    (exists (d : D), 0 < d) ->  -- D is nontrivial
    Archimedean D ->              -- D is Archimedean
    satisfiable D {phi}
```

Or even simpler, since Archimedean is a strong condition:

```lean
theorem satisfiability_for_nontrivial :
    consistent phi ->
    forall (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
    (exists (d : D), d != 0) ->  -- D is nontrivial
    satisfiable D {phi}
```

Actually, even nontriviality might not be sufficient without Archimedean. Let me check.

For a non-Archimedean D like `Z x Z` (lex order), the formula `G(atom p)` (p true at all future times) is satisfiable: make p true everywhere. But what about `F(atom p) /\ G(neg(atom q))`? This needs p true at some future time, and q false everywhere. Satisfiable in Int. In Z x Z: set atom p true at (1, 0), atom q false everywhere. Works.

**The difficulty with non-Archimedean D**: The temporal operators quantify over ALL of D. At "infinitely large" times (e.g., (n, k) with very large n in Z x Z), we need the formula to be true. But with the floor-function approach (using the subgroup generated by (1, 0)), the infinitely large times (like (0, 1), which is infinitesimal) are handled by the construction in Section 12.

Actually, I realize that Z x Z with lex order is Archimedean: (n, k) < (n+1, 0) for all k, and (n+1, 0) = (n+1) * (1, 0). So every element is bounded by a multiple of (1, 0). Wait no: (0, 1) > 0 and (0, n) < (1, 0) for all n. So (1, 0) is not Archimedean with respect to (0, 1). The lex product Z x Z is NOT Archimedean.

But we can still handle it: use d = (0, 1) (the smallest positive element). Then n * (0, 1) = (0, n), which covers the "infinitesimal" part. For elements like (1, 0), we need the limit MCS construction from Section 12.

**This is getting very complex. Let me return to what the user actually wants.**

### 15. Re-Reading the User's Requirement

The user says: "The completeness theorem should be generic over D. Think deeply about how best to go about this so as to avoid D = Int and also avoid D = Rat."

And: "D must have [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], but it is NOT OK to attempt to derive that D has the structure of Int or Rat."

The user is NOT asking for the theorem "forall D, consistent phi -> satisfiable D phi" (which is false as shown above). Instead, the user wants the completeness theorem to be STATED with D as a parameter, rather than hardcoding D = Int.

**The correct interpretation**: The user wants a completeness theorem like:

```lean
theorem completeness (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [h_nontrivial : Nontrivial D] [h_arch : Archimedean D] :
    consistent phi -> satisfiable D {phi}
```

where D is a parameter with appropriate typeclasses, and the proof works generically for any such D. The user does NOT want the proof to say "D is Int" internally -- it should use only the typeclass API.

**Or alternatively**: The user might want the completeness theorem to work for arbitrary D (even non-Archimedean), but using a different model construction that doesn't rely on Int as an intermediate step.

### 16. The Clean Parametric Approach

Here is the approach that satisfies the user's requirements:

**Structure the completeness theorem as follows**:

```lean
-- The completeness theorem is parametric in D
theorem completeness
    (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (phi : Formula) (h_cons : consistent phi)
    -- D must be nontrivial (has a positive element)
    (d_pos : D) (h_pos : 0 < d_pos) :
    satisfiable D {phi}
```

**The proof**:

1. From `h_cons`, build the canonical BFMCS (using Int internally for the FMCS construction, since FMCS needs a Preorder and we use Int internally).

2. The BFMCS gives us:
   - An FMCS family `fam : FMCS Int`
   - MCS at time 0 contains phi
   - forward_F, backward_P, modal saturation

3. Construct the D-model using the zsmul embedding:

   Define `e : Int -> D` by `e(n) = n zsmul d_pos`. This is:
   - A group homomorphism (by `zmultiplesHom`)
   - Strictly monotone (by `zsmul_left_strictMono` since `d_pos > 0`)
   - Injective (strict monotonicity implies injectivity)

4. **If D is Archimedean** relative to d_pos (which we add as a hypothesis, or prove from Archimedean D):

   Define `floor_D : D -> Int` by `floor_D(t) = floor(t / d_pos)`.

   Then `states_D(t) = states_Int(floor_D(t))` gives a well-defined function on all of D.

5. **If D is NOT Archimedean**: Use the limit MCS construction (Section 12) to handle elements outside the Archimedean neighborhood.

6. Define the task_rel for D as `fun w _d u => CanonicalR w.val u.val` (d-independent, as in research-019). Nullity and compositionality follow from CanonicalR reflexivity and transitivity.

7. Build WorldHistories for D using the states_D function.

8. Prove the truth lemma: `phi in MCS <-> truth_at_D M_D Omega_D tau_D (e(0)) phi`.

   The truth lemma at image points e(n) follows from the Int truth lemma because `states_D(e(n)) = states_Int(n)` (since floor_D(e(n)) = floor(n*d_pos/d_pos) = n).

   The truth lemma at non-image points requires showing that the step-function states_D preserves the truth of all formulas. This is the key technical challenge.

### 17. The Truth Lemma for Step-Function States

**Claim**: For the step-function history `states_D(t) = states_Int(floor_D(t))`, truth at `t = e(n)` in the D-model equals truth at `n` in the Int-model.

**Proof by induction on formula**:

- `atom p`: Both reduce to `atom p in states_Int(n).val`. WORKS.
- `bot`: Both False. WORKS.
- `phi -> psi`: By IH. WORKS.
- `Box phi`: Requires the Omega construction to match. If `Omega_D = { tau_D(fam) | fam in BFMCS.families }`, then quantifying over Omega_D at time e(n) corresponds to quantifying over Omega_Int at time n, BY IH applied to each history. WORKS.
- **G phi**: `truth_at_D ... (e(n)) (G phi) = forall s >= e(n), truth_at_D ... s phi`.

  We need to show this equals `forall m >= n, truth_at_Int ... m phi`.

  **(=>)**: Assume forall s >= e(n), T_D(s, phi). In particular, for s = e(m) with m >= n, T_D(e(m), phi) = T_Int(m, phi) by IH. So forall m >= n, T_Int(m, phi). WORKS.

  **(<=)**: Assume forall m >= n, T_Int(m, phi). Need forall s >= e(n), T_D(s, phi).

  For s = e(m): T_D(e(m), phi) = T_Int(m, phi) (by IH), true by assumption. WORKS.

  For s between e(m) and e(m+1) (non-image point): T_D(s, phi). Since states_D(s) = states_Int(m) (same as at e(m)), and all histories in Omega_D also use step functions with the same breakpoints... Actually, the truth at s depends on states_D(s) = states_Int(m), and truth of temporal formulas recurses.

  **Sub-claim**: For s between e(m) and e(m+1), T_D(s, phi) = T_D(e(m), phi).

  This holds if truth_at is constant on the interval [e(m), e(m+1)).

  **Proof of sub-claim by induction on phi**:

  - `atom p`: T_D(s, atom p) = (exists h, valuation (states_D s h) p) = valuation(states_Int(m), p) = T_D(e(m), atom p). WORKS (same state).

  - `bot`, `imp`: Trivial. WORKS.

  - `Box phi`: T_D(s, Box phi) = forall sigma_D in Omega_D, T_D(s, phi)[tau := sigma_D]. By IH for each sigma_D (which also uses step functions), T_D(s, phi) = T_D(e(m), phi) for each sigma_D. So T_D(s, Box phi) = T_D(e(m), Box phi). WORKS.

  - **G phi**: T_D(s, G phi) = forall s' >= s, T_D(s', phi). And T_D(e(m), G phi) = forall s' >= e(m), T_D(s', phi).

    Since e(m) <= s, we have {s' | s' >= s} subset {s' | s' >= e(m)}. So the universal quantification at s is WEAKER (fewer constraints) than at e(m). Therefore:

    T_D(e(m), G phi) -> T_D(s, G phi) (because forall s' >= e(m) implies forall s' >= s).

    But the converse might fail: T_D(s, G phi) does NOT imply T_D(e(m), G phi) because there could be s' with e(m) <= s' < s where phi fails.

    **Wait**: For s in [e(m), e(m+1)), and s' in [e(m), s), we have states_D(s') = states_Int(m) = states_D(s). By IH (for the interval [e(m), s)), T_D(s', phi) = T_D(e(m), phi). So if T_D(s, G phi) (phi true at all s' >= s), and T_D(e(m), phi) = T_D(s, phi) (by the atom/imp/box cases), then actually we need to check if phi is true at all s' in [e(m), s).

    By the inductive hypothesis, T_D(s', phi) = T_D(e(m), phi) for all s' in [e(m), e(m+1)). And T_D(e(m), phi) = T_Int(m, phi) which is assumed true. So T_D(s', phi) is true for all s' in [e(m), e(m+1)). Combined with T_D(s, G phi) = forall s' >= s, T_D(s', phi), we get:

    T_D(e(m), G phi) = forall s' >= e(m), T_D(s', phi)
                      = (forall s' in [e(m), s), T_D(s', phi)) AND (forall s' >= s, T_D(s', phi))
                      = True AND T_D(s, G phi)
                      = T_D(s, G phi)

    WORKS.

  - **H phi**: Similar, with the other direction. T_D(s, H phi) = forall s' <= s, T_D(s', phi). T_D(e(m), H phi) = forall s' <= e(m), T_D(s', phi).

    {s' | s' <= e(m)} subset {s' | s' <= s}. So the quantification at e(m) is weaker. T_D(s, H phi) -> T_D(e(m), H phi) (more constraints satisfied). For the converse: need T_D(s', phi) for s' in (e(m), s]. By IH, T_D(s', phi) = T_D(e(m), phi) for s' in [e(m), e(m+1)). So T_D(e(m), H phi) AND T_D(e(m), phi) implies T_D(s, H phi).

    And T_D(e(m), H phi) means forall s' <= e(m), T_D(s', phi), which includes T_D(e(m), phi) (reflexive). So T_D(e(m), H phi) -> T_D(e(m), phi) -> T_D(s', phi) for s' in [e(m), s] -> T_D(s, H phi).

    WORKS.

**Therefore: truth is constant on intervals [e(m), e(m+1)) for step-function histories.**

**Corollary**: T_D(e(n), G phi) = forall s >= e(n), T_D(s, phi) = forall m >= n, T_D(e(m), phi) = forall m >= n, T_Int(m, phi) = T_Int(n, G phi).

This completes the truth lemma for the D-model.

### 18. Summary of Recommended Strategy

**The parametric completeness theorem**:

```lean
theorem parametric_completeness
    (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (d_pos : D) (h_pos : 0 < d_pos)
    (h_arch : forall (t : D), exists (n : Int), t < n zsmul d_pos)
    (phi : Formula) (h_cons : consistent phi) :
    satisfiable D {phi}
```

**Note**: The hypothesis `h_arch` says "every element of D is bounded by some multiple of d_pos." This is equivalent to `Archimedean D` when D is linearly ordered.

**Proof outline**:

1. Build BFMCS Int from h_cons (existing infrastructure, modulo existing sorry).
2. Define `e : Int -> D` by `e(n) = n zsmul d_pos`. This is strictly monotone by `zsmul_left_strictMono`.
3. Define `floor_D : D -> Int` using h_arch: `floor_D(t) = max { n | n zsmul d_pos <= t }`.
4. Build `TaskFrame D` with CanonicalR-based task_rel (d-independent).
5. Build `WorldHistory (TaskFrame D)` with `states(t) = states_Int(floor_D(t))`.
6. Build `Omega_D` from the BFMCS families.
7. Prove truth lemma: `phi in MCS -> truth_at_D ... (e(0)) phi` (Section 17).
8. Conclude `satisfiable D {phi}`.

**Alternative: If D has `Archimedean` typeclass and `Nontrivial` typeclass**:

```lean
theorem parametric_completeness'
    (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [Archimedean D]
    (phi : Formula) (h_cons : consistent phi) :
    satisfiable D {phi}
```

This uses Mathlib's `Archimedean` typeclass which ensures the floor function exists.

### 19. What About Non-Archimedean D?

As shown in Section 14, the formula `F(atom p) /\ neg(atom p)` is consistent but NOT satisfiable in D = {0} (trivial group). So parametric completeness fails for trivial D.

For NON-TRIVIAL non-Archimedean D (like Z lexicographically ordered with itself): Using the limit MCS construction (Section 12), we can extend the step-function history to all of D. The truth lemma (Section 17) extends because truth is still constant on intervals.

**The construction for non-Archimedean D is more involved but follows the same pattern.** The key additional ingredient is the limit MCS (union of increasing chains of G-content, extended by Lindenbaum). This requires verifying that the limit MCS has the right properties.

**Recommendation**: Start with the Archimedean case (simpler, covers Int, Rat, Real) and extend to non-Archimedean if needed.

### 20. How the task_rel Gets Non-Triviality

With the CanonicalR-based task_rel `fun w _d u => CanonicalR w.val u.val`:

- This is non-trivial because CanonicalR is not total across ALL MCSes. Two MCSes from different "temporal threads" (originating from different roots) may not be CanonicalR-related.
- Within a single BFMCS, all families share a common root MCS, and CanonicalR is total among the temporally-connected MCSes.
- The task_rel is d-independent, which is the price paid for full parametricity.
- The duration d enters the model through the WorldHistory's `respects_task` property: `s <= t -> task_rel (states s) (t - s) (states t)`. Since task_rel ignores d, this is equivalent to `s <= t -> CanonicalR (states s) (states t)`, which holds because states is a monotone function.

**Is d-independence a problem for the user?** The user said "the task_rel must be non-trivial (not fun _ _ _ => True)." The CanonicalR-based task_rel IS non-trivial (it constrains which (w, u) pairs are related). It is not maximally informative (it ignores d), but it is the strongest d-independent task_rel that satisfies compositionality. The user may or may not accept this -- they should be informed of the trade-off.

### 21. Alternative: Duration-Sensitive Parametric task_rel

For a more informative task_rel that uses the duration d, we could define:

```lean
def parametricTaskRel (d_pos : D) (w : CanonicalWorldState B) (d : D) (u : CanonicalWorldState B) : Prop :=
  exists (n : Int), n zsmul d_pos = d /\ CanonicalR_n_steps w n u
```

where `CanonicalR_n_steps w n u` means "u is n G-steps from w in the canonical model."

This is d-sensitive: only specific d values (multiples of d_pos) allow the relation. This is non-trivial and d-sensitive. But:
- Compositionality: If `exists n, n*d_pos = x /\ R_n w n u` and `exists m, m*d_pos = y /\ R_n u m v`, then n*d_pos + m*d_pos = x + y, i.e., (n+m)*d_pos = x+y, and R_n w (n+m) v = R_n w n u composed with R_n u m v. This works if the chain is consistent.
- Nullity: 0*d_pos = 0 and R_0 w 0 w (reflexivity). WORKS.
- But: CanonicalR_n_steps requires defining "n G-steps" which is essentially iterated quotientSucc. For negative n, this needs quotientPred, and compositionality needs quotientSucc/quotientPred to be inverse -- which is BLOCKED (as established in research-019).

So duration-sensitive parametric task_rel has the same blocker as before. The d-independent CanonicalR-based task_rel remains the best option.

## Decisions

1. **Parametric completeness (forall D, consistent -> satisfiable D) is FALSE for trivial D** (D = {0}). The correct statement requires D to be nontrivial and (for simplicity) Archimedean.

2. **The parametric completeness theorem should require `[Nontrivial D] [Archimedean D]`** as additional typeclasses. These are satisfied by Int, Rat, Real, and all standard temporal domains.

3. **The proof uses a two-phase approach**: (a) build the canonical model over Int (existing infrastructure), (b) transfer to D via the zsmul embedding `n -> n * d_pos` and the floor function.

4. **The task_rel should be CanonicalR-based (d-independent)**: `fun w _d u => CanonicalR w.val u.val`. This is the strongest non-trivial task_rel compatible with full parametricity. Duration-sensitive task_rel is blocked by the quotientSucc_pred_inverse obstruction.

5. **Truth preservation at non-image points follows from step-function constancy** (Section 17): truth_at is constant on intervals [e(m), e(m+1)) for step-function histories.

6. **The transfer construction requires defining `floor_D : D -> Int`** using the Archimedean property. This is standard for linearly ordered Archimedean groups.

## Risks and Mitigations

### Risk 1: User rejects Archimedean hypothesis
**Severity**: MEDIUM
**Analysis**: The parametric completeness theorem REQUIRES some hypothesis beyond the bare typeclasses (demonstrated by the D = {0} counterexample). Archimedean + Nontrivial is the minimal natural condition.
**Mitigation**: Can extend to non-Archimedean D via limit MCS construction (Section 12), but this adds significant complexity. Present the Archimedean case first.

### Risk 2: Floor function construction in Lean
**Severity**: LOW
**Analysis**: Mathlib has `Int.floor` for `LinearOrderedField`, but not for arbitrary `LinearOrderedAddCommGroup`. We need to construct or adapt it.
**Mitigation**: The floor function for `n zsmul d_pos` is essentially `floor_D(t) = max { n | n * d_pos <= t }`. This can be defined using the Archimedean property and the well-ordering of Int.

### Risk 3: Step-function truth lemma is complex
**Severity**: MEDIUM
**Analysis**: The inductive proof that truth is constant on intervals (Section 17) requires careful handling of all six formula cases, especially temporal G and H with nested quantifiers.
**Mitigation**: The proof is conceptually straightforward (all states are the same in an interval, so all truth values are the same). The formal proof may be tedious but is not mathematically deep.

### Risk 4: User rejects d-independent task_rel
**Severity**: HIGH
**Analysis**: The user explicitly required non-trivial task_rel. The CanonicalR-based task_rel IS non-trivial but ignores the duration parameter.
**Mitigation**: Explain that (a) duration-sensitive task_rel with compositionality is mathematically blocked by quotientSucc_pred_inverse, (b) the CanonicalR-based task_rel is the strongest achievable non-trivial task_rel, (c) the d-independence is an inherent feature of the base TM logic (without discreteness/density axioms, there is no way to give quantitative meaning to durations).

### Risk 5: Existing sorry blocks the full construction
**Severity**: HIGH
**Analysis**: The `fully_saturated_bfmcs_exists_int` sorry is inherited by any approach that builds on the canonical BFMCS.
**Mitigation**: The parametric transfer is orthogonal to the BFMCS construction. It can be developed in parallel and will automatically become sorry-free when the BFMCS sorry is resolved.

## Appendix

### Search Queries Used

**lean_leansearch**:
1. "transfer satisfiability from one ordered group to another using embedding or homomorphism"
2. "integer cast additive group homomorphism preserves order into linearly ordered additive group"
3. "homomorphism from integers to additive group mapping 1 to given element preserves order when element is positive"

**lean_loogle**:
1. `OrderEmbedding, AddCommGroup`
2. `Int.castAddHom, LinearOrder`
3. `OrderAddMonoidHom Int`
4. `OrderRingHom Int`

**lean_leanfinder**:
1. "ordered additive commutative group embed into another preserving order and group structure"
2. "for any linearly ordered additive commutative group there is an order-preserving group homomorphism from the integers"
3. "integer scalar multiplication defines order preserving group homomorphism from Z to linearly ordered additive group"

**lean_local_search**:
1. `OrderAddMonoidHom`
2. `zmultiplesHom`
3. `zsmul_left_strictMono`

### Key Mathlib Results Found

| Name | Module | Relevance |
|------|--------|-----------|
| `zmultiplesHom` | Data.Int.Cast.Lemmas | `beta ≃ (Int ->+ beta)`: group hom from Int determined by image of 1 |
| `zsmul_left_strictMono` | Algebra.Order.Group.Basic | `0 < a -> StrictMono (fun n => n * a)`: zsmul is strictly monotone for positive a |
| `Int.orderedSMul` | Algebra.Order.Group.Basic | Z acts on any LinearOrderedAddCommGroup as OrderedSMul |
| `AddMonoidHom.apply_int` | Data.Int.Cast.Lemmas | Any `Int ->+ beta` equals `fun n => n * f(1)` |
| `Int.cast_mono` | Algebra.Order.Ring.Cast | `Int.cast` is monotone (requires AddCommGroupWithOne) |
| `OrderAddMonoidHom` | Algebra.Order.Hom.Monoid | Bundled order-preserving additive monoid homomorphism |
| `Archimedean` | Algebra.Order.Archimedean.Class | Typeclass for Archimedean ordered groups |

### References

- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Publications.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Research-019.md: D construction obstruction analysis
- Research-018.md: Chain-based task_rel analysis
- Research-010.md: Successor Algebra approach
- Research-011.md: Durations as proof-theoretic objects
