# Semantics Temporal Order Generalization - Research Report

**Date**: 2025-12-04
**Workflow**: lean-plan (Research and Planning)
**Complexity**: 3 (Medium-High)
**Status**: COMPLETE

---

## Executive Summary

This report provides a systematic comparison between Logos's current semantic definitions and the JPL paper "The Perpetuity Calculus of Agency" (§app:TaskSemantics). The key finding is that Logos uses `Int` (integers) as the temporal domain, while the paper defines a general **totally ordered abelian group** `T = ⟨T, +, ≤⟩`. This generalization enables broader applicability (rational/real time, bounded systems) without compromising correctness.

**Key Findings**:
1. **Current Implementation**: Uses `Int` for temporal order (specific abelian group)
2. **Paper Specification**: Uses arbitrary totally ordered abelian group `T`
3. **Mathlib Support**: `LinearOrderedAddCommGroup` typeclass provides exact match
4. **Impact**: Generalizing to typeclass enables rational/real time, bounded domains
5. **Effort Estimate**: 30-45 hours for full generalization across 5 modules

**Recommendation**: Generalize temporal domain to `LinearOrderedAddCommGroup` typeclass for alignment with paper specification and increased expressivity.

---

## 1. Paper Specification Analysis

### 1.1 Formal Definitions from JPL Paper

#### Task Frame Definition (def:frame, line 1835)

```latex
\begin{Ddef} \label{def:frame}
  A \textit{frame} is a structure F = ⟨W, T, ⇒⟩ where:
  \begin{enumerate}
    \item[World States:] A nonempty set of world states W.
    \item[Temporal Order:] A totally ordered abelian group T = ⟨T, +, ≤⟩.
    \item[Task Relation:] A parameterized task relation ⇒ satisfying:
      \begin{itemize}
        \item[Nullity:] w ⇒_0 w.
        \item[Compositionality:] If w ⇒_x u and u ⇒_y v, then w ⇒_{x + y} v.
      \end{itemize}
  \end{enumerate}
\end{Ddef}
```

**Paper's Temporal Order Requirements**:
- **Group Structure**: Closed under addition, associative, identity element 0, inverses
- **Abelian**: Commutative addition (x + y = y + x)
- **Totally Ordered**: For any x, y ∈ T, either x ≤ y or y ≤ x
- **Order-Preserving**: If x ≤ y, then x + z ≤ y + z for all z

**Paper Examples** (line 667):
> "Paradigm examples of abundant models identify T with either the set of integers ℤ, rational numbers ℚ, or real number ℝ."

#### World History Definition (def:world-history, line 1849)

```latex
\begin{Ddef} \label{def:world-history}
  A \textit{world history} over a frame F = ⟨W, T, ⇒⟩ is a function τ: X → W
  where X ⊆ T is convex and τ(x) ⇒_y τ(x + y) for all times x, y ∈ T
  where both x, x + y ∈ X. The set of all world histories over F is denoted H_F.
\end{Ddef}
```

**Key Properties**:
- Domain X ⊆ T must be **convex** (if x, z ∈ X and x ≤ y ≤ z, then y ∈ X)
- History respects task relation: `τ(x) ⇒_y τ(x + y)` for all x, x+y in domain
- Task relation parameter is **duration** y (element of group T)

#### Truth Evaluation (def:BL-semantics, lines 1857-1866)

```latex
\begin{Ddef} \label{def:BL-semantics}
  Truth in a model at a world history and time is defined recursively:
  \begin{enumerate}
    \item[(p_i)] M,τ,x ⊨ p_i iff x ∈ dom(τ) and τ(x) ∈ |p_i|.
    \item[(⊥)] M,τ,x ⊭ ⊥.
    \item[(→)] M,τ,x ⊨ φ → ψ iff M,τ,x ⊭ φ or M,τ,x ⊨ ψ.
    \item[(□)] M,τ,x ⊨ □φ iff M,σ,x ⊨ φ for all σ ∈ H_F.
    \item[(Past)] M,τ,x ⊨ Past φ iff M,τ,y ⊨ φ for all y ∈ T where y < x.
    \item[(Future)] M,τ,x ⊨ Future φ iff M,τ,y ⊨ φ for all y ∈ T where x < y.
  \end{enumerate}
\end{Ddef}
```

