# Research Report: Complete Axiom & Derived Theorem Coverage in modal_search

**Task**: #185 — Complete axiom & derived theorem coverage in modal_search
**Date**: 2026-05-26
**Session**: sess_1779809662_d9784a
**Type**: Full research report (expands seed report 01)

---

## 1. Executive Summary

The `modal_search` tactic in `Tactics.lean` handles 12 of 41 axiom constructors and only 1 derived theorem (`temp_future_derived`). This report provides a complete inventory of all 41 axiom constructors, maps each to its `tryAxiomMatch` status, catalogs 90+ derived theorems across 8 source files, analyzes the `modal_search` architecture for integration points, and recommends a phased implementation plan.

Key findings:
- **29 axiom constructors missing** from `tryAxiomMatch` (the seed report counted 28; `enrichment_until` and `enrichment_since` were not listed)
- **All missing axioms can be added by extending the `axiomCtors` list** — no structural changes needed
- **Non-base axioms (density, prior_UZ, prior_SZ, z1) require frame-class handling** — `trivial` won't close `h_fc` goals for these; need conditional `decide` or `Decidable` instance
- **~25 derived theorems are viable `tryDerivedMatch` candidates** (empty-context, simple patterns)
- **The computable `matchAxiom` in ProofSearch.lean covers 16 constructors** and is out of sync with `tryAxiomMatch`

---

## 2. Complete Axiom Coverage Matrix

### 2.1 Full Axiom Constructor List (41 total)

The `Axiom` inductive in `Axioms.lean` has 41 constructors organized into 8 layers:

| # | Constructor | Layer | Formula Schema | minFrameClass | In tryAxiomMatch? | In matchAxiom? |
|---|-------------|-------|---------------|---------------|-------------------|----------------|
| 1 | `prop_k` | Propositional | `(φ→(ψ→χ))→((φ→ψ)→(φ→χ))` | Base | YES | YES |
| 2 | `prop_s` | Propositional | `φ→(ψ→φ)` | Base | YES | YES |
| 3 | `ex_falso` | Propositional | `⊥→φ` | Base | YES | YES |
| 4 | `peirce` | Propositional | `((φ→ψ)→φ)→φ` | Base | YES | YES |
| 5 | `modal_t` | S5 Modal | `□φ→φ` | Base | YES | YES |
| 6 | `modal_4` | S5 Modal | `□φ→□□φ` | Base | YES | YES |
| 7 | `modal_b` | S5 Modal | `φ→□◇φ` | Base | YES | YES |
| 8 | `modal_5_collapse` | S5 Modal | `◇□φ→□φ` | Base | YES | YES |
| 9 | `modal_k_dist` | S5 Modal | `□(φ→ψ)→(□φ→□ψ)` | Base | YES | YES |
| 10 | `serial_future` | BX Temporal | `⊤→F(⊤)` | Base | YES | NO |
| 11 | `serial_past` | BX Temporal | `⊤→P(⊤)` | Base | YES | NO |
| 12 | `left_mono_until_G` | BX Temporal | `G(φ→χ)→(U(ψ,φ)→U(ψ,χ))` | Base | **NO** | NO |
| 13 | `left_mono_since_H` | BX Temporal | `H(φ→χ)→(S(ψ,φ)→S(ψ,χ))` | Base | **NO** | NO |
| 14 | `right_mono_until` | BX Temporal | `G(φ→ψ)→(U(φ,χ)→U(ψ,χ))` | Base | **NO** | NO |
| 15 | `right_mono_since` | BX Temporal | `H(φ→ψ)→(S(φ,χ)→S(ψ,χ))` | Base | **NO** | NO |
| 16 | `connect_future` | BX Temporal | `φ→G(Pφ)` | Base | **NO** | YES |
| 17 | `connect_past` | BX Temporal | `φ→H(Fφ)` | Base | **NO** | NO |
| 18 | `enrichment_until` | BX Temporal | `p∧U(ψ,φ)→U(ψ∧S(p,φ),φ)` | Base | **NO** | NO |
| 19 | `enrichment_since` | BX Temporal | `p∧S(ψ,φ)→S(ψ∧U(p,φ),φ)` | Base | **NO** | NO |
| 20 | `self_accum_until` | BX Temporal | `U(ψ,φ)→U(ψ,φ∧U(ψ,φ))` | Base | **NO** | NO |
| 21 | `self_accum_since` | BX Temporal | `S(ψ,φ)→S(ψ,φ∧S(ψ,φ))` | Base | **NO** | NO |
| 22 | `absorb_until` | BX Temporal | `U(φ∧U(ψ,φ),φ)→U(ψ,φ)` | Base | **NO** | NO |
| 23 | `absorb_since` | BX Temporal | `S(φ∧S(ψ,φ),φ)→S(ψ,φ)` | Base | **NO** | NO |
| 24 | `linear_until` | BX Temporal | `U(ψ,φ)∧U(θ,χ)→...` | Base | **NO** | NO |
| 25 | `linear_since` | BX Temporal | `S(ψ,φ)∧S(θ,χ)→...` | Base | **NO** | NO |
| 26 | `until_F` | BX Temporal | `U(ψ,φ)→F(ψ)` | Base | **NO** | NO |
| 27 | `since_P` | BX Temporal | `S(ψ,φ)→P(ψ)` | Base | **NO** | NO |
| 28 | `temp_linearity` | BX Temporal | `F(φ)∧F(ψ)→F(φ∧ψ)∨...` | Base | **NO** | NO |
| 29 | `temp_linearity_past` | BX Temporal | `P(φ)∧P(ψ)→P(φ∧ψ)∨...` | Base | **NO** | NO |
| 30 | `F_until_equiv` | BX Temporal | `F(φ)→U(φ,⊤)` | Base | **NO** | NO |
| 31 | `P_since_equiv` | BX Temporal | `P(φ)→S(φ,⊤)` | Base | **NO** | NO |
| 32 | `modal_future` | Interaction | `□φ→□(Gφ)` | Base | YES | YES |
| 33 | `discrete_symm_fwd` | Uniformity | `U(⊤,⊥)→S(⊤,⊥)` | Base | **NO** | NO |
| 34 | `discrete_symm_bwd` | Uniformity | `S(⊤,⊥)→U(⊤,⊥)` | Base | **NO** | NO |
| 35 | `discrete_propagate_fwd` | Uniformity | `U(⊤,⊥)→G(U(⊤,⊥))` | Base | **NO** | NO |
| 36 | `discrete_propagate_bwd` | Uniformity | `U(⊤,⊥)→H(U(⊤,⊥))` | Base | **NO** | NO |
| 37 | `discrete_box_necessity` | Uniformity | `U(⊤,⊥)→□(U(⊤,⊥))` | Base | **NO** | NO |
| 38 | `prior_UZ` | Prior | `F(φ)→U(φ,¬φ)` | **Discrete** | **NO** | YES |
| 39 | `prior_SZ` | Prior | `P(φ)→S(φ,¬φ)` | **Discrete** | **NO** | YES |
| 40 | `z1` | Z1 | `G(Gφ→φ)→(FGφ→Gφ)` | **Discrete** | **NO** | NO |
| 41 | `density` | Density | `GGφ→Gφ` | **Dense** | **NO** | NO |

