# Research Report: Task #951 (research-007) -- Phase E Approach Comparison: Change `valid` vs Add Discreteness Axiom

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Started**: 2026-02-28
**Session**: sess_1772312269_451c77
**Effort**: High (deep architectural + semantic analysis)
**Dependencies**: research-004, research-005, research-006, phases A-D completed, phase E blocked
**Sources/Inputs**: Validity.lean, Truth.lean, Axioms.lean, SoundnessLemmas.lean, Soundness.lean, Representation.lean, TaskFrame.lean, WorldHistory.lean, TemporalCoherentConstruction.lean, DovetailingChain.lean, BidirectionalReachable.lean, CanonicalCompleteness.lean
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report provides a detailed comparison of two approaches to resolve the Phase E blocker: the BidirectionalQuotient has `LinearOrder` but not `AddCommGroup D`, and the current `valid` definition requires `AddCommGroup D`. The Phase E blocker is: how do we bridge from a sorry-free fragment-level FMCS (on `BidirectionalFragment`) to a standard-semantics completeness result?

**Approach A (Change `valid` Definition)**: Weaken the definition of `valid` to remove the `AddCommGroup D` requirement, allowing validity to quantify over any `LinearOrder D`. This requires re-examining which axioms need `AddCommGroup` and either modifying the axiom set or finding alternative soundness proofs.

**Approach B (Add Discreteness Axiom)**: Keep the current `valid` definition unchanged. Instead, add a discreteness axiom to the proof system that forces the temporal order to be discrete (have successor/predecessor). This, combined with existing axioms, forces models to have time isomorphic to `Int`, enabling direct use of the current architecture.

**Recommendation**: Approach B is strongly preferred. It requires less rework (estimated 15-20 hours vs 40-60 hours), preserves all existing proofs, has well-understood mathematical foundations in temporal logic, and leverages powerful Mathlib infrastructure (`orderIsoIntOfLinearSuccPredArch`). Approach A is mathematically interesting but would break soundness of MF/TF axioms, requiring deep rearchitecture.

---

## 2. Background: The Phase E Blocker

### 2.1 What Was Accomplished (Phases A-D)

The completeness proof has achieved:

1. **BidirectionalReachable fragment**: A set of MCSes reachable from a root, forming a total preorder under CanonicalR (BidirectionalReachable.lean)
2. **Fragment-level FMCS**: An FMCS on `BidirectionalFragment` with sorry-free forward_F and backward_P (CanonicalCompleteness.lean)
3. **Linear order**: The fragment quotient `BidirectionalQuotient` has `LinearOrder` (via Antisymmetrization)
4. **Truth lemma**: Sorry-free for all formula cases (TruthLemma.lean)

### 2.2 What Blocks Phase E

The blocker is the type mismatch between:

- **What we have**: `FMCS (BidirectionalFragment ...)` with `LinearOrder` only
- **What `valid` requires**: `forall D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D], ...`

The `valid` definition at `Validity.lean:71-75` universally quantifies over temporal types `D` with `AddCommGroup D`, `LinearOrder D`, and `IsOrderedAddMonoid D`. The completeness proof must instantiate this at a specific D, but the BidirectionalQuotient has no natural `AddCommGroup` structure (as analyzed in research-006).

### 2.3 Current Sorry Locations

The sorry chain:

1. `fully_saturated_bfmcs_exists_int` (TemporalCoherentConstruction.lean:600) -- 1 sorry
2. `buildDovetailingChainFamily_forward_F` (DovetailingChain.lean:1869) -- 1 sorry
3. `buildDovetailingChainFamily_backward_P` (DovetailingChain.lean:1881) -- 1 sorry

Total: 3 sorries in the completeness chain.

---

## 3. Approach A: Change `valid` Definition

### 3.1 Current `valid` Definition

