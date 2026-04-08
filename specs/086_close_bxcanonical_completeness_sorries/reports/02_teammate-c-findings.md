# Teammate C Findings: Canonical TaskModel Construction for Fragment Completeness

## 1. Exact Type of Sorry #5

The sorry at `Completeness.lean:144` has the following goal context:

```
phi : Formula
h_valid : valid phi             -- phi is valid (true in all models)
h_not_deriv : IsEmpty ([] |- phi)
h_not_deriv' : ~Nonempty ([] |- phi)
h_cons : SetConsistent {phi.neg}
M : Set Formula                  -- an MCS containing neg phi
hM_sup : {phi.neg} <= M
hM_mcs : SetMaximalConsistent M
h_neg_in : phi.neg in M
h_not_in : phi notin M
|- False
```

The goal is **`False`**. We have `h_valid : valid phi` (phi is true in ALL models) and an MCS `M` with `phi notin M`. We need to derive a contradiction by constructing a concrete model where phi is false, contradicting `h_valid`.

## 2. What `valid` Quantifies Over

From `Validity.lean:73-77`:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

To contradict `h_valid`, we must provide: a type `D`, a `TaskFrame D`, a `TaskModel F`, a shift-closed `Omega`, a history `tau in Omega`, and a time `t`, such that `NOT (truth_at M Omega tau t phi)`.

## 3. TaskFrame and TaskModel Structure

**TaskFrame D** (from `TaskFrame.lean:93-122`):
- `WorldState : Type` -- type of world states
- `task_rel : WorldState -> D -> WorldState -> Prop`
- `nullity_identity : forall w u, task_rel w 0 u <-> w = u`
- `forward_comp : forall w u v x y, 0 <= x -> 0 <= y -> task_rel w x u -> task_rel u y v -> task_rel w (x + y) v`
- `converse : forall w d u, task_rel w d u <-> task_rel u (-d) w`

**TaskModel F** (from `TaskModel.lean:43-49`):
- `valuation : F.WorldState -> Atom -> Prop`

**WorldHistory F** (from `WorldHistory.lean:69-97`):
- `domain : D -> Prop`
- `convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y`
- `states : (t : D) -> domain t -> F.WorldState`
- `respects_task : forall s t (hs : domain s) (ht : domain t), s <= t -> F.task_rel (states s hs) (t - s) (states t ht)`

**ShiftClosed** (from `Truth.lean:243-244`):
```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

## 4. truth_at Semantics

From `Truth.lean:120-131`:
```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (tau : WorldHistory F) (t : D) : Formula -> Prop
  | Formula.atom p => exists (ht : tau.domain t), M.valuation (tau.states t ht) p
  | Formula.bot => False
  | Formula.imp phi psi => truth_at M Omega tau t phi -> truth_at M Omega tau t psi
  | Formula.box phi => forall (sigma : WorldHistory F), sigma in Omega -> truth_at M Omega sigma t phi
  | Formula.all_past phi => forall (s : D), s <= t -> truth_at M Omega tau s phi
  | Formula.all_future phi => forall (s : D), t <= s -> truth_at M Omega tau s phi
  | Formula.untl phi psi => exists s, t <= s /\ truth_at M Omega tau s psi /\ forall r, t <= r -> r < s -> truth_at M Omega tau r phi
  | Formula.snce phi psi => exists s, s <= t /\ truth_at M Omega tau s psi /\ forall r, s < r -> r <= t -> truth_at M Omega tau r phi
