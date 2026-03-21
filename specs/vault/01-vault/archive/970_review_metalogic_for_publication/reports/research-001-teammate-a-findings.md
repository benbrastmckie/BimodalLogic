# Research Report: Task #970 (Teammate A Findings)

**Task**: 970 - Review Metalogic for Publication Readiness
**Started**: 2026-03-15T00:00:00Z
**Completed**: 2026-03-15T00:30:00Z
**Effort**: Medium (systematic survey of metalogic module structure)
**Focus**: Primary approaches — methodology for identifying redundant definitions, bridge theorem evaluation, and mathematically standard theorem forms
**Sources/Inputs**: Codebase analysis (Theories/Bimodal/Metalogic/), specs/archive/945_*/reports/research-006.md, docs/project-info/SORRY_REGISTRY.md

---

## Key Findings

### 1. `bmcs_truth_at` Is Structurally Redundant (High-Impact)

The intermediate `bmcs_truth_at` definition in `Bundle/BFMCSTruth.lean` is **definitionally isomorphic** to the standard `truth_at` semantics when canonical definitions are chosen correctly. This was explicitly recognized in `Bundle/CanonicalConstruction.lean` (line 20): *"The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally identical to `truth_at` when canonical definitions are chosen correctly."* This is confirmed in research-006.md for task 945.

The `bmcs_truth_at` definition effectively duplicates the recursive structure of `truth_at` with:
- `atom p` → `Formula.atom p ∈ fam.mcs t` vs `M.valuation (tau.states t ht) p`
- `box φ` → `∀ fam' ∈ B.families, ...` vs `∀ σ ∈ Omega, ...`
- `all_past/all_future` → pointwise identical structure

The entire BFMCS intermediate layer (`bmcs_valid`, `bmcs_satisfiable_at`, `bmcs_satisfies_context`) exists as scaffolding for this intermediate definition and has **no downstream callers** outside the Bundle module itself. These three definitions are currently unused in the main completeness pipeline.

**Recommendation**: The semantically correct approach is to prove `bmcs_truth_lemma` directly at the `truth_at` level, eliminating `bmcs_truth_at` and the associated `BFMCS` validity definitions. `CanonicalConstruction.lean` already implements this directly via `canonical_truth_lemma` and `shifted_truth_lemma`.

### 2. Duplicate DNE/DNI Theorems Across Files

`double_negation` (DNE) is defined **three separate times** in the active codebase:
1. `Theorems/Propositional.lean`: `def double_negation (φ : Formula) : ⊢ φ.neg.neg.imp φ` (canonical location)
2. `Bundle/ModalSaturation.lean`: `noncomputable def dne_theorem (phi : Formula)` — delegates to Propositional
3. `Bundle/TemporalCoherentConstruction.lean`: `noncomputable def dne_theorem' (phi : Formula)` — another delegate

Similarly `dni_theorem` in `ModalSaturation.lean` re-derives `double_negation_introduction` from first principles when `Propositional.lean` already provides `dni` (double negation introduction).

**Recommendation**: Remove `dne_theorem`, `dne_theorem'`, and `dni_theorem` from their respective files. Use `Bimodal.Theorems.Propositional.double_negation` and `Bimodal.Theorems.Propositional.dni` directly.

### 3. `diamondFormula` Is a Thin Alias with No Added Value

`ModalSaturation.lean` defines:
```lean
def diamondFormula (phi : Formula) : Formula := phi.diamond
```
This is a one-line alias for `Formula.diamond`. The helper `diamondFormula_eq` establishes `diamondFormula phi = Formula.neg (Formula.box (Formula.neg phi))`, which is already the definitional unfolding of `phi.diamond`. Every use of `diamondFormula` could directly use `phi.diamond`.

**Recommendation**: Remove `diamondFormula` and replace all uses with `Formula.diamond`. This affects `ModalSaturation.lean` and `ChainFMCS.lean`.

### 4. `set_mcs_modal_saturation_forward` Is a Trivial Alias

