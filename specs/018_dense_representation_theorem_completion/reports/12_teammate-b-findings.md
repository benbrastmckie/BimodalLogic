# CanonicalR to ExistsTask Refactoring Analysis

**Date**: 2026-03-21
**Task**: 18 (Dense Representation Theorem)
**Scope**: Audit CanonicalR usage and assess refactoring to ExistsTask

---

## 1. Executive Summary

The codebase has **1,737 occurrences of CanonicalR across 59 Lean files**. The refactoring from CanonicalR to ExistsTask would be substantial but follows a clear pattern. The key insight is that CanonicalR is already treated as a **derived notion** in the codebase - it is defined as `g_content M <= M'` and can be recovered from CanonicalTask via the equivalence:

```
CanonicalR(u, v)  <->  exists n >= 1, CanonicalTask(u, n, v)
```

Renaming to `ExistsTask` would make this derivation explicit in the name itself.

---

## 2. CanonicalR Definition and Location

**Primary Definition** (`CanonicalFrame.lean:63`):
```lean
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

**Companion** (`CanonicalFrame.lean:71`):
```lean
def CanonicalR_past (M M' : Set Formula) : Prop :=
  h_content M ⊆ M'
```

Both definitions live in `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean`.

---

## 3. CanonicalTask Definition (The Primary Three-Place Relation)

**Definition** (`CanonicalTaskRelation.lean:167`):
```lean
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v
```

Where `CanonicalTask_forward` is defined inductively via the `Succ` relation (single-step successor).

**Key Theorems**:
- `CanonicalTask_nullity_identity`: `CanonicalTask(u, 0, v) <-> u = v`
- `CanonicalTask_forward_comp`: Chain concatenation
- `CanonicalTask_converse`: `CanonicalTask(u, n, v) <-> CanonicalTask(v, -n, u)`

---

## 4. DenseTask Definition (Dense Analogue)

**Definition** (`DenseTaskRelation.lean:74`):
```lean
def DenseTask (u q v : TimelineQuot root_mcs root_mcs_proof) : Prop :=
  @HAdd.hAdd _ _ _
    (@instHAdd _ (timelineQuotAddCommGroup root_mcs root_mcs_proof).toAdd) u q = v
```

DenseTask is the **deterministic** task relation where `u + q = v` using the transferred group structure from the Cantor isomorphism `TimelineQuot ≃o Q`.

**Relationship to CanonicalTask**:
| Property | CanonicalTask (Discrete) | DenseTask (Dense) |
|----------|-------------------------|-------------------|
| Duration Type | Int | Rat (via TimelineQuot) |
| Determinism | Non-deterministic (multiple successors) | Deterministic (unique target) |
| Building Block | Succ (immediate successor) | Group addition via Cantor |
| TaskFrame Instance | `CanonicalTaskTaskFrame` | `DenseTaskFrame` |

---

## 5. File-by-File Impact Assessment

### Critical Files (10+ occurrences)

| File | Count | Role | Refactoring Impact |
|------|-------|------|-------------------|
| `DensityFrameCondition_StrictAttempt.lean` | 394 | Boneyard (strict density) | Low (archived) |
| `DenseQuotient.lean` | 157 | Boneyard (Int/Rat) | Low (archived) |
| `DensityFrameCondition.lean` | 83 | Staged density proof | Medium |
| `IntBFMCS.lean` | 77 | BFMCS construction | Medium |
| `StagedExecution.lean` | 71 | Staged timeline | Medium |
| `DenseTimeline.lean` | 56 | Dense timeline | Medium |
| `CanonicalRecovery.lean` | 48 | Recovery theorems | **HIGH** |
| `DovetailedCoverageReach.lean` | 28 | Dovetailing | Medium |
| `CanonicalFrame.lean` | 24 | Definition site | **HIGH** |
| `CanonicalFMCS.lean` | 27 | MCS Preorder | **HIGH** |

### Active Non-Boneyard Files (59 total, ~35 active)

Files requiring changes in active codebase:
1. **Bundle** (core definitions): 12 files
2. **StagedConstruction** (dense/discrete timeline): 15 files
3. **Algebraic** (parametric completeness): 8 files
4. **Domain** (duration types): 3 files
5. **Canonical** (seriality, irreflexivity): 4 files

---

## 6. Recovery Architecture (CanonicalRecovery.lean)

The file `CanonicalRecovery.lean` already documents the intended two-level abstraction:

```
- **CanonicalTask** (Layer 1): Duration-precise primitive built from Succ-chains.
  Used for TaskFrame axiom proofs and F-nesting depth bounds.
- **CanonicalR** (Layer 2): Duration-agnostic derived relation (`g_content M ⊆ M'`).
  Used for transitivity chains, Preorder definitions, and backward compatibility.
```

**Key Theorems Already Proven**:
- `canonicalTask_forward_MCS_implies_canonicalR`: MCS-chain -> CanonicalR
- `canonicalTask_forward_one_implies_canonicalR`: 1-step -> CanonicalR
- `canonicalTask_forward_MCS_pos_implies_canonicalR`: n >= 1 chain -> CanonicalR

**Still Sorry**:
- `canonicalR_implies_canonicalTask_forward`: The backward direction (CanonicalR -> CanonicalTask)

---

## 7. Proposed Refactoring Strategy

### Option A: Full Rename (ExistsTask)

**Definition**:
```lean
def ExistsTask (M M' : Set Formula) : Prop :=
  ∃ n : Nat, n ≥ 1 ∧ CanonicalTask_forward M n M'
```

**Changes Required**:
1. Add `ExistsTask` definition to `CanonicalFrame.lean`
2. Prove equivalence: `ExistsTask <-> CanonicalR`
3. Deprecate `CanonicalR` with `@[deprecated ExistsTask]`
4. Update 59 files (1,737 occurrences)
5. Update all spec documents referencing CanonicalR

**Effort Estimate**: 4-6 hours for mechanical replacement, 2-4 hours for verification

### Option B: Add ExistsTask as Alias

**Definition**:
```lean
/-- ExistsTask is the existential projection of CanonicalTask to a binary relation.
    This makes explicit that CanonicalR is a derived notion from the primary
    three-place task relation. -/
abbrev ExistsTask := CanonicalR
```

**Changes Required**:
1. Add alias in `CanonicalFrame.lean`
2. Update comments/docstrings to reference ExistsTask
3. New code uses ExistsTask; old code remains valid

**Effort Estimate**: 1-2 hours

### Option C: Documentation-Only

**Changes**:
1. Add module-level comment explaining CanonicalR = ExistsTask conceptually
2. Update CanonicalR docstring to reference derivation from CanonicalTask
3. No code changes

**Effort Estimate**: 30 minutes

---

## 8. Comment Improvement Recommendations

### Current Confusing Comments

**CanonicalFrame.lean**:
```lean
/--
Canonical future relation: `M` sees `M'` in the future iff `g_content M ⊆ M'`.
-/
```

**Suggested Improvement**:
```lean
/--
Canonical future relation: `M` sees `M'` in the future iff `g_content M ⊆ M'`.

**Note**: This is a *derived* notion from the primary three-place `CanonicalTask`
relation. Semantically, `CanonicalR(M, M')` is equivalent to
`∃ n ≥ 1, CanonicalTask(M, n, M')` (existence of some forward path without
explicit duration). For duration-precise reasoning, use `CanonicalTask` directly.
See `CanonicalRecovery.lean` for the formal equivalence proof.
-/
```

**CanonicalFMCS.lean** (line ~37):
Current text emphasizes CanonicalR as the Preorder relation without noting its derived status.

**ParametricCanonical.lean** (line ~29):
```lean
- **d > 0**: `CanonicalR M.val N.val` (g_content M ⊆ N — forward temporal accessibility)
```

Could note: "equivalently, `∃ n ≥ 1, CanonicalTask(M.val, n, N.val)`"

---

## 9. DenseTask vs CanonicalTask Relationship

**Question**: Is DenseTask the dense analogue of CanonicalTask?

**Answer**: Yes, but with a key structural difference:

| Aspect | CanonicalTask | DenseTask |
|--------|---------------|-----------|
| Scope | Discrete (Int duration) | Dense (Rat duration) |
| Construction | Inductive (Succ chains) | Algebraic (group operation) |
| Determinism | Non-deterministic | Deterministic |
| World State | CanonicalMCS | TimelineQuot |

Both satisfy the TaskFrame axioms (nullity, composition, converse), so they are both valid `task_rel` implementations for their respective settings.

The relationship:
- **Discrete**: `CanonicalR(u,v) <-> ∃ n ≥ 1, CanonicalTask(u, n, v)`
- **Dense**: `CanonicalR(u,v) <-> ∃ q > 0, DenseTask(u, q, v)` (via timeline embedding)

---

## 10. Zero-Debt Implications

The refactoring from CanonicalR to ExistsTask:
- **Does NOT introduce any sorry** (purely renaming/documentation)
- **Clarifies the architecture** (primary CanonicalTask, derived ExistsTask)
- **Reduces future confusion** about which relation to use

**Recommendation**: Option B (alias with deprecation notice) provides the best balance of clarity and minimal disruption.

---

## 11. Files That Would Need Updates (Option A)

### Must Change (definition/core usage)
1. `CanonicalFrame.lean` - Definition site
2. `CanonicalRecovery.lean` - Recovery theorems
3. `CanonicalFMCS.lean` - Preorder definition
4. `CanonicalConstruction.lean` - TaskFrame construction
5. `CanonicalTaskRelation.lean` - Task relation bridge

### Would Benefit from Updates (theorem statements)
6. `DensityFrameCondition.lean`
7. `TimelineQuotCanonical.lean`
8. `StagedTimeline.lean`
9. `DovetailedCoverageReach.lean`
10. `IntBFMCS.lean`

### Comment-Only Updates
All remaining 49 files with CanonicalR references

---

## 12. Conclusions

1. **CanonicalR is already treated as derived** in the codebase documentation and architecture, but the name does not make this explicit.

2. **CanonicalTask (discrete) and DenseTask (dense) are the primary task relations**, both instantiating TaskFrame for their respective duration types.

3. **Renaming to ExistsTask** would align naming with semantics: the relation captures "there exists some positive-duration task" without specifying the duration.

4. **Recommended approach**: Option B (alias) followed by gradual migration to ExistsTask in new code. This preserves backward compatibility while establishing clearer conceptual naming.

5. **Estimated effort**: 1-2 hours for alias + documentation; 4-8 hours for full migration.