```

Key observations:
- **Box** quantifies over ALL histories in Omega at the SAME time t
- **G/H** quantify over ALL times in D (not just domain times)
- **Atom** requires domain membership (false outside domain)
- **Until/Since** use reflexive witness with strict guard

## 5. Can BXPoints Be Organized Into a TaskFrame?

This is the central question. The canonical model construction must map the abstract BXPoint infrastructure into the concrete TaskFrame/TaskModel/WorldHistory/Omega structure.

### 5.1 What is D?

We need `D : Type` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. Since `valid` quantifies universally over D, we can CHOOSE any D. The natural choice is **`Int`** (discrete integer time), which is the simplest ordered abelian group.

However, since `valid` says phi is true in ALL models for ALL D, to get a contradiction we only need ONE countermodel. We can use `D = Int`.

### 5.2 What are the world states?

World states of the canonical frame should be **BXPoints** (maximal consistent sets). But we need to be careful: the TaskFrame's WorldState is the type of states that histories map TO.

### 5.3 The Task Relation Problem

This is the hardest part. A TaskFrame needs:
- `task_rel : WorldState -> D -> WorldState -> Prop`
- `nullity_identity`: `task_rel w 0 u <-> w = u`
- `forward_comp` and `converse`

The `nullity_identity` axiom requires that `task_rel w 0 u` iff `w = u`. This means if WorldState = BXPoint, then two BXPoints related at duration 0 must be **equal** (definitional equality). But distinct BXPoints that are bx_le-equivalent are NOT equal in general.

**Critical issue**: The canonical ordering `bx_le` is NOT antisymmetric on BXPoints. Two distinct MCS can be bx_le-equivalent (same g_content) while being different sets. The nullity_identity axiom demands exact equality at duration 0, which conflicts with the preorder nature of bx_le.

### 5.4 WorldHistory Construction

A WorldHistory maps times D -> WorldState (with domain/convexity/task constraints). For the canonical model, a history should represent a "temporal chain" of BXPoints ordered by bx_le.

Given an MCS M0, we need a WorldHistory tau such that:
- tau passes through M0 at time 0
- For all t >= 0: truth_at ... tau t phi iff phi in tau(t).formulas (truth lemma)
- The history respects the task relation

### 5.5 The Box/Omega Challenge

The box operator quantifies over ALL histories in Omega at the same time. For the box truth lemma, we need:

`truth_at M Omega tau t (box phi)` iff `box phi in tau(t).formulas`

The left side says: for ALL sigma in Omega, truth_at at (sigma, t). The right side says: for all modally equivalent v, phi in v.formulas.

This means Omega must contain, at each time t, histories that "visit" every modally equivalent BXPoint. Specifically, for each BXPoint w and each modally equivalent v, there should be some history sigma in Omega with sigma(t) = v.

## 6. Concrete Construction Sketch

### Step 1: Choose D = Int

### Step 2: Define WorldState = BXPoint

### Step 3: Define task_rel

The simplest approach that satisfies nullity_identity:
```
task_rel w d u := (d = 0 /\ w = u) \/ (d != 0 /\ bx_le w u /\ d > 0) \/ (d != 0 /\ bx_le u w /\ d < 0)
```

Wait, this won't work for forward_comp in general. The fundamental issue is that we need a DETERMINISTIC enough relation.

**Better approach**: Use the **identity frame** where `task_rel w d u := w = u /\ d = 0`? No, this is too restrictive -- histories would be constant, so G(phi) would degenerate to phi.

**Key insight**: For the G/H truth lemma, we need histories where different times map to different BXPoints related by bx_le. The task relation must allow this.

**Proposed task relation**:
```
task_rel w d u := (d >= 0 /\ bx_le w u) \/ (d <= 0 /\ bx_le u w)
```

Check nullity_identity: `task_rel w 0 u <-> w = u`?
- Forward: If task_rel w 0 u, then either (0 >= 0 and bx_le w u) or (0 <= 0 and bx_le u w). Both hold simultaneously, giving bx_le w u and bx_le u w. But this does NOT imply w = u since bx_le is a preorder, not a partial order!

**This is the fundamental obstacle**. The nullity_identity axiom of TaskFrame demands `task_rel w 0 u <-> w = u`, but canonical BXPoints can be bx_le-equivalent without being equal.

### Possible Solutions

**Solution A: Quotient by bx_le-equivalence**. Define an equivalence relation `w ~ u iff bx_le w u /\ bx_le u w` and use the quotient type as WorldState. Then the ordering becomes antisymmetric.

Problems:
- Need to show bx_modal_equiv respects this quotient
- Truth lemma must work on equivalence classes
- Valuation must be well-defined on classes

**Solution B: Use a permissive task frame**. Use `nat_frame` or `trivial_frame` (where task_rel is trivially true or nearly so) and encode the temporal structure entirely through WorldHistory construction.

Looking at `nat_frame`: `task_rel w d u := d != 0 \/ w = u`. This satisfies nullity_identity since at d=0 it reduces to w = u. forward_comp works (see the proof in TaskFrame.lean). converse works.

But nat_frame has WorldState = Nat, not BXPoint. We could use a frame with WorldState = BXPoint and a similarly permissive relation:
```
task_rel w d u := d != 0 \/ w = u
```

This satisfies all TaskFrame axioms (same proofs as nat_frame). And it allows histories to map different times to different BXPoints without constraint (as long as duration != 0).

**This is the right approach!** The task frame axioms are satisfied trivially, and all the "real" canonical model structure lives in the WorldHistory/Omega construction.

### Step 4: Define WorldHistory for a BXPoint chain

A "canonical history" through a chain of BXPoints: given a function `f : Int -> BXPoint` such that `bx_le (f i) (f j)` for all `i <= j`, define:
```
tau.domain := fun _ => True  (universal domain)
tau.states t _ := f t
tau.respects_task: task_rel (f s) (t - s) (f t)
  -- Since t != s implies t - s != 0, left disjunct of task_rel.
  -- If t = s, then t - s = 0 and f t = f s, right disjunct.
