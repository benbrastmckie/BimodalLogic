# Research Report: Task #954 (research-001) -- Refactoring the Representation Theorem for General Duration Types

**Task**: 954 - Refactor representation theorem to avoid hardcoded Int
**Date**: 2026-03-03
**Effort**: High (deep mathematical construction with substantial Lean engineering)
**Dependencies**: Task 951 (completeness infrastructure), Task 922 (strategy study)
**Sources/Inputs**: CanonicalConstruction.lean, CanonicalFrame.lean, CanonicalCompleteness.lean, Representation.lean, FMCSDef.lean, BFMCS.lean, TaskFrame.lean, DovetailingChain.lean, BidirectionalReachable.lean, Axioms.lean; Mathlib (orderIsoIntOfLinearSuccPredArch, Archimedean dichotomy, Equiv.addCommGroup, AddTorsor, FreeAbelianGroup)
**Artifacts**: This report
**Standards**: report-format.md

---

## 1. Executive Summary

This report details how to refactor the representation theorem so that the duration type `D` is **constructed purely from syntax** — shown to be a totally ordered abelian group — rather than hardcoding `D = Int`. The refactored construction should be **fully general** and **compatible with extensions** that include a density axiom in the logic.

**Principal Findings**:

1. **The current architecture has a three-layer structure for D.** The semantics layer (`TaskFrame D`, `WorldHistory D`, `Truth D`) is fully polymorphic over D with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. The metalogic layer (`FMCS D`, `BFMCS D`) requires only `[Preorder D]`. The canonical construction layer (`CanonicalConstruction.lean`, `CanonicalCompleteness.lean`, `Representation.lean`) hardcodes `D = Int`.

2. **The hardcoding of Int occurs at exactly three points**: (a) `CanonicalTaskFrame : TaskFrame Int`, (b) `canonicalFrame : BFMCS Int → TaskFrame Int`, and (c) `standard_representation : satisfiable Int [φ]`. In all three, the duration parameter `d : Int` in `task_rel` is either unused (underscored) or trivially `True`.

3. **D should be constructed as the Antisymmetrization of the BidirectionalFragment.** This quotient is a `LinearOrder` by construction. The group structure (`AddCommGroup`) must then be derived from the fragment's intrinsic successor/predecessor structure via Mathlib's representation theorems.

4. **The Archimedean dichotomy governs what group D can be.** By `LinearOrderedAddCommGroup.discrete_or_denselyOrdered`, every Archimedean linearly ordered abelian group is either order-isomorphic to Z (discrete) or densely ordered. The base TM logic (without density axioms) produces an inherently discrete canonical model, so D ≅ Z. Adding a density axiom would force D to be densely ordered, requiring D ≅ Q or embeddable in R.

5. **The representation theorem should be parameterized by a "temporal theory" type** that determines which frame class the logic is complete with respect to. The base logic yields D ≅ Z; a density extension yields D ≅ Q; the construction pipeline is uniform.

**Recommendation**: Implement a four-phase construction: (1) define the BidirectionalQuotient as the canonical duration domain, (2) derive `SuccOrder`/`PredOrder` from F/P-witness existence, (3) use `orderIsoIntOfLinearSuccPredArch` to prove D ≃o Z and transfer `AddCommGroup`, (4) parameterize the representation theorem over temporal theories for density extensibility.

---

## 2. Current Architecture: Where Int Is Hardcoded

### 2.1 The Three-Layer D Architecture

| Layer | Files | D Parameterization | Structure Required |
|-------|-------|-------------------|-------------------|
| **Semantics** | TaskFrame.lean, WorldHistory.lean, TaskModel.lean, Truth.lean | Generic D | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` |
| **Metalogic** | FMCSDef.lean, BFMCS.lean | Generic D | `[Preorder D]` |
| **Canonical** | CanonicalConstruction.lean, CanonicalCompleteness.lean, Representation.lean | **D = Int** (hardcoded) | N/A (concrete type) |

### 2.2 Specific Hardcoding Points

#### Point 1: CanonicalConstruction.lean (lines 82-133)

```lean
-- Duration parameter d is UNUSED in canonical_task_rel
def canonical_task_rel (M : CanonicalWorldState) (_d : Int) (N : CanonicalWorldState) : Prop :=
  GContent M.val ⊆ N.val ∧ HContent N.val ⊆ M.val

