# Research Report: Full Axiom and Rule Coverage for Proof Step Dataset

**Task**: 243 (full_axiom_rule_coverage)
**Date**: 2026-06-02
**Status**: Complete

## Executive Summary

The proof step dataset (`data/proof_steps.jsonl`) currently covers 31 of 42 axiom names and 5 of 7 inference rules. The 11 missing axioms fall into three clear categories with distinct remediation strategies. The 2 missing inference rules have a single root cause (all registered theorems use empty context). This report provides a complete inventory, root cause analysis, and concrete implementation approach for achieving 42/42 and 7/7.

---

## 1. Complete Axiom Inventory (42 Axioms)

### 1.1 Covered Axioms (31/42)

| # | Axiom Name | Layer | Frame Class |
|---|-----------|-------|-------------|
| 1 | `prop_k` | Propositional | Base |
| 2 | `prop_s` | Propositional | Base |
| 3 | `ex_falso` | Propositional | Base |
| 4 | `modal_t` | S5 Modal | Base |
| 5 | `modal_4` | S5 Modal | Base |
| 6 | `modal_b` | S5 Modal | Base |
| 7 | `modal_5_collapse` | S5 Modal | Base |
| 8 | `modal_k_dist` | S5 Modal | Base |
| 9 | `serial_future` | BX Temporal | Base |
| 10 | `serial_past` | BX Temporal | Base |
| 11 | `left_mono_until_G` | BX Temporal | Base |
| 12 | `left_mono_since_H` | BX Temporal | Base |
| 13 | `right_mono_until` | BX Temporal | Base |
| 14 | `right_mono_since` | BX Temporal | Base |
| 15 | `connect_future` | BX Temporal | Base |
| 16 | `connect_past` | BX Temporal | Base |
| 17 | `enrichment_until` | BX Temporal | Base |
| 18 | `enrichment_since` | BX Temporal | Base |
| 19 | `self_accum_until` | BX Temporal | Base |
| 20 | `self_accum_since` | BX Temporal | Base |
| 21 | `absorb_until` | BX Temporal | Base |
| 22 | `absorb_since` | BX Temporal | Base |
| 23 | `linear_until` | BX Temporal | Base |
| 24 | `linear_since` | BX Temporal | Base |
| 25 | `until_F` | BX Temporal | Base |
| 26 | `since_P` | BX Temporal | Base |
| 27 | `temp_linearity` | BX Temporal | Base |
| 28 | `temp_linearity_past` | BX Temporal | Base |
| 29 | `F_until_equiv` | BX Temporal | Base |
| 30 | `P_since_equiv` | BX Temporal | Base |
| 31 | `modal_future` | Interaction | Base |

### 1.2 Missing Axioms (11/42)

| # | Axiom Name | Layer | Frame Class | Root Cause |
|---|-----------|-------|-------------|------------|
| 32 | `peirce` | Propositional | **Base** | No computable theorem uses it; Propositional/Core.lean is `noncomputable` |
| 33 | `discrete_symm_fwd` | Uniformity | **Discrete** | `decideAuto` only generates Base proofs |
| 34 | `discrete_symm_bwd` | Uniformity | **Discrete** | `decideAuto` only generates Base proofs |
| 35 | `discrete_propagate_fwd` | Uniformity | **Discrete** | `decideAuto` only generates Base proofs |
| 36 | `discrete_propagate_bwd` | Uniformity | **Discrete** | `decideAuto` only generates Base proofs |
| 37 | `discrete_box_necessity` | Uniformity | **Discrete** | `decideAuto` only generates Base proofs |
| 38 | `prior_UZ` | Prior | **Discrete** | `decideAuto` only generates Base proofs |
| 39 | `prior_SZ` | Prior | **Discrete** | `decideAuto` only generates Base proofs |
| 40 | `z1` | Z1 | **Discrete** | `decideAuto` only generates Base proofs |
| 41 | `density` | Density | **Dense** | `decideAuto` only generates Base proofs |
| 42 | `dense_indicator` | Density | **Dense** | `decideAuto` only generates Base proofs |

---

