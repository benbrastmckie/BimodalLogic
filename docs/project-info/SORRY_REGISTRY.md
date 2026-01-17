# Sorry Placeholder Registry

**Last Updated**: 2026-01-15
**Total Active Placeholders**: 46 (26 in Completeness.lean, 3 in ProofSearch.lean, 17 across other modules)
**Total Axiom Declarations**: 7 (5 in Completeness.lean for canonical model construction, 2 in Examples)
**Total Resolved**: 60 (Plan 059 Phase 1: 6 De Morgan laws, Plan 060: diamond_disj_iff + s4_diamond_box_conj + s5_diamond_conj_diamond + k_dist_diamond + biconditional infrastructure, Task 46: 3 DeductionTheorem cases)
**Note**: Count updated after comprehensive codebase review (sess_1768528304_4parxt) - Found 46 active sorry placeholders across Theories/Bimodal and Theories/Logos

This document tracks `sorry` placeholders (unproven theorems) and `axiom` declarations (unproven lemmas) in the Bimodal codebase. It provides resolution context, effort estimates, and cross-references to related tasks.

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
grep -rn "sorry" Bimodal/**/*.lean 2>/dev/null

# Count and list all axiom declarations
grep -rn "^axiom " Bimodal/**/*.lean 2>/dev/null

# Quick counts
echo "sorry: $(grep -rc 'sorry' Bimodal/**/*.lean 2>/dev/null | awk -F: '{s+=$2}END{print s}')"
echo "axiom: $(grep -rc '^axiom ' Bimodal/**/*.lean 2>/dev/null | awk -F: '{s+=$2}END{print s}')"
```

**Relationship to Other Files**:
- **specs/TODO.md**: Active tasks that resolve items in this registry
- **IMPLEMENTATION_STATUS.md**: Module status affected by sorry resolution
- **specs/**: Spec-based plans for systematic resolution

**Command Integration**:
- `/task`, `/add`, `/review`, and `/todo` now require updating this registry alongside IMPLEMENTATION_STATUS.md and TACTIC_REGISTRY.md whenever command/task updates affect sorry or tactic status; dry-run/test modes must avoid registry writes and must not create project directories for doc-only changes.

---

## Related Documentation

- [TODO.md](../../specs/TODO.md) - Active tasks addressing these items
- [IMPLEMENTATION_STATUS.md](IMPLEMENTATION_STATUS.md) - Module-by-module completion tracking (canonical sorry counts)
- [IMPLEMENTATION_STATUS.md - Known Limitations](IMPLEMENTATION_STATUS.md#known-limitations) - Blockers and workarounds affecting resolution

## Verification Commands

Run these commands to verify placeholder counts against this registry:

```bash
# Count sorry placeholders in Bimodal
grep -rn "sorry" Bimodal/**/*.lean 2>/dev/null | grep -v "^Binary" | wc -l

# List sorry locations
grep -rn "sorry" Bimodal/**/*.lean 2>/dev/null

# Count axiom declarations (unproven theorems)
grep -rn "axiom " Bimodal/**/*.lean 2>/dev/null | wc -l

