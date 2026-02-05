# Research Report: Task #865 (Round 3)

**Task**: Canonical task frame for bimodal completeness
**Date**: 2026-02-05
**Focus**: Canonical tasks as composable parametric functions, accessibility relation, world histories as duration-indexed functions, and the TruthLemma as North Star.

## Summary

This report refines the canonical construction from research-001 and research-002 based on the user's clarified vision. The key conceptual shift is away from "world-states as (family, time) pairs" (the BMCS-indexed frame from research-001 Section 4.6) toward a richer construction where **canonical tasks are composable parametric duration-indexed functions** and **world histories are total functions from a duration group to world-states**. The report develops (1) the two-place accessibility relation between MCSs, (2) canonical tasks as three-place parametric entities, (3) task composition, (4) canonical world histories, and (5) a detailed TruthLemma case analysis. The duration group is taken to be any linearly ordered abelian group D (instantiated as Int for the construction). A seed construction from a single consistent formula is outlined.

## 1. Accessibility Between MCSs (Two-Place Relation)

### 1.1 Definition

Following the user's terminological correction, define **accessibility** (not "task relation") as a two-place relation between MCSs:

```
w ~ u  iff  (1) phi in u whenever G phi in w     (G-forward)
        and (2) phi in w whenever H phi in u       (H-backward)
```

Here `G phi = Formula.all_future phi` and `H phi = Formula.all_past phi`. In codebase terms:

```lean
def accessible (w u : Set Formula) : Prop :=
  (forall phi, Formula.all_future phi in w -> phi in u) /\
  (forall phi, Formula.all_past phi in u -> phi in w)
```

This relation captures "u is temporally reachable from w (in the future direction)." It is the basic building block from which tasks and histories are constructed.

### 1.2 Properties of Accessibility

**Reflexivity**: `w ~ w` holds for any MCS w, because G phi in w implies phi in w (by the T-axiom `G phi -> phi`) and H phi in w implies phi in w (by `H phi -> phi`). Both T-axioms are in the proof system and are closed under in MCS by `theorem_in_mcs`.

**Transitivity**: If `w ~ u` and `u ~ v`, then `w ~ v`. Proof:
- G phi in w implies phi in u (by w ~ u). But we need phi in v. We need G phi in u, which follows from the 4-axiom: G phi in w implies G(G phi) in w (by `G phi -> G(G phi)`, the temporal 4 axiom, which is `Axiom.temp_4`), so G phi in u (by w ~ u with G phi), so phi in v (by u ~ v).
- H phi in v implies phi in u (by u ~ v). Similarly, H(H phi) in v implies H phi in u (by the past 4-axiom `H phi -> H(H phi)`, which is `temp_4_past`), so phi in w (by w ~ u backward).

**Connection to IndexedMCSFamily**: Within a family `fam : IndexedMCSFamily D`, for any `t < s`, we have `fam.mcs t ~ fam.mcs s`:
- G-forward: `fam.forward_G` gives `G phi in fam.mcs t -> phi in fam.mcs s` for t < s.
- H-backward: `fam.backward_H` gives `H phi in fam.mcs s -> phi in fam.mcs t` for t < s.

For `t = s`, reflexivity of ~ gives `fam.mcs t ~ fam.mcs t`.

### 1.3 Witness Conditions

The **converse** (or witness) conditions are:
- **(GW)**: If phi in u whenever w ~ u, then G phi in w.
- **(HW)**: If phi in w whenever w ~ u, then H phi in u.

These are exactly the backward direction of the TruthLemma for temporal operators. They are proven in `TemporalCoherentConstruction.lean` via contraposition using `forward_F`/`backward_P`.

## 2. Canonical Tasks as Composable Parametric Functions

### 2.1 Conceptual Definition

A **canonical task** is a three-place entity parametrized by:
1. A **starting world-state** w (an MCS)
2. A **maximum duration** d_max in D (where D is the duration group)
3. A **trajectory function** tau : [0, d_max] -> MCS assigning an MCS to each elapsed time

Formally:

```
A canonical task tau has:
  - d_max : D (with 0 <= d_max)
  - trajectory : (delta : D) -> (0 <= delta) -> (delta <= d_max) -> Set Formula
  - start : trajectory 0 = w
  - end : trajectory d_max = u (for some ending MCS u)
  - is_mcs : forall delta, SetMaximalConsistent (trajectory delta)
  - accessible_step : forall delta1 delta2,
      delta1 <= delta2 -> accessible (trajectory delta1) (trajectory delta2)
```

The accessible_step condition ensures that consecutive MCSs along the trajectory are temporally accessible. This is the "composable" part -- the trajectory respects the accessibility relation at every intermediate point.

### 2.2 Lean Formalization Sketch

The canonical task structure can be formalized as:

```lean
structure CanonicalTask (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  /-- Maximum duration of the task -/
  duration : D
  /-- Duration is non-negative -/
  duration_nonneg : 0 <= duration
  /-- Trajectory: maps elapsed time delta in [0, duration] to an MCS -/
  trajectory : D -> Set Formula
  /-- Each trajectory point is an MCS -/
  is_mcs : forall delta, SetMaximalConsistent (trajectory delta)
  /-- G-coherence along the trajectory -/
  forward_G : forall d1 d2 phi, 0 <= d1 -> d1 < d2 -> d2 <= duration ->
    Formula.all_future phi in trajectory d1 -> phi in trajectory d2
  /-- H-coherence along the trajectory -/
  backward_H : forall d1 d2 phi, 0 <= d2 -> d2 < d1 -> d1 <= duration ->
    Formula.all_past phi in trajectory d1 -> phi in trajectory d2
```