```

This works perfectly with the permissive task relation!

### Step 5: Define Omega

Omega should be the set of ALL canonical histories (all bx_le-monotone functions `Int -> BXPoint`) within a given modal equivalence class.

More precisely: fix a modal equivalence class C (the class of our target MCS M0). Define:
```
Omega := { tau : WorldHistory F | forall t, bx_modal_equiv (tau.states t ...) M0_point }
```

Wait, but we also need histories from OTHER modal classes for the box modality to work correctly. Actually, for the box truth lemma, we need:
```
truth_at M Omega tau t (box phi)
  = forall sigma in Omega, truth_at M Omega sigma t phi
  iff box phi in tau(t).formulas
  iff forall v modally-equiv tau(t), phi in v.formulas
```

So Omega must be rich enough that "for all sigma in Omega" captures exactly "for all modally equivalent BXPoints at time t". This means at each time t, the set {sigma(t) | sigma in Omega} should be exactly the modal equivalence class of tau(t).

Actually, since bx_modal_equiv is an equivalence relation and all BXPoints in a chain are bx_le-related but NOT necessarily modally equivalent, we need Omega to contain histories through ALL modally equivalent points.

**Simplest approach**: Let Omega = Set.univ (the set of ALL world histories). Then:
- ShiftClosed is trivial (Set.univ_shift_closed already proved)
- Box quantifies over ALL histories
- For the box truth lemma: `forall sigma in univ, truth_at ... sigma t phi` iff `forall v : BXPoint, phi in v.formulas`

But this is too strong! `box phi in w.formulas` only says phi holds at modally equivalent points, not ALL points.

So we need a more targeted Omega. One option:

**Omega = all histories whose states are in the modal class of M0_point**:
```
Omega := { tau | forall t ht, bx_modal_equiv M0_point (tau.states t ht) }
```

Then box quantifies over histories in Omega, and at each time t, sigma(t) ranges over all BXPoints modally equivalent to M0_point.

ShiftClosed check: if sigma in Omega, is time_shift sigma Delta in Omega? We need that (time_shift sigma Delta).states t ht' is modally equivalent to M0_point. By definition, (time_shift sigma Delta).states t ht' = sigma.states (t + Delta) ht'. Since sigma in Omega, sigma.states (t + Delta) _ is modally equivalent to M0_point. Yes, this works!

### Step 6: Define Valuation

```
valuation w p := Formula.atom p in w.formulas
```

### Step 7: Truth Lemma at Model Level

Need to show: for any canonical history tau and time t:
```
truth_at M Omega tau t phi  <->  phi in (tau.states t ht).formulas
```

But there's a subtlety: atoms require domain membership. If domain = True (universal), then:
```
truth_at M Omega tau t (atom p)
  = exists ht, valuation (tau.states t ht) p
  = exists ht, (atom p) in (tau.states t ht).formulas
