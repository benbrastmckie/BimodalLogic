# Implementation Plan: Refactor Mutual Recursion in Semantics.lean

- **Task**: 419 - Refactor mutual recursion between verifies/falsifies
- **Status**: [NOT STARTED]
- **Effort**: 4-5 hours
- **Priority**: Low
- **Dependencies**: None (subtask of 400, but independent of 417/418)
- **Research Inputs**: .claude/specs/419_refactor_mutual_recursion_semantics/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-formats.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Replace the mutual recursion between `verifies` and `falsifies` in `Theories/Logos/SubTheories/Foundation/Semantics.lean` with a single `eval` function parameterized by a `Polarity` type. This eliminates Lean's internal `PSum`-based compilation of mutual recursion, enabling cleaner structural recursion on `ConstitutiveFormula` and reducing well-founded recursion elaboration overhead.

### Research Integration

Integrated from `reports/research-001.md`:
- Polarity flag approach recommended over Bool flag (type safety, self-documenting)
- `eval` function uses structural recursion on formula structure
- Backward-compatible API via `abbrev verifies`/`abbrev falsifies` wrappers
- All existing theorems become simpler or remain equivalent

## Goals & Non-Goals

**Goals**:
- Eliminate mutual recursion between `verifies` and `falsifies`
- Maintain backward-compatible API (existing code using `verifies`/`falsifies` unchanged)
- Simplify proof terms and reduce elaboration time
- Add useful `@[simp]` lemmas for `Polarity.swap`

**Non-Goals**:
- Changing the semantic behavior (must preserve exact semantics)
- Modifying `evalTerm` (unrelated to this refactoring)
- Refactoring downstream files beyond what's needed for compatibility

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Breaking existing theorems | High | Verify each theorem compiles after `eval` change; proofs should simplify |
| API breakage for downstream files | Medium | Use `abbrev` wrappers to maintain exact signatures |
| Unexpected termination check failures | Medium | `eval` is structural on formula; use `lean_goal` to verify recursion |
| Performance regression | Low | The change is expected to improve performance; verify with build timing |

## Implementation Phases

### Phase 1: Define Polarity Type and Core Infrastructure [NOT STARTED]

**Goal**: Add the `Polarity` inductive type with `swap` function and `@[simp]` lemmas.

**Tasks**:
- [ ] Add `Polarity` inductive type with `verify` and `falsify` constructors
- [ ] Add `Polarity.swap` function
- [ ] Add `@[simp]` lemmas: `swap_verify`, `swap_falsify`, `swap_swap`
- [ ] Verify clean compilation with `lean_diagnostic_messages`

**Location**: Insert after line 31 (after `namespace Logos.SubTheories.Foundation`)

**Code to add**:
```lean
/-- Polarity for verification vs falsification mode -/
inductive Polarity where
  | verify : Polarity
  | falsify : Polarity
  deriving DecidableEq, Repr

namespace Polarity

/-- Swap polarity: verify <-> falsify -/
def swap : Polarity -> Polarity
  | .verify => .falsify
  | .falsify => .verify

@[simp] lemma swap_verify : swap .verify = .falsify := rfl
@[simp] lemma swap_falsify : swap .falsify = .verify := rfl
@[simp] lemma swap_swap (p : Polarity) : p.swap.swap = p := by cases p <;> rfl

end Polarity
```

**Timing**: 30 minutes

---

### Phase 2: Implement Unified eval Function [NOT STARTED]

**Goal**: Replace the `mutual` block with a single `eval` function parameterized by `Polarity`.

**Tasks**:
- [ ] Comment out existing `mutual` block (lines 47-139)
- [ ] Define `eval` function with all 9 formula cases
- [ ] Handle polarity-dependent cases: `atom`, `pred`, `bot`, `top`, `and`, `or`, `ident`
- [ ] Handle polarity-swapping case: `neg` (uses `pol.swap`)
- [ ] Handle polarity-preserving case: `lambdaApp`
- [ ] Verify structural recursion accepted by Lean

**Pattern for each case**:
```lean
| ConstitutiveFormula.atom p =>
    match pol with
    | .verify => s ∈ (M.interp.getSentenceLetter p).verifiers
    | .falsify => s ∈ (M.interp.getSentenceLetter p).falsifiers
| ConstitutiveFormula.neg φ =>
    eval M σ pol.swap s φ  -- Flip polarity
```

**Key semantic mappings**:
| Formula | Verify Semantics | Falsify Semantics |
|---------|------------------|-------------------|
| `atom p` | `s ∈ verifiers` | `s ∈ falsifiers` |
| `bot` | `False` | `s = null` |
| `top` | `True` | `s = full` |
| `neg φ` | `eval pol.swap` | `eval pol.swap` |
| `and φ ψ` | `∃ t u, fusion ∧ both verify` | `falsify φ ∨ falsify ψ ∨ fusion-falsify` |
| `or φ ψ` | `verify φ ∨ verify ψ ∨ fusion-verify` | `∃ t u, fusion ∧ both falsify` |
| `ident φ ψ` | `null ∧ ∀ verify-equiv ∧ ∀ falsify-equiv` | `null ∧ (¬verify-equiv ∨ ¬falsify-equiv)` |
| `lambdaApp` | `eval with updated σ` | `eval with updated σ` |

