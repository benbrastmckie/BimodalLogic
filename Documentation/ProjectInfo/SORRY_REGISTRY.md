# Sorry Placeholder Registry

**Last Updated**: 2025-12-22
**Total Active Placeholders**: 8 (1 ModalS5 documented invalid, 3 Truth.lean, 1 Completeness, 3 ProofSearch documentation)
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

### Logos/Core/Theorems/Propositional.lean (0 placeholders - Plan 059 Phase 1)

**Plan 059 Phase 1 COMPLETE** (2025-12-09): All 6 De Morgan law theorems fully proven:
- `demorgan_conj_neg_forward`: `⊢ ¬(A ∧ B) → (¬A ∨ ¬B)` [COMPLETE]
- `demorgan_conj_neg_backward`: `⊢ (¬A ∨ ¬B) → ¬(A ∧ B)` [COMPLETE]
- `demorgan_conj_neg`: `⊢ ¬(A ∧ B) ↔ (¬A ∨ ¬B)` [COMPLETE]
- `demorgan_disj_neg_forward`: `⊢ ¬(A ∨ B) → (¬A ∧ ¬B)` [COMPLETE]
- `demorgan_disj_neg_backward`: `⊢ (¬A ∧ ¬B) → ¬(A ∨ B)` [COMPLETE]
- `demorgan_disj_neg`: `⊢ ¬(A ∨ B) ↔ (¬A ∧ ¬B)` [COMPLETE]

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

### Logos/Core/Semantics/Truth.lean (3 placeholders)

These are blocking placeholders in the temporal swap validity proof infrastructure.

- **Truth.lean:635** - `is_valid_swap_imp` (implication case)
  - **Context**: Swap validity for implication formulas
  - **Blocker**: Requires showing `is_valid (ψ → χ)` implies `is_valid (swap ψ → swap χ)`
  - **Issue**: Not obviously equivalent without structural assumptions on ψ and χ
  - **Resolution**: Accept limitation for MVP; only applies to derivable formulas in practice
  - **Task**: Task 17 area (Soundness.lean related issues)
  - **Status**: BLOCKED (documented as MVP limitation)

- **Truth.lean:714** - `is_valid_swap_all_past` (past case)
  - **Context**: If `Past ψ` is valid, then ψ is valid
  - **Blocker**: Requires domain extension assumption - need some t > r in domain
  - **Issue**: Can't guarantee τ.domain extends beyond any given point
  - **Resolution**: Requires assuming histories have unbounded future domains
  - **Task**: Task 17 area (Soundness.lean related issues)
  - **Status**: BLOCKED (domain extension limitation)

- **Truth.lean:736** - `is_valid_swap_all_future` (future case)
  - **Context**: If `Future ψ` is valid, then ψ is valid
  - **Blocker**: Requires domain extension assumption - need some t < r in domain
  - **Issue**: Symmetric to past case; can't guarantee domain extends into past
  - **Resolution**: Requires assuming histories have unbounded past domains
  - **Task**: Task 17 area (Soundness.lean related issues)
  - **Status**: BLOCKED (domain extension limitation)

### Logos/Core/Metalogic/DeductionTheorem.lean (0 placeholders - COMPLETE)

**FULLY RESOLVED** (Task 46 - 2025-12-15): All deduction theorem cases proven with zero sorry.

- **DeductionTheorem.lean:370** - `deduction_theorem` (modal_k case) [COMPLETE]
  - **Status**: RESOLVED - Implemented using recursive case analysis with termination proofs
  
- **DeductionTheorem.lean:383** - `deduction_theorem` (necessitation case) [COMPLETE]
  - **Status**: RESOLVED - Handled empty context necessitation with proper formulation
  
- **DeductionTheorem.lean:419** - `deduction_theorem` (temporal_k case) [COMPLETE]
  - **Status**: RESOLVED - Implemented using structural recursion pattern

**Impact**: Deduction theorem now fully functional for all derivation rule cases, enabling advanced proof techniques like `future_k_dist` derivation (Task 42a).

### Logos/Core/Metalogic/Completeness.lean (1 placeholder)

- **Completeness.lean:369** - `provable_iff_valid` (soundness direction)
  - **Context**: Proving `semantic_consequence [] φ` implies `valid φ`
  - **Blocker**: Need to show equivalence of semantic consequence with empty context and validity
  - **Resolution**: Straightforward proof once `valid` and `semantic_consequence` definitions aligned
  - **Effort**: 1-2 hours
  - **Task**: Task 9 (Begin Completeness Proofs)
  - **Status**: NOT STARTED (low priority)

---

## Axiom Declarations (Completeness.lean)

These are `axiom` declarations representing unproven theorems in the completeness infrastructure. They require the same resolution attention as `sorry` placeholders.

### Logos/Core/Metalogic/Completeness.lean (11 axioms)

**Phase 1 - Maximal Consistent Sets** (20-30 hours total):