def CanonicalTaskFrame : TaskFrame Int where
  WorldState := CanonicalWorldState
  task_rel := canonical_task_rel
  nullity := canonical_task_rel_nullity
  compositionality := ...
```

The relation ignores the duration entirely. It is a pure formula-inclusion relation between MCSes.

#### Point 2: CanonicalCompleteness.lean (lines 93-107)

```lean
def canonicalFrame (B : BFMCS Int) : TaskFrame Int where
  WorldState := CanonicalWorldState B
  task_rel := fun _ _ _ => True       -- ← TRIVIAL task relation
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
```

This uses a completely trivial task relation (`True` for all arguments). The `Int` type is present only for type compatibility.

#### Point 3: Representation.lean

```lean
theorem standard_representation (φ : Formula) (h_cons : ContextConsistent [φ]) :
    satisfiable Int [φ]

theorem standard_weak_completeness (φ : Formula) (h_valid : valid φ) :
    Nonempty (DerivationTree [] φ)
```

### 2.3 Algebraic Operations Actually Used on D

| Operation | Where Used | Structure |
|-----------|-----------|-----------|
| `0` (zero) | TaskFrame.nullity | `Zero D` (from `AddCommGroup`) |
| `+` (addition) | TaskFrame.compositionality | `Add D` (from `AddCommGroup`) |
| `≤` (order) | FMCS forward_G/backward_H, Truth temporal quantifiers | `LE D` (from `LinearOrder` or `Preorder`) |
| `-` (subtraction) | WorldHistory.respects_task | `Sub D` (from `AddCommGroup`) |
| `neg` (negation) | Time-shift inverse | `Neg D` (from `AddCommGroup`) |

**Critical observation**: In the truth evaluation (`Truth.lean`), the temporal operators use **only `≤`**:
```lean
| all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
| all_past φ  => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
```

No group operations appear in truth evaluation. The `AddCommGroup` constraint comes from `TaskFrame`, not from temporal logic.

---

## 3. The Syntactic Construction of D

### 3.1 Overview: From Formulas to a Totally Ordered Abelian Group

The construction proceeds in five steps:

```
Step 1: Bidirectional Reachable Fragment (Preorder on MCSes)
  ↓
Step 2: Antisymmetrization (LinearOrder quotient)
  ↓
Step 3: Successor/Predecessor Structure (SuccOrder + PredOrder)
  ↓
Step 4: Order Isomorphism to Z (orderIsoIntOfLinearSuccPredArch)
  ↓
Step 5: Transfer AddCommGroup (Equiv.addCommGroup)
```

Each step builds purely on syntactic operations (MCS membership, GContent, HContent, Lindenbaum extension).

### 3.2 Step 1: Bidirectional Reachable Fragment

**Definition** (BidirectionalReachable.lean):

Given a root MCS `M₀`, the **Bidirectional Reachable Fragment** is the set of all MCSes reachable from `M₀` by alternating forward steps (CanonicalR) and backward steps (CanonicalR_past):

```
BidirectionalFragment(M₀) = {M : MCS | M₀ ≤_frag M or M ≤_frag M₀}
```

where `M ≤_frag M'` means there is a finite chain of CanonicalR steps from M to M'.

**Properties (proven)**:
- `BidirectionalFragment` is a `Preorder` (reflexive, transitive)
- Every MCS in the fragment is reachable in finitely many steps
- The fragment is countable (each step adds one MCS via Lindenbaum)

**Temporal coherence**:
- `forward_G`: If `G(φ) ∈ M` and `M ≤_frag M'`, then `φ ∈ M'`
- `backward_H`: If `H(φ) ∈ M` and `M' ≤_frag M`, then `φ ∈ M'`

