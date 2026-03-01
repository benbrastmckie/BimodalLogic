# Research Report: Task #951 (research-017) -- Minimal TaskFrame Parametrization and Frame Correspondence

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-03-01
**Session**: sess_1772400073_9480
**Mode**: Deep mathematical research (math-research-agent)
**Dependencies**: research-016 (single elegant architecture via trivial task frame trick)
**Standards**: report-format.md, return-metadata-file.md

---

## 1. Executive Summary

This report provides the precise mathematical specifications for redefining `TaskFrame` with a two-level hierarchy, embedding theorems, and frame correspondence for discreteness and density axioms.

### Principal Findings

1. **Minimal structure for TaskFrame is `[Preorder D]`** for the BFMCS truth lemma and completeness construction. The full `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` is needed only for soundness of MF/TF axioms via `time_shift_preserves_truth`, and even then only in the `WorldHistory`-based formulation.

2. **The recommended parametrization** is a two-level hierarchy:
   - `TemporalFrame D [LinearOrder D]` -- minimal structure for temporal semantics
   - `TaskFrame D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` -- extends `TemporalFrame` with task relation, used for paper-aligned validity

3. **The embedding theorem is trivial**: Every `TemporalFrame` embeds into a `TaskFrame` via the trivial task relation (`fun _ _ _ => True`). This is the "trivial task frame trick" from research-016.

4. **Frame correspondence schemas** for discreteness and density are:
   - **Discreteness**: The canonical frame has `SuccOrder` / `PredOrder` / `IsSuccArchimedean` when the logic includes discreteness axioms, giving `OrderIso D Int` via Mathlib's `orderIsoIntOfLinearSuccPredArch`.
   - **Density**: The canonical frame has `DenselyOrdered` / `NoMinOrder` / `NoMaxOrder` when the logic includes density axioms, giving `OrderIso D Rat` via Mathlib's `Order.iso_of_countable_dense`.

5. **These frame properties are mutually exclusive for nontrivial orders**: Mathlib's `Order.isSuccLimit_of_dense` proves that every element in a dense order is a successor limit, which is incompatible with `SuccOrder` for nontrivial types.

---

## 2. Precise Minimal Structure Analysis

### 2.1 Component-by-Component Dependency Map

| Component | File | Constraint Used | Actually Needs |
|-----------|------|----------------|----------------|
| `FMCS` structure | `FMCSDef.lean` | `[Preorder D]` | Preorder |
| `BFMCS` structure | `BFMCS.lean` | `[Preorder D]` | Preorder |
| `bmcs_truth_at` | `BFMCSTruth.lean` | `[Preorder D]` | Preorder |
| `bmcs_truth_lemma` | `TruthLemma.lean` | `[Preorder D] [Zero D]` | Preorder + zero |
| `CanonicalR` | `CanonicalFrame.lean` | None (pure Set.Subset) | Nothing |
| `BidirectionalFragment` | `BidirectionalReachable.lean` | None (on Set Formula) | Nothing |
| `fragmentFMCS` | `CanonicalCompleteness.lean` | `[Preorder (BidirectionalFragment ...)]` | Preorder |
| `truth_at` (standard) | `Truth.lean` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` | Full group |
| `time_shift_preserves_truth` | `Truth.lean` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` | Full group |
| `ShiftClosed` | `Truth.lean` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` | Full group |
| `valid` | `Validity.lean` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` | Full group |
| `canonicalFrame` | `Representation.lean` | `TaskFrame Int` | AddCommGroup |
| `shifted_truth_lemma` | `Representation.lean` | `TaskFrame Int` | AddCommGroup |
| `standard_representation` | `Representation.lean` | `TaskFrame Int` | AddCommGroup |

### 2.2 The Three Tiers

**Tier 1: Preorder D** (completeness construction)
- Everything in `Metalogic/Bundle/` except `Representation.lean`
- The entire BFMCS completeness chain: MCS construction, truth lemma, modal saturation
- This is the natural home of the completeness argument

**Tier 2: LinearOrder D** (canonical model properties)
- `BidirectionalFragment` quotient has `LinearOrder` (proven sorry-free)
- Linearity is needed for the temporal linearity axiom soundness
- All temporal axioms except MF/TF are sound with just `LinearOrder`

**Tier 3: AddCommGroup D + LinearOrder D + IsOrderedAddMonoid D** (paper-aligned semantics)
- `WorldHistory.time_shift`, `ShiftClosed`
- `time_shift_preserves_truth` (MF/TF soundness)
- The standard `valid` definition
- `canonicalFrame` in `Representation.lean`

### 2.3 What the TruthLemma Actually Uses

From `TruthLemma.lean` variable block:

```lean
variable {D : Type*} [Preorder D] [Zero D]
```

The `Zero D` is used only to define a distinguished time point (the "origin" at which we evaluate). The preorder is used for:
- `le_refl` in temporal T-axiom cases
- `le_trans` in temporal 4-axiom cases
- `<=` for `all_future` and `all_past` quantification

No addition, subtraction, negation, or any group operation is used.

---

## 3. Precise Specification of Minimal TaskFrame Hierarchy

### 3.1 TemporalFrame (New Definition)

```lean
/-- A temporal frame: a linearly ordered set of times with world states.
    This is the minimal structure for temporal logic semantics. -/
structure TemporalFrame (D : Type*) [LinearOrder D] where
  /-- Type of world states -/
  WorldState : Type
```

Note: No task relation, no nullity, no compositionality. The `TemporalFrame` captures only what G, H, Box need.

### 3.2 TemporalHistory (New Definition)

```lean
/-- A temporal history: a convex domain with state assignment.
    Unlike WorldHistory, there is no respects_task constraint. -/
structure TemporalHistory {D : Type*} [LinearOrder D] (TF : TemporalFrame D) where
  /-- Domain predicate -/
  domain : D -> Prop
  /-- Convexity: no temporal gaps -/
  convex : forall (x z : D), domain x -> domain z -> forall (y : D), x <= y -> y <= z -> domain y
  /-- State assignment -/
  states : (t : D) -> domain t -> TF.WorldState
```

### 3.3 TemporalModel and Truth

```lean
/-- A temporal model: frame + valuation. -/
structure TemporalModel {D : Type*} [LinearOrder D] (TF : TemporalFrame D) where
  valuation : TF.WorldState -> String -> Prop

/-- Truth at a temporal model. Identical to truth_at but without group operations. -/
def temporal_truth_at {D : Type*} [LinearOrder D] {TF : TemporalFrame D}
    (M : TemporalModel TF) (Omega : Set (TemporalHistory TF))
    (tau : TemporalHistory TF) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => temporal_truth_at M Omega tau t phi -> temporal_truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : TemporalHistory TF), sigma in Omega ->
      temporal_truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> temporal_truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> temporal_truth_at M Omega tau s phi
```

### 3.4 Temporal Validity

```lean
/-- Temporal validity: quantifies over all linear orders D and temporal frames. -/
def temporal_valid (phi : Formula) : Prop :=
  forall (D : Type) [LinearOrder D] (TF : TemporalFrame D) (M : TemporalModel TF)
    (Omega : Set (TemporalHistory TF))
    (tau : TemporalHistory TF) (h_mem : tau in Omega) (t : D),
    temporal_truth_at M Omega tau t phi
```

### 3.5 TaskFrame as Extension

```lean
/-- TaskFrame extends TemporalFrame with task relation and group structure. -/
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    extends TemporalFrame D where
  /-- Task relation -/
  task_rel : WorldState -> D -> WorldState -> Prop
  /-- Nullity -/
  nullity : forall w, task_rel w 0 w
  /-- Compositionality -/
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

### 3.6 Alternative: Keep TaskFrame, Add TemporalFrame Separately

A less invasive approach that avoids refactoring `TaskFrame`:

```lean
-- New file: TemporalFrame.lean
structure TemporalFrame (D : Type*) [LinearOrder D] where
  WorldState : Type

-- In TaskFrame.lean, add coercion:
def TaskFrame.toTemporalFrame {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) : TemporalFrame D where
  WorldState := F.WorldState
```

This approach adds new definitions alongside the existing ones without modifying them.

---

## 4. Embedding Theorem

### 4.1 Statement

**Theorem** (TemporalFrame embeds into TaskFrame): For any `TemporalFrame D [LinearOrder D]` and any type `D'` with `[AddCommGroup D'] [LinearOrder D'] [IsOrderedAddMonoid D']`, plus an order-preserving injection `iota : D ->o D'`, we can construct a `TaskFrame D'` such that the truth of formulas is preserved.

However, the simpler and more useful statement is:

**Theorem** (Trivial Task Frame Trick): For any `D` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and any type `W`, the trivial task frame:

```lean
def trivialTaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (W : Type) : TaskFrame D where
  WorldState := W
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

makes `WorldHistory.respects_task` trivially satisfied, so every temporal history lifts to a world history.

### 4.2 WorldHistory Lifting

```lean
/-- Any temporal history lifts to a world history over the trivial task frame. -/
def liftTemporalHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {W : Type} (tau : TemporalHistory (TemporalFrame.mk W)) :
    WorldHistory (trivialTaskFrame D W) where
  domain := tau.domain
  convex := tau.convex
  states := tau.states
  respects_task := fun _ _ _ _ _ => trivial
```