**Critical Semantic Point**: Past/Future quantify over times y **in the temporal order T**, not just in the history's domain. The condition `y ∈ dom(τ)` is implicit (truth undefined at times outside domain).

---

## 2. Logos Implementation Analysis

### 2.1 Current Implementation Summary

| Module | Temporal Type | Status |
|--------|--------------|--------|
| TaskFrame.lean | `Int` (hardcoded) | Lines 65-84 |
| WorldHistory.lean | `Int` (hardcoded) | Lines 57-76 |
| TaskModel.lean | Inherits from TaskFrame | No temporal refs |
| Truth.lean | Uses `Int` from WorldHistory | Lines 104-111 |
| Validity.lean | Uses `Int` from Truth | Lines 45-68 |

### 2.2 TaskFrame.lean (Current Implementation)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/TaskFrame.lean`

```lean
structure TaskFrame where
  /-- Type of world states -/
  WorldState : Type
  /-- Task relation: task_rel w x u means u is reachable from w by task of duration x -/
  task_rel : WorldState → Int → WorldState → Prop
  /-- Nullity constraint: zero-duration task is identity -/
  nullity : ∀ w, task_rel w 0 w
  /-- Compositionality constraint: tasks compose with time addition -/
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Discrepancies from Paper**:
1. **Temporal Type**: Uses `Int` directly instead of polymorphic group type
2. **Documentation** (line 39): Claims "Int is sufficient for MVP" but acknowledges generalization needed
3. **Missing**: Total order constraint not explicitly stated (implicit in Int)
4. **Missing**: Abelian group axioms not explicitly verified (implicit in Int)

**Alignment Verification** (lines 21-25):
> "- Int with addition forms an abelian group (required by paper)"

This is **correct** but **incomplete**: Int is a *specific* abelian group, not the general case.

### 2.3 WorldHistory.lean (Current Implementation)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/WorldHistory.lean`

```lean
structure WorldHistory (F : TaskFrame) where
  /-- Domain predicate (which times are in the history) -/
  domain : Int → Prop
  /-- State assignment function -/
  states : (t : Int) → domain t → F.WorldState
  /-- Task relation respect constraint -/
  respects_task : ∀ (s t : Int) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**Discrepancies from Paper**:
1. **Temporal Type**: Uses `Int` for times, not polymorphic group
2. **Domain Representation**: Uses `Int → Prop` instead of `Set T`
3. **Convexity**: NOT ENFORCED (documented as "simplified for MVP" at line 38)
4. **Constraint Form**: Uses `s ≤ t` and `t - s` (subtraction) instead of general group operations

**Documentation Note** (lines 34-39):
> "For MVP, we simplify the world history structure to avoid Mathlib dependencies
> - Domain is represented as a predicate on Int
> - Convexity is simplified for MVP (not formally enforced)"

This is a **critical limitation**: The paper requires convex domains, Logos does not enforce this.

### 2.4 Truth.lean (Current Implementation)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Truth.lean`

```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t) :
    Formula → Prop
  | Formula.atom p => M.valuation (τ.states t ht) p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t ht φ → truth_at M τ t ht ψ
  | Formula.box φ => ∀ (σ : WorldHistory F) (hs : σ.domain t), truth_at M σ t hs φ
  | Formula.past φ => ∀ (s : Int) (hs : τ.domain s), s < t → truth_at M τ s hs φ
  | Formula.future φ => ∀ (s : Int) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

**Alignment with Paper**:
- ✓ **Atom**: Matches `x ∈ dom(τ) and τ(x) ∈ |p_i|` (domain proof required)
- ✓ **Bot**: Matches `M,τ,x ⊭ ⊥` (always False)
- ✓ **Imp**: Matches material conditional definition
- ✓ **Box**: Matches `∀ σ ∈ H_F` quantification
- ✓ **Past**: Matches `∀ y ∈ T where y < x` with domain restriction
- ✓ **Future**: Matches `∀ y ∈ T where x < y` with domain restriction

**Temporal Semantics Verification** (lines 24-34):
The documentation correctly notes that Past/Future quantify over times in the **same history's domain**, matching the paper's specification with implicit domain restriction.

**Critical Observation**: The current implementation is **semantically correct** for Int, but the quantification `∀ (s : Int)` would need to become `∀ (s : T)` for generalization.

### 2.5 Validity.lean (Current Implementation)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Validity.lean`

