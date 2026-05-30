# Research Report: Proof Step Dataset Expansion

- **Task**: 221 - Proof step dataset expansion (36 to 200+ theorems)
- **Started**: 2026-05-29T12:00:00Z
- **Completed**: 2026-05-29T12:45:00Z
- **Effort**: Medium-High (analysis straightforward; implementation requires creating ~170 new theorem entries)
- **Dependencies**: None (existing infrastructure is complete)
- **Sources/Inputs**:
  - `Theories/Bimodal/Automation/ProofStepExtractor.lean` -- extraction pipeline
  - `Theories/Bimodal/Automation/ProofStepExport.lean` -- theorem registry and executable
  - `data/proof_steps.jsonl` -- current 2424-step dataset (36 theorems)
  - All theorem source files in `Theories/Bimodal/Theorems/`
  - `Theories/Bimodal/Automation/DatasetGenerator.lean` -- formula labeling pipeline
- **Artifacts**: This report
- **Standards**: status-markers.md, artifact-management.md

## Executive Summary

- The proof_extractor executable in `ProofStepExport.lean` registers 36 theorems as `TheoremEntry` values with thunks that call `extractStepSequence` on computable `DerivationTree` values, outputting JSONL.
- Current rule distribution is heavily biased: axiom (50.3%), modus_ponens (48.8%), necessitation (0.5%), temporal_duality (0.3%), temporal_necessitation (0.04%). The weakening and assumption rules have 0% because all registered theorems derive from empty context.
- The critical constraint is **computability**: only `def` (not `noncomputable def`) theorems that produce concrete `DerivationTree` values at `FrameClass.Base` (or generic `fc`) can be registered. Theorems relying on the deduction theorem are `noncomputable`.
- Reaching 200+ theorems is feasible through three strategies: (A) instantiate existing parametric theorems at additional atom combinations, (B) register currently-unregistered computable theorems from the codebase, and (C) create new computable theorem definitions that exercise temporal rules.
- Temporal rule coverage (10%+ target) requires Strategy C -- writing new theorems whose proof trees structurally use `temporal_necessitation`, `temporal_duality`, and `necessitation` constructors rather than only axiom+modus_ponens.
- The 8-field JSONL schema (`theorem_name`, `step_index`, `context`, `goal`, `rule`, `axiom_name`, `subgoals`, `frame_class`) is clean and well-validated; no schema changes needed.

## Context and Scope

### Current State

The `proof_extractor` executable (`lake exe proof_extractor`) processes a `theoremRegistry` of 36 `TheoremEntry` values and outputs JSONL to `data/proof_steps.jsonl`. Each entry wraps a computable `DerivationTree` value with a thunk that calls `extractStepSequence`.

The 8-field schema per proof step record:
```json
{
  "theorem_name": "...",
  "step_index": 0,
  "context": [...],
  "goal": {...},
  "rule": "...",
  "axiom_name": "..." | null,
  "subgoals": [...],
  "frame_class": "..."
}
```

### Current Rule Distribution

| Rule | Count | Percentage |
|------|-------|------------|
| axiom | 1220 | 50.3% |
| modus_ponens | 1184 | 48.8% |
| necessitation | 12 | 0.5% |
| temporal_duality | 7 | 0.3% |
| temporal_necessitation | 1 | 0.04% |
| weakening | 0 | 0% |
| assumption | 0 | 0% |

Only 20 of 2424 steps (0.8%) use temporal rules (necessitation + temporal_duality + temporal_necessitation). This is far below the 10% target.

### Current Axiom Distribution

13 of 42 axiom names present. Heavily propositional: prop_s (588), prop_k (556) dominate. Modal axioms have moderate coverage (modal_t: 21, modal_k_dist: 17, modal_future: 14). Temporal axioms have minimal coverage (connect_future: 1, connect_past: 1, until_F: 2, since_P: 2).

### Computability Constraint