### 4.3 Truth Preservation

```lean
/-- Truth is preserved under the trivial task frame embedding. -/
theorem trivial_embedding_preserves_truth
    {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {W : Type} {TF : TemporalFrame D} (h_eq : TF.WorldState = W)
    (M_t : TemporalModel TF) (Omega_t : Set (TemporalHistory TF))
    (tau_t : TemporalHistory TF) (t : D) (phi : Formula) :
    temporal_truth_at M_t Omega_t tau_t t phi <->
    truth_at (liftModel M_t) (liftOmega Omega_t) (liftTemporalHistory tau_t) t phi
```

This follows by structural induction on `phi`:
- **Atom**: Both sides check domain membership and valuation. Valuation is defined identically.
- **Bot**: Both sides are `False`.
- **Imp**: By induction hypothesis on subformulas.
- **Box**: Both sides quantify over `sigma in Omega`. Since `liftOmega` is a bijection on the Omega sets, the quantifications match.
- **all_past/all_future**: Both sides quantify `forall s, s <= t -> ...` (resp. `t <= s`). By induction hypothesis.

### 4.4 The Bridge Theorem

```lean
/-- temporal_valid implies valid (the easy direction for completeness). -/
theorem temporal_valid_implies_valid (phi : Formula) :
    temporal_valid phi -> valid phi := by
  intro h_tv D _ _ _ F M Omega h_sc tau h_mem t
  -- F : TaskFrame D, convert to TemporalFrame
  -- Every WorldHistory gives a TemporalHistory (by forgetting respects_task)
  -- h_tv gives truth in all temporal models, including the one from F
  -- ...
```

**Key insight from research-016**: For the completeness direction, we need the contrapositive:

```
not valid phi
<- not temporal_valid phi     (trivial: more models checked)
<- exists BFMCS falsifying phi (canonical model construction)
<- not derives [] phi          (BFMCS from consistent context)
```

The direction `temporal_valid phi -> valid phi` is the easy direction because the class of temporal models is LARGER than the class of task models (every task model, viewed as a temporal model by forgetting `respects_task`, is a temporal model -- but not every temporal model is a task model). So if `phi` holds in ALL temporal models, it certainly holds in all task models.

---

## 5. Frame Correspondence Theorems

### 5.1 The Canonical Frame's Structure

In the canonical model construction, the time domain is the `BidirectionalFragment M0 h_mcs0` quotient (Antisymmetrization of the preorder on `CanonicalR`). This quotient is:

- **A linear order**: `LinearOrder (BidirectionalFragment M0 h_mcs0)` (proven sorry-free)
- **At most countable**: The language of TM has countably many formulas, so there are at most `2^aleph_0` MCS. The fragment is a subset, hence at most countable. In fact, for a fixed formula, the closure is finite, so the relevant fragment is countable.
- **Nonempty**: Contains at least the origin `M0`.

What additional properties the canonical frame has depends on which axioms the logic includes.

### 5.2 Discreteness Axiom and Frame Correspondence

#### 5.2.1 The Discreteness Axiom Schema

In temporal logic, the standard discreteness axiom is the conjunction of:

**Axiom Disc_F (Future Discreteness)**:
```
G(phi) <-> phi /\ G(F(phi) -> phi)
```

Equivalently, decomposed into two implications:
- Forward: `G(phi) -> phi /\ G(F(phi) -> phi)` (already derivable from T-axiom + distribution)
- Backward: `phi /\ G(F(phi) -> phi) -> G(phi)` (this is the content)

An alternative formulation using successor:
```
G(phi) <-> phi /\ X(G(phi))
```
where `X(phi) = "phi at the next moment"`. But TM does not have `X` as primitive, so we use the implicational formulation.

**Axiom Disc_P (Past Discreteness)**: Temporal dual of Disc_F.

#### 5.2.2 Frame Property: SuccOrder + PredOrder + IsSuccArchimedean

The discreteness axiom is **valid** in a temporal frame iff the temporal order has:
- `SuccOrder D`: every non-maximal element has an immediate successor
- `PredOrder D`: every non-minimal element has an immediate predecessor
- `IsSuccArchimedean D`: every element is reachable from any other by iterated succ/pred

**Soundness direction** (frame property -> axiom validity):
In a discrete frame with successor `succ`, the backward direction `phi /\ G(F(phi) -> phi) -> G(phi)` is valid because: if phi holds at `t` and for every future `s >= t`, whenever phi holds at some `r >= s`, phi also holds at `s` -- then by well-founded induction (using `IsSuccArchimedean`), phi holds at every `s >= t`.