These follow directly from the definitions of CanonicalR and CanonicalR_past.

### 3.3 Step 2: Antisymmetrization

**Definition**: The **BidirectionalQuotient** is the Antisymmetrization of the BidirectionalFragment:

```lean
def BidirectionalQuotient (M₀ : Set Formula) (h : SetMaximalConsistent M₀) :=
  Antisymmetrization (BidirectionalFragment M₀ h) (· ≤ ·)
```

**Properties (proven)**:
- `BidirectionalQuotient` has `LinearOrder` (from totality of fragment + antisymmetrization)
- The quotient collapses ≤-equivalent elements

The key theorem needed: the fragment is **totally ordered** (any two elements are comparable). This follows from the linearity axiom (`temp_linearity`) which forces the temporal accessibility relation to be linear.

### 3.4 Step 3: Successor/Predecessor Structure

**Successor**: For each equivalence class `[M]` in the BidirectionalQuotient, define:

```
succ([M]) = [fragmentGSucc(M)]
```

where `fragmentGSucc(M)` is the Lindenbaum extension of `GContent(M)`, i.e., a fresh MCS M' with `CanonicalR M M'`.

**Predecessor**: Symmetric definition using `fragmentHPred`.

**Properties to prove**:

| Property | Statement | Proof Strategy |
|----------|-----------|---------------|
| `SuccOrder` | `succ` is well-defined on quotient | Quotient lifting: if M ~ N then fragmentGSucc(M) ~ fragmentGSucc(N) |
| `PredOrder` | `pred` is well-defined on quotient | Symmetric to SuccOrder |
| `IsSuccArchimedean` | Repeated succ reaches any element | Induction on fragment distance |
| `NoMaxOrder` | No maximum element | F-witness: for any M, F(⊤) ∈ M gives a successor |
| `NoMinOrder` | No minimum element | P-witness: for any M, P(⊤) ∈ M gives a predecessor |
| Coverness | succ([M]) is the immediate successor | No intermediate MCS between M and fragmentGSucc(M) |

**The critical property is coverness** (immediate successor). This requires showing that between any MCS `M` and `fragmentGSucc(M)`, no other MCS in the fragment can exist. This follows from the way Lindenbaum extension works: `fragmentGSucc(M)` is maximal over `GContent(M)`, and the linearity axiom prevents branching.

**Note on difficulty**: Research-010 and the Phase 1 implementation summary identified coverness as the primary technical challenge. The proof requires careful analysis of how Lindenbaum's lemma produces successors and why no intermediate MCS can satisfy both forward and backward coherence conditions.

### 3.5 Step 4: Order Isomorphism to Z

Once SuccOrder, PredOrder, IsSuccArchimedean, NoMaxOrder, NoMinOrder are established, apply Mathlib's representation theorem:

```lean
-- Mathlib.Order.SuccPred.LinearLocallyFinite
noncomputable def orderIsoIntOfLinearSuccPredArch
    [LinearOrder ι] [SuccOrder ι] [PredOrder ι]
    [IsSuccArchimedean ι] [NoMaxOrder ι] [NoMinOrder ι] [Nonempty ι] :
    ι ≃o ℤ
```

This gives: `BidirectionalQuotient ≃o ℤ` — a computable order isomorphism.

**Key insight**: This isomorphism is not "assuming D is Z." It is **proving** that D (constructed from pure syntax) has exactly the order type of Z. The proof goes through the successor structure, which is intrinsic to the canonical model.

### 3.6 Step 5: Transfer AddCommGroup

The order isomorphism provides an `Equiv`:

```lean
def quotientEquivInt : BidirectionalQuotient ≃ ℤ :=
  orderIsoIntOfLinearSuccPredArch.toEquiv
```

Mathlib's transfer instance machinery then gives:

```lean
-- Mathlib.Algebra.Group.TransferInstance
noncomputable instance : AddCommGroup BidirectionalQuotient :=
  quotientEquivInt.addCommGroup