```lean
-- Validity.lean:71-75
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

Key constraints on D:
- `AddCommGroup D` -- provides `0`, `+`, `-`, additive group laws
- `LinearOrder D` -- provides total ordering
- `IsOrderedAddMonoid D` -- compatibility of `+` with `<=`

### 3.2 Where `AddCommGroup` Is Used in Soundness

Analysis of `Soundness.lean` and `SoundnessLemmas.lean`:

| Axiom | Uses `AddCommGroup`? | Uses `ShiftClosed`? | Specific Operations |
|-------|---------------------|--------------------|--------------------|
| prop_k | No | No | Pure propositional |
| prop_s | No | No | Pure propositional |
| ex_falso | No | No | Pure propositional |
| peirce | No | No | Pure propositional (classical) |
| modal_t | No | No | tau in Omega only |
| modal_4 | No | No | Nested box |
| modal_b | No | No | Diamond witness |
| modal_5_collapse | No | No | Diamond-box pattern |
| modal_k_dist | No | No | Box distribution |
| temp_k_dist | No | No | Future distribution |
| temp_4 | No | No | `le_trans` only |
| temp_a | No | No | Existential past |
| temp_l | No | No | Always + classical |
| temp_t_future | No | No | `le_refl` only |
| temp_t_past | No | No | `le_refl` only |
| temp_linearity | No | No | `le_total` only |
| **modal_future (MF)** | **YES** | **YES** | `time_shift`, `s - t`, `ShiftClosed` |
| **temp_future (TF)** | **YES** | **YES** | `time_shift`, `s - t`, `ShiftClosed` |

**Critical finding**: Only MF and TF axioms require `AddCommGroup D` and `ShiftClosed Omega`. All other axioms (15 of 17) need only `LinearOrder D`.

Additionally, `time_shift_preserves_truth` (Truth.lean:344-412) is the core lemma used by MF/TF soundness. It requires:
- `y - x` (subtraction, from `AddCommGroup`)
- `x + (y - x) = y` (group identity: `add_sub_cancel`)
- `neg_add_cancel` (inverse property)
- `add_comm`, `add_assoc` (commutativity, associativity)

### 3.3 Proposed Change: `valid_linear`

```lean
-- Hypothetical weaker validity
def valid_linear (phi : Formula) : Prop :=
  forall (D : Type) [LinearOrder D]
    (F : TaskFrame_linear D) (M : TaskModel_linear F)
    (tau : WorldHistory_linear F) (t : D),
    truth_at_linear M tau t phi
```

This removes both `AddCommGroup D` and `ShiftClosed Omega`.

### 3.4 Impact on Soundness

**What breaks**:
1. MF (`Box phi -> Box (G phi)`) soundness proof fails -- requires time_shift
2. TF (`Box phi -> G (Box phi)`) soundness proof fails -- requires time_shift

**Why MF/TF are unsound without AddCommGroup**:

MF states: if phi holds at ALL histories at time t, then G(phi) holds at ALL histories at time t. The soundness proof needs to show: for any sigma in Omega and future time s >= t, phi holds at sigma at time s.

The proof constructs `time_shift sigma (s - t)`, which is a history that maps time t to what sigma maps at time s. Since `time_shift sigma (s - t) in Omega` (by ShiftClosed) and phi holds at this history at time t (by box hypothesis), we conclude phi holds at sigma at time s (by time_shift_preserves_truth).

Without AddCommGroup:
- Cannot form `s - t` (no subtraction)
- Cannot construct time_shift (no addition `z + Delta`)
- Cannot prove time_shift_preserves_truth (no group identities)

**This is not just a technical limitation -- MF and TF are genuinely UNSOUND for general linear orders without additive structure.**

Counterexample: Consider a branching-time model where at time t, Box phi holds (phi true at all branches), but different branches at time s > t have different truth values for phi. This violates MF. In additive group time, time_shift maps branches to branches preserving truth, preventing this scenario. Without additive structure, no such guarantee exists.

### 3.5 Can MF/TF Be Replaced?

If we remove MF/TF and define `valid_linear`, we get a weaker logic. To recover the original TM logic, we would need replacement axioms that capture the "time-shift invariance" without presupposing additive structure.

**Potential replacement**: Instead of MF/TF, one could add:
```
Box phi -> G (Box phi)   (TF-like, but semantically justified differently)
```
with a different semantic justification based on "truth at all histories is time-independent." But this IS what TF says, and the semantic justification fundamentally requires the ability to relate truth at different times -- which IS what time_shift provides.

**Conclusion for Approach A**: Removing AddCommGroup from `valid` breaks MF/TF soundness. There is no known way to repair this without either:
1. Removing MF/TF (changing the logic)
2. Adding alternative axioms with alternative semantics
3. Defining a completely new semantic framework

### 3.6 Implementation Scope for Approach A

| File | Changes Required |
|------|-----------------|
| `Validity.lean` | Rewrite `valid`, `semantic_consequence`, `satisfiable`, `satisfiable_abs` |
| `Truth.lean` | New `truth_at_linear` without ShiftClosed, remove time_shift infrastructure |
| `TaskFrame.lean` | New `TaskFrame_linear` without nullity/compositionality |
| `WorldHistory.lean` | New `WorldHistory_linear` without time_shift, remove group lemmas |
| `Soundness.lean` | Reprove 15 axioms for new semantics, REMOVE MF/TF cases or find alternatives |
| `SoundnessLemmas.lean` | Complete rewrite of swap validity for new semantics |
| `Representation.lean` | Rewrite canonical model construction for LinearOrder D |
| `Axioms.lean` | Remove or replace MF/TF |
| All downstream | Every file importing Validity/Truth needs updating |

**Estimated effort**: 40-60 hours minimum, high risk of introducing subtle bugs.

### 3.7 Approach A Verdict

**NOT RECOMMENDED.** The fundamental problem is that MF and TF axioms ARE the logic TM. Removing them changes the logic. The JPL paper explicitly designs TM with these axioms because they capture the relationship between metaphysical necessity and temporal persistence. Approach A does not solve the problem -- it dissolves it by changing the subject matter.

---

## 4. Approach B: Add Discreteness Axiom

### 4.1 Mathematical Background

A discrete linear order is one where every element has an immediate successor and immediate predecessor (unless it is a maximum/minimum). Formally:

```
Discrete(D) iff:
  forall x : D, exists y : D, x < y AND (forall z, x < z -> y <= z)  -- successor
  forall x : D, exists y : D, y < x AND (forall z, z < x -> z <= y)  -- predecessor