**Completeness direction** (axiom in MCS -> frame property):
If the discreteness axiom is in the logic, then in the canonical model, between any two distinct MCS `M < M'` (with respect to `CanonicalR`), there is one that is an immediate successor. This is because: if `M < M'` with no immediate successor, then there exists `M''` with `M < M'' < M'`, and by density, `F(phi) -> phi` would fail for some `phi` -- contradicting the discreteness axiom being in all MCS.

#### 5.2.3 Representation Theorem for Discrete Frames

Mathlib provides:

```lean
-- In Mathlib.Order.SuccPred.LinearLocallyFinite
noncomputable def orderIsoIntOfLinearSuccPredArch
    {iota : Type*} [LinearOrder iota] [SuccOrder iota] [PredOrder iota]
    [IsSuccArchimedean iota] [NoMaxOrder iota] [NoMinOrder iota] [Nonempty iota] :
    iota ≃o Int
```

**Requirements for applying this**:
1. `LinearOrder D` -- from BidirectionalFragment (proven)
2. `SuccOrder D` -- from discreteness axiom in the logic
3. `PredOrder D` -- from past discreteness axiom
4. `IsSuccArchimedean D` -- from discreteness + linearity
5. `NoMaxOrder D` -- from the completeness construction (MCS always have extensions)
6. `NoMinOrder D` -- from the past completeness construction
7. `Nonempty D` -- trivial (contains origin)

**Theorem** (Discrete Frame Isomorphism):
```lean
theorem canonical_discrete_iso_int
    (h_disc : /- discreteness axioms in the logic -/) :
    Nonempty (BidirectionalFragment M0 h_mcs0 ≃o Int)
```

### 5.3 Density Axiom and Frame Correspondence

#### 5.3.1 The Density Axiom Schema

**Axiom Dens (Temporal Density)**:
```
G(phi) -> G(G(phi))
```

This is the temporal 4 axiom! It is already in TM. So all TM frames are "4-frames" (transitivity), but the density axiom in temporal logic is stronger:

**Axiom Dens_strict (Strict Temporal Density)**:
```
F(phi) -> F(F(phi))    -- for some_future (existential)
```

Actually, this is not quite right either. The standard density axiom for Kt is:

```
G(G(phi)) -> G(phi)
```

which is the CONVERSE of the 4-axiom. Combined with 4, this gives `G(G(phi)) <-> G(phi)`, which corresponds to the density of the temporal order.

Wait -- TM already has `temp_4`: `G(phi) -> G(G(phi))`. The converse `G(G(phi)) -> G(phi)` is derivable from `G(phi) -> phi` (the T-axiom):

```
G(G(phi)) -> G(phi)    -- by T-axiom applied to G(phi)
```

So in TM with reflexive temporal operators and T-axioms, the order is ALREADY dense!

**Key insight**: TM's T-axioms (`G(phi) -> phi`, `H(phi) -> phi`) plus the transitivity axiom (`G(phi) -> G(G(phi))`) imply that the canonical relation is a preorder. The reflexivity from T-axioms gives `M R M` for all MCS `M`. Transitivity gives `M R M' and M' R M''` implies `M R M''`. And density follows from reflexivity: between any `M` and `M'` with `M R M'`, we have `M R M R M'` -- but this only gives a trivial "density" (the intermediate point is one of the endpoints).

True density (strict density) would require: for any `M < M'` (strict), there exists `M''` with `M < M'' < M'` (strict). This is a STRONGER property that is NOT automatic from TM's axioms.

#### 5.3.2 The Proper Density Axiom

The density axiom for strict temporal order is:

**Axiom StrictDens (Strict Density)**:
```
F(phi) -> F(F(phi))    -- where F = some_future = neg(G(neg(phi)))
```

This says: if there exists a future time where phi holds, then there exists a future time where "there exists a future time where phi holds" holds -- i.e., the witness can always be pushed further into the future with another witness in between.

Equivalently (via contraposition): `G(G(phi)) -> G(phi)` (which IS the T-axiom applied to `G(phi)` in TM -- so this is already derivable!).

**But wait**: `F(phi) -> F(F(phi))` as stated above is about the existential future operator. Let me re-examine:
- `F(phi)` = `some_future phi` = `neg(all_future(neg phi))`
- `F(F(phi))` = `some_future(some_future phi)` = `neg(all_future(neg(neg(all_future(neg phi)))))`

The claim `F(phi) -> F(F(phi))` in TM with reflexive G: Suppose there exists `s >= t` with phi at `s`. Then at `s`, `F(phi)` holds (since `s >= s` and phi at `s`). So at `t`, `F(F(phi))` holds (witnessed by `s >= t` with `F(phi)` at `s`).

So `F(phi) -> F(F(phi))` IS derivable in TM! This means TM already has a trivial form of density -- but it is the TRIVIAL density coming from reflexivity (the witness for `F(F(phi))` is the SAME `s` that witnesses `F(phi)`).

**For non-trivial density**, we need a genuinely different axiom:

**Axiom StrictDens_proper (Proper Strict Density)**:
```
some_future(phi) -> some_future(phi /\ some_future(neg(phi) /\ some_future(phi)))
```

This is unwieldy. The standard approach in temporal logic is to use the **Until** operator, but TM does not have Until.

**Alternative: The Irr axiom** (irreflexivity of the strict part):
In the literature on temporal logics of dense time, one adds:
```
phi /\ G(phi -> G(phi)) -> G(phi)
```
which forces density. This axiom says: if phi holds now, and whenever phi holds in the future it persists to all further future, then phi holds at all future times. This is a form of induction that only works in dense orders.

However, for TM with REFLEXIVE G (where G includes the present), this axiom is trivially valid:
`phi /\ G(phi -> G(phi))` means phi holds at t and for all s >= t, phi at s implies G(phi) at s. By T-axiom, G(phi) at s means phi at s (and at all s' >= s). So starting from phi at t, G(phi -> G(phi)) gives G(phi) at t. This is just the 4-axiom.

**Conclusion**: With reflexive temporal operators (as in TM), the standard density axioms are either trivially derivable or need to be formulated very carefully. The key distinction is between:

1. **The trivial density from reflexivity**: In any preorder, between `M <= M'` we can interpolate `M` itself. This is not interesting.
2. **Genuine density (DenselyOrdered)**: For every `M < M'` (strictly), there exists `M''` with `M < M'' < M'` (strictly). This requires additional axioms BEYOND TM.

