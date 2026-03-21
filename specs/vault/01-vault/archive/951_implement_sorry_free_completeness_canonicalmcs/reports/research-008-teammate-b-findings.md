# Research Report: Task #951 (research-008-teammate-b) -- Histories as MCS-Preserving Functions and Convexity

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Focus**: History functions, convexity, and the bridge from MCS-based canonical models to semantic models
**Started**: 2026-02-28
**Session**: agent_system-1768239349
**Effort**: Medium-High (structural analysis + Mathlib verification)
**Dependencies**: research-004 through research-007, phases A-D completed, phase E blocked
**Sources/Inputs**: WorldHistory.lean, Truth.lean, TaskFrame.lean, TaskModel.lean, FMCSDef.lean, BFMCS.lean, CanonicalCompleteness.lean, BidirectionalReachable.lean, CanonicalFMCS.lean, CanonicalFrame.lean, TemporalCoherentConstruction.lean, Validity.lean
**Artifacts**: This report

---

## 1. Executive Summary

This report investigates whether histories can be formally defined as functions from convex time intervals to MCSes that preserve the task relation, and how this definition relates to the completeness proof bridge.

### Key Findings

1. **WorldHistory already implements the convex-domain pattern**: The existing `WorldHistory` structure (WorldHistory.lean:69-97) has an explicit `convex` field matching the JPL paper's definition exactly: `forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y`.

2. **Mathlib's `Set.OrdConnected` is the formal convexity notion**: The property in WorldHistory's `convex` field is precisely `Set.OrdConnected` from `Mathlib.Order.Interval.Set.Defs`. Specifically, `Set.OrdConnected s` means `forall x in s, forall y in s, Set.Icc x y subset s`, which is equivalent to the WorldHistory convexity condition.

3. **`Set.OrdConnected.vadd` confirms translation invariance**: Mathlib's `Set.OrdConnected.vadd` (in `Mathlib.Algebra.Order.UpperLower`) proves that OrdConnected sets are preserved under additive translation in `[AddCommGroup D] [Preorder D] [IsOrderedAddMonoid D]`. This is exactly the property used in `time_shift` (WorldHistory.lean:236-258) to prove the shifted domain is convex.

4. **The real Phase E challenge is NOT about histories or convexity**: The Phase E blocker is that the BidirectionalFragment has `LinearOrder` but lacks `AddCommGroup D`. The `valid` definition (Validity.lean) requires `AddCommGroup D`. Histories and convexity are already well-formalized; the gap is in bridging the algebraic structure.

5. **Two proven paths exist**: research-007 identifies Approach A (change `valid` to remove AddCommGroup requirement) and Approach B (add discreteness axiom forcing Int-like time). Approach B is recommended.

---

## 2. Current WorldHistory Structure Analysis

### 2.1 WorldHistory Definition (WorldHistory.lean:69-97)

```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (F : TaskFrame D) where
  domain : D -> Prop
  convex : forall (x z : D), domain x -> domain z ->
           forall (y : D), x <= y -> y <= z -> domain y
  states : (t : D) -> domain t -> F.WorldState
  respects_task : forall (s t : D) (hs : domain s) (ht : domain t),
    s <= t -> F.task_rel (states s hs) (t - s) (states t ht)
```

**Key observations**:

- The `domain` predicate represents the convex time interval X subset D
- The `convex` field enforces the JPL paper's convexity requirement explicitly
- The `states` function is dependent: it takes `(t : D)` and a proof `domain t`
- The `respects_task` field captures the task relation preservation: tau(y) in tau(x) * (y - x)

### 2.2 Time-Shift Construction (WorldHistory.lean:236-258)

The `time_shift` construction is already implemented and proven correct:

```lean
def time_shift (sigma : WorldHistory F) (Delta : D) : WorldHistory F where
  domain := fun z => sigma.domain (z + Delta)
  convex := -- proven using sigma.convex and add_le_add_right
  states := fun z hz => sigma.states (z + Delta) hz
  respects_task := -- proven using add_sub_add_right_eq_sub
```

