# CanonicalR Recovery Analysis: Keep vs Remove

**Date**: 2026-03-21
**Status**: Research Report
**Task**: 13 (canonical_r_recovery_from_canonical_task)
**Session**: sess_1774087088_3924ec
**Focus**: Evaluate whether to keep CanonicalR as derived notation or remove it entirely

---

## 1. Executive Summary

**Recommendation: Keep CanonicalR as a defined shorthand term**

The analysis shows that CanonicalR should be retained as a derived definition rather than removed entirely. This preserves backward compatibility, maintains proof ergonomics, and aligns with the architecture where CanonicalTask is the primitive relation but CanonicalR remains useful for duration-agnostic reasoning.

---

## 2. Current CanonicalR Definition and Role

### 2.1 Definition (CanonicalFrame.lean:63-64)

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

Where `g_content M = {phi | G phi ∈ M}`.

### 2.2 Fundamental Theorems

| Theorem | Type | Location |
|---------|------|----------|
| `canonical_forward_G` | `CanonicalR M M' → G phi ∈ M → phi ∈ M'` | CanonicalFrame.lean:86 |
| `canonical_forward_F` | `F phi ∈ M → ∃ W, MCS W ∧ CanonicalR M W ∧ phi ∈ W` | CanonicalFrame.lean:122 |
| `canonical_backward_H` | `CanonicalR_past M M' → H phi ∈ M → phi ∈ M'` | CanonicalFrame.lean:96 |
| `canonical_backward_P` | `P phi ∈ M → ∃ W, MCS W ∧ CanonicalR_past M W ∧ phi ∈ W` | CanonicalFrame.lean:151 |
| `canonicalR_transitive` | `CanonicalR M M' → CanonicalR M' M'' → CanonicalR M M''` | CanonicalFrame.lean:182 |

---

## 3. Codebase Usage Analysis

### 3.1 File Count by Directory

| Directory | Files Using CanonicalR | Notes |
|-----------|----------------------|-------|
| Theories/Bimodal/Metalogic/Bundle/ | 10 | Core canonical model |
| Theories/Bimodal/Metalogic/Algebraic/ | 9 | Representation theorems |
| Theories/Bimodal/Metalogic/StagedConstruction/ | 13 | Timeline constructions |
| Theories/Bimodal/Metalogic/Canonical/ | 4 | Timeline helpers |
| Theories/Bimodal/Boneyard/ | 21 | Deprecated attempts |
| **Active Total** | ~36 | Excluding Boneyard |

### 3.2 Critical Usage Patterns

**Pattern 1: Preorder definition (CanonicalFMCS.lean:113-121)**
```lean
noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
  le_refl a := Or.inl rfl
  le_trans a b c hab hbc := by
    rcases hab with rfl | hab
    · exact hbc
    · rcases hbc with rfl | hbc
      · exact Or.inr hab
      · exact Or.inr (canonicalR_transitive a.world b.world c.world a.is_mcs hab hbc)
```

**Pattern 2: TaskFrame task_rel (ParametricCanonical.lean:85-89)**
```lean
def parametric_canonical_task_rel (M : ParametricCanonicalWorldState) (d : D)
    (N : ParametricCanonicalWorldState) : Prop :=
  if d > 0 then CanonicalR M.val N.val
  else if d < 0 then CanonicalR N.val M.val
  else M = N  -- d = 0
```

**Pattern 3: Transitivity chains (used 50+ times)**
```lean
have h_R_MU : CanonicalR M U := canonicalR_transitive M U₁ U h_mcs h_R_MU₁ h_R_U₁U
```

**Pattern 4: Witness extraction (ConstructiveFragment.lean, FMCSTransfer.lean)**
```lean
obtain ⟨W, h_W_mcs, h_R, h_phi⟩ := canonical_forward_F M h_mcs phi h_F
```

---

## 4. Relationship to CanonicalTask

### 4.1 Recovery Proposition (from Report 17)

```
CanonicalR(u, v) ↔ ∃ n ≥ 1, CanonicalTask(u, n, v)
```

**Forward (⇐)**: If `CanonicalTask(u, n, v)` for n ≥ 1, there is a Succ-chain from u to v. Each Succ step includes G-persistence (g_content u ⊆ v). By temp_4 (`G phi → GG phi`), g_content is transitive along chains, so `g_content u ⊆ v`.

**Backward (⇒)**: Given `g_content u ⊆ v`, decompose into a finite Succ-chain. Under discrete axioms with successor existence, build a chain from u toward v. The bounded witness theorem guarantees all F-obligations resolve within finitely many steps.

### 4.2 Structural Comparison

| Aspect | CanonicalR | CanonicalTask |
|--------|-----------|---------------|
| Arity | Binary (MCS × MCS) | Ternary (MCS × ℤ × MCS) |
| Duration | Implicit (existential) | Explicit (integer n) |
| Primitive? | Currently yes; proposed derived | Proposed primitive |
| Definition | `g_content M ⊆ M'` | Inductive on Succ-chains |
| Transitivity | Via temp_4 | By chain concatenation |
| Witness bound | Unknown | Bounded by F-nesting depth |