For genuine density, one would need to add axioms that prevent the canonical frame from having immediate successors. The natural candidate is an axiom that asserts there is always a strictly intermediate future time.

#### 5.3.3 Frame Property: DenselyOrdered

For the genuine density frame correspondence:

**DenselyOrdered** on the canonical model means: for any two MCS `M` and `M'` with `CanonicalR M M'` but NOT `CanonicalR M' M` (i.e., `M` strictly before `M'`), there exists `M''` with `CanonicalR M M''`, `CanonicalR M'' M'`, but NOT `CanonicalR M'' M` and NOT `CanonicalR M' M''`.

#### 5.3.4 Representation Theorem for Dense Frames

Mathlib provides:

```lean
-- In Mathlib.Order.CountableDenseLinearOrder
theorem Order.iso_of_countable_dense
    (alpha : Type*) (beta : Type*)
    [LinearOrder alpha] [LinearOrder beta]
    [Countable alpha] [DenselyOrdered alpha] [NoMinOrder alpha] [NoMaxOrder alpha] [Nonempty alpha]
    [Countable beta] [DenselyOrdered beta] [NoMinOrder beta] [NoMaxOrder beta] [Nonempty beta] :
    Nonempty (OrderIso alpha beta)
```

Applying this with `beta = Rat`:

```lean
theorem canonical_dense_iso_rat
    (h_dense : /- density axioms in the logic -/)
    (h_countable : Countable (BidirectionalFragment M0 h_mcs0))
    (h_nomin : NoMinOrder (BidirectionalFragment M0 h_mcs0))
    (h_nomax : NoMaxOrder (BidirectionalFragment M0 h_mcs0)) :
    Nonempty (BidirectionalFragment M0 h_mcs0 ≃o Rat)
```

### 5.4 Mutual Exclusivity

**Theorem**: For a nontrivial linear order, `SuccOrder` and `DenselyOrdered` are incompatible.

From Mathlib (`Order.isSuccLimit_of_dense`):
```lean
theorem isSuccLimit_of_dense [DenselyOrdered alpha] (a : alpha) : IsSuccLimit a
```

This means every element is a successor limit in a dense order, which means no element has an immediate successor. But `SuccOrder` with `IsSuccArchimedean` requires immediate successors for non-maximal elements.

Therefore discreteness and density are genuinely alternative frame properties, as expected.

---

## 6. Concrete Lean 4 Type Signatures

### 6.1 The Full Two-Level Hierarchy

