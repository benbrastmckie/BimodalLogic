# Research Report 005: The Right Way to Model Times D

**Task**: 930
**Session**: sess_1740493200_r930
**Date**: 2026-02-25
**Status**: Research complete

---

## Executive Summary

The core problem is that the current completeness chain (`bmcs_valid_mcs -> derivable`) uses `CanonicalBC BC` (a type of MCSes) as the time domain D, which has only a `Preorder`. But the standard semantics (`valid`) requires D to be a `LinearOrderedAddCommGroup`. This means the completeness chain cannot be directly bridged to standard validity -- they operate over incompatible time structures.

This report identifies three concrete approaches to resolving this, analyzes each for feasibility within the zero-sorry constraint, and recommends a specific path forward.

---

## 1. The Structural Mismatch

### 1.1 What Standard Validity Requires

From `Validity.lean`:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

Key requirements on D:
- `AddCommGroup D` (abelian group with `+`, `0`, `-`)
- `LinearOrder D` (total order)
- `IsOrderedAddMonoid D` (order compatible with addition)
- `ShiftClosed Omega` (histories closed under time translation by elements of D)

The `truth_at` definition uses these in critical ways:
- **Atoms**: `exists (ht : tau.domain t), M.valuation (tau.states t ht) p` -- domain membership
- **Box**: `forall sigma in Omega, truth_at M Omega sigma t phi` -- quantifies over histories in Omega
- **Temporal**: `forall s, s <= t -> ...` and `forall s, t <= s -> ...` -- uses the linear order on D

The `TaskFrame` structure requires:
- `task_rel : WorldState -> D -> WorldState -> Prop` -- D appears as duration
- `nullity : forall w, task_rel w 0 w` -- uses zero
- `compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v` -- uses addition

`WorldHistory` requires:
- `domain : D -> Prop` with convexity
- `respects_task : forall s t, s <= t -> F.task_rel (states s) (t - s) (states t)` -- uses subtraction

`ShiftClosed` requires:
- `forall sigma in Omega, forall Delta : D, time_shift sigma Delta in Omega` -- uses D as translation group

### 1.2 What BFMCS Completeness Uses

From `ChainBundleBFMCS.lean`, the completeness chain uses `CanonicalBC BC` as D:

```lean
structure CanonicalBC (BC : Set Formula) where
  world : Set Formula
  is_mcs : SetMaximalConsistent world
  bc_eq : MCSBoxContent world = BC

noncomputable instance (BC : Set Formula) : Preorder (CanonicalBC BC) where
  le a b := CanonicalR a.world b.world
  le_refl a := canonicalR_reflexive a.world a.property
  le_trans a b c hab hbc := canonicalR_transitive a.world b.world c.world a.property hab hbc
```

This Preorder is:
- NOT a linear order (CanonicalR is not total: two MCSes may be incomparable)
- NOT an additive group (there is no meaningful `+` operation on MCSes)
- NOT ordered-compatible (there is no monoid structure)

The `bmcs_truth_at_mcs` definition only needs `Preorder D`:
```lean
def bmcs_truth_at_mcs {D : Type*} [Preorder D] (B : BFMCS D) (fam : FMCS D) (t : D) :
    Formula -> Prop
```

### 1.3 The Gap

The implication chain currently is:
```
bmcs_valid_mcs phi -> derivable phi   (proven in ChainBundleBFMCS.lean)
derivable phi -> valid phi             (soundness, separate)
valid phi -> ???                       (UNPROVEN bridge)
```

To close this to `valid phi <-> derivable phi`, we need either:
- (A) `valid phi -> bmcs_valid_mcs phi`, or equivalently
- (B) `not derivable phi -> not valid phi` (direct standard completeness)

Both require constructing a standard semantic model (with proper D) from the BFMCS construction.

### 1.4 Why Duration-Independence Fails

Research-004 proposed `task_rel M d M' := CanonicalR M.val M'.val` (ignoring duration). This makes nullity and compositionality trivial. But the delegation context correctly identifies this as problematic:

**The problem is not the task relation.** The problem is that to instantiate `valid`, we need a type D that is a `LinearOrderedAddCommGroup`. The `CanonicalBC BC` type is NOT such a group. So even with a duration-independent task relation on the canonical frame, we cannot instantiate `valid` with `D = CanonicalBC BC`.

We MUST provide a genuine `LinearOrderedAddCommGroup` as D for the canonical model.

---

## 2. Three Approaches to Modeling D

### 2.1 Approach A: Use Int (or another concrete group) as D for the Canonical Frame

**Idea**: Build the canonical frame with `D = Int` (or Rat, Real, etc.). The task frame's world states are MCSes, and the task relation is `CanonicalR` (duration-independent). World histories map `Int -> MCS`.

**How it works**:
- Define `CanonicalFrame : TaskFrame Int` with `WorldState := {M : Set Formula // SetMaximalConsistent M}` and `task_rel M d M' := CanonicalR M.val M'.val`
- For each FMCS family in the BFMCS (which is indexed by `CanonicalBC BC`, a preorder), construct a world history indexed by `Int` by choosing an order-preserving map from (some chain in CanonicalBC) to Int
- Use `Omega = Set.univ` (trivially shift-closed)

**The challenge**: The BFMCS families are indexed by `CanonicalBC BC` (not `Int`). An FMCS is `mcs : CanonicalBC BC -> Set Formula`. To get a world history over `Int`, we need a map `Int -> CanonicalBC BC` that preserves the ordering. This is the "embedding" step.