# Full verification script
echo "=== Sorry Placeholder Verification ===" && \
grep -rn "sorry" Bimodal/**/*.lean 2>/dev/null && \
echo "" && \
echo "=== Axiom Declarations ===" && \
grep -rn "axiom " Bimodal/**/*.lean 2>/dev/null
```

---

## Active Placeholders

### Bimodal/Theorems/Perpetuity/ (0 sorry, 0 axioms)

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
The persistence lemma was completed using `modal_5` (S5 characteristic diamond phi implies box diamond phi derived from MB + diamond_4).
P5 is derived as `theorem perpetuity_5 := imp_trans (perpetuity_4 phi) (persistence phi)`.

**P6 RESOLVED** (2025-12-09): `perpetuity_6` FULLY PROVEN using double_contrapose chain via P5(neg phi) + bridge lemmas.

**Active Sorry Placeholders**: None (0)

**Active Axiom Declarations**: None (0) - All axioms have been removed or converted to theorems

### Bimodal/Theorems/ModalS5.lean (0 placeholders - all resolved)

**REMOVED (Task 369, 2026-01-11)**: Invalid theorems deleted from codebase
- `diamond_mono_imp` and `diamond_mono_conditional` were removed because they are semantically
  INVALID in modal logic (cannot be proven). The counter-model documentation is preserved as
  a comment block in ModalS5.lean (lines 67-87).
- **Alternative**: Use `k_dist_diamond` (`□(A → B) → (◇A → ◇B)`) which IS valid and fully proven.

**RESOLVED (Plan 060)**:
- **diamond_disj_iff**: `|- diamond(A or B) <-> (diamond A or diamond B)` [COMPLETE] (resolved 2025-12-09 via duality chain approach)
- **k_dist_diamond**: `|- box(A -> B) -> (diamond A -> diamond B)` [COMPLETE] (NEW - valid K distribution for diamond)

### Bimodal/Theorems/ModalS4.lean (0 placeholders - Plan 060 COMPLETE)

**ALL RESOLVED (Plan 060)**:
- **s4_diamond_box_conj**: `|- (diamond A and box B) -> diamond(A and box B)` [COMPLETE] (resolved 2025-12-09 using k_dist_diamond + modal_4)
- **s5_diamond_conj_diamond**: `|- diamond(A and diamond B) <-> (diamond A and diamond B)` [COMPLETE] (resolved 2025-12-09 using k_dist_diamond + modal_5)

### Bimodal/Metalogic/Completeness.lean (26 sorry, 5 axioms)

**Active Sorry Placeholders** (26 total):
- **Lines 1341-1391**: Multiple placeholder proofs for canonical model construction
- **Lines 1653-1794**: Truth lemma and related proofs with sorry gaps
- **Lines 1837-2507**: Various auxiliary lemmas with sorry placeholders
- **Lines 2612-2662**: Extension lemmas with sorry
- **Lines 3332-3694**: Duration-based infrastructure with sorry gaps
- **Context**: Main completeness theorem proving equivalence between provability and validity
- **Dependencies**: Requires systematic resolution of canonical model construction (tasks 132-135)
- **Status**: Major component requiring comprehensive work
- **Estimate**: 20+ hours total (tasks 132-135 plus additional infrastructure)

**Active Axiom Declarations** (5 total):
1. **Line 1585**: `someWorldState_exists` - Existence of maximal consistent set
2. **Line 2786**: `anotherWorldState_exists` - Existence of distinct maximal consistent set
3. **Line 3569**: `truth_lemma` - Truth lemma for canonical worlds
4. **Line 3600**: `weak_completeness` - Weak completeness theorem
5. **Line 3620**: `strong_completeness` - Strong completeness theorem

### Bimodal/Automation/ProofSearch.lean (3 documentation examples)

**Documentation Examples** (3 total - actual sorry placeholders but for documentation):
- **ProofSearch.lean:1348** - `bounded_search [] _ 1` example
  - **Context**: Documentation example showing bounded search usage
  - **Status**: Documentation placeholder, not blocking functionality

- **ProofSearch.lean:1353** - `bounded_search [] q 2` example
  - **Context**: Documentation example showing bounded search usage
  - **Status**: Documentation placeholder, not blocking functionality

- **ProofSearch.lean:1358** - `bounded_search [p.box] p.box 3` example
  - **Context**: Documentation example showing bounded search usage with modal formulas
  - **Status**: Documentation placeholder, not blocking functionality

### Logos/Automation.lean (0 code placeholders, 1 documentation example)

**Documentation Examples** (1 total - NOT counted as active placeholders):
- **Automation.lean:26** - Example: `modal_k_tactic` usage
  - **Context**: Documentation example showing tactic usage
  - **Status**: Documentation only, not blocking functionality

### Bimodal/Metalogic/SoundnessLemmas.lean (1 sorry placeholder)

**Active Sorry Placeholders** (1 total):
- **SoundnessLemmas.lean:684** - `temporal_duality` soundness case
  - **Context**: Temporal duality rule soundness proof in derivable_implies_swap_valid
  - **Goal**: Prove `is_valid T psi'.swap_past_future.swap_past_future` from `DerivationTree [] psi'`
  - **Status**: Blocked by circular dependency with soundness theorem (task 213 analysis)
  - **Circular Dependency**: Requires soundness (DerivationTree -> is_valid), but soundness imports this file
  - **Resolution**: Will be completed in Soundness.lean after main soundness theorem is proven
  - **Estimate**: 2-3 hours (depends on soundness theorem completion)
  - **Related**: Task 213 proved `is_valid_swap_involution` is semantically false for arbitrary formulas
  - **Updated**: 2025-12-28 - Added comprehensive documentation of circular dependency (task 213)

### Documentation comment references (not actual placeholders)

**Note**: The following are documentation comments that mention "sorry" but are not actual code placeholders:

**Bimodal/Metalogic/Completeness.lean**:
- **Lines 217-218**: Documentation comments explaining required proofs for nullity and compositionality properties

**Bimodal/Theorems/ModalS5.lean**:
- **Lines 67-87**: Documentation comment explaining why diamond monotonicity as object-level implication is invalid (counter-model preserved)

**Bimodal/Theorems/Propositional.lean**:
- **Lines 30, 497**: Documentation comments mentioning "sorry" in context descriptions
