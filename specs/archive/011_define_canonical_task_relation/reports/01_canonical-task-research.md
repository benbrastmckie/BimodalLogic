# Research Report: CanonicalTask Relation Definition

**Task**: 11 - define_canonical_task_relation
**Session**: sess_1774086842_9dd65b
**Date**: 2026-03-21

---

## 1. Executive Summary

This report provides implementation guidance for defining `CanonicalTask(u,n,v)` as an integer-indexed relation built inductively from the `Succ` relation (Task 10). The implementation involves:

1. **Inductive Definition**: Three-case inductive type (base, forward step, backward step)
2. **TaskFrame Axioms**: Nullity identity, forward compositionality, converse
3. **Bounded Witness Corollary**: Single-step forcing generalization

All prerequisites exist from Task 10. The implementation is straightforward with no blocking dependencies.

---

## 2. Prerequisites Analysis

### 2.1 Task 10 Deliverables (Completed)

From `SuccRelation.lean`:

```lean
-- Core definition
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v

-- Key theorems available
theorem Succ_implies_CanonicalR (u v : Set Formula) (h : Succ u v) : CanonicalR u v
theorem Succ_implies_h_content_reverse ... : h_content v ⊆ u
theorem single_step_forcing ... : phi ∈ v  -- when F(phi) in u, FF(phi) not in u
```

### 2.2 Existing Infrastructure

| Definition/Theorem | Location | Relevance |
|-------------------|----------|-----------|
| `Succ` | SuccRelation.lean | Base step relation |
| `single_step_forcing` | SuccRelation.lean | Key for bounded witness |
| `CanonicalR_chain` | DovetailedCoverageReach.lean | Pattern for forward chain |
| `CanonicalR_chain_backward` | DovetailedCoverageReach.lean | Pattern for backward chain |
| `Int.inductionOn'` | Mathlib | Integer induction with arbitrary base |
| `TaskFrame` | TaskFrame.lean | Target axiomatization |

### 2.3 TaskFrame Axiom Reference

From `TaskFrame.lean` (lines 93-122):
```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

---

## 3. CanonicalTask Definition Design

### 3.1 Mathematical Definition

```
CanonicalTask(u, n, v) is defined inductively:
  - Base: CanonicalTask(u, 0, v) ↔ u = v
  - Forward: CanonicalTask(u, n+1, v) ↔ ∃w, Succ(u, w) ∧ CanonicalTask(w, n, v)  [n ≥ 0]
  - Backward: CanonicalTask(u, n-1, v) ↔ ∃w, Succ(v, w) ∧ CanonicalTask(u, n, w)  [n ≤ 0]
```

### 3.2 Design Decision: Inductive vs Recursive Definition

**Option A: Inductive Type** (Recommended)
```lean
inductive CanonicalTask : Set Formula → Int → Set Formula → Prop where
  | base : CanonicalTask u 0 u
  | forward {u w v : Set Formula} {n : Nat} :
      Succ u w → CanonicalTask w n v → CanonicalTask u (n + 1) v
  | backward {u w v : Set Formula} {n : Nat} :
      Succ v w → CanonicalTask u (-n : Int) w → CanonicalTask u (-(n + 1) : Int) v
```

**Advantages**:
- Direct pattern matching for proofs
- Clear case structure for induction
- Follows `CanonicalR_chain` pattern from DovetailedCoverageReach.lean

**Option B: Recursive Definition**
```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | 0 => u = v
  | Int.ofNat (k + 1) => ∃ w, Succ u w ∧ CanonicalTask w k v
  | Int.negSucc k => ∃ w, Succ v w ∧ CanonicalTask u (-k : Int) w
```

**Disadvantages**: Termination proof may be tricky; less clear induction.

**Recommendation**: Use **Option A (Inductive Type)** for cleaner proofs.

### 3.3 Alternative: Split Forward/Backward

Following `CanonicalR_chain` and `CanonicalR_chain_backward` patterns:

```lean
-- Forward chain: n ≥ 0 steps forward
inductive CanonicalTask_forward : Set Formula → Nat → Set Formula → Prop where
  | base : CanonicalTask_forward u 0 u
  | step {u w v : Set Formula} {n : Nat} :
      Succ u w → CanonicalTask_forward w n v → CanonicalTask_forward u (n + 1) v

-- Backward chain: n steps backward (converse direction)
inductive CanonicalTask_backward : Set Formula → Nat → Set Formula → Prop where
  | base : CanonicalTask_backward u 0 u
  | step {u w v : Set Formula} {n : Nat} :
      Succ v w → CanonicalTask_backward u n w → CanonicalTask_backward u (n + 1) v