```lean
-- TemporalFrame.lean (NEW file)
structure TemporalFrame (D : Type*) [LinearOrder D] where
  WorldState : Type

structure TemporalHistory {D : Type*} [LinearOrder D] (TF : TemporalFrame D) where
  domain : D -> Prop
  convex : forall (x z : D), domain x -> domain z -> forall (y : D), x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> TF.WorldState

structure TemporalModel {D : Type*} [LinearOrder D] (TF : TemporalFrame D) where
  valuation : TF.WorldState -> String -> Prop

def temporal_truth_at {D : Type*} [LinearOrder D] {TF : TemporalFrame D}
    (M : TemporalModel TF) (Omega : Set (TemporalHistory TF))
    (tau : TemporalHistory TF) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => temporal_truth_at M Omega tau t phi -> temporal_truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : TemporalHistory TF), sigma in Omega ->
      temporal_truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> temporal_truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> temporal_truth_at M Omega tau s phi

def temporal_valid (phi : Formula) : Prop :=
  forall (D : Type) [LinearOrder D] (TF : TemporalFrame D) (M : TemporalModel TF)
    (Omega : Set (TemporalHistory TF))
    (tau : TemporalHistory TF) (h_mem : tau in Omega) (t : D),
    temporal_truth_at M Omega tau t phi
```

```lean
-- TaskFrame.lean (MODIFIED)
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    extends TemporalFrame D where
  task_rel : toTemporalFrame.WorldState -> D -> toTemporalFrame.WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

### 6.2 Bridge Theorem Signatures

```lean
-- Bridge.lean (NEW file)

/-- Forgetting the task relation gives a temporal frame. -/
def TaskFrame.toTemporalFrame' {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) : TemporalFrame D where
  WorldState := F.WorldState

/-- Forgetting respects_task gives a temporal history. -/
def WorldHistory.toTemporalHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {F : TaskFrame D} (tau : WorldHistory F) : TemporalHistory F.toTemporalFrame' where
  domain := tau.domain
  convex := tau.convex
  states := tau.states

/-- temporal_valid implies valid (the easy direction). -/
theorem temporal_valid_implies_valid (phi : Formula) :
    temporal_valid phi -> valid phi

/-- Completeness via temporal_valid. -/
theorem temporal_completeness (phi : Formula) :
    temporal_valid phi -> Nonempty (DerivationTree [] phi)

/-- Standard completeness as a corollary. -/
theorem standard_completeness (phi : Formula) :
    valid phi -> Nonempty (DerivationTree [] phi) :=
  fun h => temporal_completeness phi (temporal_valid_implies_valid phi |>.mp ... sorry)
  -- Wait: we need valid -> temporal_valid, which is the HARD direction
  -- For completeness, we actually need the chain:
  -- not derives -> not temporal_valid -> not valid (contrapositive)
```

**Corrected completeness chain**:

```lean
/-- If phi is not derivable, then phi is not valid. -/
theorem not_derivable_implies_not_valid (phi : Formula)
    (h : forall (dt : DerivationTree [] phi), False) :
    exists (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) ..., not (truth_at M Omega tau t phi) := by
  -- Step 1: Build BFMCS falsifying phi
  -- Step 2: BFMCS gives temporal model falsifying phi
  -- Step 3: Temporal model lifts to TaskFrame model via trivial task frame trick
  sorry
```

### 6.3 Frame Correspondence Signatures

```lean
-- FrameCorrespondence.lean (NEW file)

/-- Discreteness axiom schema. -/
inductive DiscreteAxiom : Formula -> Type where
  | disc_future (phi : Formula) :
      DiscreteAxiom (
        (phi.and (Formula.all_future (phi.some_future.imp phi))).imp (Formula.all_future phi)
      )
  | disc_past (phi : Formula) :
      DiscreteAxiom (
        (phi.and (Formula.all_past (phi.some_past.imp phi))).imp (Formula.all_past phi)
      )

/-- The canonical frame of TM + discreteness has SuccOrder. -/
theorem canonical_discrete_has_succ_order
    {M0 : Set Formula} {h_mcs0 : SetMaximalConsistent M0}
    (h_disc : /- M0 contains discreteness axioms -/) :
    SuccOrder (BidirectionalFragment M0 h_mcs0)

/-- The canonical frame of TM + discreteness is isomorphic to Int. -/
theorem canonical_discrete_iso_int
    {M0 : Set Formula} {h_mcs0 : SetMaximalConsistent M0}
    (h_disc : /- discreteness axioms -/)
    (h_nomax : NoMaxOrder (BidirectionalFragment M0 h_mcs0))
    (h_nomin : NoMinOrder (BidirectionalFragment M0 h_mcs0)) :
    Nonempty (BidirectionalFragment M0 h_mcs0 ≃o Int) :=
  Nonempty.intro (orderIsoIntOfLinearSuccPredArch)

/-- The canonical frame of TM + density has DenselyOrdered. -/
theorem canonical_dense_has_dense_order
    {M0 : Set Formula} {h_mcs0 : SetMaximalConsistent M0}
    (h_dens : /- M0 contains density axioms -/) :
    DenselyOrdered (BidirectionalFragment M0 h_mcs0)

