# Research Report: DenseTask Relation Definition

**Task**: 16 - Define Dense Task Relation
**Date**: 2026-03-21
**Status**: Research Complete

---

## 1. Executive Summary

This task defines `DenseTask(u, q, v)` as `e(tv) - e(tu) = q` where `e : TimelineQuot ≃o Q` is the Cantor isomorphism. The definition leverages existing infrastructure in `DurationTransfer.lean` (`canonicalTaskRel`) and `CantorApplication.lean` (`TimelineQuot`, `cantor_iso`). TaskFrame axioms are trivial from group properties. The density interpolation theorem follows directly from group structure on `TimelineQuot`.

**Key Finding**: The `canonicalTaskRel` from `DurationTransfer.lean` already provides the exact definition needed:
```lean
def canonicalTaskRel {T : Type*} [Add T] (w : T) (d : T) (w' : T) : Prop := w + d = w'
```

When instantiated with `T = TimelineQuot` (which has `AddCommGroup` from `ratAddCommGroup`), this IS the `DenseTask` relation.

---

## 2. Existing Infrastructure Analysis

### 2.1 Cantor Isomorphism (CantorApplication.lean)

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean`

The timeline quotient and Cantor isomorphism are fully implemented:

```lean
def TimelineQuot : Type :=
  Antisymmetrization (DenseTimelineElem root_mcs root_mcs_proof) (· ≤ ·)

theorem cantor_iso :
    Nonempty (TimelineQuot root_mcs root_mcs_proof ≃o Rat)
```

**Verified Instances** (all present):
- `LinearOrder (TimelineQuot root_mcs root_mcs_proof)` - line 110
- `Nonempty (TimelineQuot root_mcs root_mcs_proof)` - line 120
- `Countable (TimelineQuot root_mcs root_mcs_proof)` - line 125
- `NoMaxOrder (TimelineQuot root_mcs root_mcs_proof)` - line 144
- `NoMinOrder (TimelineQuot root_mcs root_mcs_proof)` - line 168
- `DenselyOrdered (TimelineQuot root_mcs root_mcs_proof)` - line 194

### 2.2 Duration Transfer (DurationTransfer.lean)

**File**: `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`

The group structure transfer is complete:

```lean
noncomputable def ratAddCommGroup
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    AddCommGroup T :=
  transferAddCommGroup (ratOrderIso T)

theorem ratIsOrderedAddMonoid
    (T : Type*) [LinearOrder T] [Countable T] [DenselyOrdered T]
    [NoMaxOrder T] [NoMinOrder T] [Nonempty T] :
    @IsOrderedAddMonoid T (ratAddCommGroup T).toAddCommMonoid (inferInstance : PartialOrder T)