The key properties proven:
- `time_shift_domain_iff`: Domain membership transfers (WorldHistory.lean:264)
- `time_shift_inverse_domain`: Double shift cancels on domain (WorldHistory.lean:271)
- `time_shift_time_shift_states`: Double shift cancels on states (WorldHistory.lean:304)
- `time_shift_preserves_truth`: Full truth preservation theorem (Truth.lean:344-412)

### 2.3 ShiftClosed Property (Truth.lean:231-232)

```lean
def ShiftClosed (Omega : Set (WorldHistory F)) : Prop :=
  forall sigma in Omega, forall (Delta : D), WorldHistory.time_shift sigma Delta in Omega
```

This is required for `time_shift_preserves_truth` in the box case, ensuring shifted histories remain in the admissible set Omega.

---

## 3. Convexity in Mathlib: OrdConnected

### 3.1 Set.OrdConnected Definition

From `Mathlib.Order.Interval.Set.Defs`:

```lean
structure Set.OrdConnected (s : Set alpha) : Prop where
  out' : forall x in s, forall y in s, Set.Icc x y subset s
```

This means: for any x, y in s, every z with x <= z <= z is in s.

**Verification**: This is exactly the WorldHistory convexity condition. The WorldHistory field `convex : forall x z, domain x -> domain z -> forall y, x <= y -> y <= z -> domain y` is logically equivalent to `Set.OrdConnected {t | domain t}`.

### 3.2 Relevant Mathlib Lemmas (Verified via lean_local_search and lean_loogle)

| Lemma | Type | Module |
|-------|------|--------|
| `Set.OrdConnected.vadd` | `(hs : s.OrdConnected) : (a +v s).OrdConnected` | `Mathlib.Algebra.Order.UpperLower` |
| `Set.ordConnected_univ` | `Set.univ.OrdConnected` | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.ordConnected_Ici` | `(Set.Ici a).OrdConnected` | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.ordConnected_Iic` | `(Set.Iic a).OrdConnected` | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.ordConnected_Iio` | `(Set.Iio a).OrdConnected` | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.ordConnected_Ioi` | `(Set.Ioi a).OrdConnected` | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.OrdConnected.smul` | `(hs : s.OrdConnected) : (a smul s).OrdConnected` | `Mathlib.Algebra.Order.UpperLower` |

**Key lemma**: `Set.OrdConnected.vadd` proves that OrdConnected is preserved under additive translation. The WorldHistory `time_shift` proves this manually (WorldHistory.lean:239-245); it could be refactored to use this Mathlib lemma, though the current proof is direct and clean.

### 3.3 Relationship to Analysis-Style Convexity

Mathlib distinguishes:
- **`Set.OrdConnected`** (order-theoretic): No gaps in intervals. Used for ordered sets.
- **`Convex kappa s`** (analysis-style): Closed under convex combinations. Used for vector spaces.
- **`Set.OrdConnected.convex`**: Proves OrdConnected implies Convex for linearly ordered fields.

For the temporal logic setting, **`Set.OrdConnected` is the correct notion**, since we work with ordered additive groups (not vector spaces).

---

## 4. Histories as MCS-Preserving Functions: Formal Analysis

### 4.1 What the User Proposes

Define histories as functions `sigma : I -> MCS` where:
- `I` is a convex time interval (OrdConnected subset of D)
- The task relation between MCSes is preserved over durations

### 4.2 How This Maps to Existing Code

The existing code already implements this pattern at TWO levels:

**Level 1: Semantic WorldHistory (WorldHistory.lean)**

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D -> Prop                              -- The interval I
  convex : ...                                     -- I is OrdConnected
  states : (t : D) -> domain t -> F.WorldState     -- sigma : I -> W
  respects_task : ...                              -- task_rel preservation
```

This is the semantic-level history used in truth evaluation.

**Level 2: FMCS (FMCSDef.lean)**

```lean
structure FMCS where
  mcs : D -> Set Formula                           -- sigma : D -> MCS
  is_mcs : forall t, SetMaximalConsistent (mcs t)  -- Each value is an MCS
  forward_G : ...                                  -- Temporal coherence (forward)
  backward_H : ...                                 -- Temporal coherence (backward)
```