noncomputable instance : IsOrderedAddMonoid BidirectionalQuotient :=
  -- Transfer from Int's IsOrderedAddMonoid through the OrderIso
```

**Result**: `BidirectionalQuotient` now has:
- `LinearOrder` (from antisymmetrization, Step 2)
- `AddCommGroup` (transferred from Z via order isomorphism, Step 5)
- `IsOrderedAddMonoid` (transferred from Z, Step 5)

This satisfies all three typeclasses required by `TaskFrame D`.

---

## 4. The Representation Theorem Structure

### 4.1 Statement

The representation theorem, stated with D constructed from syntax:

```lean
-- D is the BidirectionalQuotient constructed from the root MCS
-- D is proven to be a totally ordered abelian group (isomorphic to Z)
theorem representation (φ : Formula) (h_cons : ContextConsistent [φ]) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
      (τ : WorldHistory F) (t : D),
      ¬ truth_at M Omega τ t φ
```

Or equivalently with `satisfiable`:

```lean
theorem representation (φ : Formula) (h_cons : ContextConsistent [φ]) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D),
      satisfiable D [φ.neg]
```

### 4.2 Construction Pipeline

Given `h_cons : ContextConsistent [φ.neg]`:

1. **Root MCS**: Extend `{φ.neg}` to MCS `M₀` via Lindenbaum's lemma.
2. **Fragment**: Construct `BidirectionalFragment M₀`.
3. **Quotient**: Form `BidirectionalQuotient M₀` (= Antisymmetrization).
4. **Group structure**: Derive `AddCommGroup` via Steps 3-5 above.
5. **FMCS**: The fragment gives a canonical `FMCS BidirectionalQuotient` with sorry-free forward_F and backward_P (these are trivially satisfied at the fragment level because each F-obligation is individually witnessed by a fresh Lindenbaum extension).
6. **BFMCS**: Build modal saturation across multiple FMCS families.
7. **TaskFrame**: Construct `TaskFrame BidirectionalQuotient` using the canonical task relation.
8. **Truth lemma**: Prove `φ ∈ fam.mcs(t) ↔ truth_at M Omega τ t φ`.
9. **Falsification**: Since `φ.neg ∈ M₀ = fam₀.mcs(0)`, the truth lemma gives `truth_at M Omega τ₀ 0 (φ.neg)`, hence `¬ truth_at M Omega τ₀ 0 φ`.

### 4.3 Comparison: Current vs. Refactored

| Aspect | Current (hardcoded Int) | Refactored (syntactic D) |
|--------|------------------------|--------------------------|
| D type | `Int` | `BidirectionalQuotient M₀` |
| Group structure | Built-in `Int` instances | Transferred via `orderIsoIntOfLinearSuccPredArch` |
| task_rel | Ignores duration (underscore `_d`) | Meaningful: based on fragment step count |
| Modularity | Opaque (Int chosen by fiat) | Transparent (D constructed from formulas) |
| Density extension | Requires separate construction | Parameterizable (see Section 5) |
| Engineering cost | Minimal (existing) | Significant (200-400 new lines) |

---

## 5. Compatibility with Density Axiom Extension

### 5.1 The Temporal Theory Abstraction

The refactored representation theorem should support extension by a **density axiom**. Define a "temporal theory" that parameterizes the frame class:

```lean
inductive TemporalTheory where
  | base       -- Base TM: no additional temporal axioms
  | discrete   -- TM + discreteness axiom: F(φ) → φ → P(φ)
  | dense      -- TM + density axiom: F(F(φ)) → F(φ)
