# Teammate A Findings: Complete AddCommGroup Usage Audit

**Task**: 117 — Round 2: Audit every use of AddCommGroup operations
**Date**: 2026-05-08
**Focus**: Classify each usage as Essential / Convenience / Derivable

## Summary

AddCommGroup D is used in **6 semantic/metalogic files** (1,831 lines of semantics + ~1,200 lines of algebraic parametric code). The group operations serve **three distinct purposes**: (1) the task relation's duration algebra (d > 0, d = 0, d < 0 trichotomy and d + d' composition), (2) the time_shift automorphism (σ → σ(· + Δ)), and (3) the respects_task condition (duration = t - s). Purposes (1) and (2) are **Essential** to the current TaskFrame/WorldHistory formalism. Purpose (3) is **Essential** but could be reformulated. The truth_at definition itself uses **zero** group operations on D — it only needs LinearOrder D.

---

## File-by-File Audit

### 1. TaskFrame.lean (302 lines)

| Line | Operation | Classification | Notes |
|------|-----------|----------------|-------|
| 93 | `[AddCommGroup D]` in structure decl | Essential | Required for all three axioms |
| 104 | `task_rel w 0 u` | Essential (zero) | Nullity identity uses additive zero |
| 114 | `task_rel w (x + y) v` | Essential (addition) | Forward compositionality requires + |
| 114 | `0 ≤ x`, `0 ≤ y` | Essential (order + zero) | Non-negative guard |
| 122 | `task_rel u (-d) w` | Essential (negation) | Converse uses group inverse |
| 146 | backward_comp proof | Derivable | Uses `neg_nonneg`, `neg_add_rev`, `add_comm` — all derivable from the essential axioms |
| 157 | `h4 : -y + -x = -(x + y)` | Derivable | `neg_add_rev` + `add_comm` |
| 201 | `neg_eq_zero` | Derivable | In identity_frame converse proof |

**Verdict**: TaskFrame ESSENTIALLY requires {zero, addition, negation} — i.e., an additive group. The LinearOrder + IsOrderedAddMonoid are needed for the non-negative guard in forward_comp and for `0 ≤ x → 0 ≤ -x` in backward_comp. The full `AddCommGroup` (commutativity, associativity, inverse laws) is used.

### 2. WorldHistory.lean (418 lines)

| Line | Operation | Classification | Notes |
|------|-----------|----------------|-------|
| 69 | `[AddCommGroup D]` in structure decl | Essential | For respects_task and time_shift |
| 81 | convex: `∀ y, x ≤ y → y ≤ z → domain y` | Convenience (order only) | No group ops, just LinearOrder |
| 97 | `F.task_rel (states s hs) (t - s) (states t ht)` | **Essential (subtraction)** | Duration extraction: d = t - s |
| 239 | `domain := fun z => σ.domain (z + Δ)` | **Essential (addition)** | time_shift domain translation |
| 245-246 | `add_le_add_right`, `add_comm` | Essential | Convexity of shifted domain |
| 248 | `states z hz => σ.states (z + Δ) hz` | Essential (addition) | time_shift state translation |
| 256-258 | `(t + Δ) - (s + Δ) = t - s` via `add_sub_add_right_eq_sub` | **Essential** | Duration invariance under shift |
| 274-279 | `z + -Δ + Δ = z` via `add_assoc`, `neg_add_cancel`, `add_zero` | **Essential** | Inverse shift cancellation |
| 311-312 | Same cancellation pattern | Essential | Double shift states lemma |
| 328 | `add_zero` | Essential | time_shift by zero |
| 336-337 | `add_assoc`, `neg_add_cancel`, `add_zero` | Essential | Double shift neg domain |
| 349-350 | Same pattern | Essential | Double shift neg states |
| 370-394 | `neg_lt_neg`, `neg_le_neg`, `neg_neg_eq`, `neg_injective` | **Convenience** | Order reversal lemmas for temporal duality — could be stated differently |

**Verdict**: WorldHistory ESSENTIALLY requires addition (for time_shift), subtraction (for respects_task duration), and inverse + cancellation laws (for proving shift invertibility). The `respects_task` condition is the semantic anchor: "the task relation holds with duration t - s."

### 3. Truth.lean (703 lines)