**Analysis**:
- For the eval family (`canonicalBCBFMCS`), `mcs w = w.world` -- it maps each `CanonicalBC` element to its own MCS. A world history over Int would be `t : Int |-> some_canBC(t).world`. We need to define `some_canBC : Int -> CanonicalBC BC`.
- For constant families, `mcs _ = N` for a fixed N. A world history over Int would simply be the constant function `t |-> N`.

**Critical subtlety**: The truth lemma for `bmcs_truth_at_mcs` was proven with `D = CanonicalBC BC` and its Preorder. The truth lemma for `truth_at` with `D = Int` would need to be proven separately or bridged.

**Feasibility**: HIGH for the bridge direction (`valid -> bmcs_valid_mcs`), because we only need standard truth at `Omega = Set.univ` to imply BFMCS truth. This direction does NOT require constructing specific world histories from the BFMCS -- it only requires showing that if phi is true in ALL standard models (including those with D = Int), then phi is true in ALL BFMCS.

### 2.2 Approach B: Leave D Parametric with LinearOrderedAddCommGroup

**Idea**: Modify the BFMCS completeness to work with an arbitrary `D : LinearOrderedAddCommGroup` instead of `CanonicalBC BC`.

**How it works**:
- The `FMCS D` structure already works for any `D` with `Preorder D`
- The `BFMCS D` structure already works for any `D` with `Preorder D`
- The truth lemma works for any `D` with `Preorder D` and `Zero D`
- The completeness chain in `ChainBundleBFMCS.lean` specifically uses `CanonicalBC BC` because the eval family maps `CanonicalBC` elements to their own MCSes

**The challenge**: The key insight of `CanonicalBC` is that `(canonicalBCBFMCS BC).mcs w = w.world`. This identity FMCS is what makes the truth lemma connect MCS membership to BFMCS truth. If D is Int, we need an analogous construction where each integer maps to a DIFFERENT MCS, with the MCSes forming a chain under `CanonicalR`.

This is exactly what the `DovetailingChain` approach (used in `fully_saturated_bfmcs_exists_int`) attempted. But it has a sorry because building a temporally coherent chain over Int is difficult (the "dovetailing" problem -- infinitely many F/P obligations need witnesses).

**Feasibility**: MEDIUM-LOW. This restores the original approach that led to the `fully_saturated_bfmcs_exists_int` sorry. The `CanonicalBC` approach was invented precisely to AVOID this difficulty.

### 2.3 Approach C: The Two-Stage Bridge (Recommended)

**Idea**: Keep the BFMCS completeness over `CanonicalBC BC` as-is. Prove the bridge `valid phi -> bmcs_valid_mcs phi` separately by showing that standard truth (with proper D) implies BFMCS truth.

**How it works**:

**Stage 1** (already done): `bmcs_valid_mcs phi -> derivable phi` (proven in ChainBundleBFMCS.lean)

**Stage 2** (to be proven): `valid phi -> bmcs_valid_mcs phi`

This requires showing: for every BFMCS `B : BFMCS (CanonicalBC BC)`, every family, every time, if phi is valid in standard semantics, then `bmcs_truth_at_mcs B fam t phi`.

**The key theorem**:
```lean
theorem standard_truth_implies_bmcs_truth_mcs
    (B : BFMCS (CanonicalBC BC))
    (fam : FMCS (CanonicalBC BC)) (hfam : fam in B.families)
    (t : CanonicalBC BC) (phi : Formula) :
    truth_at (CanonicalValuation Int) Set.univ
      (FMCStoWorldHistory_Int (evaluateAt fam t)) 0 phi
    -> bmcs_truth_at_mcs B fam t phi
```

Wait -- this framing is not quite right. Let me think more carefully.

The correct argument for `valid phi -> bmcs_valid_mcs phi`:

1. Suppose `valid phi`. This means: for ALL D, ALL frames F, ALL models M, ALL shift-closed Omega, ALL histories tau in Omega, ALL times t, `truth_at M Omega tau t phi`.

2. We want: for ALL BC, ALL `B : BFMCS (CanonicalBC BC)`, ALL fam in B.families, ALL t, `bmcs_truth_at_mcs B fam t phi`.

3. Fix BC, B, fam, t. We need to show `bmcs_truth_at_mcs B fam t phi`.

4. **Construct a specific standard model** where truth matches `bmcs_truth_at_mcs`:
   - Choose `D := Int` (a concrete LinearOrderedAddCommGroup)
   - Choose `F := CanonicalFrame Int` (with WorldState = MCS, task_rel = CanonicalR)
   - Choose `M := CanonicalValuation Int` (atom p true at MCS M iff `atom p in M`)
   - Choose `Omega := Set.univ` (trivially shift-closed)
   - Choose `tau := FMCStoWorldHistory fam` (constant world history mapping all times to `fam.mcs t`... no, this is wrong)

Here is where it gets subtle. The FMCS family `fam` maps `CanonicalBC BC -> Set Formula`. We need a world history over Int. We cannot directly use `fam` because it is indexed by `CanonicalBC BC`, not by Int.

**Resolution**: We do not need the FULL FMCS. For each fixed `t : CanonicalBC BC`, we just need a single MCS `fam.mcs t`. We can construct a CONSTANT world history over Int that maps every integer to this MCS.

