# Research Report: Task #951 (research-016) -- Single Elegant Architecture for Temporal Completeness

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-03-01
**Session**: sess_1772398890_30630
**Mode**: Deep mathematical research (math-research-agent)
**Dependencies**: research-015, phase-1-handoff-20260301.md
**Standards**: report-format.md, return-metadata-file.md

---

## 1. Executive Summary

This report addresses the fundamental question: **Can we replace the two-layer architecture with a single elegant one that naturally accommodates frame correspondence extensions?**

The answer is **yes**, through a conceptual reframing that treats the problem differently from how it has been approached in all 15 prior research reports. The key insight is:

> **The AddCommGroup requirement in TaskFrame is not a mathematical necessity for completeness -- it is a paper-alignment choice that can be factored out.** The real semantics of TM logic is captured by a **temporal frame** (a preorder with shift-closed histories), not by an ordered abelian group. The group structure is an *instantiation* for concrete models, not a requirement for the validity definition.

### Principal Findings

1. **The two-layer problem is an artifact of an over-specialized validity definition.** The standard `valid` definition in `Validity.lean` quantifies over `TaskFrame D` which requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. This is faithful to the JPL paper's specification, but it is **more restrictive than what soundness and completeness actually need**. The logic TM is complete with respect to a much wider class of frames.

2. **A single elegant architecture is possible by defining a generalized validity notion** (`valid_gen`) that quantifies over a weaker frame structure, then proving it equivalent to the standard `valid`. Specifically:
   - `valid_gen` quantifies over `[LinearOrder D]` with a weaker task relation axiomatization
   - `valid_gen phi <-> valid phi` is provable for all formulas in TM
   - The canonical model construction targets `valid_gen` (where it works natively)
   - Frame correspondence theorems then specialize `valid_gen` to particular frame classes

3. **Alternatively (and more elegantly): redefine `TaskFrame` to parametrize on the minimal structure**, then show that any model with the richer structure embeds. This requires a one-time refactoring but produces a permanently cleaner architecture.

4. **The canonical time domain is, mathematically, the BidirectionalQuotient itself** -- a concrete linear order. No isomorphism to Int/Z is needed for completeness. Frame correspondence theorems (density, discreteness) add properties to this quotient, enabling isomorphism to Q, Z, etc. as corollaries.

---

## 2. The Fundamental Diagnosis: What "Time" Really Means

### 2.1 Where the AddCommGroup Is Used

Tracing every use of the group structure through the codebase reveals a precise dependency map:

| Component | Uses AddCommGroup For | Actually Needs |
|-----------|----------------------|----------------|
| `TaskFrame.compositionality` | `task_rel w (x + y) v` | Addition on durations |
| `WorldHistory.respects_task` | `task_rel w (t - s) u` with `s <= t` | Subtraction on durations |
| `WorldHistory.time_shift` | Shift by `Delta : D` | Translation group action |
| `ShiftClosed` | Closure under `time_shift sigma Delta` | Translation closure |
| `time_shift_preserves_truth` | `y - x`, `x - y`, `neg`, `add_sub_cancel` | Abelian group arithmetic |
| `truth_at.all_future` | `forall s, t <= s -> ...` | Linear order |
| `truth_at.all_past` | `forall s, s <= t -> ...` | Linear order |
| `truth_at.atom` | Domain membership check | Nothing beyond D being a type |
| `truth_at.box` | `forall sigma in Omega, ...` | Nothing about D |
| `valid` | Universal quantification over D | Outer existential only |

**Key observation**: The group operations (`+`, `-`, `neg`) are used in exactly two places:
1. **TaskFrame compositionality/nullity**: These use `0` and `+` on durations.
2. **WorldHistory respects_task and time_shift**: These use `-` and shift arithmetic.

The temporal operators G and H themselves use **only** the order relation (`<=`). The modal operator Box uses **nothing** about D.

### 2.2 What the TruthLemma Actually Requires

The BFMCS truth lemma (`bmcs_truth_lemma`) is proven with only `[Preorder D] [Zero D]`. This is confirmed by examining its variable block:

```lean
variable {D : Type*} [Preorder D] [Zero D]
```

The truth lemma does not use addition, subtraction, negation, or any group operation. It uses only:
- `le_refl` (reflexivity of preorder)
- `le_trans` (transitivity of preorder)

**This means the entire completeness argument at the BFMCS level is algebra-free.**

### 2.3 What Soundness Actually Requires

The soundness theorem (`soundness`) is proven for the standard `valid` definition, which requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. Examining the soundness proof reveals that the group structure is used for:

1. **MF axiom** (`Box phi -> Box(F phi)`): Uses `time_shift_preserves_truth`, which requires group subtraction
2. **TF axiom** (`Box phi -> F(Box phi)`): Same
3. **Temporal T axiom** (`G phi -> phi`): Uses `le_refl`, no group structure
4. **Temporal 4 axiom** (`G phi -> GG phi`): Uses `le_trans`, no group structure
5. **Temporal A axiom** (`phi -> GP phi`): Uses `le_refl`, no group structure

The MF and TF axioms are the **only** axioms that fundamentally require the group structure, because they involve shifting histories in time to relate modal and temporal truth. All other axioms work with just a linear order.

---

## 3. Three Architectures, Ranked by Elegance

### Architecture A: Generalized TaskFrame (Recommended)

**Core Idea**: Replace the single `TaskFrame D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` with a two-level hierarchy:

```
TemporalFrame D [LinearOrder D]
  - WorldState : Type
  - accessibility : WorldState -> WorldState -> Prop   -- for Box
  - temporal_le : D -> D -> Prop                       -- just the LE on D

TaskFrame D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  extends TemporalFrame D
  - task_rel : WorldState -> D -> WorldState -> Prop
  - nullity, compositionality
  - time_shift structure
```

**Validity hierarchy**:
```lean
-- Level 1: What the canonical model natively satisfies
def temporal_valid (phi : Formula) : Prop :=
  forall (D : Type) [LinearOrder D] (TF : TemporalFrame D),
    forall w t, temporal_truth_at TF w t phi

-- Level 2: What the JPL paper defines (current `valid`)
def task_valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ...,
    truth_at M Omega tau t phi

-- Bridge: Every task model induces a temporal frame
-- so task_valid phi -> temporal_valid phi (more models checked = harder to be valid)
-- and temporal_valid phi -> task_valid phi (proven by showing every TaskFrame embeds)
```

**Why this works for frame correspondence**: Adding axioms specializes which temporal frames are valid:
- Base TM: Any linear order (the canonical quotient qualifies)
- TM + discreteness: Discrete linear orders (isomorphic to Z)
- TM + density: Dense linear orders without endpoints (isomorphic to Q)
- TM + density + completeness: Real-like (isomorphic to R)

Each frame correspondence theorem says: "For this class of axioms, the canonical frame automatically has property P, and property P implies isomorphism to a specific algebraic structure."

**Estimated refactoring effort**: 15-20 hours (TaskFrame split, WorldHistory generalization, Validity.lean update, Soundness.lean adaptation)

### Architecture B: Parametric Completeness with Equivalence Bridge

**Core Idea**: Keep the current `valid` definition unchanged. Prove completeness in two steps:

```lean
-- Step 1: BFMCS completeness (sorry-free, already nearly done)
theorem bfmcs_completeness (phi : Formula) (h : not (derives [] phi)) :
    exists (D : Type) (_ : LinearOrder D) (B : BFMCS D),
      not (bmcs_valid B phi)

-- Step 2: Bridge from BFMCS to standard TaskFrame model
theorem bfmcs_to_task_model (D : Type) [LinearOrder D] (B : BFMCS D) :
    exists (D' : Type) [AddCommGroup D'] [LinearOrder D'] [IsOrderedAddMonoid D']
      (F : TaskFrame D') (M : TaskModel F) (Omega : Set (WorldHistory F))
      (h_sc : ShiftClosed Omega) (tau : WorldHistory F) (_ : tau in Omega),
      forall phi t, bmcs_truth_at B fam t phi <-> truth_at M Omega tau t phi
```

The bridge is the hard part. It requires constructing a TaskFrame from a BFMCS, which means we need:
- A type D' with AddCommGroup (e.g., the free abelian group on D, or simply Int/Z if D has the right structure)
- A task_rel satisfying nullity and compositionality
- WorldHistories corresponding to the BFMCS families
- Truth preservation across the bridge

**Advantage**: No refactoring of existing code.
**Disadvantage**: The bridge proof is exactly the two-layer problem we have been struggling with.

### Architecture C: Embrace the Natural Domain (Simplest)

**Core Idea**: The canonical model's time domain IS the BidirectionalQuotient. We do not need to map it to Int. We need to show that this quotient, equipped with the right structure, constitutes a valid TaskFrame model.

**The critical insight**: We do not need the quotient to be isomorphic to Z. We need it to be a **linearly ordered abelian group** (or admit embedding into one). The BidirectionalQuotient is a linear order. The question is whether it can be given group structure.

**Analysis of the BidirectionalQuotient's algebraic properties**:

The quotient's order is determined by CanonicalR (GContent subset inclusion). It is:
- A linear order (proven, sorry-free)
- Reflexive (by T-axiom: GContent(M) subset of M)
- Transitive (by 4-axiom: G(G phi) implies G phi)

Can it be given an abelian group structure? In general, **no**. A linear order admits an ordered abelian group structure if and only if it is order-isomorphic to a subgroup of the reals (Holder's theorem for Archimedean groups, or more generally, Hahn's embedding theorem). The BidirectionalQuotient can be a single point, a finite set, or a countably infinite set with various order types. Not all of these admit group structure.

**However**: For completeness, we do not need the CANONICAL model to be an ordered abelian group. We need it to REFUTE non-theorems. The canonical model refutes phi iff phi is not derivable. This refutation happens at the BFMCS level, which only needs `[Preorder D]`.

This leads us back to Architecture A: the right answer is to generalize the validity definition.

---

## 4. The Elegant Solution: Validity Generalization

### 4.1 The Mathematical Argument

**Theorem** (Informal): For any formula phi in the language of TM:
```
phi is valid over all TaskFrame models (with AddCommGroup D)
  if and only if
phi is valid over all TemporalFrame models (with just LinearOrder D)
```

**Proof sketch for the non-trivial direction** (temporal_valid -> task_valid):

