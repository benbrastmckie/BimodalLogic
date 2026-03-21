# Research Report: Succ Relation Definition

**Task**: 10 - define_succ_relation
**Session**: sess_1774085214_bbea3c
**Date**: 2026-03-21

---

## 1. Executive Summary

This report provides implementation guidance for defining the Succ relation and proving three core theorems:
1. Succ implies CanonicalR
2. g/h duality for Succ pairs
3. Single-step forcing theorem

The implementation is straightforward with no blocking dependencies. All prerequisite lemmas exist in the codebase.

---

## 2. Prerequisites Analysis

### 2.1 Required Definitions (Task 9 - Completed)

The following definitions were added to `TemporalContent.lean` by task 9:

```lean
def f_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_future phi ∈ M}

def p_content (M : Set Formula) : Set Formula :=
  {phi | Formula.some_past phi ∈ M}
```

**Simp lemmas** available:
- `mem_f_content_iff`: `phi ∈ f_content M ↔ Formula.some_future phi ∈ M`
- `mem_p_content_iff`: `phi ∈ p_content M ↔ Formula.some_past phi ∈ M`

**Duality lemmas** available:
- `f_content_iff_not_neg_in_g_content`: For MCS M, `phi ∈ f_content M ↔ phi.neg ∉ g_content M`
- `p_content_iff_not_neg_in_h_content`: For MCS M, `phi ∈ p_content M ↔ phi.neg ∉ h_content M`

### 2.2 Existing Infrastructure

| Definition/Theorem | Location | Relevance |
|-------------------|----------|-----------|
| `g_content` | TemporalContent.lean:46 | G-persistence condition (1) |
| `CanonicalR` | CanonicalFrame.lean:63 | `g_content M ⊆ M'` |
| `g_content_subset_implies_h_content_reverse` | WitnessSeed.lean:324 | Duality: g_content ⊆ implies h_content reverse |
| `h_content_subset_implies_g_content_reverse` | WitnessSeed.lean:354 | Duality: h_content ⊆ implies g_content reverse |
| `temp_4` axiom | Axioms.lean:246 | `G phi → G(G phi)` for transitivity |
| `SetMaximalConsistent.negation_complete` | MCSProperties.lean | `phi ∈ M ∨ ¬phi ∈ M` for MCS |

---

## 3. Succ Relation Definition

### 3.1 Mathematical Definition

```
Succ(u, v) := g_content(u) ⊆ v  ∧  f_content(u) ⊆ v ∪ f_content(v)
```

**Condition (1)**: G-persistence - same as CanonicalR
**Condition (2)**: F-step - every F-obligation is resolved at v or deferred to v's future

### 3.2 Lean Definition

```lean
/--
Immediate successor relation: u sees v as its next state.

Condition (1): G-persistence - all universal future commitments propagate
Condition (2): F-step - existential obligations are resolved or deferred
-/
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

### 3.3 Accessor Lemmas

```lean
theorem Succ.g_persistence (h : Succ u v) : g_content u ⊆ v := h.1

theorem Succ.f_step (h : Succ u v) : f_content u ⊆ v ∪ f_content v := h.2
```

---

## 4. Theorem 1: Succ Implies CanonicalR

### 4.1 Statement

```lean
theorem Succ_implies_CanonicalR (u v : Set Formula) (h : Succ u v) :
    CanonicalR u v := h.1
```

### 4.2 Proof Strategy

Trivial by projection: Succ condition (1) is exactly the definition of CanonicalR.

### 4.3 Implementation Complexity

**Difficulty**: Trivial (1 line)

---

## 5. Theorem 2: g/h Duality for Succ Pairs

### 5.1 Statement

From report 17 section 2.2, the g/h duality theorem states:

```lean
theorem Succ_implies_h_content_reverse
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (h_succ : Succ u v) :
    h_content v ⊆ u