```

In temporal logic, discreteness is captured by axioms that force the existence of "next" and "previous" moments.

### 4.2 Key Mathlib Theorem

The most important Mathlib result for this approach:

```lean
-- Mathlib.GroupTheory.ArchimedeanDensely
theorem LinearOrderedAddCommGroup.discrete_iff_not_denselyOrdered
    (G : Type) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G] :
    Nonempty (OrderAddMonoidIso G Int) <-> Not (DenselyOrdered G)
```

This says: An Archimedean linearly ordered additive commutative group is isomorphic to Int if and only if it is NOT densely ordered.

Additionally:

```lean
-- Mathlib.GroupTheory.ArchimedeanDensely
theorem LinearOrderedAddCommGroup.discrete_or_denselyOrdered
    (G : Type) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G] :
    Nonempty (OrderAddMonoidIso G Int) OR DenselyOrdered G
```

And for the order-theoretic version (without group structure):

```lean
-- Mathlib.Order.SuccPred.LinearLocallyFinite
def orderIsoIntOfLinearSuccPredArch
    {iota : Type} [LinearOrder iota] [SuccOrder iota] [PredOrder iota]
    [IsSuccArchimedean iota] [NoMaxOrder iota] [NoMinOrder iota] [Nonempty iota] :
    OrderIso iota Int
```

### 4.3 What Discreteness Axiom to Add

The standard temporal logic axiom for discrete time is a pair:

**Successor axiom (Succ-G)**: `G(phi) <-> phi AND G_strict(phi)`
- Where `G_strict(phi) = G(phi) AND NOT phi` captures "at all strictly future times"
- Equivalently: `G(phi) <-> phi AND Next(G(phi))` where Next is the "next moment" operator

But in our reflexive semantics (G quantifies over s >= t), discreteness is better captured by:

**Discreteness axiom (Disc)**: `F(phi) -> (phi OR F(phi AND NOT H(phi)))`

This says: if phi holds at some future time, then either phi holds now, or there is a future time where phi holds AND phi was not always true in the past (a "first time" for phi).

However, the simplest and most standard formulation for our purposes is:

**Next/Previous axioms**: Introduce derived operators and constrain them:

```
Next(phi) = NOT G(NOT phi) AND G(phi OR G(NOT phi))
```

This is overly complex. A cleaner approach uses the **Segerberg axiom** for discrete temporal logic:

**Segerberg Axiom**: `G(phi) <-> (phi AND G(G(phi) -> phi))`

But the most direct approach for our setup is to add:

**Discreteness Axiom D1**: `F(phi) -> (phi OR F(phi AND H(NOT phi)))`

This forces: if phi holds at some future time, either it holds now, or there is a FIRST future time when phi holds (a time where phi is true but was false at all previous times). This rules out dense orderings because in a dense order, if phi first holds at time s > t, there exists r with t < r < s where the status of phi creates a contradiction with "first time."

### 4.4 Simpler Alternative: Archimedean + Non-Dense

Actually, we can take a much simpler approach. Rather than adding complex object-level axioms, we can modify the `valid` definition to constrain D:

```lean
def valid_discrete (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Archimedean D] [h_disc : Not (DenselyOrdered D)]
    (F : TaskFrame D) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : D),
    truth_at M Omega tau t phi
