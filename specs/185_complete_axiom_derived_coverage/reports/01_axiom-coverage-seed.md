# Seed Research Report: Complete Axiom & Derived Theorem Coverage in modal_search

**Task**: #185 — Complete axiom & derived theorem coverage in modal_search
**Date**: 2026-05-22
**Type**: Seed report (preliminary — expand during /research phase)

## Motivation

The `modal_search` tactic in `Tactics.lean` is the primary proof automation tool for TM bimodal logic, operating at the meta-level in `TacticM` to construct `DerivationTree` proof terms directly. However, its axiom coverage is incomplete: `tryAxiomMatch` (line 507) registers only 12 of the 40 axiom constructors, and its derived theorem coverage is minimal (only `temp_future_derived`).

This means `modal_search` silently fails on goals that are direct instances of unregistered axioms (e.g., `prior_UZ`, `prior_SZ`, the 20+ BX temporal axioms) or derived theorems (e.g., `imp_trans`, `double_negation`, `rcp`, `ecq`). Users must manually apply these with `exact DerivationTree.axiom ...` or explicit proof terms, defeating the purpose of automation.

Completing coverage is the highest-leverage single improvement to the tactics library: it requires no architectural changes, directly expands the set of goals `modal_search` can close, and is prerequisite for all subsequent tactic improvements (lemma database, weakening-aware search, master dispatch).

## Current State

### tryAxiomMatch (Tactics.lean:507-567)

The function applies `DerivationTree.axiom` to the goal, then tries each axiom constructor via `mkAppM`:

```
Currently registered (12 of 40):
  Axiom.modal_t, Axiom.modal_4, Axiom.modal_b, Axiom.modal_5_collapse,
  Axiom.modal_k_dist, Axiom.serial_future, Axiom.serial_past,
  Axiom.modal_future, Axiom.prop_k, Axiom.prop_s, Axiom.ex_falso,
  Axiom.peirce
```

Missing axiom constructors (28):
- **BX temporal (20)**: `connect_future`, `connect_past`, `left_mono_until_G`, `left_mono_since_H`, `right_mono_until`, `right_mono_since`, `self_accum_until`, `self_accum_since`, `absorb_until`, `absorb_since`, `linear_until`, `linear_since`, `temp_linearity`, `temp_linearity_past`, `until_F`, `since_P`, `F_until_equiv`, `P_since_equiv`
- **Uniformity (5)**: `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity`
- **Prior (2)**: `prior_UZ`, `prior_SZ`
- **Z1 (1)**: `z1`

Note: `connect_future` appears in `matchAxiom` in `ProofSearch.lean:472-478` but is NOT in `tryAxiomMatch` in `Tactics.lean`.

### Derived theorem matching (Tactics.lean:508-525)

The `tryAxiomMatch` function has a preliminary derived theorem section (lines 508-525) that only checks `temp_future_derived`. The full derived theorem inventory spans:

**Combinators.lean** (~20 theorems): `imp_trans`, `mp`, `identity`, `b_combinator`, `theorem_flip`, `theorem_app1`, `theorem_app2`, `pairing`, `dni`, `combine_imp_conj`, `combine_imp_conj_3`, `temp_future_derived`

**Propositional.lean** (~30 theorems): `lem`, `double_negation`, `ecq`, `raa`, `efq`, `ldi`, `rdi`, `rcp`, `lce`, `rce`, `lce_imp`, `rce_imp`, `classical_merge`, `iff_intro`, `contrapose_imp`, `contraposition`, `demorgan_conj_neg`, `demorgan_disj_neg`, `ni`, `ne`, `bi_imp`, `de`, `or_elim_neg_neg`

**ModalS5.lean** (~15 theorems): `t_box_to_diamond`, `box_disj_intro`, `box_contrapose`, `k_dist_diamond`, `box_iff_intro`, `t_box_consistency`, `box_conj_iff`, `diamond_disj_iff`, `s5_diamond_box`, `s5_diamond_box_to_truth`

**TemporalDerived.lean** (~15 theorems): `temp_k_dist_derived`, `temp_4_derived`, `G_distribution`, `H_distribution`, `G_transitivity`, `H_transitivity`, `connect_future_thm`, `connect_past_thm`, `until_implies_some_future`, `since_implies_some_past`, `contrapositive`, `formula_or_comm`

**GeneralizedNecessitation.lean** (~5 theorems): `reverse_deduction`, `past_necessitation`, `past_k_dist`, `generalized_modal_k`, `generalized_temporal_k`, `generalized_past_k`