```

With domain = True, ht is trivial, so this reduces to `(atom p) in (tau.states t trivial).formulas`. Good.

For G: `truth_at M Omega tau t (G phi) = forall s >= t, truth_at M Omega tau s phi`. By IH, this is `forall s >= t, phi in (tau.states s _).formulas`. By G_iff_mcs, this should be `G(phi) in (tau.states t _).formulas` -- but G_iff_mcs says `G(phi) in w.formulas iff forall v with bx_le w v, phi in v.formulas`. The match requires that the set of BXPoints reachable as `tau.states s _` for `s >= t` is EXACTLY the set of BXPoints v with `bx_le (tau.states t _) v`.

This means we need canonical histories that are **surjective onto the bx_le-upward-closure** of each point. Given w = tau(t), for every v with bx_le w v, there must exist s >= t with tau(s) = v. This is a strong requirement!

**Construction**: For each BXPoint w0 (corresponding to our MCS M), we need a history tau0 such that:
- tau0(0) = w0
- For every v with bx_le w0 v, some s >= 0 has tau0(s) = v
- For every v with bx_le v w0, some s <= 0 has tau0(s) = v
- The function is bx_le-monotone

This requires enumerating all BXPoints in the upward/downward closure. Since there may be uncountably many, we might need to use ordinals or a well-ordering... but D = Int only gives countably many time points!

**Alternative**: Instead of requiring surjectivity onto the entire bx_le-upward-closure via a single history, we can use **Omega** to cover all witnesses. For each needed witness v, include a history that visits v at the appropriate time. Then:

`forall s >= t, truth_at M Omega tau s phi` requires phi to hold at tau(s) for all s >= t. By IH, phi in tau(s).formulas for all s >= t. But G_iff_mcs says G(phi) in tau(t).formulas iff phi in v.formulas for ALL v >= tau(t), not just those visited by tau.

So the truth lemma for G DOES require that the single history tau visits all bx_le-successors. This is impossible with D = Int if there are uncountably many successors.

### Alternative: Use D = arbitrary large type

Since `valid` quantifies over ALL D, we can pick D large enough. But we need to construct the countermodel for a specific D.

Actually, wait. The standard approach in completeness proofs for tense logic is to use a **different model structure**. The standard canonical model for temporal logic uses:
- Worlds = MCS
- R_future = bx_le
- R_modal = bx_modal_equiv

And the truth lemma is proved abstractly at the MCS level (which is ALREADY DONE in TruthLemma.lean as G_iff_mcs, H_iff_mcs, box_iff_mcs, etc.)

The question is: can we EMBED this abstract MCS-level truth into a concrete TaskFrame/TaskModel/WorldHistory/Omega structure?

## 7. The Embedding Gap

The existing TruthLemma.lean already proves the truth lemma at the MCS level:
- `G_iff_mcs`: G(phi) in w.formulas iff forall v >= w, phi in v.formulas
- `H_iff_mcs`: H(phi) in w.formulas iff forall v <= w, phi in v.formulas
- `box_iff_mcs`: box(phi) in w.formulas iff forall v ~ w, phi in v.formulas
- `until_iff_mcs` and `since_iff_mcs`: similar for Until/Since

But the completeness theorem needs: truth_at in a concrete TaskModel. The embedding must bridge from MCS-level truth to TaskModel-level truth.

**The fundamental mismatch**:
- TaskModel truth evaluates G(phi) as "forall s >= t in D, phi holds at tau(s)"
- MCS truth evaluates G(phi) as "forall BXPoint v >= w, phi in v"
- A single history tau : D -> BXPoint cannot visit all BXPoints v >= w unless D is large enough

### Possible Resolution: Bypass the Embedding Entirely

Since the goal is just `False`, and we have:
- `h_valid : valid phi` -- phi true in ALL models
- `h_not_in : phi notin M` -- phi not in some MCS M

We can construct a SIMPLE countermodel (not necessarily the full canonical model) that witnesses phi being false. We just need ANY model where phi evaluates to false at some point.

**Minimal countermodel approach**: Build a model where truth coincides with MCS membership for the SPECIFIC formula phi only, not for all formulas simultaneously. This could be much simpler.

Actually, the cleanest approach may be to construct a model that works for a single MCS M and show phi is false at M.

### Minimal Construction for `False`

We need to apply `h_valid` to get `truth_at M_model Omega tau 0 phi` for our constructed model, and then show this contradicts `h_not_in`.

**Strategy**: Build a model where `truth_at M_model Omega tau 0 phi <-> phi in M.formulas` for our specific MCS M and formula phi.

## 8. Recommended Approach: Full Canonical Model with D = Ordinal/Large Type

For full generality (supporting all formula cases including G/H), the construction needs:

1. **D** = A sufficiently large totally ordered abelian group (or use a trick)
2. **WorldState** = BXPoint (or quotient)
3. **task_rel** = permissive (d != 0 or w = u)
4. **Omega** = modal-class-restricted histories
5. **WorldHistory** = monotone functions from D to BXPoints

The key difficulty is making a single history surject onto all bx_le-successors.

**Trick**: Use `D = BXPoint -> Int` or some other large type? No, D must be an ordered abelian group.

**Better trick**: Observe that for the completeness proof, we don't need truth_at to match MCS membership for ALL formulas and ALL times. We only need it for our specific phi at one specific point. We can use **induction on phi** and build the model to match.

**Simplest viable approach**: The model can use Set.univ as Omega, have universal domain, and use a history that is CONSTANT at our MCS M. Then:
- G(phi) at constant history = phi at all future times = phi at the same point = phi at current
- This degenerates G to identity, which does NOT match the MCS truth lemma.

This won't work for G unless G(phi) <-> phi at M, which isn't generally true.

## 9. The Real Solution: Abstract Completeness

The cleanest approach (used in many formalizations) is to **not embed into TaskFrame at all** for the core completeness argument, but instead:

1. Prove an abstract completeness theorem using the MCS-level truth lemma directly
2. Then separately prove that MCS-level truth can be embedded into TaskFrame truth

For step 1, we already have everything in TruthLemma.lean. The MCS M with phi notin M directly gives us a "countermodel" at the MCS level.

For step 2 (the actual embedding), one approach is:

**Define an "MCS model"** as a separate structure, prove truth = MCS membership there, then show every MCS model gives rise to a TaskFrame model.

But the current codebase defines `valid` in terms of TaskFrame models, so we must either:
(a) Build the TaskFrame embedding, or
(b) Show that MCS truth implies TaskFrame validity (which is essentially the same).

## 10. Effort Estimate and Recommendation

### For Fragment Completeness (no Until/Since)

The sorry requires ~150-300 lines of Lean for the full canonical TaskModel construction:

| Component | Lines | Difficulty |
|-----------|-------|-----------|
| Canonical TaskFrame definition | 30-50 | Medium (task_rel design) |
| Canonical TaskModel (valuation) | 10 | Easy |
| WorldHistory construction | 40-60 | Hard (surjectivity onto bx_le closure) |
| Omega definition + ShiftClosed | 20-30 | Medium |
| Truth lemma bridge (atom, bot, imp) | 20-30 | Easy-Medium |
| Truth lemma bridge (box) | 30-50 | Hard |
| Truth lemma bridge (G, H) | 40-60 | Hard (the surjectivity issue) |
| Final assembly | 10-20 | Easy |

**Hardest sub-obligations**:
1. Constructing histories that are surjective onto bx_le-upward-closures
2. Proving ShiftClosed for the canonical Omega
3. The box case of the truth lemma bridge (bijection between Omega histories and modal equivalence classes)

### Alternative: Simpler Proof Using Set.univ and Custom D

If we define D to be a type INDEXED by BXPoints (e.g., `BXPoint` itself with a suitable group structure, or a free abelian group on some generators), we might achieve surjectivity. But constructing the ordered abelian group structure would be complex.

### Most Practical Path

The most practical path is likely:

1. Use `D = Int`
2. Use the permissive task frame (task_rel w d u := d != 0 \/ w = u)
3. For the G/H truth lemma, use a weaker correspondence that works for the NEGATION case
4. Specifically: to show phi is false at (tau, 0), we don't need the full truth lemma -- we need `NOT (truth_at M Omega tau 0 phi)`, which by the inductive structure of phi only requires the truth lemma for SUBFORMULAS

This inductive approach might dodge the surjectivity problem by building histories tailored to specific subformulas rather than needing a single "universal" history.

**Estimated effort for this approach**: 100-200 lines, with the G/H case being the crux.

## 11. Summary of Key Findings

1. **Goal type**: `False` (contradiction from valid phi and phi notin MCS M)
2. **The MCS truth lemma is already complete** for atom, bot, imp, box, G, H (TruthLemma.lean)
3. **The gap is purely the embedding** from MCS-level truth to TaskFrame-level truth
4. **Fundamental obstacle**: TaskFrame's nullity_identity requires exact equality at duration 0, while bx_le is a preorder (not antisymmetric)
5. **Recommended task_rel**: permissive `d != 0 \/ w = u` (mirrors nat_frame)
6. **Key difficulty**: Making WorldHistory surject onto all bx_le-successors for the G/H truth lemma
7. **For fragment completeness**: The Until/Since cases are not needed, but G/H still require the surjectivity argument
8. **ShiftClosed is needed**: for box soundness in time-shift, but with Set.univ or a modal-class Omega, this is straightforward
9. **Estimated effort**: 150-300 lines for full construction, possibly 100-200 with the inductive/tailored approach