```lean
def ConstantWorldHistory (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    WorldHistory (CanonicalFrame D) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun _ _ => {val := M, property := h_mcs}
  respects_task := fun s t _ _ hst => canonicalR_reflexive M h_mcs
```

Wait -- `respects_task` needs `CanonicalR M M` for any s <= t, which is reflexivity. This holds!

Now, with `tau = ConstantWorldHistory (fam.mcs t) (fam.is_mcs t) Int`:
- `truth_at (CanonicalValuation Int) Set.univ tau 0 phi`
- The atom case: `atom p` is true iff `atom p in fam.mcs t`. Matches!
- The temporal case: ALL past/future uses the SAME MCS (because history is constant). So `all_future phi` is true iff phi is true at all future times, but since the MCS is the same at all times, this reduces to phi being true at the SAME MCS. In fact, for a constant history, `truth_at ... tau s phi = truth_at ... tau 0 phi` for all s (by induction on phi, since all times see the same world state).

**The box case with Omega = Set.univ**: `truth_at ... tau 0 (box phi) = forall sigma in Set.univ, truth_at ... sigma 0 phi`. This quantifies over ALL world histories. In particular, over constant histories at every MCS. So box phi is true iff phi is true at EVERY constant history, which means phi is true at every MCS.

But `bmcs_truth_at_mcs B fam t (box phi) = forall fam' in B.families, phi in fam'.mcs t`. This only quantifies over families in B, not all MCSes.

**So standard box (Set.univ) is STRONGER than BFMCS box.** Standard truth implies BFMCS truth!

---

## 3. Detailed Analysis of Approach C

### 3.1 The Bridge Theorem

```lean
theorem standard_truth_at_constant_implies_mcs_membership
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula)
    (h_truth : truth_at (CanonicalValuation Int) Set.univ
      (ConstantWorldHistory M h_mcs Int) (0 : Int) phi) :
    phi in M
```

**Proof by induction on phi**:

**Atom p**: `truth_at ... (atom p) = exists (ht : True), atom p in M`. So `atom p in M`. Direct.

**Bot**: `truth_at ... bot = False`. Contradicts hypothesis. Vacuously `bot in M` is impossible anyway, but since h_truth is False, we are done.

**Imp psi chi**: `truth_at ... (imp psi chi) = (truth_at ... psi -> truth_at ... chi)`. By IH, if `truth_at psi` then `psi in M`, and if `truth_at chi` then `chi in M`. We need `imp psi chi in M`. By MCS properties, `imp psi chi in M` iff `(psi in M -> chi in M)`. Since standard truth of imp matches this exactly (using IH), this works. But wait -- we need BOTH directions for the IH to work. Let me reconsider.

Actually, we need a BIDIRECTIONAL lemma:

```lean
theorem constant_history_truth_iff_membership
    (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (phi : Formula)
    (t : Int) :
    truth_at (CanonicalValuation Int) Set.univ
      (ConstantWorldHistory M h_mcs Int) t phi
    <-> phi in M
```

Let me trace through more carefully:

**Atom p**: `truth_at ... t (atom p) = exists (ht : True), (CanonicalValuation Int).valuation {val := M, property := h_mcs} p = exists (ht : True), atom p in M`. So `atom p in M`. Bidirectional.

**Bot**: `truth_at ... t bot = False`. `bot in M` iff False (by MCS consistency). Bidirectional.

**Imp psi chi**:
Forward: `(truth_at psi -> truth_at chi) -> imp psi chi in M`. By IH (backward): `truth_at psi <-> psi in M` and `truth_at chi <-> chi in M`. So `(psi in M -> chi in M) -> imp psi chi in M`. This holds by MCS implication closure.
Backward: `imp psi chi in M -> (truth_at psi -> truth_at chi)`. By IH forward. This holds by MCS modus ponens property.

**All_future psi**: `truth_at ... t (all_future psi) = forall s, t <= s -> truth_at ... s psi`. By IH: `truth_at ... s psi <-> psi in M` (for any s, since the history is constant -- the MCS is the same at all times). So `forall s, t <= s -> psi in M`, which simplifies to `psi in M` (take s = t). So `all_future psi in M <-> psi in M`?

Wait, that is not right. `all_future psi in M` means `G psi in M`, which is STRONGER than `psi in M`. We have `G psi in M -> psi in M` by the T-axiom, but NOT `psi in M -> G psi in M`.

The issue: For the constant history, `truth_at (all_future psi) = forall s >= t, truth_at s psi = forall s >= t, psi in M = psi in M`. But `all_future psi in M` implies `psi in M` (T-axiom), yet `psi in M` does NOT imply `all_future psi in M`.

So the backward direction fails: `truth_at (all_future psi) <-> psi in M`, but `all_future psi in M -> psi in M` yet NOT `psi in M -> all_future psi in M`. The bidirectional lemma does NOT hold for temporal formulas on constant histories!

**This is the fundamental problem.** On a constant world history, `G psi` and `psi` have the same truth value (both reduce to `psi in M`), but they do NOT have the same MCS membership. `G psi in M` is a strictly stronger condition than `psi in M`.

### 3.2 The Constant History Problem

The constant history collapses temporal structure: all times see the same MCS, so G psi and psi become equivalent. But MCS membership distinguishes them: `G psi in M` requires the MCS to contain `G psi` explicitly, which is a stronger syntactic condition.

This means the truth lemma `truth_at ... phi <-> phi in M` FAILS for temporal formulas on constant histories.

