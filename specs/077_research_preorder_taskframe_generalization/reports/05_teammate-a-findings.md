# Teammate A Findings: Critical Re-Analysis of Task Semantics Under Partial Order D

**Task**: 77 — PreorderTaskFrame Generalization
**Session**: sess_1774981057_4f33e9
**Date**: 2026-03-31
**Focus**: Correcting prior conflation of D (durations) with WorldState (CanonicalMCS)

---

## 1. Executive Summary

The prior research reports contained a fundamental conceptual error: they conflated two entirely distinct components of Task Semantics. This report provides the corrected analysis.

**Critical Correction**:
- **D** = the type of temporal durations (an ordered abelian group like Int, Rat, or any LOAG)
- **WorldState** = the type of world states (in canonical construction: maximal consistent sets)
- **These are NOT the same thing.** The suggestion "D = CanonicalMCS" in prior reports is **mathematically incoherent**.

---

## 2. Correct Component Analysis

### 2.1 TaskFrame Structure (from TaskFrame.lean)

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

**Component roles**:

| Component | Type | Role | Constraints |
|-----------|------|------|-------------|
| `D` | Type* | Duration/time type | AddCommGroup + LinearOrder + IsOrderedAddMonoid |
| `WorldState` | Type | World state type | None (arbitrary type) |
| `task_rel` | WorldState → D → WorldState → Prop | Ternary relation | Three axioms |

The type `D` represents **durations** — the "time" elements that measure how long tasks take. It has algebraic structure (group) and order structure (linear).

The type `WorldState` represents **world states** — the possible configurations of the world. It has NO inherent structure; all structure comes from the `task_rel`.

### 2.2 WorldHistory Structure (from WorldHistory.lean)