```lean
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t),
    truth_at M τ t ht φ
```

**Discrepancy from Paper**:
- Uses `t : Int` instead of `t : T` for time parameter
- Otherwise correctly quantifies over all frames, models, histories

---

## 3. Mathlib Typeclass Analysis

### 3.1 LinearOrderedAddCommGroup

**Search Results** (lean_leansearch):

```lean
class LinearOrderedAddCommGroup (α : Type u) extends OrderedAddCommGroup α, LinearOrder α

-- Properties:
- toOrderedAddCommGroup : OrderedAddCommGroup α  -- Abelian group with order
- le_total : ∀ (a b : α), a ≤ b ∨ b ≤ a        -- Total order
- add_le_add_left : ∀ a b, a ≤ b → ∀ c, c + a ≤ c + b  -- Order-preserving
```

**Perfect Match with Paper**:
1. ✓ **Abelian Group**: Via `AddCommGroup` parent
   - Closed under addition
   - Associative: `(a + b) + c = a + (b + c)`
   - Identity: `0 + a = a`
   - Inverses: `a + (-a) = 0`
   - Commutative: `a + b = b + a`

2. ✓ **Total Order**: Via `LinearOrder` parent
   - `le_total : ∀ a b, a ≤ b ∨ b ≤ a`

3. ✓ **Order-Preserving Addition**: Via `OrderedAddCommGroup`
   - `add_le_add_left : ∀ a b, a ≤ b → ∀ c, c + a ≤ c + b`

**Mathlib Module**: `Mathlib.Algebra.Order.Group.Defs`

### 3.2 Standard Instances

Mathlib provides `LinearOrderedAddCommGroup` instances for:
- `Int` (integers)
- `Rat` (rational numbers)
- `Real` (real numbers)

**Implication**: Generalizing to `LinearOrderedAddCommGroup` enables:
1. **Integer time**: `Int` (current Logos implementation)
2. **Rational time**: `Rat` (dense temporal structures)
3. **Real time**: `Real` (continuous time physics models)
4. **Custom groups**: User-defined temporal structures

---

## 4. Detailed Discrepancy Analysis

### 4.1 Critical Discrepancies

| Component | Logos | JPL Paper | Impact |
|-----------|-------------|-----------|---------|
| **Temporal Type** | `Int` (hardcoded) | `T : Type` (polymorphic) | HIGH - Limits expressivity |
| **Frame Time** | `task_rel : WorldState → Int → WorldState → Prop` | `task_rel : WorldState → T → WorldState → Prop` | HIGH - Hardcodes integers |
| **History Domain** | `Int → Prop` | `Set T` | MEDIUM - Representational difference |
| **Convexity** | NOT ENFORCED | REQUIRED | HIGH - Soundness issue |
| **Truth Quantification** | `∀ (s : Int)` | `∀ (s : T)` | HIGH - Type mismatch |

### 4.2 Alignment Successes

| Component | Status | Notes |
|-----------|--------|-------|
| **Nullity** | ✓ ALIGNED | `∀ w, task_rel w 0 w` matches paper |
| **Compositionality** | ✓ ALIGNED | `task_rel w x u → task_rel u y v → task_rel w (x+y) v` matches |
| **Truth Semantics** | ✓ ALIGNED | All 6 operators match paper definitions |
| **Validity** | ✓ ALIGNED | Quantification structure matches paper |
| **Time-Shift** | ✓ ALIGNED | `time_shift σ Δ` infrastructure matches paper lem:history-time-shift-preservation |

### 4.3 Convexity Issue (Critical)

**Paper Requirement** (def:world-history, line 1850):
> "X ⊆ T is convex"

