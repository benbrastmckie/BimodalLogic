# Implementation Plan: Full Axiom and Rule Coverage

- **Task**: 243 - full_axiom_rule_coverage
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: Task 242
- **Research Inputs**: specs/243_full_axiom_rule_coverage/reports/01_axiom-rule-coverage.md
- **Artifacts**: plans/01_axiom-rule-coverage.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Achieve 42/42 axiom name coverage and 7/7 inference rule coverage in the proof step dataset by adding direct registry entries to `ProofStepExport.lean` for the 11 missing axioms and 2 missing rules, plus a coverage tracking function. The missing axioms break into three categories: 1 Base axiom (peirce), 5 Base-compatible uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity), 3 Discrete axioms (prior_UZ, prior_SZ, z1), and 2 Dense axioms (density, dense_indicator). The missing rules (assumption, weakening) require entries with non-empty contexts.

### Research Integration

The research report (01_axiom-rule-coverage.md) identified all 11 missing axioms and 2 missing rules with root causes. Key correction from codebase verification: the 5 uniformity axioms (discrete_symm_fwd/bwd, discrete_propagate_fwd/bwd, discrete_box_necessity) have `minFrameClass = .Base` (caught by the wildcard in `Axiom.minFrameClass`), not `.Discrete` as stated in the research report. This simplifies Phase 2 since these axioms can use `fc := .Base`. However, for semantic accuracy in training data, entries should use `fc := .Discrete` where the axiom pertains to discrete properties. Only prior_UZ, prior_SZ, z1 strictly require `fc := .Discrete`, and density, dense_indicator strictly require `fc := .Dense`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Achieve 42/42 axiom name coverage in proof step dataset
- Achieve 7/7 inference rule coverage in proof step dataset
- Add coverage tracking to the export script (print summary, identify gaps)
- Maintain `lake build` passing with no regressions
- Add multi-step derivation diversity (not just single-axiom entries)

**Non-Goals**:
- Modifying the decision procedure (`decideAuto`) to support non-Base frame classes
- Achieving specific percentage targets for assumption/weakening rules (that is task 244)
- Changing the `TableauProofStepPipeline.lean` tableau-based pipeline
- Adding new axiom constructors or modifying `Axioms.lean`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Computability issues with manual DerivationTree construction | M | L | All constructors are structural; `by simp` proofs on concrete lists are decidable |
| `by simp` membership proofs fail for context entries | M | L | Fall back to `by decide` or explicit proof terms |
| Incorrect axiom name serialization for non-Base frame classes | M | L | The `extractStepSequence` function already handles all frame classes via `fcStr` parameter; verify by running extractor |
| Registry size increase causes build timeout | L | L | Adding ~30-50 entries to a 310-entry list is modest; watch for compilation time |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Peirce and Non-Base Axiom Coverage (11 axioms) [COMPLETED]

**Goal**: Add direct axiom entries for all 11 missing axioms to the theorem registry, achieving 42/42 axiom coverage.

**Tasks**:
- [ ] Add `peirce` axiom entries (Base frame class, 2 instantiations: `peirce p q` and `peirce q r`)
- [ ] Add 5 uniformity axiom entries with `fc := .Discrete` for semantic accuracy: `discrete_symm_fwd`, `discrete_symm_bwd`, `discrete_propagate_fwd`, `discrete_propagate_bwd`, `discrete_box_necessity` (these are parameterless axiom constructors)
- [ ] Add 3 Discrete axiom entries: `prior_UZ p`, `prior_SZ p`, `z1 p` with `fc := .Discrete`
- [ ] Add 2 Dense axiom entries: `density p`, `dense_indicator` with `fc := .Dense`
- [ ] Add G-wrapped and H-wrapped variants for parameterized axioms (peirce, prior_UZ, prior_SZ, z1, density) to increase multi-step diversity
- [ ] Add multi-instantiation variants with alternative atoms (q, r) for parameterized axioms
- [ ] Build a computable `double_negation` theorem manually using `Axiom.peirce` to generate a multi-step proof (7 steps using peirce + prop_k + prop_s + ex_falso + modus_ponens) *(deviation: skipped -- peirce coverage achieved via direct axiom entries and G/H/GG wraps; manual DerivationTree construction adds complexity without coverage benefit)*
- [ ] Verify all new entries compile: `lake build Bimodal.Automation.ProofStepExport`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Add ~40-50 new entries to `theoremRegistry`

**Verification**:
- `lake build Bimodal.Automation.ProofStepExport` passes
- New entries added to the registry list
- All 11 previously-missing axiom names will appear in the output

---

### Phase 2: Assumption and Weakening Rule Coverage (2 rules) [COMPLETED]

**Goal**: Add entries with non-empty contexts to exercise the `assumption` and `weakening` inference rules.

