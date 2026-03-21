# Research Report: Torsor-Based Construction of D from Canonical Timeline

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-005
**Date**: 2026-03-06
**Session**: sess_1772900100_d9e6fa
**Status**: Findings ready for planning

---

## 1. Executive Summary

This report investigates the torsor-based approach to constructing D (the duration group) from the canonical timeline T, with particular focus on:

1. What makes the eval_w0 map a bijection (torsor structure analysis)
2. How Mathlib's `AddTorsor` infrastructure supports the construction
3. What properties T inherits from the temporal axioms alone (no discreteness/density)
4. A concrete, no-compromise approach that is compatible with both discrete and dense extensions
5. Which existing files should be archived

**Principal Finding**: The construction is viable and well-supported by Mathlib. The key insight is that we should NOT construct D as `Aut+(T)` directly and then prove it abelian. Instead, we should build the `AddTorsor` structure on T directly from the temporal coherence properties, and then D is simply the group that acts on T -- which Mathlib's `AddTorsor` machinery provides automatically via `Equiv.vaddConst`.

**Critical Constraint Verification**: This approach makes NO assumptions about discreteness or density. The construction works for ANY linear order T satisfying the temporal axioms. Future discreteness or density axioms merely specialize the resulting D.

---

## 2. Torsor Structure Analysis

### 2.1 What Makes T a Torsor for Its Translation Group?

A set T with an action of a group G is a **torsor** (principal homogeneous space) for G when the action is both:

- **Free**: If g . x = x for some x in T, then g = id
- **Transitive**: For any x, y in T, there exists g in G with g . x = y

Equivalently, T is a torsor for G when the map `(g, x) -> (g . x, x)` from `G x T` to `T x T` is a bijection. This means: for any pair `(y, x)` in `T x T`, there is a **unique** `g in G` with `g . x = y`.

In Mathlib, this is captured by `AddTorsor G T`:
- `vadd : G -> T -> T` (the action `g +v x`)
- `vsub : T -> T -> G` (the difference `y -v x`, the unique g mapping x to y)
- `vsub_vadd' : (y -v x) +v x = y` (difference then add recovers target)
- `vadd_vsub' : (g +v x) -v x = g` (add then difference recovers group element)

The eval_w0 map is exactly `Equiv.vaddConst w0 : G equiv T`, which maps `g` to `g +v w0`. Its inverse is `fun y => y -v w0`.

### 2.2 Minimal Conditions for Torsor Structure on a Linear Order

For a linear order (T, <) without endpoints, the order-preserving automorphism group Aut+(T) acts on T. This action is a torsor when:

1. **Homogeneity** (= transitivity): For any a, b in T, there exists f in Aut+(T) with f(a) = b. This means no point in T is distinguishable from any other by order-theoretic properties alone.

2. **Rigidity** (= freeness): If f in Aut+(T) fixes any point, then f = id. For linear orders, this follows from connectivity: if f(a) = a and f is order-preserving, then for any b > a, we cannot have f(b) > b or f(b) < b without contradicting that f preserves the order structure around a.

**Key theorem**: For a linear order T:
- Rigidity holds automatically for any connected linear order without endpoints (standard result in ordered permutation group theory)
- Homogeneity requires that T be "locally uniform" -- every point has the same order-theoretic neighborhood structure

### 2.3 Relationship Between Torsor Structure and Abelianness

**Theorem** (Holder, 1901): If a group G acts freely and order-preservingly on a linearly ordered set, then G is abelian (written additively: commutative).

This is why the translation group of a linear order is always an abelian group. The proof uses the fact that the ordering on G (pulled back via eval at any point) is bi-invariant, and a bi-invariantly ordered group is abelian.

**Consequence**: We do NOT need to prove commutativity separately. Once we have a free transitive order-preserving action, commutativity follows.

---

## 3. Mathlib Infrastructure Assessment

### 3.1 AddTorsor (Verified Available)

**File**: `Mathlib.Algebra.AddTorsor.Defs`