-- Combined with integer index
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v
```

**Recommendation**: Use the **split approach** for cleaner proofs of individual directions, then unify with the combined definition.

---

## 4. TaskFrame Axiom Proofs

### 4.1 Nullity Identity

**Statement**:
```lean
theorem CanonicalTask_nullity_identity (u v : Set Formula) :
    CanonicalTask u 0 v ↔ u = v
```

**Proof Strategy**:
- Forward: By case analysis on `CanonicalTask u 0 v`, only `base` applies, giving `u = v`
- Backward: Given `u = v`, apply `CanonicalTask.base` (after substitution)

**Complexity**: Trivial

### 4.2 Forward Compositionality

**Statement**:
```lean
theorem CanonicalTask_forward_comp (u w v : Set Formula) (m n : Nat) :
    CanonicalTask u m w → CanonicalTask w n v → CanonicalTask u (m + n) v
```

**Proof Strategy**:
By induction on the first derivation:
- Base case: `CanonicalTask u 0 w` means `u = w`, so result is `CanonicalTask u n v`
- Forward step: `CanonicalTask u (m+1) w` gives `∃w', Succ u w' ∧ CanonicalTask w' m w`
  Apply IH to get `CanonicalTask w' (m + n) v`, then apply `forward` constructor

**Key Lemma**: `(m + 1) + n = (m + n) + 1` (integer arithmetic)

**Complexity**: Moderate (induction with arithmetic)

### 4.3 Converse

**Statement**:
```lean
theorem CanonicalTask_converse (u v : Set Formula) (n : Int) :
    CanonicalTask u n v ↔ CanonicalTask v (-n) u
```

**Proof Strategy**:

By the structure of the inductive definition:
- `CanonicalTask u 0 v` ↔ `u = v` ↔ `v = u` ↔ `CanonicalTask v 0 u` (since -0 = 0)
- Forward steps in one direction correspond to backward steps in the other

**Key Insight**: The backward constructor is designed precisely to make converse hold:
- `forward: Succ u w ∧ CanonicalTask w n v → CanonicalTask u (n+1) v`
- `backward: Succ v w ∧ CanonicalTask u n w → CanonicalTask u (n-1) v`

When we flip the direction:
- `CanonicalTask u (n+1) v` via forward means `∃w, Succ u w ∧ CanonicalTask w n v`
- By IH, `CanonicalTask v (-n) w`
- By g/h duality (`Succ_implies_h_content_reverse`), the Succ relationship also holds in converse
- So `CanonicalTask v (-(n+1)) u` via backward

**Critical Observation**: The converse proof requires establishing that `Succ u w` implies some relationship for the converse direction. The key is that `Succ` is NOT symmetric, but:
- `Succ u v` implies `CanonicalR u v` (g_content ⊆)
- `Succ u v` with MCS conditions implies `h_content v ⊆ u`

For converse, we need: if `CanonicalTask u n v`, then `CanonicalTask v (-n) u`.

**Approach**: Define CanonicalTask so that converse holds by construction:
- Forward: `∃w, Succ u w ∧ CanonicalTask w n v`
- Backward: `∃w, Succ v w ∧ CanonicalTask u (n+1) w`

This ensures: if we go forward from u to v in n+1 steps, we can express going backward from v to u in -(n+1) steps via the backward constructor.

**Complexity**: Moderate (requires careful case analysis)

---

## 5. Bounded Witness Corollary

### 5.1 Statement

```lean
theorem bounded_witness (u v : Set Formula)
    (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (phi : Formula) (n : Nat)
    (h_Fn : F^n(phi) ∈ u)
    (h_Fn1_not : F^(n+1)(phi) ∉ u)
    (h_task : CanonicalTask u n v) :
    phi ∈ v
```

Where `F^n(phi)` denotes n-fold application of `Formula.some_future`.

### 5.2 Proof Strategy

By induction on n:

**Base case (n = 0)**:
- `F^0(phi) = phi ∈ u`
- `CanonicalTask u 0 v` means `u = v`
- So `phi ∈ v`

**Inductive case (n = k + 1)**:
- `F^(k+1)(phi) = F(F^k(phi)) ∈ u`
- `F^(k+2)(phi) ∉ u`
- `CanonicalTask u (k+1) v` means `∃w, Succ u w ∧ CanonicalTask w k v`

From `single_step_forcing`:
- `F(F^k(phi)) ∈ u` and `F(F(F^k(phi))) ∉ u` and `Succ u w`
- Therefore `F^k(phi) ∈ w`

We need to show `F^(k+1)(phi) ∉ w` to apply IH:
- This follows from the Succ properties and formula propagation
- Key: GG(¬F^k(phi)) ∈ u implies G(¬F^k(phi)) ∈ w, so F(F^k(phi)) ∉ w

Then by IH: `CanonicalTask w k v` and `F^k(phi) ∈ w` and `F^(k+1)(phi) ∉ w` implies `phi ∈ v`

### 5.3 Helper Lemma: Iterated F