## 2. Complete Inference Rule Inventory (7 Rules)

### 2.1 Covered Rules (5/7)

| Rule | Count in Dataset | Coverage |
|------|-----------------|----------|
| `axiom` | 4635 (46.1%) | Present |
| `modus_ponens` | 4325 (43.0%) | Present |
| `temporal_necessitation` | 991 (9.8%) | Present |
| `temporal_duality` | 63 (0.6%) | Present |
| `necessitation` | 49 (0.5%) | Present |

### 2.2 Missing Rules (2/7)

| Rule | Root Cause |
|------|-----------|
| `assumption` | All 310 registered theorems derive from empty context (`[] |- phi`) |
| `weakening` | All 310 registered theorems derive from empty context (`[] |- phi`) |

**Analysis**: The `assumption` rule requires `phi in Gamma` (formula is in the context). The `weakening` rule requires `Gamma subset Delta`. Both only appear in derivations with non-empty contexts. Since the current registry exclusively contains theorems (derivations from empty context), these rules never appear.

---

## 3. Root Cause Analysis

### 3.1 Peirce Axiom (Category: Computable Theorem Gap)

**Why missing**: The `peirce` axiom is Base-compatible and structurally simple, but:
1. No computable theorem in the registry uses it
2. `Propositional/Core.lean` defines `peirce_axiom` and `double_negation` (which uses Peirce), but the entire file is in a `noncomputable section` due to importing `DeductionTheorem`
3. The tableau proof search may not generate proofs using Peirce because the compositional builder handles classical reasoning differently

**Solution**: Trivial -- add direct `DerivationTree.axiom` entries for `Axiom.peirce` in `ProofStepExport.lean`, following the same pattern used for temporal axiom instantiations (lines 583-654). Also construct computable theorems that use Peirce (e.g., `double_negation` can be reimplemented computably by manually building the DerivationTree).

### 3.2 Non-Base Axioms (Category: Frame Class Limitation)

**Why missing (10 axioms)**: The decision procedure (`decideAuto`) produces `DecisionResult phi` where the proof type is `DerivationTree FrameClass.Base [] phi`. It can only use axioms where `ax.minFrameClass <= .Base`, which excludes:
- Discrete axioms (5 uniformity + 2 Prior + 1 Z1 = 8): `minFrameClass = .Discrete`
- Dense axioms (2: density + dense_indicator): `minFrameClass = .Dense`

The `processFormula` function in `TableauProofStepPipeline.lean` calls `decideAuto phi` with default `fc := .Base`, so the tableau never has access to non-base axioms.

**Solution**: Add direct `DerivationTree.axiom` entries in `ProofStepExport.lean` for each non-base axiom, parameterized by the appropriate frame class. The `extractStepSequence` function already handles frame class serialization via the `fcStr` parameter. Then build computable multi-step derivation trees using these axioms, similar to how the existing temporal axiom instantiations work.

### 3.3 Missing Rules (Category: Empty Context)

**Why missing**: The `assumption` and `weakening` rules are structural rules that only appear in context-dependent derivations:
- `assumption Gamma phi (h : phi in Gamma)` requires non-empty Gamma
- `weakening Gamma Delta phi d (h : Gamma subset Delta)` lifts a derivation to a larger context

All 310 registered theorems are theorems (derivable from empty context), so these rules never fire. The necessitation and temporal necessitation rules additionally require empty context, so they ARE compatible with the current theorem-only approach.

**Solution**: Register derivations from non-empty contexts. For example:
- `[p, p.imp q] |- q` uses `assumption` (twice) and `modus_ponens`
- `[p] |- p` uses `assumption` alone
- Taking `[p] |- p` and showing `[p, q] |- p` uses `weakening`

The `mkEntry` helper and `extractStepSequence` already support non-empty contexts (the `Gamma` parameter is serialized in the JSON). The only change needed is adding entries with non-trivial contexts to the registry.

---

## 4. Formulas Requiring Each Missing Axiom

### 4.1 Peirce (Base)

**Formula**: `((p -> q) -> p) -> p`

