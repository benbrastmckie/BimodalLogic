# Research Report: Task #865

**Task**: Canonical task frame for bimodal completeness
**Date**: 2026-02-05
**Focus**: Research and construct a canonical task frame (world-states, task relation, durations) for the Bimodal logic representation theorem. Analyze the two-place task relation w => u, duration construction from syntax, three-place task relation matching semantics, topology from task relation, and seed construction culminating in the TruthLemma.

## Summary

This report investigates how to construct a canonical task frame for the bimodal TM logic representation theorem, bridging the gap between the proven BMCS truth lemma (which operates on indexed MCS families) and the standard task-frame semantics (which requires world-states, durations, and a three-place task relation). The core challenge is: the codebase's completeness proof works at the level of MCS families with temporal coherence conditions, but the task-frame semantics expects structured objects (TaskFrame, WorldHistory, truth_at). The report proposes a construction pathway that starts from a consistent formula, builds a seed of MCS families via the recursive approach from Task 864, and then interprets this bundle as a task frame by defining durations as elements of the ordered group indexing the MCS families, world-states as MCS-indexed states, and the task relation as the temporal coherence condition between MCS assignments.

## 1. Current Codebase Semantics Inventory

### 1.1 Task Frame Structure (TaskFrame.lean)

The codebase defines task frames polymorphically over a duration type `D`:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

Key features:
- **Three-place task relation**: `task_rel w d u` means "from world-state w, a task of duration d can result in world-state u."
- **Nullity**: Zero-duration tasks are reflexive.
- **Compositionality**: Sequential tasks compose with additive time.
- **Polymorphic over D**: The duration type can be Int, Rat, Real, or any `LinearOrderedAddCommGroup`.

