# Teammate C Findings: Refactoring Path from CanonicalR to CanonicalTask

**Date**: 2026-03-21
**Focus**: How can we refactor away from CanonicalR to use CanonicalTask directly?

---

## Key Findings

### 1. Current Architecture: CanonicalR vs CanonicalTask

The codebase has two related but distinct relations:

**CanonicalR (Two-place, existential)**:
```lean
-- CanonicalFrame.lean:63-64
def CanonicalR (M M' : Set Formula) : Prop :=
  g_content M ⊆ M'
```

**CanonicalTask (Three-place, duration-indexed)**:
```lean
-- CanonicalTaskRelation.lean:167-170
def CanonicalTask (u : Set Formula) (n : Int) (v : Set Formula) : Prop :=
  match n with
  | Int.ofNat k => CanonicalTask_forward u k v
  | Int.negSucc k => CanonicalTask_backward u (k + 1) v
```

The relation between them:
- **CanonicalR** is the existential projection: `∃ n > 0, CanonicalTask M n N`
- **CanonicalTask** is the explicit duration-indexed version built from Succ chains

### 2. Proposed ExistsTask Definition

If we rename CanonicalR to ExistsTask, the cleanest definition would be:

**Option A (Most natural)**:
```lean
def ExistsTask (M N : Set Formula) : Prop :=
  ∃ d : Int, d > 0 ∧ CanonicalTask M d N
```

**Option B (Current equivalent)**:
```lean
def ExistsTask (M N : Set Formula) : Prop :=
  g_content M ⊆ N  -- Current CanonicalR definition
```

**Recommendation**: Keep Option B as the actual definition for efficiency, but document the equivalence with Option A. The `g_content M ⊆ N` formulation is more direct for proofs, while the existential characterization provides the semantic connection.

### 3. Audit of CanonicalR Uses by File

#### SaturatedChain.lean (8 uses)

| Line | Usage | Actual Need | Refactor Possibility |
|------|-------|-------------|---------------------|
| 93 | `CanonicalR w.world witness.world` - Lindenbaum witness | Existential (some d > 0) | Keep as ExistsTask |
| 105 | Same pattern - witness construction | Existential | Keep as ExistsTask |
| 353-374 | `canonicalMCS_has_future` - seriality witness | Just existence | Keep as ExistsTask |
| 363 | `Canonical.canonicalR_irreflexive` | **Irreflexivity axiom** | Core issue |
| 370 | `Canonical.canonicalR_irreflexive` | **Irreflexivity axiom** | Core issue |
| 373 | `canonicalR_transitive` | Transitivity chain | Could use CanonicalTask composition |
| 379-404 | `canonicalMCS_has_past` - symmetric to above | Existential | Keep as ExistsTask |
| 412-462 | `canonicalMCS_has_intermediate` | Density witness | True existential need |

**Assessment**: Uses are mixed:
- **Existential (essential)**: Lines 93, 105, 353-404 truly need "some duration exists"
- **Irreflexivity**: Lines 363, 370 are the problem spots
- **Transitivity**: Line 373 chains relations

#### FMCSTransfer.lean (2 uses)

| Line | Usage | Actual Need |
|------|-------|-------------|
| 214-229 | `CanonicalMCS.lt_of_canonicalR` | Derives strict order from CanonicalR |
| 274-280 | `CanonicalMCS.lt_of_canonicalR_past` | Past-direction order derivation |

**Assessment**: These use CanonicalR to derive the strict order on CanonicalMCS. The key insight is:
```lean
-- CanonicalR a.world b.world gives a ≤ b
-- Combined with irreflexivity (a ≠ b), gives a < b
```

This is an **essential use of irreflexivity** - the strict order depends on it.

#### CanonicalSerialFrameInstance.lean (4 uses)