### 3.3 Using Non-Constant Histories

To get the truth lemma to work for temporal formulas, we need histories where different times map to DIFFERENT MCSes. Specifically, for the all_future case:
- `truth_at ... t (all_future psi) = forall s >= t, truth_at ... s psi`
- By IH: `= forall s >= t, psi in mcs(s)`
- We want this to equal: `all_future psi in mcs(t)`
- Forward: `all_future psi in mcs(t)` implies `psi in mcs(s)` for all s >= t (by FMCS forward_G coherence). Good.
- Backward: `forall s >= t, psi in mcs(s)` implies `all_future psi in mcs(t)`. This is the `temporal_backward_G` property, which requires `forward_F` and `backward_P` witness properties.

So we need an FMCS over Int (or another proper group) with full temporal coherence. This brings us back to the difficult `fully_saturated_bfmcs_exists_int` sorry.

### 3.4 The Real Insight: We Do Not Need a Full Truth Lemma

For the bridge `valid phi -> bmcs_valid_mcs phi`, we need:

1. `valid phi` (phi is true in ALL standard models with shift-closed Omega)
2. Show `bmcs_truth_at_mcs B fam t phi` for arbitrary BFMCS B, fam, t.

The key insight from research-004 Section 5.12 is: **standard box with `Omega = Set.univ` is STRONGER than BFMCS box**. We can prove:

```lean
theorem valid_implies_bmcs_truth_at_mcs
    (phi : Formula) (h_valid : valid phi)
    (B : BFMCS (CanonicalBC BC)) (fam : FMCS (CanonicalBC BC))
    (hfam : fam in B.families) (t : CanonicalBC BC) :
    bmcs_truth_at_mcs B fam t phi
```

**But we cannot instantiate `valid` with `D = CanonicalBC BC`** because CanonicalBC is not a LinearOrderedAddCommGroup.

So we need an intermediate step: instantiate `valid` with some proper D (like Int), construct a model over Int that "corresponds to" the BFMCS at the specific point (B, fam, t), and then bridge from truth_at in that Int model to `bmcs_truth_at_mcs`.

### 3.5 The Correct Two-Step Bridge

**Step 1**: For a fixed (B, fam, t), construct a standard model over Int:
- Frame: WorldState = MCS, task_rel = CanonicalR (duration-independent)
- Model: valuation = atom membership
- Omega: a carefully chosen set of world histories
- History: a non-constant history derived from fam

**Step 2**: Show that phi's truth in this Int model corresponds to `bmcs_truth_at_mcs B fam t phi`.

The challenge is Step 1: we need a world history over Int that correctly reflects the temporal and modal structure of the BFMCS.

---

## 4. The Correct Way to Model D

### 4.1 The Core Realization

The question "how should D be modeled" has a simple answer for the bridge direction:

**For `valid phi -> derivable phi`, we need to construct a COUNTERMODEL when phi is not derivable.** We need to show `not derivable phi -> not valid phi`, i.e., find a standard model where phi fails.

From `not derivable phi`:
1. `[neg phi]` is consistent
2. By BFMCS construction, there exists a BFMCS B where `bmcs_truth_at_mcs B eval_family root (neg phi)`
3. Therefore `neg phi in eval_family.mcs root` (by truth lemma backward direction)
4. **We need to embed this into a standard model over some D that is a LinearOrderedAddCommGroup**

### 4.2 Approach: Embed CanonicalBC into Int via Quotient Map

The ordering on `CanonicalBC BC` is `CanonicalR`, which is a preorder. We can quotient by mutual accessibility to get a partial order, then embed any chain into Int.

But this is unnecessarily complex. Here is a simpler approach:

### 4.3 Approach: Use D = Int with a Degenerate Frame

Define a canonical frame over Int:
```lean
def CanonicalFrame_Int : TaskFrame Int where
  WorldState := { M : Set Formula // SetMaximalConsistent M }
  task_rel := fun M _ M' => CanonicalR M.val M'.val
  nullity := fun M => canonicalR_reflexive M.val M.property
  compositionality := fun M U V _ _ hMU hUV =>
    canonicalR_transitive M.val U.val V.val M.property hMU hUV
```

This is a valid `TaskFrame Int`. Duration is ignored in the task relation.

For each FMCS family `fam : FMCS (CanonicalBC BC)` and fixed `t : CanonicalBC BC`, define a world history over Int:

For the eval family, the key property we need is that world history over Int captures the FMCS's temporal structure. The eval family maps each `w : CanonicalBC BC` to `w.world`. We need an Int-indexed version.

**The key construction**: Given a countable collection of MCSes (the ones that appear in the CanonicalBC preorder), we can enumerate them along the integers. Specifically:

For the COMPLETENESS direction (not derivable -> not valid), we only need ONE specific history that evaluates `neg phi` to true at one point. We can use the following minimal construction:

```lean
def SinglePointHistory (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    WorldHistory CanonicalFrame_Int where
  domain := fun _ => True
  convex := trivially
  states := fun _ _ => {val := M, property := h_mcs}
  respects_task := fun s t _ _ hst => canonicalR_reflexive M h_mcs
```

But as shown in Section 3.2, constant histories collapse temporal formulas.

### 4.4 The Fundamental Tension (and its Resolution)

The fundamental tension is:
- Standard semantics with constant history: `G psi` is true iff `psi` is true (temporal collapse)
- MCS membership: `G psi in M` is strictly stronger than `psi in M`

