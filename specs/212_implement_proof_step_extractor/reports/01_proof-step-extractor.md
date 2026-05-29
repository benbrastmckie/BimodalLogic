# Research Report: Proof Step Extractor for BimodalHarness Training Data

**Task**: 212 - Implement proof step extractor for BimodalHarness training data
**Date**: 2026-05-29
**Session**: sess_1780083735_5vngv

---

## 1. Executive Summary

This research investigates all components needed to implement an `extractStepSequence` function that walks `DerivationTree` values and emits ordered `ProofStep` records for the BimodalHarness AlphaZero-style training pipeline. The implementation is feasible with the existing codebase infrastructure. Key findings:

- **DerivationTree** is a `Type` (not `Prop`), enabling pattern matching and data extraction
- **42 axiom constructors** + **7 inference rules** = **49-action space** confirmed
- **~108 public definitions** in `Theories/Bimodal/Theorems/` produce `DerivationTree` values (some are `noncomputable`)
- Existing `walkDerivationTree` in `DataExport.lean` provides the exact recursive traversal template
- Existing JSON serialization infrastructure (Formula.toJson, escapeJsonString, etc.) can be reused
- The `noncomputable` annotation on many theorems is the primary technical risk -- these definitions cannot be evaluated at runtime via `#eval` or in executables

---

## 2. DerivationTree Type Definition

**File**: `Theories/Bimodal/ProofSystem/Derivation.lean`

```lean
inductive DerivationTree (fc : FrameClass) : Context -> Formula -> Type where
  | axiom (G : Context) (f : Formula) (h : Axiom f) (h_fc : h.minFrameClass <= fc)
  | assumption (G : Context) (f : Formula) (h : f in G)
  | modus_ponens (G : Context) (f y : Formula)
      (d1 : DerivationTree fc G (f.imp y))
      (d2 : DerivationTree fc G f)
  | necessitation (f : Formula) (d : DerivationTree fc [] f)
  | temporal_necessitation (f : Formula) (d : DerivationTree fc [] f)
  | temporal_duality (f : Formula) (d : DerivationTree fc [] f)
  | weakening (G D : Context) (f : Formula) (d : DerivationTree fc G f) (h : G <= D)
```

### Key Properties
- **Type not Prop**: Enables pattern matching, computable functions, and data extraction
- **Parameterized by FrameClass**: `fc` parameter gates which axioms are admissible
- **7 constructors** = 7 inference rules in the action space
- Each node carries its context (`G : Context`), conclusion formula, and sub-derivations
- `deriving Repr` is present, providing automatic string representation

### Data Extractable Per Node

| Constructor | Extractable Fields |
|---|---|
| `axiom` | context, formula, axiom constructor name, frame class gate |
| `assumption` | context, formula, membership witness |
| `modus_ponens` | context, major premise formula, conclusion formula, 2 sub-trees |
| `necessitation` | formula, 1 sub-tree (empty context enforced) |
| `temporal_necessitation` | formula, 1 sub-tree (empty context enforced) |
| `temporal_duality` | formula, 1 sub-tree (empty context enforced) |
| `weakening` | source context, target context, formula, 1 sub-tree |

---

## 3. The 49-Action Space

### 7 Inference Rules (DerivationTree Constructors)

1. `axiom` -- Axiom schema instantiation
2. `assumption` -- Formula from context
3. `modus_ponens` -- If G |- A -> B and G |- A then G |- B
4. `necessitation` -- If |- A then |- box A
5. `temporal_necessitation` -- If |- A then |- G(A)
6. `temporal_duality` -- If |- A then |- swap_temporal(A)
7. `weakening` -- If G |- A and G <= D then D |- A

### 42 Axiom Constructors

**Propositional (4):**
1. `prop_k` -- (A -> (B -> C)) -> ((A -> B) -> (A -> C))
2. `prop_s` -- A -> (B -> A)
3. `ex_falso` -- bot -> A
4. `peirce` -- ((A -> B) -> A) -> A

