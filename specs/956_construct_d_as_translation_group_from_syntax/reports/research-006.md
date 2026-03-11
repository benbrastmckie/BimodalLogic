# Research Report: Blockers and Alternatives for Homogeneity, Freeness, and Commutativity

**Task**: 956 -- Construct D as translation group from syntax
**Report**: research-006
**Date**: 2026-03-06
**Session**: sess_1772910000_c3d4e5
**Status**: Findings ready for planning

---

## 1. Executive Summary

This report investigates the three blockers identified during the implementation of `TranslationGroup.lean` (D = `Additive(T ≃o T)`) and evaluates alternatives for overcoming them.

**Blockers analyzed:**
1. **Freeness/Rigidity** (LinearOrder on D): An order automorphism fixing any point must be identity
2. **Holder's Theorem** (AddCommGroup): Free order-preserving action implies abelian group
3. **Homogeneity** (AddTorsor D T): For any a, b in T, there exists an automorphism mapping a to b

**Principal Finding:** The three blockers form a dependency chain: Homogeneity is the hardest and most fundamental. Freeness is provable from the MCS structure but requires a non-trivial argument. Holder's theorem follows from freeness. However, **none of these three properties are needed for the completeness theorem** if an alternative approach bypasses the full automorphism group construction.

**Recommended Path:** Option D (Axiomatic Abstraction) -- abstract the three properties as typeclass assumptions on T, prove completeness conditionally, then discharge the assumptions in a separate task. This avoids blocking the completeness proof while maintaining zero-sorry discipline.

---

## 2. Blocker Analysis

### 2.1 Blocker 1: Freeness (Rigidity)

**Statement**: If `f : T ≃o T` satisfies `f(a) = a` for some `a : T`, then `f = OrderIso.refl`.

**Why it matters**: Freeness is needed for:
- `evalAtOrigin_injective`: injectivity of the map `d -> d.apply origin`, which gives `LinearOrder D` via `LinearOrder.lift`
- Precondition for Holder's theorem (commutativity)

**Mathematical analysis**: The implementation summary correctly notes that rigidity does NOT hold for arbitrary linear orders (e.g., `x -> 2x` on Q fixes 0 but is not identity). The prior research-005 claim that "rigidity holds automatically for connected linear orders without endpoints" is **incorrect**.

However, rigidity DOES hold for the canonical timeline T under an additional condition:

**Condition for rigidity**: T must satisfy that each point is uniquely determined by its "theory" (the set of formulas true there). Formally: if `a.world = b.world` then `a = b` in the BidirectionalFragment (which holds by `BidirectionalFragment.ext`). Since each point in T is an equivalence class of MCSes, an automorphism fixing a point `[M]` must map M to an MCS in the same equivalence class. The key question is whether this constrains the automorphism globally.

**Proof sketch for T**: If `f : T ≃o T` fixes `[M₀]` (the origin), then:
1. For any `[M]` reachable from `[M₀]` in k forward steps, `f([M])` must also be k forward steps from `[M₀]` (order-preservation)
2. If the temporal axioms ensure that the k-th forward element is unique (which holds in the discrete case via SuccOrder), then `f([M]) = [M]`
3. In the dense case, a more delicate argument is needed using the density property

**Difficulty**: Medium-Hard. Provable for specific timeline structures, but requires careful case analysis. The proof likely depends on whether T is discrete, dense, or neither.

**Key Mathlib finding**: `OrderIso.unique_of_wellFoundedLT` shows that if `[WellFoundedLT T]`, then there is exactly one order isomorphism `T ≃o T` (the identity). This is too strong -- our T does not have well-founded `<` (it has no minimum). But it shows Mathlib has related machinery.

### 2.2 Blocker 2: Holder's Theorem (Commutativity)

**Statement**: If a group G acts freely and order-preservingly on a linear order, then G is abelian.

**Why it matters**: `TaskFrame D` requires `AddCommGroup D`.