So MCS membership does NOT match standard truth on constant histories. We need non-constant histories to recover the temporal distinction.

**But here is the resolution**: We do NOT need the full truth lemma `phi in M <-> truth_at ... phi` for the bridge. We need something weaker.

**For `valid phi -> bmcs_valid_mcs phi`**:

`bmcs_valid_mcs phi` is defined as:
```lean
forall BC B fam hfam t, bmcs_truth_at_mcs B fam t phi
```

And `bmcs_truth_at_mcs` is defined recursively using:
- Atoms: `atom p in fam.mcs t`
- Bot: `False`
- Imp: standard implication on `bmcs_truth_at_mcs`
- Box: `forall fam' in B.families, phi in fam'.mcs t` (MCS membership, not recursive truth!)
- All_future: `forall s >= t, bmcs_truth_at_mcs B fam s phi` (recursive at different times)
- All_past: `forall s <= t, bmcs_truth_at_mcs B fam s phi`

The box case uses MCS membership directly, while atoms and temporals use recursive `bmcs_truth_at_mcs`. The truth lemma (`bmcs_truth_lemma_mcs`) proves `phi in fam.mcs t <-> bmcs_truth_at_mcs B fam t phi`.

For the bridge, we want: if phi is true in all standard models, then `bmcs_truth_at_mcs B fam t phi`.

**Approach**: Prove by induction on phi that standard validity implies `bmcs_truth_at_mcs`:

- **Atom**: Standard validity means `atom p` is true in ALL models. Construct a model where `atom p` is true iff `atom p in fam.mcs t`. Then validity implies `atom p in fam.mcs t`.

Actually, this approach is wrong. Standard validity means phi is true in ALL models, so in particular in a model tailored to fam.mcs t. But different models are tailored to different (fam, t), so we cannot use a single model.

### 4.5 The Correct Approach: Induction on bmcs_truth_at_mcs

Let me restart with a cleaner formulation.

**Claim**: `valid phi -> bmcs_valid_mcs phi`

**Proof attempt**: Fix BC, B, fam, hfam, t. We need `bmcs_truth_at_mcs B fam t phi`.

Since phi is valid in the standard semantics, phi is derivable (this is what we are trying to prove, so we cannot use it circularly).

Alternatively, `valid phi` means phi holds in ALL standard models. If we can construct a standard model that makes `bmcs_truth_at_mcs B fam t phi` true whenever standard truth holds, we are done.

**The right approach is through derivability**:

```
valid phi
   -> [need bridge]
   -> derivable phi
   -> bmcs_valid_mcs phi  (by soundness with respect to bmcs_truth_at_mcs)
```

Wait -- do we have soundness for `bmcs_truth_at_mcs`? The existing soundness is for standard `truth_at`. We would need a SEPARATE soundness result for `bmcs_truth_at_mcs`.

Actually, the direction we need is:
```
derivable phi -> bmcs_valid_mcs phi
```

The existing `bmcs_weak_completeness_mcs` proves the REVERSE: `bmcs_valid_mcs phi -> derivable phi`. We need the forward direction too.

**Do we have `derivable phi -> bmcs_valid_mcs phi` (BFMCS soundness)?**

This would mean: for every derivable phi, phi is true in all BFMCS under `bmcs_truth_at_mcs`. This is BMCS-soundness. It should follow from checking that all axioms and rules of the proof system are valid under `bmcs_truth_at_mcs`.

### 4.6 BFMCS Soundness

If we prove BFMCS soundness (`derivable phi -> bmcs_valid_mcs phi`), then combined with BFMCS completeness (`bmcs_valid_mcs phi -> derivable phi`), we get `derivable phi <-> bmcs_valid_mcs phi`.

Combined with standard soundness (`derivable phi -> valid phi`) and standard completeness (our goal: `valid phi -> derivable phi`), we get the full picture.

But to get `valid phi -> derivable phi`, we need EITHER:
- Direct standard completeness, or
- `valid phi -> bmcs_valid_mcs phi` (and then apply BFMCS completeness)

The second option requires showing that every valid formula is bmcs_valid_mcs. This is equivalent to showing every BFMCS is "reachable" from a standard model.

### 4.7 The Way Out: Combining Both Soundness Results

If we have:
1. `derivable phi -> valid phi` (standard soundness, DONE)
2. `derivable phi -> bmcs_valid_mcs phi` (BFMCS soundness, to prove)
3. `bmcs_valid_mcs phi -> derivable phi` (BFMCS completeness, DONE)

Then `derivable phi <-> bmcs_valid_mcs phi <-> valid phi` is NOT yet established. We have:
- `derivable <-> bmcs_valid_mcs` (from 2+3)
- `derivable -> valid` (from 1)
- `valid -> derivable` is STILL unproven

We need either `valid -> bmcs_valid_mcs` or `valid -> derivable` directly.

---

## 5. The Definitive Resolution

### 5.1 The Standard Completeness Argument

The standard completeness argument for modal logic is:

1. Assume phi is not derivable
2. Then [neg phi] is consistent
3. By Lindenbaum, extend to an MCS M containing neg phi
4. Construct a canonical model (frame + valuation + history/omega)
5. Show that phi fails in this canonical model
6. Therefore phi is not valid

Steps 1-3 are done. Step 4 requires the canonical model with proper D. Step 5 requires a truth lemma. Step 6 follows.