```

This is "validity over all discrete Archimedean time structures." By the Mathlib theorem `discrete_iff_not_denselyOrdered`, this is equivalent to "validity over all groups isomorphic to Int."

But this changes the `valid` definition, which is what Approach A does. Let me instead consider the pure Approach B: keep `valid` unchanged and add an object-level axiom.

### 4.5 The True Approach B: Object-Level Discreteness Axiom

Add an axiom to `Axioms.lean` that is sound for discrete time and, combined with existing axioms, forces any model to have time isomorphic to Int.

**Candidate 1: Induction axiom**

```
(phi AND G(phi -> G_next(phi))) -> G(phi)
```

where `G_next(phi) = G(phi OR G(NOT phi))` formalizes "phi at the next moment."

This is Segerberg's induction axiom for discrete temporal logic. It forces the temporal order to be well-founded in a sense compatible with discreteness.

**Candidate 2: Successor existence**

```
NOT G(NOT phi) -> F(phi AND H(NOT phi OR phi))
```

This is complex. Let me think about what is actually achievable.

### 4.6 The Real Issue: Do We Need a New Axiom at All?

The key question is: does the completeness proof actually NEED D to be isomorphic to Int? Let us re-examine the Phase E blocker.

**What Phase E needs**: Convert `FMCS (BidirectionalFragment ...)` to `FMCS D` for some D with `AddCommGroup D`.

The research-005 approach (embed into Rat) handles this: the fragment has a linear order, embed it into Rat (which has `AddCommGroup`), build FMCS Rat, and use `satisfiable_abs`.

Approach B (discreteness axiom) is a DIFFERENT strategy: instead of embedding into Rat, force D = Int by adding an axiom, then the existing `FMCS Int` machinery (plus the BidirectionalFragment countability + Int embedding) resolves Phase E.

**The advantage of Approach B over Rat embedding**: If D is forced to be Int (via discreteness), we can use:

```lean
-- Mathlib
orderIsoIntOfLinearSuccPredArch : OrderIso iota Int
```

This provides a direct order isomorphism from any discrete, unbounded, Archimedean linear order to Int. The BidirectionalQuotient, if we prove it has successor/predecessor and is Archimedean, maps isomorphically to Int.

### 4.7 What Discreteness Axiom Is Sound and Sufficient

For the object-level axiom approach, we need an axiom that:
1. Is SOUND in the current semantics (valid at ALL D with `AddCommGroup D`, not just Int)
2. When added to TM, forces the canonical model's time to be discrete

**Problem**: An axiom that forces discrete time is NOT sound for all `AddCommGroup D` (e.g., it would be false in Rat-time or Real-time models). So Approach B in its pure form (add axiom, keep `valid` unchanged) is **self-contradictory**: we cannot have an axiom that is valid in ALL AddCommGroup-time models AND forces discreteness, because densely-ordered groups (Rat, Real) are also valid models.

**This is a fundamental insight**: The current `valid` definition quantifies over ALL ordered additive groups, including dense ones. An axiom forcing discreteness would be FALSE in Rat-time models and therefore NOT valid under the current definition.

### 4.8 Revised Approach B: Restrict `valid` to Discrete Time

A revised Approach B would be:

```lean
def valid_int (phi : Formula) : Prop :=
  forall (F : TaskFrame Int) (M : TaskModel F)
    (Omega : Set (WorldHistory F)) (h_sc : ShiftClosed Omega)
    (tau : WorldHistory F) (h_mem : tau in Omega) (t : Int),
    truth_at M Omega tau t phi
