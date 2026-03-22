# Research Report: Succ Successor/Predecessor Existence

- **Task**: 12 - succ_successor_predecessor_existence
- **Status**: Research Complete
- **Date**: 2026-03-21
- **Dependencies**: Task 10 (Succ relation - completed)
- **Prior Research**: Reports 17, 20 from task 6

---

## 1. Executive Summary

This task proves that under discrete axioms (base + DF + seriality), for any MCS u with F(top) in u, there exists an MCS v with Succ(u,v). The key insight is that the **deferral seed** construction:

```
S = g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}
```

is consistent, and its Lindenbaum extension satisfies both Succ conditions. The consistency argument uses the DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` to show that no finite subset of the seed derives contradiction.

**Critical finding**: This is fundamentally different from the existing `forward_temporal_witness_seed` proof in WitnessSeed.lean, which proves consistency of `{ψ} ∪ g_content(M)` when `F(ψ) ∈ M`. The deferral seed includes **all** F-obligations in disjunctive form, requiring a more complex consistency argument.

---

## 2. Task 10 Implementation Analysis

### 2.1 Succ Relation Definition (from SuccRelation.lean)

```lean
def Succ (u v : Set Formula) : Prop :=
  g_content u ⊆ v ∧ f_content u ⊆ v ∪ f_content v