- **Completeness.lean:116** - `lindenbaum`
  - **Context**: Every consistent set extends to maximal consistent set
  - **Resolution**: Prove using Zorn's lemma or transfinite induction
  - **Effort**: 10-15 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 1
  - **Status**: NOT STARTED

- **Completeness.lean:140** - `maximal_consistent_closed`
  - **Context**: Maximal consistent sets closed under modus ponens
  - **Resolution**: Prove from maximality and consistency
  - **Effort**: 5-7 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 1
  - **Status**: NOT STARTED

- **Completeness.lean:154** - `maximal_negation_complete`
  - **Context**: For every formula, either it or its negation is in the maximal set
  - **Resolution**: Prove from maximality
  - **Effort**: 5-7 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 1
  - **Status**: NOT STARTED

**Phase 2 - Canonical Model Components** (20-30 hours total):

- **Completeness.lean:199** - `canonical_task_rel`
  - **Context**: Task relation defined from derivability
  - **Resolution**: Define relation, prove respects derivability
  - **Effort**: 8-10 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 2
  - **Status**: NOT STARTED

- **Completeness.lean:210** - `canonical_frame`
  - **Context**: Frame constructed from maximal consistent sets
  - **Resolution**: Prove frame satisfies nullity and compositionality axioms
  - **Effort**: 10-12 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 2
  - **Status**: NOT STARTED

- **Completeness.lean:235** - `canonical_valuation`
  - **Context**: Valuation from maximal sets (atom membership)
  - **Resolution**: Define valuation function from set membership
  - **Effort**: 3-5 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 2
  - **Status**: NOT STARTED

- **Completeness.lean:242** - `canonical_model`
  - **Context**: Combine canonical frame and valuation into model
  - **Resolution**: Construct model from proven components
  - **Effort**: 2-3 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 2
  - **Status**: NOT STARTED

**Phase 3 - Truth Lemma and Completeness** (20-30 hours total):

- **Completeness.lean:263** - `canonical_history`
  - **Context**: History from maximal sets for temporal operators
  - **Resolution**: Define history function, prove respects task relation
  - **Effort**: 8-10 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 3
  - **Status**: NOT STARTED

- **Completeness.lean:297** - `truth_lemma`
  - **Context**: Truth preservation in canonical model
  - **Resolution**: Prove by induction on formula structure (most complex proof)
  - **Effort**: 15-20 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 3
  - **Status**: NOT STARTED

- **Completeness.lean:326** - `weak_completeness`
  - **Context**: Valid implies derivable (`|= phi -> |- phi`)
  - **Resolution**: Prove from truth lemma using canonical model
  - **Effort**: 5-7 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 3
  - **Status**: NOT STARTED

- **Completeness.lean:346** - `strong_completeness`
  - **Context**: Semantic consequence implies derivability (`Gamma |= phi -> Gamma |- phi`)
  - **Resolution**: Prove from weak completeness
  - **Effort**: 5-7 hours
  - **Task**: Task 9 (Begin Completeness Proofs), Phase 3
  - **Status**: NOT STARTED

---

## Axiom Declarations (ProofSearch.lean)

### Logos/Core/Automation/ProofSearch.lean (8 axioms)

- **ProofSearch.lean:133** - `bounded_search`
  - **Resolution**: Implement depth-bounded proof search
  - **Effort**: 8-10 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:146** - `search_with_heuristics`
  - **Resolution**: Implement heuristic-guided search
  - **Effort**: 10-12 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:156** - `search_with_cache`
  - **Resolution**: Implement cached search with memoization
  - **Effort**: 10-12 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:164** - `matches_axiom`
  - **Resolution**: Implement axiom pattern matching
  - **Effort**: 3-5 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:167** - `find_implications_to`
  - **Resolution**: Implement implication chain search
  - **Effort**: 5-7 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:170** - `heuristic_score`
  - **Resolution**: Implement formula heuristic scoring
  - **Effort**: 3-5 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:173** - `box_context`
  - **Resolution**: Implement modal context extraction
  - **Effort**: 2-3 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

- **ProofSearch.lean:176** - `future_context`
  - **Resolution**: Implement temporal context extraction
  - **Effort**: 2-3 hours
  - **Task**: Task 7 (Implement Core Automation)
  - **Status**: NOT STARTED

---

## Documentation Placeholders (ProofSearch.lean)

These are example usage `sorry` placeholders in documentation code blocks (3 total):

- **ProofSearch.lean:472** - Example usage for bounded_search
- **ProofSearch.lean:477** - Example usage for bounded_search with query
- **ProofSearch.lean:482** - Example usage for bounded_search with context

**Resolution**: Replace with real examples after search functions implemented
**Effort**: 1 hour (after search implemented)
**Task**: Task 7 (Implement Core Automation)

---

## Resolved Placeholders

Resolved placeholders are tracked via git history. Query completed resolutions:

```bash
# View sorry resolution commits
git log --all --grep="sorry" --oneline

# View commits that modified Soundness.lean (where most resolutions occurred)
git log --oneline -- Logos/Core/Metalogic/Soundness.lean

# Search for specific resolution
git log --all -S "sorry" -- Logos/Core/Semantics/Truth.lean
```

