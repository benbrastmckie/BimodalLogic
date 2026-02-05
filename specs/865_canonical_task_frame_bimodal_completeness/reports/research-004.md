# Research Report: Task #865 (Round 4)

**Task**: Canonical task frame for bimodal completeness
**Date**: 2026-02-05
**Focus**: Detailed comparison of two canonical frame constructions -- trajectory-based (explicit CanonicalTask objects with composition) versus family-based (simplified, using IndexedMCSFamily directly as implicit trajectories). Full mathematical definitions, TruthLemma analysis, and implementation recommendation.

## Summary

This report presents two complete constructions for the canonical task frame bridge from BMCS completeness to standard task-frame semantics, and provides a thorough comparison. Construction A (Trajectory-Based) defines explicit CanonicalTask objects as composable parametric functions with duration and trajectory, and builds the task relation as "exists a canonical task witnessing the relation." Construction B (Family-Based/Simplified) defines the task relation directly as "exists a family placing w at time t and u at time t+d," with no intermediate task object. After detailed analysis of both constructions' TruthLemma proofs, compositionality arguments, and Lean formalization complexity, the report recommends Construction B (the family-based approach) for implementation, specifically using the BMCS-indexed variant where WorldState = (family, time) pairs. The key finding is that both constructions converge to the same underlying mathematical content -- the differences are presentational, not substantive -- but Construction B avoids an unnecessary layer of indirection that would complicate formalization without providing additional mathematical insight.

## 1. Shared Prerequisites

Both constructions share the following foundational elements from the codebase and prior research.

### 1.1 The Semantic Target

The goal is to construct, for any temporally coherent BMCS B over duration group D, a standard TaskFrame/TaskModel/WorldHistory triple satisfying:

```
theorem canonical_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hmem : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t <-> truth_at (canonical_model B) (canonical_history B fam hmem) t phi
```

This connects MCS membership (the BMCS-level truth notion) to `truth_at` (the standard task-frame-level truth). The construction must supply: a TaskFrame, a TaskModel, a WorldHistory for each family, and a proof that the TruthLemma holds for all six formula cases.

### 1.2 The Codebase Definitions

From the codebase, the structures that must be instantiated are:

**TaskFrame D** (from TaskFrame.lean):
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

**WorldHistory F** (from WorldHistory.lean):
```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall s t (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**truth_at** (from Truth.lean):
```lean
def truth_at (M : TaskModel F) (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M tau t phi -> truth_at M tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), truth_at M sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M tau s phi
```

### 1.3 The Two Key Axioms

Both constructions rely on the modal-temporal interaction axioms for the box case:

- **MF** (Axiom.modal_future): `box phi -> box(G phi)` -- necessary truths remain necessary in the future
- **TF** (Axiom.temp_future): `box phi -> G(box phi)` -- necessary truths will always be necessary

These appear in `Theories/Bimodal/ProofSystem/Axioms.lean`. Note: MF says "box phi implies box of (always-future phi)," while TF says "box phi implies always-future of (box phi)." They are distinct axioms with different semantic content.

**Critical**: There are no explicit past-direction versions (box phi -> box(H phi) or box phi -> H(box phi)) in the axiom set. However, the past versions are derivable from MF/TF together with the S5 axioms (MB: phi -> box(diamond phi)) and temporal axiom TA (phi -> G(P phi)). Alternatively, the proof system may derive them through the contrapositive path. For the TruthLemma's box case, we only need the forward direction (box phi in fam.mcs t implies phi everywhere), and the backward direction uses modal_backward which is provided directly by the BMCS structure.

### 1.4 The Accessibility Relation

Between any two MCSs w, u drawn from the same family with w at time t and u at time t' (where t <= t'), the following **accessibility** relation holds:

```
accessible(w, u) iff
  (forall phi, G phi in w -> phi in u) /\    -- G-forward
  (forall phi, H phi in u -> phi in w)       -- H-backward
```

This is the two-place relation from research-003 Section 1. It holds between fam.mcs(t) and fam.mcs(t') for any t < t' by the IndexedMCSFamily forward_G and backward_H properties.

### 1.5 The Offset Problem and its Resolution

Research-003 identified a fundamental issue: the BMCS-indexed frame (WorldState = (family, time) pairs, task_rel requires same family + time arithmetic) creates world histories that include time-shifted versions. Every world history is determined by a family fam and an offset c, giving states at time t as (fam, hmem, c + t). The box case then quantifies over all (fam', c) pairs, requiring phi to hold at fam'.mcs(c + t) for ALL c -- meaning phi must hold at all times in all families, not just at time t.

**Resolution** (from research-003 Section 8.3): The MF and TF axioms, together with the temporal 4-axiom and modal coherence, ensure:

```
box phi in fam.mcs t
  => G(box phi) in fam.mcs t              (by TF axiom, MCS closure)
  => box phi in fam.mcs s for all s >= t  (by forward_G)
  => phi in fam'.mcs s for all fam', s >= t  (by modal_forward)
```

Similarly using the past direction:
```
box phi in fam.mcs t
  => [derivable: H(box phi) in fam.mcs t]
  => box phi in fam.mcs s for all s <= t  (by backward_H)
  => phi in fam'.mcs s for all fam', s <= t  (by modal_forward)