**S5 Modal (5):**
5. `modal_t` -- box A -> A
6. `modal_4` -- box A -> box(box A)
7. `modal_b` -- A -> box(diamond A)
8. `modal_5_collapse` -- diamond(box A) -> box A
9. `modal_k_dist` -- box(A -> B) -> (box A -> box B)

**BX Temporal (22):**
10. `serial_future` -- top -> F(top)
11. `serial_past` -- top -> P(top)
12. `left_mono_until_G` -- G(A -> C) -> (U(y, A) -> U(y, C))
13. `left_mono_since_H` -- H(A -> C) -> (S(y, A) -> S(y, C))
14. `right_mono_until` -- G(A -> B) -> (U(A, C) -> U(B, C))
15. `right_mono_since` -- H(A -> B) -> (S(A, C) -> S(B, C))
16. `connect_future` -- A -> G(P(A))
17. `connect_past` -- A -> H(F(A))
18. `enrichment_until` -- p and U(y, A) -> U(y and S(p, A), A)
19. `enrichment_since` -- p and S(y, A) -> S(y and U(p, A), A)
20. `self_accum_until` -- U(y, A) -> U(y, A and U(y, A))
21. `self_accum_since` -- S(y, A) -> S(y, A and S(y, A))
22. `absorb_until` -- U(A and U(y, A), A) -> U(y, A)
23. `absorb_since` -- S(A and S(y, A), A) -> S(y, A)
24. `linear_until` -- U(y,A) and U(t,C) -> ...
25. `linear_since` -- S(y,A) and S(t,C) -> ...
26. `until_F` -- U(y, A) -> F(y)
27. `since_P` -- S(y, A) -> P(y)
28. `temp_linearity` -- F(A) and F(B) -> F(A and B) or ...
29. `temp_linearity_past` -- P(A) and P(B) -> P(A and B) or ...
30. `F_until_equiv` -- F(A) -> U(A, top)
31. `P_since_equiv` -- P(A) -> S(A, top)

**Modal-Temporal Interaction (1):**
32. `modal_future` -- box A -> box(G(A))

**Uniformity (5):**
33. `discrete_symm_fwd` -- U(top,bot) -> S(top,bot)
34. `discrete_symm_bwd` -- S(top,bot) -> U(top,bot)
35. `discrete_propagate_fwd` -- U(top,bot) -> G(U(top,bot))
36. `discrete_propagate_bwd` -- U(top,bot) -> H(U(top,bot))
37. `discrete_box_necessity` -- U(top,bot) -> box(U(top,bot))

**Prior (2):**
38. `prior_UZ` -- F(A) -> U(A, not A)
39. `prior_SZ` -- P(A) -> S(A, not A)

**Z1 (1):**
40. `z1` -- G(G A -> A) -> (F(G A) -> G A)

**Density (2):**
41. `density` -- G(G A) -> G A
42. `dense_indicator` -- not U(top, bot)

---

## 4. Existing Traversal Pattern: walkDerivationTree

**File**: `Theories/Bimodal/Automation/DataExport.lean`

The existing `walkDerivationTree` function provides the exact pattern for recursive traversal:

```lean
def walkDerivationTree {fc : FrameClass} {G : Context} {f : Formula}
    : DerivationTree fc G f -> RuleProfile
  | .axiom _ _ _ _ => { RuleProfile.empty with axiomCount := 1 }
  | .assumption _ _ _ => { RuleProfile.empty with assumptionCount := 1 }
  | .modus_ponens _ _ _ d1 d2 =>
    let r := (walkDerivationTree d1).merge (walkDerivationTree d2)
    { r with mpCount := r.mpCount + 1 }
  | .necessitation _ d => ...
  | .temporal_necessitation _ d => ...
  | .temporal_duality _ d => ...
  | .weakening _ _ _ d _ => ...
```

This demonstrates that recursive pattern matching on all 7 constructors works and compiles. The `extractStepSequence` function should follow the same structure but emit `ProofStep` records instead of counting rules.

---

## 5. Theorem Corpus Analysis

### Theorem Locations

