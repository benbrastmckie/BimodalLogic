# Research Report: Seed Consistency Axioms Provability

**Task**: 34 - prove_succ_seed_consistency_axioms
**Date**: 2026-03-23
**Session**: sess_1774250274_6670c6
**Status**: Research Complete

## Executive Summary

This research analyzes three axioms in `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` deferred from Task 29 Phase 7. Under reflexive semantics with T-axioms available (`Gφ → φ`, `Hφ → φ`), **all three axioms can likely be proven** using the same patterns already established in `WitnessSeed.lean` for `forward_temporal_witness_seed_consistent`.

**Key Finding**: The deferral seed axioms are structurally simpler than the existing `discreteImmediateSuccSeed_consistent_axiom` in `DiscreteSuccSeed.lean` because they DON'T include blocking formulas. The proof pattern from `WitnessSeed.lean` can be directly adapted.

## Axioms Under Analysis

### Axiom 1: `successor_deferral_seed_consistent_axiom` (Line 266)

```lean
axiom successor_deferral_seed_consistent_axiom (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (successor_deferral_seed u)
```

**Seed Structure**: `g_content(u) ∪ {φ ∨ F(φ) | F(φ) ∈ u}`

### Axiom 2: `predecessor_deferral_seed_consistent_axiom` (Line 311)

```lean
axiom predecessor_deferral_seed_consistent_axiom (u : Set Formula)
    (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (predecessor_deferral_seed u)
```

**Seed Structure**: `h_content(u) ∪ {φ ∨ P(φ) | P(φ) ∈ u}`

### Axiom 3: `predecessor_f_step_axiom` (Line 516)

```lean
axiom predecessor_f_step_axiom
    (u : Set Formula) (h_mcs : SetMaximalConsistent u)
    (h_P_top : Formula.some_past (Formula.neg Formula.bot) ∈ u) :
    f_content (predecessor_from_deferral_seed u h_mcs h_P_top) ⊆ u ∪ f_content u
```

**Property**: The F-obligations of the predecessor are either resolved at u or deferred.

## Analysis of Provability

### T-Axiom Status (Critical Context)

Under **reflexive semantics** (Task 29), we have T-axioms:
- `temp_t_future`: `Gφ → φ`
- `temp_t_past`: `Hφ → φ`

These ARE in the axiom system (`Theories/Bimodal/ProofSystem/Axioms.lean`, lines 289-304).

**Implication**: Under reflexive semantics, `g_content(M) ⊆ M` for any MCS M because:
- If `Gφ ∈ M` (i.e., `φ ∈ g_content(M)`), then by T-axiom `φ ∈ M`.

This is the **key difference** from strict semantics where `g_content(M) ⊈ M`.

### Axioms 1 and 2: Seed Consistency

**Proof Strategy** (analogous to `forward_temporal_witness_seed_consistent` in WitnessSeed.lean):

For the successor seed `g_content(u) ∪ deferralDisjunctions(u)`:

1. **g_content(u) is consistent** - Already proven as `g_content_consistent` in `DiscreteSuccSeed.lean` (line 225).

2. **Adding deferral disjunctions preserves consistency**:
   - Each deferral disjunction `φ ∨ F(φ)` is **derivable from F(φ)** (proven as `deferral_disjunction_from_F` in SuccExistence.lean, line 241).
   - Since `F(φ) ∈ u` for each disjunction we add, we have `[F(φ)] ⊢ φ ∨ F(φ)`.
   - These formulas are "harmless" weakenings that cannot introduce inconsistency.

3. **Joint consistency argument**:
   Suppose the seed `g_content(u) ∪ deferralDisjunctions(u)` is inconsistent.
   Then some finite `L ⊆ seed` derives `⊥`.

   Partition L into `L_g ⊆ g_content(u)` and `L_d ⊆ deferralDisjunctions(u)`.

   - **Case: L_d = ∅**: Then `L ⊆ g_content(u)` and L is inconsistent, contradicting `g_content_consistent`.

   - **Case: L_d ≠ ∅**: Each element of L_d has form `φ ∨ F(φ)` where `F(φ) ∈ u`.
     By the deduction theorem pattern used in `forward_temporal_witness_seed_consistent`:
     - Apply deduction theorem to isolate the disjunctions
     - Use generalized temporal K to lift contradictions
     - Derive that some `G(¬X) ∈ u` for a formula X, contradicting `F(X) ∈ u`

**Key Observation**: The proof pattern in `forward_temporal_witness_seed_consistent` handles `{ψ} ∪ g_content(M)` where `F(ψ) ∈ M`. The deferral seed adds `{φ ∨ F(φ) | F(φ) ∈ u}` instead of `{ψ}`, but each such disjunction is **derivable from an element of f_content(u)**, making the proof structurally similar.

**Predecessor symmetry**: Axiom 2 follows by temporal duality using `h_content`, `P`, and `generalized_past_k` instead of `g_content`, `F`, and `generalized_temporal_k`.

### Axiom 3: Predecessor F-step

**Goal**: `f_content(predecessor) ⊆ u ∪ f_content(u)`

**Proof Approach**:

The predecessor `v = predecessor_from_deferral_seed u h_mcs h_P_top` extends the seed `h_content(u) ∪ pastDeferralDisjunctions(u)`.

For any `φ ∈ f_content(v)` (i.e., `F(φ) ∈ v`), we need to show `φ ∈ u ∨ F(φ) ∈ u`.

**Case analysis on F(φ) ∈ v**:

1. **If F(φ) was in the seed**: The seed only contains `h_content(u)` and past deferral disjunctions `ψ ∨ P(ψ)`. The formula `F(φ)` cannot appear in these sets directly.