/-- The canonical frame of TM + density is isomorphic to Rat. -/
theorem canonical_dense_iso_rat
    {M0 : Set Formula} {h_mcs0 : SetMaximalConsistent M0}
    (h_dens : /- density axioms -/)
    (h_count : Countable (BidirectionalFragment M0 h_mcs0))
    (h_nomax : NoMaxOrder (BidirectionalFragment M0 h_mcs0))
    (h_nomin : NoMinOrder (BidirectionalFragment M0 h_mcs0)) :
    Nonempty (BidirectionalFragment M0 h_mcs0 ≃o Rat) :=
  Order.iso_of_countable_dense _ _
```

---

## 7. ROAD_MAP.md Reflection

### 7.1 Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Constant Witness Family | Medium | Our approach does NOT use constant witnesses. Trivial task frame is different: it uses time-varying MCS families from the BFMCS, not constant families. |
| Non-Standard Validity | HIGH | research-016's Architecture A introduces `temporal_valid`, which is a NEW validity notion. But unlike `bmcs_valid`/`fmp_valid`, the equivalence `temporal_valid <-> valid` is explicitly part of the design. Must prove the bridge. |
| Single-History FDSM | Low | Not relevant -- we use multi-family BFMCS. |
| CanonicalReachable/Quotient | Medium | The BidirectionalFragment approach superseded this. Our frame correspondence theorems use BidirectionalFragment, which is on the active path. |

### 7.2 Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family | ACTIVE | Fully aligned. Our `TemporalFrame` hierarchy does not change the MCS family approach -- it generalizes the semantic framework around it. |
| Representation-First | CONCLUDED | Aligned. The frame correspondence theorems are corollaries of the representation theorem, following the concluded strategy's architecture. |
| Algebraic Verification | PAUSED | Not affected. The algebraic path is independent. |

### 7.3 Critical Warning: Non-Standard Validity Risk

The biggest risk from the ROAD_MAP is the "Non-Standard Validity" dead end. Our proposal introduces `temporal_valid`, which LOOKS like a new validity notion. However, the key differences from `bmcs_valid`/`fmp_valid` are:

1. `temporal_valid` is semantically standard -- it uses the same truth definition structure as `valid`, just over a wider class of models.
2. The equivalence proof is architecturally simple: `temporal_valid -> valid` because task models are temporal models (larger class = harder to satisfy = anything valid in all temporal models is valid in all task models). The converse (`valid -> temporal_valid`) is the hard direction, but it is NOT needed for completeness.
3. For completeness, we only need the chain: `not derivable -> not temporal_valid -> not valid`.

The NOT-NEEDED direction (`valid -> temporal_valid`) would be needed only to claim full equivalence. This can be left as a separate theorem or documented as optional.

---

## 8. Concrete Refactoring Plan for TaskFrame.lean

### 8.1 Option A: Non-Invasive (Recommended for First Implementation)

**Changes required**:
1. Create `Theories/Bimodal/Semantics/TemporalFrame.lean` with `TemporalFrame`, `TemporalHistory`, `TemporalModel`, `temporal_truth_at`, `temporal_valid`
2. Create `Theories/Bimodal/Semantics/TemporalBridge.lean` with the bridge theorem
3. Modify `Representation.lean` to use `temporal_valid` in the completeness chain
4. Leave `TaskFrame.lean`, `WorldHistory.lean`, `Truth.lean`, `Validity.lean`, `Soundness.lean` UNCHANGED

**Estimated effort**: 8-12 hours
**Risk**: Low (no existing code modified)

### 8.2 Option B: Structural Refactor (For Long-Term Architecture)

**Changes required**:
1. Modify `TaskFrame` to `extends TemporalFrame D`
2. Modify `WorldHistory` to `extends TemporalHistory TF.toTemporalFrame`
3. Add `TaskFrame.toTemporalFrame'` coercion
4. Update `Truth.lean` to factor through `temporal_truth_at`
5. Update `Validity.lean` to add `temporal_valid`
6. Update `Soundness.lean` to handle both levels
7. Update all downstream files

**Estimated effort**: 15-20 hours
**Risk**: Medium (many files modified, potential for regressions)

### 8.3 Recommendation

Start with Option A. It proves the concept with zero risk to existing code. If the bridge theorem works cleanly, proceed to Option B in a separate task for architectural cleanliness.

---

## 9. Risk Assessment