**Timing**: 1.5 hours

---

### Phase 3: Define Backward-Compatible Wrappers [NOT STARTED]

**Goal**: Define `verifies` and `falsifies` as abbreviations to maintain API compatibility.

**Tasks**:
- [ ] Remove the old `mutual` block entirely (after verifying `eval` works)
- [ ] Define `verifies` as `abbrev` calling `eval ... .verify ...`
- [ ] Define `falsifies` as `abbrev` calling `eval ... .falsify ...`
- [ ] Preserve argument order: `M`, `σ`, `s`, `φ`
- [ ] Preserve docstrings for API documentation

**Code**:
```lean
/--
Verification relation: M, σ, s ⊩⁺ φ

A state s verifies formula φ relative to constitutive model M and
variable assignment σ.
-/
abbrev verifies (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (s : M.frame.State) (φ : ConstitutiveFormula) : Prop :=
  eval M σ .verify s φ

/--
Falsification relation: M, σ, s ⊩⁻ φ

A state s falsifies formula φ relative to constitutive model M and
variable assignment σ.
-/
abbrev falsifies (M : ConstitutiveModel) (σ : VarAssignment M.frame)
    (s : M.frame.State) (φ : ConstitutiveFormula) : Prop :=
  eval M σ .falsify s φ
```

**Timing**: 30 minutes

---

### Phase 4: Update BasicTheorems Section [NOT STARTED]

**Goal**: Update the theorems in `BasicTheorems` to work with the new definitions.

**Tasks**:
- [ ] Update `neg_verifies_iff_falsifies` - should become trivial via `rfl` or `simp`
- [ ] Update `neg_falsifies_iff_verifies` - should become trivial
- [ ] Update `double_neg_verifies` - uses `swap_swap` simp lemma
- [ ] Update `bot_not_verified` - minor adjustment
- [ ] Update `top_verified` - minor adjustment
- [ ] Update `bot_falsified_iff_null` - minor adjustment
- [ ] Update `top_falsified_iff_full` - minor adjustment
- [ ] Verify all theorems compile without errors

**Expected simplifications**:
- `neg_verifies_iff_falsifies`: Becomes `eval M σ .verify s (.neg φ) ↔ eval M σ .falsify s φ` which is definitionally true
- `double_neg_verifies`: Uses `swap_swap` lemma: `eval pol.swap.swap = eval pol`

**Timing**: 1 hour

---

### Phase 5: Update content Function and Verify Build [NOT STARTED]

**Goal**: Ensure `content` function and all downstream files compile correctly.

**Tasks**:
- [ ] Verify `content` function still works (uses `verifies`/`falsifies` abbreviations)
- [ ] Run `lake build Logos.SubTheories.Foundation.Semantics`
- [ ] Run `lake build Logos.SubTheories.Foundation` (imports Semantics)
- [ ] Run `lake build Logos.SubTheories.Explanatory.Truth` (imports Semantics)
- [ ] Run full `lake build` to verify no regressions
- [ ] Check build timing if possible (optional performance verification)

**Downstream files using Semantics**:
- `Theories/Logos/SubTheories/Foundation.lean`
- `Theories/Logos/SubTheories/Explanatory/Truth.lean`

**Timing**: 30 minutes

---

### Phase 6: Cleanup and Documentation [NOT STARTED]

**Goal**: Remove commented code, update module docstring, finalize.

**Tasks**:
- [ ] Remove any commented-out old mutual block code
- [ ] Update module docstring to reflect new implementation structure
- [ ] Add docstring to `eval` function explaining polarity parameter
- [ ] Add docstring to `Polarity` type
- [ ] Final build verification
- [ ] Run `lean_diagnostic_messages` to confirm no warnings

**Timing**: 30 minutes

## Testing & Validation

- [ ] All phases compile without errors (`lean_diagnostic_messages`)
- [ ] `lake build` succeeds for full project
- [ ] All 7 theorems in `BasicTheorems` section compile
- [ ] `content` function compiles and works correctly
- [ ] Downstream files (`Foundation.lean`, `Explanatory/Truth.lean`) compile
- [ ] No `sorry` statements introduced

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (upon completion)
- Modified: `Theories/Logos/SubTheories/Foundation/Semantics.lean`

## Rollback/Contingency

If the refactoring causes unexpected issues:

1. **Git rollback**: Revert to commit before changes with `git checkout -- Theories/Logos/SubTheories/Foundation/Semantics.lean`

2. **Lighter alternative**: If polarity approach fails, try marking existing mutual block with `@[irreducible]` to prevent unfolding during elaboration (preserves mutual structure but reduces some overhead)

3. **Partial rollback**: If only some theorems break, keep `eval` but restore individual theorem proofs from original versions