| Line | Operation | Classification | Notes |
|------|-----------|----------------|-------|
| 89 | `[AddCommGroup D]` variable block | **Inherited** | Only because TaskFrame/WorldHistory require it |
| 119-131 | truth_at definition | **ZERO group ops** | Only uses `<` (LinearOrder) |
| 121 | atom: `∃ (ht : τ.domain t)` | Order only | No group ops |
| 125 | all_past: `s < t` | Order only | No group ops |
| 126 | all_future: `t < s` | Order only | No group ops |
| 127-128 | untl: `t < s ∧ ... ∧ ∀ r, t < r → r < s → ...` | Order only | No group ops |
| 129-130 | snce: `s < t ∧ ... ∧ ∀ r, s < r → r < t → ...` | Order only | No group ops |
| 242-243 | ShiftClosed def: `time_shift σ Δ ∈ Omega` | **Essential** | Requires time_shift (which needs AddCommGroup) |
| 369-698 | time_shift_preserves_truth | **Essential** | Massive proof using: `add_sub`, `add_sub_cancel_left`, `sub_sub_cancel`, `add_lt_add_right`, `sub_lt_sub_right`, `sub_add_cancel`, `add_comm`, etc. |

**Critical finding**: The **truth_at definition itself** (lines 119-131) uses **NO group operations at all**. It only uses `<` from LinearOrder. The AddCommGroup requirement is inherited from TaskFrame/WorldHistory and is only used in:
1. ShiftClosed definition (line 242-243)
2. time_shift_preserves_truth (lines 369-698) — the largest proof in the file, ~330 lines of group arithmetic

### 4. Validity.lean (315 lines)

| Line | Operation | Classification | Notes |
|------|-----------|----------------|-------|
| 73-78 | valid: `∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` | **Essential** | Quantifies over all D with group structure |
| 97-103 | semantic_consequence: same quantifier | Essential | Same |
| 123 | satisfiable: `[AddCommGroup D]` | Essential | Same |
| 132-133 | satisfiable_abs: `∃ (_ : AddCommGroup D)` | Essential | Existential |
| 148-151 | formula_satisfiable: same pattern | Essential | Same |
| 162-168 | valid_dense: adds `[DenselyOrdered D]` | Essential | Dense variant |
| 180-186 | valid_discrete: adds `[SuccOrder D] [PredOrder D]` | Essential | Discrete variant |
| 289 | `exists_lt t` (in valid_of_valid_all_future) | Convenience (Nontrivial) | Uses NoMinOrder from Nontrivial |

**Verdict**: Validity quantifies over D with AddCommGroup. If we weakened D to LinearOrder, the quantifier would range over MORE types, making soundness harder and completeness easier.

### 5. ParametricCanonical.lean (244 lines)

| Line | Operation | Classification | Notes |
|------|-----------|----------------|-------|
| 72 | variable block | Essential | |
| 84-88 | `parametric_canonical_task_rel`: `d > 0`, `d < 0`, `d = 0` | **Essential (trichotomy)** | Uses ordered group for sign analysis |
| 100-102 | nullity_identity proof: `lt_irrefl 0` | Essential (zero + order) | |
| 119-150 | forward_comp proof | **Essential** | Uses: `add_pos`, `add_zero`, `zero_add`, `le_antisymm`, `not_lt.mp/mpr`, `sub_eq_zero`, `neg_eq_of_add_eq_zero_right/left`, `neg_nonneg` |
| 160-182 | converse proof | **Essential** | Uses: `neg_neg_of_pos`, `neg_pos_of_neg`, `neg_zero`, `le_of_lt`, `not_lt.mpr` |
| 198-205 | ParametricCanonicalTaskFrame definition | Essential | Assembles the above |
| 221-225 | parametric_task_rel_pos: `d > 0` | Essential | Trichotomy |
| 237-242 | parametric_task_rel_neg: `d < 0` | Essential | Trichotomy |

**Verdict**: The canonical task relation is built on the sign trichotomy of D (positive, zero, negative). This fundamentally requires an ordered group. The forward_comp proof chains ExistsTask using duration addition.

### 6. ParametricHistory.lean (173 lines)

| Line | Operation | Classification | Notes |
|------|-----------|----------------|-------|
| 41 | variable block | Essential | |
| 61-82 | parametric_to_history | **Essential** | respects_task proof uses: `sub_pos`, `sub_nonneg`, `le_antisymm`, `not_lt.mp`, `sub_eq_zero` |
| 69-76 | duration analysis: `t - s > 0`, `t - s = 0` | Essential (subtraction) | Duration extraction |
| 117-118 | ShiftClosedParametricCanonicalOmega | **Essential** | Uses time_shift with delta : D |
| 128-135 | time_shift compose proof | **Essential** | Uses `add_assoc`, `add_comm` |
| 139-141 | shift by zero proof | Essential | Uses `add_zero` |
| 143-149 | shift-closure proof | Essential | Uses `delta + Δ'` (addition) |
| 157-159 | subset proof | Essential | Uses zero |

**Verdict**: Every operation is essential. The history conversion fundamentally uses subtraction for duration extraction and addition for shift composition.

---

## Cross-File Summary

### Operations Actually Used