**Mathematical Definition**: A set X ⊆ T is convex if:
```
∀ x, z ∈ X, ∀ y ∈ T, x ≤ y ≤ z → y ∈ X
```

**Logos Status** (WorldHistory.lean:38):
> "Convexity is simplified for MVP (not formally enforced)"

**Soundness Impact**:
- **LOW for Int**: Integer predicates are typically convex in practice
- **MEDIUM for general groups**: Non-convex domains could break temporal semantics
- **HIGH for correctness**: Paper assumes convexity for key lemmas (e.g., lem:history-time-shift-preservation)

**Recommendation**: Add convexity constraint when generalizing to typeclass.

---

## 5. Generalization Implementation Plan

### 5.1 Phase 1: TaskFrame Generalization (8-12 hours)

**Goal**: Parameterize TaskFrame by temporal group type

**File**: `Logos/Semantics/TaskFrame.lean`

**Changes**:
```lean
-- BEFORE (current)
structure TaskFrame where
  WorldState : Type
  task_rel : WorldState → Int → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v

-- AFTER (generalized)
structure TaskFrame (T : Type*) [LinearOrderedAddCommGroup T] where
  WorldState : Type
  task_rel : WorldState → T → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v (x y : T),
    task_rel w x u → task_rel u y v → task_rel w (x + y) v
```

**Action Items**:
1. Add type parameter `T` to `TaskFrame`
2. Add typeclass constraint `[LinearOrderedAddCommGroup T]`
3. Replace all `Int` occurrences with `T`
4. Update example frames (`trivialFrame`, `identityFrame`, `natFrame`)
5. Update docstrings to reference paper definition
6. Run `lake build` and fix errors

**Breaking Changes**:
- All downstream modules must update `TaskFrame` → `TaskFrame T`
- Type inference may require explicit `T` parameters in some contexts

**Estimated Effort**: 8-12 hours (including downstream fixes)

### 5.2 Phase 2: WorldHistory Generalization (10-15 hours)

**Goal**: Parameterize WorldHistory by temporal group, add convexity constraint

**File**: `Logos/Semantics/WorldHistory.lean`

**Changes**:
```lean
-- BEFORE (current)
structure WorldHistory (F : TaskFrame) where
  domain : Int → Prop
  states : (t : Int) → domain t → F.WorldState
  respects_task : ∀ (s t : Int) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)

-- AFTER (generalized with convexity)
structure WorldHistory {T : Type*} [LinearOrderedAddCommGroup T] (F : TaskFrame T) where
  domain : T → Prop
  convex : ∀ (x z : T), domain x → domain z →
           ∀ (y : T), x ≤ y → y ≤ z → domain y
  states : (t : T) → domain t → F.WorldState
  respects_task : ∀ (s t : T) (hs : domain s) (ht : domain t),
    s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

**Action Items**:
1. Add type parameter `{T : Type*}` (implicit)
2. Add typeclass constraint `[LinearOrderedAddCommGroup T]`
3. Replace `Int` with `T` throughout
4. **ADD**: `convex` field enforcing domain convexity
5. Update all helper functions (`time_shift`, `universal`, etc.)
6. Update example histories to prove convexity
7. Update time-shift lemmas to use general group operations
8. Run `lake build` and fix errors

**Convexity Proofs Required**:
- `trivial` history: Trivial (full domain is convex)
- `universal_trivialFrame`: Trivial (full domain)
- `universal_natFrame`: Trivial (full domain)
- `time_shift`: Prove that shifted domain is convex if original is

**Estimated Effort**: 10-15 hours (convexity proofs add complexity)

### 5.3 Phase 3: Truth Generalization (6-10 hours)

**Goal**: Update truth evaluation to work with polymorphic temporal type

**File**: `Logos/Semantics/Truth.lean`

**Changes**:
```lean
-- BEFORE (current)
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t) :
    Formula → Prop
  | Formula.past φ => ∀ (s : Int) (hs : τ.domain s), s < t → truth_at M τ s hs φ
  | Formula.future φ => ∀ (s : Int) (hs : τ.domain s), t < s → truth_at M τ s hs φ

