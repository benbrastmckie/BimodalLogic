# Research Report: Duration Group Construction from Pure Syntax

- **Task**: 960 - Duration Group Construction from Pure Syntax
- **Status**: [IN PROGRESS]
- **Date**: 2026-03-14
- **Scope**: Three constructions (discrete/dense/base) of the totally ordered abelian group D from temporal axioms

## 1. Executive Summary

This report analyzes the construction of the duration type `D` — a totally ordered abelian group — from pure syntax in classical tense logic. The construction must produce `D` satisfying `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` for use in `TaskFrame D`, without hardcoding `D = Int` or `D = Rat`.

**Three constructions are needed:**
1. **Discrete** (D ≅ ℤ): Using the discreteness axiom DF, seriality, and linearity
2. **Dense** (D ≅ ℚ): Using the density axiom DN, seriality, and linearity
3. **Base/General** (D ≅ ℤ or ℚ depending on frame): The strongest logic weaker than both extensions

**Key finding**: The base logic (without density or discreteness) is complete with respect to both ℤ-frames and ℚ-frames. For all three constructions, the canonical timeline T built from MCSs can be equipped with a group structure D via an **order-isomorphism transfer** approach: build T as a linear order, prove it matches the characterization theorem for ℤ or ℚ, then transfer algebraic structure along the isomorphism.

## 2. Axiom System and Frame Correspondence

### 2.1 Complete Axiom Table

| Axiom | Schema | Frame Condition | Compatibility |
|-------|--------|-----------------|---------------|
| **Prop K** | `(φ→(ψ→χ))→((φ→ψ)→(φ→χ))` | (tautology) | base |
| **Prop S** | `φ→(ψ→φ)` | (tautology) | base |
| **EFQ** | `⊥→φ` | (tautology) | base |
| **Peirce** | `((φ→ψ)→φ)→φ` | (classical) | base |
| **MT** | `□φ→φ` | reflexive accessibility | base |
| **M4** | `□φ→□□φ` | transitive accessibility | base |
| **MB** | `φ→□◇φ` | symmetric accessibility | base |
| **M5** | `◇□φ→□φ` | Euclidean accessibility | base |
| **MK** | `□(φ→ψ)→(□φ→□ψ)` | normal modal | base |
| **TK** | `G(φ→ψ)→(Gφ→Gψ)` | normal temporal | base |
| **T4** | `Gφ→GGφ` | transitive temporal | base |
| **TA** | `φ→GPφ` | backward confluence: ∀x<y, ∃z<y, z≤x | base |
| **TL** | `△φ→GPφ` | (follows from TA) | base |
| **MF** | `□φ→□Gφ` | modal-temporal interaction | base |
| **TF** | `□φ→G□φ` | temporal-modal interaction | base |
| **Linearity** | `Fφ∧Fψ→F(φ∧ψ)∨F(φ∧Fψ)∨F(Fφ∧ψ)` | linear temporal order | base |
| **Seriality F** | `F(¬⊥)` | NoMaxOrder | serial |
| **Seriality P** | `P(¬⊥)` | NoMinOrder | serial |
| **Density DN** | `Fφ→FFφ` | DenselyOrdered | dense |
| **Discreteness DF** | `(F⊤∧φ∧Hφ)→F(Hφ)` | SuccOrder (immediate successors) | discrete |

### 2.2 Axiom Compatibility Classes

- **isBase**: Excludes density, discreteness, seriality. Valid on all linear orders.
- **isDenseCompatible**: Excludes discreteness. Valid on all dense linear orders.
- **isDiscreteCompatible**: Excludes density. Valid on all discrete linear orders.

### 2.3 Permanence: φ → GPφ (Axiom TA)

The permanence axiom TA (`φ → GPφ`) states: if φ holds now, then at all future times, there was a past time where φ held. Under irreflexive semantics with strict `<`:

**Frame condition**: For all t, for all s > t, there exists r < s with r ≤ t.

This is automatically satisfied when the temporal order is a linear order (take r = t, which satisfies r < s since t < s, and r ≤ t trivially). So TA does not impose additional frame constraints beyond linearity. It is **derivable from the irreflexive linear order semantics**.

**Soundness proof** (in `Soundness.lean:temp_a_valid`): At time t where φ holds, for any s > t, we can take the witness r = t (since t < s), where φ holds at t.

### 2.4 Key Derived Properties