**Mathematical analysis**: This is a well-known theorem from 1901. The standard proof:
1. Define order on G by `g <= h iff g(x) <= h(x)` for any fixed x (well-defined by freeness)
2. Show this order is bi-invariant: `g <= h implies k + g <= k + h` and `g + k <= h + k`
3. Show bi-invariant total order implies commutativity:
   - WLOG assume `g > 0` and `h > 0`
   - Then `g + h >= h` (left-invariance) and `g + h >= g` (right-invariance)
   - Similarly `h + g >= g` and `h + g >= h`
   - The full argument uses `g + h - h - g` and shows it equals 0

**Mathlib status**: Holder's theorem is NOT in Mathlib as a standalone result. The closest is `MonoidHom.FixedPointFree.commute_all_of_involutive` (fixed-point-free involutive automorphism implies commutativity), which is a different statement.

**Difficulty**: Medium. The mathematical argument is well-understood. The formalization requires building the bi-invariant order and then proving commutativity from bi-invariance. Estimated 100-200 lines of Lean.

**Dependency**: Requires freeness (Blocker 1) as a precondition.

### 2.3 Blocker 3: Homogeneity (Transitivity of Action)

**Statement**: For any `a b : T`, there exists `f : T ≃o T` with `f(a) = b`.

**Why it matters**: Required for `AddTorsor D T` (the `vsub` operation needs to find the unique automorphism mapping one point to another).

**Mathematical analysis**: This is the hardest of the three blockers. Homogeneity is a strong structural property that says "all points look the same."

**When homogeneity holds for T**:
- **Dense case**: If T is a countable dense linear order without endpoints, then T is isomorphic to Q (by `Order.iso_of_countable_dense`), and Q is homogeneous (every order-preserving bijection between finite subsets extends to an automorphism). The back-and-forth argument in `Mathlib.Order.CountableDenseLinearOrder` provides the infrastructure.
- **Discrete case**: If T has a successor function and is isomorphic to Z (by `orderIsoIntOfLinearSuccPredArch`), then homogeneity is trivial (translation by an integer).
- **General case (no density/discreteness)**: Homogeneity is NOT guaranteed. There exist countable linear orders without endpoints that are NOT homogeneous (e.g., Z + Q + Z).

**Critical insight**: The canonical timeline T is built from MCSes by the bidirectional reachability construction. Its order-theoretic properties depend entirely on which temporal axioms are in the logic. The base TM axioms give:
- LinearOrder (proven in BidirectionalReachable.lean)
- Nonempty (root exists)
- Connected (by construction)

But the base axioms do NOT give density or discreteness. Without one of these, homogeneity cannot be proven from the axioms alone.

**Why "axiom uniformity" arguments fail**: Research-005 argued that since temporal axioms are schemata applying uniformly to all formulas, homogeneity should follow. This argument is **insufficient** because:
1. Schema uniformity ensures the *theory* at each point is structurally similar, but does NOT ensure there is an order automorphism between points
2. Two points can have the same "local theory" but different "global positions" in the order
3. A counterexample: consider a linear order that is Z for negative indices and Q for positive indices. Every point satisfies the same local temporal axioms, but there is no automorphism mapping a Z-point to a Q-point.

**Difficulty**: Very Hard. This may be the fundamental mathematical obstacle for this approach.

---

## 3. Alternative Approaches

### Option A: Prove All Three Properties (Direct Attack)

**Approach**: Prove freeness, then Holder's theorem, then homogeneity, all for the specific canonical timeline T.

**Feasibility**:
- Freeness: Likely provable with significant effort (200-400 lines)
- Holder: Medium effort once freeness exists (100-200 lines)
- Homogeneity: Requires additional axioms or structural assumptions about T

**Risk**: Homogeneity may be unprovable without additional temporal axioms. If T is neither discrete nor dense (which the base axioms do not determine), homogeneity fails.

**Verdict**: Blocked on homogeneity unless additional axioms are added.

### Option B: Add Density or Discreteness Axiom

**Approach**: Extend the temporal logic TM with either:
- A discreteness axiom (every point has an immediate successor/predecessor)
- A density axiom (between any two points there is another)