| Operation | Files Using It | Count | Classification |
|-----------|---------------|-------|----------------|
| `0` (zero) | TaskFrame, ParametricCanonical, ParametricHistory | ~15 | Essential |
| `+` (addition) | TaskFrame, WorldHistory, Truth, ParametricCanonical, ParametricHistory | ~40 | Essential |
| `-` (subtraction = a + (-b)) | WorldHistory, Truth, ParametricHistory | ~50 | Essential |
| `-x` (negation) | TaskFrame, WorldHistory, Truth, ParametricCanonical | ~20 | Essential |
| `add_sub_add_right_eq_sub` | WorldHistory (time_shift) | 1 | Essential |
| `neg_add_cancel` + `add_zero` | WorldHistory (shift invertibility) | 6 | Essential |
| `add_assoc` | WorldHistory, ParametricHistory | 8 | Essential |
| `add_comm` | WorldHistory, Truth | 12 | Essential |
| `sub_sub_cancel` | Truth (time_shift_preserves_truth) | 8 | Essential |
| `add_sub_cancel_left` | Truth (time_shift_preserves_truth) | 8 | Essential |
| `sub_add_cancel` | Truth (time_shift_preserves_truth) | 2 | Essential |
| `add_lt_add_right` | WorldHistory, Truth | 10 | Essential |
| `sub_lt_sub_right` | Truth | 6 | Essential |
| `neg_nonneg` | TaskFrame (backward_comp) | 2 | Essential |
| `neg_lt_neg` / `neg_le_neg` | WorldHistory (order reversal) | 4 | Convenience |

### The Critical Separation

**What needs AddCommGroup**:
1. TaskFrame structure (zero, +, -, forward_comp, converse)
2. WorldHistory.respects_task (t - s duration)
3. WorldHistory.time_shift (z + Δ translation)
4. ShiftClosed / ShiftClosedParametricCanonicalOmega
5. time_shift_preserves_truth (330 lines of group arithmetic)
6. ParametricCanonicalTaskFrame (sign trichotomy)
7. parametric_to_history.respects_task (sub_pos, sub_nonneg)

**What only needs LinearOrder**:
1. **truth_at definition** (lines 119-131) — ZERO group ops
2. WorldHistory.convex — order only
3. WorldHistory.domain — predicate on D
4. All formula constructors in truth_at (atom, bot, imp, box, all_past, all_future, untl, snce)

---

## Key Finding: The "Two-Layer Architecture"

The codebase has a **natural two-layer separation**:

**Layer 1 (Order-only)**: truth_at, convex domains, validity quantifiers (if generalized)
- Needs: `[LinearOrder D]`
- Contains: The core semantics (what formulas MEAN)

**Layer 2 (Group-required)**: TaskFrame, WorldHistory.respects_task, time_shift, ShiftClosed, soundness of MF/TF
- Needs: `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
- Contains: The task infrastructure (how truth CONNECTS to tasks)

**The completeness proof goes through Layer 2** (it constructs a TaskFrame + WorldHistory). But the **truth evaluation itself** is Layer 1.

### Implications for Generalization

If we wanted validity to only require LinearOrder D:
1. We'd need to redefine `valid` to quantify over `[LinearOrder D]` instead of `[AddCommGroup D]`
2. We'd need a notion of "model" that doesn't require TaskFrame (no task_rel, no respects_task)
3. We'd lose: MF/TF axiom soundness (which requires time_shift), ShiftClosed
4. We'd gain: ability to use any linear order as D (including LimitDomSubtype)

Alternatively, we could keep TaskFrame for soundness but use a **weaker model** for completeness — one that doesn't require AddCommGroup. This would mean:
- Soundness: ∀ D with AddCommGroup, axioms are valid (current)
- Completeness: For any non-theorem φ, there exists D with **only LinearOrder** where φ fails
- Since LinearOrder D is a WEAKER requirement, this doesn't give completeness for the TaskFrame semantics — it gives it for a SIMPLER semantics

The question is: **can the same axioms be sound over the simpler (LinearOrder-only) semantics?** If yes, then the generalization works. If not (e.g., MF/TF need group structure), then we need a different approach.

## Confidence Level

**HIGH** — This is a complete line-by-line audit of every group operation in the semantic and parametric infrastructure. The classification is based on whether the operation appears in a definition (Essential), in a proof that could be rewritten (Derivable), or in auxiliary code (Convenience).

**Key uncertainty**: Whether MF/TF axiom soundness can be proved without group structure. The current soundness proof uses time_shift_preserves_truth, which uses ~50 group arithmetic lemmas. If MF/TF can be proved sound via a different mechanism (e.g., direct semantic argument on LinearOrder), the generalization is feasible.