-- AFTER (generalized)
def truth_at {T : Type*} [LinearOrderedAddCommGroup T]
    (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t) :
    Formula → Prop
  | Formula.past φ => ∀ (s : T) (hs : τ.domain s), s < t → truth_at M τ s hs φ
  | Formula.future φ => ∀ (s : T) (hs : τ.domain s), t < s → truth_at M τ s hs φ
```

**Action Items**:
1. Add type parameter `{T : Type*}` (implicit)
2. Add typeclass constraint `[LinearOrderedAddCommGroup T]`
3. Replace `Int` with `T` in all temporal quantifications
4. Update time-shift preservation theorems
5. Update temporal duality infrastructure
6. Review all lemmas for typeclass compatibility
7. Run `lake build` and fix errors

**Challenging Areas**:
- `time_shift_preserves_truth`: Uses arithmetic (`t - s`, `s + Δ`)
  - **Solution**: These operations exist in `LinearOrderedAddCommGroup`
- Omega tactic: May not work with abstract groups
  - **Solution**: Use group lemmas from Mathlib instead

**Estimated Effort**: 6-10 hours (time-shift proofs need review)

### 5.4 Phase 4: Validity and Model Generalization (3-5 hours)

**Goal**: Update validity definitions and model structures

**Files**:
- `Logos/Semantics/Validity.lean`
- `Logos/Semantics/TaskModel.lean`

**Changes**:
```lean
-- Validity.lean BEFORE
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : Int) (ht : τ.domain t),
    truth_at M τ t ht φ

-- Validity.lean AFTER
def valid (φ : Formula) : Prop :=
  ∀ {T : Type*} [LinearOrderedAddCommGroup T] (F : TaskFrame T)
    (M : TaskModel F) (τ : WorldHistory F) (t : T) (ht : τ.domain t),
    truth_at M τ t ht φ
```

**Action Items**:
1. Update `valid` to quantify over all temporal types
2. Update `semantic_consequence` similarly
3. Update `satisfiable` to use polymorphic types
4. Verify all validity lemmas still hold
5. Run `lake build` and fix errors

**Estimated Effort**: 3-5 hours (mostly mechanical changes)

### 5.5 Phase 5: Documentation and Testing (3-5 hours)

**Goal**: Update documentation and create tests for generalization

**Files**:
- `CLAUDE.md`
- `Documentation/UserGuide/ARCHITECTURE.md`
- `Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
- `LogosTest/Semantics/*Test.lean`

**Action Items**:
1. Update CLAUDE.md to reflect generalized temporal type
2. Update ARCHITECTURE.md with typeclass explanation
3. Create examples using `Rat` and `Real` temporal types
4. Add tests for convexity enforcement
5. Update IMPLEMENTATION_STATUS.md completion percentages
6. Document migration guide for existing code

**Test Examples**:
```lean
-- Test with rational time
example : TaskFrame Rat := {
  WorldState := Nat
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
}

-- Test with real time
example : TaskFrame Real := {
  WorldState := Unit
  task_rel := fun _ _ _ => True
  nullity := fun _ => trivial
  compositionality := fun _ _ _ _ _ _ _ => trivial
}
```

**Estimated Effort**: 3-5 hours (documentation and tests)

---

## 6. Effort Estimation Summary

| Phase | Description | Estimated Hours | Difficulty |
|-------|-------------|----------------|------------|
| Phase 1 | TaskFrame generalization | 8-12 | Medium |
| Phase 2 | WorldHistory + convexity | 10-15 | High |
| Phase 3 | Truth evaluation | 6-10 | Medium-High |
| Phase 4 | Validity and models | 3-5 | Low-Medium |
| Phase 5 | Documentation and tests | 3-5 | Low |
| **TOTAL** | **Full generalization** | **30-47** | **Medium-High** |

**Complexity Factors**:
- **Typeclass propagation**: Every module needs `[LinearOrderedAddCommGroup T]`
- **Convexity proofs**: New constraint requires non-trivial proofs
- **Time-shift lemmas**: Arithmetic proofs may need Mathlib group lemmas
- **Breaking changes**: All downstream code must update type signatures