Then use the corresponding Mathlib results:
- Discrete: `orderIsoIntOfLinearSuccPredArch` gives `T ≃o Z`, making D = Z trivially
- Dense: `Order.iso_of_countable_dense` gives `T ≃o Q`, making homogeneity trivial

**Feasibility**:
- Requires formulating the axiom in the proof system
- Requires proving the axiom produces the corresponding property on T
- Both paths have good Mathlib support

**Mathlib highlight**: `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` shows that any Archimedean linearly ordered abelian group is either isomorphic to Z or densely ordered. This means once we have D as a linearly ordered abelian group, we get the dichotomy for free.

**Risk**: Changes the logic TM. Needs to be justified by the JPL paper's framework.

**Verdict**: Viable but invasive. Best done as a separate task after the base construction.

### Option C: Weaken to D = Z (Discrete Time)

**Approach**: Instead of constructing D as the full automorphism group, use `D = Int` with a non-trivial task_rel built from the temporal coherence of the MCS construction.

The current codebase already has `TaskFrame Int` with a trivial `task_rel`. Replace the trivial relation with:
```
task_rel w n w' := there exists a chain of n CanonicalR steps from w to w'
```

**Feasibility**: High. Avoids all three blockers. The chain construction already exists in DovetailingChain.lean (with sorries for F/P witnesses, but those could be fixed using the BidirectionalFragment approach).

**Risk**: Loses generality. The construction would not work for dense time. But for the completeness theorem, Z-time may be sufficient.

**Verdict**: Most pragmatic option for near-term progress.

### Option D: Axiomatic Abstraction (Recommended)

**Approach**: Instead of proving the three properties, ASSUME them as typeclass hypotheses on T and prove completeness conditionally. Then discharge the assumptions in dedicated follow-up tasks.

Specifically, create a typeclass:
```lean
class HomogeneousTimeline (T : Type*) [LinearOrder T] where
  -- The automorphism group acts freely
  aut_free : forall (f : T ≃o T) (a : T), f a = a -> f = OrderIso.refl T
  -- The automorphism group acts transitively
  aut_transitive : forall (a b : T), exists (f : T ≃o T), f a = b
```

Then prove:
1. `HomogeneousTimeline T` implies `AddCommGroup (Additive (T ≃o T))` (Holder)
2. `HomogeneousTimeline T` implies `LinearOrder (Additive (T ≃o T))` (from freeness)
3. `HomogeneousTimeline T` implies `AddTorsor (Additive (T ≃o T)) T` (from transitivity)
4. `HomogeneousTimeline T` implies `TaskFrame (Additive (T ≃o T))` (combines 1-3)

The completeness theorem becomes:
```lean
theorem completeness (T : Type*) [LinearOrder T] [HomogeneousTimeline T] ...
```

**Feasibility**: High. Separates the algebraic infrastructure (which is straightforward given the assumptions) from the hard model-theoretic arguments (which can be tackled independently).

**Risk**: The assumptions may never be discharged if T's homogeneity is unprovable. But this is strictly better than sorry -- the assumptions are explicit, type-checked, and mathematically justified.

**Key advantage**: This follows the standard mathematical practice of proving theorems under hypotheses and then verifying hypotheses separately. It is zero-sorry and does not introduce new axioms.

**Verdict**: Recommended. Clean separation of concerns with no sorry debt.

### Option E: Use Model-Theoretic Back-and-Forth Directly

**Approach**: Instead of proving homogeneity of T as an abstract order, use the specific structure of MCSes to construct automorphisms directly via a back-and-forth argument.

The key idea: given two MCSes M and N in the bidirectional fragment, construct an order automorphism f with f([M]) = [N] by:
1. Enumerate all fragment elements (countable since Formula is countable and MCSes are determined by formulas)
2. Build a partial isomorphism incrementally, mapping [M] to [N]
3. At each step, extend to include the next unmatched element
4. The extension uses the existence lemma (canonical_forward_F, canonical_backward_P) to find matching witnesses

This is essentially the `PartialIso` framework from `Mathlib.Order.CountableDenseLinearOrder`, but applied to T viewed as an automorphism of itself.