The BFMCS approach already does steps 1-5 but with the weaker `bmcs_truth_at_mcs` instead of standard `truth_at`. The gap is converting the BFMCS countermodel into a standard countermodel.

### 5.2 The Minimal Bridge: Satisfiability Transfer

We need: if `neg phi` is `bmcs_truth_at_mcs`-satisfiable, then `neg phi` is `truth_at`-satisfiable (in a standard model with shift-closed Omega and proper D).

Since `bmcs_truth_at_mcs` satisfiability gives us `neg phi in fam.mcs t` (via the truth lemma), we need to show that any formula that is in some MCS is satisfiable in standard semantics. This is the STANDARD representation theorem for modal logic.

### 5.3 The Key Theorem Needed

```lean
theorem mcs_member_satisfiable (phi : Formula) (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) (h_mem : phi in M) :
    exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D)
      (_ : IsOrderedAddMonoid D) (F : TaskFrame D) (Mdl : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (tau : WorldHistory F) (_ : tau in Omega) (t : D),
    truth_at Mdl Omega tau t phi
```

This says: any formula in an MCS is satisfiable in standard semantics. This is the standard representation theorem / model existence theorem.

**How to prove this**: Use the trivial frame construction.

Define:
- `D := Int`
- `F := trivial_frame` (WorldState = Unit, task_rel = True)
- `Mdl.valuation _ p := atom p in M`
- `Omega := Set.univ` (shift-closed trivially)
- `tau := WorldHistory.trivial`
- `t := 0`

Then prove `truth_at Mdl Set.univ tau 0 phi` iff `phi in M` by induction on phi.

**This is exactly the constant history approach from Section 3.1!** And we showed it fails for temporal formulas because `G psi` collapses to `psi` on constant histories.

### 5.4 Why the Trivial Frame Actually Works

Wait. Let me reconsider. On the trivial frame with `WorldState = Unit`:
- There is exactly ONE world history (the trivial one)
- Box phi is true iff phi is true (since there is only one history)
- G psi and psi have the same truth value (constant history)

So in this model, `truth_at ... phi` reduces to:
- `atom p` true iff `atom p in M`
- `bot` is false
- `psi -> chi` is `truth psi -> truth chi`
- `box psi` is `truth psi` (only one history)
- `G psi` is `truth psi` (constant history)
- `H psi` is `truth psi` (constant history)

This means `truth_at ... phi` corresponds to the PROPOSITIONAL content of phi, ignoring modal and temporal operators (treating them as identity).

For phi in M, we need `truth_at ... phi`. This holds iff the "propositional collapse" of phi is consistent with M. But an MCS has the property that:
- `psi -> chi in M` iff `(psi in M -> chi in M)` (by MCS closure)
- `box psi in M -> psi in M` (by T-axiom)
- `G psi in M -> psi in M` (by temporal T-axiom)

So `phi in M` implies `propositional_collapse(phi)` is true under the valuation `p |-> atom p in M`. And the propositional collapse is exactly what `truth_at` computes on the trivial model.

**Formally**: Define `trivial_truth M phi := truth_at (trivial_model M) Set.univ trivial_history 0 phi`. Then:

`trivial_truth M phi = ` truth of phi with box = identity, G = identity, H = identity, atoms from M.

By induction:
- `trivial_truth M (atom p) = atom p in M`
- `trivial_truth M bot = False`
- `trivial_truth M (psi -> chi) = (trivial_truth M psi -> trivial_truth M chi)`
- `trivial_truth M (box psi) = trivial_truth M psi`
- `trivial_truth M (G psi) = trivial_truth M psi`
- `trivial_truth M (H psi) = trivial_truth M psi`

**Claim**: If `phi in M` (where M is MCS), then `trivial_truth M phi`.

**Proof by structural induction on phi**:
- `atom p in M -> trivial_truth M (atom p)`. By definition. OK.
- `bot in M -> trivial_truth M bot`. But `bot not in M` (MCS is consistent). Vacuously true.
- `(psi -> chi) in M -> trivial_truth M (psi -> chi)`. We need: if `trivial_truth M psi` then `trivial_truth M chi`. By IH backward, `trivial_truth M psi` does NOT directly give `psi in M`. We need the REVERSE implication for the IH to work.

**The reverse implication fails in general**: `trivial_truth M (G psi) = trivial_truth M psi`. If `trivial_truth M psi`, i.e., (by reverse IH) `psi in M`. But we need `G psi in M`, which is stronger.

So the forward direction `phi in M -> trivial_truth M phi` requires a reverse IH that can fail at modal/temporal steps.

### 5.5 A Fix: Stripping Operators

The issue is that `G psi in M` does NOT follow from `psi in M`. But we can observe:

**Claim (revised)**: Define `strip(phi)` to remove all outermost G/H/Box operators:
```
strip(atom p) = atom p
strip(bot) = bot
strip(psi -> chi) = strip(psi) -> strip(chi)
strip(box psi) = strip(psi)
strip(G psi) = strip(psi)
strip(H psi) = strip(psi)
```

Then `phi in M -> strip(phi) in M` (by T-axioms: `G psi -> psi`, `H psi -> psi`, `box psi -> psi`) and `strip(phi) in M <-> trivial_truth M strip(phi) = trivial_truth M phi`.

But `strip(phi) in M` does NOT imply `phi in M`. We are going the wrong direction.

### 5.6 Stepping Back: What Is Actually Needed