**Tasks**:
- [ ] Add `assumption` entries: `[p] |- p` using `DerivationTree.assumption [p] p (by simp)`
- [ ] Add `assumption` in compound derivation: `[p, p.imp q] |- q` using `modus_ponens` on two `assumption` sub-trees
- [ ] Add `weakening` entry: derive `[p, q] |- p` by weakening `[p] |- p` with subset proof `(by intro x hx; simp at hx |- *; exact Or.inl hx)` or `(by intro x hx; simp_all)`
- [ ] Add `weakening` of axiom: derive `[p] |- prop_k p q r` by weakening the empty-context axiom with subset proof `(by intro x hx; exact absurd hx (List.not_mem_nil x))`
- [ ] Add G-wrapped variants of contextual entries if possible (temporal_necessitation requires empty context, so this applies only to theorems, not contextual derivations -- skip if type-checking fails)
- [ ] Verify all new context-based entries compile: `lake build Bimodal.Automation.ProofStepExport`

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Add ~6-10 new entries with non-empty contexts

**Verification**:
- `lake build Bimodal.Automation.ProofStepExport` passes
- New entries with non-empty `context` fields in JSON output
- Both `assumption` and `weakening` rule names appear in extracted steps

---

### Phase 3: Coverage Tracking Function [COMPLETED]

**Goal**: Add a coverage analysis function to `ProofStepExport.lean` that prints axiom/rule coverage after extraction.

**Tasks**:
- [ ] Define `allAxiomNames : List String` containing all 42 canonical axiom name strings
- [ ] Define `allRuleNames : List String` containing all 7 canonical rule name strings
- [ ] Implement `computeCoverage` function that takes `List ProofStep`, computes unique axiom names and rule names, and returns coverage counts plus missing lists
- [ ] Implement `printCoverage` function that formats coverage as a summary report to stdout
- [ ] Integrate `printCoverage` into the `main` function after `processRegistry` completes, passing the accumulated proof steps
- [ ] Modify `processRegistry` to also return the flat list of `ProofStep` records (currently only returns JSONL strings) -- or parse axiom/rule names from the JSONL strings during accumulation
- [ ] Verify coverage output shows 42/42 axioms and 7/7 rules

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Add ~40-60 lines for coverage tracking

**Verification**:
- Running `lake exe proof_extractor` prints coverage summary at the end
- Coverage report shows 42/42 axioms and 7/7 rules
- Any remaining gaps are clearly identified in the output

---

### Phase 4: Full Build Verification and Dataset Regeneration [NOT STARTED]

**Goal**: Verify the complete build passes, regenerate the proof step dataset, and validate final coverage.

**Tasks**:
- [ ] Run `lake build` (full project) to verify no regressions
- [ ] Run `lake exe proof_extractor -- --output data/proof_steps.jsonl` to regenerate the dataset
- [ ] Verify the output JSONL file contains all 42 axiom names: `jq -r '.axiom_name // empty' data/proof_steps.jsonl | sort -u | wc -l` should output 42
- [ ] Verify the output JSONL file contains all 7 rule names: `jq -r '.rule' data/proof_steps.jsonl | sort -u | wc -l` should output 7
- [ ] Verify total step count and theorem count are reasonable (should be ~10,100-10,200 steps from ~340-360 theorems)
- [ ] Update the module docstring at the top of `ProofStepExport.lean` with updated inventory counts and validation results

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/ProofStepExport.lean` - Update module docstring with new counts
- `data/proof_steps.jsonl` - Regenerated output file

**Verification**:
- `lake build` passes with zero errors
- Coverage report in stdout shows 42/42 axioms, 7/7 rules
- JSONL file is valid (all lines parse as JSON)
- Module docstring reflects updated counts

## Testing & Validation

- [ ] `lake build Bimodal.Automation.ProofStepExport` compiles with no errors
- [ ] `lake build` (full project) passes with no regressions
- [ ] `lake exe proof_extractor` runs successfully and produces valid JSONL
- [ ] 42/42 axiom names present in output (verify with `jq`)
- [ ] 7/7 inference rule names present in output (verify with `jq`)
- [ ] Coverage tracking function prints correct summary to stdout
- [ ] All JSONL lines are valid JSON with required fields
- [ ] axiom_name is non-null iff rule = "axiom" (zero violations)

## Artifacts & Outputs

- `specs/243_full_axiom_rule_coverage/plans/01_axiom-rule-coverage.md` (this plan)
- `Theories/Bimodal/Automation/ProofStepExport.lean` (modified: new entries + coverage tracking)
- `data/proof_steps.jsonl` (regenerated dataset with full coverage)

## Rollback/Contingency

All changes are additions to `ProofStepExport.lean` -- no existing entries or functions are modified. To revert, remove the new registry entries and coverage tracking function. The existing 310 entries and their extraction logic remain untouched. If individual entries cause compilation issues, they can be commented out independently without affecting other entries.
