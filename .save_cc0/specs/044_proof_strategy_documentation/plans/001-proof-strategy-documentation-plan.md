# Implementation Plan: Proof Strategy Documentation

## Metadata
- **Plan ID**: 044_proof_strategy_documentation/001
- **Created**: 2025-12-08
- **Status**: [COMPLETE]
- **Complexity**: 3 (Medium)
- **Estimated Hours**: 17-25 hours
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Lean File**: Archive/ModalProofStrategies.lean, Archive/TemporalProofStrategies.lean, Archive/BimodalProofStrategies.lean
- **Dependencies**: None (leverages existing Perpetuity.lean patterns)
- **Research Report**: [001-lean-mathlib-research.md](../reports/001-lean-mathlib-research.md)

---

## Executive Summary

Create three new Lean 4 files in Archive/ demonstrating proof strategies for TM logic derivations. These files focus on **how to construct proofs** (strategies, patterns, helper lemmas) rather than just **what theorems exist** (covered in existing ModalProofs.lean, TemporalProofs.lean, BimodalProofs.lean).

**Key Deliverables**:
1. `Archive/ModalProofStrategies.lean` - S5 modal proof construction patterns
2. `Archive/TemporalProofStrategies.lean` - Linear temporal reasoning patterns
3. `Archive/BimodalProofStrategies.lean` - Modal-temporal interaction patterns
4. Updated `Archive/Archive.lean` with re-exports
5. Updated `Archive/README.md` with file descriptions

---

## Phase 1: Modal Proof Strategies [COMPLETE]

**Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Archive/ModalProofStrategies.lean`
**Estimated Hours**: 5-7 hours
**Dependencies**: []

### Goal
Create pedagogical examples demonstrating S5 modal proof construction patterns including necessity chains, possibility proofs, modal modus ponens, and S5 characteristic theorems.

### Strategy
- Use existing Archive patterns from ModalProofs.lean as template
- Focus on step-by-step proof construction with detailed comments
- Demonstrate explicit axiom application via `Derivable.axiom`
- Show helper lemma construction patterns from Perpetuity.lean

### Success Criteria
- [ ] Create `Archive/ModalProofStrategies.lean` with module docstring
- [ ] Implement necessity chain strategy (3-4 examples)
  - `theorem_necessity_iteration`: `□φ → □□φ → □□□φ` iteration
  - `theorem_necessity_idempotence`: Show `□□φ ↔ □φ` equivalence in S5
  - `theorem_identity_necessity`: `□φ → □φ` via identity combinator
- [ ] Implement possibility proof strategy (3-4 examples)
  - `theorem_diamond_from_box`: `◇φ = ¬□¬φ` conversion
  - `theorem_box_diamond_duality`: `□φ ↔ ¬◇¬φ`
  - `theorem_contraposition_modal`: Contraposition for modal operators
- [ ] Implement modal modus ponens strategy (3-4 examples)
  - `theorem_modal_k_application`: `□(φ → ψ), □φ ⊢ □ψ`
  - `theorem_necessitation`: `⊢ φ implies ⊢ □φ`
  - `theorem_modal_chain`: Multiple modal derivations
- [ ] Implement S5 characteristic theorems (2-3 examples)
  - `theorem_brouwer_b`: `φ → □◇φ` (B axiom demonstration)
  - `theorem_s5_collapse`: `◇□φ → □◇φ` in S5
- [ ] Add section headers with `/-! ## -/` blocks
- [ ] Ensure 50%+ comment density
- [ ] Verify all examples type-check: `lake build Archive`

### Theorem Specifications

| Theorem | Goal | Strategy | Complexity |
|---------|------|----------|------------|
| `necessity_iteration` | `⊢ φ.box.imp φ.box.box.box` | Chain M4 twice | Simple |
| `necessity_idempotence` | `⊢ φ.box.box.imp φ.box` | MT on □□φ | Simple |
| `diamond_from_box_neg` | `⊢ φ.neg.box.neg.imp φ.diamond` | Duality definition | Simple |
| `modal_k_application` | `[φ.imp ψ.box, φ.box] ⊢ ψ.box` | Modal K + MP | Medium |
| `brouwer_example` | `⊢ φ.imp φ.box.diamond` | MB axiom | Simple |

---

## Phase 2: Temporal Proof Strategies [COMPLETE]

**Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Archive/TemporalProofStrategies.lean`
**Estimated Hours**: 5-7 hours
**Dependencies**: [Phase 1]

### Goal
Create pedagogical examples demonstrating linear temporal reasoning patterns including always/eventually proofs, temporal duality, connectedness reasoning, and frame property proofs.

### Strategy
- Apply module structure patterns from Phase 1
- Demonstrate temporal duality rule applications
- Show temporal K rule for context transformation
- Include temporal frame property reasoning

### Success Criteria
- [ ] Create `Archive/TemporalProofStrategies.lean` with module docstring
- [ ] Implement always/eventually strategy (3-4 examples)
  - `theorem_future_iteration`: `Gφ → GGφ → GGGφ` via T4
  - `theorem_eventually_duality`: `Fφ = ¬G¬φ`
  - `theorem_past_iteration`: `Hφ → HHφ` via temporal duality on T4
- [ ] Implement temporal duality strategy (3-4 examples)
  - `theorem_swap_future_past`: Derive past theorems from future
  - `theorem_duality_preservation`: Duality preserves derivability
  - `theorem_symmetric_temporal`: Show G↔H via duality
- [ ] Implement connectedness strategy (2-3 examples)
  - `theorem_ta_application`: `φ → G(Pφ)` direct application
  - `theorem_ta_iteration`: `φ → GG(PPφ)` chain
  - `theorem_reachability`: Combine TA with T4
- [ ] Implement temporal frame strategy (2-3 examples)
  - `theorem_linear_time`: Total ordering demonstration
  - `theorem_unbounded_future`: No maximum time
- [ ] Add section headers with `/-! ## -/` blocks
- [ ] Ensure 50%+ comment density
- [ ] Verify all examples type-check: `lake build Archive`

### Theorem Specifications

| Theorem | Goal | Strategy | Complexity |
|---------|------|----------|------------|
| `future_iteration` | `⊢ φ.all_future.imp φ.all_future.all_future.all_future` | Chain T4 | Simple |
| `eventually_from_future` | `⊢ φ.neg.all_future.neg.imp φ.some_future` | Duality | Simple |
| `swap_temporal_demo` | `⊢ φ.all_past.imp φ.all_past.all_past` | Duality on T4 | Medium |
| `ta_application` | `⊢ φ.imp φ.some_past.all_future` | TA axiom | Simple |
| `convex_interval` | `[φ, ψ.all_future] ⊢ ...` | Connectedness | Medium |

---

## Phase 3: Bimodal Proof Strategies [COMPLETE]

**Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Archive/BimodalProofStrategies.lean`
**Estimated Hours**: 5-8 hours
**Dependencies**: [Phase 1, Phase 2]

### Goal
Create pedagogical examples demonstrating modal-temporal interaction patterns including perpetuity principle applications, MF/TF axiom usage, helper lemma construction, and complex proof assembly.

### Strategy
- Leverage Perpetuity.lean helper lemmas extensively
- Demonstrate imp_trans, combine_imp_conj patterns
- Show box_to_future/box_to_past component construction
- Include complex multi-step proof assembly

### Success Criteria
- [ ] Create `Archive/BimodalProofStrategies.lean` with module docstring
- [ ] Implement perpetuity application strategy (4-5 examples)
  - `theorem_p1_usage`: Use P1 (`□φ → △φ`) in complex proof
  - `theorem_p2_usage`: Use P2 (`▽φ → ◇φ`) for possibility
  - `theorem_p1_p3_chain`: Chain P1 + P3 → `□φ → □△φ`
  - `theorem_always_components`: Break down `△φ = Hφ ∧ φ ∧ Gφ`
- [ ] Implement modal-temporal axiom strategy (3-4 examples)
  - `theorem_mf_application`: `□φ → □Gφ` direct use
  - `theorem_tf_application`: `□φ → G□φ` direct use
  - `theorem_mf_tf_combined`: Use MF and TF together
- [ ] Implement helper lemma strategy (4-5 examples)
  - `theorem_imp_trans_demo`: Show implication transitivity construction
  - `theorem_combine_conj_demo`: Show conjunction assembly
  - `theorem_box_to_future_demo`: Component lemma construction
  - `theorem_contraposition_demo`: Duality via negation
- [ ] Implement complex assembly strategy (3-4 examples)
  - `theorem_multi_step_proof`: Complete proof with 5+ steps
  - `theorem_three_component`: Combine three separate derivations
  - `theorem_duality_exploitation`: Use temporal_duality for symmetry
- [ ] Add section headers with `/-! ## -/` blocks
- [ ] Ensure 50%+ comment density
- [ ] Verify all examples type-check: `lake build Archive`

### Theorem Specifications

| Theorem | Goal | Strategy | Complexity |
|---------|------|----------|------------|
| `p1_usage_demo` | `⊢ φ.box.imp (φ.all_past.and (φ.and φ.all_future))` | P1 application | Simple |
| `mf_tf_combined` | `⊢ φ.box.imp (φ.all_future.box.and φ.box.all_future)` | MF + TF | Medium |
| `imp_trans_demo` | `⊢ A.imp C` from `A.imp B` and `B.imp C` | imp_trans pattern | Simple |
| `combine_conj_3_demo` | `⊢ P.imp (A.and (B.and C))` | combine_imp_conj_3 | Medium |
| `multi_step_assembly` | `⊢ φ.box.imp φ.always.box` | 5+ step chain | Complex |

---

## Phase 4: Integration and Archive Updates [COMPLETE]

**Estimated Hours**: 2-3 hours
**Dependencies**: [Phase 1, Phase 2, Phase 3]

### Goal
Update Archive module structure to include new files and verify complete integration.

### Success Criteria
- [ ] Update `Archive/Archive.lean` with three new imports:
  ```lean
  import Archive.ModalProofStrategies
  import Archive.TemporalProofStrategies
  import Archive.BimodalProofStrategies
  ```