### 1.2 World Histories (WorldHistory.lean)

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall s t (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

Key features:
- **Convex domains**: No temporal gaps.
- **Task-respect**: For any s <= t in the domain, the states at s and t are related by the task relation with duration `t - s`.

### 1.3 Truth Evaluation (Truth.lean)

```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```

Key observations:
- **Box** quantifies over ALL world histories in the frame (S5 modal structure).
- **Temporal operators** quantify over ALL times in D (not just domain times).
- **Atoms** are false outside the history's domain.
- Temporal operators use reflexive semantics (includes present).

### 1.4 Validity (Validity.lean)

Validity quantifies over ALL temporal types D, all task frames, all models, all histories, and all times. This is fully polymorphic.

### 1.5 BMCS Completeness Architecture (Bundle/)

The current completeness proof operates at a DIFFERENT level from task-frame semantics:

| Component | BMCS Level | Task-Frame Level |
|-----------|------------|------------------|
| World-states | MCS (maximal consistent sets) | `F.WorldState` |
| Time | Direct indexing by D | Duration group D |
| Modal access | Bundle families | WorldHistory quantification |
| Temporal access | Forward_G/backward_H coherence | Temporal quantification over D |
| Truth definition | `bmcs_truth_at` (MCS membership) | `truth_at` (recursive on formula) |
| Valuation | Atom membership in MCS | `M.valuation w p` |

The BMCS truth lemma is:
```lean
theorem bmcs_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi in fam.mcs t <-> bmcs_truth_at B fam t phi
```

This has been proven for all six formula cases (atom, bot, imp, box, G, H) with no sorry in the main theorem itself. However, the construction depends on two axioms:
- `temporally_saturated_mcs_exists` (mathematically FALSE per Task 843 finding)
- `singleFamily_modal_backward_axiom` (mathematically FALSE)

### 1.6 Gap: From BMCS to Task-Frame Semantics

There is currently NO bridge connecting:
- `bmcs_truth_at B fam t phi` (the BMCS-level truth)
- `truth_at M tau t phi` (the task-frame-level truth)

The completeness theorems (`bmcs_weak_completeness`, `bmcs_strong_completeness`) are stated in terms of `bmcs_valid` and `bmcs_consequence`, NOT in terms of the standard `valid` and `semantic_consequence` from Validity.lean. This is the gap that a canonical task frame construction would close.

## 2. The Two-Place Task Relation w => u

### 2.1 Definition

Following the research focus, define a two-place task relation between MCSs:

```
w => u  iff  (1) phi in u whenever Box_G phi in w
         and (2) phi in w whenever Box_H phi in u
```

where `Box_G phi = all_future phi` (G phi) and `Box_H phi = all_past phi` (H phi).

In codebase terms:
```lean
def task_rel_2 (w u : Set Formula) (hw : SetMaximalConsistent w) (hu : SetMaximalConsistent u) : Prop :=
  (forall phi, Formula.all_future phi in w -> phi in u) /\
  (forall phi, Formula.all_past phi in u -> phi in w)
```

### 2.2 Witness Conditions (GW) and (HW)

The task relation also requires witness conditions:
- **(GW)**: If phi in u whenever w => u, then G phi in w.
- **(HW)**: If phi in w whenever w => u, then H phi in u.

These are the CONVERSE conditions. They state that if phi is true at ALL task-successors of w, then G phi holds at w. This is exactly the backward direction of the TruthLemma for temporal operators.

### 2.3 Connection to Existing Infrastructure

The existing `IndexedMCSFamily` already captures the two-place task relation implicitly:
- `forward_G`: G phi in fam.mcs t -> phi in fam.mcs t' for t' > t (condition 1)
- `backward_H`: H phi in fam.mcs t -> phi in fam.mcs t' for t' < t (condition 2)

The witness conditions correspond to:
- `temporal_backward_G`: (forall s >= t, phi in fam.mcs s) -> G phi in fam.mcs t
- `temporal_backward_H`: (forall s <= t, phi in fam.mcs s) -> H phi in fam.mcs t

These are proven in TemporalCoherentConstruction.lean using `forward_F`/`backward_P` by contraposition.

### 2.4 Key Insight: The Two-Place Relation Is Internal to a Family

Within a single IndexedMCSFamily, the MCSs at different times are related by the two-place task relation. If we define:

```
w_t := fam.mcs t  (the MCS at time t)
```

Then for t <= s:
- w_t => w_s holds (by forward_G and backward_H)

This means each IndexedMCSFamily already defines a TIME-INDEXED CHAIN of MCSs that respect the two-place task relation.

## 3. Duration Construction from Syntax

### 3.1 The Problem

The task-frame semantics requires a specific duration type D (a totally ordered commutative group) and a three-place task relation `task_rel w d u`. The question is: how to construct D from syntactic data?

### 3.2 Failed Approach: Grothendieck Group (Boneyard)

The codebase's DurationConstruction.lean documents a failed approach using:
- Chain segments of MCS
- Order-type equivalence on segments
- Grothendieck group completion

This had 15+ sorry gaps and was deprecated in favor of FiniteTime. The approach was overly complex for the actual need.

### 3.3 Simplest Approach: Use the Indexing Group Directly

The BMCS completeness proof already parameterizes over a duration type D. For the representation theorem, this is instantiated with `Int` (integer time). The canonical task frame can simply USE the same D as the duration type.

Key insight: **We do not need to construct durations from syntax.** The MCS families are already indexed by D, and the task relation can be defined in terms of MCS membership at different D-indices.

### 3.4 The Proposed Duration Construction

For the canonical task frame, set:
- **D = Int** (matching the BMCS instantiation in Completeness.lean)
- **Duration between time t and time s** = `s - t` (using the group operation)

This is not "constructing durations from syntax" in a deep sense; rather, it is choosing the simplest adequate duration group and using the BMCS-level temporal structure to define the task relation.

### 3.5 Alternative: Durations as Equivalence Classes (Topology Approach)

The research focus mentions using the two-place task relation to construct a topology where "closeness is with respect to possible nearness in time" and abstracting durations as equivalence classes. Here is how this could work:

**Definition**: For MCSs w, u, define:
```
d(w, u) = the equivalence class of (t_u - t_w) for any family where w = fam.mcs(t_w) and u = fam.mcs(t_u)
```

**Problem**: The same MCS can appear at different times in different families (or even the same family at different times if using a constant family). The "duration" between w and u is NOT well-defined unless the family and time assignment are fixed.

**Resolution**: Durations should be defined relative to a SPECIFIC world history (family), not globally. Within a single IndexedMCSFamily, the duration between fam.mcs(t) and fam.mcs(s) is canonically `s - t`. This matches the task-frame semantics where `respects_task` gives `task_rel (states s) (t - s) (states t)`.

### 3.6 Topology from the Task Relation

The two-place task relation w => u defines a partial order (or preorder) on MCSs. Within a single family, the MCSs are totally ordered by time. The topology induced by this total order is the standard order topology on D (= Int, Rat, or Real depending on the chosen duration group).

The "closeness" between MCSs is captured by the temporal distance |t_u - t_w| within a given family. Two MCSs that are "close" in this topology share many formulas (by the T-axioms and temporal K-distribution). Specifically, if G phi in fam.mcs(t), then phi in fam.mcs(t') for all t' > t, so all future MCSs "agree with" the current one on G-formulas.

However, this topology does not add anything beyond what the linear order on D already provides. The interesting topology would arise from MULTI-FAMILY structure (where different families can assign different MCSs to the same time), but this is the modal dimension, not the temporal dimension.

## 4. Three-Place Task Relation from the Two-Place Relation

### 4.1 The Construction

Given:
- An IndexedMCSFamily `fam` with MCS assignment `fam.mcs : D -> Set Formula`
- The two-place task relation w => u defined by G/H propagation

Define the three-place task relation:

```lean
def canonical_task_rel (B : BMCS D)
    (w : CanonicalWorldState) (d : D) (u : CanonicalWorldState) : Prop :=
  exists fam in B.families, exists t : D,
    fam.mcs t = w.carrier /\ fam.mcs (t + d) = u.carrier
```

That is: w is related to u by duration d if there exists a family and a time t such that the family assigns MCS w at time t and MCS u at time t + d.

### 4.2 Nullity

For nullity, we need `canonical_task_rel B w 0 w`. Set d = 0, then we need:
```
exists fam in B.families, exists t : D, fam.mcs t = w /\ fam.mcs (t + 0) = w
```

Since `t + 0 = t`, this reduces to `exists fam in B.families, exists t, fam.mcs t = w`. This holds if every canonical world-state is the MCS of some family at some time -- a condition that needs to be ensured by the construction.

**Simplification**: If we restrict world-states to those that actually appear in the BMCS (i.e., `CanonicalWorldState = {w | exists fam in B.families, exists t, fam.mcs t = w}`), then nullity holds by definition.

### 4.3 Compositionality

For compositionality, we need: if `task_rel w x u` and `task_rel u y v`, then `task_rel w (x + y) v`.

Unpacking: there exist `fam1, t1` with `fam1.mcs(t1) = w` and `fam1.mcs(t1 + x) = u`, and `fam2, t2` with `fam2.mcs(t2) = u` and `fam2.mcs(t2 + y) = v`.

**Problem**: The two witnessing families may be DIFFERENT. `fam1.mcs(t1 + x) = u = fam2.mcs(t2)` does not imply that fam1 and fam2 agree at other times. We need `fam.mcs(t1) = w` and `fam.mcs(t1 + x + y) = v` for some SINGLE family fam and time t1.

**Resolution A**: Restrict to single-family compositionality. Within a single family, `fam.mcs(t) = w`, `fam.mcs(t + x) = u`, and `fam.mcs(t + x + y) = v` gives compositionality trivially.

**Resolution B**: Use a stronger task relation that requires the SAME family:
```lean
def canonical_task_rel_strong (fam : IndexedMCSFamily D)
    (w : fam.WorldState) (d : D) (u : fam.WorldState) : Prop :=
  exists t : D, fam.mcs t = w /\ fam.mcs (t + d) = u
```

This gives compositionality within each family but loses the cross-family structure. For the representation theorem, this is acceptable because:
- Each family defines its own task frame.
- The box operator quantifies over all families (= all world histories).
- Cross-family compositionality is not needed for the semantics.

### 4.4 Proposed Canonical Task Frame Per Family

For each family `fam` in the BMCS:

```lean
def canonical_task_frame_of_family (fam : IndexedMCSFamily D) : TaskFrame D where
  WorldState := Set Formula  -- or a bundled type with MCS proof
  task_rel := fun w d u => exists t : D, fam.mcs t = w /\ fam.mcs (t + d) = u
  nullity := fun w => by
    -- Need: exists t, fam.mcs t = w /\ fam.mcs (t + 0) = w
    -- This requires w to be in the range of fam.mcs
    sorry -- requires surjectivity assumption
  compositionality := fun w u v x y h1 h2 => by
    obtain ⟨t1, ht1w, ht1u⟩ := h1
    obtain ⟨t2, ht2u, ht2v⟩ := h2
    -- Need: fam.mcs(t1 + x) = u = fam.mcs(t2) and fam.mcs(t2 + y) = v
    -- If fam.mcs is injective: t1 + x = t2, so t1 + x + y = t2 + y
    -- Then: fam.mcs(t1) = w and fam.mcs(t1 + (x + y)) = v
    sorry -- requires injectivity or functional coherence
```

**Key Assumption**: For compositionality to work, either:
1. `fam.mcs` is injective (different times give different MCSs), OR
2. We identify world-states with (time, MCS) pairs rather than MCSs alone.

Option (2) is cleaner: define `WorldState := D` (time points are the world-states) and `task_rel t d t' := t' = t + d` (trivial frame). Then the "interesting" structure is in the valuation and the world history.

### 4.5 The Trivial Frame Approach

If WorldState = D and task_rel t d t' iff t' = t + d:

```lean
def canonical_trivial_frame : TaskFrame D where
  WorldState := D
  task_rel := fun t d t' => t' = t + d
  nullity := fun t => by simp [add_zero]
  compositionality := fun t u v x y h1 h2 => by
    subst h1; subst h2; ring
```

This is the "identity frame" from TaskFrame.lean (specialized). World histories would be:

```lean
def canonical_history_of_family (fam : IndexedMCSFamily D) : WorldHistory canonical_trivial_frame where
  domain := fun _ => True  -- full domain
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => t  -- the state at time t is t itself
  respects_task := fun s t _ _ h => by
    show t = s + (t - s); ring
```

The valuation assigns truth to atoms based on MCS membership:
```lean
def canonical_valuation (fam : IndexedMCSFamily D) : TaskModel canonical_trivial_frame where
  valuation := fun t p => Formula.atom p in fam.mcs t
```

**Problem**: This makes all world histories have WorldState = D, and the box operator quantifies over ALL such histories. But we need the box operator to range over different MCS families (as in the BMCS), not over all possible functions D -> D.

### 4.6 The BMCS-Indexed Frame Approach (Recommended)

The recommended approach builds the task frame so that:
- **WorldState** is a type encoding both the family index and the time, or equivalently, a type whose inhabitants are the MCSs that appear in the BMCS.
- **Durations** are from D (e.g., Int).
- **Task relation** encodes temporal progression within a family.
- **World histories** correspond to families in the BMCS.

Concretely:

```lean
-- World states are pairs (family index, time index) with MCS data
structure CanonicalWorldState' (B : BMCS D) where
  family : IndexedMCSFamily D
  family_mem : family in B.families
  time : D

def canonical_frame (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldState' B
  task_rel := fun w d u =>
    w.family = u.family /\ u.time = w.time + d
  nullity := fun w => ⟨rfl, by simp [add_zero]⟩
  compositionality := fun w u v x y ⟨h1, h2⟩ ⟨h3, h4⟩ => by
    constructor
    · exact h1.trans h3
    · subst h2; subst h4; ring
```

Each BMCS family becomes a world history in this frame:

```lean
def canonical_world_history (B : BMCS D) (fam : IndexedMCSFamily D) (hmem : fam in B.families) :
    WorldHistory (canonical_frame B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨fam, hmem, t⟩
  respects_task := fun s t _ _ h => ⟨rfl, by ring⟩
```

And the valuation:
```lean
def canonical_model (B : BMCS D) : TaskModel (canonical_frame B) where
  valuation := fun ⟨fam, _, t⟩ p => Formula.atom p in fam.mcs t
```

## 5. The Seed Construction and TruthLemma as North Star

### 5.1 The Seed

A "seed" is a consistent formula phi from which the entire canonical model is built. The construction proceeds:

1. **Start**: phi is consistent, so [phi] has no derivation of bot.
2. **Build BMCS**: Use `construct_temporal_bmcs [phi] h_cons` to create a temporally coherent BMCS B.
3. **phi in MCS**: phi is in `B.eval_family.mcs 0` by `construct_temporal_bmcs_contains_context`.
4. **Build canonical frame**: Apply the construction from Section 4.6 to obtain `canonical_frame B` and `canonical_model B`.
5. **Build world histories**: Each family in B yields a `canonical_world_history`.

### 5.2 The TruthLemma as North Star

The TruthLemma must establish:

```lean
theorem canonical_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hmem : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t <->
    truth_at (canonical_model B) (canonical_world_history B fam hmem) t phi
```

This connects MCS membership (the BMCS-level notion) to semantic truth in the canonical task frame model (the standard semantics).

### 5.3 Case Analysis for the Canonical TruthLemma

**Atom case**: `truth_at M tau t (atom p) = exists ht, M.valuation (tau.states t ht) p`

With our definitions:
- `tau.states t _ = (fam, hmem, t)` (a CanonicalWorldState')
- `M.valuation (fam, hmem, t) p = (Formula.atom p) in fam.mcs t`
- `tau.domain t = True`, so ht is trivial

So `truth_at M tau t (atom p) = (atom p) in fam.mcs t`. The atom case is trivial.

**Bot case**: `truth_at M tau t bot = False`. Bot is not in any MCS (by consistency). Trivial.

**Imp case**: `truth_at M tau t (phi.imp psi) = truth_at ... phi -> truth_at ... psi`

By IH: `phi in mcs <-> truth phi` and `psi in mcs <-> truth psi`. Need: `(phi.imp psi) in mcs <-> (phi in mcs -> psi in mcs)`. This is exactly the MCS implication property (forward) and negation-completeness argument (backward) from the BMCS truth lemma.

**Box case**: `truth_at M tau t (box phi) = forall sigma : WorldHistory F, truth_at M sigma t phi`

The quantification is over ALL world histories in the canonical frame. Each world history in the canonical frame corresponds to a family in the BMCS. The critical question is whether EVERY world history in the canonical frame corresponds to a BMCS family.

**This is where the construction becomes delicate.** In the standard task-frame semantics, box quantifies over ALL world histories, not just the canonical ones. If there exist "rogue" world histories in the canonical frame that do not correspond to BMCS families, the box case fails.

**Resolution**: The canonical frame must be constructed so that its ONLY world histories are those arising from BMCS families. This requires either:
(a) Restricting the frame so that the task relation only allows transitions within families (already done in Section 4.6), OR
(b) Showing that any world history in the canonical frame must correspond to a BMCS family.

With the construction from Section 4.6, a world history must assign states `(fam_t, hmem_t, t)` at each time t, with `fam_s = fam_t` and `t' = t + d` required by respects_task. This means the family index must be CONSTANT along the history. So every world history is indexed by a single family, and its states at time t are `(fam, hmem, t)`. The world histories ARE exactly the canonical ones.

**But wait**: The domain must contain time t for the box quantification. Since all canonical world histories have `domain = True` (full domain), and the truth definition for box quantifies over all world histories and then checks truth at time t (not requiring t in domain for the quantifier itself), we need:

`truth_at M sigma t (box phi) = forall sigma, truth_at M sigma t phi`

For a world history sigma with `sigma.domain t = True` (or more generally, the truth_at definition handles atoms being false outside domain), this works correctly.

The box case reduces to: `box phi in fam.mcs t <-> forall fam' in B.families, phi in fam'.mcs t`. This is exactly `modal_forward` and `modal_backward` from the BMCS.

But there is a subtlety: the universal quantification in `truth_at` is over ALL `WorldHistory (canonical_frame B)`, while the BMCS modal coherence only ranges over families IN the bundle. We need:

**Every world history of the canonical frame is one of the canonical world histories.**

Proof: A world history `sigma` of `canonical_frame B` satisfies `sigma.respects_task`, which for states `w = sigma.states s` and `v = sigma.states t` with `s <= t` requires:
```
canonical_frame.task_rel w (t - s) v
= w.family = v.family /\ v.time = w.time + (t - s)
```

This means all states in the history have the same family, and `v.time = w.time + (t - s)`. Since the WorldState is `(family, family_mem, time)` and the `states` function maps `s` to `(fam, hmem, time_s)`, we get:
- `fam` is constant (same for all s)
- `time_t = time_s + (t - s)`, i.e., `time_t - time_s = t - s`

If we set `time_0 = c` for some constant, then `time_t = c + t` for all t. The world history is fully determined by the family `fam` and the offset `c`. But the valuation only depends on `fam.mcs(time_t) = fam.mcs(c + t)`.

By the time-shift construction in the semantics (time_shift_preserves_truth), truth at (sigma, t) with offset c equals truth at (sigma', t) with offset 0 (up to time-shifting). So the box quantification over all offsets c and all families fam reduces to quantification over all families fam (since time-shift doesn't change truth).

**Conclusion**: The box case of the canonical TruthLemma works correctly, matching the BMCS modal coherence conditions, PROVIDED we can show that the only "meaningful" variation among world histories is the family choice (the offset being absorbed by the time-shift preservation theorem).

**G/H cases**: `truth_at M tau t (all_future phi) = forall s >= t, truth_at M tau s phi`

This reduces to: `G phi in fam.mcs t <-> forall s >= t, phi in fam.mcs s`. This is exactly the combination of `mcs_all_future_implies_phi_at_future` (forward) and `temporal_backward_G` (backward) from TruthLemma.lean.

### 5.4 Summary: TruthLemma Feasibility

The canonical TruthLemma is feasible with the construction from Section 4.6:

| Case | Canonical TruthLemma | Reduces To |
|------|---------------------|------------|
| Atom | Trivial by definition | MCS membership |
| Bot | Trivial | MCS consistency |
| Imp | MCS implication property | BMCS imp case |
| Box | Family quantification | BMCS modal coherence |
| G | Temporal forward/backward | BMCS temporal coherence |
| H | Temporal forward/backward | BMCS temporal coherence |

The key technical challenge is the box case: showing that world-history quantification in the task-frame semantics corresponds exactly to family quantification in the BMCS. This requires careful handling of the time-shift offset (Section 5.3).

## 6. Detailed Construction Strategy

### 6.1 Phase 1: Define Canonical Task Frame

Define:
```lean
structure CanonicalWorldState (B : BMCS D) where
  family : IndexedMCSFamily D
  family_mem : family in B.families
  time : D

def canonical_frame (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldState B
  task_rel := fun w d u => w.family = u.family /\ u.time = w.time + d
  nullity := ...
  compositionality := ...
```

### 6.2 Phase 2: Define Canonical World Histories and Model

For each family in B, define a world history with full domain. Define the canonical model with valuation based on MCS membership.

### 6.3 Phase 3: Prove the Canonical TruthLemma

Prove by structural induction on the formula:
```lean
phi in fam.mcs t <-> truth_at (canonical_model B) (canonical_world_history B fam hmem) t phi
```

The proof delegates to existing BMCS truth lemma infrastructure for each case.

### 6.4 Phase 4: Bridge to Standard Completeness

Use the canonical TruthLemma to show:
```lean
-- If phi is consistent, it is satisfiable in the standard task-frame semantics
theorem standard_representation (phi : Formula) (h_cons : Consistent [phi]) :
    formula_satisfiable phi
```

This connects `bmcs_representation` (proven) to `formula_satisfiable` (the standard semantic notion).

### 6.5 Phase 5: Standard Completeness

```lean
-- If phi is valid in standard semantics, then phi is derivable
theorem standard_weak_completeness (phi : Formula) (h_valid : valid phi) :
    Nonempty (DerivationTree [] phi)
```

This uses the contrapositive: if not derivable, then consistent, then satisfiable (by standard_representation), so not valid. Combined with soundness (already proven), this gives the full completeness cycle.

## 7. Risks and Open Questions

### 7.1 Risk: The Two False Axioms

The BMCS completeness proof depends on `temporally_saturated_mcs_exists` and `singleFamily_modal_backward_axiom`, both of which are mathematically false (Task 843 finding). The canonical task frame construction inherits these dependencies.

**Mitigation**: Task 864's recursive seed construction approach aims to replace these axioms. The canonical task frame construction in this report is INDEPENDENT of how the BMCS is built -- it only requires a BMCS with the right coherence properties. Once the axioms are replaced with correct constructions, the canonical task frame automatically benefits.

### 7.2 Risk: Box Case World-History Quantification

The box case requires showing that ALL world histories of the canonical frame correspond to BMCS families (up to time-shift). This needs a careful proof that no "extra" world histories exist in the canonical frame beyond those constructed from families.

**Mitigation**: The construction from Section 4.6 ensures this by construction: the task relation requires the family to be constant along any history, and states are uniquely determined by (family, time). The only variation is the time offset, which is absorbed by time-shift preservation.

### 7.3 Risk: Atomicity Outside Domain

The standard semantics defines atoms as false outside the history's domain. With full-domain canonical histories (`domain = True`), this is not an issue. But if future constructions use restricted domains (e.g., for the Finite Model Property), the domain handling needs care.

### 7.4 Open Question: Injectivity of fam.mcs

If `fam.mcs` is not injective (i.e., the same MCS appears at multiple times), the canonical world-states at different times are extensionally different (because they carry the time index) even though they have the same MCS content. This is correct behavior: the world-state encodes "where we are in time," not just "what formulas hold."

### 7.5 Open Question: Cross-Family Task Relation

The proposed canonical task frame has a task relation that is family-local (same family required). Cross-family transitions are NOT modeled by the task relation; they are modeled by the box operator's quantification over world histories. This matches the TM semantics correctly but means the task relation is relatively simple (essentially encoding temporal flow within each family).

### 7.6 Open Question: Relationship to Topology Idea

The topology idea from the research focus (using the two-place task relation to define closeness, with durations as equivalence classes) is not pursued in the recommended construction. The reason is that the topology adds complexity without clear benefits for the TruthLemma. The linear-order topology on D already captures temporal closeness, and modal "closeness" is handled by the BMCS bundle structure.

However, the topology idea could be revisited if one wants to study the STRUCTURE of the canonical frame (e.g., its topological properties, definability results, or correspondence theory). This is a theoretical direction beyond the immediate goal of proving the TruthLemma.

## 8. Comparison with Literature

### 8.1 Standard Canonical Model for Tense Logic

In standard tense logic completeness proofs (Goldblatt 1992, Gabbay-Hodkinson-Reynolds 1994, Venema 2001):
- **Canonical frame**: Worlds are MCSs. The relation R(w, u) holds iff G phi in w implies phi in u (and H phi in u implies phi in w). There are no explicit durations.
- **Completeness**: Proven via the canonical model theorem. The TruthLemma establishes phi in w iff M, w |= phi.

Our construction extends this by:
- Adding explicit durations (from the ordered group D).
- Organizing MCSs into families indexed by D (rather than a single set of MCSs).
- Handling the modal dimension (box/diamond) via families in the BMCS bundle.

### 8.2 Metric Temporal Logic Completeness

Metric temporal logic (MTL) extends basic temporal logic with quantitative timing constraints. Completeness for full MTL over timed words is generally undecidable (Ouaknine and Worrell, 2005). Our TM logic is simpler than MTL because:
- Durations are part of the semantic framework but not explicitly mentioned in the syntax.
- Temporal operators are just G (always future) and H (always past), without bounded variants.
- The complexity comes from the INTERACTION between modal and temporal operators.

### 8.3 Henkin-Style Completeness for Higher-Order Logic

The BMCS approach is analogous to Henkin semantics for higher-order logic:
- In Henkin semantics, one restricts to "standard" models where quantifiers range over definable subsets.
- In BMCS completeness, one restricts box quantification to range over families in the bundle (rather than all possible world histories).
- Both approaches give genuine completeness results by showing that the restriction doesn't lose any derivable formulas.

## 9. Recommendations

### 9.1 Primary Recommendation: Build the Canonical Task Frame Bridge

Implement the construction from Section 4.6 to bridge BMCS completeness to standard task-frame semantics. This involves:
1. Defining `canonical_frame`, `canonical_world_history`, `canonical_model`.
2. Proving the canonical TruthLemma by reduction to the BMCS truth lemma.
3. Deriving standard completeness from BMCS completeness.

Estimated effort: 20-30 hours (mostly in the box case of the TruthLemma).

### 9.2 Secondary Recommendation: Decouple from Axiom Dependencies

The canonical task frame construction should be designed to work with ANY BMCS satisfying the coherence conditions. This way, when Task 864's recursive seed construction replaces the false axioms, the canonical task frame automatically inherits the improvement.

### 9.3 Tertiary Recommendation: Document the Topology Direction

The topology idea (using the task relation to define closeness and durations as equivalence classes) should be documented as a future direction for structural analysis of the canonical frame, separate from the immediate completeness proof.

## 10. References

### Codebase Files

- `Theories/Bimodal/Semantics/TaskFrame.lean` - TaskFrame structure
- `Theories/Bimodal/Semantics/WorldHistory.lean` - WorldHistory definition
- `Theories/Bimodal/Semantics/Truth.lean` - truth_at evaluation
- `Theories/Bimodal/Semantics/Validity.lean` - Validity and semantic consequence
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` - BMCS structure
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - BMCS truth lemma
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - BMCS completeness theorems
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - IndexedMCSFamily
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` - Temporal backward properties
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - BMCS construction
- `Theories/Bimodal/Boneyard/DurationConstruction.lean` - Deprecated Grothendieck approach
- `specs/864_recursive_seed_henkin_model/reports/research-001.md` - Recursive seed approach

### Literature

- [Temporal Logic (Stanford Encyclopedia of Philosophy)](https://plato.stanford.edu/entries/logic-temporal/)
- [Venema, "Temporal Logic" (handbook chapter)](https://staff.science.uva.nl/y.venema/papers/TempLog.pdf)
- [Gabbay, Hodkinson, Reynolds, "Temporal Logic: Mathematical Foundations and Computational Aspects" (Oxford, 1994)](https://global.oup.com/academic/product/temporal-logic-9780198537694)
- [Canonical Models for Normal Modal Logics (Imperial College notes)](https://www.doc.ic.ac.uk/~mjs/teaching/ModalTemporal499/CanonicalNormal_499_v0809_2up.pdf)
- [Bezhanishvili, "A Henkin-style completeness proof for S5"](https://philarchive.org/archive/BENAHC-2)
- [Hodkinson and Reynolds, "Separation - past, present, and future"](https://www.doc.ic.ac.uk/~imh/papers/sep.pdf)

## Next Steps

1. Implement Phase 1 (canonical task frame definition) as a new Lean file `Theories/Bimodal/Metalogic/Representation/CanonicalTaskFrame.lean`.
2. Prove nullity and compositionality for the canonical frame.
3. Define canonical world histories and canonical model.
4. Prove the canonical TruthLemma by structural induction, delegating each case to existing BMCS lemmas.
5. Derive `formula_satisfiable phi` from `bmcs_representation phi` via the canonical task frame bridge.
6. Derive standard weak/strong completeness from BMCS completeness.
