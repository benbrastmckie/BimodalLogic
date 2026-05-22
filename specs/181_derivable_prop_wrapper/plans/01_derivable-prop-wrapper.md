# Implementation Plan: Derivable Prop-Valued Wrapper

- **Task**: 181 - derivable_prop_wrapper
- **Status**: [NOT STARTED]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/181_derivable_prop_wrapper/reports/01_derivable-prop-wrapper.md
- **Artifacts**: plans/01_derivable-prop-wrapper.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Add a Prop-valued `Derivable` wrapper (`def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)`) in a new file `Theories/Bimodal/ProofSystem/Derivable.lean`. This enables `simp` and `aesop` integration for derivability goals while preserving the existing Type-valued `DerivationTree` for computable functions (height, pattern matching, metalogic infrastructure). The research report verified all proposed code compiles against the current codebase.

### Research Integration

Integrated findings from `reports/01_derivable-prop-wrapper.md`:
- All 7 constructor-mirroring lemmas verified to compile via `lean_run_code`
- Aesop attribute strategy: `@[aesop safe apply]` for most lemmas, `@[aesop unsafe 50% apply]` for `mp`
- `|-!` notation follows FormalizedFormalLogic/Foundation convention
- `Consistent G <-> -Derivable G Formula.bot` is `Iff.rfl` (no proof needed)
- No breaking changes to existing code

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task supports Phase 5 (Publication quality) by providing a Prop-valued derivability interface suitable for Mathlib-style automation. It also unblocks aesop integration that was identified as a blocker in task 179 research.

## Goals & Non-Goals

**Goals**:
- Create `Derivable` Prop-valued definition alongside existing `DerivationTree`
- Mirror all 7 `DerivationTree` constructors as `Derivable` lemmas
- Add `|-!` notation for Prop-valued derivability
- Add `@[aesop]` and `@[simp]` attributes for automation integration
- Add `Consistent` bridge lemma
- Register new file in `ProofSystem.lean` aggregator

**Non-Goals**:
- Migrating existing `Nonempty (DerivationTree ...)` patterns to `Derivable` (follow-up task)
- Modifying existing tactics in `Automation/Tactics.lean`
- Creating a custom `TMDerivable` aesop rule set (can be added later)
- Modifying any existing files beyond `ProofSystem.lean` (import only)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Aesop attribute on `mp` causes unbounded search | M | L | Use `unsafe 50%` probability; verified in research |
| Import of `Aesop` in Derivable.lean adds transitive deps | L | L | Aesop already a project dependency via AesopRules.lean |
| Notation `|-!` conflicts with existing notation | M | L | Research confirmed no conflicts; uses distinct precedence |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Create Derivable.lean with Core Definitions [NOT STARTED]

**Goal**: Create the new file with the `Derivable` definition, `ofTree` coercion, all 7 constructor-mirroring lemmas, notation, and Consistent bridge. Add import to ProofSystem.lean. Verify compilation.

**Tasks**:
- [ ] Create `Theories/Bimodal/ProofSystem/Derivable.lean` with module docstring
- [ ] Add `Derivable` definition: `def Derivable (G : Context) (p : Formula) : Prop := Nonempty (DerivationTree G p)`
- [ ] Add `Derivable.ofTree` coercion theorem
- [ ] Add all 7 constructor-mirroring lemmas: `ax`, `assume`, `mp`, `nec`, `temp_nec`, `temp_dual`, `weaken`
- [ ] Add notation `|-!` for Prop-valued derivability (both `G |-! p` and `|-! p`)
- [ ] Add `consistent_iff_not_derivable_bot` bridge lemma
- [ ] Add `import Bimodal.ProofSystem.Derivable` to `Theories/Bimodal/ProofSystem.lean`
- [ ] Run `lake build` to verify compilation

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Derivable.lean` - New file with all core definitions
- `Theories/Bimodal/ProofSystem.lean` - Add import line

**Verification**:
- `lake build` succeeds with no errors
- All 7 lemmas and notation are accessible from downstream imports

---

### Phase 2: Add Aesop and Simp Attributes [NOT STARTED]

**Goal**: Annotate Derivable lemmas with `@[aesop]` and `@[simp]` attributes per the research strategy. Verify aesop works on a test goal.

**Tasks**:
- [ ] Add `import Aesop` to `Derivable.lean`
- [ ] Add `@[aesop safe apply]` to `ax`, `assume`, `weaken`, `nec`, `temp_nec`, `temp_dual`
- [ ] Add `@[aesop unsafe 50% apply]` to `mp`
- [ ] Add `@[simp]` to `ax` and `assume` (NOT to `mp`)
- [ ] Add test example: `example (p : Atom) : Derivable [] ((Formula.box (Formula.atom p)).imp (Formula.atom p)) := by aesop`
- [ ] Run `lake build` to verify attributes compile

**Timing**: 15 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Derivable.lean` - Add attributes and test example

**Verification**:
- `lake build` succeeds
- Test `aesop` example closes the goal

---

### Phase 3: Full Build Verification and Regression Check [NOT STARTED]

**Goal**: Run full project build and verify no regressions. Confirm aesop integration works on representative goals.

**Tasks**:
- [ ] Run full `lake build` (not just the new file)
- [ ] Verify no new warnings or errors in existing files
- [ ] Test aesop on 2-3 sample Derivable goals (axiom application, modus ponens chain)
- [ ] Verify `Consistent` bridge works: `example (G : Context) : Consistent G <-> -Derivable G Formula.bot := Iff.rfl`

**Timing**: 15 minutes

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/ProofSystem/Derivable.lean` - Add verification examples (may remove after testing)

**Verification**:
- Full `lake build` succeeds with no new errors
- All test examples compile
- No regressions in existing test suite

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] All 7 Derivable lemmas accessible and correctly typed
- [ ] `|-!` notation resolves correctly for both empty and non-empty contexts
- [ ] `aesop` closes at least one Derivable goal (axiom application)
- [ ] `simp` closes Derivable goals for axiom and assumption cases
- [ ] `Consistent` bridge is definitionally equal (`Iff.rfl`)
- [ ] No regressions in existing `DerivationTree`-based proofs

## Artifacts & Outputs

- `Theories/Bimodal/ProofSystem/Derivable.lean` - New file (~100 lines)
- `Theories/Bimodal/ProofSystem.lean` - Updated with new import

## Rollback/Contingency

Rollback is straightforward: delete `Derivable.lean` and remove the import line from `ProofSystem.lean`. No existing files are modified beyond the aggregator import, so there is zero risk to existing code.