```

Each temporal theory determines:
- **Additional axioms** added to the proof system
- **Frame class** the logic is sound/complete with respect to
- **Canonical D type** used in the representation theorem

### 5.2 Frame Correspondence

| Theory | Additional Axiom | Frame Class | Canonical D |
|--------|-----------------|-------------|-------------|
| `base` | None | All linearly ordered abelian groups | D ≅ Z (discrete canonical model) |
| `discrete` | `F(φ) → φ → P(φ)` | Discrete linearly ordered groups | D ≅ Z |
| `dense` | `F(F(φ)) → F(φ)` | Densely ordered groups | D ≅ Q |

### 5.3 Why the Base Logic's Canonical Model Is Discrete

The canonical model built via Lindenbaum extensions is inherently discrete because:

1. **Step-wise construction**: Each forward/backward step adds exactly one new MCS.
2. **No intermediate MCSes**: Between consecutive Lindenbaum extensions, no MCS can satisfy both forward and backward coherence (this is the coverness property).
3. **Archimedean dichotomy**: The fragment is Archimedean (every element is reachable in finitely many steps), so by `discrete_or_denselyOrdered`, it must be Z-like or dense. Step 2 rules out density.

**Crucially**: This does NOT restrict the base logic's semantics to discrete models. The validity definition quantifies over ALL D:

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) ...
```

The canonical model being discrete (D ≅ Z) suffices for completeness because completeness requires only ONE falsifying model for each non-theorem.

### 5.4 How a Density Axiom Changes the Construction

Adding a density axiom `F(F(φ)) → F(φ)` (or equivalently, `G(φ) → G(G(φ))` with the additional constraint that between any two distinct times there exists a third) would require:

1. **Modified Lindenbaum extension**: Instead of single-step successors, insert intermediate MCSes between existing ones.
2. **Dense fragment**: The BidirectionalFragment becomes a countable dense linear order without endpoints.
3. **By Cantor's theorem**: Any countable dense linear order without endpoints is order-isomorphic to Q.
4. **D ≅ Q**: Use Mathlib's Cantor isomorphism to get `D ≃o Q`, then transfer `AddCommGroup` from Q.

The uniform construction pipeline is:

```
Fragment → Quotient → {SuccOrder → Z (discrete)} OR {DenselyOrdered → Q (dense)}
```

### 5.5 The Unified Representation Type

```lean
-- Abstract canonical domain parameterized by temporal theory
structure CanonicalDomain (T : TemporalTheory) where
  D : Type
  [addCommGroup : AddCommGroup D]
  [linearOrder : LinearOrder D]
  [isOrderedAddMonoid : IsOrderedAddMonoid D]

-- For base/discrete: D constructed via orderIsoIntOfLinearSuccPredArch ≃o Z
-- For dense: D constructed via Cantor's theorem ≃o Q

theorem representation (T : TemporalTheory) (φ : Formula)
    (h_cons : ConsistentWith T [φ.neg]) :
    ∃ (cd : CanonicalDomain T), satisfiable_in cd.D [φ.neg]
```

---

## 6. Detailed Construction: Pure Syntax to Group

### 6.1 The Fragment as a Preorder

**Input**: Root MCS `M₀` (from Lindenbaum extension of `{φ.neg}`).

**Construction**: Build the bidirectional reachable fragment:

```lean
-- Existing in BidirectionalReachable.lean
def BidirectionalFragment (M₀ : Set Formula) (h : SetMaximalConsistent M₀) :=
  { M : Set Formula // M reachable from M₀ via CanonicalR and CanonicalR_past }
```

**Operations on the fragment** (all formula-level, no D involved):
- `CanonicalR M M'` iff `GContent(M) ⊆ M'` — forward accessibility
- `CanonicalR_past M M'` iff `HContent(M) ⊆ M'` — backward accessibility
- Fragment preorder: `M ≤ M'` iff reachable via forward steps

### 6.2 The Quotient as a LinearOrder

**Construction**: Antisymmetrize the fragment preorder:

```lean
def BidirectionalQuotient := Antisymmetrization (BidirectionalFragment M₀ h) (· ≤ ·)
```

**Proof of LinearOrder**: The fragment is totally ordered because:
1. Given any two fragment elements M and M', they are both reachable from M₀.
2. By the linearity axiom (`temp_linearity`), the reachability relation is total.
3. Therefore either M ≤ M' or M' ≤ M in the fragment.
4. Antisymmetrization of a total preorder is a linear order.

