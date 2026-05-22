# Seed Research Report: Codebase-Wide Tactic Refactoring

**Task**: #193 — Codebase-wide tactic refactoring
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The ProofChecker codebase contains approximately 6,450 lines of hand-written proofs across the `Theorems/` directory (8 files) and approximately 518 lines in `Examples/` (2 files). The vast majority of these proofs use explicit term-level construction — manually calling `DerivationTree.axiom`, `DerivationTree.modus_ponens`, `imp_trans`, `b_combinator`, and similar combinators line by line. This is the Hilbert-style proof pattern: correct but extremely verbose.

With the tactics infrastructure from tasks 185-192 in place, many of these proofs could be dramatically shortened. A 15-line manual proof chain like `imp_trans (imp_trans a b) (imp_trans c d)` might become a single `tm_prove` or `modal_search 5`. The refactoring would:

1. **Demonstrate the tactics as a product**: The tactics library becomes the primary interface for writing proofs in TM logic, showcasing that the automation is capable and reliable.
2. **Reduce maintenance burden**: Shorter tactic proofs are easier to understand, modify, and extend than long chains of explicit constructor applications.
3. **Identify automation gaps**: Any proof that resists simplification reveals a missing tactic capability, feeding back into the tactics development roadmap.
4. **Improve pedagogical value**: The `Examples/` files should showcase the new tactics as the recommended way to write proofs, making the library accessible to newcomers.

This task is the capstone of the entire tactics improvement initiative — it turns the infrastructure into a user-facing product.

## Current State

### Proof Inventory by File

| File | Lines | Proof Count | Style | Tactic Potential |
|------|-------|-------------|-------|-----------------|
| `Theorems/Combinators.lean` | 673 | ~15 defs | Explicit term | High — many are pure propositional |
| `Theorems/Propositional.lean` | 1,712 | ~20 defs | Explicit term + `by` blocks | Very high — all propositional |
| `Theorems/ModalS5.lean` | 859 | ~10 defs | Mixed (some use combinators) | High — modal axiom applications |
| `Theorems/ModalS4.lean` | 468 | ~8 defs | Mixed | High |
| `Theorems/TemporalDerived.lean` | 366 | ~6 defs | Mixed | Medium — temporal complexity |
| `Theorems/GeneralizedNecessitation.lean` | 236 | ~4 defs | Structural induction | Low — inherently structural |
| `Theorems/Perpetuity/Principles.lean` | 900 | ~12 defs | Explicit term | High |
| `Theorems/Perpetuity/Bridge.lean` | 993 | ~15 defs | Explicit term | High |
| `Theorems/Perpetuity/Helpers.lean` | 155 | ~5 defs | Explicit term | Medium |
| `Examples/BimodalProofs.lean` | 241 | ~15 examples | Mixed | Very high (showcase) |
| `Examples/TemporalStructures.lean` | 277 | ~10 examples | Mixed | Very high (showcase) |

**Total refactoring surface**: ~6,880 lines, ~120 proofs

### Current Usage Patterns

Examining `Theorems/Combinators.lean:83-92` (`imp_trans`):
```lean
def imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by
  have s_axiom : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    DerivationTree.axiom [] _ (Axiom.prop_s (B.imp C) A)
  have h3 : ⊢ A.imp (B.imp C) := DerivationTree.modus_ponens [] (B.imp C) (A.imp (B.imp C)) s_axiom h2
  have k_axiom : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    DerivationTree.axiom [] _ (Axiom.prop_k A B C)
  have h4 : ⊢ (A.imp B).imp (A.imp C) :=
    DerivationTree.modus_ponens [] (A.imp (B.imp C)) ((A.imp B).imp (A.imp C)) k_axiom h3
  exact DerivationTree.modus_ponens [] (A.imp B) (A.imp C) h4 h1
```

This 7-line proof has a clear pattern: S axiom + K axiom + two modus ponens. With a mature `modal_search`, this becomes:
```lean
def imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by
  modal_search  -- or: tm_prove
```

But `imp_trans` takes *hypotheses* (`h1`, `h2`), so `modal_search` currently can't use them (it only searches the formula context `G`, not Lean hypotheses). The deduction theorem tactic (task 189) or weakening-aware search (task 188) would need to bridge this gap.

### DerivationTree Constructor Usage Counts

Across all `Theorems/` files (approximate from grep):

| Pattern | Count | Notes |
|---------|-------|-------|
| `DerivationTree.axiom` | ~120 | Most common — axiom application |
| `DerivationTree.modus_ponens` | ~150 | Explicit MP chains |
| `DerivationTree.assumption` | ~30 | Context assumption lookup |
| `DerivationTree.weakening` | ~25 | Context weakening |
| `DerivationTree.necessitation` | ~15 | Modal necessitation |
| `DerivationTree.temporal_necessitation` | ~8 | Temporal necessitation |
| `DerivationTree.temporal_duality` | ~5 | Temporal duality rule |
| `imp_trans` | ~80 | Combinator usage |
| `identity` | ~15 | Identity combinator |
| `b_combinator` | ~20 | Composition combinator |
| `theorem_flip` | ~10 | Flip combinator |
| `modal_search` | ~20 | Already using tactics |

### Metalogic/ Files — Structural vs Automatable

The `Metalogic/` directory (50,000+ lines across 30+ files) is largely structural: soundness proofs do induction on `DerivationTree`, the deduction theorem uses well-founded recursion on tree height, completeness constructs explicit trees from maximal consistent sets. These are NOT candidates for tactic refactoring — they inherently need the Type-valued tree structure.