**Note**: The trajectory is defined on ALL of D for simplicity (Lean's total functions), but the coherence conditions only apply within [0, duration].

### 2.3 Relationship to IndexedMCSFamily

An `IndexedMCSFamily D` with time assignment `fam.mcs : D -> Set Formula` gives rise to a canonical task for any pair of times t <= s:

```lean
def task_from_family (fam : IndexedMCSFamily D) (t s : D) (hts : t <= s) : CanonicalTask D where
  duration := s - t
  duration_nonneg := by linarith
  trajectory := fun delta => fam.mcs (t + delta)
  is_mcs := fun delta => fam.is_mcs (t + delta)
  forward_G := fun d1 d2 phi hd1 hd1d2 hd2 hG =>
    fam.forward_G (t + d1) (t + d2) phi (by linarith) hG
  backward_H := fun d1 d2 phi hd2 hd2d1 hd1 hH =>
    fam.backward_H (t + d1) (t + d2) phi (by linarith) hH
```

The starting MCS is `fam.mcs t` and the ending MCS is `fam.mcs s`. The duration is `s - t`.

### 2.4 Why Three-Place

A canonical task is three-place because it involves:
1. The starting world-state w = trajectory(0)
2. The duration d = d_max
3. The ending world-state u = trajectory(d_max)

This matches the `task_rel w d u` in `TaskFrame`. The trajectory is the additional structure that witnesses the relation -- it is not part of the task_rel itself but provides the proof that the relation holds.

## 3. Task Composition

### 3.1 Sequential Composition

Given two canonical tasks tau1 (duration d1) and tau2 (duration d2), where tau1 ends at the same MCS that tau2 begins at (i.e., `tau1.trajectory(d1) = tau2.trajectory(0)`), their **sequential composition** tau1 ; tau2 is:

```
(tau1 ; tau2).duration := d1 + d2
(tau1 ; tau2).trajectory(delta) :=
  if delta <= d1 then tau1.trajectory(delta)
  else tau2.trajectory(delta - d1)
```

The is_mcs property follows from the is_mcs of tau1 and tau2.

The forward_G coherence across the boundary (d1) uses the temporal 4-axiom, exactly as analyzed in research-002 Section 2.5:
- G phi in tau1.trajectory(delta) for delta <= d1 implies G(G phi) in tau1.trajectory(delta) (by 4-axiom), so G phi in tau1.trajectory(d1) (by tau1.forward_G), so G phi in tau2.trajectory(0) (by junction agreement), so phi in tau2.trajectory(delta') (by tau2.forward_G for delta' > 0).

Similarly for backward_H across the boundary.

### 3.2 Vacuous/Identity Tasks

For any MCS w, there is a **vacuous task** of duration 0:

```
vacuous(w).duration := 0
vacuous(w).trajectory(delta) := w   (constant function)
```

The coherence conditions are vacuously satisfied since there are no d1 < d2 with d1 >= 0 and d2 <= 0.

### 3.3 Composition Laws

**Left identity**: vacuous(w) ; tau = tau (when tau starts at w)
- Duration: 0 + d = d.
- Trajectory: for delta <= 0 (only delta = 0), gives w = tau.trajectory(0). For delta > 0, gives tau.trajectory(delta - 0) = tau.trajectory(delta).

**Right identity**: tau ; vacuous(u) = tau (when tau ends at u)
- Duration: d + 0 = d.
- Trajectory: for delta <= d, gives tau.trajectory(delta). For delta > d (impossible since max is d), vacuously correct.

**Associativity**: (tau1 ; tau2) ; tau3 = tau1 ; (tau2 ; tau3)
- Duration: (d1 + d2) + d3 = d1 + (d2 + d3) by group associativity.
- Trajectory: both sides give the same case-split on delta.

These laws make canonical tasks into a **category** where objects are MCSs and morphisms are canonical tasks.

## 4. Canonical World Histories

### 4.1 Definition

A **canonical world history** is a function `h : D -> Set Formula` (from the entire duration group to MCSs) such that:
- `h(t)` is an MCS for all `t : D`
- For any two times `x <= y`, there exists a canonical task going from `h(x)` to `h(y)` with duration `y - x`

Equivalently (and more simply):
- `h(t)` is an MCS for all `t : D`
- `h` is an `IndexedMCSFamily D` (with forward_G and backward_H coherence)

**Key insight**: A canonical world history IS an IndexedMCSFamily. The requirement "there exists a task from h(x) to h(y) with duration y - x" is exactly the accessibility condition `h(x) ~ h(y)` for x <= y, which is equivalent to forward_G and backward_H coherence.

### 4.2 From Tasks to Histories

Given an infinite sequence of composable tasks (with durations summing to cover all of D), one can construct a world history by composing all the trajectories. Conversely, any world history gives rise to canonical tasks between any two of its time points.

This bidirectional relationship means:
- **Tasks are segments of histories**: Any interval [x, y] of a world history defines a canonical task.
- **Histories are limits of tasks**: A consistent infinite composition of tasks yields a history.

### 4.3 Respecting the Task Relation

In the `WorldHistory` structure from the codebase:

```lean
respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
  s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

For the canonical frame, this becomes: for any s <= t, there is a canonical task from the world-state at s to the world-state at t with duration t - s. With our construction, this is guaranteed because the world history IS a temporally coherent family, and we can always extract a task_from_family.

## 5. The Canonical Task Frame

### 5.1 World-States

The **canonical world-states** are the MCSs that appear in the BMCS bundle:

```lean
def CanonicalWorldState (B : BMCS D) : Type :=
  { M : Set Formula // exists fam in B.families, exists t : D, fam.mcs t = M }
```

Alternatively, using the BMCS-indexed approach where world-states carry their provenance:

```lean
structure CanonicalWorldState (B : BMCS D) where
  carrier : Set Formula
  is_mcs : SetMaximalConsistent carrier
  origin_family : IndexedMCSFamily D
  origin_time : D
  origin_mem : origin_family in B.families
  origin_eq : origin_family.mcs origin_time = carrier
```

### 5.2 The Three-Place Canonical Task Relation

The canonical task relation matches the semantics:

```lean
def canonical_task_rel (B : BMCS D) (w : CanonicalWorldState B) (d : D) (u : CanonicalWorldState B) : Prop :=
  exists (tau : CanonicalTask D),
    tau.duration = d /\
    tau.trajectory 0 = w.carrier /\
    tau.trajectory d = u.carrier /\
    (exists fam in B.families, exists t : D,
      forall delta, 0 <= delta -> delta <= d -> tau.trajectory delta = fam.mcs (t + delta))
```

This says: w is related to u by duration d if there exists a canonical task of that duration, starting at w, ending at u, whose trajectory lies entirely within some family in the BMCS.

### 5.3 Simplified Version (Recommended for Implementation)

The above is complex. The simpler but equivalent version uses families directly:

```lean
def canonical_task_rel_simple (B : BMCS D) (w : CanonicalWorldState B) (d : D) (u : CanonicalWorldState B) : Prop :=
  exists fam in B.families, exists t : D,
    fam.mcs t = w.carrier /\ fam.mcs (t + d) = u.carrier
```

This says: w is related to u by duration d if there exists a family placing w at some time t and u at time t + d. No explicit task trajectory is needed -- the family itself IS the trajectory.

### 5.4 Nullity

`canonical_task_rel_simple B w 0 w` requires: exists fam, exists t, fam.mcs t = w.carrier and fam.mcs (t + 0) = w.carrier. Since t + 0 = t, this reduces to: exists fam, exists t, fam.mcs t = w.carrier. This holds by the definition of CanonicalWorldState (which carries origin_family and origin_time).

### 5.5 Compositionality

As analyzed in research-002, compositionality for `canonical_task_rel_simple` requires showing: if fam1 witnesses (w, d1, u) and fam2 witnesses (u, d2, v), then some fam3 witnesses (w, d1+d2, v).

**Case 1: Same family**. If fam1 = fam2, compositionality is trivial: use the same family with time t1 and duration d1 + d2.

**Case 2: Different families**. The family composition construction from research-002 Section 2 produces fam3 from fam1 and fam2, but only when d1 >= 0 and d2 > 0 (or d2 = 0 trivially). For the general case (negative durations), the construction needs the BMCS-indexed approach.

**Resolution**: Use the BMCS-indexed frame for implementation. Define world-states as `(fam, t)` pairs:

```lean
structure CanonicalWorldStateI (B : BMCS D) where
  family : IndexedMCSFamily D
  family_mem : family in B.families
  time : D

def canonical_frame_I (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldStateI B
  task_rel := fun w d u => w.family = u.family /\ u.time = w.time + d
  nullity := fun w => ⟨rfl, by simp⟩
  compositionality := fun w u v x y ⟨h1, h2⟩ ⟨h3, h4⟩ => by
    exact ⟨h1.trans h3, by rw [h4, h2]; ring⟩
```

This gives trivial nullity and compositionality. The interesting structure is in the valuation and world histories.

### 5.6 Why Both Approaches Coexist

The **MCS-as-world-state** approach (`canonical_task_rel_simple`) is mathematically natural -- the world-states ARE the MCSs, and the task relation captures when one MCS can follow another. But it has compositionality difficulties for cross-family transitions.

The **indexed approach** (`canonical_frame_I`) is cleaner for formalization. World-states carry their provenance, making compositionality trivial. The box case of the TruthLemma also becomes cleaner.

For the implementation plan, **use the indexed approach**. The MCS-as-world-state approach can be treated as a quotient or used for mathematical exposition.

## 6. The Canonical Model

### 6.1 Valuation

```lean
def canonical_model (B : BMCS D) : TaskModel (canonical_frame_I B) where
  valuation := fun w p => Formula.atom p in w.family.mcs w.time
```

The valuation at world-state `(fam, t)` checks whether the atom is in `fam.mcs t`.

### 6.2 Canonical World Histories

Each family in the BMCS gives a canonical world history:

```lean
def canonical_history (B : BMCS D) (fam : IndexedMCSFamily D) (hmem : fam in B.families) :
    WorldHistory (canonical_frame_I B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨fam, hmem, t⟩
  respects_task := fun s t _ _ hst => ⟨rfl, by ring⟩
```

Key properties:
- **Full domain**: Every time is in the domain (`domain = True`).
- **Constant family**: The family index is the same at all times.
- **Linear time**: The time component equals the input time t.
- **Task respect**: `task_rel (fam, s) (t - s) (fam, t)` holds because `fam = fam` and `t = s + (t - s)`.

### 6.3 Characterization of All World Histories

**Claim**: Every world history of `canonical_frame_I B` is of the form `(fam, hmem, t + c)` for some family fam, membership proof hmem, and constant offset c.

**Proof sketch**: Let sigma be a world history. By `respects_task`, for any s, t in the domain with s <= t:
- `sigma.states s` and `sigma.states t` must satisfy: `(sigma.states s).family = (sigma.states t).family` and `(sigma.states t).time = (sigma.states s).time + (t - s)`.

The first condition means the family is constant along the history. The second means `time_t - time_s = t - s`, so `time_t = time_s + (t - s) = (time_0 + s) + (t - s) = time_0 + t`. Setting `c = time_0`, we get `(sigma.states t).time = c + t` for all t.

So `sigma.states t = (fam, hmem, c + t)` for a fixed family fam and offset c.

### 6.4 Effect of Offset on Truth

The offset c means the world history evaluates atoms at `fam.mcs(c + t)` instead of `fam.mcs(t)`. By the time-shift preservation theorem (`time_shift_preserves_truth` in Truth.lean), truth at `(sigma, t)` with offset c equals truth at `(canonical_history fam, c + t)`.

For the TruthLemma, we evaluate at the canonical history (offset 0). When the box case quantifies over all world histories, the offset-shifted histories are handled by the time-shift bijection.

## 7. The TruthLemma (Detailed Case Analysis)

### 7.1 Statement

```lean
theorem canonical_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hmem : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t <->
    truth_at (canonical_model B) (canonical_history B fam hmem) t phi
```

### 7.2 Atom Case

`truth_at M tau t (atom p) = exists (ht : tau.domain t), M.valuation (tau.states t ht) p`

With our definitions:
- `tau.domain t = True`, so ht exists trivially.
- `tau.states t _ = (fam, hmem, t)` (a CanonicalWorldStateI).
- `M.valuation (fam, hmem, t) p = (atom p) in fam.mcs t`.

So `truth_at M tau t (atom p) = (atom p) in fam.mcs t`. **Holds trivially.**

### 7.3 Bot Case

`truth_at M tau t bot = False`

`bot in fam.mcs t` is false by MCS consistency. So `bot in fam.mcs t <-> False`. **Holds trivially.**

### 7.4 Imp Case

`truth_at M tau t (phi.imp psi) = truth_at M tau t phi -> truth_at M tau t psi`

By IH: `phi in mcs <-> truth phi` and `psi in mcs <-> truth psi`. Need: `(phi.imp psi) in mcs <-> (phi in mcs -> psi in mcs)`. This is the standard MCS implication property. **Matches the BMCS truth lemma imp case exactly.**

### 7.5 Box Case (The Critical Case)

`truth_at M tau t (box phi) = forall (sigma : WorldHistory (canonical_frame_I B)), truth_at M sigma t phi`

The universal quantification is over ALL world histories of the canonical frame. By Section 6.3, every world history is `(fam', hmem', t' + c)` for some family fam', membership proof hmem', and offset c.

So `truth_at M tau t (box phi)` becomes:
```
forall fam' in B.families, forall c : D,
  truth_at M (canonical_history_offset B fam' hmem' c) t phi
```

where `canonical_history_offset` is the offset-shifted version.

By time-shift preservation:
```
truth_at M (canonical_history_offset B fam' hmem' c) t phi
  <-> truth_at M (canonical_history B fam' hmem') (t + c) phi   -- by time_shift_preserves_truth
```

Wait -- this is problematic. The box quantification includes histories with ALL offsets c, which means we are quantifying over phi being true at ALL times `t + c` for ALL families fam'. This is STRONGER than just "phi at all families at time t."

**This is a fundamental issue.** Let me analyze it carefully.

The box semantics says: `box phi` is true at `(M, tau, t)` iff for ALL world histories sigma, `phi` is true at `(M, sigma, t)`. A world history sigma in the canonical frame is determined by `(fam', c)`. The truth at `(M, sigma, t)` depends on `sigma.states t = (fam', hmem', c + t)`. The atom evaluation gives `M.valuation (fam', hmem', c + t) p = (atom p) in fam'.mcs(c + t)`.

So `truth_at M sigma t phi` depends on `fam'.mcs(c + t)`, NOT on `fam'.mcs(t)`. The time offset c shifts which MCS the history accesses at the evaluation time t.

But wait: `truth_at` for non-atomic formulas propagates recursively. Let me re-examine.

For `truth_at M sigma t (atom p)`:
```
= exists (ht : sigma.domain t), M.valuation (sigma.states t ht) p
= exists _, (atom p) in fam'.mcs(c + t)
= (atom p) in fam'.mcs(c + t)
```

For `truth_at M sigma t (box psi)`:
```
= forall rho : WorldHistory F, truth_at M rho t psi
```

This is the SAME universal quantification regardless of sigma. So `truth_at M sigma t (box psi)` does not depend on sigma at all. The box is "family-independent" at the semantic level.

For `truth_at M sigma t (all_future psi)`:
```
= forall s >= t, truth_at M sigma s psi
```

This DOES depend on sigma, because it evaluates at different times s using the same history sigma.

So the full picture for `truth_at M sigma t phi` where `sigma = (fam', c)`:

| Formula | truth_at M sigma t | Depends on |
|---------|-------------------|------------|
| atom p | (atom p) in fam'.mcs(c+t) | fam', c |
| bot | False | nothing |
| phi -> psi | truth phi -> truth psi | recursive |
| box phi | forall rho, truth rho t phi | not sigma |
| G phi | forall s >= t, truth sigma s phi | sigma at all s >= t |
| H phi | forall s <= t, truth sigma s phi | sigma at all s <= t |

**For the box case of the TruthLemma**, we need:

```
box phi in fam.mcs t
  <-> forall sigma : WorldHistory F, truth_at M sigma t phi
  = forall (fam', c), truth_at M (fam', c) t phi
```

The BMCS `modal_forward` gives: `box phi in fam.mcs t -> phi in fam'.mcs t` for all fam' in B.families.
The BMCS `modal_backward` gives: `(forall fam' in B.families, phi in fam'.mcs t) -> box phi in fam.mcs t`.

But the RHS of the TruthLemma quantifies over `(fam', c)`, not just `fam'`. The `c` offset means we are asking for phi to hold at `(fam', c, t)` -- but the atom evaluation at this state uses `fam'.mcs(c + t)`, not `fam'.mcs(t)`.

**This is the offset problem.** The quantification over all world histories includes offset-shifted histories, and truth at an offset-shifted history evaluates formulas at shifted times within the same family.

### 7.6 Resolving the Offset Problem

There are two approaches to resolve this:

**Approach A: Restrict world histories to offset 0.**

Modify the canonical frame so that world-states are ONLY the standard `(fam, t)` pairs with canonical time (no offset). This means restricting `WorldState` so that only histories of the form `(fam, hmem, t)` (not `(fam, hmem, c + t)`) exist.

Concretely, change the task relation:

```lean
def canonical_frame_strict (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldStateI B
  task_rel := fun w d u =>
    w.family = u.family /\ u.time = w.time + d /\ w.time = ???
```

But this doesn't work cleanly -- we can't restrict which world-states appear without changing the structure.

**Approach B: Show the offset is absorbed by the IH.**

The key insight is that for the TruthLemma, we prove it for ALL families and ALL times simultaneously. So when we encounter `truth_at M (fam', c) t phi`, by the IH at family fam' and time (c + t):

```
truth_at M (canonical_history B fam' hmem') (c + t) phi
  <-> phi in fam'.mcs(c + t)   -- by IH
```

And `truth_at M (offset_history fam' c) t phi` relates to `truth_at M (canonical_history fam') (c + t) phi` by time_shift_preserves_truth:

```
truth_at M (time_shift (canonical_history B fam' hmem') (c+t - t)) t phi
  <-> truth_at M (canonical_history B fam' hmem') (c+t) phi
```

Since `time_shift (canonical_history fam') c` is exactly the offset-c history `(fam', c)` (they have the same domain, same states), we get:

```
truth_at M (fam', c) t phi <-> truth_at M (canonical_history fam') (c+t) phi <-> phi in fam'.mcs(c+t)
```

Now the box case becomes:

```
box phi in fam.mcs t
  <-> forall (fam', c), phi in fam'.mcs(c + t)   -- by IH + time-shift
  = forall fam', forall c, phi in fam'.mcs(c + t)
  = forall fam', forall s : D, phi in fam'.mcs s   -- substituting s = c + t, c ranges over all D
```

But `forall fam', forall s, phi in fam'.mcs s` says "phi is in EVERY MCS of EVERY family at EVERY time." This is much stronger than what `box phi in fam.mcs t` provides (which only gives `phi in fam'.mcs t` for all fam').

**This means the BMCS-indexed frame as defined DOES NOT give the correct box case for the standard task-frame TruthLemma.**

### 7.7 The Root Cause

The root cause is that `truth_at` for box quantifies over ALL `WorldHistory F`, including time-shifted versions that evaluate at different times. The BMCS modal coherence (`modal_forward`/`modal_backward`) only relates families at the SAME time t. But the offset-shifted histories make the box quantification range over ALL times.

In the BMCS truth definition (`bmcs_truth_at`), the box case is:
```
bmcs_truth_at B fam t (box phi) = forall fam' in B.families, bmcs_truth_at B fam' t phi
```

This only quantifies over families (at the same time t). The standard `truth_at` for box quantifies over all world histories, which in the indexed frame includes offset-shifted histories that access different times.

### 7.8 The Solution: Use Time-Indexed WorldStates

The solution is to make `WorldState = Set Formula` (bare MCSs, without family/time tags) and define the task relation differently. But as research-001 Section 4.3 noted, this has compositionality issues.

**Alternative solution**: Recognize that the standard semantics and the BMCS semantics are DIFFERENT but equivalent for completeness purposes. The bridge goes through `bmcs_truth_at`, not through `truth_at` directly.

### 7.9 The Correct Bridge Strategy

Instead of proving a direct equivalence between `fam.mcs t` and `truth_at` in the canonical frame, we should:

1. **Use bmcs completeness** (already proven) to get: consistent phi implies bmcs_satisfiable.
2. **Construct a standard model** from the BMCS that witnesses `formula_satisfiable phi`.
3. **The standard model construction** uses a DIFFERENT frame than the indexed approach.

The correct standard frame for the bridge:

```lean
def canonical_frame_standard : TaskFrame D where
  WorldState := Set Formula  -- bare MCSs
  task_rel := fun w d u =>
    exists fam in B.families, exists t : D,
      fam.mcs t = w /\ fam.mcs (t + d) = u
  nullity := ...    -- uses fact that every MCS in the model has a witnessing family/time
  compositionality := ...  -- uses family composition (research-002)
```

But compositionality for arbitrary sign durations remains problematic.

### 7.10 The Definitive Solution: Trivial Frame with Constrained Histories

After careful analysis, the correct approach is:

**Use a trivial frame where WorldState = D (time points) and task_rel t d t' iff t' = t + d.** Then define a specific MODEL over this frame, and show that the set of world histories for which the TruthLemma holds corresponds exactly to the BMCS families.

```lean
def time_frame : TaskFrame D where
  WorldState := D
  task_rel := fun t d t' => t' = t + d
  nullity := fun t => by simp
  compositionality := fun t u v x y h1 h2 => by subst h1; subst h2; ring

def time_model (fam : IndexedMCSFamily D) : TaskModel time_frame where
  valuation := fun t p => Formula.atom p in fam.mcs t

def time_history : WorldHistory time_frame where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => t
  respects_task := fun s t _ _ _ => by ring
```

In this frame, EVERY world history has `states t = t + c` for some constant offset c (because `task_rel (states s) (t - s) (states t)` gives `states t = states s + (t - s)`, i.e., the states function is an affine function of time).

The truth of `box phi` at `(time_model fam, time_history, t)` becomes:
```
forall sigma : WorldHistory time_frame, truth_at (time_model fam) sigma t phi
```

But `time_model fam` has a FIXED valuation determined by a SINGLE family fam. The box quantifies over all histories sigma, which have states `t + c` for various offsets c. The atoms evaluate as `(atom p) in fam.mcs(t + c)`.

This gives: `box phi true <-> forall c, phi true at (fam, t + c)`, which is NOT what we want.

**Conclusion**: A single family cannot support the box case. The box requires multiple families, each with its own model. But `truth_at` is defined relative to a SINGLE model M.

### 7.11 The Real Solution: Families ARE the World Histories, Not Time-Shifts

The fundamental insight is: **the standard semantics defines box as quantifying over world histories within a FIXED model M, where M determines which world histories exist.** The BMCS approach defines box as quantifying over families within a FIXED bundle B.

For the bridge, we need a model M such that:
- The set of world histories of the model corresponds to the set of families in the BMCS.
- Truth at each history matches truth at the corresponding family.

This means:
- WorldState should be rich enough that each family defines a distinct world history.
- The task relation should prevent "rogue" world histories.

**The indexed frame from Section 5.5 DOES work**, but the offset problem from Section 7.6 must be addressed by showing that offset-shifted histories DO correspond to valid BMCS evaluations.

Let me reconsider. With the indexed frame:
- World histories are `(fam, c)` pairs (family + offset).
- `truth_at M (fam, c) t phi` depends on fam.mcs(c + t) for atoms.

The box quantification becomes: `forall (fam', c), truth_at M (fam', c) t phi`.

By the IH (which ranges over ALL families and ALL times), `truth_at M (fam', c) t phi <-> phi in fam'.mcs(c + t)`.

So `box phi` is true iff `forall fam', forall c, phi in fam'.mcs(c + t)`, i.e., `forall fam', forall s, phi in fam'.mcs s`.

For the forward direction: `box phi in fam.mcs t` gives (by modal_forward) `phi in fam'.mcs t` for all fam'. But we need `phi in fam'.mcs s` for ALL s, not just s = t. This DOES NOT FOLLOW from modal_forward.

So the box case FAILS with the indexed frame because the standard semantics is too powerful -- it quantifies over time-shifted histories.

### 7.12 The Correct Model Design (Full Domain Restriction)

The solution is to RESTRICT the world histories by making the domain non-trivial. Instead of `domain = True` (all times), use a domain that pins the history to a specific time:

```lean
def canonical_history_at (B : BMCS D) (fam : IndexedMCSFamily D) (hmem : fam in B.families) (t0 : D) :
    WorldHistory (canonical_frame_I B) where
  domain := fun t => t = t0    -- singleton domain!
  convex := fun x z hx hz y hxy hyz => by
    rw [hx] at hxy; rw [hz] at hyz
    exact le_antisymm hyz hxy |>.symm ▸ hx
  states := fun t ht => ⟨fam, hmem, t⟩
  respects_task := fun s t hs ht hst => by
    rw [hs] at hst; rw [ht.symm ▸ hs]; exact ⟨rfl, by ring⟩
```

With a singleton domain `{t0}`, the world history only "exists" at time t0. The truth of atoms at time t /= t0 is FALSE (because tau.domain t is false). So temporal operators see atoms as false outside t0.

But this breaks the temporal operators (G, H) -- they quantify over ALL times, and atoms outside the domain are false, so G phi would require phi true at all future times, but atoms would be false.

**This approach doesn't work either.** The temporal semantics quantifies over ALL times, not just domain times.

### 7.13 Definitive Architecture: Non-Bridging Completeness

After thorough analysis, the correct architecture is:

**The BMCS completeness IS the completeness result.** The bridge to standard task-frame semantics is not needed for completeness per se -- the BMCS truth definition (`bmcs_truth_at`) is a valid semantics for TM logic. The `bmcs_valid` predicate quantifies over all BMCS, and `bmcs_weak_completeness` gives `bmcs_valid phi -> derivable phi`.

The standard validity (`valid phi`) quantifies over all TaskFrame models and all world histories, which is a different (and stronger) semantic notion. The relationship is:

```
derivable phi <-> bmcs_valid phi   (BMCS completeness, proven)
standard_valid phi -> derivable phi   (soundness, proven)
```

For a full equivalence `derivable phi <-> standard_valid phi`, we would need:
```
bmcs_valid phi -> standard_valid phi
```

This direction says: if phi is true in all BMCS, then phi is true in all standard models. This is NOT obvious and may not be what we want to prove.

The CONVERSE direction (which IS what the user wants) is:
```
standard_valid phi -> bmcs_valid phi
```

But this follows from soundness: `standard_valid phi -> derivable phi -> bmcs_valid phi`. Wait, no -- `derivable phi -> bmcs_valid phi` would need to be shown separately, and it is NOT the same as soundness.

Actually, the relationship is:
```
standard_valid phi -> derivable phi   (standard soundness, contrapositive of standard completeness)
derivable phi -> bmcs_valid phi       (BMCS soundness)
bmcs_valid phi -> derivable phi       (BMCS completeness, proven)
derivable phi -> standard_valid phi   (standard soundness, proven)
```

So we have: `derivable phi <-> bmcs_valid phi` and `derivable phi -> standard_valid phi`. The missing piece for full equivalence is `standard_valid phi -> derivable phi`, which is standard completeness. This is what the canonical frame bridge would provide, but as shown above, it requires careful construction.

### 7.14 The Achievable Bridge

What IS achievable without the full standard-semantics TruthLemma:

**Representation theorem bridge**: If phi is consistent, then phi is satisfiable in some standard task frame model.

This requires constructing ONE standard model satisfying phi, not characterizing ALL standard models. Here is how:

```lean
theorem standard_representation (phi : Formula) (h_cons : ContextConsistent [phi]) :
    formula_satisfiable phi := by
  -- By BMCS representation: exists B, bmcs_truth_at B B.eval_family 0 phi
  obtain ⟨B, h_true⟩ := bmcs_representation phi h_cons
  -- Construct a standard model from B
  -- Use: WorldState = Set Formula (MCSs), task_rel = family-mediated
  -- Use: a SINGLE world history corresponding to eval_family
  -- Show phi is true in this model at time 0
  sorry
```

For this, we need to construct:
1. A TaskFrame where the WorldState is Set Formula
2. A TaskModel with valuation matching MCS membership
3. A WorldHistory corresponding to the eval_family
4. A proof that phi is true at this (Model, History, time 0) triple

The key insight for this restricted goal: we only need ONE world history (the eval_family), and we need phi to be true at that one history. We do NOT need the box case to work perfectly -- we just need phi to evaluate to true.

But phi might CONTAIN box subformulas. If phi = box psi, then truth_at M sigma 0 (box psi) requires psi to be true at ALL world histories. So we still need the full box case.

**Unless** we can construct a model with exactly the right set of world histories. This is the problem we've been circling around.

## 8. The Correct Canonical Frame for Standard Completeness

### 8.1 The Key Insight: Use a Permissive Task Relation

The problem in Sections 7.6-7.12 was that the indexed frame creates too many world histories (including offset-shifted ones). The solution is to use a task frame where the task relation is PERMISSIVE (like the trivial frame), but the MODEL restricts which formulas are true.

Specifically, use:

```lean
def canonical_frame_permissive (B : BMCS D) : TaskFrame D where
  WorldState := B.families.toType x D   -- (family, time) pairs, but task_rel is permissive
  task_rel := fun (fam1, t1) d (fam2, t2) => t2 = t1 + d  -- only constrains time, not family
  nullity := fun (fam, t) => by simp
  compositionality := fun _ _ _ _ _ h1 h2 => by simp at *; linarith
```

Now world histories can switch families at different times! A world history sigma maps each time t to `(sigma_fam(t), t)` where sigma_fam is an ARBITRARY function from D to families (because task_rel only constrains time, not family).

This means:
```
truth_at M tau t (box phi) = forall sigma, truth_at M sigma t phi
```
where sigma ranges over ALL family-assignment functions.

For the atom case: `truth_at M sigma t (atom p) = (atom p) in sigma_fam(t).mcs(t)`.

For box phi at canonical history fam: `forall sigma_fam, truth_at M sigma t phi` where sigma assigns sigma_fam(t) at each time t.

**At time t, what matters is sigma_fam(t).** For box phi at time t, we need phi to be true for all choices of sigma_fam(t). Since sigma_fam(t) can be ANY family in B.families, this gives `forall fam' in B.families, truth_at M (fam', t) t phi`.

But for the temporal case (G phi), we need phi at all s >= t in the SAME history sigma, which means the SAME family-assignment function. This is more subtle.

Wait -- for the temporal case:
```
truth_at M sigma t (G phi) = forall s >= t, truth_at M sigma s phi
```

Here sigma is a SINGLE world history, so sigma_fam is a SINGLE function. For truth at different times s, the atoms evaluate using sigma_fam(s).mcs(s), which can be a different family at each time.

This means G phi is true at sigma iff phi is true at all future times s using whatever family sigma assigns at time s. This is NOT the same as "phi in fam.mcs s for all s >= t" (which uses a FIXED family fam).

**This approach also doesn't give the right TruthLemma.** The temporal case requires a fixed family along the history, but the permissive task relation allows family switching.

### 8.2 The Constrained Solution: Family-Preserving Task Relation

Going back to the indexed frame with the constraint that task_rel requires the same family:

```lean
task_rel := fun w d u => w.family = u.family /\ u.time = w.time + d
```

This ensures all world histories use a SINGLE family (constant along the history). The only freedom is the time offset c.

The box case: `forall (fam', c), truth_at M (fam', c) t phi`.

By the TruthLemma IH applied at family fam' and time c+t:
```
truth_at M (canonical_history fam') (c+t) phi <-> phi in fam'.mcs(c+t)
```

And by time_shift_preserves_truth:
```
truth_at M (offset_history fam' c) t phi <-> truth_at M (canonical_history fam') (c+t) phi
```

So:
```
box phi true at (canonical_history fam, t)
  <-> forall fam' in B.families, forall c : D, phi in fam'.mcs(c + t)
  = forall fam' in B.families, forall s : D, phi in fam'.mcs s
```

And `box phi in fam.mcs t`:
  - Forward: gives phi in fam'.mcs t for all fam'. But does NOT give phi in fam'.mcs s for s /= t.
  - So the forward direction FAILS.

**This confirms the fundamental mismatch**: the standard box semantics (quantifying over all world histories including time-shifted ones) is strictly stronger than the BMCS box semantics (quantifying over families at a fixed time).

### 8.3 Resolution: The BMCS Semantics IS Standard-Equivalent via Soundness

The resolution comes from recognizing that the proof system's axioms FORCE the equivalence:

1. `box phi -> phi` (T axiom) is valid in both BMCS and standard semantics.
2. `phi -> box(box phi)` (5 axiom for S5) holds in both.
3. More importantly: `box phi -> G(box phi)` and `box phi -> H(box phi)` (the MF and TF axioms) are in the proof system.

The MF axiom says: if box phi holds now, then box phi holds at ALL future times. Combined with the T axiom: if box phi holds at time t, then phi holds at time t, AND box phi holds at time s for all s >= t, so phi holds at time s for all s >= t.

Similarly, the TF_past axiom: `box phi -> H(box phi)` gives phi at all past times.

So `box phi in fam.mcs t` implies (by MF/TF + T): `phi in fam'.mcs s` for ALL s and ALL fam'. This IS the strong condition needed for the standard semantics box case.

**Let me verify this reasoning more carefully.**

From `box phi in fam.mcs t`:
1. By `modal_forward`: `phi in fam'.mcs t` for all fam' in B.families.
2. By MF axiom (`box phi -> G(box phi)`) which is in the proof system:
   - `G(box phi) in fam.mcs t` (since MCS is closed under theorems + modus ponens).
   - By `forward_G`: `box phi in fam.mcs s` for all s > t.
   - By `modal_forward`: `phi in fam'.mcs s` for all fam' and all s > t.
3. Similarly, by TF_past axiom (`box phi -> H(box phi)`):
   - `H(box phi) in fam.mcs t`.
   - By `backward_H`: `box phi in fam.mcs s` for all s < t.
   - By `modal_forward`: `phi in fam'.mcs s` for all fam' and all s < t.
4. Combining: `phi in fam'.mcs s` for ALL fam' in B.families and ALL s in D.

For the **backward direction** of box in the TruthLemma:
Suppose `forall fam' in B.families, forall s, phi in fam'.mcs s`.
In particular, `forall fam' in B.families, phi in fam'.mcs t`.
By `modal_backward`: `box phi in fam.mcs t`.

So:
```
box phi in fam.mcs t <-> forall fam', forall s, phi in fam'.mcs s
```

And the RHS is exactly what we need for:
```
truth_at M tau t (box phi) = forall sigma, truth_at M sigma t phi
```

(where by the IH, `truth_at M sigma t phi <-> phi in sigma_fam.mcs(sigma_time + t) = phi in fam'.mcs s` for the appropriate family and time).

**THIS IS THE SOLUTION.** The MF and TF axioms in the proof system ensure that `box phi in MCS` is equivalent to the "everywhere in all families" condition, which matches the standard semantics box quantification over all time-shifted histories.

### 8.4 Required Lemmas

To make this work, we need the following lemmas in the BMCS infrastructure:

**Lemma 1 (box_implies_everywhere)**: If `box phi in fam.mcs t` for some fam in B.families, then `phi in fam'.mcs s` for ALL fam' in B.families and ALL s : D.

Proof:
- By MF axiom: `box phi -> G(box phi)` is a theorem, so in fam.mcs t.
- `box phi in fam.mcs t` + `box phi -> G(box phi)` in fam.mcs t gives `G(box phi) in fam.mcs t`.
- By forward_G: `box phi in fam.mcs s` for all s > t.
- Similarly by TF_past axiom: `box phi in fam.mcs s` for all s < t.
- By T axiom at t: `box phi in fam.mcs t` (already have).
- So `box phi in fam.mcs s` for ALL s.
- By modal_forward: `phi in fam'.mcs s` for all fam' and all s.

**Lemma 2 (everywhere_implies_box)**: If `phi in fam'.mcs s` for ALL fam' in B.families and ALL s : D, then `box phi in fam.mcs t` for any fam in B.families and any t.

Proof: In particular, `phi in fam'.mcs t` for all fam'. By modal_backward: `box phi in fam.mcs t`.

**Corollary**: `box phi in fam.mcs t <-> forall fam' in B.families, forall s : D, phi in fam'.mcs s`.

### 8.5 The Complete TruthLemma Proof Sketch

With the indexed frame (`canonical_frame_I B`):

```
phi in fam.mcs t <-> truth_at (canonical_model B) (canonical_history B fam hmem) t phi
```

By induction on phi:

- **Atom**: Direct (Section 7.2).
- **Bot**: Direct (Section 7.3).
- **Imp**: By IH on subformulas (Section 7.4).
- **Box phi**:
  Forward: box phi in fam.mcs t -> (by Lemma 1) forall fam' s, phi in fam'.mcs s -> (by IH) forall (fam', c), truth_at M (offset fam' c) t phi -> forall sigma, truth_at M sigma t phi.
  Backward: forall sigma, truth_at M sigma t phi -> in particular, for each fam' and offset c=0, truth_at M (canonical_history fam') t phi -> (by IH) phi in fam'.mcs t for all fam' -> (by Lemma 2) box phi in fam.mcs t.
- **G phi**: Forward: G phi in fam.mcs t -> forall s >= t, phi in fam.mcs s (by mcs_all_future_implies_phi_at_future) -> (by IH) forall s >= t, truth at fam s phi. Backward: use temporal_backward_G as in the BMCS truth lemma.
- **H phi**: Symmetric to G.

### 8.6 MF and TF Axiom Existence

We need to verify that the MF and TF axioms exist in the proof system. Looking at the codebase:

The MF axiom (`box phi -> G(box phi)`, i.e., "if necessarily phi, then always in the future necessarily phi") should be in the axiom set. Let me identify the relevant axiom names.

From the proof system axioms, the relevant ones are likely:
- `Axiom.mf` or similar: box phi -> G(box phi)
- `Axiom.tf_past` or similar: box phi -> H(box phi)

These are the "modal permanence" axioms that ensure modal truth persists across time. They are fundamental to the TM logic axiomatization.

## 9. Duration Group

### 9.1 Choice of D

The BMCS completeness proof instantiates D = Int. For the canonical task frame, we also use D = Int. This is sufficient because:

1. Int is a linearly ordered abelian group (AddCommGroup + LinearOrder + IsOrderedAddMonoid).
2. All temporal formulas in the syntax are finitary (no quantitative bounds on durations).
3. The representation theorem only needs ONE model, not models for all possible D.

### 9.2 Alternative: Rational or Real Time

Using D = Rat would give dense time (between any two times there is a third). Using D = Real would give continuous time. These are mathematically interesting but unnecessary for the completeness result, which is an existential statement.

For future work on the Finite Model Property or decidability, D = Int is actually preferable because it is discrete and countable.

## 10. Seed Construction

### 10.1 From a Consistent Formula

Given a consistent formula phi:

1. **Lindenbaum extension**: Extend {phi} to an MCS M0 (the "seed MCS").
2. **BMCS construction**: Use `construct_temporal_bmcs [phi] h_cons` to build a BMCS B over D = Int.
3. **phi in eval_family**: By `construct_temporal_bmcs_contains_context`, `phi in B.eval_family.mcs 0`.
4. **Temporal coherence**: By `construct_temporal_bmcs_temporally_coherent`, B is temporally coherent.
5. **Build canonical frame**: Define `canonical_frame_I B` and `canonical_model B`.
6. **Build canonical histories**: For each family in B, define the canonical world history.
7. **Apply TruthLemma**: `phi in B.eval_family.mcs 0 <-> truth_at (canonical_model B) (canonical_history B eval_family hmem) 0 phi`.
8. **Extract satisfiability**: The RHS witnesses `formula_satisfiable phi`.

### 10.2 The Construction Pipeline

```
consistent [phi]
  --> construct_temporal_bmcs [phi] h_cons : BMCS Int
  --> canonical_frame_I B : TaskFrame Int
  --> canonical_model B : TaskModel (canonical_frame_I B)
  --> canonical_history B eval_family : WorldHistory (canonical_frame_I B)
  --> truth_at (canonical_model B) (canonical_history B eval_family) 0 phi  (by TruthLemma)
  --> formula_satisfiable phi  (existential packaging)
```

This gives `standard_representation : consistent [phi] -> formula_satisfiable phi`.

### 10.3 From Representation to Standard Completeness

```
standard_weak_completeness : valid phi -> Nonempty (DerivationTree [] phi)
```

Proof (by contraposition): If not derivable, then consistent neg(phi) (by `not_derivable_implies_neg_consistent`). By standard_representation, formula_satisfiable (neg phi). But neg phi satisfiable means phi is not valid (at the witnessing model/history/time, neg phi is true, so phi is false). Contradiction.

## 11. Implementation Recommendations

### 11.1 Phase 1: Prove the MF/TF Propagation Lemma

Before building the canonical frame, prove:

```lean
theorem box_implies_everywhere (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hfam : fam in B.families)
    (phi : Formula) (t : D) (h_box : Formula.box phi in fam.mcs t) :
    forall fam' in B.families, forall s : D, phi in fam'.mcs s
```

This requires the MF and TF axioms from the proof system and the BMCS coherence conditions. Identify the exact axiom names in the codebase first.

### 11.2 Phase 2: Define the Canonical Frame and Model

```lean
-- File: Theories/Bimodal/Metalogic/Representation/CanonicalTaskFrame.lean
structure CanonicalWorldState (B : BMCS D) where ...
def canonical_frame (B : BMCS D) : TaskFrame D where ...
def canonical_model (B : BMCS D) : TaskModel (canonical_frame B) where ...
def canonical_history (B : BMCS D) (fam ...) : WorldHistory (canonical_frame B) where ...
```

### 11.3 Phase 3: Prove the Canonical TruthLemma

The proof delegates to the BMCS truth lemma for all cases except box. The box case uses the MF/TF propagation lemma from Phase 1.

### 11.4 Phase 4: Derive Standard Completeness

Use the canonical TruthLemma + seed construction to derive `formula_satisfiable phi` from `consistent [phi]`, then derive standard weak/strong completeness by contraposition.

### 11.5 Estimated Effort

| Phase | Effort | Dependencies |
|-------|--------|-------------|
| Phase 1: MF/TF propagation | 4-6 hours | MF/TF axiom identification |
| Phase 2: Frame definitions | 4-6 hours | Phase 1 |
| Phase 3: Canonical TruthLemma | 10-15 hours | Phase 2 |
| Phase 4: Standard completeness | 4-6 hours | Phase 3 |
| **Total** | **22-33 hours** | |

## 12. Open Questions

### 12.1 MF/TF Axiom Location

Which axioms in the proof system encode `box phi -> G(box phi)` and `box phi -> H(box phi)`? These need to be identified precisely.

### 12.2 False Axiom Dependencies

The BMCS construction depends on `temporally_saturated_mcs_exists` (mathematically false per Task 843). The canonical frame bridge inherits this dependency. Task 864's recursive seed approach aims to replace this axiom.

### 12.3 Non-Indexed Alternative

Is there a way to build a canonical frame with WorldState = Set Formula (bare MCSs) that avoids the offset problem? This would be more elegant but requires solving the compositionality issue for arbitrary-sign durations.

### 12.4 Relationship to the Permissive Frame

The "permissive task frame" idea (Section 8.1) could work if the world histories were constrained externally. This is essentially what the BMCS does -- it constrains which families (= histories) are considered. But in the standard semantics, the constraint must come from the task relation itself, not from an external bundle.

## 13. References

### Codebase Files

- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame structure with nullity/compositionality
- `Theories/Bimodal/Semantics/WorldHistory.lean` -- WorldHistory with convex domain, time_shift
- `Theories/Bimodal/Semantics/Truth.lean` -- truth_at with box, G, H cases; time_shift_preserves_truth
- `Theories/Bimodal/Semantics/TaskModel.lean` -- TaskModel with valuation
- `Theories/Bimodal/Semantics/Validity.lean` -- valid, semantic_consequence, formula_satisfiable
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` -- IndexedMCSFamily with forward_G, backward_H
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` -- BMCS with modal_forward, modal_backward
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` -- bmcs_truth_at definition, bmcs_valid
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- bmcs_truth_lemma (all cases proven)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` -- bmcs_representation, bmcs_weak_completeness
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- temporal_backward_G/H

### Key Codebase Definitions Used

- `truth_at` -- Standard semantic truth evaluation
- `bmcs_truth_at` -- BMCS-restricted truth evaluation
- `formula_satisfiable` -- Existential satisfiability in standard semantics
- `valid` -- Universal validity in standard semantics
- `bmcs_valid` -- Universal validity in BMCS semantics
- `time_shift_preserves_truth` -- Truth invariance under history time-shifts

## 14. Next Steps

1. **Identify MF/TF axioms** in the proof system (search for `box phi -> G(box phi)` pattern).
2. **Prove box_implies_everywhere** using MF/TF + modal_forward.
3. **Implement the canonical frame** (indexed approach from Section 5.5).
4. **Prove the canonical TruthLemma** using box_implies_everywhere for the box case.
5. **Derive formula_satisfiable** from BMCS representation + canonical TruthLemma.
6. **Derive standard completeness** from standard representation by contraposition.