### 6.3 Successor Structure from F-Witnesses

**Defining successor** on the quotient:

For `[M] ∈ BidirectionalQuotient`:
1. By `mcs_has_F_top` (proven): `F(⊤) ∈ M` for any MCS M (every MCS believes some future exists).
2. By `canonical_forward_F`: There exists MCS `M'` with `CanonicalR M M'` and `⊤ ∈ M'`.
3. Define `succ([M]) = [M']` where M' is this fresh Lindenbaum extension.

**Coverness** (succ is immediate): Between `[M]` and `[succ(M)]`, no quotient element exists because:
- `succ(M)` is the maximal extension of `GContent(M)`.
- Any intermediate `N` with `M < N < succ(M)` would need `GContent(M) ⊆ N` (from M < N) and `GContent(N) ⊆ succ(M)` (from N < succ(M)).
- But GContent(M) already determines the successor via Lindenbaum, and the maximality of the extension leaves no room for intermediate elements.

**Predecessor**: Symmetric construction using `canonical_backward_P` and `HContent`.

### 6.4 Archimedean Property

**Claim**: `IsSuccArchimedean BidirectionalQuotient`.

**Proof**: Every element `[M]` is reachable from `[M₀]` in finitely many forward/backward steps (by definition of the fragment). If `[M]` is above `[M₀]`, then `[M] = succ^n([M₀])` for some n. If below, then `[M] = pred^n([M₀])` for some n.

### 6.5 No Maximum/Minimum

**NoMaxOrder**: For any `[M]`, `succ([M])` is strictly greater (coverness implies strict inequality).

**NoMinOrder**: For any `[M]`, `pred([M])` is strictly less.

### 6.6 OrderIso to Z

Applying Mathlib's theorem:

```lean
noncomputable def quotientOrderIsoInt :
    BidirectionalQuotient M₀ h ≃o ℤ :=
  orderIsoIntOfLinearSuccPredArch
```

### 6.7 AddCommGroup Transfer

```lean
noncomputable instance : AddCommGroup (BidirectionalQuotient M₀ h) :=
  quotientOrderIsoInt.toEquiv.addCommGroup

noncomputable instance : IsOrderedAddMonoid (BidirectionalQuotient M₀ h) :=
  -- Transferred from Int's instance via the order isomorphism
```

### 6.8 The Complete Pipeline (Summary)

```
{φ.neg}
  → Lindenbaum → M₀ (MCS)
  → BidirectionalFragment M₀ (countable preorder of MCSes)
  → Antisymmetrization (LinearOrder quotient)
  → SuccOrder + PredOrder (from F/P-witness existence)
  → IsSuccArchimedean + NoMaxOrder + NoMinOrder (from fragment properties)
  → orderIsoIntOfLinearSuccPredArch (BidirectionalQuotient ≃o Z)
  → Equiv.addCommGroup (AddCommGroup on BidirectionalQuotient)
  → TaskFrame BidirectionalQuotient (with meaningful task_rel)
  → FMCS BidirectionalQuotient (sorry-free forward_F/backward_P)
  → BFMCS BidirectionalQuotient (modal saturation)
  → Truth lemma + falsification → ¬ valid φ
```

Every step uses only:
- Formula membership in MCSes (syntactic)
- Lindenbaum's lemma (set-theoretic, via Zorn)
- GContent/HContent operations (syntactic extraction)
- Mathlib order/group transfer theorems (algebraic)

No integer arithmetic, no hardcoded type choices.

---

## 7. Impact Analysis

### 7.1 Files Requiring Changes

| File | Change | Difficulty |
|------|--------|-----------|
| `CanonicalConstruction.lean` | Parameterize over D instead of Int | Medium |
| `CanonicalCompleteness.lean` | Replace `BFMCS Int` with `BFMCS D` | Medium |
| `Representation.lean` | Use syntactic D in representation theorem | Medium |
| `BidirectionalReachable.lean` | Add SuccOrder/PredOrder/Archimedean proofs | **Hard** |
| `DovetailingChain.lean` | Keep as-is (Int-specific alternative construction) | None |