In `Completeness.lean`:
```lean
theorem set_mcs_modal_saturation_forward {S : Set Formula} {φ : Formula}
    (h_mcs : SetMaximalConsistent S)
    (h_box : Formula.box φ ∈ S) : φ ∈ S :=
  set_mcs_box_closure h_mcs h_box
```
This is a one-line wrapper that merely calls `set_mcs_box_closure`. The name `modal_saturation_forward` is a historical artifact from when the completeness proof involved a different approach. The underlying property is simply "modal T axiom closure" — which is what `set_mcs_box_closure` already states precisely.

**Recommendation**: Remove `set_mcs_modal_saturation_forward`. Any callers should use `set_mcs_box_closure` directly (which has a more accurate name).

### 5. `Completeness.lean` Contains Theorems Duplicated in `Core/MCSProperties.lean`

`Bimodal/Metalogic/Completeness.lean` (namespace `Bimodal.Metalogic`) defines:
- `set_mcs_all_future_all_future`
- `set_mcs_all_past_all_past`
- `temp_4_past`

These are **independently re-proven** in `Core/MCSProperties.lean` (namespace `Bimodal.Metalogic.Core`). The `Completeness.lean` header claims these are "Re-exported from Core modules" but they are in fact separately proven (no Lean `export` directive; both files contain full proof bodies). This means:

1. There are **two separate proof bodies** for these theorems in the codebase
2. `Completeness.lean` is imported by `StagedConstruction/StagedExecution.lean` primarily to get `set_mcs_conjunction_intro/elim/iff`, `set_mcs_disjunction_intro/elim/iff`, `set_mcs_box_closure`, `set_mcs_box_box`, and `set_mcs_diamond_box_duality`

These theorems in `Completeness.lean` that are NOT in `MCSProperties.lean` constitute the genuine unique content of the file:
- `set_mcs_disjunction_intro/elim/iff` (3 theorems)
- `set_mcs_conjunction_intro/elim/iff` (3 theorems)
- `set_mcs_box_closure` (fundamental)
- `set_mcs_box_box` (fundamental)
- `set_mcs_neg_box_implies_diamond_neg` / `set_mcs_diamond_neg_implies_neg_box` / `set_mcs_diamond_box_duality` (3 theorems)

**Recommendation**: Move all unique theorems from `Completeness.lean` into `Core/MCSProperties.lean`. Then `Completeness.lean` can be deprecated or become a pure re-export file (or eliminated entirely if no downstream code imports it for its old `Bimodal.Metalogic` namespace).

### 6. `needs_modal_witness` Is Internal Scaffolding, Not a Published Interface

`ModalSaturation.lean` defines `needs_modal_witness` and the companion theorem `is_modally_saturated_iff_no_needs_witness`. The `needs_modal_witness` predicate is only used within the equivalence proof and nowhere else. It is internal scaffolding, not a bridge theorem.

Similarly, `asDiamond` in `ModalSaturation.lean` is unused in the main completeness pipeline (it appears only in `Decidability/Tableau.lean` which has its own `asDiamond?` definition).

### 7. Current Sorry Status (9 active sorries)

```
Bundle/TemporalCoherentConstruction.lean:422  - temporal_coherent_family_exists_Int
Bundle/TemporalCoherentConstruction.lean:516  - fully_saturated_bfmcs_exists_int
Domain/DiscreteTimeline.lean:179,187,200,218,231 - SuccOrder/PredOrder/IsSuccArchimedean instances
Canonical/ConstructiveFragment.lean:579,584 - sorry in forward/backward reachability proofs
```

The two sorries in `TemporalCoherentConstruction.lean` are the critical blockers for the Int-indexed completeness path. The five sorries in `DiscreteTimeline.lean` block the discrete completeness path. The two in `ConstructiveFragment.lean` block the staged timeline construction.

---

## Recommended Approach

### Methodology for Identifying Redundant Definitions

Apply this three-test filter to every definition:

**Test 1: Is there a direct alias?**
A definition is redundant if it merely renames or wraps an existing definition with no additional preconditions or structural complexity. `diamondFormula`, `dne_theorem`, `set_mcs_modal_saturation_forward` all fail this test.