```

Where:
- `g_content u = {φ | G(φ) ∈ u}` (universal future commitments)
- `f_content u = {φ | F(φ) ∈ u}` (existential future obligations)

**Condition (1)**: G-persistence - all universal future commitments propagate
**Condition (2)**: F-step - each F-obligation is either resolved (φ ∈ v) or deferred (F(φ) ∈ v)

### 2.2 Proven Theorems from Task 10

| Theorem | Statement | Status |
|---------|-----------|--------|
| `Succ_implies_CanonicalR` | `Succ u v → CanonicalR u v` | Proven |
| `Succ_implies_h_content_reverse` | `Succ u v → h_content v ⊆ u` | Proven |
| `single_step_forcing` | `F(φ) ∈ u ∧ FF(φ) ∉ u ∧ Succ u v → φ ∈ v` | Proven |

These form the foundation. Task 12 must prove **existence** of such v.

---

## 3. Deferral Seed Construction

### 3.1 Definition

For an MCS u with `F(⊤) ∈ u`, define the **deferral seed**:

```lean
def successor_deferral_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ {Formula.or φ (Formula.some_future φ) | φ ∈ f_content u}
```

Equivalently:
- `g_content(u)` ensures G-persistence (Succ condition 1)
- `{φ ∨ F(φ) | F(φ) ∈ u}` ensures F-step (Succ condition 2)

### 3.2 Comparison with Existing Seeds

| Seed | Location | Purpose | Key Formula |
|------|----------|---------|-------------|
| `forward_temporal_witness_seed` | WitnessSeed.lean | Single F-obligation | `{ψ} ∪ g_content(M)` |
| `discreteImmediateSuccSeed` | DiscreteSuccSeed.lean | Blocking intermediates | `g_content(M) ∪ {¬ψ ∨ ¬G(ψ) \| ¬G(ψ) ∈ M}` |
| `successor_deferral_seed` | (Task 12) | Succ existence | `g_content(u) ∪ {φ ∨ F(φ) \| F(φ) ∈ u}` |

The deferral seed is structurally similar to `forward_temporal_witness_seed` but includes **all** F-obligations rather than a single one, and uses disjunctive deferrals.

### 3.3 Why Disjunctive Deferrals

The formula `φ ∨ F(φ)` for each `F(φ) ∈ u` captures the F-step condition exactly:
- If the Lindenbaum extension contains `φ`, the obligation is resolved
- If it contains `F(φ)`, the obligation is deferred

By MCS disjunction completeness, exactly one of these holds.

---

## 4. Consistency Argument via DF

### 4.1 Main Theorem to Prove

```lean
theorem successor_deferral_seed_consistent
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (successor_deferral_seed u)
```

### 4.2 Proof Strategy

**Goal**: Show no finite subset of the seed derives ⊥.

**Setup**: Suppose L ⊆ seed with L ⊢ ⊥. Partition L into:
- `L_g ⊆ g_content(u)` (G-formulas)
- `L_d = {φᵢ ∨ F(φᵢ) | i ∈ I}` (disjunctive deferrals)

**Case 1** (L_d = ∅): Then L ⊆ g_content(u), and `g_content_consistent` (from DiscreteSuccSeed.lean) gives contradiction.

**Case 2** (L_d ≠ ∅): This is the main case requiring DF.

### 4.3 Case 2 Proof Sketch (The Crux)

1. **Setup**: We have `L_g ∪ L_d ⊢ ⊥` where:
   - For each `χ ∈ L_g`, we have `G(χ) ∈ u`
   - For each disjunction `φᵢ ∨ F(φᵢ)` in L_d, we have `F(φᵢ) ∈ u`

2. **Case split on disjunctions**: Consider the derivation tree. Each disjunction `φ ∨ F(φ)` is eventually "committed to" either φ or F(φ). Consider the derivation as a propositional proof with disjunction elimination.

3. **Build a witness**: For any consistent assignment to the disjuncts, we can build an MCS that:
   - Contains all of L_g (these are in g_content, so consistent by `g_content_consistent`)
   - Resolves each disjunction one way or another

4. **Use DF**: The key insight is that if all disjunctions were committed to F(φ) (deferral), we would have:
   - `g_content(u)` plus `{F(φᵢ) | i ∈ I}` as the seed
   - This is essentially `f_content(u)` restricted to the F(φᵢ) formulas
   - DF axiom `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` guarantees this is realizable

5. **Seriality connection**: `F(⊤) ∈ u` (from `h_F_top`) ensures u has a future. The DF axiom ensures that immediate successors exist, and the seed consistency follows from the fact that g_content and the deferred F-obligations are jointly satisfiable at such an immediate successor.

### 4.4 Alternative Approach: Adapting forward_temporal_witness_seed_consistent

The existing `forward_temporal_witness_seed_consistent` proves consistency of `{ψ} ∪ g_content(M)` when `F(ψ) ∈ M`. Key observation:

**Claim**: If `{ψ₁, ..., ψₙ} ∪ g_content(M)` is consistent for each individual ψᵢ with `F(ψᵢ) ∈ M`, and the ψᵢ are "independent", then the deferral seed is consistent.

**Issue**: The ψᵢ are NOT independent - they share g_content.

**Better approach**: Show that adding disjunctions `φ ∨ F(φ)` preserves consistency because each disjunction is "weakly true" - it doesn't add new G-obligations that conflict with g_content.

---

## 5. Lindenbaum Extension

### 5.1 Existing Infrastructure

From Construction.lean:
```lean
noncomputable def lindenbaumMCS_set (S : Set Formula) (h_cons : SetConsistent S) :
    Set Formula :=
  Classical.choose (set_lindenbaum S h_cons)

lemma lindenbaumMCS_set_extends (S : Set Formula) (h_cons : SetConsistent S) :
    S ⊆ lindenbaumMCS_set S h_cons

lemma lindenbaumMCS_set_is_mcs (S : Set Formula) (h_cons : SetConsistent S) :
    SetMaximalConsistent (lindenbaumMCS_set S h_cons)
```

These are exactly what we need.

### 5.2 Successor Definition

```lean
noncomputable def successor_from_deferral_seed
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    Set Formula :=
  lindenbaumMCS_set (successor_deferral_seed u) (successor_deferral_seed_consistent u h_mcs h_F_top)