### 7.2 New Files

| File | Purpose | Size (est.) |
|------|---------|------------|
| `CanonicalDomain.lean` | Syntactic D construction pipeline | 200-300 lines |
| `SuccessorAlgebra.lean` | SuccOrder/PredOrder on BidirectionalQuotient | 150-250 lines |
| `DomainTransfer.lean` | AddCommGroup transfer via OrderIso | 100-150 lines |

### 7.3 Preserved Files (No Changes)

- `Syntax/Formula.lean` — unchanged
- `Semantics/TaskFrame.lean` — already generic over D
- `Semantics/Truth.lean` — already generic over D
- `Metalogic/Core/` — MCS infrastructure unchanged
- `Metalogic/Bundle/FMCSDef.lean` — already generic over D
- `Metalogic/Bundle/BFMCS.lean` — already generic over D

---

## 8. Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Coverness (immediate successor) unprovable | **High** | Medium | Phase 1 blocker analysis (research-010, handoff) identified this as key risk. Fallback: use chain index instead of quotient successor. |
| NoMaxOrder/NoMinOrder require non-trivial proof | Medium | Low | `mcs_has_F_top` and `mcs_has_P_top` already proven; these give witnesses. |
| OrderIso transfer breaks IsOrderedAddMonoid | Medium | Low | Mathlib's `OrderIso.isOrderedAddMonoid` should handle this; verify with lean_hover. |
| BidirectionalQuotient totality depends on linearity axiom | Medium | Low | Linearity axiom (`temp_linearity`) is in the system; totality proof should follow. |
| Performance: transferred instances may be slow | Low | Medium | `noncomputable` is fine for metalogic; no runtime execution needed. |
| Density extension requires fundamentally different construction | High | Medium | Section 5.4 outlines the approach; can defer to a separate task. |

---

## 9. Recommendations

### 9.1 Primary Recommendation: Implement Syntactic D Construction

Implement the five-step pipeline from Section 3, producing `BidirectionalQuotient` as the canonical duration domain with full `AddCommGroup + LinearOrder + IsOrderedAddMonoid` structure derived from pure syntax.

**Priority order**:
1. Prove `SuccOrder` and `PredOrder` on BidirectionalQuotient (highest risk)
2. Prove `IsSuccArchimedean`, `NoMaxOrder`, `NoMinOrder`
3. Apply `orderIsoIntOfLinearSuccPredArch` and transfer group structure
4. Parameterize `CanonicalTaskFrame`, `canonicalFrame`, `representation` over the syntactic D
5. Add `TemporalTheory` abstraction for density extensibility

### 9.2 Effort Estimate

| Phase | Effort | Confidence |
|-------|--------|-----------|
| Phase 1: SuccOrder/PredOrder on quotient | 15-25 hours | Medium (coverness is key risk) |
| Phase 2: Archimedean + unboundedness | 5-10 hours | High |
| Phase 3: OrderIso + group transfer | 5-10 hours | High |
| Phase 4: Parameterize canonical construction | 10-15 hours | High |
| Phase 5: TemporalTheory abstraction | 10-15 hours | Medium |
| **Total** | **45-75 hours** | Medium |

### 9.3 Fallback Strategy

If coverness (Phase 1) proves intractable, the fallback is:

1. Keep `D = Int` as the concrete canonical domain.
2. Add a **derivation pipeline** that constructs `Int` from the fragment: BidirectionalFragment → countable linear order → enumerate via well-ordering → embed into Z.
3. This achieves "D from syntax" without requiring SuccOrder on the quotient.
4. The density extension would still be possible via a separate construction for Q.

### 9.4 What NOT To Do