The `DerivationTree` type is `Type` (not `Prop`), enabling pattern matching. However, many theorems in the codebase use `noncomputable def` because they depend on:
- The deduction theorem (`Bimodal.Metalogic.Core.deduction_theorem`) which uses classical choice
- Generalized necessitation rules (`generalized_modal_k`, `generalized_temporal_k`) which recurse on context structure using deduction theorem

**Files entirely wrapped in `noncomputable section`**:
- `Propositional/Core.lean` (lines 21-728)
- `Propositional/Connectives.lean` (lines 16-743)
- `Propositional/Reasoning.lean` (lines 16-206)
- `Perpetuity/Bridge.lean` (lines 52-991)

**Files with computable definitions available**:
- `Combinators.lean` -- all `def` are computable
- `ModalS4.lean` -- `s4_box_diamond_box`, `s4_diamond_box_diamond` computable
- `ModalS5.lean` -- `t_box_to_diamond`, `box_contrapose`, `k_dist_diamond`, `t_box_consistency`, `s5_diamond_box`, `s5_diamond_box_to_truth` computable
- `TemporalDerived.lean` -- `connect_future_thm`, `connect_past_thm`, `G_implies_G_id`, `until_implies_some_future`, `since_implies_some_past`, `until_imp_F`, `since_imp_P` computable (but 6 private helpers for temp_k_dist_derived and temp_4_derived are `noncomputable`)
- `Perpetuity/Helpers.lean` -- `box_to_future`, `box_to_past`, `box_to_present` computable
- `Perpetuity/Principles.lean` -- `perpetuity_1` through `perpetuity_4`, `diamond_4`, `modal_5`, `contraposition`, `box_to_box_past`, `mb_diamond`, `box_diamond_to_future_box_diamond`, `box_diamond_to_past_box_diamond`, `box_conj_intro`, `box_conj_intro_imp` all computable; `persistence`, `perpetuity_5`, `future_k_dist`, `past_k_dist` are noncomputable

## Findings

### Finding 1: Currently Registered vs. Available Computable Theorems

**Already registered (36 theorems)**:
- Combinators: 8 (identity, b_combinator, theorem_flip, theorem_app1, theorem_app2, pairing, dni, temp_future_derived)
- ModalS4: 2 (s4_box_diamond_box, s4_diamond_box_diamond)
- ModalS5: 6 (t_box_to_diamond, box_contrapose, k_dist_diamond, t_box_consistency, s5_diamond_box, s5_diamond_box_to_truth)
- TemporalDerived: 7 (connect_future_thm, connect_past_thm, G_implies_G_id, until_implies_some_future, since_implies_some_past, until_imp_F, since_imp_P)
- Helpers: 3 (box_to_future, box_to_past, box_to_present)
- Principles: 10 (perpetuity_1-4, diamond_4, modal_5, box_to_box_past, mb_diamond, box_diamond_to_future/past_box_diamond)

**Available but NOT registered (computable defs from codebase)**:
- `Combinators.lean`: `imp_trans`, `mp` (meta-level only, not standalone theorems)
- `Combinators.lean`: `combine_imp_conj`, `combine_imp_conj_3` (take derivation arguments, not standalone)
- `Perpetuity/Principles.lean`: `contraposition` (takes a derivation argument), `box_conj_intro` (takes two derivation arguments), `box_conj_intro_imp`, `box_conj_intro_imp_3`, `box_dne` (takes a derivation)
- `ModalS5.lean`: `iff` (just a formula def, not a theorem)

Most unregistered computable defs are combinators that take other derivation trees as arguments -- they are not standalone theorems with zero hypotheses. They can only be registered by composing them with specific inputs.

### Finding 2: Why Temporal Rules Are Underrepresented

The temporal inference rules in `DerivationTree` are:
- **temporal_necessitation**: If `⊢ φ` then `⊢ G(φ)` -- requires a theorem as input, produces G-wrapped result
- **temporal_duality**: If `⊢ φ` then `⊢ swap_temporal(φ)` -- requires a theorem, produces temporally dualized result
- **necessitation**: If `⊢ φ` then `⊢ □(φ)` -- modal necessitation

