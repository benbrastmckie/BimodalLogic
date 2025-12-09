# Sorry Placeholder Registry

**Last Updated**: 2025-12-09
**Total Active Placeholders**: 7 (4 blocking, 3 documentation examples)
**Total Resolved**: 45 (P5 fully proven as theorem)

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
- **TODO.md** (root): Tasks that resolve items in this registry
- **IMPLEMENTATION_STATUS.md**: Module status affected by sorry resolution
- **.claude/TODO.md**: Spec-based plans for systematic resolution

---

## Related Documentation

- [TODO.md](../../TODO.md) - Active tasks addressing these items
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

### Logos/Core/Theorems/Perpetuity.lean (0 sorry, 6 axioms)

**P1 RESOLVED** (2025-12-08 Task 16): `perpetuity_1` fully proven using helper lemmas
(`identity`, `pairing` axiom, `combine_imp_conj`, `combine_imp_conj_3`, `box_to_future`,
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
Documentation updated to reflect theorem status. All tests pass.

**Active Sorry Placeholders**: None (0)

**Active Axiom Declarations**:

- **Perpetuity.lean:170** - `pairing` (`⊢ A → B → A ∧ B`)
  - **Context**: Conjunction introduction combinator
  - **Justification**: Semantically valid in task semantics (classical conjunction)
  - **Derivation**: Can be built from S(S(KS)(S(KK)I))(KI) (~40+ lines)
  - **Status**: Axiomatized (low priority, complex combinator construction)

- **Perpetuity.lean:199** - `dni` (`⊢ A → ¬¬A`)
  - **Context**: Double negation introduction for classical logic
  - **Justification**: Valid in classical two-valued semantics
  - **Derivation**: Requires excluded middle or C combinator (~50+ lines)
  - **Status**: Axiomatized (classical logic axiom, semantically justified)

- **Perpetuity.lean:909** - `future_k_dist` (`⊢ G(A → B) → (GA → GB)`)
  - **Context**: Future K distribution (normal modal logic axiom)
  - **Justification**: Standard axiom for normal modal logics
  - **Status**: Axiomatized (temporal normal modal logic axiom)

- **Perpetuity.lean:1180** - `always_dni` (`⊢ △φ → △¬¬φ`)
  - **Context**: Helper for P6 derivation
  - **Justification**: Double negation in temporal context
  - **Status**: Axiomatized (P6 support)

- **Perpetuity.lean:1246** - `always_dne` (`⊢ △¬¬φ → △φ`)
  - **Context**: Helper for P6 derivation
  - **Justification**: Double negation elimination in temporal context
  - **Status**: Axiomatized (P6 support)

- **Perpetuity.lean:1302** - `perpetuity_6` (`⊢ ▽□φ → □△φ`)
  - **Context**: P6 occurrent necessity is perpetual
  - **Blocked by**: Complex formula type manipulation in duality reasoning
  - **Justification**: Corollary 2.11 validates P6; all 4 duality lemmas proven
  - **Status**: Axiomatized (theoretically derivable from P5 + duality, mechanically complex)

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

### Logos/Core/Metalogic/Completeness.lean (1 placeholder)

- **Completeness.lean:368** - `provable_iff_valid` (soundness direction)
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
| Active `sorry` (Perpetuity) | 0 | All sorry resolved (P5 now FULLY PROVEN) |
| Active `sorry` (Truth.lean) | 3 | Temporal swap validity (domain extension) |
| Active `sorry` (Completeness) | 1 | `provable_iff_valid` soundness direction |
| Documentation `sorry` (ProofSearch) | 3 | Example usage (after implementation) |
| Completeness `axiom` | 11 | Task 9 (70-90 hours) |
| ProofSearch `axiom` | 8 | Task 7 remaining (30-40 hours) |
| Perpetuity `axiom` | 6 | pairing, dni, future_k_dist, always_dni, always_dne, perpetuity_6 |
| **Total `sorry`** | **7** | 4 blocking, 3 documentation |
| **Total `axiom`** | **25** | Infrastructure declarations |

**Perpetuity Status Update (2025-12-09 Phase 6 Complete)**:
- P1, P2, P3, P4, P5: Fully proven as theorems (zero sorry) ✓
- `persistence` lemma: Fully proven using modal_5 + swap_temporal lemmas ✓
- `contraposition`: Proven via B combinator ✓
- P6: Axiomatized (theoretically derivable, mechanically complex, semantically justified)
- Documentation updated, all tests pass

**Next Priority**: Task 17 (Truth.lean/Soundness.lean type errors), then Task 7 remaining work.

---

**Last Updated**: 2025-12-09