```lean
class AddTorsor (G : outParam Type*) (P : Type*) [AddGroup G]
    extends AddAction G P, VSub G P where
  vsub_vadd' : forall (p1 p2 : P), (p1 -v p2) +v p2 = p1
  vadd_vsub' : forall (g : G) (p : P), (g +v p) -v p = g
  nonempty : Nonempty P
```

Key equivalences:
- `Equiv.vaddConst (p : P) : G equiv P` -- the eval_p map (g -> g +v p)
- `Equiv.constVSub (p : P) : P equiv G` -- the difference-from-p map (q -> p -v q)

### 3.2 OrderIso Group Structure (Verified Available)

```lean
-- alpha equivo alpha has Group instance
instance : Group (alpha equivo alpha) := ...  -- from Mathlib
instance : MulAction (alpha equivo alpha) alpha := ...  -- from Mathlib
```

This means order automorphisms already form a group acting on alpha. However, this is a **multiplicative** group, not additive.

### 3.3 Additive Wrapper (Verified Available)

```lean
-- Additive (alpha equivo alpha) has AddGroup instance
instance : AddGroup (Additive (alpha equivo alpha)) := ...
```

The `Additive` type tag converts a multiplicative group to an additive one.

### 3.4 LinearOrder Transfer (Verified Available)

```lean
-- LinearOrder.lift : (f : alpha -> beta) -> Injective f -> ... -> LinearOrder alpha
-- Can pull back a LinearOrder from T to D via eval_w0
```

### 3.5 Key Mathlib Theorems for the Two Extension Paths

**Discrete case**:
- `orderIsoIntOfLinearSuccPredArch` -- if T has SuccOrder, PredOrder, IsSuccArchimedean, NoMaxOrder, NoMinOrder, then T equivo Int