This is the proof-theoretic analogue. Note that FMCS uses the FULL domain D (not a subdomain), and coherence conditions replace the task relation.

### 4.3 The Bridge Problem

The completeness proof must construct a semantic `WorldHistory F` from an FMCS. This requires:

1. **WorldState type**: Each MCS becomes a world state. Defined as `CanonicalWorldState` in Completeness.lean.
2. **Task relation**: Defined via MCS content (GContent/HContent subset relations)
3. **Domain**: Must be a convex subset of an `AddCommGroup D`
4. **Truth correspondence**: The Truth Lemma (`bmcs_truth_lemma` in TruthLemma.lean)

The FMCS -> WorldHistory bridge is where Phase E is stuck:
- The `BidirectionalFragment` provides a linearly ordered preorder (not an AddCommGroup)
- WorldHistory requires `AddCommGroup D`
- The convexity of the domain is trivial (use full D or appropriate interval) once D is fixed

### 4.4 Task Relation Preservation: What It Means for MCSes

The `respects_task` condition states:
```
forall s t in domain, s <= t -> F.task_rel (sigma(s)) (t - s) (sigma(t))
```

In the canonical model, the task frame's `task_rel` is defined by MCS content:
- `task_rel M d M'` iff the GContent relationships hold between M and M' for duration d

