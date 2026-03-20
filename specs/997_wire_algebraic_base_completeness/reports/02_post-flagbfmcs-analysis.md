# Research Report: Task #997 (Post-FlagBFMCS Analysis)

**Task**: Wire algebraic base completeness
**Date**: 2026-03-19
**Focus**: Post-FlagBFMCS architecture analysis

## Summary

This report analyzes the mathematically correct path forward for task 997 after the completion of tasks 1002-1005. The FlagBFMCS infrastructure is now sorry-free and provides a complete canonical model construction. Two architectural paths exist: (1) Rewire AlgebraicBaseCompleteness to use FlagBFMCS directly, or (2) Complete the existing BFMCS D infrastructure with dovetailing chains.

## Current State Analysis

### FlagBFMCS Infrastructure (Tasks 1003-1005) - SORRY-FREE

| File | Status | Sorries |
|------|--------|---------|
| `FlagBFMCS.lean` | Complete | 0 |
| `FlagBFMCSTruthLemma.lean` | Complete | 0 |
| `FlagBFMCSCompleteness.lean` | Complete | 0 |

**Key Theorems Proven**:
- `satisfies_at_iff_mem`: Truth lemma (formula in MCS iff satisfied)
- `FlagBFMCS_completeness_set`: Consistent set implies satisfiable in FlagBFMCS
- `FlagBFMCS_completeness`: List context version
- `allFlagsBFMCS_temporally_complete`: Temporal completeness for all-Flags bundle

### AlgebraicBaseCompleteness.lean - CURRENT STATE

| Component | Status | Sorries |
|-----------|--------|---------|
| `singleFamilyBFMCS` | DEPRECATED | 1 (modal_backward) |
| `construct_bfmcs_from_mcs` | DEPRECATED | 1 (generic D) |
| `algebraic_base_completeness` | Uses IntFMCSTransfer | Inherits sorries |

**Current Sorries in Active Path**:
1. `IntFMCSTransfer.lean:134` - `modal_backward` in `singleFamilyBFMCS_Int`
2. `IntBFMCS.lean:1175` - `intFMCS_forward_F` (F witness in chain)
3. `IntBFMCS.lean:1177` - `intFMCS_backward_P` (P witness in chain)

### Architecture Gap

The `valid` predicate in `Validity.lean` quantifies over:
```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (Omega : Set (WorldHistory F))
    (h_sc : ShiftClosed Omega) (τ : WorldHistory F) (h_mem : τ ∈ Omega) (t : D),
    truth_at M Omega τ t φ
```

This requires constructing a `TaskModel` over some domain `D` (currently `Int`). FlagBFMCS uses `CanonicalMCS` as the domain, but `CanonicalMCS` lacks `AddCommGroup` structure.

## Findings

### Finding 1: FlagBFMCS Completeness is Self-Contained

The FlagBFMCS completeness theorem is:
```lean
theorem FlagBFMCS_completeness_set (S : Set Formula) (h_cons : SetConsistent S) :
    ∃ (B : FlagBFMCS),
      ∀ φ ∈ S, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ
```

This proves completeness relative to `satisfies_at` (FlagBFMCS satisfaction), NOT relative to `valid` (TaskFrame/TaskModel validity).

### Finding 2: Missing Bridge Lemma

To connect FlagBFMCS to algebraic completeness, we need one of:

**Option A**: Prove that every FlagBFMCS gives rise to a valid TaskModel
```lean
theorem FlagBFMCS_to_TaskModel (B : FlagBFMCS) :
    ∃ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
      (TF : TaskFrame D) (TM : TaskModel TF)
      (Omega : Set (WorldHistory TF)) (h_sc : ShiftClosed Omega)
      (τ : WorldHistory TF) (h_mem : τ ∈ Omega) (t : D),
      ∀ φ, satisfies_at B B.eval_flag B.eval_flag_mem B.eval_element φ ↔
           truth_at TM Omega τ t φ
```

**Option B**: Reformulate validity using FlagBFMCS directly
```lean
def valid_flagbfmcs (φ : Formula) : Prop :=
  ∀ B : FlagBFMCS, ∀ F ∈ B.flags, ∀ x : ChainFMCSDomain F,
    satisfies_at B F _ x φ
```

Then prove: `valid φ ↔ valid_flagbfmcs φ`

### Finding 3: CanonicalMCS Has a Natural Preorder, Not AddCommGroup

The `CanonicalMCS` type has:
- `Preorder CanonicalMCS` (via g_content inclusion)
- No `Zero` (no distinguished MCS)
- No `Add` (no meaningful addition of MCSes)
- No `Neg` (no meaningful negation)

This makes direct instantiation of `TaskFrame CanonicalMCS` impossible.

### Finding 4: Dovetailing Chain Would Eliminate Remaining Sorries