All theorems producing `DerivationTree` values are in `Theories/Bimodal/Theorems/`:

| File | Public Definitions | Notes |
|---|---|---|
| `Combinators.lean` | 14 | imp_trans, mp, identity, b_combinator, theorem_flip, theorem_app1, theorem_app2, pairing, dni, combine_imp_conj, combine_imp_conj_3, temp_future_derived |
| `Perpetuity/Helpers.lean` | 6 | box_to_future, box_to_past, box_to_present, axiom_in_context, apply_axiom_to, apply_axiom_in_context |
| `Perpetuity/Principles.lean` | ~20 | perpetuity_1-5, contraposition, diamond_4, modal_5, box_to_box_past, box_conj_intro, persistence, future_k_dist, past_k_dist, etc. |
| `Perpetuity/Bridge.lean` | ~35 | dne, modal_duality_neg, box_mono, diamond_mono, future_mono, past_mono, always_to_past/present/future, always_mono, bridge1, bridge2, perpetuity_6, etc. |
| `Propositional/Core.lean` | ~20 | lem, double_negation, ecq, raa, efq, ldi, rdi, rcp, lce, rce, lce_imp, rce_imp, etc. |
| `Propositional/Connectives.lean` | ~15 | classical_merge, iff_intro, contrapose_imp, contraposition, demorgan_conj_neg_forward/backward, demorgan_disj_neg_forward/backward, etc. |
| `Propositional/Reasoning.lean` | 5 | ni, ne, bi_imp, de, or_elim_neg_neg |
| `ModalS5.lean` | ~12 | t_box_to_diamond, box_disj_intro, box_contrapose, k_dist_diamond, box_iff_intro, box_conj_iff, diamond_disj_iff, s5_diamond_box, s5_diamond_box_to_truth, t_box_consistency, iff |
| `ModalS4.lean` | 4 | s4_diamond_box_conj, s4_box_diamond_box, s4_diamond_box_diamond, s5_diamond_conj_diamond |
| `TemporalDerived.lean` | ~15 | temp_k_dist_derived, temp_4_derived, G_distribution, H_distribution, G/H_transitivity, connect_future/past_thm, G_implies_G_id, until/since_implies_some_future/past, contrapositive, formula_or_comm |
| `GeneralizedNecessitation.lean` | 6 | reverse_deduction, past_necessitation, past_k_dist, generalized_modal_k, generalized_temporal_k, generalized_past_k |

**Estimated total**: ~108 public definitions (some are type aliases like `iff`, not derivation trees)

### Computability Challenge

**Critical finding**: Many theorem definitions are marked `noncomputable`:
- All definitions using `deduction_theorem` (from Metalogic.Core) are noncomputable
- This includes: `classical_merge`, `box_disj_intro`, `box_conj_iff`, `diamond_disj_iff`, `G_distribution`, `H_distribution`, `generalized_modal_k`, `generalized_temporal_k`, `generalized_past_k`, `persistence`, `perpetuity_5`, and many more
- Combinators.lean definitions are computable (no noncomputable marker)
- Direct axiom applications are computable

**Impact**: Noncomputable definitions cannot be evaluated at runtime via `#eval` or in executables. The `lake exe proof_extractor` approach needs one of these workarounds:
1. **Metaprogramming approach**: Use Lean's metaprogramming to inspect the compiled definitions and extract the DerivationTree structure from the elaborated terms at compile time
2. **Explicit registration**: Have each theorem register itself into a global list at compile time (using `initialize` blocks)
3. **Computable subset**: Only extract from computable theorems (~40-50 definitions), which still yields ~200-800 steps
4. **Macro-based extraction**: Write a macro/elaborator that inspects the term structure of each definition and emits JSON at compile time

**Recommended approach**: Option 3 (computable subset) for initial implementation, with Option 1 (metaprogramming) as a stretch goal. The computable theorems are exactly the ones in Combinators.lean, Helpers.lean, most of Bridge.lean, and direct axiom applications. This should yield the lower end of the estimated 500-1600 step range.

---