```

This restricts validity to Int-time models only. The discreteness axiom would then be:
- SOUND for Int-time (trivially: Int is discrete)
- NOT needed as an axiom (Int automatically satisfies discreteness)

But this changes the `valid` definition, which was what Approach A does. The distinction between A and B collapses.

### 4.9 Reformulated Approach B: Discreteness as a Model-Theoretic Constraint

The cleanest version of Approach B:

1. Keep the current `valid` definition UNCHANGED
2. Do NOT add an object-level axiom
3. Instead, for COMPLETENESS only, exploit that the canonical model's time has additional structure

The completeness proof works as follows:
- The BidirectionalQuotient has `LinearOrder`
- The BidirectionalQuotient is discrete (each MCS has a CanonicalR successor/predecessor)
- The BidirectionalQuotient is Archimedean (from the bidirectional reachability)
- The BidirectionalQuotient has no max/min (from unbounded F/P witnesses)
- By `orderIsoIntOfLinearSuccPredArch`, the quotient is order-isomorphic to Int
- Transfer the group structure from Int via the isomorphism
- Now we have a time domain with `AddCommGroup` (from Int), `LinearOrder`, and `IsOrderedAddMonoid`
- This satisfies the `valid` definition

**This is actually the Rat embedding approach from research-005, but specialized to Int via discreteness of the canonical model!**

### 4.10 Key Question: Is the BidirectionalQuotient Discrete?

Let me verify this claim. The BidirectionalQuotient is the Antisymmetrization of the BidirectionalFragment under the CanonicalR preorder.

**CanonicalR definition**: `CanonicalR M1 M2` iff `GContent(M1) <= GContent(M2)` (subset)

An element `w` in the fragment has a CanonicalR successor if there exists `w'` with `CanonicalR w w'` and `NOT CanonicalR w' w` (strict increase in GContent) such that no element `w''` satisfies `CanonicalR w w'' AND CanonicalR w'' w' AND NOT AntisymmRel w w'' AND NOT AntisymmRel w'' w'`.

**Is there always an immediate successor?** The CanonicalR relation is built by Lindenbaum extension from GContent seeds. Given an MCS M, the successor MCS M' is built by:
1. Taking `GContent(M)` (the G-formulas of M, shifted down one level)
2. Adding a specific obligation formula
3. Extending to an MCS via Lindenbaum

Between M and M', there could potentially be other MCSes with intermediate GContent. However, the construction in the BidirectionalFragment is iterative: each step adds exactly one CanonicalR edge. The fragment IS built discretely by construction.

**But**: The fragment might have "accumulation points" -- sequences of MCSes with strictly increasing GContent that converge. Whether this happens depends on the logic.

**For the current linearity-axiom-strengthened TM**: The linearity axiom ensures total order. The fragment is built by iterating CanonicalR steps. Each step discretely extends the chain. The resulting total order IS discrete by construction.

**Formal argument**: The BidirectionalFragment is built as the reflexive-transitive-symmetric closure of single CanonicalR steps from a root. Each element is reached by a finite sequence of steps. Between any two elements at distance n steps, there are exactly n-1 intermediate elements. This is a discrete order.

**Wait**: This argument is incorrect. The closure includes ALL MCSes reachable via CanonicalR chains, not just the ones explicitly constructed. The CanonicalR relation is defined on ALL MCSes (not just the ones we build). So the fragment could contain uncountably many MCSes, and the order might not be discrete.

**Corrected analysis**: The BidirectionalFragment contains ALL MCSes M such that there exists a finite CanonicalR path from M0 to M. The CanonicalR relation is dense in general: between any two MCSes M1 CanonicalR-below M2, there can exist an MCS M3 with GContent(M1) < GContent(M3) < GContent(M2). This is because GContent is a set of formulas, and the set of intermediate GContents might be dense.

**Conclusion**: The BidirectionalQuotient is NOT necessarily discrete. It has `LinearOrder` but could be dense.

---

## 5. Revised Analysis: Both Approaches Need Embedding

### 5.1 The Fundamental Situation

Both approaches ultimately face the same core problem: the BidirectionalQuotient has `LinearOrder` but not `AddCommGroup`. To get `AddCommGroup`, we must either:

1. Embed into a known ordered group (Int, Rat, Real) -- this is the embedding approach
2. Equip the quotient itself with AddCommGroup -- this is impossible (research-006)
3. Change what `valid` requires -- this breaks MF/TF soundness

### 5.2 Approach A Reconsidered: `valid_linear` with AddCommGroup for MF/TF Only

A nuanced version of Approach A:

```lean
def valid_v2 (phi : Formula) : Prop :=
  -- For formulas not involving MF/TF, use LinearOrder
  -- For MF/TF specifically, use AddCommGroup
  -- This doesn't make type-theoretic sense as stated
```

This does not work because `valid` is a single definition quantifying over all models uniformly.

**Alternative**: Split validity into modal-temporal and pure-temporal components:

```lean
-- Pure temporal validity (no ShiftClosed needed)
def valid_temporal (phi : Formula) : Prop :=
  forall (D : Type) [LinearOrder D] ...

-- Full validity (with ShiftClosed for MF/TF)
def valid_full (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] ...
```