| Line | Usage | Actual Need |
|------|-------|-------------|
| 54 | `canonicalR_strict` call | Strictness = CanonicalR(M,N) implies ¬CanonicalR(N,M) |
| 77 | `canonicalR_irreflexive` | **Irreflexivity axiom** |
| 100 | `canonicalR_strict` | Strictness for NoMinOrder |
| 123 | `canonicalR_irreflexive` | **Irreflexivity axiom** |

**Assessment**: This file proves NoMaxOrder and NoMinOrder instances using irreflexivity. These are **essential uses**.

#### TimelineQuotCanonical.lean (1 use)

| Line | Usage | Actual Need |
|------|-------|-------------|
| 96 | `Canonical.canonicalR_irreflexive` | Prevents self-accessibility in quotient |

**Assessment**: Used in `denseTimelineElem_mutual_le_implies_mcs_eq` to show mutual ≤ implies equality. **Essential use**.

#### ClosureSaturation.lean (2 uses)

| Line | Usage | Actual Need |
|------|-------|-------------|
| 391 | `Canonical.canonicalR_irreflexive` | Strictness in forward_F proof |
| 394 | `canonicalR_transitive` | Chain construction |

**Assessment**: Both support the temporal coherence proof. Irreflexivity is used for **strictness**.

#### IncrementalTimeline.lean (1 use)

| Line | Usage | Actual Need |
|------|-------|-------------|
| 156 | `Canonical.canonicalR_irreflexive` | Prevents cycle in chain |

**Assessment**: Used in `quot_same_class_same_mcs` - **essential use**.

### 4. Classification of Uses

**Category A: Truly need ∃d, CanonicalTask M d N (existential)**
- Witness construction (Lindenbaum extensions)
- Forward_F / backward_P existence proofs
- Density witnesses
- Approximately 60% of uses

**Category B: Need irreflexivity (the problem)**
- Deriving strict order from accessibility
- Showing M ≠ N from CanonicalR(M, N)
- Preventing self-loops in chains
- Approximately 30% of uses

**Category C: Could use CanonicalTask directly**
- Transitivity chains (can use CanonicalTask composition)
- Bounded witness constructions
- Approximately 10% of uses

### 5. TaskFrame's task_rel vs CanonicalR

The TaskFrame structure has:
```lean
structure TaskFrame (D : Type*) [...] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ...
  converse : ...
```

Key observations:
1. **TaskFrame.task_rel** is the three-place relation (W × D × W)
2. **CanonicalTask** mirrors this for the canonical model
3. **CanonicalR** is the existential projection losing duration info

For the canonical TaskFrame:
```lean
-- From TimelineQuotCanonical.lean:374
theorem timelineQuotParametricTaskFrame_task_rel :
    (@timelineQuotParametricTaskFrame root_mcs root_mcs_proof).task_rel =
    parametric_canonical_task_rel := rfl
```

The TaskFrame's task_rel is **parametric_canonical_task_rel** which IS CanonicalTask, not CanonicalR.

### 6. Irreflexivity of task_rel vs ExistsTask

**Critical distinction**:
- **task_rel irreflexivity**: `¬task_rel w d w` for d ≠ 0 (follows from strict semantics)
- **ExistsTask irreflexivity**: `¬ExistsTask w w` (axiom currently)

The task_rel version comes from temporal axiom 4 (`G(φ) → GG(φ)`) which blocks self-loops via:
```
If task_rel w d w for d > 0, then by converse: task_rel w (-d) w
By forward_comp: task_rel w 0 w
By nullity_identity: w = w (trivially true)
```

This does NOT give a contradiction! The issue is that `task_rel w d w` with d > 0 would violate the strict interpretation of G/F.

### 7. Paths Forward

**Path A: Eliminate ExistsTask uses entirely**

For each use, determine if a specific duration works:
- Seriality witnesses: `CanonicalTask M 1 N` (one step)
- Density witnesses: `CanonicalTask M d N` where d is computed
- Transitivity: Use `CanonicalTask` composition directly

**Challenge**: Many proofs construct Lindenbaum witnesses where the duration is unknown/irrelevant.