**Summary**:
- **tryAxiomMatch**: 12/41 covered (all Base, all in the `axiomCtors` list at Tactics.lean:556-569)
- **matchAxiom (ProofSearch.lean)**: 16/41 covered (adds `connect_future`, `prior_UZ`, `prior_SZ`, `prop_s`)
- **Missing from both**: 25 constructors (all BX temporal beyond serial/connect_future, enrichment, uniformity, z1, density)

### 2.2 Frame Class Handling Issue

The current `tryAxiomMatch` closes `h_fc` goals with `trivial` (Tactics.lean:578). This works for all 37 base axioms because `FrameClass.Base ≤ fc` is `True` for all `fc`. However:

- **`density`** has `minFrameClass = .Dense`. The `h_fc` goal becomes `FrameClass.Dense ≤ fc`, which is `True` only when `fc = .Dense`. If the goal's frame class is `.Base` or `.Discrete`, `trivial` will fail.
- **`prior_UZ`, `prior_SZ`, `z1`** have `minFrameClass = .Discrete`. Similarly, `h_fc` requires `fc = .Discrete`.

**Resolution**: The existing `try/catch` pattern handles this correctly — if `trivial` fails on the `h_fc` goal, the axiom is simply skipped. So adding these to the `axiomCtors` list is safe. When the goal's `fc` matches, `trivial` (or `decide`) succeeds. When it doesn't, the axiom correctly fails to apply. The `DecidableRel` instance on `FrameClass.LE` (Axioms.lean:423) ensures `decide` works as a fallback for `trivial`.

However, for robustness, the `h_fc` closing tactic should be `first | trivial | decide` to handle both `True`-reducing and `Decidable`-based cases.

---

## 3. tryAxiomMatch Architecture Analysis

### 3.1 Current Structure (Tactics.lean:511-588)

```
tryAxiomMatch(goal, ctx, formula) :=
  1. Try derived theorems (lines 513-529):
     - Only temp_future_derived currently
     - Uses `goal.apply derivedExpr` + check remainingGoals.isEmpty
  
  2. Try axiom constructors (lines 531-588):
     a. Apply DerivationTree.axiom to goal → creates subgoals [Axiom φ, h_fc]
     b. Identify axiomGoal vs fcGoals from subgoals
     c. For each axiomCtor in axiomCtors list:
        - Try axiomGoal.apply ctorExpr
        - If successful, close all fcGoals with `trivial`
     d. If no match, throwError
```

