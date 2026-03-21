# Research Report 004: The Correct Canonical Frame and World History Definitions

**Task**: 930
**Session**: sess_1772072616_82b54d
**Date**: 2026-02-25
**Status**: Research complete

---

## 1. Deep Analysis of Standard Frame Requirements

### 1.1 The Three-Place Task Relation

The `TaskFrame` structure (TaskFrame.lean) defines:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity : forall w, task_rel w 0 w
  compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v
```

The key points:
- `task_rel w d u` is a **three-place** relation: "starting from world state `w`, executing a task of duration `d` can result in world state `u`."
- **Nullity**: Zero-duration tasks leave the world state unchanged (reflexivity at duration 0).
- **Compositionality**: Sequential tasks compose -- if `w` transitions to `u` in duration `x`, and `u` transitions to `v` in duration `y`, then `w` transitions to `v` in duration `x + y`.

This is NOT simply binary accessibility. The duration `d` is a genuine parameter. In the standard Kripke frame for S5, accessibility is a binary equivalence relation. Here, the duration adds a third dimension that connects modal and temporal structure.

### 1.2 WorldHistory.respects_task

```lean
respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

This says: For any two times `s <= t` in the history's domain, the world state at time `s` is related to the world state at time `t` by a task of duration `t - s`. The history is NOT just an arbitrary assignment of world states to times -- it must be **coherent** with the frame's task relation.

**Critical observation**: The duration in `task_rel` is exactly `t - s`, the time difference. This means the task relation must "know about" temporal duration. A task relation that ignores the duration parameter cannot meaningfully constrain world histories.

### 1.3 ShiftClosed

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

Where `time_shift sigma Delta` shifts the history by `Delta`:
- `(time_shift sigma Delta).domain z <-> sigma.domain (z + Delta)`
- `(time_shift sigma Delta).states z hz = sigma.states (z + Delta) hz`

ShiftClosed says: if a world history is in Omega, then **all** its temporal translates are also in Omega. This is essential for proving `time_shift_preserves_truth` (Truth.lean), which is needed for soundness of the MF and TF axioms.

### 1.4 The Gap Between BFMCS and Standard Semantics

The current completeness proof (Completeness.lean) works at the level of `bmcs_truth_at` (BFMCSTruth.lean), which is a **syntactic/Henkin-style** truth definition:

```lean
def bmcs_truth_at (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | Formula.atom p => Formula.atom p in fam.mcs t
  | Formula.box phi => forall fam' in B.families, bmcs_truth_at B fam' t phi
  | Formula.all_future phi => forall s, t <= s -> bmcs_truth_at B fam s phi
  | ...
```

This does NOT use `TaskFrame`, `WorldHistory`, `truth_at`, or `ShiftClosed` at all. The completeness result is:

```
derivable phi <-> bmcs_valid phi
```

But the standard semantics uses `truth_at` (Truth.lean), which requires a `TaskFrame`, a `TaskModel`, a set `Omega` of world histories, and evaluates truth at a specific world history and time. The soundness result is:

```
derivable phi -> valid phi   (where valid uses truth_at)
```

**The missing bridge**: To get `bmcs_valid phi -> valid phi`, we need to show that every BFMCS can be embedded into a standard semantic model. This is what the canonical frame construction is about.

---

## 2. Proposed Canonical Frame Definition

### 2.1 The Key Insight: WorldState = MCS

The correct choice is:

```
WorldState := Set Formula   -- an MCS (maximal consistent set)
```

Specifically, the canonical frame's world states are ALL maximal consistent sets. This is the standard choice in modal logic (Goldblatt, Blackburn-de Rijke-Venema, etc.).

**Why not FMCS?** An FMCS is a *family* of MCS indexed by time -- it is an entire world history, not a single world state. A world state is what exists at a single moment. An MCS captures the complete propositional and modal content at a single moment.

**Why not (FMCS, Time) pairs?** This conflates the world state with temporal position. World states should be abstract -- the history function assigns them to times. Having time inside the world state creates circular dependencies.

### 2.2 The Three-Place Canonical Task Relation

The critical definition:

```
task_rel M d M' := CanonicalR M M' /\ CanonicalR_past M' M
```

Or more precisely, using the duration:

```
task_rel M d M' :=
  (forall phi, Formula.all_future phi in M -> phi in M') /\
  (forall phi, Formula.all_past phi in M' -> phi in M)
```

Wait -- this ignores the duration `d`. Let me think more deeply.

