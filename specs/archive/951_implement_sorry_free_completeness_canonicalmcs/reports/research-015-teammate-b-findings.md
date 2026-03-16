# Teammate B Findings: Alternative Canonical Frame Constructions

**Task**: 951 - Implement sorry-free completeness via CanonicalMCS domain
**Date**: 2026-03-01
**Focus**: Alternative frame constructions that avoid imposing external algebraic structure
**Dependencies**: research-010 (Successor Algebra), research-011 (frame from syntax), research-012 (two-layer architecture)

---

## 1. Key Findings

### 1.1 The Current Structure Requirements Are Tightly Coupled to the Semantic Layer

The codebase has a clear two-layer architecture with fundamentally different requirements:

| Layer | Constraint on D | Where Defined |
|-------|----------------|---------------|
| FMCS / BFMCS / TruthLemma | `Preorder D` only | FMCSDef.lean |
| TaskFrame / WorldHistory / truth_at / valid | `AddCommGroup D` + `LinearOrder D` + `IsOrderedAddMonoid D` | TaskFrame.lean, Validity.lean |

The `AddCommGroup` requirement enters through THREE distinct pathways, each serving a specific semantic purpose:

**Pathway 1 -- TaskFrame definition (algebraic)**:
- `nullity : forall w, task_rel w 0 w` -- needs `Zero D` from `AddCommGroup`
- `compositionality : forall w u v x y, task_rel w x u -> task_rel u y v -> task_rel w (x + y) v` -- needs `Add D`

**Pathway 2 -- WorldHistory definition (geometric)**:
- `respects_task : forall (s t : D), ... s <= t -> F.task_rel (states s hs) (t - s) (states t ht)` -- needs `Sub D` (i.e., `AddGroup`)
- `time_shift` construction: `domain := fun z => sigma.domain (z + Delta)` -- needs `Add D`
- `convex` with shifts: `x + Delta <= y + Delta <= z + Delta` -- needs `IsOrderedAddMonoid D`

**Pathway 3 -- Soundness proofs (MF/TF axioms)**:
- `time_shift_preserves_truth` uses algebraic identities: `add_sub`, `add_sub_cancel_left`, `sub_sub_cancel`, `neg_sub`, `add_comm`
- The box case explicitly requires `ShiftClosed Omega` and constructs `time_shift sigma (y - x)`
- The past/future cases compute shifted time indices: `s - (y - x)`, `s' + (y - x)`

**Finding**: Every single group operation (+, -, 0, negation) is used in essential ways. The `AddCommGroup` requirement is not an artifact -- it is a genuine semantic necessity for the MF/TF axioms (which relate modal necessity to temporal operators via time-shift invariance).

### 1.2 LinearOrder Alone Is Insufficient for the Current Semantics

I investigated whether `valid` could be redefined to quantify over `[LinearOrder D]` alone. The answer is definitively NO for the current axiom system, because:

1. **MF axiom** (`Box(phi) -> G(phi)`): Soundness proof needs to shift a history in time by `y - x`, which requires subtraction (group structure).

2. **TF axiom** (`Box(phi) -> H(phi)`): Same time-shift mechanism.

3. **WorldHistory.respects_task**: The duration `t - s` between two time points IS the group subtraction.

4. **Compositionality**: Task durations compose via addition: a task of duration `x` followed by a task of duration `y` equals a task of duration `x + y`.

Without group structure, there is no notion of "duration" between time points, and the task semantics collapses -- the relationship between time points and task durations disappears.

### 1.3 The BidirectionalQuotient Already Provides LinearOrder

The codebase already has a sorry-free `LinearOrder` on `BidirectionalQuotient`:
- `BidirectionalQuotient` = `Antisymmetrization (BidirectionalFragment M0 h_mcs0) (<= .)` (line 777 of BidirectionalReachable.lean)
- `instLinearOrderBidirectionalQuotient` (lines 784-795, no sorry)
- Based on `bidirectional_totally_ordered` (lines 728-740, no sorry)
- Based on `fragment_le_total` (lines 757-763, no sorry)