**Risk Mitigation**:
- Start with TaskFrame (smallest scope)
- Test at each phase before proceeding
- Create compatibility layer if needed
- Document breaking changes thoroughly

---

## 7. Benefits Analysis

### 7.1 Scientific Benefits

1. **Paper Alignment**: Direct correspondence with JPL paper specification
2. **Generality**: Support for rational/real time models (physics, economics)
3. **Bounded Systems**: Enable finite temporal domains (games, bounded processes)
4. **Theoretical Soundness**: Convexity constraint matches paper requirements

### 7.2 Engineering Benefits

1. **Mathlib Integration**: Leverage existing `LinearOrderedAddCommGroup` lemmas
2. **Type Safety**: Polymorphism prevents accidental Int-specific assumptions
3. **Extensibility**: Users can define custom temporal structures
4. **Documentation**: Code directly reflects mathematical specification

### 7.3 Use Case Examples

**Example 1: Chess Game** (finite time)
```lean
-- Bounded temporal domain for chess moves
inductive ChessTime : Type
  | move : Nat → ChessTime  -- move 0, move 1, ..., move n

instance : LinearOrderedAddCommGroup ChessTime := ...
```

**Example 2: Physical Simulation** (continuous time)
```lean
-- Real-valued time for physics
def PhysicsFrame : TaskFrame Real := ...
```

**Example 3: Economic Model** (rational time)
```lean
-- Rational time for discrete-event simulation
def EconomyFrame : TaskFrame Rat := ...
```

---

## 8. Compatibility and Migration

### 8.1 Backward Compatibility

**Breaking Changes**:
- All `TaskFrame` must become `TaskFrame T` with explicit type parameter
- Convexity proofs required for all histories
- Some arithmetic proofs may need rewriting (omega → group lemmas)

**Migration Path**:
```lean
-- OLD CODE
def myFrame : TaskFrame := ...

-- NEW CODE (explicit Int)
def myFrame : TaskFrame Int := ...

-- OR (inferred from usage)
def myFrame {T : Type*} [LinearOrderedAddCommGroup T] : TaskFrame T := ...
```

### 8.2 Compatibility Layer (Optional)

**Option**: Provide `TaskFrameInt` type alias for smooth migration
```lean
abbrev TaskFrameInt := TaskFrame Int
abbrev WorldHistoryInt := WorldHistory (F : TaskFrame Int)
```

This allows gradual migration without breaking existing code.

---

## 9. Recommendations

### 9.1 Immediate Actions

1. **Create Implementation Plan**: Detailed phase-by-phase plan based on this research
2. **Add TODO Task**: "Task 15: Generalize Temporal Order to LinearOrderedAddCommGroup"
   - Priority: Low (architectural improvement, not blocking)
   - Effort: 30-45 hours
   - Dependencies: None (can run anytime)
   - Benefits: Paper alignment, increased expressivity

3. **Update Documentation**: Document current limitation in KNOWN_LIMITATIONS.md
   ```markdown
   ## Temporal Domain Limitation

   **Status**: LIMITATION (Int hardcoded)

   Logos currently uses `Int` for temporal domains, while the JPL paper
   specifies arbitrary totally ordered abelian groups. This limits applicability
   to integer-time systems.

   **What works well**: All current proofs and derivations work correctly with Int.

   **What to avoid**: Custom temporal structures (rational/real time, bounded domains).

   **Workaround**: Use Int and interpret as desired temporal structure semantically.

   **Roadmap**: Generalize to `LinearOrderedAddCommGroup` typeclass (Task 15, 30-45h).
   ```

### 9.2 Long-Term Strategy

**Phase 1 (Current)**: Document limitation, continue with Int
- No immediate changes required
- Layer 0 MVP complete with Int-based semantics
- Document generalization path

**Phase 2 (Post-MVP)**: Implement generalization
- After Layer 0 completion and stability testing
- Coordinate with any Layer 1 extensions that may benefit
- Full test suite coverage before and after

**Phase 3 (Future)**: Explore advanced temporal structures
- Bounded time for game-theoretic applications
- Continuous time for physical models
- Custom time structures for domain-specific logics