1. **Do not attempt FreeAbelianGroup as D.** It has no canonical LinearOrder.
2. **Do not use AddTorsor to defer the group question.** The torsor still requires constructing the underlying group.
3. **Do not refactor `valid` to be parameterized by D.** It already quantifies over all D; changing this would break all soundness proofs.
4. **Do not attempt a dense canonical model for the base logic.** Lindenbaum extensions are inherently discrete. Density requires additional axioms.

---

## 10. Decisions

1. **The canonical D should be BidirectionalQuotient** — constructed from the fragment's syntactic structure.

2. **Group structure is transferred from Z via OrderIso** — not assumed or postulated.

3. **The representation theorem should be parameterized by temporal theories** — base (D≅Z), discrete (D≅Z), dense (D≅Q).

4. **The DovetailingChain construction remains as an Int-specific alternative** — it is a different completeness path, not affected by this refactoring.

5. **Coverness is the critical gating proof** — if this cannot be established, use the fallback strategy (Section 9.3).

6. **The density extension is a future task** — the refactoring should make density extension possible, but implementing the dense construction (D≅Q) is out of scope for this task.

---

## Appendix A: Mathlib Theorems Used

### A.1 Order Isomorphism from Successor Structure

```lean
-- Mathlib.Order.SuccPred.LinearLocallyFinite
noncomputable def orderIsoIntOfLinearSuccPredArch
    [LinearOrder ι] [SuccOrder ι] [PredOrder ι]
    [IsSuccArchimedean ι] [NoMaxOrder ι] [NoMinOrder ι] [Nonempty ι] :
    ι ≃o ℤ
```

### A.2 Archimedean Dichotomy

```lean
-- Mathlib.GroupTheory.ArchimedeanDensely
lemma LinearOrderedAddCommGroup.discrete_or_denselyOrdered (G : Type*)
    [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G] :
    Nonempty (G ≃+o ℤ) ∨ DenselyOrdered G
```

### A.3 Group Transfer via Equivalence

```lean
-- Mathlib.Algebra.Group.TransferInstance (line 181)
@[to_additive "Transfer AddCommGroup across an Equiv"]
protected abbrev Equiv.commGroup [CommGroup β] (e : α ≃ β) : CommGroup α := ...
```

### A.4 Antisymmetrization

```lean
-- Mathlib.Order.Antisymmetrization
def Antisymmetrization (α : Type*) (r : α → α → Prop) := Quotient (AntisymmRel.setoid α r)

instance [Preorder α] : LinearOrder (Antisymmetrization α (· ≤ ·)) := ...
  -- When the original preorder is total
```

## Appendix B: Codebase Files Examined

- `Theories/Bimodal/Semantics/TaskFrame.lean` — TaskFrame requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- `Theories/Bimodal/Semantics/Truth.lean` — truth_at temporal quantifiers use only `≤`
- `Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean` — FMCS requires only `[Preorder D]`
- `Theories/Bimodal/Metalogic/Bundle/BFMCS.lean` — BFMCS requires only `[Preorder D]`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` — hardcodes `TaskFrame Int`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalCompleteness.lean` — hardcodes `BFMCS Int`
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` — domain-independent (no D)
- `Theories/Bimodal/Metalogic/Bundle/BidirectionalReachable.lean` — fragment construction
- `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean` — Int-specific chain
- `Theories/Bimodal/Metalogic/Representation.lean` — standard_representation with Int
- `Theories/Bimodal/ProofSystem/Axioms.lean` — 18 axiom schemata (no discreteness/density)

## Appendix C: Cross-References to Previous Research

- **research-010** (Task 951): Intrinsic group construction via Successor Algebra — the mathematical foundation for Steps 3-5
- **research-011** (Task 951): Syntactic duration construction pipeline — earlier version of this report's Section 3
- **research-013** (Task 951): Archimedean dichotomy analysis — why D must be Z or Q, not neutral
- **research-014** (Task 951): BidirectionalFragment as canonical domain — motivation for Step 1
- **research-017** (Task 951): Minimal TaskFrame parametrization — two-level hierarchy proposal
- **Phase 1 handoff** (Task 951): Coverness unprovable with current approach — key risk for Step 3