```

### 5.2 Proof Strategy

1. Extract G-persistence: `g_content u ⊆ v` from `Succ u v`
2. Apply existing `g_content_subset_implies_h_content_reverse` from WitnessSeed.lean

### 5.3 Implementation

```lean
theorem Succ_implies_h_content_reverse
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (h_succ : Succ u v) :
    h_content v ⊆ u :=
  g_content_subset_implies_h_content_reverse u v h_mcs_u h_mcs_v h_succ.1
```

### 5.4 Implementation Complexity

**Difficulty**: Trivial (direct application of existing lemma)

---

## 6. Theorem 3: Single-Step Forcing

### 6.1 Statement

```lean
theorem single_step_forcing
    (u v : Set Formula) (h_mcs_u : SetMaximalConsistent u) (h_mcs_v : SetMaximalConsistent v)
    (phi : Formula)
    (h_F : Formula.some_future phi ∈ u)
    (h_FF_not : Formula.some_future (Formula.some_future phi) ∉ u)
    (h_succ : Succ u v) :
    phi ∈ v
```

### 6.2 Proof Outline (from Report 17 Section 2.6)

1. Since u is MCS and `FFphi ∉ u`, by negation completeness: `¬FFphi ∈ u`
2. Expand: `¬FFphi = ¬(¬G¬(¬G¬phi)) = G(G(¬phi)) = GG(¬phi)`
3. So `GG(¬phi) ∈ u`
4. By g_content definition: `G(¬phi) ∈ g_content(u)`
5. By G-persistence (Succ condition 1): `G(¬phi) ∈ v`
6. This means `¬Fphi ∈ v`, so `Fphi ∉ v`
7. By F-step (Succ condition 2): `Fphi ∈ u` implies `phi ∈ v ∨ Fphi ∈ v`
8. Since `Fphi ∉ v` (step 6), conclude `phi ∈ v`

### 6.3 Key Lemmas Needed

| Step | Lemma | Status |
|------|-------|--------|
| 1 | `SetMaximalConsistent.negation_complete` | Exists |
| 2-3 | Formula unfolding: `¬FFphi = GG(¬phi)` | Need to prove (definitional) |
| 4 | `mem_g_content_iff` | Exists |
| 5 | Succ.g_persistence (subset membership) | Trivial |
| 6 | `G(¬phi) ∈ v` implies `Fphi ∉ v` | Need to prove (MCS consistency) |
| 7 | Succ.f_step (union membership) | Trivial |
| 8 | Or.resolve_right | Standard |

### 6.4 Auxiliary Lemma: Formula Expansion

```lean
-- FFphi = ¬G¬(¬G¬phi)
-- ¬FFphi = G(G(¬phi))
lemma neg_FF_eq_GG_neg (phi : Formula) :
    (Formula.some_future (Formula.some_future phi)).neg
    = Formula.all_future (Formula.all_future phi.neg) := by
  -- Definitional: some_future phi = phi.neg.all_future.neg
  -- some_future (some_future phi) = (phi.neg.all_future.neg).neg.all_future.neg
  -- neg of that = phi.neg.all_future.neg.neg.all_future
  -- phi.neg.all_future.neg.neg = phi.neg.all_future (by double negation)
  -- So: phi.neg.all_future.all_future = G(G(¬phi))
  rfl  -- or simp with appropriate unfolding
```

### 6.5 Auxiliary Lemma: G(¬phi) implies ¬F(phi)

```lean
lemma G_neg_implies_not_F (M : Set Formula) (h_mcs : SetMaximalConsistent M) (phi : Formula)
    (h_G_neg : Formula.all_future phi.neg ∈ M) :
    Formula.some_future phi ∉ M := by
  -- G(¬phi) ∈ M means ¬F(phi) ∈ M (since F = ¬G¬)
  -- By MCS consistency, F(phi) ∉ M
  intro h_F
  have h_eq : Formula.some_future phi = (Formula.all_future phi.neg).neg := rfl
  rw [h_eq] at h_F
  exact set_consistent_not_both h_mcs.1 _ h_G_neg h_F
