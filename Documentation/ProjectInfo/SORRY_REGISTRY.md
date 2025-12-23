# Sorry Placeholder Registry

**Last Updated**: 2025-12-23
**Total Active Placeholders**: 5 (1 ModalS5 documented invalid, 1 Completeness, 3 ProofSearch documentation)
**Total Axiom Declarations**: 24 (5 Perpetuity, 11 Completeness, 8 ProofSearch)
**Total Resolved**: 60 (Plan 059 Phase 1: 6 De Morgan laws, Plan 060: diamond_disj_iff + s4_diamond_box_conj + s5_diamond_conj_diamond + k_dist_diamond + biconditional infrastructure, Task 46: 3 DeductionTheorem cases)

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

### Logos/Core/Theorems/Perpetuity.lean (0 sorry, 5 axioms)

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

**Active Axiom Declarations** (5 total at lines 523, 1233, 1504, 1570, 1670):

- **Perpetuity.lean:523** - `dni` (`⊢ A → ¬¬A`)
  - **Context**: Double negation introduction for classical logic
  - **Justification**: Valid in classical two-valued semantics
  - **Derivation**: Requires excluded middle or C combinator (~50+ lines)
  - **Status**: Axiomatized (classical logic axiom, semantically justified)

- **Perpetuity.lean:1233** - `future_k_dist` (DEPRECATED - now derived theorem)
  - **Context**: Future K distribution (`⊢ G(A → B) → (GA → GB)`)
  - **Status**: **RESOLVED** (Task 42a) - Now derived as theorem in Principles.lean using deduction theorem
  - **Note**: This axiom declaration remains in Perpetuity.lean for backward compatibility but is no longer needed

- **Perpetuity.lean:1504** - `always_dni` (`⊢ △φ → △¬¬φ`)
  - **Context**: Helper for P6 derivation
  - **Justification**: Double negation in temporal context
  - **Status**: Axiomatized (P6 support)

- **Perpetuity.lean:1570** - `always_dne` (`⊢ △¬¬φ → △φ`)
  - **Context**: Helper for P6 derivation
  - **Justification**: Double negation elimination in temporal context
  - **Status**: Axiomatized (P6 support)

- **Perpetuity.lean:1670** - `always_mono` (`⊢ (A → B) → (△A → △B)`)
  - **Context**: Always monotonicity for P6 bridge lemmas
  - **Justification**: Standard modal monotonicity principle
  - **Status**: Axiomatized (derivable but complex, semantically justified)

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

### Logos/Core/Metalogic/Completeness.lean (1 placeholder)

- `provable_iff_valid` (pending tasks 132–135)

### ProofSearch documentation placeholders (3)

- Documentation stubs pending consolidation (no Lean code impact); tracked under ProofSearch doc tasks.