**Feasibility**:
- Requires proving T is countable (follows from Formula being countable)
- Requires proving the "extension property" -- that partial isomorphisms can always be extended
- The extension property is where density/discreteness matters

**Critical obstacle**: The extension property for T requires that between any two points, we can always find a matching image. For dense orders, this is the standard back-and-forth. For discrete orders, this is trivial (shift by integer). For general T, this may fail.

**However**: The temporal axioms may provide enough structure for the extension property even without density. Specifically, the `canonical_forward_F` and `canonical_backward_P` lemmas show that for every MCS and every formula, witnesses exist. This could be leveraged to prove the extension property.

**Verdict**: Promising but requires deep analysis. Could be combined with Option D (prove the extension property implies HomogeneousTimeline).

---

## 4. Mathlib Infrastructure Summary

### Available and Directly Useful

| Theorem | Module | Relevance |
|---------|--------|-----------|
| `LinearOrder.lift` | `Mathlib.Order.Basic` | Pull back LinearOrder from T to D via eval |
| `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` | Dense T implies homogeneity |
| `orderIsoIntOfLinearSuccPredArch` | (Mathlib) | Discrete T implies T ≃o Z |
| `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` | `Mathlib.GroupTheory.ArchimedeanDensely` | D is either Z or dense (if Archimedean) |
| `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` | `Mathlib.GroupTheory.ArchimedeanDensely` | Discrete Archimedean group ≃ Z |
| `Additive.addGroup` | `Mathlib.Algebra.Group.TypeTags.Basic` | AddGroup from Group |
| `PartialIso` | `Mathlib.Order.CountableDenseLinearOrder` | Back-and-forth framework |

### Not in Mathlib (Would Need Formalization)

| Result | Difficulty | Lines Est. |
|--------|-----------|------------|
| Holder's theorem (free order-action implies abelian) | Medium | 150-250 |
| Bi-invariant order implies commutativity | Medium | 50-100 |
| Freeness of Aut+(T) for specific T constructions | Hard | 200-400 |
| Homogeneity of specific T constructions | Very Hard | 300-600+ |
| `Countable (BidirectionalFragment M₀ h_mcs₀)` | Medium | 50-100 |
| `Countable (BidirectionalQuotient M₀ h_mcs₀)` | Easy (from above) | 10-20 |

---

## 5. Countability Analysis

A key enabler for several approaches is proving T is countable.

**T = BidirectionalQuotient M₀ h_mcs₀ = Antisymmetrization (BidirectionalFragment M₀ h_mcs₀) (<=)**

To prove T is countable:
1. `Formula` is `Countable` (derived in `Formula.lean`)
2. `Set Formula` is not countable in general, but MCSes are determined by their formula membership
3. `BidirectionalFragment M₀ h_mcs₀` embeds into `Set Formula` via `.world`
4. Need: the image of `.world` is countable

**Argument**: Each element of `BidirectionalFragment` is reachable from `M₀` by finitely many `BidirectionalEdge` steps. Each step uses `canonical_forward_F` or `canonical_backward_P`, which produce witnesses from `ForwardTemporalWitnessSeed` or `BackwardTemporalWitnessSeed` -- sets of the form `{phi} U GContent(M)`. Since `Formula` is countable and each seed is determined by a formula and an MCS, the reachable MCSes form a countable set.

**Formal proof strategy**: Define a surjection from `List Formula` to `BidirectionalFragment` (each list encodes a path of existence-lemma witnesses from the root). Since `List Formula` is countable, so is the fragment.

This is achievable but requires approximately 50-100 lines of Lean code.

---

## 6. Dependency Chain and Recommended Ordering

```
                Countability of T
                      |
                      v
        +-------------+-------------+
        |                           |
   Freeness of                Homogeneity of
   Aut+(T) on T               Aut+(T) on T
        |                           |
        v                           v
   LinearOrder D              AddTorsor D T
        |                           |
        +-------+   +--------------+
                |   |
                v   v
         Holder's Theorem
         (AddCommGroup D)
                |
                v
         IsOrderedAddMonoid D
                |
                v
           TaskFrame D
                |
                v
         Completeness Theorem
```