### 3.2 The `axiomCtors` List (Tactics.lean:556-569)

```lean
let axiomCtors : List Name := [
  ``Axiom.modal_t,           -- 1
  ``Axiom.modal_4,           -- 2
  ``Axiom.modal_b,           -- 3
  ``Axiom.modal_5_collapse,  -- 4
  ``Axiom.modal_k_dist,      -- 5
  ``Axiom.serial_future,     -- 6
  ``Axiom.serial_past,       -- 7
  ``Axiom.modal_future,      -- 8
  ``Axiom.prop_k,            -- 9
  ``Axiom.prop_s,            -- 10
  ``Axiom.ex_falso,          -- 11
  ``Axiom.peirce             -- 12
]
```

### 3.3 Adding Missing Axioms

Adding the remaining 29 axiom constructors is mechanical: append their `Name`s to the `axiomCtors` list. The existing infrastructure handles:
- Formula parameter inference via Lean's unifier (`apply ctorExpr` resolves metavariables)
- Multi-parameter axioms (e.g., `linear_until` has 4 formula params) — Lean infers all from the goal
- Frame class gating — `h_fc` closing via `trivial`/`decide`

**Ordering recommendation**: Keep the current 12 first (they're the most commonly encountered in proofs), then add in layer order:
1. BX temporal (20): connect_future/past, left_mono_until_G/since_H, right_mono_until/since, enrichment_until/since, self_accum_until/since, absorb_until/since, linear_until/since, until_F/since_P, temp_linearity/past, F_until_equiv/P_since_equiv
2. Uniformity (5): discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity
3. Discrete (3): prior_UZ, prior_SZ, z1
4. Dense (1): density

### 3.4 Performance Consideration

Trying 41 axiom constructors via `apply` involves Lean's unifier at each step. The `observing?` wrapper (line 532) saves/restores metavariable state on failure. For goals that DO match an axiom, only 1-12 iterations are needed (matched early). For goals that DON'T match any axiom, all 41 must be tried before falling through.

**Mitigation options** (for future optimization, not blocking):
1. **Pre-filter by formula head**: If the goal formula is `□φ → ...`, skip non-modal axioms
2. **Two-pass strategy**: Check `matches_axiom` (pure structural match, O(1)) before attempting `apply` (involves unifier)
3. **Accept the overhead**: 41 `apply` attempts with `observing?` is fast in practice (each is O(1) unification)

Recommendation: Accept the overhead for now. Add all 41 axioms. Optimize later if profiling shows a bottleneck.

---

## 4. Derived Theorem Inventory

### 4.1 Combinators.lean (675 lines, ~12 public theorems)

| Theorem | Type Signature | Context | Computable? | tryDerivedMatch Candidate? |
|---------|---------------|---------|-------------|---------------------------|
| `imp_trans` | `⊢[fc] (A→B) → ⊢[fc] (B→C) → ⊢[fc] (A→C)` | `[]` | Yes | NO (two-premise) |
| `mp` | `⊢[fc] A → ⊢[fc] (A→B) → ⊢[fc] B` | `[]` | Yes | NO (two-premise) |
| `identity` | `⊢[fc] A→A` | `[]` | Yes | YES (single-formula pattern) |
| `b_combinator` | `⊢[fc] (B→C)→((A→B)→(A→C))` | `[]` | Yes | YES (structural match) |
| `theorem_flip` | `⊢[fc] (A→B→C)→(B→A→C)` | `[]` | Yes | YES (structural match) |
| `theorem_app1` | `⊢[fc] A→((A→B)→B)` | `[]` | Yes | YES (structural match) |
| `theorem_app2` | `⊢[fc] A→(B→((A→B→C)→C))` | `[]` | Yes | LOW PRIORITY (rare) |
| `pairing` | `⊢[fc] A→(B→(A∧B))` | `[]` | Yes | YES (conjunction intro) |
| `dni` | `⊢[fc] A→¬¬A` | `[]` | Yes | YES (negation pattern) |
| `combine_imp_conj` | `⊢[fc] (P→A) → ⊢[fc] (P→B) → ⊢[fc] (P→(A∧B))` | `[]` | Yes | NO (two-premise) |
| `combine_imp_conj_3` | 3-premise variant | `[]` | Yes | NO (three-premise) |
| `temp_future_derived` | `⊢[fc] □φ→G(□φ)` | `[]` | Yes | ALREADY IN (line 515) |

### 4.2 Propositional.lean (1704 lines, ~30 public theorems)

| Theorem | Type Signature | Context | Computable? | tryDerivedMatch Candidate? |
|---------|---------------|---------|-------------|---------------------------|
| `lem` | `⊢ A∨¬A` | `[]` | Yes | YES (but LEM is A.neg→A.neg by def) |
| `double_negation` | `⊢[fc] ¬¬φ→φ` | `[]` | Yes (noncomp) | YES (DNE pattern) |
| `ecq` | `[A, ¬A] ⊢ B` | `[A, ¬A]` | Yes (noncomp) | COMPLEX (context-dependent) |
| `raa` | `⊢ A→(¬A→B)` | `[]` | Yes | YES (RAA pattern) |
| `efq` | `⊢ ¬A→(A→B)` | `[]` | Yes (noncomp) | YES (EFQ pattern) |
| `ldi` | `[A] ⊢ A∨B` | `[A]` | Yes (noncomp) | COMPLEX (context-dependent) |
| `rdi` | `[B] ⊢ A∨B` | `[B]` | Yes (noncomp) | COMPLEX (context-dependent) |
| `rcp` | `(Γ ⊢ ¬A→¬B) → (Γ ⊢ B→A)` | any | Yes (noncomp) | NO (meta-level transform) |
| `lce` | `[A∧B] ⊢ A` | `[A∧B]` | Yes (noncomp) | COMPLEX (context-dependent) |
| `rce` | `[A∧B] ⊢ B` | `[A∧B]` | Yes (noncomp) | COMPLEX (context-dependent) |
| `lce_imp` | `⊢[fc] (A∧B)→A` | `[]` | Yes | YES (conjunction elim) |
| `rce_imp` | `⊢[fc] (A∧B)→B` | `[]` | Yes | YES (conjunction elim) |
| `classical_merge` | `⊢ (P→Q)→((¬P→Q)→Q)` | `[]` | Yes (noncomp) | YES (case analysis) |
| `contrapose_imp` | `⊢ (A→B)→(¬B→¬A)` | `[]` | Yes | YES (contraposition) |
| `contraposition` | `(⊢ A→B) → ⊢ ¬B→¬A` | meta | Yes (noncomp) | NO (meta-level) |
| `iff_intro` | `(⊢ A→B) → (⊢ B→A) → ⊢ A↔B` | meta | Yes (noncomp) | NO (meta-level) |
| `demorgan_conj_neg` | `⊢ ¬(A∧B)↔(¬A∨¬B)` | `[]` | Yes (noncomp) | LOW PRIORITY |
| `demorgan_disj_neg` | `⊢ ¬(A∨B)↔(¬A∧¬B)` | `[]` | Yes (noncomp) | LOW PRIORITY |
| `ni` | `((A::Γ)⊢¬B)→((A::Γ)⊢B)→(Γ⊢¬A)` | context | Yes (noncomp) | NO (meta-level) |
| `ne` | `((¬A::Γ)⊢¬B)→((¬A::Γ)⊢B)→(Γ⊢A)` | context | Yes (noncomp) | NO (meta-level) |
| `bi_imp` | `⊢ (A→B→C)→((A∧B)→C)` | `[]` | Yes | YES (useful pattern) |
| `de` | `((A::Γ)⊢C)→((B::Γ)⊢C)→((A∨B)::Γ)⊢C` | context | noncomp | NO (meta-level) |
| `or_elim_neg_neg` | similar | context | noncomp | NO (meta-level) |

### 4.3 ModalS5.lean (859 lines, ~12 public theorems)

| Theorem | Type Signature | Context | Computable? | tryDerivedMatch Candidate? |
|---------|---------------|---------|-------------|---------------------------|
| `t_box_to_diamond` | `⊢ □A→◇A` | `[]` | Yes | YES |
| `box_disj_intro` | `⊢ (□A∨□B)→□(A∨B)` | `[]` | noncomp | YES |
| `box_contrapose` | `⊢ □(A→B)→□(¬B→¬A)` | `[]` | Yes | YES |
| `k_dist_diamond` | `⊢ □(A→B)→(◇A→◇B)` | `[]` | Yes | YES |
| `box_iff_intro` | `(⊢ (A→B)∧(B→A)) → ⊢ □A↔□B` | meta | noncomp | NO (meta-level) |
| `t_box_consistency` | `⊢ □(A∧¬A)→⊥` | `[]` | Yes | YES |
| `box_conj_iff` | `⊢ □(A∧B)↔(□A∧□B)` | `[]` | noncomp | LOW PRIORITY |
| `diamond_disj_iff` | `⊢ ◇(A∨B)↔(◇A∨◇B)` | `[]` | noncomp | LOW PRIORITY |
| `s5_diamond_box` | `⊢ ◇□A↔□A` | `[]` | Yes | LOW PRIORITY |
| `s5_diamond_box_to_truth` | `⊢ ◇□A→A` | `[]` | Yes | YES |

### 4.4 TemporalDerived.lean (366 lines, ~12 public theorems)

| Theorem | Type Signature | Context | tryDerivedMatch Candidate? |
|---------|---------------|---------|---------------------------|
| `temp_k_dist_derived` | `⊢ G(φ→ψ)→(Gφ→Gψ)` | `[]` | YES (was an axiom) |
| `temp_4_derived` | `⊢ Gφ→GGφ` | `[]` | YES (was an axiom) |
| `G_distribution` | alias of temp_k_dist_derived | `[]` | YES |
| `H_distribution` | `⊢ H(φ→ψ)→(Hφ→Hψ)` | `[]` | YES |
| `G_transitivity` | alias of temp_4_derived | `[]` | YES |
| `H_transitivity` | `⊢ Hφ→HHφ` | `[]` | YES |
| `connect_future_thm` | `⊢ φ→G(Pφ)` | `[]` | NO (same as axiom) |
| `connect_past_thm` | `⊢ φ→H(Fφ)` | `[]` | NO (same as axiom) |
| `until_implies_some_future` | `⊢ U(ψ,φ)→F(ψ)` | `[]` | NO (same as until_F axiom) |
| `since_implies_some_past` | `⊢ S(ψ,φ)→P(ψ)` | `[]` | NO (same as since_P axiom) |
| `contrapositive` | `⊢ (A→B)→(¬B→¬A)` | `[]` | DUPLICATE of Propositional |
| `formula_or_comm` | `⊢ (A∨B)→(B∨A)` | `[]` | YES |

### 4.5 GeneralizedNecessitation.lean (240 lines, ~7 public theorems)

| Theorem | Type Signature | Context | tryDerivedMatch Candidate? |
|---------|---------------|---------|---------------------------|
| `reverse_deduction` | `(Γ ⊢[fc] A→B) → (A::Γ ⊢[fc] B)` | meta | NO (meta-level) |
| `past_necessitation` | `(⊢[fc] φ) → ⊢[fc] Hφ` | meta | NO (meta-level) |
| `past_k_dist` | `⊢[fc] H(A→B)→(HA→HB)` | `[]` | YES |
| `generalized_modal_k` | `(Γ⊢[fc]φ) → (□Γ⊢[fc]□φ)` | meta | NO (used as strategy) |
| `generalized_temporal_k` | `(Γ⊢[fc]φ) → (GΓ⊢[fc]Gφ)` | meta | NO (used as strategy) |
| `generalized_past_k` | `(Γ⊢[fc]φ) → (HΓ⊢[fc]Hφ)` | meta | NO (used as strategy) |

### 4.6 Perpetuity/ (Principles.lean 900 lines, Helpers.lean 158 lines, Bridge.lean 993 lines)

Selected key theorems:

| Theorem | Type Signature | tryDerivedMatch Candidate? |
|---------|---------------|---------------------------|
| `box_mono` | `(⊢ A→B) → ⊢ □A→□B` | NO (meta-level) |
| `diamond_mono` | `(⊢ A→B) → ⊢ ◇A→◇B` | NO (meta-level) |
| `future_mono` | `(⊢ A→B) → ⊢ GA→GB` | NO (meta-level) |
| `past_mono` | `(⊢ A→B) → ⊢ HA→HB` | NO (meta-level) |
| `lce_imp` (Bridge) | `⊢ (A∧B)→A` | DUPLICATE of Propositional |
| `rce_imp` (Bridge) | `⊢ (A∧B)→B` | DUPLICATE of Propositional |
| `perpetuity_1` | `⊢ □φ→△φ` | YES (always pattern) |
| `perpetuity_3` | `⊢ □φ→□(△φ)` | YES |
| `diamond_4` | `⊢ ◇◇φ→◇φ` | YES |
| `modal_5` | `⊢ ◇φ→□◇φ` | YES |
| `box_to_future` | `⊢ □φ→Gφ` | YES |
| `box_to_past` | `⊢ □φ→Hφ` | YES |
| `box_to_present` | `⊢ □φ→φ` | NO (same as modal_t axiom) |

### 4.7 Recommended tryDerivedMatch Candidates (Priority Order)

**Tier 1 — High-value, empty-context, simple formula patterns** (add first):

1. `identity` — `⊢[fc] A→A` (matches any `φ.imp φ`)
2. `double_negation` — `⊢[fc] ¬¬φ→φ` (DNE)
3. `raa` — `⊢ A→(¬A→B)` (reductio)
4. `efq` — `⊢ ¬A→(A→B)` (ex falso)
5. `lce_imp` — `⊢[fc] (A∧B)→A` (left conjunction elimination)
6. `rce_imp` — `⊢[fc] (A∧B)→B` (right conjunction elimination)
7. `contrapose_imp` — `⊢ (A→B)→(¬B→¬A)` (contraposition)
8. `pairing` — `⊢[fc] A→(B→(A∧B))` (conjunction introduction)
9. `dni` — `⊢[fc] A→¬¬A` (double negation introduction)
10. `b_combinator` — `⊢[fc] (B→C)→((A→B)→(A→C))` (composition)
11. `theorem_flip` — `⊢[fc] (A→B→C)→(B→A→C)` (flip)
12. `theorem_app1` — `⊢[fc] A→((A→B)→B)` (application)

**Tier 2 — Temporal/Modal derived, empty-context**:

13. `temp_k_dist_derived` — `⊢ G(φ→ψ)→(Gφ→Gψ)` (G-distribution)
14. `temp_4_derived` — `⊢ Gφ→GGφ` (G-transitivity)
15. `H_distribution` — `⊢ H(φ→ψ)→(Hφ→Hψ)` (H-distribution)
16. `H_transitivity` — `⊢ Hφ→HHφ` (H-transitivity)
17. `t_box_to_diamond` — `⊢ □A→◇A`
18. `k_dist_diamond` — `⊢ □(A→B)→(◇A→◇B)`
19. `diamond_4` — `⊢ ◇◇φ→◇φ`
20. `modal_5` — `⊢ ◇φ→□◇φ`
21. `box_to_future` — `⊢ □φ→Gφ`
22. `box_to_past` — `⊢ □φ→Hφ`
23. `formula_or_comm` — `⊢ (A∨B)→(B∨A)`
24. `bi_imp` — `⊢ (A→B→C)→((A∧B)→C)`
25. `classical_merge` — `⊢ (P→Q)→((¬P→Q)→Q)`

---

## 5. modal_search Architecture

### 5.1 Search Flow (Tactics.lean:887-918)

```
searchProof(goal, depth, maxDepth) :=
  if depth = 0: return false
  extract (fc, ctx, formula) from goal

  Strategy 1: tryAxiomMatch(goal, ctx, formula)         -- cheapest
  Strategy 2: tryAssumptionMatch(goal, ctx, formula)     -- medium
  Strategy 3: tryModusPonens(goal, fc, ctx, formula, searchProof, depth)  -- expensive
  Strategy 4: tryModalK(goal, fc, ctx, formula, searchProof, depth)       -- structural
  Strategy 5: tryTemporalK(goal, fc, ctx, formula, searchProof, depth)    -- structural
```

### 5.2 Where `tryDerivedMatch` Fits

Insert between Strategy 1 (axiom) and Strategy 2 (assumption):

```
Strategy 1:   tryAxiomMatch        -- instantaneous axiom matching
Strategy 1.5: tryDerivedMatch      -- derived theorem matching (NEW)
Strategy 2:   tryAssumptionMatch   -- context membership
Strategy 3:   tryModusPonens       -- backward chaining
Strategy 4:   tryModalK            -- structural □ reduction
Strategy 5:   tryTemporalK         -- structural G reduction
```

Rationale: Derived theorems are direct `apply` targets (no recursive search), cheaper than modus ponens but slightly more expensive than axiom matching (since there are ~25 theorems vs 41 axiom constructors, but theorem application involves more complex unification).

### 5.3 Design of `tryDerivedMatch`

The function should mirror the derived theorem section of `tryAxiomMatch` (lines 513-529) but with more entries:

```lean
def tryDerivedMatch (goal : MVarId) (_ctx _formula : Expr) : TacticM Bool := do
  let result ← observing? do
    setGoals [goal]
    let derivedExprs : List Name := [
      ``Combinators.identity,
      ``Propositional.double_negation,
      ``Propositional.raa,
      ``Propositional.efq,
      ``Propositional.lce_imp,
      ``Propositional.rce_imp,
      ``Propositional.contrapose_imp,
      ``Combinators.pairing,
      ``Combinators.dni,
      ``Combinators.b_combinator,
      ``Combinators.theorem_flip,
      ``Combinators.theorem_app1,
      -- ... Tier 2 theorems ...
    ]
    for derivedName in derivedExprs do
      try
        let derivedExpr := mkConst derivedName
        let remainingGoals ← goal.apply derivedExpr
        if remainingGoals.isEmpty then
          setGoals []
          return ()
      catch _ =>
        continue
    throwError "no derived theorem matched"
  return result.isSome
```

**Key point**: These theorems all produce `DerivationTree fc [] φ` (empty context). When the actual goal has a non-empty context `Γ ⊢ φ`, the derived theorem alone doesn't suffice — it produces `[] ⊢ φ`, which needs weakening to `Γ ⊢ φ`. This is handled automatically if the theorem is registered at `⊢[fc]` — Lean's `apply` will unify the formula but leave the context mismatch. 

**Solution**: After applying the derived theorem, if there's a remaining membership/subset goal, close it with `exact List.nil_subset _` or `simp`. This mirrors how `tryAxiomMatch` handles the context: axioms are stated with `(Γ : Context)` as an explicit parameter, so `apply` works directly. Derived theorems typically have `[]` hardcoded.

**Alternative**: Wrap derived theorem application with explicit weakening:
```lean
let weakenedGoals ← goal.apply (mkConst ``DerivationTree.weakening)
-- weakening creates subgoals: (1) [] ⊢ φ, (2) [] ⊆ Γ
-- Close (2) with List.nil_subset
-- Close (1) by applying the derived theorem
```

This is more robust but adds complexity. Recommendation: Start with direct `apply` for empty-context goals only; add weakening wrapper in a follow-up if needed.

### 5.4 Noncomputable Theorems in TacticM

Many derived theorems are `noncomputable` (they use `deduction_theorem` which is noncomputable due to well-founded recursion). This does NOT affect their use in `TacticM`:

- `TacticM` operates at the meta-level, constructing `Expr` terms
- `mkConst` creates a reference to the theorem constant
- `goal.apply` checks that the type matches; it doesn't evaluate the definition
- The resulting proof term may be `noncomputable`, but this is fine for the elaborator

**Test**: The existing `temp_future_derived` is computable, but there's no barrier to adding noncomputable theorems. Lean's kernel will accept the proof term regardless.

---

## 6. matchAxiom Synchronization (ProofSearch.lean)

### 6.1 Current Coverage

`matchAxiom` (ProofSearch.lean:396-517) covers 16 patterns:
- `ex_falso`, `prop_k`, `peirce`, `modal_k_dist`, `modal_5_collapse`, `modal_4`, `modal_future`, `modal_b`, `modal_t` — 9 base axioms
- `connect_future` — 1 BX temporal
- `prior_UZ`, `prior_SZ` — 2 discrete axioms
- `prop_s` — 1 propositional
- `temp_l` (explicitly returns `none`) — dead code
- `temp_future` (handled in search loop, not in matchAxiom) — not counted

### 6.2 Synchronization Strategy

The `matchAxiom` function serves the computable search (`bounded_search_with_proof`). It returns `Option (Sigma Axiom)` — the actual axiom witness. This is fundamentally different from `tryAxiomMatch` which works in `TacticM`.

**Recommendation**: Synchronize `matchAxiom` with `tryAxiomMatch` by adding all 41 axiom constructors. For each, add a structural pattern match that extracts formula parameters and constructs the `Axiom` witness. This is straightforward but verbose (each axiom needs its own match arm).

**Effort**: ~2 hours for 25 new match arms. The existing pattern (decompose into `lhs/rhs`, match sub-structures) is clear.

**Priority**: Lower than the TacticM-based `tryAxiomMatch` completion. The computable search is already incomplete in other ways (missing modal K/temporal K in `bounded_search_with_proof`). Task 186 (unify search systems) will address this more comprehensively.

---

## 7. Test Infrastructure Analysis

### 7.1 Existing Tests

Tests exist in two locations:
1. **Tactics.lean** (inline, lines 1206-1342): 28 `example` tests covering modal_search, temporal_search, propositional_search
2. **Tests/BimodalTest/Automation/EdgeCaseTest.lean**: 30+ edge case tests including empty context, deep nesting, large contexts, complex formulas

Both use `example` declarations with `by modal_search` / `by temporal_search` / `by propositional_search`.

### 7.2 Test Plan for New Coverage

**Per new axiom** (29 axioms): One `example` test proving the axiom schema instance directly.

```lean
-- Example: connect_future
example (p : Formula) : ⊢ p.imp (p.some_past.all_future) := by modal_search

-- Example: prior_UZ (discrete frame class)
example (p : Formula) : ⊢[FrameClass.Discrete] p.some_future.imp (Formula.untl p p.neg) := by modal_search

-- Example: density (dense frame class)
example (p : Formula) : ⊢[FrameClass.Dense] p.all_future.all_future.imp p.all_future := by modal_search
```

**Per derived theorem** (~25 theorems): One `example` test.

```lean
-- Example: identity
example (p : Formula) : ⊢ p.imp p := by modal_search

-- Example: double_negation
example (p : Formula) : ⊢ p.neg.neg.imp p := by modal_search

-- Example: lce_imp
example (p q : Formula) : ⊢ (p.and q).imp p := by modal_search
```

**Total new tests**: ~54 (29 axiom + 25 derived). Add in Tactics.lean alongside existing tests (lines 1206+), grouped by category.

---

## 8. Recommended Implementation Order

### Phase 1: Complete axiom registration in tryAxiomMatch (2 hours)

1. Add 29 missing axiom constructor names to `axiomCtors` list (Tactics.lean:556-569)
2. Change `h_fc` closing from `evalTactic (← \`(tactic| trivial))` to `evalTactic (← \`(tactic| first | trivial | decide))` (line 579)
3. Add 29 axiom test examples (grouped by layer)
4. Verify with `lake build`

### Phase 2: Add tryDerivedMatch function (3 hours)

1. Create `tryDerivedMatch` function in Tactics.lean, modeled on the existing derived theorem section (lines 513-529)
2. Register ~25 Tier 1 + Tier 2 derived theorems
3. Insert `tryDerivedMatch` call in `searchProof` between Strategy 1 and Strategy 2
4. Add ~25 derived theorem test examples
5. Verify with `lake build`

### Phase 3: Synchronize matchAxiom in ProofSearch.lean (1.5 hours)

1. Add 25 missing axiom pattern match arms to `matchAxiom`
2. Add corresponding patterns to `matches_axiom`
3. Verify with `lake build`

### Phase 4: Integration tests and documentation (1.5 hours)

1. Add comprehensive integration tests in Tests/BimodalTest/Automation/
2. Update module docstring in Tactics.lean
3. Update module docstring in ProofSearch.lean
4. Verify full test suite passes

**Total estimated effort**: 8 hours

---

## 9. Risk Analysis

| Risk | Severity | Mitigation |
|------|----------|------------|
| Performance regression from 41 axiom constructors | Low | `observing?` is fast; profile if needed |
| Noncomputable derived theorems failing in TacticM | Very Low | `mkConst`/`apply` works at meta-level |
| Frame class `h_fc` failing for non-base axioms | Low | `first \| trivial \| decide` handles both |
| Derived operators (diamond, neg, and, or, etc.) blocking unification | Medium | Lean's unfold-on-demand handles definitions, but may need `whnf` hints |
| `prop_s` matching too eagerly (any `φ.imp (ψ.imp φ)`) | Low | Already in list; Lean's unifier is precise |
| Test compilation time increase | Low | 54 new tests add ~30s to build |

---

## 10. Dependencies and Downstream Impact

### This Task Enables

- **Task 186** (Unify search systems): Synchronizes `matchAxiom` with `tryAxiomMatch`
- **Task 187** (Backward-chaining lemma database): `tryDerivedMatch` is the prototype for `@[tm_lemma]` attribute
- **Task 192** (Master tactic dispatch): Comprehensive axiom + theorem coverage is prerequisite for `tm_prove`

### This Task Does NOT Affect

- Metalogic/ proofs (they don't use `modal_search`)
- Semantics/ proofs
- The Derivable wrapper (task 181)
- EF game tactics (task 195)

---

## Appendix A: Axiom Formula Patterns (for matchAxiom implementation)

For implementers adding pattern match arms to `matchAxiom`, here are the derived operator expansions:

- `⊤ = Formula.bot.imp Formula.bot` (¬⊥)
- `¬φ = φ.imp Formula.bot`
- `φ ∧ ψ = (φ.imp (ψ.imp Formula.bot)).imp Formula.bot`
- `φ ∨ ψ = (φ.imp Formula.bot).imp ψ` (= φ.neg.imp ψ)
- `◇φ = (φ.neg.box).neg = ((φ.imp Formula.bot).box.imp Formula.bot)`
- `F(φ) = some_future φ = ¬G(¬φ) = (φ.neg.all_future).neg`
  - In constructor form: `.imp (.all_future (.imp φ .bot)) .bot`
- `P(φ) = some_past φ = ¬H(¬φ) = (φ.neg.all_past).neg`
  - In constructor form: `.imp (.all_past (.imp φ .bot)) .bot`
- `△φ = always φ = φ.all_past.and (φ.and φ.all_future)` (perpetuity)

The `serial_future` axiom constructor specifies `⊤ → F(⊤)` literally as:
```
(Formula.bot.imp Formula.bot).imp (Formula.some_future (Formula.bot.imp Formula.bot))
```
where `Formula.some_future` is a primitive constructor, not a derived operator.

The `connect_future` axiom uses `some_past` which IS a derived operator:
```
connect_future φ : φ.imp (φ.some_past.all_future)
```
In `matchAxiom`, this must match the *expanded* form since Lean's kernel sees the definition-unfolded structure.

---

## Appendix B: Quick Reference — Files to Modify

| File | Changes |
|------|---------|
| `Theories/Bimodal/Automation/Tactics.lean` | Add 29 axioms to `axiomCtors` (line 556), add `tryDerivedMatch` function (~50 lines), insert call in `searchProof` (line 896), add ~54 test examples (line 1206+), fix `h_fc` closing (line 579) |
| `Theories/Bimodal/Automation/ProofSearch.lean` | Add 25 match arms to `matchAxiom` (line 396), update `matches_axiom` (line 302) |
| `Tests/BimodalTest/Automation/EdgeCaseTest.lean` | Add integration tests for new coverage (~20 additional examples) |