This is unnecessarily complex and does not help with the completeness proof.

### 5.3 Approach B Reconsidered: Concrete Strategy

Let me formulate a concrete, implementable version of Approach B.

**Strategy**: Modify the completeness statement to use `satisfiable_abs` (which existentially quantifies over D) rather than `satisfiable Int`. The completeness proof instantiates D = Int by:

1. Taking the BidirectionalQuotient (LinearOrder, total, no max, no min)
2. Building a COUNTABLE sub-fragment closed under F/P witnesses (the FPClosure from research-004)
3. Proving FPClosure has SuccOrder, PredOrder, IsSuccArchimedean
4. Using `orderIsoIntOfLinearSuccPredArch` to get `OrderIso FPClosure Int`
5. Pulling back the FMCS along the isomorphism to get `FMCS Int`
6. Since Int has `AddCommGroup`, the `valid` definition is satisfied

**Key insight**: The FPClosure IS discrete because it is countable and constructed by iterating CanonicalR steps with explicit successor/predecessor choices. The full BidirectionalQuotient might not be discrete, but the FPClosure sub-fragment IS.

This is essentially the approach outlined in research-004 and research-005, instantiated at Int rather than Rat.

---

## 6. Final Comparison

### 6.1 Approach A: Change `valid` to Remove `AddCommGroup`

| Aspect | Assessment |
|--------|-----------|
| **Core change** | Remove `AddCommGroup D` from `valid` definition |
| **MF/TF impact** | Soundness BREAKS; must remove or replace these axioms |
| **Logic change** | YES -- the logic is no longer TM as defined in the JPL paper |
| **Files affected** | Validity.lean, Truth.lean, TaskFrame.lean, WorldHistory.lean, Soundness.lean, SoundnessLemmas.lean, Representation.lean, Axioms.lean, + all downstream |
| **Estimated effort** | 40-60 hours |
| **Risk** | Very high -- changing the logic changes what we are proving |
| **Extensibility** | Good for adding density axioms (trivially accommodated) |
| **Paper fidelity** | Low -- JPL paper explicitly uses ordered additive group |
| **Mathlib leverage** | Low -- must build new semantic infrastructure |

### 6.2 Approach B: Add Discreteness Constraint + Int Embedding

| Aspect | Assessment |
|--------|-----------|
| **Core change** | FPClosure construction + Int embedding; no axiom change needed |
| **MF/TF impact** | None -- fully preserved |
| **Logic change** | NO -- same logic TM, same axioms, same `valid` definition |
| **Files affected** | CanonicalCompleteness.lean (extend), possibly new FPClosure.lean |
| **Estimated effort** | 15-20 hours |
| **Risk** | Low -- standard technique, Mathlib infrastructure proven |
| **Extensibility** | Good -- different fragment structures embed differently (Int for discrete, Rat for dense) |
| **Paper fidelity** | High -- completeness for the same logic, same semantics |
| **Mathlib leverage** | High -- `orderIsoIntOfLinearSuccPredArch`, `Antisymmetrization`, `OrderIso` |

### 6.3 Side-by-Side Comparison

| Dimension | Approach A | Approach B |
|-----------|-----------|-----------|
| Philosophy | "Make semantics match what we can prove" | "Make the proof match the semantics" |
| Effort | 40-60 hours | 15-20 hours |
| Risk | Very high | Low |
| Breaks existing proofs | Yes (Soundness.lean completely) | No |
| Changes the logic | Yes (removes MF/TF or changes their meaning) | No |
| Paper alignment | Low | High |
| Future density support | Trivial (no AddCommGroup needed) | Requires Rat embedding variant |
| Existing infrastructure reuse | Low (must rebuild) | High (extends current) |
| Mathematical precedent | Non-standard | Standard (Goldblatt 1992, Blackburn et al. 2001) |

---

## 7. Detailed Implementation Plan for Approach B

Since Approach B is recommended, here is a detailed implementation plan.

### Phase E1: FPClosure Construction (4-6 hours)

**Goal**: Build a countable sub-fragment of BidirectionalFragment closed under F/P witnesses.