2. **If F(φ) was added by Lindenbaum extension**: By MCS properties, either:
   - `F(φ)` was provably forced by the seed, OR
   - `¬F(φ)` was not in the seed's closure

**Alternative approach via temp_a duality**:

The existing `h_content_subset_implies_g_content_reverse` theorem shows:
- If `h_content(u) ⊆ v`, then `g_content(v) ⊆ u`

By the successor construction `predecessor_satisfies_h_persistence`:
- `h_content(u) ⊆ predecessor`

Combined with g/h duality:
- `g_content(predecessor) ⊆ u`

**The F-step connection**: If `F(φ) ∈ predecessor`, then by MCS properties and the seed construction, we can derive constraints. The key insight is that the predecessor seed doesn't introduce new F-obligations - it only includes h_content and P-deferral disjunctions.

**Proposed proof sketch**:
1. If `F(φ) ∈ predecessor` came from Lindenbaum, by negation completeness `¬F(φ) ∉ predecessor`
2. `¬F(φ) = G(¬φ)` by definition
3. If `G(¬φ) ∉ predecessor`, explore what prevents it...
4. Use the relationship between predecessor seed and u's temporal structure

**Complexity Assessment**: This is the most subtle axiom. The proof requires careful analysis of how F-formulas enter the Lindenbaum extension. Consider whether this should remain an axiom or be decomposed into smaller lemmas.

## Related Codebase Patterns

### Existing Similar Axiom: `discreteImmediateSuccSeed_consistent_axiom`

Location: `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (line 300)

This axiom covers a MORE COMPLEX seed that includes **blocking formulas** `¬ψ ∨ ¬G(ψ)`. The deferral seed axioms are simpler because:
- No blocking formulas (these create the main complexity in DiscreteSuccSeed)
- Deferral disjunctions `φ ∨ F(φ)` are trivially derivable from their sources

### Proven Pattern: `forward_temporal_witness_seed_consistent`

Location: `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` (line 79)

This theorem proves consistency of `{ψ} ∪ g_content(M)` when `F(ψ) ∈ M`. The proof uses:
1. Case split on whether the witness `ψ` is in the inconsistent subset
2. Deduction theorem + filter to isolate ψ
3. Generalized temporal K to lift to G(¬ψ)
4. Contradiction with F(ψ) = ¬G(¬ψ)

This exact pattern can be adapted for deferral disjunctions.

## canonicalR Reflexivity/Irreflexivity Conflict

**Task 26 notes**: `canonicalR_irreflexive_axiom` was NOT deleted and contradicts proven `canonicalR_reflexive`.

**Analysis**: This is a known issue documented in:
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`
- `Theories/Bimodal/Metalogic/Bundle/README.md`

The irreflexivity axiom is marked `@[deprecated]` and is isolated to "order-theoretic enhancements" (Layer 2). Basic completeness (Layer 1) uses reflexive semantics.

**Relevance to this task**: The seed consistency axioms are part of Layer 1 (basic successor/predecessor existence). They should be provable WITHOUT the irreflexivity axiom, using only reflexive-compatible lemmas.

## Recommendations

### Priority 1: Prove Axioms 1 and 2 (Seed Consistency)

**Approach**: Adapt `forward_temporal_witness_seed_consistent` proof pattern.

**Steps**:
1. Assume inconsistency: some `L ⊆ seed` derives `⊥`
2. If all elements from g_content: contradiction with `g_content_consistent`
3. If some element is a deferral disjunction `φ ∨ F(φ)`:
   - Apply deduction theorem to extract the disjunction
   - Since disjunction is derivable from `F(φ)` and `F(φ) ∈ u`, show that removing the disjunction and adding `F(φ)` to context preserves derivability
   - Reduce to g_content-only case

**Estimated difficulty**: Medium. The proof pattern exists; adaptation should be straightforward.

### Priority 2: Investigate Axiom 3 (F-step)

**Approach**: More careful analysis needed.

**Options**:
1. **Prove via temporal duality**: Leverage `h_content_subset_implies_g_content_reverse` and explore F/P duality
2. **Prove via MCS properties**: Analyze what F-formulas can enter Lindenbaum extension of predecessor seed
3. **Keep as axiom with stronger justification**: Document the semantic argument more rigorously

**Estimated difficulty**: High. May require new lemmas about Lindenbaum extension behavior.

### Alternative: Task Decomposition

If direct proof is too complex, consider:
1. Create subtask for additional lemmas about deferral disjunction derivability
2. Create subtask for F/P duality lemmas specific to seed extensions
3. Then revisit these axioms with richer infrastructure

## Files Examined

| File | Key Content |
|------|-------------|
| `Bundle/SuccExistence.lean` | Three axioms under analysis |
| `Bundle/WitnessSeed.lean` | Proven seed consistency patterns |
| `Bundle/TemporalContent.lean` | g/h/f/p content definitions |
| `Core/MCSProperties.lean` | MCS closure, implication properties |
| `StagedConstruction/DiscreteSuccSeed.lean` | `g_content_consistent`, blocking formulas |
| `ProofSystem/Axioms.lean` | T-axioms confirmed present |
| `Canonical/CanonicalIrreflexivityAxiom.lean` | Deprecated irreflexivity status |

## Conclusion

Under reflexive semantics with T-axioms, the three seed consistency axioms are likely provable:

1. **Axioms 1-2** (seed consistency): Strong confidence - existing proof pattern in `forward_temporal_witness_seed_consistent` directly applicable.

2. **Axiom 3** (F-step): Moderate confidence - requires more careful analysis of Lindenbaum extension behavior, but semantic argument is sound.

**Recommended next step**: Implement proofs for axioms 1-2 first, which will provide infrastructure and insights for axiom 3.