This is already a purely syntactic LinearOrder derived from CanonicalR.

### 1.4 The Gap: BidirectionalQuotient Lacks SuccOrder/PredOrder/AddCommGroup

The BidirectionalQuotient has:
- `LinearOrder` (proven)
- `Nonempty` (root M0 is in the fragment)

It lacks (needed for `orderIsoIntOfLinearSuccPredArch`):
- `SuccOrder`
- `PredOrder`
- `IsSuccArchimedean`
- `NoMaxOrder`
- `NoMinOrder`

And it ultimately lacks:
- `AddCommGroup` (the target)
- `IsOrderedAddMonoid` (order-group compatibility)

---

## 2. Alternative Frame Definitions

### 2.1 Option A: LinearOrder-Only TaskFrame (Radical Redesign)

**Idea**: Redefine `TaskFrame` to use only `LinearOrder D`, replacing group operations with order-theoretic primitives.

**Modified definitions**:
```lean
-- Instead of task_rel : WorldState -> D -> WorldState -> Prop
-- Use: task_rel : WorldState -> WorldState -> Prop (no duration parameter)
-- Or: task_rel_from_to : D -> D -> WorldState -> WorldState -> Prop (two time indices)

structure TaskFrame_Order (D : Type*) [LinearOrder D] where
  WorldState : Type
  task_rel : WorldState → D → D → WorldState → Prop  -- w,s,t,u: from w at time s to u at time t
  nullity : forall w t, task_rel w t t w
  compositionality : forall w u v s t r, task_rel w s t u → task_rel u t r v → task_rel w s r v
```

**Impact on Soundness**:
- Temporal operators (G, H, F, P) use ONLY `<=` on D -- these are fine with just LinearOrder.
- The MF/TF axioms need time-shift invariance. Without group structure, we would need to reformulate the axioms or accept that MF/TF are no longer part of the system.
- WorldHistory.respects_task would use `task_rel w s t u` instead of `task_rel w (t-s) u`.

**Verdict**: This is a **major semantic redesign**. It changes the meaning of task frames from the JPL paper's definition. The paper explicitly defines task frames as tuples `F = (W, G, .)` where G is a totally ordered abelian group. Removing the group structure would mean we are no longer proving completeness for the logic described in the paper.

**Confidence**: NOT RECOMMENDED. This changes the mathematical theory, not just the formalization.

### 2.2 Option B: Two-Phase Construction (Recommended Approach)

**Idea**: Build the frame in two phases:
1. Phase 1: Construct D = BidirectionalQuotient with only LinearOrder (purely syntactic, sorry-free)
2. Phase 2: Derive AddCommGroup + IsOrderedAddMonoid via Successor Algebra approach

**Phase 1 outputs** (all sorry-free in current codebase):
- `BidirectionalFragment M0 h_mcs0` with `Preorder`
- `BidirectionalQuotient M0 h_mcs0` with `LinearOrder`
- `FMCS (BidirectionalFragment M0 h_mcs0)` via `fragmentFMCS` (sorry-free forward_F/backward_P)

**Phase 2 requires** (new work):

Step 2a -- Define `SuccOrder` on `BidirectionalQuotient`:
```lean
-- succ [w] := [fragmentGSucc w] (the GContent successor)
-- Requires proving: fragmentGSucc is well-defined on quotient (respects equivalence)
-- Requires proving: succ is the IMMEDIATE successor (no element strictly between)
```

Step 2b -- Define `PredOrder` on `BidirectionalQuotient`:
```lean
-- pred [w] := backward analog via HContent predecessor
-- Symmetric construction
```

Step 2c -- Prove `IsSuccArchimedean`:
```lean
-- For any a <= b in BidirectionalQuotient, exists n : Nat, succ^[n] a >= b
-- Proof: by induction on BidirectionalReachable (number of edges from a to b)
```