- [ ] Update `Archive/README.md`:
  - Add new files to "Example Categories" section
  - Update file count and line counts
  - Add learning path recommendations for proof strategies
- [ ] Run full build verification: `lake build`
- [ ] Run full test suite: `lake test`
- [ ] Verify no `sorry` placeholders in new files
- [ ] Verify LEAN_STYLE_GUIDE.md compliance (100 char lines, 2-space indent)
- [ ] Verify Unicode symbols use backticks in comments

---

## Quality Criteria

Before marking plan complete, verify:

- [ ] All examples type-check without errors
- [ ] Module docstrings follow Archive pattern (see research report Section 1.2)
- [ ] Comment density ≥50% in each file
- [ ] Each strategy has 3-5 concrete examples
- [ ] Notation explained (both dot notation and Unicode)
- [ ] Cross-references to ProofSystem/ modules included
- [ ] Archive.lean updated with re-exports
- [ ] Archive/README.md updated with file descriptions
- [ ] No `sorry` placeholders (all examples complete)
- [ ] Follows LEAN_STYLE_GUIDE.md (100 char lines, 2-space indent)

---

## Risk Mitigation

### Risk 1: Incomplete Axiom Soundness
**Issue**: TL, MF, TF have partial soundness proofs
**Mitigation**:
- Document in module docstrings which axioms are fully proven
- Add warnings where strategies use incomplete axioms
- Show alternative strategies using only proven axioms (MT, M4, MB, T4, TA)

### Risk 2: Tactic Limitations
**Issue**: Only 4/12 tactics fully implemented
**Mitigation**:
- Focus on manual proof construction in examples
- Show explicit `Derivable.axiom` applications
- Mention planned tactics in comments: "Future: use `modal_search` tactic here"

### Risk 3: Scope Creep
**Issue**: Could expand into full tutorial system
**Mitigation**:
- Keep focused on **proof strategies**, not basic TM logic tutorial
- Assume reader understands TM axioms (reference TUTORIAL.md)
- ~15-20 examples per file maximum

---

## Implementation Notes

### Module Structure Template
```lean
import Logos.Core.Syntax.Formula
import Logos.Core.ProofSystem.Axioms
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Theorems.Perpetuity

/-!
# [Title] Proof Strategies

[Module description - 3-5 sentences explaining focus]

## Main Strategies

- [Strategy 1]: [Brief description]
- [Strategy 2]: [Brief description]

## Notation

- `□φ` = `φ.box` (modal necessity)
- `◇φ` = `φ.diamond` (modal possibility)
- `△φ` = `φ.always` (temporal always = Hφ ∧ φ ∧ Gφ)
- `▽φ` = `φ.sometimes` (temporal sometimes)

## References

- See `Logos/Core/ProofSystem/Axioms.lean` for axiom definitions
- See `Logos/Core/Theorems/Perpetuity.lean` for helper lemma patterns
-/

namespace Archive.[ModuleName]

open Logos.Core.Syntax
open Logos.Core.ProofSystem

/-! ## Strategy 1: [Name]

[Detailed description of when and how to use this strategy]
-/

/-- [Example description] -/
example (φ : Formula) : ⊢ [goal] := by
  -- Step 1: [explanation]
  have h1 := Derivable.axiom [] _ (Axiom.[axiom_name] φ)
  -- Step 2: [explanation]
  [next step]
  -- Final: [explanation]
  exact [result]

end Archive.[ModuleName]
```

### Comment Density Example
```lean
/-- Strategy: Chain modal axioms for nested boxes

    This demonstrates how to iterate modal 4 axiom (`□φ → □□φ`)
    to prove arbitrary depths of necessity nesting.
-/
example (p : Formula) : ⊢ p.box.imp p.box.box.box := by
  -- Step 1: Apply M4 to get `□p → □□p`
  have h1 := Derivable.axiom [] _ (Axiom.modal_4 p)
  -- Step 2: Apply M4 to `□p` to get `□□p → □□□p`
  have h2 := Derivable.axiom [] _ (Axiom.modal_4 p.box)
  -- Step 3: Chain implications via `imp_trans`
  -- Uses helper from Perpetuity.lean
  exact imp_trans h1 h2
```

---

## References

### Logos Documentation
- [Research Report](../reports/001-lean-mathlib-research.md) - Comprehensive research findings
- `/Archive/Archive.lean` - Module structure reference
- `/Archive/BimodalProofs.lean` - Existing bimodal examples (216 lines)
- `/Archive/ModalProofs.lean` - Existing modal examples (241 lines)
- `/Archive/TemporalProofs.lean` - Existing temporal examples (301 lines)
- `/Logos/Core/Theorems/Perpetuity.lean` - Helper lemma patterns

### Axiom References
- `/Logos/Core/ProofSystem/Axioms.lean` - 10 TM axiom schemata
- `/Logos/Core/ProofSystem/Derivation.lean` - 7 inference rules

---

**Plan Created**: 2025-12-08
**Plan Path**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/044_proof_strategy_documentation/plans/001-proof-strategy-documentation-plan.md`