```lean
structure WorldHistory {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ (x z : D), domain x → domain z → ∀ (y : D), x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**A WorldHistory is**:
- A function `states : domain → WorldState` from a convex subset of D to world states
- The function respects the task relation: going from time s to time t uses duration t - s

### 2.3 Canonical Construction (from ParametricCanonical.lean)

```lean
def ParametricCanonicalWorldState : Type :=
  { M : Set Formula // SetMaximalConsistent M }

def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then ExistsTask M.val N.val
  else if d < 0 then ExistsTask N.val M.val
  else M = N
```

**Canonical model**:
- `WorldState = ParametricCanonicalWorldState` = maximal consistent sets (MCS)
- `D = Int` (or any totally ordered abelian group)
- The task relation uses `ExistsTask` (g_content inclusion) for positive durations

**Key insight**: D is a PARAMETER to the canonical construction, not derived from it. The same MCS structure works for D = Int, D = Rat, or any other LOAG.

---

## 3. Analysis: What Happens Under Partial Order D?

### 3.1 The Question

If we replace `[LinearOrder D]` with `[Preorder D]` (reflexive + transitive), what changes?

### 3.2 Impact on TaskFrame

The TaskFrame axioms still make sense:
- `nullity_identity`: Zero duration gives identity relation (independent of order)
- `forward_comp`: Composition for non-negative durations (needs 0 ≤ x and 0 ≤ y, which partial orders support)
- `converse`: Negation symmetry (independent of order)

**Issue**: The order structure on D only appears in:
1. The constraint `0 ≤ x` and `0 ≤ y` in `forward_comp`
2. The conditions `d > 0`, `d < 0`, `d = 0` in the canonical task relation

With a partial order:
- `0 ≤ x` is well-defined
- But elements may be **incomparable**: neither d > 0 nor d < 0 nor d = 0

The canonical task relation would need to handle incomparable durations. One natural choice:
```
task_rel M d N :=
  if 0 < d then ExistsTask M N
  else if d < 0 then ExistsTask N M
  else if d = 0 then M = N
  else True  -- incomparable to 0: allow anything
```

### 3.3 Impact on WorldHistory — THE CRITICAL ANALYSIS

The `WorldHistory` structure uses D in two key places:

1. **domain : D → Prop** — a subset of D
2. **convex** — if x ≤ y ≤ z and domain x, domain z, then domain y
3. **respects_task** — for s ≤ t, the states satisfy task_rel with duration t - s

**With partial order D**:

The domain is a subset of D. The convexity constraint says: if two times are in the domain, then all times "between" them are also in the domain.

**Key question**: What does "convex subset" mean in a partial order?

**Standard definition** (same as current): For x ≤ y ≤ z, if x, z ∈ domain then y ∈ domain.

**Semantic meaning with partial order**:
- If D has incomparable elements d₁ || d₂ (neither d₁ ≤ d₂ nor d₂ ≤ d₁)
- A convex domain CAN contain both d₁ and d₂
- No element is "between" d₁ and d₂ (there's no y with d₁ ≤ y ≤ d₂)
- So convexity doesn't force the domain to be a single chain

### 3.4 Tree-Shaped Histories?

**Question**: If D is a partial order with branches, are WorldHistories "tree-shaped"?

**Analysis**:

Consider D = {0, 1a, 1b} with 0 ≤ 1a, 0 ≤ 1b, but 1a || 1b (incomparable).

A WorldHistory τ with domain = {0, 1a, 1b} assigns:
- τ(0) = some world state w₀
- τ(1a) = some world state w₁
- τ(1b) = some world state w₂

The `respects_task` constraint says:
- task_rel w₀ (1a - 0) w₁ must hold (for 0 ≤ 1a)
- task_rel w₀ (1b - 0) w₂ must hold (for 0 ≤ 1b)
- No constraint between w₁ and w₂! (because 1a and 1b are incomparable)

**So YES, histories can span incomparable branches.** A history is NOT required to be a single chain through time. It's a function from a convex subset of D, and convexity with partial orders allows "forking" domains.

### 3.5 Semantic Interpretation

**Linear Order D** (current):
- Time is a line
- Histories are functions from intervals to world states
- Every pair of times is comparable
- G(φ) = "at all future times φ holds" means along a single future direction

**Partial Order D** (proposed BTM):
- Time has branches
- Histories can span multiple branches from a common origin
- Incomparable times represent alternative futures or pasts
- G(φ) = "at all ≥-successors φ holds" means along ALL branches where ≤ applies

### 3.6 Why "D = CanonicalMCS" Was Wrong

The prior report suggested using CanonicalMCS (the set of all maximal consistent sets) as the duration type D. This is incoherent because:

1. **D needs AddCommGroup structure**: You can add, subtract, and negate durations. MCSs don't have a natural group structure.

2. **D is the domain of histories**: A history maps times (elements of D) to world states. If D = MCS, then a history would map MCSs to world states — but MCSs ARE world states in the canonical model!

3. **Semantic nonsense**: Durations represent "how long" tasks take. MCSs represent "what is true". These are categorically different.

**Correct understanding**:
- D = Int (or any LOAG) — the duration type (algebraic + order structure)
- WorldState = CanonicalMCS — the world state type (no inherent structure)

---

## 4. What Would BTM (Branching TM) Actually Look Like?

### 4.1 PreorderTaskFrame Definition

```lean
structure PreorderTaskFrame (D : Type*) [AddCommGroup D] [Preorder D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

The only change from TaskFrame: `[Preorder D]` instead of `[LinearOrder D]`.

### 4.2 Candidate Duration Types

For BTM completeness, what should D be?

**Option A: Product order on Int × Int**
- (a, b) ≤ (c, d) iff a ≤ c and b ≤ d
- Two independent time dimensions
- (1, 0) || (0, 1) — incomparable

**Option B: Subset lattice**
- Elements are finite sets
- Order by inclusion
- Branching via union/intersection

**Option C: Forest structure**
- Trees with explicit branching
- Partial order from ancestor relation

**Issue**: All options need AddCommGroup structure. Only Option A easily has this (coordinate-wise addition).

### 4.3 Canonical Model for BTM

For BTM completeness, we need:
- A canonical D (preorder but not linear order)
- A canonical task_rel on CanonicalMCS
- F-witnesses that don't need to be on the same timeline

**Plausible approach**:
- D = Int × Int with product order
- task_rel M (d₁, d₂) N based on temporal accessibility (like ExistsTask)
- The two dimensions give independent "future directions"

**Alternative**: Keep D = Int but drop the linearity axiom from the proof system. The semantic consequence is that models now include TaskFrames over any preorder D, not just linear orders.

---

## 5. Summary of Corrected Understanding

| Concept | Prior Report (WRONG) | Corrected Understanding |
|---------|---------------------|------------------------|
| D type | "D = CanonicalMCS" | D = ordered abelian group (Int, Rat, etc.) |
| WorldState | Confused with D | Arbitrary type; CanonicalMCS in canonical model |
| WorldHistory | Unclear | Function from convex subset of D to WorldState |
| Tree histories | Unclear | YES: partial order D allows forking histories |
| BTM semantics | Claimed D = MCS | D is preorder LOAG; WorldState = MCS |

---

## 6. Recommendations

1. **DO NOT use "D = CanonicalMCS"** — this is mathematically incoherent.

2. **Define PreorderTaskFrame** as TaskFrame but with `[Preorder D]` instead of `[LinearOrder D]`.

3. **For BTM completeness**, investigate:
   - Keeping D = Int but dropping linearity axiom
   - Using D = Int × Int with product order
   - Abstract characterization: what preordered abelian groups are "canonical" for BTM?

4. **Study tree-shaped histories** explicitly:
   - Formalize forking domain convexity
   - Understand how G and H behave on branches
   - Determine which TM axioms fail for non-linear D

---

## References

**Source Files Examined**:
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/TaskFrame.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/WorldHistory.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Semantics/Truth.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Core/MaximalConsistent.lean`