**Test 2: Is it used outside its own module?**
If a definition is only used internally, it may be necessary internal scaffolding, but it should not be exported as part of the published API. `needs_modal_witness` and `bmcs_satisfiable_at` fail this test.

**Test 3: Does it correspond to a standard mathematical concept?**
If the definition is intermediate and the mathematical content can be expressed directly in terms of the official semantics, then it is a bridge artifact. `bmcs_truth_at` fails this test because `truth_at` (the official Kripke semantics) already captures the same concept.

### Criteria for "Redundant" vs "Necessary"

A definition is **redundant** when:
- It is definitionally equal to an existing concept (aliases)
- It exists solely as a proof step, not as a named mathematical concept
- The same result could be stated directly using the official semantics without loss of readability

A definition is **necessary** when:
- It introduces new mathematical structure not expressible as a direct definitional unfolding of existing terms
- It has a name that corresponds to a standard concept in the literature (e.g., `SetMaximalConsistent`, `CanonicalR`, `GContent`)
- It is referenced from multiple independent modules as a stable interface

### What "Mathematically Standard Form" Means Here

The main theorems should:
1. **State hypothesis in terms of the official semantics** — `truth_at`, `SetMaximalConsistent`, `ContextConsistent`, not BFMCS-specific notions
2. **Not expose internal BFMCS infrastructure** — the completeness statement should be `valid φ → Derivable [] φ`, not a statement about `bmcs_truth_at`
3. **Match textbook formulations** — Blackburn et al. state the completeness theorem as: "if φ is valid in all Kripke frames of class C, then φ is derivable from the axioms for C." Our statement should parallel this form over the standard `truth_at` semantics

The main gap is that `bmcs_truth_lemma` (the current published key theorem) is still stated in terms of `bmcs_truth_at` rather than `truth_at`. The `shifted_truth_lemma` in `CanonicalConstruction.lean` is closer to the mathematically standard form.

---

## Evidence/Examples

### Example 1: `bmcs_truth_at` vs `truth_at` equivalence

From `CanonicalConstruction.lean` line 20-22 (explicit codebase acknowledgment):
> "The intermediate `bmcs_truth_at` is structurally redundant -- it is definitionally identical to `truth_at` when the canonical definitions are chosen correctly. Therefore we prove the TruthLemma directly at the `truth_at` level, eliminating the intermediate."

### Example 2: Three separate DNE definitions

```lean
-- Propositional.lean (canonical)
def double_negation (φ : Formula) : ⊢ φ.neg.neg.imp φ

-- ModalSaturation.lean (unnecessary wrapper)
noncomputable def dne_theorem (phi : Formula) : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
  Bimodal.Theorems.Propositional.double_negation phi

-- TemporalCoherentConstruction.lean (unnecessary wrapper)
noncomputable def dne_theorem' (phi : Formula) : [] ⊢ (Formula.neg (Formula.neg phi)).imp phi :=
  Bimodal.Theorems.Propositional.double_negation phi
```

### Example 3: `set_mcs_all_future_all_future` proven twice

Both `Completeness.lean` (lines 377-394) and `Core/MCSProperties.lean` (lines 243-267) contain full proof bodies for this theorem. The proof bodies are identical in structure. The distinction is namespace only.

### Example 4: `needs_modal_witness` internal-only usage

`needs_modal_witness` is defined in `ModalSaturation.lean` and used only within `is_modally_saturated_iff_no_needs_witness` (same file). It does not appear anywhere else in the codebase (excluding Boneyard).

---

## Confidence Level: High

The redundancies identified are based on:
- Direct codebase inspection of proof bodies
- Cross-referencing with explicit documentation in module headers
- Confirmed by the existing research-006.md for task 945 which explicitly identified the `bmcs_truth_at` redundancy
- The SORRY_REGISTRY.md (last updated 2026-01-15) is outdated — the current active sorry count is 9, not 46, because the old monolithic `Completeness.lean` has been archived and the new pipeline is largely sorry-free