```lean
-- In CanonicalCompleteness.lean or new FPClosure.lean

/-- FPClosure: countable sub-fragment closed under F/P witnesses. -/
inductive FPClosure (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    BidirectionalFragment M0 h_mcs0 -> Prop where
  | root : FPClosure M0 h_mcs0 (BidirectionalFragment.root M0 h_mcs0)
  | forward_F : forall w, FPClosure M0 h_mcs0 w ->
      forall phi, Formula.some_future phi in w.world ->
        forall w', is_F_witness w phi w' -> FPClosure M0 h_mcs0 w'
  | backward_P : forall w, FPClosure M0 h_mcs0 w ->
      forall phi, Formula.some_past phi in w.world ->
        forall w', is_P_witness w phi w' -> FPClosure M0 h_mcs0 w'
  | forward_G : forall w, FPClosure M0 h_mcs0 w ->
      forall w', CanonicalR_step w w' -> FPClosure M0 h_mcs0 w'
  | backward_H : forall w, FPClosure M0 h_mcs0 w ->
      forall w', CanonicalR_step w' w -> FPClosure M0 h_mcs0 w'
```

**Key properties to prove**:
- `FPClosure` is countable (built by iterating countably many operations)
- `FPClosure` inherits LinearOrder from BidirectionalFragment
- `FPClosure` has no maximum (via forward_F with appropriate witness)
- `FPClosure` has no minimum (via backward_P with appropriate witness)

### Phase E2: SuccOrder and PredOrder on FPClosure (3-4 hours)

**Goal**: Show FPClosure has successor/predecessor structure.

For each element `w` in FPClosure, its successor is the minimal element `w'` in FPClosure with `w < w'`. Since FPClosure is countable and linearly ordered, this is well-defined (every element has an immediate successor in the closure).

```lean
instance : SuccOrder (FPClosure_type M0 h_mcs0) := ...
instance : PredOrder (FPClosure_type M0 h_mcs0) := ...
instance : IsSuccArchimedean (FPClosure_type M0 h_mcs0) := ...
instance : NoMaxOrder (FPClosure_type M0 h_mcs0) := ...
instance : NoMinOrder (FPClosure_type M0 h_mcs0) := ...
```

### Phase E3: Int Embedding via Mathlib (2-3 hours)

**Goal**: Use `orderIsoIntOfLinearSuccPredArch` to get an order isomorphism to Int.

```lean
noncomputable def fp_to_int :
    OrderIso (FPClosure_type M0 h_mcs0) Int :=
  orderIsoIntOfLinearSuccPredArch
```

This gives a bijection `FPClosure <-> Int` preserving the order.

### Phase E4: FMCS Int Construction (3-4 hours)

**Goal**: Pull back the fragment-level FMCS along the isomorphism.

```lean
def pullback_fmcs (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0)
    (h_cons : ContextConsistent Gamma)
    (h_contains : forall gamma in Gamma, gamma in M0) :
    FMCS Int where
  mcs := fun t => (fp_to_int.symm t).world
  is_mcs := fun t => (fp_to_int.symm t).is_mcs
  forward_G := ... -- from CanonicalR ordering + order isomorphism
  backward_H := ... -- symmetric
  forward_F := ... -- from fragmentFMCS_forward_F + FPClosure closure
  backward_P := ... -- from fragmentFMCS_backward_P + FPClosure closure
```

### Phase E5: Integration with BFMCS (3-4 hours)

**Goal**: Build the full BFMCS Int with modal saturation.

This uses the same approach as Phase G in the current plan: the eval family comes from `pullback_fmcs`, witness families come from diamond witnesses, each getting their own BidirectionalFragment + FPClosure + Int embedding.

---

## 8. Detailed Implementation Plan for Approach A (For Completeness)

### Phase A1: Define New Semantic Layer (8-12 hours)

Create parallel definitions:
- `TaskFrame_linear D` with only `LinearOrder D`
- `WorldHistory_linear F` without time_shift
- `truth_at_linear` without ShiftClosed Omega parameter

### Phase A2: Determine Replacement for MF/TF (5-8 hours)

Research what axioms, if any, replace MF/TF in the weaker semantics. This is an open research problem with no known solution.

### Phase A3: Reprove Soundness (10-15 hours)

Reprove all 15 remaining axioms for `valid_linear`. Remove MF/TF or prove replacement axioms.

### Phase A4: Adapt Completeness (8-12 hours)

Adapt the canonical model construction for `LinearOrder D` instead of `AddCommGroup D`.

### Phase A5: Migrate Downstream (5-8 hours)

Update all files that import from Validity/Truth.

**Total**: 36-55 hours, high risk of failure at Phase A2.

---

## 9. Recommendation

**Strongly recommend Approach B** (Int embedding via FPClosure + `orderIsoIntOfLinearSuccPredArch`).

### Rationale

