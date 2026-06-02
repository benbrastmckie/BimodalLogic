# Implementation Plan: Context Proof Steps

- **Task**: 244 - Context-based proof steps for assumption/weakening training
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 242 (proof step pipeline must be functional)
- **Research Inputs**: specs/244_context_proof_steps/reports/01_context-proof-steps.md
- **Artifacts**: plans/01_context-proof-steps.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

All 310 registered theorems derive from empty context (`[] |- phi`), so the `assumption` and `weakening` inference rules never appear in the 10,063-step proof step dataset. This plan creates a new `ContextualProofs.lean` file with computable contextual derivations (avoiding the noncomputability taint from `DeductionTheorem.lean`), registers them in `ProofStepExport.lean`, and validates that assumption and weakening steps appear in the exported data. The approach follows the research report's recommended strategy: import only `Derivation.lean` and `Combinators.lean`, hand-construct `DerivationTree` values using the `assumption`, `weakening`, `modus_ponens`, and `axiom` constructors.

### Research Integration

Key findings from the research report (01_context-proof-steps.md):
- **Root cause**: All theorems are stated as `[] |- phi` (empty context). The `assumption` and `weakening` constructors are only exercised with non-empty contexts.
- **Computability barrier**: Existing contextual theorems (`ecq`, `ldi`, `rdi` in `Propositional/Core.lean`) are inside `noncomputable section` blocks due to importing `DeductionTheorem.lean`. A new file that avoids this import chain will produce computable derivation trees.
- **Infrastructure ready**: `mkEntry` accepts any context `Gamma`, and `extractStepSequence` handles all 7 constructors including `assumption` and `weakening`. No extraction changes needed.
- **Scaling**: 28 core contextual theorems plus weakening variants, multi-instantiation, and pure weakening yields ~160 registry entries. The 5%/3% targets are aspirational given the existing 10,063 steps dominate; realistic expectation is ~1.5% assumption and ~2% weakening.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the "tableau-training" topic area. The ROADMAP.md does not have a specific item for dataset coverage, but achieving 7/7 inference rule coverage directly supports the data pipeline quality needed for BimodalHarness training.

## Goals & Non-Goals

**Goals**:
- Create `Theories/Bimodal/Theorems/ContextualProofs.lean` with computable contextual derivations
- Register 80+ contextual theorem entries in `ProofStepExport.lean`
- Achieve assumption and weakening steps appearing in the exported proof step dataset
- Reach 7/7 inference rule coverage (up from 5/7)

**Non-Goals**:
- Modifying the `extractStepSequence` or `ProofStep` extraction infrastructure
- Achieving exactly 5% assumption or 3% weakening (targets are aspirational; actual percentages depend on step counts)
- Creating noncomputable theorems or importing the deduction theorem
- Modifying existing theorem files (Core.lean, Connectives.lean, etc.)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Computability failures with `by simp` proofs for membership/subset | Medium | Low | Test each theorem individually before bulk registration; use `by decide` or `by intro a; simp [List.mem_cons]` as alternatives |
| Lean type-checking slow for large registry additions | Low | Low | DerivationTree evaluation is fast for small proofs; 80 entries add minimal compile time |
| Step percentage targets unreachable without massive entry count | Medium | High | Document actual percentages; the primary goal is 7/7 rule coverage, not exact percentages |
| Import of ContextualProofs.lean creates unexpected dependency | Low | Low | File imports only Derivation.lean and Combinators.lean; no cycles possible |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Create ContextualProofs.lean with Core Theorems [COMPLETED]

**Goal**: Create the new file with 28 computable contextual derivations across three categories (propositional, modal, temporal).

**Tasks**:
- [ ] Create `Theories/Bimodal/Theorems/ContextualProofs.lean` with imports for `Bimodal.ProofSystem.Derivation` and `Bimodal.Theorems.Combinators`
- [ ] Implement Category A: Propositional in context (12 theorems)
  - [ ] `mp_in_context` : `[p -> q, p] |- q` (2 assumptions + 1 MP)
  - [ ] `mp_chain_2` : `[p -> q, q -> r, p] |- r` (3 assumptions + 2 MP)
  - [ ] `mp_chain_3` : `[p -> q, q -> r, r -> s, p] |- s` (4 assumptions + 3 MP)
  - [ ] `ecq_computable` : `[A, neg A] |- B` (re-derive without noncomputable)
  - [ ] `ldi_computable` : `[A] |- A or B` (re-derive without noncomputable)
  - [ ] `rdi_computable` : `[B] |- A or B` (re-derive without noncomputable)
  - [ ] `conj_proj_left` : `[A and B] |- A` (assumption + axiom + MP)
  - [ ] `conj_proj_right` : `[A and B] |- B` (assumption + axiom + MP)
  - [ ] `identity_in_ctx` : `[A] |- A` (single assumption)
  - [ ] `apply_in_ctx` : `[A, A -> B -> C, B] |- C` (3 assumptions + 2 MP)
  - [ ] `conj_intro_ctx` : `[A, B] |- A and B` (assumptions + pairing via weakening)
  - [ ] `weakened_axiom` : `[psi] |- box p -> p` (axiom weakened to non-empty context)