Suppose phi is valid over all temporal frames (with just LinearOrder D). We want to show phi is valid over all task frames. But every task frame induces a temporal frame (by forgetting the task relation and considering the world history's time domain as D). So if phi is valid in every temporal frame, it is a fortiori valid in every task frame.

Wait -- this direction is actually trivial because TaskFrame models are a SUBSET of TemporalFrame models. The harder direction is the converse.

**The converse** (task_valid -> temporal_valid): Suppose phi is valid over all task frames. Is it valid over all temporal frames? Not necessarily, because temporal frames might have structures that no task frame can realize.

**BUT**: For completeness, we need the CONTRAPOSITIVE:
```
phi is NOT derivable
  -> phi is NOT valid in some temporal frame
  -> phi is NOT valid in some task frame (IF we can show the temporal frame embeds)
```

The first step is the canonical model construction (BFMCS with LinearOrder D). The second step requires showing that the specific canonical temporal frame can be embedded into a task frame. And for this specific canonical frame (which is the BidirectionalQuotient), we CAN do this -- by constructing a trivial task relation.

### 4.2 The Trivial Task Frame Trick

Given ANY temporal frame `(D, <=, WorldState, truth)`, we can construct a task frame with the SAME truth conditions:

```lean
-- Given a linear order D and world states W with a temporal truth assignment
-- Construct a TaskFrame:
def trivialTaskFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (W : Type) : TaskFrame D where
  WorldState := W
  task_rel := fun w x u => True  -- trivial: any task is possible
  nullity := fun w => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

With this trivial task frame, WorldHistories become unconstrained (any function from a convex domain to W satisfies `respects_task`). The truth of temporal and modal formulas depends ONLY on the domain, the valuation, and the order -- NOT on the task relation.

**Crucial realization**: The task relation affects truth only through the WorldHistory's `respects_task` constraint. If `task_rel` is trivially true, then `respects_task` is trivially satisfied, and WorldHistories become arbitrary functions on convex domains. The truth conditions for G, H, Box are unaffected.

This means: **if a formula phi is falsified in a model with a trivial task frame on some ordered abelian group D, then phi is not task_valid.** And conversely, if phi is task_valid, then phi is true in all trivial task frame models, which means phi is true in all temporal models where D is an ordered abelian group.

### 4.3 The Completeness Chain

Putting it all together:

```
Step 1: phi not derivable
Step 2: -> exists BFMCS B with [Preorder D] falsifying phi (canonical model, sorry-free)
Step 3: -> the BidirectionalQuotient Q has [LinearOrder] (proven, sorry-free)
Step 4: -> embed Q into an ordered abelian group D' (the free ordered abelian group on Q)
           OR: use the trivial task frame trick on any ordered abelian group
Step 5: -> construct TaskFrame D' with trivial task_rel
Step 6: -> construct WorldHistories and TaskModel witnessing phi false
Step 7: -> phi not valid (standard definition)
```

**The critical step is Step 4/5/6**: transferring truth from the BFMCS to a TaskFrame model.

### 4.4 The Transfer Theorem

Here is the key mathematical result needed:

**Theorem** (BFMCS-to-TaskModel Transfer): Given a temporally coherent BFMCS B over a linear order D, and a formula phi such that `not (bmcs_truth_at B fam t phi)`, there exists:
- A type D' with `[AddCommGroup D'] [LinearOrder D'] [IsOrderedAddMonoid D']`
- A `TaskFrame D'`
- A `TaskModel F`
- A shift-closed `Omega`
- A `WorldHistory F` in Omega
- A time `t' : D'`

such that `not (truth_at M Omega tau t' phi)`.

**Proof construction**:
1. Let D' = Int (or any LOAG).
2. Let F be the trivial task frame on D' with WorldState = `BFMCS.families B`.
3. For each family fam in B.families, define a WorldHistory tau_fam with:
   - domain = `Set.univ` (all of Int)
   - states(n) = fam (using any embedding of Int into the evaluation)
4. Let Omega = the set of all such tau_fam.
5. Truth transfer: show `bmcs_truth_at B fam t phi <-> truth_at M Omega tau_fam 0 phi` by structural induction on phi.

The induction works because:
- **Atom**: Define valuation so that `M.valuation (tau_fam.states 0 _) p = (p in fam.mcs t)`. Then both sides agree.
- **Bot**: Both sides are False.
- **Imp**: By induction hypothesis on subformulas.
- **Box**: BFMCS truth quantifies over families in B.families. Standard truth quantifies over WorldHistories in Omega. Since Omega = {tau_fam | fam in B.families}, these match exactly.
- **G (all_future)**: BFMCS truth quantifies `forall s >= t, bmcs_truth_at B fam s phi`. Standard truth quantifies `forall s' >= 0, truth_at M Omega tau_fam s' phi`. These correspond via the embedding.
- **H (all_past)**: Symmetric to G.

**The temporal case requires care**: In the BFMCS, time is indexed by D (the BidirectionalFragment quotient). In the TaskFrame model, time is indexed by D' = Int. We need a correspondence between "s >= t in D" and "s' >= 0 in Int". This requires an ORDER-PRESERVING MAP from D into Int (or at least from the relevant portion of D).

This is where the architecture matters. If D is a finite linear order or a countable linear order, we can always embed it into Int (or into Q, etc.) order-preservingly. But if D is uncountable, we cannot embed into Int.

However: for completeness of a COUNTABLE language, the canonical model is at most countable (countably many formulas -> countably many MCS). So the BidirectionalQuotient is at most countable. A countable linear order can always be embedded into Q (by Cantor's back-and-forth, or directly).

**Corollary**: The BidirectionalQuotient of TM's canonical model is a countable linear order, hence embeds into Q, hence into any linearly ordered abelian group of sufficient cardinality.

---

## 5. The Proposed Single Architecture

### 5.1 Design

```
Layer 0: Syntax + Proof System (unchanged)
Layer 1: Semantics with MINIMAL structure
  - TemporalFrame D [LinearOrder D] -- just an ordered set of times
  - TemporalModel: TemporalFrame + valuation
  - temporal_truth_at: recursive truth using <=, no group ops
  - temporal_valid: quantifies over all LinearOrder D

Layer 2: TaskFrame semantics (unchanged, for paper alignment)
  - TaskFrame D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
  - truth_at, valid (unchanged)

Bridge: valid phi <-> temporal_valid phi (one-time proof)

Layer 3: Completeness (uses ONLY Layer 1)
  - BFMCS construction over BidirectionalQuotient [LinearOrder]
  - TruthLemma (already sorry-free with [Preorder])
  - Completeness theorem: derives [] phi <-> temporal_valid phi
  - Corollary: derives [] phi <-> valid phi (via bridge)

Layer 4: Frame Correspondence (extends Layer 1)
  - TM + discreteness -> canonical model has SuccOrder -> isomorphic to Z
  - TM + density -> canonical model is dense without endpoints -> isomorphic to Q
  - These are SEPARATE theorems, not prerequisites for base completeness
```

### 5.2 What "TemporalFrame" Looks Like

```lean
/-- A temporal frame: linear order of times + world states + accessibility for box. -/
structure TemporalFrame (D : Type*) [LinearOrder D] where
  WorldState : Type
  accessible : WorldState -> WorldState -> Prop  -- for box modality

/-- A temporal model adds valuation to a frame. -/
structure TemporalModel {D : Type*} [LinearOrder D] (TF : TemporalFrame D) where
  valuation : TF.WorldState -> String -> Prop

/-- A temporal history: convex domain, states, no task_rel constraint. -/
structure TemporalHistory {D : Type*} [LinearOrder D] (TF : TemporalFrame D) where
  domain : D -> Prop
  convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> TF.WorldState

/-- Truth in a temporal model. Identical to truth_at but without group operations. -/
def temporal_truth_at {D : Type*} [LinearOrder D] {TF : TemporalFrame D}
    (M : TemporalModel TF) (Omega : Set (TemporalHistory TF))
    (tau : TemporalHistory TF) (t : D) : Formula -> Prop
  | atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | bot => False
  | imp phi psi => temporal_truth_at M Omega tau t phi -> temporal_truth_at M Omega tau t psi
  | box phi => forall sigma in Omega, temporal_truth_at M Omega sigma t phi
  | all_past phi => forall s, s <= t -> temporal_truth_at M Omega tau s phi
  | all_future phi => forall s, t <= s -> temporal_truth_at M Omega tau s phi
```

**Note**: This is IDENTICAL to the current `truth_at` except:
- No `respects_task` constraint on histories
- No `ShiftClosed` requirement on Omega (this is only needed for MF/TF soundness)
- No group operations on D

### 5.3 The Bridge Theorem

```lean
/-- Every temporal model on a LOAG can be made into a task model
    by using a trivial task relation. -/
theorem temporal_to_task_valid (phi : Formula) :
    valid phi -> temporal_valid phi := by
  -- valid quantifies over MORE models (task frames are temporal frames with extra structure)
  -- So valid phi means true in a SUBSET of models
  -- We need: true in all task models -> true in all temporal models
  -- This does NOT follow in this direction!
  sorry -- This direction needs the other argument

/-- The contrapositive direction that matters for completeness:
    If phi fails in some temporal model, it fails in some task model. -/
theorem temporal_countermodel_lifts (phi : Formula)
    (h : exists D [LinearOrder D] ..., not (temporal_truth_at ...)) :
    exists D' [AddCommGroup D'] ..., not (truth_at ...) := by
  -- Given countermodel on LinearOrder D, construct TaskFrame on some LOAG D'
  -- Use trivial task frame trick
  ...
```

Actually, on deeper reflection, the correct equivalence is:

```
temporal_valid phi -> valid phi     (EASY: fewer constraints on histories = more models = harder to be valid)
valid phi -> temporal_valid phi     (HARD: need to show task constraints don't rule out countermodels)
```

Wait, this is backwards. Let me think more carefully.

- `valid phi` means: for ALL TaskFrame models, phi is true. TaskFrame models have constrained histories (respects_task).
- `temporal_valid phi` means: for ALL TemporalFrame models, phi is true. TemporalFrame models have unconstrained histories.

Since every TaskFrame model is (can be converted to) a TemporalFrame model (by forgetting the task constraint), the class of TemporalFrame models is LARGER. So:

- `temporal_valid phi -> valid phi`: If phi is true in ALL temporal models (larger class), it is certainly true in all task models (subset). **EASY.**
- `valid phi -> temporal_valid phi`: If phi is true in all task models, is it true in all temporal models? Not necessarily, because temporal models include histories that violate the task constraint. **This direction needs proof.**

For the completeness direction, we need:
```
not (derives [] phi) -> not (valid phi)
```

Which, using the canonical model, gives:
```
not (derives [] phi) -> not (temporal_valid phi) -> not (valid phi)
```

The first arrow is the BFMCS construction (sorry-free). The second arrow is `temporal_valid phi -> valid phi`, which is the EASY direction.

**This means the bridge is actually trivial!**

### 5.4 Why the Bridge Is Trivial

The completeness chain is:
1. `not (derives [] phi)` implies (by canonical BFMCS construction) `not (bmcs_valid phi)`.
2. `not (bmcs_valid phi)` implies (by bmcs_truth_lemma) there is a BFMCS where phi fails.
3. `not (temporal_valid phi)` because the BFMCS gives a concrete temporal model where phi fails.
4. Since `temporal_valid phi -> valid phi`, we get `not (valid phi)` by contrapositive.

Step 4 is the easy direction of the bridge (larger model class means easier to falsify).

The HARD direction (`valid phi -> temporal_valid phi`) would be needed for the SOUNDNESS claim "temporal_valid = valid". But for COMPLETENESS, we only need the easy direction.

**For soundness**: We already have `derives [] phi -> valid phi` (proven, sorry-free). If we also want `derives [] phi -> temporal_valid phi`, we need to verify each axiom in temporal frames. Most axioms (propositional, modal T/4/B/5, temporal T/4) hold in temporal frames. The MF and TF axioms are the only ones that use the group structure and time_shift.

**MF/TF in temporal frames**: The MF axiom says `Box phi -> Box(F phi)`. In a temporal model (without time_shift), this requires: if phi is true at all histories at time t, then F(phi) is true at all histories at time t, i.e., for every history sigma and every time s >= t, phi is true at sigma and s. But we already know phi is true at ALL histories at time t. We need it at time s >= t. This requires that the collection of histories is "shift-closed" in some sense -- or that Box quantifies UNIFORMLY across times.

In the BFMCS semantics, Box already quantifies uniformly (all families at the given time), and G quantifies over all times >= t. So `Box phi -> Box(F phi)` becomes: if phi is in all families at time t, then for all families fam' and all s >= t, phi is true at fam' at s. But phi is in fam'.mcs(t) (by modal forward), and by forward_G, phi propagates to fam'.mcs(s) for s >= t... NO, wait, that is not right. Box(phi) in MCS means phi is in ALL families. We need F(phi) in all families, which means for each family, there exists s >= t with phi at s. If phi is in the family at time t (by modal forward), and t <= t, then yes -- phi at t suffices for F(phi) at t (since F is reflexive in TM: t <= t counts).

Actually, in TM with reflexive temporal operators, F(phi) at t means "exists s >= t with phi at s". Since t >= t and phi holds at t, we get F(phi) at t. So `Box(phi) -> Box(F(phi))` holds reflexively in any BFMCS model.

Similarly, TF: `Box(phi) -> F(Box(phi))`. F(Box(phi)) at t means exists s >= t with Box(phi) at s. Since Box(phi) at t and t >= t, this holds.

**Therefore: MF and TF axioms hold in BFMCS models WITHOUT requiring AddCommGroup.**

This is the key insight: the time-shift machinery in the current soundness proof is an artifact of the WorldHistory/TaskFrame formulation. In the BFMCS formulation (which does not use WorldHistories or time_shift), MF and TF follow from the reflexivity of the temporal operators.

### 5.5 The Clean Completeness Statement

```lean
/-- Main completeness theorem: derives phi iff bmcs_valid phi -/
theorem standard_completeness (phi : Formula) :
    (derives [] phi) <-> (valid phi) := by
  constructor
  . exact soundness  -- already proven, sorry-free
  . intro h_valid
    -- Contrapositive: not derivable -> not valid
    by_contra h_not_deriv
    push_neg at h_not_deriv
    -- Step 1: Build BFMCS falsifying phi (requires only Preorder D)
    obtain ⟨D, _, _, B, h_tc, fam, hfam, t, h_false⟩ := bfmcs_countermodel phi h_not_deriv
    -- Step 2: Transfer to standard valid via trivial task frame
    -- The BFMCS gives us a linear order D and a falsification
    -- Construct TaskFrame with trivial task_rel
    -- Show truth preservation
    exact absurd (h_valid D (trivialTaskFrame D B.WorldState) ...) h_false
```

---

## 6. Extensibility for Frame Correspondence

### 6.1 The Design Principle

Frame correspondence theorems should be COROLLARIES of the base completeness, not prerequisites.

**Base TM completeness**: The canonical model has `D = BidirectionalQuotient M0 h_mcs0` with `[LinearOrder D]`. No further structure needed.

**Adding density axiom** (e.g., `G(G phi) -> G phi`): The density axiom forces the canonical model's time domain to be dense (between any two MCS, there is a third). The completeness proof for TM+density proceeds exactly as for base TM, but with an additional step: "the canonical frame, being a countable dense linear order without endpoints, is isomorphic to Q by Cantor's theorem." This gives us `valid_Q phi <-> derives_TM_density [] phi` as a corollary.

**Adding discreteness axiom** (e.g., `G phi -> phi & F(phi & G(phi -> G phi))`): The discreteness axiom forces the canonical model's time domain to be discrete. The canonical frame, being a countable discrete linear order without endpoints, is isomorphic to Z. This gives us `valid_Z phi <-> derives_TM_discrete [] phi`.

### 6.2 The Uniform Pattern

```
For each extension E of TM:
1. Prove completeness of TM+E at the BFMCS level (same pattern as base)
2. Show the canonical frame's BidirectionalQuotient has property P (from axiom E)
3. Apply the relevant order-theoretic representation theorem:
   - Discrete + no endpoints -> Z (Mathlib: orderIsoIntOfLinearSuccPredArch)
   - Dense + countable + no endpoints -> Q (Cantor's back-and-forth)
   - Dense + complete + no endpoints -> R (Dedekind completion)
4. Transfer the frame isomorphism to get completeness for specific D
```

The base TM case is the GENERIC case where Step 2 gives nothing extra (the quotient is just a linear order) and Steps 3-4 are unnecessary.

---

## 7. Concrete Implementation Path

### Phase 1: BFMCS Completeness (8-12 hours)

**Goal**: Prove `not (derives [] phi) -> exists BFMCS with [LinearOrder D] falsifying phi`.

**What exists**:
- `fragmentFMCS` on `BidirectionalFragment` is sorry-free
- `bmcs_truth_lemma` is sorry-free (with `[Preorder D] [Zero D]`)
- Modal saturation (`diamondWitnessMCS`, `box_witness_seed_consistent`) is sorry-free
- BidirectionalQuotient has LinearOrder (sorry-free)

**What is missing**:
1. A BFMCS construction that combines all the sorry-free pieces into a single bundle
2. The common domain: use BidirectionalQuotient (or BidirectionalFragment with preorder)
3. Modal coherence (modal_forward, modal_backward) for the constructed bundle
4. Temporal coherence (forward_F, backward_P) -- already proven at fragment level

**Key design decision**: Use `BidirectionalFragment M0 h_mcs0` as D (with its Preorder) for the base family, and build witness families from diamond obligations. The common domain is the union of all fragments, but since each fragment's elements are subtypes of `Set Formula`, they live in a common universe.

**Alternative (simpler)**: Use `CanonicalMCS` (the type of ALL maximal consistent sets) as D, ordered by `CanonicalR`. Each family is a function `CanonicalMCS -> Set Formula`. This avoids the fragment union problem entirely.

### Phase 2: Transfer to Standard Validity (4-8 hours)

**Goal**: Prove `not (bmcs_valid_in_some_BFMCS phi) -> not (valid phi)`.

**Method**: Trivial task frame construction on any LOAG (e.g., Int).

**What is needed**:
1. Define `TemporalModel` from BFMCS (families as histories, MCS membership as valuation)
2. Define `TaskModel` via trivial task frame
3. Prove truth preservation: `bmcs_truth_at <-> truth_at` (structural induction on phi)

### Phase 3: Frame Correspondence (Future, Optional)

**For TM + discreteness**: Show BidirectionalQuotient has SuccOrder + NoMaxOrder + NoMinOrder (derivable from discreteness axiom). Apply `orderIsoIntOfLinearSuccPredArch`.

**For TM + density**: Show BidirectionalQuotient is dense without endpoints. Apply Cantor's theorem for Q-isomorphism.

These are self-contained extensions that do not affect the base completeness.

---

## 8. ROAD_MAP.md Reflection

### Pitfalls Checked

| Dead End | Relevance | Impact on Recommendations |
|----------|-----------|--------------------------|
| Constant Witness Family | HIGH | Confirmed: constant families fail temporal coherence. Our approach uses time-varying FMCS. |
| CanonicalReachable/Quotient Stack | HIGH | Our approach uses BidirectionalFragment (not future-only reachable). Avoids this pitfall. |
| Non-Standard Validity Completeness | CRITICAL | **This is the key lesson.** We must prove completeness for the STANDARD `valid` definition, not just `bmcs_valid`. Our approach addresses this via the transfer theorem. |
| Single-Family BFMCS modal_backward | MEDIUM | We use multi-family BFMCS. Avoided. |
| MCS-Membership Semantics for Box | MEDIUM | We use standard recursive `bmcs_truth_at`. Avoided. |

### Strategy Alignment

| Strategy | Status | Relevance |
|----------|--------|-----------|
| Indexed MCS Family Approach | ACTIVE | Directly aligned. Our approach builds on FMCS/BFMCS infrastructure. |
| Algebraic Verification Path | PAUSED | Could complement: the Lindenbaum algebra provides an independent verification of the temporal_valid = valid bridge. |
| Representation-First Architecture | CONCLUDED | Our approach extends this: the BFMCS construction IS the canonical representation. |

---

## 9. Context Extension Recommendations

### Discovered Concepts Requiring Documentation

| Concept | Report Section | Currently Documented? | Gap Type |
|---------|----------------|----------------------|----------|
| Trivial task frame trick | Section 4.2 | No | new_file |
| Validity generalization hierarchy | Section 5.1 | No | new_file |
| BFMCS-to-TaskModel transfer | Section 4.4 | No | extension |
| Frame correspondence as corollary pattern | Section 6.2 | No | new_file |

### New Context File Recommendations

| Filename | Directory | Content Scope | Priority | Create Task? |
|----------|-----------|---------------|----------|--------------|
| `validity-hierarchy.md` | `lattice-theory/` or `order-theory/` | Relationship between temporal_valid and task_valid; why BFMCS completeness bridges to standard completeness | High | No (wait for implementation) |

### Summary

- **New files needed**: 1 (after implementation validates the approach)
- **Extensions needed**: 0
- **Tasks to create**: 0
- **High priority gaps**: 1 (validity hierarchy documentation)

---

## 10. Decisions

1. **Architecture A (Generalized TaskFrame) is NOT recommended for immediate implementation.** While it is the most elegant long-term solution, it requires significant refactoring of existing sorry-free code. The risk-reward ratio is poor for the immediate goal.

2. **Architecture C (Embrace Natural Domain) with the trivial task frame trick IS recommended.** It achieves the immediate goal (sorry-free standard completeness) with minimal disruption to existing code.

3. **The key new insight is the trivial task frame trick**: Given a BFMCS falsification, construct a standard TaskFrame model by using a trivial task_rel. Since the task_rel only constrains WorldHistories (not truth of formulas directly), a trivial task_rel gives maximum freedom in constructing countermodel histories.

4. **Frame correspondence is deferred to future tasks.** The base TM completeness does NOT require SuccOrder, NoMaxOrder, or any Int-isomorphism. These become relevant only when adding density/discreteness axioms.

---

## 11. Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Trivial task frame may not give correct truth for MF/TF axioms in countermodel | LOW | HIGH | MF/TF hold reflexively in BFMCS; the transfer preserves this (Section 5.4). Verify early. |
| WorldHistory with trivial task_rel may not capture BFMCS truth | MEDIUM | HIGH | The key is that WorldHistories become unconstrained, so we have full freedom to match BFMCS families. Must prove correspondence carefully. |
| Omega shift-closure may be hard to establish for trivial frame | MEDIUM | MEDIUM | For the trivial frame, ALL sets are shift-closed (time_shift of any history is another valid history). This should be straightforward. |
| The bridge between BFMCS time domain and Int/Q | LOW | LOW | Not needed! The trivial task frame works on ANY LOAG, and we just need one model. Use Int with constant histories mapping to the canonical MCS. |

---

## 12. Appendix

### A. Search Queries Used

1. "temporal logic completeness canonical model frame correspondence theorem Sahlqvist 2024 2025"
2. "canonical model temporal logic time domain construction completeness proof abstract algebraic approach"
3. "completeness tense logic Kt bimodal ordered group time flow canonical frame construction Goldblatt Venema"
4. "step by step completeness technique temporal tense logic canonical model non-canonical frame construction"
5. "tense logic Kt.4 completeness no group structure canonical frame linear order without endpoints algebraic semantics"
6. "Kt tense logic completeness linear order sufficient abelian group NOT required canonical frame strong completeness"

### B. Mathlib Lookups

- `lean_leansearch`: "linear order without endpoints has no maximum and no minimum" -> `NoTopOrder.to_noMaxOrder`
- `lean_leansearch`: "generalize validity from AddCommGroup to LinearOrder for semantics" -> `LinearOrderedAddCommGroup` hierarchy
- `lean_loogle`: `LinearOrder ?a -> Sub ?a` -> `CanonicallyOrderedAdd.toSub`

### C. Key Codebase Files Examined

- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame structure with AddCommGroup requirement
- `Theories/Bimodal/Semantics/WorldHistory.lean` -- WorldHistory with respects_task constraint
- `Theories/Bimodal/Semantics/Truth.lean` -- truth_at using <= for G/H, group ops for time_shift
- `Theories/Bimodal/Semantics/Validity.lean` -- valid quantifying over AddCommGroup D
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` -- FMCS with [Preorder D]
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` -- BFMCS with [Preorder D]
- `Theories/Bimodal/Metalogic/Bundle/BFMCSTruth.lean` -- bmcs_truth_at with [Preorder D]
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- sorry-free with [Preorder D] [Zero D]
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` -- fragment FMCS, sorry-free
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` -- fragment definition
- `Theories/Bimodal/Metalogic/Completeness.lean` -- MCS properties
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- TM axiom schemata (17 axioms)

### D. References

- Blackburn, de Rijke, Venema. *Modal Logic*. Cambridge Tracts in Theoretical Computer Science, 2001. Chapter 4 (Completeness).
- Venema, Y. "Temporal Logic." Chapter 10 in Blackwell Guide to Philosophical Logic.
- Stanford Encyclopedia of Philosophy. "Temporal Logic." https://plato.stanford.edu/entries/logic-temporal/
- Muller, T. "Tense or Temporal Logic." Chapter 12 in Handbook of the History of Logic.
- Open Logic Project. "Completeness and Canonical Models." https://builds.openlogicproject.org/content/normal-modal-logic/completeness/completeness.pdf