Step 2d -- Prove `NoMaxOrder` and `NoMinOrder`:
```lean
-- NoMaxOrder: for every [w], succ [w] > [w]
--   From: F-witness existence -- every MCS contains some F(phi), so successor is strict
-- NoMinOrder: for every [w], pred [w] < [w]
--   From: P-witness existence -- every MCS contains some P(phi), so predecessor is strict
```

Step 2e -- Apply Mathlib infrastructure:
```lean
noncomputable def canonicalOrderIso :
    BidirectionalQuotient M0 h_mcs0 ≃o Z :=
  orderIsoIntOfLinearSuccPredArch

noncomputable instance : AddCommGroup (BidirectionalQuotient M0 h_mcs0) :=
  canonicalOrderIso.toEquiv.addCommGroup

-- IsOrderedAddMonoid follows from the OrderIso preserving structure
```

**Verdict**: This is the construction from research-010, applied to the BidirectionalQuotient (which already exists in the codebase). It derives group structure from intrinsic frame properties without imposing external structure.

**Confidence**: HIGH. This is mathematically sound and leverages existing codebase infrastructure.

### 2.3 Option C: Direct Z-Indexed Construction (Pragmatic)

**Idea**: Rather than working on the quotient, define `D := Int` directly and construct the FMCS as a Z-indexed chain. This is what the enriched chain construction in CanonicalChain.lean already does.

**Existing infrastructure**:
- `CanonicalChain.lean`: Z-indexed chain of MCSes
- `DovetailingChain.lean`: Dovetailing construction placing F/P witnesses

**Why this was previously resisted**: The user wanted to avoid "assuming D = Int" and instead derive the structure from syntax.

**The key philosophical distinction**: In Option C, D = Int is an IMPLEMENTATION CHOICE, justified by the fact that the BidirectionalQuotient is order-isomorphic to Z (which we would prove separately as a theorem). The FMCS `Int -> Set Formula` is constructed from the chain, and the AddCommGroup/LinearOrder/IsOrderedAddMonoid instances are the built-in ones on Int.

**Verdict**: Pragmatically the most efficient path. Philosophically less satisfying than Option B because D is chosen rather than constructed. However, mathematically equivalent (up to isomorphism).

**Confidence**: HIGH for feasibility, MEDIUM for alignment with user's vision.

---

## 3. Impact on Soundness Proofs

### 3.1 With Option B (Successor Algebra on BidirectionalQuotient)

The soundness proofs do NOT need to change at all. They are already generic over any `D` with `AddCommGroup + LinearOrder + IsOrderedAddMonoid`. Once we provide these instances on `BidirectionalQuotient`, the existing soundness theorems apply automatically.

The key soundness proofs and their algebraic dependencies:

| Theorem | Algebraic Operations Used | Status with Transferred AddCommGroup |
|---------|--------------------------|--------------------------------------|
| `time_shift_preserves_truth` | `+`, `-`, `add_sub`, `neg_sub`, `add_comm`, `sub_sub_cancel`, `add_sub_cancel_left` | All provided by transferred AddCommGroup |
| `temp_4_valid` (G(phi) -> G(G(phi))) | Only `<=` transitivity | Already works |
| `temp_a_valid` (phi -> G(P(phi))) | Only `<=` and `add_sub_cancel_left` | Works with transferred structure |
| `modal_future_valid` (Box(phi) -> G(phi)) | `time_shift`, `ShiftClosed` | Works with transferred structure |
| `temp_future_valid` (Box(phi) -> H(phi)) | `time_shift`, `ShiftClosed` | Works with transferred structure |
| `temp_l_valid` (F(phi) and F(psi) -> ...) | `LinearOrder.le_total` | Already works from quotient LinearOrder |

### 3.2 Critical Detail: Transferred Addition Respects Order

The transferred AddCommGroup gives `a + b := e.symm (e a + e b)` where `e : D ≃o Z`. For `IsOrderedAddMonoid`, we need:

```
a <= b -> a + c <= b + c
```