## 6. Existing JSON Serialization Infrastructure

**File**: `Theories/Bimodal/Automation/DataExport.lean`

Reusable components:
- `escapeJsonString` -- String escaping for JSON values
- `listToJsonArray` -- Array construction
- `Formula.toJson` -- Recursive JSON serialization of formula AST
- `Formula.prettyPrint` -- Human-readable formula notation
- `RuleProfile` / `RuleProfile.toJson` -- Rule count serialization (template for new types)

**File**: `Theories/Bimodal/Automation/DatasetExport.lean`

Reusable components:
- `writeRecordJSONL` -- JSONL record writing pattern
- `writeDatasetJSONL` -- File-level JSONL output
- CLI argument parsing patterns
- `main` function pattern for `lake exe`

---

## 7. ProofStep Record Schema

Based on the task description and BimodalHarness integration docs, the `ProofStepRecord` should contain:

```json
{
  "theorem_name": "imp_trans",
  "step_index": 0,
  "context": [{"tag": "imp", ...}],
  "goal": {"tag": "imp", ...},
  "rule": "modus_ponens",
  "axiom_name": null,
  "subgoals": [
    {"tag": "imp", ...},
    {"tag": "imp", ...}
  ],
  "frame_class": "Base"
}
```

### Field Descriptions

| Field | Type | Description |
|---|---|---|
| `theorem_name` | string | Name of the source theorem definition |
| `step_index` | nat | Position in the theorem's step sequence (0-indexed) |
| `context` | array of formula JSON | The context G at this proof step |
| `goal` | formula JSON | The conclusion formula at this step |
| `rule` | string | One of 7 inference rule names |
| `axiom_name` | string or null | For `axiom` rule: one of 42 axiom constructor names; null otherwise |
| `subgoals` | array of formula JSON | Formulas of child nodes (premises) |
| `frame_class` | string | "Base", "Dense", or "Discrete" |

### Action Space Encoding

The `rule` field maps to one of 7 strings: `"axiom"`, `"assumption"`, `"modus_ponens"`, `"necessitation"`, `"temporal_necessitation"`, `"temporal_duality"`, `"weakening"`.

When `rule = "axiom"`, the `axiom_name` field provides the specific axiom constructor name (one of 42 strings).

Together, these form the 49-action space: 42 axiom-specific actions + 6 non-axiom rules + 1 generic axiom rule = 49 (or equivalently, 42 + 7 if axiom actions are pre-specialized).

---

## 8. Axiom Name Serialization

An `Axiom.toName` function must be implemented to convert axiom constructors to string names. The existing `deriving Repr` on `Axiom` provides a starting point, but a cleaner mapping is needed:

```lean
def Axiom.toName {f : Formula} : Axiom f -> String
  | .prop_k _ _ _ => "prop_k"
  | .prop_s _ _ => "prop_s"
  | .ex_falso _ => "ex_falso"
  | .peirce _ _ => "peirce"
  | .modal_t _ => "modal_t"
  | .modal_4 _ => "modal_4"
  | .modal_b _ => "modal_b"
  | .modal_5_collapse _ => "modal_5_collapse"
  | .modal_k_dist _ _ => "modal_k_dist"
  -- ... (42 cases total)
```

---

## 9. Implementation Architecture

### New Files

1. **`Theories/Bimodal/Automation/ProofStepExtractor.lean`** -- Core extraction logic
   - `ProofStep` structure
   - `ProofStep.toJson` serialization
   - `Axiom.toName` string mapping
   - `extractStepSequence` recursive walker
   - `Context.toJson` serialization helper

2. **`Theories/Bimodal/Automation/ProofStepExport.lean`** -- Executable entry point
   - Imports all theorem files
   - Registers computable theorems into a list
   - `main` function for `lake exe proof_extractor`
   - CLI argument parsing

### Lakefile Addition

```lean
lean_exe proof_extractor where
  root := `Bimodal.Automation.ProofStepExport
  srcDir := "Theories"
  supportInterpreter := true