### Resolution History Summary

**2025-12-15 - Task 46: Deduction Theorem Completion**
- DeductionTheorem.lean: All 3 sorry placeholders resolved (modal_k, necessitation, temporal_k cases)
- Implemented recursive case analysis with complete termination proofs
- Deduction theorem now fully functional for all derivation rule cases
- Enabled advanced proof techniques (e.g., Task 42a: future_k_dist derivation)
- Total sorry in DeductionTheorem.lean: 3 → 0 [COMPLETE]

**2025-12-15 - Task 42a: Temporal Axiom Derivation**
- Perpetuity/Principles.lean: `future_k_dist` derived as theorem using deduction theorem
- Perpetuity/Principles.lean: `always_mono` derived as theorem using deduction theorem
- Axiom count reduced by 2 (future_k_dist and always_mono now theorems)
- Note: Axiom declarations remain in Perpetuity.lean for backward compatibility

**2025-12-08 - Task 16: Perpetuity Theorem Logic Errors**
- Perpetuity.lean: P1 (`perpetuity_1`) fully proven (was sorry)
- New helper lemmas: `identity`, `pairing` (axiom), `combine_imp_conj`, `combine_imp_conj_3`
- New temporal lemmas: `box_to_future`, `box_to_past` (via duality), `box_to_present`
- P3 (`perpetuity_3`) documented as blocked (requires modal K axiom not in TM)
- Total sorry in Perpetuity.lean: 2 → 1

**2025-12-03 - Task 5: Modal K and Temporal K Rules**
- Soundness.lean: modal_k case resolved (zero sorry)
- Soundness.lean: temporal_k case resolved (zero sorry)

**2025-12-03 - Task 7: Core Automation**
- Tactics.lean: 4 tactics implemented (apply_axiom, modal_t, tm_auto, assumption_search)
- 8 helper functions replaced sorry stubs

**2025-12-03 - Task 8: WorldHistory Universal Helper**
- WorldHistory.lean: universal constructor resolved (zero sorry)

**2025-12-02 - Task 6: Perpetuity Proofs**
- Perpetuity.lean: P1-P6 principles proven (using axiom applications)

**2025-12-02 - Task 5: Soundness Axioms**
- Soundness.lean: All 8 TM axioms proven sound (MT, M4, MB, T4, TA, TL, MF, TF)
- Truth.lean: Transport lemmas completed

---

## Summary

| Category | Count | Status |
|----------|-------|--------|
| Active `sorry` (ModalS5) | 1 | diamond_mono_imp (NOT VALID - documented with counter-model) |
| Active `sorry` (Truth.lean) | 3 | Temporal swap validity (domain extension limitation) |
| Active `sorry` (DeductionTheorem) | 0 | [COMPLETE] (Task 46) |
| Active `sorry` (Completeness) | 1 | `provable_iff_valid` soundness direction |
| Documentation `sorry` (ProofSearch) | 3 | Example usage (after implementation) |
| Completeness `axiom` | 11 | Task 9 (70-90 hours) |
| ProofSearch `axiom` | 8 | Task 7 (40-60 hours) |
| Perpetuity `axiom` | 5 | dni, future_k_dist (now derived), always_dni, always_dne, always_mono |
| **Total `sorry`** | **8** | 5 blocking + 3 documentation |
| **Total `axiom`** | **24** | 5 Perpetuity + 11 Completeness + 8 ProofSearch |

**Plan 060 Status (2025-12-09 - COMPLETE)**:
- **Phase 1 COMPLETE**: k_dist_diamond (`□(A → B) → (◇A → ◇B)`) proven [COMPLETE]
- **Phase 2 COMPLETE**: Biconditional infrastructure (contrapose_iff, iff_neg_intro, box_iff_intro) [COMPLETE]
- **Phase 3 COMPLETE**: diamond_disj_iff fully proven via duality chain [COMPLETE]
- **Phase 4 COMPLETE**: s4_diamond_box_conj and s5_diamond_conj_diamond proven using k_dist_diamond [COMPLETE]
- **All 8 Phase 4 Modal Theorems**: COMPLETE (ModalS5: 5/5, ModalS4: 4/4)
- **Key Discovery**: `(φ → ψ) → (◇φ → ◇ψ)` is NOT VALID, but `□(φ → ψ) → (◇φ → ◇ψ)` IS VALID

**Perpetuity Status (2025-12-09 - ALL COMPLETE)**:
- P1, P2, P3, P4, P5, P6: ALL FULLY PROVEN as theorems (zero sorry) [COMPLETE]
- `persistence` lemma: Fully proven using modal_5 + swap_temporal lemmas [COMPLETE]
- `contraposition`: Proven via B combinator [COMPLETE]
- All bridge lemmas for P6: Fully proven [COMPLETE]

**Next Priority**: Fix AesopRules duplicate (Task 52), then Layer 1 planning.

---

**Last Updated**: 2025-12-16