This follows from:
```
a <= b
  => e a <= e b           (e is OrderIso, preserves <=)
  => e a + e c <= e b + e c  (Z is ordered additive group)
  => e.symm(e a + e c) <= e.symm(e b + e c)  (e.symm preserves <=)
  => (a + c) <= (b + c)   (definition of transferred +)
```

This proof is straightforward but must be manually provided. Mathlib does NOT automatically transfer `IsOrderedAddMonoid` through `Equiv.addCommGroup` (the `Equiv.addCommGroup` function only transfers the algebraic structure, not the order compatibility).

### 3.3 Alternative: OrderAddMonoidIso

Mathlib's `OrderAddMonoidIso` (found in `Mathlib.Algebra.Order.Hom.Monoid`) bundles both the additive equivalence and order preservation. If we can construct `BidirectionalQuotient ≃+o Z`, all structure transfers at once.

The key theorem from research-010:
```
LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos:
  For G with [LinearOrderedAddCommGroup G] [Archimedean G],
  if x is the least positive element,
  then G ≃+o Z
```

However, this requires `LinearOrderedAddCommGroup G` as input, which is what we are trying to construct. So this is circular for our purpose. The correct path is:
1. Get `OrderIso D Z` from `orderIsoIntOfLinearSuccPredArch`
2. Get `AddCommGroup D` from `Equiv.addCommGroup`
3. Manually prove `IsOrderedAddMonoid D` from the OrderIso

---

## 4. Generality Analysis (Discreteness/Density Extensibility)

### 4.1 How Discreteness/Density Axioms Affect the Construction

The Successor Algebra approach (Option B) naturally parameterizes over frame properties:

**Base TM Logic (no additional axioms)**:
- The enriched chain construction produces a discrete sequence of MCSes
- `SuccOrder` and `PredOrder` arise from `fragmentGSucc` and its backward analog
- `IsSuccArchimedean` follows from the chain construction visiting all fragment elements
- Result: `D ≃o Z`, `AddCommGroup D` transferred from Z

**With Discreteness Axiom** (`F(phi) -> phi -> P(phi)`):
- This axiom explicitly forces that the successor is immediate
- Makes the `SuccOrder` coverness proof trivial (the axiom directly gives it)
- Same result: `D ≃o Z`, but with a simpler proof

**With Density Axiom** (`F(F(phi)) -> F(phi)`):
- This forces intermediate points between any two distinct elements
- `SuccOrder` CANNOT be defined (no immediate successors)
- The BidirectionalQuotient becomes a countable dense linear order without endpoints
- By Cantor's theorem: `D ≃o Q` (unique up to isomorphism)
- `AddCommGroup D` would be transferred from Q instead of Z

### 4.2 Impact on TaskFrame Definition