**Dense case**:
- `Order.iso_of_countable_dense` -- if T and Q are both countable, dense, no endpoints, nonempty, then T equivo Q (Cantor's back-and-forth)

These are NOT needed for the base construction. They become relevant only when discreteness or density axioms are added.

---

## 4. What T Inherits from Temporal Axioms (Without Discreteness/Density)

### 4.1 Properties Guaranteed by the Base TM Axioms

The canonical timeline T (the set of all MCSs reachable from a root w0) inherits:

| Property | Source Axiom(s) | Lean Analog |
|----------|----------------|-------------|
| Linear order | `temp_linearity` + `temp_4` + `temp_a` | `LinearOrder T` |
| No maximum | `temp_a` (phi -> G(P(phi))) | `NoMaxOrder T` |
| No minimum | Temporal duality of `temp_a` | `NoMinOrder T` |
| Reflexive G/H | `temp_t_future`, `temp_t_past` | Included in `<=` definition |
| Transitive temporal relation | `temp_4` (G phi -> GG phi) | Transitivity of `<=` |
| Connected (every point reachable from w0) | Existence lemma construction | By construction |

### 4.2 Properties NOT Guaranteed (Require Additional Axioms)

| Property | Required Axiom | Effect |
|----------|---------------|--------|
| Discrete (SuccOrder) | None in base TM | Would make D iso Z |
| Dense (DenselyOrdered) | Density axiom (e.g., G phi -> GF phi) | Would make D iso Q |
| Archimedean | Implicit in base TM for countable formulas | Technical condition |

### 4.3 The Critical Question: Does Homogeneity Hold?

**For the base TM axioms**: The temporal axioms are uniform -- they apply equally at every time point. No axiom distinguishes w0 from any other point. The linearity axiom ensures T is totally ordered. The existence lemmas (from F and P formulas) ensure T has no endpoints and every point has neighbors.

**However**: Homogeneity is a **semantic** property of the specific canonical model, not a syntactic property. The key insight from research-001 is:

> For a connected linear order without endpoints where every point has the same local structure, homogeneity follows.

The temporal axioms ensure every point in T has the same local structure because:
1. The axioms are schema -- they apply to ALL formulas at ALL times
2. No axiom breaks temporal symmetry (the logic has time-reversal symmetry via swap_past_future)
3. The existence lemma produces witnesses uniformly

**Formal argument for homogeneity**: Given two points a, b in T, the "theory at a" (the set of formulas true at a) and the "theory at b" have the same structural properties (both are MCSs satisfying the same axioms). The automorphism mapping a to b can be constructed by a back-and-forth argument using the existence lemma.

### 4.4 The FMCS Structure Already Encodes the Action

The current `FMCS D` structure (in FMCSDef.lean) assigns an MCS to each time point. With `D = Preorder`, the family `fam.mcs : D -> Set Formula` is exactly the action of D on the timeline. The coherence conditions (`forward_G`, `backward_H`) ensure the action respects temporal operators.

When we specialize to the torsor approach:
- `fam.mcs t` = the MCS at the point `t +v w0` in T
- `forward_G` = the G-content of `fam.mcs t` is included in `fam.mcs t'` for t <= t'
- This IS the group action, just viewed from the D side

---

## 5. Archival Candidates

### 5.1 Files to Archive

| File | Reason | Replacement |
|------|--------|-------------|
| `DovetailingChain.lean` | Hardcodes `FMCS Int`, dovetailing construction for Z-indexed chains. Has 2 sorries (forward_F, backward_P) that cannot be resolved in the linear chain framework. | New torsor-based construction |
| `CanonicalChain.lean` | Builds `CanonicalChain` as `Int -> CanonicalMCS`, hardcodes Int. | Torsor construction makes chains unnecessary |
| `CanonicalConstruction.lean` | Defines `CanonicalTaskFrame : TaskFrame Int` with `canonical_task_rel` that ignores duration. | New canonical frame with D = Aut+(T) |

### 5.2 Files to Refactor (Not Archive)

| File | Current State | Needed Change |
|------|--------------|---------------|
| `Representation.lean` | Uses `TaskFrame Int`, `BFMCS Int`, `canonicalFrame : TaskFrame Int` with trivial task_rel | Replace Int with constructed D, replace trivial task_rel with group action |
| `TemporalCoherentConstruction.lean` | Temporal backward properties parameterized by `D : Type* [Preorder D]` | Already generic, should work with new D |
| `FMCSDef.lean` | `FMCS D` parameterized by `D : Type* [Preorder D]` | Already generic, no changes needed |
| `BFMCS.lean` | `BFMCS D` parameterized by `D : Type* [Preorder D]` | Already generic, no changes needed |

### 5.3 Files Without `orderIsoIntOfLinearSuccPredArch`

Confirmed: No files in `Theories/` reference `orderIsoIntOfLinearSuccPredArch`. It appears only in specs/ research reports as a proposed approach that was never implemented in Lean code. No archival needed for this symbol.

### 5.4 Files Without SuccOrder/PredOrder

Confirmed: No files in `Theories/` reference `SuccOrder` or `PredOrder`. These concepts were proposed in task 954's plan but never implemented. No archival needed.

---

## 6. Viable Approach: Torsor-First Construction

### 6.1 Mathematical Framework

**Step 1**: Define the canonical timeline T from a consistent context.
- T = set of all MCSs reachable from a root w0 via the existence lemma
- T has a canonical linear order from the temporal precedence relation
- T has no endpoints (from seriality/existence lemmas)

**Step 2**: Define the difference operation on T.
- For any a, b in T, define `b - a` as the unique order-automorphism mapping a to b
- This is well-defined because the action of Aut+(T) on T is free and transitive
- The "uniqueness" part follows from rigidity (freeness)
- The "existence" part follows from homogeneity (transitivity)

**Step 3**: Define D as the additive group acting on T.
- D = Additive (T equivo T) -- the order automorphisms viewed additively
- The action of D on T is `d +v w = d.toFun w`
- T becomes an AddTorsor for D

**Step 4**: Define the linear order on D.
- Pull back the linear order from T via eval_w0: `d1 <= d2 iff d1(w0) <= d2(w0)`
- This makes D a LinearOrderedAddCommGroup (abelianness from Holder's theorem)

**Step 5**: The canonical frame uses D as constructed.
- `task_rel w d w'` iff `d +v w = w'` (the group action)
- Nullity: `0 +v w = w` (identity element of group action)
- Compositionality: `(d1 + d2) +v w = d1 +v (d2 +v w)` (group action axiom)

### 6.2 Lean Implementation Strategy

#### Phase 1: Canonical Timeline (New File: `CanonicalTimeline.lean`)

```lean
-- The canonical timeline: set of MCSs reachable from root
structure CanonicalTimeline where
  root : Set Formula
  root_mcs : SetMaximalConsistent root
  -- The set of all reachable MCSs
  points : Type
  -- Linear order on points
  order : LinearOrder points
  -- No endpoints
  no_max : NoMaxOrder points
  no_min : NoMinOrder points
  -- The root point
  origin : points
  -- Each point corresponds to an MCS
  mcs_at : points -> Set Formula
  mcs_at_is_mcs : forall p, SetMaximalConsistent (mcs_at p)
  -- Origin corresponds to root
  origin_eq : mcs_at origin = root
  -- Temporal coherence
  forward_G : forall p q phi, p <= q -> Formula.all_future phi in mcs_at p -> phi in mcs_at q
  backward_H : forall p q phi, q <= p -> Formula.all_past phi in mcs_at p -> phi in mcs_at q
```

#### Phase 2: Translation Group (New File: `TranslationGroup.lean`)

```lean
-- D is the group of order-preserving automorphisms of T
-- Using Mathlib: (T equivo T) already has Group instance
-- Use Additive wrapper for additive convention

def TranslationGroup (T : CanonicalTimeline) := Additive (T.points equivo T.points)

-- Prove the action is free and transitive
-- Then construct AddTorsor instance
instance : AddTorsor (TranslationGroup T) T.points := ...
```

#### Phase 3: Linear Order on D (Same file or `DurationOrder.lean`)

```lean
-- Pull back linear order from T to D via eval at origin
instance : LinearOrder (TranslationGroup T) :=
  LinearOrder.lift (fun d => (Additive.toMul d) T.origin) (eval_injective T)
    ... -- max/min compatibility

-- Prove order compatibility with addition
instance : IsOrderedAddMonoid (TranslationGroup T) := ...

-- Prove commutativity (Holder's theorem)
instance : AddCommGroup (TranslationGroup T) := ...
```

#### Phase 4: Canonical Frame with Constructed D

```lean
-- The canonical task frame uses D = TranslationGroup T
def canonicalTaskFrame (T : CanonicalTimeline) : TaskFrame (TranslationGroup T) where
  WorldState := T.points
  task_rel := fun w d w' => (Additive.toMul d) w = w'
  nullity := fun w => OrderIso.refl_apply w  -- id(w) = w
  compositionality := ...  -- (f . g)(w) = f(g(w))
```

### 6.3 Proof Obligations

The main proof obligations, ordered by difficulty:

1. **Rigidity (freeness)**: If f in Aut+(T) fixes w0, then f = id.
   - Standard argument for connected linear orders
   - Difficulty: Medium (needs careful induction on reachability)

2. **Homogeneity (transitivity)**: For any a, b in T, there exists f in Aut+(T) with f(a) = b.
   - Requires back-and-forth argument using existence lemma
   - Difficulty: **High** (this is the hardest step)
   - Alternative: Prove this as a consequence of temporal axiom uniformity

3. **Abelianness**: Holder's theorem for Aut+(T).
   - Well-known result, but needs formalization
   - Difficulty: Medium (standard ordered group theory)

4. **Order compatibility**: The pulled-back order is compatible with addition.
   - Follows from order-preservation of automorphisms
   - Difficulty: Low

5. **Truth lemma**: MCS membership iff truth in canonical model.
   - Existing infrastructure mostly reusable
   - Difficulty: Medium (need to adapt for new task_rel)

### 6.4 Handling the Homogeneity Challenge

The homogeneity proof is the most challenging part. There are three strategies:

**Strategy A (Direct Back-and-Forth)**: Construct the automorphism mapping a to b by a transfinite back-and-forth argument. This works when T is countable (which it is, since the formula language is countable).

**Strategy B (Axiom Schema Uniformity)**: Argue that because the axioms are schemata (they hold for ALL formulas), any two MCSs in T are "elementarily equivalent" in the temporal fragment, and hence there is an automorphism between them. This is a model-theoretic argument.

**Strategy C (AddTorsor from FMCS directly)**: Instead of constructing Aut+(T) and proving homogeneity, define the torsor structure DIRECTLY from the FMCS construction. The key observation:

> Given any two points a, b in T, the "difference" b - a can be defined as the unique FMCS that maps the origin to a shifted version of b relative to a. The FMCS coherence conditions already encode this shift.

This is the most promising approach because it leverages existing infrastructure.

**Recommended**: Strategy C. The FMCS structure already provides the family `mcs : D -> Set Formula` which IS the group action. Instead of constructing Aut+(T) from scratch, we should:

1. Define D as a quotient type that captures "temporal displacements" between MCSs
2. Use the existing FMCS coherence to prove group axioms
3. Construct the AddTorsor from the FMCS action

### 6.5 Alternative Formulation: D as Difference Group

Instead of `D = Aut+(T)`, define:

```
D = T x T / ~
where (a, b) ~ (c, d) iff "the displacement from a to b equals the displacement from c to d"
```

The equivalence relation is: (a, b) ~ (c, d) iff there exists f in Aut+(T) with f(a) = c and f(b) = d.

This is the standard construction of a group from a torsor. Group operations:
- Addition: [(a, b)] + [(b, c)] = [(a, c)]
- Zero: [(a, a)]
- Negation: -[(a, b)] = [(b, a)]

The action on T: [(a, b)] +v x = "apply the same displacement as from a to b, starting at x"

**Advantage**: This avoids explicitly constructing automorphisms. The equivalence classes ARE the durations, defined purely in terms of pairs of points.

**Challenge**: Proving well-definedness requires showing that the "displacement" concept is well-defined -- which circles back to homogeneity.

---

## 7. Compatibility with Discrete and Dense Extensions

### 7.1 Discrete Extension (D iso Z)

If we add a **discreteness axiom** to TM (e.g., "every point has an immediate successor"):
- T becomes a discrete linear order without endpoints
- T has SuccOrder, PredOrder, IsSuccArchimedean
- By `orderIsoIntOfLinearSuccPredArch`: T equivo Int
- D = Aut+(T) iso (Z, +)

The torsor construction produces D first, and THEN the isomorphism D iso Z follows from the discreteness axiom. This is the correct direction: D is primary, Z is a representation.

### 7.2 Dense Extension (D iso Q)

If we add a **density axiom** to TM (e.g., G phi -> GF phi):
- T becomes a countable dense linear order without endpoints
- By `Order.iso_of_countable_dense`: T equivo Q
- D = Aut+(T) iso (Q, +) (since Aut+(Q) = (Q, +))

### 7.3 Base Case (No Extension)

Without additional axioms:
- T is a linear order without endpoints
- D = Aut+(T) is a linearly ordered abelian group
- D satisfies AddCommGroup, LinearOrder, IsOrderedAddMonoid
- This is exactly what TaskFrame D requires
- No further specialization needed for the completeness theorem

---

## 8. Relationship to Existing Codebase

### 8.1 What Can Be Reused

| Component | File | Reusability |
|-----------|------|-------------|
| FMCS structure | FMCSDef.lean | 100% -- already generic over D with Preorder |
| BFMCS structure | BFMCS.lean | 100% -- already generic |
| Temporal coherence proofs | TemporalCoherentConstruction.lean | 90% -- generic, may need minor adaptation |
| TaskFrame definition | TaskFrame.lean | 100% -- already generic over D |
| Truth definition | Truth.lean | 100% -- already generic |
| Time-shift preservation | Truth.lean | 100% -- already generic |
| ShiftClosed machinery | Truth.lean | 100% -- already generic |
| Modal saturation | ModalSaturation.lean | Check: may hardcode Int |
| Existence lemma | Construction.lean | Check: may hardcode Int |

### 8.2 What Must Be Replaced

| Component | Current | Replacement |
|-----------|---------|-------------|
| `canonicalFrame : BFMCS Int -> TaskFrame Int` | trivial task_rel, hardcoded Int | task_rel = group action, D = TranslationGroup T |
| `canonicalHistory` | Uses `mkCanonicalWorldState B fam t` | Same structure, D parameter changes |
| `shiftClosedCanonicalOmega` | Shift by Int | Shift by D |
| `standard_representation` | `satisfiable Int [phi]` | `satisfiable D [phi]` for constructed D |

### 8.3 The Trivial task_rel Problem

The current `Representation.lean` uses `task_rel := fun _ _ _ => True`. This is a placeholder that makes the semantics degenerate -- the task relation provides no information. In the torsor approach:

```lean
task_rel w d w' := (Additive.toMul d) w = w'
```

This is a **deterministic** task relation: for each (w, d), there is exactly one w'. This matches the paper's intention where task_rel represents the group action of durations on world states.

---

## 9. Risk Assessment and Recommendations

### 9.1 Risks

| Risk | Severity | Mitigation |
|------|----------|------------|
| Homogeneity proof is hard | HIGH | Use Strategy C (FMCS-based torsor) instead of explicit Aut+ construction |
| Holder's theorem not in Mathlib | MEDIUM | Prove directly for our specific case (action on linear order) |
| Existing completeness proof breaks | MEDIUM | Phase the refactor: first get D construction, then integrate |
| Upstream sorry debt inherited | LOW | Existing sorries in DovetailingChain are being replaced, not inherited |

### 9.2 Recommendations

1. **Use the FMCS-based approach (Strategy C)** rather than constructing Aut+(T) from scratch. The FMCS structure already provides the group action; we just need to extract D from it.

2. **Phase the implementation**:
   - Phase 1: Define CanonicalTimeline and prove basic properties
   - Phase 2: Construct D = TranslationGroup T with AddCommGroup
   - Phase 3: Prove LinearOrder on D and IsOrderedAddMonoid
   - Phase 4: Build canonical TaskFrame with D and non-trivial task_rel
   - Phase 5: Adapt truth lemma and completeness theorems

3. **Do NOT try to archive DovetailingChain.lean yet**. It currently provides the `construct_saturated_bfmcs_int` function used by Representation.lean. Archive only after the replacement is working.

4. **Mark implementation [BLOCKED] if homogeneity proof cannot be completed**. The homogeneity proof is the mathematical crux. If it requires techniques beyond what's currently available (e.g., model-theoretic arguments not formalized in Lean/Mathlib), the task should be blocked rather than using sorry.

5. **Consider a "thin abstraction" intermediate step**: Before the full torsor construction, create a type alias `CanonicalDuration` that wraps the existing `FMCS Int` infrastructure but hides the `Int` behind an opaque type. This allows testing the downstream changes without committing to the full construction.

---

## 10. Summary of Findings

- **Torsor analysis**: T is a torsor for Aut+(T) when the action is free (rigidity) and transitive (homogeneity). Rigidity is standard for connected linear orders. Homogeneity follows from the uniformity of temporal axioms but requires a non-trivial proof.

- **Mathlib support**: `AddTorsor`, `Equiv.vaddConst`, `LinearOrder.lift`, `Group (alpha equivo alpha)`, `Additive` wrapper are all available. The infrastructure is sufficient.

- **Temporal properties**: T inherits linear order, no endpoints, transitivity from the base TM axioms. Discreteness and density are NOT inherited -- they require additional axioms.

- **Recommended approach**: FMCS-based torsor construction (Strategy C) rather than explicit Aut+ (Strategy A/B). This leverages existing infrastructure and avoids the hardest parts of the homogeneity proof.

- **Archival**: DovetailingChain.lean, CanonicalChain.lean, and CanonicalConstruction.lean are candidates for archival once the replacement is working. No SuccOrder/PredOrder/orderIsoInt code exists in Theories/ to archive.

- **Zero-sorry commitment**: If the homogeneity proof cannot be completed, recommend [BLOCKED] status rather than sorry deferral. The construction must be sorry-free or not attempted.