- [ ] Implement Category B: Modal in context (8 theorems)
  - [ ] `box_elim_ctx` : `[box A] |- A` (assumption + T axiom weakened + MP)
  - [ ] `box_4_ctx` : `[box A] |- box (box A)` (assumption + S4 axiom weakened + MP)
  - [ ] `box_b_ctx` : `[A] |- box (diamond A)` (assumption + B axiom weakened + MP)
  - [ ] `box_to_diamond_ctx` : `[box A] |- diamond A` (box_elim + T then B or direct)
  - [ ] `k_dist_ctx` : `[box(A -> B), box A] |- box B` (K distribution in context)
  - [ ] `box_pair_ctx` : `[box A, box B] |- box A and box B` (conjunction in context)
  - [ ] `diamond_5_ctx` : `[diamond A] |- box (diamond A)` (S5 axiom in context)
  - [ ] `box_to_future_ctx` : `[box A] |- G(A)` (modal-temporal bridge in context)
- [ ] Implement Category C: Temporal in context (8 theorems)
  - [ ] `temp_k_ctx` : `[G(A -> B), G(A)] |- G(B)` (temporal K distribution in context)
  - [ ] `connect_future_ctx` : `[A] |- G(P(A))` (connect_future weakened to context)
  - [ ] `connect_past_ctx` : `[A] |- H(F(A))` (connect_past weakened to context)
  - [ ] `box_future_ctx` : `[box A] |- G(box A)` (box_to_future weakened + composed)
  - [ ] `box_past_ctx` : `[box A] |- H(A)` (box_to_past weakened to context)
  - [ ] `until_F_ctx` : `[U(psi, phi)] |- F(psi)` (until_implies_some_future in context)
  - [ ] `since_P_ctx` : `[S(psi, phi)] |- P(psi)` (since_implies_some_past in context)
  - [ ] `serial_future_ctx` : `[A] |- F(top)` (serial_future weakened to context)
- [ ] Verify `lake build Bimodal.Theorems.ContextualProofs` compiles with no errors

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Theorems/ContextualProofs.lean` - NEW FILE: all 28 core contextual theorems

**Verification**:
- `lake build Bimodal.Theorems.ContextualProofs` passes with zero errors
- No `noncomputable` markers needed in the file
- All 28 definitions are computable (no sorry, no noncomputable)

---

### Phase 2: Add Weakening Variants and Multi-Instantiation [NOT STARTED]

**Goal**: Create weakening variants (extra unused assumptions) and multi-instantiation variants (different atom combinations) to multiply the step count.

**Tasks**:
- [ ] Add weakening variants for each Category A/B/C theorem (add 1-2 extra unused formulas to context)
  - [ ] `mp_in_context_weak` : `[p -> q, p, r] |- q` (weakened from [p -> q, p])
  - [ ] `mp_chain_2_weak` : `[p -> q, q -> r, p, s] |- r`
  - [ ] `ecq_computable_weak` : `[A, neg A, C] |- B`
  - [ ] `box_elim_ctx_weak` : `[box A, B] |- A`
  - [ ] `k_dist_ctx_weak` : `[box(A -> B), box A, C] |- box B`
  - [ ] `temp_k_ctx_weak` : `[G(A -> B), G(A), C] |- G(B)`
  - [ ] Plus ~14 more weakening variants covering remaining core theorems
- [ ] Add "pure weakening" entries: existing empty-context theorems weakened to non-empty contexts
  - [ ] `identity_weakened` : `[psi] |- A -> A` (identity weakened from [])
  - [ ] `b_combinator_weakened` : `[psi] |- (B -> C) -> (A -> B) -> (A -> C)`
  - [ ] `dni_weakened` : `[psi] |- A -> neg (neg A)`
  - [ ] `connect_future_weakened` : `[psi] |- A -> G(P(A))`
  - [ ] `perpetuity_1_weakened` : `[psi] |- G(A) -> A`
  - [ ] Plus ~15 more pure weakening entries for diverse existing theorems
- [ ] Add multi-instantiation variants using different atom combinations (q/r/s instead of p/q)
  - [ ] At least 20 multi-instantiation variants of core contextual theorems
- [ ] Verify `lake build Bimodal.Theorems.ContextualProofs` still compiles

**Timing**: 1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Theorems/ContextualProofs.lean` - ADD: weakening variants, pure weakening entries, multi-instantiation variants