**Path B: Prove irreflexivity from CanonicalTask**

The naming set proof in CanonicalIrreflexivity.lean uses:
1. Construct naming set with H(¬p) and p
2. Under reflexive semantics, H(¬p) → ¬p gives contradiction

For CanonicalTask:
```
If CanonicalTask M d M for some d > 0:
  - By bounded_witness theorem, formulas are eventually forced
  - But self-loop creates an infinite descent
  - This might give a syntactic contradiction
```

**Status**: This approach is explored in teammate A and B findings - relies on F-nesting depth bounds.

**Path C: Accept as semantic axiom**

The irreflexivity expresses that no world is strictly in its own future/past - a semantic fact of strict temporal logic not derivable from the axiom system (Gabbay 1981).

### 8. Recommended Refactoring Strategy

**Step 1**: Rename CanonicalR to ExistsTask for clarity
```lean
abbrev ExistsTask := CanonicalR
```

**Step 2**: Document the equivalence
```lean
theorem ExistsTask_eq_exists_CanonicalTask :
    ExistsTask M N ↔ ∃ d : Int, d > 0 ∧ CanonicalTask M d N := by
  sorry  -- Requires full CanonicalR ↔ CanonicalTask equivalence
```

**Step 3**: For each Category C use (transitivity chains), refactor to use CanonicalTask directly

**Step 4**: For Category A uses, keep ExistsTask as convenience alias

**Step 5**: For Category B uses (irreflexivity), either:
- Prove from CanonicalTask if possible (teammate A/B research)
- Accept as semantic axiom with clear documentation

---

## Evidence/Examples

### Example: Transitivity Could Use CanonicalTask

```lean
-- Current (CanonicalR):
have h_trans := canonicalR_transitive M.world W M.world M.is_mcs h_R h_R'

-- Refactored (CanonicalTask):
have h_R1 : CanonicalTask M.world d1 W := ...
have h_R2 : CanonicalTask W d2 M.world := ...
have h_comp : CanonicalTask M.world (d1 + d2) M.world :=
  CanonicalTask_forward_comp M.world W M.world d1 d2 h_R1 h_R2
-- If d1 + d2 ≠ 0, contradiction with nullity_identity
```

### Example: Lindenbaum Witness Truly Existential

```lean
-- From CanonicalFrame.lean:122-138
theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : Formula.some_future psi ∈ M) :
    ∃ W : Set Formula, SetMaximalConsistent W ∧ CanonicalR M W ∧ psi ∈ W
```

Here we construct W via Lindenbaum. The duration d such that `CanonicalTask M d W` is **unknown** - we only know one exists. This is a genuine existential use.

---

## Confidence Level

**High confidence**:
- Classification of uses into three categories
- CanonicalTask vs CanonicalR architectural distinction
- TaskFrame's task_rel being three-place

**Medium confidence**:
- Possibility of proving irreflexivity from CanonicalTask bounds
- Feasibility of eliminating all ExistsTask uses

**Low confidence**:
- Whether complete refactoring to CanonicalTask is worth the effort
- Impact on proof complexity if we change the abstraction level

---

## Summary

The codebase has two layers:
1. **CanonicalTask** (three-place, duration-indexed) - aligns with TaskFrame
2. **CanonicalR** (two-place, existential) - convenience for duration-agnostic proofs

Renaming CanonicalR to **ExistsTask** would clarify this relationship.

Most uses of CanonicalR fall into three categories:
- **Existential witness construction** (60%) - Keep as ExistsTask
- **Irreflexivity for strictness** (30%) - Core problem
- **Transitivity chains** (10%) - Could refactor to CanonicalTask

The irreflexivity uses are the crux. Without resolving the irreflexivity axiom (either proving it or accepting it), the refactoring to CanonicalTask is incomplete. However, clarifying the naming (ExistsTask) and documenting the equivalence would improve code clarity regardless.