### 4.3 CanonicalR as Derived from CanonicalTask

After implementing CanonicalTask (tasks 11-12), CanonicalR can be redefined as:

```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  ∃ n : ℕ, n ≥ 1 ∧ CanonicalTask M n M'

-- Or equivalently, preserving original semantics:
def CanonicalR' (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'

-- With proven equivalence:
theorem canonicalR_iff_canonicalTask (M M' : Set Formula) :
    CanonicalR M M' ↔ CanonicalR' M M' := ...
```

---

## 5. Analysis: Remove vs Keep

### 5.1 Option A: Remove CanonicalR Entirely

**Required Changes:**
1. Replace all `CanonicalR M M'` with `∃ n ≥ 1, CanonicalTask M n M'`
2. Replace `canonicalR_transitive` with chain concatenation proofs
3. Update Preorder instance to use `∃ n ≥ 0, CanonicalTask a n b`
4. Update parametric_canonical_task_rel to use CanonicalTask directly
5. Refactor 36+ active files

**Advantages:**
- Single canonical concept (eliminates conceptual redundancy)
- Forces explicit duration reasoning everywhere
- Cleaner semantic alignment with TaskFrame

**Disadvantages:**
- **Proof verbosity**: Many proofs need only "future accessibility", not specific duration. Requiring `∃ n, ...` everywhere adds existential elimination overhead.
- **Breaking changes**: Massive refactoring of 36+ files, high risk of regressions
- **Loss of abstraction**: CanonicalR abstracts over duration; useful for duration-agnostic reasoning
- **Ergonomic cost**: `canonicalR_transitive M M' M'' h h'` is cleaner than chaining CanonicalTask with existential intro/elim

### 5.2 Option B: Keep CanonicalR as Derived Definition

**Required Changes:**
1. Prove `CanonicalR ↔ ∃ n ≥ 1, CanonicalTask` (task 13)
2. Optionally redefine CanonicalR in terms of CanonicalTask (or keep as-is with equivalence theorem)
3. Prove backward-compatibility layer (canonical_forward_G, canonical_forward_F from new definitions)

**Advantages:**
- **Backward compatibility**: Zero breaking changes to downstream code
- **Proof ergonomics**: Duration-agnostic proofs remain simple
- **Conceptual clarity**: Two levels of abstraction serve different purposes:
  - CanonicalTask: Duration-precise reasoning (TaskFrame axioms, F-nesting bounds)
  - CanonicalR: Duration-agnostic reasoning (existence of future accessibility)
- **Incremental migration**: New code can use CanonicalTask; old code continues working

**Disadvantages:**
- Two related concepts to maintain (minimal overhead if well-documented)
- Slight conceptual redundancy (mitigated by clear derivation relationship)

---

## 6. Ergonomic Comparison

### 6.1 Transitivity Proof

**With CanonicalR (current):**
```lean
have h_R_MV : CanonicalR M V := canonicalR_transitive M W V h_mcs h_R_MW h_R_WV
```

**Without CanonicalR (Option A):**
```lean
have h_task_MV : ∃ n, n ≥ 1 ∧ CanonicalTask M n V := by
  obtain ⟨n1, hn1, h1⟩ := h_task_MW
  obtain ⟨n2, hn2, h2⟩ := h_task_WV
  exact ⟨n1 + n2, Nat.add_pos_of_pos_of_nonneg hn1 (Nat.zero_le _),
         canonicalTask_compose h1 h2⟩
```

**Verdict**: CanonicalR is significantly more ergonomic for transitivity chains.

### 6.2 Witness Extraction

**With CanonicalR (current):**
```lean
obtain ⟨W, h_W_mcs, h_R, h_phi⟩ := canonical_forward_F M h_mcs phi h_F
```

**With CanonicalTask (Option B, backward-compat layer):**
```lean
-- Same API preserved:
obtain ⟨W, h_W_mcs, h_R, h_phi⟩ := canonical_forward_F M h_mcs phi h_F
-- Or with explicit duration:
obtain ⟨W, n, h_W_mcs, h_task, h_phi, h_bound⟩ := canonical_forward_F_with_bound M h_mcs phi h_F
```

**Verdict**: With backward-compat layer, both APIs available.

### 6.3 Preorder Definition

**With CanonicalR (current):**
```lean
le a b := a = b ∨ CanonicalR a.world b.world
```

**Without CanonicalR (Option A):**
```lean
le a b := a = b ∨ ∃ n, n ≥ 1 ∧ CanonicalTask a.world n b.world
```

**Verdict**: CanonicalR is cleaner; existential in Preorder definition is awkward.

---

## 7. Architectural Perspective

### 7.1 Layered Abstraction

The proposed architecture creates a clean layered abstraction:

```
Layer 3 (highest): parametric_canonical_task_rel
                   - Uses CanonicalR for sign-based dispatch
                   - Duration-coarse (all positive d map to same CanonicalR)

Layer 2 (middle):  CanonicalR, CanonicalR_past
                   - Duration-agnostic binary accessibility
                   - Derived: CanonicalR ↔ ∃n≥1, CanonicalTask

Layer 1 (base):    CanonicalTask, Succ
                   - Duration-precise ternary relation
                   - Primitive: CanonicalTask built from Succ-chains
```

### 7.2 When to Use Each

| Use Case | Relation | Rationale |
|----------|----------|-----------|
| TaskFrame axiom proofs | CanonicalTask | Needs explicit duration for composition |
| Truth lemma F/P cases | CanonicalTask | Witness bound from F-nesting depth |
| Preorder/transitivity | CanonicalR | Duration-agnostic, cleaner proofs |
| MCS accessibility tests | CanonicalR | Just need "some future access" |
| Representation theorems | Both | CanonicalTask for ℤ instantiation, CanonicalR for parametric |

---

## 8. Implementation Recommendation

### 8.1 Recommended Approach

**Option B: Keep CanonicalR as derived shorthand**

1. **Define CanonicalTask** as the primitive relation (task 11)
2. **Prove CanonicalR recovery** (task 13, forward/backward directions)
3. **Prove backward-compatibility theorems**: Show existing canonical_forward_G, canonical_forward_F, etc. follow from new definitions
4. **Document relationship**: Clear docstrings explaining CanonicalR as duration-agnostic view of CanonicalTask
5. **Keep original definition**: `CanonicalR M M' := g_content M ⊆ M'` remains valid; equivalence theorem provides connection

### 8.2 Proof Structure for Task 13

```lean
-- Forward direction (easy): CanonicalTask → CanonicalR
theorem canonicalTask_implies_canonicalR {M M' : Set Formula} {n : ℕ}
    (h_mcs : SetMaximalConsistent M) (h_n : n ≥ 1)
    (h_task : CanonicalTask M n M') :
    CanonicalR M M' := by
  -- Succ-chains preserve g_content via temp_4 transitivity
  ...

-- Backward direction (harder): CanonicalR → ∃n, CanonicalTask
theorem canonicalR_implies_canonicalTask {M M' : Set Formula}
    (h_mcs_M : SetMaximalConsistent M) (h_mcs_M' : SetMaximalConsistent M')
    (h_R : CanonicalR M M') :
    ∃ n : ℕ, n ≥ 1 ∧ CanonicalTask M n M' := by
  -- Requires successor existence (task 12) and F-nesting depth bounds
  ...

-- Backward-compatibility layer
theorem canonical_forward_G' (M M' : Set Formula) {n : ℕ}
    (h_task : CanonicalTask M n M') (phi : Formula) (h_G : G phi ∈ M) :
    phi ∈ M' :=
  canonical_forward_G M M' (canonicalTask_implies_canonicalR ... h_task) phi h_G
```

---

## 9. Open Questions for Implementation

1. **Backward direction difficulty**: The recovery proof's backward direction requires decomposing `g_content M ⊆ M'` into Succ-steps. This may need:
   - Successor existence theorem (task 12)
   - F-nesting depth analysis for termination
   - Possibly additional axioms or well-foundedness arguments

2. **Dense case**: CanonicalR is used in the parametric (base) representation path. For dense temporal logic, DenseTask will be defined differently (via Cantor isomorphism). Ensure the recovery proof applies only to discrete case.

3. **Definitional vs proved equivalence**: Should CanonicalR be redefined in terms of CanonicalTask (making equivalence definitional) or kept with original definition and proved equivalent? The latter is safer for backward compatibility.

---

## 10. Conclusion

CanonicalR should be **retained as a derived shorthand** rather than removed entirely. The two-level abstraction (CanonicalR for duration-agnostic, CanonicalTask for duration-precise) serves different proof needs:

- **CanonicalTask** is the right primitive for discrete completeness (bypasses covering lemma, explicit duration bounds)
- **CanonicalR** remains useful for transitivity chains, Preorder definitions, and compatibility with existing code

The recovery theorem `CanonicalR ↔ ∃n≥1, CanonicalTask` bridges the two levels while preserving backward compatibility. This is the standard mathematical practice of maintaining multiple equivalent characterizations for different proof contexts.

---

## 11. Related Materials

- **Report 17**: [17_three-place-canonical-task-relation.md](../006_canonical_taskframe_completeness/reports/17_three-place-canonical-task-relation.md) - CanonicalTask definition, recovery proposition
- **Report 20**: [20_succ-based-bypass-of-covering-lemma.md](../006_canonical_taskframe_completeness/reports/20_succ-based-bypass-of-covering-lemma.md) - Succ relation, recovery proof strategy
- **CanonicalFrame.lean**: Definition of CanonicalR and key theorems
- **SuccRelation.lean**: Succ definition and single-step forcing theorem
- **ParametricCanonical.lean**: Task relation using CanonicalR