```

**Key Definition** (the deterministic task relation):
```lean
def canonicalTaskRel {T : Type*} [Add T] (w : T) (d : T) (w' : T) : Prop :=
  w + d = w'
```

### 2.3 TimelineQuot Algebra (TimelineQuotAlgebra.lean)

**File**: `Theories/Bimodal/Metalogic/StagedConstruction/TimelineQuotAlgebra.lean`

The algebraic structure on TimelineQuot is established:

```lean
noncomputable def timelineQuotAddCommGroup :
    AddCommGroup (TimelineQuot root_mcs root_mcs_proof) :=
  ratAddCommGroup (TimelineQuot root_mcs root_mcs_proof)

theorem timelineQuotIsOrderedAddMonoid :
    @IsOrderedAddMonoid (TimelineQuot root_mcs root_mcs_proof)
      (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAddCommMonoid
      (inferInstance : PartialOrder (TimelineQuot root_mcs root_mcs_proof))
```

### 2.4 Parametric Canonical TaskFrame (ParametricCanonical.lean)

**File**: `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean`

The duration-coarse parametric relation (for comparison):

```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N
```

**Contrast**: `parametric_canonical_task_rel` is duration-coarse (all positive durations collapse to `CanonicalR`). The `DenseTask` relation from `canonicalTaskRel` is duration-precise (each rational q determines a unique target).

### 2.5 Discrete CanonicalTask (CanonicalTaskRelation.lean)

**File**: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean`

For comparison, the discrete version builds inductively from `Succ`:

```lean
inductive CanonicalTask_forward : Set Formula → Nat → Set Formula → Prop where
  | base {u : Set Formula} : CanonicalTask_forward u 0 u
  | step {u w v : Set Formula} {n : Nat} :
      Succ u w → CanonicalTask_forward w n v → CanonicalTask_forward u (n + 1) v

def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v
```

---

## 3. Definition Strategy

### 3.1 DenseTask Definition

The `DenseTask` relation should be defined as `canonicalTaskRel` instantiated with `T = TimelineQuot`:

```lean
/--
DenseTask relation: duration q takes timeline element u to element v.

This is the deterministic three-place task relation for the dense case.
Given the Cantor isomorphism `e : TimelineQuot ≃o Q`, we have:
  DenseTask(u, q, v) ↔ e(v) - e(u) = q

The definition uses the transferred group structure on TimelineQuot:
  DenseTask(u, q, v) ↔ u + q = v
-/
def DenseTask (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (u : TimelineQuot root_mcs root_mcs_proof)
    (q : TimelineQuot root_mcs root_mcs_proof)
    (v : TimelineQuot root_mcs root_mcs_proof) : Prop :=
  letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
  u + q = v
```

### 3.2 Alternative: MCS-Based WorldState

The prior research suggests also defining `DenseTask` with `WorldState = MCS`:

```lean
/--
DenseTask relation on MCSs: MCS u to MCS v via rational duration q.

This bridges the syntactic MCS structure with the semantic TimelineQuot.
Given the embedding `embed : MCS → TimelineQuot`, we have:
  DenseTask_MCS(u, q, v) ↔ embed(u) + q = embed(v)
-/
def DenseTask_MCS (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (u : ParametricCanonicalWorldState)
    (q : TimelineQuot root_mcs root_mcs_proof)
    (v : ParametricCanonicalWorldState) : Prop :=
  ∃ tu tv : TimelineQuot root_mcs root_mcs_proof,
    mcsAtTime root_mcs root_mcs_proof tu = u.val ∧
    mcsAtTime root_mcs root_mcs_proof tv = v.val ∧
    letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
    tu + q = tv
```

However, this requires additional infrastructure (the `mcsAtTime` mapping from TimelineQuot back to MCSs). The simpler approach is to work directly with `TimelineQuot` elements.

---

## 4. TaskFrame Axiom Verification

### 4.1 Nullity Identity

**Theorem**: `DenseTask(u, 0, v) ↔ u = v`

**Proof**:
```
DenseTask(u, 0, v)
  ↔ u + 0 = v       (definition)
  ↔ u = v           (group identity: a + 0 = a)
```

This is already proven in `DurationTransfer.lean`:
```lean
nullity_identity := fun w u => by
  show w + 0 = u ↔ w = u
  rw [add_zero]
```

### 4.2 Forward Compositionality

**Theorem**: If `DenseTask(u, q1, w)` and `DenseTask(w, q2, v)` with `q1, q2 >= 0`, then `DenseTask(u, q1 + q2, v)`.

**Proof**:
```
Assume: u + q1 = w  and  w + q2 = v
Then:   u + (q1 + q2)
      = (u + q1) + q2    (associativity)
      = w + q2           (substitution)
      = v                (assumption)
```

This is already proven in `DurationTransfer.lean`:
```lean
forward_comp := fun w u v x y _ _ h1 h2 => by
  show w + (x + y) = v
  rw [← h2, ← h1]
  rw [add_assoc]
```

### 4.3 Converse

**Theorem**: `DenseTask(u, q, v) ↔ DenseTask(v, -q, u)`

**Proof**:
```
DenseTask(u, q, v)
  ↔ u + q = v              (definition)
  ↔ v + (-q) = u           (group inverse: a + b = c ↔ c + (-b) = a)
  ↔ DenseTask(v, -q, u)    (definition)
```

This is already proven in `DurationTransfer.lean`:
```lean
converse := fun w d u => by
  show w + d = u ↔ u + -d = w
  constructor
  · intro h
    rw [← h]
    simp [add_assoc]
  · intro h
    rw [← h]
    simp [add_assoc]
```

---

## 5. Density Interpolation Theorem

### 5.1 Statement

**Theorem** (Density Interpolation): For timeline elements u, v with `DenseTask(u, q, v)` where `q > 0`, and any `0 < r < q`, there exists w with `DenseTask(u, r, w)` and `DenseTask(w, q - r, v)`.

### 5.2 Proof Strategy

The proof is trivial from group properties:

```lean
theorem density_interpolation
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (u v : TimelineQuot root_mcs root_mcs_proof)
    (q : TimelineQuot root_mcs root_mcs_proof)
    (hq : q > 0)
    (r : TimelineQuot root_mcs root_mcs_proof)
    (hr_pos : 0 < r)
    (hr_lt : r < q)
    (h_task : DenseTask root_mcs root_mcs_proof u q v) :
    ∃ w : TimelineQuot root_mcs root_mcs_proof,
      DenseTask root_mcs root_mcs_proof u r w ∧
      DenseTask root_mcs root_mcs_proof w (q - r) v := by
  letI := timelineQuotAddCommGroup root_mcs root_mcs_proof
  -- Let w = u + r
  use u + r
  constructor
  · -- DenseTask(u, r, w): u + r = w, trivially true
    rfl
  · -- DenseTask(w, q - r, v): w + (q - r) = v
    -- w + (q - r) = (u + r) + (q - r) = u + (r + (q - r)) = u + q = v
    simp only [add_sub_cancel]
    exact h_task
```

### 5.3 Corollary: Infinite Subdivision

**Corollary**: Any positive-duration task can be subdivided into arbitrarily many sub-tasks of equal rational duration. There is no minimal task duration.

This follows by iterated application of density interpolation.

---

## 6. File Location and Dependencies

### 6.1 Recommended File Location

```
Theories/Bimodal/Metalogic/StagedConstruction/DenseTaskRelation.lean
```

### 6.2 Required Imports

```lean
import Bimodal.Metalogic.StagedConstruction.TimelineQuotAlgebra
import Bimodal.Metalogic.Domain.DurationTransfer
import Bimodal.Semantics.TaskFrame
```

### 6.3 Dependency Graph

```
DenseTaskRelation.lean
  └── TimelineQuotAlgebra.lean
       ├── CantorApplication.lean
       │    ├── DenseTimeline.lean
       │    └── CanonicalIrreflexivityAxiom.lean
       └── DurationTransfer.lean
            └── TaskFrame.lean
```

---

## 7. Relationship to Existing Infrastructure

### 7.1 vs. ParametricCanonical.parametric_canonical_task_rel

| Aspect | parametric_canonical_task_rel | DenseTask |
|--------|------------------------------|-----------|
| Duration precision | Coarse (all d>0 map to same R) | Precise (each q unique) |
| Determinism | Non-deterministic | Deterministic |
| D type | Any ordered abelian group | TimelineQuot (≃o Q) |
| W type | ParametricCanonicalWorldState (MCSs) | TimelineQuot |
| Definition | if d>0 then CanonicalR else... | w + d = w' |

### 7.2 vs. CanonicalTask (Discrete)

| Aspect | CanonicalTask | DenseTask |
|--------|---------------|-----------|
| Duration type | Int | Q (via TimelineQuot) |
| Construction | Inductive (Succ chains) | Direct (group addition) |
| Minimal duration | 1 (single step) | None (arbitrarily small) |
| Determinism | Non-deterministic | Deterministic |
| Interpolation | No | Yes (density) |

### 7.3 Unification via canonicalTaskRel

Both discrete and dense cases can use `canonicalTaskRel`:
- **Discrete**: `T = Int`, addition is integer addition
- **Dense**: `T = TimelineQuot`, addition is transferred from Q via Cantor iso

The key difference is the underlying type T, not the relation definition.

---

## 8. Implementation Plan

### Phase 1: Define DenseTask (Core Definition)

1. Create `DenseTaskRelation.lean` with imports
2. Define `DenseTask` using `canonicalTaskRel` pattern
3. Prove basic lemmas: `DenseTask_zero`, `DenseTask_add`, `DenseTask_neg`

### Phase 2: TaskFrame Q Instance

1. Define `DenseTaskFrame` as TaskFrame Q instantiation
2. Verify all three axioms (trivial from existing proofs)
3. Add `DenseTemporalFrame` instance marker

### Phase 3: Density Interpolation

1. Prove `density_interpolation` theorem
2. Prove `arbitrary_subdivision` corollary
3. Document relationship to F-obligation resolution

### Phase 4: Integration

1. Export key definitions/theorems in module structure
2. Update `Metalogic.lean` imports
3. Verify lake build succeeds

---

## 9. Risk Assessment

### 9.1 Low Risk: Core Definition

The `canonicalTaskRel` definition is already proven to satisfy TaskFrame axioms in `DurationTransfer.lean`. The only work is instantiating with `T = TimelineQuot`.

### 9.2 Low Risk: Density Interpolation

The proof is straightforward group arithmetic. No complex proof search required.

### 9.3 Medium Risk: MCS↔TimelineQuot Bridge

If we need `DenseTask_MCS` (relating MCSs via rational durations), we need the `mcsAtTime` mapping. This requires either:
- Extracting the MCS from a TimelineQuot element (which carries `DenseTimelineElem` internally)
- Using the FMCS structure from `TimelineQuotCanonical.lean`

This is a potential scope extension but not required for the core definition.

---

## 10. Zero-Debt Compliance

**Confirmed**: All proposed proofs use standard group theory lemmas from Mathlib (`add_zero`, `add_assoc`, `add_sub_cancel`, etc.). No `sorry` deferral patterns are recommended. The implementation approach guarantees completion without axiom introduction.

---

## 11. Conclusion

Task 16 is straightforward to implement because:

1. **Infrastructure exists**: `canonicalTaskRel`, `timelineQuotAddCommGroup`, `cantor_iso` all present
2. **Axioms trivial**: TaskFrame proofs already done for generic T in `DurationTransfer.lean`
3. **Density interpolation simple**: Just group arithmetic
4. **Clear file location**: `StagedConstruction/DenseTaskRelation.lean`

**Estimated effort**: 1-2 hours implementation, primarily setup and documentation.