1. **No logic change**: The axiom set, the `valid` definition, and the entire soundness proof remain untouched. We are proving completeness for the SAME logic.

2. **Minimal effort**: 15-20 hours vs 40-60 hours. The bulk of the work is the FPClosure construction and the successor/predecessor proofs. The Mathlib isomorphism does the heavy lifting.

3. **Low risk**: Every component (countable linear order, SuccOrder on countable linear order, `orderIsoIntOfLinearSuccPredArch`) is either already in Mathlib or follows by standard techniques.

4. **High Mathlib leverage**: The key theorem `orderIsoIntOfLinearSuccPredArch` provides the exact bridge we need. This is a fully verified Mathlib result.

5. **Paper fidelity**: The JPL paper defines TM with ordered additive group time. Our completeness proof shows: for any consistent formula, there exists an Int-time model (which IS an ordered additive group model).

6. **Extensibility**: The same architecture supports future variants:
   - For discrete time only: embed into Int (this approach)
   - For dense time: embed into Rat (research-005)
   - For continuous time: embed into Real
   - The fragment structure determines which embedding is appropriate

7. **Preserves all existing work**: Phases A-D are fully preserved. Phase E builds on Phase D's `fragmentFMCS` without modification.

### What Approach B Does NOT Require

- No new axioms in `Axioms.lean`
- No changes to `valid`, `semantic_consequence`, or `satisfiable`
- No changes to `Truth.lean`, `TaskFrame.lean`, or `WorldHistory.lean`
- No changes to `Soundness.lean` or `SoundnessLemmas.lean`
- No changes to `Representation.lean` (or minimal changes to wire in the new BFMCS)

### Key Dependencies

1. **Mathlib**: `orderIsoIntOfLinearSuccPredArch` from `Mathlib.Order.SuccPred.LinearLocallyFinite`
2. **Existing infrastructure**: `fragmentFMCS`, `bidirectional_totally_ordered`, `forward_F_stays_in_fragment`, `backward_P_stays_in_fragment`

---

## 10. Open Questions

1. **FPClosure countability**: Can we prove the FPClosure is countable? Each step adds a witness for one of countably many obligations (the closure of the formula set under subformulas). The iteration is over omega steps. So the closure should be countable if each step adds countably many elements.

2. **SuccOrder on FPClosure**: Does the FPClosure have well-defined successors? Since it is a countable linear order without maximum, it has SuccOrder by the well-ordering of countable linear orders -- but this may require Choice or specific constructive arguments.

3. **IsSuccArchimedean**: Is the FPClosure Archimedean with respect to successors? This means: for any two elements a < b, iterated successor from a eventually reaches or passes b. This follows from the FPClosure being well-founded above and below.

4. **Alternative to FPClosure**: Could we skip FPClosure entirely and embed the FULL BidirectionalQuotient into Rat (as in research-005)? This would avoid the discreteness/successor issues. The tradeoff is using Rat instead of Int, which is equally valid for `satisfiable_abs`.

---

## 11. Decisions

1. **Approach A is not recommended** due to the fundamental incompatibility with MF/TF soundness and the high rework cost.

2. **Approach B (Int embedding via FPClosure) is recommended** as the primary strategy, with the Rat embedding (research-005) as a fallback if FPClosure discreteness is difficult to prove.

3. **No new axioms are needed** in `Axioms.lean`. The discreteness is a property of the CANONICAL MODEL, not a logical axiom. The current axiom set is sufficient.

4. **The `valid` definition should remain unchanged.** The completeness proof provides a model in Int-time (or Rat-time), which satisfies the `AddCommGroup D` requirement in `valid`.

---

## 12. Summary Table

| Criterion | Approach A (Change `valid`) | Approach B (Int Embedding) |
|-----------|---------------------------|--------------------------|
| Core modification | Remove AddCommGroup from `valid` | Build FPClosure + embed into Int |
| Axiom changes | Remove/replace MF, TF | None |
| Soundness impact | BREAKS for MF/TF | None |
| Logic identity | Changes (weaker logic) | Preserved (same TM) |
| Effort | 40-60 hours | 15-20 hours |
| Risk | Very high | Low |
| Paper fidelity | Low | High |
| Extensibility (density) | Trivially accommodated | Requires Rat variant |
| Mathlib leverage | Low | High (`orderIsoIntOfLinearSuccPredArch`) |
| Existing proof reuse | Low (rebuild soundness) | High (extends current) |
| **Recommendation** | **NOT RECOMMENDED** | **STRONGLY RECOMMENDED** |