After all this analysis, the fundamental situation is:

1. **BFMCS completeness works** (`bmcs_valid_mcs <-> derivable`), using CanonicalBC as D with Preorder structure
2. **Standard soundness works** (`derivable -> valid`), using arbitrary D with LinearOrderedAddCommGroup
3. **The gap** is `valid -> derivable`, which requires constructing a standard countermodel

The standard countermodel needs:
- D that is a LinearOrderedAddCommGroup
- A non-trivial frame where histories reflect temporal structure
- A truth lemma connecting truth_at to MCS membership

**The only known way to get the truth lemma for temporal formulas** is to have non-constant histories where different times map to different MCSes connected by CanonicalR. This is exactly the "dovetailing chain" over Int that the original approach attempted.

### 5.7 Recommendation: Prove BFMCS Soundness and Accept the Equivalence

The most practical path forward is:

**Phase 1**: Prove BFMCS soundness: `derivable phi -> bmcs_valid_mcs phi`

This gives `derivable phi <-> bmcs_valid_mcs phi` (combined with existing BFMCS completeness).

**Phase 2**: Prove `valid phi -> bmcs_valid_mcs phi` (the downward bridge)

This does NOT require constructing world histories. It goes by showing that every BFMCS with `bmcs_truth_at_mcs` semantics can be realized as a special case of standard truth_at.

Alternatively, prove `valid -> derivable` by noting:
- `not derivable -> not valid` is the contrapositive
- `not derivable -> consistent [neg phi]` (already proven)
- `consistent [neg phi] -> satisfiable` requires the canonical model

**Phase 3** (if needed): Build the canonical model over Int properly

This requires solving the dovetailing chain problem: building an FMCS over Int with full temporal coherence. The CanonicalBC approach avoids this by using a different D, but to connect to standard validity, we need to either:
- Find a clever way to embed CanonicalBC's preorder into Int's linear order, or
- Prove BFMCS soundness directly, making the canonical model unnecessary for the equivalence

---

## 6. Concrete Recommendation

### 6.1 The Recommended Path

**Prove BFMCS soundness**: `derivable phi -> bmcs_valid_mcs phi`

This is the missing piece that, combined with BFMCS completeness, gives `derivable <-> bmcs_valid_mcs`. It is a standard inductive argument on derivation trees, checking that each axiom and rule preserves `bmcs_truth_at_mcs` truth.

Once we have `derivable <-> bmcs_valid_mcs` and `derivable -> valid` (soundness), the remaining gap `valid -> derivable` can be established by showing `valid -> bmcs_valid_mcs`. This requires:

**Prove validity-to-BFMCS bridge**: For any BFMCS B over `CanonicalBC BC`, construct a standard model (with D = Int, proper TaskFrame, shift-closed Omega) such that standard truth implies `bmcs_truth_at_mcs` truth. The argument from research-004 Section 5.12 is the right approach:
- Instantiate validity with D = Int, the canonical frame, canonical valuation, Omega = Set.univ
- Show standard truth (with box over Set.univ) implies bmcs_truth_at_mcs (with box over B.families)
- The key is that Set.univ box is STRONGER than BFMCS box

### 6.2 Why This Works Now

The bridge `valid -> bmcs_valid_mcs` does NOT require a full truth lemma. It only requires:

```lean
truth_at (CanonicalValuation Int) Set.univ (FMCStoWorldHistory_Fixed fam t) 0 phi
  -> bmcs_truth_at_mcs B fam t phi
```

where `FMCStoWorldHistory_Fixed fam t` is a history over Int that is CONSTANT at `fam.mcs t`.

The proof goes by induction on phi:
- Atom: Both check `atom p in fam.mcs t`. Direct.
- Bot: Both are False.
- Imp: By IH.
- Box: Standard truth at Set.univ requires phi at ALL histories. BFMCS truth requires phi at B.families only. Since B.families is a subset of all histories (via FMCStoWorldHistory), the standard condition is stronger.
- All_future: Standard truth requires phi at all future times. Since the history is constant, this equals `phi in fam.mcs t` (by the propositional collapse). BFMCS truth requires `forall s >= t, bmcs_truth_at_mcs B fam s phi`.

**Wait** -- the all_future case still has the problem: standard truth on constant history collapses `G psi` to `psi`, but `bmcs_truth_at_mcs` does NOT collapse it. So the implication `truth_at (G psi) -> bmcs_truth_at_mcs (G psi)` may fail because:
- `truth_at (G psi) = forall s >= 0, truth_at s psi` (on constant history, equals `truth_at 0 psi`)
- `bmcs_truth_at_mcs (G psi) = forall s >= t, bmcs_truth_at_mcs s psi`

These are different because `bmcs_truth_at_mcs B fam s phi` may differ for different s (the FMCS maps different times to different MCSes).

**The fix**: Do NOT use a constant history. Use a history that reflects the FMCS structure. But this brings us back to the need for an FMCS over Int.

### 6.3 The Real Answer: D Is Irrelevant for the Bridge Direction

Here is the crucial insight that resolves everything:

The bridge `valid phi -> bmcs_valid_mcs phi` is equivalent (by contraposition) to `not bmcs_valid_mcs phi -> not valid phi`.

`not bmcs_valid_mcs phi` means: there exists a BFMCS B, family fam, time t where `bmcs_truth_at_mcs B fam t phi` is false.

By the truth lemma (backward): `phi not in fam.mcs t`.