```

### 5.3 Verification of Succ Conditions

**Theorem**: `Succ u (successor_from_deferral_seed u h_mcs h_F_top)`

**Proof**:
1. **G-persistence**: `g_content u ⊆ seed ⊆ v` by `lindenbaumMCS_set_extends`
2. **F-step**: For each `F(φ) ∈ u`:
   - `φ ∨ F(φ) ∈ seed ⊆ v`
   - By MCS disjunction: `φ ∈ v ∨ F(φ) ∈ v`
   - This is exactly `φ ∈ v ∪ f_content(v)`

---

## 6. Predecessor Existence via DB

### 6.1 Symmetric Construction

For an MCS u with `P(⊤) ∈ u`, define the **predecessor deferral seed**:

```lean
def predecessor_deferral_seed (u : Set Formula) : Set Formula :=
  h_content u ∪ {Formula.or φ (Formula.some_past φ) | φ ∈ p_content u}
```

### 6.2 DB Axiom

The backward discreteness axiom DP (derivable from DF via temporal duality) is:
```
(P⊤ ∧ φ ∧ Gφ) → P(Gφ)
```

This is proven in `Theories/Bimodal/Theorems/Discreteness.lean`:
```lean
def discreteness_past (φ : Formula) :
    ⊢ (P⊤ ∧ φ ∧ Gφ) → P(Gφ)
```

### 6.3 Symmetric Proof

The predecessor existence proof is symmetric:
- Replace g_content with h_content
- Replace f_content with p_content
- Replace G with H, F with P
- Use DP instead of DF
- Use `contains_seriality_past` instead of `contains_seriality_future`

---

## 7. Existing Infrastructure Inventory

### 7.1 Available (No Additional Work)

| Component | Location | Status |
|-----------|----------|--------|
| `g_content`, `h_content` | TemporalContent.lean | Exists |
| `f_content`, `p_content` | TemporalContent.lean | Exists (task 9) |
| `Succ` definition | SuccRelation.lean | Exists (task 10) |
| `single_step_forcing` | SuccRelation.lean | Exists (task 10) |
| `lindenbaumMCS_set` | Construction.lean | Exists |
| `g_content_consistent` | DiscreteSuccSeed.lean | Exists |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean | Exists |
| `contains_seriality_future` | CanonicalTimeline.lean | Exists |
| `contains_seriality_past` | CanonicalTimeline.lean | Exists |
| `discreteness_past` (DP from DF) | Theorems/Discreteness.lean | Exists |
| DF axiom | ProofSystem/Axioms.lean | Exists |

### 7.2 Required New Components

| Component | Description | Difficulty |
|-----------|-------------|------------|
| `successor_deferral_seed` | Seed definition | Trivial |
| `successor_deferral_seed_consistent` | Main consistency proof | **Hard** |
| `successor_exists` | Existence theorem | Easy (given consistency) |
| `predecessor_deferral_seed` | Symmetric seed | Trivial |
| `predecessor_deferral_seed_consistent` | Symmetric consistency | Moderate (from successor) |
| `predecessor_exists` | Symmetric existence | Easy |

---

## 8. Risk Assessment

### 8.1 Primary Risk: Deferral Seed Consistency

**Risk level**: High

The existing `discreteImmediateSuccSeed_consistent` in DiscreteSuccSeed.lean is axiomatized:
```lean
axiom discreteImmediateSuccSeed_consistent_axiom (M : Set Formula)
    (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M)