```lean
def iter_F : Nat → Formula → Formula
  | 0, phi => phi
  | n + 1, phi => Formula.some_future (iter_F n phi)

lemma iter_F_succ (n : Nat) (phi : Formula) :
    iter_F (n + 1) phi = Formula.some_future (iter_F n phi) := rfl
```

**Complexity**: Moderate (induction with single_step_forcing application)

---

## 6. File Structure

### 6.1 Recommended File Location

```
Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean
```

### 6.2 Required Imports

```lean
import Bimodal.Metalogic.Bundle.SuccRelation
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Semantics.TaskFrame
```

### 6.3 Module Structure

```lean
namespace Bimodal.Metalogic.Bundle

-- Section 1: Iterated F helper
def iter_F : Nat → Formula → Formula
lemma iter_F_succ ...

-- Section 2: Forward chain (Nat-indexed)
inductive CanonicalTask_forward : Set Formula → Nat → Set Formula → Prop

-- Section 3: Backward chain (Nat-indexed)
inductive CanonicalTask_backward : Set Formula → Nat → Set Formula → Prop

-- Section 4: Combined Int-indexed definition
def CanonicalTask : Set Formula → Int → Set Formula → Prop

-- Section 5: Nullity Identity
theorem CanonicalTask_nullity_identity ...

-- Section 6: Forward Compositionality
theorem CanonicalTask_forward_forward_comp ...  -- Nat version
theorem CanonicalTask_forward_comp ...          -- Int version (restricted)

-- Section 7: Converse
theorem CanonicalTask_converse ...

-- Section 8: Bounded Witness
theorem bounded_witness ...

end Bimodal.Metalogic.Bundle
```

---

## 7. Mathlib Lemmas to Use

| Lemma | Type | Usage |
|-------|------|-------|
| `Int.ofNat_add` | `↑(a + b) = ↑a + ↑b` | Arithmetic in compositionality |
| `Int.neg_add` | `-(a + b) = -a + -b` | Converse proof |
| `Int.neg_neg` | `--a = a` | Converse symmetry |
| `Nat.add_comm` | `a + b = b + a` | Chain concatenation |
| `Int.add_assoc` | `(a + b) + c = a + (b + c)` | Compositionality |

---

## 8. Complexity Assessment

| Component | Lines | Difficulty | Blocking Risk |
|-----------|-------|------------|---------------|
| iter_F definition | 5 | Trivial | None |
| CanonicalTask_forward | 8 | Easy | None |
| CanonicalTask_backward | 8 | Easy | None |
| CanonicalTask combined | 10 | Easy | None |
| nullity_identity | 10 | Easy | None |
| forward_comp (Nat) | 20 | Moderate | None |
| forward_comp (Int) | 15 | Moderate | None |
| converse | 30 | Moderate | None |
| bounded_witness | 40 | Moderate | None |

**Total Estimated Lines**: 150-180
**Overall Difficulty**: Moderate
**Blocking Dependencies**: None - Task 10 provides all prerequisites

---

## 9. Implementation Order

1. **Phase 1**: iter_F helper and basic forward/backward inductives
2. **Phase 2**: Combined CanonicalTask definition
3. **Phase 3**: Nullity identity (warmup proof)
4. **Phase 4**: Forward compositionality (Nat version first, then Int)
5. **Phase 5**: Converse theorem
6. **Phase 6**: Bounded witness corollary

---

## 10. Verification Checklist

Before marking task complete, verify:

- [ ] `lake build Bimodal.Metalogic.Bundle.CanonicalTaskRelation` succeeds
- [ ] No sorries in the file
- [ ] All three TaskFrame axioms proven:
  - [ ] `CanonicalTask_nullity_identity`
  - [ ] `CanonicalTask_forward_comp` (or restricted version)
  - [ ] `CanonicalTask_converse`
- [ ] Bounded witness corollary proven:
  - [ ] `bounded_witness`
- [ ] Documentation comments for each definition/theorem

---

## 11. Future Dependencies

This file will be used by:
- **Task 12** (if separate): Additional TaskFrame properties
- **Task 13** (if separate): Integration with completeness
- **Task 14+**: Canonical model construction leveraging CanonicalTask

---

## 12. Recommendations

1. **Use split approach**: Define `CanonicalTask_forward` and `CanonicalTask_backward` separately, then combine. This mirrors the existing `CanonicalR_chain` pattern.

2. **Prove Nat versions first**: The Nat-indexed compositionality is cleaner; derive Int version from it.

3. **Test converse carefully**: The backward constructor must be designed to make converse trivial by definition.

4. **Use `single_step_forcing` as black box**: The bounded witness proof should invoke this theorem without re-proving its internals.

5. **Add simp lemmas**: `@[simp] lemma CanonicalTask_zero : CanonicalTask u 0 v ↔ u = v` will help automation.