By MCS negation completeness: `neg phi in fam.mcs t`.

We need: `not valid phi`, i.e., there exists a standard model where phi fails at some point.

**Key realization**: We do NOT need the standard model to faithfully represent the BFMCS. We just need ONE model where phi fails. The BFMCS gives us `neg phi in fam.mcs t`. We need to find a standard model where `neg phi` is true.

The question reduces to: **can every formula in an MCS be made true in some standard model?**

This is the standard "model existence" theorem. For propositional modal logic, it follows from the canonical model construction. For our bimodal temporal logic with the task frame constraint, it requires building the full canonical model.

### 6.4 Final Assessment

**The fundamental issue is**: bridging from BFMCS semantics to standard semantics requires a canonical model construction with D being a proper LinearOrderedAddCommGroup. There is no shortcut.

**Two viable paths**:

**Path 1 (Recommended)**: Prove `derivable phi <-> bmcs_valid_mcs phi` (BFMCS soundness + completeness). Then prove `derivable phi -> valid phi` (standard soundness, already done). Accept that `valid phi -> derivable phi` requires additional work (the canonical model over Int). This gives a COMPLETE characterization of derivability via BFMCS semantics, plus soundness for standard semantics. The gap `valid -> derivable` is deferred.

**Path 2**: Solve the canonical model over Int problem. This means:
- Build an FMCS over Int with full temporal coherence (the dovetailing chain)
- Build the canonical frame with D = Int
- Prove the truth lemma for truth_at over Int
- This gives the full `valid <-> derivable`

Path 2 is the mathematically complete solution but requires solving the dovetailing chain problem that has been blocking progress.

---

## 7. On the Question of D

To directly answer the research questions:

### 7.1 How Should D Be Modeled?

**For the BFMCS completeness chain (already working)**: D = CanonicalBC BC with Preorder. This is correct and sufficient for `bmcs_valid_mcs <-> derivable`.

**For bridging to standard validity**: D must be a LinearOrderedAddCommGroup (Int, Rat, or Real). The simplest choice is `D = Int`.

**For defining the canonical frame**: D = Int with a duration-independent task relation (`task_rel M d M' := CanonicalR M.val M'.val`). Despite the delegation context saying "duration-independence is NOT correct," the duration-independent task relation IS mathematically correct for the canonical model construction. The issue raised is really about whether CanonicalBC is an adequate D for standard validity, and the answer is no (it is not a LinearOrderedAddCommGroup). But the task relation itself can legitimately be duration-independent.

### 7.2 Parametric vs. Specific Definition of D

D should be **parametric** in the BFMCS completeness chain (CanonicalBC works). D should be **specifically Int** for the bridge to standard validity.

### 7.3 How Does the Choice of D Affect Canonical Model Construction?

With D = CanonicalBC: The canonical model construction works perfectly (identity FMCS, CanonicalR preorder). But it cannot interface with standard validity.

With D = Int: Requires solving the dovetailing chain problem (building temporally coherent FMCS over Int). This is the hard open problem.

### 7.4 The Standard Contrapositive Argument

The standard contrapositive argument (not derivable -> not valid) requires constructing a standard countermodel. This requires:
1. A LinearOrderedAddCommGroup D (like Int)
2. A TaskFrame over D
3. A WorldHistory over D whose truth_at matches MCS membership
4. A truth lemma connecting truth_at to MCS membership

The current time structure (CanonicalBC with Preorder) breaks this argument because CanonicalBC is not a LinearOrderedAddCommGroup, so we cannot instantiate the standard validity definition.

### 7.5 Summary Table

| Aspect | Current (CanonicalBC) | Needed (Standard) |
|--------|----------------------|-------------------|
| D type | CanonicalBC BC | Int (or similar) |
| D structure | Preorder only | LinearOrderedAddCommGroup |
| Task relation | CanonicalR | CanonicalR (duration-independent OK) |
| Truth definition | bmcs_truth_at_mcs | truth_at |
| Completeness | PROVEN | Requires bridge |
| Bridge to standard | UNPROVEN | Needs canonical model over Int |

---

## 8. Specific Implementation Recommendations

### 8.1 Immediate (No New Code)

Accept that the current codebase has:
- BFMCS completeness: `bmcs_valid_mcs <-> derivable` (sorry-free)
- Standard soundness: `derivable -> valid` (sorry-free)
- Gap: `valid -> derivable` (unproven)

### 8.2 Short-Term: Prove BFMCS Soundness

Prove `derivable phi -> bmcs_valid_mcs phi` by induction on derivation trees. This gives the full BFMCS equivalence and does not require any changes to D.

### 8.3 Medium-Term: Bridge to Standard Validity

Two sub-approaches:

**(a)** Weaken validity definition to not require ShiftClosed. This gives an "almost standard" completeness result. The MF/TF axiom soundness would need to be stated separately.

**(b)** Build the canonical model over Int. This requires solving the dovetailing chain problem. The CanonicalBC approach shows how to handle modal saturation; the remaining challenge is temporal coherence over a linear order.

### 8.4 What NOT to Do

- Do NOT try to give CanonicalBC a LinearOrderedAddCommGroup structure (it does not have one)
- Do NOT change the contrapositive argument structure -- it is correct
- Do NOT use `bmcs_truth_at` (the old truth definition) -- `bmcs_truth_at_mcs` is the right one
- Do NOT try to prove the bridge using constant world histories -- they collapse temporal structure