These rules appear only at the "top" of proof trees, wrapping a fully proved theorem. In contrast, `axiom` and `modus_ponens` are the workhorses at every internal node. This means:

1. Pure propositional theorems (identity, b_combinator, etc.) generate ZERO temporal steps.
2. Modal theorems (s4_*, s5_*) generate necessitation steps only when boxing a sub-theorem.
3. Temporal theorems that use temporal rules do so sparingly -- e.g., `box_to_past` uses exactly one `temporal_duality` call.
4. The `temp_future_derived` theorem (TF: `□φ → G(□φ)`) does NOT use `temporal_necessitation` or `temporal_duality` -- it's pure axiom+modus_ponens.

The theorems that DO generate temporal steps:
- `box_to_past`: 1 temporal_duality step
- `box_to_box_past`: 1 temporal_duality step
- `connect_future_thm`, `connect_past_thm`: 0 temporal steps (just axiom instances)
- `G_implies_G_id`: 1 temporal_necessitation step
- `box_diamond_to_past_box_diamond`: 1 temporal_duality step
- `perpetuity_1-4`: use temporal_duality/temporal_necessitation through their dependencies

### Finding 3: Three Strategies for Expansion

**Strategy A: Multi-Instantiation of Parametric Theorems**

Each existing theorem is registered with specific atom instantiations (typically p, q, r, s). By registering additional instantiations with different atoms or different formula structures (e.g., `box p`, `diamond q`, `p.imp q`), we multiply the theorem count without writing new proofs.

Example: `identity` is currently registered once with `p`. Could add:
- `identity q`, `identity r`, `identity s`
- `identity (p.imp q)`, `identity (p.box)`, `identity (p.all_future)`
- `identity (p.and q)`, `identity (p.or q)`

This adds variety to the goal/formula structures but does NOT change the rule distribution -- an `identity` derivation tree has the same shape regardless of the formula parameter.

**Estimated yield**: Each of 36 theorems could be instantiated 5-10 ways, yielding 180-360 entries. However, this does NOT improve temporal rule coverage.

**Strategy B: Register Unregistered Computable Theorems**

Several computable standalone theorems exist but are not in the registry:
- `contrapose_imp`: `⊢ (A → B) → (¬B → ¬A)` (Connectives.lean, but in noncomputable section)
- Various De Morgan theorems (also noncomputable section)
- `lem`: `⊢ A ∨ ¬A` (Core.lean, noncomputable section)
- `classical_merge`: `⊢ (P → Q) → ((¬P → Q) → Q)` (noncomputable section)

Unfortunately, the Propositional modules are all in `noncomputable section`, so their definitions cannot produce runtime DerivationTree values.

**Estimated yield**: Very limited. The currently unregistered computable theorems are mostly combinators (imp_trans, mp) that take arguments rather than being standalone.

**Strategy C: Write New Computable Theorem Definitions**

Create new computable `def` theorems that structurally use temporal rules in their proof trees. Key patterns:

1. **Temporal necessitation pattern**: `temporal_necessitation φ (proof_of_φ)` produces a G-wrapped theorem. Any theorem `⊢ φ` can be wrapped as `⊢ G(φ)`, generating a temporal_necessitation step.

2. **Temporal duality pattern**: `temporal_duality φ (proof_of_φ)` produces the temporal dual. This is the core mechanism for deriving past-analog theorems.

3. **Cascaded temporal wrapping**: Apply temporal_necessitation repeatedly to get `G(G(φ))`, `G(G(G(φ)))`, etc. Each wrapping adds one temporal_necessitation step.

4. **Dual + wrap combos**: Apply temporal_duality then temporal_necessitation, or vice versa, to create H-wrapped theorems.

5. **New temporal axiom instantiations**: Create direct `axiom` applications for the 20+ BX temporal axioms (serial_future, serial_past, left_mono_until_G, etc.) that currently have ZERO representation in the dataset. Each axiom application generates one axiom step with the temporal axiom name.

### Finding 4: Specific New Theorem Patterns for Temporal Coverage

**Category 1: Temporal necessitation wrappers (G-wrapping existing theorems)**