```

### Umbrella Import Update

Add to `Theories/Bimodal/Automation.lean`:
```lean
import Bimodal.Automation.ProofStepExtractor
-- ProofStepExport is a lean_exe target, not imported through umbrella
```

---

## 10. Estimated Step Yield

### Computable Theorems (~40-50 definitions)

Most definitions in Combinators.lean (14), Helpers.lean (6), and direct axiom applications throughout the codebase are computable. These tend to be shorter proofs.

**Estimated steps**: Each computable theorem averages 3-8 nodes in its DerivationTree.
- 50 computable theorems x 5 avg steps = **~250 steps** (lower bound)

### All Theorems Including Noncomputable (~108 definitions)

If a metaprogramming approach can extract from noncomputable definitions:
- Complex theorems like `perpetuity_5` or `diamond_disj_iff` may have 20-50+ nodes
- Simple theorems like `connect_future_thm` have 1-2 nodes
- **Estimated steps**: **~500-1,600 steps** (matches task description estimate)

### Recommendation

Start with computable theorems only. The step yield will be on the lower end (~250-500) but provides a working pipeline. Noncomputable extraction can be added as a follow-up enhancement.

---

## 11. Technical Risks and Mitigations

### Risk 1: Noncomputable Definitions

**Problem**: ~60% of theorem definitions are noncomputable, meaning they cannot be evaluated by the Lean interpreter at runtime.

**Mitigation**: Two-phase approach:
- Phase 1: Extract from computable theorems only (guaranteed to work)
- Phase 2: Use `Lean.Elab` metaprogramming to inspect noncomputable terms at compile time

### Risk 2: Axiom Type Parameter Erasure

**Problem**: The `Axiom` type uses dependent typing -- `Axiom f` where `f : Formula` is the axiom's formula. Pattern matching requires the formula parameter to be available.

**Mitigation**: The `extractStepSequence` function receives the full `DerivationTree fc G f` with all parameters explicit, so pattern matching works. The `Axiom.toName` function can use a simple 42-case match.

### Risk 3: Large Formula JSON Size

**Problem**: Complex formulas can produce very large JSON ASTs, making JSONL files unwieldy.

**Mitigation**: Include both `formula` (full AST) and `formula_string` (pretty-printed) fields. The pretty-print form is compact. Consider an optional `--compact` flag that omits the full AST.

### Risk 4: Theorem Registration

**Problem**: There is no built-in mechanism in Lean to enumerate all definitions of a given type.

**Mitigation**: Explicit registration array. Create a list of `(String, Sigma (fun f => DerivationTree FrameClass.Base [] f))` entries, one per computable theorem. This is boilerplate-heavy but straightforward.

---

## 12. Implementation Plan Recommendation

### Phase 1: Core Extraction (3-4 days)
- Define `ProofStep` and `ProofStep.toJson`
- Implement `Axiom.toName` (42-case match)
- Implement `extractStepSequence` following `walkDerivationTree` pattern
- Unit tests with 3-5 simple theorems

### Phase 2: Theorem Registration (2-3 days)
- Create registry of computable theorems with names
- Implement iteration over registry
- JSONL output function

### Phase 3: Executable and Integration (1-2 days)
- `lakefile.lean` addition for `proof_extractor` executable
- CLI argument parsing (output path, frame class filter)
- `main` function
- End-to-end test run

### Phase 4 (Optional): Noncomputable Extraction
- Metaprogramming approach to inspect elaborated terms
- Adds ~60% more theorems to the corpus

---

## 13. File Dependencies

The new code depends on:
- `Bimodal.ProofSystem.Derivation` (DerivationTree type)
- `Bimodal.ProofSystem.Axioms` (Axiom type, FrameClass)
- `Bimodal.Syntax.Formula` (Formula type)
- `Bimodal.Syntax.Context` (Context type)
- `Bimodal.Automation.DataExport` (JSON helpers, Formula.toJson)
- `Bimodal.Theorems.*` (all theorem modules, for registration)

No circular dependency issues: the extraction code only reads from theorem modules, never the reverse.