**Key insight**: Freeness and Homogeneity are independent. Freeness is more tractable. Homogeneity is the critical blocker.

---

## 7. Recommendations

### Primary Recommendation: Option D (Axiomatic Abstraction)

1. Create `HomogeneousTimeline` typeclass with freeness and transitivity
2. Prove `TaskFrame D` assuming `HomogeneousTimeline T` (estimated 300-500 lines)
3. Prove completeness theorem conditionally on `HomogeneousTimeline T`
4. Create follow-up tasks to discharge `HomogeneousTimeline` for:
   - T with a discreteness axiom (gives T ≃o Z, trivial)
   - T with a density axiom (gives T ≃o Q, via back-and-forth)
   - T from base TM axioms (hardest, may require new ideas)

### Secondary Recommendation: Parallel Track with Option C

For near-term completeness proof progress:
1. Use `D = Int` with non-trivial task_rel (chain-based)
2. This gives a working completeness theorem for discrete time immediately
3. Later, generalize via Option D

### Task Decomposition

| Sub-task | Dependency | Difficulty | Priority |
|----------|-----------|------------|----------|
| Define `HomogeneousTimeline` typeclass | None | Easy | 1 |
| Prove Holder's theorem from freeness | HomogeneousTimeline | Medium | 2 |
| Prove `LinearOrder D` from freeness | HomogeneousTimeline | Medium | 2 |
| Prove `AddTorsor D T` from homogeneity | HomogeneousTimeline | Easy | 2 |
| Prove `IsOrderedAddMonoid D` | LinearOrder D | Easy | 3 |
| Assemble `TaskFrame D` | All above | Easy | 4 |
| Prove `Countable T` | None | Medium | 3 |
| Prove freeness for canonical T | Countable T | Hard | 5 |
| Prove homogeneity for canonical T | Countable T + axiom choice | Very Hard | 6 |

---

## 8. Addressing the Implementation Summary's Specific Claims

### Claim: "rigidity holds automatically for connected linear orders"
**Verdict**: INCORRECT. Counterexample: `x -> 2x` on Q fixes 0 but is not identity. The implementation summary (from the previous agent) correctly identified this error. Rigidity requires additional properties beyond connectivity.

### Claim: "Holder's theorem requires freeness + order-preserving action"
**Verdict**: CORRECT. This is the standard statement. Not in Mathlib but well-understood mathematically.

### Claim: "homogeneity requires a back-and-forth argument using uniformity of temporal axioms"
**Verdict**: PARTIALLY CORRECT but INSUFFICIENT. The temporal axiom uniformity provides local uniformity (same theory at each point) but not global uniformity (existence of automorphisms). A genuine back-and-forth argument needs the extension property, which depends on the order-theoretic structure of T (dense vs. discrete vs. neither).

### Claim: "the Mathlib AddTorsor for Additive(alpha ≃o alpha) is unsound"
**Verdict**: This needs clarification. The bug found was about `SMulCommClass (Equiv.Perm (Fin 3))`, which is specific to permutation groups on finite types. The generic `AddTorsor` instance may not exist for `Additive(alpha ≃o alpha)` -- the implementation correctly avoids relying on it. The bug should be verified and reported separately.

---

## 9. Summary of Findings

- **The three blockers (freeness, Holder, homogeneity) form a dependency chain** with homogeneity at the root
- **Homogeneity is the fundamental mathematical obstacle** and cannot be proven from the base TM axioms alone without additional structural assumptions about T
- **The implementation summary's claim about rigidity being automatic is correctly identified as wrong**
- **Option D (axiomatic abstraction via HomogeneousTimeline typeclass) is the recommended approach** -- it maintains zero-sorry discipline while separating the algebraic infrastructure from the hard model theory
- **Mathlib provides good infrastructure** for both the discrete (Z isomorphism) and dense (Q back-and-forth) cases, but not for the general case
- **Countability of T is provable** and enables the back-and-forth machinery
- **Holder's theorem needs approximately 150-250 lines of new formalization** but is mathematically straightforward given freeness