---

## 10. References

### 10.1 Paper References

- **JPL Paper**: "The Perpetuity Calculus of Agency"
  - §app:TaskSemantics (lines 1825-1867)
  - def:frame (line 1835): Frame definition
  - def:world-history (line 1849): World history definition
  - def:BL-semantics (lines 1857-1866): Truth evaluation
  - lem:history-time-shift-preservation (line 1913): Time-shift theorem

### 10.2 Implementation References

- **TaskFrame.lean**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/TaskFrame.lean`
- **WorldHistory.lean**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/WorldHistory.lean`
- **Truth.lean**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Truth.lean`
- **Validity.lean**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Semantics/Validity.lean`

### 10.3 Mathlib References

- **LinearOrderedAddCommGroup**: `Mathlib.Algebra.Order.Group.Defs`
  - Module documentation: [Mathlib.Algebra.Order.Group.Defs](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Algebra/Order/Group/Defs.html)
  - Typeclass hierarchy: AddCommGroup → OrderedAddCommGroup → LinearOrderedAddCommGroup

---

## Appendix A: Complete Discrepancy Table

| Component | Line | Logos | JPL Paper | Severity |
|-----------|------|-------------|-----------|----------|
| TaskFrame.WorldState | 67 | `WorldState : Type` | `W : Set` | LOW (equivalent) |
| TaskFrame.task_rel | 69 | `task_rel : WorldState → Int → WorldState → Prop` | `task_rel : W × T → P(W)` | HIGH (Int vs T) |
| TaskFrame.nullity | 76 | `∀ w, task_rel w 0 w` | `w ⇒_0 w` | LOW (aligned) |
| TaskFrame.compositionality | 84 | `task_rel w x u → task_rel u y v → task_rel w (x + y) v` | `w ⇒_x u ∧ u ⇒_y v → w ⇒_{x+y} v` | LOW (aligned) |
| WorldHistory.domain | 59 | `domain : Int → Prop` | `X ⊆ T` | MEDIUM (pred vs set) |
| WorldHistory.convex | N/A | **NOT PRESENT** | `X convex` | HIGH (missing) |
| WorldHistory.states | 65 | `states : (t : Int) → domain t → F.WorldState` | `τ : X → W` | LOW (dep vs fun) |
| WorldHistory.respects_task | 74 | `s ≤ t → task_rel (states s hs) (t - s) (states t ht)` | `τ(x) ⇒_y τ(x+y)` | LOW (aligned) |
| truth_at.past | 110 | `∀ (s : Int) (hs : τ.domain s), s < t → ...` | `∀ y ∈ T, y < x → ...` | HIGH (Int vs T) |
| truth_at.future | 111 | `∀ (s : Int) (hs : τ.domain s), t < s → ...` | `∀ y ∈ T, x < y → ...` | HIGH (Int vs T) |
| valid | 45 | `∀ ... (t : Int) ...` | `∀ ... (x : T) ...` | HIGH (Int vs T) |

---

## Appendix B: Mathlib Typeclass Hierarchy

```
AddCommGroup α
  ├─ AddGroup α
  │   ├─ AddMonoid α
  │   │   └─ AddSemigroup α
  │   └─ AddZeroClass α
  └─ AddCommMonoid α

PartialOrder α
  └─ Preorder α

OrderedAddCommGroup α
  ├─ AddCommGroup α
  └─ PartialOrder α
  ├─ add_le_add_left : ∀ a b, a ≤ b → ∀ c, c + a ≤ c + b

LinearOrder α
  ├─ PartialOrder α
  └─ le_total : ∀ a b, a ≤ b ∨ b ≤ a

LinearOrderedAddCommGroup α
  ├─ OrderedAddCommGroup α
  └─ LinearOrder α
```

**Standard Instances**:
- `Int : LinearOrderedAddCommGroup Int`
- `Rat : LinearOrderedAddCommGroup Rat`
- `Real : LinearOrderedAddCommGroup Real`

---

**Report Status**: COMPLETE
**Next Step**: Create implementation plan document
**Reference**: This report should be used as foundation for Task 15 planning
