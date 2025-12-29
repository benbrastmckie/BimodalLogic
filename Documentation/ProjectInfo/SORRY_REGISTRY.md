# Sorry Placeholder Registry

**Last Updated**: 2025-12-28
**Total Active Placeholders**: 5 (1 ModalS5 documented invalid, 1 Completeness, 1 SoundnessLemmas, 2 documentation examples in ProofSearch/Automation)
**Total Axiom Declarations**: 11 (all in Completeness.lean for canonical model construction)
**Total Resolved**: 60 (Plan 059 Phase 1: 6 De Morgan laws, Plan 060: diamond_disj_iff + s4_diamond_box_conj + s5_diamond_conj_diamond + k_dist_diamond + biconditional infrastructure, Task 46: 3 DeductionTheorem cases)
**Note**: Count corrected from 6 to 5 after codebase review (sess_1766969902_lx) - ProofSearch has 3 sorry but only counted as documentation examples, Automation.lean has 1 documentation example

This document tracks `sorry` placeholders (unproven theorems) and `axiom` declarations (unproven lemmas) in the Logos codebase. It provides resolution context, effort estimates, and cross-references to related tasks.

## Update Instructions

**When to Update**: After resolving sorry placeholders, adding new axioms, or changing technical debt.

**How to Update**:
1. Run verification commands (below) to get accurate counts
2. Move resolved items to "Resolved Placeholders" section with date and summary
3. Update "Total Active Placeholders" and "Total Resolved" counts at top
4. Update "Last Updated" date
5. Cross-reference changes in IMPLEMENTATION_STATUS.md

**Verification Commands**:
```bash
# Count and list all sorry placeholders
grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null

# Count and list all axiom declarations
grep -rn "^axiom " Logos/Core/**/*.lean 2>/dev/null

# Quick counts
echo "sorry: $(grep -rc 'sorry' Logos/Core/**/*.lean 2>/dev/null | awk -F: '{s+=$2}END{print s}')"
echo "axiom: $(grep -rc '^axiom ' Logos/Core/**/*.lean 2>/dev/null | awk -F: '{s+=$2}END{print s}')"
```

**Relationship to Other Files**:
- **.opencode/specs/TODO.md**: Active tasks that resolve items in this registry
- **IMPLEMENTATION_STATUS.md**: Module status affected by sorry resolution
- **.opencode/specs/**: Spec-based plans for systematic resolution

**Command Integration**:
- `/task`, `/add`, `/review`, and `/todo` now require updating this registry alongside IMPLEMENTATION_STATUS.md and TACTIC_REGISTRY.md whenever command/task updates affect sorry or tactic status; dry-run/test modes must avoid registry writes and must not create project directories for doc-only changes.

**Note**: CLAUDE.md has been deprecated and moved to Archive/deprecated/CLAUDE.md.deprecated-20251215. Configuration is now handled through .opencode/context/.

---

## Related Documentation

- [TODO.md](../../.opencode/specs/TODO.md) - Active tasks addressing these items
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking (canonical sorry counts)
- [IMPLEMENTATION_STATUS.md - Known Limitations](IMPLEMENTATION_STATUS.md#known-limitations) - Blockers and workarounds affecting resolution

## Verification Commands

Run these commands to verify placeholder counts against this registry:

```bash
# Count sorry placeholders in Logos
 grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null | grep -v "^Binary" | wc -l

# List sorry locations
 grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null

# Count axiom declarations (unproven theorems)
 grep -rn "axiom " Logos/Core/**/*.lean 2>/dev/null | wc -l

# Full verification script
 echo "=== Sorry Placeholder Verification ===" && \
 grep -rn "sorry" Logos/Core/**/*.lean 2>/dev/null && \
 echo "" && \
 echo "=== Axiom Declarations ===" && \
 grep -rn "axiom " Logos/Core/**/*.lean 2>/dev/null