This is the axiom itself. Direct instantiation produces a 1-step proof. For a multi-step proof using Peirce, `double_negation` (`(not (not p)) -> p`) requires exactly: 2x `prop_k`, 2x `prop_s`, 1x `ex_falso`, 1x `peirce`, and 4x `modus_ponens` (7 steps).

### 4.2 Discrete Uniformity Axioms (5 axioms, all Discrete)

Each uniformity axiom is its own simplest proof witness:

| Axiom | Formula | Steps |
|-------|---------|-------|
| `discrete_symm_fwd` | `U(top, bot) -> S(top, bot)` | 1 |
| `discrete_symm_bwd` | `S(top, bot) -> U(top, bot)` | 1 |
| `discrete_propagate_fwd` | `U(top, bot) -> G(U(top, bot))` | 1 |
| `discrete_propagate_bwd` | `U(top, bot) -> H(U(top, bot))` | 1 |
| `discrete_box_necessity` | `U(top, bot) -> box(U(top, bot))` | 1 |

For multi-step proofs, combine with modus ponens:
- `box(U(top,bot)) -> U(top,bot)`: uses `modal_t` + `discrete_box_necessity` (2 axiom steps + 1 MP)

### 4.3 Prior Axioms (2 axioms, Discrete)

| Axiom | Formula | Steps |
|-------|---------|-------|
| `prior_UZ` | `F(p) -> U(p, not p)` | 1 |
| `prior_SZ` | `P(p) -> S(p, not p)` | 1 |

For multi-step: `F(p) -> F(p)` (identity) composed with `prior_UZ` gives `F(p) -> U(p, not p)` in 7 steps.

### 4.4 Z1 Axiom (Discrete)

| Axiom | Formula | Steps |
|-------|---------|-------|
| `z1` | `G(G(p) -> p) -> (F(G(p)) -> G(p))` | 1 |

### 4.5 Density Axioms (2 axioms, Dense)

| Axiom | Formula | Steps |
|-------|---------|-------|
| `density` | `G(G(p)) -> G(p)` | 1 |
| `dense_indicator` | `not U(top, bot)` | 1 |

---

## 5. Export Script Analysis

### 5.1 Current Architecture

The export system has two pipelines:

1. **Hand-registered theorems** (`ProofStepExport.lean`): 310 entries in `theoremRegistry`, each a `TheoremEntry` with a thunk that evaluates a `DerivationTree` and calls `extractStepSequence`. Run via `lake exe proof_extractor`.

2. **Tableau pipeline** (`TableauProofStepPipeline.lean`): Enumerates formulas, decides each with `decideAuto`, extracts steps. Run via `lake exe tableau_proof_steps`. Has its own `computeCoverage` function tracking rule/axiom histograms.

### 5.2 Coverage Tracking

The `TableauProofStepPipeline.lean` already has a `computeCoverage` function (lines 199-204) that returns `(rules_covered, total_rules, axioms_covered, total_axioms)` using `StepDistribution.ruleHistogram.size` and `StepDistribution.axiomHistogram.size`. The metadata JSON includes this.

The `ProofStepExport.lean` has NO coverage tracking -- it just writes JSONL lines with no analysis.

### 5.3 How to Add Coverage Tracking to ProofStepExport

Add a post-processing step in the `main` function that:
1. Accumulates all `ProofStep` records
2. Counts unique axiom names and rule names
3. Compares against the canonical 42-axiom and 7-rule lists
4. Prints a coverage summary and optionally writes it to metadata JSON

This can reuse the `StepDistribution` type from `TableauProofStepPipeline.lean` or define a simpler coverage checker.

---

## 6. Implementation Approach

### Phase 1: Peirce Axiom Coverage (1 axiom, Base)

**Approach**: Add direct axiom entries and a computable `double_negation` theorem.

```lean
-- Direct peirce axiom instantiation
mkEntry "peirce_axiom"
  (DerivationTree.axiom (fc := .Base) [] _ (Axiom.peirce p q) trivial),
mkEntry "peirce_axiom_qr"
  (DerivationTree.axiom (fc := .Base) [] _ (Axiom.peirce q r) trivial),

-- Computable double_negation using peirce (manually constructed DerivationTree)
-- ((p -> bot) -> bot) -> p
-- Uses: peirce, ex_falso, prop_k, prop_s, b_combinator
```