### 9.1 Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| `temporal_valid` becomes another non-standard validity like `bmcs_valid` | HIGH | Prove `temporal_valid -> valid` immediately. Document that the converse is separate. |
| Universe level issues in `temporal_valid` | MEDIUM | Use `Type` (not `Type*`) as in current `valid`. Test early. |
| Bridge theorem box case mismatch | MEDIUM | The box case in `temporal_truth_at` quantifies over `TemporalHistory`, while `truth_at` quantifies over `WorldHistory`. The trivial task frame trick ensures a bijection. Test this specific case first. |
| Discreteness axiom formulation for TM with reflexive G | LOW | Standard discreteness axiom literature assumes irreflexive temporal operators. May need reformulation for reflexive case. Research the exact formulation before coding. |
| `ShiftClosed` requirement in `valid` | MEDIUM | `temporal_valid` does NOT require `ShiftClosed`. Must verify that the bridge `temporal_valid -> valid` accounts for this by showing temporal countermodels can always be made shift-closed. |

### 9.2 The ShiftClosed Problem

The current `valid` definition requires `ShiftClosed Omega`:

```lean
def valid (phi : Formula) : Prop :=
  forall D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

For `temporal_valid -> valid`, we need to show: if `phi` is true in ALL temporal models (including non-shift-closed ones), then `phi` is true in all task models with shift-closed Omega. This follows because task models with shift-closed Omega are a SUBSET of all temporal models. So `temporal_valid` (all temporal models) implies truth in any task model with shift-closed Omega.

This direction works. The converse is where `ShiftClosed` causes complications.

---

## 10. Summary of Deliverables

1. **Minimal TaskFrame specification**: `TemporalFrame D [LinearOrder D]` for completeness, `TaskFrame D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` for paper alignment (Section 3).

2. **Embedding theorem**: Trivial task frame trick embeds any temporal model into a task model with truth preservation (Section 4).

3. **Frame correspondence schema** (Section 5):
   - Discreteness axiom <-> `SuccOrder + PredOrder + IsSuccArchimedean` <-> `OrderIso D Int`
   - Density axiom <-> `DenselyOrdered + NoMin + NoMax` <-> `OrderIso D Rat` (for countable D)

4. **Refactoring plan**: Option A (non-invasive, 8-12 hours) recommended for first implementation (Section 8).

5. **Risk assessment**: Primary risk is creating another non-standard validity; mitigated by proving `temporal_valid -> valid` immediately (Section 9).

---

## 11. Decisions

1. **temporal_valid is semantically justified**: Unlike `bmcs_valid` and `fmp_valid` (which changed the truth predicate), `temporal_valid` uses the same recursive truth definition. It only generalizes which structures are quantified over.

2. **The bridge direction needed for completeness is the easy one**: `temporal_valid -> valid` (more models = harder to be valid). The hard direction (`valid -> temporal_valid`) is NOT needed for completeness.

3. **Discreteness and density are extensions, not prerequisites**: Base TM completeness works with just `[LinearOrder D]`. Frame correspondence theorems are corollaries.

4. **Non-invasive refactoring first**: Add new files alongside existing ones. Do not modify `TaskFrame.lean` initially.

5. **The density axiom needs careful formulation for reflexive TM**: Standard density axioms from the irreflexive-G literature are trivially derivable in reflexive-G TM. A proper density axiom for TM must assert genuine density (no immediate successors), not just transitivity.

---

## Appendix A: Mathlib Theorems Used

| Theorem | Module | Purpose |
|---------|--------|---------|
| `orderIsoIntOfLinearSuccPredArch` | `Mathlib.Order.SuccPred.LinearLocallyFinite` | Discrete linear order <-> Int |
| `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` | Countable dense linear order <-> Rat |
| `Order.isSuccLimit_of_dense` | (Mathlib) | Dense orders have no immediate successors |
| `Order.embedding_from_countable_to_dense` | `Mathlib.Order.CountableDenseLinearOrder` | Countable order embeds in dense order |

## Appendix B: Search Queries Used

- Mathlib leansearch: "countable dense linear order without endpoints isomorphic to rationals"
- Mathlib leansearch: "discrete linear order isomorphic to integers successor predecessor"
- Mathlib leansearch: "SuccOrder and DenselyOrdered cannot both hold"
- Mathlib loogle: `SuccOrder ?a, DenselyOrdered ?a`
- Mathlib loogle: `OrderIso ?a Int, SuccOrder ?a, PredOrder ?a`
- Mathlib leanfinder: "DenselyOrdered cannot have successor order for nontrivial type"

## Appendix C: Codebase Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Validity.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Soundness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Completeness.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCS.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean`
- `/home/benjamin/Projects/ProofChecker/specs/ROAD_MAP.md`
- `/home/benjamin/Projects/ProofChecker/specs/951_implement_sorry_free_completeness_canonicalmcs/reports/research-016.md`