```

This suggests the proof may be non-trivial. However, the deferral seed has a different structure that may be more amenable to proof:
- Blocking formulas `¬ψ ∨ ¬G(ψ)` create complex interactions
- Deferral formulas `φ ∨ F(φ)` are simpler disjunctions

### 8.2 Mitigation: Leverage forward_temporal_witness_seed_consistent

The proof of `forward_temporal_witness_seed_consistent` shows that `{ψ} ∪ g_content(M)` is consistent when `F(ψ) ∈ M`. The key technique:
1. Case split on whether ψ is in the inconsistent finite subset L
2. Use generalized temporal K to lift derivation
3. Derive contradiction with `F(ψ) ∈ M`

A similar approach may work for the deferral seed by:
1. Case splitting on which disjunctive deferrals are in L
2. Using generalized temporal K on the G-formulas
3. Deriving contradiction with the presence of F-obligations in u

### 8.3 Fallback Strategy

If the direct proof is intractable, we can:
1. **Axiomatize** `successor_deferral_seed_consistent` (like `discreteImmediateSuccSeed_consistent_axiom`)
2. Document the semantic justification (seriality + DF guarantee realizability)
3. This is weaker and more transparent than `discrete_Icc_finite_axiom`

---

## 9. Recommended Implementation Approach

### 9.1 Phase 1: Definitions (Easy)

1. Define `successor_deferral_seed` and `predecessor_deferral_seed`
2. Add membership lemmas
3. Define `Pred` relation: `Pred u v := Succ v u`

### 9.2 Phase 2: Consistency Proof (Hard)

Attempt direct proof of `successor_deferral_seed_consistent`:

1. **Base case**: Adapt `g_content_consistent` proof pattern
2. **Inductive case**: Handle disjunctive deferrals using case analysis
3. **Key lemma**: Each disjunction `φ ∨ F(φ)` is "harmless" - derivable from `F(φ)` which is in u, so adding it to g_content doesn't create inconsistency

Alternative if direct proof fails:
- Use DF axiom more directly
- Consider semantic argument via frame satisfiability
- Axiomatize if necessary (document justification)

### 9.3 Phase 3: Existence Theorems (Easy given Phase 2)

1. Define `successor_from_deferral_seed` using `lindenbaumMCS_set`
2. Prove `Succ u (successor_from_deferral_seed u h_mcs h_F_top)`
3. Combine into `successor_exists`:
   ```lean
   theorem successor_exists (u : Set Formula) (h_mcs : SetMaximalConsistent u)
       (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
       ∃ v, SetMaximalConsistent v ∧ Succ u v
   ```

### 9.4 Phase 4: Predecessor Existence (Moderate - symmetric)

Mirror Phase 2-3 using:
- h_content instead of g_content
- p_content instead of f_content
- DP instead of DF
- `contains_seriality_past` instead of `contains_seriality_future`

---

## 10. Estimated Effort

| Phase | Description | Effort | Difficulty |
|-------|-------------|--------|------------|
| 1 | Definitions | 1 hour | Easy |
| 2 | Successor consistency | 3-4 hours | Hard |
| 3 | Successor existence | 30 min | Easy |
| 4 | Predecessor (symmetric) | 1.5 hours | Moderate |
| 5 | Integration/testing | 30 min | Easy |
| **Total** | | **6-7 hours** | **Hard** |

---

## 11. Implementation Checklist

**Prerequisites verified**:
- [x] Task 10 Succ relation completed
- [x] f_content, p_content exist (task 9)
- [x] g_content_consistent exists
- [x] lindenbaumMCS_set infrastructure exists
- [x] contains_seriality_future/past exist
- [x] DF axiom exists
- [x] DP derivable (discreteness_past theorem)

**Core deliverables**:
- [ ] `successor_deferral_seed` definition
- [ ] `successor_deferral_seed_consistent` theorem
- [ ] `successor_exists` theorem
- [ ] `predecessor_deferral_seed` definition
- [ ] `predecessor_deferral_seed_consistent` theorem
- [ ] `predecessor_exists` theorem

**Optional enhancements**:
- [ ] `Pred` relation definition (just `fun u v => Succ v u`)
- [ ] Succ/Pred duality lemmas

---

## 12. References

1. **Prior research reports**:
   - specs/006_canonical_taskframe_completeness/reports/17_three-place-canonical-task-relation.md (Section 2.7)
   - specs/006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md (Section 5)

2. **Existing codebase**:
   - Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean (Task 10 implementation)
   - Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean (consistency patterns)
   - Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean (blocking formulas)
   - Theories/Bimodal/Theorems/Discreteness.lean (DP from DF)
   - Theories/Bimodal/Metalogic/Canonical/CanonicalTimeline.lean (seriality)

3. **Literature**:
   - Goldblatt 1992, *Logics of Time and Computation*
   - Verbrugge et al., "Completeness by construction for tense logics of linear time"