```

### 6.6 Implementation Complexity

**Difficulty**: Moderate (8-step proof with formula manipulation)

The proof follows a standard pattern and all pieces exist. The main work is:
1. Proving the formula expansion lemma (definitional)
2. Chaining the steps correctly

---

## 7. File Structure

### 7.1 Recommended File Location

```
Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean
```

### 7.2 Required Imports

```lean
import Bimodal.Metalogic.Bundle.TemporalContent
import Bimodal.Metalogic.Bundle.CanonicalFrame
import Bimodal.Metalogic.Bundle.WitnessSeed
import Bimodal.Metalogic.Core.MCSProperties
```

### 7.3 Module Structure

```lean
namespace Bimodal.Metalogic.Bundle

-- Section 1: Definition
def Succ ...
theorem Succ.g_persistence ...
theorem Succ.f_step ...

-- Section 2: Relationship to CanonicalR
theorem Succ_implies_CanonicalR ...

-- Section 3: g/h Duality
theorem Succ_implies_h_content_reverse ...

-- Section 4: Single-step Forcing
lemma neg_FF_eq_GG_neg ...
lemma G_neg_implies_not_F ...
theorem single_step_forcing ...

end Bimodal.Metalogic.Bundle
```

---

## 8. Mathlib Lemmas to Use

| Lemma | Type | Usage |
|-------|------|-------|
| `Set.subset_union_left` | `s ⊆ s ∪ t` | F-step: resolved case |
| `Set.subset_union_of_subset_right` | `s ⊆ u → s ⊆ t ∪ u` | F-step: deferred case |
| `Set.mem_union` | `x ∈ s ∪ t ↔ x ∈ s ∨ x ∈ t` | Disjunction from F-step |
| `Or.resolve_right` | `a ∨ b → ¬b → a` | Final step in forcing theorem |

---

## 9. Complexity Assessment

| Component | Lines | Difficulty | Blocking Risk |
|-----------|-------|------------|---------------|
| Succ definition | 5 | Trivial | None |
| Accessor lemmas | 4 | Trivial | None |
| Succ_implies_CanonicalR | 2 | Trivial | None |
| Succ_implies_h_content_reverse | 3 | Trivial | None |
| neg_FF_eq_GG_neg | 5 | Easy | None |
| G_neg_implies_not_F | 8 | Easy | None |
| single_step_forcing | 20 | Moderate | None |

**Total Estimated Lines**: 50-60
**Overall Difficulty**: Low-Moderate
**Blocking Dependencies**: None - all prerequisites exist

---

## 10. Verification Checklist

Before marking task complete, verify:

- [ ] `lake build Bimodal.Metalogic.Bundle.SuccRelation` succeeds
- [ ] No sorries in the file
- [ ] All three main theorems proven:
  - [ ] `Succ_implies_CanonicalR`
  - [ ] `Succ_implies_h_content_reverse`
  - [ ] `single_step_forcing`
- [ ] Documentation comments for each definition/theorem

---

## 11. Future Dependencies

This file will be used by:
- **Task 11** (CanonicalTask relation): Builds chains of Succ steps
- **Task 12** (TaskFrame axioms): Proves compositionality using Succ chains
- **Task 13** (Bounded witness): Uses single_step_forcing inductively
- **Task 15** (CanonicalR recovery): Shows CanonicalR = exists Succ-chain

---

## 12. Recommendations

1. **Implement in order**: Definition, accessors, Succ_implies_CanonicalR, duality, then forcing theorem
2. **Use `simp` for formula unfolding**: The neg_FF_eq_GG_neg lemma should be provable by `rfl` or simple `simp`
3. **Test single_step_forcing carefully**: This is the most complex proof; consider breaking into sub-lemmas if needed
4. **Add comprehensive docstrings**: This file establishes core concepts used throughout the discrete track