```

---

## Active Placeholders

### Logos/Core/Theorems/Perpetuity.lean (0 sorry, 0 axioms)

**ALL 6 PERPETUITY PRINCIPLES FULLY PROVEN** (P1-P6) - Zero sorry in proof code.

**P1 RESOLVED** (2025-12-08 Task 16): `perpetuity_1` fully proven using helper lemmas
(`identity`, `pairing`, `combine_imp_conj`, `combine_imp_conj_3`, `box_to_future`,
`box_to_past`, `box_to_present`). Key technique: temporal duality on `box_to_future` to derive `box_to_past`.

**P2 RESOLVED** (2025-12-08 Task 18 Phase 1): `perpetuity_2` fully proven via contraposition.
Added `b_combinator` helper theorem, used to prove `contraposition` theorem (zero sorry).
P2 derived as contraposition of P1 applied to `¬φ`.

**P3 RESOLVED** (2025-12-08 Task 16): `perpetuity_3` fully proven using axiomatic extension.
Added modal K distribution axiom (`modal_k_dist`) and necessitation rule to enable combining
boxed conjuncts via `box_conj_intro_imp_3` helper lemma.

**P4 RESOLVED** (2025-12-08 Task 18 Phase 2): `perpetuity_4` fully proven via contraposition of P3.
Added `dni` (double negation introduction) axiom for classical logic. P4 derived as contraposition
of P3 applied to `¬φ` with DNI bridging double negation in formula structure.

**P5 RESOLVED** (2025-12-09 Phase 6 Complete): `perpetuity_5` is FULLY PROVEN as a theorem.
The persistence lemma was completed using `modal_5` (S5 characteristic ◇φ → □◇φ derived from MB + diamond_4).
P5 is derived as `theorem perpetuity_5 := imp_trans (perpetuity_4 φ) (persistence φ)`.

**P6 RESOLVED** (2025-12-09): `perpetuity_6` FULLY PROVEN using double_contrapose chain via P5(¬φ) + bridge lemmas.

**Active Sorry Placeholders**: None (0)

**Active Axiom Declarations**: None (0) - All axioms have been removed or converted to theorems

### Logos/Core/Theorems/ModalS5.lean (1 placeholder - documented invalid theorem)

- **ModalS5.lean:89** - `diamond_mono_imp` (fundamental limitation - NOT VALID)
  - **Context**: Diamond monotonicity as object-level theorem
  - **Goal**: `⊢ (φ → ψ) → (◇φ → ◇ψ)`
  - **Status**: **DOCUMENTED AS INVALID** - intentional sorry to mark theorem that cannot be derived
  - **Counter-model**: Documented at lines 70-84 (S5 with w0, w1: A everywhere, B only at w0)
  - **Explanation**: Local truth of φ → ψ at one world doesn't guarantee modal relationships
  - **Meta-level vs Object-level**: Diamond_mono works as META-RULE (if ⊢ φ → ψ then ⊢ ◇φ → ◇ψ) but NOT as object theorem
  - **Resolution**: Cannot be derived - fundamental theoretical limitation (THIS IS EXPECTED)
  - **Alternative**: Use `k_dist_diamond`: `□(A → B) → (◇A → ◇B)` (Plan 060)

- **ModalS5.lean:96-99** - `diamond_mono_conditional` (depends on diamond_mono_imp)
  - **Context**: Conditional form of diamond monotonicity
  - **Status**: **DOCUMENTED AS INVALID** - depends on diamond_mono_imp
  - **Alternative**: Use `k_dist_diamond` pattern instead (Plan 060)

**RESOLVED (Plan 060)**:
- **diamond_disj_iff**: `⊢ ◇(A ∨ B) ↔ (◇A ∨ ◇B)` [COMPLETE] (resolved 2025-12-09 via duality chain approach)
- **k_dist_diamond**: `⊢ □(A → B) → (◇A → ◇B)` [COMPLETE] (NEW - valid K distribution for diamond)

### Logos/Core/Theorems/ModalS4.lean (0 placeholders - Plan 060 COMPLETE)

**ALL RESOLVED (Plan 060)**:
- **s4_diamond_box_conj**: `⊢ (◇A ∧ □B) → ◇(A ∧ □B)` [COMPLETE] (resolved 2025-12-09 using k_dist_diamond + modal_4)
- **s5_diamond_conj_diamond**: `⊢ ◇(A ∧ ◇B) ↔ (◇A ∧ ◇B)` [COMPLETE] (resolved 2025-12-09 using k_dist_diamond + modal_5)

### Logos/Core/Metalogic/Completeness.lean (1 sorry, 11 axioms)

**Active Sorry Placeholders** (1 total):
- **Completeness.lean:369** - `provable_iff_valid` theorem
  - **Context**: Main completeness theorem proving equivalence between provability and validity
  - **Dependencies**: Requires Lindenbaum lemma, canonical model construction, and truth lemma (tasks 132-135)
  - **Status**: Pending systematic resolution via tasks 132-135
  - **Estimate**: 11 hours total (tasks 132-135)

**Active Axiom Declarations** (11 total):
1. **Line 117**: `lindenbaum` - Maximal consistent extension lemma (task 132)
2. **Line 141**: `maximal_consistent_closed` - Maximal consistency closure property
3. **Line 155**: `maximal_negation_complete` - Negation completeness for maximal sets
4. **Line 200**: `canonical_task_rel` - Canonical task relation
5. **Line 211**: `canonical_frame` - Canonical frame construction
6. **Line 236**: `canonical_valuation` - Canonical valuation function
7. **Line 243**: `canonical_model` - Canonical model construction (task 133)
8. **Line 264**: `canonical_history` - Canonical world history
9. **Line 298**: `truth_lemma` - Truth lemma for canonical model (task 134)
10. **Line 327**: `weak_completeness` - Weak completeness theorem
11. **Line 347**: `strong_completeness` - Strong completeness theorem

### Logos/Core/Automation/ProofSearch.lean (0 code placeholders, 3 documentation examples)

**Documentation Examples** (3 total - NOT counted as active placeholders):
- **ProofSearch.lean:448** - Test case 1: `bounded_search [] _ 1` example
  - **Context**: Documentation example showing bounded search usage
  - **Status**: Documentation only, not blocking functionality
  - **Note**: ProofSearch has 11 build errors (dependent elimination, unknown constant List.qsort, termination_by issues)
  
- **ProofSearch.lean:453** - Test case 2: `bounded_search [] q 2` example
  - **Context**: Documentation example showing bounded search usage
  - **Status**: Documentation only, not blocking functionality
  
- **ProofSearch.lean:458** - Test case 3: `bounded_search [p.box] p.box 3` example
  - **Context**: Documentation example showing bounded search usage with modal formulas
  - **Status**: Documentation only, not blocking functionality

### Logos/Automation.lean (0 code placeholders, 1 documentation example)

**Documentation Examples** (1 total - NOT counted as active placeholders):
- **Automation.lean:26** - Example: `modal_k_tactic` usage
  - **Context**: Documentation example showing tactic usage
  - **Status**: Documentation only, not blocking functionality

### Logos/Core/Metalogic/SoundnessLemmas.lean (1 sorry placeholder)

**Active Sorry Placeholders** (1 total):
- **SoundnessLemmas.lean:684** - `temporal_duality` soundness case
  - **Context**: Temporal duality rule soundness proof in derivable_implies_swap_valid
  - **Goal**: Prove `is_valid T ψ'.swap_past_future.swap_past_future` from `DerivationTree [] ψ'`
  - **Status**: Blocked by circular dependency with soundness theorem (task 213 analysis)
  - **Circular Dependency**: Requires soundness (DerivationTree → is_valid), but soundness imports this file
  - **Resolution**: Will be completed in Soundness.lean after main soundness theorem is proven
  - **Estimate**: 2-3 hours (depends on soundness theorem completion)
  - **Related**: Task 213 proved `is_valid_swap_involution` is semantically false for arbitrary formulas
  - **Updated**: 2025-12-28 - Added comprehensive documentation of circular dependency (task 213)

### Documentation comment references (not actual placeholders)

**Note**: The following are documentation comments that mention "sorry" but are not actual code placeholders:

**Logos/Core/Metalogic/Completeness.lean**:
- **Lines 217-218**: Documentation comments explaining required proofs for nullity and compositionality properties

**Logos/Core/Theorems/ModalS5.lean**:
- **Line 93**: Documentation comment explaining diamond_mono_imp sorry

**Logos/Core/Theorems/Propositional.lean**:
- **Lines 30, 497**: Documentation comments mentioning "sorry" in context descriptions