### matchAxiom in ProofSearch.lean (lines 396-517)

The computable search has a separate `matchAxiom` function that returns `Option (Sigma Axiom)`. It covers more axioms than `tryAxiomMatch` (includes `connect_future`, `prior_UZ`, `prior_SZ`, `prop_s`) but is still incomplete (missing all BX temporal axioms beyond `connect_future`). The two implementations are not synchronized.

## Proposed Approach

### Phase 1: Complete axiom registration in tryAxiomMatch

Add all 28 missing axiom constructors to the `axiomCtors` list at `Tactics.lean:540-553`. The existing infrastructure already handles this — each axiom constructor is tried via `mkAppM` with Lean's unifier resolving the formula parameters. No new logic needed, just extending the list.

Order axioms by frequency: propositional/modal first (commonly encountered in proofs), then BX temporal (less common but needed for completeness), then uniformity/prior/Z1 (rare, discrete-specific).

### Phase 2: Add tryDerivedMatch function

Create a new `tryDerivedMatch` function parallel to `tryAxiomMatch` that tries derived theorems. Key design decisions:

1. **Which theorems to register**: Start with theorems of type `⊢ φ` (empty context) since these can be applied via weakening to any goal. Context-dependent theorems (like `ecq : [A, ¬A] ⊢ B`) need the context to match, which is more complex.

2. **Application strategy**: For empty-context theorems, use `apply` + weakening. For context-dependent theorems, extract context and check subset relationship.

3. **Call order in searchProof**: Insert `tryDerivedMatch` between `tryAxiomMatch` and `tryAssumptionMatch` (Tactics.lean:871-876), since derived theorems are cheaper to check than assumption search with `simp`.

### Phase 3: Synchronize matchAxiom in ProofSearch.lean

Update the computable `matchAxiom` (ProofSearch.lean:396-517) to cover the same axiom set. This ensures the computable and tactic searches have consistent behavior.

### Phase 4: Tests

Add test examples for each newly registered axiom and derived theorem, following the existing pattern at Tactics.lean:1182-1317.

## Key Questions for Research Phase

1. **Performance impact of 40-constructor loop**: Does trying all 40 axiom constructors via `mkAppM` have measurable overhead? If so, should we add heuristic pre-filtering based on formula structure (e.g., only try modal axioms when the formula contains `□`)?

2. **Derived theorem ordering**: Which derived theorems are most commonly needed as lemma applications? Analyze the Theorems/ directory to determine frequency of use and prioritize accordingly.

3. **Context-dependent derived theorems**: How should `tryDerivedMatch` handle theorems like `ecq : [A, ¬A] ⊢ B` that require context? Is subset checking via `isDefEq` on list expressions feasible in `TacticM`?

4. **Noncomputable barriers**: Many derived theorems are `noncomputable` (they use the deduction theorem). Does this affect their use in `TacticM`-based proof construction via `mkAppM`?

5. **matchAxiom synchronization**: Should `matchAxiom` in ProofSearch.lean be auto-generated from the axiom inductive, or manually maintained in parallel with `tryAxiomMatch`?

## Estimated Scope

- **Phase 1** (axiom registration): 2 hours — extend list, verify each compiles
- **Phase 2** (derived theorem matching): 3 hours — new function, empty-context theorems first
- **Phase 3** (ProofSearch sync): 1 hour — update matchAxiom
- **Phase 4** (tests): 2 hours — one test per new pattern
- **Total**: ~8 hours (small effort)

## Dependencies

- **Depends on**: Nothing (standalone improvement)
- **Depended on by**: Task 186 (unify search), Task 187 (lemma database), Task 189 (deduction theorem tactic), Task 192 (master dispatch)
- **Related**: Task 181 (Derivable wrapper — parallel, independent)

## References

- `Theories/Bimodal/Automation/Tactics.lean` — `tryAxiomMatch` (line 507), `searchProof` (line 862), test examples (line 1182+)
- `Theories/Bimodal/Automation/ProofSearch.lean` — `matchAxiom` (line 396), `matches_axiom` (line 302)
- `Theories/Bimodal/ProofSystem/Axioms.lean` — 40 axiom constructors (line 74-372)
- `Theories/Bimodal/Theorems/Combinators.lean` — ~20 derived theorems
- `Theories/Bimodal/Theorems/Propositional.lean` — ~30 derived theorems
- `Theories/Bimodal/Theorems/ModalS5.lean` — ~15 derived theorems
- `Theories/Bimodal/Theorems/TemporalDerived.lean` — ~15 derived theorems
- `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean` — ~5 derived theorems