However, some Metalogic files contain derivability subgoals that could benefit:
- `MaximalConsistent.lean` — consistency/derivability side conditions
- `Completeness.lean` — small derivability lemmas within the completeness proof
- `MCSProperties.lean` — many `Nonempty (DerivationTree ...)` goals

These would use `Derivable` + aesop/`tm_prove` rather than explicit tree construction.

## Proposed Approach

### Phase 1: Audit and Classify (8h)

Write a script/analysis that classifies each proof in `Theorems/` by:
- Whether it's a closed theorem (`⊢ p`) or a derived rule (hypotheses → conclusion)
- Whether the formula is propositional, modal, temporal, or bimodal
- Current proof length (lines)
- Whether `modal_search` can already close it (test empirically)

Produce a spreadsheet: `File | Proof | Category | CurrentLines | ModalSearchClosable | EstimatedNewLines`.

### Phase 2: Propositional Theorems (8h)

Refactor all propositional theorems using `decide_prop` or `propositional_search`:
- `Theorems/Propositional.lean`: `lem`, `ecq`, `raa`, `efq`, `lce`, `rce`, `ldi`, `rdi`, etc.
- `Theorems/Combinators.lean`: `identity`, `b_combinator`, `theorem_flip`, `pairing`, `dni`, etc.

Many of these should become one-liners. Proofs that take hypotheses need the deduction theorem integration.

### Phase 3: Modal Theorems (8h)

Refactor modal S5 and S4 theorems:
- `Theorems/ModalS5.lean`: `t_box_to_diamond`, `box_disj_intro`, `box_contrapose`, etc.
- `Theorems/ModalS4.lean`: modal 4 consequences

These require `modal_search` with the lemma database (task 187) to know about `box_mono`, `diamond_mono`, `imp_trans` etc.

### Phase 4: Temporal and Perpetuity Theorems (8h)

Refactor temporal derived theorems and perpetuity principles:
- `Theorems/TemporalDerived.lean`: `temp_k_dist_derived`, `temp_4_derived`
- `Theorems/Perpetuity/`: modal-temporal interaction theorems

These are the hardest — temporal proofs often involve intricate axiom chains.

### Phase 5: Examples Rewrite (4h)

Rewrite `Examples/BimodalProofs.lean` and `Examples/TemporalStructures.lean` as showcases:
- Before/after comparisons
- Demonstrate `tm_prove`, `modal_search`, `decide_prop`
- Pedagogical comments explaining the tactic approach

### Phase 6: Metalogic Integration (4h)

Apply `Derivable` + `tm_prove` to derivability subgoals in Metalogic/:
- Replace `Nonempty (DerivationTree ...)` patterns with `Derivable`
- Use aesop for simple derivability side conditions

## Key Questions for Research Phase

1. How many of the ~120 proofs in `Theorems/` can `modal_search` (current, unmodified) already close? This sets the baseline.
2. For proofs with hypotheses (derived rules like `imp_trans`), how should the tactics consume Lean-level hypotheses? Options: (a) deduction theorem, (b) add hypotheses to context via weakening, (c) use `have` chains.
3. Should refactored proofs use `by tm_prove` or explicit tactic names (`by modal_search 5`)? The former is more uniform but hides the strategy; the latter documents the approach.
4. How to handle `noncomputable` propagation? Many theorems in `Theorems/` are `noncomputable` (because `generalized_modal_k` uses the deduction theorem). Will tactic-generated proofs change this?
5. What is the target compression ratio? For propositional theorems, 10:1 is realistic (15-line proofs → 1-2 lines). For modal/temporal theorems, 3:1 to 5:1. What is the overall target?
6. Should combinators like `imp_trans`, `identity`, `b_combinator` remain as named lemmas (for use by other proofs) even if they can be one-liners? Yes — they serve as API surface for dependent proofs.

## Estimated Scope

- **Phase 1**: Audit and classify (8h)
- **Phase 2**: Propositional refactoring (8h)
- **Phase 3**: Modal refactoring (8h)
- **Phase 4**: Temporal/perpetuity refactoring (8h)
- **Phase 5**: Examples rewrite (4h)
- **Phase 6**: Metalogic integration (4h)
- **Total**: ~40 hours

## Dependencies

- **Depends on**: Task 192 (master tactic dispatch — provides `tm_prove`)
- **Transitively depends on**: Tasks 181, 185, 187, 188, 189, 190, 191 (all tactics infrastructure)
- **Depended on by**: None (capstone task)

## References

- `Theories/Bimodal/Theorems/Combinators.lean` — 673 lines, 58 DerivationTree references
- `Theories/Bimodal/Theorems/Propositional.lean` — 1,712 lines, 135 DerivationTree references
- `Theories/Bimodal/Theorems/ModalS5.lean` — 859 lines, 34 DerivationTree references
- `Theories/Bimodal/Theorems/ModalS4.lean` — 468 lines, 21 DerivationTree references
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — 366 lines, 21 DerivationTree references
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — 236 lines, 19 DerivationTree references
- `Theories/Bimodal/Theorems/Perpetuity/Principles.lean` — 900 lines, 55 DerivationTree references
- `Theories/Bimodal/Theorems/Perpetuity/Bridge.lean` — 993 lines, 63 DerivationTree references
- `Theories/Bimodal/Examples/BimodalProofs.lean` — 241 lines
- `Theories/Bimodal/Examples/TemporalStructures.lean` — 277 lines