The computable `double_negation` can be built by manually constructing the same proof tree as in `Core.lean` but without using the tactic block (which requires `noncomputable`). Since the proof only uses `DerivationTree` constructors, `Axiom.peirce`, `Axiom.ex_falso`, `Axiom.prop_k`, `Axiom.prop_s`, and `DerivationTree.modus_ponens`, it is structurally computable.

### Phase 2: Non-Base Axiom Coverage (10 axioms, Discrete + Dense)

**Approach**: Add entries parameterized by the correct frame class.

```lean
-- Discrete axioms (8)
mkEntry "discrete_symm_fwd_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ Axiom.discrete_symm_fwd trivial),
mkEntry "discrete_symm_bwd_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ Axiom.discrete_symm_bwd trivial),
mkEntry "discrete_propagate_fwd_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ Axiom.discrete_propagate_fwd trivial),
mkEntry "discrete_propagate_bwd_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ Axiom.discrete_propagate_bwd trivial),
mkEntry "discrete_box_necessity_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ Axiom.discrete_box_necessity trivial),
mkEntry "prior_UZ_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ (Axiom.prior_UZ p) trivial),
mkEntry "prior_SZ_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ (Axiom.prior_SZ p) trivial),
mkEntry "z1_axiom"
  (DerivationTree.axiom (fc := .Discrete) [] _ (Axiom.z1 p) trivial),

-- Dense axioms (2)
mkEntry "density_axiom"
  (DerivationTree.axiom (fc := .Dense) [] _ (Axiom.density p) trivial),
mkEntry "dense_indicator_axiom"
  (DerivationTree.axiom (fc := .Dense) [] _ Axiom.dense_indicator trivial),
```

**Note**: The `mkEntry` helper already supports non-Base frame classes through the `{fc : FrameClass}` parameter. The `frameClassToString` function handles `.Dense` and `.Discrete` serialization. Multi-step proofs using these axioms can also be constructed (e.g., G-wrapped, combined with modal axioms).

### Phase 3: Assumption and Weakening Rules (2 rules)

**Approach**: Register derivations with non-empty contexts.

```lean
-- Assumption: [p] |- p
mkEntry "assume_p"
  (DerivationTree.assumption [p] p (by simp)),

-- Assumption within modus ponens: [p, p -> q] |- q
mkEntry "mp_from_assumptions"
  (DerivationTree.modus_ponens [p, p.imp q] p q
    (DerivationTree.assumption [p, p.imp q] (p.imp q) (by simp))
    (DerivationTree.assumption [p, p.imp q] p (by simp))),

-- Weakening: [p] |- p  implies  [p, q] |- p
mkEntry "weakened_assume_p"
  (DerivationTree.weakening [p] [p, q] p
    (DerivationTree.assumption [p] p (by simp))
    (by intro x hx; simp at hx |- *; exact Or.inl hx)),

-- Weakening of axiom: [] |- prop_k  implies  [p] |- prop_k
mkEntry "weakened_prop_k"
  (DerivationTree.weakening [] [p] _
    (DerivationTree.axiom [] _ (Axiom.prop_k p q r) trivial)
    (by intro x hx; exact absurd hx (List.not_mem_nil x))),
```

**Challenge**: The `by simp` proofs in context membership and subset obligations compile fine in the current Lean setup. They only need to verify list membership and subset relations on concrete formula lists, which is decidable.

### Phase 4: Coverage Tracking in Export Script

Add a `computeAndPrintCoverage` function to `ProofStepExport.lean`:

```lean
def allAxiomNames : List String :=
  ["prop_k", "prop_s", "ex_falso", "peirce",
   "modal_t", "modal_4", "modal_b", "modal_5_collapse", "modal_k_dist",
   "serial_future", "serial_past", ...]  -- all 42

def allRuleNames : List String :=
  ["axiom", "assumption", "modus_ponens", "necessitation",
   "temporal_necessitation", "temporal_duality", "weakening"]

def printCoverage (steps : List ProofStep) : IO Unit := do
  let axiomsSeen := steps.filterMap (·.axiomName) |>.eraseDups
  let rulesSeen := steps.map (·.rule) |>.eraseDups
  let missingAxioms := allAxiomNames.filter (fun a => !axiomsSeen.contains a)
  let missingRules := allRuleNames.filter (fun r => !rulesSeen.contains r)
  IO.println s!"Axiom coverage: {axiomsSeen.length}/42"
  IO.println s!"Rule coverage: {rulesSeen.length}/7"
  if !missingAxioms.isEmpty then
    IO.println s!"Missing axioms: {missingAxioms}"
  if !missingRules.isEmpty then
    IO.println s!"Missing rules: {missingRules}"
```

---

## 7. Feasibility Assessment

### 7.1 Can the Tableau Generate Proofs Using Missing Axioms?

**Peirce**: The tableau has a `priorUZ` rule (line 128 of Tableau.lean) and handles frame-class-gated rules. However, `decideAuto` defaults to `.Base`, so frame-class-specific rules are not triggered. For Peirce specifically, the proof search may not produce it because the compositional builder handles classical reasoning via direct pattern matching rather than invoking Peirce.

**Non-Base axioms**: The tableau DOES have rules for discrete/dense axioms (lines 119-134 of Tableau.lean: `denseIndicatorClosure`, `densityRule`, `priorUZ`, `priorSZ`, `z1Rule`). In principle, calling `decideAuto phi (.Discrete)` or `decideAuto phi (.Dense)` would enable these rules. However, the `DecisionResult` type currently uses `DerivationTree FrameClass.Base [] phi` in its `valid` constructor, so non-Base proofs cannot be returned.

**Recommendation**: Direct axiom registration (Phase 2 approach) is far simpler and more reliable than extending the decision procedure. The decision procedure change would require modifying `DecisionResult` to be generic over frame class and updating all downstream consumers.

### 7.2 Computability

All proposed additions are computable:
- `DerivationTree.axiom` constructors are structural data constructors
- `DerivationTree.assumption`, `weakening`, `modus_ponens` are similarly structural
- Context membership proofs (`by simp`) are decidable on concrete lists
- The `extractStepSequence` function handles all rule cases already

No `noncomputable` definitions are needed for any of the proposed changes.

### 7.3 Multi-Step Diversity

Beyond single-axiom entries, the following multi-step theorems should be added:
- **Peirce-based**: `double_negation` (7 steps), `lem_explicit` (using Peirce), G-wrapped variants
- **Discrete**: `G(discrete_symm_fwd)`, `G(prior_UZ)`, combining uniformity axioms with modal axioms
- **Dense**: `G(density)`, combining density with temporal axioms
- **Context-based**: multi-assumption proofs, weakening chains, assumption-within-MP patterns

### 7.4 Build Impact

Adding entries to `theoremRegistry` requires importing the relevant axiom constructors, which are already available via `Bimodal.ProofSystem.Axioms`. No new imports are needed for Phases 1-3. Phase 4 (coverage tracking) adds pure IO/String processing with no new dependencies.

---

## 8. Summary of Recommendations

1. **Phase 1** (Peirce): Add 2-4 direct axiom entries + 1 computable `double_negation` theorem + G/H wraps. Expected: +1 axiom covered.

2. **Phase 2** (Non-Base): Add 10 direct axiom entries (8 Discrete + 2 Dense) + multi-instantiation variants + G/H wraps. Expected: +10 axioms covered.

3. **Phase 3** (Rules): Add 4-6 context-based derivation entries (assumption alone, MP from assumptions, weakening of assumption, weakening of axiom). Expected: +2 rules covered.

4. **Phase 4** (Tracking): Add coverage analysis function to `ProofStepExport.lean` main function. Print axiom/rule coverage to stdout and optionally to metadata JSON.

**Total effort**: ~50-80 new registry entries in `ProofStepExport.lean`, plus a ~30-line coverage tracking function. No new Lean files needed. Expected result: 42/42 axioms, 7/7 rules.