Specifically:
- `CanonicalR M M'` means `GContent(M) subset M'` (all G-formulas of M hold at M')
- This is the "duration-free" version; in the semantic model, the duration `(t - s)` enters through the temporal indexing

The FMCS coherence conditions (`forward_G`, `backward_H`) ARE the MCS-level analogue of `respects_task`. The FMCS says: if G(phi) is at time t, then phi is at all future times. This is equivalent to saying the MCS-assignment function preserves the temporal relations.

---

## 5. The Real Phase E Challenge: AddCommGroup vs LinearOrder

### 5.1 Summary of the Blocker

The completeness statement in `Validity.lean` is:

```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ...
    truth_at M Omega tau t phi
```

Completeness is: if `derivable phi`, then `valid phi`.

The contrapositive: if `not (valid phi)`, then `not (derivable phi)`.

To prove `valid phi`, we must show truth at ALL temporal types D with AddCommGroup.

For completeness, we need: if `phi` is not derivable, construct a model (with AddCommGroup D) where `phi` fails. The BidirectionalFragment provides such a model, but its time type lacks AddCommGroup.

### 5.2 How Histories and Convexity Relate

Once the AddCommGroup gap is resolved (by either approach from research-007), the history construction is straightforward:

1. **Use D = Int** (or isomorphic discrete ordered group)
2. **Domain = Set.univ** (convex trivially: `Set.ordConnected_univ`)
3. **States assignment**: Each integer time maps to the MCS at that position in the chain
4. **Task relation**: Defined by GContent subset relations, satisfying nullity (reflexivity via T-axiom) and compositionality (transitivity via Temporal-4)
5. **ShiftClosed**: The set of all such histories is shift-closed because shifting preserves GContent relationships

The convexity of domains is NOT the bottleneck. Using full D as the domain (all histories defined everywhere) makes convexity trivial.

---

## 6. ShiftClosed and Modal Coherence

### 6.1 ShiftClosed in the Canonical Model

For the canonical model to satisfy the box axioms via `time_shift_preserves_truth`, the set Omega of admissible histories must be shift-closed.

In the BFMCS approach:
- Each FMCS family corresponds to one WorldHistory
- The bundle of families corresponds to Omega
- ShiftClosed(Omega) must hold

Currently, the BFMCS truth definition (BFMCSTruth.lean) avoids explicit WorldHistory by defining truth directly on FMCS families. The box case uses `modal_forward`/`modal_backward` instead of `ShiftClosed`.

For the semantic bridge:
- Convert each FMCS family to a WorldHistory
- The shifted WorldHistory `time_shift(sigma, Delta)` corresponds to "viewing sigma from a different reference time"
- The FMCS coherence conditions ensure that shifting the underlying MCS chain produces another valid FMCS in the bundle

### 6.2 Connection to ShiftClosed

If we define:
- `sigma_fam : WorldHistory F` from `fam : FMCS Int` as `sigma_fam.domain = Set.univ`, `sigma_fam.states t _ = canonical_world_state (fam.mcs t)`
- `Omega = {sigma_fam | fam in B.families}` for BFMCS B

Then `ShiftClosed Omega` requires: for any family `fam in B.families` and any shift `Delta : Int`, there exists `fam' in B.families` such that `fam'.mcs t = fam.mcs (t + Delta)` for all t.

This is a NON-TRIVIAL requirement. It means the bundle must be closed under time-translation of families. This is NOT the same as `modal_forward`/`modal_backward`.

**Critical observation**: The BFMCS truth definition sidesteps this by NOT using WorldHistory/ShiftClosed at all. It defines truth directly in terms of MCS membership and family quantification. The truth lemma is proven at the BFMCS level, not the WorldHistory level.

**Therefore**: For the completeness proof, we do NOT need to construct explicit WorldHistory objects or verify ShiftClosed. The BFMCS truth lemma provides completeness at the MCS level. The only remaining gap is bridging from BFMCS-truth to semantic-truth (or redefining validity in terms of BFMCS-truth).

---

## 7. Can Convexity Be Relaxed?

### 7.1 Why Convexity Exists

Convexity is required for the time_shift construction to work:
- If domain is not convex, time_shift may produce histories with non-convex domains
- Actually, time_shift ALWAYS preserves convexity (proven in WorldHistory.lean:238-245)

But convexity is mainly needed for:
1. Ensuring temporal operators can "see" intermediate times
2. The paper's definition requires it explicitly

### 7.2 When Convexity Can Be Relaxed

For the completeness proof:
- Using `domain = Set.univ` (the full time line) makes convexity trivially satisfied
- No history in the canonical model needs a restricted domain
- Convexity relaxation is irrelevant since we use full-domain histories

For more sophisticated models (finite games, bounded time):
- Convexity prevents "time gaps" which would make temporal reasoning unsound
- Relaxing it would require modifying the truth definition

**Verdict**: Convexity CAN be trivially relaxed for the completeness proof by using full-domain histories, but it SHOULD NOT be removed from the WorldHistory definition since it matches the paper and is needed for general semantic models.

---

## 8. Recommended Approach for Phase E

Based on this analysis, the recommended approach combines findings from research-007 with the history analysis here:

### 8.1 Short-Term Path (Approach B from research-007)

1. Add discreteness axiom to the proof system
2. Use D = Int for completeness proof
3. Histories have domain = Set.univ (convexity trivial)
4. Each FMCS Int family becomes a WorldHistory with full domain
5. Task relation defined by GContent subset
6. ShiftClosed is handled by BFMCS modal coherence (no explicit WorldHistory needed)

### 8.2 Architecture

The completeness proof does NOT need to explicitly construct WorldHistory objects:

```
Consistent formula phi
  -> Lindenbaum: extend to MCS M0
  -> BidirectionalFragment: sorry-free FMCS at fragment level
  -> Chain embedding: FMCS Int (with forward_F, backward_P)
  -> BFMCS Int: modal saturation via witness families
  -> Truth Lemma: phi in M0 <-> bmcs_truth phi (sorry-free)
  -> Completeness: phi not derivable -> phi not valid
```

The BFMCS truth lemma (TruthLemma.lean) replaces the need for WorldHistory-based truth. The remaining sorry is `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:600), which combines temporal coherence with modal saturation.

### 8.3 What About the User's Proposal?

The user proposes "histories as functions from convex time intervals to MCSes preserving task relations." This is:

1. **Already implemented** as `WorldHistory` (semantic level) and `FMCS` (proof-theoretic level)
2. **Not the bottleneck** -- the bottleneck is AddCommGroup vs LinearOrder and temporal+modal saturation combination
3. **Correct in spirit** -- the FMCS IS a function from time to MCS with coherence (= task relation preservation)
4. **Convexity is trivially satisfied** for the completeness proof since full-domain histories are used

---

## 9. Evidence: Verified Lemma Names

All lemma names below were verified via `lean_local_search` or `lean_loogle`:

| Name | Verified | Location |
|------|----------|----------|
| `Set.OrdConnected` | Yes | `Mathlib.Order.Interval.Set.Defs` |
| `Set.OrdConnected.vadd` | Yes (via lean_loogle) | `Mathlib.Algebra.Order.UpperLower` |
| `Set.ordConnected_univ` | Yes | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.ordConnected_Ici` | Yes | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.ordConnected_Iic` | Yes | `Mathlib.Order.Interval.Set.OrdConnected` |
| `Set.OrdConnected.smul` | Yes | `Mathlib.Algebra.Order.UpperLower` |
| `ShiftClosed` | Yes (project) | `Theories/Bimodal/Semantics/Truth.lean` |
| `WorldHistory` | Yes (project) | `Theories/Bimodal/Semantics/WorldHistory.lean` |
| `WorldHistory.time_shift` | Yes (project) | `Theories/Bimodal/Semantics/WorldHistory.lean` |
| `time_shift_preserves_truth` | Yes (project) | `Theories/Bimodal/Semantics/Truth.lean` |
| `FMCS` | Yes (project) | `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` |
| `BFMCS` | Yes (project) | `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` |
| `CanonicalR` | Yes (project) | `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` |
| `BidirectionalFragment` | Yes (project) | `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` |
| `fragmentFMCS` | Yes (project) | `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` |

---

## 10. Confidence Level

**High confidence** on the structural analysis:
- The relationship between WorldHistory, FMCS, OrdConnected, and ShiftClosed is clear
- The Phase E blocker is well-characterized (AddCommGroup gap, not convexity)
- The BFMCS approach correctly sidesteps WorldHistory for the truth lemma

**Medium confidence** on the recommended approach:
- Approach B (discreteness axiom) has clear mathematical foundations
- The combination of temporal+modal saturation (the remaining sorry) is a genuine challenge
- The BidirectionalFragment approach resolves forward_F/backward_P but not the Int embedding

**Low relevance** of convexity to the blocker:
- Convexity is already correctly handled
- It is NOT the bottleneck for completeness
- Full-domain histories make convexity trivial

---

## 11. Summary for Team Lead

**Direct answers to research questions**:

1. **What is the current WorldHistory structure?** A dependent structure with `domain : D -> Prop`, `convex`, `states`, and `respects_task`. Already matches the JPL paper's convex-domain history definition (WorldHistory.lean:69-97).

2. **How does ShiftClosed relate to history functions?** ShiftClosed ensures the admissible history set Omega is closed under time-translation. The BFMCS approach bypasses this entirely by defining truth directly on MCS membership.

3. **What mathematical properties make an interval convex?** `Set.OrdConnected`: for any x, y in the interval, every z between them is also in the interval. Mathlib provides this in `Mathlib.Order.Interval.Set.Defs`.

4. **Can histories be defined as sigma : I -> MCS where I is convex?** Yes, and this is ALREADY the FMCS structure. The FMCS uses full D rather than a subdomain, making convexity trivial.

5. **What does "preserving the task relation over duration" mean formally?** `forall s t, s <= t -> task_rel (sigma(s)) (t - s) (sigma(t))`. In MCS terms, this is captured by the FMCS coherence conditions forward_G and backward_H.

6. **Does Mathlib have convex interval types?** Yes: `Set.OrdConnected` is the correct notion, with `Set.ordConnected_univ`, `Set.ordConnected_Ici`, etc. Translation invariance is provided by `Set.OrdConnected.vadd`.

**Bottom line**: Histories and convexity are well-formalized and NOT the Phase E bottleneck. The bottleneck is bridging from BidirectionalFragment (LinearOrder only) to the semantic model (requires AddCommGroup D), and combining temporal+modal saturation in the BFMCS construction.