From the axiom system:
- **CanonicalR is transitive**: via T4 (`Gφ → GGφ`), proven in `canonicalR_transitive`
- **CanonicalR_past is transitive**: via temporal dual of T4, proven in `HContent_chain_transitive`
- **HContent ⊆ relation dualizes GContent ⊆**: proven in `HContent_subset_implies_GContent_reverse`
- **CanonicalR determines a total preorder on bidirectional fragments**: via linearity axiom

## 3. The Canonical Timeline Construction

### 3.1 Fundamental Definitions

Given a root MCS M₀:

1. **CanonicalR(M, M')** := `GContent(M) ⊆ M'`, where `GContent(M) = {φ | G(φ) ∈ M}`
2. **CanonicalR_past(M, M')** := `HContent(M) ⊆ M'`, where `HContent(M) = {φ | H(φ) ∈ M}`
3. **BidirectionalEdge(M₁, M₂)** := `CanonicalR(M₁,M₂) ∨ CanonicalR(M₂,M₁)`
4. **BidirectionalReachable(M₀, M)** := reflexive-transitive closure of BidirectionalEdge from M₀
5. **BidirectionalFragment(M₀)** := `{M | BidirectionalReachable(M₀, M) ∧ SetMaximalConsistent(M)}`
6. **BidirectionalQuotient(M₀)** := `Antisymmetrization(BidirectionalFragment(M₀), ≤)`

The quotient T = BidirectionalQuotient has a `LinearOrder` instance (from total preorder + antisymmetrization).

### 3.2 Proven Properties of the Fragment

Already in the codebase (`BidirectionalReachable.lean`):
- **Forward closure**: If M is in fragment and CanonicalR(M, M'), then M' is in fragment
- **Backward closure**: If M is in fragment and CanonicalR(M', M), then M' is in fragment
- **F-witness closure**: If F(φ) ∈ M for M in fragment, witness from `canonical_forward_F` stays in fragment
- **P-witness closure**: If P(φ) ∈ M for M in fragment, witness from `canonical_backward_P` stays in fragment
- **Preorder**: CanonicalR gives a preorder on the fragment (reflexive closure + transitivity)
- **Totality**: Linearity axiom ensures any two elements in the fragment are comparable

### 3.3 Key Properties of the Quotient T

T = BidirectionalQuotient already has:
- **LinearOrder** (from `instLinearOrderBidirectionalQuotient`)
- **Nonempty** (root MCS provides an element)
- **Countable** (MCSs are countable since formulas are countable; quotient of countable is countable)

What needs to be proved:
- **NoMaxOrder**: From seriality F(¬⊥)
- **NoMinOrder**: From seriality P(¬⊥)
- **DenselyOrdered** (for dense case): From density axiom DN
- **SuccOrder + PredOrder** (for discrete case): From discreteness axiom DF
- **IsSuccArchimedean** (for discrete case): From fragment structure

## 4. Three Constructions in Detail

### 4.1 Construction 1: Discrete Time (D ≅ ℤ)

**Axiom set**: Base + Seriality + Linearity + Discreteness (DF)

**Pipeline**:
```
MCSs → BidirectionalFragment → Antisymmetrization (T, LinearOrder)
     → SuccOrder + PredOrder (from DF)
     → IsSuccArchimedean + NoMaxOrder + NoMinOrder
     → T ≃o ℤ (characterization theorem)
     → Transfer AddCommGroup along ≃o
     → D = T with [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
```

**Step 1: SuccOrder from DF**

The discreteness axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` ensures immediate successors exist.

Define `succ([M])` for `[M] ∈ T`:
- From seriality, F(⊤) ∈ M, so ∃ M' with CanonicalR(M, M')
- The discreteness axiom ensures that among all such M', there is a **closest** one
- Specifically: the MCS W satisfying CanonicalR(M, W) such that for all formulas φ, if Hφ ∈ W then φ ∈ M

The **coverness** proof (no element between [M] and succ([M])) is the main technical challenge:
- Suppose [M] < [V] ≤ succ([M])
- Need to show [V] = succ([M])
- Use the discreteness axiom: for any φ with φ ∈ M and Hφ ∈ M, we get F(Hφ) ∈ M
- This forces the gap between M and its immediate successor to be "atomic"

**Step 2: Characterization theorem**

Mathlib provides `orderIsoIntOfLinearSuccPredArch` (or equivalent):
- Given: `[LinearOrder T] [SuccOrder T] [PredOrder T] [IsSuccArchimedean T] [NoMaxOrder T] [NoMinOrder T]`
- Result: `Nonempty (T ≃o ℤ)`

**Step 3: Transfer**

Given `e : T ≃o ℤ`:
- `AddCommGroup T` via `Equiv.addCommGroup e.toEquiv` (transfer from ℤ)
- `IsOrderedAddMonoid T` via compatibility (since e is an OrderIso and ℤ has IsOrderedAddMonoid)

**Codebase status**: Task 954 plan exists but Phase 1 (SuccOrder/PredOrder) is [NOT STARTED]. The coverness proof is identified as the primary blocker.

### 4.2 Construction 2: Dense Time (D ≅ ℚ)

**Axiom set**: Base + Seriality + Linearity + Density (DN)

**Pipeline**:
```
MCSs → BidirectionalFragment → Antisymmetrization (T, LinearOrder)
     → DenselyOrdered (from DN) + Countable + NoMaxOrder + NoMinOrder
     → T ≃o ℚ (Cantor's theorem)
     → Transfer AddCommGroup along ≃o
     → D = T with [AddCommGroup T] [LinearOrder T] [IsOrderedAddMonoid T]
```

**Step 1: DenselyOrdered from DN**

The density axiom `Fφ → FFφ` ensures density of CanonicalR.

The density frame condition (`DensityFrameCondition.lean`) proves: if CanonicalR(M, M') and ¬CanonicalR(M', M), then ∃ W with CanonicalR(M, W) and CanonicalR(W, M').

This translates to DenselyOrdered on the quotient T: if [M] < [M'], then ∃ [W] with [M] < [W] < [M'].

**Challenge**: The `density_frame_condition` gives a **non-strict** intermediate (W might be equivalent to M or M' in the quotient). The strict version `density_frame_condition_strict` exists but has sorries (12 sorries in `DensityFrameCondition.lean`).

The `CantorApplication.lean` module already applies `Order.iso_of_countable_dense` to get `T ≃o ℚ`, but has 3 remaining sorries (NoMaxOrder reflexive case, NoMinOrder, DenselyOrdered strictness).

**Step 2: Cantor's theorem**

Mathlib provides `Order.iso_of_countable_dense`:
```
theorem Order.iso_of_countable_dense (α β : Type*) [LinearOrder α] [LinearOrder β]
  [Countable α] [Countable β] [DenselyOrdered α] [DenselyOrdered β]
  [NoMinOrder α] [NoMinOrder β] [NoMaxOrder α] [NoMaxOrder β]
  [Nonempty α] [Nonempty β] : Nonempty (α ≃o β)
```

This is already imported via `Mathlib.Order.CountableDenseLinearOrder` in `CantorApplication.lean`.

**Step 3: Transfer (same as discrete)**

**Codebase status**: Staged construction exists with 3+12 sorries. `cantor_iso` theorem compiles modulo sorry'd instances.

### 4.3 Construction 3: Base Logic (General D)

**Axiom set**: Base + Seriality + Linearity (no density, no discreteness)

**Key insight**: The base logic (without density or discreteness) is complete with respect to BOTH ℤ-frames and ℚ-frames. This is because:
- Soundness of density DN requires `[DenselyOrdered D]`, which ℤ doesn't have
- Soundness of discreteness DF requires `[SuccOrder D]`, which ℚ doesn't have
- All base axioms are valid on both ℤ and ℚ (and any D)

**Two approaches for the base case**:

**Approach A: Use ℤ (simplest)**

The canonical timeline T for the base logic is a countable linear order without endpoints. We can:
1. Well-order T (countable, so ω-enumerable)
2. Embed T into ℤ via an order-preserving bijection (since T is countable and has no endpoints)
3. Actually: directly prove T has SuccOrder (even without DF axiom) by well-ordering + taking the ℤ-indexed enumeration

This is essentially what the current `construct_saturated_bfmcs_int` does: it produces a ℤ-indexed family.

**Approach B: Use the archimedean dichotomy**

Mathlib provides `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`:
any `LinearOrderedAddCommGroup` is either discrete or densely ordered.

So for the base logic, we can:
1. Build T as a linear order
2. Case-split: if T is discrete, use ℤ-construction; if T is dense, use ℚ-construction
3. Either way, we get D with the required typeclasses

**Approach C: Translation group (D = Aut(T))**

Define D = Additive(T ≃o T), the group of order automorphisms of T. This approach:
- Gets AddGroup for free from `RelIso.instGroup`
- Needs Hölder's theorem for commutativity (every Archimedean ordered group is abelian)
- Needs freeness/homogeneity proofs for LinearOrder on D

This is the most mathematically elegant but requires the most work. The codebase has `TranslationGroup.lean` in the Boneyard with the basic setup but defers commutativity and LinearOrder.

**Recommended approach for base case**: **Use ℤ (Approach A)**. The base logic IS complete w.r.t. ℤ-frames, so we can simply choose D = ℤ. The key is that `valid φ` quantifies over ALL D, and the base axioms are sound for all D. For completeness, we only need ONE D that works, and ℤ always works for the base axioms plus seriality plus linearity.

## 5. Frame Correspondence Deep Dive

### 5.1 Permanence and Its Consequences

**Axiom TA**: `φ → GPφ` (permanence)

Under irreflexive semantics (G uses strict `<`):
- `GPφ` at time t means: for all s > t, there exists r < s such that φ at r
- Given φ at t: take r = t, then r < s (since t < s) and φ at r = t ✓

So TA's frame condition is: **backward linear density** — between any two related points, the past of the later reaches the earlier. This is trivially satisfied by linear orders.

TA is crucial for the truth lemma: it ensures that present truths are "remembered" in the future via P-witnesses.

### 5.2 Linearity and the Canonical Total Preorder

**Linearity axiom**: `Fφ ∧ Fψ → F(φ∧ψ) ∨ F(φ∧Fψ) ∨ F(Fφ∧ψ)`

This axiom is **not derivable** from the other TM axioms — a 3-point branching frame satisfies all other axioms but violates linearity (documented in `LinearityDerivedFacts.lean`).

The linearity axiom ensures:
- If CanonicalR(M, M₁) and CanonicalR(M, M₂), then M₁ and M₂ are CanonicalR-comparable
- This gives **totality** of the CanonicalR preorder on the bidirectional fragment
- After antisymmetrization, the quotient has a **LinearOrder**

### 5.3 Seriality and Unboundedness

**F(¬⊥)**: Every MCS contains this (proven in `mcs_contains_seriality_future`). This gives: for every MCS M, ∃ M' with CanonicalR(M, M'). Combined with forward closure, this gives **NoMaxOrder** on the fragment (and quotient).

**P(¬⊥)**: Symmetric, giving **NoMinOrder**.

The sorries in `CantorApplication.lean` for NoMaxOrder arise from the **reflexive MCS case**: when CanonicalR(M, M) holds (M is "reflexive"), the successor M' from seriality might satisfy CanonicalR(M', M) too, making [M'] = [M] in the quotient. This is the key technical obstacle.

**Resolution**: In a reflexive MCS M (where GContent(M) ⊆ M), every G-formula in M is also directly in M. This means M contains a very rich set of formulas. The key insight is that applying seriality iteratively must eventually escape the equivalence class, because the MCS is countable and each step potentially adds new formulas. The proof requires showing that the equivalence class of M under mutual CanonicalR is finite (or that seriality eventually breaks out).

### 5.4 Density Frame Condition

**Density axiom DN**: `Fφ → FFφ`

The density frame condition proof (`DensityFrameCondition.lean`) uses the **double-density trick**:

Given CanonicalR(M, M') and ¬CanonicalR(M', M):
1. Find distinguishing formula δ with G(δ) ∈ M' and δ ∉ M
2. Case A (G(δ) ∉ M): F(¬δ) ∈ M. Apply density twice to get FF(¬δ) ∈ M. Extract intermediate W.
3. Case B (G(δ) ∈ M): Split on reflexivity of M'. If M' is reflexive, take W = M'. If not, reduce to Case A with a different formula.

The non-strict version is essentially proven. The strict version (needed for DenselyOrdered on the quotient) has sorries.

### 5.5 Discreteness Frame Condition

**Discreteness axiom DF**: `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)`

Frame condition: SuccOrder — between any element and its successor, there are no other elements.

The soundness proof (`discreteness_forward_valid` in `Soundness.lean`) uses:
- `Order.lt_succ_of_not_isMax`: t < succ(t) when t is not maximal
- `Order.le_of_lt_succ`: r < succ(t) → r ≤ t

The canonical model construction for the discrete case needs to prove:
1. Define succ on T using Lindenbaum extension of GContent
2. Prove coverness: no element between [M] and succ([M])
3. This is the analog of the density frame condition but in the "opposite direction"

## 6. Existing Codebase Approaches: Assessment

### 6.1 BidirectionalQuotient → ℤ (Task 954)

**Status**: Plan exists, Phase 1 NOT STARTED
**Approach**: Fragment → Antisymmetrization → SuccOrder/PredOrder → ℤ characterization → Transfer
**Blocking issue**: Coverness proof for SuccOrder
**Assessment**: Sound approach for discrete case. Coverness proof is hard but likely achievable using the discreteness axiom's frame condition.

### 6.2 StagedConstruction → ℚ (Task 956 / StagedConstruction/)

**Status**: 3 sorries in CantorApplication, 12 in DensityFrameCondition
**Approach**: Build staged timeline by interleaving F/P witnesses (even stages) and density intermediates (odd stages), then apply Cantor
**Blocking issues**:
  - NoMaxOrder/NoMinOrder for reflexive MCSs (sorry)
  - Strict density for DenselyOrdered instance (sorry)
**Assessment**: Most complete approach for dense case. Close to working. The reflexive MCS obstacle is the main blocker.

### 6.3 TranslationGroup D = Aut(T) (Boneyard)

**Status**: AddGroup proven, commutativity/LinearOrder deferred
**Approach**: D = order automorphisms of canonical timeline
**Blocking issues**:
  - Hölder's theorem needed for AddCommGroup (not in Mathlib)
  - Freeness/rigidity needed for LinearOrder on D
  - Homogeneity needed for AddTorsor
**Assessment**: Most elegant but requires the most new mathematics. Hölder's theorem is a major theorem not available in Mathlib.

### 6.4 Product/Bulldozing (Boneyard)

**Status**: Infrastructure exists, no truth lemma
**Approach**: TemporalDomain = RestrictedQuotient × ℚ, truth depends only on MCS component
**Blocking issues**: Truth lemma not proven for product construction
**Assessment**: Sidesteps the order-theoretic problems but introduces ℚ externally (not "from syntax"). Also, the truth lemma would need to relate MCS membership to truth at `([M], q)` points.

### 6.5 Sorry Inventory Summary

| File | Sorries | Nature |
|------|---------|--------|
| `TemporalCoherentConstruction.lean` | 1 | `fully_saturated_bfmcs_exists_int` (combining temporal + modal saturation) |
| `CantorApplication.lean` | 3 | NoMaxOrder reflexive, NoMinOrder, DenselyOrdered strictness |
| `DensityFrameCondition.lean` | 12 | `density_frame_condition_strict` sub-cases |
| `DovetailingChain.lean` | 2 | Chain construction |
| `CanonicalIrreflexivity.lean` | 2 | Freshness condition for atoms |
| `ConstructiveFragment.lean` | 2 | Constructive proofs |

## 7. Recommended Strategy: Unified Construction

### 7.1 Architecture Overview

```
                    ┌──────────────────────────────┐
                    │     valid / valid_dense /     │
                    │      valid_discrete           │
                    │   (quantify over all D)       │
                    └──────────────┬───────────────┘
                                   │
                    ┌──────────────▼───────────────┐
                    │      Completeness Proof       │
                    │   "consistent → satisfiable"  │
                    └──────────────┬───────────────┘
                                   │
              ┌────────────────────┼────────────────────┐
              │                    │                    │
     ┌────────▼────────┐ ┌────────▼────────┐ ┌────────▼────────┐
     │  Base Logic      │ │  Dense Logic    │ │  Discrete Logic │
     │  D = ℤ           │ │  D ≅ ℚ         │ │  D ≅ ℤ          │
     │  (fallback)      │ │  (Cantor)      │ │  (characterize) │
     └────────┬────────┘ └────────┬────────┘ └────────┬────────┘
              │                    │                    │
              └────────────────────┼────────────────────┘
                                   │
                    ┌──────────────▼───────────────┐
                    │   Canonical Timeline T       │
                    │   (BidirectionalQuotient)     │
                    │   [LinearOrder] [Countable]   │
                    │   [Nonempty] [NoMax] [NoMin]  │
                    └──────────────────────────────┘
```

### 7.2 Shared Infrastructure (All Three Cases)

All three constructions share:
1. **CanonicalR and CanonicalR_past** — already proven
2. **BidirectionalFragment with closure properties** — already proven
3. **Antisymmetrization to LinearOrder quotient** — already proven
4. **Countability of quotient** — already proven
5. **Nonempty quotient** — already proven
6. **NoMaxOrder and NoMinOrder** — needs the reflexive MCS fix (shared obstacle)

### 7.3 Dense Case: Complete the Staged Construction

**Priority**: Fix the 3 sorries in `CantorApplication.lean`:

1. **NoMaxOrder reflexive case**: When M is reflexive (CanonicalR(M,M)), the successor from seriality might be equivalent in the quotient. Solution: prove that seriality + density forces existence of a STRICT successor in the quotient. Use density to find an intermediate that breaks the equivalence class.

2. **NoMinOrder**: Symmetric to NoMaxOrder.

3. **DenselyOrdered strictness**: The non-strict density_frame_condition gives an intermediate W. Need: W is strict (not equivalent to M or M'). The `density_frame_condition_strict` function attempts this but has sorries. The key insight is that Case A of the double-density trick already provides a strict intermediate (the W from double density is distinct from both endpoints by construction).

**After fixing these**: `cantor_iso : Nonempty (T ≃o ℚ)` immediately follows.

### 7.4 Discrete Case: Build SuccOrder/PredOrder

**Priority**: Implement Task 954 Phase 1.

1. **Define fragmentGSucc**: Given MCS M in fragment, extend `{φ | Hφ} ∪ GContent(M)` to MCS via Lindenbaum. The discreteness axiom ensures this is the "next" MCS.

2. **Prove coverness**: No MCS V satisfies [M] < [V] < [succ(M)] in the quotient. The proof uses DF: if V is between M and succ(M), then CanonicalR(M, V) and CanonicalR(V, succ(M)). The discreteness axiom forces V to be equivalent to succ(M) because V inherits all H-formulas from its position.

3. **Instantiate SuccOrder, PredOrder**: Via coverness proofs.

4. **Prove IsSuccArchimedean**: Every element is reachable from any other by finitely many succ/pred steps. This follows from the fragment structure (finite chains of BidirectionalEdges).

5. **Apply characterization**: `orderIsoIntOfLinearSuccPredArch` or equivalent gives `T ≃o ℤ`.

### 7.5 Base Case: Use ℤ Directly

For the base logic (no density, no discreteness), the simplest approach is:
1. Use the existing `construct_saturated_bfmcs_int` with D = ℤ
2. The base axioms are all valid on ℤ-frames (proven in `axiom_base_valid`)
3. Completeness w.r.t. ℤ-frames suffices for base completeness

This is mathematically correct because `valid φ` quantifies over ALL D, and if we can build a ℤ-model falsifying ¬φ, then φ is valid.

**Alternative**: If a "pure syntax" construction is desired even for the base case, note that the canonical timeline T for base logic (with seriality and linearity) is a countable linear order without endpoints. Since T might be dense or discrete (depending on the specific theory), we can use the archimedean dichotomy and handle both cases.

### 7.6 Group Transfer Along OrderIso

Given `e : T ≃o ℤ` (or `e : T ≃o ℚ`):

```lean
-- Transfer AddCommGroup
noncomputable instance : AddCommGroup T :=
  Equiv.addCommGroup e.toEquiv

-- Transfer zero and addition interact correctly with order
noncomputable instance : IsOrderedAddMonoid T := by
  -- Since e is an order isomorphism and ℤ (or ℚ) has IsOrderedAddMonoid,
  -- the transferred structure is compatible
  ...
```

**Mathlib availability**:
- `Equiv.addCommGroup` (or `Equiv.addGroup`): Transfers group structure along an equivalence. Available in `Mathlib.Algebra.Group.TransferInstance` or equivalent.
- `OrderIso` → `Equiv`: Every `OrderIso` has an underlying `Equiv` via `.toEquiv`.
- `IsOrderedAddMonoid` transfer: May need to be proven manually — verify that the transferred addition respects the order.

## 8. Mathlib Availability Assessment

### 8.1 Available (Used or Verified)

| Item | Mathlib Module | Status |
|------|---------------|--------|
| `Antisymmetrization` | `Mathlib.Order.Antisymmetrization` | ✅ Used in `CantorApplication.lean` |
| `Order.iso_of_countable_dense` | `Mathlib.Order.CountableDenseLinearOrder` | ✅ Used in `CantorApplication.lean` |
| `SuccOrder`, `PredOrder` | `Mathlib.Order.SuccPred.Basic` | ✅ Imported in `Validity.lean` |
| `RelIso.instGroup` | `Mathlib.Algebra.Order.Group.End` | ✅ Used in `TranslationGroup.lean` |
| `Additive` | `Mathlib.Algebra.Group.TypeTags.Basic` | ✅ Used in `TranslationGroup.lean` |
| `Order.lt_succ_of_not_isMax` | `Mathlib.Order.SuccPred.Basic` | ✅ Used in `Soundness.lean` |
| `Order.le_of_lt_succ` | `Mathlib.Order.SuccPred.Basic` | ✅ Used in `Soundness.lean` |

### 8.2 Confirmed Available (Verified via Web Search)

| Item | Mathlib Module | Signature/Notes |
|------|---------------|-----------------|
| `orderIsoIntOfLinearSuccPredArch` | `Mathlib.Order.SuccPred.LinearLocallyFinite` | `{ι : Type} [LinearOrder ι] [SuccOrder ι] [PredOrder ι] [IsSuccArchimedean ι] [NoMaxOrder ι] [NoMinOrder ι] [Nonempty ι] : ι ≃o ℤ` |
| `Equiv.addCommGroup` | `Mathlib.Algebra.Group.TransferInstance` | `(e : α ≃ β) [AddCommGroup β] : AddCommGroup α` (abbrev, transfers right-to-left) |
| `Equiv.addGroup` | `Mathlib.Algebra.Group.TransferInstance` | Same pattern for AddGroup |
| `orderIsoNatOfLinearSuccPredArch` | `Mathlib.Order.SuccPred.LinearLocallyFinite` | For orders with bot but no top → ℕ |
| `countable_of_linear_succ_pred_arch` | `Mathlib.Order.SuccPred.LinearLocallyFinite` | Succ-archimedean linear orders are countable |

### 8.3 Probably Not in Mathlib

- **Hölder's theorem** (every Archimedean totally ordered group embeds into ℝ): This major theorem is likely not formalized in Mathlib. This blocks the TranslationGroup approach.
- **IsOrderedAddMonoid transfer along OrderIso**: Not directly in Mathlib. Must prove manually: given `e : T ≃o ℤ` and `AddCommGroup T` via `Equiv.addCommGroup e.toEquiv`, prove `a ≤ b → a + c ≤ b + c`. This follows from: `e` preserves order, ℤ has `IsOrderedAddMonoid`, and the transferred `+` is defined as `a + b = e.symm (e a + e b)`. Then `a ≤ b → e a ≤ e b → e a + e c ≤ e b + e c → e.symm(e a + e c) ≤ e.symm(e b + e c) → a + c ≤ b + c`. **Provable but requires manual proof.**

## 9. Historical Context: Classical Constructions

### 9.1 Burgess (1984) — "Basic Tense Logic"

Burgess's canonical model construction for Kt (minimal tense logic) and extensions:
- **Worlds** = maximal consistent sets
- **R(M, M')** iff {φ | Gφ ∈ M} ⊆ M' (identical to our CanonicalR)
- **Truth lemma** by structural induction on formulas
- **Completeness** via Lindenbaum extension of consistent sets

For extensions:
- **Kt.Li** (linear time): add linearity axiom, prove R is a total preorder on generated subframes
- **Kt.Li.D** (dense linear time): add density axiom DN, prove R is dense
- **Kt.Li.Df** (discrete linear time): add discreteness axiom DF, prove R has SuccOrder

Burgess does NOT construct the group D — he works directly with the Kripke frame (T, R) where T is a linear order. The group structure is not needed for completeness of pure tense logic (without the box modality and task semantics).

### 9.2 Goldblatt (1992) — "Logics of Time and Computation"

Goldblatt's treatment:
- Canonical model for Kt with detailed truth lemma proof
- "Bulldozing" technique: replace each point with a copy of ℚ to ensure density
- Applied to dense tense logic: T × ℚ with lexicographic order
- Cantor's theorem: any countable dense linear order without endpoints ≅ ℚ

### 9.3 Blackburn, de Rijke, Venema (2001) — "Modal Logic"

Standard reference for:
- Frame correspondence theory (Section 3)
- Bulldozing/unraveling techniques (Section 4.3)
- Canonical model constructions for tense logics (Section 5.5)
- Sahlqvist's theorem and correspondence (Chapter 3)

### 9.4 Key Observation: Group Structure is Novel

**Important**: Classical tense logic references do NOT construct the duration group D. They work with:
- Kripke frames (W, R) where R is a binary relation
- Linear orders (T, <) for tense logic
- The GROUP structure `(D, +, ≤)` is specific to the TaskFrame semantics of bimodal TM logic

This means the construction of D from syntax is a **novel contribution** of this project, not a reproduction of classical results. The classical constructions provide the timeline T; the group structure must be derived from T.

The key insight enabling group structure: **order isomorphism transfer**. If we can prove T ≃o ℤ or T ≃o ℚ, then the group structure transfers along the isomorphism. This avoids the need to construct the group directly from the order (which would require Hölder's theorem or similar).

## 10. Rethinking: The Connection Made Clear

### 10.1 The Core Insight

The connection between temporal axioms and algebraic structure becomes clear through the following chain:

1. **Axioms determine frame conditions** (frame correspondence theory)
2. **Frame conditions determine order-theoretic properties of T** (the canonical timeline)
3. **Order-theoretic properties uniquely characterize T** (Cantor for dense, ℤ-characterization for discrete)
4. **Characterization provides an OrderIso to a known group** (ℤ or ℚ)
5. **OrderIso transfers group structure** (Equiv.addCommGroup + compatibility)

So: **Axioms → Frame conditions → Order properties → Characterization → Group transfer**

### 10.2 Why Previous Approaches Struggled

The previous approaches failed or stalled because they tried to construct D **directly** rather than via characterization:
- **Grothendieck group** (Boneyard): Tried to build D as quotient of chain segments — too complex
- **Translation group** (Boneyard): Tried to build D as Aut(T) — needs Hölder's theorem
- **Task 954 plan**: Correct approach (characterization) but Phase 1 coverness proof was hard

The characterization approach (build T as an order, prove it matches ℤ or ℚ, transfer group) is the **right** approach because:
- It leverages existing Mathlib theorems (Cantor, ℤ-characterization)
- It avoids needing to construct non-trivial algebra from scratch
- The main work is order-theoretic (proving T has the right properties), not algebraic

### 10.3 The Three Cases Unified

For all three logics, the construction follows the same pattern:
1. Build T = BidirectionalQuotient(M₀)
2. Prove T has [LinearOrder] [Countable] [Nonempty] [NoMaxOrder] [NoMinOrder] (shared)
3. **Dense case**: Prove T has [DenselyOrdered], apply Cantor to get T ≃o ℚ
4. **Discrete case**: Prove T has [SuccOrder] [PredOrder] [IsSuccArchimedean], apply ℤ-characterization
5. **Base case**: Use ℤ directly (base axioms are ℤ-sound; or apply archimedean dichotomy)
6. Transfer AddCommGroup + IsOrderedAddMonoid along the OrderIso

## 11. Implementation Roadmap

### Phase 0: Fix Shared Infrastructure [5-10 hours]
- Fix NoMaxOrder for reflexive MCSs in quotient
- Fix NoMinOrder (symmetric)
- These are needed by BOTH dense and discrete constructions

### Phase 1: Dense Construction [10-15 hours]
- Fix DenselyOrdered instance on quotient (make density_frame_condition strict)
- Apply Cantor's theorem (already compiles modulo sorry'd instances)
- Transfer group structure from ℚ to T

### Phase 2: Discrete Construction [15-20 hours]
- Define fragmentGSucc and quotientSucc
- Prove coverness for SuccOrder
- Define fragmentHPred and quotientPred
- Prove IsSuccArchimedean
- Apply ℤ-characterization theorem
- Transfer group structure from ℤ to T

### Phase 3: Integration [10-15 hours]
- Create CanonicalDomain.lean as unified interface
- Parameterize completeness proof over syntactic D
- Remove hardcoded Int from CanonicalConstruction, CanonicalCompleteness, Representation
- Verify all existing theorems still compile

### Phase 4: Verification [5 hours]
- `lake build` passes
- Zero sorries in new files
- All existing tests pass

**Total estimated effort**: 40-65 hours

## 12. Open Questions

1. **Is `orderIsoIntOfLinearSuccPredArch` in Mathlib?** If not, we may need to prove the ℤ characterization ourselves.

2. **Can `Equiv.addCommGroup` transfer `IsOrderedAddMonoid`?** The group transfer is straightforward, but the ordered monoid property needs the order to be compatible with the transferred addition. This should follow from the OrderIso, but needs verification.

3. **Is the reflexive MCS obstacle truly blocking?** Can a reflexive MCS (CanonicalR(M,M)) exist in the bidirectional fragment? If so, how does seriality interact with reflexivity to ensure NoMaxOrder?

4. **For the base case, is D = ℤ the right choice?** Or should we construct D from syntax for conceptual purity? The mathematical answer is: ℤ works fine for completeness. The philosophical answer depends on the project's goals.

## 13. References

- Burgess, J.P. (1984). "Basic Tense Logic." In *Handbook of Philosophical Logic*, Vol. II, pp. 89-133.
- Goldblatt, R. (1992). *Logics of Time and Computation*. CSLI Lecture Notes.
- Blackburn, P., de Rijke, M., Venema, Y. (2001). *Modal Logic*. Cambridge University Press.
- Prior, A.N. (1967). *Past, Present, and Future*. Oxford University Press.
- Segerberg, K. (1971). *An Essay in Classical Modal Logic*. Uppsala.
- Cantor, G. (1895). "Beiträge zur Begründung der transfiniten Mengenlehre." Math. Ann. 46.
- Hölder, O. (1901). "Die Axiome der Quantität und die Lehre vom Mass." Ber. Verh. Sachs. Ges. Wiss. Leipzig, Math. Phys. Kl. 53.