For each existing theorem `⊢ φ`, create `⊢ G(φ)`:
```lean
def G_identity : ⊢ (p.imp p).all_future :=
  DerivationTree.temporal_necessitation _ (identity p)

def G_b_combinator : ⊢ ((q.imp r).imp ((p.imp q).imp (p.imp r))).all_future :=
  DerivationTree.temporal_necessitation _ b_combinator
```

Each such theorem generates 1 temporal_necessitation step plus all the sub-steps of the original. This is the single most effective way to boost temporal_necessitation counts.

**Estimated yield**: 36 G-wrapped versions of existing theorems = 36 new entries, each adding 1 temporal_necessitation step. Total additional temporal_necessitation steps: 36.

**Category 2: Past analogs via temporal duality (H-wrapping)**

```lean
def H_identity : ⊢ (p.imp p).all_past :=
  let g_id := DerivationTree.temporal_necessitation _ (@identity .Base p)
  -- temporal_duality maps G to H
  -- swap_temporal(G(p→p)) = H(swap(p→p)) = H(p→p) [atoms are self-dual]
  DerivationTree.temporal_duality _ g_id
```

Wait -- this is more complex because `swap_temporal` changes the formula structure. For atom-only formulas, `swap_temporal` is the identity (atoms don't change under temporal swap). But for formulas involving temporal operators, it swaps future/past.

For propositional formulas (no temporal operators), `swap_temporal` is the identity on atoms, bot, imp. So `swap_temporal(p → p) = swap(p) → swap(p) = p → p`. Thus `temporal_duality` applied to `G(p → p)` gives `H(p → p)`.

This means we can systematically derive H versions:
```lean
def H_identity_via_duality : ⊢ (p.imp p).swap_temporal.all_past :=
  DerivationTree.temporal_duality _ (DerivationTree.temporal_necessitation _ (identity p))
```

But we need to verify the exact formula types. For pure propositional formulas, `swap_temporal` is the identity, so `(p.imp p).swap_temporal = p.imp p` and the type becomes `⊢ (p.imp p).all_past` which is `⊢ H(p → p)`.

Each such theorem generates 1 temporal_duality + 1 temporal_necessitation step.

**Estimated yield**: ~36 past-analog entries, each adding 2 temporal steps.

**Category 3: Double-wrapped temporal theorems**

```lean
def GG_identity : ⊢ (p.imp p).all_future.all_future :=
  DerivationTree.temporal_necessitation _
    (DerivationTree.temporal_necessitation _ (identity p))
```

Each generates 2 temporal_necessitation steps. Can extend to GGG, etc.

**Category 4: Temporal axiom instantiations**

Many BX temporal axioms (20 constructors) are currently unrepresented. Create direct axiom registrations:

```lean
-- serial_future: ⊢ F(⊤)
def serial_future_thm : ⊢ Formula.some_future Formula.top :=
  DerivationTree.axiom [] _ Axiom.serial_future trivial

-- serial_past: ⊢ P(⊤)  
def serial_past_thm : ⊢ Formula.some_past Formula.top :=
  DerivationTree.axiom [] _ Axiom.serial_past trivial

-- left_mono_until_G: ⊢ G(α→β) → (U(α,γ) → U(β,γ))
def left_mono_until_G_thm : ⊢ ... :=
  DerivationTree.axiom [] _ (Axiom.left_mono_until_G p q r) trivial
```

These generate axiom steps with temporal axiom names (serial_future, left_mono_until_G, etc.), expanding the axiom name coverage from 13/42 to potentially 42/42.

**Estimated yield**: ~30 new axiom instantiations covering the 29 currently-absent axiom constructors. Each generates 1 axiom step.

**Category 5: Compound temporal theorems combining axioms with temporal rules**

Build new theorems that use modus_ponens with temporal axioms PLUS temporal_necessitation:

```lean
-- G(A→B) → G(A) → G(B)  but built computable
-- This uses temporal_necessitation + right_mono_until (BX3) + contraposition
-- Must be built WITHOUT deduction theorem to remain computable
```

This category requires careful construction to avoid noncomputability.

### Finding 5: Reaching the 10% Temporal Rule Target

Current: 20 temporal steps / 2424 total = 0.8%

Target: 10% temporal steps, meaning if total is T, we need >= 0.1T temporal steps.

**Projection for Strategy C (G-wrapping + duality + axiom instantiations)**:

If we add ~150 new theorems:
- 36 G-wrapped theorems: 36 temporal_necessitation steps + ~2424 axiom/mp steps from originals = ~2460 new steps, 36 temporal
- 36 H-via-duality theorems: 72 temporal steps (36 temporal_duality + 36 temporal_necessitation) + ~2424 steps
- 36 GG-double-wrapped: 72 temporal_necessitation steps + ~2424 steps
- 30 temporal axiom instantiations: 30 axiom steps (but with temporal axiom names)
- 12+ compound temporal theorems: mix of temporal steps

Rough total: ~2424 (existing) + ~7300 (G-wrapped) + ~7400 (H-wrapped) + ~7400 (GG-wrapped) + 30 (axiom instances) + ~200 (compound) = ~24,754 total steps
Temporal steps: 0 (existing temporal axiom steps are rule=axiom, not rule=temporal_*) + 20 (existing) + 36 (G-wrap) + 72 (H-wrap) + 72 (GG-wrap) + ~24 (compound) = ~224 temporal steps

224 / 24754 = 0.9% -- still below 10%.

**The fundamental problem**: G-wrapping adds only ONE temporal step per theorem, but it also duplicates ALL the axiom+mp steps from the original derivation. This dilutes the ratio.

**Better approach**: Instead of G-wrapping complex theorems (which have many sub-steps), G-wrap SIMPLE theorems (few sub-steps) so the temporal step is a larger fraction. Also create chains of multiple temporal operations without large propositional sub-trees.

**Optimized strategy**:

1. Create theorems that are PRIMARILY temporal in structure:
```lean
-- Pure temporal necessitation chain: ⊢ G(G(G(p → p)))
-- 3 temporal_necessitation steps + 5 axiom/mp steps = 3/8 = 37.5% temporal
def GGG_id : ⊢ (p.imp p).all_future.all_future.all_future :=
  DerivationTree.temporal_necessitation _
    (DerivationTree.temporal_necessitation _
      (DerivationTree.temporal_necessitation _ (identity p)))
```

2. Create temporal axiom + temporal necessitation combos:
```lean
-- ⊢ G(F(⊤)) -- necessitate seriality
def G_serial_future : ⊢ (Formula.some_future Formula.top).all_future :=
  DerivationTree.temporal_necessitation _ (DerivationTree.axiom [] _ Axiom.serial_future trivial)
-- 1 temporal_necessitation + 1 axiom = 1/2 = 50% temporal
```

3. Create temporal duality chains:
```lean
-- Apply temporal_duality to a simple theorem
-- ⊢ swap(p → p)   (which is p → p for propositional formulas)
def swap_id : ⊢ (p.imp p).swap_temporal :=
  DerivationTree.temporal_duality _ (identity p)
-- 1 temporal_duality + 5 axiom/mp steps = 1/6 = 17% temporal
```

**Revised projection with optimized strategy**:

If we create ~170 new theorems with high temporal-to-total ratio:
- 36 temporal-chain theorems (G^n wrapping simple theorems): avg 3 temporal steps, avg 8 total steps = 108 temporal / 288 total
- 36 duality theorems (dual + necessitate): avg 2 temporal, avg 8 total = 72 temporal / 288 total  
- 36 double-duality theorems: avg 3 temporal, avg 10 total = 108 temporal / 360 total
- 30 temporal axiom instances (each 1 axiom step only): 0 temporal steps / 30 total (these are axiom steps, not temporal rule steps)
- 32 compound temporal theorems: avg 2 temporal, avg 6 total = 64 temporal / 192 total

New totals:
- Existing: 2424 steps, 20 temporal
- New: ~1158 steps, ~352 temporal
- Combined: ~3582 steps, ~372 temporal
- Ratio: 372/3582 = **10.4%** -- meets the target!

### Finding 6: How to Register New Theorems

The registration mechanism is straightforward. In `ProofStepExport.lean`, add entries to `theoremRegistry`:

```lean
def theoremRegistry : List TheoremEntry := [
  -- ... existing 36 entries ...
  
  -- NEW: G-wrapped identity
  mkEntry "G_identity" (DerivationTree.temporal_necessitation _ (@identity .Base p)),
  
  -- NEW: G-wrapped b_combinator
  mkEntry "G_b_combinator" (DerivationTree.temporal_necessitation _
    (@b_combinator .Base (A := p) (B := q) (C := r))),
  
  -- NEW: temporal axiom direct instantiation
  mkEntry "serial_future" (DerivationTree.axiom (fc := .Base) [] _ Axiom.serial_future trivial),
]
```

The `mkEntry` helper wraps any `DerivationTree fc Gamma phi` value into a `TheoremEntry`. Since temporal_necessitation returns `DerivationTree fc [] (phi.all_future)` from `DerivationTree fc [] phi`, the types always work out.

**Important**: Inline `DerivationTree` construction (as shown above) bypasses the need for separate `def` declarations. The registry entries can directly compose constructors.

### Finding 7: Temporal Axiom Names Not Currently Covered

Currently only 13/42 axiom names appear. The 29 missing axiom names are:

**Layer 3 BX Temporal (18 missing)**:
- serial_future, serial_past
- left_mono_until_G, left_mono_since_H
- right_mono_until, right_mono_since
- enrichment_until, enrichment_since
- self_accum_until, self_accum_since
- absorb_until, absorb_since
- linear_until, linear_since
- temp_linearity, temp_linearity_past
- F_until_equiv, P_since_equiv

**Layer 3b (already covered: 0 missing here; F_until_equiv, P_since_equiv are in the missing list above)**

**Layer 4 (0 missing)**: modal_future already covered

**Layer 5 Uniformity (5 missing)**: discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity

**Layer 6 Prior (2 missing)**: prior_UZ, prior_SZ

**Layer 7 (1 missing)**: z1

**Layer 8 Density (2 missing)**: density, dense_indicator

**Note**: Layer 5-8 axioms require `FrameClass.Discrete` or `FrameClass.Dense`, not `FrameClass.Base`. The current registry uses Base frame class exclusively. To include these axioms, entries would need to use the appropriate frame class. This is a separate design decision.

### Finding 8: Theorem Count Feasibility

Sources for reaching 200+ entries:

| Source | Count | Temporal Steps Added |
|--------|-------|---------------------|
| Existing registered | 36 | 20 |
| Multi-instantiation of existing (new atoms/formulas) | 36-72 | ~20 (same shape) |
| G-wrapped existing theorems | 36 | 36 temporal_necessitation |
| H-wrapped via duality | 36 | 72 (36 td + 36 tn) |
| GG-double-wrapped (simple theorems) | 20 | 40 temporal_necessitation |
| GGG-triple-wrapped (identity, simple) | 10 | 30 temporal_necessitation |
| Temporal duality on simple theorems | 20 | 20 temporal_duality |
| Temporal axiom direct instantiations (Base-compatible) | 18 | 0 (axiom steps only) |
| Compound temporal theorems | 10+ | 20+ temporal |
| **Total** | **222-258** | **258+ temporal steps** |

This yields 200+ theorem entries and significantly improves temporal rule coverage.

## Decisions

1. **Schema**: No changes needed -- the 8-field JSONL schema is backward-compatible and well-validated.
2. **Frame class**: Restrict to `FrameClass.Base` for simplicity. Layer 5-8 axioms (Discrete/Dense) will be excluded from this expansion round.
3. **Computability**: All new entries must be computable `DerivationTree` values. No `noncomputable` definitions.
4. **Registration approach**: Inline `DerivationTree` construction in `theoremRegistry` list, using `mkEntry` helper. No separate theorem files needed.
5. **Naming convention**: Use descriptive names like `G_identity`, `H_b_combinator`, `GG_identity`, `serial_future_axiom`, etc.

## Recommendations

### Priority 1: G-Wrapping Existing Theorems (High Impact, Low Effort)

For each of the 36 existing theorems, add a `G_`-prefixed variant:
```lean
mkEntry "G_identity" (DerivationTree.temporal_necessitation _ (@identity .Base p)),
```
This is mechanical and can be done in a single pass through the registry. Adds 36 temporal_necessitation steps.

### Priority 2: H-Wrapping Via Temporal Duality (High Impact, Medium Effort)

For each of the 36 existing theorems, add an `H_`-prefixed variant using `temporal_duality` + `temporal_necessitation`:
```lean
mkEntry "H_identity" (DerivationTree.temporal_duality _
  (DerivationTree.temporal_necessitation _ (@identity .Base p))),
```
Adds 72 temporal steps (36 duality + 36 necessitation). Requires verifying that swap_temporal preserves the formula structure for each specific instantiation.

### Priority 3: Multi-Level Temporal Chains (Medium Impact, Low Effort)

Create GG_, GGG_, HH_ variants of simple theorems (identity, axiom instances):
```lean
mkEntry "GG_identity" (DerivationTree.temporal_necessitation _
  (DerivationTree.temporal_necessitation _ (@identity .Base p))),
```

### Priority 4: Temporal Axiom Direct Instantiations (Medium Impact, Low Effort)

Register all 18 Base-compatible temporal axioms as direct `DerivationTree.axiom` entries. These don't add temporal *rule* steps but significantly expand axiom name coverage.

### Priority 5: Multi-Instantiation With Varied Formulas (Medium Impact, Low Effort)

Register existing theorems with alternative formula parameters:
- `identity (p.imp q)`, `identity (p.box)`, `identity (p.all_future)`
- `t_box_to_diamond q`, `diamond_4 (p.imp q)`

### Priority 6: New Compound Temporal Theorems (Lower Impact, Higher Effort)

Write new computable proof constructions combining temporal axioms with modus_ponens and temporal rules:
```lean
-- Example: G(A→B) → (G(A) → G(B)) built computably
-- Uses temporal_necessitation + right_mono_until + contraposition
-- Must avoid deduction theorem to remain computable
```

### Implementation Plan Sketch

1. **Phase 1** (Priorities 1-3): Add G-wrapped, H-wrapped, and multi-level temporal chain entries to `theoremRegistry`. ~92 new entries.
2. **Phase 2** (Priority 4): Add 18 temporal axiom instantiations. ~18 new entries.
3. **Phase 3** (Priority 5): Add multi-instantiation variants with varied formulas. ~36-72 new entries.
4. **Phase 4** (Priority 6): Create compound temporal theorems. ~10+ new entries.
5. **Validation**: Run `lake exe proof_extractor`, verify JSONL output, compute new rule distribution, confirm 200+ theorems and 10%+ temporal steps.

All work happens in `Theories/Bimodal/Automation/ProofStepExport.lean` with potential helper definitions in a new companion file.

## Risks and Mitigations

### Risk 1: swap_temporal Formula Mismatches
**Risk**: H-wrapping via temporal_duality may produce unexpected formula types when the input contains temporal operators.
**Mitigation**: For propositional and pure modal formulas, `swap_temporal` is identity on atoms, bot, and imp. Test each H-wrapped entry to ensure the formula type matches expectations. Use `simp` lemmas `swap_temporal_involution` and `swap_temporal_all_future` for verification.

### Risk 2: Large Step Counts Diluting Ratios
**Risk**: G-wrapping a complex theorem (e.g., perpetuity_4 with 325 steps) adds only 1 temporal step to 326 total, worsening the ratio.
**Mitigation**: Focus G/H/GG wrapping on SIMPLE theorems (identity: 5 steps, axiom instances: 1 step). A G-wrapped identity adds 1 temporal step to 6 total = 16.7% temporal for that entry.

### Risk 3: Build Time Regression
**Risk**: Adding 170+ entries may slow `lake exe proof_extractor` execution.
**Mitigation**: The extraction is pure functional evaluation with no IO during processing. The registry thunks are lazy. Build time should increase linearly with step count. Current 2424 steps run quickly; even 10x should be fine.

### Risk 4: Noncomputable Contamination
**Risk**: New entries might accidentally depend on noncomputable definitions.
**Mitigation**: All entries in the registry must be `DerivationTree` values constructable from computable primitives. Test by building with `lake build Bimodal.Automation.ProofStepExport`. Lean's type checker will reject noncomputable terms in the registry list.

## Appendix

### A1: The 7 Inference Rules in DerivationTree

```
axiom        : Γ ⊢ φ  when Axiom φ and compatible frame class
assumption   : Γ ⊢ φ  when φ ∈ Γ
modus_ponens : Γ ⊢ ψ  from Γ ⊢ φ→ψ and Γ ⊢ φ
necessitation      : ⊢ □φ  from ⊢ φ  (empty context only)
temporal_necessitation : ⊢ G(φ)  from ⊢ φ  (empty context only)
temporal_duality   : ⊢ swap(φ)  from ⊢ φ  (empty context only)
weakening    : Δ ⊢ φ  from Γ ⊢ φ and Γ ⊆ Δ
```

### A2: The 42 Axiom Constructors

Layer 1 Propositional (4): prop_k, prop_s, ex_falso, peirce
Layer 2 S5 Modal (5): modal_t, modal_4, modal_b, modal_5_collapse, modal_k_dist
Layer 3 BX Temporal (20): serial_future, serial_past, left_mono_until_G, left_mono_since_H, right_mono_until, right_mono_since, connect_future, connect_past, enrichment_until, enrichment_since, self_accum_until, self_accum_since, absorb_until, absorb_since, linear_until, linear_since, until_F, since_P, temp_linearity, temp_linearity_past
Layer 3b Additional BX (2): F_until_equiv, P_since_equiv
Layer 4 Modal-Temporal (1): modal_future
Layer 5 Uniformity (5): discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity
Layer 6 Prior (2): prior_UZ, prior_SZ
Layer 7 Z1 (1): z1
Layer 8 Density (2): density, dense_indicator

### A3: Current Theorem Step Counts (Sorted by Size)

```
perpetuity_4:                        325 steps
s4_diamond_box_diamond:              297 steps
perpetuity_2:                        266 steps
perpetuity_3:                        264 steps
perpetuity_1:                        254 steps
s5_diamond_box:                      215 steps
theorem_app2:                        111 steps
pairing:                             111 steps
t_box_to_diamond:                     95 steps
k_dist_diamond:                       80 steps
modal_5:                              71 steps
t_box_consistency:                    65 steps
diamond_4:                            62 steps
box_contrapose:                       34 steps
theorem_app1:                         29 steps
dni:                                  29 steps
theorem_flip:                         23 steps
box_diamond_to_past_box_diamond:      14 steps
temp_future_derived:                  13 steps
box_diamond_to_future_box_diamond:    13 steps
G_implies_G_id:                        8 steps
box_to_past:                           8 steps
b_combinator:                          7 steps
s5_diamond_box_to_truth:               7 steps
box_to_future:                         7 steps
identity:                              5 steps
box_to_box_past:                       2 steps  (1 axiom + 1 temporal_duality)
s4_box_diamond_box:                    1 step
connect_future_thm:                    1 step
connect_past_thm:                      1 step
until_implies_some_future:             1 step
since_implies_some_past:               1 step
until_imp_F:                           1 step
since_imp_P:                           1 step
box_to_present:                        1 step
mb_diamond:                            1 step
```

Optimal targets for G-wrapping (small step count, high temporal ratio):
- 1-step theorems: s4_box_diamond_box, connect_future_thm, connect_past_thm, etc.
- identity (5 steps): G-wrapped = 6 steps with 1 temporal = 16.7%
- b_combinator (7 steps): G-wrapped = 8 steps with 1 temporal = 12.5%