The current TaskFrame definition with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` is ALREADY general enough for both cases:
- Discrete case: D = Z (or isomorphic), satisfies all three
- Dense case: D = Q (or isomorphic), satisfies all three
- Continuous case: D = R (or isomorphic), satisfies all three

No change to TaskFrame is needed for extensibility.

### 4.3 Impact on Validity Definition

The validity definition quantifies over ALL `D` with the required typeclasses:
```lean
def valid (phi : Formula) : Prop :=
  forall (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ...
```

This already covers Z, Q, R, and any other totally ordered abelian group. Completeness with respect to a specific D (say Z) gives completeness with respect to all D (since validity quantifies universally).

### 4.4 What Would Change for Density Extensions

If we add a density axiom to the logic:
1. The BidirectionalQuotient would be densely ordered (no SuccOrder)
2. We would need a different representation theorem: `D ≃o Q` instead of `D ≃o Z`
3. The transfer mechanism would be the same (`Equiv.addCommGroup` from Q instead of Z)
4. The soundness proofs would not change (they are generic over D)

The only code that would change is the completeness proof:
- Instead of `orderIsoIntOfLinearSuccPredArch`, use Cantor's theorem for countable dense linear orders
- Instead of transferring from Z, transfer from Q

The key point: the Successor Algebra approach is specific to the DISCRETE case. A general framework would use:

| Frame Property | Representation | Mathlib Path |
|---------------|---------------|--------------|
| Discrete, no endpoints, Archimedean | D ≃o Z | `orderIsoIntOfLinearSuccPredArch` |
| Dense, countable, no endpoints | D ≃o Q | Cantor's back-and-forth (needs implementation) |
| Archimedean, continuous | D embeds into R | `Archimedean.denseRange_cast` |

### 4.5 Generality Assessment

The recommended approach (Option B) handles the base TM logic (discrete case) and naturally extends to density/continuity variants. The key abstraction point is the representation theorem:

```
For each axiom set A:
  The canonical BidirectionalQuotient for TM + A
  is order-isomorphic to the "standard" ordered group G_A
  where G_A = Z (discrete), Q (dense), or R (continuous)
```

This is the "extensibility by discreteness/density axioms" that the user envisions. The approach scales because:
1. The BidirectionalQuotient construction is independent of which axioms are present
2. The order-theoretic properties of the quotient are determined by the axioms
3. The representation theorem connects these properties to a standard group
4. The structure transfer mechanism is uniform

---

## 5. Recommended Approach

### 5.1 Synthesis

**Primary Recommendation**: Option B (Two-Phase Construction via Successor Algebra)

This approach:
- Uses ONLY properties that arise naturally from the syntax (MCS, formulas, derivability)
- Does NOT impose external structure -- the AddCommGroup is DERIVED, not assumed
- Is compatible with future extensions (density axioms change which representation theorem applies)
- Leverages existing codebase infrastructure (BidirectionalQuotient with LinearOrder is already proven)
- Aligns with the user's vision of "constructing the frame from pure syntax"

### 5.2 Concrete Steps

1. **Define SuccOrder on BidirectionalQuotient** (MEDIUM difficulty)
   - Lift `fragmentGSucc` to the quotient
   - Prove coverness (immediate successor, no intermediate elements)

2. **Define PredOrder on BidirectionalQuotient** (MEDIUM difficulty)
   - Symmetric construction using HContent predecessor

3. **Prove IsSuccArchimedean** (MEDIUM difficulty)
   - Induction on BidirectionalReachable edge count

4. **Prove NoMaxOrder / NoMinOrder** (EASY-MEDIUM difficulty)
   - From F-witness / P-witness existence

5. **Apply orderIsoIntOfLinearSuccPredArch** (FREE from Mathlib)
   - Requires items 1-4 plus LinearOrder (already proven) and Nonempty (already proven)

6. **Transfer AddCommGroup via Equiv.addCommGroup** (FREE from Mathlib)
   - Requires the OrderIso from item 5

7. **Prove IsOrderedAddMonoid** (EASY)
   - From the OrderIso preserving both order and transferred addition

8. **Construct TaskFrame (BidirectionalQuotient M0 h_mcs0)** (MEDIUM difficulty)
   - Define task_rel using quotient position differences
   - Prove nullity and compositionality from group structure

### 5.3 Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| SuccOrder coverness proof is hard | HIGH | HIGH | Use the enriched chain's integer indexing as a shortcut: the chain already defines successor by `chain(n+1)`, and coverness follows from the chain being maximal |
| Quotient lifting for succ fails | MEDIUM | HIGH | Work on the enriched chain type instead of the quotient directly |
| NoMaxOrder needs formula-level argument | LOW | LOW | Standard MCS property: completeness of negation + F-witness existence |
| IsOrderedAddMonoid transfer is manual | LOW | LOW | Straightforward from OrderIso structure preservation |
| This does not resolve the remaining sorry | CERTAIN | N/A | The sorry in `fully_saturated_bfmcs_exists_int` is about modal saturation, completely orthogonal to D's algebraic structure |

### 5.4 What About the SuccOrder Coverness Problem?

This is the hardest part of the construction. The question is: given `w` in the BidirectionalQuotient and `succ(w) = [fragmentGSucc w]`, is there NO element strictly between `w` and `succ(w)`?

**Approach via Enriched Chain**: Rather than proving coverness directly on the quotient, use the fact that the enriched chain construction (CanonicalChain.lean) already produces a Z-indexed sequence where `chain(n)` and `chain(n+1)` are related by a single CanonicalR step. If the chain visits ALL elements of the BidirectionalFragment (which it should, by the dovetailing construction), then the chain ordering IS the quotient ordering, and coverness follows from the chain being Z-indexed with no gaps.

**Approach via Fragment Analysis**: Suppose `w < v < succ(w)` in the quotient. Then:
- `GContent(w.world) strictly-subset-of v.world` (from `w < v`)
- `GContent(v.world) strictly-subset-of succ(w).world` (from `v < succ(w)`)
- But `succ(w) = fragmentGSucc(w)` is the Lindenbaum extension of `GContent(w.world)`
- So `v.world` contains `GContent(w.world)` but is strictly contained in `fragmentGSucc(w).world`

The question reduces to: can a strict intermediate MCS exist between `w.world` and `fragmentGSucc(w).world` in the CanonicalR order? This depends on whether the Lindenbaum extension can be "partially applied."

In the absence of density axioms, the key insight is that CanonicalR steps correspond to SINGLE temporal transitions. The fragment captures all MCSes reachable by iterated single steps. An intermediate element would require "half a step" which the logic does not provide.

**Assessment**: The coverness proof is the critical path item. If it proves too difficult on the quotient, the fallback is to use Int directly (Option C) with the philosophical justification from the representation theorem.

---

## 6. Confidence Level

**Overall Confidence**: HIGH (0.85)

- The two-layer architecture analysis is definitive -- AddCommGroup is genuinely required for the semantic layer
- The Successor Algebra approach (Option B) is mathematically sound and well-supported by Mathlib
- The existing BidirectionalQuotient with LinearOrder provides a solid foundation
- The main uncertainty is the SuccOrder coverness proof, which has clear fallback paths
- The extensibility to density/discreteness axioms is well-characterized

**Specific Confidence Levels**:
- Finding 1.1 (AddCommGroup is necessary): 0.95
- Finding 1.2 (LinearOrder alone is insufficient): 0.95
- Option B feasibility: 0.80
- SuccOrder coverness provability: 0.65
- Extensibility analysis: 0.85

---

## 7. Appendix: Codebase Files Examined

| File | Key Observation |
|------|----------------|
| `Validity.lean` | `valid` quantifies `forall D [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` |
| `TaskFrame.lean` | Requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` in structure params |
| `Truth.lean` | `truth_at` uses only `<=` for temporal operators, but inherits group params from TaskFrame |
| `WorldHistory.lean` | `time_shift` uses `z + Delta`, `t - s`, `add_sub_add_right_eq_sub` |
| `SoundnessLemmas.lean` | `time_shift_preserves_truth` uses full group algebra |
| `FMCSDef.lean` | FMCS requires only `Preorder D` (confirmed) |
| `BidirectionalReachable.lean` | LinearOrder on BidirectionalQuotient proven (no sorry) |
| `TemporalCoherentConstruction.lean` | Single sorry at line 600 (modal saturation, orthogonal to D structure) |

## 8. Appendix: Mathlib Lookups

| Query | Tool | Result |
|-------|------|--------|
| `orderIsoIntOfLinearSuccPredArch` | lean_loogle | `OrderIso iota Z` for discrete linear orders without endpoints |
| `Equiv.addCommGroup` | lean_loogle | Transfers AddCommGroup through equivalence |
| `LinearOrderedAddCommGroup` | lean_local_search | Found `discrete_or_denselyOrdered`, `isAddCyclic_iff_nonempty_equiv_int` |
| `IsSuccArchimedean` | lean_local_search | Found class in `Mathlib.Order.SuccPred.Archimedean` |
| `OrderAddMonoidIso` | lean_leanfinder | Bundles AddEquiv + order preservation |
| Transfer ordered monoid via OrderIso | lean_leansearch | `OrderAddMonoidIso` API, no automatic transfer |