**Verification**:
- `lake build Bimodal.Theorems.ContextualProofs` passes
- File contains at least 80 total theorem definitions
- All definitions remain computable (no sorry, no noncomputable)

---

### Phase 3: Register in ProofStepExport.lean [NOT STARTED]

**Goal**: Import `ContextualProofs.lean` in `ProofStepExport.lean` and register all contextual theorems in `theoremRegistry`.

**Tasks**:
- [ ] Add `import Bimodal.Theorems.ContextualProofs` to ProofStepExport.lean
- [ ] Add `open Bimodal.Theorems.ContextualProofs` to the namespace block
- [ ] Add new section header `-- ============================================================` / `-- ContextualProofs.lean (contextual theorems)` / `-- ============================================================`
- [ ] Register all Category A core theorems with `mkEntry` using concrete atoms (p, q, r, s)
- [ ] Register all Category B core theorems
- [ ] Register all Category C core theorems
- [ ] Register all weakening variants
- [ ] Register all pure weakening entries
- [ ] Register all multi-instantiation variants
- [ ] Update the docstring comment at the top of the file to reflect new entry count and categories
- [ ] Verify `lake build Bimodal.Automation.ProofStepExport` compiles

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - ADD: import, open, ~80+ new mkEntry registrations, updated docstring

**Verification**:
- `lake build Bimodal.Automation.ProofStepExport` passes
- `theoremRegistry` list includes all new entries
- No compile errors from new entries

---

### Phase 4: Validate and Measure Coverage [NOT STARTED]

**Goal**: Run the proof step extractor, verify assumption/weakening steps appear, and measure actual rule distribution percentages.

**Tasks**:
- [ ] Run `lake build` to verify full project compiles with all changes
- [ ] Run `lake exe proof_extractor -- --output /tmp/proof_steps_ctx.jsonl` to extract steps
- [ ] Verify the output JSONL contains records with `"rule": "assumption"`
- [ ] Verify the output JSONL contains records with `"rule": "weakening"`
- [ ] Count total steps and compute rule distribution percentages
- [ ] Verify 7/7 inference rules are now present (axiom, modus_ponens, necessitation, temporal_necessitation, temporal_duality, assumption, weakening)
- [ ] Update the docstring in ProofStepExport.lean with final counts and percentages
- [ ] Document actual assumption/weakening percentages vs. the aspirational 5%/3% targets

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - UPDATE: docstring with final validation results

**Verification**:
- `lake exe proof_extractor` runs successfully
- Output contains assumption and weakening rule entries
- 7/7 inference rules present in the output
- Docstring updated with final metrics

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `lake exe proof_extractor` produces valid JSONL output
- [ ] JSONL contains records with `"rule": "assumption"` (non-zero count)
- [ ] JSONL contains records with `"rule": "weakening"` (non-zero count)
- [ ] All 7 inference rules appear in the rule distribution
- [ ] No `noncomputable` markers in ContextualProofs.lean
- [ ] No `sorry` markers in ContextualProofs.lean
- [ ] Existing 310 theorems still extract correctly (no regression)

## Artifacts & Outputs

- `Theories/Bimodal/Theorems/ContextualProofs.lean` - New file: 80+ computable contextual derivations
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Modified: new import, 80+ registry entries, updated docstring
- `specs/244_context_proof_steps/plans/01_context-proof-steps.md` - This plan

## Rollback/Contingency

If ContextualProofs.lean causes build issues:
1. Remove the `import Bimodal.Theorems.ContextualProofs` line from ProofStepExport.lean
2. Remove the registry entries for contextual theorems
3. The existing 310-theorem registry continues to work unchanged

If individual theorems fail computability checks:
1. Comment out the failing theorem and its registry entry
2. Investigate whether the proof needs restructuring (avoid `Classical.propDecidable`)
3. Proceed with the computable subset

The changes are purely additive -- no existing code is modified except ProofStepExport.lean (adding imports and entries). Reverting is straightforward.