**The duration problem**: In standard temporal logic completeness, the canonical frame for a tense logic has:
- Worlds = MCS
- Future relation R(M, M') iff GContent(M) subset M'
- Past relation R^{-1}(M, M') iff HContent(M) subset M'

But the task frame demands a THREE-place relation `task_rel M d M'` where `d` is a duration. The standard canonical model for tense logic does not have durations at all -- it has an ordering on worlds.

**Deep contemplation**: The paper's task frame generalizes the standard temporal frame. In the standard approach, there is an ordering on time points and world states at each time. The task relation `task_rel w d u` captures: "in duration d, world state w can evolve to world state u." The key is that in the CANONICAL construction, we do not need the duration to do anything non-trivial.

**The correct approach**: Define the canonical task relation to be DURATION-INDEPENDENT:

```lean
def CanonicalTaskRel (M : Set Formula) (d : D) (M' : Set Formula) : Prop :=
  GContent M subset M'  -- CanonicalR M M'
```

That is, `task_rel M d M'` iff `CanonicalR M M'`, regardless of `d`.

### 2.3 Nullity and Compositionality

**Nullity** (`task_rel M 0 M`): We need `CanonicalR M M`, i.e., `GContent M subset M`. This holds for any MCS `M` by the T-axiom `G phi -> phi` (already proven as `canonicalR_reflexive` in CanonicalFrame.lean).

**Compositionality** (`task_rel M x U /\ task_rel U y V -> task_rel M (x+y) V`): We need `CanonicalR M U /\ CanonicalR U V -> CanonicalR M V`. This is transitivity of `CanonicalR`, already proven as `canonicalR_transitive` in CanonicalFrame.lean using the Temporal 4 axiom `G phi -> GG phi`.

So the canonical TaskFrame is:

```lean
def CanonicalFrame (D) : TaskFrame D where
  WorldState := {M : Set Formula // SetMaximalConsistent M}
  task_rel := fun M d M' => CanonicalR M.val M'.val
  nullity := fun M => canonicalR_reflexive M.val M.property
  compositionality := fun M U V x y hMU hUV =>
    canonicalR_transitive M.val U.val V.val M.property hMU hUV
```

Note: We use a subtype `{M : Set Formula // SetMaximalConsistent M}` for WorldState to bundle the MCS property.

### 2.4 Why Duration-Independence is Correct

One might worry that ignoring the duration makes the frame degenerate. But this is actually standard and correct for completeness:

1. **Completeness is existential**: We only need ONE model satisfying our consistent context. The canonical model's task relation is maximally permissive (any MCS can reach any future-accessible MCS in any duration).

2. **The temporal structure comes from world histories**: The duration `d` matters in `respects_task`, where it constrains which state assignments count as legitimate histories. The task relation being permissive means MORE functions qualify as world histories, which is exactly what we need for completeness (we need to FIND satisfying histories, not rule them out).

3. **Soundness goes the other way**: Soundness restricts models; completeness constructs them. A permissive canonical frame gives MORE world histories, making it EASIER to satisfy a consistent context.

---

## 3. Proposed Canonical WorldHistory Construction

### 3.1 From FMCS to WorldHistory

Given an FMCS `fam : FMCS D`, we construct a `WorldHistory (CanonicalFrame D)`:

```lean
def FMCStoWorldHistory (fam : FMCS D) : WorldHistory (CanonicalFrame D) where
  domain := fun t => True   -- total domain (all times are in the history)
  convex := fun x z hx hz y hxy hyz => trivial
  states := fun t _ => {
    val := fam.mcs t,
    property := fam.is_mcs t
  }
  respects_task := fun s t hs ht hst => by
    -- Need: CanonicalR (fam.mcs s) (fam.mcs t)
    -- i.e., GContent (fam.mcs s) subset (fam.mcs t)
    -- This is: for all phi, G phi in fam.mcs s -> phi in fam.mcs t
    -- This follows from fam.forward_G since s <= t
    intro phi h_G_phi
    exact fam.forward_G s t phi hst h_G_phi
```

**Key property**: The `respects_task` obligation reduces to showing that `CanonicalR (fam.mcs s) (fam.mcs t)` whenever `s <= t`. This is exactly the `forward_G` coherence condition of FMCS! The FMCS structure was designed precisely to satisfy this.

### 3.2 Total Domain

We use `domain := fun t => True` (total domain). This is natural because:
- An FMCS assigns an MCS to EVERY time point `t : D`
- The FMCS `forward_G` and `backward_H` conditions hold for all times
- Total domain is trivially convex
- This matches the standard canonical model construction where world histories span all of time

### 3.3 The Valuation

The canonical model's valuation is standard:

```lean
def CanonicalValuation : TaskModel (CanonicalFrame D) where
  valuation := fun M p => Formula.atom p in M.val
```

An atom `p` is true at world state `M` (an MCS) iff `atom p` is in `M`.

---

## 4. Shift-Closure Strategy

### 4.1 The Problem

If we define `Omega` as the set of world histories arising from FMCS families in our BFMCS, shift-closure fails:
- `time_shift (FMCStoWorldHistory fam) Delta` shifts the MCS assignment: `states t = fam.mcs (t + Delta)`
- This corresponds to a "shifted FMCS" `fam'` where `fam'.mcs t = fam.mcs (t + Delta)`
- There is no reason this shifted family should be in our original BFMCS bundle

### 4.2 The Solution: Universal Omega

Define Omega as the set of ALL well-formed world histories over the canonical frame:

```lean
def CanonicalOmega (D) : Set (WorldHistory (CanonicalFrame D)) :=
  Set.univ  -- ALL world histories over the canonical frame
```

**Why this works**:
1. `Set.univ` is trivially shift-closed (already proven as `Set.univ_shift_closed` in Truth.lean)
2. Every FMCS-derived world history is in `Set.univ`
3. The `truth_at` definition with `Omega = Set.univ` gives:
   - `truth_at M Set.univ sigma t (box phi) = forall sigma' : WorldHistory F, truth_at M Set.univ sigma' t phi`
   - This universally quantifies over ALL world histories at time t

### 4.3 Why Universal Omega Does Not Break Completeness

The worry: if Box quantifies over ALL world histories, not just those from our BFMCS families, the truth lemma might fail.

**Analysis**: Let us trace the truth lemma for the box case:

**Forward** (`Box phi in fam.mcs t -> truth_at ... t (box phi)`):
- `Box phi in fam.mcs t` means, by BFMCS modal_forward: `phi in fam'.mcs t` for all fam' in the bundle
- We need: `truth_at M Omega sigma t phi` for ALL `sigma in Omega = Set.univ`
- This is: for EVERY world history `sigma` (not just FMCS-derived ones), phi is true at `sigma` at time t
- **This does NOT follow from phi being in finitely many families' MCS!**

This reveals a fundamental tension. The BFMCS approach achieves completeness by restricting box quantification to bundle families. The standard semantics quantifies over ALL world histories. These are different.

### 4.4 Revised Strategy: Omega = BFMCS-Derived Histories

Instead of `Set.univ`, define:

```lean
def BFMCSOmega (B : BFMCS D) : Set (WorldHistory (CanonicalFrame D)) :=
  { sigma | exists fam in B.families, exists Delta : D,
    sigma = time_shift (FMCStoWorldHistory fam) Delta }
```

This set consists of all time-shifted versions of FMCS-derived histories. It is shift-closed BY CONSTRUCTION:

**Proof sketch of shift-closure**: If `sigma in BFMCSOmega B`, then `sigma = time_shift (FMCStoWorldHistory fam) Delta` for some `fam` and `Delta`. Then `time_shift sigma Delta' = time_shift (time_shift (FMCStoWorldHistory fam) Delta) Delta'`. We need this to be in `BFMCSOmega B`. The double time-shift `time_shift (time_shift h Delta) Delta'` is the same as `time_shift h (Delta + Delta')` (by the group structure of D). This is still a shift of `FMCStoWorldHistory fam`, so it is in `BFMCSOmega B`.

Wait -- we need to verify that `time_shift (time_shift h Delta) Delta' = time_shift h (Delta + Delta')`. Let us check:
- `(time_shift (time_shift h Delta) Delta').domain z = (time_shift h Delta).domain (z + Delta') = h.domain (z + Delta' + Delta) = h.domain (z + (Delta' + Delta))`
- `(time_shift h (Delta + Delta')).domain z = h.domain (z + (Delta + Delta'))`
- These are equal if `Delta' + Delta = Delta + Delta'`, which holds since D is an additive commutative group.

Similarly for states. So shift-closure holds.

### 4.5 The Critical Observation: What Do Shifted FMCS Look Like?

`time_shift (FMCStoWorldHistory fam) Delta` is a world history where:
- `states t = fam.mcs (t + Delta)` (as an MCS)

This is itself an FMCS-derived history! It corresponds to the "shifted family" `fam_Delta` where `fam_Delta.mcs t = fam.mcs (t + Delta)`.

**Key question**: Does this shifted family satisfy the FMCS coherence conditions?

- **forward_G**: If `G phi in fam_Delta.mcs t = fam.mcs (t + Delta)` and `t <= t'`, then `phi in fam_Delta.mcs t' = fam.mcs (t' + Delta)`. Since `t <= t'` implies `t + Delta <= t' + Delta`, and `fam.forward_G` gives `phi in fam.mcs (t' + Delta)`, this holds.

- **backward_H**: Symmetric argument.

So shifted families ARE valid FMCS. This means `BFMCSOmega B` can be equivalently described as `{FMCStoWorldHistory fam' | fam' is a shifted version of some family in B}`.

### 4.6 Truth Lemma with BFMCSOmega

Now the box case of the truth lemma becomes:

**Forward** (`Box phi in fam.mcs t -> truth_at ... t (box phi)`):
- `Box phi in fam.mcs t`
- By BFMCS modal_forward: `phi in fam'.mcs t` for all `fam' in B.families`
- We need: for all `sigma in BFMCSOmega B`, `truth_at ... sigma t phi`
- Every `sigma in BFMCSOmega B` has the form `time_shift (FMCStoWorldHistory fam') Delta` for some `fam' in B.families` and some `Delta`
- At time t, `sigma.states t = fam'.mcs (t + Delta)`
- We need `phi in fam'.mcs (t + Delta)` -- but we only know `phi in fam'.mcs t`!

**This fails!** Knowing `phi in fam'.mcs t` does NOT give us `phi in fam'.mcs (t + Delta)` for arbitrary `Delta`. We would need `Box phi -> G(phi)` which is NOT a theorem of TM logic.

### 4.7 Resolution: The Two-Layer Structure

The failure above reveals a fundamental structural issue. The standard semantics has box quantifying over all histories AT A FIXED TIME, while BFMCS box quantifies over families at the same time index. The time-shifted histories evaluate at different "syntactic times."

**The correct resolution** is to recognize that in the canonical model, the box quantification in `truth_at` and in `bmcs_truth_at` are fundamentally different:

- `truth_at`: Box at `(sigma, t)` quantifies over `sigma' in Omega` -- different histories but SAME time `t`
- `bmcs_truth_at`: Box at `(fam, t)` quantifies over `fam' in B.families` -- different families at SAME time `t`

For the bridge to work, `Omega` must be chosen so that "all histories in Omega at time t" corresponds exactly to "all families in B at time t."

This means: at each time t, the set of world states `{sigma.states t | sigma in Omega, t in sigma.domain}` must equal `{fam.mcs t | fam in B.families}`.

**This is achieved by taking Omega = {FMCStoWorldHistory fam | fam in B.families} WITHOUT time shifts!**

```lean
def BFMCSOmega_NoShift (B : BFMCS D) : Set (WorldHistory (CanonicalFrame D)) :=
  { sigma | exists fam in B.families, sigma = FMCStoWorldHistory fam }
```

Then at time t, the set of states is exactly `{fam.mcs t | fam in B.families}`, which is what BFMCS box quantifies over.

**But this is NOT shift-closed!** And we NEED shift-closure for `time_shift_preserves_truth`.

### 4.8 The Deep Insight: Shift-Closure vs. Truth Lemma

We are caught between two requirements:
1. **Truth lemma**: Omega must contain exactly the BFMCS families (no shifts) so that box quantification matches
2. **Shift-closure**: Omega must contain all time-shifts so that temporal axiom soundness works

These are in tension. The resolution requires EITHER:

**(A) Redefine the canonical frame so that shifted histories correspond to the SAME MCS at the current time**, or

**(B) Build a BFMCS that is intrinsically closed under time-shifting of its families**, or

**(C) Bypass `truth_at` entirely and prove completeness with respect to `bmcs_valid` directly**, which is what the current code already does.

Let me explore each.

### 4.9 Approach (A): Make WorldState Time-Aware

If we set `WorldState := MCS x D` (pairs of MCS with a "reference time"), then the task relation can track temporal shifts:

```
task_rel (M, t0) d (M', t0') := CanonicalR M M' /\ t0' = t0 + d
```

A world history would assign `states t = (fam.mcs t, t)` -- the reference time equals the actual time. Shifting produces `states t = (fam.mcs (t + Delta), t + Delta)`. But now the "world state" at time t in the shifted history is `(fam.mcs (t + Delta), t + Delta)`, which is DIFFERENT from `(fam.mcs t, t)`.

This does not help with the truth lemma either, because atom evaluation would need to look at the MCS component, and shifted histories still see different MCS.

### 4.10 Approach (B): Shift-Closed BFMCS Bundle

Build a BFMCS where the set of families is itself closed under time-shifting of families:

```
ForallFamInB, ForallDelta, ShiftedFam(fam, Delta) in B.families
```

Where `ShiftedFam(fam, Delta).mcs t = fam.mcs (t + Delta)`.

With this, `BFMCSOmega_NoShift` is automatically shift-closed, because the time-shift of `FMCStoWorldHistory fam` is `FMCStoWorldHistory (ShiftedFam fam Delta)`, which is in `BFMCSOmega_NoShift` since `ShiftedFam fam Delta` is in B.families.

**AND** the truth lemma holds because at any time t, the set of states `{fam.mcs t | fam in B.families}` includes all shifted versions.

**The question is**: Can we build such a BFMCS that satisfies modal coherence?

**Modal forward**: `Box phi in fam.mcs t -> phi in fam'.mcs t` for all `fam' in B.families`. Since `B.families` now includes shifted families `fam'_Delta` where `fam'_Delta.mcs t = fam'.mcs (t + Delta)`, we would need `phi in fam'.mcs (t + Delta)` for ALL Delta. This requires `G(phi) in fam'.mcs t` (by forward_G propagation), which is STRONGER than what `Box phi` gives us.

**This also fails.** Box phi does NOT imply G phi in TM logic. (They are independent modalities.)

### 4.11 Approach (C): Completeness Relative to BFMCS Semantics

This is what the codebase already achieves! The current results are:

1. **Soundness**: `derivable phi -> valid phi` (using standard `truth_at` semantics)
2. **BFMCS Completeness**: `bmcs_valid phi -> derivable phi`

Combined: `bmcs_valid phi -> derivable phi -> valid phi`

This gives: `valid phi -> bmcs_valid phi` (by contraposition: if not derivable, then not bmcs_valid).

Actually, the implication chain is: `bmcs_valid phi -> derivable phi -> valid phi`, so `bmcs_valid phi -> valid phi`. But we want the OTHER direction for full completeness: `valid phi -> derivable phi`. We have it via: `not derivable phi -> not bmcs_valid phi` (contrapositive of BFMCS completeness). And we need: `not derivable phi -> not valid phi` (contrapositive of standard completeness). Since `bmcs_valid phi -> valid phi` would give `not valid phi -> not bmcs_valid phi`, composing: `not derivable phi -> not bmcs_valid phi`, which is what we already have.

Wait, let me redo this more carefully:

- Soundness: `derivable phi -> valid phi`
- BFMCS completeness: `bmcs_valid phi -> derivable phi`
- We want: `valid phi -> derivable phi`

From soundness and BFMCS completeness: `bmcs_valid phi -> derivable phi -> valid phi`.

But we ALSO need: `valid phi -> bmcs_valid phi`. This requires showing that every BFMCS model is a special case of a standard model. Precisely: if phi is true in ALL standard models, it must be true in ALL BFMCS.

This reduces to: for every BFMCS B, there exists a standard model (F, M, Omega) such that `bmcs_truth_at B fam t phi <-> truth_at M Omega (FMCStoWorldHistory fam) t phi`.

**This is exactly the embedding we need.** And the earlier analysis shows it requires shift-closure, which creates the tension.

### 4.12 Actually, the Current Approach IS Complete

Let me re-read the code more carefully. The completeness theorem states:

```lean
theorem bmcs_weak_completeness (phi : Formula) (h_valid : bmcs_valid phi) :
    Nonempty (DerivationTree [] phi)
```

This says: if phi is valid in ALL BFMCS, then phi is derivable. By soundness, derivable implies valid (in standard semantics). So we have:

```
bmcs_valid phi -> derivable phi -> valid phi
```

For the converse direction, the contrapositive of BFMCS completeness gives:

```
not derivable phi -> not bmcs_valid phi
```

Soundness contrapositive gives:

```
not valid phi -> not derivable phi
```

But we want:

```
valid phi -> derivable phi
```

Which is the contrapositive of: `not derivable phi -> not valid phi`. But we only have `not derivable phi -> not bmcs_valid phi`, which is WEAKER than `not derivable phi -> not valid phi` (unless `bmcs_valid` implies `valid`).

**So there IS a gap**: The current code proves `bmcs_valid phi <-> derivable phi`, but to bridge to `valid phi <-> derivable phi`, we need to show either:
- `valid phi -> bmcs_valid phi` (every standard model can be captured by a BFMCS), or
- `not derivable phi -> not valid phi` (direct standard completeness), which is what requires the canonical frame embedding.

**However**, there is a simpler argument. By contraposition:
- `not derivable phi` means `[neg phi]` is consistent (by `not_derivable_implies_neg_consistent`)
- By BFMCS representation, there exists a BFMCS where `neg phi` is true
- If we can show this BFMCS can be embedded in a standard model, then `neg phi` is satisfiable in standard semantics, so `phi` is not valid.

This is exactly the path that needs the canonical frame embedding. But it only requires showing that ONE specific BFMCS embeds, not that ALL do.

---

## 5. The Correct Canonical Construction (Revised)

### 5.1 Starting Point: The Specific BFMCS from Completeness

Given a consistent context Gamma, the completeness proof constructs a specific BFMCS B via `construct_saturated_bfmcs_int`. This B has:
- A set of FMCS families (`B.families`)
- Modal forward/backward coherence
- Temporal coherence (forward_F, backward_P)
- The context Gamma is satisfied at `B.eval_family.mcs 0`

We need to embed THIS specific B into standard semantics.

### 5.2 The Canonical Frame for This BFMCS

```lean
WorldState := { M : Set Formula // SetMaximalConsistent M }

task_rel (M : WorldState) (d : D) (M' : WorldState) : Prop :=
  CanonicalR M.val M'.val
  -- equivalently: GContent M.val subset M'.val
  -- equivalently: forall phi, G phi in M.val -> phi in M'.val
```

Nullity and compositionality hold as argued in Section 2.3.

### 5.3 The Canonical World Histories

For each FMCS family `fam` in B.families, construct:

```lean
FMCStoWorldHistory fam : WorldHistory (CanonicalFrame D) where
  domain := fun _ => True
  convex := trivially
  states t _ := { val := fam.mcs t, property := fam.is_mcs t }
  respects_task s t _ _ hst :=
    -- Need: CanonicalR (fam.mcs s) (fam.mcs t) when s <= t
    -- This is: GContent (fam.mcs s) subset (fam.mcs t)
    -- Follows from fam.forward_G
    fun phi hG => fam.forward_G s t phi hst hG
```

### 5.4 Omega and Shift-Closure: The Closure Construction

To achieve shift-closure, define Omega as the **shift-closure** of the FMCS-derived histories:

```lean
def CanonicalOmega (B : BFMCS Int) : Set (WorldHistory (CanonicalFrame Int)) :=
  { sigma | exists fam in B.families, exists Delta : Int,
    sigma = time_shift (FMCStoWorldHistory fam) Delta }
```

This is shift-closed by construction (as argued in 4.4, using commutativity of addition).

**Each shifted history is also an FMCS-derived history**: `time_shift (FMCStoWorldHistory fam) Delta = FMCStoWorldHistory (shiftFMCS fam Delta)` where `shiftFMCS fam Delta` is the family with `mcs t = fam.mcs (t + Delta)`. This shifted family satisfies FMCS coherence (forward_G, backward_H) as shown in 4.5.

### 5.5 The Valuation

```lean
def CanonicalValuation : TaskModel (CanonicalFrame Int) where
  valuation M p := Formula.atom p in M.val
```

### 5.6 The Truth Lemma for Standard Semantics

**Claim**: For `sigma = FMCStoWorldHistory fam` and `Omega = CanonicalOmega B`:

```
truth_at CanonicalValuation Omega sigma t phi
  <-> phi in fam.mcs t
  <-> bmcs_truth_at B fam t phi
```

The second equivalence is the existing `bmcs_truth_lemma`. We need the first.

**Proof by structural induction on phi**:

**Atom case**: `truth_at ... sigma t (atom p) = exists (ht : sigma.domain t), CanonicalValuation.valuation (sigma.states t ht) p = exists (ht : True), atom p in (fam.mcs t) = atom p in fam.mcs t`. Matches.

**Bot case**: Both sides are False. Matches.

**Imp case**: By induction hypothesis. Matches.

**All_future case**: `truth_at ... sigma t (all_future phi) = forall s, t <= s -> truth_at ... sigma s phi`. By IH, this equals `forall s, t <= s -> phi in fam.mcs s`. By the existing truth lemma, this equals `bmcs_truth_at B fam t (all_future phi)` iff `all_future phi in fam.mcs t`. The argument requires `temporal_backward_G` (already proven). Matches.

**All_past case**: Symmetric. Matches.

**Box case**: This is the critical case.

`truth_at CanonicalValuation Omega sigma t (box phi) = forall sigma' in Omega, truth_at ... sigma' t phi`

Every `sigma' in Omega` has the form `time_shift (FMCStoWorldHistory fam') Delta` for some `fam' in B.families` and `Delta : Int`.

At time t, `sigma'.states t = fam'.mcs (t + Delta)`.

By IH (applied to the shifted history at time t):

`truth_at ... sigma' t phi <-> phi in fam'.mcs (t + Delta)`

So the box condition becomes:

`forall fam' in B.families, forall Delta : Int, phi in fam'.mcs (t + Delta)`

Which is: `forall fam' in B.families, forall t' : Int, phi in fam'.mcs t'` (since `t + Delta` ranges over all of Int as Delta varies).

But `bmcs_truth_at B fam t (box phi) = forall fam' in B.families, bmcs_truth_at B fam' t phi`.

By `bmcs_truth_lemma`, this equals: `forall fam' in B.families, phi in fam'.mcs t`.

**The mismatch**: Standard semantics box requires `phi in fam'.mcs t'` for ALL `t'`, while BFMCS box only requires `phi in fam'.mcs t` for the CURRENT time.

**This is a genuine gap.** `Box phi` at time t in standard semantics with shift-closed Omega implies phi at all times in all families, which is `Box (G phi) /\ Box (H phi)`. But in BFMCS semantics, `Box phi` at time t only means phi at time t in all families.

### 5.7 Root Cause Analysis

The root cause is that `time_shift_preserves_truth` (proven in Truth.lean) shows:

```
truth_at M Omega (time_shift sigma Delta) x phi <-> truth_at M Omega sigma (x + Delta) phi
```

So if `sigma' = time_shift (FMCStoWorldHistory fam') Delta`, then:

```
truth_at M Omega sigma' t phi <-> truth_at M Omega (FMCStoWorldHistory fam') (t + Delta) phi
```

The box at time t quantifies over ALL `sigma' in Omega`, which includes all shifts. So the box truth at time t in the standard semantics effectively "sees" all times in all families, not just time t.

**This is intrinsic to the shift-closed semantics.** The box operator in the standard shift-closed semantics is STRONGER than the box operator in BFMCS semantics.

### 5.8 The Real Resolution: A Different Omega (NOT Shift-Closed)

The paper requires ShiftClosed for soundness of MF and TF axioms. But what if we examine whether the MF/TF axioms are actually used in completeness?

**Completeness does NOT need soundness of MF/TF axioms.** Completeness is about constructing a model, not about verifying axiom soundness.

So the canonical embedding does NOT need Omega to be shift-closed. We can use:

```lean
def CanonicalOmega_Fixed (B : BFMCS Int) : Set (WorldHistory (CanonicalFrame Int)) :=
  { sigma | exists fam in B.families, sigma = FMCStoWorldHistory fam }
```

This is NOT shift-closed, but the truth lemma works:

**Box case**: `truth_at ... sigma t (box phi) = forall sigma' in CanonicalOmega_Fixed B, truth_at ... sigma' t phi`. Each such sigma' is `FMCStoWorldHistory fam'` for some `fam' in B.families`. By IH: `truth_at ... (FMCStoWorldHistory fam') t phi <-> phi in fam'.mcs t`. So the box condition is `forall fam' in B.families, phi in fam'.mcs t`, which matches `bmcs_truth_at B fam t (box phi)`.

**The truth lemma holds for Omega = CanonicalOmega_Fixed B**, even though this Omega is not shift-closed.

### 5.9 What We Lose Without Shift-Closure

Without shift-closure, `time_shift_preserves_truth` does not apply. But we do NOT need time_shift_preserves_truth for completeness. We need it for soundness of MF/TF axioms, which is a separate concern already handled by the existing soundness proof.

For completeness, the argument is:
1. If phi is consistent, construct BFMCS B where neg(phi) is satisfied
2. Embed B into standard semantics using CanonicalOmega_Fixed (NOT shift-closed)
3. The truth lemma gives: neg(phi) is true in the standard model
4. Therefore phi is not valid in this model
5. Therefore phi is not valid (in models with this specific Omega)

**BUT**: Standard validity requires truth at ALL Omega (including shift-closed ones). So showing phi fails at one non-shift-closed Omega only gives failure at that Omega, not failure of validity (which requires failure at ALL shift-closed Omega).

**Wait** -- let me re-read the validity definition:

```lean
def valid (phi : Formula) : Prop :=
  forall D ... F M Omega (h_sc : ShiftClosed Omega) tau (h_mem : tau in Omega) t,
    truth_at M Omega tau t phi
```

Validity quantifies over ALL shift-closed Omega. So to show phi is NOT valid, we need to find ONE shift-closed Omega where phi fails. A non-shift-closed Omega does not suffice.

### 5.10 The Final Resolution: Shift-Close the Omega

Given `CanonicalOmega_Fixed B`, take its shift-closure:

```lean
def ShiftClose (S : Set (WorldHistory F)) : Set (WorldHistory F) :=
  { sigma | exists tau in S, exists Delta, sigma = time_shift tau Delta }
```

Then `ShiftClose (CanonicalOmega_Fixed B) = CanonicalOmega B` (the set from 5.4).

The question reduces to: does the truth lemma still hold with the LARGER Omega = CanonicalOmega B?

From Section 5.6, we saw that the box case fails because Omega includes shifted histories. Let us re-examine.

**The key insight I missed**: `truth_at` with `Omega` as the shift-closure CHANGES the semantics of box. But we don't need the truth lemma to hold for Omega = full shift-closure. We need:

**If phi is consistent and neg(phi) is in some MCS, then phi is not valid.**

The valid definition quantifies: for ALL frames, models, shift-closed Omega, histories in Omega, and times. So phi is NOT valid iff there EXISTS a frame, model, shift-closed Omega, history in Omega, and time where phi fails.

We need to construct such a countermodel. The challenge is that with shift-closed Omega, the box becomes stronger. But we're constructing a countermodel for neg(phi) being TRUE (not for phi failing under box).

Actually, let me reconsider. We want to show neg(phi) is satisfiable. We need:

```
exists F M Omega (h_sc : ShiftClosed Omega) tau (h_mem : tau in Omega) t,
  truth_at M Omega tau t (neg phi)
```

For neg(phi) to be true, we need phi to be false. For an atom, phi is false if the atom is not in the MCS. For implications, it works inductively. The box case of neg(phi) is NOT problematic because neg(Box psi) means there EXISTS sigma in Omega where psi fails, which is an existential.

**Let me think about this differently.** The issue is not with neg(phi) directly, but with whether the truth of ARBITRARY formulas at the canonical model matches MCS membership. For completeness, we only need the truth of neg(phi) (or equivalently, the falsity of phi) at one specific history and time.

### 5.11 The Definitive Strategy: A Complete Canonical Embedding

Here is the final, correct approach:

**Step 1**: Build the BFMCS B from the consistent context [neg phi], getting `neg phi in B.eval_family.mcs 0`.

**Step 2**: Build the canonical frame:
- `WorldState := { M : Set Formula // SetMaximalConsistent M }`
- `task_rel M d M' := CanonicalR M.val M'.val`
- Nullity and compositionality from canonicalR_reflexive and canonicalR_transitive

**Step 3**: For EVERY MCS M (not just those in B.families), and for every time assignment `f : D -> {MCS}` that forms a valid FMCS, include the corresponding world history in Omega.

Specifically, define:

```lean
def UniversalCanonicalOmega : Set (WorldHistory (CanonicalFrame D)) :=
  { sigma : WorldHistory (CanonicalFrame D) | True }  -- ALL well-formed world histories
```

Since `task_rel` only requires `CanonicalR`, any FMCS with `forward_G` produces a valid world history. But `UniversalCanonicalOmega = Set.univ` is trivially shift-closed.

**Step 4**: Prove the truth lemma: for the SPECIFIC history `sigma_0 = FMCStoWorldHistory B.eval_family`, we have:

```
truth_at CanonicalValuation Set.univ sigma_0 0 (neg phi)
```

This requires showing `neg phi in B.eval_family.mcs 0 -> truth_at ... sigma_0 0 (neg phi)`.

The proof goes by induction on phi. The problematic box case:

`truth_at ... sigma_0 t (box psi) = forall sigma' in Set.univ, truth_at ... sigma' t psi`

This quantifies over ALL world histories. For `Box psi in B.eval_family.mcs t`, we need psi to hold at ALL world histories in `Set.univ` at time t. This is too strong -- we only know psi holds at families in B.

**So the full truth lemma with Set.univ does NOT hold.** Only a PARTIAL truth lemma holds (for non-box formulas, and for the forward direction of box).

### 5.12 The Correct Final Answer

After deep contemplation, here is the correct approach:

**The BFMCS completeness result IS the completeness result.** The gap between `bmcs_valid` and `valid` is bridged by showing:

```
valid phi -> bmcs_valid phi
```

This can be proven by showing that every BFMCS IS a standard model (with a specific Omega):

For any BFMCS B, define:
- Frame: WorldState = {MCS}, task_rel = CanonicalR
- Model: valuation M p = atom p in M
- Omega = {FMCStoWorldHistory fam | fam in B.families} (NOT shift-closed)
- History: FMCStoWorldHistory fam, time: t

Then: `bmcs_truth_at B fam t phi <-> truth_at CanonicalValuation Omega (FMCStoWorldHistory fam) t phi`

This holds because the truth definitions are structurally identical (atoms check MCS membership, box quantifies over the same set, temporals quantify over same ordinals).

BUT Omega is NOT shift-closed. So `truth_at` with this Omega does NOT satisfy the ShiftClosed condition in the definition of `valid`.

**The resolution**: The definition of `valid` can be relaxed to not require ShiftClosed, OR we prove that soundness does not need ShiftClosed for the axioms that ARE needed.

Actually, looking at the code again: `valid` DOES require `ShiftClosed Omega`:

```lean
def valid (phi : Formula) : Prop :=
  forall D ... Omega (h_sc : ShiftClosed Omega) tau (h_mem : tau in Omega) t,
    truth_at M Omega tau t phi
```

So `valid phi` means phi is true in ALL models with shift-closed Omega. To show `valid phi -> bmcs_valid phi`, we need: if phi is true in all standard models with shift-closed Omega, then phi is true in all BFMCS. Contrapositively: if phi fails in some BFMCS B, then phi fails in some standard model with shift-closed Omega.

We construct: the canonical frame, model, Omega = shift-closure of {FMCStoWorldHistory fam | fam in B}, and show phi fails somewhere in this model.

The challenge remains: the truth lemma with shift-closed Omega has the stronger box condition.

**The real mathematical answer** is:

The validity definition in the paper uses shift-closed Omega because the paper's logic includes the MF and TF axioms which require shift-closure for soundness. If we define validity WITHOUT the shift-closure condition:

```lean
def valid_general (phi : Formula) : Prop :=
  forall D ... F M Omega tau (h_mem : tau in Omega) t,
    truth_at M Omega tau t phi
```

Then `valid_general phi -> valid phi` (since shift-closed Omega is a special case), and `valid phi -> derivable phi` (by soundness + BFMCS completeness). And `derivable phi -> valid_general phi` also holds (by soundness, since derivable formulas are valid in ALL models).

But to get `valid phi -> derivable phi` directly, the current codebase's approach of proving `bmcs_valid phi <-> derivable phi` and separately `derivable phi -> valid phi` IS sufficient for full completeness when combined:

```
derivable phi -> valid phi    (soundness, proven)
valid phi -> derivable phi    (?? - THIS is the gap)
```

The gap `valid phi -> derivable phi` is the standard completeness. The BFMCS approach proves `bmcs_valid phi -> derivable phi`. To bridge, we need `valid phi -> bmcs_valid phi`.

**Final insight**: Every BFMCS model can be made into a standard model by adding a trivial shift-closed extension. Define Omega to be ALL world histories over the canonical frame (Set.univ, which is trivially shift-closed). Then phi being bmcs_valid means phi holds in all BFMCS, and if phi is valid (holds in all standard models with shift-closed Omega), then in particular it holds in the model with Set.univ as Omega.

But we need to show: if phi holds in the standard model with Omega = Set.univ, then it holds in all BFMCS. This requires showing that for every BFMCS B, the BFMCS truth `bmcs_truth_at B fam t phi` is implied by the standard truth `truth_at CanonicalValuation Set.univ (FMCStoWorldHistory fam) t phi`. But this only holds if box in standard semantics (quantifying over Set.univ) is STRONGER than box in BFMCS (quantifying over B.families). Which it is! If phi holds for ALL world histories, it certainly holds for the BFMCS-specific histories.

**So `valid phi -> bmcs_valid phi` holds** if we can show:

```
forall B : BFMCS, forall fam in B.families, forall t,
  truth_at CanonicalValuation Set.univ (FMCStoWorldHistory fam) t phi
  -> bmcs_truth_at B fam t phi
```

**Proof by induction on phi**:
- **Atom**: Both check `atom p in fam.mcs t`. Identical.
- **Bot**: Both are False.
- **Imp**: By IH on both subformulas.
- **Box**: `truth_at ... Set.univ sigma t (box psi)` = forall sigma' (regardless of membership), `truth_at ... sigma' t psi`. This includes the BFMCS-specific histories. By IH, this implies `bmcs_truth_at B fam' t psi` for each `fam' in B.families`. So `bmcs_truth_at B fam t (box psi)`.
- **All_future/All_past**: By IH at each time.

**This works!** The key is that standard box with `Omega = Set.univ` is STRONGER than BFMCS box, so standard truth implies BFMCS truth.

---

## 6. Summary and Concrete Next Steps

### 6.1 The Complete Picture

The completeness theorem chain is:

1. **Soundness** (already proven): `derivable phi -> valid phi`
2. **BFMCS Completeness** (already proven): `bmcs_valid phi -> derivable phi`
3. **Standard-to-BFMCS bridge** (to be proven): `valid phi -> bmcs_valid phi`

Combined: `valid phi <-> derivable phi` (full completeness).

The bridge (3) is proven by showing that for any BFMCS B, there exists a standard model M with shift-closed Omega = Set.univ such that standard truth implies BFMCS truth. Since standard truth with Set.univ has a STRONGER box (quantifying over all histories), it implies the BFMCS-restricted box.

### 6.2 Canonical Frame Definition (to implement)

```lean
def CanonicalFrame (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskFrame D where
  WorldState := { M : Set Formula // SetMaximalConsistent M }
  task_rel := fun M _ M' => CanonicalR M.val M'.val
  nullity := fun M => canonicalR_reflexive M.val M.property
  compositionality := fun M U V _ _ hMU hUV =>
    canonicalR_transitive M.val U.val V.val M.property hMU hUV
```

### 6.3 Canonical WorldHistory (to implement)

```lean
def FMCStoWorldHistory (fam : FMCS D) :
    WorldHistory (CanonicalFrame D) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => ⟨fam.mcs t, fam.is_mcs t⟩
  respects_task := fun s t _ _ hst =>
    fun phi hG => fam.forward_G s t phi hst hG
```

### 6.4 Canonical Valuation (to implement)

```lean
def CanonicalValuation (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] :
    TaskModel (CanonicalFrame D) where
  valuation := fun M p => Formula.atom p in M.val
```

### 6.5 The Bridge Theorem (to implement)

```lean
theorem standard_truth_implies_bmcs_truth (B : BFMCS D)
    (fam : FMCS D) (hfam : fam in B.families) (t : D) (phi : Formula) :
    truth_at (CanonicalValuation D) Set.univ (FMCStoWorldHistory fam) t phi
    -> bmcs_truth_at B fam t phi
```

Proof by induction on phi. The key box case uses the fact that `Set.univ` box is stronger than BFMCS box.

### 6.6 The Final Completeness Theorem

```lean
theorem valid_implies_bmcs_valid (phi : Formula) (h : valid phi) : bmcs_valid phi := by
  intro D _ B fam hfam t
  -- Instantiate valid with the canonical frame, model, Set.univ, and FMCStoWorldHistory fam
  have h_std := h D (CanonicalFrame D) (CanonicalValuation D) Set.univ
    Set.univ_shift_closed (FMCStoWorldHistory fam) (Set.mem_univ _) t
  exact standard_truth_implies_bmcs_truth B fam hfam t phi h_std

theorem full_completeness (phi : Formula) : valid phi <-> Nonempty (DerivationTree [] phi) :=
  ⟨fun h => bmcs_weak_completeness phi (valid_implies_bmcs_valid phi h),
   fun ⟨d⟩ => soundness_theorem phi d⟩
```

### 6.7 Remaining Obstacles

1. **Universe levels**: `valid` uses `Type` while `CanonicalFrame` may need `Type*`. Need to ensure universe compatibility. The current `valid` definition uses `Type` (not `Type*`), which was specifically chosen for this purpose.

2. **Subtype coercion**: WorldState is `{M : Set Formula // SetMaximalConsistent M}`. Need to handle subtype projections cleanly.

3. **The bridge theorem induction**: The induction hypothesis for box requires applying IH to ARBITRARY world histories (not just FMCS-derived ones). Need to handle the case where `sigma'` in `Set.univ` may not correspond to any FMCS. For the box FORWARD direction (standard -> BFMCS), we only need IH for FMCS-derived histories (which are a subset of Set.univ), so this works.

4. **Existing sorry obligations**: The `fully_saturated_bfmcs_exists_int` still has a sorry. This is orthogonal to the canonical frame question but remains for overall completeness.

### 6.8 What Is NOT Needed

- No need to redefine the frame to use (MCS, Time) pairs
- No need for duration-aware task_rel (duration-independent suffices)
- No need for shift-closed Omega in the BFMCS embedding (use Set.univ)
- No need to modify the existing BFMCS truth definition or truth lemma
- No need to change the BFMCS completeness proof

### 6.9 Relationship to the User's Directive

The user asked to focus on the DEFINITION of a frame and world histories built out of syntax. The answer is:

1. **WorldState = MCS** (individual maximal consistent sets, NOT families)
2. **task_rel M d M' = CanonicalR M M'** (duration-independent, using GContent inclusion)
3. **World histories from FMCS**: Each FMCS family yields a world history with total domain
4. **Shift-closure**: Achieved trivially by using `Omega = Set.univ` in the bridge theorem
5. **The bridge** from `valid` to `bmcs_valid` uses the fact that `Set.univ` box is stronger than BFMCS box

The "action" is NOT in making Omega shift-closed by clever definitions. The action is in recognizing that the bridge from standard to BFMCS semantics goes in the easy direction: standard box is STRONGER, so standard truth implies BFMCS truth.