```

Combining: `box phi in fam.mcs t <=> forall fam' in B.families, forall s : D, phi in fam'.mcs s`.

This resolves the offset problem because the standard semantics box quantification (over all world histories including offset-shifted ones) yields exactly this "everywhere in all families" condition.

---

## 2. Construction A: Trajectory-Based

### 2.1 Core Idea

In Construction A, the canonical frame explicitly reifies tasks as first-class objects. A "canonical task" is a parametric function from a duration interval to MCSs, representing the trajectory of world-states during a task's execution. The three-place task relation `task_rel w d u` is then defined as "there exists a canonical task of duration d whose trajectory goes from w to u."

### 2.2 Definitions

**Definition A1 (CanonicalTask)**:
```lean
structure CanonicalTask (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  duration : D
  duration_nonneg : 0 <= duration
  trajectory : D -> Set Formula
  is_mcs : forall delta, SetMaximalConsistent (trajectory delta)
  forward_G : forall d1 d2 phi, 0 <= d1 -> d1 < d2 -> d2 <= duration ->
    Formula.all_future phi in trajectory d1 -> phi in trajectory d2
  backward_H : forall d1 d2 phi, 0 <= d2 -> d2 < d1 -> d1 <= duration ->
    Formula.all_past phi in trajectory d1 -> phi in trajectory d2
```

The trajectory is a total function `D -> Set Formula` but the coherence conditions only apply within the interval [0, duration]. Points outside this interval carry MCS data but are semantically irrelevant.

**Definition A2 (Canonical World State)**:
```lean
structure CanonicalWorldState (B : BMCS D) where
  carrier : Set Formula
  is_mcs : SetMaximalConsistent carrier
  -- Provenance: which family/time this MCS came from
  origin_family : IndexedMCSFamily D
  origin_time : D
  origin_mem : origin_family in B.families
  origin_eq : origin_family.mcs origin_time = carrier
```

**Definition A3 (Canonical Task Relation)**:
```lean
def canonical_task_rel_A (B : BMCS D) (w : CanonicalWorldState B)
    (d : D) (u : CanonicalWorldState B) : Prop :=
  exists (tau : CanonicalTask D),
    tau.duration = d /\
    tau.trajectory 0 = w.carrier /\
    tau.trajectory d = u.carrier /\
    (exists fam in B.families, exists t : D,
      forall delta, 0 <= delta -> delta <= d ->
        tau.trajectory delta = fam.mcs (t + delta))
```

This says: w is related to u by duration d if there exists a canonical task of that duration, starting at w, ending at u, whose trajectory lies entirely within some family in the BMCS.

**Definition A4 (Task Composition)**:
Given tasks tau1 (duration d1, from w to u) and tau2 (duration d2, from u to v), their sequential composition tau1 ; tau2 is:
```
(tau1 ; tau2).duration := d1 + d2
(tau1 ; tau2).trajectory(delta) :=
  if delta <= d1 then tau1.trajectory(delta)
  else tau2.trajectory(delta - d1)
```

The cross-boundary coherence (forward_G across the junction d1, backward_H across the junction) is proven using the temporal 4-axiom (G phi -> G(G phi), H phi -> H(H phi)), as analyzed in research-002 Section 2.5.

**Definition A5 (Vacuous/Identity Task)**:
```
vacuous(w).duration := 0
vacuous(w).trajectory(delta) := w   (constant function)
```

Coherence conditions are vacuously satisfied since there are no d1 < d2 with d1 >= 0 and d2 <= 0.

**Definition A6 (Canonical Frame A)**:
```lean
def canonical_frame_A (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldState B
  task_rel := canonical_task_rel_A B
  nullity := -- uses vacuous task
  compositionality := -- uses task composition
```

**Definition A7 (Canonical Model A)**:
```lean
def canonical_model_A (B : BMCS D) : TaskModel (canonical_frame_A B) where
  valuation := fun w p => Formula.atom p in w.carrier
```

**Definition A8 (Canonical World Histories)**:
Each family in the BMCS gives a canonical world history. For family fam with membership proof hmem:
```lean
def canonical_history_A (B : BMCS D) (fam : IndexedMCSFamily D)
    (hmem : fam in B.families) : WorldHistory (canonical_frame_A B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => {
    carrier := fam.mcs t,
    is_mcs := fam.is_mcs t,
    origin_family := fam,
    origin_time := t,
    origin_mem := hmem,
    origin_eq := rfl
  }
  respects_task := fun s t _ _ hst => by
    -- Need: canonical_task_rel_A B (states s) (t - s) (states t)
    -- Witness: task_from_family fam s t hst
    sorry -- constructing the explicit CanonicalTask witness
```

### 2.3 TruthLemma for Construction A

**Atom case**: `truth_at M_A tau_A t (atom p) = exists ht, M_A.valuation (tau_A.states t ht) p`. Since tau_A.domain t = True and M_A.valuation w p = (atom p in w.carrier), this reduces to `(atom p) in fam.mcs t`. Trivial.

**Bot case**: Trivial (MCS consistency).

**Imp case**: Standard MCS implication property, delegated to BMCS truth lemma.

**G/H cases**: G phi in fam.mcs t <-> forall s >= t, phi in fam.mcs s. Forward direction: fam.forward_G plus T-axiom for t = s. Backward direction: temporal_backward_G from TemporalCoherentConstruction.lean (contraposition via forward_F).

**Box case**: The box case requires showing that every WorldHistory of canonical_frame_A corresponds to a BMCS family (up to time-shift offset). A world history sigma must respect `canonical_task_rel_A`, which means for any s <= t in the domain, there exists a canonical task of duration t - s whose trajectory lies in some family. If the domain is {all of D}, then for each pair (s, t) the witnessing family might be different. However, the task_rel requires an EXPLICIT CanonicalTask witness for each pair, and these witnesses must be compatible along the history.

**Key difficulty for Construction A**: Characterizing ALL world histories of canonical_frame_A is complex. The task relation is existential (exists a task, exists a family), so a world history could in principle use different families for different time intervals. Showing that such histories always reduce to single-family evaluations (up to the offset resolution from Section 1.5) requires additional argumentation about how the existence of overlapping tasks forces family agreement.

### 2.4 Compositionality for Construction A

Compositionality for canonical_task_rel_A requires: if there exists a task from w to u of duration x (witnessed by some family fam1), and a task from u to v of duration y (witnessed by some family fam2), then there exists a task from w to v of duration x + y.

**Same-family case**: Trivial -- the family segment from w to v is itself a canonical task.

**Cross-family case**: Uses the family composition construction from research-002. Given fam1 and fam2 sharing junction point u, construct fam3 by case-splitting on time relative to the junction, with cross-boundary coherence via the 4-axiom. The composed family yields a canonical task from w to v.

**Sign restrictions**: The simple composition works when x >= 0 and y > 0 (or y = 0 trivially). Negative durations require additional case analysis (see research-002 Section 3.1).

### 2.5 Properties of Construction A

| Property | Status | Complexity |
|----------|--------|-----------|
| Nullity | Holds via vacuous task | Simple |
| Compositionality | Holds via task composition | Complex (cross-family, sign cases) |
| World history characterization | Requires proof of family coherence | Complex |
| Box case of TruthLemma | Depends on history characterization | Complex |
| G/H cases | Standard, delegates to BMCS | Simple |
| Lean formalization effort | High | Extra structure (CanonicalTask, composition) |

---

## 3. Construction B: Family-Based (Simplified)

### 3.1 Core Idea

In Construction B, there is no explicit "task" object. The task relation is defined directly in terms of family membership: w is related to u by duration d if some family in the BMCS places w at time t and u at time t + d. Families serve as implicit trajectories -- each family IS a trajectory through MCS-space, and any interval of a family witnesses a task relation instance.

Construction B has two variants:

- **Variant B1 (Bare MCS)**: WorldState = Set Formula (bare MCSs). The task relation uses existential family quantification. Compositionality requires family composition.
- **Variant B2 (BMCS-Indexed)**: WorldState = (family, time) pairs. The task relation requires same family + time arithmetic. Compositionality is trivial.

Research-003 recommended Variant B2, and this report analyzes both.

### 3.2 Variant B1: Bare MCS World States

**Definition B1-1 (World State)**:
```lean
def CanonicalWorldState_B1 (B : BMCS D) :=
  { M : Set Formula // exists fam in B.families, exists t : D, fam.mcs t = M }
```

**Definition B1-2 (Task Relation)**:
```lean
def canonical_task_rel_B1 (B : BMCS D)
    (w : CanonicalWorldState_B1 B) (d : D) (u : CanonicalWorldState_B1 B) : Prop :=
  exists fam in B.families, exists t : D,
    fam.mcs t = w.val /\ fam.mcs (t + d) = u.val
```

**Definition B1-3 (Canonical Frame B1)**:
```lean
def canonical_frame_B1 (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldState_B1 B
  task_rel := canonical_task_rel_B1 B
  nullity := fun w => by
    -- Need: exists fam t, fam.mcs t = w /\ fam.mcs (t + 0) = w
    -- Since t + 0 = t, just need: exists fam t, fam.mcs t = w
    -- This holds by definition of CanonicalWorldState_B1
    obtain ⟨fam, hfam, t, ht⟩ := w.property
    exact ⟨fam, hfam, t, ht, by rw [add_zero]; exact ht⟩
  compositionality := by
    -- Cross-family composition needed (research-002)
    sorry
```

**Compositionality difficulty**: Same as Construction A's cross-family case. Requires the family composition construction, with sign restrictions on durations.

### 3.3 Variant B2: BMCS-Indexed World States (Recommended)

**Definition B2-1 (World State)**:
```lean
structure CanonicalWorldState_B2 (B : BMCS D) where
  family : IndexedMCSFamily D
  family_mem : family in B.families
  time : D
```

**Definition B2-2 (Task Relation)**:
```lean
def canonical_task_rel_B2 (B : BMCS D)
    (w : CanonicalWorldState_B2 B) (d : D) (u : CanonicalWorldState_B2 B) : Prop :=
  w.family = u.family /\ u.time = w.time + d
```

**Definition B2-3 (Canonical Frame B2)**:
```lean
def canonical_frame_B2 (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldState_B2 B
  task_rel := fun w d u => w.family = u.family /\ u.time = w.time + d
  nullity := fun w => ⟨rfl, by simp [add_zero]⟩
  compositionality := fun w u v x y ⟨h1, h2⟩ ⟨h3, h4⟩ => by
    constructor
    · exact h1.trans h3
    · rw [h4, h2]; ring
```

**Definition B2-4 (Canonical Model)**:
```lean
def canonical_model_B2 (B : BMCS D) : TaskModel (canonical_frame_B2 B) where
  valuation := fun w p => Formula.atom p in w.family.mcs w.time
```

**Definition B2-5 (Canonical World History)**:
```lean
def canonical_history_B2 (B : BMCS D) (fam : IndexedMCSFamily D)
    (hmem : fam in B.families) : WorldHistory (canonical_frame_B2 B) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨fam, hmem, t⟩
  respects_task := fun s t _ _ hst => ⟨rfl, by ring⟩
```

### 3.4 World History Characterization for Variant B2

**Theorem (World History Structure)**: Every world history sigma of canonical_frame_B2 B with full domain is of the form (fam, hmem, c + t) for a fixed family fam, membership proof hmem, and constant offset c.

*Proof*: Let sigma be a world history with full domain. By respects_task, for any s <= t:
```
sigma.states s .family = sigma.states t .family   -- (family equality)
sigma.states t .time = sigma.states s .time + (t - s)   -- (time arithmetic)
```

The first condition means the family is constant along the history. Call it fam.

The second condition means: if we write time_s = (sigma.states s).time, then time_t = time_s + (t - s). Setting s = 0: time_t = time_0 + t. Let c = time_0. Then (sigma.states t).time = c + t for all t.

So sigma.states t = (fam, hmem, c + t). QED.

**Corollary**: World histories of canonical_frame_B2 B (with full domain) are parametrized by pairs (fam in B.families, c : D), where fam is the constant family and c is the time offset.

### 3.5 TruthLemma for Construction B (Variant B2)

**Statement**:
```
phi in fam.mcs t <-> truth_at (canonical_model_B2 B) (canonical_history_B2 B fam hmem) t phi
```

The proof is by structural induction on phi.

**Atom case**: `truth_at M tau t (atom p) = exists ht, M.valuation (tau.states t ht) p`. With tau = canonical_history_B2 B fam hmem:
- tau.domain t = True, so ht is trivial.
- tau.states t _ = (fam, hmem, t), a CanonicalWorldState_B2.
- M.valuation (fam, hmem, t) p = (Formula.atom p) in fam.mcs t.

Result: truth_at M tau t (atom p) <-> (atom p) in fam.mcs t. **Trivial.**

**Bot case**: truth_at = False, bot not in MCS by consistency. **Trivial.**

**Imp case**: By IH on both subformulas + MCS implication property. **Standard.**

**G case (all_future)**:
```
truth_at M tau t (G phi) = forall s, t <= s -> truth_at M tau s phi
```

By IH: truth_at M tau s phi <-> phi in fam.mcs s. So:
```
truth_at M tau t (G phi) <-> forall s, t <= s -> phi in fam.mcs s
```

Forward: G phi in fam.mcs t. For s > t: fam.forward_G gives phi in fam.mcs s. For s = t: the T-axiom (temp_t_future: G phi -> phi) gives phi in fam.mcs t.

Backward: (forall s >= t, phi in fam.mcs s) -> G phi in fam.mcs t. This is temporal_backward_G from TemporalCoherentConstruction.lean, proven by contraposition using forward_F and MCS maximality.

**H case (all_past)**: Symmetric to G case, using backward_H and temporal_backward_H.

**Box case** (the critical case):
```
truth_at M tau t (box phi) = forall sigma : WorldHistory F, truth_at M sigma t phi
```

By Section 3.4, every world history sigma with full domain is (fam', c) for some fam' in B.families and offset c : D. The truth at sigma with offset c:

For atoms: truth_at M (offset-history fam' c) t (atom p) = (atom p) in fam'.mcs(c + t).

For compound formulas: by IH applied at family fam' and time (c + t), using time_shift_preserves_truth to relate truth at (offset-history fam' c, t) to truth at (canonical_history fam', c + t).

So: truth_at M sigma t phi <-> phi in fam'.mcs(c + t) (by IH at fam' and time c + t).

Therefore:
```
truth_at M tau t (box phi)
  <-> forall fam' in B.families, forall c : D, phi in fam'.mcs(c + t)
  = forall fam' in B.families, forall s : D, phi in fam'.mcs s
    (substituting s = c + t, c ranges over all D)
```

**Forward**: box phi in fam.mcs t implies (forall fam', forall s, phi in fam'.mcs s).

Proof chain:
1. box phi in fam.mcs t.
2. By TF axiom (box phi -> G(box phi)) and MCS closure: G(box phi) in fam.mcs t.
3. By fam.forward_G for any s > t: box phi in fam.mcs s.
4. By T-axiom at t: box phi in fam.mcs t (already have).
5. For the past direction: we need H(box phi) in fam.mcs t. This is derivable from box phi via the proof system. (The derivation uses MF: box phi -> box(G phi), then the S5/temporal axioms to derive box phi -> H(box phi). See Section 4.1 for the detailed derivation.)
6. By backward_H: box phi in fam.mcs s for all s < t.
7. Combining steps 3, 4, 6: box phi in fam.mcs s for ALL s : D.
8. By modal_forward: phi in fam'.mcs s for all fam' in B.families and all s.

**Backward**: (forall fam' in B.families, forall s, phi in fam'.mcs s) implies box phi in fam.mcs t.

Proof: In particular, phi in fam'.mcs t for all fam' in B.families. By modal_backward: box phi in fam.mcs t.

### 3.6 Properties of Construction B (Variant B2)

| Property | Status | Complexity |
|----------|--------|-----------|
| Nullity | Trivial (rfl, simp) | Trivial |
| Compositionality | Trivial (trans, ring) | Trivial |
| World history characterization | Clean (constant family + offset) | Simple |
| Box case of TruthLemma | Uses MF/TF + offset resolution | Moderate |
| G/H cases | Standard, delegates to BMCS | Simple |
| Lean formalization effort | Low | No extra structures needed |

---

## 4. Deep Analysis of Differences

### 4.1 The Derivability of box phi -> H(box phi)

Both constructions need this for the box case backward-in-time direction. The proof system has:

- MF: box phi -> box(G phi)
- TF: box phi -> G(box phi)
- TA: phi -> G(P phi) -- "the present was in the past of the future"
- M4: box phi -> box(box phi)
- MB: phi -> box(diamond phi)
- temp_4: G phi -> G(G phi)
- temp_a: phi -> G(P phi)

Deriving box phi -> H(box phi):

**Approach 1 (via TA and duality)**:
1. box phi (given)
2. G(box phi) (by TF)
3. box phi -> G(P(box phi)) (by TA applied to box phi, giving box phi -> G(P(box phi)))

Wait, TA is phi -> G(P phi) where P = some_past (not all_past H). Let me reconsider.

TA (temp_a) is: phi -> G(F^{-1}(phi)) where F^{-1} = some_past. That is: phi -> G(P phi) where P is the existential past operator (P phi = not(H(not phi)) = some_past phi).

This does NOT directly give H(box phi). Let me re-examine what axioms are available for the past direction.

The axiom set includes temp_l: always(phi) -> G(H phi), where always(phi) = G phi /\ H phi (the "perpetuity" operator). So if we can derive always(box phi), we could get G(H(box phi)) and then H(box phi) by the T-axiom for G.

Actually, let me reconsider. From box phi:
1. box phi -> G(box phi) by TF
2. From step 1 + the original box phi, we might be able to derive H(box phi) if we have a "past TF" derivable.

The key observation is: the axiom set is NOT symmetric between past and future. There is no explicit "box phi -> H(box phi)" axiom. However, in TM logic (which is sound and complete for task frames), this should be derivable if it is valid.

**Validity argument**: In any task frame model, if box phi is true at (M, tau, t), then box phi is true at (M, sigma, t) for ALL sigma (box quantifies over all histories). In particular, for any time-shifted sigma, box phi is true at (M, time_shift(tau, delta), t) for all delta. By time_shift_preserves_truth, box phi is true at (M, tau, t + delta) for all delta. So G(box phi) is true at (M, tau, t). But we can also take negative delta, giving box phi at all past times, so H(box phi) is true.

So box phi -> H(box phi) IS valid. Since TM is sound and complete (modulo the axiom issues from task 843), it must be derivable. The derivation might use MF + TA + temporal duality.

**Practical impact for both constructions**: The derivation of "box phi in MCS t implies box phi in MCS s for all s" can be established as follows:
1. box phi in fam.mcs t (given)
2. G(box phi) in fam.mcs t (by TF + MCS closure under theorems and modus ponens)
3. box phi in fam.mcs s for all s > t (by forward_G)
4. For s <= t: We need box phi in fam.mcs s. We can argue:
   - box(G phi) in fam.mcs t (by MF + MCS closure)
   - Since G phi in fam'.mcs t for all fam' (by modal_forward on box(G phi))
   - In particular, G phi in fam.mcs t
   - So phi in fam.mcs s' for all s' >= t (by forward_G on G phi)
   - Also, from G(box phi) in fam.mcs t, box phi in fam.mcs s' for all s' > t
   - For past times: use TA (phi -> G(P phi)) with phi = box phi:
     box phi -> G(P(box phi)) (axiom instance of TA)
   - So G(P(box phi)) in fam.mcs t
   - P(box phi) in fam.mcs s for all s >= t (by forward_G)
   - P(box phi) = some_past(box phi) = not(H(not(box phi)))
   - P(box phi) in fam.mcs t means: exists s' < t with box phi in fam.mcs s'
   - But this only gives ONE past witness, not ALL past times.

**Alternative approach**: The simplest path for the implementation is to establish the following lemma at the BMCS level using the TemporalCoherentFamily infrastructure:

```
box_propagates_everywhere : box phi in fam.mcs t ->
  forall s : D, box phi in fam.mcs s
```

This can be proven by:
1. Forward direction: G(box phi) by TF, then forward_G.
2. Backward direction: By contraposition. Suppose box phi not in fam.mcs s for some s < t. Then neg(box phi) in fam.mcs s (MCS maximality). neg(box phi) = diamond(neg phi). So diamond(neg phi) in fam.mcs s. By the MCS property for diamond (if diamond psi in MCS, then exists fam' with psi in fam'.mcs s), neg phi in fam'.mcs s for some fam'. But we also have (from step 1 forward) box phi in fam.mcs s' for all s' > t, and by modal_forward, phi in fam'.mcs s' for all s' > t...

This is getting circular. Let me take a step back.

**The clean approach**: Instead of deriving the past propagation of box phi from axioms, we can use the BMCS structure directly. The BMCS modal coherence conditions give us:

- box phi in fam.mcs t => phi in fam'.mcs t for all fam' (modal_forward)
- (forall fam', phi in fam'.mcs t) => box phi in fam.mcs t (modal_backward)

Combined with TF (box phi -> G(box phi)), we get box phi at all future times. For past times, we use the following observation:

**If B is temporally coherent** (which is a hypothesis of the TruthLemma), then each family in B is a TemporalCoherentFamily, meaning it has forward_F and backward_P properties. We can then derive:

1. box phi in fam.mcs t
2. Suppose for contradiction: box phi not in fam.mcs s for some s < t
3. Then neg(box phi) = diamond(neg phi) in fam.mcs s
4. diamond(neg phi) in fam.mcs s means (by diamond property of the BMCS): exists fam' in B.families with neg phi in fam'.mcs s
5. But G(box phi) in fam.mcs t (by TF), so box phi in fam.mcs s' for all s' >= t
6. In particular, box phi in fam.mcs t, so phi in fam'.mcs t (by modal_forward)
7. G phi in fam'.mcs t (actually we need G phi... hmm)

This is still not clean. Let me try the direct approach using the temporal axiom `temp_4_past` (if it exists) or the existing `always` infrastructure.

**Actually**, the cleanest resolution for the implementation is: **use the `always` operator**. If we can show `always(box phi) in fam.mcs t` (where always phi = G phi /\ H phi), then temp_l gives G(H(box phi)), and the T-axiom gives H(box phi).

From box phi in fam.mcs t:
1. G(box phi) in fam.mcs t (by TF)
2. box(G phi) in fam.mcs t (by MF)
3. G phi in fam'.mcs t for all fam' (by modal_forward on step 2)
4. In particular, G phi in fam.mcs t
5. H phi in fam.mcs t? Not yet established.

For step 5, we need to work harder. This is the fundamental asymmetry: the axiom set has MF and TF for the future direction but not explicit past versions.

**Resolution for the implementation**: Rather than deriving box phi -> H(box phi) from the axioms (which may require a non-trivial derivation chain), we can establish it as a consequence of the semantic analysis. Since both constructions ultimately need this lemma, and it is valid (as shown by the semantic argument), we can:

(a) Prove it as a derived theorem in the proof system (effort: moderate, involves constructing a derivation tree), OR
(b) Use the fact that for the TruthLemma backward direction (going from standard semantics to MCS membership), we only need the WEAKER condition: (forall fam', forall s, phi in fam'.mcs s) -> box phi in fam.mcs t. This is just modal_backward applied at time t, and does NOT require past propagation.

**Option (b) is sufficient and avoids the derivability question entirely.** The backward direction of the box case only uses modal_backward at the evaluation time t. The forward direction is where we need the full "everywhere" propagation, and for that, the forward-time propagation (via TF + forward_G) covers the future, and we need the past direction only for the forward implication. But in the forward direction, we START with box phi in fam.mcs t and need to SHOW phi in fam'.mcs s for all fam' and s. For future s, this works. For past s, we need an additional argument.

**Final resolution**: The forward direction of the box case can be split:
- For (fam', c) with c + t >= some reference time: use TF + forward_G + modal_forward
- For (fam', c) with c + t < reference time: needs past propagation

Since c ranges over ALL of D, including very negative values, we cannot avoid the past direction. We MUST establish box phi -> H(box phi) or an equivalent.

**The derivation exists** via the following path:
1. box phi (given)
2. box(box phi) (by M4: box phi -> box(box phi))
3. box(G(box phi)) (by MF applied to box phi, using step 2: box(box phi) -> box(G(box phi))... wait, MF gives box phi -> box(G phi), not box(box phi) -> box(G(box phi)))

Let me be more careful. MF is: box psi -> box(G psi), for any psi. So:
- With psi = phi: box phi -> box(G phi)
- With psi = box phi: box(box phi) -> box(G(box phi))

From M4: box phi -> box(box phi).
Composing M4 with MF(psi=box phi): box phi -> box(box phi) -> box(G(box phi)).
So: box(G(box phi)) in fam.mcs t.
By modal_forward: G(box phi) in fam'.mcs t for all fam'.
In particular: G(box phi) in fam.mcs t.
By forward_G: box phi in fam.mcs s for all s > t.

For past: Use TA (temp_a): phi -> G(P phi) where P = some_past.
With phi = box phi: box phi -> G(P(box phi)).
So G(P(box phi)) in fam.mcs t.
By forward_G applied at any s > t: P(box phi) in fam.mcs s for all s > t.
By T-axiom for G at t itself: P(box phi) in fam.mcs t (from G(P(box phi)) -> P(box phi)).
P(box phi) in fam.mcs t means: some_past(box phi) in fam.mcs t, i.e., there exists s' < t with box phi in fam.mcs s'.

But this only gives ONE past time. We need ALL past times. Let me iterate:
- box phi in fam.mcs s' for some s' < t (from P(box phi) at t)
- G(box phi) in fam.mcs s' (by TF)
- P(box phi) in fam.mcs s' (by TA + T-axiom as above)
- So exists s'' < s' with box phi in fam.mcs s''

This gives an infinite descending chain of witnesses but does not directly give box phi at ALL past times. In a discrete setting (D = Int), this would suffice by induction. In a dense setting (D = Rat or Real), this only gives countably many witnesses.

**The correct approach uses backward_P**: If the family is a TemporalCoherentFamily (which it is, under the temporal_coherent hypothesis), then backward_P gives: P(box phi) in fam.mcs t implies exists s < t with box phi in fam.mcs s. Combined with the TA derivation, we can show box phi in fam.mcs s for all s by well-founded induction (for D = Int) or by a density argument.

**For D = Int (the concrete case)**: By backward induction. box phi in fam.mcs t. By TA: P(box phi) in fam.mcs t. By backward_P: exists s < t with box phi in fam.mcs s. Since D = Int and s < t, s <= t - 1. By induction: box phi in fam.mcs n for all n <= t. Combined with the forward direction: box phi in fam.mcs n for all n in Z.

**Both constructions face this same issue identically.** The derivation is the same regardless of whether we use explicit CanonicalTask objects or direct family-based task relations. This is a shared prerequisite, not a differentiator.

### 4.2 Structural Differences

| Aspect | Construction A (Trajectory) | Construction B2 (Family-Indexed) |
|--------|---------------------------|--------------------------------|
| WorldState type | MCS + provenance metadata | (family, time) pair |
| Task relation | Existential (exists CanonicalTask) | Algebraic (same family, time arithmetic) |
| Nullity proof | Via vacuous task | By rfl + simp |
| Compositionality proof | Via task composition (4-axiom) | By trans + ring |
| Intermediate objects | CanonicalTask, compose, vacuous | None |
| World histories | Requires characterization theorem | Direct characterization |
| Formalization overhead | ~200-300 lines for task infrastructure | ~50 lines total |

### 4.3 What Construction A Gains

1. **Category-theoretic structure**: Canonical tasks form a category where objects are MCSs and morphisms are tasks. Composition and identity make this precise. This is mathematically elegant and connects to higher-level categorical semantics.

2. **Explicit witnesses**: The task relation carries an explicit trajectory witness. This could be useful for extracting computational content (e.g., "given that w is related to u by duration d, produce a concrete sequence of intermediate states").

3. **Modularity**: The CanonicalTask structure can be studied independently of the BMCS. One could define canonical tasks from any source of temporally coherent MCS chains, not just BMCS families.

4. **Natural description of compositionality**: The task composition construction directly mirrors the semantic intuition of "doing task tau1 followed by task tau2."

### 4.4 What Construction A Loses

1. **Formalization complexity**: The CanonicalTask structure, composition proofs, and vacuous task add significant code. Each proof about the canonical frame must unfold through the existential quantifier over tasks.

2. **Indirect world history characterization**: Since the task relation is existential, characterizing all world histories requires showing that any sequence of task witnesses from a world history must be consistent (same family). This is an additional proof obligation.

3. **Redundancy with families**: Every CanonicalTask is ultimately derived from an IndexedMCSFamily segment (Definition A3 requires the trajectory to lie within some family). The CanonicalTask is therefore a redundant layer of abstraction over what families already provide.

4. **Sign complications in composition**: Task composition inherits the sign restrictions from research-002 (x >= 0, y > 0 for the simple case). While resolvable, this adds case analysis.

### 4.5 What Construction B2 Gains

1. **Simplicity**: The entire frame definition fits in ~10 lines. Nullity and compositionality are trivial. No intermediate structures needed.

2. **Transparent world history characterization**: The characterization of all world histories (constant family + offset) is immediate from the definition.

3. **Clean TruthLemma structure**: Each case of the TruthLemma directly accesses the BMCS structure without unwrapping existential quantifiers over tasks.

4. **Alignment with codebase**: The construction directly instantiates TaskFrame/TaskModel/WorldHistory without introducing new structure definitions. It reuses IndexedMCSFamily as-is.

5. **Trivial frame axioms**: Both nullity and compositionality are proved by `rfl`/`ring` -- there is zero mathematical content in these proofs because the structure is chosen to make them trivial. The mathematical content is concentrated in the TruthLemma where it belongs.

### 4.6 What Construction B2 Loses

1. **No reified task objects**: There is no explicit "task" entity that can be composed or studied independently. The task relation is purely relational.

2. **Tagged world states**: World states carry family/time tags rather than being bare MCSs. Two different (family, time) pairs can have the same underlying MCS, creating distinct world states with identical logical content. This is mathematically less natural (the "real" world state is the MCS, not the pair).

3. **Offset world histories**: The existence of offset-shifted world histories (where states at time t access fam.mcs(c + t) rather than fam.mcs(t)) complicates the box case. The resolution via MF/TF/time_shift_preserves_truth works but requires careful reasoning.

4. **No cross-family tasks**: The task relation is family-local. There is no single task from a state in family fam1 to a state in family fam2. Cross-family accessibility is modeled only through the box operator's history quantification, not through the task relation.

### 4.7 Semantic Faithfulness

**Which construction more faithfully matches the TaskFrame.lean semantics?**

Both constructions instantiate the same TaskFrame structure, so both are "faithful" in the technical sense. However:

- Construction B2's task relation (same family + time arithmetic) is very restrictive -- within any single world history, the task relation is essentially "advance time by d." The interesting structure is entirely in the BMCS bundle, not in the frame.
- Construction A's task relation (exists a trajectory) is more permissive and more "task-like" -- it captures the intuition that there is a meaningful process connecting w to u. However, since the trajectory must lie in a single family, the permissiveness is illusory.

**Verdict**: Construction B2 is more honest about where the mathematical content lives. The TaskFrame formalism requires nullity and compositionality, and B2 satisfies them trivially, making clear that the real structure is in the BMCS bundle and the TruthLemma, not in the frame axioms. Construction A dresses up what is essentially the same mathematical content with additional structure that does not carry genuine information.

### 4.8 Compositionality: Is It Needed?

In both constructions, the compositionality axiom of TaskFrame is required by the structure definition. The question is: does compositionality do any real work in the TruthLemma?

**Answer: No.** The TruthLemma never invokes the task relation directly. It works with:
- The valuation (for atoms)
- MCS membership and properties (for bot, imp)
- The BMCS modal coherence (for box)
- The family temporal coherence (for G, H)

The task relation only appears in the WorldHistory.respects_task field, which is used to establish that world histories have the correct structure. But in Construction B2, respects_task is trivially proved by `rfl + ring`, and the world history characterization does not rely on compositionality of the task relation.

**So compositionality is a structural requirement of TaskFrame that adds no mathematical content to the completeness proof.** Both constructions must satisfy it, but Construction B2 makes this non-contribution explicit by proving it trivially.

### 4.9 Nullity: How Each Construction Handles It

- **Construction A**: canonical_task_rel_A B w 0 w requires a canonical task of duration 0 from w to w. The vacuous task (Definition A5) provides this. The proof is simple but not trivial (must instantiate the existential with a specific task object).

- **Construction B2**: canonical_task_rel_B2 B w 0 w requires w.family = w.family (rfl) and w.time = w.time + 0 (by simp). Completely trivial.

- **Construction B1**: canonical_task_rel_B1 B w 0 w requires exists fam t, fam.mcs t = w and fam.mcs(t + 0) = w. Since t + 0 = t, this reduces to exists fam t, fam.mcs t = w, which holds by definition of CanonicalWorldState_B1. Simple but involves existential unpacking.

---

## 5. TruthLemma Comparison: Case-by-Case

### 5.1 Atom Case

Both constructions: Trivially reduces to atom-in-MCS. No difference.

### 5.2 Bot Case

Both constructions: Trivial (MCS consistency). No difference.

### 5.3 Imp Case

Both constructions: Standard MCS implication property. No difference.

### 5.4 G Case (all_future)

Both constructions: Forward uses forward_G + T-axiom. Backward uses temporal_backward_G. Identical reasoning, identical proof structure. The task relation is not involved.

### 5.5 H Case (all_past)

Both constructions: Symmetric to G case. Identical.

### 5.6 Box Case (the differentiator)

**Construction A**: The box case requires showing that every WorldHistory of canonical_frame_A corresponds to (up to truth-preserving isomorphism) a BMCS family evaluation.

Step 1: Characterize world histories. A world history sigma assigns states to all times, respecting canonical_task_rel_A. This means for any s <= t, there exists a CanonicalTask tau_{s,t} of duration t - s with sigma.states(s) at the start and sigma.states(t) at the end, and tau_{s,t}'s trajectory lies in some family.

Step 2: Show consistency. The tasks tau_{s,t} for overlapping intervals must use the same family (or at least agree on the MCS values at shared times). This requires a compatibility argument.

Step 3: Conclude that sigma corresponds to a single family (possibly time-shifted).

Step 4: Apply the IH and the offset resolution (Section 1.5).

**Construction B2**: The box case proceeds as in Section 3.5.

Step 1: World history characterization is immediate (constant family + offset, proved in Section 3.4).

Step 2: Apply IH + time_shift_preserves_truth for each (fam', c) pair.

Step 3: Reduce to "forall fam', forall s, phi in fam'.mcs s."

Step 4: Forward: MF/TF + modal_forward. Backward: modal_backward at time t.

**Comparison**: Construction B2's box case is significantly simpler because the world history characterization is immediate. Construction A requires an additional compatibility argument (Step 2) that has no analogue in B2.

---

## 6. Lean Formalization Comparison

### 6.1 Lines of Code Estimate

| Component | Construction A | Construction B2 |
|-----------|---------------|----------------|
| CanonicalTask structure | ~30 lines | 0 |
| Task composition | ~60 lines (with cross-boundary proof) | 0 |
| Vacuous task | ~15 lines | 0 |
| WorldState definition | ~15 lines (with provenance) | ~8 lines |
| TaskFrame definition | ~20 lines | ~12 lines |
| TaskModel definition | ~8 lines | ~8 lines |
| WorldHistory definition | ~30 lines (with task witness) | ~12 lines |
| World history characterization | ~40 lines | ~20 lines |
| TruthLemma (atom, bot, imp) | ~30 lines | ~30 lines |
| TruthLemma (G, H) | ~50 lines | ~50 lines |
| TruthLemma (box) | ~80 lines | ~50 lines |
| box_propagates_everywhere | ~60 lines | ~60 lines |
| **Total** | **~440 lines** | **~250 lines** |

Construction A requires roughly 75% more code than Construction B2, with the excess entirely in the task infrastructure (CanonicalTask, composition, vacuous task) and the more complex box case.

### 6.2 Proof Difficulty

**Construction A proofs that are genuinely harder**:
- Task composition cross-boundary coherence (forward_G across junction, needs 4-axiom chain)
- World history compatibility (showing overlapping tasks from a history use the same family)
- WorldHistory.respects_task (must construct an explicit CanonicalTask witness for each time pair)

**Construction B2 proofs that are trivial where A is non-trivial**:
- Nullity: `rfl, simp` vs. existential instantiation with vacuous task
- Compositionality: `trans, ring` vs. task composition construction
- WorldHistory.respects_task: `rfl, ring` vs. CanonicalTask witness construction

### 6.3 Dependency Profile

Both constructions depend on:
- IndexedMCSFamily (forward_G, backward_H)
- BMCS (modal_forward, modal_backward)
- TemporalCoherentFamily (forward_F, backward_P for temporal backward lemmas)
- Proof system axioms (MF, TF, M4, T-axioms)

Construction A additionally depends on:
- A CanonicalTask module (new code)
- A task composition module (new code)
- The temporal 4-axiom (G phi -> G(G phi)) for composition cross-boundary proofs

Construction B2 does NOT need the 4-axiom for the frame definition (since compositionality is trivial). The 4-axiom only appears in the TruthLemma's box case (for the "box phi propagates to all times" lemma), which both constructions share.

---

## 7. Edge Cases and Subtleties

### 7.1 World Histories with Non-Full Domain

Both constructions define canonical world histories with `domain = True` (full domain). However, the TaskFrame allows world histories with restricted domains. Are there world histories with non-full domain in the canonical frame?

**Construction B2**: A world history sigma with non-full domain still has respects_task. The domain must be convex. For any s, t in the domain, sigma.states(s).family = sigma.states(t).family and sigma.states(t).time = sigma.states(s).time + (t - s). So within its domain, the history has the same structure as the full-domain case: constant family, linear time.

The box case of truth_at quantifies over ALL world histories, including those with non-full domains. For a history sigma with domain D' (a convex subset of D), truth_at M sigma t (atom p) is false if t is not in D' (since the existential requires ht : sigma.domain t). So atoms are false outside the domain.

For the TruthLemma, the canonical history has full domain, so this is not an issue for the "forward" direction. For the "backward" direction (standard truth implies MCS membership), we need to show that truth at ALL histories (including restricted-domain ones) implies truth at the canonical history. But truth at a restricted-domain history makes atoms false outside the domain, so temporal formulas (G phi, H phi) could be affected.

**This is handled by the box semantics**: box phi is true at (M, tau, t) iff for ALL sigma, phi is true at (M, sigma, t). If sigma has a domain not containing t, then atoms at t are false, and the truth of phi at (M, sigma, t) depends on phi's structure (not on sigma's states at t). For the backward direction of the box case, we only need: "if phi is true at all (M, sigma, t), then in particular phi is true at each canonical history (fam', 0), giving phi in fam'.mcs t for all fam', giving box phi in fam.mcs t by modal_backward."

**Both constructions handle this identically.**

### 7.2 Non-Injective MCS Assignment

If fam.mcs is not injective (same MCS at different times), then:

- **Construction A**: Two CanonicalWorldStates with the same carrier MCS but different provenance (family, time) are distinct. The task relation treats them as different endpoints.
- **Construction B2**: Two CanonicalWorldState_B2 values with the same family but different times are distinct (because they have different .time fields). This is correct: the world state encodes "where we are in the flow of time," not just "what formulas hold."

No issues for either construction.

### 7.3 Empty BMCS

Both constructions require B.nonempty (the BMCS is non-empty). This is guaranteed by the BMCS structure definition.

---

## 8. Recommendation

### 8.1 Primary Recommendation: Construction B2 (Family-Indexed)

**Construction B2** (Variant B2 of the family-based approach) should be implemented. The reasons:

1. **Minimal code**: ~250 lines vs. ~440 for Construction A. The extra code in A provides no mathematical insight.

2. **Trivial frame axioms**: Nullity and compositionality are proved by `rfl + ring`. No intermediate structures, no composition arguments, no sign restrictions.

3. **Transparent box case**: The world history characterization is immediate, and the box case follows a clear logical path (offset resolution -> IH -> MF/TF propagation).

4. **Alignment with codebase philosophy**: The existing BMCS completeness proof works at the family level, not the task level. Construction B2 maintains this philosophy, adding only a thin veneer of TaskFrame structure.

5. **Shared hard parts**: The genuinely difficult mathematics (deriving box phi -> H(box phi), proving temporal backward lemmas, the MF/TF propagation) is identical in both constructions. Construction A adds difficulty (composition proofs) without adding value.

### 8.2 What to Keep from Construction A

The mathematical insights from Construction A should be documented but not implemented:

- **Canonical tasks as a category**: The observation that tasks form a category with MCSs as objects and CanonicalTasks as morphisms is mathematically interesting but not needed for completeness.
- **Family composition**: The result that families can be composed at shared junction points (research-002) is a useful mathematical fact that may have applications beyond the completeness bridge.
- **4-axiom role in composition**: The insight that temporal 4-axioms enable cross-boundary coherence is important for understanding the proof system's structure.

### 8.3 Implementation Outline for Construction B2

**File**: `Theories/Bimodal/Metalogic/Representation/CanonicalTaskFrame.lean`

```lean
-- Phase 1: Frame and Model definitions (~50 lines)
structure CanonicalWorldState (B : BMCS D) where ...
def canonical_frame (B : BMCS D) : TaskFrame D where ...
def canonical_model (B : BMCS D) : TaskModel (canonical_frame B) where ...
def canonical_history (B : BMCS D) (fam ...) : WorldHistory ... where ...

-- Phase 2: World history characterization (~30 lines)
theorem world_history_constant_family ...
theorem world_history_linear_time ...

-- Phase 3: Key propagation lemma (~60 lines)
theorem box_propagates_everywhere ...

-- Phase 4: Canonical TruthLemma (~100 lines)
theorem canonical_truth_lemma ...

-- Phase 5: Standard completeness bridge (~30 lines)
theorem standard_representation ...
theorem standard_weak_completeness ...
```

### 8.4 Risk Assessment

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|-----------|
| Past propagation of box phi | Medium | High (blocks box case) | Prove for D = Int by induction; general case may need additional axiom |
| Offset resolution in box case | Low | Medium | time_shift_preserves_truth already proven |
| Non-full domain histories | Low | Low | Handled by atom semantics (false outside domain) |
| False axiom dependencies | High | High | Inherited from BMCS; independent of frame construction choice |

### 8.5 Estimated Effort

| Phase | Effort | Notes |
|-------|--------|-------|
| Frame/Model/History definitions | 2-3 hours | Straightforward structure instantiation |
| World history characterization | 2-3 hours | Dependent type reasoning in Lean |
| box_propagates_everywhere | 4-6 hours | Needs MF/TF + past propagation argument |
| Canonical TruthLemma | 8-12 hours | Main effort; box case is the bottleneck |
| Standard completeness bridge | 2-3 hours | Existential packaging |
| **Total** | **18-27 hours** | |

---

## 9. References

### Codebase Files

- `Theories/Bimodal/Semantics/TaskFrame.lean` -- TaskFrame structure with nullity/compositionality
- `Theories/Bimodal/Semantics/WorldHistory.lean` -- WorldHistory with convex domain, time_shift
- `Theories/Bimodal/Semantics/Truth.lean` -- truth_at with box, G, H cases; time_shift_preserves_truth
- `Theories/Bimodal/Semantics/TaskModel.lean` -- TaskModel with valuation
- `Theories/Bimodal/Semantics/Validity.lean` -- valid, semantic_consequence, formula_satisfiable
- `Theories/Bimodal/ProofSystem/Axioms.lean` -- Axiom definitions including MF and TF
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` -- IndexedMCSFamily with forward_G, backward_H
- `Theories/Bimodal/Metalogic/Bundle/BMCS.lean` -- BMCS with modal_forward, modal_backward
- `Theories/Bimodal/Metalogic/Bundle/BMCSTruth.lean` -- bmcs_truth_at definition, bmcs_valid
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` -- bmcs_truth_lemma (all cases proven)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` -- bmcs_representation, bmcs_weak_completeness
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherentConstruction.lean` -- temporal_backward_G/H, forward_F/backward_P

### Previous Research Reports

- `specs/865_canonical_task_frame_bimodal_completeness/reports/research-001.md` -- Initial codebase inventory and BMCS-indexed frame proposal
- `specs/865_canonical_task_frame_bimodal_completeness/reports/research-002.md` -- Family composition and compositionality resolution
- `specs/865_canonical_task_frame_bimodal_completeness/reports/research-003.md` -- Canonical tasks as composable functions, offset problem, MF/TF resolution

### Key Axioms Used

| Axiom | Lean Name | Formula | Role in TruthLemma |
|-------|-----------|---------|-------------------|
| MF | Axiom.modal_future | box phi -> box(G phi) | Box case forward direction |
| TF | Axiom.temp_future | box phi -> G(box phi) | Box case forward direction |
| M4 | Axiom.modal_4 | box phi -> box(box phi) | Box propagation chain |
| MT | Axiom.modal_t | box phi -> phi | Box case, T-axiom |
| TT-G | Axiom.temp_t_future | G phi -> phi | G case, reflexive semantics |
| TT-H | Axiom.temp_t_past | H phi -> phi | H case, reflexive semantics |
| T4 | Axiom.temp_4 | G phi -> G(G phi) | (Only in Construction A composition) |
| TA | Axiom.temp_a | phi -> G(P phi) | Box propagation to past times |

## 10. Next Steps

1. **Implement Construction B2** as `CanonicalTaskFrame.lean`.
2. **Prove box_propagates_everywhere** using MF/TF + TA + backward induction for D = Int.
3. **Prove the canonical TruthLemma** by structural induction, delegating each case to BMCS lemmas.
4. **Derive standard_representation**: consistent phi -> formula_satisfiable phi.
5. **Derive standard_weak_completeness**: valid phi -> derivable phi (by contraposition).