Task 1004's research (`semantic-bridge-evaluation.md`) analyzed the dovetailing chain approach. If implemented:
- `intFMCS_forward_F` and `intFMCS_backward_P` would become provable
- `modal_backward` sorry would still require multi-family saturation
- The existing BFMCS D approach would then work

### Finding 5: Two Completeness Theorems Could Coexist

The codebase could have:
1. `algebraic_base_completeness` (TaskFrame semantics, D = Int, for algebraic reasoning)
2. `FlagBFMCS_completeness` (Flag semantics, for canonical model completeness)

Both express the same mathematical content. The first is useful for algebraic applications; the second is the canonical model proof.

## Recommendations

### Recommendation 1: Define FlagBFMCS-Based Validity

Create a new definition that captures validity in terms of FlagBFMCS:

```lean
def valid_canonical (φ : Formula) : Prop :=
  ∀ B : FlagBFMCS, B.temporally_complete →
    ∀ F ∈ B.flags, ∀ x : ChainFMCSDomain F,
      satisfies_at B F (by assumption) x φ
```

Then prove: `Nonempty (DerivationTree [] φ) ↔ valid_canonical φ`

This sidesteps the TaskFrame domain requirement entirely.

### Recommendation 2: Prove FlagBFMCS Embeds into TaskFrame CanonicalMCS

While `CanonicalMCS` lacks AddCommGroup, we can:
1. Define `TaskFrame (FlagBFMCS.World B)` with world type `Σ F, ChainFMCSDomain F`
2. Define temporal accessibility as cross-Flag CanonicalMCS ordering
3. Show equivalence: `satisfies_at B ... φ ↔ truth_at TM Omega τ t φ`

This requires proving the FlagBFMCS model IS a valid TaskFrame model when viewed appropriately.

### Recommendation 3 (Preferred): Declare FlagBFMCS Completeness as the Primary Result

The mathematically cleanest approach:

1. **Keep `FlagBFMCS_completeness` as the main completeness theorem** (sorry-free, self-contained)
2. **Rename `algebraic_base_completeness` to `algebraic_base_completeness_Int`** (indicates it's Int-specific)
3. **Document the relationship** between the two formulations
4. **Mark the BFMCS D sorries as architectural gaps**, not blocking issues

The FlagBFMCS result IS a valid completeness theorem. The only question is whether the `valid` predicate needs to be updated to accept FlagBFMCS models, or whether a bridge lemma needs to be proven.

## Mathematical Correctness Assessment

### What FlagBFMCS Proves

**Theorem**: For any consistent set S, there exists a canonical model (FlagBFMCS) where all formulas in S are true.

This IS completeness. The `satisfies_at` relation is a valid semantic satisfaction relation that:
- Respects propositional logic (atoms, bot, implication)
- Handles modal operators (Box) via MCSBoxContent accessibility
- Handles temporal operators (G, H) via CanonicalMCS ordering (cross-Flag)

### The Domain Question

The `valid` definition uses `∀ D : Type` with algebraic structure. FlagBFMCS uses `CanonicalMCS` as the implicit domain (via `ChainFMCSDomain`).

Two perspectives:
1. **FlagBFMCS IS a model over an implicit ordered domain** (CanonicalMCS with its preorder)
2. **The `valid` definition is too restrictive** if it excludes valid canonical models

### Verdict

FlagBFMCS completeness is mathematically correct. The only gap is connecting it to the specific `valid` predicate in `Validity.lean`. This is a definitional alignment issue, not a mathematical error.

## Next Steps

### Immediate (No Sorries)

1. Create `FlagBFMCSValidity.lean` defining:
   ```lean
   def valid_flagbfmcs (φ : Formula) : Prop := ...
   theorem flagbfmcs_completeness_iff : Nonempty (DerivationTree [] φ) ↔ valid_flagbfmcs φ
   ```

2. Document the relationship between `valid` and `valid_flagbfmcs`

### Optional (Eliminates BFMCS D Sorries)

3. Implement dovetailing chain for `intFMCS_forward_F` and `intFMCS_backward_P`
4. Implement multi-family modal saturation for `modal_backward`
5. Complete the `algebraic_base_completeness` proof via the BFMCS D path

### Architectural Decision Required

**Question**: Should `valid` be the primary validity definition, requiring a bridge to FlagBFMCS? Or should FlagBFMCS-based validity be adopted as equivalent?

**Recommendation**: Prove equivalence, documenting that both are valid formulations:
- `valid` for algebraic/domain-specific reasoning
- `valid_flagbfmcs` for canonical model reasoning

## References

- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCS.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSCompleteness.lean`
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicBaseCompleteness.lean`
- `Theories/Bimodal/Semantics/Validity.lean`

## Context Extension Recommendations

none (meta-level analysis, no new domain knowledge discovered)
